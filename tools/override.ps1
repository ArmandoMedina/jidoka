#Requires -Version 5
# override.ps1 - EL ESCRITOR UNICO de las acciones firmadas del MODO AVANZADO (R5).
# Port fiel de extension/contratos.js: registrarOverride + firmaDeterminista (ADR 0047).
# El motor PS se vuelve el unico que autora un override firmado en tools/contratos.json;
# la app Tauri lo invoca desde 'reclasResumen' (reclasificar / candado / aceptar desviacion).
# Hermano de parametrizar.ps1 (R4, el escritor del alta); calca su molde exacto de encoding.
#
# DIVERGENCIA DE DISENO CONFESADA (diverge del plan R5 a proposito):
#   El plan listaba `-Quien -Email` como parametros. AQUI NO: la firma se DERIVA de
#   `git config user.name` / `git config user.email` DENTRO del script (corriendo git en
#   $Repo). Si el llamador pudiera pasar -Quien, la app podria INVENTAR el firmante -- y el
#   ADR 0047 manda "firma derivada de git, nunca inventada". El escritor unico es dueno de la
#   regla: aborta con error si user.name esta vacio (exit 1); no hay forma de que la app
#   pase por encima. El email vacio SI se tolera (string vacio), calcando contratos.js:54
#   ('email || ''': email y cuando pueden ir vacios pero se incluyen en la firma).
#   La firma resultante = { quien, email, cuando (ISO 8601 UTC via Get-Date), motivo }.
#
# Hace, calcando registrarOverride de contratos.js EXACTO:
#   - Deriva la firma de git (quien = user.name; email = user.email o ''; cuando = ahora UTC).
#   - UPSERT del contrato en tools/contratos.json (merge por path que PRESERVA campos previos;
#     crea el contrato minimo si el path no tenia; crea el archivo si no existe -- INSTANCIA,
#     no-clobber, ADR 0046). El cambio por accion:
#       aceptar-desviacion    -> estado='aceptado'  + firma
#       candado-on            -> candado=true        + firma
#       candado-off           -> candado=false       + firma
#       reclasificar-estatuto -> regimen='estatuto'  + firma
#       reclasificar-libre    -> regimen='libre'     + firma
#     (NUNCA ofrece 'motor': ese regimen solo lo trae Jidoka de fabrica -- calca contratos.js:76.)
#
# El CONTRATO DE ENCODING con PowerShell (calca contratos.js/parametrizar.ps1): TODA escritura
# es UTF-8 SIN BOM + newline final via [System.IO.File]::WriteAllText con UTF8Encoding($false).
# JSON con ConvertTo-Json -Depth 8; arrays protegidos con @() (un array de 1 se colapsa a
# objeto en PS 5.1). Regla dura (contratos.js): jamas regex-replace del cuerpo de un JSON --
# se PARSEA, se MUTA el objeto, se re-serializa completo.
#
#   -Repo <ruta>     repo a escribir (default: el padre de tools/, o sea este repo)
#   -Path <ruta>     OBLIGATORIA: ruta relativa POSIX de la pieza (sin '..' ni absoluta)
#   -Accion <a>      OBLIGATORIA: aceptar-desviacion | candado-on | candado-off |
#                    reclasificar-estatuto | reclasificar-libre
#   -Motivo <m>      OBLIGATORIO no-vacio (sin motivo no hay reclasificacion, ADR 0047)
#   -Json            emite {ok,contrato} a stdout (UTF-8 sin BOM); si no, texto legible
#
# Exit 0 si ok; 1 si error duro (validacion, accion desconocida, o sin git user.name).
# La firma NO se inventa: sin user.name -> {ok:false} + exit 1. ASCII a proposito, PS 5.1.

param(
  [string]$Repo = '',
  [string]$Path,
  [string]$Accion,
  [string]$Motivo,
  [switch]$Json
)

$repoRoot = if ($Repo) { $Repo } else { Split-Path -Parent $PSScriptRoot }

