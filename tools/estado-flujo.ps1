#Requires -Version 5
# estado-flujo.ps1 - la vista del ESTADO VIVO del pilar de flujo (FLU-1, ADR 0049).
# Tres modos, un molde:
#   -Gate    (R5): el muro de entrada del WIP. Imprime el veredicto y sale con codigo.
#   -Json    (R6): emite a stdout SOLO el JSON del contrato (la cara la pinta el Tauri
#                  despues; este motor no dibuja UI). Ver el contrato mas abajo.
#   (default)(R6): el RESUMEN humano compacto. Es lo que el hook SessionStart inyecta
#                  al abrir sesion -- gestion visual: el estado se EMPUJA a la vista,
#                  no se le pregunta a nadie.
#
# Drum-buffer-rope: el ritmo lo marca la ACEPTACION del cliente, no la produccion. No
# se abre un sprint nuevo con un Gemba pendiente de aceptar -- el gate se planta y
# NOMBRA cual Gemba lo bloquea.
#
# El estado es dato de INSTANCIA en tools/flujo.json (clave 'estado'):
#   wip_limite          -> el techo de trabajo en curso (dato, no muro todavia).
#   sprint_activo       -> el sprint abierto (informativo).
#   gembas_pendientes[] -> { id, desde (AAAA-MM-DD), aceptado (bool), que_ver }.
# El booleano 'aceptado' es lo que DESBLOQUEA: un Gemba con aceptado != true
# retiene la linea. La aceptacion se registra en /jidoka:gemba (aceptado:true +
# aceptado_fecha) cuando el cliente da el OK; el cierre registra el Gemba nuevo.
#
# Modo -Gate (R5): imprime el veredicto y sale con codigo.
#   Sin clave 'estado' en flujo.json (o sin flujo.json) -> "no aplica", exit 0
#     (un repo sin el limite WIP no se bloquea).
#   flujo.json corrupto -> FALLA CERRADO exit 2 (un gate que no puede leer su
#     contrato no aprueba a ciegas).
#   gembas_pendientes ausente -> lista vacia; wip_limite ausente -> no se aplica el
#     conteo WIP (solo gembas).
#   Entradas con aceptado != true -> [BLOQUEA] por cada una + linea final, exit 1.
#   Entrada malformada (sin id) -> AVISO, cuenta como pendiente (fail-safe: lo
#     dudoso bloquea).
#   Sin pendientes -> [OK] flujo despejado, exit 0.
#
# Modo -Json (R6): SOLO el JSON a stdout, sin decoraciones. El contrato:
#   {
#     "version": 1,
#     "sprint_activo": "...",              // estado.sprint_activo (o "")
#     "wip_limite": N,                     // estado.wip_limite (o null)
#     "gembas_pendientes": [...],          // tal cual del ledger (estado.gembas_pendientes)
#     "siguientes": [ up to 3 del ROADMAP  // primero Urgente (alta asc), luego Con fecha
#        { "titulo","clase","alta","apetito","vence"(si aplica),"espera"(si trae espera:) }
#     ],                                   //   (vence asc), luego Normal (alta asc)
#     "esperando_terceros": [              // TODOS los items vivos con marcador espera:<quien>
#        { "quien","titulo","clase" }
#     ],
#     "muertos_recientes": [ { "titulo" } ],   // items de la ULTIMA entrada ## de MUERTOS.md
#     "conteos": { "urgente":N, "con_fecha":N, "normal":N, "algun_dia":N }
#   }
#   El ROADMAP se parsea con las mismas convenciones del check [contrato-roadmap] de
#   verificar.ps1 (secciones = clase de servicio; item = '^- ' de nivel raiz; titulo =
#   el texto en negritas **...**). Sin flujo.json/ROADMAP -> JSON minimo valido con lo
#   que haya y claves vacias (la vista degrada, no truena). flujo.json corrupto -> exit 2.
#
# Modo default (R6): el RESUMEN humano compacto (<= ~15 lineas): sprint activo,
#   Gembas pendientes (o "0 pendientes"), "Siguen:" los 3 siguientes con clase/apetito,
#   "Esperando a terceros:" agrupado por quien (o nada si vacio), "Murio recientemente:"
#   (solo si hay). Lo inyecta el hook flujo-sessionstart al abrir sesion.
#
# Uso:  ./tools/estado-flujo.ps1                     (RESUMEN humano -- lo que empuja el hook)
#       ./tools/estado-flujo.ps1 -Gate               (veredicto del limite WIP)
#       ./tools/estado-flujo.ps1 -Json               (el contrato JSON para la cara Tauri)
#       ./tools/estado-flujo.ps1 -Repo <ruta>        (raiz del repo, como los hermanos)
#
# Nota: archivo ASCII a proposito (PS 5.1, sin depender del BOM). Las salidas del gate
# son ASCII por diseno; el resumen/JSON pueden traer acentos leidos del ROADMAP (titulos)
# -- por eso se fija [Console]::OutputEncoding a UTF-8 al arrancar. Los .md se leen con
# -Encoding UTF8 (mismo gotcha que verificar/expirar: sin el, PS 5.1 los lee como ANSI).

