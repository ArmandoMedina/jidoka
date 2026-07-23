# Sprint 28 — Volver muro las dos exploraciones

> Plan aprobado en plan mode el 2026-07-23. **Este plan ES el sprint**: lo que no está aquí, no entra (se anota abajo en "Lo que NO entra").

## Contexto (por qué)

Las dos exploraciones del 2026-07-23 (`huella-en-labs` y `procedencia-del-backlog` / `allowlist-por-asiento`) dejaron dos clases de deuda medida: **reglas nuevas que quedaron en prosa** (la procedencia y el guion de revisión del ROADMAP se aplicaron a mano y «el hueco volvió al día siguiente») y **defectos de falla-abierta en los propios gates**, verificados en vivo (`review-stop` se auto-firmó, un hook con `SyntaxError` dejó pasar la escritura, los 4 Stop hooks cierran sin la ley, tres scripts resuelven rutas contra el CWD, el contrato del apetito no expresa < 1h, el contenedor anidado da falso-verde). Este sprint las vuelve mecanismo y cura los agujeros — sin abrir superficie nueva.

## Encuadre de producto (validado con el cliente)

Endurece dos capacidades vigentes, ninguna nueva:

- **[[AND-1-muro-andon]]** — el muro hoy tiene huecos medidos: un gate que pasa en silencio contradice la tesis del brief (*«muro real solo si el punto de control vive FUERA del LLM»*). R1–R5 los cierran.
- **[[FLU-1-pilar-de-flujo]]** — el contrato del ROADMAP/backlog (ADR 0049) sin gate se vuelve a llenar de pendientes sin origen; el apetito miente sobre la restricción del sistema (la atención del dueño). R1, R2, R6 lo endurecen.

No hay hipótesis abierta: cada rebanada nace de un defecto ya medido, con informe y guion de revisión en `docs/analisis/`.

## Decisiones del cliente

- **2026-07-23** — QUÉ aprobado con nombre: los 8 criterios de aceptación R1–R8 tal como se redactaron en R0 (esta sesión).
- **2026-07-23** — **R5 = defecto** (no diseño): los 4 Stop hooks se curan a falla-cerrada (exit 2), consistente con el Gherkin vigente de AND-1.
- **2026-07-23** — **R8 = solo la cura de seguridad** (matar el falso-verde de la forma anidada; instalador falla cerrado). La migración real de carpetas `→ jidoka/` queda FUERA.
- **2026-07-23** — Apetito del sprint: **10 h** de atención del dueño.
- Heredada (2026-07-10): publicar tag+release está autorizado; **merge de PR requiere orden nombrada** cada vez.

Decisión gorda → ADR: la extensión del contrato del ROADMAP (procedencia + guion de revisión + apetito sub-hora) se asienta en un ADR que enmienda/extiende el **0049** (cubre R1, R2, R6).

## Alcance (rebanadas verticales)

Ordenadas por dependencia y valor. **[LEY]** = toca `tools/blast-radius.json` o el contrato gobernado (rol escribano, gate andon-stop).

1. **R1 — Candado de procedencia del ROADMAP** `[LEY]` `[ADR]` — `verificar.ps1` exige a cada ítem vivo un puntero a informe/ADR/issue, igual que hoy exige `apetito:`. Verde por sí sola: check nuevo + su prueba en `probar-verificar` + ADR (extiende 0049). *Criterio:* un ítem sin puntero → exit 1.
2. **R2 — Cada ítem declara cómo se revisa** `[LEY]` — extiende R1 con un segundo requisito: el puntero debe alcanzar una sección «Qué debe revisar el dueño» en su informe. Depende de R1 (mismo check). *Criterio:* ítem cuyo puntero no alcanza guion → bloquea.
3. **R6 — El apetito expresa < 1h** `[LEY]` — el check `apetito:\d+h` (`verificar.ps1:300`) pasa a aceptar sub-hora (p. ej. `\d+(h|m)` o fracción decidida en la rebanada) y `estado-flujo` lo suma correcto. Va junto a R1/R2 porque toca el mismo contrato 0049 y el mismo archivo. *Criterio:* `apetito:30m` → aceptado y sumado como 0.5h.
4. **R3 — `review-stop` no entrega su llave** — quitar del mensaje de bloqueo el comando exacto de auto-firma (`review-stop.ps1:80`) y hacer que su SHA cubra también los archivos sin rastrear (hoy `git diff HEAD`, `:65-69`). *Criterio:* al bloquear, el mensaje NO imprime el comando de firma; el hash cambia si cambia un archivo sin rastrear.
5. **R4 — Un hook que truena falla CERRADO** — un `SyntaxError` (o cualquier crash) en un hook `PreToolUse` debe bloquear, no pasar en silencio. Aplica a `candado-pretooluse.ps1` y hermanos. *Criterio:* hook con error de sintaxis + escritura que debía bloquear → se bloquea.
6. **R5 — Los 4 Stop hooks fallan CERRADO sin la ley** — `andon`/`review`/`gemba`/`validador-stop` salen exit 2 («no apruebo a ciegas») si falta `blast-radius.json`, en vez de exit 0. *Criterio:* sin la ley, un Stop hook falla cerrado.
7. **R7 — Los 3 scripts resuelven contra la raíz** — `estado-flujo.ps1:102-105`, `expirar.ps1:79-82`, `auditar.ps1:82` usan el `-Repo` que ya aceptan para hallar sus JSON. Prueba `probar-*` rojo→verde. *Criterio:* corridos desde otra carpeta con `-Repo`, hallan sus archivos.
8. **R8 — Contenedor `jidoka/` no da falso-verde** — el instalador/gate falla cerrado ante la forma anidada mal resuelta, en vez de aprobar sin mirar. Solo la cura de seguridad (sin migración de carpetas). *Criterio:* lab con maquinaria anidada mal → falla cerrado.

