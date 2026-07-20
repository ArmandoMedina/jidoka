#Requires -Version 5
# estado-gobierno.ps1 - La LINTERNA del gobierno: una vista de SOLO LECTURA que
# renderiza el grafo de la maquina determinista de un repo (areas del blast-radius,
# gates vivo/dormido, documentos gobernados, y HUERFANOS en rojo) a un .html
# autocontenido que se abre con doble clic. NO gatea nada, nadie la llama: es un
# reporte, como estado-docs.ps1 o los SVG del atlas -- por eso NO viola ADR 0002
# (prohibido API/MCP como capa de GOBIERNO; una vista estatica no lo es). Nace
# VISTA, no muro (regla 2-3).
#
# La regla de oro: la linterna NO inventa verdad. Deriva el grafo de las mismas
# fuentes que ya gatean -- tools/blast-radius.json (la ley) y
# tools/docs-gobernados.json (el ledger capa-2). Un HUERFANO es un archivo que
# NINGUNA capa cubre: ni una area del blast-radius (fuente menos excluye, con el
# mismo matcher que verificar.ps1), ni el ledger de docs, ni un arbol auditado.
# Ese es el rojo que el cliente quiere ver (el "candy.md" de entisoft-rescate).
#
#   -Repo <ruta>    repo a inspeccionar (default: el padre de tools/, o sea este repo)
#   -Salida <ruta>  a donde escribir el .html (default: <repo>/.jidoka/gobierno.html)
#
# Nota vivo/dormido: la regla canonica vive en rutear.ps1 (fuente unica). Aqui se
# REPLICA la misma condicion sobre la ley (comentada abajo) para no depender de
# capturar la salida Write-Host de rutear; R2 consolida ambos en rutear.ps1 -Json.
# Se siembra en cada hijo (motor). Archivo ASCII a proposito, PS 5.1. Sin
# $ErrorActionPreference global.

param([string]$Repo = '', [string]$Salida = '')

$repoRoot = if ($Repo) { $Repo } else { Split-Path -Parent $PSScriptRoot }
$leyPath = Join-Path $repoRoot 'tools/blast-radius.json'
$ledgerPath = Join-Path $repoRoot 'tools/docs-gobernados.json'

if (-not (Test-Path -LiteralPath $leyPath)) {
  Write-Host "[ERROR] no encuentro la ley: $leyPath" -ForegroundColor Red
  Write-Host "        la linterna necesita tools/blast-radius.json para saber que gobierna que."
  exit 1
}
try { $areas = @((Get-Content -LiteralPath $leyPath -Raw | ConvertFrom-Json)) }
catch {
  Write-Host "[ERROR] la ley no es JSON valido: $leyPath" -ForegroundColor Red
  Write-Host "        $($_.Exception.Message)"
  exit 1
}

$ledger = $null
if (Test-Path -LiteralPath $ledgerPath) {
  try { $ledger = Get-Content -LiteralPath $ledgerPath -Raw | ConvertFrom-Json } catch { $ledger = $null }
}

# --- Matcher de globs: EXACTAMENTE el de verificar.ps1 (un patron sin '/' solo casa
#     la raiz). Si no fuera identico, la linterna mentiria sobre lo que el gate ve. ---
function Test-Pattern($path, $pattern) {
  if ($pattern -notlike '*/*' -and $path -like '*/*') { return $false }
  return ($path -like $pattern)
}
function Test-NoVacio($v) { return ($v -and @($v).Count -gt 0) }

# Gates que ACTUAN sobre un area (misma logica que rutear.ps1 Get-GatesDeArea).
function Get-GatesDeArea($a) {
  $g = @()
  if ($a.rol -eq 'revisor-visual') { $g += 'gemba-stop' }
  if ($a.rol -eq 'validador')      { $g += 'validador-stop' }
  if ($a.revisa -eq $true)         { $g += 'review-stop' }
  if ((Test-NoVacio $a.doc_bloquea) -or (Test-NoVacio $a.doc_avisa) -or (Test-NoVacio $a.product_avisa)) { $g += 'andon-stop' }
  return $g
}

# Estado GLOBAL de cada Stop hook segun la ley (misma condicion que rutear.ps1:51-54).
$revisaVivo = @($areas | Where-Object { $_.revisa -eq $true }).Count -gt 0
$gembaVivo  = @($areas | Where-Object { $_.rol -eq 'revisor-visual' }).Count -gt 0
$validaVivo = @($areas | Where-Object { $_.rol -eq 'validador' }).Count -gt 0
$andonVivo  = @($areas | Where-Object { (Test-NoVacio $_.doc_bloquea) -or (Test-NoVacio $_.doc_avisa) -or (Test-NoVacio $_.product_avisa) }).Count -gt 0
$gatesRoster = @(
  [pscustomobject]@{ gate = 'andon-stop';     vivo = $andonVivo;  razon = 'ninguna area con doc_bloquea/doc_avisa/product_avisa' }
  [pscustomobject]@{ gate = 'review-stop';    vivo = $revisaVivo; razon = 'ninguna area con revisa:true' }
  [pscustomobject]@{ gate = 'gemba-stop';     vivo = $gembaVivo;  razon = 'ninguna area con rol revisor-visual' }
  [pscustomobject]@{ gate = 'validador-stop'; vivo = $validaVivo; razon = 'ninguna area con rol validador' }
)

