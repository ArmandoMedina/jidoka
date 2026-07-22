#Requires -Version 5
# estado-docs.ps1 - AVISO de conformidad ESTRUCTURAL de los documentos capa-2.
# Hermano estructural de estado-motor.ps1: aquel gobierna el motor por HASH; este
# gobierna los documentos instancia-de-template por SECCIONES. Lee el ledger
# tools/docs-gobernados.json (que doc, su molde, sus secciones requeridas) y, para
# cada doc capa-2 presente, verifica que sus encabezados '## ' contengan las
# requeridas. Faltante -> DESVIADO (garantia nula); aditiva -> OK (no importa).
# El campo 'doc' puede ser un archivo singleton (product/infra.md) o un GLOB de
# FAMILIA (docs/sprints/*-plan.md, qa_runs/*/LOG.md): el glob se expande y se valida
# cada miembro; 0 miembros -> AVISO [FAMILIA VACIA], nunca un CONFORME en falso.
# exit 0 por defecto (aviso, no muro). -Estricto -> exit 1 si un doc 'estricto:true'
# pierde una requerida (el muro OPT-IN; se cablea en CI, nunca en verificar.ps1,
# para no clobbear el verificar customizado del hijo). Se siembra en cada hijo
# (motor). Archivo ASCII a proposito, PS 5.1.

param([switch]$Estricto)

$raiz = Split-Path -Parent $PSScriptRoot
$ledgerPath = Join-Path $raiz 'tools/docs-gobernados.json'

# Normaliza un encabezado para comparar: quita los '#', trim, colapsa espacios,
# minuscula, y hace FOLD DE ACENTOS via .NET FormD (sin literales acentuados en la
# fuente -> el archivo queda ASCII, coherente con el pipeline del motor). Asi
# 'Que hace' (stub ASCII) y 'Que hace (capacidades ancla)' (maduro con acento) caen
# bajo la misma clave, pero una seccion renumerada ('2. El flujo') NO empieza igual.
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

# Extrae los encabezados nivel 2 ('## ' con espacio, no '###') de un markdown,
# normalizados. Salta las lineas dentro de un bloque de codigo cercado (``` o ~~~):
# un '## ejemplo' dentro de un fence es ilustracion, no un encabezado real -- contarlo
# daria un CONFORME falso si el encabezado de verdad se borro.
function Get-Secciones($path) {
  $out = @()
  $enFence = $false
  foreach ($line in [System.IO.File]::ReadAllLines($path)) {
    if ($line -match '^\s*(```|~~~)') { $enFence = -not $enFence; continue }
    if ($enFence) { continue }
    if ($line -match '^##\s+\S') { $out += (Normaliza $line) }
  }
  return ,$out
}

Write-Host "== Conformidad estructural de documentos (capa-2) =="

if (-not (Test-Path -LiteralPath $ledgerPath)) {
  Write-Host "  (no hay tools/docs-gobernados.json: actualiza el motor para gobernar la estructura de brief/infra/CONTRIBUTING.)" -ForegroundColor Yellow
  exit 0
}
$ledger = Get-Content -LiteralPath $ledgerPath -Raw | ConvertFrom-Json

# Valida UN doc contra sus requeridas: imprime su linea y devuelve un codigo
#   0 = CONFORME | 1 = DESVIADO (no estricto) | 2 = DESVIADO estricto.
# Comparte la mecanica entre el doc singleton y cada miembro de una familia-glob.
function Check-Doc($docAbs, $label, $requeridas, $estricto) {
  $secciones = Get-Secciones $docAbs
  $faltan = @()
  foreach ($req in $requeridas) {
    $reqN = Normaliza $req
    $hit = $false
    foreach ($sec in $secciones) { if ($sec.StartsWith($reqN)) { $hit = $true; break } }
    if (-not $hit) { $faltan += $req }
  }
  if ($faltan.Count -eq 0) {
    Write-Host ("  [CONFORME]  {0}" -f $label) -ForegroundColor Green
    return 0
  }
  if ($estricto) { $etq = '[DESVIADO*]' } else { $etq = '[DESVIADO] ' }
  Write-Host ("  {0} {1} -- falta(n): {2}" -f $etq, $label, ($faltan -join ', ')) -ForegroundColor Yellow
  Write-Host "               garantia nula: la logica que el ritual inyecta con @ no se garantiza sobre este doc."
  if ($estricto) { return 2 } else { return 1 }
}

$conf = 0; $desv = 0; $estrictoRoto = 0
foreach ($e in $ledger.capa2) {
  # 'doc' puede ser una ruta singleton (product/infra.md) o un GLOB de familia
  # (docs/sprints/*-plan.md, qa_runs/*/LOG.md). El glob se detecta por *, ? o [.
  $esFamilia = ($e.doc -match '[\*\?\[]')
  if ($esFamilia) {
    # Familia: se expande el glob y se valida CADA miembro por separado. 0 miembros
    # -> AVISO visible, NUNCA un CONFORME en falso: un glob que no matchea es una
    # senal (patron roto o carpeta vacia), no un pase silencioso (el verde mentiroso).
    $glob = Join-Path $raiz $e.doc
    $miembros = @(Get-ChildItem -Path $glob -File -ErrorAction SilentlyContinue | Sort-Object FullName)
    if ($miembros.Count -eq 0) {
      Write-Host ("  [FAMILIA VACIA]  {0} -- 0 miembros: el glob no matcheo ningun archivo (revisa el patron)." -f $e.doc) -ForegroundColor Yellow
      continue
    }
    foreach ($m in $miembros) {
      $label = $m.FullName.Substring($raiz.Length).TrimStart('\', '/')
      $r = Check-Doc $m.FullName $label $e.requeridas $e.estricto
      if ($r -eq 0) { $conf++ } elseif ($r -eq 2) { $desv++; $estrictoRoto++ } else { $desv++ }
    }
  }
  else {
    $docAbs = Join-Path $raiz $e.doc
    if (-not (Test-Path -LiteralPath $docAbs)) { continue }   # no presente en este arquetipo/hijo: se salta
    $r = Check-Doc $docAbs $e.doc $e.requeridas $e.estricto
    if ($r -eq 0) { $conf++ } elseif ($r -eq 2) { $desv++; $estrictoRoto++ } else { $desv++ }
  }
}

if ($estrictoRoto -gt 0) { $extra = " ($estrictoRoto estricto)" } else { $extra = '' }
Write-Host ("  Resumen: {0} conforme(s) | {1} desviado(s){2}." -f $conf, $desv, $extra) -ForegroundColor Cyan
if ($desv -gt 0) {
  Write-Host "  (DESVIADO = la estructura gobernada cambio; el contenido puede variar libre, las SECCIONES no. '*' = estricto.)"
}

# -Estricto: muro OPT-IN. Solo los docs 'estricto:true' que pierden una requerida
# bloquean (exit 1). Sin -Estricto, siempre exit 0 (aviso). Nace apagado: encenderlo
# es marcar estricto:true en el ledger + correr con -Estricto en el required-check de CI.
if ($Estricto -and $estrictoRoto -gt 0) { exit 1 }
exit 0
