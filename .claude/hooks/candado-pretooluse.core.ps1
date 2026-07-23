# candado-pretooluse.core.ps1 - LOGICA REAL del candado IA (ADR 0047). La invoca el envoltorio
# fail-closed candado-pretooluse.ps1 en un PROCESO HIJO. Reparto de responsabilidad (R4): si ESTE
# script truena (SyntaxError, excepcion no atrapada) o NO emite veredicto, el envoltorio EMITE DENY
# -- el muro deja de fallar-ABIERTO cuando su propia logica se rompe (medido en vivo 2026-07-23).
# Por eso aqui:
#   (a) TODO camino de PASO llama Allow, que imprime el centinela <<<JIDOKA-CANDADO-OK>>>: el
#       envoltorio SOLO deja pasar si ve ese centinela con exit 0. "Silencio" ya no es "pase".
#   (b) $ErrorActionPreference='Stop' -> cualquier error inesperado TERMINA (exit != 0) y el
#       envoltorio lo convierte en BLOQUEO. Las UNICAS fallas-abiertas legitimas (hijo sin ledger /
#       ledger podrido / stdin ilegible) son Allow EXPLICITO, decision documentada, no accidente.
#
# DENIEGA en el momento en que la IA intenta EDITAR (Write/Edit/Bash) una pieza con CANDADO
# declarado en tools/contratos.json. El candado lo pone el humano desde la extension (R6, con
# firma); el hook lo hace cumplir contra el agente. permissions.deny de settings es capa estatica
# (matchea prefijo de comando, NO ruta destino); este hook si mira el destino. Limite conocido
# heredado: aliases y rutas ofuscadas evaden el matcher heuristico de Bash; frontera confesada en
# andon/README.md. Se siembra (motor). ASCII a proposito, PS 5.1.
#
# Disparo: deny-vs-ask -- este hook ES el lado DENY del eje (bloqueo duro estilo Airbus para lo que
# el humano protegio): una pieza con candado no se edita (deny), no se pregunta (ask).

$ErrorActionPreference = 'Stop'

function Allow { Write-Output '<<<JIDOKA-CANDADO-OK>>>'; exit 0 }

$raw = [Console]::In.ReadToEnd()
try { $inp = $raw | ConvertFrom-Json } catch { Allow }   # stdin ilegible: no es un hit de candado
if (-not $inp) { Allow }

# repo root = dos padres arriba de .claude/hooks/. CLAUDE_PROJECT_DIR manda si esta.
$repoRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
if ($env:CLAUDE_PROJECT_DIR) { $repoRoot = $env:CLAUDE_PROJECT_DIR }
$contratosPath = Join-Path $repoRoot 'tools/contratos.json'
if (-not (Test-Path -LiteralPath $contratosPath)) { Allow }   # sin ledger (caso hijo): falla-abierta DELIBERADA
try { $ctr = Get-Content -LiteralPath $contratosPath -Raw | ConvertFrom-Json } catch { Allow }  # ledger podrido: falla-abierta DELIBERADA

# Rutas con candado (relativas al repo root, normalizadas a '/').
$candados = @()
foreach ($c in @($ctr.contratos)) {
  if ($c -and $c.path -and $c.candado) { $candados += ($c.path -replace '\\', '/') }
}
if ($candados.Count -eq 0) { Allow }

$hit = $null
# Editar incluye BORRAR: se agregan Remove-Item/Clear-Content/rm a los verbos de escritura.
$cmdletEscritura = 'Set-Content|Add-Content|Out-File|New-Item|Tee-Object|Move-Item|Copy-Item|Clear-Content|Remove-Item|\btee\b|\bcp\b|\bmv\b|\brm\b'

# Write/Edit: el destino es tool_input.file_path (ruta absoluta). Casa si TERMINA en la ruta con
# candado, en frontera de '/' (o es exactamente ella). Comparacion LITERAL (EndsWith), no -like:
# un candado con metacaracteres de glob ('[',']','*','?') rompia el patron -like y fallaba-ABIERTO.
$path = $inp.tool_input.file_path
if ($path) {
  $pn = $path.Replace('\', '/')
  foreach ($rel in $candados) {
    if ($pn -eq $rel -or $pn.EndsWith('/' + $rel, [System.StringComparison]::OrdinalIgnoreCase)) { $hit = $rel; break }
  }
}

# Bash: el destino viaja dentro de tool_input.command. Solo una ESCRITURA a la ruta con candado:
# un cmdlet/utilidad de escritura + la ruta, o una redireccion ('>'/'>>') a la ruta. '2>&1'/
# '2>/dev/null' son stderr, NO escrituras -> no disparan.
if (-not $hit) {
  $cmd = $inp.tool_input.command
  if ($cmd) {
    $cmdNorm = $cmd.Replace('\', '/')
    foreach ($rel in $candados) {
      $relRx = [regex]::Escape($rel)
      $redirARuta = '>>?[^>&|;]*' + $relRx
      if ((($cmdNorm -match $relRx) -and ($cmdNorm -match $cmdletEscritura)) -or ($cmdNorm -match $redirARuta)) { $hit = $rel; break }
    }
  }
}

if (-not $hit) { Allow }

$razon = "Candado IA: la pieza '$hit' tiene candado en tools/contratos.json (ADR 0047): la IA no la " +
         "edita en el momento. El candado lo puso el humano desde la extension de VS Code. Si de verdad " +
         "hay que cambiarla, es MODO AVANZADO con firma (quita el candado en la extension, con motivo y " +
         "firma), no una edicion directa del agente. La UI autora, el gate ejecuta (ADR 0002/0044)."
$out = @{
  hookSpecificOutput = @{
    hookEventName            = 'PreToolUse'
    permissionDecision       = 'deny'
    permissionDecisionReason = $razon
  }
}
$out | ConvertTo-Json -Compress -Depth 5
exit 0