# --- Conformidad estructural de un doc capa-2 (misma regla que estado-docs.ps1) ---
function Normaliza($s) {
  $t = ($s -replace '^#{1,6}\s+', '').Trim()
  $t = ($t -replace '\s+', ' ').ToLowerInvariant()
  $formD = $t.Normalize([System.Text.NormalizationForm]::FormD)
  $sb = New-Object System.Text.StringBuilder
  foreach ($ch in $formD.ToCharArray()) {
    if ([System.Globalization.CharUnicodeInfo]::GetUnicodeCategory($ch) -ne [System.Globalization.UnicodeCategory]::NonSpacingMark) { [void]$sb.Append($ch) }
  }
  return $sb.ToString().Normalize([System.Text.NormalizationForm]::FormC)
}
function Get-Secciones($path) {
  $out = @(); $enFence = $false
  foreach ($line in [System.IO.File]::ReadAllLines($path)) {
    if ($line -match '^\s*(```|~~~)') { $enFence = -not $enFence; continue }
    if ($enFence) { continue }
    if ($line -match '^##\s+\S') { $out += (Normaliza $line) }
  }
  return , $out
}
function Get-EstadoDoc($docAbs, $requeridas) {
  if (-not (Test-Path -LiteralPath $docAbs)) { return 'ausente' }
  $secciones = Get-Secciones $docAbs
  foreach ($req in $requeridas) {
    $reqN = Normaliza $req; $hit = $false
    foreach ($sec in $secciones) { if ($sec.StartsWith($reqN)) { $hit = $true; break } }
    if (-not $hit) { return 'desviado' }
  }
  return 'conforme'
}

# --- Enumerar archivos del repo (trackeados + no-trackeados no-ignorados): la foto
#     real incluye lo recien soltado por el agente ("documentos sin trackear"). ---
Push-Location $repoRoot
# -c core.quotepath=false: sin esto, git escapa las rutas no-ASCII en octal y entre
# comillas (docs/notana.md -> "d\303\263cs\...") -- esa cadena, no la ruta real, casaria
# contra los globs de la ley y saldria como HUERFANO falso en un repo en espanol.
$tracked = @(git -c core.quotepath=false ls-files 2>$null)
$okGit = ($LASTEXITCODE -eq 0)
$untracked = @(git -c core.quotepath=false ls-files --others --exclude-standard 2>$null)
Pop-Location
if (-not $okGit) {
  # Falla CERRADO: sin la lista de archivos no se puede decir que esta huerfano. Emitir
  # un "cero huerfanos" con 0 archivos seria justo la mentira verde que esta vista existe
  # para matar ("la linterna no inventa verdad"). Mismo criterio que verificar.ps1/rutear.ps1.
  Write-Host "[ERROR] no pude enumerar los archivos de $repoRoot (git ls-files fallo -- es un repo git?)." -ForegroundColor Red
  Write-Host "        la linterna FALLA CERRADO: sin la foto de los archivos no se pinta un verde a ciegas."
  exit 2
}
$files = @(@($tracked + $untracked) | Where-Object { $_ } | Sort-Object -Unique)

# Arboles que el auditor del grafo escanea (auditar.ps1): estar aqui = gobernado por
# el grafo de notas, aunque ninguna area del blast-radius lo liste como fuente.
$arbolesAuditados = @('product/', 'docs/', 'kanban/', 'doctrina/', 'kit/.jidoka/templates/')
# Docs declarados LIBRES a proposito (capa-3): no son huerfanos, son constancia.
$libres = @()
if ($ledger -and $ledger.capa3) { $libres = @($ledger.capa3) }
$capa2Docs = @()
if ($ledger -and $ledger.capa2) { $capa2Docs = @($ledger.capa2 | ForEach-Object { $_.doc }) }

# La ley MENCIONA un path en algun excluye (canonicos de raiz, piezas exentas): el
# gate no lo nombra, pero NO es desconocido -- la ley lo declara. Cubierto, no huerfano.
function Test-EnLaLey($path) {
  foreach ($a in $areas) {
    if ($a.excluye) { foreach ($e in $a.excluye) { if (Test-Pattern $path $e) { return $true } } }
  }
  return $false
}

