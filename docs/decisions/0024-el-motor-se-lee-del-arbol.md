---
tipo: decision
---
# ADR 0024 — El motor se lee del árbol (no "solo en kit/"): se cierra la decisión abierta del ADR 0003

- **Estado:** aceptado
- **Fecha:** 2026-07-11

## Contexto

El [ADR 0003](0003-auditoria-del-motor.md) dejó una **decisión abierta para el Sprint 3**: *"Hoy `tools/` es la
copia maestra provisional del motor y `kit/` solo trae los disparos. Dos copias de una ley driftean: en Sprint 3
el motor debe vivir **solo en `kit/`** y este repo instalarse su propio kit. El dogfood completo."* Quedó como
el último pendiente de la Fase 3.C. Con Jidoka ya en `v1.8.0` y el instalador maduro, toca resolverla — y al
analizarla contra el artefacto real, la premisa **ya no se sostiene**.

**Verificado (2026-07-11):** hoy **NO hay dos copias**. El motor vive **solo en el árbol raíz** (`tools/*.ps1`,
`.claude/`, `doctrina/`, `kanban/`, `andon/`, `docs/guias/`) y el manifiesto (`kit/.jidoka/instalar/
manifiesto.json`) apunta su `origen` a ese árbol; el instalador lo lee de ahí directo (Fase 3.A). `kit/` solo
trae **plantillas de instancia**: las leyes por arquetipo (`kit/.jidoka/leyes/`), la librería de templates, los
disparos y los `qa_runs`. Una sola fuente de verdad del motor: el árbol.

## Decisión

**Se mantiene el modelo "leer del árbol". El árbol raíz es la copia maestra única del motor; no se migra a
`kit/` ni Jidoka se auto-instala.** La decisión abierta del ADR 0003 se cierra como *resuelta: no se hace*.

## Por qué

- **No hay duplicación que eliminar; migrar la crearía.** El razonamiento del ADR 0003 ("dos copias driftean")
  aplicaría si `kit/` tuviera una segunda copia del motor — pero no la tiene. Mover el motor a `kit/` y que
  Jidoka se instale a sí mismo produciría **dos copias git-trackeadas** (la fuente en `kit/` + la instalada en
  la raíz) → *más* drift, no menos. Se invertiría el objetivo.
- **Los docs son contenido, no solo semilla.** `doctrina/`, `kanban/`, `andon/`, los comandos y skills son el
  **contenido propio** de Jidoka (viven en la raíz, versionados) *y* la fuente de siembra. No pueden "vivir
  solo en `kit/`" sin duplicarse en la raíz. Para ellos, leer-del-árbol es la única forma sin duplicación.
- **El dogfood ya está cubierto.** El único beneficio real del auto-install (que un bug del instalador se cace
  porque Jidoka es su propio hijo) lo da ya `probar-instalador.ps1`: instala en un repo temporal y corre los
  **self-tests sembrados** ahí (`probar-gate`/`hooks`/`auditor`/`disparos`), más el chequeo de enlaces y el
  caso EOL. Si el instalador siembra un motor roto, se caza — sin la cirugía.

## El camino que NO se toma (y por qué tienta)

**El auto-install completo (motor solo en `kit/`, Jidoka como primera instalación de su propio instalador).**
Tienta por pureza conceptual: "el repo de la metodología es un hijo de su propio kit" suena elegante y cierra
un círculo. Se descarta porque el atractivo es **estético, no técnico**: paga con duplicación real (la que
decía evitar), complejidad de arranque (chicken-and-egg: `instalar.ps1` tendría que vivir en `kit/` y correrse
desde ahí para generar el propio `tools/`), y alto blast-radius (toca la pieza de la que dependen todos los
gates) — a cambio de una cobertura de dogfood que `probar-instalador` ya entrega. La elegancia no vale el costo.

## Consecuencias

- **Cierra el último pendiente de la Fase 3.C** (Sprint 3) y la única "decisión abierta" del ADR 0003. El
  modelo leer-del-árbol pasa de *provisional* a **decisión deliberada**, con su porqué.
- `kit/` queda confirmado como el hogar de las **plantillas de instancia** (leyes, templates, disparos,
  qa_runs), no del motor. (Nota de higiene: hay dirs vacíos residuales `kit/.claude/`, `kit/.githooks/`,
  `kit/.github/` de un intento viejo; git no trackea dirs vacíos, así que no son deuda — se ignoran.)
- No hay cambio de código: el diseño ya era este. Lo que cambia es que **ahora está decidido**, no pendiente.
  Versión `v1.8.1`.
