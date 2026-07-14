---
description: Abre la sesión con el estado real del proyecto y fija las reglas duras de trabajo (ritual Jidoka)
argument-hint: "[nota opcional de en qué quieres enfocar la sesión]"
allowed-tools: Read, Bash(git status:*), Bash(git log:*), Bash(git branch:*), Bash(test:*), Bash(cat:*), Bash(powershell:*)
---

Estás **abriendo una sesión de trabajo** en este proyecto. Antes de tocar nada, orienta la sesión con el estado real —no con tu memoria ni con un resumen— y fija las reglas del ritual. Este es el `/jidoka:arranca` del método (ver `kanban/lazo.md`, `kanban/roles.md`).

## 1. Lee el estado en vuelo (el relevo)

El estado del proyecto vive en artefactos, no en la memoria de nadie:

- **Estado en vuelo y pendientes** — se lee y **se limpia** al abrir:
@HANDOFF.md

- **Recursos del proyecto** (lo que no debes preguntar: material, identidades, máquinas/ambientes, convenciones):
@product/recursos-del-proyecto.md

- **Plan de trabajo del día**, si una sesión anterior lo dejó a medias (efímero, fuera de git — ADR 0006):
!`test -f .jidoka/plan-actual.md && cat .jidoka/plan-actual.md || echo "(no hay plan de trabajo activo — empezamos limpio)"`

- **Dónde está git ahora mismo**:
!`git branch --show-current && git status --short && git log --oneline -5`

## 2. Siéntate y rutea (el casting y el router)

Antes de construir, la sesión **se sienta en un asiento** y adopta la **tabla de ruteo** de la ley — nada de esto se deduce sobre la marcha ni depende de tu iniciativa:

- **Adopta el casting.** `product/recursos-del-proyecto.md` (ya leído arriba) trae la sección **## El casting**: quién ocupa cada asiento del método, por nombre. **Anúncialo en voz alta** (`🎭 Asiento: <rol> — <nombre>`). Si no hay casting, usa los roles neutrales de `kanban/roles.md` y sugiere sembrar uno.
- **Lee el router** — la ley (`tools/blast-radius.json`) dice qué área se rutea a qué asiento, qué gate la vigila, y qué Stop hooks están **vivos o dormidos** (con la razón de cada dormido):
!`powershell -NoProfile -File tools/rutear.ps1 || echo "(no hay router: tools/rutear.ps1 no esta sembrado -- actualiza el motor)"`

> **Adopta, no resumas.** Esa tabla ES la ley de ruteo de la sesión: si tocas la `fuente` de un área, te sientas en su rol y su gate te va a vigilar al cerrar. Un gate **DORMIDO** no es un permiso — es un área que la ley aún no declara; si tu trabajo la necesita, se declara en la ley (no se improvisa).

## 3. Desconfía de la compactación

> **Los resúmenes de compactación pueden mentir** (disparo `desconfia-de-la-compactacion`). Si esta sesión viene de un resumen (compactación o cierre anterior), antes de retomar algo verifica contra el **artefacto real** —el código, el archivo, este HANDOFF— no contra el resumen. Un plan de trabajo o un HANDOFF en disco es fuente primaria; tu recuerdo de la conversación, no.

## 4. Fija las reglas duras de la sesión

Enúncialas en voz alta para que rijan lo que sigue (detalle en `kanban/roles.md`):

- **Una sola sesión escritora por working tree.** Si hay otra sesión tocando este repo, esta es de solo-lectura o se lleva su propio worktree. El HANDOFF tiene un solo dueño a la vez.
- **El orquestador no pica código en el hilo principal.** La lectura voluminosa y el trabajo pesado van a subagentes; el hilo principal decide y teje. Cuando hagas en sesión el trabajo de otro asiento, anúncialo (`🎭 Asiento: <rol> (en sesión) — <por qué>`).
- **Evidencia-no-palabra.** Nada se declara hecho hasta que corre; la evidencia va al artefacto (test verde, demo, `qa_runs/`, log), no a tu palabra.
- **La disciplina escala con el riesgo.** Menú, no molde: enciende solo la ceremonia que este cambio merece.
- **Nada de memorias de la IA**: todo va al repo (HANDOFF, ADR, docs del dominio). El hook `no-memorias` lo hace cumplir.

## 5. Orienta y propón

Con el estado ya leído, resume en pocas líneas **dónde estamos** y **qué sigue en orden de valor** (si el HANDOFF o el ROADMAP lo dicen, cítalos; si quieres el detalle priorizado, usa `/jidoka:que-sigue`).

Si el cliente dejó una nota de enfoque, tenla en cuenta: **$ARGUMENTS**

Luego **espera la señal del cliente** antes de construir. Si la tarea amerita un plan de sprint, propón `/jidoka:planea`. No arranques a picar código sin el QUÉ aprobado.