# Que CUBRE a un archivo (o $null si es HUERFANO -- la ley no lo conoce de ninguna forma).
# Un archivo esta cubierto si: (1) un area lo GOBIERNA (fuente, no excluido por esa area);
# (2) el ledger de docs lo lista (capa-2/3); (3) vive en un arbol auditado; (4) es infra
# convencional (dot-dirs de config, qa_runs de evidencia); (5) la ley lo declara exento por
# algun excluye. Solo lo que no cae en NINGUNA es huerfano (el "candy.md" de entisoft-rescate).
function Get-Cobertura($path) {
  foreach ($a in $areas) {
    if (-not (Test-NoVacio $a.fuente)) { continue }
    $inFuente = $false
    foreach ($f in $a.fuente) { if (Test-Pattern $path $f) { $inFuente = $true; break } }
    if (-not $inFuente) { continue }
    $excl = $false
    if ($a.excluye) { foreach ($e in $a.excluye) { if (Test-Pattern $path $e) { $excl = $true; break } } }
    if (-not $excl) { return "area:$($a.nombre)" }
  }
  if ($capa2Docs -contains $path) { return 'ledger:capa-2' }
  if ($libres -contains $path) { return 'ledger:capa-3 (libre)' }
  foreach ($arbol in $arbolesAuditados) { if ($path -like "$arbol*") { return "auditor:$arbol" } }
  # infra convencional: dot-dirs de config (.github/.vscode/.jidoka) y evidencia (qa_runs)
  if ($path -like '.*/*' -or $path -like 'qa_runs/*' -or $path -like '*/qa_runs/*') { return 'infra' }
  if (Test-EnLaLey $path) { return 'ley:exento' }
  return $null
}

$huerfanos = @()
foreach ($p in $files) {
  # el propio .html generado nunca cuenta (vive fuera de git idealmente)
  if ($p -like '.jidoka/*') { continue }
  $cob = Get-Cobertura $p
  if (-not $cob) { $huerfanos += $p }
}

# ------------------------------------------------------------------ construir el grafo
$nodos = New-Object System.Collections.Generic.List[object]
$aristas = New-Object System.Collections.Generic.List[object]

foreach ($g in $gatesRoster) {
  $det = if ($g.vivo) { 'Stop hook VIVO: alguna area de la ley lo enciende.' } else { "DORMIDO: $($g.razon)." }
  $nodos.Add([pscustomobject]@{ id = "gate:$($g.gate)"; label = $g.gate; tipo = 'gate'; vivo = [bool]$g.vivo; detalle = $det })
}
foreach ($a in $areas) {
  if (-not (Test-NoVacio $a.fuente)) { continue }
  $det = "$($a.desc). Gobierna: $($a.fuente -join ', ')."
  if ($a.excluye) { $det += " Excluye: $($a.excluye -join ', ')." }
  $nodos.Add([pscustomobject]@{ id = "area:$($a.nombre)"; label = $a.nombre; tipo = 'area'; vivo = $true; detalle = $det })
  foreach ($gate in (Get-GatesDeArea $a)) {
    $aristas.Add([pscustomobject]@{ s = "area:$($a.nombre)"; t = "gate:$gate"; kind = 'vigila' })
  }
}
if ($ledger -and $ledger.capa2) {
  foreach ($e in $ledger.capa2) {
    $estado = Get-EstadoDoc (Join-Path $repoRoot $e.doc) $e.requeridas
    if ($estado -eq 'ausente') { continue }
    $det = "doc capa-2 (gobernado por secciones). Estado: $estado. Molde: $($e.molde)."
    $nodos.Add([pscustomobject]@{ id = "doc:$($e.doc)"; label = $e.doc; tipo = "doc-$estado"; vivo = $true; detalle = $det })
    $cob = Get-Cobertura $e.doc
    if ($cob -and $cob -like 'area:*') { $aristas.Add([pscustomobject]@{ s = "doc:$($e.doc)"; t = ($cob -replace '^area:', 'area:'); kind = 'cubre' }) }
  }
}
foreach ($p in $huerfanos) {
  $nodos.Add([pscustomobject]@{ id = "orphan:$p"; label = $p; tipo = 'orphan'; vivo = $false; detalle = 'HUERFANO: ninguna area, ni el ledger de docs, ni un arbol auditado lo cubre. No esta mapeado contra nada.' })
}

# ---------------------------------------------------------------- R2: la telarana completa
# Hasta aqui el grafo era el esqueleto (areas, gates, docs, huerfanos). Ahora se suma lo que
# hace del blast-radius una telarana: los documentos-dueno (si tocas X, actualiza/bloquea Y),
# las capacidades del producto, los hooks de agente, y los checks de CI. Todo derivado de la
# ley real + settings.json + andon.yml + product/capacidades -- ni un nodo inventado.
$seen = New-Object System.Collections.Generic.HashSet[string]
function Add-NodoUnico($id, $label, $tipo, $vivo, $detalle) {
  if ($seen.Add($id)) {
    $nodos.Add([pscustomobject]@{ id = $id; label = $label; tipo = $tipo; vivo = $vivo; detalle = $detalle })
  }
}
# A donde apunta una arista de documento-dueno. Si el doc YA es un nodo capa-2 (existe en
# disco -> se creo el nodo doc:), se apunta a ESE nodo -- no se duplica el mismo archivo como
# 'owner:' y 'doc:' desconectados (hallazgo de code-review). La condicion (capa2 + existe) es
# la misma con que el bucle capa-2 creo el nodo, asi que nunca apunta a un nodo inexistente.
function Get-OwnerTargetId($d) {
  if (($capa2Docs -contains $d) -and (Test-Path -LiteralPath (Join-Path $repoRoot $d))) { return "doc:$d" }
  return "owner:$d"
}

