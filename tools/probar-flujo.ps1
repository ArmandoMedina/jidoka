#Requires -Version 5
# probar-flujo.ps1 - self-test del pilar de flujo (FLU-1, ADR 0049): los contratos del
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
#
# Casos del CHANGELOG (check [contrato-changelog], flujo.json SOLO con la clave changelog):
# se mide SOLO la seccion TOPE (del primer '## [' al siguiente). (z1) tope conforme (header
# datado con guion largo, bullets tipados + un ADR, prosa breve) -> exit 0 y conteo; (z2)
# header sin fecha -> exit 1; (z3) bullet sin tipo ('- arregle cosas') -> exit 1 nombrandolo;
# (z4) bullet '- **ADR 0099** - ...' -> ACEPTADO (exit 0); (z5) prosa de 12 lineas con max 8
# -> exit 1 'no carta'; (z6) segunda seccion vieja con bullets sin tipo -> exit 0 (solo el
# tope se mide, no es retroactivo); (z7) sin clave changelog -> el check no aplica, exit 0;
# (z8) changelog:{} incompleto -> exit 2 (falla cerrado).
#
# Casos de la EXPIRACION (tools/expirar.ps1, el circuit breaker; fixtures con -Repo + -Hoy
# inyectada): (s) 1 Normal vencido (alta hace 100 dias) -> expirar SIN -Simular: exit 0, el
# item ya NO esta en ROADMAP, SI esta en MUERTOS con motivo y fecha, y el ROADMAP resultante
# sigue pasando [contrato-roadmap]; (t) -Simular NO modifica nada (ROADMAP y MUERTOS byte-
# iguales) y anuncia el vencido; (u) segunda corrida -> 0 vencidos y sin doble entrada
# (idempotencia); (v) "Con fecha" con vence: pasado -> muere; (w) Referencia vieja -> NO muere;
# (x) flujo sin vencimiento_dias -> "no aplica" exit 0; (y) "Algun dia" con alta hace 200 dias
# (ventana 180) -> muere. Se ejecuta la mecanica REAL con -Hoy anclada a 2026-07-21.
#
# Casos del LIMITE WIP (tools/estado-flujo.ps1 -Gate, el muro de entrada de /jidoka:planea;
# fixtures con flujo.json SOLO con la clave estado): (w1) 1 gemba pendiente (aceptado:false)
# -> exit 1, la salida NOMBRA el id y trae "ABRIR SPRINT NUEVO BLOQUEADO"; (w2) el mismo con
# aceptado:true -> exit 0 "flujo despejado"; (w3) flujo.json sin clave estado -> "no aplica"
# exit 0; (w4) flujo.json corrupto -> exit 2 (falla cerrado); (w5) entrada sin id -> AVISO +
# cuenta como pendiente (exit 1, fail-safe: lo dudoso bloquea); (w6) estado presente pero
# gembas_pendientes ausente -> exit 0 (lista vacia).
#
# Casos de la VISTA (tools/estado-flujo.ps1 -Json y el resumen default, R6): (j1) -Json
# sobre un fixture completo (roadmap con 1 urgente + 1 con fecha + 2 normal, uno con
# espera:Marcelo, + MUERTOS con una entrada) parsea con ConvertFrom-Json: version 1,
# siguientes[0] es el Urgente, esperando_terceros trae a Marcelo, muertos_recientes no
# vacio, conteos correctos; (j2) -Json sin ROADMAP -> JSON valido con claves vacias,
# exit 0; (j3) el resumen default imprime "Sprint activo" y "Siguen:"; (j4) -Json con
# flujo.json corrupto -> exit 2 (falla cerrado, como el gate).
#
# Casos del REPORTE para terceros (tools/reporte-avance.ps1, R7 -- es VISTA, no gate):
# (r1) sobre el repo REAL genera el .html con exit 0, trae los 5 titulos de seccion y NO
# contiene NINGUNA jerga prohibida (grep case-insensitive de: gate, WIP, commit, "PR ",
# rebanada -- el reporte se le manda tal cual a un tercero no-tecnico); (r2) sobre un fixture
# minimo SIN docs/MUERTOS.md ni tools/flujo.json genera sin tronar (degrada con gracia) y la
# seccion 4 dice "Nada se ha descartado"; (r3) el .html trae el hill chart (`<svg`).

# Continue (no Stop): este test hace shell-out al verificar real, y el caso corrupto (f)
# hace que el hijo escriba a stderr (el error de ConvertFrom-Json). Con 2>&1 + Stop, PS 5.1
# promueve ese stderr nativo a un NativeCommandError TERMINANTE que abortaria el harness
# antes de poder afirmar el exit 2 -- el mismo gotcha que publicar.ps1 evita con Continue.
$ErrorActionPreference = 'Continue'
$veri = Join-Path $PSScriptRoot 'verificar.ps1'
if (-not (Test-Path $veri)) { Write-Host "  [FALLA] no existe tools/verificar.ps1 (el gate que este test ejercita)" -ForegroundColor Red; exit 1 }
$expi = Join-Path $PSScriptRoot 'expirar.ps1'
if (-not (Test-Path $expi)) { Write-Host "  [FALLA] no existe tools/expirar.ps1 (la mecanica que este test ejercita)" -ForegroundColor Red; exit 1 }
$esti = Join-Path $PSScriptRoot 'estado-flujo.ps1'
if (-not (Test-Path $esti)) { Write-Host "  [FALLA] no existe tools/estado-flujo.ps1 (la mecanica que este test ejercita)" -ForegroundColor Red; exit 1 }
$repo = Join-Path $PSScriptRoot 'reporte-avance.ps1'
if (-not (Test-Path $repo)) { Write-Host "  [FALLA] no existe tools/reporte-avance.ps1 (la vista que este test ejercita)" -ForegroundColor Red; exit 1 }

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

# ==== Procedencia (R1, ADR 0057): opt-in roadmap.procedencia=true. Cada item vivo cita de
# donde vino -- informe docs/analisis/, record docs/sprints/, ADR (link o 'ADR NNNN' textual)
# o #issue. Off por defecto (New-FlujoRoadmap NO la trae): un hijo que no la adopta no se rompe.
function New-FlujoRoadmapProc($techo) {
  return @"
{
  "roadmap": {
    "techo_lineas": $techo,
    "historico": "docs/roadmap-historico.md",
    "procedencia": true
  }
}
"@
}

# ------------------------------------------------------------------ (r1p) ON + informe -> verde
$rProcOk = @(
  "# Roadmap fixture",
  "",
  "## Normal",
  "- **Item con origen** [alta:2026-07-21${sep}apetito:2h] -- medido en [informe](docs/analisis/algo-202607.md)"
)
$dirRP1 = New-RoadmapFixture 'roadmap-proc-ok' (New-FlujoRoadmapProc 90) $rProcOk
$rRP1 = Invoke-Verificar $dirRP1
if ($rRP1.Code -eq 0) { Ok "roadmap-proc-ok: exit 0 (item con puntero docs/analisis/ pasa)" } else { No "roadmap-proc-ok: esperaba exit 0, fue $($rRP1.Code)`n$($rRP1.Out)" }

# ------------------------------------------------------------------ (r2p) ON + sin puntero -> ROJO
$rProcNo = @(
  "# Roadmap fixture",
  "",
  "## Normal",
  "- **Item huerfano** [alta:2026-07-21${sep}apetito:2h] -- no dice de donde vino"
)
$dirRP2 = New-RoadmapFixture 'roadmap-proc-sin' (New-FlujoRoadmapProc 90) $rProcNo
$rRP2 = Invoke-Verificar $dirRP2
if ($rRP2.Code -eq 1) { Ok "roadmap-proc-sin: exit 1 (BLOQUEA -- item sin procedencia)" } else { No "roadmap-proc-sin: esperaba exit 1, fue $($rRP2.Code)`n$($rRP2.Out)" }
if ($rRP2.Out -match 'contrato-roadmap' -and $rRP2.Out -match 'procedencia') { Ok "roadmap-proc-sin: acusa la procedencia faltante" } else { No "roadmap-proc-sin: esperaba acusar procedencia`n$($rRP2.Out)" }

# ------------------------------------------------------------------ (r3p) ON + ADR textual / #issue -> verde
$rProcAdr = @(
  "# Roadmap fixture",
  "",
  "## Normal",
  "- **Uno por ADR** [alta:2026-07-20${sep}apetito:4h] -- converger el motor (ADR 0015)",
  "- **Uno por issue** [alta:2026-07-20${sep}apetito:2h] -- alimenta el issue #67"
)
$dirRP3 = New-RoadmapFixture 'roadmap-proc-adr' (New-FlujoRoadmapProc 90) $rProcAdr
$rRP3 = Invoke-Verificar $dirRP3
if ($rRP3.Code -eq 0) { Ok "roadmap-proc-adr: exit 0 (ADR textual y #issue cuentan como procedencia)" } else { No "roadmap-proc-adr: esperaba exit 0, fue $($rRP3.Code)`n$($rRP3.Out)" }

# ------------------------------------------------------------------ (r4p) OFF (default) -> no se exige
# El item huerfano de (r2p) pasa cuando el opt-in NO esta: la regla es opt-in, el hijo no se rompe.
$dirRP4 = New-RoadmapFixture 'roadmap-proc-off' (New-FlujoRoadmap 90) $rProcNo
$rRP4 = Invoke-Verificar $dirRP4
if ($rRP4.Code -eq 0) { Ok "roadmap-proc-off: exit 0 (sin el opt-in la procedencia NO se exige -- hijo intacto)" } else { No "roadmap-proc-off: esperaba exit 0, fue $($rRP4.Code)`n$($rRP4.Out)" }

