#Requires -Version 5
# bandeja.ps1 - La BANDEJA: "pendiente de parametrizar". Una vista de SOLO LECTURA
# que reune en UNA cola los archivos del repo que ninguna regla gobierna de verdad,
# para que el verde deje de mentir. NO gatea nada (exit 0 siempre; es cola, no muro),
# nadie la llama: es un reporte, como estado-gobierno.ps1 o estado-docs.ps1 -- por eso
# NO viola ADR 0002. La UI la vaciara (R4); aqui solo se muestra.
#
# La cola v1 tiene tres motivos (calca el matcher de verificar.ps1/estado-gobierno.ps1):
#   huerfano   - ninguna capa lo cubre (ni area del blast-radius, ni ledger, ni arbol).
#   existe     - "cubierto solo por existir": vive en un arbol auditado pero NINGUNA
#                regla lo gobierna (el hueco de docs/: p.ej. docs/analisis/*). OJO:
#                product/ NO cae aqui -- lo gobierna el grafo de auditar.ps1 (frontmatter,
#                wikilinks, Gherkin), asi que cuenta como parametrizado.
#   desviado   - doc capa-2 (docs-gobernados.json) que perdio una seccion requerida
#                (misma deteccion que estado-docs.ps1: garantia nula).
#
# Resta lo firmado en tools/contratos.json (INSTANCIA, no-clobber, ADR 0046): un
# elemento con contrato 'parametrizado' sale de la cola; uno 'aceptado' sale y se lista
# aparte con su firma (badge). Si contratos.json no existe (el caso comun hoy), la cola
# sale completa. La bandeja lo LEE; la extension lo escribe (R4/R6).
#
#   -Repo <ruta>    repo a inspeccionar (default: el padre de tools/, o sea este repo)
#   -Salida <ruta>  escribe un .html de tabla simple (default: solo consola)
#
# Falla CERRADO (exit 2) si no puede enumerar los archivos (no es git): sin la foto no
# se pinta una cola vacia a ciegas. Se siembra en cada hijo (motor). ASCII a proposito,
# PS 5.1. Sin $ErrorActionPreference global.
#
# GEMELAS (sincronizar a mano): Test-Pattern es copia byte-fiel de verificar.ps1/
# estado-gobierno.ps1; Normaliza + Get-Secciones son copia byte-fiel de estado-docs.ps1.
# Son copias A PROPOSITO (script aparte, no un modo de la linterna). Si aquellas cambian su
# REGLA (el glob, el fold de acentos, la deteccion de secciones), actualiza estas en paralelo
# o la promesa "matcher byte-fiel" (andon/README.md) se rompe: la bandeja mostraria distinto
# de lo que el CI bloquea.

param([string]$Repo = '', [string]$Salida = '', [switch]$Json)

$repoRoot = if ($Repo) { $Repo } else { Split-Path -Parent $PSScriptRoot }
$leyPath = Join-Path $repoRoot 'tools/blast-radius.json'
$ledgerDocsPath = Join-Path $repoRoot 'tools/docs-gobernados.json'
$contratosPath = Join-Path $repoRoot 'tools/contratos.json'

if (-not (Test-Path -LiteralPath $leyPath)) {
  Write-Host "[ERROR] no encuentro la ley: $leyPath" -ForegroundColor Red
  Write-Host "        la bandeja necesita tools/blast-radius.json para saber que regla gobierna que."
  exit 1
}
try { $areas = @((Get-Content -LiteralPath $leyPath -Raw | ConvertFrom-Json)) }
catch {
  Write-Host "[ERROR] la ley no es JSON valido: $leyPath" -ForegroundColor Red
  Write-Host "        $($_.Exception.Message)"
  exit 1
}

# --- Matcher de globs: EXACTAMENTE el de verificar.ps1/estado-gobierno.ps1 (un patron
#     sin '/' solo casa la raiz). Si no fuera identico, la bandeja mentiria. ---
function Test-Pattern($path, $pattern) {
  if ($pattern -notlike '*/*' -and $path -like '*/*') { return $false }
  return ($path -like $pattern)
}
function Test-NoVacio($v) { return ($v -and @($v).Count -gt 0) }