param(
  [switch]$Gate,
  [switch]$Json,
  [string]$Repo = ''
)

$ErrorActionPreference = 'Continue'
if (-not $Repo) { $Repo = Split-Path -Parent $PSScriptRoot }
Push-Location $Repo

# La salida puede traer acentos (titulos del ROADMAP). Sin esto PS 5.1 los emite en la
# codepage OEM y el hook los inyecta deformados. ASCII es subconjunto de UTF-8: el -Gate
# (ASCII puro) emite los mismos bytes, no se afecta.
try { [Console]::OutputEncoding = New-Object System.Text.UTF8Encoding($false) } catch {}

function Fin($code) { Pop-Location; exit $code }
function Fail($msg) {
  # Falla CERRADO: si no puede leer su contrato, no emite a ciegas (exit 2).
  Write-Host "  [ERROR] $msg" -ForegroundColor Red
  Write-Host ""
  Write-Host "== Estado de flujo sin veredicto: FALLA CERRADO (exit 2). Un muro que ante fallo interno se abre no es muro. ==" -ForegroundColor Red
  Fin 2
}

# ============================================================================ -Gate
# El muro de entrada del WIP (R5). Su comportamiento NO cambia: lee flujo.json, mide los
# Gembas pendientes de aceptacion y sale con codigo. Se lee su propio flujo.json a
# proposito (auto-contenido: el gate no depende de la mecanica de vista de abajo).
if ($Gate) {
  Write-Host "== Estado de flujo (limite WIP; contrato en tools/flujo.json) =="

  $flujoCfg = $null
  if (Test-Path 'tools/flujo.json') {
    try { $flujoCfg = Get-Content 'tools/flujo.json' -Raw -Encoding UTF8 | ConvertFrom-Json }
    catch { Fail "tools/flujo.json existe pero no parsea como JSON." }
    if (-not $flujoCfg) { Fail "tools/flujo.json existe pero no parsea como JSON." }
  }
  if (-not $flujoCfg -or -not $flujoCfg.estado) {
    Write-Host "  [no aplica] sin clave estado en tools/flujo.json: el limite WIP no aplica (un repo sin el pilar no se bloquea)."
    Fin 0
  }

  $estado = $flujoCfg.estado

  # wip_limite: informativo. Ausente -> no se aplica el conteo WIP (solo gembas).
  $wipParsed = 0
  $wipTxt = 'sin limite WIP declarado'
  $wipRaw = $estado.wip_limite
  if ($null -ne $wipRaw -and [int]::TryParse([string]$wipRaw, [ref]$wipParsed) -and $wipParsed -ge 0) {
    $wipTxt = "WIP limite: $wipParsed"
  }

  # gembas_pendientes ausente -> lista vacia.
  $gembas = @()
  if ($null -ne $estado.gembas_pendientes) { $gembas = @($estado.gembas_pendientes) }

  # El veredicto: cada Gemba con aceptado != true retiene la linea.
  $bloqueos = 0
  foreach ($g in $gembas) {
    $id = [string]$g.id
    if (-not $id) {
      Write-Host "  [AVISO] entrada de gembas_pendientes SIN id: malformada. Cuenta como pendiente (fail-safe: lo dudoso bloquea)." -ForegroundColor Yellow
      $bloqueos++
      continue
    }
    if ($g.aceptado -eq $true) { continue }   # aceptado explicito: no retiene
    $desde = [string]$g.desde
    if (-not $desde) { $desde = '?' }
    $queVer = [string]$g.que_ver
    if (-not $queVer) { $queVer = '(sin descripcion de que ver)' }
    Write-Host ("  [BLOQUEA] Gemba pendiente de aceptacion: {0} (desde {1}): {2}" -f $id, $desde, $queVer) -ForegroundColor Red
    $bloqueos++
  }

  if ($bloqueos -gt 0) {
    Write-Host ""
    Write-Host ("== ABRIR SPRINT NUEVO BLOQUEADO: {0} Gemba(s) esperan los ojos del cliente. El limite lo pone la aceptacion, no la produccion. ==" -f $bloqueos) -ForegroundColor Red
    Fin 1
  }

  Write-Host ("  [OK] flujo despejado: 0 Gembas pendientes ({0})" -f $wipTxt) -ForegroundColor Green
  Fin 0
}

