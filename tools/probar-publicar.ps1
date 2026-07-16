#Requires -Version 5
# probar-publicar.ps1 - prueba de vida de publicar.ps1 (el release derivado del SSOT).
# Corre publicar -DryRun y verifica: deriva la version del SSOT (tools/version.txt),
# extrae las notas del CHANGELOG, y NO crea ningun tag (dry-run sin efectos). Quien
# valida tambien se valida. Jidoka-only (como publicar.ps1). ASCII a proposito, PS 5.1.
#   exit 0 = sano; exit 1 = bug.

$raiz = Split-Path -Parent $PSScriptRoot
$script:fallos = 0; $script:casos = 0
function Check($n, $c, $d) {
  $script:casos++
  if ($c) { Write-Host "  [PASA]  $n" -ForegroundColor Green }
  else { Write-Host "  [FALLA] $n ($d)" -ForegroundColor Red; $script:fallos++ }
}

Write-Host "== Prueba de vida de publicar.ps1 (release derivado del SSOT) =="

$version = (Get-Content (Join-Path $raiz 'tools/version.txt') -Raw).Trim()
$tagsAntes = @(git -C $raiz tag -l)
$out = (& powershell -NoProfile -ExecutionPolicy Bypass -File (Join-Path $PSScriptRoot 'publicar.ps1') -DryRun 2>&1 | Out-String)
$code = $LASTEXITCODE
$tagsDespues = @(git -C $raiz tag -l)

Check 'dry-run: exit 0' ($code -eq 0) "exit $code"
Check "dry-run: deriva el tag del SSOT (v$version)" ($out -match ('Publicar v' + [regex]::Escape($version))) "no derivo v$version de: $out"
Check 'dry-run: anuncia DRY RUN (no publica)' ($out -match 'DRY RUN') 'no dijo DRY RUN'
Check 'dry-run: NO crea ningun tag (sin efectos)' ($tagsAntes.Count -eq $tagsDespues.Count) "creo un tag: antes $($tagsAntes.Count), despues $($tagsDespues.Count)"
# El titulo del release no debe llevar comillas dobles: PS 5.1 rompe el paso de un arg
# con '"' a gh (bug cazado al cortar v1.6.0). Las notas si las conservan (van por archivo).
$lineaTitulo = @($out -split "`r?`n" | Where-Object { $_ -match 'titulo:' }) -join ' '
Check 'dry-run: el titulo derivado no lleva comillas dobles (no rompe gh en PS 5.1)' (-not ($lineaTitulo -match '"')) "el titulo tiene comillas: $lineaTitulo"

# El preflight debe incluir TODOS los self-tests probar-*.ps1 del motor (hueco cazado en
# v1.12.0: probar-sembrar existia pero el release se cortaba sin correrlo). Se excluye
# probar-publicar: es este meta-test (quien valida al publicador no corre dentro de el).
$publicarSrc = Get-Content (Join-Path $PSScriptRoot 'publicar.ps1') -Raw
$selfTests = Get-ChildItem (Join-Path $PSScriptRoot 'probar-*.ps1') |
  Where-Object { $_.Name -ne 'probar-publicar.ps1' } |
  ForEach-Object { $_.BaseName }
$fuera = @($selfTests | Where-Object { $publicarSrc -notmatch ("'" + [regex]::Escape($_) + "'") })
Check 'preflight: incluye todos los self-tests probar-*.ps1 del motor' ($fuera.Count -eq 0) "fuera del preflight: $($fuera -join ', ')"

# El preflight debe FALLAR CERRADO si el archivo de un test NO existe en disco (issue #78,
# gemelo del caso anterior: estar en la lista no basta si el archivo puede no estar en el
# disco). Sin la guarda, CommandNotFoundException (no-terminante) se traga con *> $null y
# $LASTEXITCODE conserva el 0 del test anterior -> [OK] de un test que jamas corrio.
# Cazado en vivo cortando v1.14.0 con probar-instalador en cuarentena de AV.
Check 'preflight: guarda Test-Path antes de correr cada test (un test ausente muere, no da [OK] mudo)' `
  ($publicarSrc -match 'Test-Path\s+\$tPath') 'publicar.ps1 no tiene la guarda Test-Path del preflight (issue #78)'

Write-Host ""
if ($script:fallos -gt 0) {
  Write-Host "== $($script:fallos) de $($script:casos) fallidos. publicar.ps1 tiene un bug. ==" -ForegroundColor Red
  exit 1
}
Write-Host "== publicar.ps1 sano: los $($script:casos) casos se comportan como se espera. ==" -ForegroundColor Green
exit 0
