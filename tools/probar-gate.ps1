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

# Casos contra la LEY REAL (tools/blast-radius.json). Se eligen casos que valen en
# CUALQUIER arquetipo (el area universal 'decisiones' y 'ritual'), no piezas propias
# de Jidoka -- asi este self-test se siembra y pasa en un repo instalado.
Caso 'limpio: cambio fuera de las areas cubiertas (ley real)' 0 'al dia' '[AVISO]' `
  @{ Cambiados = @('README.md') }
Caso 'bloquea: ADR nuevo sin listar en el indice (ley real)' 1 '[BLOQUEA]' '' `
  @{ Cambiados = @('docs/decisions/0099-prueba.md') }
Caso 'pasa: ADR nuevo listado en el indice en el mismo cambio (ley real)' 0 '' '[BLOQUEA]' `
  @{ Cambiados = @('docs/decisions/0099-prueba.md', 'docs/decisions/README.md') }
Caso 'avisa: comando /jidoka:* nuevo sin CHANGELOG (area ritual, ley real)' 0 '[AVISO]' '[BLOQUEA]' `
  @{ Cambiados = @('.claude/commands/jidoka/prueba.md') }

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

# product_avisa (manifiesto sintetico): tocar un area sin tocar su grafo de producto AVISA;
# tocarlo junto con una nota de producto NO avisa. Dimension cosechada de los labs (Fase B).
$tmpP = Join-Path $env:TEMP 'jidoka-blast-radius-producto.json'
@'
[
  {
    "nombre": "prueba-producto",
    "desc": "escenario sintetico: cambio de area sin tocar el grafo de producto",
    "fuente": ["src/*"],
    "doc_bloquea": [],
    "doc_avisa": [],
    "product_avisa": ["product/capacidades/*"],
    "rol": "prueba"
  }
]
'@ | Set-Content -Path $tmpP -Encoding Ascii

Caso 'avisa: area tocada sin el grafo de producto (product_avisa sintetico)' 0 '[AVISO]' '' `
  @{ Cambiados = @('src/x.py'); Manifiesto = $tmpP }
Caso 'pasa: area tocada CON su nota de producto (product_avisa sintetico)' 0 '' '[AVISO]' `
  @{ Cambiados = @('src/x.py', 'product/capacidades/CAP-1.md'); Manifiesto = $tmpP }

Remove-Item $tmpP -ErrorAction SilentlyContinue

# Falla CERRADO: si git no puede calcular el rango, el gate NO aprueba a ciegas (exit 2).
Caso 'falla cerrado: base de git inexistente (no aprueba a ciegas)' 2 '[ERROR]' 'Todo limpio' `
  @{ Base = 'origin/rama-que-no-existe-jamas' }

# FIXTURE DEL QUICKSTART DEL README: el flujo REAL commit->verificar por GIT (no
# -Cambiados inyectado), para que la demo copy-paste del README ("crea un ADR sin
# listar, commitea, corre verificar -> BLOQUEA") no se rompa en silencio.
$fix = Join-Path $env:TEMP ("jidoka-gate-fixture-" + [guid]::NewGuid().ToString('N').Substring(0,8))
try {
  New-Item -ItemType Directory -Path (Join-Path $fix 'tools') -Force | Out-Null
  New-Item -ItemType Directory -Path (Join-Path $fix 'docs/decisions') -Force | Out-Null
  Copy-Item -LiteralPath (Join-Path $PSScriptRoot 'blast-radius.json') -Destination (Join-Path $fix 'tools/blast-radius.json')
  Copy-Item -LiteralPath $gate -Destination (Join-Path $fix 'tools/verificar.ps1')
  Set-Content -Path (Join-Path $fix 'docs/decisions/README.md') "# Decisiones (indice)" -Encoding Ascii
  $fgate = Join-Path $fix 'tools/verificar.ps1'
  Push-Location $fix
  git init -q 2>&1 | Out-Null
  git config user.email 'smoke@jidoka.local' 2>&1 | Out-Null
  git config user.name 'smoke' 2>&1 | Out-Null
  git config commit.gpgsign false 2>&1 | Out-Null
  git add -A 2>&1 | Out-Null; git commit -q -m 'baseline' 2>&1 | Out-Null
  $base = (git rev-parse HEAD 2>$null).Trim()
  # Paso 3 del README: un ADR SIN listar en el indice, commiteado.
  Set-Content -Path (Join-Path $fix 'docs/decisions/9999-demo.md') '# ADR 9999 - demo' -Encoding Ascii
  git add -A 2>&1 | Out-Null; git commit -q -m 'demo: ADR sin listar' 2>&1 | Out-Null
  Pop-Location

  $script:casos++
  $rb = (& powershell -NoProfile -ExecutionPolicy Bypass -File $fgate -Base $base 2>&1 | Out-String); $rbCode = $LASTEXITCODE
  if ($rbCode -eq 1 -and $rb.Contains('[BLOQUEA]')) { Write-Host "  [PASA]  fixture README: ADR commiteado sin listar -> BLOQUEA (exit 1)" -ForegroundColor Green }
  else { Write-Host "  [FALLA] fixture README: esperaba bloqueo (exit 1 + [BLOQUEA]); fue exit $rbCode" -ForegroundColor Red; $script:fallos++ }

  # Curalo: listalo en el indice y commitea -> el mismo rango pasa (exit 0).
  Push-Location $fix
  Add-Content -Path (Join-Path $fix 'docs/decisions/README.md') '| 9999 | demo | aceptado |'
  git add -A 2>&1 | Out-Null; git commit -q -m 'lista el ADR en el indice' 2>&1 | Out-Null
  Pop-Location

  $script:casos++
  $rp = (& powershell -NoProfile -ExecutionPolicy Bypass -File $fgate -Base $base 2>&1 | Out-String); $rpCode = $LASTEXITCODE
  if ($rpCode -eq 0 -and -not $rp.Contains('[BLOQUEA]')) { Write-Host "  [PASA]  fixture README: ADR listado en el indice -> pasa (exit 0)" -ForegroundColor Green }
  else { Write-Host "  [FALLA] fixture README: esperaba pasar (exit 0 sin [BLOQUEA]); fue exit $rpCode" -ForegroundColor Red; $script:fallos++ }
}
finally { Remove-Item $fix -Recurse -Force -ErrorAction SilentlyContinue }

Write-Host ""
if ($script:fallos -gt 0) {
  Write-Host "== $($script:fallos) de $($script:casos) caso(s) fallidos. El gate tiene un bug: no lo estrenes. ==" -ForegroundColor Red
  exit 1
}
Write-Host "== Gate sano: los $($script:casos) casos se comportan como se espera. ==" -ForegroundColor Green
exit 0
