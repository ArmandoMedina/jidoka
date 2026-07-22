#Requires -Version 5
# probar-parametrizar.ps1 - Self-test de parametrizar.ps1 (el escritor unico de los ledgers).
# Molde: probar-bandeja.ps1 -- fixture temporal en TEMP (jamas toca el repo real), contador
# Ok/No, exit por veredicto. Trae los casos de extension/contratos.test.js + ritual.test.js
# mas los del plan R4. ASCII a proposito, PS 5.1.
#
# LECCION ANTI-PII (obligatoria): en los fixtures, NINGUNA secuencia <char-de-palabra>@X.con.punto
# -- el detector de emails de la base (tools/anti-pii.ps1) casaria un char-de-palabra pegado a
# un arroba-ruta-con-punto como correo. Cada
# token @X.md va en su propia linea o precedido de espacio/backtick. Este archivo mismo no
# escribe tokens crudos: los @ de fixture van dentro de here-strings con espacio/borde.
#   exit 0 = sano; exit 1 = bug.

$script:pass = 0; $script:fail = 0
function Ok($m) { Write-Host "  [OK]   $m" -ForegroundColor Green; $script:pass++ }
function No($m) { Write-Host "  [FALLA] $m" -ForegroundColor Red; $script:fail++ }

Write-Host "== Probar parametrizar.ps1 =="

$script = Join-Path $PSScriptRoot 'parametrizar.ps1'
if (-not (Test-Path $script)) { No "no existe tools/parametrizar.ps1"; Write-Host "== INCOMPLETO =="; exit 1 }

