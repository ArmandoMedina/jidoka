# 0045 — El pilar de flujo: contratos de documentos con gate, límite WIP y visibilidad determinista

- **Estado:** aceptado
- **Fecha:** 2026-07-21
- **Sprint:** El pilar de flujo (`docs/sprints/sprint-pilar-de-flujo-plan.md`)

## Contexto

La Casa del TPS se sostiene sobre **dos** pilares: Jidoka (parar ante el defecto) y JIT/flujo
(que el trabajo avance sin acumularse). El método construyó Jidoka con dientes — gates
deterministas, muros server-side, evidencia-no-palabra — pero **el pilar de flujo no existía**.
Toda la capa de gestión del avance era prosa que dependía de que alguien se acordara.

El diagnóstico, medido y no opinado (`docs/analisis/gemba-gestion-del-flujo-202607.md` sobre
274 MB de transcripciones, y el benchmark de 4 frentes `docs/analisis/benchmark-flujo-202607.md`):

- El **HANDOFF declaraba «se limpia al abrir» en su primera línea** y aun así llegó a 419 líneas
  con 12 secciones históricas — nadie lo limpiaba porque nada lo obligaba.
- El **ROADMAP solo crecía** (70× en un lab), sin expiración: un backlog que solo acumula.
- **Cola de Gembas vencidos** sin aceptar, cero límite de trabajo en curso, cero visibilidad
  determinista del estado (había que preguntarle al agente, que es narrador y parte).

La lección de fondo, dicha por el cliente y confirmada por los 4 frentes del benchmark: **«si
depende de que el modelo coopere, no es muro»**. Kanban en su forma clásica se apoya en presión
social (el tablero que todos ven, el compañero que pregunta) — con agentes esa presión no existe.
La regla del sprint: **todo tiene que ser código que rechaza la acción**.

## Decisión

Se construye el pilar de flujo como **contratos deterministas**, no como disciplina. Cada
documento de estado deja de ser un diario que crece solo y pasa a tener un **contrato con gate**,
con los límites como **dato de instancia** (`tools/flujo.json`) y los checks en el motor:

1. **Contrato del HANDOFF / ROADMAP / CHANGELOG** — el HANDOFF queda con una sección «Dónde
   estamos» + máximo N históricas + techo de líneas (check `[contrato-handoff]` en
   `tools/verificar.ps1`, **BLOQUEA** al excederse; lo archivado vive íntegro en
   `docs/handoff-historico.md`, que `/jidoka:arranca` **nunca** inyecta). El ROADMAP se
   reestructura en **clases de servicio** (no se rankea: se clasifica) con `[clase · fecha ·
   apetito]` por ítem. El CHANGELOG entra al ledger `tools/docs-gobernados.json` (patrón KIT-2)
   con estructura fija por versión — deja de ser «una carta de correo».
2. **Expiración automática** — `tools/expirar.ps1` mueve lo vencido a `docs/MUERTOS.md` **por
   script, no por juicio**, con fecha y motivo; vuelve solo si alguien lo re-propone.
3. **Límite WIP que muerde** — `tools/flujo.json` declara el WIP y los Gembas pendientes de
   aceptación; `/jidoka:planea` gana un preflight `!` que **se planta** si hay un Gemba vencido,
   nombrando cuál — no se abre sprint nuevo con trabajo sin aceptar aguas arriba.
4. **Visibilidad determinista** — `tools/estado-flujo.ps1 -Json` emite el contrato (sprint activo,
   siguientes por clase, bloqueados-por-tercero, gembas pendientes) y el **primer hook
   `SessionStart`** del repo lo inyecta al abrir; un `tools/reporte-avance.ps1` emite un `.html`
   autocontenido (patrón linterna) con hill chart y cinco secciones **sin jerga** (qué cerró, qué
   está en curso, qué espera a la autoridad, qué murió, qué sigue) — legible para un tercero.
5. **Reparto de funciones** — se separan dos roles humanos: **autoridad del dominio** (el que
   sabe; sus horas son la restricción) y **dueño-operador del método** (prioriza, presupuesta,
   corre el ritual), + los asientos-agente con su carta SÍ-le-toca / NO-le-toca y **enfoque
   conductual** real (`product/casting.md`, template sembrable).

Se entrega en **9 rebanadas, M1→M2→M3** por dependencia (documentos que no crecen → trabajo con
límite → avance y roles visibles), cada una commiteable y verde sola. Plan-contrato aprobado en
plan mode el 2026-07-21: `docs/sprints/sprint-pilar-de-flujo-plan.md`. Este ADR registra el
**movimiento 1** entregado (R1, el contrato del HANDOFF) y la dirección del pilar completo.

## El camino que NO se toma

- **Un asiento PM / capataz que persiga el trabajo a mano** — en Toyota ese rol **no existe**: el
  flujo lo gobierna el sistema (Kanban, takt, poka-yoke), no un capataz que anda recordando. Un
  asiento así sería el mismo desmadre con otro nombre, y encima uno que depende de la cooperación
  del modelo. La restricción rechaza la acción; no persigue a nadie.
- **Importar Scrum** (story points, velocity, standups, RACI formal) — el benchmark lo descartó
  **con fuentes** (`benchmark-flujo-202607.md`): la estimación por puntos y la velocity son
  ceremonias de coordinación humana que no miden flujo y que con agentes se vuelven teatro. Se
  toma de Kanban/Lean lo que es mecánico (clases de servicio, WIP, expiración), no las ceremonias.
- **Reglas como prosa / acuerdo** («acordemos limpiar el HANDOFF», «recuerda clasificar») — es
  **exactamente lo que falló**: el HANDOFF pedía por escrito que se limpiara y llegó a 419 líneas.
  Un principio sin mecanismo es una promesa. Cada regla del pilar es un check que bloquea.

## Consecuencias

- El **HANDOFF y el ROADMAP dejan de ser un diario**: se vuelven relevos de tamaño acotado que se
  jalan (lo que la sesión entrante necesita), no que se empujan (el diario de la que sale). Lo
  histórico no se pierde — se archiva íntegro donde el ritual no lo re-inyecta.
- **Muerte por defecto** de los ítems vencidos: el backlog encoge por script, con la razón
  registrada, en vez de crecer para siempre. Lo que revive, revive porque alguien lo re-propone.
- El **apetito se mide en horas de revisión humana** (la restricción real): el sprint que estrenó
  el pilar declaró 6 horas de revisión del cliente con **muerte por defecto** si se consumen sin
  entregar — primer uso del circuit breaker sobre el propio método.
- **Frontera:** este sprint entrega motor + contrato JSON, **cero UI nueva** (la cara la pinta el
  agente del Tauri sobre el contrato `-Json`); enti no se escribe (solo análisis + molde
  sembrable); la coordinación multi-máquina de escritores queda registrada al ROADMAP, no
  resuelta aquí.
- Prueba de vida del movimiento 1: `tools/probar-flujo.ps1` (fixtures ROJO→VERDE del contrato del
  HANDOFF, incl. la regresión del encoding UTF-8 y el falla-cerrado ante `flujo.json` corrupto),
  en el preflight de `publicar.ps1` y en el CI.
