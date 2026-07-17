# ADR 0042 — Gobierno documental por estructura (capa-2): el hermano estructural del sello

- **Estado:** aceptado
- **Fecha:** 2026-07-17
- **Relacionado:** [ADR 0012](0012-lazo-sincronizacion-labs.md) (el lazo; este extiende su gobierno del motor a los documentos de instancia) · [[KIT-2-gobierno-documental]]

## Contexto

El cliente hizo análisis de flujos en un hijo (lab de rescate) y sintió que "los documentos de los hijos están super diferentes". La medición (solo-lectura) contra el artefacto real desmintió la premisa inicial y encontró la verdadera:

- Los `.md` del **ritual** (arranca/planea/cierra) **NO divergen** — son motor, gobernados por **hash** (el sello `tools/jidoka-motor.json` + `estado-motor -Detallado`). El lazo ya los cubre.
- Los documentos **instancia-de-template** que el ritual inyecta con `@` — `PRODUCT_BRIEF`, `infra`, `CONTRIBUTING` — **no** los cubre nada: el sello solo hashea el motor y las plantillas, no el doc **lleno** del hijo. Y el hash es la herramienta **equivocada** para ellos, porque su contenido varía a propósito por proyecto (un hash siempre diría "modificado").
- Donde había template (brief, infra) el hijo **conformó** (brief 14/14 secciones idénticas en orden; infra molde + 1 aditiva). Donde **no** había template (`CONTRIBUTING`, que se sembraba como stub inline de 4 líneas) cada repo inventó su estructura — tres versiones sin relación. Ese era el hueco.

El modelo mental del cliente es **SAP**: puedes configurar/llenar el sistema, pero si **alteras la estructura** gobernada, *garantía nula* — el proveedor ya no garantiza que funcione. Aplicado aquí: si el hijo destripa o reestructura `CONTRIBUTING`, la lógica que el ritual inyecta con `@CONTRIBUTING.md` opera sobre basura, y el preflight de existencia (jidoka#104) no lo caza porque el archivo **sí existe**.

## Decisión

Se añade el **hermano estructural** del sello: gobierno por **secciones**, no por bytes. Tres piezas (capacidad [[KIT-2-gobierno-documental]]):

1. **El ledger `tools/docs-gobernados.json`** (archivo nuevo, autoral, sembrado como motor y hasheado). Declara la taxonomía de tres capas y, para cada doc **capa-2**, su molde y su lista **congelada** de secciones `requeridas`. Capa-1 = motor (hash, ya existe); capa-2 = instancia-de-template (secciones); capa-3 = libre (`CODE_OF_CONDUCT`, `LICENSE` — fuera del blast-radius, declarado para dejar constancia de que **no** se gobierna).
2. **El detector `tools/estado-docs.ps1`** (hermano de `estado-motor.ps1`). Para cada doc capa-2 presente, verifica que sus encabezados `##` contengan las requeridas (match por prefijo normalizado con fold de acentos). Faltante → **DESVIADO** (*garantía nula*), aditiva → OK, reordenada → no bloquea. **Aviso** por defecto (exit 0), surtido en `/jidoka:arranca`.
3. **El template real de `CONTRIBUTING`** (`kit/.jidoka/templates/CONTRIBUTING.md`) + su stub estructurado en el manifiesto — cierra el hueco que originó todo.

### Las tres decisiones de arquitectura (validadas con el asiento arquitecto)

- **(dec. 2) El ledger es archivo propio**, no un campo del sello (que es *generado* por el instalador, no editable a mano) ni derivado del manifiesto (que no se siembra al hijo). Es una constante del método, autoral y versionada.
- **(dec. 3) La ejecución es aviso por defecto; el muro es opt-in y nace apagado.** El `-Estricto` bloquea (exit 1) **solo** si un doc marcado `estricto:true` pierde una requerida, y se cablea en el **required-check de CI** (`andon.yml`), **nunca** en `verificar.ps1` (no clobbear el verificar customizado del hijo). El "no se pueda" del cliente llega como **palanca que él enciende** flipando el flag en su ledger, no como muro impuesto.
- **(dec. 5) El detector gobierna solo los 3 singletons inyectados.** El grafo de producto (`capacidades/`, `procesos/`, `dominios/`) **se queda con `auditar.ps1`**, que ya gobierna su estructura (frontmatter, links, Gherkin) con regla risk-scaled — y cuyas plantillas se auto-declaran de secciones opcionales. Doble-gobernarlo inundaría de falsos positivos.

## Razones

- **El hash no sirve para lo que varía a propósito.** El motor debe ser idéntico byte a byte (hash); el doc de instancia debe variar en contenido pero no en estructura (secciones). Dos herramientas para dos regímenes.
- **Congelar el contrato en el ledger, no leerlo del template vivo.** Si el detector derivara las requeridas de los `##` del molde, el día que un template gane una sección **todos los hijos** quedarían DESVIADO de golpe en la próxima `-Actualizar` (el molde converge como motor; la instancia no). El ledger congela un contrato mínimo; el template crece libre y sus secciones nuevas entran como opcionales.
- **El único muro real es el required check server-side** (doctrina del único-muro): por eso el estricto va a CI y no a un Stop hook (bypaseable) ni al `verificar` del hijo (clobber).

## El camino que NO se toma (y por qué tienta)

- **(a) Forzar los docs de instancia como motor (que `-Actualizar` los pise).** Tienta porque garantiza conformidad. Se rechaza: viola la regla dura de KIT-1 (la instancia nunca se sobrescribe) y borraría el contenido propio del hijo. El detector **declara**, no muta.
- **(b) Meter las requeridas en el template vivo y leerlas de ahí.** Tienta por DRY. Se rechaza por el versionado-de-molde: acopla cada edición de template al pass/fail de todos los hijos.
- **(c) Cablear el estricto en `verificar.ps1`.** Tienta porque es el gate de push local. Se rechaza: clobbea el `verificar` customizado del hijo (p.ej. SGI con ruff/pytest). `andon.yml` y `pre-push` convergen por `-Actualizar` sin tocar la costura `.local`.
- **(d) Gobernar también el grafo de producto.** Tienta por completitud. Se rechaza: `auditar.ps1` ya lo hace, y sus moldes se auto-declaran risk-scaled — un detector paralelo con "todas las secciones en orden" entrenaría el click-para-ignorar (`doctrina/04`).
- **(e) Encender el muro estricto por defecto.** Tienta porque el cliente pidió "no se pueda". Se rechaza: una sola edición de molde podría brickear el CI de todos los hijos a la vez. El "no se pueda" se honra dándole la palanca, no encendiéndola.

## Consecuencias

- El `arranca` gana un surtido de conformidad estructural en §1b (aviso, classifier-safe con el idioma `test -f X && powershell -File ... || echo`, ya probado en producción en la guardia del plan-de-trabajo).
- `CONTRIBUTING` deja de ser un stub de 4 líneas: gana template real y stub estructurado; un hijo nuevo nace CONFORME.
- El motor gana `tools/estado-docs.ps1`, `tools/docs-gobernados.json`, `tools/probar-docs.ps1` (sembrados; el test corre en el smoke local y en CI). `probar-publicar` los exige en el preflight (invariante existente).
- Los hijos existentes con un `CONTRIBUTING` viejo o reestructurado verán un **aviso** (no un muro) al abrir sesión — el nudge honesto que el cliente buscaba. Encienden el muro cuando quieran, por doc, en su ledger.
- Límite v0 aceptado (grieta #3): el detector mide **presencia** de secciones, no su **contenido** — la verdad del contenido la pone el humano.
