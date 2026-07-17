#Requires -Version 5
# estado-docs.ps1 - AVISO de conformidad ESTRUCTURAL de los documentos capa-2.
# Hermano estructural de estado-motor.ps1: aquel gobierna el motor por HASH; este
# gobierna los documentos instancia-de-template por SECCIONES. Lee el ledger
# tools/docs-gobernados.json (que doc, su molde, sus secciones requeridas) y, para
# cada doc capa-2 presente, verifica que sus encabezados '## ' contengan las
# requeridas. Faltante -> DESVIADO (garantia nula); aditiva -> OK (no importa).
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

$conf = 0; $desv = 0; $estrictoRoto = 0
foreach ($e in $ledger.capa2) {
  $docAbs = Join-Path $raiz $e.doc
  if (-not (Test-Path -LiteralPath $docAbs)) { continue }   # no presente en este arquetipo/hijo: se salta
  $secciones = Get-Secciones $docAbs
  $faltan = @()
  foreach ($req in $e.requeridas) {
    $reqN = Normaliza $req
    $hit = $false
    foreach ($sec in $secciones) { if ($sec.StartsWith($reqN)) { $hit = $true; break } }
    if (-not $hit) { $faltan += $req }
  }
  if ($faltan.Count -eq 0) {
    Write-Host ("  [CONFORME]  {0}" -f $e.doc) -ForegroundColor Green
    $conf++
  }
  else {
    if ($e.estricto) { $etq = '[DESVIADO*]' } else { $etq = '[DESVIADO] ' }
    Write-Host ("  {0} {1} -- falta(n): {2}" -f $etq, $e.doc, ($faltan -join ', ')) -ForegroundColor Yellow
    Write-Host "               garantia nula: la logica que el ritual inyecta con @ no se garantiza sobre este doc."
    $desv++
    if ($e.estricto) { $estrictoRoto++ }
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