# --- Fixture temporal: una raiz con tools/ + la ley + los comandos del ritual. ---
$fix = Join-Path ([System.IO.Path]::GetTempPath()) ("parametrizar-" + [System.Guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path (Join-Path $fix 'tools') -Force | Out-Null
New-Item -ItemType Directory -Path (Join-Path $fix '.claude/commands/jidoka') -Force | Out-Null

$sinBom = New-Object System.Text.UTF8Encoding($false)
function EscribeUtf8($rel, $texto) {
  $abs = Join-Path $fix $rel
  $dir = Split-Path -Parent $abs
  if ($dir -and -not (Test-Path -LiteralPath $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
  [System.IO.File]::WriteAllText($abs, $texto, $sinBom)
}
function LeeBytes($rel) { return [System.IO.File]::ReadAllBytes((Join-Path $fix $rel)) }
function LeeTexto($rel) { return [System.IO.File]::ReadAllText((Join-Path $fix $rel), $sinBom) }

# ley minima: un area 'guias' con fuente. El area 'inexistente' NO se declara (caso 6b).
$ley = @'
[
  { "nombre": "guias", "desc": "guias del dominio", "fuente": ["docs/guias/*"], "doc_avisa": ["HANDOFF.md"], "rol": "escribano" }
]
'@
EscribeUtf8 'tools/blast-radius.json' $ley

# comando del ritual con el marcador y dos @ de fabrica (con borde: espacio antes del @).
# Nota anti-PII: cada token de fixture va precedido de un espacio para no formar <char>@X.md.
$MARCADOR = '<!-- jidoka:arrobas -->'
$cmdBase = @(
  '# arranca',
  '',
  ' @product/PRODUCT_BRIEF.md',
  ' @HANDOFF.md',
  $MARCADOR,
  '',
  '## sigue el ritual',
  'cuerpo intacto'
) -join "`n"
EscribeUtf8 '.claude/commands/jidoka/arranca.md' $cmdBase
EscribeUtf8 '.claude/commands/jidoka/planea.md' $cmdBase

# --- helper: corre parametrizar.ps1 -Json en PROCESO APARTE, captura stdout SIN BOM. ---
function CorreJson($argsExtra) {
  $psi = New-Object System.Diagnostics.ProcessStartInfo
  $psi.FileName = 'powershell'
  $psi.Arguments = "-NoProfile -ExecutionPolicy Bypass -File `"$script`" -Repo `"$fix`" $argsExtra -Json"
  $psi.RedirectStandardOutput = $true
  $psi.UseShellExecute = $false
  $psi.StandardOutputEncoding = $sinBom
  $p = [System.Diagnostics.Process]::Start($psi)
  $txt = $p.StandardOutput.ReadToEnd()
  $p.WaitForExit()
  return @{ txt = $txt; exit = $p.ExitCode; bytes = $sinBom.GetBytes($txt) }
}

# ============================ CASO 1: alta nueva ============================
# contratos.json no existe -> se crea con el contrato, estado parametrizado, sin BOM, newline final.
if (Test-Path (Join-Path $fix 'tools/contratos.json')) { Remove-Item (Join-Path $fix 'tools/contratos.json') -Force }
$r1 = CorreJson '-Path docs/guias/glosario.md -Tipo documento -Regimen libre'
if ($r1.exit -eq 0) { Ok "alta nueva: exit 0" } else { No "alta nueva: esperaba exit 0, fue $($r1.exit)" }
if (Test-Path (Join-Path $fix 'tools/contratos.json')) { Ok "alta nueva: contratos.json se creo (no existia)" } else { No "alta nueva: no se creo contratos.json" }
$c1 = $null; try { $c1 = LeeTexto 'tools/contratos.json' | ConvertFrom-Json } catch { }
if ($c1 -and @($c1.contratos).Count -eq 1 -and $c1.contratos[0].path -eq 'docs/guias/glosario.md' -and $c1.contratos[0].estado -eq 'parametrizado') {
  Ok "alta nueva: un contrato, path correcto, estado 'parametrizado'"
} else { No "alta nueva: el contrato no quedo como se esperaba" }
$b1 = LeeBytes 'tools/contratos.json'
if ($b1[0] -ne 0xEF) { Ok "alta nueva: contratos.json SIN BOM (primer byte no es 0xEF)" } else { No "alta nueva: contratos.json tiene BOM" }
if ($b1[$b1.Length - 1] -eq 0x0A) { Ok "alta nueva: contratos.json termina en newline (el contrato)" } else { No "alta nueva: contratos.json sin newline final" }
# el -Json parsea y no tiene BOM (caso 8).
$j1 = $null; try { $j1 = $r1.txt | ConvertFrom-Json } catch { }
if ($j1 -and $j1.ok -eq $true) { Ok "-Json: parsea a {ok:true} (caso 8)" } else { No "-Json: no parsea o ok!=true" }
if ($r1.bytes.Length -ge 1 -and $r1.bytes[0] -ne 0xEF) { Ok "-Json: stdout SIN BOM (caso 8)" } else { No "-Json: stdout con BOM" }

# ============================ CASO 2: upsert (merge por path) ============================
# mismo path dos veces con regimen distinto -> un solo contrato, el segundo gana, no duplica.
CorreJson '-Path docs/x.md -Regimen libre' | Out-Null
$r2 = CorreJson '-Path docs/x.md -Regimen estatuto'
$c2 = LeeTexto 'tools/contratos.json' | ConvertFrom-Json
$xs = @($c2.contratos | Where-Object { $_.path -eq 'docs/x.md' })
if ($xs.Count -eq 1) { Ok "upsert: un solo contrato por path (no duplica)" } else { No "upsert: se duplico el path docs/x.md ($($xs.Count) veces)" }
if ($xs.Count -ge 1 -and $xs[0].regimen -eq 'estatuto') { Ok "upsert: el segundo gana (regimen 'estatuto')" } else { No "upsert: el merge no dejo el regimen nuevo" }

# ============================ CASO 3: arroba idempotente ============================
# @ insertado bajo el marcador; segunda corrida NO duplica.
$r3a = CorreJson '-Path docs/guias/glosario.md -Comandos arranca'
$j3a = $r3a.txt | ConvertFrom-Json
$txt3 = LeeTexto '.claude/commands/jidoka/arranca.md'
$lineas3 = $txt3 -split "`r?`n"
$iM = ($lineas3 | ForEach-Object { $_ } | Select-String -SimpleMatch $MARCADOR | Select-Object -First 1)
$idxM = -1; for ($i = 0; $i -lt $lineas3.Count; $i++) { if ($lineas3[$i].Contains($MARCADOR)) { $idxM = $i; break } }
if ($idxM -ge 0 -and $lineas3[$idxM + 1] -eq ('@' + 'docs/guias/glosario.md')) { Ok "arroba: el @ va JUSTO bajo el marcador" } else { No "arroba: el @ no quedo bajo el marcador" }
if ($j3a.arrobas -eq 1) { Ok "arroba: primera corrida inserta 1" } else { No "arroba: esperaba arrobas=1, fue $($j3a.arrobas)" }
$r3b = CorreJson '-Path docs/guias/glosario.md -Comandos arranca'
$j3b = $r3b.txt | ConvertFrom-Json
$cuenta3 = ([regex]::Matches((LeeTexto '.claude/commands/jidoka/arranca.md'), [regex]::Escape('@' + 'docs/guias/glosario.md'))).Count
if ($j3b.arrobas -eq 0 -and $cuenta3 -eq 1) { Ok "arroba: segunda corrida NO duplica (idempotente por token)" } else { No "arroba: se duplico o arrobas!=0 (cuenta=$cuenta3, arrobas=$($j3b.arrobas))" }
# (a) el archivo del comando termina en newline (byte final == 0x0A).
$bytes3 = LeeBytes '.claude/commands/jidoka/arranca.md'
if ($bytes3.Length -ge 1 -and $bytes3[$bytes3.Length - 1] -eq 0x0A) { Ok "arroba: el .md del comando termina en newline (0x0A) tras Insertar-Arroba" } else { No "arroba: el .md del comando NO termina en newline tras Insertar-Arroba" }
# (b) las arrobas de fabrica del fixture siguen presentes: ' @product/PRODUCT_BRIEF.md' y ' @HANDOFF.md'.
$txt3b = LeeTexto '.claude/commands/jidoka/arranca.md'
$fab1 = $txt3b -match '(?m)(^| )@product/PRODUCT_BRIEF\.md'
$fab2 = $txt3b -match '(?m)(^| )@HANDOFF\.md'
if ($fab1 -and $fab2) { Ok "arroba: las arrobas de fabrica del fixture siguen presentes tras Insertar-Arroba" } else { No "arroba: alguna arroba de fabrica desaparecio (PRODUCT_BRIEF=$fab1, HANDOFF=$fab2)" }

# ============================ CASO 4: LA SUTILEZA (borde por token) ============================
# fixture con ' @docs/glosario.md' presente -> insertar 'docs/glo.md' SI inserta (el borde muerde).
$cmdSut = @('# t', $MARCADOR, ' @docs/glosario.md') -join "`n"
EscribeUtf8 '.claude/commands/jidoka/sutileza.md' $cmdSut
$r4 = CorreJson '-Path docs/glo.md -Comandos sutileza'
$j4 = $r4.txt | ConvertFrom-Json
if ($j4.arrobas -eq 1) { Ok "sutileza: 'docs/glo.md' SI se inserta pese a existir 'docs/glosario.md' (borde por token)" } else { No "sutileza: el prefijo se dio por presente (arrobas=$($j4.arrobas)) -- el borde NO mordio" }
# y NO reinserta 'docs/glosario.md' si ya esta (idempotencia del token largo).
$r4b = CorreJson '-Path docs/glosario.md -Comandos sutileza'
$j4b = $r4b.txt | ConvertFrom-Json
if ($j4b.arrobas -eq 0) { Ok "sutileza: 'docs/glosario.md' NO se reinserta (ya estaba, token exacto)" } else { No "sutileza: reinserto glosario.md (arrobas=$($j4b.arrobas))" }

# ============================ CASO 5: comando sin marcador -> aviso, contrato igual ============================
$cmdSinMarca = @('# sin marcador', ' @HANDOFF.md', 'cuerpo') -join "`n"
EscribeUtf8 '.claude/commands/jidoka/nomarca.md' $cmdSinMarca
$r5 = CorreJson '-Path docs/otro.md -Comandos nomarca'
$j5 = $r5.txt | ConvertFrom-Json
if ($j5.ok -eq $true -and $r5.exit -eq 0) { Ok "sin marcador: ok:true, exit 0 (el contrato quedo, sin exito falso)" } else { No "sin marcador: esperaba ok:true/exit 0 (fue ok=$($j5.ok), exit=$($r5.exit))" }
if (@($j5.avisos).Count -ge 1 -and ($j5.avisos -join ' ') -match 'nomarca') { Ok "sin marcador: aviso en el JSON (viaja al llamador)" } else { No "sin marcador: no hay aviso de nomarca" }
$c5 = LeeTexto 'tools/contratos.json' | ConvertFrom-Json
if (@($c5.contratos | Where-Object { $_.path -eq 'docs/otro.md' }).Count -eq 1) { Ok "sin marcador: el contrato de docs/otro.md se escribio igual (jamas silencio)" } else { No "sin marcador: no se escribio el contrato pese al aviso" }

# ============================ CASO 6: area existente vs inexistente ============================
# 6a) area existente 'guias' -> path agregado a la fuente, idempotente.
$r6a = CorreJson '-Path docs/guias/nuevo.md -Area guias'
$leyObj = LeeTexto 'tools/blast-radius.json' | ConvertFrom-Json
$guias = @($leyObj | Where-Object { $_.nombre -eq 'guias' })[0]
if (@($guias.fuente) -contains 'docs/guias/nuevo.md') { Ok "area existente: 'docs/guias/nuevo.md' agregado a la fuente de 'guias'" } else { No "area existente: no se agrego a la fuente" }
$r6aBis = CorreJson '-Path docs/guias/nuevo.md -Area guias'
$leyObj2 = LeeTexto 'tools/blast-radius.json' | ConvertFrom-Json
$guias2 = @($leyObj2 | Where-Object { $_.nombre -eq 'guias' })[0]
$cuentaFuente = @($guias2.fuente | Where-Object { $_ -eq 'docs/guias/nuevo.md' }).Count
if ($cuentaFuente -eq 1) { Ok "area existente: idempotente (no duplica en la fuente)" } else { No "area existente: se duplico en la fuente ($cuentaFuente)" }
# 6b) area inexistente -> AVISO, contrato escrito, la ley NO crea el area.
$r6b = CorreJson '-Path docs/z.md -Area inexistente'
$j6b = $r6b.txt | ConvertFrom-Json
if ($j6b.ok -eq $true -and (@($j6b.avisos) -join ' ') -match 'inexistente') { Ok "area inexistente: AVISO en el JSON, ok:true (no error duro)" } else { No "area inexistente: esperaba aviso + ok:true" }
$leyObj3 = LeeTexto 'tools/blast-radius.json' | ConvertFrom-Json
if (@($leyObj3 | Where-Object { $_.nombre -eq 'inexistente' }).Count -eq 0) { Ok "area inexistente: la ley NO creo el area a ciegas" } else { No "area inexistente: se creo el area (no debia)" }

# ============================ CASO 7: array de 1 elemento sale como array ============================
# contratos.json fresco con UN solo contrato -> el JSON leido trae 'contratos' como ARRAY.
$fix7 = Join-Path ([System.IO.Path]::GetTempPath()) ("param7-" + [System.Guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path (Join-Path $fix7 'tools') -Force | Out-Null
[System.IO.File]::WriteAllText((Join-Path $fix7 'tools/blast-radius.json'), $ley, $sinBom)
& powershell -NoProfile -ExecutionPolicy Bypass -File $script -Repo $fix7 -Path docs/solo.md -Regimen libre | Out-Null
$c7txt = [System.IO.File]::ReadAllText((Join-Path $fix7 'tools/contratos.json'), $sinBom)
$c7 = $c7txt | ConvertFrom-Json
if ($c7.contratos -is [System.Array] -and $c7.contratos.Count -eq 1) { Ok "array de 1: 'contratos' es ARRAY con 1 elemento (el @() protegio el colapso PS 5.1)" } else { No "array de 1: 'contratos' NO es array (colapso PS 5.1)" }
Remove-Item -LiteralPath $fix7 -Recurse -Force -ErrorAction SilentlyContinue

# ============================ CASO 8 (extra): validaciones de error duro ============================
# Path faltante, regimen invalido, fuerza invalida, ley ausente -> exit 1 + {ok:false,error}.
$rErrRegimen = CorreJson '-Path docs/e.md -Regimen inventado'
$jErr = $null; try { $jErr = $rErrRegimen.txt | ConvertFrom-Json } catch { }
if ($rErrRegimen.exit -eq 1 -and $jErr -and $jErr.ok -eq $false -and $jErr.error) { Ok "validacion: regimen invalido -> exit 1 + {ok:false,error}" } else { No "validacion: regimen invalido no dio exit 1/{ok:false}" }
$rErrFuerza = CorreJson '-Path docs/e.md -Regimen libre -Fuerza gritar'
if ($rErrFuerza.exit -eq 1) { Ok "validacion: fuerza invalida -> exit 1" } else { No "validacion: fuerza invalida no dio exit 1 (fue $($rErrFuerza.exit))" }
# ley ausente -> falla cerrado exit 1.
$fixSinLey = Join-Path ([System.IO.Path]::GetTempPath()) ("param-noley-" + [System.Guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path (Join-Path $fixSinLey 'tools') -Force | Out-Null
& powershell -NoProfile -ExecutionPolicy Bypass -File $script -Repo $fixSinLey -Path docs/a.md -Json | Out-Null
if ($LASTEXITCODE -eq 1) { Ok "sin ley: falla CERRADO (exit 1)" } else { No "sin ley: esperaba exit 1, fue $LASTEXITCODE" }
Remove-Item -LiteralPath $fixSinLey -Recurse -Force -ErrorAction SilentlyContinue

# --- limpieza: JAMAS dejar rastro en el repo real (todo fue en TEMP). ---
Remove-Item -LiteralPath $fix -Recurse -Force -ErrorAction SilentlyContinue

Write-Host ""
if ($script:fail -gt 0) {
  Write-Host "== parametrizar INCOMPLETO: $($script:fail) fallo(s), $($script:pass) ok. ==" -ForegroundColor Red
  exit 1
}
Write-Host "== parametrizar sano: $($script:pass) verificaciones verdes. ==" -ForegroundColor Green
exit 0
