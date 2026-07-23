---
tipo: analisis
estado: vigente
---
# Exploración — «explorador» significa dos cosas distintas (2026-07-23)

> **Sobre el tamaño, sin coartada.** La regla 5 de `doctrina/08-kata-de-mejora.md` pide *media
> cuartilla* (~15 líneas). Este informe tiene ~95 y **no la cumple**; solo es más corto que la
> vuelta anterior (193). La tensión entre «media cuartilla» y los informes durables de
> `docs/analisis/` está declarada en el molde (`kit/.jidoka/templates/exploracion.md:11-14`), **no
> resuelta**, y es una de las decisiones abiertas del dueño. Se dice aquí porque el molde exige
> que si sale largo, se diga por qué: sale largo porque la sección de método y el guion de
> revisión no caben en quince líneas.

**Timebox declarado:** una vuelta corta dentro de la sesión · **Corte:** 2026-07-23 · v1.32.0

## Las cinco preguntas

1. **Condición objetivo.** Que al decir un nombre de asiento nadie tenga que preguntar «¿te
   refieres a la persona o a la mecánica?». Un nombre, un referente.
2. **Condición actual.** Medida abajo: hay **tres ejes** de nombres y dos colisiones reales.
3. **Obstáculo elegido AHORA.** Los nombres de los asientos-subagente por tier (`.claude/agents/`)
   se tomaron del vocabulario de roles, no del de esfuerzo. Los otros obstáculos (qué seats
   faltan, qué archivos toca cada uno) se anotan sin atacarse.
4. **Hipótesis, escrita antes de mirar.** *«Existe una colisión, y es solo `explorador` vs
   exploración.»* → **Refutada parcialmente:** hay **dos** colisiones, no una. Ver abajo.
5. **Cita de revisión.** Cuando se decida el casting canon: si al leer la tabla nueva hace falta
   una nota aclaratoria para distinguir ejes, el renombre no sirvió.

## Método

Lectura de las tres fuentes que definen nombres en el repo (`kanban/roles.md`,
`.claude/agents/*.md`, `product/casting.md`) y careo de sus tablas entre sí buscando el mismo
token usado con dos sentidos. Sin experimento: la pregunta es de coherencia documental, y el
medio más barato que la responde es leer las tres tablas — no hay nada que ejecutar.

## Condición actual (medida)

Tres ejes conviven hoy, con fuentes distintas:

| Eje | Qué nombra | Dónde vive | Nombres |
|---|---|---|---|
| **Rol del método** | la función; es el **token que la ley y los hooks leen** | `kanban/roles.md`, `tools/blast-radius.json` | orquestador, desarrollador, devops, escribano, validador, revisor-visual, arquitecto-doc |
| **Mecánica por tier** | **cuánto cerebro** cuesta la tarea; `model:` fijo (ADR 0033) | `.claude/agents/*.md` | explorador, mecanico, auditor, arquitecto |
| **Casting (persona)** | etiqueta cosmética sobre el eje 1 | `product/casting.md`, tabla de ejemplo en `kanban/roles.md:40-48` | nombres de pila (ver nota de confidencialidad abajo) |

**Colisión 1 — `explorador`.** En el eje 2 es el asiento **más barato** (haiku: barre y localiza,
no juzga). En el habla del proyecto, «exploración» es el trabajo de **más juicio** (la kata:
producir conocimiento y graduar tarjetas). Misma raíz, sentidos opuestos.

**Colisión 2 — `arquitecto`.** Existe en el eje 2 (tier opus) **y** en el eje 1 como
`arquitecto-doc` (`kanban/roles.md:26`). Son cosas distintas: uno es un tier, el otro un rol con
carta propia.

**Hueco medido, no colisión:** el eje 1 **no tiene rol de descubrimiento/exploración**. El casting
de ejemplo asigna el nombre que el dueño usa para ese trabajo a `arquitecto-doc` (`kanban/roles.md:47`), que es formato del grafo de
docs — no es punta de lanza ni produce backlog. El asiento que el dueño describe **no existe
todavía** en el método.

## Resultado — rojo → verde

**Ninguno.** Nada se curó ni se cableó: la vuelta produce conocimiento y tarjetas, no mecanismo.

## Rojo honesto (medido, sin cura)

- **Las dos colisiones siguen vivas hoy.** Nadie las curó en esta vuelta; el vocabulario ambiguo
  sigue en `.claude/agents/*.md` y en el habla del proyecto.
