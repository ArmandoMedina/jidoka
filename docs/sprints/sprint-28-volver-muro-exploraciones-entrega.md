# Sprint 28 — Volver muro las dos exploraciones · Entrega

> El récord del sprint. Se llena al cerrar; las lecciones viajan al siguiente `planea`, el contexto no.

## Objetivo

Volver mecanismo las reglas que las dos exploraciones del 2026-07-23 dejaron en prosa (procedencia + guion de revisión del ROADMAP) y curar los defectos de falla-abierta medidos en vivo en los propios gates, sin abrir superficie nueva.

## Decisiones

- Plan aprobado en plan mode (2026-07-23); apetito 10 h de atención del dueño. Récord-contrato: [`sprint-28-volver-muro-exploraciones-plan.md`](sprint-28-volver-muro-exploraciones-plan.md).
- **R5 = defecto** (no diseño): los 4 Stop hooks se curan a falla-cerrada (exit 2), consistente con el Gherkin vigente de AND-1.
- **R8 = solo la cura de seguridad** (matar el falso-verde de la forma anidada; instalador falla cerrado). La migración real de carpetas `→ jidoka/` queda FUERA.
- **R7 = no-defecto**: los 3 scripts ya resolvían contra `-Repo`; cierra con guardianes de regresión en vez de cura.
- La extensión del contrato del ROADMAP (procedencia + guion) se asienta en **ADR 0057** (extiende el 0049); la falla-cerrada de los hooks en **ADR 0058**.
- Versión de salida **`v1.34.0`** (MINOR — agrega capacidades). El tag+release está autorizado; el **merge de PR requiere orden nombrada** del cliente.

## Qué se entregó

Las 8 rebanadas, contra el alcance del plan:

- **R1 — Candado de procedencia del ROADMAP** `[LEY]` `[ADR]` — DONE. `verificar.ps1` (`[contrato-roadmap]`) exige a cada ítem vivo un puntero a informe/ADR/issue; opt-in `roadmap.procedencia:true`. Ítem sin origen → exit 1. ADR 0057.
- **R2 — Cada ítem declara cómo se revisa** `[LEY]` — DONE. Segundo requisito: el puntero alcanza una sección «Qué debe revisar el dueño» en su informe (`roadmap.guion_revision:true`; el icebox exento). Remedió 13 ítems (4 informes ganaron sección de guion, 3 ítems re-apuntados). ADR 0057 (enmienda).
- **R3 — `review-stop` no entrega su llave** — DONE. El mensaje de bloqueo ya no dicta el comando de auto-firma, y su SHA cubre también los archivos sin rastrear.
- **R4 — Un hook que truena falla CERRADO** — DONE. El candado `PreToolUse` falla cerrado ante su propio crash (envoltorio + `.core` en proceso hijo). ADR 0058.
- **R5 — Los 4 Stop hooks fallan CERRADO sin la ley** — DONE. `andon`/`review`/`gemba`/`validador-stop` salen exit 2 sin la ley **y con ley corrupta** (hallazgo de code-review). ADR 0058.
- **R6 — El apetito expresa < 1h** — DONE. El check acepta `Nh` o `Nm` (minutos) y `estado-flujo` los suma correcto (`apetito:30m` → 0.5h).
- **R7 — Los 3 scripts resuelven contra la raíz** — NO era defecto: los 3 scripts (`estado-flujo`/`expirar`/`auditar`) ya resuelven sus JSON contra `-Repo`; se agregaron guardianes de regresión (cwd1–cwd3). Cierra como no-defecto.
- **R8 — Contenedor `jidoka/` no da falso-verde** — DONE (solo la cura de seguridad). El instalador (`-Sellar`) falla cerrado ante la maquinaria anidada mal resuelta (falso-verde curado). La **migración real de carpetas a `jidoka/` NO se hizo** (fuera de alcance) — sigue pendiente.

## Evidencia (review)

Una revisión de código independiente encontró **2 CRÍTICOS** —path traversal en el check del guion (R2) y los 4 Stop hooks fallando ABIERTO con la ley corrupta (R5)—, ambos curados y re-verificados. Suites verdes al cierre (verificadas): **probar-flujo 123/0 · probar-hooks 68/0 · probar-instalador 72/0 · probar-gate 18/0 · probar-adrs 14/0 · conformidad-docs 58/0**. Los 3 contratos de flujo (handoff/roadmap/changelog) verdes en `verificar.ps1`; `estado-docs.ps1` 0 desviado.

## Hallazgos de la data real

