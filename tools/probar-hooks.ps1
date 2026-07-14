#Requires -Version 5
# probar-hooks.ps1 - prueba de vida de los hooks (disparo prueba-de-vida-del-gate:
# un hook no se estrena sin correrlo contra escenarios de resultado conocido,
# incluido uno que DEBE bloquear). Complementa a probar-gate.ps1 (que prueba el
# verificador). Prueba no-memorias por stdin y los Stop-hooks review/gemba en un
# repo git TEMPORAL con el estado exacto que dispara cada caso.
#
# Uso:  ./tools/probar-hooks.ps1   (exit 0 = hooks sanos; exit 1 = un hook tiene un bug)
# Nota: archivo ASCII a proposito (sin acentos), PS 5.1.

$hooksDir = Join-Path (Split-Path -Parent $PSScriptRoot) '.claude/hooks'
$script:fallos = 0
$script:casos = 0

function Check($nombre, $cond, $detalle) {
  $script:casos++
  if ($cond) { Write-Host "  [PASA]  $nombre" -ForegroundColor Green }
  else { Write-Host "  [FALLA] $nombre ($detalle)" -ForegroundColor Red; $script:fallos++ }
}

# Corre un hook alimentando stdin JSON como PROCESO hijo (asi [Console]::In lo lee),
# opcionalmente con CLAUDE_PROJECT_DIR apuntando a un repo de prueba.
function Invoke-Hook($hookPath, $stdinJson, $projectDir) {
  $prev = $env:CLAUDE_PROJECT_DIR
  if ($projectDir) { $env:CLAUDE_PROJECT_DIR = $projectDir }
  try { $out = ($stdinJson | powershell -NoProfile -ExecutionPolicy Bypass -File $hookPath 2>&1 | Out-String) }
  finally { $env:CLAUDE_PROJECT_DIR = $prev }
  return $out
}

function New-TempRepo {
  $dir = Join-Path $env:TEMP ("jidoka-hooktest-" + [guid]::NewGuid().ToString('N').Substring(0,8))
  New-Item -ItemType Directory -Path $dir -Force | Out-Null
  New-Item -ItemType Directory -Path (Join-Path $dir 'tools') -Force | Out-Null
  New-Item -ItemType Directory -Path (Join-Path $dir '.claude') -Force | Out-Null
  Push-Location $dir
  git init -q 2>&1 | Out-Null
  git config user.email "test@jidoka.local" 2>&1 | Out-Null
  git config user.name "jidoka-test" 2>&1 | Out-Null
  git config commit.gpgsign false 2>&1 | Out-Null
  Pop-Location
  return $dir
}

function Set-Manifest($repo, $json) { Set-Content -Path (Join-Path $repo 'tools/blast-radius.json') -Value $json -Encoding Ascii }

Write-Host "== Prueba de vida de los hooks (.claude/hooks) =="

# --- no-memorias (PreToolUse, stdin-driven) ---
$noMem = Join-Path $hooksDir 'no-memorias-pretooluse.ps1'
$outDeny = Invoke-Hook $noMem '{"tool_input":{"file_path":"C:\\Users\\x\\.claude\\projects\\slug\\memory\\foo.md"}}' $null
Check 'no-memorias: DENIEGA escritura a la carpeta de memoria' ($outDeny.Contains('"permissionDecision":"deny"')) "no denego: $outDeny"
$outAllow = Invoke-Hook $noMem '{"tool_input":{"file_path":"C:\\repo\\HANDOFF.md"}}' $null
Check 'no-memorias: DEJA pasar una ruta normal del repo' (-not $outAllow.Contains('deny')) "denego de mas: $outAllow"

