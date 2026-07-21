#Requires -Version 5
# tuberia-datos.ps1 - EL CONSOLIDADOR: la foto UNICA que la app (mitad UI) lee al abrir.
# Reune en UNA llamada las piezas+aristas+regimenes de la semilla curada
# (tools/tuberia-piezas.json, spec congelada) SUPERPUESTAS con el estado VIVO del repo
# (regimen efectivo, candado y firma de tools/contratos.json), mas la bandeja y el estatuto
# del ritual (invocando bandeja.ps1 -Json y estado-ritual.ps1 -Json: REUSA, no recalcula) y
# los nombres de las areas de la ley. Emite UN JSON consolidado a stdout, UTF-8 SIN BOM.
# Es el contrato app<->motor (ADR 0048): el motor PS es el que lee; la app solo invoca.
# Falla CERRADO (exit 1) si no hay tools/blast-radius.json (no es repo Jidoka), calcando
# bandeja.ps1. contratos.json ausente = normal (instancia sin overrides). ASCII, PS 5.1.
#
# POR QUE invocar los otros scripts en PROCESO APARTE (& powershell -File ... -Json) y NO
# dot-sourcearlos: bandeja.ps1 y estado-ritual.ps1 terminan con 'exit 0'. Dot-sourcearlos
# (. $script) correria ese 'exit' en ESTE proceso y mataria el consolidador antes de emitir
# nada. El sub-proceso aisla el exit y me deja capturar SOLO su stdout JSON. Es lo robusto
# en PS 5.1 (calca el molde de probar-bandeja.ps1, que ya corre los scripts asi).

param([string]$Repo = '')

# Resolucion de $Repo: calca bandeja.ps1 (el padre de tools/ si no se pasa -Repo).
$repoRoot = if ($Repo) { $Repo } else { Split-Path -Parent $PSScriptRoot }
$leyPath = Join-Path $repoRoot 'tools/blast-radius.json'
$piezasPath = Join-Path $PSScriptRoot 'tuberia-piezas.json'
$contratosPath = Join-Path $repoRoot 'tools/contratos.json'
$versionPath = Join-Path $PSScriptRoot 'version.txt'

# --- Falla CERRADO si no es repo Jidoka (sin la ley no hay foto): calca bandeja.ps1. ---
if (-not (Test-Path -LiteralPath $leyPath)) {
  [Console]::Error.WriteLine("[ERROR] no encuentro la ley: $leyPath")
  [Console]::Error.WriteLine("        tuberia-datos necesita tools/blast-radius.json (no parece repo Jidoka).")
  exit 1
}
if (-not (Test-Path -LiteralPath $piezasPath)) {
  [Console]::Error.WriteLine("[ERROR] no encuentro la semilla: $piezasPath")
  [Console]::Error.WriteLine("        tuberia-datos necesita tools/tuberia-piezas.json (el censo curado de la maqueta).")
  exit 1
}

# --- Semilla curada (piezas+aristas+regimenes). UTF-8; ConvertFrom-Json respeta acentos. ---
try {
  $semilla = Get-Content -LiteralPath $piezasPath -Raw -Encoding UTF8 | ConvertFrom-Json
}
catch {
  [Console]::Error.WriteLine("[ERROR] la semilla no es JSON valido: $piezasPath")
  [Console]::Error.WriteLine("        $($_.Exception.Message)")
  exit 1
}

# --- La ley: solo necesito los NOMBRES de las areas para el campo 'areas'. ---
try {
  $areas = @((Get-Content -LiteralPath $leyPath -Raw | ConvertFrom-Json))
}
catch {
  [Console]::Error.WriteLine("[ERROR] la ley no es JSON valido: $leyPath")
  [Console]::Error.WriteLine("        $($_.Exception.Message)")
  exit 1
}
$areasNombres = @($areas | ForEach-Object { "$($_.nombre)" })

# --- Estado VIVO de contratos.json (ausente = normal: sin overrides). Indexado por path. ---
$ctrRegimen = @{}   # path -> regimen (override)
$ctrCandado = @{}   # path -> bool
$ctrFirma = @{}     # path -> texto de firma (quien)
if (Test-Path -LiteralPath $contratosPath) {
  try {
    $ctr = Get-Content -LiteralPath $contratosPath -Raw | ConvertFrom-Json
    foreach ($c in @($ctr.contratos)) {
      if (-not $c.path) { continue }
      if ($c.regimen) { $ctrRegimen["$($c.path)"] = "$($c.regimen)" }
      if ($null -ne $c.candado) { $ctrCandado["$($c.path)"] = [bool]$c.candado }
      if ($c.firma -and $c.firma.quien) { $ctrFirma["$($c.path)"] = "$($c.firma.quien)" }
    }
  }
  catch { }   # contrato ilegible: se ignora (instancia mal formada no debe tumbar la foto)
}