# ------------------------------------------------------------------ (r5p) aplica tambien a Algun dia
$rProcIce = @(
  "# Roadmap fixture",
  "",
  $hAlgunDia,
  "- **Icebox huerfano** [alta:2026-07-13] -- sin origen; el icebox tambien lo exige"
)
$dirRP5 = New-RoadmapFixture 'roadmap-proc-icebox' (New-FlujoRoadmapProc 90) $rProcIce
$rRP5 = Invoke-Verificar $dirRP5
if ($rRP5.Code -eq 1 -and $rRP5.Out -match 'procedencia') { Ok "roadmap-proc-icebox: exit 1 (procedencia aplica a TODA clase viva, incluido el icebox)" } else { No "roadmap-proc-icebox: esperaba exit 1 por procedencia, fue $($rRP5.Code)`n$($rRP5.Out)" }

# ==== Guion de revision (R2, ADR 0057 enmienda): opt-in roadmap.guion_revision=true. Cada item
# EJECUTABLE (Urgente/Con fecha/Normal) declara COMO se revisa: cita un informe docs/analisis/
# con seccion "Que debe revisar el dueno", o un record docs/sprints/ (guion por molde). El icebox
# 'Algun dia' va EXENTO (no es ejecutable). Off por defecto.
function New-FlujoRoadmapGuion($techo) {
  return @"
{
  "roadmap": {
    "techo_lineas": $techo,
    "historico": "docs/roadmap-historico.md",
    "guion_revision": true
  }
}
"@
}
function Add-Informe($dir, $rel, $lines) {
  $full = Join-Path $dir $rel
  New-Item -ItemType Directory -Path (Split-Path $full -Parent) -Force | Out-Null
  [System.IO.File]::WriteAllLines($full, [string[]]$lines, $utf8NoBom)
}
$informeConGuion = @("# Informe fixture", "", "## Que debe revisar el dueno (guion)", "- paso 1", "- paso 2")
$informeSinGuion = @("# Informe fixture", "", "## Resultados", "- algo medido, pero sin guion de revision")

# ------------------------------------------------------------------ (g1) ON + informe con guion -> verde
$rGui1 = @(
  "# Roadmap fixture",
  "",
  "## Normal",
  "- **Item con guion** [alta:2026-07-21${sep}apetito:2h] -- ver [informe](docs/analisis/con-guion-202607.md)"
)
$dirG1 = New-RoadmapFixture 'roadmap-guion-ok' (New-FlujoRoadmapGuion 90) $rGui1
Add-Informe $dirG1 'docs/analisis/con-guion-202607.md' $informeConGuion
$rG1 = Invoke-Verificar $dirG1
if ($rG1.Code -eq 0) { Ok "roadmap-guion-ok: exit 0 (informe citado trae la seccion de guion)" } else { No "roadmap-guion-ok: esperaba exit 0, fue $($rG1.Code)`n$($rG1.Out)" }

# ------------------------------------------------------------------ (g2) ON + informe SIN guion -> ROJO
$rGui2 = @(
  "# Roadmap fixture",
  "",
  "## Normal",
  "- **Item sin guion** [alta:2026-07-21${sep}apetito:2h] -- ver [informe](docs/analisis/sin-guion-202607.md)"
)
$dirG2 = New-RoadmapFixture 'roadmap-guion-sin' (New-FlujoRoadmapGuion 90) $rGui2
Add-Informe $dirG2 'docs/analisis/sin-guion-202607.md' $informeSinGuion
$rG2 = Invoke-Verificar $dirG2
if ($rG2.Code -eq 1) { Ok "roadmap-guion-sin: exit 1 (BLOQUEA -- el informe citado no trae guion)" } else { No "roadmap-guion-sin: esperaba exit 1, fue $($rG2.Code)`n$($rG2.Out)" }
if ($rG2.Out -match 'contrato-roadmap' -and $rG2.Out -match 'guion de revision') { Ok "roadmap-guion-sin: acusa el guion de revision faltante" } else { No "roadmap-guion-sin: esperaba acusar guion de revision`n$($rG2.Out)" }

# ------------------------------------------------------------------ (g3) ON + record de sprint -> verde
$rGui3 = @(
  "# Roadmap fixture",
  "",
  "## Con fecha",
  "- **Item por sprint** [alta:2026-07-20${sep}vence:2026-08-04${sep}apetito:4h] -- pasos en [entrega](docs/sprints/sprint-21-foo-entrega.md)"
)
$dirG3 = New-RoadmapFixture 'roadmap-guion-sprint' (New-FlujoRoadmapGuion 90) $rGui3
$rG3 = Invoke-Verificar $dirG3
if ($rG3.Code -eq 0) { Ok "roadmap-guion-sprint: exit 0 (un record docs/sprints/ cuenta como guion por molde)" } else { No "roadmap-guion-sprint: esperaba exit 0, fue $($rG3.Code)`n$($rG3.Out)" }

# ------------------------------------------------------------------ (g4) ON + icebox sin guion -> EXENTO
$rGui4 = @(
  "# Roadmap fixture",
  "",
  $hAlgunDia,
  "- **Icebox sin guion** [alta:2026-07-13] -- no es ejecutable, va exento del guion"
)
$dirG4 = New-RoadmapFixture 'roadmap-guion-icebox' (New-FlujoRoadmapGuion 90) $rGui4
$rG4 = Invoke-Verificar $dirG4
if ($rG4.Code -eq 0) { Ok "roadmap-guion-icebox: exit 0 (el icebox 'Algun dia' va EXENTO del guion -- no es ejecutable)" } else { No "roadmap-guion-icebox: esperaba exit 0, fue $($rG4.Code)`n$($rG4.Out)" }

# ------------------------------------------------------------------ (g5) OFF (default) -> no se exige
$dirG5 = New-RoadmapFixture 'roadmap-guion-off' (New-FlujoRoadmap 90) $rGui2
Add-Informe $dirG5 'docs/analisis/sin-guion-202607.md' $informeSinGuion
$rG5 = Invoke-Verificar $dirG5
if ($rG5.Code -eq 0) { Ok "roadmap-guion-off: exit 0 (sin el opt-in el guion NO se exige -- hijo intacto)" } else { No "roadmap-guion-off: esperaba exit 0, fue $($rG5.Code)`n$($rG5.Out)" }

# ------------------------------------------------------------------ (g6) path traversal -> NO cuenta como guion
# Seguridad (R2): un item cita 'docs/analisis/../../fuera.md'. El regex 'docs/analisis/[^\s)]+\.md'
# casa ESA ruta con '..' adentro; sin el guardia, Test-Path la resuelve a fuera.md FUERA de
# docs/analisis/ (aqui, la raiz del fixture) y -- si trae el encabezado de guion -- satisface el
# gate leyendo un .md ajeno (PoC: exit 0 con un archivo externo). Con el guardia, '..' se rechaza
# como puntero invalido: el item queda SIN guion -> BLOQUEA (exit 1). El fuera.md SI trae el
# encabezado a proposito: lo que bloquea es el traversal, no la ausencia de la seccion.
$rGui6 = @(
  "# Roadmap fixture",
  "",
  "## Normal",
  "- **Item con traversal** [alta:2026-07-21${sep}apetito:2h] -- ver [informe](docs/analisis/../../fuera.md)"
)
$dirG6 = New-RoadmapFixture 'roadmap-guion-traversal' (New-FlujoRoadmapGuion 90) $rGui6
Add-Informe $dirG6 'fuera.md' $informeConGuion   # FUERA de docs/analisis/ (raiz del fixture)
$rG6 = Invoke-Verificar $dirG6
if ($rG6.Code -eq 1) { Ok "roadmap-guion-traversal: exit 1 (el traversal '..' NO cuenta como guion -- PoC bloqueado)" } else { No "roadmap-guion-traversal: esperaba exit 1 (traversal bloqueado), fue $($rG6.Code)`n$($rG6.Out)" }
if ($rG6.Out -match 'contrato-roadmap' -and $rG6.Out -match 'guion de revision') { Ok "roadmap-guion-traversal: acusa el guion faltante (el .md externo no lo satisface)" } else { No "roadmap-guion-traversal: esperaba acusar guion de revision`n$($rG6.Out)" }

# ------------------------------------------------------------------ (g7) legitimo sin '..' SIGUE pasando
# El guardia del traversal no debe romper el camino feliz: un 'docs/analisis/con-guion.md' sin
# '..', dentro de docs/analisis/, con la seccion de guion, SIGUE contando como guion -> exit 0.
$rGui7 = @(
  "# Roadmap fixture",
  "",
  "## Normal",
  "- **Item con guion legitimo** [alta:2026-07-21${sep}apetito:2h] -- ver [informe](docs/analisis/con-guion.md)"
)
$dirG7 = New-RoadmapFixture 'roadmap-guion-legitimo' (New-FlujoRoadmapGuion 90) $rGui7
Add-Informe $dirG7 'docs/analisis/con-guion.md' $informeConGuion
$rG7 = Invoke-Verificar $dirG7
if ($rG7.Code -eq 0) { Ok "roadmap-guion-legitimo: exit 0 (informe legitimo sin '..' sigue contando como guion)" } else { No "roadmap-guion-legitimo: esperaba exit 0, fue $($rG7.Code)`n$($rG7.Out)" }

Write-Host ""
Write-Host "== Contrato del CHANGELOG (check [contrato-changelog]): fixtures ROJO->VERDE =="

