# candado-pretooluse.ps1 - PreToolUse hook. DENIEGA en el momento en que la IA intenta
# EDITAR (Write/Edit/Bash) una pieza con CANDADO declarado en tools/contratos.json (ADR
# 0047). Es el UNICO muro determinista del meta-gobierno: el permissions.deny de settings
# es capa estatica barata (matchea prefijo de comando, NO ruta destino); este hook si mira
# el destino. El candado lo pone el humano desde la extension (R6, con firma); el hook lo
# hace cumplir contra el agente. Falla-ABIERTA (exit 0) si el stdin no parsea, o si
# contratos.json no existe o esta podrido -- el hook viaja a hijos SIN ledger y ahi no debe
# bloquear NADA. Calca no-memorias-pretooluse.ps1 (misma disciplina de redirecciones).
# Limite conocido heredado: aliases y rutas ofuscadas evaden el matcher heuristico de Bash;
# frontera confesada en andon/README.md. Se siembra (motor). ASCII a proposito, PS 5.1.
#
# Disparo: deny-vs-ask -- este hook ES el lado DENY del eje (bloqueo duro estilo Airbus para lo
# que el humano protegio): una pieza con candado no se edita (deny en el momento), no se pregunta
# (ask). El lado ask (override con juicio) queda para acciones que lo requieran.

$ErrorActionPreference = 'SilentlyContinue'

$raw = [Console]::In.ReadToEnd()
try { $inp = $raw | ConvertFrom-Json } catch { exit 0 }
if (-not $inp) { exit 0 }

# repo root = dos padres arriba de .claude/hooks/. CLAUDE_PROJECT_DIR manda si esta.
$repoRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
if ($env:CLAUDE_PROJECT_DIR) { $repoRoot = $env:CLAUDE_PROJECT_DIR }
$contratosPath = Join-Path $repoRoot 'tools/contratos.json'
if (-not (Test-Path -LiteralPath $contratosPath)) { exit 0 }   # sin ledger no hay candados (caso hijo): falla-abierta
try { $ctr = Get-Content -LiteralPath $contratosPath -Raw | ConvertFrom-Json } catch { exit 0 }  # ledger podrido: falla-abierta

# Rutas con candado (relativas al repo root, normalizadas a '/').
$candados = @()
foreach ($c in @($ctr.contratos)) {
  if ($c -and $c.path -and $c.candado) { $candados += ($c.path -replace '\\', '/') }
}
if ($candados.Count -eq 0) { exit 0 }

$hit = $null
# Editar incluye BORRAR: se agregan Remove-Item/Clear-Content/rm a los verbos de escritura.
$cmdletEscritura = 'Set-Content|Add-Content|Out-File|New-Item|Tee-Object|Move-Item|Copy-Item|Clear-Content|Remove-Item|\btee\b|\bcp\b|\bmv\b|\brm\b'

# Write/Edit: el destino es tool_input.file_path (ruta absoluta). Casa si TERMINA en la ruta
# con candado, en frontera de '/' (o es exactamente ella).
$path = $inp.tool_input.file_path
if ($path) {
  $pn = $path.Replace('\', '/')
  foreach ($rel in $candados) {
    # Comparacion LITERAL (no -like): un candado cuya ruta traiga metacaracteres de glob
    # ('[', ']', '*', '?') rompia el patron -like y fallaba-ABIERTO (agujero). EndsWith es literal.
    if ($pn -eq $rel -or $pn.EndsWith('/' + $rel, [System.StringComparison]::OrdinalIgnoreCase)) { $hit = $rel; break }
  }
}

# Bash: el destino viaja dentro de tool_input.command. Como no-memorias, solo una ESCRITURA a
# la ruta con candado: un cmdlet/utilidad de escritura + la ruta, o una redireccion ('>'/'>>')
# cuyo destino es la ruta. '2>&1'/'2>/dev/null' son stderr, NO escrituras -> no disparan.
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

if (-not $hit) { exit 0 }

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
