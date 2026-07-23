# HANDOFF — relevo entre sesiones

> Estado en vuelo y pendientes. **Se llena al cerrar**, **se lee y se limpia al abrir.** Contrato del relevo (FLU-1): **1 sección «Dónde estamos» + máximo 2 históricas + techo de líneas** — lo hace cumplir el check `[contrato-handoff]` de `tools/verificar.ps1` (límites en `tools/flujo.json`). Lo cerrado se archiva ÍNTEGRO en [`docs/handoff-historico.md`](docs/handoff-historico.md), que **no se inyecta al abrir**. Nada de memorias de la IA — todo va aquí.

## En una frase

**Jidoka** — el Sistema de Producción Toyota para agentes de IA: fusión de doctrina + método + ritual de sprint. Estable en `v1.x`. Instalador PowerShell + CLI `npx jidoka-method` construido (pendiente `npm publish`). Se construye por sprints, usando su propio ritual (dogfooding).

## Dónde estamos (2026-07-23 — Sprint 28 «Volver muro las dos exploraciones» · CONSTRUIDO 8/8 · `v1.34.0` · PR pendiente de orden de merge)

**Las dos exploraciones del 2026-07-23 dejaron reglas en prosa y agujeros de falla-abierta; este sprint las vuelve mecanismo y cierra los huecos.** Ocho rebanadas construidas, verificadas y commiteadas (6 commits): el candado de procedencia del ROADMAP ya es gate (R1, opt-in `roadmap.procedencia:true`, ADR 0057) y el guion de revisión obligatorio también (R2, `roadmap.guion_revision:true` — remedió 13 ítems); `review-stop` dejó de dictar su propia llave y su SHA cubre lo sin rastrear (R3); el candado `PreToolUse` falla cerrado ante su crash (R4) y los 4 Stop hooks salen exit 2 sin la ley y con ley corrupta (R5) — ambos en ADR 0058; el apetito acepta minutos (R6); el instalador rechaza la maquinaria anidada (R8, falso-verde curado; la migración de carpetas a `jidoka/` sigue pendiente). R7 se midió y NO era defecto: se blindó con guardianes de regresión (cwd1–cwd3).

**Dos CRÍTICOS atrapados por una revisión de código independiente y curados:** (1) path traversal en el check del guion (R2); (2) los 4 Stop hooks fallando ABIERTO con la ley corrupta (R5). Ambos re-verificados. Suites verdes: probar-flujo 123/0, probar-hooks 68/0, probar-instalador 72/0, probar-gate 18/0, probar-adrs 14/0, conformidad-docs 58/0.

**Cola de decisiones del cliente (ninguna es del agente):**
1. `[PENDIENTE]` **Merge + release de `v1.34.0`** — el PR queda listo, pendiente de la **orden de merge nombrada** del cliente (el tag+release está autorizado; el merge requiere orden cada vez).
2. `[PENDIENTE]` **El Gemba del cliente del sprint 28** — el demo sin terminal (✔/✘ del PR sobre el commit-trampa + los `LOG.md` A/B de R3/R4/R5/R8) queda por correr; el cierre lo registró pendiente.
3. `[PENDIENTE]` **La migración real de carpetas a `jidoka/`** — R8 solo curó el falso-verde; el reorg grande del contenedor sigue en la cola.
4. `[PENDIENTE]` **La sesión a fondo del modelo de asientos** (marcada importantísimo por el dueño): ¿la punta de lanza es agente o skill? ¿tres ejes de nombres o menos?
5. `[PENDIENTE]` **Nombres de personas ya en `main`** desde el 2026-07-10 (`kanban/roles.md:40-48`): reescribir historia para sacarlos, o aceptarlos con un ADR que enmiende el 0055.
6. `[PENDIENTE]` Heredadas y aún abiertas: ¿contenedor antes o después del batch que **vence 2026-08-04**? · elegir boceto del tablero Operar (A/B/C) para reanudar el Sprint 27 pausado.

## Dónde estuvimos (2026-07-23 — exploración: procedencia del backlog + el enredo de asientos · SIN sprint · `v1.33.0` · PR #130)

**El backlog se reinició de 62 a 41 ítems por una regla nueva: todo pendiente cita de dónde viene** (informe/ADR/issue). Medido: 41 de 62 no citaban nada y git no lo suplía (el reformateo de FLU-1 aplanó la historia). 32 huérfanos a [`docs/MUERTOS.md`](docs/MUERTOS.md); 9 rescatados con puntero verificado. Dos hallazgos con dientes: el hook `PreToolUse` **sí distingue al asiento** que lo invoca (viable el asiento de exploración, rojo→verde), y **el modelo de asientos está enredado** (tres ejes bajo «asiento», renombre de 120+ sitios) — mapa levantado para la sesión a fondo. Las reglas que aquí eran prosa las volvió gate el sprint 28. Cuatro auditores ciegos revisaron la sesión; sus curas están aplicadas.

## Dónde estuvimos (2026-07-23 — exploración: la huella de Jidoka en un lab · SIN sprint · `v1.32.0` liberada)

**Primera vuelta de la kata (cap. 08) corrida de verdad.** Pregunta: ¿el estorbo de Jidoka en un repo ajeno es colisión estructural o ruido visual? **Respuesta medida: estructural, y aislable sin apagar el muro.** Expediente: [`exploracion-huella-en-labs-202607.md`](docs/analisis/exploracion-huella-en-labs-202607.md). Molde nuevo `kit/.jidoka/templates/exploracion.md` (n=1, fuera del ledger). Hallazgos colaterales: los 4 Stop hooks dejan cerrar sin la ley, y `review-stop` suma tres defectos medidos al usarlo — ambos curados por el sprint 28.

## Autorizaciones vigentes del cliente (dichas con nombre)

- **Publicar releases de GitHub** (2026-07-10): «Eres libre y autorizado para publicar versiones» — tag + release del cierre no necesita re-autorización.
- **Merges de PR y cambios de configuración/permisos**: SIGUEN necesitando orden nombrada cada vez («no me muevas configuración», dicho explícito).
