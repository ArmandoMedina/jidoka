#Requires -Version 5
# probar-override.ps1 - Self-test de override.ps1 (el escritor de las acciones firmadas del
# modo avanzado, R5). Molde: probar-parametrizar.ps1 -- fixture temporal en TEMP (jamas toca
# el repo real) que ademas hace `git init` + `git config --local user.name/user.email` propios
# del fixture (la firma se DERIVA de git, no se pasa por parametro). Contador Ok/No, exit por
# veredicto. Trae los casos de extension/contratos.test.js que tocan override + firma + los del
# plan R5. ASCII a proposito, PS 5.1.
#
# LECCION ANTI-PII (obligatoria): en los fixtures, NINGUN token <char-de-palabra>@X.punto.Y
# literal -- el detector de emails de la base (tools/anti-pii.ps1) casaria un correo. El email
# del fixture se construye por CONCATENACION en el codigo ('prueba@' + 'ejemplo.local') para que
# el escaneo estatico jamas vea un correo entero. Este archivo no escribe tokens crudos.
#   exit 0 = sano; exit 1 = bug.

$script:pass = 0; $script:fail = 0
function Ok($m) { Write-Host "  [OK]   $m" -ForegroundColor Green; $script:pass++ }
function No($m) { Write-Host "  [FALLA] $m" -ForegroundColor Red; $script:fail++ }

Write-Host "== Probar override.ps1 =="

$script = Join-Path $PSScriptRoot 'override.ps1'
if (-not (Test-Path $script)) { No "no existe tools/override.ps1"; Write-Host "== INCOMPLETO =="; exit 1 }

$sinBom = New-Object System.Text.UTF8Encoding($false)

# --- El email del fixture: por CONCATENACION (anti-PII: el escaneo estatico nunca ve el token entero). ---
$fixUser  = 'Firmante Prueba'
$fixEmail = 'prueba@' + 'ejemplo.local'

