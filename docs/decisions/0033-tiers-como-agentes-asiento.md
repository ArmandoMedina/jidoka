# ADR 0033 — Los tiers de modelo se instalan como agentes-asiento

- **Estado:** aceptado
- **Fecha:** 2026-07-16

## Contexto

Issue #63: la regla de model-routing (`kanban/roles.md`, sección "Model-routing") vivía solo en prosa — "pequeño para lo mecánico, medio para juicio acotado, grande para decisiones con trade-offs". Nada la hacía cumplirse. Un agente que delega un subagente sin declarar `model:` (o que lo declara con un id inventado, un typo, o un alias que el harness no reconoce) no truena: el harness **cae en silencio al default** — que en este linaje es el modelo caro. El cliente lo cazó a ojo el 2026-07-14, revisando el gasto de una sesión que debió resolverse con barridos de lectura baratos y en cambio corrió entero en el tier grande.

Es el mismo hilo que el ADR 0029 ya cerró para la conciencia de ruteo (`arranca` sienta, `rutear.ps1` decide vivo/dormido): *"nada de conciencia depende de la iniciativa del agente"*. Aquí el objeto es distinto (qué modelo corre una tarea, no qué gate la vigila) pero la falla es la misma forma — una regla correcta en prosa, sin mecánica que la sostenga cuando el agente está apurado, cansado, o simplemente se equivoca de alias.

La primera construcción de esta rebanada se hizo en una rama que se descartó completa (el sprint "Conciencia del agente" se reinició); este ADR documenta la reconstrucción limpia bajo el issue #75, rebanada R1.

## Decisión

Los cuatro tiers del menú de asientos-subagente se instalan como **agentes-asiento** — archivos `.claude/agents/*.md` con `model:` fijo en el frontmatter, no una elección que el agente hace cada vez de memoria:

- `explorador.md` — `model: haiku` — barridos de lectura y localización.
- `mecanico.md` — `model: haiku` — edits mecánicos bien especificados.
- `auditor.md` — `model: sonnet` — juicio acotado: revisar contra spec, correr un test.
- `arquitecto.md` — `model: opus` — decisiones con trade-offs: diseño, alternativas, riesgos.

Cada uno declara en su `description` el criterio de CUÁNDO usarlo, para que el orquestador elija **por asiento** (la tarea determina el rol, el rol trae su tier) en vez de recordar "qué modelo tocaba hoy".

Un lint nuevo, `tools/probar-agentes.ps1`, vigila la instalación: existen los 4 asientos esperados, cada `.md` tiene frontmatter con `name:`, `description:`, `model:` y `tools:`, `name:` coincide con el archivo, y — el caso que motivó el ADR — `model:` es un alias real y cerrado del harness (`haiku` | `sonnet` | `opus`). Un id inventado o un typo ya no cae en silencio: el lint lo bloquea antes de que el agente se estrene. El área `ritual` de la ley (`tools/blast-radius.json`) se extiende con `.claude/agents/*` — los agentes-asiento son ritual ejecutable, la misma familia que los comandos `/jidoka:*` y las skills.

## Por qué

- Una regla de model-routing en prosa depende de que el agente la recuerde y aplique bien cada vez; falla en silencio y el harness cae al default (el modelo caro) sin avisar.
- El cliente la cazó a ojo revisando el gasto de una sesión: sin mecánica, la regla es auditable solo a posteriori y a mano.
- El ADR 0029 ya cerró la misma forma de falla (regla correcta en prosa sin mecánica que la sostenga) para la conciencia de ruteo; este ADR aplica el patrón al tier de modelo.

## El camino que NO se toma (y por qué tienta)

- **Un cue en prosa dentro de `arranca.md`** ("recuerda elegir el modelo según la tarea"). Tienta porque es el cambio más barato. Se descarta: es exactamente lo que el issue #63 acusa — una regla que depende de que el agente la recuerde y la aplique bien cada vez, sin nada que la haga cumplirse. Ya falló una vez; repetirla en otro archivo no la arregla.
- **Un campo `tier` en la ley (`tools/blast-radius.json`)**, junto a `rol`. Tienta porque la ley ya rutea área→asiento y parece el lugar natural para añadir área→modelo. Se descarta: la ley rutea **áreas del repo a roles** (quién es dueño de qué), no tareas de un subagente a un modelo — son dos preguntas distintas ("¿quién es dueño de este código?" vs. "¿qué tan grande es esta tarea puntual?"). Mezclarlas habría hecho que cada tarea nueva necesitara una entrada en la ley, cuando el tier ya es fijo por asiento y no varía por área tocada.

## Consecuencias

- **Más fácil:** los tiers evolucionan editando el frontmatter de un `.md` (un cambio de una línea, revisable en el diff), no prosa que hay que releer y confiar. El orquestador delega por asiento (`Agent({ subagent_type: "auditor", ... })`) y el `model:` viaja con la definición, no con la memoria de la sesión.
- **Más difícil / deuda:** el lint solo caza aliases inventados o ausentes — no caza que el orquestador haya elegido el asiento *equivocado* para la tarea (p.ej. mandar una decisión de arquitectura a `mecanico`). Esa sigue siendo la doctrina de model-routing en `kanban/roles.md`, sin mecánica que la fuerce: el orquestador sigue decidiendo **QUÉ** delegar y **A QUIÉN** de los cuatro asientos; lo único que queda instalado es que, una vez elegido el asiento, el tier ya no se puede desviar en silencio.

---

> Reglas del registro: una decisión = un archivo · al agregarlo, **listalo en el [índice](README.md) en el mismo commit** (el gate lo exige) · nunca borres una decisión: márcala *reemplazada* y enlaza la nueva.
