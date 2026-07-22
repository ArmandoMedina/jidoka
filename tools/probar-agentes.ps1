#Requires -Version 5
# probar-agentes.ps1 - lint de los agentes-asiento (.claude/agents/*.md). Los tiers de
# modelo (ADR 0033) se instalan como agentes-asiento con model: fijo en frontmatter --
# este lint es lo que los vigila: si el harness ve un alias que no reconoce, cae en
# silencio al default caro (el punto exacto que ADR 0029/0033 acusa: la conciencia no
# depende de la iniciativa del agente). Valida, contra un directorio (default
# .claude/agents; -Dir para fixtures de prueba):
#   - existen los 4 asientos esperados: explorador, mecanico, auditor, arquitecto.
#   - cada .md tiene frontmatter YAML con name:, description:, model:, tools:.
#   - model: es un ALIAS REAL del harness (haiku | sonnet | opus -- lista cerrada).
#   - name: coincide con el nombre del archivo (sin .md).
#   - el cuerpo trae el enfoque conductual (R8b): seccion '## Como piensas', seccion
#     '## Tu reporte', y la frase obligatoria del reporte 'Lo que note por mi cuenta'
#     -- sin estas, el asiento volvio a ser el prompt generico (el defecto que R8b cura).
#
# Uso:  ./tools/probar-agentes.ps1 [-Dir <ruta>]   (exit 0 = sano; exit 1 = un agente
#       tiene un bug -- no lo estrenes.)
# Nota: archivo ASCII a proposito (sin acentos), PS 5.1.

param([string]$Dir = '')

if (-not $Dir) { $Dir = Join-Path (Split-Path -Parent $PSScriptRoot) '.claude/agents' }

$script:fallos = 0
$script:casos = 0
function Check($nombre, $cond, $detalle) {
  $script:casos++
  if ($cond) { Write-Host "  [PASA]  $nombre" -ForegroundColor Green }
  else { Write-Host "  [FALLA] $nombre ($detalle)" -ForegroundColor Red; $script:fallos++ }
}

# Parsea el frontmatter YAML simple (key: value) del bloque --- ... --- inicial.
# Parser GEMELO del de tools/auditar.ps1 (duplicado a proposito: cada lint corre
# standalone, sin dot-source); si arreglas un edge-case aqui, revisa el otro.
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

$aliasReales = @('haiku', 'sonnet', 'opus')
$asientosEsperados = @('explorador', 'mecanico', 'auditor', 'arquitecto')

# Lista cerrada de herramientas validas del harness (issue #82). Derivada de los 4 agentes
# reales (.claude/agents/) + herramientas estandar documentadas del SDK. EDITABLE: si el
# harness suma una herramienta nueva, agregarla aqui antes de declararla en un agente.
# Herramientas de los asientos actuales: Read, Glob, Grep, Bash, Edit
# Herramientas estandar del harness: Read, Write, Edit, Glob, Grep, Bash, WebFetch,
#   WebSearch, Agent, AskUserQuestion, Skill, NotebookEdit, TodoWrite, Task
$toolsValidas = @(
  'Read', 'Write', 'Edit', 'Glob', 'Grep', 'Bash',
  'WebFetch', 'WebSearch', 'Agent', 'AskUserQuestion',
  'Skill', 'NotebookEdit', 'TodoWrite', 'Task'
)

Write-Host "== Lint de agentes-asiento ($Dir) =="

if (-not (Test-Path -LiteralPath $Dir)) {
  Write-Host "  [FALLA] el directorio no existe: $Dir" -ForegroundColor Red
  Write-Host ""
  Write-Host "== 1 de 1 caso(s) fallidos. No hay agentes que lintear. ==" -ForegroundColor Red
  exit 1
}

# 1. Existen los 4 asientos esperados.
foreach ($asiento in $asientosEsperados) {
  $p = Join-Path $Dir "$asiento.md"
  Check "existe el asiento: $asiento.md" (Test-Path -LiteralPath $p) "no encuentro $p"
}

