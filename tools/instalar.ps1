#Requires -Version 5
# instalar.ps1 - El instalador minimo de Jidoka (Sprint 3, Fase 3.A). Siembra el
# metodo (ritual + motor Andon) en un repo destino. MVP Windows-first (ADR 0008):
# lee el motor GENERICO del propio arbol de Jidoka y lo copia -- NO duplica la ley
# (verificar.ps1 y auditar.ps1 ya son data-driven). Solo la ley se siembra desde
# una PLANTILLA por arquetipo. El npx jidoka-method (npm, cross-platform) es una
# fase posterior; ver ROADMAP.
#
# Regla dura: NO CLOBBER. Nunca sobrescribe un archivo existente en el destino
# (lo salta y lo reporta) -- instalar sobre un repo con trabajo no borra nada.
#
# Uso:
#   ./tools/instalar.ps1 -Destino C:\ruta\repo-limpio                 (instalar)
#   ./tools/instalar.ps1 -Destino ... -Arquetipo docs-as-code -Yes    (instalar sin prompt)
#   ./tools/instalar.ps1 -Destino ... -Actualizar                     (bajar la mecanica al hijo)
#   ./tools/instalar.ps1 -Destino ... -Sellar                         (sellar un hijo que convergio a mano)
# Nota: archivo ASCII a proposito (sin acentos) para PS 5.1.

[CmdletBinding()]
param(
  [Parameter(Mandatory = $true)][string]$Destino,
  [string]$Arquetipo = '',   # vacio = no se paso: pregunta interactivo (o docs-as-code con -Yes)
  [switch]$Yes,
  [switch]$Actualizar,
  [switch]$Sellar
)

$ErrorActionPreference = 'Stop'
$jidoka = Split-Path -Parent $PSScriptRoot   # raiz de Jidoka (padre de tools/)
$script:copiados = 0
$script:saltados = 0
$script:stubs = 0

function Info($m) { Write-Host "  $m" }
function Ok($m)   { Write-Host "  [OK] $m"   -ForegroundColor Green }
function Skip($m) { Write-Host "  [SALTA] $m (ya existe; no se sobrescribe)" -ForegroundColor Yellow }
function Die($m)  { Write-Host "[ERROR] $m" -ForegroundColor Red; exit 1 }

# Copia un archivo si el destino NO existe (no clobber). Crea el directorio padre.
function Copy-Safe($src, $dst) {
  if (Test-Path -LiteralPath $dst) { Skip $dst; $script:saltados++; return }
  $parent = Split-Path -Parent $dst
  if ($parent -and -not (Test-Path -LiteralPath $parent)) { New-Item -ItemType Directory -Path $parent -Force | Out-Null }
  Copy-Item -LiteralPath $src -Destination $dst -Force
  $script:copiados++
}

