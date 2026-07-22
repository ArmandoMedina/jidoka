#Requires -Version 5
# probar-adrs.ps1 - MURO de conformidad del corpus de ADRs (docs/decisions).
# Hermano de estado-docs.ps1 (gobierno por SECCIONES) pero para el registro de
# decisiones, y con dientes: aqui exit 1 SIEMPRE que un ADR se desvie -- es MURO,
# no aviso (decision del cliente 2026-07-22: los ADRs "salen todos con el mismo
# formato" o no llegan a main). Valida, por cada docs/decisions/NNNN-*.md (excepto
# 0000-plantilla y README):
#   (a) ESTRUCTURA: tiene las 5 secciones canonicas del molde (0000-plantilla.md /
#       kit/.jidoka/templates/adr.md): Contexto, Decision, Por que, El camino que NO
#       se toma, Consecuencias. Match por prefijo con FOLD de acentos (fuente ASCII).
#   (b) COHERENCIA de estado: la CLASE de estado del header del archivo
#       (propuesta|aceptado|reemplazado|obsoleto) coincide con la del indice README.
#       Se compara la clase, no la prosa: "aceptado (delegado)" ~ "aceptado (revisable)"
#       coherentes; "aceptado" (archivo) vs "reemplazado" (indice) = el bug de 0044.
#   (c) HUERFANOS: cada archivo NNNN esta listado en el indice y viceversa.
# Incluye un self-test sintetico que DEBE cazar cada tipo de desvio (quien valida se
# valida -- disparo prueba-de-vida-del-gate). Se siembra (motor). ASCII a proposito, PS 5.1.
#
# Uso: ./tools/probar-adrs.ps1            (exit 0 = corpus conforme; exit 1 = un ADR se desvio)
#      ./tools/probar-adrs.ps1 -Reporte   (+ emite un tablero de conformidad al -Salida)
#      ./tools/probar-adrs.ps1 -Reporte -Salida docs/decisions/conformidad-adrs.html

param([switch]$Reporte, [string]$Salida)

$repoRoot     = Split-Path -Parent $PSScriptRoot
$decisionsDir = Join-Path $repoRoot 'docs/decisions'
$indexPath    = Join-Path $decisionsDir 'README.md'
$script:fallos = 0
$script:casos  = 0

# Las 5 secciones requeridas, en forma FOLDED-ASCII (asi la fuente queda sin acentos).
# El match es StartsWith sobre el encabezado normalizado: "el camino que no se toma
# (y por que tienta)" empieza con "el camino que no se toma" -> cuenta.
$script:REQUERIDAS = @('contexto', 'decision', 'por que', 'el camino que no se toma', 'consecuencias')
$script:CLASES     = @('propuesta', 'reemplazado', 'obsoleto', 'aceptado')

function Check($nombre, $cond, $detalle) {
  $script:casos++
  if ($cond) { Write-Host "  [PASA]  $nombre" -ForegroundColor Green }
  else { Write-Host "  [FALLA] $nombre ($detalle)" -ForegroundColor Red; $script:fallos++ }
}

# Fold a ASCII-minuscula, colapsa espacios, quita acentos via .NET FormD (sin
# literales acentuados en la fuente). Mismo metodo que estado-docs.ps1.
function Fold($s) {
  if ($null -eq $s) { return '' }
  $t = (($s -replace '\s+', ' ').Trim()).ToLowerInvariant()
  $formD = $t.Normalize([System.Text.NormalizationForm]::FormD)
  $sb = New-Object System.Text.StringBuilder
  foreach ($ch in $formD.ToCharArray()) {
    if ([System.Globalization.CharUnicodeInfo]::GetUnicodeCategory($ch) -ne [System.Globalization.UnicodeCategory]::NonSpacingMark) {
      [void]$sb.Append($ch)
    }
  }
  return $sb.ToString().Normalize([System.Text.NormalizationForm]::FormC)
}

