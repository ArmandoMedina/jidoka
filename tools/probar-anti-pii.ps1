#Requires -Version 5
# probar-anti-pii.ps1 - prueba de vida del gate anti-PII (disparo
# prueba-de-vida-del-gate: un gate no se estrena sin correrlo contra escenarios
# de resultado conocido, incluido uno que DEBE bloquear). Ejercita las dos
# clases del detector (email real, ruta de usuario), los falsos positivos reales
# medidos en el repo (handle GitHub, placeholder x, dominio sintetico, noreply),
# la denylist local y la ruta que FALLA CERRADO. Quien valida tambien se valida.
# Las cadenas-trampa se ARMAN en tiempo de ejecucion (concatenadas) para que este
# archivo de prueba no contenga PII literal ni se dispare a si mismo.
#
# Uso:  ./tools/probar-anti-pii.ps1   (exit 0 = gate sano; exit 1 = el gate tiene un bug)
# Nota: archivo ASCII a proposito (sin acentos), PS 5.1.

$gate = Join-Path $PSScriptRoot 'anti-pii.ps1'
$script:fallos = 0
$script:casos = 0

function New-Tmp {
  $d = Join-Path $env:TEMP ("jidoka-antipii-" + [guid]::NewGuid().ToString('N').Substring(0,8))
  New-Item -ItemType Directory -Path $d -Force | Out-Null
  return $d
}
function Set-File($dir, $name, $content) {
  $p = Join-Path $dir $name
  $sub = Split-Path -Parent $p
  if (-not (Test-Path $sub)) { New-Item -ItemType Directory -Path $sub -Force | Out-Null }
  Set-Content -LiteralPath $p -Value $content -Encoding Ascii
}

# Corre el gate y verifica exit code (+ opcional: la salida contiene una marca).
function Caso($nombre, $exitEsperado, $gateArgs, $debeContener) {
  $script:casos++
  $out = (& $gate @gateArgs 6>&1 | Out-String)
  $code = $LASTEXITCODE
  $detalle = ''
  if ($code -ne $exitEsperado) { $detalle = "exit $code, esperaba $exitEsperado" }
  elseif ($debeContener -and -not $out.Contains($debeContener)) { $detalle = "la salida no contiene '$debeContener'" }
  if ($detalle) { Write-Host "  [FALLA] $nombre ($detalle)" -ForegroundColor Red; $script:fallos++ }
  else { Write-Host "  [PASA]  $nombre" -ForegroundColor Green }
}

Write-Host "== Prueba de vida del gate anti-PII (tools/anti-pii.ps1) =="

# Cadenas-trampa armadas en runtime (no aparecen literales en este archivo).
$emailReal = 'leak.person' + '@' + 'realcorp.com'
$emailNoreply = '49213394+algo' + '@' + 'users.noreply.github.com'
$pathWin   = 'C:' + '\Users\' + 'RealName' + '\proyecto\secreto'
$pathWinPh = 'C:' + '\Users\' + 'x' + '\.claude\config'
$pathGuia  = 'C:' + '\ruta\a\' + 'tu-repo'
$pathNix   = '/home/' + 'realdev' + '/repo'

$tmp = New-Tmp
try {
  # --- DEBE BLOQUEAR (ROJO sin gate) ---
  Set-File $tmp 'fuga-email.md' "contacto: $emailReal"
  Caso 'email con dominio real -> BLOQUEA' 1 @{ Repo = $tmp; Cambiados = @('fuga-email.md') } '[BLOQUEA]'

  Set-File $tmp 'fuga-win.md' "el repo esta en $pathWin"
  Caso 'ruta C:\Users\<nombre real> -> BLOQUEA' 1 @{ Repo = $tmp; Cambiados = @('fuga-win.md') } '[BLOQUEA]'

  Set-File $tmp 'fuga-nix.md' "clonar en $pathNix"
  Caso 'ruta /home/<nombre real> -> BLOQUEA' 1 @{ Repo = $tmp; Cambiados = @('fuga-nix.md') } '[BLOQUEA]'

  # --- DEBE PASAR (falsos positivos reales medidos) ---
  Set-File $tmp 'ok-handle.md' "reporta a [@ArmandoMedina](https://github.com/ArmandoMedina)"
  Caso 'handle GitHub (@usuario sin dominio) -> PASA' 0 @{ Repo = $tmp; Cambiados = @('ok-handle.md') }

  Set-File $tmp 'ok-placeholder.ps1' "`$p = '$pathWinPh'"
  Caso 'ruta C:\Users\x (placeholder) -> PASA' 0 @{ Repo = $tmp; Cambiados = @('ok-placeholder.ps1') }

  Set-File $tmp 'ok-guia.md' "clona en $pathGuia y entra"
  Caso 'ruta C:\ruta\a\tu-repo (placeholder de guia) -> PASA' 0 @{ Repo = $tmp; Cambiados = @('ok-guia.md') }

  Set-File $tmp 'ok-sintetico.ps1' "git config user.email 'smoke@jidoka.local'"
  Caso 'email de dominio sintetico (.local) -> PASA' 0 @{ Repo = $tmp; Cambiados = @('ok-sintetico.ps1') }

  Set-File $tmp 'ok-noreply.md' "autor: $emailNoreply"
  Caso 'email noreply de GitHub -> PASA' 0 @{ Repo = $tmp; Cambiados = @('ok-noreply.md') }

  # --- Denylist local (cinturon) ---
  $marca = 'ZZFAKE-SECRETO-' + '123'
  $deny = Join-Path $tmp 'deny.txt'
  Set-Content -LiteralPath $deny -Value "# fixture`n$marca" -Encoding Ascii
  Set-File $tmp 'fuga-deny.md' "un texto con $marca dentro"
  Caso 'denylist local: cadena reservada -> BLOQUEA' 1 @{ Repo = $tmp; Cambiados = @('fuga-deny.md'); Denylist = $deny } '[BLOQUEA]'

  # Sin denylist presente: el detector estructural corre igual y pasa si limpio.
  Set-File $tmp 'limpio.md' "documento sin nada sensible, solo texto normal"
  Caso 'sin denylist presente: estructural corre y PASA si limpio' 0 @{ Repo = $tmp; Cambiados = @('limpio.md') }
}
finally { Remove-Item $tmp -Recurse -Force -ErrorAction SilentlyContinue }

# --- FALLA CERRADO: -Repo a un dir que no es git, sin -Cambiados -> exit 2 ---
$noGit = New-Tmp
try {
  Caso 'sin poder listar el arbol (no-git) -> FALLA CERRADO (exit 2)' 2 @{ Repo = $noGit } 'FALLA CERRADO'
}
finally { Remove-Item $noGit -Recurse -Force -ErrorAction SilentlyContinue }

Write-Host ""
if ($script:fallos -gt 0) {
  Write-Host "== $($script:fallos) de $($script:casos) caso(s) fallidos. El gate anti-PII tiene un bug: no lo estrenes. ==" -ForegroundColor Red
  exit 1
}
Write-Host "== Gate anti-PII sano: los $($script:casos) casos se comportan como se espera. ==" -ForegroundColor Green
exit 0