# Guion largo (U+2014) y backtick reales, armados sin literal (esta fuente es ASCII a
# proposito): asi el CHANGELOG-fixture trae el header datado y los tipos entre backticks
# como el CHANGELOG real.
$emd = [char]0x2014
$bt2 = [char]0x60
$tiposFull = '["feat","fix","test","docs","chore","breaking"]'

function New-FlujoChangelog($tiposJson, $maxProsa) {
  # JSON valido SOLO con la clave changelog: sin handoff/roadmap, los checks hermanos no aplican.
  return @"
{
  "changelog": {
    "tipos": $tiposJson,
    "max_prosa_lineas": $maxProsa
  }
}
"@
}

function New-ChangelogFixture($nombre, $flujoTexto, $changelogLines) {
  $dir = Join-Path $tmpRoot $nombre
  New-Item -ItemType Directory -Path (Join-Path $dir 'tools') -Force | Out-Null
  if ($null -ne $flujoTexto) {
    [System.IO.File]::WriteAllText((Join-Path $dir 'tools/flujo.json'), $flujoTexto, $utf8NoBom)
  }
  # HANDOFF trivial: sin la clave handoff el check hermano no aplica y no ensucia el veredicto.
  [System.IO.File]::WriteAllLines((Join-Path $dir 'HANDOFF.md'), [string[]]@("# HANDOFF fixture"), $utf8NoBom)
  [System.IO.File]::WriteAllLines((Join-Path $dir 'CHANGELOG.md'), [string[]]$changelogLines, $utf8NoBom)
  return $dir
}

# ------------------------------------------------------------------ (z1) tope conforme
# Header datado con guion largo real, un subtitulo '### ' (no cuenta como prosa), 1 linea de
# prosa, y 3 bullets conformes (feat + fix tipados + un ADR). Conteo esperado: 3 bullets, prosa 1/8.
$clConforme = @(
  "# Changelog fixture",
  "",
  "## [1.2.0] $emd 2026-07-21",
  "",
  "### Subtitulo que no cuenta como prosa",
  "",
  "prosa breve de una sola linea",
  "",
  "- **${bt2}feat${bt2}** algo nuevo",
  "- **${bt2}fix${bt2}** algo arreglado",
  "- **ADR 0099** una decision de la casa"
)
$dirZ1 = New-ChangelogFixture 'changelog-conforme' (New-FlujoChangelog $tiposFull 8) $clConforme
$rZ1 = Invoke-Verificar $dirZ1
if ($rZ1.Code -eq 0) { Ok "changelog-conforme: exit 0" } else { No "changelog-conforme: esperaba exit 0, fue $($rZ1.Code)`n$($rZ1.Out)" }
if ($rZ1.Out -match '\[contrato-changelog\]' -and $rZ1.Out -match 'dentro de contrato') { Ok "changelog-conforme: seccion tope dentro de contrato" } else { No "changelog-conforme: esperaba '[contrato-changelog] ... dentro de contrato'`n$($rZ1.Out)" }
if ($rZ1.Out -match '3 bullets tipados' -and $rZ1.Out -match 'prosa 1/8') { Ok "changelog-conforme: conteo CORRECTO (3 bullets tipados, prosa 1/8 -- el '### ' no cuenta)" } else { No "changelog-conforme: esperaba '3 bullets tipados' y 'prosa 1/8'`n$($rZ1.Out)" }

# ------------------------------------------------------------------ (z2) header sin fecha
$clSinFecha = @(
  "# Changelog fixture",
  "",
  "## [1.2.0]",
  "",
  "- **${bt2}feat${bt2}** algo nuevo"
)
$dirZ2 = New-ChangelogFixture 'changelog-sin-fecha' (New-FlujoChangelog $tiposFull 8) $clSinFecha
$rZ2 = Invoke-Verificar $dirZ2
if ($rZ2.Code -eq 1) { Ok "changelog-sin-fecha: exit 1 (BLOQUEA)" } else { No "changelog-sin-fecha: esperaba exit 1, fue $($rZ2.Code)`n$($rZ2.Out)" }
if ($rZ2.Out -match 'contrato-changelog' -and $rZ2.Out -match 'header') { Ok "changelog-sin-fecha: acusa el header sin fecha" } else { No "changelog-sin-fecha: esperaba acusar el header`n$($rZ2.Out)" }

# ------------------------------------------------------------------ (z3) bullet sin tipo
$clSinTipo = @(
  "# Changelog fixture",
  "",
  "## [1.2.0] $emd 2026-07-21",
  "",
  "- arregle cosas"
)
$dirZ3 = New-ChangelogFixture 'changelog-sin-tipo' (New-FlujoChangelog $tiposFull 8) $clSinTipo
$rZ3 = Invoke-Verificar $dirZ3
if ($rZ3.Code -eq 1) { Ok "changelog-sin-tipo: exit 1 (BLOQUEA)" } else { No "changelog-sin-tipo: esperaba exit 1, fue $($rZ3.Code)`n$($rZ3.Out)" }
if ($rZ3.Out -match 'contrato-changelog' -and $rZ3.Out -match 'arregle cosas' -and $rZ3.Out -match 'no declara su tipo') { Ok "changelog-sin-tipo: acusa el bullet '- arregle cosas' por su tipo faltante" } else { No "changelog-sin-tipo: esperaba acusar el bullet por tipo faltante`n$($rZ3.Out)" }

# ------------------------------------------------------------------ (z4) bullet ADR aceptado
# Un unico bullet '- **ADR 0099** - ...': la voz de la casa se acepta como bullet tipado.
$clADR = @(
  "# Changelog fixture",
  "",
  "## [1.2.0] $emd 2026-07-21",
  "",
  "- **ADR 0099** $emd una decision de la casa"
)
$dirZ4 = New-ChangelogFixture 'changelog-adr' (New-FlujoChangelog $tiposFull 8) $clADR
$rZ4 = Invoke-Verificar $dirZ4
if ($rZ4.Code -eq 0) { Ok "changelog-adr: exit 0 (el bullet 'ADR ' se acepta)" } else { No "changelog-adr: esperaba exit 0, fue $($rZ4.Code)`n$($rZ4.Out)" }
if ($rZ4.Out -match 'dentro de contrato' -and $rZ4.Out -match '1 bullets tipados') { Ok "changelog-adr: la seccion tope pasa con 1 bullet ADR" } else { No "changelog-adr: esperaba 'dentro de contrato' con 1 bullet`n$($rZ4.Out)" }

# ------------------------------------------------------------------ (z5) prosa de carta
# 12 lineas de prosa antes del primer bullet, con max 8 -> BLOQUEA 'no carta'.
$clProsa = @(
  "# Changelog fixture",
  "",
  "## [1.2.0] $emd 2026-07-21",
  ""
)
1..12 | ForEach-Object { $clProsa += "linea de prosa numero $_" }
$clProsa += ""
$clProsa += "- **${bt2}feat${bt2}** al fin un bullet"
$dirZ5 = New-ChangelogFixture 'changelog-prosa' (New-FlujoChangelog $tiposFull 8) $clProsa
$rZ5 = Invoke-Verificar $dirZ5
if ($rZ5.Code -eq 1) { Ok "changelog-prosa: exit 1 (BLOQUEA)" } else { No "changelog-prosa: esperaba exit 1, fue $($rZ5.Code)`n$($rZ5.Out)" }
if ($rZ5.Out -match 'contrato-changelog' -and $rZ5.Out -match 'no carta') { Ok "changelog-prosa: acusa la prosa de carta (12 > 8)" } else { No "changelog-prosa: esperaba acusar la prosa 'no carta'`n$($rZ5.Out)" }

# ------------------------------------------------------------------ (z6) solo el tope se mide
# Tope [1.2.0] conforme; una segunda seccion vieja [1.1.0] con bullets sin tipo -> exit 0
# (no es retroactivo: la historia no se re-mide).
$clRetro = @(
  "# Changelog fixture",
  "",
  "## [1.2.0] $emd 2026-07-21",
  "",
  "- **${bt2}feat${bt2}** el tope si cumple",
  "",
  "## [1.1.0] $emd 2026-07-20",
  "- esto es historia vieja sin tipo",
  "- tampoco esto tiene tipo"
)
$dirZ6 = New-ChangelogFixture 'changelog-retro' (New-FlujoChangelog $tiposFull 8) $clRetro
$rZ6 = Invoke-Verificar $dirZ6
if ($rZ6.Code -eq 0) { Ok "changelog-retro: exit 0 (solo la seccion tope se mide, no es retroactivo)" } else { No "changelog-retro: esperaba exit 0, fue $($rZ6.Code)`n$($rZ6.Out)" }
if ($rZ6.Out -match 'dentro de contrato' -and $rZ6.Out -match '1 bullets tipados') { Ok "changelog-retro: solo el bullet del tope cuenta (1), la historia vieja no se mide" } else { No "changelog-retro: esperaba 'dentro de contrato' con 1 bullet del tope`n$($rZ6.Out)" }

# ------------------------------------------------------------------ (z7) sin clave changelog -> no aplica
# flujo.json sin la clave changelog (aqui: {}): el check NO aplica aunque el CHANGELOG exista.
$dirZ7 = New-ChangelogFixture 'changelog-sin-clave' '{}' $clConforme
$rZ7 = Invoke-Verificar $dirZ7
if ($rZ7.Code -eq 0) { Ok "changelog-sin-clave: exit 0 (sin la clave changelog el check no aplica)" } else { No "changelog-sin-clave: esperaba exit 0, fue $($rZ7.Code)`n$($rZ7.Out)" }
if ($rZ7.Out -notmatch 'contrato-changelog') { Ok "changelog-sin-clave: el check NO aparece sin la clave changelog" } else { No "changelog-sin-clave: el check no deberia aparecer sin la clave`n$($rZ7.Out)" }

