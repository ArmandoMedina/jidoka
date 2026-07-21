#Requires -Version 5
# anti-pii.ps1 - gate anti-fuga de PII de entorno en docs rastreados de un repo
# publico. Detecta FORMAS de dato personal, nunca instancias hardcodeadas: un
# gate que contiene la PII que busca la re-publica. Dos clases:
#   1) email con dominio real (tolera dominios sinteticos .local/.test/example y
#      el noreply de GitHub, que existe justo para NO exponer el correo real).
#   2) ruta de perfil de usuario con segmento nombrado (C:\Users\<x>, /home/<x>,
#      /Users/<x>) que no sea un placeholder (x, usuario, ruta...).
# Complementa (no reemplaza) un cinturon local: tools/anti-pii.denylist.txt
# (gitignoreado, NUNCA committeado) con cadenas literales del entorno del
# operador; si existe, tambien se busca. Modelo de amenaza: el ACCIDENTE (dato
# que se cuela sin querer), no un adversario con push -- por eso las allowlists
# son evadibles a proposito y no se persigue al que quiere colar algo.
#   BLOQUEA (exit 1) si encuentra una fuga; FALLA CERRADO (exit 2) si no puede
#   listar los archivos (un gate que no puede medir no aprueba a ciegas); exit 0
#   si limpio.
# disparo sin-pii-en-el-repo. Cableado: andon.yml (CI, el muro) y .githooks/pre-push (local).
#
# Uso:  ./tools/anti-pii.ps1                       (escanea todos los archivos rastreados)
#       ./tools/anti-pii.ps1 -Cambiados a.md,b.md  (prueba: escanea solo esos, relativos a -Repo)
#       ./tools/anti-pii.ps1 -Repo <ruta>          (prueba/CI: raiz del repo a escanear)
#       ./tools/anti-pii.ps1 -Denylist <ruta>      (prueba: denylist alterna)
# Nota: archivo ASCII a proposito (sin acentos) para no depender del BOM en PS 5.1.

param(
  [string[]]$Cambiados = @(),
  [string]$Repo = '',
  [string]$Denylist = ''
)

$script:block = 0

function Block($msg) { Write-Host "  [BLOQUEA] $msg" -ForegroundColor Red; $script:block++ }
function Ok($msg)    { Write-Host "  [OK] $msg"      -ForegroundColor Green }
function Fail($msg) {
  Write-Host "  [ERROR] $msg" -ForegroundColor Red
  Write-Host ""
  Write-Host "== Gate sin veredicto: FALLA CERRADO (exit 2). Un muro que ante fallo interno se abre no es muro. ==" -ForegroundColor Red
  exit 2
}

if ($Repo) { $root = $Repo } else { $root = Split-Path -Parent $PSScriptRoot }
if (-not (Test-Path -LiteralPath $root)) { Fail "no encuentro la raiz del repo ($root)" }

# --- Allowlists: FORMAS genericas, sin PII (no revelan nada del operador) ---
$dominiosOk = @('jidoka.local','example.com','example.org','example.net')
$sufijosOk  = @('.local','.test','.example','.invalid','noreply.github.com')
$segsOk     = @('x','usuario','user','tu-usuario','nombre','ruta','you','username','tu','yo','miusuario','tuusuario')
# La propia maquinaria del gate contiene patrones por naturaleza: se excluye.
$excluidos  = @('tools/anti-pii.ps1','tools/probar-anti-pii.ps1','tools/anti-pii.denylist.example.txt')
$extsOk     = @('.md','.json','.yml','.yaml','.txt','.ps1')

$reEmail   = '[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}'
# La captura del segmento para en caracteres de palabra: evita tragar la
# puntuacion de cierre (backtick, comillas, parentesis) de docs que citan una ruta.
$rePathWin = '[A-Za-z]:\\Users\\([A-Za-z0-9._-]+)'
$rePathNix = '/(?:home|Users)/([A-Za-z0-9._-]+)'

# --- Lista de archivos a escanear ---
if ($Cambiados.Count -gt 0) {
  $files = $Cambiados
} else {
  Push-Location $root
  $tracked = @(& git ls-files 2>$null)
  $rc = $LASTEXITCODE
  Pop-Location
  if ($rc -ne 0) { Fail "git ls-files fallo en $root (no puedo medir el arbol rastreado)" }
  $files = $tracked
}

Write-Host "== Anti-PII: escaneo de fuga de dato de entorno en docs rastreados =="

# --- Denylist local (cinturon; ausente = solo corre el detector estructural) ---
$denyPath = $Denylist
if (-not $denyPath) { $denyPath = Join-Path $root 'tools/anti-pii.denylist.txt' }
$denyStrings = @()
if (Test-Path -LiteralPath $denyPath) {
  $denyStrings = @(Get-Content -LiteralPath $denyPath | ForEach-Object { $_.Trim() } | Where-Object { $_ -and -not $_.StartsWith('#') })
}

function Test-DominioOk($dom) {
  $d = $dom.ToLower()
  if ($dominiosOk -contains $d) { return $true }
  foreach ($s in $sufijosOk) { if ($d.EndsWith($s)) { return $true } }
  return $false
}

$escaneados = 0
foreach ($f in $files) {
  $rel = ($f -replace '\\','/')
  if ($excluidos -contains $rel) { continue }
  $ext = [System.IO.Path]::GetExtension($rel).ToLower()
  if ($extsOk -notcontains $ext) { continue }
  $abs = Join-Path $root $rel
  if (-not (Test-Path -LiteralPath $abs)) { continue }
  $escaneados++
  $n = 0
  foreach ($line in (Get-Content -LiteralPath $abs)) {
    $n++
    foreach ($m in [regex]::Matches($line, $reEmail)) {
      $email = $m.Value
      $dom = $email.Substring($email.IndexOf('@') + 1)
      if (-not (Test-DominioOk $dom)) { Block "$rel`:$n email con dominio real: $email" }
    }
    foreach ($m in [regex]::Matches($line, $rePathWin)) {
      if ($segsOk -notcontains $m.Groups[1].Value.ToLower()) { Block "$rel`:$n ruta de perfil de usuario: $($m.Value)" }
    }
    foreach ($m in [regex]::Matches($line, $rePathNix)) {
      if ($segsOk -notcontains $m.Groups[1].Value.ToLower()) { Block "$rel`:$n ruta de perfil de usuario: $($m.Value)" }
    }
    foreach ($s in $denyStrings) {
      if ($line.Contains($s)) { Block "$rel`:$n coincide con la denylist local (cadena reservada del entorno)" }
    }
  }
}

Write-Host ""
if ($script:block -gt 0) {
  Write-Host "== $($script:block) fuga(s) de dato de entorno en $escaneados archivo(s) rastreado(s). NO se publica. Corrige, o si es falso positivo ajusta la allowlist en tools/anti-pii.ps1. ==" -ForegroundColor Red
  exit 1
}
Ok "sin fugas de dato de entorno en $escaneados archivo(s) rastreado(s)."
exit 0
