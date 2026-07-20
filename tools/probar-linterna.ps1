#Requires -Version 5
# probar-linterna.ps1 - self-test de la linterna del gobierno (estado-gobierno.ps1).
# Partes:
#   A) COMPORTAMIENTO: repo-fixture git temporal con una ley sintetica y archivos (uno
#      cubierto, uno libre capa-3, uno HUERFANO, uno con acento en el nombre). Verifica
#      que el .html marca el huerfano y cuenta 1; luego lo borra y verifica 0 (ROJO->VERDE).
#   A2) FALLA CERRADO: un dir SIN git -> exit 2 (no un "cero huerfanos" mentiroso).
#   A3) INYECCION: un texto de la ley con los literales __META__/__DATA__ NO corrompe el
#      JSON incrustado (regresion del bug de doble-Replace, cazado en code-review).
#   A4) RUTA CON ACENTO: un archivo con 'n~' en el nombre no sale como huerfano falso ni
#      escapado en octal (regresion del git ls-files sin core.quotepath=false).
#   B) INTEGRIDAD (ley REAL): corre sobre este repo, .html valido, exit 0, conteo presente.
# Todo el ciclo va en try/finally: los fixtures temporales se limpian aunque un aserto falle.
# Se siembra (mecanica). PS 5.1, ASCII a proposito.

$ErrorActionPreference = 'Stop'
$raiz = Split-Path -Parent $PSScriptRoot
if (-not $raiz) { $raiz = (Get-Location).Path }
$linterna = Join-Path $PSScriptRoot 'estado-gobierno.ps1'

$script:pass = 0; $script:fail = 0
function Ok($m) { Write-Host "  [PASA]  $m"; $script:pass++ }
function No($m) { Write-Host "  [FALLA] $m" -ForegroundColor Red; $script:fail++ }

function Init-GitFixture($dir) {
  $eapPrev = $ErrorActionPreference; $ErrorActionPreference = 'Continue'
  Push-Location $dir
  git init -q 2>&1 | Out-Null
  git config core.autocrlf false 2>&1 | Out-Null
  git config core.safecrlf false 2>&1 | Out-Null
  git add -A 2>&1 | Out-Null
  Pop-Location
  $ErrorActionPreference = $eapPrev
}

Write-Host "== Linterna del gobierno: comportamiento + inyeccion + falla-cerrado + integridad =="

$tmp = [System.IO.Path]::GetTempPath()
$fix    = Join-Path $tmp ("linterna-" + [System.Guid]::NewGuid().ToString('N'))
$nogit  = Join-Path $tmp ("linterna-nogit-" + [System.Guid]::NewGuid().ToString('N'))
$inj    = Join-Path $tmp ("linterna-inj-" + [System.Guid]::NewGuid().ToString('N'))
$out    = Join-Path $tmp ("linterna-out-" + [System.Guid]::NewGuid().ToString('N') + ".html")
$out2   = Join-Path $tmp ("linterna-inj-" + [System.Guid]::NewGuid().ToString('N') + ".html")
$outReal = Join-Path $tmp ("linterna-real-" + [System.Guid]::NewGuid().ToString('N') + ".html")
$jsTmp  = Join-Path $tmp ("linterna-js-" + [System.Guid]::NewGuid().ToString('N') + ".js")
$pf     = Join-Path $tmp ("linterna-pf-" + [System.Guid]::NewGuid().ToString('N'))
$outpf  = Join-Path $tmp ("linterna-pfo-" + [System.Guid]::NewGuid().ToString('N') + ".html")

# invariante compartido: parsea el DATA embebido y CUENTA las aristas que apuntan a un nodo
# inexistente (la "mentira por omision" que el JS descarta en silencio). Devuelve un ENTERO
# (no un array: un @() vacio se desenvuelve a $null en PS y arruina el chequeo); -1 = no parseo.
function Get-AristasColgadasCount($html) {
  $m = [regex]::Match($html, 'const DATA = (.+?);\s*const META')
  if (-not $m.Success) { return -1 }
  $data = $m.Groups[1].Value | ConvertFrom-Json
  $ids = @{}; foreach ($n in $data.nodes) { $ids[$n.id] = $true }
  $c = 0
  foreach ($e in $data.edges) { if (-not $ids.ContainsKey($e.s) -or -not $ids.ContainsKey($e.t)) { $c++ } }
  return $c
}
$nAcento = "nota-" + [char]0x00F1 + ".md"   # 'nota-n~.md' sin literal no-ASCII en la fuente