# Encabezados '## ' (no '###'), folded, saltando bloques de codigo cercados.
function Get-Secciones($path) {
  $out = @()
  $enFence = $false
  foreach ($line in [System.IO.File]::ReadAllLines($path)) {
    if ($line -match '^\s*(```|~~~)') { $enFence = -not $enFence; continue }
    if ($enFence) { continue }
    if ($line -match '^##\s+\S') { $out += (Fold ($line -replace '^#{1,6}\s+', '')) }
  }
  return ,$out
}

# La CLASE de estado de un texto libre: el primer token conocido que aparezca.
# Devuelve $null si no reconoce ninguno.
function Get-EstadoClase($texto) {
  $f = Fold $texto
  # Palabra completa: '(^|[^a-z]) clase ([^a-z]|$)'. Sin ancla, 'inaceptado' matchearia
  # 'aceptado' (substring). El orden de CLASES resuelve 'reemplazado ... por' (primer token).
  foreach ($c in $script:CLASES) { if ($f -match ('(^|[^a-z])' + [regex]::Escape($c) + '([^a-z]|$)')) { return $c } }
  return $null
}

# Lee la clase de estado del header de un archivo ADR (la linea '- **Estado:** ...').
function Get-EstadoArchivo($path) {
  foreach ($line in [System.IO.File]::ReadAllLines($path)) {
    if ($line -match '\*\*Estado:\*\*\s*(.+)$') { return (Get-EstadoClase $Matches[1]) }
  }
  return $null
}

# Parsea el indice README: por fila con [NNNN](archivo.md) devuelve num, archivo y
# la clase de estado (ultima celda). Robusto a '|' dentro del titulo: se parte por
# '|' y se toma la 1a celda con el link y la penultima (el estado).
function Get-Indice($path) {
  $filas = @{}
  foreach ($line in [System.IO.File]::ReadAllLines($path)) {
    if ($line -notmatch '^\s*\|') { continue }
    # Celdas sin los vacios de borde (pipe inicial/final): asi el estado es la ULTIMA
    # celda real, con o sin pipe de cierre (GitHub acepta filas sin pipe final).
    $celdas = [System.Collections.ArrayList]@($line -split '\|')
    while ($celdas.Count -gt 0 -and "$($celdas[0])".Trim() -eq '') { $celdas.RemoveAt(0) }
    while ($celdas.Count -gt 0 -and "$($celdas[$celdas.Count - 1])".Trim() -eq '') { $celdas.RemoveAt($celdas.Count - 1) }
    if ($celdas.Count -lt 2) { continue }
    $numFound = $null; $archFound = $null
    foreach ($cel in $celdas) {
      if ($cel -match '\[(\d{4})\]\(([^)]+\.md)\)') { $numFound = $Matches[1]; $archFound = $Matches[2]; break }
    }
    if (-not $numFound) { continue }
    $estadoCell = "$($celdas[$celdas.Count - 1])"
    $filas[$numFound] = @{ archivo = $archFound; estadoClase = (Get-EstadoClase $estadoCell); estadoTexto = $estadoCell.Trim() }
  }
  return $filas
}

