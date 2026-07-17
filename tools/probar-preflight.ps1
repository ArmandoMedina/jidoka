#Requires -Version 5
# probar-preflight.ps1 - self-test del preflight de inyeccion. Invariante: todo @archivo
# de instancia que un comando del ritual inyecta debe estar cubierto por un preflight ! que
# verifique su existencia ([ -f ...] o test -f ...) en el MISMO archivo. Un @ ausente inyecta vacio EN
# SILENCIO (jidoka#104): el ritual sigue de largo y le da al operador la sensacion de estar
# preparado con el agente sin el QUE/COMO/DONDE. Este test es el guardian de regresion de esa
# clase - falla ROJO si un comando gana un @ nuevo sin extender su preflight. Se siembra
# (mecanica). PS 5.1, ASCII a proposito.

$ErrorActionPreference = 'Stop'
$raiz = Split-Path -Parent $PSScriptRoot
if (-not $raiz) { $raiz = (Get-Location).Path }

$script:pass = 0; $script:fail = 0
function Ok($m) { Write-Host "  [PASA]  $m"; $script:pass++ }
function No($m) { Write-Host "  [FALLA] $m" -ForegroundColor Red; $script:fail++ }

Write-Host "== Preflight de inyeccion: todo @ de instancia esta guardado (jidoka#104) =="

# Comandos del ritual que inyectan contexto de instancia via @ de nivel superior.
$comandos = @('.claude/commands/jidoka/arranca.md', '.claude/commands/jidoka/planea.md')

foreach ($rel in $comandos) {
  $path = Join-Path $raiz $rel
  if (-not (Test-Path $path)) { No "$rel : no existe"; continue }
  $lineas = Get-Content $path

  # 1. @archivo de nivel superior: linea que empieza con @ seguido de una ruta.
  $inyectados = @()
  foreach ($l in $lineas) { if ($l -match '^@(\S+)') { $inyectados += $matches[1] } }

  # 2. preflight: lineas ! que traen un test de existencia ([ -f ... ] o test -f ...).
  #    El idioma 'test -f' es el que el clasificador de permisos auto-corre (mismo que la
  #    guardia del plan-de-trabajo en arranca.md); '[ -f' se acepta por compatibilidad.
  $preflight = ($lineas | Where-Object { $_ -match '^!' -and ($_ -match '\[ -f' -or $_ -match 'test -f') }) -join "`n"

  if ($inyectados.Count -eq 0) { No "$rel : no se hallo ningun @ inyectado (parser roto?)"; continue }

  foreach ($inj in ($inyectados | Select-Object -Unique)) {
    if ($preflight -match [regex]::Escape($inj)) {
      Ok "$rel : @$inj cubierto por el preflight"
    } else {
      No "$rel : @$inj se inyecta SIN preflight que verifique su existencia (fallaria en silencio)"
    }
  }
}

Write-Host ""
if ($script:fail -gt 0) {
  Write-Host "== Preflight INCOMPLETO: $($script:fail) @ sin guardia, $($script:pass) ok. ==" -ForegroundColor Red
  exit 1
}
Write-Host "== Preflight sano: los $($script:pass) @ de instancia estan guardados. =="
exit 0
