#Requires -Version 5
# sembrar-manual.ps1 - Fallback de siembra/actualizacion del motor, INDEPENDIENTE de
# instalar.ps1. Existe porque instalar.ps1 -- por nombre ("instalar") y comportamiento
# (core.hooksPath + copia de hooks + -ExecutionPolicy Bypass) -- es iman de heuristica
# de AV: en Windows endurecido (justo los repos regulados que Jidoka apunta) el SO puede
# negar leerlo/ejecutarlo, y el hijo se queda SIN ruta de siembra ni actualizacion, en
# silencio (jidoka#40/#43). La leccion (ADR 0027): la ruta de actualizacion NO debe ser a
# la vez unico punto de falla y el artefacto mas sospechoso del kit. Este script es el
# segundo camino: mismo destino, menor superficie de sospecha (sin Bypass, sin el nombre
# "instalar"). Reproduce el fallback manual del reporte (copiar 'motor' del manifiesto +
# core.hooksPath + escribir el sello), pero guiado y testeado.
#
# Uso:
#   ./tools/sembrar-manual.ps1 -Destino <repo>                       (siembra fresca, docs-as-code)
#   ./tools/sembrar-manual.ps1 -Destino <repo> -Arquetipo code-first (siembra fresca, otro arquetipo)
#   ./tools/sembrar-manual.ps1 -Destino <repo> -Jidoka <ruta>        (desde un hijo: apunta al checkout de Jidoka)
#   ./tools/sembrar-manual.ps1 -Destino <repo> -Actualizar           (baja la mecanica a un hijo ya sembrado)
#
# NO usa -ExecutionPolicy Bypass ni se llama "instalar" a proposito. No-clobber: nunca pisa
# la instancia. Los 3 helpers de abajo estan DUPLICADOS de instalar.ps1 a proposito: este
# script debe correr aunque instalar.ps1 sea ilegible, asi que no puede depender de el.
# Nota: archivo ASCII a proposito (sin acentos) para PS 5.1.

[CmdletBinding()]
param(
  [Parameter(Mandatory = $true)][string]$Destino,
  [string]$Jidoka = '',
  [string]$Arquetipo = 'docs-as-code',
  [switch]$Actualizar
)

$ErrorActionPreference = 'Stop'
$utf8 = New-Object System.Text.UTF8Encoding($false)

function Info($m) { Write-Host "  $m" }
function Ok($m)   { Write-Host "  [OK] $m" -ForegroundColor Green }
function Die($m)  { Write-Host "[ERROR] $m" -ForegroundColor Red; exit 1 }

# SHA256 del contenido NORMALIZADO A LF (sin CR): hash agnostico al fin de linea, igual
# que instalar.ps1/estado-motor. Sin esto un hijo eol=lf diverge de un Jidoka crlf en todo
# (ADR 0021). Duplicado a proposito (independencia de instalar.ps1; ver cabecera).
function Get-MotorHash($path) {
  $bytes = [System.IO.File]::ReadAllBytes($path)
  $sinCR = New-Object System.Collections.Generic.List[byte]
  foreach ($b in $bytes) { if ($b -ne 13) { $sinCR.Add($b) } }
  $sha = [System.Security.Cryptography.SHA256]::Create()
  try { $h = $sha.ComputeHash($sinCR.ToArray()) } finally { $sha.Dispose() }
  return ([System.BitConverter]::ToString($h) -replace '-', '')
}

