# validador-stop.ps1 - Stop hook (validador: verificar por MEDICION). Si hay cambios sin
# commitear en areas de DATOS/ESPECIFICACION (rol 'validador' en la ley), exige EVIDENCIA
# VERIFICABLE de una corrida de motor determinista en qa_runs/validador-* antes de cerrar:
# un "validado al centavo" en prosa NO vale (disparo evidencia-no-palabra, variante medicion).
# El gate lee el artefacto (la tabla entrada->obtenido->esperado que emite el motor), no la
# palabra del agente.
#
# Hermano de gemba-stop (revisor-visual/pixeles) pero para NUMEROS: una spec numerica o un
# dataset que debe verificarse recalculando contra golden-masters. SE AUTO-CONFIGURA desde
# tools/blast-radius.json: dispara si el diff toca 'fuente' de areas con rol 'validador'. Si
# ninguna area lo es, el hook esta DORMIDO (exit limpio; su dormancia se declara en
# andon/README.md, no se re-anuncia cada turno). En Jidoka nace dormido: el metodo no tiene
# deliverable de datos/spec propio; su prueba de vida vive en el self-test (probar-hooks.ps1).
#
# VARIANTE LOCAL / FIXTURES CONFIDENCIALES: cuando los golden-masters son PII (gitignored,
# fuera del remoto), el motor NO puede correr en CI (el runner no los tiene). Por eso este
# gate es LOCAL (corre en Stop), como Gemba, y exige la evidencia COMMITEADA (la salida
# saneada del motor, sin datos sensibles), no la corrida en el servidor.
#
# EVIDENCIA VALIDA = el LOG.md de la corrida bajo qa_runs/validador-*/LOG.md RASTREADO POR GIT
# (git add -f; qa_runs/ suele estar gitignoreado) con mtime posterior al ultimo cambio de la
# spec -- un archivo suelto que no sea LOG.md no cuenta (el liston, ADR 0030). Lo primero cierra
# un Goodhart (un archivo fresco pero nunca commiteado satisface el mtime y git no lo ve);
# lo segundo pide Stop local (un git checkout/clone reescribe mtimes). Respaldo anti-bucle:
# marcador .claude/.validador-marker (gitignored) con el SHA1 del diff ya aprobado por el
# cliente -- valvula HUMANA para el caso raro de aprobar sin artefacto, NO auto-firma. ASCII.
#
# ERRORES (ALTO-04): sin $ErrorActionPreference global; cada git real revisa $LASTEXITCODE y
# AVISA (sin block) si git falla de verdad. "No es repo git" sigue siendo salida limpia.

# Evitar bucle si este stop ya viene de un stop-hook.
$raw = [Console]::In.ReadToEnd()
try { $inp = $raw | ConvertFrom-Json } catch { $inp = $null }
if ($inp -and $inp.stop_hook_active) { exit 0 }

if ($env:CLAUDE_PROJECT_DIR) { Set-Location $env:CLAUDE_PROJECT_DIR }
$repo = (git rev-parse --show-toplevel 2>$null)
if (-not $repo) { exit 0 }

function Write-GitFailWarning($comando, $detalle) {
  $ctx = "AVISO (validador-stop): '$comando' fallo (exit $LASTEXITCODE): $detalle. " +
         "No se pudo comprobar cambios de spec/datos; revisalos a mano y deja evidencia de una corrida en qa_runs/validador-* si aplica."
  $out = @{ hookSpecificOutput = @{ hookEventName = 'Stop'; additionalContext = $ctx } }
  $out | ConvertTo-Json -Compress -Depth 5
}

# Areas de datos/spec del manifiesto (rol validador). Se auto-configura.
$manifestPath = Join-Path $repo 'tools/blast-radius.json'
if (-not (Test-Path $manifestPath)) { exit 0 }
try { $manifest = Get-Content $manifestPath -Raw | ConvertFrom-Json } catch { exit 0 }
$areasVal = @($manifest | Where-Object { $_.rol -eq 'validador' })
if ($areasVal.Count -eq 0) { exit 0 }   # dormido: no hay areas de validacion por medicion

function Test-Pattern($path, $pattern) {
  if ($pattern -notlike '*/*' -and $path -like '*/*') { return $false }
  return ($path -like $pattern)
}

# Cambios de spec/datos sin commitear. -uall (--untracked-files=all): sin esto git COLAPSA un
# dir recien-nacido sin trackear en 'dir/' y el glob de 'fuente' no casa -> fallo-abierto (#50).
$statusRaw = git status --porcelain --untracked-files=all 2>&1
if ($LASTEXITCODE -ne 0) { Write-GitFailWarning 'git status --porcelain' ($statusRaw -join ' '); exit 0 }
$changed = @($statusRaw) | ForEach-Object { $s = "$_"; if ($s.Length -gt 3) { $s.Substring(3).Trim() } }
$valChanged = @()
foreach ($f in $changed) {
  foreach ($area in $areasVal) {
    $hit = $false
    foreach ($pat in $area.fuente) { if (Test-Pattern $f $pat) { $hit = $true; break } }
    if ($hit -and $area.excluye) {
      foreach ($ex in $area.excluye) { if (Test-Pattern $f $ex) { $hit = $false; break } }
    }
    if ($hit) { $valChanged += $f; break }
  }
}
if ($valChanged.Count -eq 0) { exit 0 }