# (1) documentos-dueno: lo que un gate exige sincronizar. doc_bloquea = arista DURA (bloquea el
#     push); doc_avisa = arista BLANDA (solo avisa). Un mismo doc (CHANGELOG.md) apuntado por
#     varias areas queda como UN nodo con varias flechas: se ve el dueno compartido.
foreach ($a in $areas) {
  if (-not (Test-NoVacio $a.fuente)) { continue }
  foreach ($d in @($a.doc_bloquea)) {
    if (-not $d) { continue }
    $tid = Get-OwnerTargetId $d
    if ($tid -like 'owner:*') { Add-NodoUnico $tid $d 'doc-owner' $true "Documento-dueno. Si tocas el area '$($a.nombre)', este doc DEBE cambiar en el mismo commit o el push se BLOQUEA (doc_bloquea, arista dura)." }
    $aristas.Add([pscustomobject]@{ s = "area:$($a.nombre)"; t = $tid; kind = 'bloquea' })
  }
  foreach ($d in @($a.doc_avisa)) {
    if (-not $d) { continue }
    $tid = Get-OwnerTargetId $d
    if ($tid -like 'owner:*') { Add-NodoUnico $tid $d 'doc-owner' $true "Documento-dueno. Si tocas el area '$($a.nombre)', conviene actualizar este doc (doc_avisa: avisa, no bloquea)." }
    $aristas.Add([pscustomobject]@{ s = "area:$($a.nombre)"; t = $tid; kind = 'avisa' })
  }
}

# (2) capacidades del producto (product/capacidades/*.md) + area->cap (product_avisa) + wikilinks.
$caps = @()
$capsDir = Join-Path $repoRoot 'product/capacidades'
if (Test-Path -LiteralPath $capsDir) {
  Get-ChildItem -LiteralPath $capsDir -Filter *.md -File | Where-Object { $_.Name -ne 'README.md' } | ForEach-Object {
    $raw = Get-Content -LiteralPath $_.FullName -Raw
    $clave = $_.BaseName
    if ($raw -match '(?m)^\s*clave:\s*(.+?)\s*$') { $clave = $Matches[1].Trim() }
    $caps += [pscustomobject]@{ clave = $clave; file = $_.Name; stem = $_.BaseName; path = "product/capacidades/$($_.Name)"; raw = $raw }
  }
}
foreach ($c in $caps) {
  Add-NodoUnico "cap:$($c.file)" $c.clave 'capability' $true "Capacidad del producto ($($c.clave)). Vive en $($c.path)."
}
foreach ($a in $areas) {
  # mismo guard que el bucle de docs: un area sin 'fuente' no tiene nodo (el nodo area: exige
  # fuente), asi que emitir aristas desde ella crearia flechas a un nodo inexistente que el JS
  # descarta en silencio -- mentira por omision (hallazgo de code-review). Ej: la entrada config
  # 'auditor' (scanDirsExtra) no tiene fuente.
  if (-not (Test-NoVacio $a.fuente)) { continue }
  if (-not (Test-NoVacio $a.product_avisa)) { continue }
  foreach ($glob in @($a.product_avisa)) {
    if (-not $glob) { continue }
    $resolvio = $false
    foreach ($c in $caps) {
      if (Test-Pattern $c.path $glob) {
        $aristas.Add([pscustomobject]@{ s = "area:$($a.nombre)"; t = "cap:$($c.file)"; kind = 'product' })
        $resolvio = $true
      }
    }
    if (-not $resolvio) {
      # la ley apunta a capacidades que no existen aun (hijo sin ese grafo): muestra el glob (honesto).
      Add-NodoUnico "capglob:$glob" $glob 'capability' $true "Capacidades apuntadas por la ley pero sin resolver (no hay esa capacidad en product/capacidades)."
      $aristas.Add([pscustomobject]@{ s = "area:$($a.nombre)"; t = "capglob:$glob"; kind = 'product' })
    }
  }
}
foreach ($c in $caps) {
  foreach ($m in [regex]::Matches($c.raw, '\[\[([^\]\|#]+)')) {
    $dest = $m.Groups[1].Value.Trim()
    foreach ($h in @($caps | Where-Object { $_.stem -eq $dest -or $_.clave -eq $dest -or $_.file -eq "$dest.md" })) {
      if ($h -and $h.file -ne $c.file) {
        $aristas.Add([pscustomobject]@{ s = "cap:$($c.file)"; t = "cap:$($h.file)"; kind = 'wikilink' })
      }
    }
  }
}