## Archivos

- **Contrato/ley (R1, R2, R6):** `tools/verificar.ps1` (checks `[contrato-roadmap]`, `apetito`), `tools/flujo.json` (límites), `ROADMAP.md` (auto-conforme a la regla nueva), `docs/decisions/` (ADR nuevo que extiende 0049 + su índice `README.md`), `tools/probar-verificar.ps1` (o suite equivalente).
- **Barreras (R3, R4, R5):** `andon/review-stop.ps1`, `andon/andon-stop.ps1`, `andon/gemba-stop.ps1`, `andon/validador-stop.ps1`, `tools/candado-pretooluse.ps1`, sus `probar-*` / `qa_runs/` de evidencia A/B.
- **Motor (R7):** `tools/estado-flujo.ps1`, `tools/expirar.ps1`, `tools/auditar.ps1` + su prueba.
- **Instalador (R8):** `tools/instalar.ps1` / `tools/sembrar-manual.ps1` (la ruta de detección de raíz), su `probar-instalador`.
- **Cierre:** `CHANGELOG.md`, `HANDOFF.md`, `docs/sprints/README.md`, `ROADMAP.md` (retirar las 8 tarjetas cumplidas).

> Blast radius real: R1/R2/R6 tocan la **ley** → gate `andon-stop`, rol escribano. R3/R4/R5 tocan **barreras** → gates `review-stop` + `andon-stop`. Se confirma con `tools/rutear.ps1` al construir.

## Verificación (el demo que corre el cliente) — `owner: cliente`

**Cómo lo corre (sin código ni terminal):**

- **R1 + R2 + R6 (en GitHub, sin terminal):** abres el PR del sprint en github.com. En un commit-trampa (que dejo señalado en la descripción del PR) verás el check **`andon` en ROJO** sobre un ítem del ROADMAP sin puntero / sin guion / y el `apetito:30m` aceptado en verde. Miras la ✔/✘ de la página del PR — no corres nada.
- **R7 (en GitHub, sin terminal):** el mismo PR trae un test nuevo `probar-*` rojo→verde; lo ves como un **check verde** en la lista de checks del PR.
- **R3, R4, R5, R8 (evidencia A/B en `qa_runs/`, sin terminal):** para cada uno dejo en `qa_runs/volver-muro-<slug>/LOG.md` la corrida **antes/después**: el mensaje de bloqueo de `review-stop` sin el comando de firma (R3), el hook con `SyntaxError` bloqueando (R4), un Stop hook fallando cerrado sin la ley (R5), el instalador rechazando el anidado (R8). Abres ese `LOG.md` en el navegador (GitHub lo renderiza) y lees el contraste — no ejecutas los scripts tú.

> **Regla del demo tangible:** R1/R2/R6/R7 se ven sin terminal en la página del PR. R3/R4/R5/R8 son muro interno: su demo es *ver el gate bloquear un intento real*, y la evidencia durable es el `LOG.md` A/B rastreado por git — el formato que el brief acepta para trabajo de muro (los Gherkin de AND-1 son exactamente eso). Ninguna rebanada se cierra con «corre este script»: se cierra con la ✔/✘ del PR o el `LOG.md`.

## Lo que NO entra (siguientes)

- **La exploración profunda del modelo de asientos** (agentes vs skills vs casting) — sesión aparte, es juicio no build; marcada importantísimo por el dueño.
- **La allowlist de escritura por asiento** (asiento de exploración + generalización a todos) y **el casting canon** — dependen de la sesión de asientos.
- **La migración real de carpetas a `jidoka/`** — R8 solo cura el falso-verde; el reorg es la épica grande del contenedor.
- **La decisión de nombres de personas en `main`** (`kanban/roles.md`) — decisión del dueño, no build.
- Todo lo `espera:ventana-labs` / `espera:cliente` (batch a labs, épica `.local` SGI, demos de campo, Gemba e2e de la app).
