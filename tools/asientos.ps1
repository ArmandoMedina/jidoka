#Requires -Version 5
# asientos.ps1 - El casting vivo de la sesion. Lee los agentes-asiento (.claude/agents/*.md)
# y dice, de forma DETERMINISTA, que asientos-subagente existen en ESTE repo y con que
# tier de modelo fijo (ADR 0033: el tier vive en el frontmatter del agente, no en la
# iniciativa de la sesion). Es el gemelo de rutear.ps1 para el casting: /jidoka:arranca
# lo imprime al abrir, en vez de cargar una copia en prosa que deriva -- la tabla se
# genera del artefacto que tiene dientes, asi que no puede mentir sobre el.
#
# Degrada con gracia (exit 0): sin agentes sembrados NO es un error de la ley -- es el
# fallback documentado del ritual (delegar con general-purpose y ACUSAR la degradacion).
# El mensaje impreso ES la acusacion. Se siembra en cada hijo (motor, clase mecanica);
# los self-tests (probar-hooks.ps1) apuntan carpetas sinteticas con -Dir.
# Archivo ASCII a proposito, PS 5.1, sin acentos en los literales (lo que imprime de
# los .md de los agentes se lee como UTF-8, acentos incluidos).

param([string]$Dir = '')

try { [Console]::OutputEncoding = New-Object System.Text.UTF8Encoding($false) } catch {}

if (-not $Dir) { $Dir = Join-Path (Split-Path $PSScriptRoot -Parent) '.claude\agents' }

$archivos = @()
if (Test-Path -LiteralPath $Dir) {
  $archivos = @(Get-ChildItem -LiteralPath $Dir -Filter '*.md' -File | Sort-Object Name)
}

# Parsea el frontmatter YAML simple (key: value) del bloque --- ... --- inicial.
# Parser GEMELO del de tools/probar-agentes.ps1 y tools/auditar.ps1 (duplicado a
# proposito: cada tool corre standalone, sin dot-source); si arreglas un edge-case
# aqui, revisa los otros dos. Devuelve $null si no hay frontmatter valido -- el
# caller se salta ese archivo (un .md sin frontmatter no es un agente).
function Get-Frontmatter($path) {
  $texto = [System.IO.File]::ReadAllText($path, (New-Object System.Text.UTF8Encoding($false)))
  $lineas = $texto -split "`r?`n"
  if ($lineas.Count -lt 2 -or $lineas[0].Trim() -ne '---') { return $null }
  $fm = @{}
  for ($i = 1; $i -lt $lineas.Count; $i++) {
    if ($lineas[$i].Trim() -eq '---') { return $fm }
    if ($lineas[$i] -match '^\s*([A-Za-z_][A-Za-z0-9_-]*):\s*(.*)$') {
      $fm[$Matches[1]] = $Matches[2].Trim()
    }
  }
  return $null  # sin cierre ---
}

# La tabla lee como el model-routing de kanban/roles.md (pequeno -> grande); tier
# desconocido al final -- probar-agentes.ps1 es quien lo caza como error, no este preview.
$peso = @{ 'haiku' = 1; 'sonnet' = 2; 'opus' = 3 }

$filas = @(foreach ($f in $archivos) {
  $fm = Get-Frontmatter $f.FullName
  if ($null -eq $fm) { continue }   # sin frontmatter (p.ej. un README): no es un agente
  $nombre = if ($fm['name']) { $fm['name'] } else { $f.BaseName }
  $tier = if ($fm['model']) { $fm['model'] } else { '?' }
  $desc = if ($fm['description']) { $fm['description'] } else { '' }
  # Resumen corto: hasta el primer guion largo, tope 64 chars (el detalle vive en el agente).
  $corte = $desc.IndexOf([char]0x2014)
  if ($corte -gt 10) { $desc = $desc.Substring(0, $corte).Trim() }
  if ($desc.Length -gt 64) { $desc = $desc.Substring(0, 61).TrimEnd() + '...' }
  $w = if ($peso.ContainsKey($tier)) { $peso[$tier] } else { 9 }
  [pscustomobject]@{ nombre = $nombre; tier = $tier; desc = $desc; peso = $w }
})

if ($filas.Count -eq 0) {
  Write-Host "== Casting vivo: SIN agentes-asiento ($Dir) =="
  Write-Host "  [DEGRADADO] no hay agentes-asiento sembrados: delega con el agente general" -ForegroundColor Yellow
  Write-Host "  (general-purpose) y anuncia igual el asiento que representa -- la degradacion se acusa, no se finge."
  exit 0
}

Write-Host "== Casting vivo: los asientos-subagente de este repo ($Dir) =="
Write-Host "   Elige el asiento, no el modelo: el tier ya esta fijo en el agente (ADR 0033)."
Write-Host ""
$fmt = "  {0,-14} {1,-8} {2}"
Write-Host ($fmt -f 'ASIENTO', 'TIER', 'PARA QUE')
Write-Host ($fmt -f '-------', '----', '--------')
foreach ($fila in ($filas | Sort-Object peso, nombre)) {
  Write-Host ($fmt -f $fila.nombre, $fila.tier, $fila.desc)
}
exit 0