# el area que gobierna el motor (hooks + CI): a ella se cuelgan los hooks no-gate y los checks.
$ciArea = $null
$covCi = Get-Cobertura '.github/workflows/andon.yml'
if ($covCi -and $covCi -like 'area:*') { $ciArea = $covCi }

# (3) hooks de agente NO-gate (los Stop hooks ya son nodos gate): no-memorias (PreToolUse), etc.
$gateNames = @('andon-stop', 'review-stop', 'gemba-stop', 'validador-stop')
$settingsPath = Join-Path $repoRoot '.claude/settings.json'
if (Test-Path -LiteralPath $settingsPath) {
  try {
    $st = Get-Content -LiteralPath $settingsPath -Raw | ConvertFrom-Json
    foreach ($evt in @('PreToolUse', 'Stop')) {
      foreach ($grp in @($st.hooks.$evt)) {
        foreach ($h in @($grp.hooks)) {
          if ($h.command -and $h.command -match '([\w\-]+)\.ps1') {
            $nm = $Matches[1]
            if ($gateNames -contains $nm) { continue }
            Add-NodoUnico "hook:$nm" $nm 'hook' $true "Hook de agente ($evt): maquinaria fija que corre en cada '$evt' (no es un Stop gate de la ley)."
            if ($ciArea) { $aristas.Add([pscustomobject]@{ s = "hook:$nm"; t = $ciArea; kind = 'hook' }) }
          }
        }
      }
    }
  } catch {}
}
if (Test-Path -LiteralPath (Join-Path $repoRoot '.githooks/pre-push')) {
  Add-NodoUnico "hook:pre-push" 'pre-push' 'hook' $true 'Hook de git: corre el verificador y anti-PII antes de cada push (cinturon local, se salta con --no-verify -- el muro real es el CI).'
  if ($ciArea) { $aristas.Add([pscustomobject]@{ s = "hook:pre-push"; t = $ciArea; kind = 'hook' }) }
}

# (4) checks de CI (pasos de .github/workflows/andon.yml): el muro server-side, el unico real.
$ciPath = Join-Path $repoRoot '.github/workflows/andon.yml'
$ciIdx = 0
if (Test-Path -LiteralPath $ciPath) {
  foreach ($ln in [System.IO.File]::ReadAllLines($ciPath)) {
    if ($ln -match '^\s*-\s*name:\s*(.+?)\s*$') {
      # limpia comillas de YAML y un comentario en linea (hallazgo de code-review, cosmetico).
      $cn = ($Matches[1] -replace '\s+#.*$', '').Trim().Trim('"', "'")
      if (-not $cn) { continue }
      $ciIdx++
      # id UNICO por posicion: dos steps con el mismo 'name' en jobs distintos ya no colapsan
      # en un nodo (hallazgo de code-review); el label sigue siendo el nombre corto.
      $cid = "check:$($ciIdx):$cn"
      $short = if ($cn.Length -gt 30) { $cn.Substring(0, 28) + '..' } else { $cn }
      Add-NodoUnico $cid $short 'check' $true "Check de CI server-side (el muro REAL, required check sin bypass): $cn"
      if ($ciArea) { $aristas.Add([pscustomobject]@{ s = $cid; t = $ciArea; kind = 'ci' }) }
    }
  }
}

$conteo = [pscustomobject]@{
  huerfanos = $huerfanos.Count
  areas     = @($areas | Where-Object { Test-NoVacio $_.fuente }).Count
  gatesVivos = @($gatesRoster | Where-Object { $_.vivo }).Count
  archivos  = $files.Count
}
$meta = [pscustomobject]@{
  repo = (Split-Path -Leaf $repoRoot)
  huerfanos = $huerfanos.Count
  areas = $conteo.areas
  gatesVivos = $conteo.gatesVivos
  archivos = $conteo.archivos
}

$dataJson = (@{ nodes = $nodos; edges = $aristas } | ConvertTo-Json -Depth 8 -Compress)
$metaJson = ($meta | ConvertTo-Json -Depth 4 -Compress)