# --- Emisor de JSON a stdout: bytes UTF-8 REALES al stream crudo (sin BOM, newline final). ---
# NO usar Write-Output: la app spawnea PS sin consola (CREATE_NO_WINDOW), asi [Console]::Output-
# Encoding cae a la code page OEM (CP437) y ConvertTo-Json emitido asi corrompe '->' (byte 0x1A,
# un control) y los acentos (bytes invalidos), que el JSON.parse de la app rechaza. Los bytes
# crudos cruzan el pipe fieles a Rust (que lee from_utf8_lossy). Los WriteAllText a archivo no
# tienen este problema (ya fijan UTF8Encoding($false)); esto es solo para el stdout que Rust lee.
function Emit-Utf8Json($json) {
  if (-not $json.EndsWith("`n")) { $json = $json + "`n" }
  $stdout = [Console]::OpenStandardOutput()
  $bytes = (New-Object System.Text.UTF8Encoding($false)).GetBytes($json)
  $stdout.Write($bytes, 0, $bytes.Length); $stdout.Flush()
}

# --- Salida de error: JSON {ok:false,error} + exit 1 (con -Json) o texto (sin -Json). ---
function Salir-Error($msg) {
  if ($Json) {
    $obj = @{ ok = $false; error = "$msg" }
    Emit-Utf8Json ($obj | ConvertTo-Json -Depth 8 -Compress)
  } else {
    Write-Host "[ERROR] $msg" -ForegroundColor Red
  }
  exit 1
}

# --- El contrato de encoding: UTF-8 SIN BOM + newline final (lo que el motor PS lee). ---
function Escribir-Texto($p, $texto) {
  if (-not $texto.EndsWith("`n")) { $texto = $texto + "`n" }
  [System.IO.File]::WriteAllText($p, $texto, (New-Object System.Text.UTF8Encoding($false)))
}
function Escribir-Json($p, $obj) {
  # ConvertTo-Json + newline final. Sin BOM. Depth 8 para la firma anidada.
  $txt = ($obj | ConvertTo-Json -Depth 8)
  Escribir-Texto $p $txt
}

# --- contratos.json (instancia): leerContratos + upsertContrato (port de contratos.js). ---
function Leer-Contratos($p) {
  if (-not (Test-Path -LiteralPath $p)) { return @{ contratos = @() } }
  $obj = Get-Content -LiteralPath $p -Raw | ConvertFrom-Json
  if (-not $obj -or $null -eq $obj.contratos) {
    throw 'contratos.json no trae la clave "contratos"'
  }
  return $obj
}

# Inserta o REEMPLAZA (merge por 'path') el contrato de una pieza. Preserva las claves
# previas que no se pisen (p.ej. un regimen/comandos previos + un candado nuevo). Devuelve
# el contrato final como hashtable. contrato: hashtable con al menos 'path'.
function Upsert-Contrato($p, $contrato) {
  if (-not $contrato -or -not $contrato['path']) { throw 'el contrato necesita "path"' }
  $obj = Leer-Contratos $p
  # Normalizo la lista existente a un array de hashtables (mutable, sin colapso PS 5.1).
  $lista = @()
  foreach ($c in @($obj.contratos)) {
    $h = @{}
    foreach ($prop in $c.PSObject.Properties) { $h[$prop.Name] = $prop.Value }
    $lista += $h
  }
  $idx = -1
  for ($i = 0; $i -lt $lista.Count; $i++) {
    if ($lista[$i]['path'] -eq $contrato['path']) { $idx = $i; break }
  }
  if ($idx -ge 0) {
    # merge: las claves nuevas ganan, las previas no pisadas se conservan.
    foreach ($k in $contrato.Keys) { $lista[$idx][$k] = $contrato[$k] }
    $final = $lista[$idx]
  } else {
    $lista += $contrato
    $final = $contrato
  }
  $raiz = @{ contratos = @($lista) }
  Escribir-Json $p $raiz
  return $final
}