# Normaliza + Get-Secciones: calca estado-docs.ps1 (fold de acentos, salta code-fences)
# para detectar el doc capa-2 DESVIADO con la MISMA regla que el detector oficial.
function Normaliza($s) {
  $t = ($s -replace '^#{1,6}\s+', '').Trim()
  $t = ($t -replace '\s+', ' ').ToLowerInvariant()
  $formD = $t.Normalize([System.Text.NormalizationForm]::FormD)
  $sb = New-Object System.Text.StringBuilder
  foreach ($ch in $formD.ToCharArray()) {
    if ([System.Globalization.CharUnicodeInfo]::GetUnicodeCategory($ch) -ne [System.Globalization.UnicodeCategory]::NonSpacingMark) {
      [void]$sb.Append($ch)
    }
  }
  return $sb.ToString().Normalize([System.Text.NormalizationForm]::FormC)
}
function Get-Secciones($path) {
  $out = @()
  $enFence = $false
  foreach ($line in [System.IO.File]::ReadAllLines($path)) {
    if ($line -match '^\s*(```|~~~)') { $enFence = -not $enFence; continue }
    if ($enFence) { continue }
    if ($line -match '^##\s+\S') { $out += (Normaliza $line) }
  }
  return , $out
}

# --- Ledger de docs capa-2/3 (docs-gobernados.json): calcula DESVIADOS y CONFORMES. ---
$capa2Paths = @()
$capa3 = @()
$desviados = @()
$ledgerDocs = $null
if (Test-Path -LiteralPath $ledgerDocsPath) {
  try { $ledgerDocs = Get-Content -LiteralPath $ledgerDocsPath -Raw | ConvertFrom-Json } catch { $ledgerDocs = $null }
}
if ($ledgerDocs) {
  if ($ledgerDocs.capa3) { $capa3 = @($ledgerDocs.capa3) }
  foreach ($e in @($ledgerDocs.capa2)) {
    $capa2Paths += $e.doc
    $docAbs = Join-Path $repoRoot $e.doc
    if (-not (Test-Path -LiteralPath $docAbs)) { continue }
    $secciones = Get-Secciones $docAbs
    $falta = $false
    foreach ($req in $e.requeridas) {
      $reqN = Normaliza $req
      $hit = $false
      foreach ($sec in $secciones) { if ($sec.StartsWith($reqN)) { $hit = $true; break } }
      if (-not $hit) { $falta = $true; break }
    }
    if ($falta) { $desviados += $e.doc }
  }
}

# --- Contratos de instancia (contratos.json): lo firmado sale de la cola. ---
$firmados = @{}     # path -> estado ('parametrizado'|'aceptado')
$firmaDe = @{}      # path -> texto de firma (para el badge de 'aceptado')
if (Test-Path -LiteralPath $contratosPath) {
  try {
    $ctr = Get-Content -LiteralPath $contratosPath -Raw | ConvertFrom-Json
    foreach ($c in @($ctr.contratos)) {
      if (-not $c.path) { continue }
      $est = if ($c.estado) { "$($c.estado)" } else { 'parametrizado' }
      $firmados[$c.path] = $est
      if ($c.firma -and $c.firma.quien) { $firmaDe[$c.path] = "$($c.firma.quien)" }
    }
  } catch { }
}

# Arboles que auditar.ps1 INDEXA, pero solo AUDITA product/ (frontmatter/wikilinks/Gherkin).
# Vivir en uno de los otros arboles NO es una regla que gobierne: es "cubierto solo por existir".
$arbolesAuditados = @('product/', 'docs/', 'kanban/', 'doctrina/', 'kit/.jidoka/templates/')

function Test-EnLaLey($path) {
  foreach ($a in $areas) {
    if ($a.excluye) { foreach ($e in $a.excluye) { if (Test-Pattern $path $e) { return $true } } }
  }
  return $false
}

# Clasifica un archivo: en cola (con motivo) o parametrizado (con detalle de que lo cubre).
function Clasifica($path) {
  # 1. una AREA del blast-radius lo gobierna (fuente, no excluido por esa area) -> parametrizado.
  foreach ($a in $areas) {
    if (-not (Test-NoVacio $a.fuente)) { continue }
    $inFuente = $false
    foreach ($f in $a.fuente) { if (Test-Pattern $path $f) { $inFuente = $true; break } }
    if (-not $inFuente) { continue }
    $excl = $false
    if ($a.excluye) { foreach ($e in $a.excluye) { if (Test-Pattern $path $e) { $excl = $true; break } } }
    if (-not $excl) { return @{ cola = $false; motivo = 'area'; detalle = "area:$($a.nombre)" } }
  }
  # 2. ledger capa-2: DESVIADO -> cola; CONFORME -> parametrizado.
  if ($capa2Paths -contains $path) {
    if ($desviados -contains $path) { return @{ cola = $true; motivo = 'desviado'; detalle = 'doc capa-2 sin seccion requerida' } }
    return @{ cola = $false; motivo = 'ledger'; detalle = 'ledger:capa-2 (conforme)' }
  }
  if ($capa3 -contains $path) { return @{ cola = $false; motivo = 'ledger'; detalle = 'ledger:capa-3 (libre)' } }
  # 3. product/ lo gobierna el grafo de auditar.ps1 -> parametrizado (no es "solo existir").
  if ($path -like 'product/*') { return @{ cola = $false; motivo = 'grafo'; detalle = 'auditar:product' } }
  # 4. infra convencional (dot-dirs de config, qa_runs de evidencia) -> parametrizado.
  if ($path -like '.*/*' -or $path -like 'qa_runs/*' -or $path -like '*/qa_runs/*') { return @{ cola = $false; motivo = 'infra'; detalle = 'infra' } }
  # 5. la ley lo declara EXENTO por algun excluye (un canonico carveado a proposito, p.ej. el
  #    indice de ADRs docs/decisions/README.md, que ademas es doc_bloquea) -> parametrizado:
  #    la ley lo conoce y lo nombra. Va ANTES del bucket "solo existe" (un carve-out es una
  #    regla; vivir en un arbol auditado, no).
  if (Test-EnLaLey $path) { return @{ cola = $false; motivo = 'exento'; detalle = 'ley:exento' } }
  # 6. otro arbol auditado sin regla (docs/analisis, docs/sprints...): cubierto solo por existir.
  foreach ($arbol in $arbolesAuditados) { if ($path -like "$arbol*") { return @{ cola = $true; motivo = 'existe'; detalle = "arbol auditado sin regla ($arbol)" } } }
  # 7. huerfano puro: la ley no lo conoce de ninguna forma.
  return @{ cola = $true; motivo = 'huerfano'; detalle = 'ninguna capa lo cubre' }
}