# ==================================================================== -Json / resumen
# La VISTA de "que sigue" (R6). Comparte el mismo parseo del estado + ROADMAP + MUERTOS;
# solo cambia la forma de emitir: JSON crudo (-Json) o resumen humano (default).

# Acentos armados por codigo (esta fuente es ASCII a proposito).
$uAcc = [char]0x00FA   # u -> Algun / dia
$iAcc = [char]0x00ED   # i -> dia
$oAcc = [char]0x00F3   # o -> Murio

function Clase-Display($k) {
  switch ($k) {
    'urgente'   { 'Urgente' }
    'con_fecha' { 'Con fecha' }
    'normal'    { 'Normal' }
    'algun_dia' { "Alg${uAcc}n d${iAcc}a" }
    default     { [string]$k }
  }
}

# Parsea el ROADMAP con las convenciones del check [contrato-roadmap] de verificar.ps1:
# secciones = clase de servicio; item = '^- ' de nivel raiz (los sub-bullets no cuentan);
# titulo = el texto en negritas **...**. Referencia no lleva items vivos.
function Parse-Roadmap($roadmapPath) {
  $items = @()
  if (-not (Test-Path $roadmapPath)) { return ,$items }
  $lineas = @(Get-Content $roadmapPath -Encoding UTF8)
  $claseKey = $null
  $orden = 0
  foreach ($ln in $lineas) {
    if ($ln -match '^## (.+)$') {
      $secTexto = $matches[1].Trim()
      $secClave = ($secTexto -replace $uAcc,'u' -replace $iAcc,'i').ToLowerInvariant()
      switch ($secClave) {
        'urgente'    { $claseKey = 'urgente' }
        'con fecha'  { $claseKey = 'con_fecha' }
        'normal'     { $claseKey = 'normal' }
        'algun dia'  { $claseKey = 'algun_dia' }
        'referencia' { $claseKey = 'referencia' }
        default      { $claseKey = $null }
      }
      continue
    }
    if ($ln -notmatch '^- ') { continue }
    if ($null -eq $claseKey -or $claseKey -eq 'referencia') { continue }

    $titulo = $null
    if ($ln -match '\*\*(.+?)\*\*') { $titulo = $matches[1].Trim() }
    else { $titulo = ($ln -replace '^\s*-\s*','').Trim(); if ($titulo.Length -gt 80) { $titulo = $titulo.Substring(0,80) } }
    $alta = $null;    if ($ln -match 'alta:\s*(\d{4}-\d{2}-\d{2})')   { $alta = $matches[1] }
    # Apetito en HORAS (Nh) O MINUTOS (Nm): el contrato acepta menos de una hora, asi que la
    # vista no debe tragarse el sub-hora (con solo \d+h un 'apetito:30m' quedaria invisible).
    # Ancla de fin de unidad (?![A-Za-z]): sin ella 'apetito:30min'/'2hrs' casarian el
    # '30m'/'2h' de adentro y la vista mostraria una unidad basura como valida (R6).
    $apetito = $null; if ($ln -match 'apetito:\s*(\d+[hm])(?![A-Za-z])')  { $apetito = $matches[1] }
    $vence = $null;   if ($ln -match 'vence:\s*(\d{4}-\d{2}-\d{2})')  { $vence = $matches[1] }
    $espera = $null;  if ($ln -match 'espera:\s*([A-Za-z0-9_-]+)')    { $espera = $matches[1] }

    $items += [pscustomobject]@{
      Titulo = $titulo; ClaseKey = $claseKey; Alta = $alta; Apetito = $apetito; Vence = $vence; Espera = $espera; Orden = $orden
    }
    $orden++
  }
  return ,$items
}

