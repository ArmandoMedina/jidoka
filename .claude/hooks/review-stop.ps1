# review-stop.ps1 - Stop hook. Si hay codigo sin revisar en el rango de cierre,
# frena y manda a correr /code-review. Cosechado de los labs (criterio-no-copia,
# ADR 0007): en el origen el area de codigo estaba hardcodeada a una carpeta fija; aqui se
# LEE de la ley (tools/blast-radius.json) -- las areas con "revisa": true aportan
# sus 'fuente' globs. Si ninguna area lo pide, el hook se declara dormido.
# Usa un marcador con el SHA del diff ya revisado (.claude/.review-marker,
# gitignored) para no re-revisar lo mismo: se termina solo. NO es auto-firma: el
# humano lo pone tras revisar, y el hook verifica que el SHA sea el del diff real.
# Archivo ASCII a proposito (PS 5.1 sin BOM). Disparos: no-verify-es-teatro,
# prueba-de-vida-del-gate.
#
# ERRORES (ALTO-04): sin $ErrorActionPreference global. Cada git real revisa
# $LASTEXITCODE; si git falla de verdad (no "sin cambios" sino fallo real), el
# hook AVISA (additionalContext, sin decision=block) en vez de callar.

# Evitar bucle si este stop ya viene de un stop-hook.
$raw = [Console]::In.ReadToEnd()
try { $inp = $raw | ConvertFrom-Json } catch { $inp = $null }
if ($inp -and $inp.stop_hook_active) { exit 0 }

if ($env:CLAUDE_PROJECT_DIR) { Set-Location $env:CLAUDE_PROJECT_DIR }
$repo = (git rev-parse --show-toplevel 2>$null)
if (-not $repo) { exit 0 }

function Write-GitFailWarning($comando, $detalle) {
  $ctx = "AVISO (review-stop): '$comando' fallo (exit $LASTEXITCODE): $detalle. " +
         "No se pudo comprobar si hay codigo sin revisar; revisalo a mano con /code-review antes de cerrar."
  $out = @{ hookSpecificOutput = @{ hookEventName = 'Stop'; additionalContext = $ctx } }
  $out | ConvertTo-Json -Compress -Depth 5
}

# Areas de codigo del manifiesto (las que piden "revisa": true). Se auto-configura.
$manifestPath = Join-Path $repo 'tools/blast-radius.json'
# FALLA CERRADA (R5): sin la ley el muro no puede saber que codigo se toco -> NO apruebo a ciegas.
# Antes salia exit 0 (silencio, dejaba cerrar). Alineado con el criterio de fallar-cerrado del gate.
if (-not (Test-Path $manifestPath)) {
  [Console]::Error.WriteLine("BLOQUEO (review-stop): no encuentro la ley tools/blast-radius.json. No apruebo a ciegas: sin la ley el muro no sabe que codigo exige revision. Restaura tools/blast-radius.json (o corre el instalador) antes de cerrar.")
  exit 2
}
# FALLA CERRADA (R5, camino gemelo): la ley EXISTE pero NO parsea (JSON corrupto/truncado) es la MISMA
# clase de "aprobar a ciegas" que la ley ausente -- antes salia exit 0 (silencio, dejaba cerrar). Un
# JSON corrupto (edicion interrumpida) se dispara mas facil que borrar el archivo. Ahora falla cerrado.
try { $manifest = Get-Content $manifestPath -Raw -ErrorAction Stop | ConvertFrom-Json -ErrorAction Stop }
catch {
  [Console]::Error.WriteLine("BLOQUEO (review-stop): la ley tools/blast-radius.json existe pero no puedo medirla (JSON corrupto/truncado): $($_.Exception.Message). No apruebo a ciegas: sin poder leer la ley el muro no sabe que codigo exige revision. Repara tools/blast-radius.json (o corre el instalador) antes de cerrar.")
  exit 2
}
if (-not $manifest) {
  [Console]::Error.WriteLine("BLOQUEO (review-stop): la ley tools/blast-radius.json parseo a algo vacio/no-usable. No apruebo a ciegas: sin la ley el muro no sabe que codigo exige revision. Repara tools/blast-radius.json antes de cerrar.")
  exit 2
}
$areasCod = @($manifest | Where-Object { $_.revisa -eq $true })
if ($areasCod.Count -eq 0) { exit 0 }   # dormido: ninguna area pide revision

function Test-Pattern($path, $pattern) {
  if ($pattern -notlike '*/*' -and $path -like '*/*') { return $false }
  return ($path -like $pattern)
}

