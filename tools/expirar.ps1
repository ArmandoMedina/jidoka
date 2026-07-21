#Requires -Version 5
# expirar.ps1 - el circuit breaker del ROADMAP (FLU-1, ADR 0045). La MECANICA de la
# muerte por defecto: mueve los items VENCIDOS del ROADMAP.md al archivo de muertos
# (docs/MUERTOS.md) con fecha y motivo. Lo que caduca no muere por juicio de nadie --
# muere por script. Convierte "podar" de decision-que-nadie-toma en evento-que-ocurre-solo.
#
# El vencimiento es por CLASE DE SERVICIO (dato de instancia en tools/flujo.json,
# clave roadmap.vencimiento_dias):
#   Con fecha  -> vence si su 'vence:' es anterior a hoy.
#   Urgente    -> alta + vencimiento_dias.urgente < hoy.
#   Normal     -> alta + vencimiento_dias.normal < hoy.
#   Algun dia  -> alta + vencimiento_dias.algun-dia < hoy.
#   Referencia -> nunca vence (landscape, sin contrato de item).
# Un item sin fecha parseable -> AVISO, no se toca (el gate contrato-roadmap ya lo
# bloquea; expirar no duplica el muro). Reproponer un muerto = agregarlo de nuevo al
# ROADMAP con alta NUEVA -- nada vuelve solo.
#
# Uso:  ./tools/expirar.ps1                       (ejecuta: mueve lo vencido, EDITA los archivos)
#       ./tools/expirar.ps1 -Simular              (dry-run: solo imprime, no toca nada; + early warning)
#       ./tools/expirar.ps1 -Hoy 2026-08-01       (inyeccion de fecha para tests; default = sistema)
#       ./tools/expirar.ps1 -Repo <ruta>          (raiz del repo, como verificar/estado-ligas)
#
# Sin clave roadmap o sin vencimiento_dias en flujo.json -> "no aplica" (exit 0): un
# repo sin el pilar de flujo no expira nada. flujo.json corrupto -> exit 2 (falla
# cerrado: una mecanica que no puede leer su contrato no borra a ciegas). ROADMAP.md
# ausente -> "no aplica" (exit 0).
#
# Nota: archivo ASCII a proposito (PS 5.1, sin depender del BOM). Los acentos que van
# al .md de salida se arman con [char] (murio/vencia/re-proponiendolo/Algun dia). Los
# archivos se leen/escriben como UTF-8 SIN BOM, preservando line endings y el resto
# byte-igual (solo se quitan las lineas que mueren).

param(
  [switch]$Simular,
  [string]$Hoy = '',
  [string]$Repo = ''
)

$ErrorActionPreference = 'Continue'
if (-not $Repo) { $Repo = Split-Path -Parent $PSScriptRoot }
Push-Location $Repo

function Fin($code) { Pop-Location; exit $code }
function Fail($msg) {
  # Falla CERRADO: si la mecanica no puede leer su contrato, no borra a ciegas (exit 2).
  Write-Host "  [ERROR] $msg" -ForegroundColor Red
  Write-Host ""
  Write-Host "== Expirar sin contrato legible: FALLA CERRADO (exit 2). No se poda a ciegas. ==" -ForegroundColor Red
  Fin 2
}

# UTF-8 SIN BOM: el mismo contrato de encoding que el ROADMAP/HANDOFF de la nave.
$utf8NoBom = New-Object System.Text.UTF8Encoding($false)

# Acentos de SALIDA (esta fuente es ASCII): se arman por codigo, no por literal.
$oAcc = [char]0x00F3   # o -> murio
$iAcc = [char]0x00ED   # i -> vencia / dia
$eAcc = [char]0x00E9   # e -> re-proponiendolo
$uAcc = [char]0x00FA   # u -> Algun / Algun dia (header y clase)

Write-Host "== Expirar (circuit breaker del ROADMAP; contrato en tools/flujo.json) =="

# --- La fecha de hoy (default sistema; -Hoy la inyecta para tests) ----------------
$hoyDate = $null
if ($Hoy) {
  $parsed = [datetime]::MinValue
  if (-not [datetime]::TryParseExact($Hoy, 'yyyy-MM-dd',
      [System.Globalization.CultureInfo]::InvariantCulture,
      [System.Globalization.DateTimeStyles]::None, [ref]$parsed)) {
    Fail "-Hoy '$Hoy' no es una fecha AAAA-MM-DD valida."
  }
  $hoyDate = $parsed.Date
}
else { $hoyDate = (Get-Date).Date }
$hoyStr = $hoyDate.ToString('yyyy-MM-dd')

