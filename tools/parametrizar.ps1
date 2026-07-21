#Requires -Version 5
# parametrizar.ps1 - EL ESCRITOR UNICO de los ledgers al PARAMETRIZAR una pieza (R4).
# Port fiel de extension/contratos.js (escribir/leerContratos/upsertContrato/leerLey/
# agregarAFuente) + extension/ritual.js (insertarArroba/MARCADOR). El motor PS se vuelve
# el unico que autora contratos.json + blast-radius.json + los @ del ritual; la app Tauri
# lo invoca (ADR 0048). El port de registrarOverride/firmaDeterminista es R5 (override.ps1).
#
# Hace, en orden, calcando extension.js:409-458 (el patron "acumula avisos, jamas exito falso"):
#   1. UPSERT del contrato en tools/contratos.json (merge por path, estado 'parametrizado';
#      crea el archivo si no existe -- INSTANCIA, no-clobber, ADR 0046: jamas al manifiesto
#      de siembra).
#   2. si -Area: agrega -Path a la 'fuente' de esa area en tools/blast-radius.json
#      (idempotente; si el area no existe -> AVISO, no error: no la crea a ciegas).
#   3. por cada comando de -Comandos (csv): insertarArroba en
#      .claude/commands/jidoka/<c>.md bajo el marcador (idempotencia POR TOKEN con borde;
#      garantiza newline final; sin marcador o comando ausente -> AVISO).
# Los pasos 2-3 acumulan avisos SIN revertir el paso 1: una escritura parcial JAMAS se
# disfraza de exito (el contrato quedo; los avisos viajan al llamador para que actue).
#
# El CONTRATO DE ENCODING con PowerShell (calca ligas.js/contratos.js): TODA escritura de
# archivo es UTF-8 SIN BOM + newline final, via [System.IO.File]::WriteAllText con
# UTF8Encoding($false). JSON con ConvertTo-Json -Depth 8; arrays protegidos con @()
# (un array de 1 elemento se colapsa a objeto en PS 5.1). Regla dura (contratos.js): jamas
# regex-replace del cuerpo de un JSON -- se PARSEA, se MUTA el objeto, se re-serializa.
#
# La SUTILEZA CRITICA (ritual.js:21-25, sobrevivio a un code-review): la idempotencia del @
# es POR TOKEN CON BORDE (regex '@' + arroba + '(?![\w./-])'), para que '@docs/glo.md' NO se
# de por presente solo porque exista '@docs/glosario.md'. El @ backtickeado tambien caza.
#
#   -Repo <ruta>     repo a escribir (default: el padre de tools/, o sea este repo)
#   -Path <ruta>     OBLIGATORIA: ruta relativa POSIX de la pieza a parametrizar
#   -Tipo <t>        el tipo de la pieza (documento por defecto en el contrato)
#   -Regimen <r>     estatuto | libre
#   -Area <a>        area de la ley a la que agregar Path (opcional; vacio = no toca la ley)
#   -Fuerza <f>      avisa | bloquea (default avisa)
#   -Comandos <csv>  comandos que leen el doc, csv (p.ej. "arranca,planea"); vacio = ninguno
#   -Json            emite {ok,contrato,avisos,arrobas} a stdout (UTF-8 sin BOM); si no, texto
#
# Exit 0 si ok (aunque haya avisos); 1 si error duro (validacion o falta la ley).
# Falla CERRADO (exit 1) si no existe tools/blast-radius.json. ASCII a proposito, PS 5.1.

param(
  [string]$Repo = '',
  [string]$Path,
  [string]$Tipo,
  [string]$Regimen,
  [string]$Area = '',
  [string]$Fuerza = 'avisa',
  [string]$Comandos = '',
  [switch]$Json
)

$MARCADOR = '<!-- jidoka:arrobas -->'
$repoRoot = if ($Repo) { $Repo } else { Split-Path -Parent $PSScriptRoot }