# Los items de la ULTIMA entrada '## ' de docs/MUERTOS.md (lo que murio mas reciente).
function Parse-MuertosRecientes($muertosPath) {
  $res = @()
  if (-not (Test-Path $muertosPath)) { return ,$res }
  $lineas = @(Get-Content $muertosPath -Encoding UTF8)
  $lastIdx = -1
  for ($i = 0; $i -lt $lineas.Count; $i++) { if ($lineas[$i] -match '^## ') { $lastIdx = $i } }
  if ($lastIdx -lt 0) { return ,$res }
  for ($i = $lastIdx + 1; $i -lt $lineas.Count; $i++) {
    $ln = $lineas[$i]
    if ($ln -match '^## ') { break }
    if ($ln -notmatch '^- ') { continue }
    $titulo = $null
    if ($ln -match '\*\*(.+?)\*\*') { $titulo = $matches[1].Trim() }
    else { $titulo = ($ln -replace '^\s*-\s*','').Trim(); if ($titulo.Length -gt 80) { $titulo = $titulo.Substring(0,80) } }
    $res += [pscustomobject][ordered]@{ titulo = $titulo }
  }
  return ,$res
}

# --- El estado (flujo.json). Corrupto -> falla cerrado (exit 2) en ambos modos. -------
$flujoCfg = $null
if (Test-Path 'tools/flujo.json') {
  try { $flujoCfg = Get-Content 'tools/flujo.json' -Raw -Encoding UTF8 | ConvertFrom-Json }
  catch { Fail "tools/flujo.json existe pero no parsea como JSON." }
  if (-not $flujoCfg) { Fail "tools/flujo.json existe pero no parsea como JSON." }
}

$sprintActivo = ''
$wipLimite = $null
$gembasPendientes = @()
$muertosPath = 'docs/MUERTOS.md'
if ($flujoCfg) {
  if ($flujoCfg.estado) {
    if ($flujoCfg.estado.sprint_activo) { $sprintActivo = [string]$flujoCfg.estado.sprint_activo }
    $wipParsedV = 0
    if ($null -ne $flujoCfg.estado.wip_limite -and [int]::TryParse([string]$flujoCfg.estado.wip_limite, [ref]$wipParsedV)) { $wipLimite = $wipParsedV }
    if ($null -ne $flujoCfg.estado.gembas_pendientes) { $gembasPendientes = @($flujoCfg.estado.gembas_pendientes) }
  }
  if ($flujoCfg.roadmap -and $flujoCfg.roadmap.muertos) { $muertosPath = [string]$flujoCfg.roadmap.muertos }
}

# --- El ROADMAP: siguientes, esperando terceros, conteos ------------------------------
$items = Parse-Roadmap 'ROADMAP.md'

$urgentes  = @($items | Where-Object { $_.ClaseKey -eq 'urgente' }   | Sort-Object @{ Expression = { $_.Alta } }, Orden)
$confechas = @($items | Where-Object { $_.ClaseKey -eq 'con_fecha' } | Sort-Object @{ Expression = { $_.Vence } }, Orden)
$normales  = @($items | Where-Object { $_.ClaseKey -eq 'normal' }    | Sort-Object @{ Expression = { $_.Alta } }, Orden)

