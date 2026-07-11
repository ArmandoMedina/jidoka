#Requires -Version 5
# verificar.ps1 - El gate local de Jidoka (Andon). Jidoka corre su propio Andon
# sobre si mismo (dogfooding). Lee la ley unica tools/blast-radius.json y hace
# cumplir el radio de impacto: si tocas un area, su doc dueno se toca en el mismo
# cambio.
#   BLOQUEA los doc_bloquea faltantes (exit 1); AVISA los doc_avisa (exit 0).
#   FALLA CERRADO (exit 2) si git no puede calcular el rango: un gate que no
#   puede medir no aprueba a ciegas.
# El hook local pre-push lo dispara antes de cada push. Saltar a proposito:
# git push --no-verify. El muro real es el required check server-side (CI).
#
# Uso:  ./tools/verificar.ps1                        (local: upstream...HEAD o working tree)
#       ./tools/verificar.ps1 -Base origin/main      (CI: rango del PR, base...HEAD)
#       ./tools/verificar.ps1 -Cambiados a.md,b.md   (prueba: lista inyectada, sin git)
#       -Manifiesto <ruta>                           (prueba/CI: manifiesto alterno)
#       -Repo <ruta>                                 (CI: raiz del repo, si el script corre copiado fuera de tools/)
# Nota: archivo ASCII a proposito (sin acentos) para no depender del BOM en PS 5.1.

param(
  [string]$Base = '',
  [string[]]$Cambiados = @(),
  [string]$Manifiesto = '',
  [string]$Repo = ''
)

$ErrorActionPreference = 'Continue'
if (-not $Repo) { $Repo = Split-Path -Parent $PSScriptRoot }
Push-Location $Repo
$script:warn = 0
$script:block = 0

function Note($msg)  { Write-Host "  [AVISO] $msg"   -ForegroundColor Yellow; $script:warn++ }
function Block($msg) { Write-Host "  [BLOQUEA] $msg" -ForegroundColor Red;    $script:block++ }
function Ok($msg)    { Write-Host "  [OK] $msg"      -ForegroundColor Green }
function Fail($msg) {
  # Falla CERRADO: si el gate no puede medir, no aprueba (exit 2, distinto del bloqueo).
  Write-Host "  [ERROR] $msg" -ForegroundColor Red
  Write-Host ""
  Write-Host "== Gate sin veredicto: FALLA CERRADO (exit 2). Un muro que ante fallo interno se abre no es muro. ==" -ForegroundColor Red
  Pop-Location
  exit 2
}

function Test-Pattern($path, $pattern) {
  if ($pattern -notlike '*/*' -and $path -like '*/*') { return $false }
  return ($path -like $pattern)
}
function Match-Any($list, $pattern) {
  foreach ($item in $list) { if (Test-Pattern $item $pattern) { return $true } }
  return $false
}

Write-Host "== Verificar (Jidoka Andon; ley tools/blast-radius.json) =="

if ($Cambiados.Count -gt 0) { $changed = $Cambiados }
elseif ($Base) {
  $changed = git diff --name-only "$Base...HEAD" 2>$null
  if ($LASTEXITCODE -ne 0) { Fail "no pude calcular el rango $Base...HEAD (base inexistente o historia incompleta)" }
}
else {
  $upstream = git rev-parse --abbrev-ref --symbolic-full-name '@{u}' 2>$null
  if ($LASTEXITCODE -eq 0) {
    # 3 puntos (merge-base), consistente con el CI: mide MIS cambios, no los del upstream.
    $changed = git diff --name-only '@{u}...HEAD' 2>$null
    if ($LASTEXITCODE -ne 0) { Fail "no pude calcular el rango @{u}...HEAD" }
  }
  else {
    # Sin upstream (rama nueva): solo se ve el working tree. Limite conocido:
    # el primer push de una rama nueva no se verifica aqui; lo cubre el CI en el PR.
    $changed = git diff --name-only HEAD 2>$null
    if ($LASTEXITCODE -ne 0) { Fail "no pude leer el working tree (git diff HEAD)" }
  }
}

if (-not $Manifiesto) { $Manifiesto = "$PSScriptRoot/blast-radius.json" }
if (-not (Test-Path $Manifiesto)) { Fail "no encuentro la ley ($Manifiesto)" }
$manifest = Get-Content $Manifiesto -Raw | ConvertFrom-Json
if (-not $manifest) { Fail "la ley ($Manifiesto) no parsea como JSON" }
$hayFalta = $false
$hayAviso = $false

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
  $quienes = ($tocados | Select-Object -First 3) -join ', '

  foreach ($tgt in $entry.doc_bloquea) {
    if (-not (Match-Any $changed $tgt)) {
      Block "[$($entry.nombre)] tocaste $quienes sin $tgt ($($entry.desc)). Rol: $($entry.rol)."
      $hayFalta = $true
    }
  }
  foreach ($tgt in $entry.doc_avisa) {
    if (-not (Match-Any $changed $tgt)) {
      $extra = ""; if ($entry.mensaje) { $extra = " $($entry.mensaje)." }
      Note "[$($entry.nombre)] tocaste $quienes; considera actualizar $tgt.$extra"
      $hayAviso = $true
    }
  }
  # product_avisa: sincronia del GRAFO de producto (capacidades, modulos, dominios),
  # no de un doc tecnico. Los targets son globs; si tocaste el area pero NINGUNA nota
  # de producto cambio en el mismo cambio, avisa una sola vez (baja fatiga).
  if ($entry.product_avisa -and $entry.product_avisa.Count -gt 0) {
    $tocoProducto = $false
    foreach ($tgt in $entry.product_avisa) { if (Match-Any $changed $tgt) { $tocoProducto = $true; break } }
    if (-not $tocoProducto) {
      $ej = ($entry.product_avisa | Select-Object -First 2) -join ', '
      Note "[$($entry.nombre)] tocaste $quienes sin tocar el grafo de producto (ej: $ej). Si la capacidad cambio, actualiza su nota en product/; si fue interno (refactor, perf), este aviso no es para ti."
      $hayAviso = $true
    }
  }
}

if (-not $hayFalta -and -not $hayAviso) { Ok "blast-radius al dia (o sin cambios en areas cubiertas)" }

# Costura .local: extension de mecanica ESPECIFICA del repo (p.ej. lint/tests de un
# lenguaje: ruff, pytest). El motor generico NO se bifurca -- el hijo pone sus checks
# aqui y siguen contando para $script:warn / $script:block (usa Note/Block/Ok). Es la
# via sostenible para customizar sin romper -Actualizar. Ausente -> se ignora (la
# mayoria de repos no la necesita). Ve $changed y las funciones del gate por dot-source.
$local = Join-Path $PSScriptRoot 'verificar.local.ps1'
if (Test-Path -LiteralPath $local) {
  Write-Host "== Extension local del gate (tools/verificar.local.ps1) =="
  . $local
}

Write-Host ""
if ($script:block -gt 0) {
  Write-Host "== $($script:block) bloqueo(s). PUSH DETENIDO. ==" -ForegroundColor Red
  Write-Host "   Sincroniza los docs duenos y reintenta, o 'git push --no-verify' a proposito." -ForegroundColor Red
  Pop-Location
  exit 1
}
elseif ($script:warn -gt 0) {
  Write-Host "== $($script:warn) aviso(s) no bloqueante(s). Revisalos antes de subir. ==" -ForegroundColor Yellow
  Pop-Location
  exit 0
}
else { Write-Host "== Todo limpio. ==" -ForegroundColor Green; Pop-Location; exit 0 }