# --- helper: crea un fixture (repo git) con user.name/user.email locales del propio fixture. ---
# Aislamiento total de la config del OPERADOR: cada corrida corre con GIT_CONFIG_GLOBAL y
# GIT_CONFIG_SYSTEM apuntando a rutas inexistentes del fixture (git 2.x), asi la unica fuente
# de firma es la config LOCAL del fixture -- el caso "sin user.name" es determinista sin
# importar que el operador SI tenga user.name en su ~/.gitconfig.
function Nuevo-Fixture($conNombre = $true, $email = $fixEmail) {
  $fix = Join-Path ([System.IO.Path]::GetTempPath()) ("override-" + [System.Guid]::NewGuid().ToString('N'))
  New-Item -ItemType Directory -Path (Join-Path $fix 'tools') -Force | Out-Null
  & git -C $fix init 2>$null | Out-Null
  # user.name LOCAL solo si $conNombre; en el caso sin nombre NO se pone (y el aislamiento de
  # global/system garantiza que git config user.name salga vacio -> la firma no se inventa).
  if ($conNombre) { & git -C $fix config --local user.name $fixUser 2>$null | Out-Null }
  & git -C $fix config --local user.email $email 2>$null | Out-Null
  return $fix
}
function EscribeUtf8($fix, $rel, $texto) {
  $abs = Join-Path $fix $rel
  $dir = Split-Path -Parent $abs
  if ($dir -and -not (Test-Path -LiteralPath $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
  [System.IO.File]::WriteAllText($abs, $texto, $sinBom)
}
function LeeBytes($fix, $rel) { return [System.IO.File]::ReadAllBytes((Join-Path $fix $rel)) }
function LeeTexto($fix, $rel) { return [System.IO.File]::ReadAllText((Join-Path $fix $rel), $sinBom) }

# --- helper: corre override.ps1 -Json en PROCESO APARTE, captura stdout SIN BOM. ---
function CorreJson($fix, $argsExtra) {
  $psi = New-Object System.Diagnostics.ProcessStartInfo
  $psi.FileName = 'powershell'
  $psi.Arguments = "-NoProfile -ExecutionPolicy Bypass -File `"$script`" -Repo `"$fix`" $argsExtra -Json"
  $psi.RedirectStandardOutput = $true
  $psi.UseShellExecute = $false
  $psi.StandardOutputEncoding = $sinBom
  # Aisla la config git del operador: la firma solo puede venir de la config LOCAL del fixture.
  $noConfig = Join-Path $fix '.no-git-config'
  $psi.EnvironmentVariables['GIT_CONFIG_GLOBAL'] = $noConfig
  $psi.EnvironmentVariables['GIT_CONFIG_SYSTEM'] = $noConfig
  $p = [System.Diagnostics.Process]::Start($psi)
  $txt = $p.StandardOutput.ReadToEnd()
  $p.WaitForExit()
  return @{ txt = $txt; exit = $p.ExitCode; bytes = $sinBom.GetBytes($txt) }
}

# ============================ CASO 1: candado-on sobre contrato EXISTENTE ============================
# Un contrato previo con regimen + comandos -> candado-on debe poner candado:true + firma completa
# SIN pisar regimen ni comandos (merge que preserva campos previos).
$fix = Nuevo-Fixture
$previo = @'
{
  "contratos": [
    { "path": "docs/x.md", "regimen": "estatuto", "comandos": ["arranca", "planea"], "estado": "parametrizado" }
  ]
}
'@
EscribeUtf8 $fix 'tools/contratos.json' $previo
$r1 = CorreJson $fix '-Path docs/x.md -Accion candado-on -Motivo "lo sello para la demo"'
if ($r1.exit -eq 0) { Ok "candado-on: exit 0" } else { No "candado-on: esperaba exit 0, fue $($r1.exit)" }
$c1 = LeeTexto $fix 'tools/contratos.json' | ConvertFrom-Json
$x1 = @($c1.contratos | Where-Object { $_.path -eq 'docs/x.md' })
if ($x1.Count -eq 1) { Ok "candado-on: un solo contrato por path (no duplica)" } else { No "candado-on: se duplico el path ($($x1.Count))" }
if ($x1.Count -ge 1 -and $x1[0].candado -eq $true) { Ok "candado-on: candado=true" } else { No "candado-on: candado no quedo en true" }
if ($x1.Count -ge 1 -and $x1[0].regimen -eq 'estatuto' -and @($x1[0].comandos).Count -eq 2) { Ok "candado-on: campos previos (regimen, comandos) INTACTOS (merge preserva)" } else { No "candado-on: el merge piso campos previos (regimen=$($x1[0].regimen), comandos=$(@($x1[0].comandos).Count))" }
$f1 = $x1[0].firma
if ($f1 -and $f1.quien -eq $fixUser -and $f1.motivo -and "$($f1.email)" -eq $fixEmail -and $f1.cuando -match '^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}Z$') {
  Ok "candado-on: firma completa {quien,email,cuando(ISO UTC),motivo} derivada de git"
} else { No "candado-on: la firma no quedo completa (quien=$($f1.quien), email=$($f1.email), cuando=$($f1.cuando), motivo=$($f1.motivo))" }

# ============================ CASO 2: candado-off actualiza la firma ============================
$r2 = CorreJson $fix '-Path docs/x.md -Accion candado-off -Motivo "lo abro de nuevo"'
if ($r2.exit -eq 0) { Ok "candado-off: exit 0" } else { No "candado-off: esperaba exit 0, fue $($r2.exit)" }
$c2 = LeeTexto $fix 'tools/contratos.json' | ConvertFrom-Json
$x2 = @($c2.contratos | Where-Object { $_.path -eq 'docs/x.md' })
if ($x2.Count -eq 1 -and $x2[0].candado -eq $false) { Ok "candado-off: candado=false (gana el override nuevo)" } else { No "candado-off: candado no quedo en false (count=$($x2.Count))" }
if ($x2[0].firma -and $x2[0].firma.motivo -eq 'lo abro de nuevo') { Ok "candado-off: la firma se ACTUALIZO (nuevo motivo)" } else { No "candado-off: la firma no se actualizo (motivo=$($x2[0].firma.motivo))" }

# ============================ CASO 3: aceptar-desviacion sobre path SIN contrato previo ============================
# contratos.json no existe -> se crea con un contrato MINIMO {path, estado:aceptado, firma}.
$fix3 = Nuevo-Fixture
if (Test-Path (Join-Path $fix3 'tools/contratos.json')) { Remove-Item (Join-Path $fix3 'tools/contratos.json') -Force }
$r3 = CorreJson $fix3 '-Path docs/nuevo.md -Accion aceptar-desviacion -Motivo "asumo la desviacion"'
if ($r3.exit -eq 0) { Ok "aceptar-desviacion (sin previo): exit 0" } else { No "aceptar-desviacion (sin previo): esperaba exit 0, fue $($r3.exit)" }
if (Test-Path (Join-Path $fix3 'tools/contratos.json')) { Ok "aceptar-desviacion (sin previo): contratos.json se creo (no existia)" } else { No "aceptar-desviacion (sin previo): no se creo contratos.json" }
$c3 = LeeTexto $fix3 'tools/contratos.json' | ConvertFrom-Json
$x3 = @($c3.contratos | Where-Object { $_.path -eq 'docs/nuevo.md' })
if ($x3.Count -eq 1 -and $x3[0].estado -eq 'aceptado' -and $x3[0].firma.quien -eq $fixUser) { Ok "aceptar-desviacion (sin previo): contrato minimo {path,estado:aceptado,firma}" } else { No "aceptar-desviacion (sin previo): el contrato minimo no quedo (estado=$($x3[0].estado))" }
# sin BOM + newline final (caso 8).
$b3 = LeeBytes $fix3 'tools/contratos.json'
if ($b3[0] -ne 0xEF) { Ok "aceptar-desviacion: contratos.json SIN BOM (primer byte no es 0xEF)" } else { No "aceptar-desviacion: contratos.json tiene BOM" }
if ($b3[$b3.Length - 1] -eq 0x0A) { Ok "aceptar-desviacion: contratos.json termina en newline" } else { No "aceptar-desviacion: contratos.json sin newline final" }
# el -Json parsea y no tiene BOM (caso 8).
$j3 = $null; try { $j3 = $r3.txt | ConvertFrom-Json } catch { }
if ($j3 -and $j3.ok -eq $true -and $j3.contrato) { Ok "-Json: parsea a {ok:true,contrato} (caso 8)" } else { No "-Json: no parsea o ok!=true" }
if ($r3.bytes.Length -ge 1 -and $r3.bytes[0] -ne 0xEF) { Ok "-Json: stdout SIN BOM (caso 8)" } else { No "-Json: stdout con BOM" }

# ============================ CASO 4: reclasificar-estatuto / -libre, candado previo intacto ============================
$fix4 = Nuevo-Fixture
$previo4 = @'
{
  "contratos": [
    { "path": "docs/y.md", "regimen": "libre", "candado": true, "estado": "parametrizado" }
  ]
}
'@
EscribeUtf8 $fix4 'tools/contratos.json' $previo4
$r4a = CorreJson $fix4 '-Path docs/y.md -Accion reclasificar-estatuto -Motivo "sube a estatuto"'
$c4a = LeeTexto $fix4 'tools/contratos.json' | ConvertFrom-Json
$y4a = @($c4a.contratos | Where-Object { $_.path -eq 'docs/y.md' })
if ($r4a.exit -eq 0 -and $y4a[0].regimen -eq 'estatuto') { Ok "reclasificar-estatuto: regimen='estatuto'" } else { No "reclasificar-estatuto: regimen no cambio (exit=$($r4a.exit), regimen=$($y4a[0].regimen))" }
if ($y4a[0].candado -eq $true) { Ok "reclasificar-estatuto: candado PREVIO (true) intacto (merge preserva)" } else { No "reclasificar-estatuto: se perdio el candado previo (candado=$($y4a[0].candado))" }
$r4b = CorreJson $fix4 '-Path docs/y.md -Accion reclasificar-libre -Motivo "baja a libre"'
$c4b = LeeTexto $fix4 'tools/contratos.json' | ConvertFrom-Json
$y4b = @($c4b.contratos | Where-Object { $_.path -eq 'docs/y.md' })
if ($r4b.exit -eq 0 -and $y4b[0].regimen -eq 'libre') { Ok "reclasificar-libre: regimen='libre'" } else { No "reclasificar-libre: regimen no cambio (regimen=$($y4b[0].regimen))" }
if ($y4b[0].candado -eq $true) { Ok "reclasificar-libre: candado previo (true) sigue intacto" } else { No "reclasificar-libre: se perdio el candado previo (candado=$($y4b[0].candado))" }

# ============================ CASO 5: sin user.name -> {ok:false}, exit 1, contratos.json NO tocado ============================
# fixture con git config --local user.name "" (explicitamente vacio). La firma NO se inventa.
$fix5 = Nuevo-Fixture $false
$previo5 = @'
{
  "contratos": [
    { "path": "docs/z.md", "regimen": "libre", "estado": "parametrizado" }
  ]
}
'@
EscribeUtf8 $fix5 'tools/contratos.json' $previo5
$antes5 = LeeTexto $fix5 'tools/contratos.json'
$r5 = CorreJson $fix5 '-Path docs/z.md -Accion candado-on -Motivo "intento sin firma"'
$j5 = $null; try { $j5 = $r5.txt | ConvertFrom-Json } catch { }
if ($r5.exit -eq 1 -and $j5 -and $j5.ok -eq $false -and $j5.error -match 'user.name') { Ok "sin user.name: {ok:false, error} + exit 1 (la firma no se inventa, ADR 0047)" } else { No "sin user.name: esperaba exit 1 + {ok:false, error user.name} (exit=$($r5.exit), ok=$($j5.ok), error=$($j5.error))" }
$despues5 = LeeTexto $fix5 'tools/contratos.json'
if ($antes5 -eq $despues5) { Ok "sin user.name: contratos.json NO fue tocado (no escribe a medias)" } else { No "sin user.name: contratos.json cambio pese al error" }

# ============================ CASO 6: motivo vacio -> error, exit 1 ============================
$fix6 = Nuevo-Fixture
$r6 = CorreJson $fix6 '-Path docs/x.md -Accion candado-on -Motivo ""'
$j6 = $null; try { $j6 = $r6.txt | ConvertFrom-Json } catch { }
if ($r6.exit -eq 1 -and $j6 -and $j6.ok -eq $false) { Ok "motivo vacio: {ok:false} + exit 1 (sin motivo no hay reclasificacion)" } else { No "motivo vacio: esperaba exit 1 + {ok:false} (exit=$($r6.exit), ok=$($j6.ok))" }

# ============================ CASO 7: accion invalida -> error, exit 1 ============================
$fix7 = Nuevo-Fixture
$r7 = CorreJson $fix7 '-Path docs/x.md -Accion borrar-todo -Motivo "hago cualquier cosa"'
$j7 = $null; try { $j7 = $r7.txt | ConvertFrom-Json } catch { }
if ($r7.exit -eq 1 -and $j7 -and $j7.ok -eq $false -and $j7.error -match 'accion') { Ok "accion invalida: {ok:false, error} + exit 1" } else { No "accion invalida: esperaba exit 1 + {ok:false, error accion} (exit=$($r7.exit), error=$($j7.error))" }
# path inseguro (traversal) -> exit 1 tambien.
$r7b = CorreJson $fix7 '-Path ../fuera.md -Accion candado-on -Motivo "traversal"'
if ($r7b.exit -eq 1) { Ok "path inseguro (..): exit 1 (guarda anti-traversal)" } else { No "path inseguro: esperaba exit 1, fue $($r7b.exit)" }

# ============================ CASO 8: array de 1 elemento sale como ARRAY ============================
# contratos.json fresco con UN solo override -> el JSON leido trae 'contratos' como ARRAY.
$fix8 = Nuevo-Fixture
& powershell -NoProfile -ExecutionPolicy Bypass -File $script -Repo $fix8 -Path docs/solo.md -Accion candado-on -Motivo 'un solo contrato' | Out-Null
$c8txt = [System.IO.File]::ReadAllText((Join-Path $fix8 'tools/contratos.json'), $sinBom)
$c8 = $c8txt | ConvertFrom-Json
if ($c8.contratos -is [System.Array] -and $c8.contratos.Count -eq 1) { Ok "array de 1: 'contratos' es ARRAY con 1 elemento (el @() protegio el colapso PS 5.1)" } else { No "array de 1: 'contratos' NO es array (colapso PS 5.1)" }
$b8 = [System.IO.File]::ReadAllBytes((Join-Path $fix8 'tools/contratos.json'))
if ($b8[0] -ne 0xEF -and $b8[$b8.Length - 1] -eq 0x0A) { Ok "array de 1: SIN BOM + termina en newline" } else { No "array de 1: BOM o sin newline final" }

# --- limpieza: JAMAS dejar rastro en el repo real (todo fue en TEMP). ---
foreach ($f in @($fix, $fix3, $fix4, $fix5, $fix6, $fix7, $fix8)) {
  Remove-Item -LiteralPath $f -Recurse -Force -ErrorAction SilentlyContinue
}

Write-Host ""
if ($script:fail -gt 0) {
  Write-Host "== override INCOMPLETO: $($script:fail) fallo(s), $($script:pass) ok. ==" -ForegroundColor Red
  exit 1
}
Write-Host "== override sano: $($script:pass) verificaciones verdes. ==" -ForegroundColor Green
exit 0
