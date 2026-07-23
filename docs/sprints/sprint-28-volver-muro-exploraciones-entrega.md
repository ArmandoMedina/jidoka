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

> **Estado del Gemba:** pendiente de la corrida del cliente. Los agentes NO marcan esta sección como cumplida; queda como checkbox en «Pendiente que dejó».

## Pendiente que dejó

- [ ] Gemba del cliente del sprint 28: correr el demo sin terminal (✔/✘ del PR sobre el commit-trampa + los `LOG.md` A/B de R3/R4/R5/R8) y registrar la aceptación en `flujo.json`.
- [ ] Merge del PR de `v1.34.0` con orden nombrada del cliente + tag+release.
- [ ] La **migración real de carpetas a `jidoka/`** (el reorg grande del contenedor): R8 solo curó el falso-verde.

## Lo aprendido (Kaizen)

1. Un gate nuevo es superficie nueva: el check que cierra un hueco (R2) puede abrir otro (path traversal) — se valida el validador con review adversarial.
2. Falla-cerrada tiene más de un camino: «sin la ley» y «con la ley corrupta» son dos modos distintos; curar uno no cura el otro (R5).
3. No todo síntoma es defecto: R7 se midió antes de curar y resultó ya correcto; el entregable fue el guardián de regresión, no una cura.
4. Volver mecanismo lo que era prosa es lo que hace que «el hueco no vuelva al día siguiente»: la procedencia y el guion duraron un día como regla escrita y ya son gate (R1/R2).