# --- El contrato: flujo.json --------------------------------------------------------
$flujoCfg = $null
if (Test-Path 'tools/flujo.json') {
  try { $flujoCfg = Get-Content 'tools/flujo.json' -Raw -Encoding UTF8 | ConvertFrom-Json }
  catch { Fail "tools/flujo.json existe pero no parsea como JSON." }
  if (-not $flujoCfg) { Fail "tools/flujo.json existe pero no parsea como JSON." }
}
if (-not $flujoCfg -or -not $flujoCfg.roadmap -or -not $flujoCfg.roadmap.vencimiento_dias) {
  Write-Host "  [no aplica] sin clave roadmap.vencimiento_dias en tools/flujo.json: nada que expirar."
  Fin 0
}
if (-not (Test-Path 'ROADMAP.md')) {
  Write-Host "  [no aplica] no hay ROADMAP.md: nada que expirar."
  Fin 0
}

$vd = $flujoCfg.roadmap.vencimiento_dias
$diasUrgente = [int]$vd.urgente
$diasNormal  = [int]$vd.normal
$diasAlgun   = [int]$vd.'algun-dia'
$muertosPath = [string]$flujoCfg.roadmap.muertos
if (-not $muertosPath) { $muertosPath = 'docs/MUERTOS.md' }

# --- Leer el ROADMAP preservando EOL y el resto byte-igual --------------------------
$rawRoadmap = [System.IO.File]::ReadAllText((Join-Path $Repo 'ROADMAP.md'), $utf8NoBom)
$eolRoadmap = if ($rawRoadmap.Contains("`r`n")) { "`r`n" } else { "`n" }
$trailNL = $rawRoadmap.EndsWith("`n")
$body = $rawRoadmap
if ($trailNL) { $body = $body.Substring(0, $body.Length - $eolRoadmap.Length) }
$lines = @($body -split "\r?\n")

# --- Clasificar y detectar vencidos -------------------------------------------------
$vencidos = @()        # objetos { Index; Linea; Clase; Alta; Vence }
$sinFecha = @()        # objetos { Nombre; Clase } (AVISO, no se tocan)
$porVencer = 0         # early-warning: no vencidos pero a <=7 dias
$claseActual = $null

for ($i = 0; $i -lt $lines.Count; $i++) {
  $ln = $lines[$i]
  if ($ln -match '^## (.+)$') {
    $secTexto = $matches[1].Trim()
    $secClave = ($secTexto -replace $uAcc,'u' -replace $iAcc,'i').ToLowerInvariant()
    switch ($secClave) {
      'urgente'    { $claseActual = 'urgente' }
      'con fecha'  { $claseActual = 'confecha' }
      'normal'     { $claseActual = 'normal' }
      'algun dia'  { $claseActual = 'algundia' }
      'referencia' { $claseActual = 'referencia' }
      default      { $claseActual = $null }
    }
    continue
  }
  # Solo items de nivel RAIZ ('^- '); los sub-bullets indentados no cuentan.
  if ($ln -notmatch '^- ') { continue }
  if ($null -eq $claseActual -or $claseActual -eq 'referencia') { continue }

  $nombre = $ln.Trim()
  if ($nombre.Length -gt 60) { $nombre = $nombre.Substring(0, 60) }

  # Fecha de vencimiento segun la clase.
  $venceDate = $null
  if ($claseActual -eq 'confecha') {
    if ($ln -match 'vence:\s*(\d{4}-\d{2}-\d{2})') {
      $venceDate = [datetime]::ParseExact($matches[1], 'yyyy-MM-dd', [System.Globalization.CultureInfo]::InvariantCulture).Date
    }
  }
  else {
    if ($ln -match 'alta:\s*(\d{4}-\d{2}-\d{2})') {
      $altaDate = [datetime]::ParseExact($matches[1], 'yyyy-MM-dd', [System.Globalization.CultureInfo]::InvariantCulture).Date
      $dias = switch ($claseActual) { 'urgente' { $diasUrgente } 'normal' { $diasNormal } 'algundia' { $diasAlgun } }
      $venceDate = $altaDate.AddDays($dias)
    }
  }

  if ($null -eq $venceDate) {
    # Sin fecha parseable: AVISO, no se toca (el gate contrato-roadmap ya lo bloquea).
    $sinFecha += [pscustomobject]@{ Nombre = $nombre; Clase = $claseActual }
    continue
  }

  $altaStr = ''
  if ($ln -match 'alta:\s*(\d{4}-\d{2}-\d{2})') { $altaStr = $matches[1] }

  if ($venceDate -lt $hoyDate) {
    $vencidos += [pscustomobject]@{
      Index = $i; Linea = $ln; Nombre = $nombre; Clase = $claseActual; Alta = $altaStr; Vence = $venceDate
    }
  }
  elseif (($venceDate - $hoyDate).Days -le 7) {
    $porVencer++
  }
}

