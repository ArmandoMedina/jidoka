# no-memorias-pretooluse.ps1 - PreToolUse hook. Bloquea escrituras a la memoria
# persistente de Claude: la regla es "nada de memorias, todo al repo". Jidoka
# corre su propio Andon (dogfooding): el repo de la metodologia hace cumplir su
# propia doctrina. La regla se cablea como gate porque repetirla en prosa se
# olvida; el punto de control vive FUERA del LLM (la tesis de Jidoka).
#
# Que bloquea: una ESCRITURA a una carpeta de memoria de Claude
# (~/.claude/projects/<slug>/memory/), venga por Write/Edit (destino en
# tool_input.file_path) o por Bash (destino dentro de tool_input.command, con un
# token de escritura). Leer/recall de la memoria NO se bloquea. Cierra la grieta 2
# de la auditoria: antes el matcher era solo Write|Edit y un Set-Content por Bash
# lo rodeaba. Se cablea en .claude/settings.json (matcher Write|Edit|Bash).
# Archivo ASCII a proposito (PS 5.1).

$ErrorActionPreference = 'SilentlyContinue'

$raw = [Console]::In.ReadToEnd()
try { $inp = $raw | ConvertFrom-Json } catch { exit 0 }
if (-not $inp) { exit 0 }

$memoria = '/\.claude/projects/[^/]+/memory/'
$bloquear = $false

# Write/Edit: el destino es tool_input.file_path.
$path = $inp.tool_input.file_path
if ($path -and ($path.Replace('\', '/') -match $memoria)) { $bloquear = $true }

# Bash: el destino viaja dentro de tool_input.command. Solo se bloquea la ESCRITURA
# a la memoria (leer/recall es legitimo): ruta de memoria + un token de escritura.
# La redireccion '>' cubre echo/printf/etc; los cmdlets y cp/mv/tee cubren el resto.
# Limite conocido: aliases (sc/ac/ni) y rutas ofuscadas (base64, variables) evaden
# el matcher heuristico; la cobertura server-side no existe (la memoria es conducta
# del agente, no estado del repo). Frontera confesada en andon/README.md.
if (-not $bloquear) {
  $cmd = $inp.tool_input.command
  if ($cmd) {
    $cmdNorm = $cmd.Replace('\', '/')
    $escritura = 'Set-Content|Add-Content|Out-File|New-Item|Tee-Object|Move-Item|Copy-Item|>|\btee\b|\bcp\b|\bmv\b'
    if (($cmdNorm -match $memoria) -and ($cmdNorm -match $escritura)) { $bloquear = $true }
  }
}

if (-not $bloquear) { exit 0 }

$razon = "Nada de memorias: todo al repo (disparo anti-memoria de Jidoka). Lo que ibas a guardar tiene un " +
         "lugar con dueno: estado en vuelo o pendientes -> HANDOFF.md; una decision y su porque -> " +
         "docs/decisions/ (un ADR, y listalo en el indice); doctrina o hecho del dominio -> doctrina/; y si es " +
         "una regla accionable nueva, ademas su forma compilada -> kit/.jidoka/disparos/. Esta regla se cablea " +
         "porque en prosa fallo 4 veces en el laboratorio de campo antes de volverse hook (ADR 0003 de la " +
         "doctrina). Si de verdad es una preferencia personal trans-repo del usuario, pidele confirmacion " +
         "explicita antes."
$out = @{
  hookSpecificOutput = @{
    hookEventName            = 'PreToolUse'
    permissionDecision       = 'deny'
    permissionDecisionReason = $razon
  }
}
$out | ConvertTo-Json -Compress -Depth 5
exit 0