# ------------------------------------------------------------------ (z8) changelog:{} -> falla cerrado
# changelog:{} sin tipos ni max_prosa_lineas: config incompleta es tan invalida como corrupta
# -> exit 2 (falla cerrado). CHANGELOG conforme a proposito: lo dicta la config rota.
$dirZ8 = New-ChangelogFixture 'changelog-incompleto' '{ "changelog": {} }' $clConforme
$rZ8 = Invoke-Verificar $dirZ8
if ($rZ8.Code -eq 2) { Ok "changelog-incompleto: exit 2 (falla cerrado, tipos/max_prosa_lineas requeridos)" } else { No "changelog-incompleto: esperaba exit 2, fue $($rZ8.Code)`n$($rZ8.Out)" }
if ($rZ8.Out -match 'incompleta') { Ok "changelog-incompleto: acusa la clave changelog incompleta" } else { No "changelog-incompleto: esperaba mensaje de clave incompleta`n$($rZ8.Out)" }

Write-Host ""
Write-Host "== La expiracion (tools/expirar.ps1, circuit breaker): fixtures con -Hoy inyectada =="

# Ancla de fecha para TODA la seccion: la mecanica se corre con -Hoy 2026-07-21 (no la del
# sistema), asi el test es reproducible. Las 'alta' se derivan del ancla (hace N dias).
$ci = [System.Globalization.CultureInfo]::InvariantCulture
$anchor = '2026-07-21'
$hoyDt = [datetime]::ParseExact($anchor, 'yyyy-MM-dd', $ci)
$alta100 = $hoyDt.AddDays(-100).ToString('yyyy-MM-dd')   # Normal (90d): vencido
$alta200 = $hoyDt.AddDays(-200).ToString('yyyy-MM-dd')   # Algun dia (180d): vencido
$altaFresca = $hoyDt.AddDays(-5).ToString('yyyy-MM-dd')  # Normal: sobrevive de sobra

function New-FlujoExpirar($techo) {
  # flujo.json completo para expirar: roadmap con techo (para el contrato) + muertos +
  # vencimiento_dias por clase. Sin la clave handoff -> el check hermano no aplica.
  return @"
{
  "roadmap": {
    "techo_lineas": $techo,
    "historico": "docs/roadmap-historico.md",
    "muertos": "docs/MUERTOS.md",
    "vencimiento_dias": { "urgente": 14, "normal": 90, "algun-dia": 180 }
  }
}
"@
}

function New-ExpirarFixture($nombre, $flujoTexto, $roadmapLines) {
  $dir = Join-Path $tmpRoot $nombre
  New-Item -ItemType Directory -Path (Join-Path $dir 'tools') -Force | Out-Null
  New-Item -ItemType Directory -Path (Join-Path $dir 'docs') -Force | Out-Null
  if ($null -ne $flujoTexto) {
    [System.IO.File]::WriteAllText((Join-Path $dir 'tools/flujo.json'), $flujoTexto, $utf8NoBom)
  }
  [System.IO.File]::WriteAllLines((Join-Path $dir 'HANDOFF.md'), [string[]]@("# HANDOFF fixture"), $utf8NoBom)
  [System.IO.File]::WriteAllLines((Join-Path $dir 'ROADMAP.md'), [string[]]$roadmapLines, $utf8NoBom)
  # MUERTOS sembrado con header (como la nave): expirar appendea bajo el.
  [System.IO.File]::WriteAllLines((Join-Path $dir 'docs/MUERTOS.md'), [string[]]@("# Muertos fixture", ""), $utf8NoBom)
  return $dir
}

function Invoke-Expirar($dir, $simular) {
  $a = @('-NoProfile','-ExecutionPolicy','Bypass','-File',$expi,'-Repo',$dir,'-Hoy',$anchor)
  if ($simular) { $a += '-Simular' }
  $out = (& powershell @a 2>&1 | Out-String)
  return @{ Out = $out; Code = $LASTEXITCODE }
}
function Read-Text($p) { return [System.IO.File]::ReadAllText($p, $utf8NoBom) }

# ------------------------------------------------------------------ (s) Normal vencido muere
$rExp = @(
  "# Roadmap fixture",
  "",
  "## Normal",
  "- **Item vencido de sobra** [alta:$alta100${sep}apetito:2h] -- deberia morir por ventana Normal",
  "- **Item fresco** [alta:$altaFresca${sep}apetito:2h] -- sobrevive"
)
$dirS = New-ExpirarFixture 'expira-normal' (New-FlujoExpirar 90) $rExp
$rS = Invoke-Expirar $dirS $false
$roadmapS = Read-Text (Join-Path $dirS 'ROADMAP.md')
$muertosS = Read-Text (Join-Path $dirS 'docs/MUERTOS.md')
if ($rS.Code -eq 0) { Ok "expira-normal: exit 0" } else { No "expira-normal: esperaba exit 0, fue $($rS.Code)`n$($rS.Out)" }
if ($roadmapS -notmatch 'Item vencido de sobra') { Ok "expira-normal: el vencido YA NO esta en ROADMAP" } else { No "expira-normal: el vencido sigue en ROADMAP`n$roadmapS" }
if ($roadmapS -match 'Item fresco') { Ok "expira-normal: el fresco SIGUE en ROADMAP" } else { No "expira-normal: el fresco desaparecio del ROADMAP`n$roadmapS" }
if ($muertosS -match 'Item vencido de sobra' -and $muertosS -match "## $anchor" -and $muertosS -match "alta $alta100" -and $muertosS -match 'revive re-proponi') { Ok "expira-normal: el vencido esta en MUERTOS con motivo y fecha de hoy" } else { No "expira-normal: MUERTOS no trae el vencido con motivo/fecha`n$muertosS" }
# El ROADMAP resultante sigue pasando el contrato [contrato-roadmap].
$rSveri = Invoke-Verificar $dirS
if ($rSveri.Code -eq 0 -and $rSveri.Out -match 'contrato-roadmap' -and $rSveri.Out -match 'dentro de contrato') { Ok "expira-normal: el ROADMAP podado sigue dentro de [contrato-roadmap]" } else { No "expira-normal: el ROADMAP tras expirar rompe el contrato (exit $($rSveri.Code))`n$($rSveri.Out)" }

# ------------------------------------------------------------------ (t) -Simular no toca nada
$dirT = New-ExpirarFixture 'expira-simula' (New-FlujoExpirar 90) $rExp
$roadmapAntes = Read-Text (Join-Path $dirT 'ROADMAP.md')
$muertosAntes = Read-Text (Join-Path $dirT 'docs/MUERTOS.md')
$rT = Invoke-Expirar $dirT $true
$roadmapDespues = Read-Text (Join-Path $dirT 'ROADMAP.md')
$muertosDespues = Read-Text (Join-Path $dirT 'docs/MUERTOS.md')
if ($rT.Code -eq 0) { Ok "expira-simula: exit 0" } else { No "expira-simula: esperaba exit 0, fue $($rT.Code)`n$($rT.Out)" }
if ($roadmapAntes -eq $roadmapDespues -and $muertosAntes -eq $muertosDespues) { Ok "expira-simula: -Simular NO modifico ni ROADMAP ni MUERTOS (byte-iguales)" } else { No "expira-simula: -Simular altero un archivo (dry-run roto)" }
if ($rT.Out -match '\[SIMULA\]' -and $rT.Out -match 'Item vencido de sobra') { Ok "expira-simula: anuncia el vencido con prefijo [SIMULA]" } else { No "expira-simula: no anuncio el vencido en dry-run`n$($rT.Out)" }

# ------------------------------------------------------------------ (u) idempotencia
$dirU = New-ExpirarFixture 'expira-idempotente' (New-FlujoExpirar 90) $rExp
$rU1 = Invoke-Expirar $dirU $false
$roadmapU1 = Read-Text (Join-Path $dirU 'ROADMAP.md')
$rU2 = Invoke-Expirar $dirU $false
$roadmapU2 = Read-Text (Join-Path $dirU 'ROADMAP.md')
$muertosU2 = Read-Text (Join-Path $dirU 'docs/MUERTOS.md')
if ($rU2.Code -eq 0 -and $rU2.Out -match '0 vencidos') { Ok "expira-idempotente: la 2a corrida dice '0 vencidos'" } else { No "expira-idempotente: la 2a corrida no reporto 0 vencidos (exit $($rU2.Code))`n$($rU2.Out)" }
if ($roadmapU1 -eq $roadmapU2) { Ok "expira-idempotente: el ROADMAP no cambio en la 2a corrida" } else { No "expira-idempotente: la 2a corrida volvio a tocar el ROADMAP" }
if (([regex]::Matches($muertosU2, "## $anchor")).Count -eq 1) { Ok "expira-idempotente: MUERTOS tiene UNA sola entrada de hoy (sin doble muerte)" } else { No "expira-idempotente: MUERTOS duplico la entrada de hoy" }