try {
  # ---------------------------------------------------------------- Parte A
  New-Item -ItemType Directory -Path (Join-Path $fix 'tools') -Force | Out-Null
  New-Item -ItemType Directory -Path (Join-Path $fix 'candy') -Force | Out-Null

  $leyFix = @'
[
  { "nombre":"motor","desc":"el motor","fuente":["tools/*"],"doc_avisa":["NOTAS.md"],"revisa":true,"rol":"escribano" },
  { "nombre":"raiz","desc":"la raiz","fuente":["*"],"excluye":["LICENSE"],"doc_avisa":["HANDOFF.md"],"rol":"escribano" }
]
'@
  Set-Content -LiteralPath (Join-Path $fix 'tools/blast-radius.json') -Value $leyFix -Encoding ASCII
  $ledgerFix = @'
{ "capa2":[ {"doc":"NOTAS.md","molde":"m.md","requeridas":["Intro"],"estricto":false} ], "capa3":["LICENSE"] }
'@
  Set-Content -LiteralPath (Join-Path $fix 'tools/docs-gobernados.json') -Value $ledgerFix -Encoding ASCII

  Set-Content -LiteralPath (Join-Path $fix 'tools/algo.ps1') -Value "# algo" -Encoding ASCII
  Set-Content -LiteralPath (Join-Path $fix 'NOTAS.md') -Value "# t`n## Intro`ncuerpo" -Encoding UTF8
  Set-Content -LiteralPath (Join-Path $fix 'LICENSE') -Value "MIT" -Encoding ASCII
  Set-Content -LiteralPath (Join-Path $fix $nAcento) -Value "# nota con acento en el nombre" -Encoding UTF8
  Set-Content -LiteralPath (Join-Path $fix 'candy/audit.md') -Value "# auditoria que Claude solto" -Encoding UTF8
  Init-GitFixture $fix   # git add -A: todo lo anterior queda TRACKEADO (candy/audit.md incluido)
  # ...y un huerfano UNTRACKED (recien soltado, sin git add): la linterna tambien debe verlo
  # (git ls-files --others). Cubre el dolor "documentos sin trackear".
  New-Item -ItemType Directory -Path (Join-Path $fix 'soltado') -Force | Out-Null
  Set-Content -LiteralPath (Join-Path $fix 'soltado/nuevo.md') -Value "# nuevo sin trackear" -Encoding UTF8

  $o1 = (& powershell -NoProfile -File $linterna -Repo $fix -Salida $out 2>&1 | Out-String)
  $c1 = $LASTEXITCODE
  if ($c1 -eq 0) { Ok "corrida con huerfano: exit 0 (es vista, no muro)" } else { No "esperaba exit 0, fue $c1" }
  if (Test-Path -LiteralPath $out) { Ok "genero el .html" } else { No "no genero el .html en $out" }
  $html1 = if (Test-Path -LiteralPath $out) { Get-Content -LiteralPath $out -Raw } else { '' }
  if ($o1 -match 'candy/audit\.md') { Ok "consola nombra el huerfano trackeado candy/audit.md" } else { No "la consola deberia nombrar candy/audit.md" }
  if ($html1 -match '"orphan:candy/audit\.md"') { Ok "el grafo tiene el nodo huerfano trackeado (rojo)" } else { No "el .html deberia tener el nodo orphan:candy/audit.md" }
  if ($html1 -match '"orphan:soltado/nuevo\.md"') { Ok "el grafo ve tambien el huerfano UNTRACKED (git ls-files --others)" } else { No "un huerfano sin trackear deberia verse igual" }
  if ($html1 -match '"huerfanos":2') { Ok "metrica: huerfanos = 2 (trackeado + untracked)" } else { No "META deberia decir huerfanos:2" }
  if ($html1 -notmatch '"orphan:tools/algo\.ps1"') { Ok "tools/algo.ps1 (cubierto por un area) NO se marca huerfano" } else { No "un archivo cubierto por un area se marco huerfano" }
  if ($html1 -notmatch '"orphan:LICENSE"') { Ok "LICENSE (capa-3 libre) NO es huerfano" } else { No "LICENSE declarado libre no deberia ser huerfano" }
  if ($html1 -match 'doc-conforme') { Ok "doc capa-2 NOTAS.md aparece como conforme" } else { No "NOTAS.md deberia aparecer como doc-conforme" }
  # H2: NOTAS.md es capa-2 Y target de doc_avisa del area 'motor'; NO debe duplicarse como owner:
  if ($html1 -notmatch '"owner:NOTAS\.md"') { Ok "H2: NOTAS.md (capa-2 + doc_avisa) no se duplica como nodo owner" } else { No "H2: NOTAS.md salio duplicado (doc: y owner: desconectados)" }
  if ($html1 -match '"t":"doc:NOTAS\.md","kind":"avisa"') { Ok "H2: la arista doc_avisa se unifica al nodo capa-2 (doc:)" } else { No "H2: la arista avisa no apunta al nodo capa-2 unificado" }
  if ($html1 -match 'gate:gemba-stop') { Ok "gate DORMIDO (gemba-stop) presente como nodo" } else { No "el gate dormido gemba-stop deberia ser un nodo (inactivo, no ausente)" }
  if ($html1 -match 'gate:andon-stop') { Ok "gate VIVO (andon-stop) presente como nodo" } else { No "andon-stop deberia ser un nodo" }
  # A4: la ruta con acento no se escapa en octal ni sale como huerfano falso.
  if ($html1 -notmatch '\\303|\\\d\d\d') { Ok "ruta con acento: sin escape octal en el .html (core.quotepath=false)" } else { No "aparecio un escape octal (git quotepath): la ruta con acento se mangleo" }
  if ($html1 -notmatch 'orphan:nota-') { Ok "la nota con acento (cubierta por 'raiz') NO es huerfano falso" } else { No "la nota con acento salio como huerfano falso (bug quotepath)" }

  # corrida 2: quitamos ambos huerfanos -> cero huerfanos (VERDE).
  Remove-Item -LiteralPath (Join-Path $fix 'candy') -Recurse -Force -ErrorAction SilentlyContinue
  Remove-Item -LiteralPath (Join-Path $fix 'soltado') -Recurse -Force -ErrorAction SilentlyContinue
  Init-GitFixture $fix   # re-stage: que git deje de ver candy/
  $o2 = (& powershell -NoProfile -File $linterna -Repo $fix -Salida $out 2>&1 | Out-String)
  $c2 = $LASTEXITCODE
  if ($c2 -eq 0) { Ok "corrida sin huerfano: exit 0" } else { No "esperaba exit 0, fue $c2" }
  $html2 = if (Test-Path -LiteralPath $out) { Get-Content -LiteralPath $out -Raw } else { '' }
  if ($html2 -match '"huerfanos":0') { Ok "metrica: huerfanos = 0 (VERDE tras corregir)" } else { No "META deberia decir huerfanos:0" }
  if ($o2 -match 'cero huerfanos') { Ok "consola declara cero huerfanos" } else { No "la consola deberia declarar cero huerfanos" }

  # ---------------------------------------------------------------- Parte A2: falla cerrado (no-git)
  New-Item -ItemType Directory -Path (Join-Path $nogit 'tools') -Force | Out-Null
  Set-Content -LiteralPath (Join-Path $nogit 'tools/blast-radius.json') -Value $leyFix -Encoding ASCII
  Set-Content -LiteralPath (Join-Path $nogit 'suelto.md') -Value "# suelto" -Encoding UTF8
  # OJO: NO se hace git init aqui a proposito.
  $o3 = (& powershell -NoProfile -File $linterna -Repo $nogit -Salida $out2 2>&1 | Out-String)
  $c3 = $LASTEXITCODE
  if ($c3 -eq 2) { Ok "dir sin git -> exit 2 (FALLA CERRADO, no un verde mentiroso)" } else { No "dir sin git: esperaba exit 2, fue $c3" }
  if ($o3 -match 'FALLA CERRADO|no pude enumerar') { Ok "el error explica el fallo-cerrado" } else { No "deberia explicar el fallo-cerrado" }

  # ---------------------------------------------------------------- Parte A3: inyeccion __META__/__DATA__
  New-Item -ItemType Directory -Path (Join-Path $inj 'tools') -Force | Out-Null
  $leyInj = @'
[
  { "nombre":"motor","desc":"colision __META__ y __DATA__ dentro del desc","fuente":["tools/*"],"doc_avisa":["X.md"],"rol":"escribano" }
]
'@
  Set-Content -LiteralPath (Join-Path $inj 'tools/blast-radius.json') -Value $leyInj -Encoding ASCII
  Set-Content -LiteralPath (Join-Path $inj 'tools/algo.ps1') -Value "# a" -Encoding ASCII
  Init-GitFixture $inj
  $o4 = (& powershell -NoProfile -File $linterna -Repo $inj -Salida $out2 2>&1 | Out-String)
  $html4 = if (Test-Path -LiteralPath $out2) { Get-Content -LiteralPath $out2 -Raw } else { '' }
  # si el doble-Replace estuviera vivo, el literal '__META__' del desc se habria sustituido
  # por el objeto META y este match exacto fallaria; que sobreviva prueba el arreglo.
  if ($html4 -match 'colision __META__ y __DATA__ dentro del desc') { Ok "texto de ley con __META__/__DATA__ sobrevive intacto (no corrompe el JSON)" } else { No "el doble-Replace corrompio el desc con __META__/__DATA__" }
  if ($html4 -match '"gatesVivos":') { Ok "el objeto META sigue bien formado pese al texto colisionante" } else { No "META quedo corrompido por el texto de la ley" }

  # ---------------------------------------------------------------- Parte A5: H1 (area sin fuente)
  # un area con product_avisa pero SIN fuente no tiene nodo -> no debe emitir aristas colgadas.
  New-Item -ItemType Directory -Path (Join-Path $pf 'tools') -Force | Out-Null
  New-Item -ItemType Directory -Path (Join-Path $pf 'product/capacidades') -Force | Out-Null
  $leyPf = @'
[
  { "nombre":"motor","desc":"m","fuente":["tools/*"],"product_avisa":["product/capacidades/CAP-*"],"rol":"escribano" },
  { "nombre":"soloconfig","desc":"config sin fuente","product_avisa":["product/capacidades/CAP-*"] }
]
'@
  Set-Content -LiteralPath (Join-Path $pf 'tools/blast-radius.json') -Value $leyPf -Encoding ASCII
  Set-Content -LiteralPath (Join-Path $pf 'product/capacidades/CAP-1-algo.md') -Value "---`nclave: CAP-1`n---`n# cap" -Encoding UTF8
  Set-Content -LiteralPath (Join-Path $pf 'tools/algo.ps1') -Value "# a" -Encoding ASCII
  Init-GitFixture $pf
  & powershell -NoProfile -File $linterna -Repo $pf -Salida $outpf 2>&1 | Out-Null
  $htmlPf = if (Test-Path -LiteralPath $outpf) { Get-Content -LiteralPath $outpf -Raw } else { '' }
  $colgPf = Get-AristasColgadasCount $htmlPf
  if ($colgPf -eq 0) { Ok "H1: area con product_avisa SIN fuente no genera aristas colgadas" } else { No "H1: $colgPf arista(s) colgadas de un area sin fuente (-1 = no parseo)" }
  if ($htmlPf -notmatch '"area:soloconfig"') { Ok "H1: el area sin fuente no aparece como nodo" } else { No "H1: el area sin fuente aparecio como nodo" }
  if ($htmlPf -match '"tipo":"capability"') { Ok "H1: la capacidad SI se conecta desde el area valida (motor)" } else { No "H1: la capacidad deberia existir (via el area con fuente)" }

  # ---------------------------------------------------------------- Parte B (ley REAL)
  $oR = (& powershell -NoProfile -File $linterna -Repo $raiz -Salida $outReal 2>&1 | Out-String)
  $cR = $LASTEXITCODE
  if ($cR -eq 0) { Ok "linterna sobre el repo real: exit 0" } else { No "sobre el repo real esperaba exit 0, fue $cR" }
  $htmlR = if (Test-Path -LiteralPath $outReal) { Get-Content -LiteralPath $outReal -Raw } else { '' }
  if ($htmlR -match '"huerfanos":\d+') { Ok "el .html real trae el conteo de huerfanos" } else { No "el .html real deberia traer la metrica huerfanos" }
  if ($htmlR -match 'area:barreras') { Ok "el grafo real incluye el area barreras (el motor Andon)" } else { No "el grafo real deberia incluir area:barreras" }
  # la telarana R2: doc-duenos, capacidades, hooks y checks deben aparecer como nodos.
  if ($htmlR -match '"doc-owner"') { Ok "R2: hay nodos documento-dueno (las flechas si-tocas-X-actualiza-Y)" } else { No "R2: faltan los nodos doc-owner" }
  if ($htmlR -match '"tipo":"check"') { Ok "R2: los checks de CI aparecen como nodos" } else { No "R2: faltan los nodos check de CI" }
  if ($htmlR -match '"kind":"bloquea"|"kind":"avisa"') { Ok "R2: aristas tipadas (dura bloquea / blanda avisa) presentes" } else { No "R2: faltan las aristas tipadas doc" }
  if ($htmlR -match '"tipo":"capability"') { Ok "R2: nodos capacidad presentes (repo real)" } else { No "R2: faltan nodos capability" }
  if ($htmlR -match '"tipo":"hook"') { Ok "R2: nodos hook presentes" } else { No "R2: faltan nodos hook" }
  if ($htmlR -match '"kind":"product"') { Ok "R2: aristas product (area->capacidad) presentes" } else { No "R2: faltan aristas product" }
  $colgR = Get-AristasColgadasCount $htmlR
  if ($colgR -eq 0) { Ok "R2: ninguna arista cuelga de un nodo inexistente (repo real)" } else { No "R2: $colgR arista(s) colgadas en el grafo real (-1 = no parseo)" }
  # los 3 modos de vista (Foco / Agrupado / Clusters): sin ellos el grafo denso es una marana.
  foreach ($m in @('foco', 'agrupado', 'clusters')) {
    if ($htmlR -match ("data-m=""" + $m + """")) { Ok "modo '$m' presente en la barra" } else { No "falta el boton del modo '$m'" }
  }
  if ($htmlR -match "setMode\('foco'\)") { Ok "arranca en modo Foco (esqueleto legible, no los N nodos de golpe)" } else { No "deberia arrancar en modo Foco" }
  if ($htmlR -match "hidden=new Set\(\['capability','check'\]\)") { Ok "las capas ruidosas (capacidad/check) nacen apagadas en la leyenda" } else { No "capability/check deberian nacer ocultas" }
  if ($htmlR -match 'function visible\(' -and $htmlR -match 'function edgesActive\(') { Ok "la visibilidad depende del modo (visible/edgesActive)" } else { No "faltan visible()/edgesActive()" }
  # el JS embebido debe PARSEAR (evita la pagina en blanco por error de sintaxis). Si no hay node, se salta.
  if ($null -ne (Get-Command node -ErrorAction SilentlyContinue)) {
    $mjs = [regex]::Match($htmlR, '(?s)<script>(.+?)</script>')
    if ($mjs.Success) {
      Set-Content -LiteralPath $jsTmp -Value $mjs.Groups[1].Value -Encoding UTF8
      & node --check $jsTmp 2>&1 | Out-Null
      if ($LASTEXITCODE -eq 0) { Ok "el JS embebido parsea sin error de sintaxis (node --check)" } else { No "el JS embebido tiene error de sintaxis (node --check fallo)" }
    }
  } else {
    Write-Host "  [SKIP]  node --check del JS (node no disponible en esta maquina)" -ForegroundColor DarkGray
  }
}
finally {
  foreach ($p in @($fix, $nogit, $inj, $pf)) { if ($p) { Remove-Item -LiteralPath $p -Recurse -Force -ErrorAction SilentlyContinue } }
  foreach ($p in @($out, $out2, $outReal, $jsTmp, $outpf)) { if ($p) { Remove-Item -LiteralPath $p -Force -ErrorAction SilentlyContinue } }
}

Write-Host ""
if ($script:fail -gt 0) {
  Write-Host "== Linterna INCOMPLETA: $($script:fail) fallo(s), $($script:pass) ok. ==" -ForegroundColor Red
  exit 1
}
Write-Host "== Linterna sana: $($script:pass) verificaciones verdes. =="
exit 0