# --- Regimenes de la semilla: porTipo (+ override por id) es el DEFAULT; contratos.json
#     puede sobrescribir el regimen POR PATH (el estado vivo manda sobre la spec). ---
$regPorTipo = $semilla.regimenes.porTipo
$regOverride = $semilla.regimenes.override
if (-not $regOverride) { $regOverride = [PSCustomObject]@{} }
function Get-RegimenSemilla($pieza) {
  # override por id (la semilla) tiene prioridad sobre el default por tipo.
  $ovr = $regOverride.PSObject.Properties[$pieza.id]
  if ($ovr) { return "$($ovr.Value)" }
  $porTipo = $regPorTipo.PSObject.Properties["$($pieza.tipo)"]
  if ($porTipo) { return "$($porTipo.Value)" }
  return 'libre'
}

# --- Superponer estado vivo sobre cada pieza: regimen (con override de contrato por path),
#     candado (bool), firma (si el contrato la trae). Piezas con path=null nunca overridean. ---
$piezasVivas = @()
foreach ($p in $semilla.piezas) {
  $regimen = Get-RegimenSemilla $p
  $candado = $false
  $firma = $null
  $pathReal = if ($p.PSObject.Properties['path']) { $p.path } else { $null }
  if ($pathReal -and $ctrRegimen.ContainsKey("$pathReal")) { $regimen = $ctrRegimen["$pathReal"] }
  if ($pathReal -and $ctrCandado.ContainsKey("$pathReal")) { $candado = $ctrCandado["$pathReal"] }
  if ($pathReal -and $ctrFirma.ContainsKey("$pathReal")) { $firma = $ctrFirma["$pathReal"] }

  $piezasVivas += [ordered]@{
    id         = "$($p.id)"
    tipo       = "$($p.tipo)"
    nombre     = "$($p.nombre)"
    tag        = "$($p.tag)"
    desc       = "$($p.desc)"
    confHoy    = "$($p.confHoy)"
    confVision = "$($p.confVision)"
    path       = $pathReal
    regimen    = $regimen
    candado    = $candado
    firma      = $firma
  }
}

# --- Invocar bandeja.ps1 -Json y estado-ritual.ps1 -Json en proceso aparte (ver cabecera).
#     Capturo SOLO stdout; parseo con ConvertFrom-Json. Falla suave: si un sub-script no
#     devuelve JSON (no deberia), se guarda el objeto vacio para no tumbar la foto entera. ---
function Invoke-JsonScript($scriptName, $extraArgs) {
  $scriptPath = Join-Path $PSScriptRoot $scriptName
  if (-not (Test-Path -LiteralPath $scriptPath)) { return $null }
  $argList = @('-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', $scriptPath, '-Json') + $extraArgs
  $raw = (& powershell @argList) | Out-String
  if (-not $raw.Trim()) { return $null }
  try { return ($raw | ConvertFrom-Json) } catch { return $null }
}

$bandeja = Invoke-JsonScript 'bandeja.ps1' @('-Repo', $repoRoot)
if ($null -eq $bandeja) { $bandeja = [ordered]@{ cola = @(); aceptados = @() } }
$ritualObj = Invoke-JsonScript 'estado-ritual.ps1' @()
$ritual = if ($ritualObj -and $null -ne $ritualObj.comandos) { @($ritualObj.comandos) } else { @() }

# --- version.txt (SSOT). Si falta, cadena vacia (no es fatal para la foto). ---
$version = ''
if (Test-Path -LiteralPath $versionPath) { $version = (Get-Content -LiteralPath $versionPath -Raw).Trim() }

# --- Ruta con forward slashes (contrato con la app JS). ---
$repoAbs = (Resolve-Path -LiteralPath $repoRoot).Path
$repoFwd = $repoAbs.Replace('\', '/')

# --- La foto consolidada. @() fuerza array en las listas (trampa PS 5.1: 1 elemento se
#     colapsa a objeto). ordered para una forma estable/legible del JSON. ---
$foto = [ordered]@{
  version   = $version
  repo      = $repoFwd
  generado  = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
  piezas    = @($piezasVivas)
  aristas   = @($semilla.aristas)
  regimenes = $semilla.regimenes
  bandeja   = $bandeja
  ritual    = @($ritual)
  areas     = @($areasNombres)
}

# stdout SIN BOM: Write-Output del string de ConvertTo-Json (no Out-File, que mete BOM en PS 5.1).
Write-Output ($foto | ConvertTo-Json -Depth 8)
exit 0