# ------------------------------------------------------------------ (v) Con fecha vencida muere
$rConFecha = @(
  "# Roadmap fixture",
  "",
  "## Con fecha",
  "- **Con fecha ya pasada** [alta:2026-06-01${sep}vence:2026-07-01${sep}apetito:4h] -- vence antes de hoy"
)
$dirV = New-ExpirarFixture 'expira-confecha' (New-FlujoExpirar 90) $rConFecha
$rV = Invoke-Expirar $dirV $false
$roadmapV = Read-Text (Join-Path $dirV 'ROADMAP.md')
$muertosV = Read-Text (Join-Path $dirV 'docs/MUERTOS.md')
if ($rV.Code -eq 0 -and $roadmapV -notmatch 'Con fecha ya pasada' -and $muertosV -match 'Con fecha ya pasada' -and $muertosV -match '2026-07-01; revive') { Ok "expira-confecha: el 'Con fecha' con vence pasado murio (motivo con su vence)" } else { No "expira-confecha: el 'Con fecha' vencido no murio bien (exit $($rV.Code))`n$roadmapV`n$muertosV" }

# ------------------------------------------------------------------ (w) Referencia no muere
$rRef = @(
  "# Roadmap fixture",
  "",
  "## Referencia",
  "> landscape",
  "- **Algo viejisimo declarativo** [alta:2020-01-01] -- Referencia nunca vence"
)
$dirW = New-ExpirarFixture 'expira-referencia' (New-FlujoExpirar 90) $rRef
$rW = Invoke-Expirar $dirW $false
$roadmapW = Read-Text (Join-Path $dirW 'ROADMAP.md')
if ($rW.Code -eq 0 -and $rW.Out -match '0 vencidos' -and $roadmapW -match 'Algo viejisimo declarativo') { Ok "expira-referencia: la Referencia vieja NO murio (0 vencidos, sigue en ROADMAP)" } else { No "expira-referencia: la Referencia se toco indebidamente (exit $($rW.Code))`n$($rW.Out)`n$roadmapW" }

# ------------------------------------------------------------------ (x) sin vencimiento_dias -> no aplica
# New-FlujoRoadmap trae roadmap con techo pero SIN vencimiento_dias: expirar no aplica.
$dirX = New-ExpirarFixture 'expira-sin-config' (New-FlujoRoadmap 90) $rExp
$roadmapXantes = Read-Text (Join-Path $dirX 'ROADMAP.md')
$rX = Invoke-Expirar $dirX $false
$roadmapXdespues = Read-Text (Join-Path $dirX 'ROADMAP.md')
if ($rX.Code -eq 0 -and $rX.Out -match 'no aplica') { Ok "expira-sin-config: sin vencimiento_dias -> 'no aplica' exit 0" } else { No "expira-sin-config: esperaba 'no aplica' exit 0, fue $($rX.Code)`n$($rX.Out)" }
if ($roadmapXantes -eq $roadmapXdespues) { Ok "expira-sin-config: no toco el ROADMAP (nada que expirar)" } else { No "expira-sin-config: modifico el ROADMAP sin contrato de vencimiento" }

# ------------------------------------------------------------------ (y) Algun dia vencido muere
$rIcebox = @(
  "# Roadmap fixture",
  "",
  $hAlgunDia,
  "- **Item del icebox vencido** [alta:$alta200] -- 200 dias > ventana 180"
)
$dirY = New-ExpirarFixture 'expira-algundia' (New-FlujoExpirar 90) $rIcebox
$rY = Invoke-Expirar $dirY $false
$roadmapY = Read-Text (Join-Path $dirY 'ROADMAP.md')
$muertosY = Read-Text (Join-Path $dirY 'docs/MUERTOS.md')
if ($rY.Code -eq 0 -and $roadmapY -notmatch 'Item del icebox vencido' -and $muertosY -match 'Item del icebox vencido' -and $muertosY -match "alta $alta200") { Ok "expira-algundia: el 'Algun dia' con 200 dias murio (ventana 180)" } else { No "expira-algundia: el icebox vencido no murio bien (exit $($rY.Code))`n$roadmapY`n$muertosY" }

Write-Host ""
Write-Host "== El limite WIP (tools/estado-flujo.ps1 -Gate, muro de entrada de planea): fixtures =="

# flujo.json SOLO con la clave estado: los checks hermanos (handoff/roadmap/changelog) no
# aplican y estado-flujo solo mira 'estado'. Fixture = dir con tools/flujo.json (nada mas:
# estado-flujo no lee HANDOFF/ROADMAP/CHANGELOG).
function New-EstadoFixture($nombre, $flujoTexto) {
  $dir = Join-Path $tmpRoot $nombre
  New-Item -ItemType Directory -Path (Join-Path $dir 'tools') -Force | Out-Null
  if ($null -ne $flujoTexto) {
    [System.IO.File]::WriteAllText((Join-Path $dir 'tools/flujo.json'), $flujoTexto, $utf8NoBom)
  }
  return $dir
}
function Invoke-EstadoFlujo($dir) {
  $out = (& powershell -NoProfile -ExecutionPolicy Bypass -File $esti -Gate -Repo $dir 2>&1 | Out-String)
  return @{ Out = $out; Code = $LASTEXITCODE }
}

# ------------------------------------------------------------------ (w1) 1 gemba pendiente -> BLOQUEA
$estadoPendiente = @"
{
  "estado": {
    "wip_limite": 8,
    "sprint_activo": "prueba",
    "gembas_pendientes": [
      { "id": "FLU-1", "desde": "2026-07-21", "aceptado": false, "que_ver": "el limite WIP se planta" }
    ]
  }
}
"@
$dirW1 = New-EstadoFixture 'wip-pendiente' $estadoPendiente
$rW1 = Invoke-EstadoFlujo $dirW1
if ($rW1.Code -eq 1) { Ok "wip-pendiente: exit 1 (BLOQUEA abrir sprint nuevo)" } else { No "wip-pendiente: esperaba exit 1, fue $($rW1.Code)`n$($rW1.Out)" }
if ($rW1.Out -match '\[BLOQUEA\]' -and $rW1.Out -match 'FLU-1' -and $rW1.Out -match 'ABRIR SPRINT NUEVO BLOQUEADO') { Ok "wip-pendiente: la salida NOMBRA el id (FLU-1) y trae el muro 'ABRIR SPRINT NUEVO BLOQUEADO'" } else { No "wip-pendiente: esperaba [BLOQUEA] nombrando FLU-1 + 'ABRIR SPRINT NUEVO BLOQUEADO'`n$($rW1.Out)" }

# ------------------------------------------------------------------ (w2) aceptado:true -> despejado
$estadoAceptado = @"
{
  "estado": {
    "wip_limite": 8,
    "sprint_activo": "prueba",
    "gembas_pendientes": [
      { "id": "FLU-1", "desde": "2026-07-21", "aceptado": true, "aceptado_fecha": "2026-07-21", "que_ver": "ya lo vio el cliente" }
    ]
  }
}
"@
$dirW2 = New-EstadoFixture 'wip-aceptado' $estadoAceptado
$rW2 = Invoke-EstadoFlujo $dirW2
if ($rW2.Code -eq 0) { Ok "wip-aceptado: exit 0 (aceptado:true no retiene)" } else { No "wip-aceptado: esperaba exit 0, fue $($rW2.Code)`n$($rW2.Out)" }
if ($rW2.Out -match 'flujo despejado') { Ok "wip-aceptado: 'flujo despejado' (0 Gembas pendientes)" } else { No "wip-aceptado: esperaba 'flujo despejado'`n$($rW2.Out)" }

# ------------------------------------------------------------------ (w3) sin clave estado -> no aplica
$dirW3 = New-EstadoFixture 'wip-sin-estado' '{ "handoff": { "max_historicas": 2, "techo_lineas": 120 } }'
$rW3 = Invoke-EstadoFlujo $dirW3
if ($rW3.Code -eq 0 -and $rW3.Out -match 'no aplica') { Ok "wip-sin-estado: sin la clave estado -> 'no aplica' exit 0" } else { No "wip-sin-estado: esperaba 'no aplica' exit 0, fue $($rW3.Code)`n$($rW3.Out)" }

# ------------------------------------------------------------------ (w4) corrupto -> falla cerrado
$dirW4 = New-EstadoFixture 'wip-corrupto' "esto no es json valido {{{"
$rW4 = Invoke-EstadoFlujo $dirW4
if ($rW4.Code -eq 2) { Ok "wip-corrupto: exit 2 (falla cerrado -- un gate que no puede leer su contrato no aprueba)" } else { No "wip-corrupto: esperaba exit 2, fue $($rW4.Code)`n$($rW4.Out)" }

# ------------------------------------------------------------------ (w5) entrada sin id -> AVISO + bloquea
$estadoSinId = @"
{
  "estado": {
    "wip_limite": 8,
    "gembas_pendientes": [
      { "desde": "2026-07-21", "aceptado": false, "que_ver": "sin id, malformada" }
    ]
  }
}
"@
$dirW5 = New-EstadoFixture 'wip-sin-id' $estadoSinId
$rW5 = Invoke-EstadoFlujo $dirW5
if ($rW5.Code -eq 1 -and $rW5.Out -match '\[AVISO\]' -and $rW5.Out -match 'ABRIR SPRINT NUEVO BLOQUEADO') { Ok "wip-sin-id: entrada sin id -> AVISO + cuenta como pendiente (exit 1, fail-safe)" } else { No "wip-sin-id: esperaba AVISO + exit 1 (lo dudoso bloquea), fue $($rW5.Code)`n$($rW5.Out)" }

# ------------------------------------------------------------------ (w6) gembas_pendientes ausente -> despejado
$estadoSinLista = @"
{
  "estado": {
    "wip_limite": 8,
    "sprint_activo": "prueba"
  }
}
"@
$dirW6 = New-EstadoFixture 'wip-sin-lista' $estadoSinLista
$rW6 = Invoke-EstadoFlujo $dirW6
if ($rW6.Code -eq 0 -and $rW6.Out -match 'flujo despejado') { Ok "wip-sin-lista: estado presente pero gembas_pendientes ausente -> lista vacia, exit 0 despejado" } else { No "wip-sin-lista: esperaba exit 0 despejado (lista vacia), fue $($rW6.Code)`n$($rW6.Out)" }

