#Requires -Version 5
# probar-ritual.ps1 - Self-test de estado-ritual.ps1 (el estatuto del ritual: los @ de
# fabrica). Molde: probar-docs.ps1 -- Parte A monta un fixture temporal y corre el script en
# proceso aparte comparando salida+exit; Parte B corre contra el repo real. ASCII, PS 5.1.

$raiz = Split-Path -Parent $PSScriptRoot
$script:pass = 0; $script:fail = 0
function Ok($m) { Write-Host "  [OK]   $m" -ForegroundColor Green; $script:pass++ }
function No($m) { Write-Host "  [FALLA] $m" -ForegroundColor Red; $script:fail++ }

Write-Host "== Probar estado-ritual.ps1 =="

$detector = Join-Path $PSScriptRoot 'estado-ritual.ps1'
if (-not (Test-Path $detector)) { No "no existe tools/estado-ritual.ps1"; Write-Host "== INCOMPLETO =="; exit 1 }

# ------------------------------------------------------------------ Parte A (fixture)
$fix = Join-Path ([System.IO.Path]::GetTempPath()) ("ritual-" + [System.Guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path (Join-Path $fix 'tools') -Force | Out-Null
New-Item -ItemType Directory -Path (Join-Path $fix 'cmd') -Force | Out-Null
Copy-Item $detector (Join-Path $fix 'tools/estado-ritual.ps1')

$ledger = @'
{ "comandos": [
  { "comando": "cmd/conforme.md", "arrobas_requeridas": ["A.md", "B.md"], "estricto": false },
  { "comando": "cmd/falta.md",    "arrobas_requeridas": ["A.md", "B.md"], "estricto": false },
  { "comando": "cmd/extra.md",    "arrobas_requeridas": ["A.md"],         "estricto": false },
  { "comando": "cmd/backtick.md", "arrobas_requeridas": ["A.md"],         "estricto": false },
  { "comando": "cmd/fence.md",    "arrobas_requeridas": ["A.md"],         "estricto": false },
  { "comando": "cmd/estricto.md", "arrobas_requeridas": ["A.md"],         "estricto": true }
] }
'@
Set-Content -LiteralPath (Join-Path $fix 'tools/ritual-gobernado.json') -Value $ledger -Encoding ASCII

$conformeDoc = @'
# c
@A.md
@B.md
'@
Set-Content -LiteralPath (Join-Path $fix 'cmd/conforme.md') -Value $conformeDoc -Encoding UTF8
$faltaDoc = @'
# f
@A.md
'@
Set-Content -LiteralPath (Join-Path $fix 'cmd/falta.md')    -Value $faltaDoc -Encoding UTF8
$extraDoc = @'
# e
@A.md
@Z.md
'@
Set-Content -LiteralPath (Join-Path $fix 'cmd/extra.md')    -Value $extraDoc -Encoding UTF8
Set-Content -LiteralPath (Join-Path $fix 'cmd/backtick.md') -Value "# b`n- **``@A.md``** el estado en vuelo" -Encoding UTF8
$estrictoDoc = @'
# es
@Q.md
'@
Set-Content -LiteralPath (Join-Path $fix 'cmd/estricto.md') -Value $estrictoDoc -Encoding UTF8
# fence.md: '@A.md' SOLO aparece dentro de un bloque de codigo cercado -> no cuenta -> DESVIADO.
$fenceDoc = @'
# fe

```
@A.md
```

sin @ real
'@
Set-Content -LiteralPath (Join-Path $fix 'cmd/fence.md') -Value $fenceDoc -Encoding UTF8

$scriptFix = Join-Path $fix 'tools/estado-ritual.ps1'
$out = (& powershell -NoProfile -File $scriptFix 2>&1 | Out-String)
$code = $LASTEXITCODE

if ($code -eq 0) { Ok "no-estricto: exit 0 (aviso, no muro)" } else { No "no-estricto: esperaba exit 0, fue $code" }
if ($out -match '\[CONFORME\]\s+cmd/conforme\.md') { Ok "conforme.md -> CONFORME (tiene @A.md y @B.md)" } else { No "conforme.md deberia ser CONFORME" }
if ($out -match 'cmd/falta\.md.*[Bb]\.md') { Ok "falta.md -> DESVIADO nombrando el @ faltante (B.md)" } else { No "falta.md deberia DESVIADO por B.md" }
if ($out -match '\[CONFORME\]\s+cmd/extra\.md') { Ok "extra.md -> CONFORME (un @ EXTRA es aditiva legal)" } else { No "extra.md deberia CONFORME (aditiva permitida)" }
if ($out -match '\[CONFORME\]\s+cmd/backtick\.md') { Ok "backtick.md -> CONFORME (un @ backtickeado en vinieta SI cuenta, como que-sigue.md)" } else { No "backtick.md deberia CONFORME (@ backtickeado cuenta)" }
if ($out -match 'cmd/fence\.md.*[Aa]\.md') { Ok "fence.md -> DESVIADO (un @ dentro de un fence NO cuenta)" } else { No "fence.md: un @ dentro de un fence no deberia contar (falso CONFORME)" }
if ($out -match 'cmd/estricto\.md.*[Aa]\.md') { Ok "estricto.md -> DESVIADO nombrando A.md" } else { No "estricto.md deberia DESVIADO por A.md" }

& powershell -NoProfile -File $scriptFix -Estricto 2>&1 | Out-Null
$codeE = $LASTEXITCODE
if ($codeE -eq 1) { Ok "-Estricto con un comando estricto desviado -> exit 1 (muro opt-in muerde)" } else { No "-Estricto: esperaba exit 1, fue $codeE" }

# el mismo fixture pero con estricto.md sano debe salir 0 aun en -Estricto:
$estrictoSanoDoc = @'
# es
@A.md
ahora si trae A
'@
Set-Content -LiteralPath (Join-Path $fix 'cmd/estricto.md') -Value $estrictoSanoDoc -Encoding UTF8
& powershell -NoProfile -File $scriptFix -Estricto 2>&1 | Out-Null
$codeE2 = $LASTEXITCODE
if ($codeE2 -eq 0) { Ok "-Estricto sin estrictos desviados -> exit 0 (no bloquea de mas)" } else { No "-Estricto sano: esperaba exit 0, fue $codeE2" }

Remove-Item -LiteralPath $fix -Recurse -Force -ErrorAction SilentlyContinue

# ------------------------------------------------------------------ Parte B (repo REAL)
$outReal = (& powershell -NoProfile -File $detector 2>&1 | Out-String)
$codeReal = $LASTEXITCODE
if ($codeReal -eq 0) { Ok "Parte B: el detector corre contra el ritual real (exit 0)" } else { No "Parte B: esperaba exit 0, fue $codeReal" }
if ($outReal -match '\[CONFORME\]\s+\.claude/commands/jidoka/arranca\.md') { Ok "Parte B: arranca.md CONFORME (tiene sus 4 @ de fabrica)" } else { No "Parte B: arranca.md deberia ser CONFORME contra el ledger real" }
# cubre TODOS los comandos de una: el ritual real no debe tener ningun desviado (si alguien borra
# un @ de fabrica de planea/que-sigue, este assert lo caza, no solo el de arranca).
if ($outReal -match '\|\s*0 desviado') { Ok "Parte B: el ritual real no tiene desviados (todos los @ de fabrica presentes)" } else { No "Parte B: el ritual real tiene un comando desviado -- perdio un @ de fabrica" }
# integridad del ledger real: cada @ requerido aparece HOY en su comando (contrato posible).
$L = Get-Content -LiteralPath (Join-Path $raiz 'tools/ritual-gobernado.json') -Raw | ConvertFrom-Json
$rotas = 0
foreach ($e in $L.comandos) {
  $cmdAbs = Join-Path $raiz $e.comando
  if (-not (Test-Path -LiteralPath $cmdAbs)) { No "ledger apunta a un comando ausente: $($e.comando)"; $rotas++; continue }
}
if ($rotas -eq 0) { Ok "Parte B: todos los comandos del ledger real existen en disco" } else { No "Parte B: $rotas comando(s) del ledger no existen" }

Write-Host ""
if ($script:fail -gt 0) {
  Write-Host "== Estatuto del ritual INCOMPLETO: $($script:fail) fallo(s), $($script:pass) ok. ==" -ForegroundColor Red
  exit 1
}
Write-Host "== Estatuto del ritual sano: $($script:pass) verificaciones verdes. ==" -ForegroundColor Green
exit 0
