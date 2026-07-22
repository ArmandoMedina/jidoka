---
description: Abre la sesión con el estado real del proyecto y fija las reglas duras de trabajo (ritual Jidoka)
argument-hint: "[nota opcional de en qué quieres enfocar la sesión]"
allowed-tools: Read, Bash(git status:*), Bash(git log:*), Bash(git branch:*), Bash(test:*), Bash(cat:*), Bash(powershell:*)
---

Estás **abriendo una sesión de trabajo** en este proyecto. Antes de tocar nada, orienta la sesión con el estado real —no con tu memoria ni con un resumen— y fija las reglas del ritual. Este es el `/jidoka:arranca` del método.

## 1. Lee el estado real, en orden de onboarding: git → qué → cómo → dónde

Te orientas como se onboardea a un colega: primero **si esto está fresco** (git), luego **qué es** (brief), **cómo se trabaja** (contributing/infra) y **dónde se quedó** (handoff). El contenido de cada `@` ya está inyectado abajo — no es lectura pendiente (ADR 0034).

**Regla de conflicto: git gana.** Si el HANDOFF describe un estado que git contradice —ramas ya mergeadas, cambios ya en `main`, "pendiente" que ya se hizo—, cree a git y lee el relevo con esa lupa.

### §1a — Revisa la frescura en git

La lupa de todo lo demás; léela primero:
!`git branch --show-current && git status --short && git log --oneline -5`

### §1b — Carga el contexto (`@`), en orden qué → cómo → dónde