# El corazon: escanea un directorio de decisiones contra su indice y devuelve
# @{ problemas=@(); adrs=@(@{num;archivo;conforme;faltan;estadoArch;estadoIdx}) }.
function Test-Adrs($dir, $index) {
  $problemas = @()
  $adrs = @()
  # Falla-suave: un repo sin docs/decisions o sin su indice NO se bloquea (un hijo recien
  # sembrado, o brownfield sin ADRs). 'no aplica', no excepcion -- como el resto del motor.
  if (-not (Test-Path -LiteralPath $dir) -or -not (Test-Path -LiteralPath $index)) {
    return @{ problemas = @(); adrs = @(); noAplica = $true }
  }
  $indice = Get-Indice $index

  $archivos = Get-ChildItem -LiteralPath $dir -Filter '*.md' -File |
    Where-Object { $_.Name -match '^(\d{4})-' -and $_.Name -ne '0000-plantilla.md' } |
    Sort-Object Name
  $numsEnDisco = @{}

  foreach ($f in $archivos) {
    $null = ($f.Name -match '^(\d{4})-'); $num = $Matches[1]
    $numsEnDisco[$num] = $true
    $secciones = Get-Secciones $f.FullName
    $faltan = @()
    foreach ($req in $script:REQUERIDAS) {
      $hit = $false
      foreach ($sec in $secciones) { if ($sec -eq $req -or $sec -match ('^' + [regex]::Escape($req) + '[^a-z]')) { $hit = $true; break } }
      if (-not $hit) { $faltan += $req }
    }
    $estadoArch = Get-EstadoArchivo $f.FullName
    $estadoIdx  = $null
    if ($indice.ContainsKey($num)) { $estadoIdx = $indice[$num].estadoClase } else { $problemas += "${num}: el archivo existe pero NO esta listado en el indice" }
    if (-not $estadoArch) { $problemas += "${num}: no se reconoce la clase de estado en el header del archivo" }
    if ($faltan.Count -gt 0) { $problemas += ("${num}: falta(n) seccion(es): {0}" -f ($faltan -join ', ')) }
    if ($estadoArch -and $estadoIdx -and ($estadoArch -ne $estadoIdx)) {
      $problemas += "${num}: estado incoherente -- archivo '$estadoArch' vs indice '$estadoIdx'"
    }
    $adrs += @{ num = $num; archivo = $f.Name; conforme = ($faltan.Count -eq 0); faltan = $faltan; estadoArch = $estadoArch; estadoIdx = $estadoIdx }
  }

  foreach ($num in $indice.Keys) {
    if ($num -eq '0000') { continue }
    if (-not $numsEnDisco.ContainsKey($num)) { $problemas += "${num}: listado en el indice pero el archivo no existe en disco" }
  }

  return @{ problemas = $problemas; adrs = ($adrs | Sort-Object { $_.num }) }
}

