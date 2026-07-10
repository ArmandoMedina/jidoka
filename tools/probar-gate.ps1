#Requires -Version 5
# probar-gate.ps1 - prueba de humo del Andon (disparo prueba-de-humo-del-gate:
# un gate no se estrena sin correrlo contra escenarios de resultado conocido).
# Ejercita las rutas del verificador contra la LEY REAL de Jidoka
# (avisa / limpio / bloquea / pasa), la ruta de bloqueo con un manifiesto
# sintetico (para que la rama que BLOQUEA no se pudra si la ley real cambia;
# disparo prueba-de-vida-del-gate) y la ruta que FALLA CERRADO (un gate que no
# puede medir no aprueba a ciegas). Quien valida tambien se valida.
# CI lo corre antes de correr el gate sobre el rango del PR.
#
# Uso:  ./tools/probar-gate.ps1   (exit 0 = gate sano; exit 1 = el gate tiene un bug)
# Nota: archivo ASCII a proposito (sin acentos) para no depender del BOM en PS 5.1.

$gate = Join-Path $PSScriptRoot 'verificar.ps1'
$script:fallos = 0
$script:casos = 0

function Caso($nombre, $exitEsperado, $debeContener, $noDebeContener, $gateArgs) {
  $script:casos++
  $out = (& $gate @gateArgs 6>&1 | Out-String)
  $code = $LASTEXITCODE
  $detalle = ''
  if ($code -ne $exitEsperado) { $detalle = "exit $code, esperaba $exitEsperado" }
  elseif ($debeContener -and -not $out.Contains($debeContener)) { $detalle = "la salida no contiene '$debeContener'" }
  elseif ($noDebeContener -and $out.Contains($noDebeContener)) { $detalle = "la salida contiene '$noDebeContener'" }
  if ($detalle) {
    Write-Host "  [FALLA] $nombre ($detalle)" -ForegroundColor Red
    $script:fallos++
  }
  else { Write-Host "  [PASA]  $nombre" -ForegroundColor Green }
}

Write-Host "== Prueba de humo del Andon (tools/verificar.ps1) =="

# Casos contra la LEY REAL (tools/blast-radius.json):
Caso 'avisa: doctrina tocada sin su disparo (ley real)' 0 '[AVISO]' '' `
  @{ Cambiados = @('doctrina/00-tesis.md') }
Caso 'limpio: cambio fuera de las areas cubiertas (ley real)' 0 'al dia' '[AVISO]' `
  @{ Cambiados = @('README.md') }
Caso 'bloquea: ADR nuevo sin listar en el indice (ley real)' 1 '[BLOQUEA]' '' `
  @{ Cambiados = @('docs/decisions/0099-prueba.md') }
Caso 'pasa: ADR nuevo listado en el indice en el mismo cambio (ley real)' 0 '' '[BLOQUEA]' `
  @{ Cambiados = @('docs/decisions/0099-prueba.md', 'docs/decisions/README.md') }

# Manifiesto sintetico: guarda la rama que bloquea aunque la ley real cambie.
$tmp = Join-Path $env:TEMP 'jidoka-blast-radius-prueba.json'
@'
[
  {
    "nombre": "prueba-bloqueo",
    "desc": "escenario sintetico: doctrina exige su disparo en el mismo cambio",
    "fuente": ["doctrina/*"],
    "doc_bloquea": ["kit/.jidoka/disparos/README.md"],
    "doc_avisa": [],
    "rol": "prueba"
  }
]
'@ | Set-Content -Path $tmp -Encoding Ascii

Caso 'bloquea: doc_bloquea faltante (manifiesto sintetico)' 1 '[BLOQUEA]' '' `
  @{ Cambiados = @('doctrina/00-tesis.md'); Manifiesto = $tmp }

Remove-Item $tmp -ErrorAction SilentlyContinue

# Falla CERRADO: si git no puede calcular el rango, el gate NO aprueba a ciegas (exit 2).
Caso 'falla cerrado: base de git inexistente (no aprueba a ciegas)' 2 '[ERROR]' 'Todo limpio' `
  @{ Base = 'origin/rama-que-no-existe-jamas' }

Write-Host ""
if ($script:fallos -gt 0) {
  Write-Host "== $($script:fallos) de $($script:casos) caso(s) fallidos. El gate tiene un bug: no lo estrenes. ==" -ForegroundColor Red
  exit 1
}
Write-Host "== Gate sano: los $($script:casos) casos se comportan como se espera. ==" -ForegroundColor Green
exit 0
