#Requires -Version 5
# rutear.ps1 - El router de la sesion. Lee la ley (tools/blast-radius.json) y dice,
# de forma DETERMINISTA, que area se rutea a que asiento, que gate la vigila, y
# cuales Stop hooks estan VIVOS o DORMIDOS segun la ley -- con la RAZON de cada
# dormido. Es la tabla de ruteo que /jidoka:arranca adopta al abrir: la conciencia
# (quien se sienta, que cambio dispara que gate) deja de depender de que el agente
# la deduzca. estado-motor.ps1 -Gates consume la seccion de gates.
#
# Fuente UNICA de la logica vivo/dormido (la misma que cada hook lee de la ley):
#   review-stop     vivo si alguna area tiene "revisa": true
#   gemba-stop      vivo si alguna area tiene "rol": "revisor-visual"
#   validador-stop  vivo si alguna area tiene "rol": "validador"
#   andon-stop      vivo si alguna area tiene doc_bloquea/doc_avisa/product_avisa
#
# Falla CERRADO: sin ley legible o parseable -> [ERROR] + exit 1. Un router mudo que
# aprueba a ciegas es peor que ninguno (mismo criterio que verificar.ps1: si no puedo
# medir, no apruebo). Se siembra en cada hijo (motor, clase mecanica). Los self-tests
# apuntan leyes sinteticas con -Ley. Archivo ASCII a proposito, PS 5.1, sin acentos.
# Sin $ErrorActionPreference global.

param([string]$Ley = '', [switch]$Gates)

if (-not $Ley) { $Ley = Join-Path $PSScriptRoot 'blast-radius.json' }

if (-not (Test-Path -LiteralPath $Ley)) {
  Write-Host "[ERROR] no encuentro la ley: $Ley" -ForegroundColor Red
  Write-Host "        rutear falla cerrado: sin ley no hay ruteo (revisa tools/blast-radius.json)."
  exit 1
}
try { $areas = @((Get-Content -LiteralPath $Ley -Raw | ConvertFrom-Json)) }
catch {
  Write-Host "[ERROR] la ley no es JSON valido: $Ley" -ForegroundColor Red
  Write-Host "        $($_.Exception.Message)"
  exit 1
}

function Test-NoVacio($v) { return ($v -and @($v).Count -gt 0) }

# Gates que ACTUAN sobre un area, segun la ley (misma logica que los hooks filtran).
function Get-GatesDeArea($a) {
  $g = @()
  if ($a.rol -eq 'revisor-visual') { $g += 'gemba-stop' }
  if ($a.rol -eq 'validador')      { $g += 'validador-stop' }
  if ($a.revisa -eq $true)         { $g += 'review-stop' }
  if ((Test-NoVacio $a.doc_bloquea) -or (Test-NoVacio $a.doc_avisa) -or (Test-NoVacio $a.product_avisa)) { $g += 'andon-stop' }
  return $g
}

# Estado GLOBAL de cada Stop hook segun la ley: un gate esta VIVO si alguna area lo
# enciende. Se ordena por autoridad (andon primero); la razon acompana a los dormidos.
$revisaVivo = @($areas | Where-Object { $_.revisa -eq $true }).Count -gt 0
$gembaVivo  = @($areas | Where-Object { $_.rol -eq 'revisor-visual' }).Count -gt 0
$validaVivo = @($areas | Where-Object { $_.rol -eq 'validador' }).Count -gt 0
$andonVivo  = @($areas | Where-Object { (Test-NoVacio $_.doc_bloquea) -or (Test-NoVacio $_.doc_avisa) -or (Test-NoVacio $_.product_avisa) }).Count -gt 0

$gatesRoster = @(
  [pscustomobject]@{ gate = 'andon-stop';     vivo = $andonVivo;  razon = 'ninguna area con doc_bloquea/doc_avisa/product_avisa: se enciende al declarar un doc dueno en la ley' }
  [pscustomobject]@{ gate = 'review-stop';    vivo = $revisaVivo; razon = 'ninguna area con revisa:true: se enciende al marcar en la ley el codigo que pide /code-review' }
  [pscustomobject]@{ gate = 'gemba-stop';     vivo = $gembaVivo;  razon = 'ninguna area con rol revisor-visual: se enciende al declarar un area visual en la ley' }
  [pscustomobject]@{ gate = 'validador-stop'; vivo = $validaVivo; razon = 'ninguna area con rol validador: se enciende al declarar un area de datos/spec en la ley' }
)

function Write-SeccionGates {
  Write-Host "== Gates (Stop hooks) segun la ley =="
  foreach ($g in $gatesRoster) {
    if ($g.vivo) {
      Write-Host ("  [VIVO]    {0}" -f $g.gate) -ForegroundColor Green
    }
    else {
      Write-Host ("  [DORMIDO] {0} -- {1}" -f $g.gate, $g.razon) -ForegroundColor DarkGray
    }
  }
  Write-Host "  (un gate DORMIDO no es un permiso: es un area que la ley aun no declara.)"
}

# -Gates: solo la seccion de gates (la consume estado-motor.ps1).
if ($Gates) { Write-SeccionGates; exit 0 }

# --- Salida default: la tabla de ruteo area -> asiento -> gate ---
Write-Host "== Router de la sesion (la ley: $Ley) =="
Write-Host "   Si tocas la 'fuente' de un area, te sientas en su ROL y su GATE te vigila."
Write-Host ""
$fmt = "  {0,-14} {1,-16} {2,-30} {3}"
Write-Host ($fmt -f 'AREA', 'ROL', 'GATE(S) QUE LA VIGILA', 'ESTADO')
Write-Host ($fmt -f '----', '---', '--------------------', '------')
foreach ($a in $areas) {
  if (-not (Test-NoVacio $a.fuente)) { continue }   # pseudo-areas sin fuente (p.ej. auditor): no rutean
  $rol = if ($a.rol) { "$($a.rol)" } else { '-' }
  $g = @(Get-GatesDeArea $a)
  $gTxt = if ($g.Count -gt 0) { $g -join ', ' } else { '(ninguno)' }
  $estado = if ($g.Count -gt 0) { 'VIGILADA' } else { 'sin gate' }
  Write-Host ($fmt -f "$($a.nombre)", $rol, $gTxt, $estado)
}
Write-Host ""
Write-SeccionGates
exit 0