- **El asiento de descubrimiento/exploración no existe y el dueño ya lo está usando de hecho.**
  Cuando el dueño nombra ese asiento está nombrando un rol que el método no define — así que hoy ese trabajo
  no tiene carta, ni límites escritos, ni gate que lo vigile.
- **Quién es el dueño del canon está sin determinar.** Según la tabla SSOT de `CONTRIBUTING.md`
  el reparto vive en `product/casting.md`, pero los nombres viven en la tabla de *ejemplo* de
  `kanban/roles.md:40-48`. Cuál manda cuando se vuelva canon lo decide el dueño, no el agente.

## Lo NO medido

- **Qué nombres nuevos debería llevar el eje de tiers.** Se identificó el defecto, no la cura.
- **Si renombrar el eje de tiers rompe algo**: no se buscaron referencias a `explorador`/
  `arquitecto` en skills, docs, atlas o suites. Un renombre sin ese censo rompe punteros.

## Qué debe revisar el dueño (guion) — 8 min

1. **Haz esto:** lee la tabla de tres ejes de arriba y responde en voz alta qué es `explorador`.
   **Debe pasar:** contestas «la mecánica barata» sin dudar, y sabes que el asiento de exploración es otra cosa.
   **Recházalo si** sigues necesitando preguntar cuál de los dos te están nombrando — entonces la
   tabla no resolvió nada y el renombre es urgente, no «Normal».
2. **Haz esto:** abre `kanban/roles.md` en la línea 47 y mira a qué rol está asignado el nombre con el que llamas al trabajo de exploración.
   **Debe pasar:** dice `arquitecto-doc`, y reconoces que **no** es el trabajo que tú le pides.
   **Recházalo si** te parece que `arquitecto-doc` sí describe lo que hace — entonces no falta un
   asiento y la tarjeta del casting sobra.
3. **Haz esto:** busca nombres de pila en lo que esta rama agrega
   (`git diff main.. -- ROADMAP.md docs/analisis/`). **Debe pasar:** no aparece ninguno — el
   canon nominal se decidió fuera de git (ver abajo). **Recházalo si** encuentras uno: la
   decisión del 2026-07-23 no se aplicó completa.

## La decisión de confidencialidad (tomada, 2026-07-23)

Se preguntó al dueño si los nombres del casting son personas reales o apodos de asiento.
**Respuesta: personas reales que no contribuyen al repo**, usadas porque sus funciones coinciden
con la realidad y le sirven para recordar quién hace qué. Eso activa la frontera de
`CONTRIBUTING.md:40` (ADR 0055): un repo público no lleva nombres de personas.

**Decisión del dueño: el canon nominal vive FUERA de git** — patrón del `plan-actual.md` (ADR
0006), archivo local no rastreado. El repo público conserva los roles neutrales. Costo aceptado:
el canon no viaja entre máquinas ni a los labs.

**Deuda que esto deja abierta:** seis de esos nombres están en `kanban/roles.md:40-48` **desde el
2026-07-10**, ya en la historia pública de `main`. Esta rama no los introduce ni los quita;
sacarlos exige reescribir historia. Va como tarjeta aparte, no se resuelve aquí.

## Qué se descarta (y por qué)

- **Renombrar el eje 1** (los roles del método): son el token que leen `blast-radius.json` y los
  hooks. Tocarlos es cambiar la ley y romper a los hijos. Descartado.
- **Vivir con la ambigüedad y aclarar de viva voz cada vez.** Ya se midió que no funciona: el
  dueño tuvo que preguntar explícitamente cuál de los dos se le estaba nombrando.

## Qué mata este informe si se adopta

La tabla de casting de ejemplo de `kanban/roles.md:40-48` dejaría de decir la verdad en dos filas
(el asiento de exploración y el escribano). Ningún ADR queda superseded.

## Qué gradúa

Tres tarjetas al ROADMAP, ninguna construida aquí:

1. **Renombrar la mecánica por tier** para que ningún nombre suene a rol — el eje 2 debería hablar
   de esfuerzo, no de oficio.
2. **El casting canon, con el nominal fuera de git** — el repo estrena el rol de
   descubrimiento/exploración que hoy no existe y nombra al escribano en el eje neutral; la capa
   de nombres de pila vive en el archivo local.
3. **Alcance de escritura por asiento** (qué archivos toca cada quien) — es la misma allowlist de
   `PreToolUse` ya encolada, generalizada de un asiento a todos.
4. **Los nombres que ya están en `main` desde el 2026-07-10** — decidir si se reescribe la
   historia para sacarlos o se aceptan por escrito.