# --- Salida de error: JSON {ok:false,error} + exit 1 (con -Json) o texto (sin -Json). ---
function Salir-Error($msg) {
  if ($Json) {
    $obj = @{ ok = $false; error = "$msg" }
    Write-Output ($obj | ConvertTo-Json -Depth 8 -Compress)
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
  # ConvertTo-Json + newline final. Sin BOM. Depth 8 para firma anidada.
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
# previas que no se pisen (p.ej. una firma vieja + un candado nuevo). Devuelve el contrato
# final como hashtable. contrato: hashtable con al menos 'path'.
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

# --- blast-radius.json (la ley, ARRAY raiz): leerLey + agregarAFuente (port). ---
function Leer-Ley($p) {
  if (-not (Test-Path -LiteralPath $p)) { throw 'no existe tools/blast-radius.json (la ley)' }
  $arr = Get-Content -LiteralPath $p -Raw | ConvertFrom-Json
  if ($arr -isnot [System.Array] -and $null -ne $arr) {
    # ConvertFrom-Json de un array de 1 elemento no lo colapsa aqui, pero por seguridad:
    if ($arr.PSObject.Properties.Name -notcontains 'nombre') {
      # no es un objeto-area suelto; si no es array, es invalido.
    }
  }
  return @($arr)
}

# Agrega la ruta a la 'fuente' de un area EXISTENTE. Idempotente: no duplica. Si el area no
# existe, NO la crea (el llamador lo convierte en AVISO). Devuelve un hashtable de resultado:
#   @{ escrito = $true/$false; areaExiste = $true/$false }
# Divergencia confesada con contratos.js:agregarAFuente: alli, si el area no existe, la CREA.
# El plan R4 ordena lo contrario ("si el area no existe -> AVISO, no error"), asi que aqui NO
# se crea el area; se reporta que no existe para que el paso lo acumule como aviso.
function Agregar-A-Fuente($p, $area, $ruta) {
  if (-not $area -or -not $ruta) { throw 'agregarAFuente necesita area y ruta' }
  # @() en el sitio de llamada: una funcion PS que retorna @($x) con 1 elemento lo RE-desenvuelve
  # a escalar al salir (trampa PS 5.1). Sin este @(), un area sola llega como PSCustomObject y
  # $arr.Count sale vacio -> el for nunca corre -> el area existente se reporta como inexistente.
  $arr = @(Leer-Ley $p)
  $idx = -1
  for ($i = 0; $i -lt $arr.Count; $i++) {
    if ($arr[$i].nombre -eq $area) { $idx = $i; break }
  }
  if ($idx -lt 0) { return @{ escrito = $false; areaExiste = $false } }
  # reconstruyo el array de areas como hashtables para mutar sin colapso.
  $areas = @()
  foreach ($a in $arr) {
    $h = @{}
    foreach ($prop in $a.PSObject.Properties) { $h[$prop.Name] = $prop.Value }
    $areas += $h
  }
  $fuente = @()
  if ($null -ne $areas[$idx]['fuente']) { $fuente = @($areas[$idx]['fuente']) }
  if ($fuente -contains $ruta) { return @{ escrito = $false; areaExiste = $true } }
  $fuente += $ruta
  $areas[$idx]['fuente'] = @($fuente)
  Escribir-Json $p @($areas)
  return @{ escrito = $true; areaExiste = $true }
}

# --- ritual.js: insertarArroba (idempotencia POR TOKEN con borde). ---
# Inserta la linea '@<arroba>' justo DESPUES del marcador. Idempotente por TOKEN: si el
# @<arroba> ya esta (en cualquier parte, seguido de fin o de un caracter que NO continua la
# ruta), no lo duplica. Preserva el resto y el EOL. Garantiza newline final SIEMPRE.
# Lanza si no hay marcador. Devuelve $true si inserto, $false si ya estaba.
function Insertar-Arroba($comandoPath, $arroba) {
  if (-not $arroba) { throw 'insertarArroba necesita la ruta del @' }
  $texto = [System.IO.File]::ReadAllText($comandoPath, (New-Object System.Text.UTF8Encoding($false)))
  $eol = if ($texto.Contains("`r`n")) { "`r`n" } else { "`n" }
  $lineas = [System.Collections.ArrayList]@($texto -split "`r?`n")
  # Idempotencia por TOKEN, no por substring: '@docs/glo.md' NO cuenta como presente solo
  # porque exista '@docs/glosario.md'. El @<arroba> seguido de fin o de un caracter que no
  # continua la ruta [\w./-] (asi tambien caza la forma backtickeada, p.ej. `@HANDOFF.md`).
  $escapada = [regex]::Escape($arroba)
  $rx = New-Object System.Text.RegularExpressions.Regex ('@' + $escapada + '(?![\w./-])')
  $yaEsta = $false
  foreach ($l in $lineas) {
    $sinEspacios = ($l -replace '\s+', '')
    if ($rx.IsMatch($sinEspacios)) { $yaEsta = $true; break }
  }
  if ($yaEsta) { return $false }
  $iMarcador = -1
  for ($i = 0; $i -lt $lineas.Count; $i++) {
    if ($lineas[$i].Contains($MARCADOR)) { $iMarcador = $i; break }
  }
  if ($iMarcador -lt 0) {
    throw "el comando $comandoPath no tiene el marcador $MARCADOR (punto de insercion)"
  }
  [void]$lineas.Insert($iMarcador + 1, '@' + $arroba)
  $salida = ($lineas -join $eol)
  if (-not $salida.EndsWith($eol)) { $salida += $eol }   # el contrato: newline final SIEMPRE
  [System.IO.File]::WriteAllText($comandoPath, $salida, (New-Object System.Text.UTF8Encoding($false)))
  return $true
}

# ================================ MAIN ================================

$leyPath = Join-Path $repoRoot 'tools/blast-radius.json'
if (-not (Test-Path -LiteralPath $leyPath)) {
  Salir-Error "no encuentro la ley: $leyPath (parametrizar necesita tools/blast-radius.json; falla cerrado)"
}

# --- Validacion de entradas (error duro -> JSON {ok:false,error} + exit 1). ---
if (-not $Path -or -not "$Path".Trim()) { Salir-Error 'Path es obligatorio (la ruta relativa POSIX de la pieza)' }
if ([System.IO.Path]::IsPathRooted($Path) -or $Path -match '(^|[\\/])\.\.([\\/]|$)') {
  Salir-Error "Path inseguro: '$Path' no puede ser absoluto ni contener '..' como segmento"
}
if ($Regimen -and @('estatuto', 'libre') -notcontains $Regimen) {
  Salir-Error "Regimen invalido: '$Regimen' (debe ser 'estatuto' o 'libre')"
}
if ($Fuerza -and @('avisa', 'bloquea') -notcontains $Fuerza) {
  Salir-Error "Fuerza invalida: '$Fuerza' (debe ser 'avisa' o 'bloquea')"
}

$avisos = @()
$contratosPath = Join-Path $repoRoot 'tools/contratos.json'

# --- 1. UPSERT del contrato (el paso que SIEMPRE queda; jamas se revierte). ---
$comandosLista = @()
if ($Comandos -and "$Comandos".Trim()) {
  $comandosLista = @($Comandos -split ',' | ForEach-Object { $_.Trim() } | Where-Object { $_ })
}
$contrato = @{
  path    = "$Path"
  tipo    = if ($Tipo) { "$Tipo" } else { 'documento' }
  regimen = if ($Regimen) { "$Regimen" } else { 'libre' }
  fuerza  = "$Fuerza"
  comandos = @($comandosLista)
  estado  = 'parametrizado'
}
if ($Area) { $contrato['area'] = "$Area" }
try {
  $contratoFinal = Upsert-Contrato $contratosPath $contrato
} catch {
  Salir-Error "no pude escribir el contrato: $($_.Exception.Message)"
}

# --- 2. la REGLA en la ley (si -Area): la ruta a la fuente del area. Solo AVISOS. ---
if ($Area -and "$Area".Trim()) {
  try {
    $res = Agregar-A-Fuente $leyPath $Area $Path
    if (-not $res.areaExiste) {
      $avisos += "el area '$Area' no existe en tools/blast-radius.json: no agregue '$Path' a su fuente (crea el area en la ley si la quieres gobernar)"
    }
  } catch {
    $avisos += "no pude escribir la regla en la ley (area '$Area'): $($_.Exception.Message)"
  }
}

# --- 3. el @ en los comandos que lo leen (aditiva legal; el estatuto la acepta). ---
$arrobas = 0
$cmdFallidos = @()
foreach ($c in $comandosLista) {
  if ($c -match '[/\\]' -or $c -match '\.\.') { $avisos += "comando '$c' ignorado: el nombre no puede contener '/', '\' ni '..'"; continue }
  $cmdPath = Join-Path $repoRoot (".claude/commands/jidoka/$c.md")
  if (-not (Test-Path -LiteralPath $cmdPath)) { $cmdFallidos += "$c (ausente)"; continue }
  try {
    if (Insertar-Arroba $cmdPath $Path) { $arrobas++ }
  } catch {
    $cmdFallidos += $c
  }
}
if ($cmdFallidos.Count -gt 0) {
  $avisos += "no pude insertar el @ en: $($cmdFallidos -join ', ') (revisa el marcador $MARCADOR)"
}

# --- Salida ---------------------------------------------------------------
if ($Json) {
  $salida = @{
    ok       = $true
    contrato = $contratoFinal
    avisos   = @($avisos)
    arrobas  = $arrobas
  }
  Write-Output ($salida | ConvertTo-Json -Depth 8)
  exit 0
}

Write-Host ""
Write-Host "== Parametrizar: '$Path' ==" -ForegroundColor Cyan
Write-Host "  contrato escrito (estado 'parametrizado', regimen '$($contratoFinal.regimen)')." -ForegroundColor Green
Write-Host "  @ insertados: $arrobas"
if ($avisos.Count -gt 0) {
  Write-Host ""
  Write-Host "  AVISOS (el contrato quedo; esto NO se completo):" -ForegroundColor Yellow
  foreach ($a in $avisos) { Write-Host "    - $a" -ForegroundColor Yellow }
} else {
  Write-Host "  sin avisos: contrato + ley + @ al dia." -ForegroundColor Green
}
exit 0
