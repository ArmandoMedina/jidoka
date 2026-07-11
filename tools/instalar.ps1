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
#   ./tools/instalar.ps1 -Destino C:\ruta\repo-limpio
#   ./tools/instalar.ps1 -Destino ... -Arquetipo docs-as-code -Yes
# Nota: archivo ASCII a proposito (sin acentos) para PS 5.1.

[CmdletBinding()]
param(
  [Parameter(Mandatory = $true)][string]$Destino,
  [string]$Arquetipo = 'docs-as-code',
  [switch]$Yes
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

# SHA256 de un archivo (hash del sello / deteccion de divergencia).
function Get-MotorHash($path) { return (Get-FileHash -LiteralPath $path -Algorithm SHA256).Hash }

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

Write-Host "== Instalador de Jidoka (arquetipo: $Arquetipo) =="

# 1. Leer el manifiesto de siembra.
$manifPath = Join-Path $jidoka 'kit/.jidoka/instalar/manifiesto.json'
if (-not (Test-Path $manifPath)) { Die "no encuentro el manifiesto ($manifPath)" }
$manif = Get-Content $manifPath -Raw | ConvertFrom-Json

# 2. Validar el arquetipo.
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
$utf8 = New-Object System.Text.UTF8Encoding($false)
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