# Grieta 2 (auditoria externa): el bypass por Bash. Antes el matcher era solo Write|Edit
# y un Set-Content/redireccion por Bash rodeaba el deny. Ahora se inspecciona
# tool_input.command: ESCRITURA a la memoria bloquea; LECTURA (recall) no.
$outBashSet = Invoke-Hook $noMem '{"tool_name":"Bash","tool_input":{"command":"Set-Content -Path C:\\Users\\x\\.claude\\projects\\slug\\memory\\foo.md -Value hola"}}' $null
Check 'no-memorias: DENIEGA escritura a memoria por Bash (Set-Content)' ($outBashSet.Contains('"permissionDecision":"deny"')) "no denego el bypass: $outBashSet"
$outBashRedir = Invoke-Hook $noMem '{"tool_name":"Bash","tool_input":{"command":"echo hola > ~/.claude/projects/slug/memory/foo.md"}}' $null
Check 'no-memorias: DENIEGA escritura a memoria por Bash (redireccion >)' ($outBashRedir.Contains('"permissionDecision":"deny"')) "no denego el redirect: $outBashRedir"
$outBashRead = Invoke-Hook $noMem '{"tool_name":"Bash","tool_input":{"command":"cat C:\\Users\\x\\.claude\\projects\\slug\\memory\\foo.md"}}' $null
Check 'no-memorias: DEJA LEER memoria por Bash (recall no se bloquea)' (-not $outBashRead.Contains('deny')) "bloqueo una lectura: $outBashRead"
$outBashNorm = Invoke-Hook $noMem '{"tool_name":"Bash","tool_input":{"command":"Set-Content -Path C:\\repo\\HANDOFF.md -Value hi"}}' $null
Check 'no-memorias: DEJA pasar una escritura Bash normal del repo' (-not $outBashNorm.Contains('deny')) "denego de mas por Bash: $outBashNorm"
# Regresion v1.1.0: el token '>' casaba con '2>&1'/'2>/dev/null' (redireccion de stderr,
# NO escritura a memoria) y bloqueaba lecturas comunes. Deben DEJAR pasar.
$outBashErr1 = Invoke-Hook $noMem '{"tool_name":"Bash","tool_input":{"command":"cat ~/.claude/projects/slug/memory/foo.md 2>&1"}}' $null
Check 'no-memorias: DEJA LEER memoria con 2>&1 (no es escritura)' (-not $outBashErr1.Contains('deny')) "falso positivo 2>&1: $outBashErr1"
$outBashErr2 = Invoke-Hook $noMem '{"tool_name":"Bash","tool_input":{"command":"ls -1 ~/.claude/projects/slug/memory/ 2>/dev/null"}}' $null
Check 'no-memorias: DEJA LISTAR memoria con 2>/dev/null (no es escritura)' (-not $outBashErr2.Contains('deny')) "falso positivo 2>/dev/null: $outBashErr2"

# --- stop_hook_active: los Stop-hooks no re-bloquean ---
foreach ($h in @('review-stop.ps1','gemba-stop.ps1','andon-stop.ps1','validador-stop.ps1')) {
  $o = Invoke-Hook (Join-Path $hooksDir $h) '{"stop_hook_active":true}' $null
  Check "${h}: respeta stop_hook_active (no re-bloquea)" (-not $o.Contains('"decision":"block"')) "bloqueo en re-entrada: $o"
}

# --- review-stop en repo temporal ---
$r1 = New-TempRepo
Set-Manifest $r1 '[{"nombre":"motor","desc":"x","fuente":["tools/*"],"doc_bloquea":[],"doc_avisa":[],"revisa":true,"rol":"x"}]'
Set-Content (Join-Path $r1 'tools/motor.ps1') "# v1" -Encoding Ascii
Push-Location $r1; git add -A 2>&1 | Out-Null; git commit -q -m init 2>&1 | Out-Null; Pop-Location
# Caso BLOQUEA: codigo (tools/*) modificado sin marcador de revision.
Set-Content (Join-Path $r1 'tools/motor.ps1') "# v2 cambiado" -Encoding Ascii
$oBlock = Invoke-Hook (Join-Path $hooksDir 'review-stop.ps1') '{}' $r1
Check 'review-stop: BLOQUEA codigo sin /code-review' ($oBlock.Contains('"decision":"block"') -and $oBlock.Contains('code-review')) "no bloqueo: $oBlock"
# Caso PASA: sin codigo sin commitear (todo commiteado).
Push-Location $r1; git add -A 2>&1 | Out-Null; git commit -q -m v2 2>&1 | Out-Null; Pop-Location
$oPass = Invoke-Hook (Join-Path $hooksDir 'review-stop.ps1') '{}' $r1
Check 'review-stop: DEJA cerrar sin codigo pendiente' (-not $oPass.Contains('"decision":"block"')) "bloqueo indebido: $oPass"
Remove-Item $r1 -Recurse -Force -ErrorAction SilentlyContinue