- La revisión adversarial atrapó que un gate nuevo puede introducir su propio agujero: el check del guion (R2), pensado para cerrar un hueco, abría un path traversal — un muro que valida rutas también las resuelve.
- Curar los Stop hooks a falla-cerrada sin la ley (R5) no bastaba: la **ley corrupta** era un segundo camino de falla-abierta que el diseño original no cubría.
- R7 recuerda que no todo lo que «parece defecto» lo es: los 3 scripts ya estaban bien; el valor fue el guardián de regresión, no una cura inexistente.

## Verificación (el demo que corre el cliente) — `owner: cliente`

**Cómo lo corre (sin código ni terminal):**

- **R1 + R2 + R6 (en GitHub, sin terminal):** abres el PR del sprint en github.com. En un commit-trampa (que dejo señalado en la descripción del PR) verás el check **`andon` en ROJO** sobre un ítem del ROADMAP sin puntero / sin guion / y el `apetito:30m` aceptado en verde. Miras la ✔/✘ de la página del PR — no corres nada.
- **R7 (en GitHub, sin terminal):** el mismo PR trae un test nuevo `probar-*` rojo→verde; lo ves como un **check verde** en la lista de checks del PR.
- **R3, R4, R5, R8 (evidencia A/B en `qa_runs/`, sin terminal):** para cada uno dejo en `qa_runs/volver-muro-<slug>/LOG.md` la corrida **antes/después**: el mensaje de bloqueo de `review-stop` sin el comando de firma (R3), el hook con `SyntaxError` bloqueando (R4), un Stop hook fallando cerrado sin la ley (R5), el instalador rechazando el anidado (R8). Abres ese `LOG.md` en el navegador (GitHub lo renderiza) y lees el contraste — no ejecutas los scripts tú.

> **Regla del demo tangible:** R1/R2/R6/R7 se ven sin terminal en la página del PR. R3/R4/R5/R8 son muro interno: su demo es *ver el gate bloquear un intento real*, y la evidencia durable es el `LOG.md` A/B rastreado por git — el formato que el brief acepta para trabajo de muro (los Gherkin de AND-1 son exactamente eso). Ninguna rebanada se cierra con «corre este script»: se cierra con la ✔/✘ del PR o el `LOG.md`.

> **Estado del Gemba:** ✔ **ACEPTADO por el dueño (2026-07-23).** El dueño revisó la evidencia (5/5 muros muerden, `qa_runs/gemba-volver-muro-20260723/LOG.md`) y autorizó «gemba» por nombre en `/jidoka:cierra`.

## Pendiente que dejó

- [x] Gemba del cliente del sprint 28: **ACEPTADO (2026-07-23)** — el dueño revisó la evidencia (5/5 muros muerden, `qa_runs/gemba-volver-muro-20260723/LOG.md`) y autorizó «gemba» por nombre. Registrado en `flujo.json`.
- [ ] Merge del PR de `v1.34.0` con orden nombrada del cliente + tag+release.
- [ ] La **migración real de carpetas a `jidoka/`** (el reorg grande del contenedor): R8 solo curó el falso-verde.

## Lo aprendido (Kaizen)

1. Un gate nuevo es superficie nueva: el check que cierra un hueco (R2) puede abrir otro (path traversal) — se valida el validador con review adversarial.
2. Falla-cerrada tiene más de un camino: «sin la ley» y «con la ley corrupta» son dos modos distintos; curar uno no cura el otro (R5).
3. No todo síntoma es defecto: R7 se midió antes de curar y resultó ya correcto; el entregable fue el guardián de regresión, no una cura.
4. Volver mecanismo lo que era prosa es lo que hace que «el hueco no vuelva al día siguiente»: la procedencia y el guion duraron un día como regla escrita y ya son gate (R1/R2).

## Cuadro de cierre — sesión de deuda y /code-review (2026-07-23)

> Esta sesión NO es una rebanada nueva: el sprint 28 se construyó y cerró antes. Aquí se cerró su **deuda** (Gemba + merge + release) y los **4 fixes del `/code-review` del dueño**.

### Hechos (números, nombres, sí/no)