# --- firmaDeterminista (port de contratos.js:51-55). LANZA si falta quien o motivo: una
# firma sin quien o sin porque es invalida. email y cuando pueden ir vacios pero se incluyen.
function Firma-Determinista($quien, $email, $cuando, $motivo) {
  if (-not $quien -or -not "$quien".Trim()) {
    throw 'la firma necesita "quien" (git config user.name)'
  }
  if (-not $motivo -or -not "$motivo".Trim()) {
    throw 'la firma necesita "motivo" (sin motivo no hay reclasificacion, ADR 0047)'
  }
  # Orden de claves fijo para que la firma serializada sea determinista.
  $firma = [ordered]@{
    quien  = "$quien"
    email  = if ($email) { "$email" } else { '' }
    cuando = if ($cuando) { "$cuando" } else { '' }
    motivo = "$motivo"
  }
  return $firma
}

# ================================ MAIN ================================

$contratosPath = Join-Path $repoRoot 'tools/contratos.json'

# --- Validacion de entradas (error duro -> JSON {ok:false,error} + exit 1). ---
if (-not $Path -or -not "$Path".Trim()) {
  Salir-Error 'Path es obligatorio (la ruta relativa POSIX de la pieza)'
}
if ([System.IO.Path]::IsPathRooted($Path) -or $Path -match '(^|[\\/])\.\.([\\/]|$)') {
  Salir-Error "Path inseguro: '$Path' no puede ser absoluto ni contener '..' como segmento"
}
$accionesOk = @('aceptar-desviacion', 'candado-on', 'candado-off', 'reclasificar-estatuto', 'reclasificar-libre')
if (-not $Accion -or $accionesOk -notcontains $Accion) {
  Salir-Error "accion desconocida: '$Accion' (usa una de: $($accionesOk -join ', '); no se ofrece 'motor', solo lo trae Jidoka de fabrica)"
}
if (-not $Motivo -or -not "$Motivo".Trim()) {
  Salir-Error 'Motivo es obligatorio no-vacio (sin motivo no hay reclasificacion, ADR 0047)'
}

# --- Deriva la firma de git (NUNCA la inventa el llamador; ADR 0047). ---
# quien = git config user.name en $Repo. Vacio -> aborta: la firma no se inventa.
$quien = (git -C $repoRoot config user.name 2>$null)
if ($quien) { $quien = "$quien".Trim() }
if (-not $quien) {
  Salir-Error 'sin git user.name -- la firma no se inventa (ADR 0047)'
}
# email = git config user.email; vacio SE TOLERA (string vacio), calca contratos.js:54.
$email = (git -C $repoRoot config user.email 2>$null)
if ($email) { $email = "$email".Trim() } else { $email = '' }
# cuando = ahora en ISO 8601 UTC (derivado con Get-Date, jamas tecleado).
$cuando = (Get-Date).ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ssZ')

try {
  $firma = Firma-Determinista $quien $email $cuando $Motivo
} catch {
  Salir-Error "firma invalida: $($_.Exception.Message)"
}

# --- El cambio por accion (calca porAccion de contratos.js:68-74). ---
$cambio = @{}
switch ($Accion) {
  'aceptar-desviacion'    { $cambio['estado']  = 'aceptado' }
  'candado-on'            { $cambio['candado']  = $true }
  'candado-off'           { $cambio['candado']  = $false }
  'reclasificar-estatuto' { $cambio['regimen']  = 'estatuto' }
  'reclasificar-libre'    { $cambio['regimen']  = 'libre' }
}

# --- UPSERT del contrato firmado (merge por path; preserva campos previos). ---
$contrato = @{ path = "$Path" }
foreach ($k in $cambio.Keys) { $contrato[$k] = $cambio[$k] }
$contrato['firma'] = $firma
try {
  $contratoFinal = Upsert-Contrato $contratosPath $contrato
} catch {
  Salir-Error "no pude escribir el override: $($_.Exception.Message)"
}

# --- Salida ---------------------------------------------------------------
if ($Json) {
  $salida = @{
    ok       = $true
    contrato = $contratoFinal
  }
  Emit-Utf8Json ($salida | ConvertTo-Json -Depth 8)
  exit 0
}

Write-Host ""
Write-Host "== Override: '$Accion' sobre '$Path' ==" -ForegroundColor Cyan
Write-Host "  contrato firmado (quien '$($firma.quien)', cuando '$($firma.cuando)')." -ForegroundColor Green
Write-Host "  motivo: $($firma.motivo)"
exit 0