# Codigo sin commitear que caiga en un area de revision. -uall (--untracked-files=all):
# sin esto git COLAPSA un directorio recien-nacido y sin trackear en una sola entrada
# 'dir/', y el glob de 'fuente' no casa -> el gate falla-ABIERTO justo en el deliverable
# nuevo que existe para atrapar (issue #50). Con -uall lista archivo por archivo.
$statusRaw = git -c core.quotepath=false status --porcelain --untracked-files=all 2>&1
if ($LASTEXITCODE -ne 0) { Write-GitFailWarning 'git status --porcelain' ($statusRaw -join ' '); exit 0 }
# Se conserva CUALES estan sin rastrear (codigo '??'): git diff HEAD no ve su contenido, asi que
# el hash de mas abajo tiene que anexarlo aparte (si no, un archivo nuevo escapa del marcador).
$changed = @()
$untracked = @{}
foreach ($ln in @($statusRaw)) {
  $s = "$ln"
  if ($s.Length -le 3) { continue }
  $f = $s.Substring(3).Trim()
  $changed += $f
  if ($s.Substring(0,2) -eq '??') { $untracked[$f] = $true }
}
$codChanged = @()
foreach ($f in $changed) {
  foreach ($area in $areasCod) {
    $hit = $false
    foreach ($pat in $area.fuente) { if (Test-Pattern $f $pat) { $hit = $true; break } }
    if ($hit -and $area.excluye) {
      foreach ($ex in $area.excluye) { if (Test-Pattern $f $ex) { $hit = $false; break } }
    }
    if ($hit) { $codChanged += $f; break }
  }
}
if ($codChanged.Count -eq 0) { exit 0 }

# SHA del estado revisable actual. git diff HEAD ve el contenido de los archivos RASTREADOS pero
# NO el de los archivos SIN RASTREAR (nuevos): sin esto, un archivo nuevo del area revisada podia
# cambiar de contenido sin mover el SHA -> el marcador de "revisado" no lo cubre (medido en vivo
# 2026-07-23). Por eso el payload anexa el CONTENIDO de cada archivo sin rastrear del area.
$diffRaw = git diff HEAD -- $codChanged 2>&1
if ($LASTEXITCODE -ne 0) { Write-GitFailWarning 'git diff HEAD -- <codigo>' ($diffRaw -join ' '); exit 0 }
$payload = (($diffRaw) -join "`n") + "|" + (($codChanged) -join "`n")
foreach ($f in $codChanged) {
  if ($untracked[$f]) {
    $abs = Join-Path $repo $f
    $body = ''
    if (Test-Path -LiteralPath $abs) { $body = (Get-Content -LiteralPath $abs -Raw -ErrorAction SilentlyContinue) }
    $payload += "`n>>SIN-RASTREAR:$f`n" + [string]$body
  }
}
$sha1 = New-Object System.Security.Cryptography.SHA1Managed
$sha = [System.BitConverter]::ToString($sha1.ComputeHash([System.Text.Encoding]::UTF8.GetBytes($payload))).Replace('-','')
# Semilla de diagnostico SOLO para el self-test (el harness nunca la enciende): expone el SHA por
# stderr para poder comprobar que CAMBIA cuando cambia un archivo sin rastrear (defecto 2, R3).
if ($env:JIDOKA_REVIEW_EMIT_SHA) { [Console]::Error.WriteLine("REVIEW_SHA=$sha") }

$marker = Join-Path $repo '.claude\.review-marker'
$last = if (Test-Path $marker) { (Get-Content $marker -Raw).Trim() } else { '' }
if ($sha -eq $last) { exit 0 }   # este diff exacto ya se reviso

$ctx = "Hay codigo sin revisar (" + (($codChanged | Select-Object -First 5) -join ', ') + "). " +
       "Corre /code-review sobre el diff actual ANTES de cerrar (y antes del escribano). " +
       "No uses --no-verify ni maquilles el estado staged para pasar (disparo no-verify-es-teatro): " +
       "el muro real es el required check server-side. La firma del marcador de revision " +
       "(.claude/.review-marker) la pone un HUMANO tras revisar, no el agente: este hook NO dicta el " +
       "comando de firma -- dictarlo seria entregar la llave junto a la cerradura."
$out = @{
  decision = 'block'
  reason   = 'Codigo sin revisar. Corre /code-review sobre el diff antes de cerrar.'
  hookSpecificOutput = @{ hookEventName = 'Stop'; additionalContext = $ctx }
}
$out | ConvertTo-Json -Compress -Depth 5
exit 0