Write-Host ""
Write-Host "== La vista de que sigue (tools/estado-flujo.ps1 -Json / resumen, R6): fixtures =="

# Fixture completo: tools/flujo.json (estado + roadmap) + ROADMAP.md + docs/MUERTOS.md.
function New-VistaFixture($nombre, $flujoTexto, $roadmapLines, $muertosLines) {
  $dir = Join-Path $tmpRoot $nombre
  New-Item -ItemType Directory -Path (Join-Path $dir 'tools') -Force | Out-Null
  New-Item -ItemType Directory -Path (Join-Path $dir 'docs') -Force | Out-Null
  if ($null -ne $flujoTexto) {
    [System.IO.File]::WriteAllText((Join-Path $dir 'tools/flujo.json'), $flujoTexto, $utf8NoBom)
  }
  if ($null -ne $roadmapLines) {
    [System.IO.File]::WriteAllLines((Join-Path $dir 'ROADMAP.md'), [string[]]$roadmapLines, $utf8NoBom)
  }
  if ($null -ne $muertosLines) {
    [System.IO.File]::WriteAllLines((Join-Path $dir 'docs/MUERTOS.md'), [string[]]$muertosLines, $utf8NoBom)
  }
  return $dir
}
function Invoke-EstadoJson($dir) {
  $out = (& powershell -NoProfile -ExecutionPolicy Bypass -File $esti -Json -Repo $dir 2>&1 | Out-String)
  return @{ Out = $out; Code = $LASTEXITCODE }
}
function Invoke-EstadoResumen($dir) {
  $out = (& powershell -NoProfile -ExecutionPolicy Bypass -File $esti -Repo $dir 2>&1 | Out-String)
  return @{ Out = $out; Code = $LASTEXITCODE }
}

# ------------------------------------------------------------------ (j1) -Json completo
$vistaFlujo = @"
{
  "estado": { "wip_limite": 8, "sprint_activo": "prueba-r6", "gembas_pendientes": [] },
  "roadmap": { "techo_lineas": 90, "muertos": "docs/MUERTOS.md" }
}
"@
$vistaRoadmap = @(
  "# Roadmap fixture",
  "",
  "## Urgente",
  "- **Un urgente R6** [alta:2026-07-10${sep}apetito:2h] -- el primero de la cola",
  "",
  "## Con fecha",
  "- **Uno con fecha R6** [alta:2026-07-15${sep}vence:2026-08-01${sep}apetito:4h] -- con vence",
  "",
  "## Normal",
  "- **Uno normal R6** [alta:2026-07-12${sep}apetito:6h] -- normal simple",
  "- **Espera a Marcelo** [alta:2026-07-11${sep}apetito:2h${sep}espera:Marcelo] -- bloqueado por tercero"
)
$vistaMuertos = @(
  "# Muertos fixture",
  "",
  "## 2026-07-20",
  "- **Un muerto reciente R6** [alta:2026-04-01${sep}apetito:2h] -- murio por ventana Normal",
  "  - murio: Normal, alta 2026-04-01, vencia 2026-06-30; revive re-proponiendolo"
)
$dirJ1 = New-VistaFixture 'vista-completa' $vistaFlujo $vistaRoadmap $vistaMuertos
$rJ1 = Invoke-EstadoJson $dirJ1
$objJ1 = $null
try { $objJ1 = $rJ1.Out | ConvertFrom-Json } catch { $objJ1 = $null }
if ($rJ1.Code -eq 0 -and $objJ1 -and $objJ1.version -eq 1) { Ok "vista-json: exit 0 y JSON parseable (version 1)" } else { No "vista-json: esperaba exit 0 + JSON version 1, fue $($rJ1.Code)`n$($rJ1.Out)" }
if ($objJ1 -and $objJ1.siguientes -and $objJ1.siguientes[0].clase -eq 'urgente') { Ok "vista-json: siguientes[0] es el Urgente (orden: urgente -> con fecha -> normal)" } else { No "vista-json: siguientes[0] no es el Urgente`n$($rJ1.Out)" }
if ($objJ1 -and @($objJ1.esperando_terceros | Where-Object { $_.quien -eq 'Marcelo' }).Count -ge 1) { Ok "vista-json: esperando_terceros trae a Marcelo" } else { No "vista-json: esperando_terceros no trae a Marcelo`n$($rJ1.Out)" }
if ($objJ1 -and @($objJ1.muertos_recientes).Count -ge 1) { Ok "vista-json: muertos_recientes NO vacio (ultima entrada de MUERTOS)" } else { No "vista-json: muertos_recientes vacio, esperaba la entrada`n$($rJ1.Out)" }
if ($objJ1 -and $objJ1.conteos.urgente -eq 1 -and $objJ1.conteos.con_fecha -eq 1 -and $objJ1.conteos.normal -eq 2 -and $objJ1.conteos.algun_dia -eq 0) { Ok "vista-json: conteos correctos (urgente 1, con_fecha 1, normal 2, algun_dia 0)" } else { No "vista-json: conteos incorrectos`n$($rJ1.Out)" }

# ------------------------------------------------------------------ (j2) -Json sin ROADMAP
# flujo.json con estado pero SIN ROADMAP.md: la vista degrada, no truena -> JSON minimo
# valido con las claves de cola vacias, exit 0.
$dirJ2 = New-VistaFixture 'vista-sin-roadmap' '{ "estado": { "wip_limite": 8, "sprint_activo": "sin-roadmap" } }' $null $null
$rJ2 = Invoke-EstadoJson $dirJ2
$objJ2 = $null
try { $objJ2 = $rJ2.Out | ConvertFrom-Json } catch { $objJ2 = $null }
if ($rJ2.Code -eq 0 -and $objJ2 -and $objJ2.version -eq 1) { Ok "vista-sin-roadmap: exit 0 y JSON valido (version 1)" } else { No "vista-sin-roadmap: esperaba exit 0 + JSON valido, fue $($rJ2.Code)`n$($rJ2.Out)" }
if ($objJ2 -and @($objJ2.siguientes).Count -eq 0 -and @($objJ2.esperando_terceros).Count -eq 0 -and $objJ2.conteos.urgente -eq 0) { Ok "vista-sin-roadmap: claves de cola vacias (degrada, no truena)" } else { No "vista-sin-roadmap: esperaba claves vacias`n$($rJ2.Out)" }

# ------------------------------------------------------------------ (j3) resumen default
$dirJ3 = New-VistaFixture 'vista-resumen' $vistaFlujo $vistaRoadmap $vistaMuertos
$rJ3 = Invoke-EstadoResumen $dirJ3
if ($rJ3.Code -eq 0 -and $rJ3.Out -match 'Sprint activo' -and $rJ3.Out -match 'Siguen:') { Ok "vista-resumen: el modo default imprime 'Sprint activo' y 'Siguen:' (exit 0)" } else { No "vista-resumen: esperaba 'Sprint activo' + 'Siguen:' exit 0, fue $($rJ3.Code)`n$($rJ3.Out)" }

# ------------------------------------------------------------------ (j4) -Json corrupto
$dirJ4 = New-VistaFixture 'vista-corrupta' "esto no es json valido {{{" $vistaRoadmap $null
$rJ4 = Invoke-EstadoJson $dirJ4
if ($rJ4.Code -eq 2) { Ok "vista-json-corrupta: exit 2 (falla cerrado -- la vista no emite a ciegas)" } else { No "vista-json-corrupta: esperaba exit 2, fue $($rJ4.Code)`n$($rJ4.Out)" }

Write-Host ""
Write-Host "== El reporte para terceros (tools/reporte-avance.ps1, R7): VISTA sin jerga =="

# El repo REAL es el padre de tools/ (donde vive este test). El reporte se corre contra el,
# con -Salida a un .html temporal (no se toca el .jidoka/ real).
$repoReal = Split-Path -Parent $PSScriptRoot
function Invoke-Reporte($repoDir) {
  $salida = Join-Path $tmpRoot ("reporte-" + [System.Guid]::NewGuid().ToString('N') + '.html')
  $out = (& powershell -NoProfile -ExecutionPolicy Bypass -File $repo -Repo $repoDir -Salida $salida 2>&1 | Out-String)
  $html = ''
  if (Test-Path -LiteralPath $salida) { $html = [System.IO.File]::ReadAllText($salida, [System.Text.Encoding]::UTF8) }
  return @{ Out = $out; Code = $LASTEXITCODE; Html = $html; Salida = $salida }
}

# ------------------------------------------------------------------ (r1) repo real, 5 secciones, cero jerga
$rR1 = Invoke-Reporte $repoReal
if ($rR1.Code -eq 0 -and $rR1.Html) { Ok "reporte-real: exit 0 y .html generado" } else { No "reporte-real: esperaba exit 0 + .html, fue $($rR1.Code)`n$($rR1.Out)" }
# Los 5 titulos de seccion (se casan por su parte ASCII, esta fuente es ASCII a proposito).
$titulos = @('se termin', 'vamos', 'espera una respuesta', 'se descart', 'sigue</h2>')
$faltan = @($titulos | Where-Object { $rR1.Html -notmatch [regex]::Escape($_) })
if ($faltan.Count -eq 0) { Ok "reporte-real: trae los 5 titulos de seccion" } else { No "reporte-real: faltan titulos de seccion: $($faltan -join ', ')" }
# La JERGA PROHIBIDA: grep case-insensitive. El .html se le manda TAL CUAL a un tercero; ni
# una de estas palabras -- ni siquiera dentro de una clase CSS -- puede aparecer.
# \b como en Scrub-Jerga: sin frontera, palabras inocentes del estado real ("mitigate",
# "commitment", "gateway") harian fallar en falso este caso (hallazgo del review de rama).
$jerga = @('gate', 'wip', 'commit', 'PR', 'rebanada')
$coladas = @($jerga | Where-Object { $rR1.Html -match ('(?i)\b' + [regex]::Escape($_) + '\b') })
if ($coladas.Count -eq 0) { Ok "reporte-real: CERO jerga prohibida (gate/WIP/commit/'PR '/rebanada)" } else { No "reporte-real: jerga colada en la salida: $($coladas -join ', ')" }