# Ultimo cambio de spec (mtime; corre local en Stop, donde el mtime es fiable).
$lastVal = Get-Date '2000-01-01'
foreach ($f in $valChanged) {
  $p = Join-Path $repo $f
  if (Test-Path -LiteralPath $p) {
    $t = (Get-Item -LiteralPath $p).LastWriteTime
    if ($t -gt $lastVal) { $lastVal = $t }
  }
}

# Evidencia fresca Y RASTREADA POR GIT bajo qa_runs/validador-*. Solo cuentan los archivos que
# git rastrea (git add -f), no los que solo estan en disco -- evidencia-no-palabra exige que
# EXISTA EN GIT. core.quotepath=false: que git NO octalice rutas no-ASCII (asi Test-Path las halla).
$qaTrackedRaw = git -C $repo -c core.quotepath=false ls-files -- qa_runs 2>&1
if ($LASTEXITCODE -ne 0) { Write-GitFailWarning 'git ls-files -- qa_runs' ($qaTrackedRaw -join ' '); exit 0 }
foreach ($rel in @($qaTrackedRaw)) {
  if (-not $rel) { continue }
  # LISTON DE EVIDENCIA: solo cuenta el LOG.md de la corrida (qa_runs/validador-<corrida>/LOG.md,
  # plantilla kit/.jidoka/templates/qa-log.md). Un archivo suelto satisfacia frescura+tracking
  # pero no es la salida del motor -- el liston (ADR 0030). El gate mide presencia+frescura+
  # tracking del LOG; su CONTENIDO (la tabla entrada->obtenido->esperado) lo juzga el humano.
  if ($rel -notlike 'qa_runs/validador*/LOG.md') { continue }   # solo el LOG.md de la corrida de validacion
  $abs = Join-Path $repo $rel
  if ((Test-Path -LiteralPath $abs) -and ((Get-Item -LiteralPath $abs).LastWriteTime -gt $lastVal)) {
    exit 0   # artefacto de corrida rastreado por git y posterior al cambio: evidencia valida
  }
}

# Respaldo anti-bucle: este diff exacto ya fue aprobado por el cliente sin artefacto.
$diffRaw = git diff HEAD -- $valChanged 2>&1
if ($LASTEXITCODE -ne 0) { Write-GitFailWarning 'git diff HEAD -- <spec>' ($diffRaw -join ' '); exit 0 }
$payload = (($diffRaw) -join "`n") + "|" + ($valChanged -join "`n")
$sha1 = New-Object System.Security.Cryptography.SHA1Managed
$sha = [System.BitConverter]::ToString($sha1.ComputeHash([System.Text.Encoding]::UTF8.GetBytes($payload))).Replace('-','')
$marker = Join-Path $repo '.claude\.validador-marker'
$last = if (Test-Path $marker) { (Get-Content $marker -Raw).Trim() } else { '' }
if ($sha -eq $last) { exit 0 }

$fecha = Get-Date -Format 'yyyyMMdd-HHmmss'
$ctx = "Validador (validacion por medicion): tocaste spec/datos (" + (($valChanged | Select-Object -First 5) -join ', ') + ") " +
       "y NO hay evidencia en qa_runs/validador-* posterior al cambio. Un 'validado al centavo' en prosa no vale (evidencia-no-palabra). " +
       "QUE HACER: [1] corre el MOTOR DETERMINISTA (tools/validar-<dominio>.ps1) que recalcula el artefacto contra los golden-masters " +
       "y emite la tabla entrada->obtenido->esperado + exit 0/1 -- el calculo lo hace el motor, NUNCA el LLM; " +
       "[2] guarda su salida como el LOG.md de la corrida en qa_runs/validador-$fecha/LOG.md (plantilla kit/.jidoka/templates/qa-log.md) y FORZALO al indice con 'git add -f qa_runs/validador-$fecha/LOG.md' -- SOLO cuenta el LOG.md (un veredicto suelto no vale) " +
       "(qa_runs/ esta gitignoreado; solo cuenta la evidencia que git rastrea); si los fixtures son confidenciales, commitea la salida SANEADA (sin PII), no los datos; " +
       "[3] cita la corrida desde el HANDOFF/entrega. " +
       "Caso raro (el cliente aprueba sin artefacto): Set-Content -Encoding ASCII '.claude/.validador-marker' '$sha'"
$out = @{
  decision = 'block'
  reason   = 'Spec/datos (rol validador) sin evidencia de corrida en qa_runs/validador-* (validador-stop).'
  hookSpecificOutput = @{ hookEventName = 'Stop'; additionalContext = $ctx }
}
$out | ConvertTo-Json -Compress -Depth 5
exit 0
