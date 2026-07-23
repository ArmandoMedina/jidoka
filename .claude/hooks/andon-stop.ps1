# andon-stop.ps1 - Stop hook. Si al cerrar hay doc-drift (segun la ley,
# tools/blast-radius.json), frena el cierre y manda al Escribano a sincronizar.
# Cuando todos los docs duenos estan sincronizados, el hook deja cerrar solo.
# Jidoka corre su propio Andon (dogfooding). Archivo ASCII (sin acentos) a proposito.
#
# VENTANA: este hook evalua git status --porcelain (cambios SIN commitear).
# El gate de push (verificar.ps1) evalua @{u}..HEAD (commiteado sin pushear).
# Si committeas sin docs, esta ventana ya no detecta el drift: lo atrapan
# verificar.ps1 al push y el CI (andon.yml) sobre el rango del PR.
#
# Matcher: comodines -like; un patron SIN '/' solo casa archivos en la raiz del
# repo; 'excluye' (opcional) resta rutas; 'mensaje' (opcional) se anexa al aviso.

$ErrorActionPreference = 'Continue'

# ALTO-04 (leccion del laboratorio de campo): cada git real revisa $LASTEXITCODE.
# Si git falla de verdad (no instalado, repo corrupto), se AVISA en vez de callar:
# tratar un fallo como "sin cambios" es un gate podrido en silencio. El hook no
# bloquea por esto (es aviso); los que fallan cerrado son verificar.ps1 y el CI.
function Avisa-SinVeredicto($detalle) {
  $out = @{
    hookSpecificOutput = @{
      hookEventName     = 'Stop'
      additionalContext = "[AVISO] andon-stop no pudo medir: $detalle. El gate de cierre queda sin veredicto esta vez; verificar.ps1 (pre-push) y el CI si fallan cerrado."
    }
  }
  $out | ConvertTo-Json -Compress -Depth 5
  exit 0
}

# 1. Leer el input del hook. Si este stop YA viene de un stop-hook, no re-bloquear.
$raw = [Console]::In.ReadToEnd()
try { $inp = $raw | ConvertFrom-Json } catch { $inp = $null }
if ($inp -and $inp.stop_hook_active) { exit 0 }

# 2. Obtener lista de archivos con cambios sin commitear.
if ($env:CLAUDE_PROJECT_DIR) { Set-Location $env:CLAUDE_PROJECT_DIR }
$repoRaw = git rev-parse --show-toplevel 2>&1
if ($LASTEXITCODE -ne 0) { Avisa-SinVeredicto "git rev-parse fallo o no hay repo ($("$repoRaw".Trim() -split "`n" | Select-Object -First 1))" }
$repo = "$repoRaw".Trim()
# -uall (--untracked-files=all): sin esto git COLAPSA un directorio recien-nacido y sin
# trackear en una sola entrada 'dir/', y el glob de 'fuente' no casa -> el gate falla-
# ABIERTO justo en el deliverable nuevo que existe para atrapar (issue #50).
$statusRaw = git status --porcelain --untracked-files=all 2>&1
if ($LASTEXITCODE -ne 0) { Avisa-SinVeredicto "git status fallo ($("$statusRaw".Trim() -split "`n" | Select-Object -First 1))" }
$changed = @($statusRaw) | ForEach-Object { $s = "$_"; if ($s.Length -gt 3) { $s.Substring(3).Trim() } }
if (-not $changed) { exit 0 }

# 3. Leer el manifiesto unico de blast-radius (la ley).
$manifestPath = Join-Path $repo 'tools/blast-radius.json'
# FALLA CERRADA (R5): sin la ley el muro no puede saber que docs dueno exige el cambio -> NO apruebo a
# ciegas. Antes salia exit 0 (silencio, dejaba cerrar). Alineado con el criterio de fallar-cerrado del gate.
if (-not (Test-Path $manifestPath)) {
  [Console]::Error.WriteLine("BLOQUEO (andon-stop): no encuentro la ley tools/blast-radius.json. No apruebo a ciegas: sin la ley el muro no sabe que docs dueno hay que sincronizar. Restaura tools/blast-radius.json (o corre el instalador) antes de cerrar.")
  exit 2
}
# FALLA CERRADA (R5, camino gemelo): la ley EXISTE pero NO parsea (JSON corrupto/truncado) es la
# MISMA clase de "aprobar a ciegas" que la ley ausente -- NO un hipo de git (eso sigue en Avisa-
# SinVeredicto por ALTO-04). Un JSON corrupto (edicion interrumpida) se dispara mas facil que borrar
# el archivo, y antes salia exit 0 (solo aviso, dejaba cerrar). Ahora falla cerrado igual que ausente.
try { $manifest = Get-Content $manifestPath -Raw -ErrorAction Stop | ConvertFrom-Json -ErrorAction Stop }
catch {
  [Console]::Error.WriteLine("BLOQUEO (andon-stop): la ley tools/blast-radius.json existe pero no puedo medirla (JSON corrupto/truncado): $($_.Exception.Message). No apruebo a ciegas: sin poder leer la ley el muro no sabe que docs dueno exige el cambio. Repara tools/blast-radius.json (o corre el instalador) antes de cerrar.")
  exit 2
}
if (-not $manifest) {
  [Console]::Error.WriteLine("BLOQUEO (andon-stop): la ley tools/blast-radius.json parseo a algo vacio/no-usable. No apruebo a ciegas: sin la ley el muro no sabe que docs dueno hay que sincronizar. Repara tools/blast-radius.json antes de cerrar.")
  exit 2
}
# FALLA CERRADA (R5, camino gemelo): la ley parsea a un objeto/array SIN NINGUNA entrada de area usable
# (un '{}' objeto vacio parsea a un PSCustomObject truthy que ESQUIVA el guard '-not $manifest' de arriba,
# y caeria al camino normal aprobando a ciegas en silencio). "Usable" = al menos un area con nombre+fuente.
# OJO: esto NO rompe la dormancia legitima -- una ley VALIDA con areas donde ninguna aplica al diff SI
# tiene entradas usables (pasa este guard) y sigue su camino normal a exit 0.
$areasUsables = @($manifest | Where-Object { $_ -and $_.nombre -and $_.fuente })
if ($areasUsables.Count -eq 0) {
  [Console]::Error.WriteLine("BLOQUEO (andon-stop): la ley tools/blast-radius.json no tiene contenido usable (ninguna entrada de area con nombre+fuente; p.ej. un objeto vacio '{}'). No apruebo a ciegas: sin la ley el muro no sabe que docs dueno hay que sincronizar. Repara tools/blast-radius.json antes de cerrar.")
  exit 2
}