# ------------------------------------------------------------------ (r3) el hill chart
if ($rR1.Html -match '<svg') { Ok "reporte-real: trae el hill chart (<svg inline)" } else { No "reporte-real: no trae <svg (el hill chart)" }

# ------------------------------------------------------------------ (r2) fixture minimo degrada con gracia
# Un repo pelado: sin tools/flujo.json ni docs/MUERTOS.md. El reporte no debe tronar y la
# seccion 4 cae al mensaje "Nada se ha descartado".
$dirR2 = Join-Path $tmpRoot 'reporte-minimo'
New-Item -ItemType Directory -Path $dirR2 -Force | Out-Null
$rR2 = Invoke-Reporte $dirR2
if ($rR2.Code -eq 0 -and $rR2.Html) { Ok "reporte-minimo: genera sin tronar (exit 0) pese a que faltan flujo.json y MUERTOS" } else { No "reporte-minimo: esperaba exit 0 + .html, fue $($rR2.Code)`n$($rR2.Out)" }
if ($rR2.Html -match 'Nada se ha descartado') { Ok "reporte-minimo: la seccion 4 dice 'Nada se ha descartado' (degrada con gracia)" } else { No "reporte-minimo: esperaba 'Nada se ha descartado' sin MUERTOS`n$($rR2.Out)" }

Write-Host ""
Write-Host "== El apetito en MINUTOS (R6): el contrato acepta apetito:Nm ademas de apetito:Nh =="

# El presupuesto de atencion del dueno es LA restriccion del sistema, y hay trabajo que vale
# menos de una hora. Antes el check exigia apetito:\d+h, asi que todo item chico se declaraba
# '1h' y el backlog SOBREESTIMABA ese presupuesto (informe huella-en-labs 2026-07-23). Ahora
# acepta horas (Nh) O minutos (Nm, entero). Fixtures ROJO->VERDE con el verificar REAL.

# ------------------------------------------------------------------ (m1) apetito:30m aceptado
$rMin30 = @(
  "# Roadmap fixture",
  "",
  "## Normal",
  "- **Tarea de media hora** [alta:2026-07-21${sep}apetito:30m] -- menos de una hora, ahora expresable"
)
$dirM1 = New-RoadmapFixture 'roadmap-apetito-30m' (New-FlujoRoadmap 90) $rMin30
$rM1 = Invoke-Verificar $dirM1
if ($rM1.Code -eq 0) { Ok "roadmap-apetito-30m: exit 0 (apetito:30m aceptado)" } else { No "roadmap-apetito-30m: esperaba exit 0, fue $($rM1.Code)`n$($rM1.Out)" }
if ($rM1.Out -match '\[contrato-roadmap\]' -and $rM1.Out -match 'dentro de contrato') { Ok "roadmap-apetito-30m: ROADMAP dentro de contrato con apetito en minutos" } else { No "roadmap-apetito-30m: esperaba '[contrato-roadmap] ... dentro de contrato'`n$($rM1.Out)" }

# ------------------------------------------------------------------ (m2) apetito:2m bajo Normal pasa
$rMin2 = @(
  "# Roadmap fixture",
  "",
  "## Normal",
  "- **Tarea de dos minutos** [alta:2026-07-21${sep}apetito:2m] -- trivial pero contabilizada al minuto"
)
$dirM2 = New-RoadmapFixture 'roadmap-apetito-2m' (New-FlujoRoadmap 90) $rMin2
$rM2 = Invoke-Verificar $dirM2
if ($rM2.Code -eq 0) { Ok "roadmap-apetito-2m: exit 0 (apetito:2m pasa el contrato bajo Normal)" } else { No "roadmap-apetito-2m: esperaba exit 0, fue $($rM2.Code)`n$($rM2.Out)" }

# ------------------------------------------------------------------ (m3) apetito:4h SIGUE valido
# La regresion: aceptar minutos NO debe romper las horas enteras que ya estaban en uso.
$rHoras4 = @(
  "# Roadmap fixture",
  "",
  "## Urgente",
  "- **Sigue en horas** [alta:2026-07-21${sep}apetito:4h] -- las horas no se rompieron"
)
$dirM3 = New-RoadmapFixture 'roadmap-apetito-4h' (New-FlujoRoadmap 90) $rHoras4
$rM3 = Invoke-Verificar $dirM3
if ($rM3.Code -eq 0) { Ok "roadmap-apetito-4h: exit 0 (apetito:4h sigue valido -- Nh intacto)" } else { No "roadmap-apetito-4h: esperaba exit 0, fue $($rM3.Code)`n$($rM3.Out)" }

# ------------------------------------------------------------------ (m4) apetito sin unidad sigue BLOQUEANDO
# Aflojar a minutos no es abrir el campo: un 'apetito:30' pelado (ni h ni m) sigue sin declarar
# su contrato -> BLOQUEA. Que el muro no se abra de mas es tan importante como que acepte Nm.
$rMalApetito = @(
  "# Roadmap fixture",
  "",
  "## Normal",
  "- **Apetito sin unidad** [alta:2026-07-21${sep}apetito:30] -- ni horas ni minutos, invalido"
)
$dirM4 = New-RoadmapFixture 'roadmap-apetito-malo' (New-FlujoRoadmap 90) $rMalApetito
$rM4 = Invoke-Verificar $dirM4
if ($rM4.Code -eq 1 -and $rM4.Out -match 'apetito:Nh o Nm') { Ok "roadmap-apetito-malo: exit 1 (apetito:30 sin unidad sigue bloqueando; el check no se abrio de mas)" } else { No "roadmap-apetito-malo: esperaba exit 1 acusando 'apetito:Nh o Nm', fue $($rM4.Code)`n$($rM4.Out)" }

# ------------------------------------------------------------------ (m5) la VISTA no pierde el sub-hora
# estado-flujo -Json parsea apetito: para la vista; con solo \d+h un 'apetito:30m' quedaba
# INVISIBLE (campo vacio). Ahora lo captura y lo emite tal cual en siguientes[].
$vistaMinFlujo = '{ "estado": { "sprint_activo": "r6-min" }, "roadmap": { "techo_lineas": 90 } }'
$vistaMinRoad = @(
  "# Roadmap fixture",
  "",
  "## Normal",
  "- **Sub-hora en la vista** [alta:2026-07-21${sep}apetito:30m] -- media hora"
)
$dirM5 = New-VistaFixture 'vista-apetito-min' $vistaMinFlujo $vistaMinRoad $null
$rM5 = Invoke-EstadoJson $dirM5
$objM5 = $null
try { $objM5 = $rM5.Out | ConvertFrom-Json } catch { $objM5 = $null }
if ($rM5.Code -eq 0 -and $objM5 -and @($objM5.siguientes).Count -ge 1 -and $objM5.siguientes[0].apetito -eq '30m') { Ok "vista-apetito-min: la vista captura y muestra apetito:30m (no se lo traga)" } else { No "vista-apetito-min: esperaba siguientes[0].apetito == '30m', fue $($rM5.Out)" }

# ==== Ancla de fin de unidad del apetito (R6): sin '(?![A-Za-z])' el regex 'apetito:\d+[hm]'
# casaba el '30m'/'2h' DE ADENTRO de 'apetito:30min'/'2hrs'/'5horas' y colaba una unidad basura
# como valida. La cura ancla el fin: solo Nh/Nm seguido de NO-letra vale. Fixtures ROJO->VERDE.

# ------------------------------------------------------------------ (m6) apetito:30min BLOQUEA
$rMin30min = @(
  "# Roadmap fixture",
  "",
  "## Normal",
  "- **Unidad basura min** [alta:2026-07-21${sep}apetito:30min] -- 'min' no es la unidad, debe bloquear"
)
$dirM6 = New-RoadmapFixture 'roadmap-apetito-30min' (New-FlujoRoadmap 90) $rMin30min
$rM6 = Invoke-Verificar $dirM6
if ($rM6.Code -eq 1 -and $rM6.Out -match 'apetito:Nh o Nm') { Ok "roadmap-apetito-30min: exit 1 (apetito:30min NO cuela el '30m' de adentro)" } else { No "roadmap-apetito-30min: esperaba exit 1 acusando 'apetito:Nh o Nm', fue $($rM6.Code)`n$($rM6.Out)" }

# ------------------------------------------------------------------ (m7) apetito:2hrs BLOQUEA
$rHrs2 = @(
  "# Roadmap fixture",
  "",
  "## Normal",
  "- **Unidad basura hrs** [alta:2026-07-21${sep}apetito:2hrs] -- 'hrs' no es la unidad, debe bloquear"
)
$dirM7 = New-RoadmapFixture 'roadmap-apetito-2hrs' (New-FlujoRoadmap 90) $rHrs2
$rM7 = Invoke-Verificar $dirM7
if ($rM7.Code -eq 1 -and $rM7.Out -match 'apetito:Nh o Nm') { Ok "roadmap-apetito-2hrs: exit 1 (apetito:2hrs NO cuela el '2h' de adentro)" } else { No "roadmap-apetito-2hrs: esperaba exit 1 acusando 'apetito:Nh o Nm', fue $($rM7.Code)`n$($rM7.Out)" }

