#Requires -Version 5
# auditar.ps1 - Auditor determinista del grafo de documentacion (product/).
# Verifica integridad estructural: frontmatter, wikilinks, criterios de las
# capacidades vigentes y huerfanas. Es un "muro" que corre el CI: un subagente no
# lo puede saltar porque se evalua sobre el ARTEFACTO (los .md del repo), no sobre
# confiar en el agente. Cosechado de los labs (criterio-no-copia, ADR 0007): alla
# auditaba product/+engineering/ y referencias a tests .py; aqui es generico
# (product/ + self-tests .ps1) y acepta -Repo para poder probarse.
#
# Complementa al doc-gate de verificar.ps1 (code->doc dueno, blast-radius):
# aquel cuida la sincronia codigo<->doc; este cuida que el grafo del QUE este integro.
#
# Reglas:
#   BLOQUEA - frontmatter ausente/incompleto; wikilink roto; capacidad 'vigente'
#             sin criterios de aceptacion Gherkin.
#   AVISA   - capacidad 'vigente' sin test referenciado ni disclaimer; nota huerfana.
#   Modulacion por estado (kanban/estados.md): 'en_definicion'/'en_revision' solo
#             exigen frontmatter+enlaces; 'vigente' exige criterios; 'pausado'/
#             'fuera_de_alcance' nada. Si no puede leer la ruta, degrada a no-marcar.
#
# Uso:
#   ./tools/auditar.ps1                    # audita todo product/ (modo aviso, exit 0)
#   ./tools/auditar.ps1 -Range main..HEAD  # solo las notas tocadas en el rango
#   ./tools/auditar.ps1 -Bloquea           # exit 1 si hay hallazgos BLOQUEA (modo CI)
#   ./tools/auditar.ps1 -Repo <ruta>       # audita otro arbol (para el self-test)
#
# Archivo ASCII a proposito (sin acentos) para PS 5.1; lee los .md como UTF-8.

[CmdletBinding()]
param(
  [string]$Range,
  [switch]$Bloquea,
  [string]$Repo
)

if (-not $Repo) { $Repo = Split-Path -Parent $PSScriptRoot }
Set-Location $Repo
$utf8 = New-Object System.Text.UTF8Encoding($false)

$script:block = 0
$script:warn  = 0
function Note($msg)  { Write-Host "  [AVISO] $msg"   -ForegroundColor Yellow; $script:warn++ }
function Block($msg) { Write-Host "  [BLOQUEA] $msg" -ForegroundColor Red;    $script:block++ }
function Fail($msg) {
  Write-Host "  [ERROR] $msg" -ForegroundColor Red
  Write-Host ""
  Write-Host "== Gate sin veredicto: FALLA CERRADO (exit 2). Un muro que ante fallo interno se abre no es muro. ==" -ForegroundColor Red
  exit 2
}

# Parsea el frontmatter YAML simple (key: value) del bloque --- ... --- inicial.
function Get-Frontmatter($text) {
  $lines = $text -split "`r?`n"
  if ($lines.Count -lt 2 -or $lines[0].Trim() -ne '---') { return $null }
  $fm = @{}
  for ($i = 1; $i -lt $lines.Count; $i++) {
    if ($lines[$i].Trim() -eq '---') { return $fm }
    if ($lines[$i] -match '^\s*([A-Za-z_][A-Za-z0-9_-]*):\s*(.*)$') {
      $fm[$Matches[1]] = $Matches[2].Trim()
    }
  }
  return $null  # sin cierre ---
}

# Normaliza el destino de un wikilink: [[a|alias]] -> a ; [[a#anchor]] -> a
function Get-WikiTarget($raw) {
  return ((($raw -split '\|')[0]) -split '#')[0].Trim()
}

Write-Host "== Auditar grafo de docs (product/) =="