function Test-Pattern($path, $pattern) {
  # Patron sin '/' = solo raiz del repo (un '*.md' no debe casar docs/x.md).
  if ($pattern -notlike '*/*' -and $path -like '*/*') { return $false }
  return ($path -like $pattern)
}
function Match-Any($list, $pattern) {
  foreach ($item in $list) { if (Test-Pattern $item $pattern) { return $true } }
  return $false
}

# 4. Detectar drift: doc_bloquea faltantes bloquean; doc_avisa solo acompana
#    el mensaje (los avisos puros los cobran verificar.ps1 y el CI).
$faltas = @()
$avisos = @()
foreach ($entry in $manifest) {
  $tocados = @()
  foreach ($f in $changed) {
    $enFuente = $false
    foreach ($pat in $entry.fuente) { if (Test-Pattern $f $pat) { $enFuente = $true; break } }
    if ($enFuente -and $entry.excluye) {
      foreach ($ex in $entry.excluye) { if (Test-Pattern $f $ex) { $enFuente = $false; break } }
    }
    if ($enFuente) { $tocados += $f }
  }
  if ($tocados.Count -eq 0) { continue }

  foreach ($tgt in $entry.doc_bloquea) {
    if (-not (Match-Any $changed $tgt)) {
      $faltas += "area '$($entry.nombre)' (tocaste $(($tocados | Select-Object -First 3) -join ', ')): falta su doc dueno '$tgt' (rol $($entry.rol))"
    }
  }
  foreach ($tgt in $entry.doc_avisa) {
    if ($tgt -and -not (Match-Any $changed $tgt)) {
      $linea = "area '$($entry.nombre)': revisa '$tgt' (rol $($entry.rol))"
      if ($entry.mensaje) { $linea += " - $($entry.mensaje)" }
      $avisos += $linea
    }
  }
  # product_avisa: el grafo de producto. Aviso unico por area si no se toco ninguna nota.
  if ($entry.product_avisa -and $entry.product_avisa.Count -gt 0) {
    $tocoProducto = $false
    foreach ($tgt in $entry.product_avisa) { if (Match-Any $changed $tgt) { $tocoProducto = $true; break } }
    if (-not $tocoProducto) {
      $ej = ($entry.product_avisa | Select-Object -First 2) -join ', '
      $avisos += "area '$($entry.nombre)': tocaste el area sin tocar el grafo de producto (ej: $ej). Si la capacidad cambio, actualiza su nota en product/."
    }
  }
}

# 5. Sin drift en doc_bloquea: dejar cerrar. Con drift: bloquear y mandar al Escribano.
if ($faltas.Count -eq 0) { exit 0 }

$ctx = "Doc-drift (la ley: tools/blast-radius.json). BLOQUEA: " + ($faltas -join '; ') + ". "
if ($avisos.Count -gt 0) { $ctx += "AVISOS no bloqueantes (verificar y el CI los re-verifican): " + (($avisos | Select-Object -First 5) -join '; ') + ". " }
$ctx += "Sincroniza los docs duenos antes de cerrar. Si el cambio implica una DECISION (no solo codigo), " +
        "no la escribas suelta: agrega un ADR en docs/decisions/ y listalo en el indice. " +
        "NOTA: este hook ve cambios sin commitear (working tree). Si ya committeaste sin los docs, " +
        "el drift lo atrapan verificar.ps1 al push y el CI (andon.yml)."
# El texto rico va en 'reason': es el campo que documentadamente llega al modelo
# en un Stop hook (additionalContext no esta documentado para Stop; se conserva
# por si el harness lo aprovecha, pero no se depende de el).
$out = @{
  decision = 'block'
  reason   = $ctx
  hookSpecificOutput = @{
    hookEventName     = 'Stop'
    additionalContext = $ctx
  }
}
$out | ConvertTo-Json -Compress -Depth 5
exit 0
