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

# --- La ley: emito las areas como objetos {nombre,fuente,doc_bloquea,doc_avisa,revisa}
#     para que la UI pueda reconstruir la tabla completa (nombre/disparaCon/exige). ---
try {
  $areas = @((Get-Content -LiteralPath $leyPath -Raw | ConvertFrom-Json))
}
catch {
  [Console]::Error.WriteLine("[ERROR] la ley no es JSON valido: $leyPath")
  [Console]::Error.WriteLine("        $($_.Exception.Message)")
  exit 1
}
$areasObjetos = @($areas | ForEach-Object {
  [ordered]@{
    nombre      = "$($_.nombre)"
    fuente      = @(if ($_.PSObject.Properties['fuente'])      { @($_.fuente) }      else { @() })
    doc_bloquea = @(if ($_.PSObject.Properties['doc_bloquea']) { @($_.doc_bloquea) } else { @() })
    doc_avisa   = @(if ($_.PSObject.Properties['doc_avisa'])   { @($_.doc_avisa) }   else { @() })
    revisa      = if ($_.PSObject.Properties['revisa'] -and $_.revisa) { $true } else { $false }
  }
})

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

# --- LA CONVENCION (el censo se DERIVA de las carpetas, no de una lista a mano): cada archivo
#     del repo se clasifica por su ruta. Los arboles conocidos -> su TIPO BONITO con su regimen
#     por defecto; TODO lo demas cae en un cajon por carpeta (catch-all) para que nada quede
#     invisible. El estado vivo (contratos.json) sigue mandando el regimen POR PATH encima.
#     Editar una fila aqui = un tipo nuevo; soltar un archivo en su carpeta = aparece solo. ---
$TIPOS = @(
  @{ tipo = 'Ritual — comandos';       glob = @('.claude/commands/jidoka/*.md');                          regimen = 'mal' }
  @{ tipo = 'Asientos — agentes';      glob = @('.claude/agents/*.md');                                   regimen = 'estatuto' }
  @{ tipo = 'Skills — oficios';        glob = @('.claude/skills/*/SKILL.md');                             regimen = 'motor' }
  @{ tipo = 'Hooks de Claude';         glob = @('.claude/hooks/*.ps1');                                   regimen = 'motor' }
  @{ tipo = 'git — el cinturón local'; glob = @('.githooks/*');                                           regimen = 'motor' }
  @{ tipo = 'GitHub — el muro';        glob = @('.github/workflows/*');                                   regimen = 'motor' }
  @{ tipo = 'La ley y los ledgers';    glob = @('tools/*.json', 'kit/.jidoka/instalar/manifiesto.json'); excluye = @('tuberia-piezas.json', 'jidoka-motor.json'); regimen = 'estatuto' }
  @{ tipo = 'El motor (tools/)';       glob = @('tools/*.ps1'); excluye = @('probar-*', 'tuberia-*', 'parametrizar.ps1', 'override.ps1'); regimen = 'motor' }
  @{ tipo = 'Doctrina ejecutable';     glob = @('kit/.jidoka/disparos/*.md');                             regimen = 'motor' }
  @{ tipo = 'Doctrina';                glob = @('doctrina/*.md');                                         regimen = 'motor' }
  @{ tipo = 'Templates del kit';       glob = @('kit/.jidoka/templates/*');                               regimen = 'motor' }
  @{ tipo = 'Producto — capacidades';  glob = @('product/capacidades/*.md');                              regimen = 'libre' }
  @{ tipo = 'Dominio';                 glob = @('product/dominios/*.md');                                 regimen = 'libre' }
  @{ tipo = 'Módulo';                  glob = @('product/modulos/*.md');                                  regimen = 'libre' }
  @{ tipo = 'Docs de instancia';       glob = @('product/PRODUCT_BRIEF.md', 'product/infra.md', 'product/casting.md', 'CONTRIBUTING.md', 'HANDOFF.md', 'ROADMAP.md', 'CHANGELOG.md'); regimen = 'estatuto' }
)

# Nombre lindo para el cajon catch-all segun su carpeta (lo no-mapeado). Sin acentos en las
# CLAVES (rutas), con acentos en los VALORES (contenido; el .ps1 se graba UTF-8 con BOM).
$BUCKETS = @{
  'docs/sprints'   = 'Sprints';       'docs/analisis' = 'Análisis';   'docs/decisions' = 'ADRs'
  'docs/guias'     = 'Guías';         'docs/atlas'    = 'Atlas';       'docs/assets'    = 'Assets'
  'docs'           = 'Docs (otros)';  'kanban'        = 'Kanban';      'qa_runs'        = 'Evidencia (qa_runs)'
  'app'            = 'App (código)';  'kit'           = 'Kit';         'product'        = 'Producto (otros)'
  'tools'          = 'Tools (otros)'; '.github'       = 'GitHub (otros)'; '.claude'     = 'Claude (otros)'
}
$ASSET_EXT = @('.png', '.gif', '.ico', '.jpg', '.jpeg', '.svg', '.webp', '.pdf', '.zip', '.vsix', '.woff', '.woff2', '.ttf', '.mp4')