# --- Enumerar archivos (trackeados + no-trackeados no-ignorados): la foto real incluye
#     lo recien soltado por el agente. -c core.quotepath=false: sin esto git escapa las
#     rutas no-ASCII y casarian mal contra los globs. Falla CERRADO si no es git. ---
Push-Location $repoRoot
$tracked = @(git -c core.quotepath=false ls-files 2>$null)
$okGit = ($LASTEXITCODE -eq 0)
$untracked = @(git -c core.quotepath=false ls-files --others --exclude-standard 2>$null)
Pop-Location
if (-not $okGit) {
  Write-Host "[ERROR] no pude enumerar los archivos de $repoRoot (git ls-files fallo -- es un repo git?)." -ForegroundColor Red
  Write-Host "        la bandeja FALLA CERRADO: sin la foto de los archivos no se pinta una cola vacia a ciegas."
  exit 2
}
$files = @(@($tracked + $untracked) | Where-Object { $_ } | Sort-Object -Unique)

# --- Construir la cola ---------------------------------------------------------
$cola = @()          # items pendientes: @{ path; motivo; detalle }
$aceptados = @()     # firmados 'aceptado': @{ path; firma }
foreach ($f in $files) {
  $c = Clasifica $f
  if (-not $c.cola) { continue }
  # restar lo firmado en contratos.json
  if ($firmados.ContainsKey($f)) {
    if ($firmados[$f] -eq 'aceptado') {
      $fma = if ($firmaDe.ContainsKey($f)) { $firmaDe[$f] } else { 'firmado' }
      $aceptados += @{ path = $f; firma = $fma; motivo = $c.motivo }
    }
    continue   # parametrizado o aceptado: fuera de la cola pendiente
  }
  $cola += @{ path = $f; motivo = $c.motivo; detalle = $c.detalle }
}

# --- Salida JSON (-Json): aditiva. Emite SOLO {"cola":[...],"aceptados":[...]} a stdout
#     y sale con el mismo exit 0 de siempre. Sin -Json, NADA de esto corre (byte-identico).
#     TRAMPA PS 5.1: un array de 1 elemento se colapsa a objeto en ConvertTo-Json; el @()
#     al construir el hashtable raiz fuerza SIEMPRE array (verificado en probar-bandeja).
#     Sin BOM: Write-Output del string (no Out-File, que mete BOM en PS 5.1).
if ($Json) {
  $raizJson = @{ cola = @($cola); aceptados = @($aceptados) }
  Write-Output ($raizJson | ConvertTo-Json -Depth 6)
  exit 0
}

# --- Salida consola ------------------------------------------------------------
$byMotivo = @{ huerfano = @(); existe = @(); desviado = @() }
foreach ($it in $cola) { $byMotivo[$it.motivo] += $it }