# --- Nombres legibles de clase (con acentos por [char] para el .md de salida) -------
function Clase-Display($c) {
  switch ($c) {
    'urgente'    { return 'Urgente' }
    'confecha'   { return 'Con fecha' }
    'normal'     { return 'Normal' }
    'algundia'   { return "Alg${uAcc}n d${iAcc}a" }
    default      { return $c }
  }
}

$prefijo = ''
if ($Simular) { $prefijo = '[SIMULA] ' }

# --- Avisos de items sin fecha (no se tocan) ----------------------------------------
foreach ($sf in $sinFecha) {
  Write-Host ("  [AVISO] " + $sf.Nombre + " sin fecha parseable (" + (Clase-Display $sf.Clase) + "): no se toca -- lo bloquea el gate contrato-roadmap.") -ForegroundColor Yellow
}

# --- Reporte de lo que muere --------------------------------------------------------
if ($vencidos.Count -eq 0) {
  Write-Host "  ${prefijo}0 vencidos"
}
else {
  foreach ($v in $vencidos) {
    $venceStr = $v.Vence.ToString('yyyy-MM-dd')
    $altaTxt = if ($v.Alta) { $v.Alta } else { '?' }
    Write-Host ("  ${prefijo}[MUERE] " + $v.Nombre + " -- " + (Clase-Display $v.Clase) + ", alta " + $altaTxt + ", vencia " + $venceStr) -ForegroundColor Yellow
  }
}

# --- Early warning (solo -Simular) --------------------------------------------------
if ($Simular) {
  Write-Host "  [SIMULA] $porVencer por vencer en <=7 dias (early warning)."
}

# --- Ejecucion: mover lo vencido (solo sin -Simular) --------------------------------
if (-not $Simular -and $vencidos.Count -gt 0) {
  # 1. Armar el bloque de muertos para docs/MUERTOS.md.
  $muertosAbs = Join-Path $Repo $muertosPath
  $rawMuertos = ''
  if (Test-Path $muertosAbs) { $rawMuertos = [System.IO.File]::ReadAllText($muertosAbs, $utf8NoBom) }
  $eolMuertos = if ($rawMuertos.Contains("`r`n")) { "`r`n" } else { "`n" }

  $bloque = @()
  $bloque += "## $hoyStr"
  foreach ($v in $vencidos) {
    $venceStr = $v.Vence.ToString('yyyy-MM-dd')
    $altaTxt = if ($v.Alta) { $v.Alta } else { '?' }
    $bloque += $v.Linea
    $bloque += ("  - muri${oAcc}: " + (Clase-Display $v.Clase) + ", alta " + $altaTxt + ", venc${iAcc}a " + $venceStr + "; revive re-proponi${eAcc}ndolo con alta nueva")
  }
  $bloqueTexto = ($bloque -join $eolMuertos)

  $nuevoMuertos = $rawMuertos
  if ($nuevoMuertos.Length -gt 0 -and -not $nuevoMuertos.EndsWith("`n")) { $nuevoMuertos += $eolMuertos }
  # Una linea en blanco de separacion antes de la nueva entrada, si ya habia contenido.
  if ($nuevoMuertos.Length -gt 0) { $nuevoMuertos += $eolMuertos }
  $nuevoMuertos += $bloqueTexto + $eolMuertos
  [System.IO.File]::WriteAllText($muertosAbs, $nuevoMuertos, $utf8NoBom)

  # 2. Quitar del ROADMAP las lineas muertas (+ sus sub-bullets indentados contiguos).
  $quitar = @{}
  foreach ($v in $vencidos) {
    $quitar[$v.Index] = $true
    $j = $v.Index + 1
    while ($j -lt $lines.Count -and $lines[$j] -match '^\s+\S') { $quitar[$j] = $true; $j++ }
  }
  $kept = @()
  for ($k = 0; $k -lt $lines.Count; $k++) {
    if (-not $quitar.ContainsKey($k)) { $kept += $lines[$k] }
  }
  $nuevoRoadmap = ($kept -join $eolRoadmap)
  if ($trailNL) { $nuevoRoadmap += $eolRoadmap }
  [System.IO.File]::WriteAllText((Join-Path $Repo 'ROADMAP.md'), $nuevoRoadmap, $utf8NoBom)

  Write-Host ""
  Write-Host "  == $($vencidos.Count) vencido(s) movido(s) a $muertosPath. =="
}
elseif (-not $Simular) {
  Write-Host ""
  Write-Host "  == Nada que mover: el ROADMAP esta al dia. =="
}

Fin 0
