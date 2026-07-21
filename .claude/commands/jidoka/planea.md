---
description: Diseña el plan de un sprint con el QUÉ aprobado por el cliente ANTES de escribir código (rebanada R0 con STOP)
argument-hint: "[nombre corto del sprint o la capacidad a planear]"
allowed-tools: Read, Bash(git status:*), Bash(test:*), Bash(powershell:*)
---

Vas a **planear un sprint**, no a construirlo. El entregable de este comando es un plan aprobado —el contrato del sprint—, no código. La **Intención (el QUÉ)** se escribe y se aprueba antes que la Construcción.

Enfoque pedido por el cliente: **$ARGUMENTS**

Frescura primero — el estado pudo moverse desde el arranca; si algo de abajo lo contradice, git gana:
!`git status --short`

El estado que el plan necesita queda inyectado **aquí mismo** — la garantía de que correr `planea` directo, sin pasar por `arranca`, no planea a ciegas (si vienes del arranca lo verás repetido: costo aceptado, es la póliza):

> **Preflight — los `@` NO avisan si faltan.** Un `@` a un archivo ausente inyecta vacío en
> silencio y `planea` planearía a ciegas. Si algo sale `[FALTA]`, siembra la instancia antes de
> redactar R0 (o corre `/jidoka:descubre` si el brief está vacío — jidoka#104).
!`test -f HANDOFF.md || echo "[FALTA] HANDOFF.md"; test -f ROADMAP.md || echo "[FALTA] ROADMAP.md"; test -f product/PRODUCT_BRIEF.md || echo "[FALTA] product/PRODUCT_BRIEF.md"; echo "[preflight @] revisado -- cada [FALTA] de arriba inyecta VACIO ese @ (el plan saldria a ciegas). Siembra la instancia (instalar.ps1 -Actualizar) antes de R0. Sin [FALTA] = relevo, backlog y brief existen."`

- **El relevo** (pendientes y cola de decisiones del cliente — insumo directo del plan):
@HANDOFF.md

- **El backlog** (hacia dónde va el proyecto; el orden de valor se defiende contra esto):
@ROADMAP.md

## El límite WIP (FLU-1): si hay un Gemba esperando tus ojos, NO se abre sprint nuevo

> **Drum-buffer-rope: el ritmo lo marca la aceptación del cliente, no la producción.** Antes de
> redactar R0, el gate del estado vivo se planta si hay un Gemba entregado que el cliente aún no
> aceptó ni rechazó — y **nombra cuál**. Sin `tools/flujo.json` (o sin la clave `estado`) dirá «no
> aplica»; corrupto → falla cerrado (exit 2).
!`test -f tools/estado-flujo.ps1 && powershell -NoProfile -ExecutionPolicy Bypass -File tools/estado-flujo.ps1 -Gate || echo "[flujo] sin vista del limite WIP (tools/estado-flujo.ps1 no sembrado) -- corre instalar.ps1 -Actualizar; el limite WIP no se hace cumplir en este planea."`

**Si arriba salió `[BLOQUEA]`, DETENTE aquí: no redactes R0.** El camino es correr el Gemba pendiente (`/jidoka:gemba`) o que el cliente lo acepte/rechace **con nombre**. Saltarse el muro = **decisión del cliente escrita, no iniciativa del agente**.

## R0 — el QUÉ, con STOP (lo primero, sin excepción)

> **La lección más cara del linaje: sprints construidos sin criterios aprobados entregaron cosas que el cliente no pidió.** La primera rebanada de todo sprint es **R0**: el QUÉ aprobado por el cliente, leyendo lo que el producto ya definió, **antes de la primera línea de código**.

1. **Lee el encuadre de producto.** El brief ya está inyectado aquí (un `@` es un hecho, no un encargo — ADR 0034):
@product/PRODUCT_BRIEF.md

   Las **capacidades** de `product/` se exploran **dirigido al sprint** (solo lo que este QUÉ toca — leerlas es el trabajo de este paso, no un relevo); el ROADMAP ya quedó inyectado arriba. Si el brief está vacío o el QUÉ es ambiguo, eso es un hallazgo, no un permiso para inventar: **→ corre `/jidoka:descubre` primero** — la entrevista de descubrimiento disuelve la niebla y deja el brief lleno; lo que ni el descubrimiento resuelva **se marca como pendiente del cliente, no se rellena**.
2. **Redacta la capacidad con criterios de aceptación** en lenguaje llano: `Dado que… cuando… entonces…`. Esta es la mitad que casi todos se saltan. Cada criterio debe poder demostrarse **sin código ni terminal** (disparo `demo-que-corre-el-cliente`): si la única forma de verlo funcionar es corriendo un script, la rebanada no es vertical todavía.
3. **STOP — checkpoint humano.** Presenta el QUÉ y **espera la aprobación explícita del cliente** antes de diseñar el CÓMO. Automatiza alto la propuesta; mantén baja la decisión (disparo `decision-queda-en-humano`): tú propones, el cliente elige y firma. Y la aprobación **nombra lo que aprueba** (disparo `aprobacion-nombrada`): un "dale" o un "a tu criterio" no cierran un R0 — pide que el cliente diga con nombre qué aprueba. No es un muro determinista —es un checkpoint— pero es la regla: nada irreversible se construye sin el QUÉ aprobado.

## El plan (una vez aprobado el QUÉ)

Copia la plantilla `@kit/.jidoka/templates/sprint-plan.md` y llénala con:

- **Contexto** (por qué ahora), **Encuadre de producto** (validado con el cliente), **Decisiones del cliente** (con fecha; las gordas van además a un ADR).
- **Alcance en rebanadas verticales** — cada una commiteable y verde por sí sola, ordenadas por dependencia y valor. Marca las que tocan la ley (`tools/blast-radius.json`).
- **Archivos** (para dimensionar el blast radius antes de empezar).
- **Verificación (el demo que corre el cliente)** — `owner: cliente`: los pasos exactos con los que el cliente verá el incremento funcionando **sin código ni terminal** (abrir una URL, hacer clic, mirar un reporte). Regla del demo tangible (disparo `demo-que-corre-el-cliente`): si el cliente no puede correrlo así, la rebanada **no es vertical** — re-rebánala o márcala como decisión pendiente; no la cierres con una demo de terminal que solo tú puedes correr. Nace aquí y se cierra idéntico en la entrega.
- **Lo que NO entra** — la frontera explícita del alcance.

## Cómo cierra este comando

- **STOP 2 — la aprobación formal del plan, SIEMPRE en plan mode.** El plan se entrega en **plan mode**; si no estás en plan mode, **entra** para entregarlo — la conversación no es canal formal de aprobación. Un plan rechazado **se ajusta y se re-presenta** — no se archiva.
- Al aprobarse, el plan se archiva como `docs/sprints/sprint-N-plan.md` (se versiona: es el contrato permanente). **No lo confundas con el plan de trabajo del día** (`/.jidoka/plan-actual.md`, efímero — ADR 0006).
- Registra el sprint en `docs/sprints/README.md`.
- **Ancla el plan a la vista.** Registra las rebanadas aprobadas como **lista de tareas del harness** (la que se ve en la UI del chat) y márcalas conforme avanzan — el cliente ve el progreso en vivo, sin preguntar.
- Recién entonces se construye — rebanada por rebanada, cada una verde.
