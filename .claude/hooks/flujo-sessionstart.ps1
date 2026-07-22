# flujo-sessionstart.ps1 - SessionStart hook (FLU-1, ADR 0049). El PRIMER hook
# SessionStart del repo: al abrir sesion EMPUJA a la vista el estado del flujo -- que
# sigue y que espera a terceros -- sin que nadie lo pida (gestion visual). Ya no depende
# de que un comando se acuerde de mostrarlo.
#
# Guarda: sin tools/estado-flujo.ps1 (un repo que no sembro el pilar de flujo) sale 0
# SILENCIOSO -- no ensucia el arranque. Timeout-friendly: la vista es rapida y sin red.
#
# La raiz del repo se resuelve como los hooks hermanos: $env:CLAUDE_PROJECT_DIR (lo que
# settings.json pasa como ${CLAUDE_PROJECT_DIR}); si no esta, se deriva de la ubicacion
# del hook (.claude/hooks/ -> raiz). Archivo ASCII a proposito.

$ErrorActionPreference = 'Continue'

# SessionStart trae un JSON por stdin (info de la sesion); no lo necesitamos, pero se
# drena para no dejar el pipe colgado.
try { $null = [Console]::In.ReadToEnd() } catch {}

$repo = if ($env:CLAUDE_PROJECT_DIR) { $env:CLAUDE_PROJECT_DIR } else { Split-Path -Parent (Split-Path -Parent $PSScriptRoot) }
$esti = Join-Path $repo 'tools/estado-flujo.ps1'

# Repo sin el pilar de flujo: nada que empujar, salida silenciosa.
if (-not (Test-Path $esti)) { exit 0 }

# La vista puede traer acentos (titulos del ROADMAP): UTF-8 para que la inyeccion no los
# deforme (mismo criterio que estado-flujo.ps1).
try { [Console]::OutputEncoding = New-Object System.Text.UTF8Encoding($false) } catch {}

Write-Output "== Que sigue (FLU-1; tools/estado-flujo.ps1) =="
# El resumen humano (modo default de estado-flujo). Su stdout se inyecta al contexto de
# la sesion entrante.
$resumen = & powershell -NoProfile -ExecutionPolicy Bypass -File $esti -Repo $repo 2>&1
$resumen | ForEach-Object { Write-Output $_ }

exit 0