# --- gemba-stop en repo temporal ---
$r2 = New-TempRepo
New-Item -ItemType Directory -Path (Join-Path $r2 'ui') -Force | Out-Null
Set-Manifest $r2 '[{"nombre":"ui","desc":"x","fuente":["ui/*"],"doc_bloquea":[],"doc_avisa":[],"rol":"revisor-visual"}]'
Set-Content (Join-Path $r2 'ui/app.js') "// v1" -Encoding Ascii
Push-Location $r2; git add -A 2>&1 | Out-Null; git commit -q -m init 2>&1 | Out-Null; Pop-Location
# Caso BLOQUEA: cambio visual sin evidencia fresca en qa_runs/.
Set-Content (Join-Path $r2 'ui/app.js') "// v2 cambio visual" -Encoding Ascii
$oVBlock = Invoke-Hook (Join-Path $hooksDir 'gemba-stop.ps1') '{}' $r2
Check 'gemba-stop: BLOQUEA cambio visual sin evidencia' ($oVBlock.Contains('"decision":"block"') -and $oVBlock.Contains('qa_runs')) "no bloqueo: $oVBlock"
# Caso BLOQUEA (Goodhart): evidencia fresca por mtime pero NO rastreada por git.
# qa_runs/ esta gitignoreado; un archivo sin 'git add -f' satisface el mtime pero git
# nunca lo vera -- no vale (evidencia-no-palabra: existe en git, no solo en disco).
Set-Content (Join-Path $r2 '.gitignore') "qa_runs/" -Encoding Ascii
$qa = Join-Path $r2 'qa_runs/gemba-prueba'
New-Item -ItemType Directory -Path $qa -Force | Out-Null
$log = Join-Path $qa 'LOG.md'
Set-Content $log "corrida" -Encoding Ascii
(Get-Item $log).LastWriteTime = (Get-Date).AddMinutes(5)   # fresca por mtime, pero sin trackear
$oVUntracked = Invoke-Hook (Join-Path $hooksDir 'gemba-stop.ps1') '{}' $r2
Check 'gemba-stop: BLOQUEA evidencia fresca pero NO rastreada por git (Goodhart)' ($oVUntracked.Contains('"decision":"block"')) "no bloqueo evidencia no-commiteada: $oVUntracked"
# Caso PASA: la misma evidencia, ahora forzada al indice con git add -f.
Push-Location $r2; git add -f qa_runs/gemba-prueba/LOG.md 2>&1 | Out-Null; Pop-Location
(Get-Item $log).LastWriteTime = (Get-Date).AddMinutes(5)   # re-garantiza mtime posterior al cambio
$oVPass = Invoke-Hook (Join-Path $hooksDir 'gemba-stop.ps1') '{}' $r2
Check 'gemba-stop: DEJA cerrar con evidencia rastreada y fresca (git add -f)' (-not $oVPass.Contains('"decision":"block"')) "bloqueo indebido: $oVPass"
Remove-Item $r2 -Recurse -Force -ErrorAction SilentlyContinue

# --- gemba-stop: LISTON DE EVIDENCIA -- un archivo suelto que NO es LOG.md no vale (ROJO->VERDE) ---
# Antes, CUALQUIER archivo rastreado y fresco bajo qa_runs/ pasaba: un 'veredicto.txt' pelon
# satisfacia el gate (Goodhart -- la evidencia rica se degrado a una tabla pelona en campo).
# Ahora solo cuenta el LOG.md de la corrida (plantilla kit/.jidoka/templates/qa-log.md).
$r5 = New-TempRepo
New-Item -ItemType Directory -Path (Join-Path $r5 'ui') -Force | Out-Null
Set-Manifest $r5 '[{"nombre":"ui","desc":"x","fuente":["ui/*"],"doc_bloquea":[],"doc_avisa":[],"rol":"revisor-visual"}]'
Set-Content (Join-Path $r5 'ui/app.js') "// v1" -Encoding Ascii
Set-Content (Join-Path $r5 '.gitignore') "qa_runs/" -Encoding Ascii
Push-Location $r5; git add -A 2>&1 | Out-Null; git commit -q -m init 2>&1 | Out-Null; Pop-Location
Set-Content (Join-Path $r5 'ui/app.js') "// v2 cambio visual" -Encoding Ascii
$qa5 = Join-Path $r5 'qa_runs/gemba-veredicto'
New-Item -ItemType Directory -Path $qa5 -Force | Out-Null
$vd5 = Join-Path $qa5 'veredicto.txt'
Set-Content $vd5 "PASA - se ve bien" -Encoding Ascii
Push-Location $r5; git add -f qa_runs/gemba-veredicto/veredicto.txt 2>&1 | Out-Null; Pop-Location
(Get-Item $vd5).LastWriteTime = (Get-Date).AddMinutes(5)   # rastreado y fresco, pero NO es LOG.md
$oVListn = Invoke-Hook (Join-Path $hooksDir 'gemba-stop.ps1') '{}' $r5
Check 'gemba-stop: BLOQUEA veredicto suelto rastreado y fresco que NO es LOG.md (liston de evidencia)' ($oVListn.Contains('"decision":"block"')) "no bloqueo el archivo suelto que no es LOG.md: $oVListn"
Remove-Item $r5 -Recurse -Force -ErrorAction SilentlyContinue

