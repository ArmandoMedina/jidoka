#Requires -Version 5
# estado-ligas.ps1 - el gate GRANULAR codigo<->capacidad (las "ligas").
# Hermano de estado-docs.ps1 (aquel gobierna estructura de docs; este gobierna la
# co-ocurrencia declarada entre codigo y capacidades). Lee el ledger tools/ligas.json
# -- que el cliente AUTORA (desde la extension de VS Code o a mano) -- y mide sobre
# el rango git: si cambio algo que casa 'codigo' sin tocar sus 'capacidades' (o al
# reves, segun 'direccion'), la liga esta VIOLADA. La UI nunca es el muro: este
# script es el que muerde (pre-push + CI desde la base, ADR 0003).
#   [AVISO]   liga 'fuerza:avisa' violada (exit 0 siempre).
#   [BLOQUEA] liga 'fuerza:bloquea' violada -- se imprime SIEMPRE (la verdad se
#             dice), pero solo -Estricto la convierte en exit 1 (el muro se cablea).
#   [ROTA]    la liga apunta a codigo o capacidad que ya no existe: aviso siempre,
#             nunca bloqueo, y la liga queda FUERA de la evaluacion (un medidor con
#             metadatos podridos no emite veredicto).
#   exit 0 aviso / ledger ausente; exit 1 solo -Estricto con bloqueo; exit 2 FALLA
#   CERRADO (rango incalculable, ledger que no parsea, enum invalido).
#
# Uso:  ./tools/estado-ligas.ps1                      (local: upstream...HEAD o working tree)
#       ./tools/estado-ligas.ps1 -Estricto            (pre-push / CI: las 'bloquea' muerden)
#       ./tools/estado-ligas.ps1 -Base origin/main    (CI: rango del PR)
#       ./tools/estado-ligas.ps1 -Cambiados a.ps1     (prueba: lista inyectada, sin diff)
#       -Ledger <ruta>                                (prueba/CI: ledger alterno, leido de la base)
#       -Repo <ruta>                                  (CI: raiz del repo si el script corre copiado)
# Nota: archivo ASCII a proposito (PS 5.1). El ledger se lee con ReadAllText
# (detecta UTF-8 sin BOM: exactamente lo que escribe el modulo JS de la extension).

param(
  [string]$Base = '',
  [string[]]$Cambiados = @(),
  [string]$Ledger = '',
  [string]$Repo = '',
  [switch]$Estricto
)

$ErrorActionPreference = 'Continue'
if (-not $Repo) { $Repo = Split-Path -Parent $PSScriptRoot }
Push-Location $Repo
$script:avisos = 0
$script:bloqueos = 0
$script:rotas = 0

function Note($msg)  { Write-Host "  [AVISO] $msg"   -ForegroundColor Yellow; $script:avisos++ }
function Block($msg) { Write-Host "  [BLOQUEA] $msg" -ForegroundColor Red;    $script:bloqueos++ }
function Rota($msg)  { Write-Host "  [ROTA] $msg"    -ForegroundColor Yellow; $script:rotas++ }
function Ok($msg)    { Write-Host "  [OK] $msg"      -ForegroundColor Green }
function Fail($msg) {
  # Falla CERRADO: si el gate no puede medir, no aprueba (exit 2, distinto del bloqueo).
  Write-Host "  [ERROR] $msg" -ForegroundColor Red
  Write-Host ""
  Write-Host "== Gate sin veredicto: FALLA CERRADO (exit 2). Un muro que ante fallo interno se abre no es muro. ==" -ForegroundColor Red
  Pop-Location
  exit 2
}

# Matcher byte-fiel a verificar.ps1 (y a la linterna): un patron sin '/' solo casa
# en la raiz. Divergir aqui seria mentir sobre lo que ve el gate.
function Test-Pattern($path, $pattern) {
  if ($pattern -notlike '*/*' -and $path -like '*/*') { return $false }
  return ($path -like $pattern)
}
function Match-Any($list, $pattern) {
  foreach ($item in $list) { if (Test-Pattern $item $pattern) { return $true } }
  return $false
}

Write-Host "== Estado de las ligas (codigo<->capacidad; ledger tools/ligas.json) =="

# -Cambiados acepta lista separada por comas (invocacion via powershell -File pasa
# los args como strings planos). Contrato PROPIO de este script (verificar.ps1 no
# splitea); limitacion conocida: una ruta legitima con coma se parte -- solo afecta
# la via de inyeccion (tests/CLI), el diff de git nunca pasa por aqui.
$Cambiados = @($Cambiados | ForEach-Object { $_ -split ',' } | Where-Object { $_ })

# El ledger por defecto vive en el REPO medido (-Repo), no junto al script: en CI
# el script corre copiado fuera de tools/ y en las pruebas mide un fixture.
if (-not $Ledger) { $Ledger = Join-Path $Repo 'tools/ligas.json' }
if (-not (Test-Path -LiteralPath $Ledger)) {
  Write-Host "  (no hay tools/ligas.json: declara ligas desde la extension 'Jidoka: ligar a capacidad...' o a mano.)" -ForegroundColor Yellow
  Pop-Location
  exit 0
}
try {
  $ledgerObj = [System.IO.File]::ReadAllText((Resolve-Path -LiteralPath $Ledger).Path) | ConvertFrom-Json
} catch {
  Fail "el ledger ($Ledger) no parsea como JSON: $($_.Exception.Message)"
}
if ($null -eq $ledgerObj -or $null -eq $ledgerObj.PSObject.Properties['ligas']) {
  Fail "el ledger ($Ledger) no trae la clave 'ligas'"
}
$ligas = @($ledgerObj.ligas)
if ($ligas.Count -eq 0) {
  Ok "cero ligas declaradas: nada que vigilar."
  Pop-Location
  exit 0
}