# ------------------------------------------------------------------ plantilla HTML
# Here-string LITERAL (@' '@): el JS usa $ y ${} sin que PS los expanda. Los datos
# se inyectan por Replace de dos placeholders. Cero <script src>, cero fetch, cero
# servidor: un archivo que se abre con doble clic.
$tmpl = @'
<!doctype html>
<html lang="es"><head><meta charset="utf-8">
<meta name="viewport" content="width=device-width,initial-scale=1">
<title>Linterna del gobierno</title>
<style>
  :root{--bg:#0f1115;--fg:#e6e8ee;--mut:#9aa3b2;--card:#171a21;--line:#2a2f3a;
        --area:#4c8dff;--gate-on:#31c48d;--gate-off:#6b7280;--conf:#2dd4bf;--desv:#f59e0b;--orphan:#ef4444;--free:#94a3b8;
        --owner:#22d3ee;--cap:#a78bfa;--hook:#fb923c;--check:#f472b6;}
  @media (prefers-color-scheme:light){:root{--bg:#f6f7f9;--fg:#1b1f27;--mut:#5b6472;--card:#fff;--line:#e2e6ec;}}
  *{box-sizing:border-box} html,body{margin:0;height:100%}
  body{background:var(--bg);color:var(--fg);font:14px/1.4 system-ui,Segoe UI,Roboto,sans-serif;display:flex;flex-direction:column}
  header{padding:12px 16px;border-bottom:1px solid var(--line);display:flex;gap:20px;align-items:center;flex-wrap:wrap}
  h1{font-size:15px;margin:0;font-weight:650}
  .metric{display:flex;gap:6px;align-items:baseline}
  .metric b{font-size:26px;line-height:1} .metric.bad b{color:var(--orphan)} .metric.good b{color:var(--gate-on)}
  .metric span{color:var(--mut);font-size:12px}
  .sub{color:var(--mut);font-size:12px}
  .legend{display:flex;gap:12px;flex-wrap:wrap;margin-left:auto}
  .lg{display:flex;gap:5px;align-items:center;font-size:12px;color:var(--mut);cursor:pointer;user-select:none}
  .lg .dot{width:11px;height:11px;border-radius:50%;display:inline-block}
  .lg.off{opacity:.35;text-decoration:line-through}
  #wrap{flex:1;position:relative;overflow:hidden}
  svg{width:100%;height:100%;display:block}
  .edge{stroke:var(--line);stroke-width:1.2}
  .node circle{stroke:rgba(0,0,0,.25);stroke-width:1;cursor:grab}
  .node text{fill:var(--fg);font-size:11px;pointer-events:none;paint-order:stroke;stroke:var(--bg);stroke-width:3px}
  .node.dim{opacity:.12} .edge.dim{opacity:.05}
  .node.orphan circle{stroke:#fff;stroke-width:1.5;filter:drop-shadow(0 0 5px var(--orphan))}
  #tip{position:absolute;pointer-events:none;background:var(--card);border:1px solid var(--line);border-radius:8px;
       padding:8px 10px;max-width:320px;font-size:12px;color:var(--fg);box-shadow:0 6px 24px rgba(0,0,0,.35);opacity:0;transition:opacity .1s;z-index:5}
  #tip b{color:var(--fg)} #tip .k{color:var(--mut)}
  footer{padding:6px 16px;border-top:1px solid var(--line);color:var(--mut);font-size:11px}
</style></head>
<body>
<header>
  <h1>Linterna del gobierno &mdash; <span id="repo" class="sub"></span></h1>
  <div class="metric" id="mHuerfanos"><b>0</b><span>huerfanos</span></div>
  <div class="metric"><b id="mAreas">0</b><span>areas</span></div>
  <div class="metric"><b id="mGates">0</b><span>gates vivos</span></div>
  <div class="metric"><b id="mArchivos">0</b><span>archivos</span></div>
  <div class="legend" id="legend"></div>
</header>
<div id="wrap"><svg id="svg"></svg><div id="tip"></div></div>
<footer>Vista de solo lectura, derivada de la ley real (tools/blast-radius.json + docs-gobernados.json). No gatea nada. Arrastra los nodos; pasa el cursor para el porque.</footer>
<script>
/*__PAYLOAD__*/
const TIPOS = {
  area:{c:'var(--area)',r:12,txt:'area (que gobierna)'},
  'gate':{c:'var(--gate-on)',r:9,txt:'gate (Stop hook)'},
  'doc-conforme':{c:'var(--conf)',r:8,txt:'doc capa-2 conforme'},
  'doc-desviado':{c:'var(--desv)',r:8,txt:'doc capa-2 desviado'},
  'doc-ausente':{c:'var(--free)',r:7,txt:'doc ausente'},
  'doc-owner':{c:'var(--owner)',r:8,txt:'documento-dueno'},
  capability:{c:'var(--cap)',r:9,txt:'capacidad'},
  hook:{c:'var(--hook)',r:8,txt:'hook'},
  check:{c:'var(--check)',r:7,txt:'check de CI'},
  orphan:{c:'var(--orphan)',r:9,txt:'HUERFANO'},
};
function colorOf(n){
  if(n.tipo==='gate') return n.vivo?'var(--gate-on)':'var(--gate-off)';
  const t=TIPOS[n.tipo]; return t?t.c:'var(--free)';
}
function radiusOf(n){const t=TIPOS[n.tipo];return t?t.r:8;}
document.getElementById('repo').textContent=META.repo;
document.getElementById('mAreas').textContent=META.areas;
document.getElementById('mGates').textContent=META.gatesVivos;
document.getElementById('mArchivos').textContent=META.archivos;
const mh=document.getElementById('mHuerfanos');
mh.querySelector('b').textContent=META.huerfanos;
mh.classList.add(META.huerfanos>0?'bad':'good');

// --- leyenda + filtro por tipo ---
const legend=document.getElementById('legend');
const hidden=new Set();
const legendItems=[['area','area','var(--area)'],['gate','gate','var(--gate-on)'],
  ['doc-owner','doc-dueno','var(--owner)'],['doc-conforme','doc ok','var(--conf)'],['doc-desviado','doc desviado','var(--desv)'],
  ['capability','capacidad','var(--cap)'],['hook','hook','var(--hook)'],['check','check CI','var(--check)'],['orphan','huerfano','var(--orphan)']];
legendItems.forEach(([tp,lbl,col])=>{
  const el=document.createElement('span');el.className='lg';el.dataset.tp=tp;
  el.innerHTML=`<span class="dot" style="background:${col}"></span>${lbl}`;
  el.onclick=()=>{el.classList.toggle('off');if(hidden.has(tp))hidden.delete(tp);else hidden.add(tp);draw();};
  legend.appendChild(el);
});
function tipoOculto(t){ if(t.startsWith('doc-'))return hidden.has(t); return hidden.has(t); }

// --- layout force-directed (vanilla, sin dependencias) ---
const svg=document.getElementById('svg'), wrap=document.getElementById('wrap'), tip=document.getElementById('tip');
let W=wrap.clientWidth, H=wrap.clientHeight;
const nodes=DATA.nodes.map((n,i)=>({...n,x:W/2+Math.cos(i)*140+(i%7)*9,y:H/2+Math.sin(i)*140+(i%5)*9,vx:0,vy:0}));
const idx=new Map(nodes.map((n,i)=>[n.id,i]));
const edges=DATA.edges.filter(e=>idx.has(e.s)&&idx.has(e.t)).map(e=>({s:idx.get(e.s),t:idx.get(e.t),kind:e.kind}));
// estilo de arista por tipo de relacion (color + punteado): dura=roja solida, blanda=ambar
// punteada, capacidad=violeta, wikilink=teal, vigila=verde, ci/hook=gris.
const EK={bloquea:['var(--orphan)',''],avisa:['var(--desv)','4 3'],product:['var(--cap)','2 3'],
  wikilink:['var(--conf)',''],vigila:['var(--gate-on)',''],cubre:['var(--area)',''],
  ci:['var(--check)','1 3'],hook:['var(--hook)','1 3']};
const adj=new Map(); nodes.forEach((_,i)=>adj.set(i,new Set()));
edges.forEach(e=>{adj.get(e.s).add(e.t);adj.get(e.t).add(e.s);});
let alpha=1, dragging=null, hoverId=null;

function step(){
  if(alpha<0.005 && !dragging) return;
  const k=alpha;
  for(let i=0;i<nodes.length;i++){
    const a=nodes[i];
    // repulsion
    for(let j=i+1;j<nodes.length;j++){
      const b=nodes[j]; let dx=a.x-b.x, dy=a.y-b.y; let d2=dx*dx+dy*dy||1; let d=Math.sqrt(d2);
      const rep=2600/d2; const fx=dx/d*rep, fy=dy/d*rep;
      a.vx+=fx*k; a.vy+=fy*k; b.vx-=fx*k; b.vy-=fy*k;
    }
    // gravedad al centro
    a.vx+=(W/2-a.x)*0.002*k; a.vy+=(H/2-a.y)*0.002*k;
  }
  // resortes en aristas
  edges.forEach(e=>{
    const a=nodes[e.s], b=nodes[e.t]; let dx=b.x-a.x, dy=b.y-a.y; let d=Math.sqrt(dx*dx+dy*dy)||1;
    const f=(d-90)*0.02*k; const fx=dx/d*f, fy=dy/d*f;
    a.vx+=fx; a.vy+=fy; b.vx-=fx; b.vy-=fy;
  });
  nodes.forEach(n=>{ if(n===dragging)return; n.vx*=0.82; n.vy*=0.82; n.x+=n.vx; n.y+=n.vy;
    n.x=Math.max(24,Math.min(W-24,n.x)); n.y=Math.max(24,Math.min(H-24,n.y)); });
  alpha*=0.985;
}
function draw(){
  let s='';
  edges.forEach(e=>{
    const a=nodes[e.s], b=nodes[e.t];
    const dimmed = (hoverId!==null && a.id!==hoverId && b.id!==hoverId) ? ' dim':'';
    if(tipoOculto(a.tipo)||tipoOculto(b.tipo))return;
    const ek=EK[e.kind]||['var(--line)',''];
    const dash=ek[1]?`;stroke-dasharray:${ek[1]}`:'';
    s+=`<line class="edge${dimmed}" style="stroke:${ek[0]}${dash}" x1="${a.x.toFixed(1)}" y1="${a.y.toFixed(1)}" x2="${b.x.toFixed(1)}" y2="${b.y.toFixed(1)}"/>`;
  });
  nodes.forEach(n=>{
    if(tipoOculto(n.tipo))return;
    const r=radiusOf(n), col=colorOf(n);
    const neigh = hoverId!==null && (n.id===hoverId || (adj.get(idx.get(hoverId))||new Set()).has(idx.get(n.id)));
    const dimmed = (hoverId!==null && !neigh) ? ' dim':'';
    const cls='node'+(n.tipo==='orphan'?' orphan':'')+dimmed;
    s+=`<g class="${cls}" data-id="${encodeURIComponent(n.id)}">`+
       `<circle cx="${n.x.toFixed(1)}" cy="${n.y.toFixed(1)}" r="${r}" fill="${col}"/>`+
       `<text x="${(n.x+r+3).toFixed(1)}" y="${(n.y+3).toFixed(1)}">${esc(n.label)}</text></g>`;
  });
  svg.innerHTML=s;
}
function esc(t){return (t+'').replace(/[&<>]/g,c=>({'&':'&amp;','<':'&lt;','>':'&gt;'}[c]));}
function loop(){ step(); draw(); requestAnimationFrame(loop); }
loop();

// --- interaccion: drag + hover ---
function nodeAt(ev){
  const g=ev.target.closest('.node'); if(!g)return null;
  return decodeURIComponent(g.dataset.id);
}
svg.addEventListener('mousedown',ev=>{const id=nodeAt(ev);if(id){dragging=nodes[idx.get(id)];alpha=Math.max(alpha,.3);}});
window.addEventListener('mousemove',ev=>{
  const rect=wrap.getBoundingClientRect();
  if(dragging){dragging.x=ev.clientX-rect.left;dragging.y=ev.clientY-rect.top;dragging.vx=dragging.vy=0;return;}
  const id=nodeAt(ev);
  if(id){ const n=nodes[idx.get(id)]; hoverId=id;
    tip.style.opacity=1; tip.style.left=(ev.clientX-rect.left+14)+'px'; tip.style.top=(ev.clientY-rect.top+14)+'px';
    tip.innerHTML=`<b>${esc(n.label)}</b><br><span class="k">${esc((TIPOS[n.tipo]||{txt:n.tipo}).txt)}</span><br>${esc(n.detalle||'')}`;
  } else { hoverId=null; tip.style.opacity=0; }
});
window.addEventListener('mouseup',()=>{dragging=null;});
window.addEventListener('resize',()=>{W=wrap.clientWidth;H=wrap.clientHeight;alpha=Math.max(alpha,.3);});
</script>
</body></html>
'@

# UN SOLO reemplazo de un token que no vive en los datos: el .Replace escanea la
# PLANTILLA (que aun no tiene datos) y sustituye la unica ocurrencia; el texto inyectado
# NO se re-escanea. Asi un texto de la ley que contenga '__DATA__'/'__META__' no puede
# corromper el JSON incrustado (bug del doble-Replace secuencial, cazado en code-review).
$payload = "const DATA = $dataJson;`n  const META = $metaJson;"
$html = $tmpl.Replace('/*__PAYLOAD__*/', $payload)

if (-not $Salida) { $Salida = Join-Path $repoRoot '.jidoka/gobierno.html' }
$dirSalida = Split-Path -Parent $Salida
if ($dirSalida -and -not (Test-Path -LiteralPath $dirSalida)) { New-Item -ItemType Directory -Path $dirSalida -Force | Out-Null }
[System.IO.File]::WriteAllText($Salida, $html, (New-Object System.Text.UTF8Encoding($false)))

Write-Host "== Linterna del gobierno =="
Write-Host ("  Repo: {0}" -f (Split-Path -Leaf $repoRoot))
if ($huerfanos.Count -gt 0) {
  Write-Host ("  [HUERFANOS] {0} archivo(s) que ninguna capa cubre:" -f $huerfanos.Count) -ForegroundColor Red
  foreach ($h in $huerfanos) { Write-Host ("    - {0}" -f $h) -ForegroundColor Red }
} else {
  Write-Host "  [OK] cero huerfanos: todo archivo lo cubre alguna capa (o esta declarado libre)." -ForegroundColor Green
}
Write-Host ("  Areas: {0} | Gates vivos: {1} | Archivos: {2}" -f $conteo.areas, $conteo.gatesVivos, $conteo.archivos) -ForegroundColor Cyan
Write-Host ("  Vista escrita en: {0}" -f $Salida)
Write-Host "  Abrela con doble clic (o start '$Salida') -- es un .html autocontenido, sin servidor."
exit 0