# --- gemba-stop: deliverable NUEVO en dir recien-nacido sin trackear (fix issue #50) ---
# git status --porcelain (sin -uall) COLAPSA un dir sin ningun archivo trackeado en una
# sola entrada 'entregas/', y el glob especifico 'entregas/*-entrega.md' no casa -> el gate
# fallaba-ABIERTO justo en el deliverable nuevo que existe para atrapar. Con -uall git lista
# el archivo y el gate vuelve a bloquear. Este caso ROJO->VERDE guarda contra la regresion.
$r4 = New-TempRepo
Set-Manifest $r4 '[{"nombre":"entregas","desc":"x","fuente":["entregas/*-entrega.md"],"doc_bloquea":[],"doc_avisa":[],"rol":"revisor-visual"}]'
Push-Location $r4; git add -A 2>&1 | Out-Null; git commit -q -m init 2>&1 | Out-Null; Pop-Location
# El dir 'entregas/' NACE ahora, sin ningun archivo trackeado dentro (el caso exacto del bug).
New-Item -ItemType Directory -Path (Join-Path $r4 'entregas') -Force | Out-Null
Set-Content (Join-Path $r4 'entregas/sprint-1-entrega.md') "# entrega" -Encoding Ascii
$oNew = Invoke-Hook (Join-Path $hooksDir 'gemba-stop.ps1') '{}' $r4
Check 'gemba-stop: BLOQUEA deliverable nuevo en dir recien-nacido sin trackear (fix #50)' ($oNew.Contains('"decision":"block"')) "fallo-abierto por dir colapsado: $oNew"
Remove-Item $r4 -Recurse -Force -ErrorAction SilentlyContinue

# --- gemba-stop DORMIDO: sin area rol revisor-visual, no dispara ---
$r3 = New-TempRepo
New-Item -ItemType Directory -Path (Join-Path $r3 'ui') -Force | Out-Null
Set-Manifest $r3 '[{"nombre":"ui","desc":"x","fuente":["ui/*"],"doc_bloquea":[],"doc_avisa":[],"rol":"Escribano"}]'
Set-Content (Join-Path $r3 'ui/app.js') "// v1" -Encoding Ascii
Push-Location $r3; git add -A 2>&1 | Out-Null; git commit -q -m init 2>&1 | Out-Null; Pop-Location
Set-Content (Join-Path $r3 'ui/app.js') "// v2" -Encoding Ascii
$oDorm = Invoke-Hook (Join-Path $hooksDir 'gemba-stop.ps1') '{}' $r3
Check 'gemba-stop: DORMIDO si no hay area revisor-visual' (-not $oDorm.Contains('"decision":"block"')) "bloqueo estando dormido: $oDorm"
Remove-Item $r3 -Recurse -Force -ErrorAction SilentlyContinue