# Copia un directorio recursivo, archivo por archivo, respetando no-clobber.
function Copy-DirSafe($srcDir, $dstDir) {
  Get-ChildItem -LiteralPath $srcDir -Recurse -File | ForEach-Object {
    $rel = $_.FullName.Substring($srcDir.Length).TrimStart('\', '/')
    Copy-Safe $_.FullName (Join-Path $dstDir $rel)
  }
}

# SHA256 del CONTENIDO NORMALIZADO A LF (sin CR): el hash es AGNOSTICO al fin de
# linea. Sin esto, un hijo con politica eol=lf (working tree en LF) diverge de un
# Jidoka con eol=crlf en TODAS las piezas, para siempre -- el three-way compara
# hash(LF) vs seed(CRLF) y nunca casan (defecto cazado al bajar a tracker-financiero;
# ADR 0021). El motor es 100% texto; normalizar quitando 0x0D es seguro aqui.
function Get-MotorHash($path) {
  $bytes = [System.IO.File]::ReadAllBytes($path)
  $sinCR = New-Object System.Collections.Generic.List[byte]
  foreach ($b in $bytes) { if ($b -ne 13) { $sinCR.Add($b) } }
  $sha = [System.Security.Cryptography.SHA256]::Create()
  try { $h = $sha.ComputeHash($sinCR.ToArray()) } finally { $sha.Dispose() }
  return ([System.BitConverter]::ToString($h) -replace '-', '')
}

# Enumera los archivos que una entrada de motor cubre en $root (aplana dirs).
# Devuelve objetos { rel = ruta relativa con '/'; abs = ruta absoluta }.
function Get-MotorFiles($entry, $root) {
  $dst = Join-Path $root $entry.destino
  if (-not (Test-Path -LiteralPath $dst)) { return @() }
  if ($entry.dir) {
    return Get-ChildItem -LiteralPath $dst -Recurse -File | ForEach-Object {
      $rel = $_.FullName.Substring($root.Length).TrimStart('\', '/').Replace('\', '/')
      [pscustomobject]@{ rel = $rel; abs = $_.FullName }
    }
  }
  return ,([pscustomobject]@{ rel = ($entry.destino.Replace('\', '/')); abs = $dst })
}

# ---------------------------------------------------------------------------
# Modo -Actualizar: re-siembra SOLO la mecanica (clase=mecanica) con conciencia
# de TRES VIAS por hash (estilo dpkg conffiles). Por cada archivo de motor:
#   - hijo ausente                       -> lo agrega (nuevo en esta version)
#   - hijo == Jidoka                     -> al dia (no toca)
#   - hijo == hash sembrado (no lo toco) -> lo actualiza a la version de Jidoka
#   - hijo != hash sembrado (lo customizo) -> DIVERGENCIA: NO pisa; escribe
#                                             <archivo>.jidoka-nuevo y lo reporta
# La INSTANCIA (ley, stubs, product/, HANDOFF, ADRs) nunca se toca: solo se itera
# 'motor'. El sello registra la version de Jidoka a la que se sincronizo y, por
# archivo, el hash que Jidoka ENVIA ahora (para el siguiente -Actualizar).
function Invoke-Actualizar($jidoka, $manif, $Destino, $utf8) {
  $selloDst = Join-Path $Destino 'tools/jidoka-motor.json'
  if (-not (Test-Path -LiteralPath $selloDst)) {
    Die "no hay sello (tools/jidoka-motor.json) en '$Destino': no parece un hijo instalado. Usa la instalacion normal (sin -Actualizar)."
  }
  $sello = Get-Content $selloDst -Raw | ConvertFrom-Json
  $seed = @{}
  if ($sello.sembrado_hashes) {
    foreach ($p in $sello.sembrado_hashes.PSObject.Properties) { $seed[$p.Name] = $p.Value }
  }
  $versionPath = Join-Path $jidoka 'tools/version.txt'
  $versionNueva = if (Test-Path $versionPath) { (Get-Content $versionPath -Raw).Trim() } else { 'desconocida' }

  Write-Host "== Actualizar motor: hijo en Jidoka $($sello.version) -> Jidoka $versionNueva =="
  if ($sello.version -eq $versionNueva) { Info "(el sello ya declara $versionNueva; re-checando piezas por si cambiaron)" }

  $nuevoSeed = [ordered]@{}
  $alDia = 0; $agregados = 0; $actualizados = 0; $divergen = @()

  # Limite conocido (estilo dpkg): -Actualizar re-siembra el motor ACTUAL de Jidoka.
  # NO borra piezas que una version futura de Jidoka haya retirado -- un archivo viejo
  # sigue en el hijo y cae del sello sin aviso. Removerlas es decision aparte (arriesga
  # pisar algo que el hijo aun usa); por ahora se prefiere no borrar.
  foreach ($e in $manif.motor) {
    if ($e.clase -and $e.clase -ne 'mecanica') { continue }        # solo la mecanica converge
    $srcRoot = Join-Path $jidoka $e.origen
    if (-not (Test-Path -LiteralPath $srcRoot)) { continue }        # origen ausente en Jidoka: nada que sembrar

    # Aplana la entrada a pares (rel, origen-abs) usando el arbol de Jidoka como verdad.
    $pares = @()
    if ($e.dir) {
      Get-ChildItem -LiteralPath $srcRoot -Recurse -File | ForEach-Object {
        $relEnOrigen = $_.FullName.Substring($srcRoot.Length).TrimStart('\', '/').Replace('\', '/')
        $relDst = ($e.destino.Replace('\', '/')).TrimEnd('/') + '/' + $relEnOrigen
        $pares += [pscustomobject]@{ rel = $relDst; src = $_.FullName }
      }
    } else {
      $pares += [pscustomobject]@{ rel = $e.destino.Replace('\', '/'); src = $srcRoot }
    }

    foreach ($par in $pares) {
      $jidokaHash = Get-MotorHash $par.src
      $childAbs = Join-Path $Destino $par.rel
      $nuevoSeed[$par.rel] = $jidokaHash                            # el sello guarda lo que Jidoka ENVIA ahora

      if (-not (Test-Path -LiteralPath $childAbs)) {               # 1. nuevo en esta version
        $parent = Split-Path -Parent $childAbs
        if ($parent -and -not (Test-Path -LiteralPath $parent)) { New-Item -ItemType Directory -Path $parent -Force | Out-Null }
        Copy-Item -LiteralPath $par.src -Destination $childAbs -Force
        Write-Host "  [NUEVO]  $($par.rel)" -ForegroundColor Green; $agregados++
        continue
      }
      $childHash = Get-MotorHash $childAbs
      if ($childHash -eq $jidokaHash) { $alDia++; continue }        # 2. al dia
      $seedHash = $seed[$par.rel]
      if ($seedHash -and $childHash -eq $seedHash) {                # 3. el hijo no lo toco -> actualiza
        Copy-Item -LiteralPath $par.src -Destination $childAbs -Force
        Write-Host "  [ACTUALIZA] $($par.rel)" -ForegroundColor Cyan; $actualizados++
        continue
      }
      # 4. DIVERGENCIA: el hijo lo customizo. No se pisa; se deja la version de Jidoka al lado.
      $nuevoPath = "$childAbs.jidoka-nuevo"
      Copy-Item -LiteralPath $par.src -Destination $nuevoPath -Force
      Write-Host "  [DIVERGE] $($par.rel) -> se dejo $($par.rel).jidoka-nuevo (revisa a mano)" -ForegroundColor Yellow
      $divergen += $par.rel
    }
  }

  # Actualiza el sello: version nueva + los hashes que Jidoka envia ahora.
  $selloNuevo = [ordered]@{ version = $versionNueva; sembrado_hashes = $nuevoSeed }
  [System.IO.File]::WriteAllText($selloDst, ($selloNuevo | ConvertTo-Json -Depth 5), $utf8)

  Write-Host ""
  Write-Host "== Motor: $alDia al dia | $actualizados actualizado(s) | $agregados nuevo(s) | $($divergen.Count) divergen ==" -ForegroundColor Green
  if ($divergen.Count -gt 0) {
    Write-Host "Divergencias (el hijo customizo estas piezas de mecanica; se preservaron):" -ForegroundColor Yellow
    foreach ($d in $divergen) { Write-Host "  - $d  (compara con $d.jidoka-nuevo)" -ForegroundColor Yellow }
    Write-Host "  Reconcilia a mano: adopta el .jidoka-nuevo o mueve tu ajuste a la costura .local." -ForegroundColor Yellow
  }
  Write-Host "Instancia (ley, product/, HANDOFF, ADRs) intacta: -Actualizar solo toca la mecanica." -ForegroundColor Cyan
  Write-Host "Siguiente: revisa el diff en una rama y abrelo como PR (el diff ES la revision)." -ForegroundColor Cyan
}

# ---------------------------------------------------------------------------
# Modo -Sellar: escribe el sello INICIAL de un hijo que ya tiene el motor pero
# convergio a mano (sin sello), CLASIFICANDO cada pieza de mecanica:
#   - hijo == Jidoka actual  -> PRISTINA: la registra en la semilla con el hash
#     de Jidoka (asi el proximo -Actualizar la actualiza como al dia/actualiza).
#   - hijo != Jidoka         -> CUSTOMIZADA: NO la registra (semilla sin ella) ->
#     el proximo -Actualizar la vera DIVERGE (child != seed=null) y la PRESERVA.
#   - hijo ausente           -> se omite (el -Actualizar la agregara).
# Generaliza el arreglo manual que se hizo a mano en los labs (SGI: quitar las
# entradas code-first; TF: semilla vacia): en vez de asumir pristina (el bug que
# casi pisa el motor de SGI) o preservar todo (semilla vacia, que no actualiza lo
# pristino), clasifica pieza por pieza. La instancia nunca se toca.
function Invoke-Sellar($jidoka, $manif, $Destino, $utf8) {
  $selloDst = Join-Path $Destino 'tools/jidoka-motor.json'
  $versionPath = Join-Path $jidoka 'tools/version.txt'
  $version = if (Test-Path $versionPath) { (Get-Content $versionPath -Raw).Trim() } else { 'desconocida' }

  Write-Host "== Sellar motor: clasifica cada pieza pristina-vs-customizada (Jidoka $version) =="
  if (Test-Path -LiteralPath $selloDst) { Info "(ya hay un sello; se re-clasifica y sobrescribe)" }

  $seed = [ordered]@{}
  $pristinas = 0; $divergen = @(); $ausentes = 0

  foreach ($e in $manif.motor) {
    if ($e.clase -and $e.clase -ne 'mecanica') { continue }
    $srcRoot = Join-Path $jidoka $e.origen
    if (-not (Test-Path -LiteralPath $srcRoot)) { continue }

    $pares = @()
    if ($e.dir) {
      Get-ChildItem -LiteralPath $srcRoot -Recurse -File | ForEach-Object {
        $relEnOrigen = $_.FullName.Substring($srcRoot.Length).TrimStart('\', '/').Replace('\', '/')
        $relDst = ($e.destino.Replace('\', '/')).TrimEnd('/') + '/' + $relEnOrigen
        $pares += [pscustomobject]@{ rel = $relDst; src = $_.FullName }
      }
    } else {
      $pares += [pscustomobject]@{ rel = $e.destino.Replace('\', '/'); src = $srcRoot }
    }

    foreach ($par in $pares) {
      $childAbs = Join-Path $Destino $par.rel
      if (-not (Test-Path -LiteralPath $childAbs)) { $ausentes++; continue }
      $jidokaHash = Get-MotorHash $par.src
      $childHash = Get-MotorHash $childAbs
      if ($childHash -eq $jidokaHash) {
        $seed[$par.rel] = $jidokaHash                                 # pristina -> registrada
        $pristinas++
      } else {
        $divergen += $par.rel                                         # customizada -> omitida (se preservara)
      }
    }
  }

  $selloNuevo = [ordered]@{ version = $version; sembrado_hashes = $seed }
  $parent = Split-Path -Parent $selloDst
  if ($parent -and -not (Test-Path -LiteralPath $parent)) { New-Item -ItemType Directory -Path $parent -Force | Out-Null }
  [System.IO.File]::WriteAllText($selloDst, ($selloNuevo | ConvertTo-Json -Depth 5), $utf8)

  Write-Host ""
  Write-Host "== Sello escrito: $pristinas pristina(s) registrada(s) | $($divergen.Count) divergen (se preservaran) | $ausentes ausente(s) ==" -ForegroundColor Green
  if ($divergen.Count -gt 0) {
    Write-Host "Piezas customizadas (NO registradas en la semilla -> -Actualizar las preservara):" -ForegroundColor Yellow
    foreach ($d in $divergen) { Write-Host "  - $d" -ForegroundColor Yellow }
  }
  Write-Host "Sello: tools/jidoka-motor.json (version $version). Siguiente: -Actualizar baja lo pristino, preserva lo customizado." -ForegroundColor Cyan
}

$utf8 = New-Object System.Text.UTF8Encoding($false)

# 1. Leer el manifiesto de siembra.
$manifPath = Join-Path $jidoka 'kit/.jidoka/instalar/manifiesto.json'
if (-not (Test-Path $manifPath)) { Die "no encuentro el manifiesto ($manifPath)" }
$manif = Get-Content $manifPath -Raw | ConvertFrom-Json

# Modo -Actualizar: re-siembra SOLO la mecanica sobre un hijo ya instalado, y termina.
if ($Actualizar) {
  if (-not (Test-Path -LiteralPath $Destino)) { Die "el destino '$Destino' no existe (para -Actualizar debe ser un hijo ya instalado)" }
  $Destino = (Resolve-Path -LiteralPath $Destino).Path
  if ($Destino -eq $jidoka) { Die "el destino no puede ser el propio repo de Jidoka" }
  Invoke-Actualizar $jidoka $manif $Destino $utf8
  exit 0
}

# Modo -Sellar: escribe el sello inicial (clasificando pristina-vs-customizada) de un
# hijo que ya tiene el motor pero convergio a mano sin sello. Y termina.
if ($Sellar) {
  if (-not (Test-Path -LiteralPath $Destino)) { Die "el destino '$Destino' no existe (para -Sellar debe ser un hijo con el motor ya presente)" }
  $Destino = (Resolve-Path -LiteralPath $Destino).Path
  if ($Destino -eq $jidoka) { Die "el destino no puede ser el propio repo de Jidoka" }
  Invoke-Sellar $jidoka $manif $Destino $utf8
  exit 0
}

# 2. Resolver el arquetipo. Si no se paso: pregunta interactivo (o docs-as-code con -Yes).
#    Antes tenia un default silencioso 'docs-as-code' -- un repo code-first recibia el
#    arquetipo equivocado sin enterarse. Ahora se pregunta salvo que corras desatendido.
if (-not $Arquetipo) {
  $disp = @($manif.arquetipos.PSObject.Properties | Where-Object { $_.Value.disponible })
  if ($Yes) {
    $Arquetipo = 'docs-as-code'   # desatendido: default explicito
  }
  else {
    Write-Host "== Elige el arquetipo (que siembra Jidoka) =="
    for ($i = 0; $i -lt $disp.Count; $i++) {
      Write-Host ("  [{0}] {1} - {2}" -f ($i + 1), $disp[$i].Name, $disp[$i].Value.desc)
    }
    $sel = Read-Host "Numero o nombre (Enter = docs-as-code)"
    if (-not $sel) { $Arquetipo = 'docs-as-code' }
    elseif ($sel -match '^\d+$' -and [int]$sel -ge 1 -and [int]$sel -le $disp.Count) { $Arquetipo = $disp[[int]$sel - 1].Name }
    else { $Arquetipo = $sel.Trim() }
  }
}

Write-Host "== Instalador de Jidoka (arquetipo: $Arquetipo) =="

# 2b. Validar el arquetipo.
$arq = $manif.arquetipos.$Arquetipo
if (-not $arq) { Die "arquetipo desconocido: '$Arquetipo'. Opciones: $($manif.arquetipos.PSObject.Properties.Name -join ', ')" }
if (-not $arq.disponible) { Die "el arquetipo '$Arquetipo' aun no esta disponible: $($arq.nota)" }

# 3. Preparar el destino (git init si hace falta).
if (-not (Test-Path -LiteralPath $Destino)) {
  if (-not $Yes) {
    $r = Read-Host "El destino '$Destino' no existe. Crearlo? (s/N)"
    if ($r -ne 's' -and $r -ne 'S') { Die "cancelado por el usuario" }
  }
  New-Item -ItemType Directory -Path $Destino -Force | Out-Null
}
$Destino = (Resolve-Path -LiteralPath $Destino).Path
if ($Destino -eq $jidoka) { Die "el destino no puede ser el propio repo de Jidoka" }
if (-not (Test-Path (Join-Path $Destino '.git'))) {
  Info "el destino no es un repo git; corriendo 'git init'..."
  # 2>$null (no 2>&1): bajo ErrorActionPreference=Stop, 2>&1 envolveria un aviso
  # de git a stderr como ErrorRecord y abortaria el instalador. 2>$null lo descarta.
  git init -q $Destino 2>$null | Out-Null
}

# 4. Copiar el motor generico segun el manifiesto.
Info "Sembrando el motor generico..."
foreach ($e in $manif.motor) {
  $src = Join-Path $jidoka $e.origen
  $dst = Join-Path $Destino $e.destino
  if (-not (Test-Path -LiteralPath $src)) { Info "(origen ausente, se omite: $($e.origen))"; continue }
  if ($e.dir) { Copy-DirSafe $src $dst } else { Copy-Safe $src $dst }
}

# 5. Sembrar la ley del arquetipo -> ley_destino.
$leySrc = Join-Path $jidoka $arq.ley
$leyDst = Join-Path $Destino $manif.ley_destino
Copy-Safe $leySrc $leyDst

# 6. Crear stubs (solo si faltan).
Info "Creando stubs (solo los que falten)..."
foreach ($s in $manif.stubs) {
  $dst = Join-Path $Destino $s.ruta
  if (Test-Path -LiteralPath $dst) { Skip $dst; $script:saltados++; continue }
  $parent = Split-Path -Parent $dst
  if ($parent -and -not (Test-Path -LiteralPath $parent)) { New-Item -ItemType Directory -Path $parent -Force | Out-Null }
  [System.IO.File]::WriteAllText($dst, $s.contenido, $utf8)
  $script:stubs++
}

# 6b. Stubs ESPECIFICOS del arquetipo (la matriz ejecutable): la semilla del QUE
#     (grafo de notas vs brief) y la gobernanza si el arquetipo la pide.
$extra = @()
if ($arq.producto -and $manif.stubs_arquetipo.($arq.producto)) { $extra += $manif.stubs_arquetipo.($arq.producto) }
if ($arq.gobernanza -and $manif.stubs_arquetipo.gobernanza) { $extra += $manif.stubs_arquetipo.gobernanza }
foreach ($s in $extra) {
  $dst = Join-Path $Destino $s.ruta
  if (Test-Path -LiteralPath $dst) { Skip $dst; $script:saltados++; continue }
  $parent = Split-Path -Parent $dst
  if ($parent -and -not (Test-Path -LiteralPath $parent)) { New-Item -ItemType Directory -Path $parent -Force | Out-Null }
  [System.IO.File]::WriteAllText($dst, $s.contenido, $utf8)
  $script:stubs++
}

# 6c. Sellar la version del motor sembrado. El hijo sabe de que Jidoka viene su
#     maquinaria (version + hash de cada pieza de motor). Es la linea base para el
#     modo -Actualizar (conciencia de tres vias) y el aviso de divergencia. No-clobber:
#     si el sello ya existe (re-instalacion), no se toca -- lo actualiza -Actualizar.
$versionPath = Join-Path $jidoka 'tools/version.txt'
$version = if (Test-Path $versionPath) { (Get-Content $versionPath -Raw).Trim() } else { 'desconocida' }
$selloDst = Join-Path $Destino 'tools/jidoka-motor.json'
if (Test-Path -LiteralPath $selloDst) { Skip $selloDst; $script:saltados++ }
else {
  $hashes = [ordered]@{}
  foreach ($e in $manif.motor) {
    if ($e.clase -and $e.clase -ne 'mecanica') { continue }
    foreach ($f in (Get-MotorFiles $e $Destino)) { $hashes[$f.rel] = (Get-MotorHash $f.abs) }
  }
  $sello = [ordered]@{ version = $version; sembrado_hashes = $hashes }
  [System.IO.File]::WriteAllText($selloDst, ($sello | ConvertTo-Json -Depth 5), $utf8)
  Ok "sello de version: tools/jidoka-motor.json (Jidoka $version, $($hashes.Count) pieza(s) de motor)"
}

# 7. Encender lo manual: core.hooksPath.
if ($manif.post.hooksPath) {
  git -C $Destino config core.hooksPath $manif.post.hooksPath 2>$null | Out-Null
  if ($LASTEXITCODE -eq 0) { Ok "core.hooksPath = $($manif.post.hooksPath)" }
  else { Info "(no pude fijar core.hooksPath; hazlo a mano: git config core.hooksPath $($manif.post.hooksPath))" }
}

# 8. Resumen + siguientes pasos.
Write-Host ""
Write-Host "== Sembrado: $($script:copiados) archivo(s), $($script:stubs) stub(s); $($script:saltados) saltado(s) (no clobber). ==" -ForegroundColor Green
Write-Host "Siguientes pasos:" -ForegroundColor Cyan
$n = 1
foreach ($p in $manif.post.siguientes_pasos) { Write-Host "  $n. $p"; $n++ }
exit 0
