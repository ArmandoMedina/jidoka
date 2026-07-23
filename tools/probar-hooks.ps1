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

# Igual que Invoke-Hook pero DEVUELVE el exit code ademas de la salida (para los Stop hooks que
# fallan-cerrado con exit 2, y para el envoltorio del candado que deniega con exit != 0 del hijo).
function Invoke-HookFull($hookPath, $stdinJson, $projectDir) {
  $prev = $env:CLAUDE_PROJECT_DIR
  if ($projectDir) { $env:CLAUDE_PROJECT_DIR = $projectDir }
  try {
    $out = ($stdinJson | powershell -NoProfile -ExecutionPolicy Bypass -File $hookPath 2>&1 | Out-String)
    $code = $LASTEXITCODE
  }
  finally { $env:CLAUDE_PROJECT_DIR = $prev }
  return [pscustomobject]@{ out = $out; code = $code }
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

# --- candado IA (PreToolUse, contra tools/contratos.json; ADR 0047) ---
$candado = Join-Path $hooksDir 'candado-pretooluse.ps1'
$repoCand = New-TempRepo
Set-Content -Path (Join-Path $repoCand 'tools/contratos.json') -Value '{"contratos":[{"path":"tools/blast-radius.json","candado":true}]}' -Encoding Ascii
$candFP = ($repoCand -replace '\\', '/')
$outCandW = Invoke-Hook $candado ('{"tool_input":{"file_path":"' + $candFP + '/tools/blast-radius.json"}}') $repoCand
Check 'candado: DENIEGA Write/Edit a una pieza con candado' ($outCandW.Contains('"permissionDecision":"deny"')) "no denego: $outCandW"
$outCandOk = Invoke-Hook $candado ('{"tool_input":{"file_path":"' + $candFP + '/tools/otra-cosa.ps1"}}') $repoCand
Check 'candado: DEJA pasar una pieza SIN candado (silencio)' (-not $outCandOk.Contains('deny')) "denego de mas: $outCandOk"
$outCandBash = Invoke-Hook $candado '{"tool_name":"Bash","tool_input":{"command":"Set-Content -Path tools/blast-radius.json -Value x"}}' $repoCand
Check 'candado: DENIEGA escritura Bash (Set-Content) a la pieza con candado' ($outCandBash.Contains('"permissionDecision":"deny"')) "no denego el Bash: $outCandBash"
$outCandRead = Invoke-Hook $candado '{"tool_name":"Bash","tool_input":{"command":"cat tools/blast-radius.json"}}' $repoCand
Check 'candado: DEJA LEER la pieza con candado (leer no es editar)' (-not $outCandRead.Contains('deny')) "bloqueo una lectura: $outCandRead"
$outCandErr = Invoke-Hook $candado '{"tool_name":"Bash","tool_input":{"command":"cat tools/blast-radius.json 2>&1"}}' $repoCand
Check 'candado: 2>&1 NO dispara falso positivo (no es escritura)' (-not $outCandErr.Contains('deny')) "falso positivo 2>&1: $outCandErr"
$repoNoLedger = New-TempRepo
$outNoLedger = Invoke-Hook $candado ('{"tool_input":{"file_path":"' + ($repoNoLedger -replace '\\', '/') + '/tools/blast-radius.json"}}') $repoNoLedger
Check 'candado: SIN contratos.json (hijo sin ledger) -> falla-abierta (no bloquea)' (-not $outNoLedger.Contains('deny')) "bloqueo sin ledger: $outNoLedger"
Set-Content -Path (Join-Path $repoNoLedger 'tools/contratos.json') -Value '{ esto no es json valido' -Encoding Ascii
$outRot = Invoke-Hook $candado ('{"tool_input":{"file_path":"' + ($repoNoLedger -replace '\\', '/') + '/tools/blast-radius.json"}}') $repoNoLedger
Check 'candado: ledger PODRIDO -> falla-abierta (no bloquea)' (-not $outRot.Contains('deny')) "bloqueo con ledger podrido: $outRot"
$repoOff = New-TempRepo
Set-Content -Path (Join-Path $repoOff 'tools/contratos.json') -Value '{"contratos":[{"path":"tools/blast-radius.json","candado":false}]}' -Encoding Ascii
$outOff = Invoke-Hook $candado ('{"tool_input":{"file_path":"' + ($repoOff -replace '\\', '/') + '/tools/blast-radius.json"}}') $repoOff
Check 'candado: candado:false NO bloquea (solo candado:true muerde)' (-not $outOff.Contains('deny')) "bloqueo con candado:false: $outOff"
$outCandEdit = Invoke-Hook $candado ('{"tool_name":"Edit","tool_input":{"file_path":"' + $candFP + '/tools/blast-radius.json"}}') $repoCand
Check 'candado: DENIEGA Edit (no solo Write) a la pieza con candado' ($outCandEdit.Contains('"permissionDecision":"deny"')) "no denego el Edit: $outCandEdit"
$outCandBs = Invoke-Hook $candado '{"tool_name":"Bash","tool_input":{"command":"Set-Content -Path tools\\blast-radius.json -Value x"}}' $repoCand
Check 'candado: DENIEGA escritura Bash con backslash (prueba la normalizacion \\ -> /)' ($outCandBs.Contains('"permissionDecision":"deny"')) "no normalizo el backslash: $outCandBs"

# --- candado: DENEGACION INCONDICIONAL de los marcadores humanos (R3 / ADR 0058, clase auto-firma) ---
# Medido en vivo 2026-07-23: un .claude/.review-marker AUTO-FIRMADO por el agente (sin OK humano) vivio
# en disco -- "la llave junto a la cerradura". El agente NO se auto-firma: escribir .review-marker o
# .gemba-marker (los checkpoints HUMANOS) se DENIEGA siempre. La denegacion es HARDCODED (no depende de
# tools/contratos.json) -> se prueba en un repo SIN ledger. El humano firma FUERA del agente; y BORRAR
# un marcador stale sigue permitido (fail-safe: re-dispara el gate, mas estricto, nunca aprueba a ciegas).
$repoMk = New-TempRepo   # sin tools/contratos.json: prueba que la denegacion no depende del ledger
$mkFP = ($repoMk -replace '\\', '/')
$outMkReview = Invoke-Hook $candado ('{"tool_name":"Write","tool_input":{"file_path":"' + $mkFP + '/.claude/.review-marker"}}') $repoMk
Check 'candado: DENIEGA Write al marcador humano .review-marker (el agente no se auto-firma)' ($outMkReview.Contains('"permissionDecision":"deny"')) "no denego el Write al .review-marker: $outMkReview"
$outMkGemba = Invoke-Hook $candado ('{"tool_name":"Write","tool_input":{"file_path":"' + $mkFP + '/.claude/.gemba-marker"}}') $repoMk
Check 'candado: DENIEGA Write al marcador humano .gemba-marker (el agente no se auto-firma)' ($outMkGemba.Contains('"permissionDecision":"deny"')) "no denego el Write al .gemba-marker: $outMkGemba"
$outMkBash = Invoke-Hook $candado '{"tool_name":"Bash","tool_input":{"command":"Set-Content -Encoding ASCII .claude/.review-marker ABC123"}}' $repoMk
Check 'candado: DENIEGA escritura Bash (Set-Content) al marcador humano .review-marker' ($outMkBash.Contains('"permissionDecision":"deny"')) "no denego el Set-Content al marcador: $outMkBash"
$outMkRedir = Invoke-Hook $candado '{"tool_name":"Bash","tool_input":{"command":"echo ABC123 > .claude/.gemba-marker"}}' $repoMk
Check 'candado: DENIEGA redireccion Bash (>) al marcador humano .gemba-marker' ($outMkRedir.Contains('"permissionDecision":"deny"')) "no denego la redireccion al marcador: $outMkRedir"
# Control: un Write a un archivo NORMAL no se toca (la denegacion del marcador no bloquea de mas).
$outMkNorm = Invoke-Hook $candado ('{"tool_name":"Write","tool_input":{"file_path":"' + $mkFP + '/HANDOFF.md"}}') $repoMk
Check 'candado: DEJA pasar un Write a un archivo normal (la denegacion del marcador no bloquea de mas)' (-not $outMkNorm.Contains('deny')) "denego de mas un archivo normal: $outMkNorm"
# Control fail-safe: BORRAR el marcador stale (Remove-Item) sigue permitido. OJO: 'Remove-Item' contiene
# el substring 'move-Item' -- el \b del matcher evita que 'Move-Item' de un falso positivo aqui.
$outMkDel = Invoke-Hook $candado '{"tool_name":"Bash","tool_input":{"command":"Remove-Item -LiteralPath .claude/.review-marker -Force"}}' $repoMk
Check 'candado: DEJA borrar el marcador stale (Remove-Item; fail-safe, no confundir con Move-Item)' (-not $outMkDel.Contains('deny')) "bloqueo el borrado del marcador stale: $outMkDel"

# --- candado: cierre de bypasses del marcador humano (traversal '..', alias PS5.1, API .NET) ---
# Medido en vivo 2026-07-23 por auditoria: el EndsWith se esquivaba con un '..' intercalado en la ruta
# ('.claude/x/../.review-marker' -> EndsWith no casa, pero resuelve al marcador) y el matcher de Bash
# ignoraba los alias (sc/ac/ni) y las APIs .NET ([IO.File]::WriteAllText). Ahora Write resuelve la ruta
# ABSOLUTA (colapsa '..') y el matcher de Bash incluye alias + .NET. Todos deben DENEGAR.
$outMkTravW = Invoke-Hook $candado ('{"tool_name":"Write","tool_input":{"file_path":"' + $mkFP + '/.claude/x/../.review-marker"}}') $repoMk
Check 'candado: DENIEGA Write con traversal ..  al .review-marker (ruta absoluta resuelta)' ($outMkTravW.Contains('"permissionDecision":"deny"')) "no denego el Write con '..': $outMkTravW"
$outMkTravG = Invoke-Hook $candado ('{"tool_name":"Write","tool_input":{"file_path":"' + $mkFP + '/.claude/x/../.gemba-marker"}}') $repoMk
Check 'candado: DENIEGA Write con traversal ..  al .gemba-marker (ruta absoluta resuelta)' ($outMkTravG.Contains('"permissionDecision":"deny"')) "no denego el Write con '..' al gemba: $outMkTravG"
$outMkTravB = Invoke-Hook $candado '{"tool_name":"Bash","tool_input":{"command":"Set-Content .claude/x/../.review-marker ABC"}}' $repoMk
Check 'candado: DENIEGA Bash con traversal ..  al marcador (match por nombre, no por ruta)' ($outMkTravB.Contains('"permissionDecision":"deny"')) "no denego el Set-Content con '..': $outMkTravB"
$outMkSc = Invoke-Hook $candado '{"tool_name":"Bash","tool_input":{"command":"sc .claude/.review-marker ABC"}}' $repoMk
Check 'candado: DENIEGA alias sc (Set-Content) al marcador humano' ($outMkSc.Contains('"permissionDecision":"deny"')) "no denego el alias sc: $outMkSc"
$outMkAc = Invoke-Hook $candado '{"tool_name":"Bash","tool_input":{"command":"ac .claude/.review-marker ABC"}}' $repoMk
Check 'candado: DENIEGA alias ac (Add-Content) al marcador humano' ($outMkAc.Contains('"permissionDecision":"deny"')) "no denego el alias ac: $outMkAc"
$outMkNi = Invoke-Hook $candado '{"tool_name":"Bash","tool_input":{"command":"ni .claude/.gemba-marker"}}' $repoMk
Check 'candado: DENIEGA alias ni (New-Item) al marcador humano' ($outMkNi.Contains('"permissionDecision":"deny"')) "no denego el alias ni: $outMkNi"
$outMkNet = Invoke-Hook $candado '{"tool_name":"Bash","tool_input":{"command":"[IO.File]::WriteAllText(''.claude/.review-marker'',''x'')"}}' $repoMk
Check 'candado: DENIEGA la API .NET [IO.File]::WriteAllText al marcador humano' ($outMkNet.Contains('"permissionDecision":"deny"')) "no denego la API .NET: $outMkNet"
# Control fail-safe reconfirmado: BORRAR el marcador (Remove-Item) NO esta en la regex de escritura -> PASA.
$outMkDel2 = Invoke-Hook $candado '{"tool_name":"Bash","tool_input":{"command":"Remove-Item .claude/.review-marker"}}' $repoMk
Check 'candado: RE-confirma que Remove-Item del marcador sigue PASANDO (borrado no es auto-firma)' (-not $outMkDel2.Contains('deny')) "bloqueo de mas el borrado del marcador: $outMkDel2"
# Simetria (ADR arquitecto): el candado de CONTRATOS comparte la grieta alias/.NET -> tambien debe morder.
$outCandSc = Invoke-Hook $candado '{"tool_name":"Bash","tool_input":{"command":"sc tools/blast-radius.json x"}}' $repoCand
Check 'candado: DENIEGA alias sc (Set-Content) a la pieza con candado de contratos (simetria)' ($outCandSc.Contains('"permissionDecision":"deny"')) "no denego el alias sc en contratos: $outCandSc"
Remove-Item $repoMk -Recurse -Force -ErrorAction SilentlyContinue

# --- candado FAIL-CLOSED (R4): un hook del muro que TRUENA debe BLOQUEAR, no dejar pasar ---
# Medido en vivo 2026-07-23: un SyntaxError en un PreToolUse dejo pasar la escritura que debia
# bloquear, sin ruido (falla-ABIERTA). Ahora el envoltorio candado-pretooluse.ps1 corre la logica
# real en un hijo y, si el hijo truena o no emite veredicto, EMITE DENY. Se prueba plantando un
# core roto/mudo junto a una copia del envoltorio en un dir temporal.
$tmpFc = Join-Path $env:TEMP ("jidoka-candado-fc-" + [guid]::NewGuid().ToString('N').Substring(0,8))
New-Item -ItemType Directory -Path $tmpFc -Force | Out-Null
try {
  Copy-Item $candado (Join-Path $tmpFc 'candado-pretooluse.ps1') -Force
  $wrap = Join-Path $tmpFc 'candado-pretooluse.ps1'
  $stdinHit = '{"tool_name":"Write","tool_input":{"file_path":"/x/tools/blast-radius.json"}}'

  # ROJO->VERDE: core con SyntaxError (parse error -> exit != 0) -> el envoltorio DENIEGA.
  Set-Content -Path (Join-Path $tmpFc 'candado-pretooluse.core.ps1') -Value 'if (' -Encoding Ascii
  $outFcBroken = Invoke-Hook $wrap $stdinHit $null
  Check 'candado FAIL-CLOSED: core con SyntaxError -> DENIEGA (no falla-abierta)' ($outFcBroken.Contains('"permissionDecision":"deny"')) "un core roto dejo pasar (falla-abierta): $outFcBroken"

  # Core que corre pero NO emite veredicto reconocible (exit 0, ruido) -> el envoltorio DENIEGA.
  Set-Content -Path (Join-Path $tmpFc 'candado-pretooluse.core.ps1') -Value 'Write-Output "hola, no soy un veredicto"; exit 0' -Encoding Ascii
  $outFcMute = Invoke-Hook $wrap $stdinHit $null
  Check 'candado FAIL-CLOSED: core sin veredicto reconocible -> DENIEGA' ($outFcMute.Contains('"permissionDecision":"deny"')) "un core mudo dejo pasar: $outFcMute"

  # Core sano que PASA (imprime el centinela) -> el envoltorio DEJA PASAR (no rompe el camino feliz).
  Copy-Item (Join-Path $hooksDir 'candado-pretooluse.core.ps1') (Join-Path $tmpFc 'candado-pretooluse.core.ps1') -Force
  $outFcOk = Invoke-Hook $wrap '{"tool_name":"Write","tool_input":{"file_path":"/x/tools/otra-cosa.ps1"}}' $null
  Check 'candado FAIL-CLOSED: core sano que PASA -> el envoltorio deja pasar (silencio)' (-not $outFcOk.Contains('deny')) "el envoltorio denego el camino feliz: $outFcOk"
}
finally { Remove-Item $tmpFc -Recurse -Force -ErrorAction SilentlyContinue }

# --- stop_hook_active: los Stop-hooks no re-bloquean ---
foreach ($h in @('review-stop.ps1','gemba-stop.ps1','andon-stop.ps1','validador-stop.ps1')) {
  $o = Invoke-Hook (Join-Path $hooksDir $h) '{"stop_hook_active":true}' $null
  Check "${h}: respeta stop_hook_active (no re-bloquea)" (-not $o.Contains('"decision":"block"')) "bloqueo en re-entrada: $o"
}

# --- R5: los 4 Stop hooks FALLAN CERRADO (exit 2) si falta la ley tools/blast-radius.json ---
# Medido A/B 2026-07-23: con la ley presente el hook emite decision:block; SIN la ley salia exit 0
# (silencio) y dejaba cerrar -> "aprobar a ciegas". DECISION del cliente: es DEFECTO. Ahora sin la
# ley -> exit 2 ("no apruebo a ciegas"), alineado con el criterio de fallar-cerrado del gate.
$stopHooks = @('review-stop.ps1','andon-stop.ps1','gemba-stop.ps1','validador-stop.ps1')
$rNoLey = New-TempRepo   # NOTA: New-TempRepo NO crea tools/blast-radius.json
Set-Content (Join-Path $rNoLey 'tools/motor.ps1') "# v1" -Encoding Ascii
Push-Location $rNoLey; git add -A 2>&1 | Out-Null; git commit -q -m init 2>&1 | Out-Null; Pop-Location
Set-Content (Join-Path $rNoLey 'tools/motor.ps1') "# v2 cambiado sin commitear" -Encoding Ascii   # cambio pendiente (andon-stop es change-gated)
foreach ($h in $stopHooks) {
  $res = Invoke-HookFull (Join-Path $hooksDir $h) '{}' $rNoLey
  Check "${h}: FALLA CERRADO (exit 2) si falta la ley (no apruebo a ciegas)" ($res.code -eq 2) "no fallo cerrado (code=$($res.code)): $($res.out)"
}
Remove-Item $rNoLey -Recurse -Force -ErrorAction SilentlyContinue

# Control (que la cura no bloquee para siempre): CON la ley presente (sin area que dispare) NO
# fallan cerrado -- es la AUSENCIA de la ley lo que bloquea, no el cierre en si.
$rConLey = New-TempRepo
Set-Manifest $rConLey '[{"nombre":"docs","desc":"x","fuente":["docs/*"],"doc_bloquea":[],"doc_avisa":[],"rol":"escribano"}]'
Set-Content (Join-Path $rConLey 'tools/motor.ps1') "# v1" -Encoding Ascii
Push-Location $rConLey; git add -A 2>&1 | Out-Null; git commit -q -m init 2>&1 | Out-Null; Pop-Location
Set-Content (Join-Path $rConLey 'tools/motor.ps1') "# v2 cambiado sin commitear" -Encoding Ascii
foreach ($h in $stopHooks) {
  $res = Invoke-HookFull (Join-Path $hooksDir $h) '{}' $rConLey
  Check "${h}: con la ley presente (area no relacionada) NO falla cerrado (exit != 2)" ($res.code -ne 2) "fallo cerrado con la ley presente (code=$($res.code)): $($res.out)"
}
Remove-Item $rConLey -Recurse -Force -ErrorAction SilentlyContinue

# --- R5 (camino gemelo): los 4 Stop hooks FALLAN CERRADO (exit 2) si la ley EXISTE pero esta CORRUPTA ---
# Medido A/B 2026-07-23: con tools/blast-radius.json = '{ esto no es json valido' los 4 salian code=0
# (review/gemba/validador mudos; andon solo un aviso no bloqueante) -> "aprobar a ciegas" por el camino
# GEMELO del que R5 cerro con la ley ausente. Un JSON corrupto (edicion interrumpida) se dispara mas
# facil que borrar el archivo. Ahora la ley presente-pero-ilegible falla cerrado igual que la ausente.
$rLeyRota = New-TempRepo
Set-Manifest $rLeyRota '{ esto no es json valido'
Set-Content (Join-Path $rLeyRota 'tools/motor.ps1') "# v1" -Encoding Ascii
Push-Location $rLeyRota; git add -A 2>&1 | Out-Null; git commit -q -m init 2>&1 | Out-Null; Pop-Location
Set-Content (Join-Path $rLeyRota 'tools/motor.ps1') "# v2 cambiado sin commitear" -Encoding Ascii   # cambio pendiente (andon-stop es change-gated)
foreach ($h in $stopHooks) {
  $res = Invoke-HookFull (Join-Path $hooksDir $h) '{}' $rLeyRota
  Check "${h}: FALLA CERRADO (exit 2) si la ley existe pero esta CORRUPTA (no apruebo a ciegas)" ($res.code -eq 2) "no fallo cerrado con ley corrupta (code=$($res.code)): $($res.out)"
}
Remove-Item $rLeyRota -Recurse -Force -ErrorAction SilentlyContinue

# --- R5 (camino gemelo): ley presente pero VACIA/no-usable tambien falla cerrado (parsea a $null) ---
$rLeyVacia = New-TempRepo
Set-Manifest $rLeyVacia ''
Set-Content (Join-Path $rLeyVacia 'tools/motor.ps1') "# v1" -Encoding Ascii
Push-Location $rLeyVacia; git add -A 2>&1 | Out-Null; git commit -q -m init 2>&1 | Out-Null; Pop-Location
Set-Content (Join-Path $rLeyVacia 'tools/motor.ps1') "# v2 cambiado sin commitear" -Encoding Ascii   # cambio pendiente (andon-stop es change-gated)
foreach ($h in $stopHooks) {
  $res = Invoke-HookFull (Join-Path $hooksDir $h) '{}' $rLeyVacia
  Check "${h}: FALLA CERRADO (exit 2) si la ley existe pero parsea a vacio/no-usable" ($res.code -eq 2) "no fallo cerrado con ley vacia (code=$($res.code)): $($res.out)"
}
Remove-Item $rLeyVacia -Recurse -Force -ErrorAction SilentlyContinue

# --- R5 (camino gemelo): ley = '{}' (objeto vacio, JSON VALIDO) tambien falla cerrado ---
# Medido A/B 2026-07-23: un '{}' parsea a un PSCustomObject VACIO que es TRUTHY -> ESQUIVA el guard
# '-not $manifest' (que si captura null y []) y caia al camino normal: review/gemba/validador se
# declaraban 'dormidos' (0 areas de su rol) y andon no hallaba faltas -> los 4 salian exit 0 en SILENCIO,
# aprobando a ciegas. Ahora un manifiesto sin NINGUNA entrada de area usable (sin nombre+fuente) falla
# cerrado (exit 2) igual que ausente/corrupta/vacia. La dormancia LEGITIMA (ley VALIDA con areas que no
# aplican al diff) sigue en exit 0 -- eso lo blinda el bloque de control 'con la ley presente' de arriba.
$rLeyLlaves = New-TempRepo
Set-Manifest $rLeyLlaves '{}'
Set-Content (Join-Path $rLeyLlaves 'tools/motor.ps1') "# v1" -Encoding Ascii
Push-Location $rLeyLlaves; git add -A 2>&1 | Out-Null; git commit -q -m init 2>&1 | Out-Null; Pop-Location
Set-Content (Join-Path $rLeyLlaves 'tools/motor.ps1') "# v2 cambiado sin commitear" -Encoding Ascii   # cambio pendiente (andon-stop es change-gated)
foreach ($h in $stopHooks) {
  $res = Invoke-HookFull (Join-Path $hooksDir $h) '{}' $rLeyLlaves
  Check "${h}: FALLA CERRADO (exit 2) si la ley es '{}' (objeto vacio, JSON valido, sin areas usables)" ($res.code -eq 2) "no fallo cerrado con ley '{}' (code=$($res.code)): $($res.out)"
}
Remove-Item $rLeyLlaves -Recurse -Force -ErrorAction SilentlyContinue

# --- review-stop en repo temporal ---
$r1 = New-TempRepo
Set-Manifest $r1 '[{"nombre":"motor","desc":"x","fuente":["tools/*"],"doc_bloquea":[],"doc_avisa":[],"revisa":true,"rol":"x"}]'
Set-Content (Join-Path $r1 'tools/motor.ps1') "# v1" -Encoding Ascii
Push-Location $r1; git add -A 2>&1 | Out-Null; git commit -q -m init 2>&1 | Out-Null; Pop-Location
# Caso BLOQUEA: codigo (tools/*) modificado sin marcador de revision.
Set-Content (Join-Path $r1 'tools/motor.ps1') "# v2 cambiado" -Encoding Ascii
$oBlock = Invoke-Hook (Join-Path $hooksDir 'review-stop.ps1') '{}' $r1
Check 'review-stop: BLOQUEA codigo sin /code-review' ($oBlock.Contains('"decision":"block"') -and $oBlock.Contains('code-review')) "no bloqueo: $oBlock"
# R3 defecto 1: el mensaje NO debe regalar el comando de auto-firma (la llave junto a la cerradura).
# Medido en vivo 2026-07-23: el agente pego el 'Set-Content ... .review-marker' que el hook dictaba
# y se auto-firmo. El mensaje ahora manda a que un HUMANO firme, SIN incluir el comando.
Check 'review-stop: NO dicta el comando de auto-firma (sin Set-Content del marcador)' (-not ($oBlock -match 'Set-Content' -and $oBlock -match 'review-marker')) "el mensaje sigue regalando el comando de firma: $oBlock"
# Caso PASA: sin codigo sin commitear (todo commiteado).
Push-Location $r1; git add -A 2>&1 | Out-Null; git commit -q -m v2 2>&1 | Out-Null; Pop-Location
$oPass = Invoke-Hook (Join-Path $hooksDir 'review-stop.ps1') '{}' $r1
Check 'review-stop: DEJA cerrar sin codigo pendiente' (-not $oPass.Contains('"decision":"block"')) "bloqueo indebido: $oPass"
Remove-Item $r1 -Recurse -Force -ErrorAction SilentlyContinue

# --- review-stop (R3 defecto 2): el SHA del marcador cubre archivos SIN RASTREAR ---
# Medido en vivo 2026-07-23: el SHA se calculaba sobre 'git diff HEAD', que NO ve el contenido de
# un archivo NUEVO (sin rastrear) -> se edito dos veces un archivo sin rastrear del area y el SHA
# no se movio: un diff firmado como "revisado" podia llevar archivos nuevos con cualquier cosa.
# Ahora el payload anexa el contenido de los archivos sin rastrear; el SHA debe moverse. Se observa
# via la semilla de diagnostico JIDOKA_REVIEW_EMIT_SHA (stderr, apagada en produccion).
$r6 = New-TempRepo
Set-Manifest $r6 '[{"nombre":"motor","desc":"x","fuente":["tools/*"],"doc_bloquea":[],"doc_avisa":[],"revisa":true,"rol":"x"}]'
Set-Content (Join-Path $r6 'tools/base.ps1') "# base" -Encoding Ascii
Push-Location $r6; git add -A 2>&1 | Out-Null; git commit -q -m init 2>&1 | Out-Null; Pop-Location
Set-Content (Join-Path $r6 'tools/nuevo.ps1') "# contenido v1" -Encoding Ascii   # NUEVO, sin rastrear
$env:JIDOKA_REVIEW_EMIT_SHA = '1'
$o1 = Invoke-Hook (Join-Path $hooksDir 'review-stop.ps1') '{}' $r6
Set-Content (Join-Path $r6 'tools/nuevo.ps1') "# contenido v2 REESCRITO por completo distinto" -Encoding Ascii  # mismo archivo, otro contenido
$o2 = Invoke-Hook (Join-Path $hooksDir 'review-stop.ps1') '{}' $r6
$env:JIDOKA_REVIEW_EMIT_SHA = $null
$sha1m = ([regex]::Match($o1, 'REVIEW_SHA=([0-9A-Fa-f]+)')).Groups[1].Value
$sha2m = ([regex]::Match($o2, 'REVIEW_SHA=([0-9A-Fa-f]+)')).Groups[1].Value
Check 'review-stop: el SHA cubre archivos SIN RASTREAR (cambia si cambia su contenido)' (($sha1m.Length -gt 0) -and ($sha2m.Length -gt 0) -and ($sha1m -ne $sha2m)) "el SHA no se movio al reescribir un archivo sin rastrear: '$sha1m' vs '$sha2m'"
Remove-Item $r6 -Recurse -Force -ErrorAction SilentlyContinue

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

# --- asientos.ps1: el casting vivo (asiento + tier leidos de .claude/agents/) ---
# asientos no bloquea nada -- reporta -- pero su tabla ES la que arranca imprime en vez
# de una copia en prosa, asi que se prueba de vida igual: agentes sinteticos de resultado
# conocido + la degradacion acusada sin agentes. Vive en tools/ (hermano de este self-test).
$asientos = Join-Path $PSScriptRoot 'asientos.ps1'
$tmpAgentes = Join-Path $env:TEMP ("jidoka-asientos-" + [guid]::NewGuid().ToString('N').Substring(0,8))
New-Item -ItemType Directory -Path $tmpAgentes -Force | Out-Null
try {
  # Agente sintetico con frontmatter conocido: debe salir su fila asiento + tier.
  Set-Content (Join-Path $tmpAgentes 'probador.md') "---`nname: probador`ndescription: caso sintetico del self-test`nmodel: haiku`n---`n# Asiento" -Encoding Ascii
  $aOk = Invoke-Ps $asientos @('-Dir', $tmpAgentes)
  Check 'asientos: imprime la fila asiento+tier leida del frontmatter' ($aOk.out -match 'probador\s+haiku' -and $aOk.code -eq 0) "no imprimio la fila (code=$($aOk.code)): $($aOk.out)"

  # Un .md sin frontmatter (p.ej. un README) NO es un agente: no aparece en la tabla.
  Set-Content (Join-Path $tmpAgentes 'README.md') "# no soy un agente" -Encoding Ascii
  $aFantasma = Invoke-Ps $asientos @('-Dir', $tmpAgentes)
  Check 'asientos: un .md sin frontmatter no aparece como fila fantasma' ($aFantasma.out -notmatch 'README' -and $aFantasma.out -match 'probador\s+haiku') "el README aparecio en la tabla: $($aFantasma.out)"

  # Sin agentes: degrada con gracia (exit 0) y ACUSA la degradacion, no la finge.
  $aDeg = Invoke-Ps $asientos @('-Dir', (Join-Path $tmpAgentes 'no-existe'))
  Check 'asientos: sin agentes degrada acusado ([DEGRADADO], exit 0)' ($aDeg.out -match 'DEGRADADO' -and $aDeg.code -eq 0) "no acuso la degradacion (code=$($aDeg.code)): $($aDeg.out)"
}
finally { Remove-Item $tmpAgentes -Recurse -Force -ErrorAction SilentlyContinue }

# --- flujo-sessionstart.ps1: la vista de "que sigue" al abrir sesion (FLU-1, R6) ---
# El PRIMER hook SessionStart del repo empuja el estado del flujo al abrir. Prueba de
# vida: existe, settings.json lo declara en SessionStart, corre en el repo real
# imprimiendo el encabezado (exit 0), y en un dir SIN tools/estado-flujo.ps1 sale 0
# SILENCIOSO (un repo sin el pilar no ensucia el arranque).
$flujoHook = Join-Path $hooksDir 'flujo-sessionstart.ps1'
Check 'flujo-sessionstart: el archivo del hook existe' (Test-Path $flujoHook) "no existe $flujoHook"

$repoRoot = Split-Path -Parent $PSScriptRoot
$settingsPath = Join-Path $repoRoot '.claude/settings.json'
$tieneSessionStart = $false
if (Test-Path $settingsPath) {
  try {
    $settingsObj = Get-Content $settingsPath -Raw | ConvertFrom-Json
    foreach ($grp in @($settingsObj.hooks.SessionStart)) {
      foreach ($h in @($grp.hooks)) { if ("$($h.command)" -match 'flujo-sessionstart\.ps1') { $tieneSessionStart = $true } }
    }
  } catch { $tieneSessionStart = $false }
}
Check 'flujo-sessionstart: settings.json lo declara en el evento SessionStart' $tieneSessionStart "no aparece en hooks.SessionStart de .claude/settings.json"

# Corriendo en el repo REAL: imprime el encabezado y sale 0.
$outFlujoReal = Invoke-Hook $flujoHook '{"hook_event_name":"SessionStart","source":"startup"}' $repoRoot
$codeFlujoReal = $LASTEXITCODE
Check 'flujo-sessionstart: imprime el encabezado "Que sigue" en el repo real' ($outFlujoReal -match 'Que sigue \(FLU-1') "no imprimio el encabezado: $outFlujoReal"
Check 'flujo-sessionstart: sale 0 en el repo real' ($codeFlujoReal -eq 0) "exit code fue $codeFlujoReal"

# En un dir SIN tools/estado-flujo.ps1: exit 0 SILENCIOSO (sin encabezado).
$tmpNoFlujo = Join-Path $env:TEMP ("jidoka-noflujo-" + [guid]::NewGuid().ToString('N').Substring(0,8))
New-Item -ItemType Directory -Path $tmpNoFlujo -Force | Out-Null
$outNoFlujo = Invoke-Hook $flujoHook '{"hook_event_name":"SessionStart","source":"startup"}' $tmpNoFlujo
$codeNoFlujo = $LASTEXITCODE
Check 'flujo-sessionstart: dir sin tools/estado-flujo.ps1 sale 0 silencioso' (($codeNoFlujo -eq 0) -and (-not ($outNoFlujo -match 'Que sigue'))) "no salio silencioso (code=$codeNoFlujo): $outNoFlujo"
Remove-Item $tmpNoFlujo -Recurse -Force -ErrorAction SilentlyContinue

Write-Host ""
if ($script:fallos -gt 0) {
  Write-Host "== $($script:fallos) de $($script:casos) caso(s) fallidos. Un hook tiene un bug: no lo estrenes. ==" -ForegroundColor Red
  exit 1
}
Write-Host "== Hooks sanos: los $($script:casos) casos se comportan como se espera. ==" -ForegroundColor Green
exit 0