# --- validador-stop en repo temporal (validacion por medicion, #52) ---
$v1 = New-TempRepo
New-Item -ItemType Directory -Path (Join-Path $v1 'spec') -Force | Out-Null
Set-Manifest $v1 '[{"nombre":"spec","desc":"x","fuente":["spec/*.md"],"doc_bloquea":[],"doc_avisa":[],"rol":"validador"}]'
Set-Content (Join-Path $v1 'spec/formula.md') "# formula v1" -Encoding Ascii
Push-Location $v1; git add -A 2>&1 | Out-Null; git commit -q -m init 2>&1 | Out-Null; Pop-Location
# Caso BLOQUEA: la spec cambio sin evidencia de corrida en qa_runs/validador-*.
Set-Content (Join-Path $v1 'spec/formula.md') "# formula v2 cambiada" -Encoding Ascii
$oValBlock = Invoke-Hook (Join-Path $hooksDir 'validador-stop.ps1') '{}' $v1
Check 'validador-stop: BLOQUEA spec cambiada sin evidencia de corrida' ($oValBlock.Contains('"decision":"block"') -and $oValBlock.Contains('qa_runs/validador')) "no bloqueo: $oValBlock"
# Caso BLOQUEA (Goodhart): evidencia fresca por mtime pero NO rastreada por git.
Set-Content (Join-Path $v1 '.gitignore') "qa_runs/" -Encoding Ascii
$vqa = Join-Path $v1 'qa_runs/validador-prueba'
New-Item -ItemType Directory -Path $vqa -Force | Out-Null
$vlog = Join-Path $vqa 'LOG.md'
Set-Content $vlog "entrada|obtenido|esperado" -Encoding Ascii
(Get-Item $vlog).LastWriteTime = (Get-Date).AddMinutes(5)   # fresca por mtime, pero sin trackear
$oValUntracked = Invoke-Hook (Join-Path $hooksDir 'validador-stop.ps1') '{}' $v1
Check 'validador-stop: BLOQUEA evidencia fresca pero NO rastreada por git (Goodhart)' ($oValUntracked.Contains('"decision":"block"')) "no bloqueo evidencia no-commiteada: $oValUntracked"
# Caso PASA: la misma evidencia, ahora forzada al indice con git add -f.
Push-Location $v1; git add -f qa_runs/validador-prueba/LOG.md 2>&1 | Out-Null; Pop-Location
(Get-Item $vlog).LastWriteTime = (Get-Date).AddMinutes(5)   # re-garantiza mtime posterior al cambio
$oValPass = Invoke-Hook (Join-Path $hooksDir 'validador-stop.ps1') '{}' $v1
Check 'validador-stop: DEJA cerrar con evidencia de corrida rastreada y fresca (git add -f)' (-not $oValPass.Contains('"decision":"block"')) "bloqueo indebido: $oValPass"
Remove-Item $v1 -Recurse -Force -ErrorAction SilentlyContinue

# --- validador-stop: LISTON DE EVIDENCIA -- una tabla suelta que NO es LOG.md no vale (ROJO->VERDE) ---
# Simetrico a gemba: antes cualquier archivo qa_runs/validador-* rastreado y fresco pasaba; ahora
# solo cuenta el LOG.md de la corrida (la salida del motor determinista, plantilla qa-log.md).
$v3 = New-TempRepo
New-Item -ItemType Directory -Path (Join-Path $v3 'spec') -Force | Out-Null
Set-Manifest $v3 '[{"nombre":"spec","desc":"x","fuente":["spec/*.md"],"doc_bloquea":[],"doc_avisa":[],"rol":"validador"}]'
Set-Content (Join-Path $v3 'spec/formula.md') "# formula v1" -Encoding Ascii
Set-Content (Join-Path $v3 '.gitignore') "qa_runs/" -Encoding Ascii
Push-Location $v3; git add -A 2>&1 | Out-Null; git commit -q -m init 2>&1 | Out-Null; Pop-Location
Set-Content (Join-Path $v3 'spec/formula.md') "# formula v2 cambiada" -Encoding Ascii
$vqa3 = Join-Path $v3 'qa_runs/validador-veredicto'
New-Item -ItemType Directory -Path $vqa3 -Force | Out-Null
$vd3 = Join-Path $vqa3 'veredicto.txt'
Set-Content $vd3 "validado al centavo" -Encoding Ascii
Push-Location $v3; git add -f qa_runs/validador-veredicto/veredicto.txt 2>&1 | Out-Null; Pop-Location
(Get-Item $vd3).LastWriteTime = (Get-Date).AddMinutes(5)   # rastreado y fresco, pero NO es LOG.md
$oValListn = Invoke-Hook (Join-Path $hooksDir 'validador-stop.ps1') '{}' $v3
Check 'validador-stop: BLOQUEA tabla suelta rastreada y fresca que NO es LOG.md (liston de evidencia)' ($oValListn.Contains('"decision":"block"')) "no bloqueo el archivo suelto que no es LOG.md: $oValListn"
Remove-Item $v3 -Recurse -Force -ErrorAction SilentlyContinue

