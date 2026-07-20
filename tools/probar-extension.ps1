#Requires -Version 5
# probar-extension.ps1 - lint de la extension de VS Code (extension/).
# La extension es JS plano sin build step, asi que no hay compilador que cace sus
# roturas: este lint hace de compilador barato. Verifica el CONTRATO manifiesto<->codigo
# (un comando declarado que nadie registra sale del menu y no hace nada: rot silencioso),
# que el JS parsee, y que la DECISION de que la extension es Jidoka-only siga siendo
# cierta -- si alguien la mete al manifiesto de siembra, este test lo caza (la decision
# del ADR 0044 deja de ser prosa y se vuelve invariante).
# Jidoka-only (como probar-instalador): NO se siembra. PS 5.1, ASCII a proposito.

$ErrorActionPreference = 'Stop'
$raiz = Split-Path -Parent $PSScriptRoot
if (-not $raiz) { $raiz = (Get-Location).Path }

$script:pass = 0; $script:fail = 0
function Ok($m) { Write-Host "  [PASA]  $m"; $script:pass++ }
function No($m) { Write-Host "  [FALLA] $m" -ForegroundColor Red; $script:fail++ }

Write-Host "== Extension de VS Code: contrato manifiesto<->codigo =="

$dir = Join-Path $raiz 'extension'
$manifPath = Join-Path $dir 'package.json'

if (-not (Test-Path -LiteralPath $manifPath)) {
  No "no existe extension/package.json (el manifiesto de la extension)"
}
else {
  Ok "existe el manifiesto extension/package.json"
  $manif = $null
  try { $manif = Get-Content -LiteralPath $manifPath -Raw | ConvertFrom-Json; Ok "el manifiesto es JSON valido" }
  catch { No "el manifiesto no es JSON valido: $($_.Exception.Message)" }

  if ($manif) {
    # main debe apuntar a un archivo que exista (si no, la extension no carga)
    $main = "$($manif.main)" -replace '^\./', ''
    $mainAbs = Join-Path $dir $main
    if ($main -and (Test-Path -LiteralPath $mainAbs)) { Ok "main apunta a un archivo real ($main)" }
    else { No "main ('$($manif.main)') no apunta a un archivo existente" }

    if ($manif.engines -and $manif.engines.vscode) { Ok "declara engines.vscode ($($manif.engines.vscode))" }
    else { No "falta engines.vscode (VS Code no sabria si es compatible)" }

    # EL CONTRATO: cada comando declarado debe registrarse en el codigo.
    $src = if (Test-Path -LiteralPath $mainAbs) { Get-Content -LiteralPath $mainAbs -Raw } else { '' }
    $cmds = @($manif.contributes.commands)
    if ($cmds.Count -gt 0) { Ok "declara $($cmds.Count) comando(s) en contributes" }
    else { No "no declara ningun comando (la extension no haria nada)" }
    foreach ($c in $cmds) {
      if (-not $c.command) { continue }
      if ($src -match [regex]::Escape("'" + $c.command + "'")) {
        Ok "comando registrado en el codigo: $($c.command)"
      } else {
        No "comando '$($c.command)' declarado en el manifiesto pero NO registrado en $main (saldria en el menu sin hacer nada)"
      }
      if ($c.title) { Ok "comando con titulo visible: $($c.title)" } else { No "el comando $($c.command) no tiene title" }
    }
  }

  # el JS debe parsear. Sin build step no hay compilador; node --check es el sustituto.
  if ($null -ne (Get-Command node -ErrorAction SilentlyContinue)) {
    $jsFiles = @(Get-ChildItem -LiteralPath $dir -Filter *.js -File -ErrorAction SilentlyContinue)
    foreach ($f in $jsFiles) {
      & node --check $f.FullName 2>&1 | Out-Null
      if ($LASTEXITCODE -eq 0) { Ok "parsea sin error de sintaxis: extension/$($f.Name)" }
      else { No "error de sintaxis en extension/$($f.Name) (node --check fallo)" }
    }
    if ($jsFiles.Count -eq 0) { No "no hay ningun .js en extension/" }

    # los modulos con self-test JS corren con el runner nativo. Se pasan los *.test.js
    # EXPLICITOS (no el directorio): con el dir, node tambien carga extension.js, que
    # requiere el modulo 'vscode' y solo existe dentro del editor.
    $testFiles = @(Get-ChildItem -LiteralPath $dir -Filter *.test.js -File -ErrorAction SilentlyContinue)
    if ($testFiles.Count -gt 0) {
      $eapPrev = $ErrorActionPreference; $ErrorActionPreference = 'Continue'
      & node --test @($testFiles | ForEach-Object { $_.FullName }) 2>&1 | Out-Null
      $testsOk = ($LASTEXITCODE -eq 0)
      $ErrorActionPreference = $eapPrev
      if ($testsOk) { Ok "self-tests JS verdes (node --test, $($testFiles.Count) archivo(s) *.test.js)" }
      else { No "node --test fallo (algun self-test JS en rojo)" }
    }
  }
  else {
    Write-Host "  [SKIP]  node --check (node no disponible en esta maquina)" -ForegroundColor DarkGray
  }
}

# LA DECISION COMO INVARIANTE (ADR 0044): la extension es Jidoka-only. La mecanica que
# consume (ligas + evaluador) SI se siembra; la extension NO. Si alguien la agrega al
# manifiesto de siembra sin cambiar la decision, esto lo caza.
$sembradoPath = Join-Path $raiz 'kit/.jidoka/instalar/manifiesto.json'
if (Test-Path -LiteralPath $sembradoPath) {
  $sembrado = Get-Content -LiteralPath $sembradoPath -Raw
  if ($sembrado -match '"extension/') {
    No "extension/ aparece en el manifiesto de siembra: la decision (ADR 0044) dice Jidoka-only. Si cambio, cambia el ADR primero"
  } else {
    Ok "extension/ NO se siembra a los hijos (Jidoka-only, ADR 0044)"
  }
}

Write-Host ""
if ($script:fail -gt 0) {
  Write-Host "== Extension INCOMPLETA: $($script:fail) fallo(s), $($script:pass) ok. ==" -ForegroundColor Red
  exit 1
}
Write-Host "== Extension sana: $($script:pass) verificaciones verdes. =="
exit 0
