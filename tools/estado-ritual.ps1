#Requires -Version 5
# estado-ritual.ps1 - AVISO de conformidad del ESTATUTO del ritual. Hermano de
# estado-docs.ps1: aquel gobierna la ESTRUCTURA de los documentos de instancia por
# SECCIONES; este gobierna los @-includes de FABRICA de los comandos del ritual. Lee el
# ledger tools/ritual-gobernado.json (que comando, sus @ requeridos) y, para cada comando
# presente, verifica que sus directivas @<ruta> (fuera de bloques de codigo cercados)
# contengan las requeridas. Faltante -> DESVIADO (garantia nula); aditiva (@ EXTRA del
# cliente) -> OK (el corazon: extender es legal, mutilar no). exit 0 por defecto (aviso,
# no muro). -Estricto -> exit 1 si un comando 'estricto:true' pierde un @ requerido (el
# muro OPT-IN; se cablea en CI, nunca en verificar.ps1). Se siembra (motor). ASCII, PS 5.1.
#
# Trampa confesada (fase 1): los comandos son MOTOR (sellados por hash). Un @ legal que el
# cliente agregue hara DIVERGER el sello aunque el estatuto diga CONFORME -- el estatuto es
# la autoridad sobre la LEGALIDAD del @; el sello solo ve bytes. La cura completa (clase
# 'contrato' en la siembra) esta diferida (R3b, ADR 0046). El detector lo confiesa abajo.

param([switch]$Estricto, [switch]$Json)

$raiz = Split-Path -Parent $PSScriptRoot
$ledgerPath = Join-Path $raiz 'tools/ritual-gobernado.json'

# Extrae las directivas @<ruta> de un comando: cualquier token '@<ruta.ext>' (una ruta con
# extension) FUERA de un bloque de codigo cercado (``` o ~~~). Matchea las dos formas que usa
# el ritual: bare en columna 0 (arranca/planea: `@product/PRODUCT_BRIEF.md`) y backtickeada en
# vinieta (que-sigue: `- **`@HANDOFF.md`**`). Solo se saltan los FENCES (ilustracion), no los
# backticks inline -- un @ref backtickeado sigue siendo la referencia. Misma disciplina de
# fences que Get-Secciones de estado-docs.ps1.
function Get-Arrobas($path) {
  $out = @()
  $enFence = $false
  foreach ($line in [System.IO.File]::ReadAllLines($path)) {
    if ($line -match '^\s*(```|~~~)') { $enFence = -not $enFence; continue }
    if ($enFence) { continue }
    foreach ($m in [regex]::Matches($line, '(?<![A-Za-z0-9_])@([A-Za-z0-9_./\-]+\.[A-Za-z0-9]+)')) {
      $out += $m.Groups[1].Value
    }
  }
  return , $out
}

# --- Con -Json, la salida de consola se silencia (aditivo puro): se acumula el array
#     $comandos y se emite SOLO {"comandos":[{comando,conforme,faltan[]}]} al final.
#     Sin -Json, el comportamiento es byte-identico al de siempre. ---
if (-not $Json) { Write-Host "== Conformidad del estatuto del ritual (@-includes de fabrica) ==" }

if (-not (Test-Path -LiteralPath $ledgerPath)) {
  if ($Json) {
    Write-Output (@{ comandos = @() } | ConvertTo-Json -Depth 6)
    exit 0
  }
  Write-Host "  (no hay tools/ritual-gobernado.json: actualiza el motor para gobernar los @ de fabrica del ritual.)" -ForegroundColor Yellow
  exit 0
}
$ledger = Get-Content -LiteralPath $ledgerPath -Raw | ConvertFrom-Json

$conf = 0; $desv = 0; $estrictoRoto = 0
$comandos = @()   # -Json: @{ comando; conforme; faltan[] } por comando presente
foreach ($e in $ledger.comandos) {
  $cmdAbs = Join-Path $raiz $e.comando
  if (-not (Test-Path -LiteralPath $cmdAbs)) { continue }   # comando no presente en este arquetipo/hijo: se salta
  $arrobas = Get-Arrobas $cmdAbs
  $faltan = @()
  foreach ($req in $e.arrobas_requeridas) {
    if ($arrobas -notcontains $req) { $faltan += $req }
  }
  if ($faltan.Count -eq 0) {
    if (-not $Json) { Write-Host ("  [CONFORME]  {0}" -f $e.comando) -ForegroundColor Green }
    $conf++
    $comandos += @{ comando = "$($e.comando)"; conforme = $true; faltan = @() }
  }
  else {
    if (-not $Json) {
      if ($e.estricto) { $etq = '[DESVIADO*]' } else { $etq = '[DESVIADO] ' }
      Write-Host ("  {0} {1} -- falta(n) el/los @: {2}" -f $etq, $e.comando, ($faltan -join ', ')) -ForegroundColor Yellow
      Write-Host "               garantia nula: la logica que el comando esperaba inyectar con ese @ no corre."
    }
    $desv++
    if ($e.estricto) { $estrictoRoto++ }
    $comandos += @{ comando = "$($e.comando)"; conforme = $false; faltan = @($faltan) }
  }
}

# -Json: emite el array (envuelto en @() para no colapsar 1 elemento a objeto) y sale con
# el MISMO exit code de siempre (respeta -Estricto). Sin BOM: Write-Output del string.
if ($Json) {
  Write-Output (@{ comandos = @($comandos) } | ConvertTo-Json -Depth 6)
  if ($Estricto -and $estrictoRoto -gt 0) { exit 1 }
  exit 0
}

if ($estrictoRoto -gt 0) { $extra = " ($estrictoRoto estricto)" } else { $extra = '' }
Write-Host ("  Resumen: {0} conforme(s) | {1} desviado(s){2}." -f $conf, $desv, $extra) -ForegroundColor Cyan
if ($desv -gt 0) {
  Write-Host "  (DESVIADO = falta un @ de FABRICA. Un @ EXTRA que agregues es CONFORME: aditiva legal. Reconcilia: restaura el @ o acepta con firma.)"
}
Write-Host "  (Nota fase 1: un @ extra legal puede hacer DIVERGER el sello por hash del comando aunque aqui sea CONFORME. El estatuto manda sobre la legalidad del @; el sello solo ve bytes. Cura completa: R3b, la clase 'contrato' en la siembra.)" -ForegroundColor DarkGray

# -Estricto: muro OPT-IN. Solo los comandos 'estricto:true' que pierden un @ requerido
# bloquean (exit 1). Sin -Estricto, siempre exit 0 (aviso). Nace apagado: encenderlo es
# marcar estricto:true en el ledger + correr con -Estricto en el required-check de CI.
if ($Estricto -and $estrictoRoto -gt 0) { exit 1 }
exit 0