# 2. Cada .md del directorio (no solo los 4 esperados: una fixture de prueba puede
#    traer solo el roto) tiene frontmatter valido y un model: de la lista cerrada.
$archivos = @(Get-ChildItem -LiteralPath $Dir -Filter *.md -File -ErrorAction SilentlyContinue)
if ($archivos.Count -eq 0) {
  Check "hay al menos un agente .md en el directorio" $false "directorio vacio: $Dir"
}
foreach ($f in $archivos) {
  $texto = Get-Content -LiteralPath $f.FullName -Raw -Encoding UTF8
  $fm = Get-Frontmatter $texto
  if ($null -eq $fm) {
    Check "$($f.Name): frontmatter YAML valido (--- ... ---)" $false "sin frontmatter o sin cierre ---"
    continue
  }
  Check "$($f.Name): frontmatter tiene 'name:'" ($fm.ContainsKey('name') -and $fm['name']) "falta name: o esta vacio"
  Check "$($f.Name): frontmatter tiene 'description:'" ($fm.ContainsKey('description') -and $fm['description']) "falta description: o esta vacia"
  Check "$($f.Name): frontmatter tiene 'model:'" ($fm.ContainsKey('model') -and $fm['model']) "falta model: o esta vacio"
  Check "$($f.Name): frontmatter tiene 'tools:'" ($fm.ContainsKey('tools') -and $fm['tools']) "falta tools: o esta vacio"

  if ($fm.ContainsKey('model') -and $fm['model']) {
    Check "$($f.Name): model: es un alias real del harness ($($aliasReales -join ' | '))" `
      ($aliasReales -contains $fm['model']) `
      "model: '$($fm['model'])' no es haiku/sonnet/opus -- el harness lo ignoraria en silencio y caeria al default caro"
  }

  if ($fm.ContainsKey('name') -and $fm['name']) {
    Check "$($f.Name): name: coincide con el nombre del archivo" `
      ($fm['name'] -eq $f.BaseName) `
      "name: '$($fm['name'])' no coincide con '$($f.BaseName)'"
  }

  if ($fm.ContainsKey('tools') -and $fm['tools']) {
    $nombresDeclarados = @($fm['tools'] -split ',' | ForEach-Object { $_.Trim() } | Where-Object { $_ })
    # -cnotcontains: case-sensitive a proposito -- el harness distingue 'Read' de 'read';
    # el -notcontains default de PS 5.1 dejaria pasar un casing roto.
    $toolsInvalidas = @($nombresDeclarados | Where-Object { $toolsValidas -cnotcontains $_ })
    Check "$($f.Name): tools: solo usa herramientas de la lista cerrada del harness" `
      ($toolsInvalidas.Count -eq 0) `
      "herramienta(s) no reconocida(s): $($toolsInvalidas -join ', ') -- un typo silencioso rompe el agente; lista valida: $($toolsValidas -join ', ')"
  }

  # 3. El cuerpo trae el enfoque conductual (R8b): sin esto el asiento es el prompt
  #    generico otra vez -- el defecto exacto que R8b cura. Los headers y la frase llevan
  #    acentos en los .md (UTF-8); este lint es ASCII a proposito, asi que se matchean con
  #    '.' comodin donde va el acento ('C.mo' = 'Como', 'not.' = 'note'). Multilinea (?m)
  #    para anclar el header a su propia linea; \s*$ tolera espacios sueltos al final.
  Check "$($f.Name): cuerpo tiene la seccion '## Como piensas' (el sesgo de oficio)" `
    ($texto -match '(?m)^##\s+C.mo piensas\s*$') `
    "falta el header '## Como piensas' -- sin el, el asiento no declara como piensa distinto"

  Check "$($f.Name): cuerpo tiene la seccion '## Tu reporte' (estructura fija)" `
    ($texto -match '(?m)^##\s+Tu reporte\s*$') `
    "falta el header '## Tu reporte' -- sin el, no hay estructura de entrega"

  Check "$($f.Name): reporte trae la frase obligatoria 'Lo que note por mi cuenta'" `
    ($texto -match 'Lo que not. por mi cuenta') `
    "falta 'Lo que note por mi cuenta' -- el hallazgo no pedido es el corazon de R8b; obligatorio aunque diga 'nada'"
}

Write-Host ""
if ($script:fallos -gt 0) {
  Write-Host "== $($script:fallos) de $($script:casos) caso(s) fallidos. Un agente-asiento tiene un bug: no lo estrenes. ==" -ForegroundColor Red
  exit 1
}
Write-Host "== Agentes-asiento sanos: los $($script:casos) casos se comportan como se espera. ==" -ForegroundColor Green
exit 0