Write-Host ""
Write-Host "== Bandeja: pendiente de parametrizar ==" -ForegroundColor Cyan
$etqMotivo = @{
  huerfano = 'HUERFANO   (ninguna regla lo cubre)'
  existe   = 'SOLO EXISTE (arbol auditado sin regla)'
  desviado = 'DESVIADO   (doc capa-2 sin seccion requerida)'
}
foreach ($m in @('huerfano', 'desviado', 'existe')) {
  $items = @($byMotivo[$m])
  if ($items.Count -eq 0) { continue }
  Write-Host ""
  Write-Host ("  [{0}]  {1}" -f $items.Count, $etqMotivo[$m]) -ForegroundColor Yellow
  foreach ($it in ($items | Sort-Object { $_.path })) {
    Write-Host ("    - {0}" -f $it.path)
  }
}
if ($aceptados.Count -gt 0) {
  Write-Host ""
  Write-Host ("  [{0}]  ACEPTADOS con firma (fuera de la cola, con badge)" -f $aceptados.Count) -ForegroundColor DarkGray
  foreach ($it in ($aceptados | Sort-Object { $_.path })) {
    Write-Host ("    - {0}  (firma: {1})" -f $it.path, $it.firma) -ForegroundColor DarkGray
  }
}
Write-Host ""
if ($cola.Count -eq 0) {
  Write-Host "  Cola vacia: nada pendiente de parametrizar (el verde no miente)." -ForegroundColor Green
} else {
  Write-Host ("  Total pendiente: {0} elemento(s). Parametrizalos desde la extension (R4) o acepta con firma (R6)." -f $cola.Count) -ForegroundColor Cyan
}
if (-not (Test-Path -LiteralPath $contratosPath)) {
  Write-Host "  (no hay tools/contratos.json todavia: la cola sale completa. Se crea al parametrizar desde la UI.)" -ForegroundColor DarkGray
}

# --- Salida HTML opcional (-Salida): tabla simple, autocontenida, UTF-8 sin BOM. ---
if ($Salida) {
  $rows = ''
  $motivoLabel = @{ huerfano = 'huerfano'; existe = 'solo existe'; desviado = 'desviado' }
  foreach ($m in @('huerfano', 'desviado', 'existe')) {
    foreach ($it in (@($byMotivo[$m]) | Sort-Object { $_.path })) {
      $p = $it.path.Replace('&', '&amp;').Replace('<', '&lt;').Replace('>', '&gt;')
      $d = "$($it.detalle)".Replace('&', '&amp;').Replace('<', '&lt;').Replace('>', '&gt;')
      $rows += "<tr class=""m-$m""><td>$p</td><td class=""mot"">$($motivoLabel[$m])</td><td class=""det"">$d</td></tr>`n"
    }
  }
  foreach ($it in (@($aceptados) | Sort-Object { $_.path })) {
    $p = $it.path.Replace('&', '&amp;').Replace('<', '&lt;').Replace('>', '&gt;')
    $fma = "$($it.firma)".Replace('&', '&amp;').Replace('<', '&lt;').Replace('>', '&gt;')
    $rows += "<tr class=""m-aceptado""><td>$p</td><td class=""mot"">aceptado</td><td class=""det"">firma: $fma</td></tr>`n"
  }
  if (-not $rows) { $rows = "<tr><td colspan=""3"" class=""vacia"">Cola vacia: nada pendiente de parametrizar.</td></tr>" }
  $tmpl = @'
<!doctype html>
<html lang="es"><head><meta charset="utf-8">
<title>Bandeja - pendiente de parametrizar</title>
<style>
  body{font-family:system-ui,Segoe UI,Arial,sans-serif;margin:2rem;background:#0f1115;color:#e6e6e6}
  h1{font-size:1.3rem}
  .sub{color:#9aa4b2;margin-bottom:1.2rem}
  table{border-collapse:collapse;width:100%;font-size:.9rem}
  th,td{text-align:left;padding:.45rem .6rem;border-bottom:1px solid #262a33}
  th{color:#9aa4b2;font-weight:600}
  td.mot{white-space:nowrap;font-weight:600}
  td.det{color:#9aa4b2}
  tr.m-huerfano td.mot{color:#ff6b6b}
  tr.m-existe td.mot{color:#f0a35e}
  tr.m-desviado td.mot{color:#e6c84f}
  tr.m-aceptado td{color:#6b7280}
  td.vacia{color:#5ec26a;text-align:center;padding:1.5rem}
</style></head><body>
<h1>Bandeja &mdash; pendiente de parametrizar</h1>
<div class="sub">Lo que ninguna regla gobierna de verdad. La UI lo vaciara (parametrizar o aceptar con firma). Vista de solo lectura; no es un muro.</div>
<table>
<tr><th>archivo</th><th>motivo</th><th>detalle</th></tr>
<!--__ROWS__-->
</table>
</body></html>
'@
  $html = $tmpl.Replace('<!--__ROWS__-->', $rows)
  $dirSalida = Split-Path -Parent $Salida
  if ($dirSalida -and -not (Test-Path -LiteralPath $dirSalida)) { New-Item -ItemType Directory -Path $dirSalida -Force | Out-Null }
  [System.IO.File]::WriteAllText($Salida, $html, (New-Object System.Text.UTF8Encoding($false)))
  Write-Host ("  HTML escrito: {0}" -f $Salida) -ForegroundColor DarkGray
}

exit 0
