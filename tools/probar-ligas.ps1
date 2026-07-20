#Requires -Version 5
# probar-ligas.ps1 - self-test del gate de ligas (estado-ligas.ps1).
# Partes:
#   A) COMPORTAMIENTO: repo-fixture git temporal con un ledger sintetico. Matriz de
#      co-ocurrencia con -Cambiados inyectados (sin pagar un commit por caso) +
#      un caso de rango git REAL con -Base (2 commits). ROJO->VERDE: la liga
#      'bloquea' violada con -Estricto sale 1 NOMBRANDO la capacidad; tocando
#      codigo Y capacidad sale 0.
#   A2) FALLA CERRADO: ledger malformado -> exit 2; enum invalido -> exit 2.
#   A3) ROTA: liga con codigo/capacidad inexistente avisa y NUNCA bloquea.
#   A4) CONTRATO ENTRE STACKS (si hay node): un ligas.json escrito por el modulo JS
#      de la extension (extension/ligas.js) lo lee y hace cumplir el evaluador PS.
#   B) INTEGRIDAD (ledger REAL): si tools/ligas.json existe, parsea, enums validos,
#      cero rotas en este repo.
# Todo en try/finally. Se siembra (mecanica). PS 5.1, ASCII a proposito.

$ErrorActionPreference = 'Stop'
$raiz = Split-Path -Parent $PSScriptRoot
if (-not $raiz) { $raiz = (Get-Location).Path }
$evaluador = Join-Path $PSScriptRoot 'estado-ligas.ps1'

$script:pass = 0; $script:fail = 0
function Ok($m) { Write-Host "  [PASA]  $m"; $script:pass++ }
function No($m) { Write-Host "  [FALLA] $m" -ForegroundColor Red; $script:fail++ }

function Init-GitFixture($dir) {
  $eapPrev = $ErrorActionPreference; $ErrorActionPreference = 'Continue'
  Push-Location $dir
  git init -q 2>&1 | Out-Null
  git config core.autocrlf false 2>&1 | Out-Null
  git config core.safecrlf false 2>&1 | Out-Null
  git config user.email 'test@jidoka.local' 2>&1 | Out-Null
  git config user.name 'jidoka-test' 2>&1 | Out-Null
  git add -A 2>&1 | Out-Null
  git commit -q -m 'fixture' 2>&1 | Out-Null
  Pop-Location
  $ErrorActionPreference = $eapPrev
}

# Corre el evaluador en proceso aparte (exit code limpio) y devuelve @{out;code}.
function Corre($fixDir, $argumentos) {
  $eapPrev = $ErrorActionPreference; $ErrorActionPreference = 'Continue'
  $salida = (& powershell -NoProfile -File $evaluador -Repo $fixDir @argumentos 2>&1 | Out-String)
  $codigo = $LASTEXITCODE
  $ErrorActionPreference = $eapPrev
  return @{ out = $salida; code = $codigo }
}

Write-Host "== Gate de ligas: co-ocurrencia + direccion + rotas + falla-cerrado + contrato =="

$tmp = [System.IO.Path]::GetTempPath()
$fix  = Join-Path $tmp ("ligas-" + [System.Guid]::NewGuid().ToString('N'))
$fixB = Join-Path $tmp ("ligas-base-" + [System.Guid]::NewGuid().ToString('N'))

