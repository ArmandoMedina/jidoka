# ADR 0009 — Los arquetipos ejecutables (matriz-como-manifiesto) y la poda a dos

- **Estado:** aceptado (tomada bajo delegación del cliente · **revisable**)
- **Fecha:** 2026-07-10
- **Sprint:** 3 · Fase 3.B

<!-- El cliente delegó explícitamente esta decisión ("creo que tú tomarás una mejor decisión")
     al preguntar si había riesgo de sobreingeniería. Se declara revisable: el cliente puede
     ampliarla o revertirla. -->

## Contexto

El instalador (Fase 3.A) sembraba **un** arquetipo. La promesa del Sprint 3 es que *pregunte el arquetipo y siembre solo lo que el proyecto merece*. El `project-starter` definió 3 arquetipos (code-first · docs-as-code · doc-only, ADR 0002 del starter) y una **matriz pieza×arquetipo** — pero como **prosa**, no como config ejecutable. A media construcción, el cliente preguntó: *"¿no corremos riesgo de sobreingeniería?"* — invocando, sin nombrarla, la **regla 2–3** del propio método (*lo que no toques en 2–3 proyectos, pódalo*) y el **method-fiction** (*una estructura completa parece madura aunque nadie la haya usado*).

## Decisión

1. **La matriz vive como manifiesto ejecutable**, no como prosa: `kit/.jidoka/instalar/manifiesto.json` codifica, por arquetipo, su ley, su semilla del QUÉ (grafo de notas vs `PRODUCT_BRIEF`) y su gobernanza. El instalador la consume. *Este es el valor real de Jidoka sobre el ancestro* (el starter tenía la matriz solo en prosa).
2. **Se poda de 3 a 2 arquetipos.** Se estrenan **`docs-as-code`** (probado — es Jidoka mismo) y **`code-first`** (barato: casi la misma ley con un área `codigo`; y es el consumidor más probable, un repo de código). **`doc-only` se difiere al ROADMAP** — es el genuinamente especulativo (specs reguladas con código en otro repo; ningún proyecto real lo pide hoy). Su ley se removió: no se estrena maquinaria por especulación.
3. **Los 12 templates de producto se envían como librería "menú, no molde"** (`kit/.jidoka/templates/producto/`) — son *moldes* que se copian, no maquinaria que corre y se mantiene; el starter también los envía todos. Bajo riesgo, mientras se presenten como menú.
4. **La validación real es el USO, no más construcción.** El siguiente paso de mayor valor es instalar Jidoka en un repo vivo y dejar que el uso revele qué arquetipos/piezas faltan — se construyen cuando duela, no antes.

## Por qué

- **Podar dos veces es más barato que mantener maquinaria muerta.** Un arquetipo `doc-only` sin consumidor es un gate que nunca muerde: la propia doctrina lo condena (`andon/`, teatro de gates). Dos arquetipos ya prueban que el mecanismo "pregunta el arquetipo" funciona con variación real.
- **La distinción templates (baratos) vs runtime (caro) es la que importa.** Los moldes no driftean con el código; las leyes y ramas del instalador sí. La restricción se aplica donde cuesta.

## El camino que NO se toma (y por qué tienta)

- **"Un arquetipo nuevo que sume todo lo aprendido."** Tienta como consolidación. Se descarta: *pelea con el corazón del método* — la idea de tener arquetipos es que **un molde no le queda a todos** (menú, no molde; la disciplina escala con el riesgo). Un mega-molde es lo contrario. Y lo aprendido **ya está consolidado** en `kanban/`, `doctrina/` y los ADRs; esa es la consolidación, no un arquetipo más.
- **Construir los 3 arquetipos "por si acaso."** Tienta por completitud/paridad con el starter. Se descarta por la regla 2–3: se construye breadth cuando un 2º/3º proyecto lo demanda, no antes (evita method-fiction).
- **"Investigar más antes de decidir."** No era una brecha de información (el starter ya se exprimió) sino una decisión de *restraint*; más investigación solo la aplazaba.

## Consecuencias

- El instalador pregunta el arquetipo y siembra distinto (docs-as-code → grafo; code-first → brief), probado en el smoke (12 casos).
- `doc-only` + la matriz de piezas más fina + el CLI npm + multiplataforma quedan en el ROADMAP (Fase 3.C), a construir bajo demanda real.

## Qué NO resuelve

- **Dos arquetipos siguen siendo 0-1 consumidores reales.** Ni docs-as-code ni code-first tienen aún un repo ajeno que los use (los labs no instalan Jidoka: son sus padres). La validación de verdad sigue pendiente de una instalación en un proyecto vivo — el siguiente paso de mayor valor, por encima de más construcción.

---

> Reglas del registro: una decisión = un archivo · al agregarlo, **listalo en el [índice](README.md) en el mismo commit** (el gate lo exige) · nunca borres una decisión: márcala *reemplazada* y enlaza la nueva.
