# ADR 0034 — El arranca inyecta, no encarga; el asiento lo ocupa el subagente

- **Estado:** aceptado
- **Fecha:** 2026-07-16

## Contexto

`/jidoka:arranca` (ADR 0029) instaló dos mecánicas sembradas: la sesión "se sienta" en un asiento (adopta el casting) y "lee el router" antes de tocar nada. Validado en el terreno durante la rebanada R3 del sprint "Conciencia del agente" (issue #75), el reframe expuso tres huecos entrelazados:

1. **El "sentarse" del hilo principal era conciencia de utilería.** El comando pedía anunciar `🎭 Asiento: <rol> — <nombre>` para el hilo que abre la sesión, pero el hilo principal **decide y teje** (`kanban/roles.md`) — no ejecuta con el tier de modelo de un rol. El asiento con dientes, el que de verdad corre con un modelo fijo, lo ocupa el **subagente** al que se delega. Este mismo sprint sembró `.claude/agents/{explorador,mecanico,auditor,arquitecto}.md` con `model:` fijo (haiku/haiku/sonnet/opus — ADR 0033): el mecanismo real para "sentarse" en un asiento ya existe y no es el hilo principal anunciando una etiqueta.
2. **Un puntero es una esperanza, un `@` es un hecho.** El arranca decía "lee `product/recursos-del-proyecto.md`" como instrucción en prosa: seguirla quedaba a criterio del agente, y un agente presionado (contexto largo, prisa) puede saltárselo sin que nada lo note. `/jidoka:descubre` (ADR 0031) ya resolvió el mismo problema para el brief con `@`-inclusión directa — el contenido entra al contexto de la apertura sin depender de que alguien decida leerlo.
3. **El brief monolítico mezclaba el QUÉ con el CÓMO.** `product/recursos-del-proyecto.md` cargaba a la vez material de negocio (lo que el descubrimiento llena, ADR 0031) e infraestructura (máquinas, identidades, convenciones) en un solo archivo, sin frontera. Decisión del cliente (2026-07-14): separar en `product/PRODUCT_BRIEF.md` (el QUÉ) e `product/infra.md` (el CÓMO); el casting nombrado que antes vivía ahí sobrevive como plantilla en `kit/` para los repos hijos, y esta nave nodriza usa los roles neutrales de `kanban/roles.md` a propósito — sigue la misma ruta que un usuario recién sembrado, para no sesgarse.

## Decisión

Tres curas entrelazadas, un solo reframe — **el arranca inyecta, no encarga; el asiento lo ocupa el subagente**:

1. **Reframe rol-teatro → roster + router-preview.** La sección "Siéntate y rutea" se reescribe como "El roster y el router": el roster es la **tabla de responsables** (quién responde por cada asiento, sin que el hilo lo "ocupe"); el router (`tools/rutear.ps1`) se presenta como **preview de gates** ("según lo que toques, ESTOS gates te van a vigilar al cerrar"), no como un asiento que se adopta. Se elimina la instrucción de anunciar `🎭 Asiento: <rol> — <nombre>` para el hilo principal como rito de apertura.
2. **El asiento lo ocupa el subagente (regla instalada).** Sección nueva en `arranca.md`: delega por asiento a `.claude/agents/` — `explorador` (haiku, barridos de lectura), `mecanico` (haiku, edits mecánicos), `auditor` (sonnet, juicio acotado), `arquitecto` (opus, trade-offs). El tier ya está fijado en el agente (ADR 0033): el orquestador elige el asiento, no el modelo. El anuncio que sobrevive es **qué se delegó a quién** — no un ritual de sentarse. Si el hilo principal hace excepcionalmente el trabajo de un asiento, lo acusa como excepción (`🎭 Asiento: <rol> (en sesión) — <por qué>`), no como rito de apertura.
3. **Payload inyecta-directo + split del brief.** El arranca reemplaza el puntero en prosa a `product/recursos-del-proyecto.md` por `@`-inclusión directa de `product/PRODUCT_BRIEF.md` (el QUÉ) y `product/infra.md` (el CÓMO), y agrega `@CONTRIBUTING.md` (el flujo y el SSOT de qué doc es dueño de qué). `@HANDOFF.md` se conserva igual. El casting nombrado que antes vivía en `recursos-del-proyecto.md` sobrevive como plantilla en `kit/` para los hijos que quieran nombrarlo; esta nave nodriza sigue usando los roles neutrales de `kanban/roles.md`.

## Por qué

- **Un puntero es una esperanza; un `@` es un hecho.** La misma familia de decisión que la lectura inyectada del brief en `/jidoka:descubre` (ADR 0031): lo que la sesión no debe re-preguntar no puede depender de que el agente decida leerlo — tiene que estar ya en el contexto cuando el comando termina de correr.
- **El asiento real tiene tier, no etiqueta.** Anunciar `🎭 Asiento: X` en el hilo principal sin que ese hilo cambie de modelo era conciencia de utilería: la etiqueta sonaba a disciplina pero no movía nada. El tier fijo en `.claude/agents/*.md` (ADR 0033) es el mecanismo que sí hace la diferencia — delegar ahí es "sentarse" de verdad; anunciarlo en el hilo principal no lo era.
- **Roster ≠ asiento.** Confundir "quién responde por un área" (una tabla, útil para saber a quién preguntar) con "quién ejecuta con qué modelo" (el subagente) llevaba a que el hilo principal se declarara ocupando un rol que en realidad no ejercía. Separar las dos preguntas —roster (responsable) vs. delegación (ejecutor)— es lo que vuelve el reframe honesto.
- **El split del brief refleja una frontera real.** El QUÉ (caso concreto, métrica, autoridad del dominio) y el CÓMO (máquinas, identidades, convenciones) tienen dueños distintos y cambian con cadencias distintas — mezclarlos en un archivo forzaba a releer infraestructura cada vez que cambiaba una cifra de negocio, y viceversa.

## El camino que NO se toma (y por qué tienta)

- **Mantener el anuncio `🎭 Asiento: <rol> — <nombre>` para el hilo principal, solo con mejor redacción.** Tienta porque conserva el ritual visible sin tocar la mecánica de delegación. Se descarta: el problema no era la redacción, era que el hilo principal anunciaba un rol que no ejecutaba con su tier — pulir las palabras de un teatro sigue siendo teatro.
- **Un gate determinista que bloquee si `arranca.md` no delegó a `.claude/agents/` en la sesión.** Tienta porque sería la cura mecánica pura, coherente con la doctrina de "el determinismo bloquea". Se difiere: no hay forma barata de que un hook observe qué corrió *dentro* de una sesión de chat (a diferencia de un diff de archivos); un gate que no puede medir el hecho real degradaría al mismo teatro que se está corrigiendo. Queda como candidato si el mecanismo de observabilidad de sesión madura.
- **Fusionar de nuevo `PRODUCT_BRIEF.md` e `infra.md` para evitar dos `@` extra.** Tienta por ahorrar tokens en cada apertura. Se descarta: la frontera QUÉ/CÓMO ya está decidida (2026-07-14) y tiene dueños y cadencias de cambio distintos; volver a fusionar reintroducería el problema que motivó el split, solo para ahorrar una inyección.

## Consecuencias

- **Más fácil:** delegar por asiento deja de ser una decisión de "a qué modelo le pido esto" — el tier ya viene fijado en `.claude/agents/*.md`; el orquestador solo elige el rol. La lectura de estado al abrir sesión (HANDOFF, brief, infra, contribuir) ya no depende de que el agente decida seguir un puntero.
- **Más difícil / deuda:** el payload inyectado en cada apertura crece (cuatro `@` en vez de dos) — más tokens consumidos por sesión abierta, incluso en sesiones cortas que no los necesitan todos. Se acepta a propósito: la lectura del estado no es opcional, y el costo de un `@` de más es barato comparado con el costo de un HANDOFF no leído o un brief ignorado. Además, repos que no adoptaron el split `PRODUCT_BRIEF.md`/`infra.md` verán un `@` a un archivo ausente hasta que lo siembren.

## Enmienda 2026-07-17 — el orden de lectura: git → qué → cómo → dónde

El payload de §1 se inyectaba en orden **HANDOFF → brief → infra → CONTRIBUTING → plan → git** (el relevo primero, git al final). Trabajando el atlas del ritual (sesión 2026-07-17), el cliente cuestionó ese orden con lógica de **onboarding humano**: cada sesión abre como una **mente nueva** —la tesis del propio método— así que se orienta como se onboardea a un colega, y **git va primero** porque es el **filtro de frescura**: nada de lo que se lea sirve si el repo ya no está donde el documento cree.

Evidencia en vivo: esa misma sesión abrió con un HANDOFF que juraba "3 cambios sin commitear" mientras git mostraba que ya estaban en `main` (#102). Leer git primero convierte esa contradicción en la **lupa** con la que se lee el relevo, en vez de un dato enterrado al final.

**Se reafirma la inyección (no se revierte 0034):** todo sigue entrando con `@`/`!` — un puntero sigue siendo esperanza. Solo cambia el **orden** y se agrega el **principio de frescura**:

1. **git** — la frescura, la lupa de todo lo demás (si el HANDOFF contradice a git, **git gana**).
2. **qué** — `PRODUCT_BRIEF.md`.
3. **cómo** — `CONTRIBUTING.md` (cómo se trabaja) + `infra.md` (la infraestructura).
4. **dónde** — `HANDOFF.md` (dónde se quedó la última sesión) + el plan del día.

Tocado: `.claude/commands/jidoka/arranca.md` §1 (encabezado + orden de los bloques) y su espejo en el atlas (`docs/atlas/10-ritual/10-arranca-con-subprocesos.bpmn`: `documentation` + nodo `T_Leer`, re-renderizado). El diagrama de referencia `arranca-propuesta-usuario.bpmn` —un boceto alterno que proponía lectura perezosa "solo lo activado", **contrario** a la inyección de 0034— se **borró** para no dejar ruido de una ruta no tomada.

---

> Reglas del registro: una decisión = un archivo · al agregarlo, **listalo en el [índice](README.md) en el mismo commit** (el gate lo exige) · nunca borres una decisión: márcala *reemplazada* y enlaza la nueva.
