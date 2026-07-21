# Changelog — Jidoka

Formato: [Keep a Changelog](https://keepachangelog.com/es-ES/1.0.0/) · Versionado: [SemVer](https://semver.org/lang/es/).

## [1.26.0] — 2026-07-21

### El pilar de flujo, movimiento 1 — los documentos dejan de crecer (FLU-1, ADR 0045)

La Casa del TPS tiene dos pilares; el método construyó Jidoka (parar ante el defecto) y el pilar de flujo (JIT) no existía. Nace del diagnóstico medido sobre 274 MB de transcripciones y de un benchmark de 4 frentes (`docs/analisis/gemba-gestion-del-flujo-202607.md`, `docs/analisis/benchmark-flujo-202607.md`): el HANDOFF declaraba «se limpia al abrir» en su primera línea y llegó a 419 líneas con 12 secciones históricas sin que nada lo detectara. La regla del sprint: **todo tiene que ser código que rechaza la acción** — Kanban se apoya en presión social que con agentes no existe. Plan-contrato: `docs/sprints/sprint-pilar-de-flujo-plan.md` (aprobado 2026-07-21; apetito: 6 horas de revisión del cliente con muerte por defecto).

- **`feat` — el contrato del HANDOFF (R1):** el relevo se JALA, no se empuja. Check `[contrato-handoff]` en `tools/verificar.ps1`: UNA sección «Dónde estamos» + máximo N históricas + techo de líneas; excedido → **BLOQUEA** el push. Los límites son dato de instancia en `tools/flujo.json` (nuevo; sin el archivo el check no aplica — un repo sin el pilar no se bloquea; corrupto → falla cerrado, exit 2). Lo cerrado se archiva ÍNTEGRO en `docs/handoff-historico.md` (nuevo), que **`/jidoka:arranca` nunca inyecta**. Migración inicial: el HANDOFF de la nave pasó de 419 líneas y 12 históricas a 40 líneas y 2.
- **`feat` — el contrato del ROADMAP (R2):** el ROADMAP es una cola de trabajo **clasificada, no un diario**. Check `[contrato-roadmap]` en `tools/verificar.ps1`, **espejo del de handoff** (misma semántica de falla-cerrado, mismo invariante de estado): las únicas secciones legales son las 4 clases de servicio (Urgente/Con fecha/Normal/«Algún día») + Referencia; todo ítem vivo declara `[alta:AAAA-MM-DD · apetito:Nh]` (los «Con fecha» además `vence:`; el icebox «Algún día» solo `alta:`; Referencia exenta). Secciones fuera del contrato o ítems sin sus metadatos → **BLOQUEA** el push (exit 1); más un **techo de líneas** (`tools/flujo.json`, hoy 90). Sin la clave `roadmap` el check no aplica; incompleta (sin `techo_lineas`) → falla cerrado (exit 2). Migración inicial: el roadmap-diario de 140 líneas pasó a una cola de 55 líneas con **32 ítems vivos clasificados**; el diario íntegro se archiva en `docs/roadmap-historico.md` (nuevo).
- **`feat` — la muerte por defecto (R3, el circuit breaker de Shape Up):** `tools/expirar.ps1` (nuevo, mecánica) mueve lo vencido del `ROADMAP.md` a `docs/MUERTOS.md` (nuevo) con **fecha y motivo**, por **clase de servicio** (`vencimiento_dias` en `tools/flujo.json`: «Con fecha» muere si su `vence:` ya pasó; Urgente/Normal/«Algún día» si `alta + su ventana < hoy`; Referencia nunca). Lo caduco muere por **script, no por juicio** — la poda deja de depender de que alguien se acuerde. Revivir un muerto = **re-proponerlo con alta nueva**; nada vuelve solo. **Paso duro del cierre** (`/jidoka:cierra` §2, ejecuta) + **early-warning en el arranca** (`/jidoka:arranca`, `-Simular`: anuncia lo que moriría y lo que vence en ≤7 días, sin tocar nada). Idempotente; sin la clave `roadmap`/`vencimiento_dias` → «no aplica» (exit 0); `flujo.json` corrupto → falla cerrado (exit 2). Preserva el resto del ROADMAP byte-igual (UTF-8 sin BOM, mismos line endings). Cubierto por `tools/probar-flujo.ps1` (casos s–y: Normal/«Con fecha»/«Algún día» vencidos mueren, Referencia no, `-Simular` no toca nada, idempotencia, sin config = no aplica).
- **`feat` — el cierre estandarizado y el CHANGELOG bajo contrato (R4):** el cierre deja de depender de memoria. `/jidoka:cierra` fija el **orden del registro** (expirar → HANDOFF → ROADMAP → CHANGELOG → índices → gates verdes; «cerrado» es veredicto de los gates, no frase del agente) y el CHANGELOG gana su propio contrato: check `[contrato-changelog]` en `tools/verificar.ps1` que mide **solo la sección tope** (no es retroactivo) y exige **header datado** (`## [X.Y.Z] — AAAA-MM-DD`), **bullets tipados** (un tipo permitido entre backticks —`feat`/`fix`/`test`/`docs`/`chore`/`breaking`— o `ADR `, la voz de la casa) y **prosa con techo** (`max_prosa_lineas`, hoy 8): registro operativo, no carta. Los tipos y el techo son dato de instancia en `tools/flujo.json`; sin la clave el check no aplica, incompleta → falla cerrado (exit 2). Cubierto por `tools/probar-flujo.ps1` (casos z1–z8).
- **`feat` — el límite WIP como muro de entrada (R5, *drum-buffer-rope*):** el ritmo lo marca la **aceptación del cliente, no la producción**. `tools/estado-flujo.ps1 -Gate` (nuevo, mecánica) + clave `estado` (dato **vivo** de instancia) en `tools/flujo.json`: si hay un Gemba en `estado.gembas_pendientes` con `aceptado != true`, `/jidoka:planea` **se planta antes de R0** nombrando cuál (`[BLOQUEA] … <id> …` + `ABRIR SPRINT NUEVO BLOQUEADO`, exit 1). La aceptación se **registra en `/jidoka:gemba`** (booleano `aceptado: true` + `aceptado_fecha`, lo que desbloquea; un rechazo se queda pendiente y el rework hereda el mismo `id`) y el **cierre** (`/jidoka:cierra`) registra el Gemba nuevo (`aceptado: false`) — un sprint sin Gemba registrado es uno que se auto-declaró aceptado, y eso no existe. Es **gate de comando, no de push** (el que bloquea pushes sigue siendo `verificar`). Entrada sin `id` → AVISO + cuenta como pendiente (fail-safe); sin la clave `estado` → «no aplica» (exit 0); corrupto → falla cerrado (exit 2). R6 le agregará `-Json`. Cubierto por `tools/probar-flujo.ps1` (casos w1–w6).
- **`fix` cazado en vivo:** el check leía HANDOFF.md sin `-Encoding UTF8` y PS 5.1 deformaba los acentos — el contrato se medía en falso (0 históricas donde había 2). Curado con caso de regresión en el self-test.
- **`test` — `tools/probar-flujo.ps1` (nuevo, mecánica):** fixtures ROJO→VERDE del contrato (conforme, doble «estamos», históricas de más, techo excedido, sin flujo.json = no aplica, corrupto = falla cerrado, acentos UTF-8 sin BOM contados bien). En el preflight de `publicar.ps1` y en el CI.
- **ADR 0045** — el pilar de flujo: contratos de documentos con gate, límite WIP y visibilidad determinista · aceptado.

## [1.25.0] — 2026-07-20

### El editor del gobierno — la extensión AUTORA, el gate EJECUTA (ADR 0044)

Sucede a la linterna (`v1.24.0`): aquella devolvió los ojos, esta devuelve la **mano**. Nace de dos hallazgos al usar la linterna sobre el caso real: el grafo se satura y **el gobierno es demasiado grueso** — el área `codigo` avisaba sobre *las 89 capacidades* sin decir cuál. El QUÉ del cliente: *"yo poder decir: este archivo son estas 5 capacidades, y que el trigger sea el cambio de código... o al revés, o en ambas direcciones"* — sin editar JSON a mano. La cadena completa: **clic → JSON en git → pre-push/CI**; nada depende de la cooperación del modelo.

- **`feat` — el ledger `tools/ligas.json` (nuevo, dato de instancia):** las declaraciones del cliente — `{ id, codigo[], capacidades[], direccion (codigo-a-capacidad | capacidad-a-codigo | ambas), fuerza (avisa | bloquea) }`. **NO se siembra** (a diferencia de `docs-gobernados.json`): sembrarlo haría que `-Actualizar` pisara las declaraciones del hijo.
- **`feat` — el evaluador `tools/estado-ligas.ps1` (nuevo, mecánica):** mide **co-ocurrencia** sobre el rango git (matcher byte-fiel a `verificar.ps1`). `[BLOQUEA]` se imprime siempre **nombrando la capacidad exacta**; solo `-Estricto` (pre-push + CI) lo vuelve exit 1. Ligas **ROTAS** (código o capacidad inexistente) avisan y quedan excluidas — nunca bloquean (un medidor con metadatos podridos no emite veredicto). **Falla cerrado** (exit 2) ante ledger ilegible o rango incalculable. En CI, evaluador **y ledger se leen desde la base** (ADR 0003). Primera liga dogfood (`linterna-extension` → `AND-1`) que **mordió en el propio sprint** nombrando la capacidad.
- **`feat` — la extensión autora (R3):** comandos **"Jidoka: ligar código a capacidad..."** y **"Jidoka: quitar liga código-capacidad..."** (clic derecho en el explorador, multi-selección; carpeta → glob; el nombre estrechado en el re-Gemba del cliente: "ligar" a secas prometía de más — en este repo también "ligan" el blast-radius y los wikilinks): QuickPicks de capacidades (clave del frontmatter, pre-marcadas las ya ligadas) → dirección → fuerza → `extension/ligas.js` escribe el ledger (UTF-8 sin BOM — el contrato de encoding que el evaluador PS lee) y el grafo del panel se repinta. La UI **nunca** es el muro (ADR 0002 intacto).
- **`feat` — la linterna pinta las ligas (R2c):** nodo propio `liga:<id>` con dirección/fuerza en el tooltip, aristas tipadas `liga-bloquea`/`liga-avisa` hacia sus capacidades, **rotas en rojo**, ancladas al cúmulo de su área.
- **`feat` — rework del Gemba del cliente (7 hallazgos de uso real, curados en el mismo sprint):** el render ganó **flechas** (la dirección estaba en el dato y se tiraba) con **grosor por fuerza**; en Foco el área con `doc_bloquea` lleva **anillo rojo** (la severidad era invisible en el esqueleto); **etiquetas legibles** (paths abreviados al último tramo, checks con nombre corto, capas ruidosas mudas salvo hover o pocos nodos — muere la mancha de texto encimado); **fit-to-viewport** (`viewBox` persigue lo visible: nada se corta fuera de pantalla) con drag transformado; **Clusters se separa de verdad** (centros sobre un mundo más ancho + gravedad más fuerte); los **sueltos no-huérfanos** (capa-2/3 sin área) llevan trazo punteado y tooltip que explica por qué no tienen aristas; la **tabla del gobierno** bajo el grafo ordenada por severidad (*el grafo para mirar, la tabla para leer* — mata la lectura por cercanía del force-directed); y el modo **Reparto**: treemap de archivos por capa de cobertura que hace visible el bulto del cajón `raiz` (instrumento de la decisión pendiente del cliente). `probar-linterna` 56/56.
- **`test` — `tools/probar-ligas.ps1` (nuevo, mecánica):** 26 casos ROJO→VERDE — co-ocurrencia por dirección, `avisa` jamás bloquea, rotas sin falso bloqueo, falla-cerrado, rango git real con `-Base`, y el **contrato entre stacks** (lo que escribe `node -e` vía `ligas.js` lo lee y hace cumplir el `.ps1`). `extension/ligas.test.js` (9 casos, `node --test`) cableado en `probar-extension.ps1`.
- **ADR 0044** — el editor del gobierno: la extensión autora, el gate ejecuta · aceptado. Capacidad [[AND-1-muro-andon]] extendida.
- **Declarado (regla 2-3):** ni marketplace ni siembra de la extensión (el `.vsix` se empaqueta a mano, guía en `extension/README.md`); la herramienta **no sugiere** qué ligar (el juicio es del humano); el gate sigue midiendo co-ocurrencia, no contenido.

## [1.24.0] — 2026-07-19

### La linterna del gobierno — ver la máquina determinista con tus ojos, no con la narración del agente (ADR 0043)

Nace de que el cliente entra a proyectos avanzados, les mete Jidoka, y su Claude Code se pone necio con "documentos sin trackear / blast-radius" — y el parche era pedirle al agente que lo arreglara, quedando **juez y parte** (*"no sé qué hace, horas revisando cada cambio, él me explica"*). El dolor de fondo: la barrera de entrada de Jidoka es alta, y el método prohíbe delegar a ciegas. El grafo del gobierno ya existía disperso y en texto (`blast-radius.json`, `rutear.ps1`, `estado-docs.ps1`, `auditar.ps1`, `settings.json`, `andon.yml`); nadie lo renderizaba junto ni mostraba los **huérfanos** (lo que ninguna capa cubre — el "candy.md" que el agente suelta).

- **`feat` — `tools/estado-gobierno.ps1` (nuevo, mecánica):** una **vista de solo lectura** que **deriva** el grafo del gobierno de la ley real y lo emite a un **`.html` autocontenido** (grafo force-directed en JS vanilla inline; cero dependencias, cero servidor, cero Chromium — se abre con doble clic). Muestra áreas, gates (vivo/dormido), **documentos-dueño** con aristas **duras** (`doc_bloquea`, bloquean el push) vs **blandas** (`doc_avisa`), capacidades + sus wikilinks, hooks, checks de CI, y los **huérfanos en rojo** con contador (la métrica: cero huérfanos en un repo brownfield). **No inventa verdad**: el matcher de globs, la regla vivo/dormido y la normalización de secciones son copias byte-fieles de `verificar`/`rutear`/`estado-docs` (verificado en code-review). **Falla cerrado** (exit 2) si el repo no es git — no pinta un "cero huérfanos" con cero archivos.
- **`feat` — es vista, NO gate (ADR 0043):** no bloquea nada, nadie la llama para que un gate decida — un reporte, como `estado-docs.ps1` o los SVG del atlas. Respeta **ADR 0002** (nada de API/MCP como capa de gobierno). Nace **aviso** por regla 2-3, como el atlas. Se siembra a los hijos (`-Actualizar`).
- **`test` — `tools/probar-linterna.ps1` (nuevo, mecánica):** fixture git ROJO→VERDE (huérfano trackeado + untracked → contador correcto; corregido → cero) + regresiones de **inyección** (`__META__`/`__DATA__` en la ley no corrompe el JSON embebido), **falla-cerrado** (dir no-git → exit 2), **rutas con acento** (`git -c core.quotepath=false`, sin falsos huérfanos en español) y **`node --check`** del JS embebido (si hay node). En el smoke de `andon.yml` y en el preflight de `publicar.ps1`.
- **ADR 0043** — La linterna del gobierno: vista de solo lectura, no gate · aceptado.
- **Follow-up registrado:** consolidar la regla vivo/dormido y el grafo de capacidades (hoy réplicas byte-fieles en la linterna) en una fuente única (`rutear.ps1 -Json`, `auditar.ps1 -Grafo`) — refactor por regla 2-3, la duplicación no causa bug hoy.

## [1.23.0] — 2026-07-17

### Documentos gobernados — el motor gobierna la *estructura* de los documentos de instancia, no solo el hash (modelo SAP)

Nace de que el cliente, haciendo análisis de flujos en un lab de rescate, sintió que "los documentos de los hijos están super diferentes". La medición (solo-lectura) desmintió la premisa inicial —los `.md` del ritual NO divergen, son motor gobernado por hash— y encontró la real: los documentos **instancia-de-template** que el ritual inyecta con `@` (`PRODUCT_BRIEF`, `infra`, `CONTRIBUTING`) no los cubría nada, porque su contenido varía a propósito y el hash es la herramienta equivocada. Donde había template el hijo conformó; donde no (`CONTRIBUTING`, un stub de 4 líneas) cada repo inventó su estructura. Modelo mental del cliente: SAP — puedes llenar, pero si alteras la **estructura** gobernada, *garantía nula*.

- **`feat` — el ledger `tools/docs-gobernados.json` (nuevo, mecánica):** declara la taxonomía de tres capas — capa-1 (motor, hash, ya existe), capa-2 (instancia-de-template, gobernada por **secciones**: brief, infra, CONTRIBUTING), capa-3 (libre: `CODE_OF_CONDUCT`, `LICENSE`, fuera del blast-radius, declarado para dejar constancia). Para cada capa-2, su molde y su lista **congelada** de secciones requeridas. El contrato vive en el ledger, no en el template vivo — así una edición de molde no marca DESVIADO a todos los hijos de golpe.
- **`feat` — el detector `tools/estado-docs.ps1` (nuevo, mecánica), hermano estructural de `estado-motor.ps1`:** verifica que cada doc capa-2 conserve sus secciones requeridas (match por prefijo normalizado con fold de acentos). Faltante → **DESVIADO** (*garantía nula*); aditiva → OK (el contenido varía libre); reordenada → no bloquea. Aviso por defecto (exit 0), surtido en `/jidoka:arranca` §1b con el idioma classifier-safe `test -f X && powershell -File … || echo` (ya probado en la guardia del plan-de-trabajo).
- **`feat` — el muro estricto es OPT-IN y nace APAGADO:** `estado-docs.ps1 -Estricto` sale 1 solo si un doc marcado `estricto:true` pierde una requerida, cableado en el required-check de CI (`andon.yml`), **nunca** en `verificar.ps1` (no clobbea el verificar customizado del hijo). Todos los docs nacen `estricto:false`: el "no se pueda" del cliente llega como palanca que él enciende en su ledger, no como muro impuesto.
- **`feat` — `CONTRIBUTING` gana template real** (`kit/.jidoka/templates/CONTRIBUTING.md`) y stub estructurado en el manifiesto (antes: un stub inline de 4 líneas sin molde — la causa raíz de su divergencia). Un hijo nuevo nace CONFORME. `CODE_OF_CONDUCT` confirmado capa-3, fuera del blast-radius.
- **`test` — `tools/probar-docs.ps1` (nuevo, mecánica):** casos ROJO→VERDE del detector (conforme, faltante, aditiva, fold de acentos, muro opt-in) + integridad del ledger (cada molde existe, cada requerida es prefijo de una sección del molde, los 3 docs inyectados están gobernados). En el smoke local (`andon.yml`) y en el preflight de `publicar.ps1`.
- **ADR 0042** — Gobierno documental por estructura (capa-2): el hermano estructural del sello · aceptado. Capacidad **[[KIT-2-gobierno-documental]]** (extiende KIT-1).
- **Nota de coordinación:** esta versión incluye el preflight `!` de la 1.21.1 (su rama se plegó aquí). El PR #108 (`gate-anti-pii`) cortó `1.22.0` primero, así que este sprint rebumpó a `1.23.0` al mergear.

## [1.22.0] — 2026-07-17

### El repo público deja de filtrar dato de entorno — un gate lo hace cumplir (ADR 0041)

Nace de que el cliente cazó datos personales suyos en este repo público: una cuenta gh **secundaria** nombrada en `product/infra.md` y `HANDOFF.md` (vinculaba dos identidades), violando la "Frontera de confidencialidad" del `CONTRIBUTING`. Se limpió del HEAD; faltaba el muro que impidiera la recaída. La "Frontera" era prosa — ahora es maquinaria.

- **`feat` — `tools/anti-pii.ps1` (nuevo, mecánica) + `tools/probar-anti-pii.ps1` (11 casos, ROJO→VERDE):** detector anti-fuga de PII de entorno en docs rastreados. Busca **formas**, no instancias (un gate que contiene la PII que busca la re-publica): email con dominio real y rutas de perfil de usuario nombradas (`C:\Users\<x>`, `/home/<x>`) que no sean placeholders. **BLOQUEA** (exit 1); **FALLA CERRADO** (exit 2) si no puede listar el árbol. Cero falsos positivos medidos contra los 206 archivos del repo (el handle `@ArmandoMedina`, los `@jidoka.local`, los `C:\Users\x` y `C:\ruta\a\` pasan por allowlist).
- **Se parte en dos por diseño (ADR 0041):** el detector estructural es el muro **público server-side** (corre en el check `andon` con el patrón "detector de la base"); una **denylist local** (`tools/anti-pii.denylist.txt`, gitignoreada, nunca committeada; plantilla `.example.txt`) es el cinturón pre-push para cadenas literales del entorno. Modelo de amenaza: el accidente, no el adversario.
- **Cableado:** step nuevo en `.github/workflows/andon.yml` (el muro) + self-test en el humo; invocación en `.githooks/pre-push` (aviso local); disparo 16.º `sin-pii-en-el-repo`; baja a los hijos por el manifiesto (`-Actualizar`).
- **Limpieza asociada:** el nombre de la cuenta secundaria quitado de `infra.md` y `HANDOFF` (PR previo); email de commits de este repo fijado al `noreply` de GitHub (config local).

## [1.21.1] — 2026-07-17

### Preflight de inyección: los `@` del ritual dejan de fallar en silencio (jidoka#104)

Nace de un lab: `arranca` y `planea` inyectan documentos de instancia con `@archivo`, y un `@` a un archivo ausente inyecta **vacío en silencio** — el ritual seguía hasta "qué sigue" y le daba al operador la **sensación de estar preparado** con el agente sin el QUÉ/CÓMO/DÓNDE. La siembra (cosecha #7) es best-effort en tiempo de instalación; faltaba la defensa en cada sesión.

- **`arranca.md` §1b y `planea.md`** ganan un **preflight** `!` ANTES del bloque `@`: verifica que cada archivo a inyectar existe y, si falta alguno, lo grita con remediación (`[FALTA] … instalar.ps1 -Actualizar`) — mismo patrón defensivo que las guardias de `rutear`/`asientos`. No reemplaza el `@` (se conserva ADR 0034: "un `@` es un hecho ya inyectado"); solo antecede la precondición.
- **`tools/probar-preflight.ps1`** (nuevo, mecánica): guardián de regresión. Invariante — todo `@` de instancia que un comando inyecta debe estar cubierto por un preflight que teste su existencia. Falla rojo si un comando gana un `@` nuevo sin extender su preflight. Cableado en `publicar.ps1`, `andon.yml` y el manifiesto (baja a los labs con `-Actualizar`).
- La inconsistencia que lo delató: `descubre.md` ya cargaba el mismo `PRODUCT_BRIEF.md` **con** guardia (`test -f && cat || echo`), mientras `arranca`/`planea` lo inyectaban **sin** guardia vía `@`.
- **Corrección antes de release (mismo 1.21.1):** el primer preflight usaba `for f in …; do [ -f "$f" ] …` — el **clasificador de permisos** de Claude Code marca esa expansión de shell (`simple_expansion`) y **se niega a auto-correrla**, tronando el comando entero al abrir. Reescrito al idioma que el clasificador SÍ auto-corre (el mismo que la guardia del plan-de-trabajo en `arranca.md`): `test -f X || echo "[FALTA] X"` por archivo — sin variables ni `for`, y **nombra** el archivo que falta. `probar-preflight.ps1` se amplió para reconocer `test -f` además de `[ -f`. Lección durable en `ROADMAP.md`: todo `!`-inline sembrado evita variables/`for` de shell.

## [1.21.0] — 2026-07-17

### El ritual se vuelve determinista — sin punteros, atlas Method & Style y el cuadro de cierre

Nace de que el cliente cazó la incertidumbre de los punteros ("a veces lo lee y a veces no") y la elevó a principio (ADR 0040); el resto del sprint lo despliega: el casting se imprime del artefacto, los diagramas cumplen Method & Style de punta a punta, el planea gana sus dos STOPs blindados y el cierre gana métricas versionadas.

#### El arranca onboardea como a una mente nueva — git → qué → cómo → dónde

Nace de que el cliente, viendo los flujos del atlas, cuestionó el **orden de lectura** del `/jidoka:arranca`. Enmienda a ADR 0034 (reafirma la inyección, refina el orden).

- **`feat` — §1 del arranca reordenada a `git → qué → cómo → dónde`:** git **primero** como filtro de frescura (si el HANDOFF contradice a git, git gana — cazaría el doc-drift que abrió esta misma sesión); luego el QUÉ (`PRODUCT_BRIEF`), el CÓMO (`CONTRIBUTING` + `infra`), y al final el relevo (`HANDOFF` + plan del día). Cada sesión abre como una mente nueva, así que se orienta como se onboardea a un colega. Sigue siendo inyección `@`/`!` — no se revierte 0034. Fuente: `.claude/commands/jidoka/arranca.md`.
- **`refactor` — §1 del arranca abierta en dos movimientos (§1a/§1b):** el comando refleja explícitamente lo que el modelado del atlas aclaró — **§1a revisar la frescura en git** (la lupa) y **§1b cargar el contexto (`@`)** en orden qué → cómo → dónde. Mejora de autoría informada por el diagrama; el comando sigue siendo la fuente (ADR 0039). Sin cambio de conducta: corre los mismos comandos e inyecta los mismos `@`.
- **`docs` — el atlas sigue fiel:** `10-arranca-con-subprocesos.bpmn` (`documentation` + nodo `T_Leer`) refleja el nuevo orden, re-renderizado. Se **borró** `referencia/arranca-propuesta-usuario.bpmn` (boceto alterno de lectura perezosa "solo lo activado", contrario a la inyección de 0034 — ruido de una ruta no tomada).
- **`fix` — sellados los 2 diagramas que quedaron sin sellar en v1.20.0** (`10-arranca-con-subprocesos.bpmn`, `31-sembrar-manual-as-is.bpmn`): les faltaba el atributo `modeler:executionPlatformVersion`, así que Miragon (VS Code) preguntaba "Camunda 7 u 8" cada vez que se abrían. `atlas:sellar` los normaliza; los otros 23 ya lo tenían.
- **`docs` — el `10-arranca` re-modelado en estilo Method & Style (Bruce Silver):** etiquetas de tarea verbo+objeto cortas y el detalle de cada sección movido a *text annotations*; §1 se abre en dos pasos que trazan a la misma sección — *Revisar frescura en git* (§1a, el filtro) y *Cargar el contexto (@)* (§1b, la inyección) — para que "git primero" sea visible en el flujo. El comando no cambia (fidelidad intacta); solo el dibujo.
- **ADR 0039** — El comando es la fuente forzada, el diagrama-primero es hábito de autoría, y la dirección del acoplamiento es un knob por-lab (reafirma 0036) · aceptado.
- **ADR 0040** — En el ritual todo es `@`, `!` o inline — nunca un puntero (extiende 0034 al ritual completo; el guardarraíl del principio determinista que gobernó este sprint) · aceptado.
- **`refactor` — el arranca se vuelve determinista de punta a punta: fuera los punteros, el casting se imprime del artefacto.** Nace de que el cliente cazó que un puntero ("ver `kanban/roles.md`") a veces se sigue y a veces no — y entre puntero y nada, prefiere nada (todo lo que el comando pida debe ser garantizado: `@`, `!` o inline). Se quitan los 3 punteros a `kanban/*` (línea 7, §3, §5); §5 queda inline (enunciar las reglas ES el trabajo del comando; no es copia — solo 2 de sus 5 reglas coinciden con las de `roles.md`).
- **`docs` — los fines del `10-arranca` casan con el gateway del padre (regla Method & Style):** el hijo cerraba en un solo fin genérico ("Sesión orientada") y el `01-operar-sesion` preguntaba de la nada "¿Hay un trabajo definido?" — el cliente no podía ver cuál fin hace continuar el flujo. Ahora la señal del cliente se evalúa (gateway *¿La señal define un trabajo?*) y el proceso cierra en dos end states — **"Orientada: trabajo definido" / "Orientada: sin trabajo definido"** — que el gateway del padre lee directo (anotado en ambos diagramas). El STOP ("sin construir sin el QUÉ aprobado") rige en ambos fines, movido a annotation. De pilón, *¿El QUÉ está suficientemente claro?* gana la anotación "decisión conductual" que sus tres gateways hermanos ya tenían (su respuesta no tenía origen visible).
- **`fix` — el `12-planea` gana el segundo STOP y el `01` deja de construir con el plan en espera:** el comando exige aprobación formal del plan ("al aprobarse, el plan se archiva" — plan mode) pero el diagrama saltaba de *Redactar el plan* directo a *Archivar*; ahora el Humano aprueba dos veces (el QUÉ en R0 y el plan) con loop *no: ajustar*. Y en el `01`, tras `[12]` faltaba leer sus end states: el padre seguía a construir aunque el hijo terminara en "Espera aprobación". Gateway nuevo *¿Plan aprobado?* → No cierra en **"Sprint en espera de aprobación"** (anotado con el mapeo de fines, como la costura del `[10]`). Auditoría del `01` con hallazgos pendientes anotados: `[17]` y `[15]` tienen el mismo defecto de fin único que tenía el `[10]`; *¿Humano presente?* sin anotación de quién lo decide.
- **`feat` — el cierre gana el cuadro de cierre, versionado con los planes (checklist del cliente):** los hechos medibles que siempre generaban dudas al cerrar — sprint y si terminó o queda en curso, rama y commits, PR y si la rama mergeada se borró, ritual corrido, pruebas altas/cambios/bajas, E2E, evidencia en `qa_runs/` citada y commiteada, archivos tocados, gates y avisos (atendidos vs no-aplicables con razón), ADRs, CHANGELOG/versión, issues, pendientes al HANDOFF y resúmenes — ahora son una **tabla obligatoria de `/jidoka:cierra`** que se llena con verdad (un hueco se declara, no se rellena bonito) y **se versiona**: dentro de la entrega del sprint, o como `docs/sprints/cierre-AAAAMMDD.md` en el índice. Segunda ronda con el cliente sumó: **rebanadas del plan** (rollup de una línea), **delegaciones y excepciones 🎭**, **aprobaciones nombradas otorgadas**, **compactación y re-verificación**, **working tree y duración**, **motor al día** (`estado-motor`, clave en hijos) y **fricción y errores del agente (Kaizen crudo)**. Descartados a propósito: tokens/costo (no medible confiable desde adentro) y el detalle de rebanadas (vive en la entrega; el cuadro solo lleva el rollup). Insumo de métricas entre sesiones. Espejo en `16-cierra` y criterio nuevo en RIT-1.
- **`feat` — `planea.md` blinda el "planea sin arranca" y ancla el plan a la vista (comentarios del cliente):** el plan se entrega **SIEMPRE en plan mode** (si el agente no está, entra — la conversación no es canal formal de aprobación); se inyectan además **`@HANDOFF`** y **`@ROADMAP`** — la póliza determinista para cuando el usuario corre `planea` directo sin `arranca` (validarlo no es medible sin maquinaria nueva: un marcador de "arranca corrió" sería esperanza o estaría rancio; la inyección garantiza el insumo sin validar nada); y al aprobarse, las rebanadas se **anclan como lista de tareas del harness** visible en la UI, para ver el avance en vivo. `que-sigue` ya inyectaba el ROADMAP completo — precedente del propio ritual.
- **`refactor` — `planea.md` encuadrado al principio determinista:** fuera los 2 punteros de lectura (`kanban/lazo.md`, `kanban/estados.md` — la esencia de ambos ya vivía inline); el **brief se inyecta** (`@`, un hecho — ADR 0034) en vez de encargarse; **frescura `!git status` al abrir** (el permiso `Bash(git status:*)` existía en el frontmatter sin que nadie lo usara); y el segundo checkpoint queda rotulado **STOP 2** con su regla explícita (un plan rechazado se ajusta y se re-presenta, no se archiva). ROADMAP y capacidades quedan como **exploración dirigida** a propósito: leer el encuadre ES el trabajo de R0 y su subconjunto depende del sprint — inyectarlos completos cada planea sería bloat. Espejo: `12-planea` gana la annotation de frescura+inyección en *Leer el encuadre*.
- **`fix` — `[17]` y `[15]` ganan sus end states y el `01` cierra todas sus costuras:** *que-sigue* metía la señal del cliente en un solo fin; ahora la evalúa (*¿La señal arranca un trabajo?*) y cierra en **"Paso elegido: continuar" / "Sin continuar por hoy"**, que *¿El usuario decide continuar?* lee directo. En *gemba*, el rechazo del cliente vivía en un loop interno "Corregir" que **duplicaba el loop del padre** (su propia `documentation` lo confesaba) y encimaba dos nodos en el DI; corregir es construcción, no gemba: ahora cierra en **"Verificado: aceptado con evidencia" / "Rechazado: a corregir"** (el rework regresa a `[13]` en el padre) y el veredicto objetivo también puede rechazar (*¿El artefacto aprueba?* — un artefacto que no aprueba no se cita como si nada). Y *¿Humano presente?* se renombra a la pregunta honesta — **"¿El usuario pidió /jidoka:desatendido?"** — porque eso es lo que decide la rama: la invoca el usuario, no la "evalúa" el agente.
- **`docs` — `docs/analisis/` gana su índice (censo de documentos 2026-07-17):** el censo por referencias (161 `.md` trackeados) confirmó que el núcleo está traqueado — ADRs y sprints con índice gate-vigilado, `product/` con wikilinks + `auditar.ps1`, plantillas vía el manifiesto — pero `docs/analisis/` era la única carpeta de contenido **sin índice**: sus 3 auditorías tenían cero referencias (incluida, irónicamente, la auditoría de documentos). El `README.md` nuevo fija además la regla de la carpeta: informes con fecha de corte que no se actualizan; las decisiones que salgan de un informe van a ADR.
- **`feat` — `tools/asientos.ps1`, el casting vivo (el gemelo del router):** la §3 del arranca cargaba una copia en prosa de los 4 asientos-subagente que ya viven en `.claude/agents/` (y en la tabla de `roles.md` — tres copias del mismo hecho). Ahora la tabla asiento→tier **se imprime del artefacto con dientes** (`asientos.ps1` lee el frontmatter `name`/`model`/`description`, ADR 0033): determinista como el router, imposible que derive, y en un hijo con casting propio muestra *sus* agentes, no los de la nave. Degrada con gracia (`[DEGRADADO]` → `general-purpose`, acusando). Viaja como motor (manifiesto, clase mecánica); prueba de vida en `probar-hooks.ps1`; mapa en `andon/README.md`.

## [1.20.0] — 2026-07-16

### El atlas dice la verdad — fidelidad de los 24 diagramas contra su fuente real

Sprint nacido de que el cliente sintió que `10-arranca` "era diferente" — y tenía razón. Se auditaron los 24 diagramas AS-IS contra su **fuente real** (comando `.md` / script `.ps1`), con cada hallazgo verificado y citado: **14 fieles, 10 desviados**. Plan-contrato: `docs/sprints/sprint-atlas-fiel-plan.md`; informe durable: `docs/analisis/fidelidad-atlas-202607.md`.

- **`fix` — `10-arranca` reconstruido fiel a `arranca.md`:** la versión anterior **inventaba** un bucle de aclaración y una tarea "leer doc activada", y **omitía** §3 (el asiento lo ocupa el subagente), §5 (reglas duras) y las lecturas de PRODUCT_BRIEF/CONTRIBUTING; el router estaba en el carril Motor en vez de Agente. Ahora modela las 6 secciones reales en orden, con el STOP del cliente al final.
- **`feat` — la ruta AV-segura dibujada (`31-sembrar-manual-as-is.bpmn`, nuevo):** el instalador AV-seguro (`sembrar-manual.ps1`, ADR 0027) que faltaba en el mapa — 8 secciones, 2 modos (siembra fresca / `-Actualizar`), guarda AV anotada. Enlazado como 6ª rama del mapa `02-instalar-mantener-metodo` y en `RELACIONES.csv` (que además pierde 2 filas obsoletas de subprocesos del viejo 10-arranca).
- **`fix` — 5 omisiones de lógica del método anotadas** fiel a su fuente: `11-descubre` (Paso 0: leer el brief, no re-preguntar), `13-construye` (Paso 0: la maquinaria no corre mientras exploras), `70-auditoria` (pasos 6/7: descartado a propósito + checklist humano), `71-nocturna` (el click-it-down, la regla más importante del modo desatendido), `72-homologacion` (la regla dura de la frontera NDA).
- **`fix` — 30-instalar y 42-sellar reconciliados contra el `instalar.ps1` real** (leído de git, `skip-worktree` por cuarentena AV): el desglose del sembrado + no-clobber del sello (30) y la clasificación pristina-vs-customizada del modo `-Sellar` (42). Menores: `12-planea` (residuo pendiente) y `44-reportar-leccion` (Fuente ampliada al ritual completo).
- **Lección de tooling (issue aparte):** auditar el atlas contra el disco miente cuando hay piezas `skip-worktree` — hay que leer de git. La cazó el cliente (un falso "fuente muerta" de `instalar.ps1`); `41-actualizar` resultó fiel.
- **Evidencia:** `atlas:validate` sin huecos (26 diagramas, 25 call activities, todas en el CSV); `verificar.ps1` limpio; cada diagrama tocado re-renderizado e inspeccionado a la vista.

## [1.19.0] — 2026-07-16

### La nave se audita a sí misma — 5 auditorías + curas (issues #95–#99, ADR 0038)

Sesión de auditoría pedida por el cliente: documentos y ley, fidelidad del atlas, garantía de la bajada a hijos, prueba de vida de la nodriza, y el veredicto teatro-vs-real. Los informes viven en `docs/analisis/` (`en_revision`); los hallazgos accionables se curaron en la misma sesión.

- **`docs` — los 5 informes de la auditoría** (`docs/analisis/auditoria-{documentos-y-ley,atlas,kit}-202607.md`, `prueba-de-vida-nodriza-202607.md`, `veredicto-teatro-vs-real-202607.md`). El veredicto: el núcleo Toyota es maquinaria real con mordidas documentadas; la pata Scrum es conductual y se dobla (los demos del cliente se difieren); el teatro se acumula en los bordes (piezas sin consumidor). Incluye 3 hallazgos de subagente descartados al verificar, acusados por honestidad.
- **`feat` — la ley gana cobertura (ADR 0038, #97):** el área `atlas` gana `tools/*.ps1` como fuente (el drift motor→diagrama de la ventana v1.17/v1.18 ya no es invisible); `metodo` gana `docs/atlas/*` (editar el atlas avisa CHANGELOG); `barreras` gana `bin/*` (el CLI ya no está sin vigilar); área nueva `guias` (tres viajan a los hijos); la raíz excluye sus canónicos reales (`CODE_OF_CONDUCT.md`, `package.json`, `package-lock.json`, `jidoka.code-workspace` — 4 falsos avisos curados). Todo aviso; el único bloqueo sigue siendo el índice de ADRs.
- **`fix` — el atlas reconciliado con el motor (#95) y honesto en el ritual (#96):** 11 diagramas curados — `80-publicar` gana la suite de self-tests que omitía (el control más importante del release, invisible en su propio diagrama); `44-reportar-leccion` corrige carriles invertidos (anonimizar/redactar son del humano); `41-actualizar` refleja `[MIGRA]`/`[EXCLUIDA]`/Die sin sello (ADR 0037/0022); `81-preflight` gana `probar-agentes` y el guard que falla cerrado; `30-instalar` pierde el smoke que el script no corre y gana el aviso brownfield; `40-estado-motor` gana sus 3 exits tempranos; `01-operar` anota sus 3 gateways como decisión conductual y gana salida de abandono; `15-gemba` gana el camino de rechazo del cliente; `18-desatendido` representa "no edites tus propios gates". `atlas:validate` sin huecos; 25 SVG re-renderizados.
- **`feat` — los tests del kit muerden más (#98 parcial):** `probar-sembrar` 36→38 (el sello registra `producto` en siembra fresca de ambos arquetipos — el hueco que dejaba pasar un sello mudo); `probar-agentes` 28→32 (los `tools:` de cada agente se validan contra lista cerrada — el typo `Gerp` ya no pasa, cierra lo vivo de #82); `sembrar-manual` avisa en vez de callar si un arquetipo pide gobernanza sin stub en el manifiesto. Diferido por cuarentena AV: los espejos en `instalar.ps1`/`probar-instalador.ps1` (ventana de campo).
- **`chore` — prueba de vida de `auditar.ps1` (#99 parcial):** el gate del grafo mordió por primera vez en la nodriza (wikilink roto sintético → 5 BLOQUEA, exit 1 → verde al restaurar). Las 4 decisiones de poda del cliente quedan registradas en #99 como contrato de la próxima cosecha (sprint-entrega se cura por proceso, no se poda; `que-sigue` se funde; `desatendido` con plazo 2026-08-16; `jerarquia`/`verificacion` se podan).

## [1.18.0] — 2026-07-16

### La bajada que dolió — cosecha #7 del lazo (issues #86–#91 + #82, ADR 0037)

Seis issues llegados en batch de la primera bajada real 1.13→1.16 en un hijo instalado (caso 1). Plan-contrato: `docs/sprints/sprint-cosecha-7-plan.md`.

- **`feat` — la conciencia viaja en el kit (R1, #86/#87, cura B del #82).** Los agentes-asiento del ADR 0033 (`.claude/agents/`, los 4 tiereados) y su lint `probar-agentes.ps1` entran al manifiesto; las leyes-plantilla ganan `.claude/agents/*` en `ritual`. La instancia que el `arranca` inyecta se vuelve stub común de todo arquetipo: `product/PRODUCT_BRIEF.md` (deja la raíz), `product/infra.md` —con `## El casting`: la casa única del roster, se inyecta donde vive— y `CONTRIBUTING.md` mínimo; la plantilla `recursos-del-proyecto.md` se retira. `-Actualizar` (instalar y `sembrar-manual`) **migra**: siembra no-clobber los stubs que el hijo no tiene (`[MIGRA]`); lo condicionado a arquetipo solo si el sello registra `producto` (campo nuevo del sello; con sello viejo avisa, no adivina).
- **`fix` — el juez sin hueco (R2, #88).** `no-borres-el-motor` solo acepta como "ADR nuevo" los **agregados** de verdad (`--diff-filter=A` + `-AgregadosInyectados`): un ADR editado —o borrado— ya no destraba borrar una pieza del motor. 2 casos negativos nuevos en `probar-gate` (14/14).
- **`feat`/`fix` — mecánica menor (R3, #89/#90/#91).** Guard del manifiesto sin `stubs` en `sembrar-manual` (+ caso regresivo: `@($null)` de PS 5.1 ya no revienta la siembra a medias); **costura `.local` del CI**: `andon.yml` invoca `tools/ci.local.ps1` si existe (espejo de `verificar.local.ps1` — la customización del hijo deja de re-divergir en cada bajada) con tabla de costuras en la guía; el sello se escribe con newline final (4 sitios + check). El "resumen doble" del #91 **no reproduce** en corrida real: artefacto de captura, acusado en el issue.
- **Evidencia:** `qa_runs/cosecha-7-20260716/LOG.md` — suite completa verde (instalador 67/67, sembrar 36/36, gate 14/14) + demo de migración end-to-end sobre un hijo 1.16.1 real.
- **Nota de numeración:** esta cosecha se construyó en paralelo al atlas (`v1.17.0`, ADRs 0035/0036): su ADR nació como 0035 y se renumeró a **0037** al reconciliar; la versión pasó de 1.17.0 a **1.18.0**.

## [1.17.0] — 2026-07-16

### El atlas de procesos del método vive en el repo, en BPMN (ADR 0035)

El método se documenta como diagrama de proceso navegable, versionado en `docs/atlas/`. BPMN ganó un bake-off de 3 formatos (BPMN vs Mermaid vs D2) por fidelidad de swimlanes: es el único que dibuja los carriles agente/humano como bandas reales — y ese reparto es el corazón de Jidoka.

- **`docs` — atlas importado a `docs/atlas/`** (25 BPMN + 1 DMN + índice `RELACIONES.csv`), limpio de la copia duplicada anidada con que llegó. Interno: no entra a `docs/guias/`, no se publica a npm.
- **`feat` — toolchain del atlas** (`docs/atlas/tools/`): `atlas:validate` (sin dependencias; verifica que todo `calledElement` resuelva y toda Call Activity esté en el CSV), `atlas:render` (SVG por `npx bpmn-to-image`, on-demand para no bajar Chromium en cada `npm install`), `atlas:layout` (`bpmn-auto-layout`, geometría automática). Scripts en `package.json`; `bpmn-auto-layout` como única `devDependency`.
- **`feat` — `16-cierra` re-modelado como patrón:** pool con carriles Agente/Humano, tareas de servicio (agente) y de usuario (`OK del dueño`), gateways `¿motor sano y sin drift?` (con lazo de corrección sin `--no-verify`) y `¿entrega versión?`. Los otros 19 diagramas siguen happy-path (siguiente lote).
- **`chore` — recomendación de editor** (`.vscode/extensions.json`: Miragon BPMN Modeler) con excepción en `.gitignore` para que viaje con el repo.
- **`docs` — ADR 0035** (aceptado) y guía de colaboración en `docs/atlas/README.md` (convención BPMN-formal / Mermaid-borrador).

### El atlas se acopla al flujo (aviso comando→diagrama) y se homologa a WYSIWYG (ADR 0036)

Decidido el acoplamiento **asimétrico**: el proceso (el `.md` del comando) es la fuente; prosa y diagrama son dos vistas; el código es implementación. Se descarta el acoplamiento simétrico de tres vías (fatiga, choca con el un-solo-bloqueo del manifiesto).

- **`feat` — área `atlas` en `tools/blast-radius.json`:** tocar un comando `/jidoka:*` **avisa** (no bloquea) revisar su diagrama en `docs/atlas/` (que lo declara como `Fuente`). El bloqueo no se cablea (regla 2-3: se gana con drift real). `probar-gate` sigue 10/10; `andon/README.md` actualizado (9 áreas).
- **`feat` — `atlas:sellar`** (`docs/atlas/tools/sellar-plataforma.mjs`): escribe `modeler:executionPlatform` (Camunda 7) en los `.bpmn`/`.dmn` para que el editor visual los abra directo, sin preguntar la plataforma en cada archivo.
- **`refactor` — `10-arranca` homologado a WYSIWYG:** los dos subprocesos embebidos ahora se muestran **expandidos** en el lienzo (sin drill-down), consistente con el resto del atlas. Se elimina el único diagrama que exigía doble clic para ver su detalle.
- **`chore` — `jidoka.code-workspace`** en la raíz: abre el repo con la extensión y la asociación de `.bpmn` al editor visual listas.

### La familia del ritual, re-modelada completa (carriles + gateways)

Los 9 diagramas de `10-ritual/` dejan de ser happy-path: cada uno se re-modeló desde su comando fuente con pool + carriles Agente/Humano, tareas de servicio (engrane) y de usuario (STOP), y gateways reales.

- **`refactor`** — `11-descubre` (juez de verdad + aprobación nombrada), `12-planea` (niebla→Call Activity a descubre, STOP del QUÉ), `13-construye` (el lazo Intención→Construcción→Verificación→Registro con reintento y OK humano), `14-revisión` (review-stop + pre-push + el muro de CI), `15-gemba` (objetivo vs. checkpoint del cliente), `17-que-sigue` (proponer por valor, la señal la da el cliente), `18-desatendido` (las dos lanes agente/humano + click-it-down). `10-arranca` y `16-cierra` ya estaban.
- Cada diagrama declara su `Fuente` (el aviso `atlas` del blast-radius apunta ahí). Los 25 SVG re-renderizados; `atlas:validate` sin huecos.

### El atlas completo, sin happy-path: instalación, lazo-motor, auditoría y release

Las 4 familias fuera del ritual (10 diagramas) se re-modelaron con carriles donde hay actor humano y gateways en las decisiones reales; los procesos de puro motor van en un carril único (honesto), no forzando un carril humano donde no lo hay.

- **`refactor`** — `30-instalar` (arquetipo humano + gate del smoke), `40-estado-motor` (gateway de divergencia), `41-actualizar` (loop por pieza con el gateway de 4 estados: ausente/al día/actualizar/diverge), `42-sellar` (pipeline de motor), `44-reportar-leccion` (lab reporta / mantenedor decide construir-vs-diferir), `70-auditoría-en-rama` (fan-out + veredictos GO/NO-GO), `71-nocturna` (reparto ejecutar-vs-preparar), `72-homologación` (gateway de 3 destinos: ascender/esperar/descartar), `80-publicar` (guardas + OK nombrado del dueño), `81-preflight` (las 7 suites → gate verde/rojo).
- **Con esto los 25 diagramas del atlas están re-modelados** (ninguno en happy-path). Cada uno inspeccionado a la vista; 25 SVG re-renderizados; `atlas:validate` sin huecos.

## [1.16.1] — 2026-07-16

### El método se mide a sí mismo — primer pase del análisis de costo neto sobre el lab real (issue #72)

- **`docs` — `docs/analisis/costo-neto-sgi-202607.md`** (`en_revision`): el análisis manual que pidió el issue #72, sobre evidencia existente de SimGhostInputs (dos barridos independientes: artefactos locales + API de GitHub). Titulares: el **muro server-side paga su costo con margen** (206 corridas, ~10 % rojas corregidas en minutos, 3 doc-drifts reales frenados antes del merge, ruleset sin bypass); el **costo dominante es el lazo y la doc ceremonial**, no los gates; y **cuatro piezas con cero señal de vida** en el lab (auditor `docs-graph` sin fallo histórico, `sprint-entrega.md` sin usos, `reportar-leccion` sin issues, summary de avisos afirmado en doc pero no implementado en config) quedan sobre la mesa para poda o prueba de vida (#46). Limitaciones explícitas; la instrumentación permanente (#66) espera la segunda medición (regla 2-3).
- **`docs` — #74-R3 evaluado en el issue** (sin cambio de código): `instalar.ps1` no contiene `-ExecutionPolicy Bypass` y la evidencia AV de `v1.14.0` ya midió que quitarlo no baja del umbral heurístico. Del issue queda vivo solo el certificado Authenticode.

## [1.16.0] — 2026-07-16

### La conciencia del agente se instala — asientos-subagente tiereados y el arranca que inyecta, no encarga (ADRs 0033/0034)

Reconstrucción limpia del sprint descartado por la regresión enmascarada ([#75](https://github.com/ArmandoMedina/jidoka/issues/75) es el inventario; el salvavidas que la caza nació en `v1.15.0`). Principio de la familia (ADR 0029): *nada de conciencia depende de la iniciativa del agente*.

- **`feat` — agentes-asiento tiereados ([#63](https://github.com/ArmandoMedina/jidoka/issues/63), ADR 0033).** `.claude/agents/{explorador,mecanico→haiku · auditor→sonnet · arquitecto→opus}` con `model:` y `tools:` fijos en frontmatter: el tier deja de vivir en prosa que nadie obliga a leer — se elige el asiento, no el modelo. Lint `tools/probar-agentes.ps1` (caza aliases inventados; en el preflight del release) y `".claude/agents/*"` entra al área `ritual` de la ley. La tabla asiento→tier aterriza en `kanban/roles.md`.
- **`feat` — el `arranca` inyecta, no encarga (ADR 0034).** El estado (`@HANDOFF`, `@product/PRODUCT_BRIEF.md`, `@product/infra.md`, `@CONTRIBUTING.md`) se inyecta al abrir — un puntero es una esperanza, un `@` es un hecho. **Reframe rol-teatro:** el orquestador ya no "se sienta" — el roster es la tabla de responsables, el router es un preview de gates, y el asiento con dientes lo ocupa el subagente tiereado.
- **`feat` — el QUÉ y el CÓMO-operativo se separan (#75).** `product/recursos-del-proyecto.md` se divide en `product/PRODUCT_BRIEF.md` (el QUÉ de Jidoka, consolidado desde lo ya escrito) y `product/infra.md` (identidades, máquinas, convenciones). El casting nombrado sobrevive como plantilla en `kit/` (los hijos castean; la nave usa roles neutrales a propósito — decisión 2026-07-14). Plantilla nueva `kit/.jidoka/templates/infra.md` para los hijos.

## [1.15.0] — 2026-07-16

### El juez falla cerrado — el preflight no aprueba lo que no corrió y el motor no se borra sin decisión (ADR 0032)

Cosecha #6 del lazo, nacida de dos fallas de la misma familia cazadas en vivo cortando `v1.14.0`: **jueces del motor que aprueban lo que no midieron**. El preflight del release imprimió `[OK]` de un test cuyo archivo estaba en cuarentena de AV ([#78](https://github.com/ArmandoMedina/jidoka/issues/78)); y en un sprint anterior un subagente borró 750 líneas del motor sin que ningún gate lo cazara ([#73](https://github.com/ArmandoMedina/jidoka/issues/73)).

- **`fix` — el preflight de `publicar.ps1` falla cerrado ante un test ausente (#78).** Guarda `Test-Path` antes de correr cada `probar-*` (un archivo en cuarentena mata el corte con la ruta alterna señalada: la evidencia server-side vive en el CI) + reset de `$LASTEXITCODE` antes de cada test (la otra mitad del mecanismo: el exit viciado del test anterior). Decisión del cliente (2026-07-16): morir siempre, no "[AUSENTE] y seguir". `probar-publicar` sube a 7 casos (ROJO→VERDE).
- **`feat` — salvavidas `no-borres-el-motor` en `verificar.ps1` (#73, disparo 15.º).** Si el cambio **borra** una pieza del motor (`tools/*.ps1`, `tools/blast-radius.json`) sin un ADR nuevo en el mismo cambio → `[BLOQUEA]`. Una decisión se documenta; un accidente no — restaurar es seguro, el archivo sigue en git. Detección vía `--diff-filter=D`; parámetro `-BorradosInyectados` para pruebas; `probar-gate` sube a 12 casos (ROJO→VERDE).
- **`docs` — las rutas AV dejan de ser invisibles.** La guía del motor gana la receta oficial `skip-worktree` (#79: cuándo, cómo auditarla con `git ls-files -v`, cómo revertirla — la cura mecánica queda regla 2-3); el README presenta `sembrar-manual.ps1` como ruta AV-independiente de primera clase (#74-R2).
- **`docs` — la frontera de producto se declara (#71, primer paso).** README + ROADMAP distinguen **Jidoka Core** (estable) de las **familias opcionales** (Discovery / Docs / Operations / Observability) con su estado de madurez. Solo documentación; nada se reorganiza.

## [1.14.0] — 2026-07-15

### El instalador AV-seguro se vuelve completo — `sembrar-manual.ps1` siembra la instancia entera (ADR 0027, enmienda)

Nace del **segundo entorno endurecido** (regla 2-3), esta vez en la máquina del autor: Bitdefender Endpoint Security Tools puso en cuarentena `instalar.ps1` **y** `probar-instalador.ps1` (`CMD:Heur.…Boxter`, familia ransomware). La investigación **contra el AV real** (evidencia en `qa_runs/av-sembrar-20260715/`) tumbó la hipótesis del "nombre-imán" del ADR 0027: **el trigger es densidad de comportamiento acumulada, no el nombre ni una línea suelta** — cayó el test (`probar-instalador`, que no instala) y sobrevive `sembrar-manual` (que sí siembra); quitar el flag Bypass, el spawn o el loop de bytes no baja del umbral; partir el archivo sí. Re-clonar no cura (el scan re-detecta el contenido).

- **`feat` — `sembrar-manual.ps1` completa la siembra de instancia.** Deja de sembrar solo mecánica + ley + sello: ahora también los **stubs de instancia** (HANDOFF, ROADMAP, CHANGELOG, índice de ADRs, `.gitignore` + la semilla del QUÉ del arquetipo), enrutados por el mismo loop no-clobber para no subir su densidad heurística. Un cliente en máquina endurecida obtiene un repo **entero**, sin depender de su AV ni de un certificado de firma.
- **`test` — `probar-sembrar.ps1` sube a 26 casos** (2 nuevos: stubs comunes + semilla del arquetipo).
- **`ci` — `probar-instalador` y `probar-sembrar` corren en el CI** (`andon.yml`), donde no hay Bitdefender. El preflight del instalador deja de depender de la máquina del autor (que los tiene en cuarentena); el CI ejercita el código nuevo server-side (`probar-instalador` 51/51, `probar-sembrar` 26/26).
- **`docs` — ADR 0027 enmendado + `mantener-el-motor-al-dia.md` reposicionado:** `sembrar-manual` pasa de *fallback* a *camino AV-seguro primario*; se corrige la causa (densidad, no nombre); la firma (Authenticode) queda como la cura robusta de fondo, diferida por falta de cert.

**Evidencia (verde, esta máquina 2026-07-15, contra Bitdefender EST):** `probar-sembrar` 26/26 · oráculo de AV (el archivo editado queda legible como el sobreviviente, no en cuarentena) · demo de siembra fresca con instancia completa. LOG: `qa_runs/av-sembrar-20260715/`.

## [1.13.0] — 2026-07-14

### La capa de consultoría: `/jidoka:descubre` — sacar la sopa cuando el QUÉ está borroso (ADR 0031)

Nace de contrastar tres despliegues reales: donde el cliente trae el QUÉ claro el ritual vuela; donde no, patina — y el método solo sabía *marcar* la niebla ("pendiente del cliente"), no disolverla. Los diagnósticos de campo midieron el porqué: **el QUÉ vive en ejemplos concretos, no en documentos** (el aparato metodológico era idéntico en los tres repos); **STOP no es comprensión** (checkpoints atravesados con *"autorizo a tu criterio"* costaron sprints de retrabajo); y a veces la autoridad del dominio es **un tercero que no opera la IA** (*"no conozco el producto y el experto no está"*).

- **`feat` — el comando `/jidoka:descubre`.** Entrevista de descubrimiento mecánica: diagnóstico de UNA pregunta cerrada (3 nieblas: no sé ni el problema / sé la idea pero no el alcance / sé el síntoma operativo — más ¿quién es el juez de verdad?), rondas de preguntas fijas por ruta (cronología de hechos estilo JTBD; apetito + caso ancla narrado; evidencia de primera mano + porqués confirmados), **filtro Mom Test como lista negra escrita** (prohibido "¿te gustaría…?"; obligatorio "cuéntame la última vez que…"), cero jerga sin traducir, y cierre poblando el brief. La lectura se **inyecta** (@-include del brief al abrir), no se encarga.
- **`feat` — el brief gana los campos del descubrimiento** (`PRODUCT_BRIEF.md`): caso concreto citable · métrica con número · autoridad del dominio (quién juzga, disponibilidad, formato de validación) · criterio de "hecho" · apetito · no-metas · aprobación del QUÉ.
- **`feat` — la autoridad tercera** (plantilla `kit-entrevista.md`): kit de entrevista portátil (3–7 preguntas en el lenguaje del experto, formato mensajeable por WhatsApp) para el experto que es **autoridad, no usuario**; sus respuestas regresan como evidencia rastreada (`docs/gemba/`), y su formato de validación se define desde el descubrimiento.
- **`feat` — disparo 14.º `aprobacion-nombrada`** (cableado en `descubre`, nombrado en `planea`): lo que se aprueba se nombra — "dale"/"a tu criterio" no cierran un QUÉ. `probar-disparos` sube a 14 (ROJO→VERDE).
- **`feat` — el ruteo mecánico:** `planea` R0 ya no solo marca la ambigüedad: **manda a `/jidoka:descubre` primero**.

## [1.12.1] — 2026-07-14

### La nave nodriza respeta su propia doctrina (dogfooding al día)

Pase de dogfooding tras auditar el propio repo contra lo que su método exige a los hijos: dos huecos duros y un drift blando, todos cerrados aquí; lo que no era hueco quedó con su razón registrada (el "no hay sello" propio es correcto por ADR 0024; sin `CLAUDE.md` es doctrina anti-memoria).

- **`fix` — `publicar.ps1` corre `probar-sembrar` en su preflight.** El follow-up conocido de v1.10.0: el smoke del fallback anti-AV (`sembrar-manual`, 24 casos) existía pero el release se cortaba sin correrlo. Además, `probar-publicar.ps1` gana un caso invariante (ROJO→VERDE) que cierra la clase entera: **todo `probar-*.ps1` del motor debe estar en el preflight** — el próximo self-test que nazca fuera de la lista rompe el meta-test, no un release.
- **`docs` — el propio repo siembra su `## El casting`** en `product/recursos-del-proyecto.md` (la sección que v1.12.0 prescribe y la nave nodriza no tenía: su `arranca` caía al fallback neutral). Con nombres neutrales a propósito — decisión del cliente: seguir la ruta del usuario recién sembrado, sin sesgo — y los asientos dormidos (revisor-visual/validador) anotados como lo que son: áreas que la ley aún no declara.
- **`docs` — el listón `LOG.md` (ADR 0030) se adopta en casa.** Las corridas de `qa_runs/` anteriores predatan la convención y se conservan tal cual (no se fabrica evidencia retroactiva); `qa_runs/README.md` lo acusa. La corrida de evidencia de este mismo cambio (`qa_runs/dogfood-20260714/`) es el **primer uso propio** de la plantilla `qa-log.md`.

## [1.12.0] — 2026-07-14

### Cosecha #5: instalar = funcionar — la conciencia se instala (ADRs 0029/0030 — cierra #53/#51)

Quinta cosecha por el lazo. Una instalación fresca entregaba la capa **máquina** (hooks, CI, gates) y funcionaba, pero la capa de **conciencia** —quién se sienta, qué cambio se rutea a qué asiento, qué gate está vivo o dormido— viajaba como prosa que nada obligaba a usar. En campo eso costó: la calidad de la evidencia se degradaba dentro del mismo día (un `LOG.md` rico → un `veredicto.txt` pelón) y en otro lab la brecha la tapaba el usuario a mano, con un párrafo de apertura escrito cada sesión. El principio de la cosecha: **nada de conciencia puede depender de la iniciativa del agente** — se instala como maquinaria determinista o no está instalada.

- **`feat` — el `arranca` sienta y rutea (ADR 0029, cierra #53).** Nuevo `tools/rutear.ps1` (mecánica, se siembra): fuente única de la lógica router + vivo/dormido; lee la ley y reporta, por área, qué asiento la ocupa y qué gate la vigila, y por Stop hook si está **VIVO o DORMIDO** con la **razón** de cada dormido. **Falla cerrado** (exit 1) sin ley legible. `/jidoka:arranca` gana una sección que **adopta el casting** de `recursos-del-proyecto.md` (que ahora se siembra con la sección **## El casting**) y **lee el router** al abrir (regla *"adopta, no resumas"*). Cuatro casos de prueba de vida nuevos.
- **`feat` — la dormancia se hace visible (cierra #51).** `estado-motor.ps1` imprime la sección Gates (vía `rutear -Gates`) **siempre**, antes del sello: un Stop hook dormido ya no sale limpio y en silencio — se lista como DORMIDO con su razón.
- **`feat` — el listón de evidencia: el `LOG.md` de la corrida (ADR 0030).** `gemba-stop` y `validador-stop` ya no cuentan cualquier archivo rastreado y fresco bajo `qa_runs/` — solo `qa_runs/<corrida>/LOG.md` (para validación, `qa_runs/validador-*/LOG.md`). Cierra un Goodhart real: un `veredicto.txt` pelón satisfacía el gate y la evidencia rica se degradaba a una tabla vacía en campo. El gate mide **presencia + frescura + tracking** del `LOG`; su contenido lo juzga el humano. Se siembra la plantilla `kit/.jidoka/templates/qa-log.md`; dos casos de vida nuevos en ROJO→VERDE.
- **`feat` — el demo que corre el cliente, sin código ni terminal (disparo `demo-que-corre-el-cliente`, 13.º del catálogo).** La Verificación de una rebanada debe demostrarse sin código ni terminal (abrir una URL, hacer clic, mirar un reporte); si no se puede, la rebanada no es vertical — se re-rebana o se marca pendiente. Cableado en `planea`, `cierra` y las plantillas `sprint-plan`/`sprint-entrega`.

## [1.11.0] — 2026-07-14

### El tercer gate de evidencia (`validador-stop`) + el fallo-abierto de los Stop hooks (ADR 0028)

Cuarta cosecha por el lazo: tres issues (#50–#52) de un despliegue real en un repo de **reconstrucción / ingeniería inversa**, donde el entregable central no era código ni UI sino una **especificación numérica** verificada contra golden-masters. Un sprint la cerró con un *"validado al centavo"* en prosa y **ningún gate lo atrapó** — el tipo de deliverable caía fuera de lo que la ley vigilaba.

- **`fix` — los Stop hooks fallaban-abierto en directorios recién-nacidos (#50).** `git status --porcelain` (sin `--untracked-files=all`) **colapsa** un dir sin ningún archivo trackeado en una sola entrada `dir/`, y el glob específico de una `fuente` no casa → el gate salía limpio **justo en el deliverable nuevo que existe para atrapar**. Arreglado en los 3 Stop hooks (fuente = semilla del kit) + su caso de prueba de vida que distingue el bug (ROJO→VERDE).
- **`feat` — el gate de validación por medición, `validador-stop` (#52, ADR 0028).** Tercer gate de evidencia, simétrico a `review-stop` (código) y `gemba-stop` (visual) pero para **números**: un área `rol: validador` en la ley enciende un Stop hook que **frena el cierre** si la spec/datos cambia sin evidencia **fresca y rastreada por git** de una corrida de motor determinista en `qa_runs/validador-*`. El motor emite la tabla `entrada → obtenido → esperado` (**el cálculo lo hace el motor, nunca el LLM**). Incluye la **variante local** para fixtures confidenciales (PII gitignored): el gate corre en `Stop`, no en CI, y exige la evidencia commiteada saneada. Nace **dormido** en Jidoka (sin deliverable de datos propio); cinco casos nuevos de prueba de vida.
- **Registrado como lección de método:** #51 (los gates de evidencia pueden quedar todos dormidos a la vez) y #53 (la capa de *conciencia*: el `arranca` canónico sub-informa al orquestador sobre los asientos) quedan abiertos en el ROADMAP/issues para la siguiente cosecha.

## [1.10.0] — 2026-07-13

### La ruta de actualización deja de colgar del instalador (ADR 0027) + el auditor configurable

Tercera cosecha por el lazo: siete issues (#40–#46) de dos despliegues reales (un repo regulado **PLD/CNBV** y
un proceso de **operación**). Se atendieron los dos con daño activo; los otros cinco se registran en el ROADMAP
con marca **regla 2-3** (esperan su 2º/3er uso real, no se construyen por método-ficción).

- **[#40/#43] Fallback anti-AV `tools/sembrar-manual.ps1`.** En Windows endurecido con AV de terceros,
  `instalar.ps1` cae en cuarentena heurística (nombre "instalar" + `core.hooksPath` + hooks + `-ExecutionPolicy
  Bypass`) y el SO niega leerlo/ejecutarlo, **mudo**: el hijo queda sin ruta de siembra/actualización. El fallback
  es el **segundo camino, independiente** de `instalar.ps1` (no usa `Bypass`, no se llama "instalar"): copia la
  `mecanica` del manifiesto, fija `core.hooksPath` y escribe el sello — mismo estado final, no-clobber y tres vías
  incluidas. Se siembra como motor (baja a los hijos por el lazo). Sus helpers puros están **duplicados a propósito**
  (debe correr aunque `instalar.ps1` sea ilegible).
- **[#40/#43] `estado-motor.ps1` degrada con gracia**: al avisar que estás atrás, detecta si `instalar.ps1` es
  legible; si el AV lo bloqueó, apunta directo a `sembrar-manual.ps1 -Actualizar` en vez de recomendar un script
  que no va a correr.
- **[#42] `scanDirs` del auditor configurables desde la instancia**: campo `scanDirsExtra` en la ley
  (`tools/blast-radius.json`) amplía el índice de wikilinks del auditor a capas de docs propias del repo (p.ej.
  `engineering/`), para que un `[[wikilink]]` de `product/` hacia ellas no cuente como roto y bloquee el CI. Sin el
  campo, comportamiento **idéntico** al anterior.
- **Cobertura nueva**: `tools/probar-sembrar.ps1` (24 casos: siembra, paridad del sello con `instalar.ps1`,
  no-clobber, tres vías, degradación con gracia) + 2 casos en `probar-auditor.ps1` (#42, con y sin config).
- **El acuse del lazo, escrito**: `docs/guias/reportar-leccion-a-jidoka.md` gana la sección *"Cómo se acusa una
  lección"* (el 3er paso, antes tácito): todo reporte recibe respuesta, con dos plantillas (construida / diferida
  por regla 2-3) para que lo diferido no se lea como rechazo y el issue abierto sea el marcador del contador 2-3.
- **Cosechados al ROADMAP (regla 2-3, no construidos)**: `doc-only` (#41, primer uso real), arquetipo `operacion`
  (#44), gobernanza compuesta (#45), prueba de vida ≠ tests verdes (#46), y reducir la superficie de AV del
  instalador original (renombrar/firmar/`npx`).

El fallback y el auditor configurable son **mecánica**: bajan a los labs por `-Actualizar`.

## [1.9.0] — 2026-07-12

### Cosecha brownfield: cinco arreglos al bajar el método a repos reales (ADR 0026)

Al bajar el método a repos reales —SGI (experimento) y **TequiOBD** (adopción brownfield)— el propio método hizo
aparecer **cinco defectos** del instalador con una raíz común: no era consciente de la **instancia** ni del
**arquetipo** del hijo. Los cinco quedan cerrados (issues #34–#38).

- **[#36] El sello del install fresco clasifica pristina-vs-customizada** (como `-Sellar`). Antes, en un hijo
  brownfield con piezas customizadas (saltadas por no-clobber), registraba la versión **customizada** como semilla
  → el próximo `-Actualizar` la **pisaba** (pérdida de datos). Ahora compara destino vs origen y **omite** las
  customizadas. Helper compartido `Get-SelloClasificado` (install y `-Sellar`, una sola lógica).
- **[#38] El arquetipo declara `excluir_motor`**: `code-first` excluye `tools/probar-gate.ps1` y
  `.github/workflows/andon.yml` (prueban el contrato canónico de `verificar`, que code-first customiza). Mata la
  fricción recurrente que SGI y TequiOBD resolvían a mano por separado.
- **[#37] Aviso de cableado inerte**: si un `.claude/settings.json` preexistente no cablea los hooks del motor
  actual (`review/andon/gemba-stop`) o su `PreToolUse` no cubre `Bash`, el install **avisa** en vez de callar.
- **[#35] Guía aclarada** (`mantener-el-motor-al-dia.md`): al **conservar** la versión local, se borra el
  `.jidoka-nuevo` antes de commitear; el diff del PR lleva la decisión aplicada, no el sidecar.
- **[#34] El wrapper npx no fuerza `-ExecutionPolicy Bypass`** (los guardrails de agentes IA lo bloquean):
  pre-chequea la política y solo lo agrega si de verdad bloquearía (`Restricted`/`AllSigned`).

Cobertura nueva en `probar-instalador.ps1` (caso brownfield + caso code-first). Los arreglos son **mecánica**:
bajarán a los labs (SGI, TF, TequiOBD) por `-Actualizar`.

### El substrato es git porque es el idioma nativo del agente (ADR 0025)

Cierra el *por qué git* que le faltaba al [ADR 0008]. Ante la hipótesis *"¿y si dejamos git por una API más potente
y flexible?"*: git **no está forzado** — es el **idioma nativo del agente**; una API es fuera-de-distribución y se
**degrada con el agente**, git no. La tesis del método es que el substrato aguante *cuando el agente se degrada*.
**Evidencia archivada**: 3 agentes frescos, ciegos, sin contexto (2 arrancando dentro del hijo) operaron el lazo
(`-Actualizar`) desde los artefactos solos y preservaron la instancia — **3/3**, calzando exacto con la referencia.
Sincronizar = lógica de registry, **interfaz de git**. Incluye predicción falsable (prueba de vida).

## [1.8.1] — 2026-07-11

### El motor se lee del árbol — cierra la decisión abierta del ADR 0003 (ADR 0024)

Resuelve el último pendiente de la Fase 3.C (el "dogfood completo": mover el motor a `kit/` y que Jidoka se
auto-instale). Al analizarlo contra el artefacto: la premisa **ya no se sostiene** — hoy no hay dos copias (el
motor se lee del árbol raíz; `kit/` solo trae plantillas de instancia). Migrar **crearía** la duplicación que
buscaba evitar, para los docs es imposible sin duplicar (son contenido + semilla), y el dogfood ya lo cubre
`probar-instalador` (instala en temp + corre los self-tests sembrados). **Decisión: se mantiene leer-del-árbol**
como diseño deliberado, no provisional. Sin cambio de código; lo que cambia es que ahora está decidido.

## [1.8.0] — 2026-07-11

### El CLI `npx jidoka-method` (construido, listo para publicar) + párrafo en inglés

Dos piezas de distribución/presentación.

- **CLI npm** (`package.json` + `bin/jidoka-method.js`): un **wrapper Node** que reusa `tools/instalar.ps1` vía
  PowerShell (`pwsh` en Mac/Linux, `powershell` en Windows) en vez de duplicar el instalador. Subcomandos
  `init` / `actualizar` / `sellar`. **Probado en Windows** (siembra 76 archivos vía el wrapper); la ruta
  Mac/Linux (pwsh Core) **debería** funcionar pero **NO está verificada** — no afirmamos cross-platform sin
  evidencia. **`npm publish` pendiente** (necesita la cuenta npm del mantenedor); hasta entonces, usable en el
  repo con `node bin/jidoka-method.js init <ruta>`. **SSOT extendido**: `probar-version.ps1` ahora exige
  `package.json.version == version.txt` (el CLI no puede mentir sobre qué versión instala).
- **Párrafo en inglés** en el README (decisión del autor): un solo párrafo para el visitante anglófono —
  qué es Jidoka y por qué está en español a propósito. La maquinaria es language-agnostic.

## [1.7.1] — 2026-07-11

### Comunidad — `CODE_OF_CONDUCT.md` (Contributor Covenant 2.1 ES)

Archivo de salud de comunidad para el repo público (GitHub lo muestra en la pestaña de comunidad y da un
mecanismo neutro de moderación antes del primer conflicto con extraños). Contacto vía el perfil de GitHub del
mantenedor / issue del repo — **no publica un correo personal** (esa elección queda del autor; cambiable a
email si lo prefiere). No se siembra (cada repo tiene su propia política).

## [1.7.0] — 2026-07-11

### La estructura canónica — comandos namespaced, rol neutral el mecanismo (ADR 0023)

Cierra la **segunda mitad** del drift estructural (ADR 0015 #3): faltaba declarar cuál FORMA es canónica entre
Jidoka y los labs (que divergían, con cruft — SGI tenía los mismos comandos y skills duplicados).

- **Comandos namespaced** (`.claude/commands/jidoka/*`, `/jidoka:*`) = canónico: un método instalado no debe
  colisionar con los comandos propios del proyecto anfitrión.
- **El rol neutral es el mecanismo** (la ley referencia roles); el **nombre del skill es sabor de instancia** —
  neutral (Jidoka) o persona (labs, si declaran su asiento neutral; ADR 0035). La autoridad la da la ley, no el
  nombre.
- **Los labs convergen la forma, conservan el sabor** — usando la exclusión (ADR 0022) para su familia de
  skills. Jidoka ya es namespaced+neutral: no cambia; el trabajo es reconciliar los labs.

## [1.6.0] — 2026-07-11

### Guía — "Mantener el motor al día" (el canal de bajada, documentado)

Cierra un hueco de doc: los mecanismos del lazo shippeados post-1.0 (`-Sellar`, `estado-motor -Detallado`,
`excluir`, el EOL-agnóstico, y `publicar.ps1`) no estaban en ninguna guía. `docs/guias/mantener-el-motor-al-dia.md`
(nueva, `estado: vigente`, **sembrada** a los labs) es la guía operativa para quien mantiene un repo instalado:
cuándo y cómo `-Actualizar`, leer la salida (`[ACTUALIZA]`/`[NUEVO]`/`[DIVERGE]`/`[EXCLUIDA]`), manejar
divergencias (`.jidoka-nuevo` / costura `.local`), declarar `excluir`, ver la divergencia fina con `-Detallado`,
y sellar con `-Sellar` (con su límite: no para repos atrasados). Más una sección para el mantenedor de Jidoka
(`publicar.ps1`). `probar-instalador.ps1` 45/45 (siembra + verificador de enlaces).
- **Fix `publicar.ps1`** (dogfood, cazado al cortar este release): el título derivado del CHANGELOG llevaba
  comillas dobles y PS 5.1 rompe el paso de un argumento con `"` embebido a `gh`. Se **sanea** el título (las
  notas, que van por `--notes-file`, las conservan). Caso nuevo en `probar-publicar.ps1`.

## [1.5.1] — 2026-07-11

### Doctrina — matiz de la cita Airbus (fact-check)

`doctrina/03-aviacion.md`: los límites duros del envelope Airbus (la analogía del `deny`) valen en **Normal
Law**; bajo fallas el avión degrada a **Alternate/Direct Law** y las protecciones se pierden — el piloto sí
puede exceder el envelope. La 'dureza' del `deny` es condicional al modo. Con la lección para el gate: **hasta
un `deny` duro tiene modo degradado; confiésalo** (como las *fronteras del muro*). Registrado como cita #9 en
`doctrina/citas-verificadas.md`. Doc-only.

## [1.5.0] — 2026-07-11

### La lista de exclusión del hijo — el lazo no re-agrega lo que el hijo no quiere (ADR 0022)

Cierra la mitad "re-agregado" del drift estructural (ADR 0015 #3), lección de la ventana de bajada: en cada
`-Actualizar` los labs rehacían los mismos back-outs (`probar-gate`, `andon.yml`, comandos namespaced, skills
genéricos) porque el lazo los re-agregaba como piezas nuevas.

- **El sello gana `excluir: [rutas]`**: las piezas de mecánica que el hijo declara que **no quiere**.
  `-Actualizar` no las re-agrega, no las toca (reporta `[EXCLUIDA]`); `-Sellar` las salta; ambos **preservan**
  la lista entre bajadas. Sin `excluir` (sellos viejos): comportamiento idéntico (retro-compatible).
- **Seguro**: solo omite, nunca borra ni pisa. El hijo declara una vez y el lazo lo honra siempre.
- Evidencia: `probar-instalador.ps1` 45/45 (3 casos nuevos). **Siguiente**: los labs añaden su `excluir` una vez
  → su próxima bajada no pedirá back-outs.

## [1.4.0] — 2026-07-11

### El lazo es agnóstico al fin de línea — `Get-MotorHash` normaliza a LF (ADR 0021)

Bug estructural del lazo, cazado al bajar el batch a los labs: **un hijo con `eol=lf` divergía en TODAS las
piezas** porque el three-way comparaba `hash(LF del hijo)` vs `seed(CRLF de Jidoka)` — nunca casan, aunque el
contenido sea idéntico. TF (LF) reportó `0 al día | 62 divergen`; SGI (CRLF, casa Jidoka) funcionó.

- **`Get-MotorHash` hashea el contenido normalizado a LF** (quita `0x0D` antes de SHA256) → el hash es
  agnóstico al fin de línea. Aplicado en `instalar.ps1` (`-Actualizar`/`-Sellar`/sembrado), `estado-motor.ps1`
  (`-Detallado`) y `probar-instalador.ps1`. La política de EOL es del hijo, no de Jidoka.
- **Caso nuevo en `probar-instalador.ps1`** (42/42): convierte un hijo entero a LF y verifica que `-Actualizar`
  reporta **0 divergencias** (antes del fix: todo divergía).
- **Consecuencia**: los sellos de SGI/TF (hashes CRLF de la bajada previa) se re-clasifican una vez; la bajada
  del batch se **rehace** con el instalador arreglado en ambos labs.

## [1.3.0] — 2026-07-11

### El release se deriva del SSOT — `publicar.ps1` (ADR 0020)

Quita el tipeo manual de versión del ritual de release: la versión se escribe UNA vez en `tools/version.txt`
(el SSOT) y el tag, el título y las notas del release **derivan** de ahí + del CHANGELOG.

- **`tools/publicar.ps1`** (Jidoka-only): lee la versión del SSOT, extrae su sección del CHANGELOG (leída como
  UTF-8, para no corromper acentos/flechas en las notas), corre **la suite completa** de self-tests
  (evidencia-no-palabra: no publica un motor roto, bajo `ErrorActionPreference=Continue` para que un warning
  benigno de git no aborte), y crea el tag + release. `-DryRun` muestra todo sin correr nada; `-SoloVerificar`
  corre el preflight (suite) sin publicar. *(El estreno cazó un bug del propio `publicar.ps1` —el `Stop` volvía
  fatal un warning `LF→CRLF`— antes de crear el tag: `prueba-de-humo-del-gate` en acción.)*
- **`tools/probar-publicar.ps1`** (Jidoka-only, 4 casos): prueba de vida del `-DryRun` (deriva el tag del SSOT,
  no crea tags). Junto con `probar-version` quedan CI-gateados en Jidoka vía una guarda `Test-Path` en
  `andon.yml` (se saltan en un hijo que no los tiene).
- **Dogfood**: este `v1.3.0` se cortó con `publicar.ps1` — su primera corrida real es su prueba de vida.
- Primer peldaño del CLI npm (cuando se retome): la versión ya está centralizada y derivable.

## [1.2.0] — 2026-07-11

### El lazo ve la divergencia — sello bootstrap clasificador + `estado-motor -Detallado` (ADR 0019)

Ejecuta dos de las cuatro lecciones de la segunda cosecha (ADR 0015): mejoras a la mecánica del lazo, sin tocar
los labs. Son la herramienta de la propia bajada — conviene tenerlas antes de la próxima ventana de bajada.

- **`instalar.ps1 -Sellar`**: sella un hijo que convergió a mano **clasificando cada pieza** contra el Jidoka
  actual — pristina (== Jidoka) → registrada; customizada (!= Jidoka) → omitida de la semilla, así el próximo
  `-Actualizar` la ve DIVERGE y la **preserva**. Generaliza en la máquina el arreglo que en Sprint B se hizo a
  mano en SGI/TF (mejor que asumir-pristina —el bug que casi pisa SGI— y que semilla-vacía —que no actualiza
  lo pristino—).
- **`estado-motor.ps1 -Detallado`**: compara **pieza por pieza (por hash)** contra el motor de Jidoka y lista
  las que DIVERGEN o faltan; la versión sola era de grano grueso (decía "al día" aunque una pieza divergiera).
  El mensaje de versión pasa a *"declara la versión X"* — más honesto.
- Evidencia: `probar-instalador.ps1` 41/41 (6 casos nuevos). **Follow-through**: ambas son mecánica → bajan a
  SGI y TF en la próxima ventana de bajada, y el re-sellado usará `-Sellar`.

## [1.1.1] — 2026-07-11

### Fix — el matcher Bash de `no-memorias` bloqueaba lecturas con `2>&1`/`2>/dev/null`

Regresión de `v1.1.0` (ADR 0018), cazada por dogfooding minutos después de publicar: el token `>` de la lista
de escritura casaba con `2>&1` y `2>/dev/null` (redirecciones de **stderr**, no escrituras a memoria), así que
un comando de **lectura** común (`cat …/memory/x 2>&1`) se denegaba en falso.

- **Fix**: la redirección se maneja aparte del `>` suelto — solo cuenta como escritura una redirección **cuyo
  destino es la ruta de memoria** (`>`/`>>` seguido de la ruta, sin cruzar otro redirect/pipe), o un cmdlet de
  escritura (`Set-Content`/`Out-File`/`cp`/`mv`/`tee`…) con la ruta. `2>&1`/`2>/dev/null` ya no cuentan.
- Dos casos de regresión nuevos en `probar-hooks.ps1` (17/17): lectura de memoria con `2>&1` y con
  `2>/dev/null` → **allow**; las escrituras siguen **deny**.

## [1.1.0] — 2026-07-11

### El muro cumple lo que promete — grietas 2 y 5 cerradas con invariantes testeables (ADR 0018)

Endurece la promesa central (*los gates son deterministas, no teatro*) cerrando dos huecos confesados de la
auditoría externa, con tests y no con prosa.

- **`no-memorias` cubre Bash** (grieta 2, cerrada en parte): el hook inspecciona `tool_input.command` y deniega
  la **escritura** a la memoria de Claude vía Bash (`Set-Content`/`Out-File`/redirección `>`/`cp`/`mv`/`tee`);
  la lectura/recall no se bloquea. Matcher `Write|Edit` → `Write|Edit|Bash`. Cuatro casos nuevos en
  `probar-hooks.ps1` (15/15). **Residual honesto** (confesado en `andon/README.md`): aliases y rutas ofuscadas
  evaden el matcher; server-side no es gateable (la memoria es conducta del agente, no estado del repo).
- **El registro de disparos cableados** (grieta 5, cerrada): cada disparo de `kit/.jidoka/disparos/` declara
  `Cableado en: <punto>` (que nombra su slug) o `Catalogo-solo: <razón>`. `tools/probar-disparos.ps1` (nuevo,
  4/4, con caso sintético de rot) verifica que ningún cableado se caiga de su punto — la grieta real era la
  falta de verificación, no de cableado. Tolerante a puntos no sembrados en un hijo (los omite con aviso
  visible). Registrado en CI (`andon.yml`) y en el manifiesto (`mecanica`); `probar-instalador` 35/35.
- **Follow-through**: el hook y `probar-disparos` son mecánica → bajarán a SGI y TF por `-Actualizar`.

## [1.0.0] — 2026-07-11

### Jidoka sale de beta — el método corre end-to-end en repos ajenos (ADR 0017)

Se cumple, **con evidencia**, la vara de 1.0 del ROADMAP: *el método completo corre end-to-end en un repo
ajeno*. El programa hacia 1.0 lo remató bajando el núcleo a **dos labs reales** por el lazo de sincronización.

- **Los dos labs bajaron el núcleo `0.13.0-beta`** (ADR 0015): **SimGhostInputs `v2.6.0`** (Python) actualizó
  el núcleo y curó un bug del sello; **tracker-financiero `v0.2.0`** (JS/PWA) se cableó al lazo (sello + canal
  de subida + `core.hooksPath`). Ambos PRs con **CI verde server-side** —el `audit` de blast-radius y el
  `gate-smoke` bloqueando de verdad, self-tests verdes— y evidencia en el `qa_runs/` de cada lab. Lo
  code-first se preservó sin pisar una pieza.
- **Segunda cosecha por el lazo** (ADR 0015): el mecanismo **probado en producción**; cuatro refinamientos que
  suben (generalizar el sello bootstrap pristina-vs-customizada, `estado-motor -Detallado` por-hash, el drift
  estructural núcleo↔labs, la épica `.local` code-first) quedan **registrados post-1.0** — ninguno bloquea.
- **Licencia MIT consciente** (ADR 0016): se mantiene MIT sobre copyleft, ahora como decisión razonada con su
  camino no tomado — no herencia.
- **`tools/version.txt` → `1.0.0`** (sin `-beta`). Alcance **1.0 funcional**: lo público (social preview,
  párrafo en inglés, `CODE_OF_CONDUCT`), el CLI npm/SSOT, multiplataforma y la reconciliación code-first vía
  `.local` se difieren **explícitos** a post-1.0 (ROADMAP).
- Evidencia: suite completa verde (`probar-version`/`gate`/`hooks`/`instalador`/`auditor` + `auditar` +
  `verificar -Base main`); required check `andon` verde en el PR de release.

## [0.13.0-beta] — 2026-07-11

### Jidoka listo para 1.0 — los cuatro bloqueantes de "corre en un repo ajeno" (ADR 0014)

Cierra los bloqueantes duros del criterio de 1.0 (*el método corre end-to-end en un repo ajeno*). Alcance **1.0 funcional**: lo público y el CLI npm quedan post-1.0.

- **El instalador pregunta el arquetipo** (`tools/instalar.ps1`): si no pasas `-Arquetipo` ni `-Yes`, menú interactivo (`docs-as-code`/`code-first`); con `-Yes` cae a `docs-as-code`. Antes el default silencioso sembraba el arquetipo equivocado a un repo code-first.
- **El método se siembra** (fin de los enlaces muertos): el manifiesto ahora siembra `kanban/` + `andon/` + `doctrina/` + la guía de entorno como `mecanica` → el hijo es autocontenido. Un **verificador de enlaces** en `probar-instalador.ps1` lo vuelve invariante (ningún doc sembrado cita un doc de método ausente).
- **Fixture del quickstart** (`probar-gate.ps1`): un caso que ejercita el flujo real commit→verificar por git, replicando el paso 3 del README (ADR sin listar → `[BLOQUEA]`; listarlo → pasa). La demo copy-paste no se rompe en silencio.
- **Guía `docs/guias/empezar-de-cero.md` completa** (`estado: vigente`): walkthrough de instalación desde cero verificado contra el flujo real.
- Evidencia: `probar-instalador.ps1` 34/34, `probar-gate.ps1` 10/10, suite completa verde.

## [0.12.0-beta] — 2026-07-11

### Primera cosecha por el lazo — tres lecciones de campo absorbidas (ADR 0013)

La primera cosecha que pasa **por el canal** que el lazo (ADR 0012) abrió — la máquina en uso. SGI (primer consumidor) reportó lecciones de campo y la sesión destapó una meta-lección del cliente; tres maduraron a mejora de método.

- **`gemba-stop` exige evidencia rastreada por git** (`.claude/hooks/gemba-stop.ps1`): antes validaba por *mtime del working tree* y `qa_runs/` está gitignoreado → un archivo que nunca se commitea satisfacía el gate (Goodhart). Ahora solo cuenta la evidencia que `git ls-files -- qa_runs` rastrea (`git add -f`), alineado con el disparo `evidencia-no-palabra`. Self-test nuevo: bloquea evidencia no-trackeada, pasa la forzada al índice (`probar-hooks.ps1` 11/11).
- **Excepción de dominio con nombre para el mandato sintético** (`revisor-visual` SKILL, `gemba.md`, `verificacion.md`): "datos 100% sintéticos siempre" → **"sintético por defecto, salvo excepción de dominio cableada con nombre"** (disparo `excepciones-cableadas`) para cuando lo sintético no ejercita el artefacto (HUD/render sobre telemetría) — dato real fuera del repo, solo capturas entran, excepción nombrada.
- **Criterio operativo de delegación** (`kanban/roles.md`): sección nueva "Qué va a subagente vs qué se queda" con tabla al vistazo + la sesión del lazo como ejemplo trabajado. Vuelve operativa una regla que era principio disperso (meta-lección del cliente).

## [0.11.0-beta] — 2026-07-11

### El lazo de sincronización labs↔Jidoka (Sprint 3 · Fase 3.C — ADR 0012)

*La lección sube, la máquina baja.* El primer canal mecanizado para que un repo hijo baje correcciones del motor sin que las versiones diverjan. Regla dura: **la mecánica converge idéntica; la estética/instancia nunca se sobrescribe; la divergencia se detecta y se preserva, no se pisa.**

- **Sello de versión sembrado** (`tools/jidoka-motor.json`): el instalador escribe en cada hijo de qué versión de Jidoka viene su motor + el SHA256 de cada pieza. La fuente única es **`tools/version.txt` (SSOT)**, atada al tope del CHANGELOG por el self-test `tools/probar-version.ps1` para que el sello no mienta.
- **Modo `-Actualizar` con conciencia de tres vías** (`tools/instalar.ps1`, estilo `dpkg conffiles`): re-siembra SOLO la mecánica (`clase: mecanica`). Por pieza — ausente→agrega; `hijo==Jidoka`→al día; `hijo==hash sembrado`→actualiza; `hijo!=hash sembrado`→**divergencia** (no pisa, deja `<archivo>.jidoka-nuevo` y reporta). La instancia (ley, `product/`, HANDOFF, ADRs) nunca se toca.
- **Aviso de divergencia** (`tools/estado-motor.ps1`, sembrado): compara el sello contra un Jidoka alcanzable (`-Jidoka`/`$env:JIDOKA_HOME`) y avisa "al día / atrás". Aviso, no muro (exit 0).
- **Canal de subida** (`tools/reportar-leccion.ps1` + `docs/guias/reportar-leccion-a-jidoka.md`): el hijo reporta la lección al issue `leccion.md` de Jidoka en vez de parchear su motor local.
- **Costura `.local`**: `verificar.ps1` dot-sourcea `tools/verificar.local.ps1` si existe — el hijo extiende la mecánica (ruff/pytest) sin bifurcar el genérico; la vía para converger sin clobber.
- **Manifiesto**: cada pieza de motor marcada `clase: mecanica`. **Smoke `tools/probar-instalador.ps1`: 32/32** (siembra + sello + tres vías + aviso + `.local` + canal). SGI queda como primer consumidor del lazo.

## [0.10.1-beta] — 2026-07-11

### Vitrina — el README, aterrizado (PR #12)
- **README reescrito con lectores en frío como evidencia** (7 lentes: técnico escéptico, vibe-coder ×2, cliente no-técnico, fact-checker hostil, dev Mac/Linux, experta DX — corridas en `qa_runs/lector-en-frio-readme-20260711/`): los dolores del usuario antes de la marca (*¿Te suena?*, 5 viñetas), *Qué hace por ti* en positivo con glosario de una línea, requisitos explícitos (Claude Code; Windows/PS 5.1 hoy + qué sirve ya en Mac/Linux), techo de gasto por suscripción (verificado contra fuentes), aviación comprimida a Airbus/Boeing, *Empezar* como router por lector.
- **El GIF del gate mordiendo** (`docs/assets/gate-bloqueando.gif`): render fiel de una **corrida real** en SimGhostInputs — el agente toca la UI sin la guía de usuario → `[BLOQUEA] PUSH DETENIDO` → actualiza la guía → pasa. Evidencia cruda y generador en `qa_runs/gif-gate-20260711/`.
- **SimGhostInputs, público, se nombra y linkea** como evidencia del linaje (README + `docs/casos-de-exito.md`, retitulado *De dónde viene*) — avanza la grieta 4 de la auditoría externa.
- **El quickstart ahora bloquea de verdad** (hallazgo del fact-check, reproducido): el snippet anterior no commiteaba y el verificador no ve archivos sin commit — imprimía `Todo limpio`. El paso 3 curado se probó en clon (`[BLOQUEA]`, exit 1, limpieza incluida).
- **Doc-drift interno curado**: versión real (`v0.10.0-beta` vs el `v0.9.0` anunciado), tabla de sprints con versiones correctas + fila de homologación, índice de `docs/sprints/` descongelado (+4 filas y el hueco de planes sin archivar, confesado), `kanban/README` y `empezar-de-cero.md` al día, ROADMAP con grietas 1–3 en su estado real. El README ya no afirma que el instalador "pregunta" el arquetipo (es parámetro; el interactivo quedó en Fase 3.C). `andon/README` documenta el nombre real del required check.
- **Panorama al backlog**: OpenWiki (LangChain — complemento, no competidor) y GBrain (Garry Tan — "pregúntale al proyecto" para no-técnicos), con fuentes.

## [0.10.0-beta] — 2026-07-11

### Homologación · Etapa 2 — Cosecha de SGI (ADR 0011)
- **Auditoría "full join" contra un repo hijo real (SGI):** la maquinaria descendió byte-idéntica (hooks, `settings.json`, comandos, esquema de la ley); el hijo, en cambio, **corrigió y maduró** dos cosas que ascienden al método.
- **Token neutral en la ley:** `tools/blast-radius.json` baja `"rol": "Escribano"` → `"escribano"` (minúscula) en las 8 áreas, para **cumplir la propia regla** de `kanban/roles.md` (la ley usa el token genérico). Cosmético-seguro: ningún gate ramifica sobre ese literal — el único que ramifica busca `revisor-visual`; el resto solo lo interpola en el mensaje.
- **Tres maduraciones al casting neutral** (regla 2–3, cosechadas del hijo): `arquitecto-doc` gana "criterios Gherkin derivados de tests reales; si no hay test, se declara"; `escribano` gana "propone, no commitea; el humano aprueba" (alinea con "nada irreversible sin checkpoint"); `revisor-visual` gana la nota de regresión de snapshot en CI para lo medible (lo subjetivo sigue siendo checkpoint humano).
- Confirmado que **no hay lección de método del hijo que Jidoka desconozca**; los huecos restantes son de arquetipo *code-first* (barreras de stack, gate UX 3-capas, SSOT de versión), ya en el ROADMAP 3.C.

## [0.9.0-beta] — 2026-07-10

### Homologación · Etapa 1 — Jidoka como superset del método (ADR 0010)
- **Rumbo a una sola metodología** (no versiones paralelas entre Jidoka, SGI y TF). El diagnóstico de delta mostró que en el motor Jidoka ya es la versión más nueva; solo faltaban tres piezas de método para ser el superset y que los labs puedan adoptarlo sin regresión. Esta etapa las sube.
- **El asiento `devops`** al roster (`kanban/roles.md`): agente de plataforma/máquina (VMs, SSH, CI, deploys, secretos, `hooksPath`, branch protection), **no skill del repo** — como el orquestador y el desarrollador. Tres asientos no-skill ahora.
- **El modo desatendido, generalizado** (`kanban/desatendido.md` + comando **`/jidoka:desatendido`** + plantilla): las dos lanes `[agente]`/`[humano]`, prioridad declarada, click-it-down y las reglas duras (nada irreversible sin el humano; el agente **no edita sus propios gates**) — para cualquier trabajo autónomo, no solo auditar.
- **El modelo de casting neutral+persona** (`roles.md` → *Personalizar el casting*): la maquinaria usa roles neutrales siempre (ahí vive la única metodología); el nombre propio es una capa cosmética por repo. Dos repos con castings distintos corren el mismo método — cero paralelo, cero alias en runtime.
- Reconciliación de doctrina (anti-sobreingeniería): `devops` y `desarrollador` se documentan como **asientos, no skills** (respeta `asiento ≠ skill`); nada de maquinaria especulativa.

## [0.8.0-beta] — 2026-07-10

### Sprint 3 · Fase 3.B — Los arquetipos ejecutables + los templates de producto (ADR 0009)
- **El instalador pregunta el arquetipo y siembra distinto.** La matriz pieza×arquetipo deja de ser prosa (como en el ancestro) y vive como **manifiesto ejecutable** (`kit/.jidoka/instalar/manifiesto.json`) — el mayor valor de Jidoka sobre el starter.
- **Dos arquetipos** (poda consciente, decisión delegada-revisable — regla 2–3 contra el method-ficción): **`docs-as-code`** (grafo de notas) + **`code-first`** (`PRODUCT_BRIEF` en vez del grafo). `doc-only` **diferido** al ROADMAP hasta que un repo regulado real lo pida.
- **Los 12 templates de producto** portados del starter como librería *menú, no molde* (`kit/.jidoka/templates/producto/`: capacidad, módulo, dominio, ecosistema, solución, componente, spec técnica, modelo-de-datos, requerimiento, proceso, glosario, propuesta-gate-proceso) + **`PRODUCT_BRIEF`** con sección *Landscape* + el HANDOFF sembrado gana la columna **Validación**.
- Smoke del instalador a **12 casos** (los 2 arquetipos instalan, siembran distinto, y su gate sembrado pasa).

## [0.7.0-beta] — 2026-07-10

### Sprint 3 · Fase 3.A — El instalador mínimo que corre (ADR 0008)
- **Jidoka ya se puede instalar en otro repo.** `tools/instalar.ps1` (PowerShell, Windows-first) siembra el método —ritual + motor Andon— en un repo destino. Meta: el primer paso verificable hacia la 1.0 (*corre en un repo ajeno*, probable en las VMs del autor).
- **Sin duplicar la ley**: el instalador **lee el motor genérico del árbol de Jidoka** (`verificar.ps1`/`auditar.ps1` ya son data-driven) y solo cambia la ley por una **plantilla de arquetipo**. Un arquetipo en el MVP: **`docs-as-code`** (`kit/.jidoka/leyes/blast-radius.docs-as-code.json` + `kit/.jidoka/instalar/manifiesto.json`).
- **Regla dura NO CLOBBER**: nunca sobrescribe un archivo existente en el destino. Enciende `core.hooksPath`, crea stubs, guía la branch protection.
- **Smoke `tools/probar-instalador.ps1`** (9 casos): instala en un repo temporal, commitea, y corre los self-tests **sembrados** + `verificar` ahí — un instalador que siembra un motor roto se caza en su prueba de vida.
- La ley gana el área **`kit`**. `probar-gate.ps1` se hace **agnóstico al arquetipo** (se siembra y pasa en el repo instalado).
- Lo diferido (otros 2 arquetipos + matriz ejecutable, 12 templates de producto, multiplataforma, CLI npm + SSOT de versión + release-CI, barreras code-first, dogfood completo del ADR 0003) queda registrado en `ROADMAP.md` → Sprint 3, fases 3.B/3.C.

## [0.6.0-beta] — 2026-07-10

### Sprint 2 · Fase B — Los muros, cosechados de los casos de éxito (ADR 0007)
- **Jidoka alcanza a sus labs.** El descubrimiento de la sesión: los dos casos de éxito vivos ya tenían los muros probados en producción; se homologan hacia arriba (labs → Jidoka, ADR 0005), genéricos y anonimizados (frontera NDA: cero nombres propios ni términos del trabajo).
- **`review-stop`**: código sin `/code-review` frena el cierre. "Código" se lee de la ley (áreas con `revisa: true`), no hardcodeado. Marcador humano `.claude/.review-marker` (no auto-firma: el hook verifica el SHA del diff real).
- **`gemba-stop`**: cambio visual sin evidencia fresca en `qa_runs/` (mtime posterior) frena. Se auto-configura desde `rol: revisor-visual`; **dormido** en Jidoka (sin UI). Marcador `.claude/.gemba-marker`.
- **Auditor del grafo** (`tools/auditar.ps1`): frontmatter + wikilinks + Gherkin de capacidades `vigente` + huérfanas, modulado por estado. Corre en CI (`-Range base...HEAD -Bloquea`).
- **Dimensión `product_avisa`** en la ley (sincronía del grafo de `product/`) en los dos motores; **flag `revisa`** por área.
- **Grieta 1 cerrada**: los avisos suben al **summary del PR** (antes invisibles en un check verde).
- **Prueba de vida nueva**: `tools/probar-hooks.ps1` y `tools/probar-auditor.ps1` (los labs no tenían harness de hooks — invención de Jidoka), con casos que DEBEN bloquear.
- **Grafo `product/` sembrado**: dominio Método → módulos → capacidades RIT-1 (el ritual) y AND-1 (el muro), para que el auditor muerda (dogfooding).

## [0.5.0-beta] — 2026-07-10

### Sprint 2 · Fase A — El ritual Kanban ejecutable
- **El ritual deja de ser prosa y se vuelve máquina.** Cinco comandos en `.claude/commands/jidoka/`: **`/jidoka:arranca`** (abre leyendo el estado real — HANDOFF + `product/recursos-del-proyecto.md` + plan-de-trabajo + git — y fija las reglas duras de sesión), **`/jidoka:planea`** (la rebanada **R0 con STOP**: el QUÉ con criterios aprobado por el cliente antes de la primera línea de código), **`/jidoka:gemba`** (el demo desde el producto real, evidencia a `qa_runs/`), **`/jidoka:cierra`** (registra por caducidad, poda, `git add -f` de la evidencia, ritual de release) y **`/jidoka:que-sigue`** (propone en orden de valor, separando lo que decide la IA de lo que firma el cliente).
- **Las cuatro skills-asiento** (`.claude/skills/`): `escribano`, `validador`, `revisor-visual` y `arquitecto-doc` (opcional, doc-heavy). Cada `SKILL.md` lleva sus límites ("lo que NO hace") de `kanban/roles.md`, la sección **Entorno de 5 líneas embebida** (porque los subagentes no leen la config global) y la declaración de que **no son `subagent_type`**.
- **La ley crece a 7 áreas** con `ritual` (`.claude/commands/*` y `.claude/skills/*` avisan CHANGELOG — el output del sprint queda bajo el propio Andon, dogfooding). El self-test sube a **7 casos**.
- **Zanjada la contradicción del plan efímero** (deuda del ADR 0005): **ADR 0006** — el plan-de-trabajo vive en `/.jidoka/plan-actual.md`, fuera de git pero persistente (sobrevive la compactación); patrón `.gitignore` anclado `/.jidoka/` para no ignorar el kit.
- Los muros deterministas (gemba-stop, review-stop, auditor del grafo, grietas de auditoría) quedan para la **Fase B** (`v0.6.0-beta`).

## [0.4.0-beta] — 2026-07-10

### Auditoría externa + vitrina pública
- **Primera auditoría de terceros del repo** (evidencia: corrió el self-test 6/6 y comparó contra el panorama 2026 — Spec Kit, BMAD, Agent OS). Veredicto citable: el diferenciador real de Jidoka es el muro server-side; ninguno de los frameworks grandes tiene uno. Las **5 grietas** encontradas quedaron registradas con destino en `ROADMAP.md` → *Grietas de la auditoría externa* (avisos invisibles en CI verde; `no-memorias` no es muro por la propia ley; co-ocurrencia gameable; el linaje privado es palabra; 11 de 12 disparos sin cablear).
- **Ko-fi cableado en tres puntos**: `.github/FUNDING.yml` (botón *Sponsor*), badge en el README e invitación al café en la línea de la licencia.
- **Template de PR** (`.github/PULL_REQUEST_TEMPLATE.md`): el punto de inyección de disparos en PRs que `andon/README.md` prometía — evidencia-no-palabra, ADR→índice, `no-verify-es-teatro`. Corto a propósito (anti click-para-pasar).
- **Templates de issues**: `reporte.md` (para no-programadores, pide evidencia) y `leccion.md` (la homologación abierta al público, con regla 2–3 y `frontera-nda` embebidas).
- **ROADMAP** gana dos secciones con receta completa: *Vitrina pública* (GIF del gate mordiendo con guion de una toma, social preview, CODE_OF_CONDUCT, y las dos decisiones abiertas del cliente: párrafo en inglés y ADR de la licencia) y *Grietas de la auditoría*. **HANDOFF** podado a puntero (lo atendido se borró; el detalle vive en el ROADMAP).

### El exprimido final del linaje (ADR 0005)
- **Jidoka es la fuente de verdad definitiva del método.** Última cosecha de los 4 repos del linaje (letra por letra, con agentes de extracción); los 2 repos de **método** se archivan con lápida; los 2 **casos de éxito** siguen vivos — no es una migración, se construye una metodología.
- `kanban/` crece de 4 a 7 docs: **`homologacion.md`** (el protocolo de 5 pasos + regla 2–3 de maduración), **`verificacion.md`** (dos capas, entrada hostil, e2e por clave, cerrar por medición) y **`estados.md`** (`vigente` ≠ construido, gate modulado por estado, gobernanza documental).
- **`docs/casos-de-exito.md`**: los dos casos de campo con números (32 versiones / 34 ADRs / 453 tests; 6 sprints del ritual con cliente que no lee código), anonimizados.
- **`docs/guias/entorno-windows-powershell51.md`**: el recetario de trampas pagadas (commits con acentos vía `-F` sin BOM, ASCII en scripts de barrera, "los subagentes no leen la config global").
- Ampliaciones: paso 0 y poda en `lazo.md`; grafo en disco + TBL/TEC + mapa a marcos en `jerarquia.md`; reglas duras nuevas en `roles.md` (diseño del tope; una sola escritora por working tree); familia de drift + GO condicionado + **corrida nocturna desatendida** en `auditoria.md`; cuatro reglas de campo en `andon/`; estados de ADR ampliados y "Qué NO resuelve" en el template; ritual de release en `CONTRIBUTING.md`.
- Limpieza: referencias colgantes a `../fuentes/` en la doctrina reescritas; el índice del corpus interno (7 frentes) registrado en `doctrina/decisiones/README.md`.

## [0.3.0-beta] — 2026-07-10

### Sprint 1.5 — Vitrina en español + centralización del conocimiento (ADR 0004)
- **Todo en español, a propósito** — decisión de identidad, declarada en el README. Badges, topics, wiki apagada, release `v0.1.0-beta` publicado; el claim del hero ahora es verificable ("este repo se gobierna con su propio Andon").
- **El andamio documentado:** `kanban/lazo.md` (Intención→Construcción→Verificación→Registro), `kanban/jerarquia.md` (QUÉ/CÓMO, 5 niveles, capacidad con Gherkin), `kanban/roles.md` (asiento ≠ skill, model-routing, reglas duras con incidentes) y `kanban/auditoria.md` (el ritual de auditoría en rama).
- **Los porqués de la doctrina:** sus 4 ADRs heredados a `doctrina/decisiones/` (destaca 0002: no API propia como gobierno; 0003: disparos, no lectura).
- **Templates probados al kit** (`kit/.jidoka/templates/`: sprint-plan, sprint-entrega, plan-de-trabajo efímero, adr) y la convención **`qa_runs/`** de evidencia Gemba (artefactos, no actas; `git add -f` de lo citado).
- **Hardening del laboratorio de campo:** ALTO-04 en `andon-stop` (git roto → aviso, no silencio), área `raiz` en la ley (6 áreas), mensajes que enseñan cuándo NO aplican.
- `CONTRIBUTING.md` (flujo + tabla SSOT), `docs/sprints/README.md` (índice-récord), plantilla de ADR con "El camino que NO se toma".

## [0.2.0-beta] — 2026-07-10

### Sprint 1 (cierre) — Auditoría del motor (ADR 0003)
- **El verificador falla cerrado:** si git no puede calcular el rango (base inexistente, historia incompleta), exit 2 con `[ERROR]` — antes aprobaba a ciegas. Self-test ampliado a 6 casos.
- **El juez viaja en la base:** el check `andon` de CI ejecuta la ley y el verificador de la rama base — un PR ya no puede editar la ley que lo juzga.
- **`jidoka-method`:** el paquete anunciado deja de ser `jidoka` (nombre ocupado en npm por un tercero desde 2017).
- Rama default renombrada a `main`; `.gitattributes` gobierna line endings (hooks LF, ps1 CRLF); `andon-stop` entrega su mensaje completo en `reason`; `ROADMAP.md` con los sprints 2–4; `andon/README.md` gana "Fronteras del muro" y el encendido completo de branch protection; README con tabla "Dónde va la beta" (evidencia, no palabra).
- Exactitud: los disparos son **12**, no 13 (nunca se contaron contra el artefacto); rutas del disparo `anti-memoria` actualizadas.

### Sprint 1 — El motor Andon (dogfooding)
- Motor de gate en `tools/`: `blast-radius.json` (la ley), `verificar.ps1` (avisa/bloquea) y `probar-gate.ps1` (self-test con caso que DEBE bloquear).
- Hooks locales en `.claude/`: `no-memorias-pretooluse` (deny a memorias, todo al repo) y `andon-stop` (frena el cierre ante doc-drift), cableados en `settings.json`.
- Muro server-side: workflow `andon` (CI en `windows-latest`) + `.githooks/pre-push` (UX local, saltable).
- **La ley con un bloqueo real:** un ADR nuevo debe listarse en `docs/decisions/README.md` o el push se detiene (único `doc_bloquea`; el resto avisa — doctrina anti-fatiga). Ver ADR 0002.
- `andon/README.md` deja de ser solo doctrina: mapea el motor concreto y cómo encenderlo (hooks + required check).

## [0.1.0-beta] — 2026-07-10

### Sprint 0 — Esqueleto + identidad
- Repo público con historial limpio (ADR 0001).
- README con el pitch (Sistema de Producción Toyota para IA), el linaje de aviación destacado (AF447, Airbus/Boeing → deny/ask, Bainbridge) y los diferenciadores propios.
- **Licencia MIT** — permisiva, para máxima adopción.
- Doctrina embebida (`doctrina/`, 9 documentos, self-contained) desde el linaje poka-yoke.
- Índices del sistema TPS: `kanban/` (ritual de sprint), `andon/` (gates deterministas).
- Los 12 disparos sembrados en `kit/.jidoka/disparos/`. *(Esta línea decía "13"; el conteo real contra el artefacto es 12 — corregido en el cierre del Sprint 1.)*
