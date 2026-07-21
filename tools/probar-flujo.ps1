#Requires -Version 5
# probar-flujo.ps1 - self-test del pilar de flujo (FLU-1, ADR 0045): los contratos del
# HANDOFF y del ROADMAP, ambos en verificar.ps1. El check [contrato-handoff] cuenta las
# secciones "Donde estamos" (max 1), las historicas "Donde estuvimos"/"Antes"
# (max_historicas) y el techo de lineas. El check [contrato-roadmap] exige que el ROADMAP
# sea una cola CLASIFICADA (solo secciones Urgente/Con fecha/Normal/Algun dia/Referencia)
# con cada item vivo declarando [alta:] (+ apetito/vence segun su clase) bajo un techo de
# lineas. Los limites son dato de instancia en tools/flujo.json. Este test monta fixtures
# ROJO->VERDE y corre el verificar REAL contra cada uno.
#
# Mecanica clave: se invoca el verificar REAL (tools/verificar.ps1) con -Repo <fixture>.
# Push-Location lleva el CWD al fixture, asi tools/flujo.json y HANDOFF.md se leen del
# fixture; pero $PSScriptRoot sigue siendo el tools/ real, de donde el verificar lee su ley
# (blast-radius.json). -Cambiados docs/nada.md no casa con NINGUNA area (la raiz usa '*',
# que por la guarda del matcher no cruza '/'), asi el unico veredicto posible es el del
# contrato-handoff -- el resto del gate queda mudo.
#
# Casos: (a) conforme con ACENTOS reales UTF-8 sin BOM -> exit 0 y conteo correcto de
# historicas (regresion del encoding: si saliera 0/2 con 2 historicas, PS 5.1 leyo el
# HANDOFF como ANSI y el contrato se midio en falso); (b) doble "Donde estamos" -> exit 1;
# (c) 3 historicas (mezcla estuvimos/Antes) -> exit 1; (d) techo excedido -> exit 1;
# (e) sin tools/flujo.json -> exit 0 y el check NO aplica; (f) flujo.json corrupto -> exit 2
# (falla cerrado); (g) clave handoff incompleta (sin max_historicas/techo_lineas) -> exit 2
# (falla cerrado, NO bloquea-todo con [int]$null=0); (h) "## Antesala del proyecto" NO cuenta
# como historica (regresion del regex de prefijo); (i) sin ninguna "Donde estamos" -> exit 1
# (el contrato exige UNA). Se siembra (mecanica). PS 5.1, ASCII a proposito.
#
# Casos del ROADMAP (check [contrato-roadmap], flujo.json SOLO con la clave roadmap -- asi
# el check hermano del handoff no aplica y no ensucia el veredicto): (j) conforme (las 5
# secciones, items clasificados, un sub-bullet indentado que NO cuenta) -> exit 0 y conteo;
# (k) item sin [alta: -> exit 1 acusando el item; (l) urgente sin apetito -> exit 1;
# (m) "Con fecha" sin vence -> exit 1; (n) seccion H2 extra ("## Notas de la sesion")
# -> exit 1 (el ROADMAP no es diario); (o) techo excedido -> exit 1; (p) item bajo
# Referencia sin metadatos -> exit 0 (exento); (q) flujo.json sin clave roadmap -> el check
# NO aplica, exit 0; (r) roadmap:{} incompleto (sin techo_lineas) -> exit 2 (falla cerrado).

# Continue (no Stop): este test hace shell-out al verificar real, y el caso corrupto (f)
# hace que el hijo escriba a stderr (el error de ConvertFrom-Json). Con 2>&1 + Stop, PS 5.1
# promueve ese stderr nativo a un NativeCommandError TERMINANTE que abortaria el harness
# antes de poder afirmar el exit 2 -- el mismo gotcha que publicar.ps1 evita con Continue.
$ErrorActionPreference = 'Continue'
$veri = Join-Path $PSScriptRoot 'verificar.ps1'
if (-not (Test-Path $veri)) { Write-Host "  [FALLA] no existe tools/verificar.ps1 (el gate que este test ejercita)" -ForegroundColor Red; exit 1 }

