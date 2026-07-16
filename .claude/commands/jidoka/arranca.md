---
description: Abre la sesión con el estado real del proyecto y fija las reglas duras de trabajo (ritual Jidoka)
argument-hint: "[nota opcional de en qué quieres enfocar la sesión]"
allowed-tools: Read, Bash(git status:*), Bash(git log:*), Bash(git branch:*), Bash(test:*), Bash(cat:*), Bash(powershell:*)
---

Estás **abriendo una sesión de trabajo** en este proyecto. Antes de tocar nada, orienta la sesión con el estado real —no con tu memoria ni con un resumen— y fija las reglas del ritual. Este es el `/jidoka:arranca` del método (ver `kanban/lazo.md`, `kanban/roles.md`).

## 1. Lee el estado en vuelo (el relevo)

El estado del proyecto vive en artefactos, no en la memoria de nadie. Lo que sigue no son punteros a criterio tuyo de seguir o no —cada `@` es una **inyección directa**: el contenido ya está en tu contexto al abrir esta sesión, no una lectura que queda pendiente (un puntero es una esperanza; un `@` es un hecho — ADR 0034):

- **Estado en vuelo y pendientes** — se lee y **se limpia** al abrir:
@HANDOFF.md

- **El QUÉ del proyecto** (el brief: caso concreto, métrica, autoridad del dominio, criterio de "hecho"):
@product/PRODUCT_BRIEF.md

- **El CÓMO del proyecto** (infraestructura, identidades, máquinas/ambientes, el roster con nombres si el repo lo declaró):
@product/infra.md

- **Cómo se contribuye aquí** (el flujo, quién es dueño de qué doc, el ritual de versión):
@CONTRIBUTING.md

- **Plan de trabajo del día**, si una sesión anterior lo dejó a medias (efímero, fuera de git — ADR 0006):
!`test -f .jidoka/plan-actual.md && cat .jidoka/plan-actual.md || echo "(no hay plan de trabajo activo — empezamos limpio)"`

- **Dónde está git ahora mismo**:
!`git branch --show-current && git status --short && git log --oneline -5`

## 2. El roster y el router

Antes de construir, ubica dos tablas de la ley — ninguna se deduce sobre la marcha ni depende de tu iniciativa:

- **El roster** es la **tabla de responsables**: quién responde por cada asiento del método — no un asiento que el hilo principal "ocupa". Si el repo declaró un casting con nombres, vive en la sección `## El casting` de su instancia de recursos (`product/recursos-del-proyecto.md` en los hijos; su plantilla viaja en `kit/.jidoka/templates/`). Si no hay casting declarado, usa los roles **neutrales** de `kanban/roles.md` — esta nave nodriza usa los neutrales a propósito (decisión del cliente, 2026-07-14) — y sugiere sembrar uno si el repo lo amerita.
- **El router** (`tools/rutear.ps1`) es el **preview de gates** de esta sesión: según lo que toques, ESTOS gates te van a vigilar al cerrar — no una tabla en la que "te sientas".
!`powershell -NoProfile -File tools/rutear.ps1 || echo "(no hay router: tools/rutear.ps1 no esta sembrado -- actualiza el motor)"`

> **Previsualiza, no resumas.** Esa tabla ES la ley de ruteo de la sesión: si tocas la `fuente` de un área, ESE gate va a medir tu diff al cerrar — mide el artefacto, no si alguien "se sentó" en el rol. Un gate **DORMIDO** no es un permiso — es un área que la ley aún no declara; si tu trabajo la necesita, se declara en la ley (no se improvisa).

## 3. El asiento lo ocupa el subagente

El roster de arriba dice **quién responde**; el asiento con dientes —el que de verdad ejecuta, con un tier de modelo ya fijo— lo ocupa el **subagente** al que delegas, no el hilo principal "sentado" en un rol:

- **`explorador`** (haiku) — barridos de lectura: localizar archivos, símbolos, referencias cruzadas.
- **`mecanico`** (haiku) — edits mecánicos: renombres, aplicar un patrón ya dado, cambios repetitivos.
- **`auditor`** (sonnet) — juicio acotado: veredicto contra una spec dada, correr un test puntual y leer su salida.
- **`arquitecto`** (opus) — trade-offs: diseño, alternativas, riesgos.

**El tier ya está fijado en el agente** (`.claude/agents/`, ADR 0033): elige el asiento, no el modelo. Al delegar, anuncia **qué se delegó a quién** ("delegado a `explorador`: localizar todas las referencias a X") — no un ritual de "sentarse" en el hilo principal.

Si `.claude/agents/` no está sembrado en este repo, delega con el agente general (`general-purpose`) y anuncia igual el asiento que representa — la degradación se acusa, no se finge.

Si el hilo principal hace **excepcionalmente** el trabajo de un asiento (edición acoplada con bucle TDD sobre los mismos archivos, contexto que ya vive en el hilo), acúsalo como **excepción**, no como rito: `🎭 Asiento: <rol> (en sesión) — <por qué>` (criterio completo en `kanban/roles.md`).

## 4. Desconfía de la compactación

> **Los resúmenes de compactación pueden mentir** (disparo `desconfia-de-la-compactacion`). Si esta sesión viene de un resumen (compactación o cierre anterior), antes de retomar algo verifica contra el **artefacto real** —el código, el archivo, este HANDOFF— no contra el resumen. Un plan de trabajo o un HANDOFF en disco es fuente primaria; tu recuerdo de la conversación, no.

## 5. Fija las reglas duras de la sesión

Enúncialas en voz alta para que rijan lo que sigue (detalle en `kanban/roles.md`):

- **Una sola sesión escritora por working tree.** Si hay otra sesión tocando este repo, esta es de solo-lectura o se lleva su propio worktree. El HANDOFF tiene un solo dueño a la vez.
- **El orquestador no pica código en el hilo principal.** La lectura voluminosa y el trabajo pesado van a subagentes; el hilo principal decide y teje. Cuando hagas en sesión el trabajo de otro asiento, anúncialo (`🎭 Asiento: <rol> (en sesión) — <por qué>`).
- **Evidencia-no-palabra.** Nada se declara hecho hasta que corre; la evidencia va al artefacto (test verde, demo, `qa_runs/`, log), no a tu palabra.
- **La disciplina escala con el riesgo.** Menú, no molde: enciende solo la ceremonia que este cambio merece.
- **Nada de memorias de la IA**: todo va al repo (HANDOFF, ADR, docs del dominio). El hook `no-memorias` lo hace cumplir.

## 6. Orienta y propón

Con el estado ya leído, resume en pocas líneas **dónde estamos** y **qué sigue en orden de valor** (si el HANDOFF o el ROADMAP lo dicen, cítalos; si quieres el detalle priorizado, usa `/jidoka:que-sigue`).

Si el cliente dejó una nota de enfoque, tenla en cuenta: **$ARGUMENTS**

Luego **espera la señal del cliente** antes de construir. Si la tarea amerita un plan de sprint, propón `/jidoka:planea`. No arranques a picar código sin el QUÉ aprobado.
