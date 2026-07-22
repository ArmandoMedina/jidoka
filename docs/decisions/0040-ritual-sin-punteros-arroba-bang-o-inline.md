# ADR 0040 — En el ritual todo es `@`, `!` o inline — nunca un puntero

- **Estado:** aceptado
- **Fecha:** 2026-07-17
- **Extiende:** [ADR 0034](0034-arranca-inyecta-no-encarga.md) (de la §1 del arranca al ritual completo)

## Contexto

Refinando el `arranca` y el `planea` (2026-07-17), el cliente cazó que los comandos del ritual
mezclaban mecanismos de contenido con **garantías distintas**: inyecciones `@` (el contenido llega
al contexto, garantizado), ejecuciones `!` (corren al cargar, garantizado), texto inline (es el
prompt mismo, garantizado) — y **punteros de lectura** tipo *"(detalle en `kanban/roles.md`)"*,
que a veces el agente sigue y a veces no. Su regla textual: *"prefiero tener seguridad y saber si
lo va a hacer o no; entre tenerlo como puntero o no tenerlo, prefiero no tenerlo."*

Además, la §3 del arranca cargaba una **copia en prosa** de los asientos-subagente que ya vivían
en `.claude/agents/` (el artefacto con dientes) y en la tabla de `kanban/roles.md` — tres copias
del mismo hecho, drift garantizado el día que una cambie.

## Decisión

1. **Todo contenido que un comando del ritual necesite es `@` (inyección), `!` (ejecución) o
   inline (el prompt mismo)** — mecanismos garantizados. Los punteros de lectura ("ver X",
   "detalle en Y") **se prohíben en los comandos**: entre puntero y nada, nada.
2. **Cuando el contenido vive en un artefacto con dientes** (el frontmatter de los agentes, la
   ley), **no se copia en prosa: se imprime del artefacto con un `!`** — el patrón gemelo
   `rutear.ps1` / `asientos.ps1`. Determinista, e imposible que derive.
3. **La exploración dirigida sigue siendo legítima cuando leer ES el trabajo del comando**
   (ej. las capacidades de `product/` en el R0 del planea: su subconjunto relevante depende
   del sprint). El criterio que separa: **relevo-de-estado → `@`** ·
   **trabajo-de-análisis → instrucción de explorar**. La frecuencia modula: un comando que
   corre una vez por sprint (planea) tolera inyecciones más gordas (ROADMAP) que uno que
   corre en cada sesión (arranca).

## Por qué

- **Un puntero es una esperanza** — la misma razón de ADR 0034, extendida de la §1 del arranca
  al ritual entero: su cumplimiento es probabilístico, y el cliente dirige sin leer el código;
  necesita saber **qué va a pasar**, no "a veces".
- **Una copia inline de un artefacto deriva en silencio** — pasó: tres copias de los asientos.
  El `!` que imprime del artefacto cierra el drift por construcción, no por disciplina.

## El camino que NO se toma (y por qué tienta)

- **(a) Volver a poner punteros "para acortar el comando".** Tienta porque es barato y parece
  DRY. Se rechaza porque su cumplimiento es probabilístico — el muro que en realidad es
  sugerencia, justo lo que Jidoka existe para matar.
- **(b) Inyectar TODO con `@` en los comandos de cada sesión** (p. ej. `roles.md` completo en
  cada arranca para ahorrarse 5 líneas inline, o el grafo entero de capacidades). Tienta porque
  parece "más determinista". Se rechaza porque el bloat degrada el razonamiento y **entierra
  las reglas importantes** (evidencia revisada en sesión: la degradación empieza ~3000 tokens;
  una regla enterrada en un prompt largo puede no seguirse). El knob es la frecuencia del
  comando, no el tamaño del archivo por sí solo.

## Consecuencias

- `arranca.md` y `planea.md` ya cumplen (punteros fuera; brief inyectado; casting impreso del
  artefacto vía `tools/asientos.ps1`). Los demás comandos `/jidoka:*` **se alinean al tocarlos**
  — no big-bang.
- El patrón "imprime del artefacto" queda disponible como gemelos `rutear`/`asientos` para
  cualquier contenido futuro con dientes.
- Costo aceptado: los comandos pierden las citas de cortesía a la doctrina. La doctrina se
  enseña en sus **vistas** (atlas, `kanban/`), no en el ejecutable — coherente con ADR 0039.