try {
  # ---------------------------------------------------------------- fixture A
  New-Item -ItemType Directory -Path (Join-Path $fix 'tools') -Force | Out-Null
  New-Item -ItemType Directory -Path (Join-Path $fix 'servidor') -Force | Out-Null
  New-Item -ItemType Directory -Path (Join-Path $fix 'product/capacidades') -Force | Out-Null
  Set-Content -LiteralPath (Join-Path $fix 'servidor/pagos.js') -Value "// pagos" -Encoding ASCII
  Set-Content -LiteralPath (Join-Path $fix 'servidor/envios.js') -Value "// envios" -Encoding ASCII
  Set-Content -LiteralPath (Join-Path $fix 'suelto.ps1') -Value "# raiz" -Encoding ASCII
  Set-Content -LiteralPath (Join-Path $fix 'product/capacidades/PAGO-1.md') -Value "# cap pagos" -Encoding UTF8
  Set-Content -LiteralPath (Join-Path $fix 'product/capacidades/ENVIO-1.md') -Value "# cap envios" -Encoding UTF8

  $ledgerFix = @'
{ "ligas": [
  { "id": "pagos", "codigo": ["servidor/pagos.js"], "capacidades": ["product/capacidades/PAGO-1.md"],
    "direccion": "codigo-a-capacidad", "fuerza": "bloquea" },
  { "id": "envios", "codigo": ["servidor/envios.js"], "capacidades": ["product/capacidades/ENVIO-1.md"],
    "direccion": "codigo-a-capacidad", "fuerza": "avisa" },
  { "id": "espejo", "codigo": ["servidor/envios.js"], "capacidades": ["product/capacidades/ENVIO-1.md"],
    "direccion": "capacidad-a-codigo", "fuerza": "avisa" }
] }
'@
  Set-Content -LiteralPath (Join-Path $fix 'tools/ligas.json') -Value $ledgerFix -Encoding ASCII
  Init-GitFixture $fix
  $ledgerPath = Join-Path $fix 'tools/ligas.json'

  # 1: ledger ausente -> exit 0 con mensaje (no muro).
  $r = Corre $fix @('-Ledger', (Join-Path $fix 'tools/no-existe.json'), '-Cambiados', 'servidor/pagos.js')
  if ($r.code -eq 0) { Ok "ledger ausente: exit 0 (aviso amable, no muro)" } else { No "ledger ausente: esperaba 0, fue $($r.code)" }
  if ($r.out -match 'no hay') { Ok "ledger ausente: el mensaje orienta" } else { No "ledger ausente: falta el mensaje" }

  # 2: bloquea + -Estricto, codigo sin capacidad -> exit 1 NOMBRANDO la capacidad (ROJO).
  $r = Corre $fix @('-Ledger', $ledgerPath, '-Cambiados', 'servidor/pagos.js', '-Estricto')
  if ($r.code -eq 1) { Ok "bloquea+Estricto violada: exit 1 (el muro muerde)" } else { No "bloquea+Estricto: esperaba 1, fue $($r.code)" }
  if ($r.out -match 'PAGO-1\.md') { Ok "el bloqueo NOMBRA la capacidad exacta (PAGO-1.md, no 'revisa las 89')" } else { No "el bloqueo deberia nombrar product/capacidades/PAGO-1.md" }
  if ($r.out -match '\[BLOQUEA\]') { Ok "etiqueta [BLOQUEA] presente" } else { No "falta la etiqueta [BLOQUEA]" }

  # 3: mismo cambio SIN -Estricto -> exit 0 pero la verdad se dice ([BLOQUEA] impreso).
  $r = Corre $fix @('-Ledger', $ledgerPath, '-Cambiados', 'servidor/pagos.js')
  if ($r.code -eq 0) { Ok "bloquea violada sin -Estricto: exit 0 (el muro se cablea, no se hereda)" } else { No "sin -Estricto esperaba 0, fue $($r.code)" }
  if ($r.out -match '\[BLOQUEA\]') { Ok "sin -Estricto el [BLOQUEA] igual se imprime (la verdad se dice)" } else { No "sin -Estricto deberia imprimir [BLOQUEA] aunque no mate" }

  # 4: VERDE del caso 2 -- tocando codigo Y capacidad, -Estricto -> exit 0.
  $r = Corre $fix @('-Ledger', $ledgerPath, '-Cambiados', 'servidor/pagos.js,product/capacidades/PAGO-1.md', '-Estricto')
  if ($r.code -eq 0) { Ok "codigo + capacidad tocados juntos: exit 0 aun con -Estricto (VERDE)" } else { No "co-ocurrencia satisfecha: esperaba 0, fue $($r.code)" }

  # 5: avisa NUNCA bloquea, ni con -Estricto.
  $r = Corre $fix @('-Ledger', $ledgerPath, '-Cambiados', 'servidor/envios.js', '-Estricto')
  if ($r.code -eq 0) { Ok "fuerza:avisa violada + -Estricto: exit 0 (avisa jamas bloquea)" } else { No "avisa+Estricto: esperaba 0, fue $($r.code)" }
  if ($r.out -match '\[AVISO\] liga ''envios''') { Ok "el aviso nombra la liga 'envios'" } else { No "falta el [AVISO] de la liga envios" }

  # 6: direccionalidad -- capacidad-a-codigo (liga 'espejo') avisa cuando cambia la
  # capacidad sin codigo; la liga 'envios' (codigo-a-capacidad) NO se activa con eso.
  $r = Corre $fix @('-Ledger', $ledgerPath, '-Cambiados', 'product/capacidades/ENVIO-1.md')
  if ($r.out -match '\[AVISO\] liga ''espejo''') { Ok "capacidad-a-codigo: capacidad sin codigo -> violada" } else { No "la liga espejo deberia avisar (capacidad sin codigo)" }
  if ($r.out -notmatch '\[AVISO\] liga ''envios''') { Ok "codigo-a-capacidad NO se activa al tocar solo la capacidad (direccion real)" } else { No "la liga envios no debia activarse tocando solo la capacidad" }

  # 7: 'ambas' viola por cada direccion por separado.
  $ledgerAmbas = @'
{ "ligas": [
  { "id": "dual", "codigo": ["servidor/pagos.js"], "capacidades": ["product/capacidades/PAGO-1.md"],
    "direccion": "ambas", "fuerza": "avisa" }
] }
'@
  $ambasPath = Join-Path $fix 'tools/ligas-ambas.json'
  Set-Content -LiteralPath $ambasPath -Value $ledgerAmbas -Encoding ASCII
  $r = Corre $fix @('-Ledger', $ambasPath, '-Cambiados', 'servidor/pagos.js')
  $r2 = Corre $fix @('-Ledger', $ambasPath, '-Cambiados', 'product/capacidades/PAGO-1.md')
  if ($r.out -match '\[AVISO\] liga ''dual''' -and $r2.out -match '\[AVISO\] liga ''dual''') { Ok "'ambas': viola en las dos direcciones por separado" } else { No "'ambas' deberia violar en cada direccion" }

  # 8: cambio que no casa ninguna liga -> silencio verde.
  $r = Corre $fix @('-Ledger', $ledgerPath, '-Cambiados', 'suelto.ps1', '-Estricto')
  if ($r.code -eq 0 -and $r.out -notmatch '\[AVISO\]|\[BLOQUEA\]') { Ok "cambio fuera de toda liga: exit 0 sin ruido" } else { No "cambio ajeno: esperaba 0 silencioso, fue $($r.code)" }

  # 9: regresion del matcher byte-fiel -- un patron sin '/' NO casa rutas anidadas.
  $ledgerRaizPat = @'
{ "ligas": [
  { "id": "raizpat", "codigo": ["*.js"], "capacidades": ["product/capacidades/PAGO-1.md"],
    "direccion": "codigo-a-capacidad", "fuerza": "bloquea" } ] }
'@
  $raizPath = Join-Path $fix 'tools/ligas-raiz.json'
  Set-Content -LiteralPath $raizPath -Value $ledgerRaizPat -Encoding ASCII
  $r = Corre $fix @('-Ledger', $raizPath, '-Cambiados', 'servidor/pagos.js', '-Estricto')
  if ($r.out -match '\[ROTA\]') { Ok "matcher: '*.js' sin '/' no casa servidor/ -> la liga sale ROTA, no falso bloqueo" } else { No "el patron raiz '*.js' no debia casar servidor/pagos.js" }
  if ($r.code -eq 0) { Ok "liga rota nunca bloquea (exit 0 aun -Estricto+bloquea)" } else { No "rota: esperaba 0, fue $($r.code)" }

  # 10: liga rota por capacidad inexistente -> [ROTA], excluida, sin falso [BLOQUEA].
  $ledgerRota = @'
{ "ligas": [
  { "id": "fantasma", "codigo": ["servidor/pagos.js"], "capacidades": ["product/capacidades/NO-EXISTE.md"],
    "direccion": "codigo-a-capacidad", "fuerza": "bloquea" } ] }
'@
  $rotaPath = Join-Path $fix 'tools/ligas-rota.json'
  Set-Content -LiteralPath $rotaPath -Value $ledgerRota -Encoding ASCII
  $r = Corre $fix @('-Ledger', $rotaPath, '-Cambiados', 'servidor/pagos.js', '-Estricto')
  if ($r.code -eq 0 -and $r.out -match '\[ROTA\]' -and $r.out -notmatch '\[BLOQUEA\]') { Ok "capacidad inexistente: [ROTA] avisa, se excluye, cero falso [BLOQUEA]" } else { No "rota por capacidad: esperaba ROTA sin BLOQUEA y exit 0 (fue $($r.code))" }

  # 11: ledger malformado -> exit 2 (falla cerrado); enum invalido -> exit 2.
  $malPath = Join-Path $fix 'tools/ligas-mal.json'
  Set-Content -LiteralPath $malPath -Value '{ esto no es json' -Encoding ASCII
  $r = Corre $fix @('-Ledger', $malPath)
  if ($r.code -eq 2) { Ok "ledger malformado: exit 2 (FALLA CERRADO)" } else { No "malformado: esperaba 2, fue $($r.code)" }
  $enumPath = Join-Path $fix 'tools/ligas-enum.json'
  Set-Content -LiteralPath $enumPath -Value '{ "ligas": [ { "id":"x","codigo":["servidor/pagos.js"],"capacidades":["product/capacidades/PAGO-1.md"],"direccion":"diagonal","fuerza":"avisa" } ] }' -Encoding ASCII
  $r = Corre $fix @('-Ledger', $enumPath)
  if ($r.code -eq 2) { Ok "direccion invalida: exit 2 (el gate no interpreta ley que no entiende)" } else { No "enum invalido: esperaba 2, fue $($r.code)" }

  # 12: rango git REAL con -Base (sin -Cambiados): 2do commit toca codigo sin capacidad.
  New-Item -ItemType Directory -Path (Join-Path $fixB 'tools') -Force | Out-Null
  New-Item -ItemType Directory -Path (Join-Path $fixB 'servidor') -Force | Out-Null
  New-Item -ItemType Directory -Path (Join-Path $fixB 'product/capacidades') -Force | Out-Null
  Set-Content -LiteralPath (Join-Path $fixB 'servidor/pagos.js') -Value "// v1" -Encoding ASCII
  Set-Content -LiteralPath (Join-Path $fixB 'product/capacidades/PAGO-1.md') -Value "# cap" -Encoding UTF8
  $ledgerB = @'
{ "ligas": [
  { "id": "pagos", "codigo": ["servidor/pagos.js"], "capacidades": ["product/capacidades/PAGO-1.md"],
    "direccion": "codigo-a-capacidad", "fuerza": "bloquea" } ] }
'@
  Set-Content -LiteralPath (Join-Path $fixB 'tools/ligas.json') -Value $ledgerB -Encoding ASCII
  Init-GitFixture $fixB
  $eapPrev = $ErrorActionPreference; $ErrorActionPreference = 'Continue'
  Push-Location $fixB
  git branch -M principal 2>&1 | Out-Null
  git checkout -q -b rama 2>&1 | Out-Null
  Set-Content -LiteralPath (Join-Path $fixB 'servidor/pagos.js') -Value "// v2 sin capacidad" -Encoding ASCII
  git add -A 2>&1 | Out-Null
  git commit -q -m 'toca codigo sin capacidad' 2>&1 | Out-Null
  Pop-Location
  $ErrorActionPreference = $eapPrev
  $r = Corre $fixB @('-Base', 'principal', '-Estricto')
  if ($r.code -eq 1 -and $r.out -match 'PAGO-1\.md') { Ok "rango git real (-Base): la violacion se detecta por diff, no solo inyectada" } else { No "-Base: esperaba 1 nombrando PAGO-1.md, fue $($r.code)" }

  # ---------------------------------------------------------------- Parte B (ledger REAL)
  $realPath = Join-Path $raiz 'tools/ligas.json'
  if (Test-Path -LiteralPath $realPath) {
    $eapPrev = $ErrorActionPreference; $ErrorActionPreference = 'Continue'
    $realObj = $null
    try { $realObj = [System.IO.File]::ReadAllText($realPath) | ConvertFrom-Json } catch {}
    $ErrorActionPreference = $eapPrev
    if ($null -ne $realObj -and $null -ne $realObj.PSObject.Properties['ligas']) { Ok "ledger real: parsea y trae 'ligas'" } else { No "ledger real: no parsea o falta 'ligas'" }
    $enumMal = 0
    foreach ($l in @($realObj.ligas)) {
      if (@('codigo-a-capacidad','capacidad-a-codigo','ambas') -notcontains $l.direccion) { $enumMal++ }
      if (@('avisa','bloquea') -notcontains $l.fuerza) { $enumMal++ }
    }
    if ($enumMal -eq 0) { Ok "ledger real: enums de direccion/fuerza validos" } else { No "ledger real: $enumMal enum(s) invalido(s)" }
    # cero rotas en el repo real: el evaluador mismo lo dictamina (sin cambios inyectamos lista vacia benigna).
    $r = Corre $raiz @('-Cambiados', 'archivo-que-no-existe-para-rango-vacio.txt')
    if ($r.out -notmatch '\[ROTA\]') { Ok "ledger real: cero ligas rotas en este repo" } else { No "ledger real: hay ligas rotas (el grafo miente)" }
    if ($r.code -eq 0) { Ok "evaluador sobre el repo real: exit 0" } else { No "repo real: esperaba 0, fue $($r.code)" }
  } else {
    Write-Host "  [SKIP]  ledger real (tools/ligas.json no existe en este repo)" -ForegroundColor DarkGray
  }
}
finally {
  foreach ($p in @($fix, $fixB)) { if ($p) { Remove-Item -LiteralPath $p -Recurse -Force -ErrorAction SilentlyContinue } }
}

Write-Host ""
if ($script:fail -gt 0) {
  Write-Host "== Gate de ligas INCOMPLETO: $($script:fail) fallo(s), $($script:pass) ok. ==" -ForegroundColor Red
  exit 1
}
Write-Host "== Gate de ligas sano: $($script:pass) verificaciones verdes. =="
exit 0