$script:pass = 0; $script:fail = 0
function Ok($m) { Write-Host "  [PASA]  $m"; $script:pass++ }
function No($m) { Write-Host "  [FALLA] $m" -ForegroundColor Red; $script:fail++ }

# UTF-8 SIN BOM real (New-Object UTF8Encoding($false)): asi se escriben los fixtures, el
# mismo contrato de encoding que el verificar lee con -Encoding UTF8.
$utf8NoBom = New-Object System.Text.UTF8Encoding($false)
# 'o' acentuada real, construida sin literal (esta fuente es ASCII a proposito): asi el
# HANDOFF-fixture trae "Donde" con acento de verdad, como el HANDOFF real.
$o = [char]0x00F3
$tmpRoot = Join-Path ([System.IO.Path]::GetTempPath()) ("flujofix-" + [System.Guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path $tmpRoot -Force | Out-Null

# Encabezados con acento real, armados por concatenacion (sin literal acentuado en la fuente).
$hEstamos   = "## D" + $o + "nde estamos"
$hEstuvimos = "## D" + $o + "nde estuvimos"

function New-Flujo($maxHist, $techo) {
  # JSON valido con la clave handoff; los limites son dato de instancia por fixture.
  return @"
{
  "handoff": {
    "max_historicas": $maxHist,
    "techo_lineas": $techo,
    "historico": "docs/handoff-historico.md"
  }
}
"@
}

function New-Fixture($nombre, $flujoTexto, $handoffLines) {
  $dir = Join-Path $tmpRoot $nombre
  New-Item -ItemType Directory -Path (Join-Path $dir 'tools') -Force | Out-Null
  if ($null -ne $flujoTexto) {
    [System.IO.File]::WriteAllText((Join-Path $dir 'tools/flujo.json'), $flujoTexto, $utf8NoBom)
  }
  [System.IO.File]::WriteAllLines((Join-Path $dir 'HANDOFF.md'), [string[]]$handoffLines, $utf8NoBom)
  return $dir
}

function Invoke-Verificar($dir) {
  $out = (& powershell -NoProfile -ExecutionPolicy Bypass -File $veri -Repo $dir -Cambiados docs/nada.md 2>&1 | Out-String)
  return @{ Out = $out; Code = $LASTEXITCODE }
}

Write-Host "== Contrato del HANDOFF (check [contrato-handoff]): fixtures ROJO->VERDE =="

# ------------------------------------------------------------------ (a) conforme
# 1 "Donde estamos" + 2 historicas (frontera: 2 == max, NO bloquea) + acentos reales.
$hConforme = @(
  "# HANDOFF fixture",
  "",
  ($hEstamos + " (2026-07-21)"),
  "el estado vigente en una frase",
  "",
  ($hEstuvimos + " (2026-07-20)"),
  "lo anterior, resumido",
  "",
  ($hEstuvimos + " (2026-07-19)"),
  "aun mas atras, resumido"
)
$dirA = New-Fixture 'conforme' (New-Flujo 2 120) $hConforme
$rA = Invoke-Verificar $dirA
if ($rA.Code -eq 0) { Ok "conforme: exit 0" } else { No "conforme: esperaba exit 0, fue $($rA.Code)`n$($rA.Out)" }
if ($rA.Out -match '\[contrato-handoff\]') { Ok "conforme: el check [contrato-handoff] SI aplica (flujo.json presente)" } else { No "conforme: esperaba ver [contrato-handoff] en la salida" }
if ($rA.Out -match 'dentro de contrato') { Ok "conforme: HANDOFF dentro de contrato" } else { No "conforme: esperaba 'dentro de contrato'" }
# LA REGRESION DEL ENCODING: 2 historicas escritas UTF-8 sin BOM deben contarse como 2,
# no como 0. Si el conteo sale 0/2, el verificar leyo el HANDOFF como ANSI (sin -Encoding
# UTF8) y "Donde" acentuado no caso el regex -- el contrato se midio en falso.
if ($rA.Out -match '2/2 historicas') { Ok "conforme: conteo CORRECTO de historicas (2/2) -- acentos UTF-8 leidos bien" } else { No "conforme: el conteo de historicas no es 2/2 (regresion del encoding: PS 5.1 leyo el HANDOFF como ANSI?)`n$($rA.Out)" }

# ------------------------------------------------------------------ (b) doble "Donde estamos"
$hDosEstamos = @(
  "# HANDOFF fixture",
  "",
  ($hEstamos + " (bloque A)"),
  "un estado",
  "",
  ($hEstamos + " (bloque B)"),
  "otro estado que deberia haberse fundido"
)
$dirB = New-Fixture 'dos-estamos' (New-Flujo 2 120) $hDosEstamos
$rB = Invoke-Verificar $dirB
if ($rB.Code -eq 1) { Ok "dos-estamos: exit 1 (BLOQUEA)" } else { No "dos-estamos: esperaba exit 1, fue $($rB.Code)`n$($rB.Out)" }
if ($rB.Out -match 'contrato-handoff') { Ok "dos-estamos: la salida acusa contrato-handoff" } else { No "dos-estamos: esperaba que acusara contrato-handoff" }

# ------------------------------------------------------------------ (c) 3 historicas (mezcla)
$hTresHist = @(
  "# HANDOFF fixture",
  "",
  ($hEstamos + " (vigente)"),
  "el estado",
  "",
  ($hEstuvimos + " (1)"),
  "historica 1",
  "",
  ($hEstuvimos + " (2)"),
  "historica 2",
  "",
  "## Antes (3)",
  "historica 3 -- de mas"
)
$dirC = New-Fixture 'tres-historicas' (New-Flujo 2 120) $hTresHist
$rC = Invoke-Verificar $dirC
if ($rC.Code -eq 1) { Ok "tres-historicas: exit 1 (BLOQUEA)" } else { No "tres-historicas: esperaba exit 1, fue $($rC.Code)`n$($rC.Out)" }
if ($rC.Out -match 'contrato-handoff' -and $rC.Out -match 'historicas') { Ok "tres-historicas: acusa contrato-handoff por historicas de mas (mezcla estuvimos/Antes contada)" } else { No "tres-historicas: esperaba acusar contrato-handoff por historicas`n$($rC.Out)" }

# ------------------------------------------------------------------ (d) techo de lineas excedido
# Config con techo bajo (12) y un HANDOFF de 23 lineas: 1 estamos, 0 historicas -> SOLO el techo dispara.
$hLargo = @("# HANDOFF fixture", "", ($hEstamos + " (vigente)"))
1..20 | ForEach-Object { $hLargo += "linea de relleno $_" }
$dirD = New-Fixture 'techo' (New-Flujo 2 12) $hLargo
$rD = Invoke-Verificar $dirD
if ($rD.Code -eq 1) { Ok "techo: exit 1 (BLOQUEA)" } else { No "techo: esperaba exit 1, fue $($rD.Code)`n$($rD.Out)" }
if ($rD.Out -match 'contrato-handoff' -and $rD.Out -match 'techo') { Ok "techo: acusa contrato-handoff por techo de lineas" } else { No "techo: esperaba acusar contrato-handoff por el techo`n$($rD.Out)" }

# ------------------------------------------------------------------ (e) sin flujo.json -> no aplica
$dirE = New-Fixture 'sin-flujo' $null $hConforme
$rE = Invoke-Verificar $dirE
if ($rE.Code -eq 0) { Ok "sin-flujo: exit 0 (un repo sin el pilar no se bloquea)" } else { No "sin-flujo: esperaba exit 0, fue $($rE.Code)`n$($rE.Out)" }
if ($rE.Out -notmatch 'contrato-handoff') { Ok "sin-flujo: el check NO aplica (sin tools/flujo.json, [contrato-handoff] ausente)" } else { No "sin-flujo: el check no deberia aparecer sin flujo.json`n$($rE.Out)" }

# ------------------------------------------------------------------ (f) flujo.json corrupto -> falla cerrado
$dirF = New-Fixture 'corrupto' "esto no es json valido {{{" $hConforme
$rF = Invoke-Verificar $dirF
if ($rF.Code -eq 2) { Ok "corrupto: exit 2 (falla cerrado -- un gate que no puede medir no aprueba)" } else { No "corrupto: esperaba exit 2, fue $($rF.Code)`n$($rF.Out)" }

# ------------------------------------------------------------------ (g) handoff incompleto -> falla cerrado
# flujo.json con la clave handoff VACIA (sin max_historicas/techo_lineas). Antes, [int]$null
# daba 0 y BLOQUEABA TODO con mensajes rotos; ahora el config incompleto es tan invalido como
# el corrupto -> exit 2 (falla cerrado), no un falso exit 1. HANDOFF conforme a proposito: el
# veredicto lo dicta la config rota, no el relevo.
$dirG = New-Fixture 'handoff-incompleto' '{ "handoff": {} }' $hConforme
$rG = Invoke-Verificar $dirG
if ($rG.Code -eq 2) { Ok "handoff-incompleto: exit 2 (falla cerrado, no bloquea-todo con [int]`$null=0)" } else { No "handoff-incompleto: esperaba exit 2, fue $($rG.Code)`n$($rG.Out)" }
if ($rG.Out -match 'incompleta') { Ok "handoff-incompleto: acusa la clave handoff incompleta" } else { No "handoff-incompleto: esperaba mensaje de clave incompleta`n$($rG.Out)" }

# ------------------------------------------------------------------ (h) 'Antesala' NO es historica
# "## Antesala del proyecto" NO debe contar como historica (el regex antes casaba 'Antes' por
# prefijo). max_historicas=0: si Antesala contara, exit 1; como NO cuenta, exit 0 y 0/0 historicas.
$hAntesala = @(
  "# HANDOFF fixture",
  "",
  ($hEstamos + " (vigente)"),
  "el estado vigente",
  "",
  "## Antesala del proyecto",
  "contexto de arranque -- NO es una seccion historica"
)
$dirH = New-Fixture 'antesala' (New-Flujo 0 120) $hAntesala
$rH = Invoke-Verificar $dirH
if ($rH.Code -eq 0) { Ok "antesala: exit 0 ('Antesala' no dispara el limite de historicas)" } else { No "antesala: esperaba exit 0, fue $($rH.Code)`n$($rH.Out)" }
if ($rH.Out -match '0/0 historicas') { Ok "antesala: conteo CORRECTO (0/0 historicas -- 'Antesala' no casa por prefijo)" } else { No "antesala: esperaba conteo 0/0 historicas`n$($rH.Out)" }

# ------------------------------------------------------------------ (i) sin "Donde estamos" -> BLOQUEA
# 0 secciones "Donde estamos": el contrato exige exactamente UNA. Antes pasaba verde; ahora
# BLOQUEA (exit 1) porque el relevo perdio su estado vigente.
$hSinEstamos = @(
  "# HANDOFF fixture",
  "",
  ($hEstuvimos + " (solo historia)"),
  "quedo historia pero se perdio el estado vigente"
)
$dirI = New-Fixture 'sin-estamos' (New-Flujo 2 120) $hSinEstamos
$rI = Invoke-Verificar $dirI
if ($rI.Code -eq 1) { Ok "sin-estamos: exit 1 (BLOQUEA -- 0 secciones 'Donde estamos')" } else { No "sin-estamos: esperaba exit 1, fue $($rI.Code)`n$($rI.Out)" }
if ($rI.Out -match 'contrato-handoff' -and $rI.Out -match "perdio su secci") { Ok "sin-estamos: acusa contrato-handoff por la seccion 'Donde estamos' perdida" } else { No "sin-estamos: esperaba acusar contrato-handoff por 'Donde estamos' ausente`n$($rI.Out)" }

Write-Host ""
Write-Host "== Contrato del ROADMAP (check [contrato-roadmap]): fixtures ROJO->VERDE =="

# 'u'/'i' acentuadas reales, armadas sin literal (esta fuente es ASCII a proposito): asi el
# ROADMAP-fixture trae "Algun dia" con acentos de verdad, como el ROADMAP real.
$uu = [char]0x00FA
$ii = [char]0x00ED
$hAlgunDia = "## Alg" + $uu + "n d" + $ii + "a"
# Separador de punto medio (U+00B7) real, como el ROADMAP de la nave -- armado sin literal
# (esta fuente es ASCII a proposito). El regex del contrato no lo mira; es cosmetico.
$sep = " " + [char]0x00B7 + " "

function New-FlujoRoadmap($techo) {
  # JSON valido SOLO con la clave roadmap: sin la clave handoff, el check hermano no aplica.
  return @"
{
  "roadmap": {
    "techo_lineas": $techo,
    "historico": "docs/roadmap-historico.md"
  }
}
"@
}

function New-RoadmapFixture($nombre, $flujoTexto, $roadmapLines) {
  $dir = Join-Path $tmpRoot $nombre
  New-Item -ItemType Directory -Path (Join-Path $dir 'tools') -Force | Out-Null
  if ($null -ne $flujoTexto) {
    [System.IO.File]::WriteAllText((Join-Path $dir 'tools/flujo.json'), $flujoTexto, $utf8NoBom)
  }
  # HANDOFF trivial: sin la clave handoff en flujo.json el check hermano no aplica, asi que
  # su contenido no ensucia el veredicto del roadmap.
  [System.IO.File]::WriteAllLines((Join-Path $dir 'HANDOFF.md'), [string[]]@("# HANDOFF fixture"), $utf8NoBom)
  [System.IO.File]::WriteAllLines((Join-Path $dir 'ROADMAP.md'), [string[]]$roadmapLines, $utf8NoBom)
  return $dir
}

# ------------------------------------------------------------------ (j) conforme
# Las 5 secciones con acentos reales, items clasificados, y un sub-bullet indentado bajo
# Normal que NO debe contar (regresion del '^- ' de nivel raiz). Conteo esperado: 4 items
# (urgente + con fecha + normal + algun dia; el de Referencia esta exento y no cuenta).
$rConforme = @(
  "# Roadmap fixture",
  "",
  "> intro del contrato",
  "",
  "## Urgente",
  "- **Un urgente** [alta:2026-07-21${sep}apetito:2h] -- desc",
  "",
  "## Con fecha",
  "- **Uno con fecha** [alta:2026-07-20${sep}vence:2026-08-04${sep}apetito:4h] -- desc",
  "",
  "## Normal",
  "- **Uno normal** [alta:2026-07-21${sep}apetito:6h] -- desc",
  "  - sub-bullet indentado sin metadatos (no cuenta como item)",
  "",
  $hAlgunDia,
  "- **Uno del icebox** [alta:2026-07-13] -- solo alta, sin apetito",
  "",
  "## Referencia",
  "> landscape, no es cola de trabajo",
  "- **Una referencia** sin contrato de item -- exenta"
)
$dirJ = New-RoadmapFixture 'roadmap-conforme' (New-FlujoRoadmap 90) $rConforme
$rJ = Invoke-Verificar $dirJ
if ($rJ.Code -eq 0) { Ok "roadmap-conforme: exit 0" } else { No "roadmap-conforme: esperaba exit 0, fue $($rJ.Code)`n$($rJ.Out)" }
if ($rJ.Out -match '\[contrato-roadmap\]' -and $rJ.Out -match 'dentro de contrato') { Ok "roadmap-conforme: ROADMAP dentro de contrato" } else { No "roadmap-conforme: esperaba '[contrato-roadmap] ... dentro de contrato'`n$($rJ.Out)" }
if ($rJ.Out -match '4 items clasificados') { Ok "roadmap-conforme: conteo CORRECTO (4 items -- sub-bullet y Referencia NO cuentan)" } else { No "roadmap-conforme: esperaba '4 items clasificados'`n$($rJ.Out)" }

# ------------------------------------------------------------------ (k) item sin [alta:
# Un item bajo Normal con apetito pero SIN alta: -> BLOQUEA nombrando el item y la falta.
$rSinAlta = @(
  "# Roadmap fixture",
  "",
  "## Normal",
  "- **Item sin fecha de alta** apetito:2h -- le falta el alta"
)
$dirK = New-RoadmapFixture 'roadmap-sin-alta' (New-FlujoRoadmap 90) $rSinAlta
$rK = Invoke-Verificar $dirK
if ($rK.Code -eq 1) { Ok "roadmap-sin-alta: exit 1 (BLOQUEA)" } else { No "roadmap-sin-alta: esperaba exit 1, fue $($rK.Code)`n$($rK.Out)" }
if ($rK.Out -match 'contrato-roadmap' -and $rK.Out -match 'Item sin fecha de alta' -and $rK.Out -match 'alta:AAAA-MM-DD') { Ok "roadmap-sin-alta: acusa el item por su alta faltante" } else { No "roadmap-sin-alta: esperaba acusar el item por alta faltante`n$($rK.Out)" }

# ------------------------------------------------------------------ (l) urgente sin apetito
$rSinApetito = @(
  "# Roadmap fixture",
  "",
  "## Urgente",
  "- **Urgente sin apetito** [alta:2026-07-21] -- le falta el apetito"
)
$dirL = New-RoadmapFixture 'roadmap-sin-apetito' (New-FlujoRoadmap 90) $rSinApetito
$rL = Invoke-Verificar $dirL
if ($rL.Code -eq 1) { Ok "roadmap-sin-apetito: exit 1 (BLOQUEA)" } else { No "roadmap-sin-apetito: esperaba exit 1, fue $($rL.Code)`n$($rL.Out)" }
if ($rL.Out -match 'contrato-roadmap' -and $rL.Out -match 'apetito:Nh') { Ok "roadmap-sin-apetito: acusa el apetito faltante (Urgente lo exige)" } else { No "roadmap-sin-apetito: esperaba acusar apetito faltante`n$($rL.Out)" }

# ------------------------------------------------------------------ (m) "Con fecha" sin vence
$rSinVence = @(
  "# Roadmap fixture",
  "",
  "## Con fecha",
  "- **Con fecha pero sin vence** [alta:2026-07-20${sep}apetito:4h] -- le falta el vence"
)
$dirM = New-RoadmapFixture 'roadmap-sin-vence' (New-FlujoRoadmap 90) $rSinVence
$rM = Invoke-Verificar $dirM
if ($rM.Code -eq 1) { Ok "roadmap-sin-vence: exit 1 (BLOQUEA)" } else { No "roadmap-sin-vence: esperaba exit 1, fue $($rM.Code)`n$($rM.Out)" }
if ($rM.Out -match 'contrato-roadmap' -and $rM.Out -match 'vence:AAAA-MM-DD') { Ok "roadmap-sin-vence: acusa el vence faltante (Con fecha lo exige)" } else { No "roadmap-sin-vence: esperaba acusar vence faltante`n$($rM.Out)" }

# ------------------------------------------------------------------ (n) seccion H2 extra
# El ROADMAP no es un diario: una seccion fuera del contrato ("## Notas de la sesion")
# BLOQUEA. El item bajo ella no se clasifica (claseActual = nulo).
# ('o' acentuada reusada del setup del handoff: $o); armamos "sesion" con acento sin literal.
$rSeccionExtra = @(
  "# Roadmap fixture",
  "",
  "## Urgente",
  "- **Uno bien** [alta:2026-07-21${sep}apetito:2h]",
  "",
  "## Notas de la sesi" + $o + "n",
  "- diario que no pertenece a una cola clasificada"
)
$dirN = New-RoadmapFixture 'roadmap-seccion-extra' (New-FlujoRoadmap 90) $rSeccionExtra
$rN = Invoke-Verificar $dirN
if ($rN.Code -eq 1) { Ok "roadmap-seccion-extra: exit 1 (BLOQUEA)" } else { No "roadmap-seccion-extra: esperaba exit 1, fue $($rN.Code)`n$($rN.Out)" }
if ($rN.Out -match 'contrato-roadmap' -and $rN.Out -match 'fuera del contrato') { Ok "roadmap-seccion-extra: acusa la seccion fuera del contrato" } else { No "roadmap-seccion-extra: esperaba acusar la seccion fuera del contrato`n$($rN.Out)" }

# ------------------------------------------------------------------ (o) techo excedido
# Techo bajo (8) y un ROADMAP mas largo, todo lo demas conforme -> SOLO el techo dispara.
$rLargo = @("# Roadmap fixture", "", "## Normal")
1..10 | ForEach-Object { $rLargo += "- **Item $_** [alta:2026-07-21${sep}apetito:2h]" }
$dirO = New-RoadmapFixture 'roadmap-techo' (New-FlujoRoadmap 8) $rLargo
$rO = Invoke-Verificar $dirO
if ($rO.Code -eq 1) { Ok "roadmap-techo: exit 1 (BLOQUEA)" } else { No "roadmap-techo: esperaba exit 1, fue $($rO.Code)`n$($rO.Out)" }
if ($rO.Out -match 'contrato-roadmap' -and $rO.Out -match 'techo') { Ok "roadmap-techo: acusa el techo de lineas" } else { No "roadmap-techo: esperaba acusar el techo`n$($rO.Out)" }

# ------------------------------------------------------------------ (p) Referencia exenta
# Un item pelado bajo Referencia (sin alta/apetito/vence) NO bloquea: Referencia es
# landscape, no lleva contrato de item.
$rReferencia = @(
  "# Roadmap fixture",
  "",
  "## Referencia",
  "> landscape",
  "- **Algo declarativo** sin ningun metadato -- y aun asi exento"
)
$dirP = New-RoadmapFixture 'roadmap-referencia' (New-FlujoRoadmap 90) $rReferencia
$rP = Invoke-Verificar $dirP
if ($rP.Code -eq 0) { Ok "roadmap-referencia: exit 0 (Referencia exime a sus items)" } else { No "roadmap-referencia: esperaba exit 0, fue $($rP.Code)`n$($rP.Out)" }
if ($rP.Out -match 'dentro de contrato') { Ok "roadmap-referencia: ROADMAP dentro de contrato pese al item pelado" } else { No "roadmap-referencia: esperaba 'dentro de contrato'`n$($rP.Out)" }

# ------------------------------------------------------------------ (q) sin clave roadmap -> no aplica
# flujo.json sin la clave roadmap (aqui: {}): el check NO aplica (un repo sin el pilar no
# se bloquea), aunque el ROADMAP.md exista.
$dirQ = New-RoadmapFixture 'roadmap-sin-clave' '{}' $rConforme
$rQ = Invoke-Verificar $dirQ
if ($rQ.Code -eq 0) { Ok "roadmap-sin-clave: exit 0 (sin la clave roadmap el check no aplica)" } else { No "roadmap-sin-clave: esperaba exit 0, fue $($rQ.Code)`n$($rQ.Out)" }
if ($rQ.Out -notmatch 'contrato-roadmap') { Ok "roadmap-sin-clave: el check NO aparece sin la clave roadmap" } else { No "roadmap-sin-clave: el check no deberia aparecer sin la clave roadmap`n$($rQ.Out)" }

# ------------------------------------------------------------------ (r) roadmap incompleto -> falla cerrado
# roadmap:{} sin techo_lineas: config incompleta es tan invalida como corrupta -> exit 2
# (falla cerrado), no un falso bloqueo. ROADMAP conforme a proposito: lo dicta la config rota.
$dirR = New-RoadmapFixture 'roadmap-incompleto' '{ "roadmap": {} }' $rConforme
$rR = Invoke-Verificar $dirR
if ($rR.Code -eq 2) { Ok "roadmap-incompleto: exit 2 (falla cerrado, techo_lineas requerida)" } else { No "roadmap-incompleto: esperaba exit 2, fue $($rR.Code)`n$($rR.Out)" }
if ($rR.Out -match 'incompleta') { Ok "roadmap-incompleto: acusa la clave roadmap incompleta" } else { No "roadmap-incompleto: esperaba mensaje de clave incompleta`n$($rR.Out)" }

# ------------------------------------------------------------------ limpieza
Remove-Item -LiteralPath $tmpRoot -Recurse -Force -ErrorAction SilentlyContinue

Write-Host ""
if ($script:fail -gt 0) {
  Write-Host "== Pilar de flujo (HANDOFF+ROADMAP) INCOMPLETO: $($script:fail) fallo(s), $($script:pass) ok. ==" -ForegroundColor Red
  exit 1
}
Write-Host "== Pilar de flujo (HANDOFF+ROADMAP) sano: $($script:pass) verificaciones verdes. =="
exit 0
