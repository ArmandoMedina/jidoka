#Requires -Version 5
# verificar.ps1 - El gate local de Jidoka (Andon). Jidoka corre su propio Andon
# sobre si mismo (dogfooding). Lee la ley unica tools/blast-radius.json y hace
# cumplir el radio de impacto: si tocas un area, su doc dueno se toca en el mismo
# cambio.
#   BLOQUEA los doc_bloquea faltantes (exit 1); AVISA los doc_avisa (exit 0).
# El hook local pre-push lo dispara antes de cada push. Saltar a proposito:
# git push --no-verify. El muro real es el required check server-side (CI).
#
# Uso:  ./tools/verificar.ps1                        (local: upstream..HEAD o working tree)
#       ./tools/verificar.ps1 -Base origin/main      (CI: rango del PR, base...HEAD)
#       ./tools/verificar.ps1 -Cambiados a.md,b.md   (prueba: lista inyectada, sin git)
#       -Manifiesto <ruta>                           (prueba: manifiesto alterno)
# Nota: archivo ASCII a proposito (sin acentos) para no depender del BOM en PS 5.1.

param(
  [string]$Base = '',
  [string[]]$Cambiados = @(),
  [string]$Manifiesto = ''
)

$repo = Split-Path -Parent $PSScriptRoot
Set-Location $repo
$script:warn = 0
$script:block = 0

function Note($msg)  { Write-Host "  [AVISO] $msg"   -ForegroundColor Yellow; $script:warn++ }
function Block($msg) { Write-Host "  [BLOQUEA] $msg" -ForegroundColor Red;    $script:block++ }
function Ok($msg)    { Write-Host "  [OK] $msg"      -ForegroundColor Green }

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
elseif ($Base) { $changed = git diff --name-only "$Base...HEAD" }
else {
  $upstream = git rev-parse --abbrev-ref --symbolic-full-name '@{u}' 2>$null
  if ($LASTEXITCODE -eq 0) { $changed = git diff --name-only '@{u}..HEAD' }
  else { $changed = git diff --name-only HEAD }
}

if (-not $Manifiesto) { $Manifiesto = "$PSScriptRoot/blast-radius.json" }
$manifest = Get-Content $Manifiesto -Raw | ConvertFrom-Json
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
}

if (-not $hayFalta -and -not $hayAviso) { Ok "blast-radius al dia (o sin cambios en areas cubiertas)" }

Write-Host ""
if ($script:block -gt 0) {
  Write-Host "== $($script:block) bloqueo(s). PUSH DETENIDO. ==" -ForegroundColor Red
  Write-Host "   Sincroniza los docs duenos y reintenta, o 'git push --no-verify' a proposito." -ForegroundColor Red
  exit 1
}
elseif ($script:warn -gt 0) {
  Write-Host "== $($script:warn) aviso(s) no bloqueante(s). Revisalos antes de subir. ==" -ForegroundColor Yellow
  exit 0
}
else { Write-Host "== Todo limpio. ==" -ForegroundColor Green; exit 0 }
