# 0043 — La linterna del gobierno: una vista de solo lectura, no un gate

- **Estado:** aceptado
- **Fecha:** 2026-07-19
- **Sprint:** La linterna del gobierno (`docs/sprints/sprint-17-linterna-gobierno-plan.md`)

## Contexto

El cliente entra a proyectos avanzados, les mete Jidoka, y conforme crecen su Claude Code se
pone necio ("documentos sin trackear", "blast-radius", los hooks). El parche de hoy era pedirle
al agente que lo arreglara — pero *"no sé qué hace, no le puedo seguir el ritmo, miles de cambios,
horas revisando, y sigue siendo **juez y parte** porque él me explica"*. La única linterna para
entender el grafo de gobierno era la narración del propio agente. Y el dolor de fondo, con sus
palabras: *"el proyecto ya trae una barrera de entrada bien grande porque ya no es solo instalo y
ya, y como el mismo Jidoka predica no puedes confiarle todo a la IA"*.

El grafo del gobierno **ya existía disperso y en texto**: `blast-radius.json` (áreas, aristas
`doc_bloquea`/`doc_avisa`/`product_avisa`), `rutear.ps1` (área→gate, vivo/dormido), `estado-docs.ps1`
(conformidad capa-2), `auditar.ps1` (grafo de capacidades), `settings.json` (hooks), `andon.yml`
(checks de CI). Nadie lo renderizaba junto, y sobre todo: nadie mostraba **qué archivos no cubre
ninguna capa** — los huérfanos, el "candy.md" que el agente suelta y queda sin gobernar.

## Decisión

Se construye `tools/estado-gobierno.ps1` (familia `estado-*`, PS 5.1 ASCII, se siembra como
`clase: mecanica`): una **vista de solo lectura** que **deriva** el grafo del gobierno de las
fuentes que ya gatean y lo emite a un **`.html` autocontenido** (grafo force-directed en JS vanilla
inline; cero dependencias, cero servidor, cero Chromium) que se abre con doble clic. Muestra áreas,
gates (vivo/dormido), documentos-dueño con aristas **duras** (`doc_bloquea`) vs **blandas**
(`doc_avisa`), capacidades y sus wikilinks, hooks, checks de CI, y los **huérfanos en rojo** con
su contador (la métrica: cero huérfanos en un repo brownfield).

Tres invariantes de diseño:

1. **No inventa verdad.** Cada nodo y arista se deriva de la ley real; el matcher de globs, la regla
   vivo/dormido de los gates y la normalización de secciones son **copias byte-fieles** de
   `verificar.ps1` / `rutear.ps1` / `estado-docs.ps1` (verificado en code-review). Lee de la misma
   fuente que gatea, o mentiría.
2. **Falla cerrado.** Si no puede enumerar los archivos (repo no-git), sale con error — no pinta un
   "cero huérfanos" con cero archivos (la mentira verde que esta vista existe para matar).
3. **Es vista, NO gate.** No bloquea nada, nadie la llama para que un gate decida.

## Por qué

- El grafo del gobierno ya existía disperso en texto, pero nadie lo renderizaba junto ni mostraba los huérfanos: la única linterna era la narración del propio agente (juez y parte).
- Una vista que deriva de las mismas fuentes que gatean no puede mentir por construcción; una que las reinterpreta o resume crearía un segundo oráculo.
- Falla cerrado: un "cero huérfanos" con cero archivos enumerados es la mentira verde que esta herramienta existe para matar.

## El camino que NO se toma

- **Una UI/servidor/MCP como capa de gobierno** — lo prohíbe [ADR 0002](0002-motor-andon.md) (y su
  ancestro doctrinal [ADR 0053](0053-sin-api-propia-como-gobierno.md)): una API que la IA llama voluntariamente tiene el
  mismo modo de falla que las memorias (depende de cooperación → no es muro). Una vista estática que
  nadie invoca para decidir **no** es capa de gobierno; es un reporte, como `estado-docs.ps1` o los
  SVG del atlas. La restricción se respeta mientras no haya servidor/servicio del que dependa un gate.
- **Cablearla a Andon (que gatee los huérfanos)** — se difiere por **regla 2-3**: nace como aviso/vista
  (igual que el atlas en [ADR 0035](0035-atlas-de-procesos-bpmn.md) y que `estado-*`), y se ganará un
  gate solo si el uso lo pide. Convertir "hay un huérfano" en bloqueo hoy sería método-ficción.
- **Un generador en Node** (como el toolchain del atlas) — Node en este repo es Jidoka-only y no entra
  al manifiesto; como la linterna **debe sembrarse a los hijos**, va en PS 5.1 ASCII. Emitir HTML-string
  desde PS no arrastra dependencias (a diferencia del atlas, que necesita Chromium para rasterizar BPMN).
- **Edición desde la UI** (mapear arrastrando, escribir el JSON) — diferida al horizonte: solo si la
  vista prueba valor primero; tocaría ADR 0002 de frente y **subiría** la barrera de entrada que este
  proyecto busca **bajar**.

## Consecuencias

- El humano ve el gobierno **con sus ojos**, sin el agente como narrador — le devuelve el juicio
  (Gemba) y baja la barrera de entrada de Jidoka sin traicionar "no confíes todo a la IA".
- Prueba de vida: `tools/probar-linterna.ps1` (fixture git ROJO→VERDE, regresiones de inyección /
  falla-cerrado / rutas con acento, y `node --check` del JS embebido si hay node). En el preflight
  de `publicar.ps1` y en el CI.
- **Follow-up (deuda registrada):** la regla vivo/dormido y el grafo de capacidades hoy se **replican**
  en `estado-gobierno.ps1` (fieles, verificado). La consolidación en una fuente única (`rutear.ps1 -Json`,
  `auditar.ps1 -Grafo`) queda como refactor por regla 2-3 — la duplicación no causa bug hoy, pero es
  dos lugares que mantener si la regla cambia.