# ------------------------------------------------------------------ (m8) apetito:30m SIGUE pasando
# La regresion: anclar el fin NO debe romper la unidad legitima 'm' al final del token.
$rMin30ok = @(
  "# Roadmap fixture",
  "",
  "## Normal",
  "- **Media hora legitima** [alta:2026-07-21${sep}apetito:30m] -- unidad valida, pasa"
)
$dirM8 = New-RoadmapFixture 'roadmap-apetito-30m-ok' (New-FlujoRoadmap 90) $rMin30ok
$rM8 = Invoke-Verificar $dirM8
if ($rM8.Code -eq 0) { Ok "roadmap-apetito-30m-ok: exit 0 (apetito:30m sigue valido tras el ancla)" } else { No "roadmap-apetito-30m-ok: esperaba exit 0, fue $($rM8.Code)`n$($rM8.Out)" }

# ------------------------------------------------------------------ (m9) apetito:4h SIGUE pasando
$rHrs4ok = @(
  "# Roadmap fixture",
  "",
  "## Urgente",
  "- **Cuatro horas legitimas** [alta:2026-07-21${sep}apetito:4h] -- unidad valida, pasa"
)
$dirM9 = New-RoadmapFixture 'roadmap-apetito-4h-ok' (New-FlujoRoadmap 90) $rHrs4ok
$rM9 = Invoke-Verificar $dirM9
if ($rM9.Code -eq 0) { Ok "roadmap-apetito-4h-ok: exit 0 (apetito:4h sigue valido tras el ancla)" } else { No "roadmap-apetito-4h-ok: esperaba exit 0, fue $($rM9.Code)`n$($rM9.Out)" }

# ------------------------------------------------------------------ (m10) la VISTA tampoco cuela la basura
# El mismo ancla en estado-flujo.ps1: 'apetito:30min' NO debe emitirse como apetito:'30m' en la
# vista (antes lo capturaba). Con el ancla, el campo queda vacio (null), no una unidad falsa.
$vistaBasuraRoad = @(
  "# Roadmap fixture",
  "",
  "## Normal",
  "- **Sub-hora basura en la vista** [alta:2026-07-21${sep}apetito:30min] -- 'min' no es unidad"
)
$dirM10 = New-VistaFixture 'vista-apetito-basura' $vistaMinFlujo $vistaBasuraRoad $null
$rM10 = Invoke-EstadoJson $dirM10
$objM10 = $null
try { $objM10 = $rM10.Out | ConvertFrom-Json } catch { $objM10 = $null }
if ($rM10.Code -eq 0 -and $objM10 -and @($objM10.siguientes).Count -ge 1 -and -not $objM10.siguientes[0].apetito) { Ok "vista-apetito-basura: la vista NO captura '30m' de 'apetito:30min' (campo vacio, no unidad falsa)" } else { No "vista-apetito-basura: esperaba siguientes[0].apetito vacio, fue $($rM10.Out)" }

Write-Host ""
Write-Host "== R7: rutas resueltas contra -Repo, no contra el CWD (corriendo desde OTRA carpeta) =="

# Los tres scripts (estado-flujo/expirar/auditar) aceptan -Repo y ya resuelven contra la raiz
# (Push-Location/Set-Location `$Repo al arrancar). Este guardian lo BLINDA: corre el script
# desde una carpeta NEUTRAL -- ni el repo ni el fixture, SIN tools/flujo.json -- y exige que
# aun asi halle el JSON del -Repo. Si alguien quitara el Push-Location y volviera a la ruta
# literal, el script diria "no aplica" (falso verde) y este caso lo cazaria en rojo.
# Se usa Start-Process -WorkingDirectory para fijar el CWD del hijo sin ambiguedad.
$neutral = Join-Path $tmpRoot 'cwd-neutral'
New-Item -ItemType Directory -Path $neutral -Force | Out-Null
function Invoke-DesdeOtraCarpeta($scriptPath, $argv, $workdir) {
  $outF = Join-Path $tmpRoot ('r7-out-' + [System.Guid]::NewGuid().ToString('N'))
  $errF = Join-Path $tmpRoot ('r7-err-' + [System.Guid]::NewGuid().ToString('N'))
  $a = @('-NoProfile','-ExecutionPolicy','Bypass','-File',$scriptPath) + $argv
  $p = Start-Process -FilePath 'powershell' -ArgumentList $a -WorkingDirectory $workdir -Wait -PassThru -NoNewWindow -RedirectStandardOutput $outF -RedirectStandardError $errF
  $out = ''
  if (Test-Path -LiteralPath $outF) { $out += [System.IO.File]::ReadAllText($outF) }
  if (Test-Path -LiteralPath $errF) { $out += [System.IO.File]::ReadAllText($errF) }
  return @{ Out = $out; Code = $p.ExitCode }
}

# ------------------------------------------------------------------ (cwd1) estado-flujo -Gate desde otra carpeta
# Fixture con wip_limite DISTINTIVO (3): si el script leyera un flujo.json equivocado (o
# ninguno) no reportaria justo ese numero -- diria "no aplica" o WIP limite otro.
$dirCwd1 = New-EstadoFixture 'r7-estado' '{ "estado": { "wip_limite": 3, "sprint_activo": "r7", "gembas_pendientes": [] } }'
$rCwd1 = Invoke-DesdeOtraCarpeta $esti @('-Gate','-Repo',$dirCwd1) $neutral
if ($rCwd1.Code -eq 0 -and $rCwd1.Out -match 'WIP limite: 3' -and $rCwd1.Out -notmatch 'no aplica') { Ok "r7-estado-flujo: desde OTRA carpeta halla el flujo.json del -Repo (WIP limite: 3, sin 'no aplica')" } else { No "r7-estado-flujo: esperaba exit 0 + 'WIP limite: 3' sin 'no aplica', fue $($rCwd1.Code)`n$($rCwd1.Out)" }

# ------------------------------------------------------------------ (cwd2) expirar -Simular desde otra carpeta
# Fixture con un Normal vencido (alta hace 100 dias, $alta100 del setup de expiracion): si
# expirar no hallara ROADMAP/flujo del -Repo diria "no aplica" o "0 vencidos"; debe anunciarlo.
$rCwdExp = @(
  "# Roadmap fixture",
  "",
  "## Normal",
  "- **Vencido desde otra carpeta** [alta:$alta100${sep}apetito:2h] -- muere por ventana Normal"
)
$dirCwd2 = New-ExpirarFixture 'r7-expira' (New-FlujoExpirar 90) $rCwdExp
$rCwd2 = Invoke-DesdeOtraCarpeta $expi @('-Simular','-Repo',$dirCwd2,'-Hoy',$anchor) $neutral
if ($rCwd2.Code -eq 0 -and $rCwd2.Out -match 'Vencido desde otra carpeta' -and $rCwd2.Out -notmatch 'no aplica') { Ok "r7-expirar: desde OTRA carpeta halla ROADMAP+flujo del -Repo y anuncia el vencido" } else { No "r7-expirar: esperaba anunciar el vencido sin 'no aplica', fue $($rCwd2.Code)`n$($rCwd2.Out)" }

# ------------------------------------------------------------------ (cwd3) auditar desde otra carpeta
# auditar fija 'tools/blast-radius.json' pero hace Set-Location `$Repo al arrancar; corrido
# desde el neutral con -Repo al fixture (que trae product/ con una nota), debe auditar ESE
# product/ y salir 0, no tronar por no hallar la ley.
$dirCwd3 = Join-Path $tmpRoot 'r7-auditar'
New-Item -ItemType Directory -Path (Join-Path $dirCwd3 'tools') -Force | Out-Null
New-Item -ItemType Directory -Path (Join-Path $dirCwd3 'product') -Force | Out-Null
[System.IO.File]::WriteAllText((Join-Path $dirCwd3 'tools/blast-radius.json'), '[]', $utf8NoBom)
$auditar = Join-Path $PSScriptRoot 'auditar.ps1'
$rCwd3 = Invoke-DesdeOtraCarpeta $auditar @('-Repo',$dirCwd3) $neutral
if ($rCwd3.Code -eq 0 -and $rCwd3.Out -match 'Auditar grafo de docs' -and $rCwd3.Out -notmatch '\[ERROR\]') { Ok "r7-auditar: desde OTRA carpeta halla su ley y product/ del -Repo (sin fallar cerrado)" } else { No "r7-auditar: esperaba exit 0 auditando el -Repo sin [ERROR], fue $($rCwd3.Code)`n$($rCwd3.Out)" }

# ------------------------------------------------------------------ limpieza
Remove-Item -LiteralPath $tmpRoot -Recurse -Force -ErrorAction SilentlyContinue

Write-Host ""
if ($script:fail -gt 0) {
  Write-Host "== Pilar de flujo (HANDOFF+ROADMAP+CHANGELOG+expiracion+WIP+vista+reporte) INCOMPLETO: $($script:fail) fallo(s), $($script:pass) ok. ==" -ForegroundColor Red
  exit 1
}
Write-Host "== Pilar de flujo (HANDOFF+ROADMAP+CHANGELOG+expiracion+WIP+vista+reporte) sano: $($script:pass) verificaciones verdes. =="
exit 0