# --- validador-stop DORMIDO: sin area rol validador, no dispara ---
$v2 = New-TempRepo
New-Item -ItemType Directory -Path (Join-Path $v2 'spec') -Force | Out-Null
Set-Manifest $v2 '[{"nombre":"spec","desc":"x","fuente":["spec/*.md"],"doc_bloquea":[],"doc_avisa":[],"rol":"Escribano"}]'
Set-Content (Join-Path $v2 'spec/formula.md') "# v1" -Encoding Ascii
Push-Location $v2; git add -A 2>&1 | Out-Null; git commit -q -m init 2>&1 | Out-Null; Pop-Location
Set-Content (Join-Path $v2 'spec/formula.md') "# v2" -Encoding Ascii
$oValDorm = Invoke-Hook (Join-Path $hooksDir 'validador-stop.ps1') '{}' $v2
Check 'validador-stop: DORMIDO si no hay area rol validador' (-not $oValDorm.Contains('"decision":"block"')) "bloqueo estando dormido: $oValDorm"
Remove-Item $v2 -Recurse -Force -ErrorAction SilentlyContinue

# --- rutear.ps1: el router determinista (vivo/dormido leido de la ley) ---
# rutear no bloquea nada -- reporta -- pero su logica vivo/dormido ES la que estado-motor
# y arranca muestran, asi que se prueba de vida igual: leyes sinteticas de resultado
# conocido + el fallo cerrado sin ley. Vive en tools/ (hermano de este self-test).
$rutear = Join-Path $PSScriptRoot 'rutear.ps1'
$estadoMotor = Join-Path $PSScriptRoot 'estado-motor.ps1'
function Invoke-Ps($scriptPath, $argsArr) {
  $out = (& powershell -NoProfile -ExecutionPolicy Bypass -File $scriptPath @argsArr 2>&1 | Out-String)
  return [pscustomobject]@{ out = $out; code = $LASTEXITCODE }
}
$tmpLeyes = Join-Path $env:TEMP ("jidoka-rutear-" + [guid]::NewGuid().ToString('N').Substring(0,8))
New-Item -ItemType Directory -Path $tmpLeyes -Force | Out-Null
try {
  # Ley sintetica SIN rol revisor-visual ni validador: ambos deben salir DORMIDOS.
  $leyDormido = Join-Path $tmpLeyes 'ley-dormido.json'
  Set-Content $leyDormido '[{"nombre":"docs","desc":"x","fuente":["docs/*"],"doc_avisa":["CHANGELOG.md"],"rol":"escribano"}]' -Encoding Ascii
  $rD = Invoke-Ps $rutear @('-Ley', $leyDormido, '-Gates')
  $gembaLine = ($rD.out -split "`r?`n" | Where-Object { $_ -match 'gemba-stop' }) -join ''
  Check 'rutear: gemba-stop DORMIDO cuando la ley no tiene rol revisor-visual' ($gembaLine -match 'DORMIDO') "no reporto dormido: $($rD.out)"

  # Ley sintetica CON un area rol validador: validador-stop debe salir VIVO.
  $leyValida = Join-Path $tmpLeyes 'ley-valida.json'
  Set-Content $leyValida '[{"nombre":"spec","desc":"x","fuente":["spec/*.md"],"doc_bloquea":[],"doc_avisa":[],"rol":"validador"}]' -Encoding Ascii
  $rV = Invoke-Ps $rutear @('-Ley', $leyValida, '-Gates')
  $valLine = ($rV.out -split "`r?`n" | Where-Object { $_ -match 'validador-stop' }) -join ''
  Check 'rutear: validador-stop VIVO con area rol validador' ($valLine -match 'VIVO' -and $valLine -notmatch 'DORMIDO') "no reporto vivo: $($rV.out)"

  # Falla CERRADO: sin ley legible, exit 1 (un router mudo que aprueba a ciegas es peor).
  $rF = Invoke-Ps $rutear @('-Ley', (Join-Path $tmpLeyes 'no-existe.json'))
  Check 'rutear: falla cerrado (exit 1) sin ley' ($rF.code -eq 1) "no fallo cerrado (code=$($rF.code)): $($rF.out)"

  # estado-motor imprime la seccion Gates SIEMPRE (aun sin sello: la dormancia es visible).
  $rE = Invoke-Ps $estadoMotor @()
  Check 'estado-motor: imprime la seccion Gates (dormancia visible antes del sello)' ($rE.out -match 'Gates \(Stop hooks\)') "no imprimio la seccion Gates: $($rE.out)"
}
finally { Remove-Item $tmpLeyes -Recurse -Force -ErrorAction SilentlyContinue }

Write-Host ""
if ($script:fallos -gt 0) {
  Write-Host "== $($script:fallos) de $($script:casos) caso(s) fallidos. Un hook tiene un bug: no lo estrenes. ==" -ForegroundColor Red
  exit 1
}
Write-Host "== Hooks sanos: los $($script:casos) casos se comportan como se espera. ==" -ForegroundColor Green
exit 0
