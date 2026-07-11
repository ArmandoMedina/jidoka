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

Write-Host ""
if ($script:fallos -gt 0) {
  Write-Host "== $($script:fallos) de $($script:casos) fallidos. publicar.ps1 tiene un bug. ==" -ForegroundColor Red
  exit 1
}
Write-Host "== publicar.ps1 sano: los $($script:casos) casos se comportan como se espera. ==" -ForegroundColor Green
exit 0