# Aplana una entrada de 'motor' a pares { rel; src }: la ruta relativa (destino, con '/')
# y la fuente absoluta en el arbol de Jidoka. Igual que instalar.ps1 (duplicado a proposito).
function Get-MotorPares($entry, $root) {
  $srcRoot = Join-Path $root $entry.origen
  $pares = @()
  if (-not (Test-Path -LiteralPath $srcRoot)) { return $pares }
  if ($entry.dir) {
    Get-ChildItem -LiteralPath $srcRoot -Recurse -File | ForEach-Object {
      $relEnOrigen = $_.FullName.Substring($srcRoot.Length).TrimStart('\', '/').Replace('\', '/')
      $relDst = ($entry.destino.Replace('\', '/')).TrimEnd('/') + '/' + $relEnOrigen
      $pares += [pscustomobject]@{ rel = $relDst; src = $_.FullName }
    }
  } else {
    $pares += [pscustomobject]@{ rel = $entry.destino.Replace('\', '/'); src = $srcRoot }
  }
  return $pares
}

# --- 1. Resolver el checkout de Jidoka (la FUENTE del motor) --------------------
# Orden: -Jidoka > $env:JIDOKA_HOME > el padre de este script si parece un Jidoka.
$jidoka = $Jidoka
if (-not $jidoka) { $jidoka = $env:JIDOKA_HOME }
if (-not $jidoka) {
  $cand = Split-Path -Parent $PSScriptRoot
  if (Test-Path (Join-Path $cand 'kit/.jidoka/instalar/manifiesto.json')) { $jidoka = $cand }
}
if (-not $jidoka) {
  Die "no se de donde tomar el motor. Pasa -Jidoka <ruta-al-repo-jidoka> o exporta JIDOKA_HOME."
}
$jidoka = (Resolve-Path -LiteralPath $jidoka).Path
$manifPath = Join-Path $jidoka 'kit/.jidoka/instalar/manifiesto.json'
if (-not (Test-Path $manifPath)) { Die "no encuentro el manifiesto en '$jidoka' (kit/.jidoka/instalar/manifiesto.json). Es un checkout de Jidoka?" }
$manif = Get-Content $manifPath -Raw | ConvertFrom-Json

# --- 2. Preparar el destino -----------------------------------------------------
if (-not (Test-Path -LiteralPath $Destino)) { New-Item -ItemType Directory -Path $Destino -Force | Out-Null }
$Destino = (Resolve-Path -LiteralPath $Destino).Path
if ($Destino -eq $jidoka) { Die "el destino no puede ser el propio repo de Jidoka" }
if (-not (Test-Path (Join-Path $Destino '.git'))) {
  Info "el destino no es un repo git; corriendo 'git init'..."
  git init -q $Destino 2>$null | Out-Null
}

$selloDst = Join-Path $Destino 'tools/jidoka-motor.json'
$versionPath = Join-Path $jidoka 'tools/version.txt'
$version = if (Test-Path $versionPath) { (Get-Content $versionPath -Raw).Trim() } else { 'desconocida' }

# --- 3. Leer el sello previo (excluir + hashes sembrados) para el modo -Actualizar ---
$seedPrevio = @{}
$excluir = @()
if (Test-Path -LiteralPath $selloDst) {
  $selloViejo = Get-Content $selloDst -Raw | ConvertFrom-Json
  if ($selloViejo.sembrado_hashes) { foreach ($p in $selloViejo.sembrado_hashes.PSObject.Properties) { $seedPrevio[$p.Name] = $p.Value } }
  if ($selloViejo.excluir) { $excluir = @($selloViejo.excluir) }
} elseif ($Actualizar) {
  Die "no hay sello (tools/jidoka-motor.json) en '$Destino': no parece un hijo ya sembrado. Corre sin -Actualizar para la siembra inicial."
}

# En siembra fresca, el arquetipo puede excluir piezas (p.ej. code-first no quiere
# probar-gate.ps1 ni andon.yml). Se anotan en el sello para que un -Actualizar no las re-agregue.
if (-not $Actualizar) {
  $arq = $manif.arquetipos.$Arquetipo
  if (-not $arq) { Die "arquetipo desconocido: '$Arquetipo'. Opciones: $($manif.arquetipos.PSObject.Properties.Name -join ', ')" }
  if (-not $arq.disponible) { Die "el arquetipo '$Arquetipo' aun no esta disponible: $($arq.nota)" }
  if ($arq.excluir_motor) { $excluir = @($arq.excluir_motor) }
}

# --- 4. Sembrar la mecanica -----------------------------------------------------
# Politica: siembra fresca = no-clobber (preserva lo que ya exista); -Actualizar = tres
# vias por hash (igual que instalar.ps1). El sello se reconstruye clasificando cada pieza.
$modo = if ($Actualizar) { 'Actualizar (baja la mecanica al hijo)' } else { "siembra fresca (arquetipo: $Arquetipo)" }
Write-Host "== Sembrar manual: $modo | Jidoka $version =="
Info "Fuente: $jidoka"

$seed = [ordered]@{}
$copiados = 0; $alDia = 0; $actualizados = 0; $divergen = @(); $excluidas = 0

foreach ($e in $manif.motor) {
  if ($e.clase -and $e.clase -ne 'mecanica') { continue }
  foreach ($par in (Get-MotorPares $e $jidoka)) {
    if ($excluir -contains $par.rel) {
      if ($Actualizar) { Write-Host "  [EXCLUIDA] $($par.rel)" -ForegroundColor DarkGray; $excluidas++ }
      continue
    }
    $jidokaHash = Get-MotorHash $par.src
    $childAbs = Join-Path $Destino $par.rel

    if (-not (Test-Path -LiteralPath $childAbs)) {                       # 1. ausente -> copiar
      $parent = Split-Path -Parent $childAbs
      if ($parent -and -not (Test-Path -LiteralPath $parent)) { New-Item -ItemType Directory -Path $parent -Force | Out-Null }
      Copy-Item -LiteralPath $par.src -Destination $childAbs -Force
      $seed[$par.rel] = $jidokaHash; $copiados++
      Write-Host "  [SIEMBRA] $($par.rel)" -ForegroundColor Green
      continue
    }
    $childHash = Get-MotorHash $childAbs
    if ($childHash -eq $jidokaHash) { $seed[$par.rel] = $jidokaHash; $alDia++; continue }  # 2. al dia

    # 3. el hijo difiere de Jidoka.
    if ($Actualizar) {
      $seedHash = $seedPrevio[$par.rel]
      if ($seedHash -and $childHash -eq $seedHash) {                     # 3a. no lo toco -> actualizar
        Copy-Item -LiteralPath $par.src -Destination $childAbs -Force
        $seed[$par.rel] = $jidokaHash; $actualizados++
        Write-Host "  [ACTUALIZA] $($par.rel)" -ForegroundColor Cyan
      } else {                                                          # 3b. lo customizo -> DIVERGE (preserva)
        Copy-Item -LiteralPath $par.src -Destination "$childAbs.jidoka-nuevo" -Force
        $seed[$par.rel] = $jidokaHash; $divergen += $par.rel            # el sello guarda lo que Jidoka ENVIA
        Write-Host "  [DIVERGE] $($par.rel) -> se dejo $($par.rel).jidoka-nuevo (revisa a mano)" -ForegroundColor Yellow
      }
    } else {                                                            # siembra fresca (no-clobber): customizada
      $divergen += $par.rel                                             # preservada; OMITIDA del sello (se vera DIVERGE luego)
      Write-Host "  [PRESERVA] $($par.rel) (customizada; no se pisa, no se sella)" -ForegroundColor Yellow
    }
  }
}

# --- 5. Sembrar la ley del arquetipo (solo en siembra fresca, no-clobber) --------
# La mecanica sembrada (verificar/auditar) necesita tools/blast-radius.json para correr.
if (-not $Actualizar) {
  $leySrc = Join-Path $jidoka $manif.arquetipos.$Arquetipo.ley
  $leyDst = Join-Path $Destino $manif.ley_destino
  if (Test-Path -LiteralPath $leyDst) { Info "(ley ya existe, no se pisa: $($manif.ley_destino))" }
  elseif (Test-Path -LiteralPath $leySrc) {
    $parent = Split-Path -Parent $leyDst
    if ($parent -and -not (Test-Path -LiteralPath $parent)) { New-Item -ItemType Directory -Path $parent -Force | Out-Null }
    Copy-Item -LiteralPath $leySrc -Destination $leyDst -Force
    Ok "ley del arquetipo sembrada: $($manif.ley_destino)"
  }
}

# --- 6. Escribir el sello (tools/jidoka-motor.json) -----------------------------
# version + hash de cada pieza pristina/enviada. En -Actualizar preserva la lista de
# exclusion; en siembra fresca la anota si el arquetipo excluyo piezas.
$selloNuevo = [ordered]@{ version = $version; sembrado_hashes = $seed }
if ($excluir.Count) { $selloNuevo.excluir = @($excluir) }
$parent = Split-Path -Parent $selloDst
if ($parent -and -not (Test-Path -LiteralPath $parent)) { New-Item -ItemType Directory -Path $parent -Force | Out-Null }
[System.IO.File]::WriteAllText($selloDst, ($selloNuevo | ConvertTo-Json -Depth 5), $utf8)

# --- 7. Encender core.hooksPath -------------------------------------------------
if ($manif.post.hooksPath) {
  git -C $Destino config core.hooksPath $manif.post.hooksPath 2>$null | Out-Null
  if ($LASTEXITCODE -eq 0) { Ok "core.hooksPath = $($manif.post.hooksPath)" }
  else { Info "(no pude fijar core.hooksPath; hazlo a mano: git -C '$Destino' config core.hooksPath $($manif.post.hooksPath))" }
}

# --- 8. Resumen -----------------------------------------------------------------
Write-Host ""
$resumen = if ($Actualizar) {
  "== Motor: $alDia al dia | $actualizados actualizado(s) | $copiados nuevo(s) | $($divergen.Count) divergen"
} else {
  "== Sembrado: $copiados pieza(s) | $alDia ya al dia | $($divergen.Count) preservada(s) (customizadas)"
}
if ($excluidas) { $resumen += " | $excluidas excluida(s)" }
Write-Host "$resumen ==" -ForegroundColor Green
Ok "sello escrito: tools/jidoka-motor.json (Jidoka $version, $($seed.Count) pieza(s))"
if ($divergen.Count -gt 0 -and $Actualizar) {
  Write-Host "Divergencias (el hijo las customizo; se preservaron, compara los .jidoka-nuevo):" -ForegroundColor Yellow
  foreach ($d in $divergen) { Write-Host "  - $d" -ForegroundColor Yellow }
}
Write-Host "Instancia (ley, product/, HANDOFF, ADRs) intacta salvo la ley sembrada si faltaba." -ForegroundColor Cyan
if (-not $Actualizar) {
  Write-Host "Nota: este fallback siembra la MECANICA + la ley + el sello (lo que desbloquea el gate)." -ForegroundColor Cyan
  Write-Host "      Los stubs de instancia (HANDOFF, ROADMAP, product/) se crean con instalar.ps1 cuando el AV lo permita, o a mano desde kit/.jidoka/templates/." -ForegroundColor Cyan
}
Write-Host "Verifica: ./tools/estado-motor.ps1 -Jidoka '$jidoka'  (debe decir [OK] al dia)." -ForegroundColor Cyan
exit 0
