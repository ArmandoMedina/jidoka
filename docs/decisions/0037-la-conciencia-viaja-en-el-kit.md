# ADR 0035 — La conciencia viaja en el kit: los agentes se siembran, `-Actualizar` migra la instancia que el motor asume, y el roster vive donde se inyecta

- **Estado:** aceptado
- **Fecha:** 2026-07-16

## Contexto

La primera bajada real de `v1.16.x` a un hijo instalado (caso 1, 1.13.0 → 1.16.1) pagó lo que el issue #82 había predicho un día antes: la capa de conciencia de `v1.16.0` (ADRs 0033/0034) quedó instalada **solo en la nave nodriza**. El `arranca` sembrado inyectaba `@product/PRODUCT_BRIEF.md`, `@product/infra.md` y `@CONTRIBUTING.md` que ningún arquetipo sembraba completos (el brief vivía en la **raíz** y solo para `code-first`); instruía delegar a agentes de `.claude/agents/` que el manifiesto no entregaba; y el casting quedó en `recursos-del-proyecto.md`, un archivo que el `arranca` ya no lee. Además `-Actualizar` re-sembraba la mecánica **sin** la instancia que esa mecánica nueva asume (issues #86/#87). Sobre la mesa estaban la cura A (el `arranca` degrada con gracia) y la B (el kit siembra la conciencia completa).

## Decisión

Cura **B completa** (decisión del cliente, 2026-07-16), en cuatro piezas:

1. **Los agentes-asiento viajan en el kit**: `.claude/agents/` (los 4 asientos tiereados del ADR 0033) y su lint `tools/probar-agentes.ps1` entran al manifiesto como `clase: mecanica`; las leyes-plantilla de ambos arquetipos ganan `.claude/agents/*` en el área `ritual`. El `arranca` conserva una línea de degradación honesta por si un hijo los excluye.
2. **La instancia que el `arranca` inyecta es stub común**: `product/PRODUCT_BRIEF.md` (con frontmatter, enlazado a `[[infra]]`), `product/infra.md` y un `CONTRIBUTING.md` mínimo se siembran para **todo** arquetipo, no-clobber. El stub del brief en la raíz (solo `code-first`) se retira.
3. **`-Actualizar` es consciente de migraciones**: los stubs del manifiesto que el hijo no tiene se siembran en la misma pasada (`[MIGRA]`, no-clobber estricto); lo condicionado a arquetipo solo se decide si el sello lo registra — el sello gana `producto`/`gobernanza` desde esta versión; con sello viejo se avisa, no se adivina. La doctrina de stubs pasa de "nunca se actualiza" a "**no-clobber siempre**; se siembra solo lo que falte".
4. **La casa única del roster es `product/infra.md`** (*se inyecta donde vive*): la sección `## El casting` migra a la plantilla `infra.md`; `recursos-del-proyecto.md` se retira del kit (este ADR lo documenta); los hijos viejos migran la sección a mano (receta en el `arranca` §2).

## Por qué

- **Nada de conciencia depende de la iniciativa del agente** (principio de la cosecha #5, ADR 0029): un `arranca` que inyecta archivos inexistentes no es conciencia instalada, es un `@` roto — y un kit que instruye delegar a asientos que no entrega es prosa sin maquinaria.
- **La regla 2-3 ya estaba pagada**: no es método-ficción — el caso 1 pagó el costo hoy, y los siguientes consumidores (bajada a labs, piloto #70) tropezarían exactamente ahí.
- **La migración decidible sin adivinar**: mover brief/infra/CONTRIBUTING a stubs comunes hace la migración de `-Actualizar` 100 % decidible para lo común; el `producto` en el sello vuelve decidible lo condicionado — y lo indecidible se **avisa** en vez de adivinarse (fallar informando, no improvisar).

## El camino que NO se toma (y por qué tienta)

- **Cura A (solo degradación con gracia)**: mínima y sin agrandar la siembra — pero deja "conciencia instalada" como promesa exclusiva de la nave: cada hijo fresco recibiría instrucciones a medias, para siempre. Se conserva solo su parte barata (la línea de degradación del §3).
- **Inferir el arquetipo de un sello viejo** (¿existe `product/README.md`? → grafo): tienta porque automatiza la migración completa, pero un hijo `code-first` sin grafo es **correcto**, no incompleto — la inferencia produciría falsos `[MIGRA]`. Un aviso honesto cuesta una línea; una adivinanza equivocada siembra basura en el repo del hijo.
- **Roster en su archivo propio** (`recursos-del-proyecto.md`): mantenerlo evitaba tocar plantillas, pero perpetuaba la contradicción — el `arranca` inyecta `infra.md` y el casting vivía en otro lado: un puntero es una esperanza, un `@` es un hecho (ADR 0034).

## Consecuencias

- La siembra crece (~4 agentes + 1 lint + 3 stubs): más superficie del kit, vigilada por `probar-instalador`/`probar-sembrar` (67/36 checks).
- Los hijos existentes convergen vía `-Actualizar` con `[MIGRA]` para lo común; el casting y los stubs por-arquetipo de hijos pre-1.17 requieren un paso manual avisado (una vez).
- `sembrar-manual.ps1` gana las mismas ramas (migración + sello con arquetipo): su restricción de **magrez AV** (ADR 0027) obliga a re-probar contra el AV real en la próxima ventana de campo — deuda anotada.

## Qué NO resuelve

- La validación de nombres de `tools:` en `probar-agentes` (un typo `Gerp` pasa) — vivo en #82.
- El `stubs_arquetipo.gobernanza` referenciado por el código no existe aún en el manifiesto (regla 2-3: se construye cuando un arquetipo con gobernanza lo pida).
- La bajada efectiva a los labs y la re-prueba AV de `sembrar-manual` — ventana de campo aparte.
