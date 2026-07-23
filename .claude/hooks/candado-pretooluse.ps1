# candado-pretooluse.ps1 - ENVOLTORIO FAIL-CLOSED del candado IA (R4, ADR 0047). Este archivo es
# DELGADO y a prueba de parseo A PROPOSITO: casi no tiene logica, para que casi no pueda tener un
# SyntaxError. Corre la logica REAL (candado-pretooluse.core.ps1) en un PROCESO HIJO y decide:
#
#   - el core imprime el centinela <<<JIDOKA-CANDADO-OK>>> con exit 0  -> DEJA PASAR.
#   - el core imprime un veredicto deny (JSON)                          -> reenvia el DENY.
#   - el core TRUENA (SyntaxError/excepcion -> exit != 0) o NO emite
#     veredicto reconocible                                             -> EMITE DENY (falla-CERRADA).
#
# Antes, la logica vivia aqui y un SyntaxError en el hook dejaba pasar la escritura que debia
# bloquear, sin ruido (medido en vivo 2026-07-23): un muro que se cae en silencio no es un muro.
# Ahora "el hook se rompio" y "el hook aprobo" son estados DISTINTOS, y el primero BLOQUEA.
#
# Frontera deliberada: si el core NO EXISTE (repo sin motor sembrado, mismo caso que un hijo sin
# ledger) se DEJA PASAR -- no se brickea un repo a medio instalar. El fail-closed cubre el core
# PRESENTE que truena, que es el defecto medido. Patron reutilizable para cualquier hook-muro cuya
# logica pueda romperse. ASCII a proposito, PS 5.1.
#
# Disparo: deny-vs-ask -- este hook (envoltorio + core) ES el lado DENY del eje (bloqueo duro estilo
# Airbus para lo que el humano protegio con candado): la pieza no se edita (deny), no se pregunta (ask).

$raw = [Console]::In.ReadToEnd()

$deny = '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"BLOQUEO fail-closed (candado): la logica del candado (candado-pretooluse.core.ps1) truena o no emitio veredicto. No apruebo a ciegas una edicion cuando el muro no puede evaluarla. Revisa el hook del candado; hasta entonces las ediciones a piezas potencialmente con candado se bloquean."}}'

$core = Join-Path $PSScriptRoot 'candado-pretooluse.core.ps1'
if (-not (Test-Path -LiteralPath $core)) { exit 0 }   # sin core: repo sin motor, no se bloquea (como hijo sin ledger)

$out  = $raw | powershell -NoProfile -ExecutionPolicy Bypass -File $core 2>$null
$code = $LASTEXITCODE
$joined = ($out | Out-String)

if ($code -eq 0 -and $joined -match 'JIDOKA-CANDADO-OK') { exit 0 }                       # PASO explicito
if ($code -eq 0 -and $joined -match '"permissionDecision":"deny"') { Write-Output ($joined.Trim()); exit 0 }  # DENY del core

# El core truena, sale != 0, o no emite veredicto reconocible: FALLA CERRADA.
Write-Output $deny
exit 0