# --- 1. Indice global de notas (stem -> ruta) para resolver wikilinks ----------
$scanDirs = @('product', 'docs', 'kanban', 'doctrina', 'kit/.jidoka/templates')
# Capas de docs PROPIAS del repo (fuera del set generico) se declaran en la INSTANCIA:
# tools/blast-radius.json -> "auditor": { "scanDirsExtra": ["engineering", ...] }. Asi un
# repo con product/ narrativo puede enlazar [[notas]] hacia su capa propia (p.ej. un
# engineering/ de runbooks) sin que el auditor las cuente como wikilink roto y bloquee el
# CI (jidoka#42). Sin el campo, el comportamiento es IDENTICO al de antes (default fijo).
# auditar.ps1 es mecanica que converge por el lazo; el campo es instancia (viaja en la ley,
# -Actualizar no la pisa). El directorio extra solo AMPLIA el indice para resolver wikilinks;
# lo AUDITADO sigue siendo product/ (paso 2).
$leyPath = 'tools/blast-radius.json'
if (Test-Path $leyPath) {
  try {
    $ley = Get-Content $leyPath -Raw | ConvertFrom-Json
    # La ley es un ARRAY de reglas; el config del auditor viaja como un entry con
    # "scanDirsExtra" (sin "fuente", inofensivo para verificar.ps1). Se itera y se
    # recogen los dirs extra de cualquier entry que los declare.
    foreach ($regla in @($ley)) {
      if ($regla.scanDirsExtra) {
        foreach ($d in @($regla.scanDirsExtra)) {
          if ($d -and ($scanDirs -notcontains $d)) { $scanDirs += $d }
        }
      }
    }
  } catch {}
}
$allNotes = @()
foreach ($d in $scanDirs) {
  if (Test-Path $d) { $allNotes += Get-ChildItem -Path $d -Recurse -Filter *.md -File }
}
$stemIndex = @{}
foreach ($n in $allNotes) {
  $stemIndex[[System.IO.Path]::GetFileNameWithoutExtension($n.Name)] = $n.FullName
}

# --- 2. Notas a auditar: product/, sin READMEs ---------------------------------
$targets = @()
if (Test-Path 'product') {
  $targets += Get-ChildItem -Path 'product' -Recurse -Filter *.md -File |
    Where-Object { $_.Name -ne 'README.md' }
}