# El rango: replica del triple fallback de verificar.ps1 (inyectado -> base -> upstream/working tree).
if ($Cambiados.Count -gt 0) {
  $changed = $Cambiados
}
elseif ($Base) {
  $changed = git diff --name-only "$Base...HEAD" 2>$null
  if ($LASTEXITCODE -ne 0) { Fail "no pude calcular el rango $Base...HEAD (base inexistente o historia incompleta)" }
}
else {
  $upstream = git rev-parse --abbrev-ref --symbolic-full-name '@{u}' 2>$null
  if ($LASTEXITCODE -eq 0) {
    $changed = git diff --name-only '@{u}...HEAD' 2>$null
    if ($LASTEXITCODE -ne 0) { Fail "no pude calcular el rango @{u}...HEAD" }
  }
  else {
    $changed = git diff --name-only HEAD 2>$null
    if ($LASTEXITCODE -ne 0) { Fail "no pude leer el working tree (git diff HEAD)" }
  }
}
$changed = @($changed | Where-Object { $_ })

# El arbol real (trackeados + untracked no-ignorados, misma enumeracion que la
# linterna) para detectar ligas ROTAS. quotepath=false: rutas con acento intactas.
$arbol = git -c core.quotepath=false ls-files --cached --others --exclude-standard 2>$null
if ($LASTEXITCODE -ne 0) { Fail "no pude enumerar los archivos del repo (git ls-files)" }
$arbol = @($arbol | Where-Object { $_ })

$dirValidas = @('codigo-a-capacidad', 'capacidad-a-codigo', 'ambas')
$fzaValidas = @('avisa', 'bloquea')
$evaluadas = 0

foreach ($liga in $ligas) {
  $id = if ($liga.id) { $liga.id } else { '(sin id)' }
  if (-not $liga.codigo -or @($liga.codigo).Count -eq 0) { Fail "liga '$id': 'codigo' vacio o ausente" }
  if (-not $liga.capacidades -or @($liga.capacidades).Count -eq 0) { Fail "liga '$id': 'capacidades' vacio o ausente" }
  if ($dirValidas -notcontains $liga.direccion) { Fail "liga '$id': direccion '$($liga.direccion)' invalida (usa: $($dirValidas -join ' | '))" }
  if ($fzaValidas -notcontains $liga.fuerza) { Fail "liga '$id': fuerza '$($liga.fuerza)' invalida (usa: $($fzaValidas -join ' | '))" }

  # Liga ROTA: un glob de codigo que no casa nada del arbol, o una capacidad ausente.
  # Aviso siempre, nunca bloqueo, y la liga queda excluida de la evaluacion.
  $rota = $false
  foreach ($pat in $liga.codigo) {
    if (-not (Match-Any $arbol $pat)) { Rota "liga '$id': el patron de codigo '$pat' no casa ningun archivo del repo (renombrado o borrado?)"; $rota = $true }
  }
  foreach ($cap in $liga.capacidades) {
    if (-not (Match-Any $arbol $cap)) { Rota "liga '$id': la capacidad '$cap' no existe en el repo"; $rota = $true }
  }
  if ($rota) { continue }
  $evaluadas++

  $tocaCodigo = @(); $tocaCap = @()
  foreach ($f in $changed) {
    foreach ($pat in $liga.codigo) { if (Test-Pattern $f $pat) { $tocaCodigo += $f; break } }
    foreach ($cap in $liga.capacidades) { if (Test-Pattern $f $cap) { $tocaCap += $f; break } }
  }

  $violaciones = @()
  if ($liga.direccion -eq 'codigo-a-capacidad' -or $liga.direccion -eq 'ambas') {
    if ($tocaCodigo.Count -gt 0 -and $tocaCap.Count -eq 0) {
      $violaciones += ("cambiaste [{0}] sin tocar su capacidad: {1}" -f (($tocaCodigo | Select-Object -First 3) -join ', '), ($liga.capacidades -join ', '))
    }
  }
  if ($liga.direccion -eq 'capacidad-a-codigo' -or $liga.direccion -eq 'ambas') {
    if ($tocaCap.Count -gt 0 -and $tocaCodigo.Count -eq 0) {
      $violaciones += ("cambiaste la capacidad [{0}] sin tocar su codigo: {1}" -f (($tocaCap | Select-Object -First 3) -join ', '), ($liga.codigo -join ', '))
    }
  }

  foreach ($v in $violaciones) {
    if ($liga.fuerza -eq 'bloquea') { Block "liga '$id': $v" } else { Note "liga '$id': $v" }
  }
}

Write-Host ("  Resumen: {0} liga(s) | {1} evaluada(s) | {2} aviso(s) | {3} bloqueo(s) | {4} rota(s)." -f $ligas.Count, $evaluadas, $script:avisos, $script:bloqueos, $script:rotas) -ForegroundColor Cyan
if ($script:bloqueos -gt 0 -and -not $Estricto) {
  Write-Host "  (hay ligas 'bloquea' violadas; sin -Estricto este reporte no muerde -- el pre-push y el CI SI corren con -Estricto.)"
}

Pop-Location
# -Estricto: el muro. Solo las ligas fuerza:bloquea violadas matan (exit 1).
if ($Estricto -and $script:bloqueos -gt 0) { exit 1 }
exit 0
