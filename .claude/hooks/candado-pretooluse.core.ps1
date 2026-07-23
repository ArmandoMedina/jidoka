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

# DENEGACION INCONDICIONAL (R3 / ADR 0058): el AGENTE no se auto-firma. Los marcadores de checkpoint
# HUMANO (.claude/.review-marker, .claude/.gemba-marker) los pone un HUMANO FUERA del agente -- que el
# agente pueda escribirlos es "la llave junto a la cerradura" (medido en vivo: un .review-marker
# auto-firmado por el agente vivio en disco). Esto es HARDCODED, independiente de tools/contratos.json:
# aunque no haya ledger, el agente NUNCA escribe estos marcadores. El humano sigue pudiendo firmarlos
# (los escribe FUERA de la sesion del agente); solo el agente queda bloqueado aqui. Cierra R3: el
# checkpoint vive fuera del LLM de verdad.
function Deny-Marcador {
  $razon = "el marcador de revision/gemba (.claude/.review-marker / .claude/.gemba-marker) lo pone un " +
           "HUMANO fuera del agente; el agente no se auto-firma -- completa R3/ADR 0058 (el checkpoint " +
           "vive fuera del LLM). Si de verdad ya revisaste/aprobaste, firma el marcador TU MISMO fuera de " +
           "la sesion del agente; el agente no puede escribirlo (seria entregar la llave junto a la cerradura)."
  $out = @{
    hookSpecificOutput = @{
      hookEventName            = 'PreToolUse'
      permissionDecision       = 'deny'
      permissionDecisionReason = $razon
    }
  }
  $out | ConvertTo-Json -Compress -Depth 5
  exit 0
}
# repo root = dos padres arriba de .claude/hooks/. CLAUDE_PROJECT_DIR manda si esta. Se calcula AQUI
# (antes del bloque de marcadores) porque la denegacion del marcador ahora resuelve rutas absolutas
# contra el repo root para cerrar el bypass de '..' (traversal) medido en vivo 2026-07-23.
$repoRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
if ($env:CLAUDE_PROJECT_DIR) { $repoRoot = $env:CLAUDE_PROJECT_DIR }

$marcadoresHumanos = @('.claude/.review-marker', '.claude/.gemba-marker')
# Write/Edit: el destino es tool_input.file_path. Casa si TERMINA en el marcador (frontera de '/', el
# cinturon) O si la ruta ABSOLUTA RESUELTA (con '..' colapsado) iguala la del marcador -- asi un
# '.claude/x/../.review-marker' ya no esquiva el EndsWith (bypass de traversal cerrado).
$mpath = $inp.tool_input.file_path
if ($mpath) {
  $mpn = $mpath.Replace('\', '/')
  $absFull = $null
  try {
    $cand = $mpath
    if (-not [System.IO.Path]::IsPathRooted($cand)) { $cand = Join-Path $repoRoot $cand }
    $absFull = [System.IO.Path]::GetFullPath($cand)
  } catch { $absFull = $null }
  foreach ($m in $marcadoresHumanos) {
    $mAbs = [System.IO.Path]::GetFullPath((Join-Path $repoRoot $m))
    if ($mpn -eq $m -or $mpn.EndsWith('/' + $m, [System.StringComparison]::OrdinalIgnoreCase) -or
        ($absFull -and $absFull.Equals($mAbs, [System.StringComparison]::OrdinalIgnoreCase))) { Deny-Marcador }
  }
}
# Bash: una ESCRITURA al marcador (cmdlet/utilidad de escritura + la ruta, o una redireccion '>'/'>>' a
# la ruta). '2>&1'/'2>/dev/null' son stderr, NO escrituras -> no disparan (mismo criterio que el candado).
$mcmd = $inp.tool_input.command
if ($mcmd) {
  $mcmdNorm = $mcmd.Replace('\', '/')
  # Solo verbos que CREAN/ESCRIBEN contenido en el marcador (auto-firma). NO se listan Remove-Item/
  # Clear-Content/rm a proposito: BORRAR o vaciar un marcador solo hace que el gate RE-DISPARE (direccion
  # fail-safe, mas estricto, nunca aprueba a ciegas), asi que la limpieza de un marcador stale es legitima.
  # Los \b son CRITICOS: -match es case-insensitive y sin frontera 'Move-Item' casaria dentro de
  # 'Remove-Item' (substring 'move-Item') y bloquearia el borrado legitimo del marcador stale.
  # Se anaden los alias de PS5.1 (sc/ac/ni = Set-/Add-Content, New-Item) y las APIs .NET ([IO.File]::
  # Write/Append) que evadian el matcher de cmdlets. Se matchea por NOMBRE del marcador ('.review-marker'/
  # '.gemba-marker'), no por la ruta relativa completa, para que un '..' intercalado no esquive el hit.
  $escrituraRx = '\bSet-Content|\bAdd-Content|\bOut-File|\bNew-Item|\bTee-Object|\bMove-Item|\bCopy-Item|\btee\b|\bcp\b|\bmv\b|\bsc\b|\bac\b|\bni\b|\[(?:System\.)?IO\.File\]::(?:Write|Append)'
  $marcadorNombres = @('.review-marker', '.gemba-marker')
  foreach ($b in $marcadorNombres) {
    $bRx = [regex]::Escape($b)
    $redirAMarcador = '>>?[^>&|;]*' + $bRx
    if ((($mcmdNorm -match $bRx) -and ($mcmdNorm -match $escrituraRx)) -or ($mcmdNorm -match $redirAMarcador)) { Deny-Marcador }
  }
}

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
$cmdletEscritura = 'Set-Content|Add-Content|Out-File|New-Item|Tee-Object|Move-Item|Copy-Item|Clear-Content|Remove-Item|\btee\b|\bcp\b|\bmv\b|\brm\b|\bsc\b|\bac\b|\bni\b|\[(?:System\.)?IO\.File\]::(?:Write|Append)'

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