| Campo | Valor |
| --- | --- |
| Sprint | 28 «Volver muro las dos exploraciones» — cierre de deuda **TERMINADO** (sprint ya cerrado antes; esta sesión cerró su deuda) |
| Rebanadas | 8 planeadas / 8 entregadas / 0 desviadas (R1–R8). Esta sesión: cierre de deuda (no rebanada nueva) + 4 fixes del `/code-review` |
| Rama | `sprint/volver-muro-exploraciones-20260723` · 9 commits |
| Commit de esta sesión | `2c83f67` — `fix(muro): cierra la deuda del sprint 28 y los hallazgos del /code-review` |
| Working tree al cerrar | limpio |
| Duración | sesión del 2026-07-23 |
| PR | se abre y mergea a `main` en este cierre · rama a borrar tras merge |
| Release | **v1.34.0** (MINOR) |
| Ritual corrido | arranca · planea · gemba · cierra |
| Delegaciones | explorador (barridos/atlas/guiones), mecánico (edits de docs), auditor (verificaciones + paneles adversariales), arquitecto (diseño de la cura de bypasses), general-purpose (aplicar+verificar con TDD). Hilo principal: orquestación + una edición menor del LOG del Gemba (metadata), marcada como excepción |
| Aprobaciones del dueño | «Adelante» (composición, R0, plan del sprint — sesiones previas). Esta sesión: aprobó la secuencia de correcciones, pidió imprimir el SHA, **firmó el marcador él mismo**, y autorizó por nombre en `/jidoka:cierra`: «gemba, pr, release, merge, poda» |
| Pruebas automáticas | probar-flujo 123→140 (**+17** casos), probar-hooks 68→87 (**+19** casos), 0 bajas / 0 debilitadas |
| Suites al cierre | probar-flujo **140/140**, probar-hooks **87/87**, `verificar -Base main` **verde**. E2E (Playwright): no aplica (trabajo de motor PS) |
| Evidencia qa_runs (commiteada `-f`) | `gemba-volver-muro-20260723/LOG.md` (Gemba 5/5 muros muerden), `volver-muro-barreras-20260723/LOG.md` (A/B hooks), `volver-muro-instalador-20260723/LOG.md` (R8) |
| Gates | `verificar` verde (1 aviso atlas no bloqueante, juzgado no-flujo por un explorador), probar-flujo/hooks verdes, estado-docs verde |
| Compactación | sí, la sesión se compactó; se re-verificó contra los artefactos al retomar (evidencia-no-palabra en todo) |
| ADRs | **0057** (creado + enmendado: R1 valida existencia; junction confesado) y **0058** (creado + enmendado: ley `{}`/corrupta fail-closed; candado deniega marcador; residuo Bash confesado) |
| CHANGELOG | al día, `[1.34.0]`, MINOR |
| Hallazgos | panel adversarial (H1–H5: traversal y alias del candado, junction, excepción `GetFullPath`; curados o confesados) + `/code-review` del dueño (5: **4 curados** — #1 guion-existencia, #2 hash-incidental, #3 quotepath, #4 vista-regex; **1 confesado** — #5 sobre-bloqueo). No se abrieron issues de GitHub |
| Pendientes al HANDOFF | idea de exploración «cuándo es suficiente la revisión» |

### Fricción / Kaizen crudo

- **Correcciones del dueño al agente:** «no te veo usando subagentes» (delegar más), «asumes que domino todo» (hizo falta un resumen a altura de dueño), «solo me explicaste 1» (explicar TODOS los mecanismos, no uno).
- **Errores del agente reparados:** el guard `{}` fail-open no atrapaba el objeto vacío (cazado por auditoría); los 4 huecos del `/code-review`; el candado bloqueó mi propio commit por mencionar el marcador en el mensaje (H3 en vivo) — se rodeó con `git commit -F`.

### Kaizen

1. Un muro nuevo hay que auditarlo en **todas** sus ramas hermanas: curar una y olvidar la hermana (quotepath, guard `{}`, contratos) fue patrón recurrente en esta sesión.
2. El `/code-review` del dueño cazó lo que el panel adversarial del agente NO vio: revisores independientes que se contradicen **son** la seguridad, no un fallo del proceso.
3. Confesar el límite > fingir la garantía: se caminó para atrás de «no puede en absoluto» a «defensa en profundidad» — evidencia-no-palabra también aplica a las promesas que escriben los docs.
4. La cota de apetito (R6) es justo lo que arreglaba el sobreestimado que el dueño notó (14 h estimadas vs. ~1 h real): el contrato forzaba horas enteras e inflaba el número.

### Gemba — ACEPTADO por el dueño

✔ El dueño revisó la evidencia (**5/5 muros muerden**, `qa_runs/gemba-volver-muro-20260723/LOG.md`) y autorizó «gemba» por nombre el **2026-07-23**. La sección «Verificación (el demo que corre el cliente)» y su checkbox en «Pendiente que dejó» quedan marcados como cumplidos citando esa evidencia.