> **Preflight — los `@` de abajo NO avisan si faltan.** Un `@` a un archivo ausente inyecta
> **vacío en silencio**: el ritual seguiría hasta el paso 6 y te daría la **sensación de estar
> preparado** con el agente sin el QUÉ/CÓMO/DÓNDE. La siembra es best-effort en tiempo de
> instalación; este preflight es la última defensa, y corre en cada sesión. Si algo sale
> `[FALTA]`, **detente a sembrar la instancia antes de confiar en la sesión** (regla dura del §5)
> — no propongas trabajo sobre contexto vacío (jidoka#104).
!`test -f product/PRODUCT_BRIEF.md || echo "[FALTA] product/PRODUCT_BRIEF.md"; test -f CONTRIBUTING.md || echo "[FALTA] CONTRIBUTING.md"; test -f product/infra.md || echo "[FALTA] product/infra.md"; test -f HANDOFF.md || echo "[FALTA] HANDOFF.md"; echo "[preflight @] revisado -- cada [FALTA] de arriba inyecta VACIO ese @ (el agente NO recibe ese contexto). Siembra la instancia antes de confiar en la sesion: instalar.ps1 -Actualizar (o sembrar-manual.ps1 -Actualizar) desde Jidoka. Sin [FALTA] = los 4 @ existen."`

> **El `@` existe, ¿pero tiene las secciones?** El preflight de arriba verifica que el archivo **esté**;
> este verifica que su **estructura** siga el molde gobernado. Un `CONTRIBUTING`/`brief`/`infra` presente
> pero **destripado o reestructurado** pasa el `[FALTA]` y aun así **inyecta basura** al `@`. Gobierno por estatuto:
> el contenido varía libre, las **secciones** no — `DESVIADO` = *garantía nula* sobre ese doc. Aviso, no
> muro (jidoka KIT-2; el muro es opt-in en CI).
!`test -f tools/estado-docs.ps1 && powershell -File tools/estado-docs.ps1 || echo "[docs] sin detector de conformidad estructural -- corre instalar.ps1 -Actualizar (o sembrar-manual) para gobernar la estructura de brief/infra/CONTRIBUTING."`

> **¿Y los `@` de fábrica del ritual siguen puestos?** El estatuto de arriba gobierna la *estructura* de
> los docs; este gobierna los **`@`-includes de fábrica** de los comandos `/jidoka:*`. Un `@` extra que
> agregaste es **CONFORME** (aditiva legal); si a un comando le falta un `@` de fábrica, sale `DESVIADO`
> nombrándolo — *garantía nula*: la lógica que ese `@` inyectaba no corre. Reconcilia: restaura el `@` o
> acéptalo con firma. Aviso, no muro (jidoka CFG-1, el estatuto; muro opt-in en CI).
!`test -f tools/estado-ritual.ps1 && powershell -File tools/estado-ritual.ps1 || echo "[ritual] sin detector del estatuto del ritual -- corre instalar.ps1 -Actualizar (o sembrar-manual) para gobernar los @ de fabrica de los comandos /jidoka:*."`

- **El QUÉ** (el brief: caso concreto, métrica, autoridad del dominio, criterio de "hecho"):
@product/PRODUCT_BRIEF.md

- **El CÓMO — cómo se trabaja aquí** (el flujo, quién es dueño de qué doc, el ritual de versión):
@CONTRIBUTING.md

- **El CÓMO — la infraestructura** (identidades, máquinas/ambientes, el roster con nombres si el repo lo declaró):
@product/infra.md

- **El DÓNDE — dónde se quedó la última sesión**: el relevo se lee y **se limpia** al abrir; interprétalo contra git (§1a), no al revés:
@HANDOFF.md

<!-- Punto de insercion de @ del cliente (parametrizar desde la extension). Aditiva legal: el estatuto del ritual acepta un @ extra. No borres el marcador. -->
<!-- jidoka:arrobas -->

- **El plan de trabajo del día**, si una sesión anterior lo dejó a medias (efímero, fuera de git — ADR 0006):
!`test -f .jidoka/plan-actual.md && cat .jidoka/plan-actual.md || echo "(no hay plan de trabajo activo — empezamos limpio)"`

## 2. El roster y el router

Antes de construir, ubica dos tablas de la ley — ninguna se deduce sobre la marcha ni depende de tu iniciativa:

- **El roster** es la **tabla de responsables**: quién responde por cada asiento del método — no un asiento que el hilo principal "ocupa". Si el repo declaró un casting con nombres, vive en la sección `## El casting` de `product/infra.md` — **ya inyectado arriba**: el casting vive donde se inyecta (cosecha #7; los repos sembrados antes de v1.17 lo tenían en `product/recursos-del-proyecto.md` — migra esa sección a `infra.md`). Si no hay casting declarado, usa los roles **neutrales** de `kanban/roles.md` — esta nave nodriza usa los neutrales a propósito (decisión del cliente, 2026-07-14) — y sugiere sembrarlo si el repo lo amerita.
- **El router** (`tools/rutear.ps1`) es el **preview de gates** de esta sesión: según lo que toques, ESTOS gates te van a vigilar al cerrar — no una tabla en la que "te sientas".
!`powershell -NoProfile -File tools/rutear.ps1 || echo "(no hay router: tools/rutear.ps1 no esta sembrado -- actualiza el motor)"`

> **Previsualiza, no resumas.** Esa tabla ES la ley de ruteo de la sesión: si tocas la `fuente` de un área, ESE gate va a medir tu diff al cerrar — mide el artefacto, no si alguien "se sentó" en el rol. Un gate **DORMIDO** no es un permiso — es un área que la ley aún no declara; si tu trabajo la necesita, se declara en la ley (no se improvisa).

## 3. El asiento lo ocupa el subagente

El roster de arriba dice **quién responde**; el asiento con dientes —el que de verdad ejecuta, con un tier de modelo ya fijo en el agente (`.claude/agents/`, ADR 0033)— lo ocupa el **subagente** al que delegas, no el hilo principal "sentado" en un rol. El casting vivo de este repo:
!`powershell -NoProfile -File tools/asientos.ps1 || echo "(no hay tools/asientos.ps1 -- actualiza el motor; mientras, delega con general-purpose y acusa la degradacion)"`

**Elige el asiento, no el modelo.** Al delegar, anuncia **qué se delegó a quién** ("delegado a `explorador`: localizar todas las referencias a X") — no un ritual de "sentarse" en el hilo principal. Si la tabla salió `[DEGRADADO]`, obedece la instrucción que trae impresa — el fallback lo dicta la tabla, no tu criterio.

Si el hilo principal hace **excepcionalmente** el trabajo de un asiento (edición acoplada con bucle TDD sobre los mismos archivos, contexto que ya vive en el hilo), acúsalo como **excepción**, no como rito: `🎭 Asiento: <rol> (en sesión) — <por qué>`.

## 4. Desconfía de la compactación

> **Los resúmenes de compactación pueden mentir** (disparo `desconfia-de-la-compactacion`). Si esta sesión viene de un resumen (compactación o cierre anterior), antes de retomar algo verifica contra el **artefacto real** —el código, el archivo, este HANDOFF— no contra el resumen. Un plan de trabajo o un HANDOFF en disco es fuente primaria; tu recuerdo de la conversación, no.

## 5. Fija las reglas duras de la sesión

Enúncialas en voz alta para que rijan lo que sigue:

- **Una sola sesión escritora por working tree.** Si hay otra sesión tocando este repo, esta es de solo-lectura o se lleva su propio worktree. El HANDOFF tiene un solo dueño a la vez.
- **El orquestador no pica código en el hilo principal.** La lectura voluminosa y el trabajo pesado van a subagentes; el hilo principal decide y teje. Cuando hagas en sesión el trabajo de otro asiento, anúncialo (`🎭 Asiento: <rol> (en sesión) — <por qué>`).
- **Evidencia-no-palabra.** Nada se declara hecho hasta que corre; la evidencia va al artefacto (test verde, demo, `qa_runs/`, log), no a tu palabra.
- **La disciplina escala con el riesgo.** Menú, no molde: enciende solo la ceremonia que este cambio merece.
- **Nada de memorias de la IA**: todo va al repo (HANDOFF, ADR, docs del dominio). El hook `no-memorias` lo hace cumplir.

## 6. Orienta y propón

Con el estado ya leído, resume en pocas líneas **dónde estamos** y **qué sigue en orden de valor** (si el HANDOFF o el ROADMAP lo dicen, cítalos; si quieres el detalle priorizado, usa `/jidoka:que-sigue`).

Si el cliente dejó una nota de enfoque, tenla en cuenta: **$ARGUMENTS**

Luego **espera la señal del cliente** antes de construir. Si la tarea amerita un plan de sprint, propón `/jidoka:planea`. No arranques a picar código sin el QUÉ aprobado.