# --- Emite el tablero de conformidad (R4): HTML autocontenido, sin BOM. ---
function Write-Reporte($resultado, $salidaPath) {
  $rows = ''
  $conf = 0
  foreach ($a in $resultado.adrs) {
    $estadoOk = (-not $a.estadoArch) -or (-not $a.estadoIdx) -or ($a.estadoArch -eq $a.estadoIdx)
    $ok = $a.conforme -and $estadoOk
    if ($ok) { $conf++ }
    $clase = if ($ok) { 'ok' } else { 'mal' }
    $etq = if ($ok) { 'conforme' } else { 'DESVIADO' }
    $nota = ''
    if (-not $a.conforme) { $nota += ('falta: ' + ($a.faltan -join ', ')) }
    if (-not $estadoOk) { if ($nota) { $nota += ' | ' }; $nota += ("estado: arch '{0}' vs idx '{1}'" -f $a.estadoArch, $a.estadoIdx) }
    $rows += ("<tr class='$clase'><td>{0}</td><td>{1}</td><td>{2}</td><td>{3}</td></tr>`n" -f $a.num, $a.archivo, $etq, $nota)
  }
  $total = $resultado.adrs.Count
  $desv  = $resultado.problemas.Count
  $html = @"
<!doctype html><html lang='es'><head><meta charset='utf-8'>
<title>Conformidad de ADRs - Jidoka</title>
<style>
 body{font-family:system-ui,Segoe UI,sans-serif;margin:2rem;color:#1a1a1a}
 h1{font-size:1.3rem} .resumen{margin:1rem 0;font-size:1.1rem}
 table{border-collapse:collapse;width:100%} th,td{border:1px solid #ddd;padding:.4rem .6rem;text-align:left;font-size:.9rem}
 th{background:#f4f4f4} tr.ok td:nth-child(3){color:#0a7d2c;font-weight:600}
 tr.mal td{background:#fff3f3} tr.mal td:nth-child(3){color:#c0292b;font-weight:700}
</style></head><body>
<h1>Conformidad del corpus de ADRs</h1>
<p class='resumen'>$conf de $total conformes &middot; $desv problema(s) de gate.</p>
<table><thead><tr><th>#</th><th>Archivo</th><th>Estado</th><th>Nota</th></tr></thead>
<tbody>
$rows</tbody></table>
<p style='margin-top:1.5rem;color:#666;font-size:.8rem'>Generado por tools/probar-adrs.ps1 -Reporte. El gate mide forma + coherencia de estado, no el contenido de la decision.</p>
</body></html>
"@
  $enc = New-Object System.Text.UTF8Encoding($false)
  [System.IO.File]::WriteAllText($salidaPath, $html, $enc)
  Write-Host "  [REPORTE] tablero escrito en $salidaPath" -ForegroundColor Cyan
}

Write-Host "== Conformidad del corpus de ADRs (docs/decisions) =="

# --- El corpus REAL: 0 problemas o el muro cae. ---
$real = Test-Adrs $decisionsDir $indexPath
if ($real.noAplica) {
  Write-Host "  [N/A]   sin docs/decisions o su indice: no aplica (un repo sin ADRs no se bloquea)." -ForegroundColor DarkGray
}
else {
  Check ("corpus real: los {0} ADRs conforman (secciones + estado coherente + sin huerfanos)" -f $real.adrs.Count) ($real.problemas.Count -eq 0) ($real.problemas -join ' | ')
  if ($real.problemas.Count -gt 0) {
    foreach ($p in $real.problemas) { Write-Host "     - $p" -ForegroundColor Yellow }
  }
}

# --- El template 0000-plantilla.md es el molde del que se copia: cada seccion
#     REQUERIDA debe existir en el. Asi, tocar la plantilla (quitar/renombrar una
#     seccion canonica) TRUENA aqui -- el template no gobierna solo, pero tampoco
#     puede desviarse en silencio del guardian. La regla vive en $REQUERIDAS; este
#     check la ata al molde (como probar-docs Parte B ata el ledger al template).
$plantillaPath = Join-Path $decisionsDir '0000-plantilla.md'
if (Test-Path -LiteralPath $plantillaPath) {
  $secPlantilla = Get-Secciones $plantillaPath
  foreach ($req in $script:REQUERIDAS) {
    $hit = $false
    foreach ($s in $secPlantilla) { if ($s.StartsWith($req)) { $hit = $true; break } }
    Check ("plantilla 0000: la seccion requerida '$req' esta en el molde") $hit "la plantilla y `$REQUERIDAS divergieron: el molde no tiene '$req'"
  }
}
else {
  # Sin plantilla (hijo recien sembrado, brownfield sin corpus de ADRs): el guard
  # del molde no aplica -- solo tiene sentido donde el molde existe. 'no aplica', no
  # falla, como el corpus real de arriba. Un repo sin la plantilla NO se bloquea.
  Write-Host "  [N/A]   sin docs/decisions/0000-plantilla.md: el guard del molde no aplica (no hay molde que atar)." -ForegroundColor DarkGray
}

# --- Self-test sintetico: DEBE cazar cada tipo de desvio y NO marcar el sano. ---
$tmp = Join-Path $env:TEMP ("jidoka-adrs-prueba-" + [guid]::NewGuid().ToString('N').Substring(0, 8))
New-Item -ItemType Directory -Path $tmp -Force | Out-Null
try {
  $bueno = @"
# ADR 0001 - decision sana

- **Estado:** aceptado
- **Fecha:** 2026-01-01

## Contexto
x
## Decision
x
## Por que
x
## El camino que NO se toma (y por que tienta)
x
## Consecuencias
x
"@
  $sinSeccion = @"
# ADR 0002 - le falta Por que

- **Estado:** aceptado
- **Fecha:** 2026-01-01

## Contexto
x
## Decision
x
## Razones
x
## El camino que NO se toma
x
## Consecuencias
x
"@
  $estadoMalo = @"
# ADR 0003 - estado incoherente

- **Estado:** aceptado
- **Fecha:** 2026-01-01

## Contexto
x
## Decision
x
## Por que
x
## El camino que NO se toma
x
## Consecuencias
x
"@
  $huerfano = @"
# ADR 0004 - existe pero no en el indice

- **Estado:** aceptado
- **Fecha:** 2026-01-01

## Contexto
x
## Decision
x
## Por que
x
## El camino que NO se toma
x
## Consecuencias
x
"@
  $encA = New-Object System.Text.UTF8Encoding($false)
  [System.IO.File]::WriteAllText((Join-Path $tmp '0001-bueno.md'), $bueno, $encA)
  [System.IO.File]::WriteAllText((Join-Path $tmp '0002-sin-seccion.md'), $sinSeccion, $encA)
  [System.IO.File]::WriteAllText((Join-Path $tmp '0003-estado-malo.md'), $estadoMalo, $encA)
  [System.IO.File]::WriteAllText((Join-Path $tmp '0004-huerfano.md'), $huerfano, $encA)
  # indice: 0001 aceptado, 0002 aceptado, 0003 REEMPLAZADO (choca con el archivo),
  # 0004 ausente (huerfano de disco), 0005 listado sin archivo (huerfano de indice).
  $idx = @"
# Decisiones

| # | Titulo | Estado |
|---|---|---|
| [0000](0000-plantilla.md) | Plantilla | plantilla |
| [0001](0001-bueno.md) | Bueno | aceptado |
| [0002](0002-sin-seccion.md) | Sin seccion | aceptado |
| [0003](0003-estado-malo.md) | Estado malo | reemplazado por [0009] |
| [0005](0005-fantasma.md) | Fantasma sin archivo | aceptado |
"@
  [System.IO.File]::WriteAllText((Join-Path $tmp 'README.md'), $idx, $encA)

  $s = Test-Adrs $tmp (Join-Path $tmp 'README.md')
  $p = $s.problemas -join ' | '
  Check 'sintetico: caza la SECCION faltante (0002 sin Por que)'      ($p -match '0002.*por que') $p
  Check 'sintetico: caza el ESTADO incoherente (0003 aceptado vs reemplazado)' ($p -match "0003.*incoherente") $p
  Check 'sintetico: caza el HUERFANO de disco (0004 no en indice)'    ($p -match '0004.*NO esta listado') $p
  Check 'sintetico: caza el HUERFANO de indice (0005 sin archivo)'    ($p -match '0005.*no existe en disco') $p
  $sano = @($s.adrs | Where-Object { $_.num -eq '0001' })[0]
  Check 'sintetico: NO marca el ADR sano (0001 conforme)'             ($sano.conforme -and -not ($p -match '0001')) $p

  # --- Curas del review 2026-07-22: plural que no cuela + estado no-anclado + falla-suave. ---
  $plural = @"
# ADR 0006 - plural + estado espurio

- **Estado:** inaceptado
- **Fecha:** 2026-01-01

## Contexto
x
## Decisiones
x
## Por que
x
## El camino que NO se toma
x
## Consecuencias
x
"@
  [System.IO.File]::WriteAllText((Join-Path $tmp '0006-plural.md'), $plural, $encA)
  $s2 = Test-Adrs $tmp (Join-Path $tmp 'README.md')
  $p2 = $s2.problemas -join ' | '
  Check "sintetico: '## Decisiones' (plural) NO satisface 'decision'"          ($p2 -match '0006.*decision') $p2
  Check "sintetico: estado 'inaceptado' NO se lee como 'aceptado'"             ($p2 -match '0006.*no se reconoce') $p2
  $sNA = Test-Adrs (Join-Path $tmp 'no-existe') (Join-Path $tmp 'no-existe/README.md')
  Check 'sintetico: dir/indice ausente -> noAplica (no truena, no bloquea)'    ($sNA.noAplica -eq $true) "noAplica=$($sNA.noAplica)"
}
finally { Remove-Item $tmp -Recurse -Force -ErrorAction SilentlyContinue }

# --- Reporte opcional (R4). ---
if ($Reporte) {
  if (-not $Salida) { $Salida = Join-Path $decisionsDir 'conformidad-adrs.html' }
  Write-Reporte $real $Salida
}

Write-Host ""
if ($script:fallos -gt 0) {
  Write-Host "== $($script:fallos) de $($script:casos) caso(s) fallidos. El corpus de ADRs tiene un desvio de formato. ==" -ForegroundColor Red
  exit 1
}
Write-Host "== Corpus de ADRs conforme: los $($script:casos) casos se comportan como se espera. ==" -ForegroundColor Green
exit 0
