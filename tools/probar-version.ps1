#Requires -Version 5
# probar-version.ps1 - self-test de consistencia de version (SSOT). Asegura que
# tools/version.txt (la fuente que el instalador siembra como sello en cada hijo)
# coincide con el tope de CHANGELOG.md. Un sello que MIENTE es peor que no tenerlo:
# el aviso de divergencia del hijo se apoya en este numero.
#   exit 0 = consistente; exit 1 = divergen (arreglalo antes de sembrar/publicar).
# Nota: es self-test del repo Jidoka (NO se siembra: el hijo versiona su app aparte).
# Archivo ASCII a proposito, PS 5.1.

$raiz = Split-Path -Parent $PSScriptRoot
$versionPath = Join-Path $raiz 'tools/version.txt'
$changelogPath = Join-Path $raiz 'CHANGELOG.md'
$script:fallos = 0

function Check($nombre, $cond, $detalle) {
  if ($cond) { Write-Host "  [PASA]  $nombre" -ForegroundColor Green }
  else { Write-Host "  [FALLA] $nombre ($detalle)" -ForegroundColor Red; $script:fallos++ }
}

Write-Host "== Consistencia de version (SSOT: tools/version.txt) =="

if (-not (Test-Path $versionPath)) { Write-Host "  [FALLA] no existe tools/version.txt" -ForegroundColor Red; exit 1 }
if (-not (Test-Path $changelogPath)) { Write-Host "  [FALLA] no existe CHANGELOG.md" -ForegroundColor Red; exit 1 }

$version = (Get-Content $versionPath -Raw).Trim()
Check 'version.txt no esta vacio' ($version -ne '') 'esta vacio'

# Tope del CHANGELOG: primer encabezado '## [x.y.z...]'
$topVersion = ''
foreach ($line in Get-Content $changelogPath) {
  if ($line -match '^\#\#\s*\[([^\]]+)\]') { $topVersion = $matches[1].Trim(); break }
}
Check 'CHANGELOG tiene un encabezado de version' ($topVersion -ne '') 'no encontre ## [x.y.z]'
Check "version.txt ($version) coincide con el tope de CHANGELOG ($topVersion)" ($version -eq $topVersion) 'divergen: actualiza tools/version.txt o el CHANGELOG'

# SSOT extendido: si existe package.json (el CLI npm), su version deriva de version.txt.
# Un paquete npm que declara otra version que el metodo miente sobre lo que instala.
$pkgPath = Join-Path $raiz 'package.json'
if (Test-Path $pkgPath) {
  $pkgVer = ''
  try { $pkgVer = (Get-Content $pkgPath -Raw | ConvertFrom-Json).version } catch {}
  Check "package.json ($pkgVer) coincide con version.txt ($version)" ($pkgVer -eq $version) 'el CLI npm quedaria desincronizado del SSOT'
}

Write-Host ""
if ($script:fallos -gt 0) {
  Write-Host "== $($script:fallos) inconsistencia(s) de version. El sello mentiria: no siembres ni publiques asi. ==" -ForegroundColor Red
  exit 1
}
Write-Host "== Version consistente: $version ==" -ForegroundColor Green
exit 0
