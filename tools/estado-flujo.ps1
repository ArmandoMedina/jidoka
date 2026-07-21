#Requires -Version 5
# estado-flujo.ps1 - la vista del ESTADO VIVO del pilar de flujo (FLU-1, ADR 0045):
# el limite WIP como muro de entrada. Drum-buffer-rope: el ritmo lo marca la
# ACEPTACION del cliente, no la produccion. No se abre un sprint nuevo con un Gemba
# pendiente de aceptar -- el comando se planta y NOMBRA cual Gemba lo bloquea.
#
# El estado es dato de INSTANCIA en tools/flujo.json (clave 'estado'):
#   wip_limite          -> el techo de trabajo en curso (dato, no muro todavia).
#   sprint_activo       -> el sprint abierto (informativo).
#   gembas_pendientes[] -> { id, desde (AAAA-MM-DD), aceptado (bool), que_ver }.
# El booleano 'aceptado' es lo que DESBLOQUEA: un Gemba con aceptado != true
# retiene la linea. La aceptacion se registra en /jidoka:gemba (aceptado:true +
# aceptado_fecha) cuando el cliente da el OK; el cierre registra el Gemba nuevo.
#
# Modo -Gate (R5): imprime el veredicto y sale con codigo.
#   Sin clave 'estado' en flujo.json (o sin flujo.json) -> "no aplica", exit 0
#     (un repo sin el limite WIP no se bloquea).
#   flujo.json corrupto -> FALLA CERRADO exit 2 (un gate que no puede leer su
#     contrato no aprueba a ciegas).
#   gembas_pendientes ausente -> lista vacia; wip_limite ausente -> no se aplica el
#     conteo WIP (solo gembas).
#   Entradas con aceptado != true -> [BLOQUEA] por cada una + linea final, exit 1.
#   Entrada malformada (sin id) -> AVISO, cuenta como pendiente (fail-safe: lo
#     dudoso bloquea).
#   Sin pendientes -> [OK] flujo despejado, exit 0.
#
# TODO(R6): el modo -Json (emitir el estado como JSON para consumidores como la
# linterna del gobierno) aun NO existe. El param -Json se deja declarado para no
# romper el contrato de invocacion, pero hoy solo -Gate esta implementado.
#
# Uso:  ./tools/estado-flujo.ps1 -Gate               (veredicto del limite WIP)
#       ./tools/estado-flujo.ps1 -Gate -Repo <ruta>  (raiz del repo, como los hermanos)
#
# Nota: archivo ASCII a proposito (PS 5.1, sin depender del BOM). Las salidas del
# gate son ASCII por diseno; si alguna requiriera acento, se arma con [char]. El
# flujo.json se lee como los hermanos (verificar/expirar).

param(
  [switch]$Gate,
  [switch]$Json,
  [string]$Repo = ''
)

$ErrorActionPreference = 'Continue'
if (-not $Repo) { $Repo = Split-Path -Parent $PSScriptRoot }
Push-Location $Repo

function Fin($code) { Pop-Location; exit $code }
function Fail($msg) {
  # Falla CERRADO: si el gate no puede leer su contrato, no aprueba a ciegas (exit 2).
  Write-Host "  [ERROR] $msg" -ForegroundColor Red
  Write-Host ""
  Write-Host "== Estado de flujo sin veredicto: FALLA CERRADO (exit 2). Un muro que ante fallo interno se abre no es muro. ==" -ForegroundColor Red
  Fin 2
}

# -Json: stub honesto (R6). Se declara el param, no la mecanica.
if ($Json) {
  Write-Host "  [TODO] el modo -Json llega en R6; hoy estado-flujo solo implementa -Gate."
  Fin 0
}

Write-Host "== Estado de flujo (limite WIP; contrato en tools/flujo.json) =="

# --- El contrato: flujo.json --------------------------------------------------------
$flujoCfg = $null
if (Test-Path 'tools/flujo.json') {
  try { $flujoCfg = Get-Content 'tools/flujo.json' -Raw | ConvertFrom-Json }
  catch { Fail "tools/flujo.json existe pero no parsea como JSON." }
  if (-not $flujoCfg) { Fail "tools/flujo.json existe pero no parsea como JSON." }
}
if (-not $flujoCfg -or -not $flujoCfg.estado) {
  Write-Host "  [no aplica] sin clave estado en tools/flujo.json: el limite WIP no aplica (un repo sin el pilar no se bloquea)."
  Fin 0
}

$estado = $flujoCfg.estado

# wip_limite: informativo. Ausente -> no se aplica el conteo WIP (solo gembas).
$wipParsed = 0
$wipTxt = 'sin limite WIP declarado'
$wipRaw = $estado.wip_limite
if ($null -ne $wipRaw -and [int]::TryParse([string]$wipRaw, [ref]$wipParsed) -and $wipParsed -ge 0) {
  $wipTxt = "WIP limite: $wipParsed"
}

# gembas_pendientes ausente -> lista vacia.
$gembas = @()
if ($null -ne $estado.gembas_pendientes) { $gembas = @($estado.gembas_pendientes) }

# --- El veredicto: cada Gemba con aceptado != true retiene la linea ----------------
$bloqueos = 0
foreach ($g in $gembas) {
  $id = [string]$g.id
  if (-not $id) {
    # Entrada malformada (sin id): AVISO y cuenta como pendiente (fail-safe: lo dudoso bloquea).
    Write-Host "  [AVISO] entrada de gembas_pendientes SIN id: malformada. Cuenta como pendiente (fail-safe: lo dudoso bloquea)." -ForegroundColor Yellow
    $bloqueos++
    continue
  }
  if ($g.aceptado -eq $true) { continue }   # aceptado explicito: no retiene
  $desde = [string]$g.desde
  if (-not $desde) { $desde = '?' }
  $queVer = [string]$g.que_ver
  if (-not $queVer) { $queVer = '(sin descripcion de que ver)' }
  Write-Host ("  [BLOQUEA] Gemba pendiente de aceptacion: {0} (desde {1}): {2}" -f $id, $desde, $queVer) -ForegroundColor Red
  $bloqueos++
}

if ($bloqueos -gt 0) {
  Write-Host ""
  Write-Host ("== ABRIR SPRINT NUEVO BLOQUEADO: {0} Gemba(s) esperan los ojos del cliente. El limite lo pone la aceptacion, no la produccion. ==" -f $bloqueos) -ForegroundColor Red
  Fin 1
}

Write-Host ("  [OK] flujo despejado: 0 Gembas pendientes ({0})" -f $wipTxt) -ForegroundColor Green
Fin 0
