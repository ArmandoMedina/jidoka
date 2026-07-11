#Requires -Version 5
# publicar.ps1 - corta el release de Jidoka DERIVANDO todo del SSOT (tools/version.txt).
# Lee la version del SSOT, extrae su seccion del CHANGELOG (titulo + notas), corre la
# suite de self-tests (evidencia-no-palabra: no se publica un motor roto), y crea el
# tag + release de GitHub con esas notas. Quita el tipeo manual de version del ritual
# (drift): la version se escribe UNA vez en version.txt y todo lo demas deriva.
#   -DryRun   muestra que haria (version, titulo, notas, guardas) SIN crear nada. Testable.
# Jidoka-only (NO se siembra): los hijos versionan su app con su propio esquema.
# Nota: archivo ASCII a proposito, PS 5.1.

param([switch]$DryRun)

$ErrorActionPreference = 'Stop'
$raiz = Split-Path -Parent $PSScriptRoot
function Die($m) { Write-Host "[ERROR] $m" -ForegroundColor Red; exit 1 }

# 1. La version viene del SSOT.
$versionPath = Join-Path $raiz 'tools/version.txt'
if (-not (Test-Path $versionPath)) { Die "no encuentro tools/version.txt (el SSOT)" }
$version = (Get-Content $versionPath -Raw).Trim()
if (-not $version) { Die "version.txt esta vacio" }
$tag = "v$version"

# 2. Extraer la seccion del CHANGELOG de esta version: desde '## [version]' hasta el
#    siguiente '## ['. El primer '### ...' de la seccion es el titulo descriptivo.
$changelogPath = Join-Path $raiz 'CHANGELOG.md'
if (-not (Test-Path $changelogPath)) { Die "no encuentro CHANGELOG.md" }
# -Encoding UTF8: el CHANGELOG trae acentos/flechas; sin esto PS 5.1 los lee como
# mojibake y las notas del release saldrian corruptas.
$dentro = $false; $descTitulo = ''; $notas = @()
foreach ($ln in (Get-Content -LiteralPath $changelogPath -Encoding UTF8)) {
  if ($ln -match '^\#\#\s*\[([^\]]+)\]') {
    if ($dentro) { break }                                  # empieza el siguiente release
    if ($matches[1].Trim() -eq $version) { $dentro = $true; continue }
  }
  if ($dentro) {
    if (-not $descTitulo -and $ln -match '^\#\#\#\s+(.*\S)') { $descTitulo = $matches[1].Trim() }
    $notas += $ln
  }
}
if (-not $dentro) { Die "no hay seccion [$version] en el CHANGELOG (el tope debe ser esta version; corre probar-version.ps1)" }
$notasTxt = ($notas -join "`n").Trim()
$tituloRel = if ($descTitulo) { "$tag - $descTitulo" } else { $tag }

# 3. Estado del repo (guardas).
$rama = (git -C $raiz rev-parse --abbrev-ref HEAD 2>$null)
if ($rama) { $rama = $rama.Trim() }
$limpio = [string]::IsNullOrEmpty((git -C $raiz status --porcelain 2>$null | Out-String).Trim())
$tagExiste = [bool]((git -C $raiz tag -l $tag 2>$null | Out-String).Trim())

Write-Host "== Publicar $tag  (derivado del SSOT tools/version.txt) =="
Write-Host "  titulo: $tituloRel"
Write-Host "  rama: $rama | arbol limpio: $limpio | tag $tag ya existe: $tagExiste"

if ($DryRun) {
  Write-Host "-- DRY RUN: no se crea nada. Notas derivadas del CHANGELOG:" -ForegroundColor Cyan
  Write-Host $notasTxt
  exit 0
}

if ($rama -ne 'main') { Die "no estas en main (rama: $rama): el release se corta desde main." }
if (-not $limpio)     { Die "el arbol no esta limpio: commitea o descarta antes de publicar." }
if ($tagExiste)       { Die "el tag $tag ya existe (sube la version en tools/version.txt + CHANGELOG)." }

# 4. La suite DEBE pasar antes de publicar (prueba de vida; no se estrena un motor roto).
Write-Host "== Suite de self-tests (evidencia-no-palabra antes de publicar) =="
foreach ($t in @('probar-version','probar-gate','probar-hooks','probar-auditor','probar-disparos','probar-instalador')) {
  & (Join-Path $PSScriptRoot "$t.ps1") *> $null
  if ($LASTEXITCODE -ne 0) { Die "$t.ps1 fallo (exit $LASTEXITCODE): no se publica." }
  Write-Host "  [OK] $t" -ForegroundColor Green
}
& (Join-Path $PSScriptRoot 'auditar.ps1') *> $null
if ($LASTEXITCODE -ne 0) { Die "auditar.ps1 fallo: no se publica." }
Write-Host "  [OK] auditar" -ForegroundColor Green

# 5. Crear el release (crea el tag en main). Notas = la seccion del CHANGELOG.
$notasFile = Join-Path $env:TEMP ("jidoka-notas-$version.md")
[System.IO.File]::WriteAllText($notasFile, $notasTxt, (New-Object System.Text.UTF8Encoding($false)))
try {
  gh release create $tag --repo ArmandoMedina/jidoka --target main --title $tituloRel --notes-file $notasFile
  if ($LASTEXITCODE -ne 0) { Die "gh release create fallo (exit $LASTEXITCODE)." }
}
finally { Remove-Item $notasFile -ErrorAction SilentlyContinue }
Write-Host "== Release $tag publicado; notas derivadas del CHANGELOG. ==" -ForegroundColor Green
exit 0