function Get-CatchAll($path) {
  $ext = [System.IO.Path]::GetExtension($path).ToLower()
  if ($ASSET_EXT -contains $ext) { return @{ tipo = 'Otros / assets'; regimen = 'libre' } }
  $parts = $path -split '/'
  if ($parts.Count -eq 1) { return @{ tipo = 'Raíz'; regimen = 'libre' } }
  # docs/<sub>/... -> su subcarpeta; docs/<archivo> -> 'docs'. El resto -> su carpeta tope.
  $key = if ($parts[0] -eq 'docs' -and $parts.Count -ge 3) { 'docs/' + $parts[1] } elseif ($parts[0] -eq 'docs') { 'docs' } else { $parts[0] }
  $tipo = if ($BUCKETS.ContainsKey($key)) { $BUCKETS[$key] } else { $key }
  return @{ tipo = $tipo; regimen = 'libre' }
}

function Resolve-Tipo($path) {
  foreach ($t in $TIPOS) {
    foreach ($g in $t.glob) {
      if ($path -like $g) {
        $excl = $false
        if ($t.excluye) {
          $base = Split-Path $path -Leaf
          foreach ($e in $t.excluye) { if ($base -like $e) { $excl = $true; break } }
        }
        if (-not $excl) { return @{ tipo = $t.tipo; regimen = $t.regimen } }
      }
    }
  }
  return (Get-CatchAll $path)
}

# Nombre lindo para la pieza (que no se vea 'arranca.md' pelon): los comandos con su nombre
# canonico /jidoka:<x>; los .md con su primer encabezado H1 (tras el frontmatter); el resto,
# el nombre de archivo. Lee UTF-8 (acentos). Si algo falla, cae al nombre de archivo.
function Get-Nombre($path) {
  if ($path -like '.claude/commands/jidoka/*.md') {
    return '/jidoka:' + [System.IO.Path]::GetFileNameWithoutExtension($path)
  }
  if ($path -like '*.md') {
    try {
      $abs = Join-Path $repoRoot $path
      foreach ($l in (Get-Content -LiteralPath $abs -TotalCount 40 -Encoding UTF8 -ErrorAction Stop)) {
        $m = [regex]::Match($l, '^#\s+(.+?)\s*$')
        if ($m.Success) { return $m.Groups[1].Value }
      }
    }
    catch { }
    return [System.IO.Path]::GetFileNameWithoutExtension($path)
  }
  return (Split-Path $path -Leaf)
}

# --- Enumerar TODOS los archivos del repo (trackeados + no-trackeados no-ignorados), como
#     bandeja.ps1: la foto incluye lo recien soltado por el agente. -c core.quotepath=false
#     para que las rutas no-ASCII casen contra los globs. Cada archivo -> una pieza (nada
#     invisible). El regimen vivo de contratos.json manda por path sobre el default del tipo. ---
Push-Location $repoRoot
$tracked = @(git -c core.quotepath=false ls-files 2>$null)
$untracked = @(git -c core.quotepath=false ls-files --others --exclude-standard 2>$null)
Pop-Location
$allFiles = @(@($tracked + $untracked) | Where-Object { $_ } | Sort-Object -Unique)

$piezasVivas = @()
foreach ($f in $allFiles) {
  $rt = Resolve-Tipo $f
  $regimen = $rt.regimen
  $candado = $false
  $firma = $null
  if ($ctrRegimen.ContainsKey("$f")) { $regimen = $ctrRegimen["$f"] }
  if ($ctrCandado.ContainsKey("$f")) { $candado = $ctrCandado["$f"] }
  if ($ctrFirma.ContainsKey("$f"))   { $firma = $ctrFirma["$f"] }

  $piezasVivas += [ordered]@{
    id         = "$f"
    tipo       = "$($rt.tipo)"
    nombre     = (Get-Nombre $f)
    tag        = ''
    desc       = ''
    confHoy    = ''
    confVision = ''
    path       = "$f"
    regimen    = $regimen
    candado    = $candado
    firma      = $firma
  }
}

# porTipo derivado de la convencion (para la leyenda/fallback de la UI); texto/color se conservan.
$porTipoObj = [ordered]@{}
foreach ($t in $TIPOS) { if (-not $porTipoObj.Contains($t.tipo)) { $porTipoObj[$t.tipo] = $t.regimen } }
$regimenesObj = [ordered]@{
  porTipo  = $porTipoObj
  override = [ordered]@{}
  texto    = $semilla.regimenes.texto
  color    = $semilla.regimenes.color
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
  aristas   = @()
  regimenes = $regimenesObj
  bandeja   = $bandeja
  ritual    = @($ritual)
  areas     = @($areasObjetos)
}

# stdout SIN BOM y UTF-8 REAL: escribimos los bytes UTF-8 directo al stream crudo del stdout.
# NO Write-Output: la app spawnea PS sin consola (CREATE_NO_WINDOW), asi [Console]::OutputEncoding
# cae a la code page OEM (CP437) y ConvertTo-Json emitido asi corrompe '->' (byte 0x1A, un control)
# y los acentos (bytes invalidos) -> el JSON.parse de la app los rechaza ("Bad control character").
# Los bytes crudos cruzan el pipe fieles a Rust (que lee from_utf8_lossy). Ni Out-File (mete BOM).
$json = ($foto | ConvertTo-Json -Depth 8)
if (-not $json.EndsWith("`n")) { $json = $json + "`n" }
$stdout = [Console]::OpenStandardOutput()
$bytes = (New-Object System.Text.UTF8Encoding($false)).GetBytes($json)
$stdout.Write($bytes, 0, $bytes.Length); $stdout.Flush()
exit 0