$siguientesRaw = @($urgentes + $confechas + $normales) | Select-Object -First 3
$siguientes = @()
foreach ($it in $siguientesRaw) {
  $o = [ordered]@{ titulo = $it.Titulo; clase = $it.ClaseKey; alta = $it.Alta; apetito = $it.Apetito }
  if ($it.ClaseKey -eq 'con_fecha' -and $it.Vence) { $o.vence = $it.Vence }
  if ($it.Espera) { $o.espera = $it.Espera }
  $siguientes += [pscustomobject]$o
}

$esperando = @()
foreach ($it in @($items | Where-Object { $_.Espera })) {
  $esperando += [pscustomobject][ordered]@{ quien = $it.Espera; titulo = $it.Titulo; clase = $it.ClaseKey }
}

$conteos = [ordered]@{
  urgente   = @($items | Where-Object { $_.ClaseKey -eq 'urgente' }).Count
  con_fecha = @($items | Where-Object { $_.ClaseKey -eq 'con_fecha' }).Count
  normal    = @($items | Where-Object { $_.ClaseKey -eq 'normal' }).Count
  algun_dia = @($items | Where-Object { $_.ClaseKey -eq 'algun_dia' }).Count
}

$muertos = Parse-MuertosRecientes $muertosPath

# ---------------------------------------------------------------------------- -Json ---
if ($Json) {
  $contrato = [ordered]@{
    version            = 1
    sprint_activo      = $sprintActivo
    wip_limite         = $wipLimite
    gembas_pendientes  = @($gembasPendientes)
    siguientes         = @($siguientes)
    esperando_terceros = @($esperando)
    muertos_recientes  = @($muertos)
    conteos            = $conteos
  }
  # SOLO el JSON a stdout (sin decoraciones): es el contrato que la cara Tauri pintara.
  Write-Output ($contrato | ConvertTo-Json -Depth 6)
  Fin 0
}

# -------------------------------------------------------------------------- resumen ---
# Compacto (<= ~15 lineas): lo que el hook SessionStart empuja al abrir sesion.
$sp = if ($sprintActivo) { $sprintActivo } else { '(sin sprint activo declarado)' }
Write-Host ("Sprint activo: {0}" -f $sp)

$pend = @($gembasPendientes | Where-Object { $_.aceptado -ne $true })
if ($pend.Count -eq 0) {
  Write-Host "Gembas pendientes: 0 pendientes"
}
else {
  $ids = ($pend | ForEach-Object { $id = [string]$_.id; if (-not $id) { '(sin id)' } else { $id } }) -join ', '
  Write-Host ("Gembas pendientes: {0} ({1})" -f $pend.Count, $ids)
}

if ($siguientes.Count -eq 0) {
  Write-Host "Siguen: (nada en la cola clasificada)"
}
else {
  Write-Host "Siguen:"
  foreach ($s in $siguientes) {
    $cd = Clase-Display $s.clase
    $ap = if ($s.apetito) { " apetito:$($s.apetito)" } else { "" }
    $ve = if ($s.PSObject.Properties['vence']) { " vence:$($s.vence)" } else { "" }
    $es = if ($s.PSObject.Properties['espera']) { " espera:$($s.espera)" } else { "" }
    Write-Host ("  - [{0}] {1}{2}{3}{4}" -f $cd, $s.titulo, $ap, $ve, $es)
  }
}

if ($esperando.Count -gt 0) {
  Write-Host "Esperando a terceros:"
  foreach ($grp in ($esperando | Group-Object quien)) {
    $tits = ($grp.Group | ForEach-Object { $_.titulo }) -join '; '
    Write-Host ("  - {0}: {1}" -f $grp.Name, $tits)
  }
}

if ($muertos.Count -gt 0) {
  $md = ($muertos | ForEach-Object { $_.titulo }) -join '; '
  Write-Host ("Muri${oAcc} recientemente: {0}" -f $md)
}

Fin 0