# Filtro por rango: solo las notas tocadas en $Range (para el CI sobre un PR).
# Fail-closed (sprint 26): si git no puede calcular el rango, $changed quedaria
# vacio y el auditor aprobaria EN SILENCIO ("nada que auditar", exit 0) -- el
# unico gate que contradecia la disciplina del resto. Un auditor que no puede
# medir no aprueba.
if ($Range) {
  $changed = git diff --name-only $Range -- product
  if ($LASTEXITCODE -ne 0) { Fail "git diff no pudo calcular el rango '$Range': no se que notas auditar" }
  $changedSet = @{}
  foreach ($c in $changed) { $changedSet[$c.Replace('\', '/')] = $true }
  $targets = $targets | Where-Object {
    $changedSet.ContainsKey($_.FullName.Substring($Repo.Length + 1).Replace('\', '/'))
  }
}

if ($targets.Count -eq 0) {
  Write-Host "  (nada que auditar en product/ para este alcance)" -ForegroundColor DarkGray
}

# --- 3. Auditar cada nota ------------------------------------------------------
foreach ($t in $targets) {
  $rel  = $t.FullName.Substring($Repo.Length + 1).Replace('\', '/')
  $text = [System.IO.File]::ReadAllText($t.FullName, $utf8)
  $fm   = Get-Frontmatter $text

  # 3a. Frontmatter + claves requeridas.
  if ($null -eq $fm) { Block "$rel : sin frontmatter YAML valido (--- ... ---)"; continue }
  if (-not $fm.ContainsKey('tipo'))   { Block "$rel : frontmatter sin 'tipo'" }
  if (-not $fm.ContainsKey('estado')) { Block "$rel : frontmatter sin 'estado'" }
  $tipo   = $fm['tipo']
  $estado = $fm['estado']
  if ($tipo -eq 'capacidad') {
    foreach ($k in @('clave', 'modulo', 'dominio')) {
      if (-not $fm.ContainsKey($k)) { Block "$rel : capacidad sin '$k' en frontmatter" }
    }
  }

  # 3b. Wikilinks rotos.
  foreach ($m in [regex]::Matches($text, '\[\[([^\]]+)\]\]')) {
    $tg = Get-WikiTarget $m.Groups[1].Value
    if ($tg -and -not $stemIndex.ContainsKey($tg)) {
      Block "$rel : wikilink roto [[$tg]] (no existe nota con ese nombre)"
    }
  }

  # 3c. Modulacion por estado (solo capacidades vigentes exigen criterios).
  #     'pausado'/'fuera_de_alcance' no se auditan como capacidad activa.
  if ($tipo -eq 'capacidad' -and $estado -eq 'vigente') {
    if ($text -notmatch '##\s+Criterios de aceptaci') {
      Block "$rel : capacidad vigente sin seccion '## Criterios de aceptacion'"
    }
    elseif ($text -notmatch '(?im)^\s*-?\s*Dado ') {
      Block "$rel : capacidad vigente sin criterios Gherkin (Dado que... cuando... entonces...)"
    }
    $tieneDisclaimer = $text -match '(?i)no existe test'
    $testOk = $false
    foreach ($rt in [regex]::Matches($text, '(tools[/\\]probar-[\w-]+\.ps1|tests?[/\\][\w/\\.-]+)')) {
      if (Test-Path $rt.Value.Replace('\', '/')) { $testOk = $true; break }
    }
    if (-not $tieneDisclaimer -and -not $testOk) {
      Note "$rel : capacidad vigente sin test referenciado ni disclaimer 'no existe test'"
    }
  }

  # 3d. Molde de secciones de modulo/dominio (backbone; solo los vigentes). Un modulo
  #     vigente lista sus capacidades; un dominio vigente, sus modulos. Es el minimo
  #     canonico: no fuerza contenido a los stubs, pero impide que un modulo/dominio
  #     futuro pierda su seccion nucleo. El grafo de product/ lo gobierna auditar
  #     (ADR 0042), NO el ledger docs-gobernados.json (evita el doble-gobierno).
  if ($tipo -eq 'modulo' -and $estado -eq 'vigente') {
    if ($text -notmatch '(?im)^##\s+Capacidades') {
      Block "$rel : modulo vigente sin seccion '## Capacidades'"
    }
  }
  if ($tipo -eq 'dominio' -and $estado -eq 'vigente') {
    if ($text -notmatch '(?im)^##\s+M.dulos') {
      Block "$rel : dominio vigente sin seccion '## Modulos'"
    }
  }
}

# --- 4. Huerfanos: notas sin ningun enlace entrante [[...]] o ](...md) ----------
$inbound = @{}
foreach ($t in $targets) { $inbound[[System.IO.Path]::GetFileNameWithoutExtension($t.Name)] = 0 }
foreach ($n in $allNotes) {
  $srcStem = [System.IO.Path]::GetFileNameWithoutExtension($n.Name)
  $txt = [System.IO.File]::ReadAllText($n.FullName, $utf8)
  foreach ($m in [regex]::Matches($txt, '\[\[([^\]]+)\]\]')) {
    $tg = Get-WikiTarget $m.Groups[1].Value
    if ($inbound.ContainsKey($tg) -and $tg -ne $srcStem) { $inbound[$tg]++ }
  }
  foreach ($m in [regex]::Matches($txt, '\]\(([^)\s]+\.md)(?:#[^)]*)?\)')) {
    $st = [System.IO.Path]::GetFileNameWithoutExtension([System.Uri]::UnescapeDataString($m.Groups[1].Value))
    if ($inbound.ContainsKey($st) -and $st -ne $srcStem) { $inbound[$st]++ }
  }
}
$exentTipos = @('ecosistema', 'solucion', 'backlog', 'proceso', 'recursos', 'dominio')
foreach ($t in $targets) {
  $stem = [System.IO.Path]::GetFileNameWithoutExtension($t.Name)
  if ($inbound[$stem] -gt 0) { continue }
  $fm = Get-Frontmatter ([System.IO.File]::ReadAllText($t.FullName, $utf8))
  $tp = if ($fm) { $fm['tipo'] } else { '' }
  if ($exentTipos -contains $tp) { continue }
  $rel = $t.FullName.Substring($Repo.Length + 1).Replace('\', '/')
  Note "$rel : huerfana (ninguna otra nota la enlaza con [[...]])"
}

# --- 5. Resumen ----------------------------------------------------------------
Write-Host ""
if ($script:block -gt 0) {
  Write-Host "== $($script:block) hallazgo(s) BLOQUEA en el grafo de docs. ==" -ForegroundColor Red
  if ($script:warn -gt 0) { Write-Host "   (+$($script:warn) aviso[s] no bloqueante[s].)" -ForegroundColor Yellow }
  if ($Bloquea) { exit 1 }
  Write-Host "   (modo aviso local: no detiene. El CI con -Bloquea si lo hace.)" -ForegroundColor Yellow
  exit 0
}
elseif ($script:warn -gt 0) {
  Write-Host "== $($script:warn) aviso(s) en el grafo de docs (no bloquean). ==" -ForegroundColor Yellow
  exit 0
}
else { Write-Host "== Grafo de docs integro. ==" -ForegroundColor Green; exit 0 }
