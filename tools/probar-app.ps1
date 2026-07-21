#Requires -Version 5
# probar-app.ps1 - lint del cascaron de la app de la tuberia (app/).
# La app es un cascaron Tauri v2 cuya interfaz ES la maqueta. En R2 no hay compilador
# barato que corra en el CI (Rust no vive ahi), asi que este lint verifica los CONTRATOS
# que un test SI puede afirmar sin cargo: (a) la UI es copia byte-fiel de la spec congelada
# (la vara del Gemba de fidelidad), (b) la DECISION de que app/ es Jidoka-only sigue siendo
# cierta -- si alguien la mete al manifiesto de siembra, esto lo caza (ADR 0048, migrado del
# invariante de probar-extension.ps1), (c) la config Tauri parsea y apunta a la UI, y (d) las
# piezas del cascaron (Cargo.toml, main.rs) existen.
# NO invoca cargo: el CI no tiene Rust; el build local es la evidencia del .exe.
# Jidoka-only (como probar-extension): NO se siembra. PS 5.1, ASCII a proposito.

$ErrorActionPreference = 'Stop'
$raiz = Split-Path -Parent $PSScriptRoot
if (-not $raiz) { $raiz = (Get-Location).Path }

$script:pass = 0; $script:fail = 0
function Ok($m) { Write-Host "  [PASA]  $m"; $script:pass++ }
function No($m) { Write-Host "  [FALLA] $m" -ForegroundColor Red; $script:fail++ }

Write-Host "== App de la tuberia: cascaron fiel (app/) =="

$dir = Join-Path $raiz 'app'
$uiPath = Join-Path $dir 'ui/index.html'
$specPath = Join-Path $raiz 'docs/analisis/maqueta-tuberia-202607.html'

# (a) FIDELIDAD: app/ui/index.html nace copia byte-fiel de la maqueta congelada.
# NOTA R3: este assert se RELAJARA a paridad estructural (tabs #tuberia #bandeja #flujos
# #huecos, #ovl/#wiz, paleta) cuando el bloque de datos (P/E) se sustituya por invoke() al
# motor -- ver el plan-contrato, decision de diseno 3. Mientras tanto, hash identico = teatro
# fiel, la vara del Gemba de fidelidad que el cliente aprueba con sus ojos.
if (-not (Test-Path -LiteralPath $uiPath)) {
  No "no existe app/ui/index.html (la interfaz de la app)"
}
elseif (-not (Test-Path -LiteralPath $specPath)) {
  No "no existe la spec congelada docs/analisis/maqueta-tuberia-202607.html (la vara de fidelidad)"
}
else {
  Ok "existe app/ui/index.html (la interfaz)"
  $hUi = (Get-FileHash -LiteralPath $uiPath -Algorithm SHA256).Hash
  $hSpec = (Get-FileHash -LiteralPath $specPath -Algorithm SHA256).Hash
  if ($hUi -eq $hSpec) {
    Ok "app/ui/index.html es byte-identico a la maqueta congelada (SHA256 $hUi)"
  } else {
    No "app/ui/index.html NO es byte-fiel a la maqueta (UI $hUi vs spec $hSpec): la fidelidad se rompio"
  }
}

# (c) La config Tauri parsea como JSON y su frontendDist apunta a la UI.
$confPath = Join-Path $dir 'src-tauri/tauri.conf.json'
if (-not (Test-Path -LiteralPath $confPath)) {
  No "no existe app/src-tauri/tauri.conf.json (la config del cascaron)"
}
else {
  Ok "existe app/src-tauri/tauri.conf.json"
  $conf = $null
  try { $conf = Get-Content -LiteralPath $confPath -Raw | ConvertFrom-Json; Ok "la config Tauri es JSON valido" }
  catch { No "app/src-tauri/tauri.conf.json no es JSON valido: $($_.Exception.Message)" }
  if ($conf) {
    $fd = "$($conf.build.frontendDist)"
    if ($fd -match 'ui') { Ok "frontendDist apunta a la UI ($fd)" }
    else { No "frontendDist ('$fd') no apunta a la UI (la app no serviria la maqueta)" }
  }
}

# (d) Las piezas del cascaron Rust existen.
$cargoPath = Join-Path $dir 'src-tauri/Cargo.toml'
$mainPath = Join-Path $dir 'src-tauri/src/main.rs'
if (Test-Path -LiteralPath $cargoPath) { Ok "existe app/src-tauri/Cargo.toml" }
else { No "no existe app/src-tauri/Cargo.toml (el cascaron no compilaria)" }
if (Test-Path -LiteralPath $mainPath) { Ok "existe app/src-tauri/src/main.rs" }
else { No "no existe app/src-tauri/src/main.rs (falta el punto de entrada)" }

# (b) LA DECISION COMO INVARIANTE (ADR 0048): app/ es Jidoka-only. Es la cara de Jidoka,
# no motor generico que se propaga a los hijos. Si alguien la agrega al manifiesto de
# siembra sin cambiar la decision, esto lo caza (migrado del invariante de la extension).
$sembradoPath = Join-Path $raiz 'kit/.jidoka/instalar/manifiesto.json'
if (Test-Path -LiteralPath $sembradoPath) {
  $sembrado = Get-Content -LiteralPath $sembradoPath -Raw
  if ($sembrado -match '"app/') {
    No "app/ aparece en el manifiesto de siembra: la decision (ADR 0048) dice Jidoka-only. Si cambio, cambia el ADR primero"
  } else {
    Ok "app/ NO se siembra a los hijos (Jidoka-only, ADR 0048)"
  }
}

Write-Host ""
if ($script:fail -gt 0) {
  Write-Host "== App INCOMPLETA: $($script:fail) fallo(s), $($script:pass) ok. ==" -ForegroundColor Red
  exit 1
}
Write-Host "== App sana: $($script:pass) verificaciones verdes. =="
exit 0
