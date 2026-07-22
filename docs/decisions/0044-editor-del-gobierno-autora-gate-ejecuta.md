# 0044 — El editor del gobierno: la extensión AUTORA, el gate EJECUTA

- **Estado:** reemplazado (en la superficie) por [ADR 0048](0048-superficie-app-tuberia.md) — el principio "la UI autora, el gate ejecuta" sigue vigente
- **Fecha:** 2026-07-20
- **Sprint:** El editor del gobierno, parte 2 (`docs/sprints/sprint-editor-gobierno-2-plan.md`; R1 en `sprint-editor-gobierno-plan.md`)

## Contexto

La linterna (ADR 0043) le devolvió los ojos al cliente, y con los ojos llegaron dos hallazgos
sobre el caso real (entisoft): **el grafo se satura** (132 objetos) y **el gobierno es demasiado
grueso** — el área `codigo` avisa sobre *las 89 capacidades* sin decir cuál. Las palabras del
cliente fijaron el QUÉ: *"yo poder decir: este archivo son estas 5 capacidades, y poder decir que
el trigger es el cambio de código... o al revés, o en ambas direcciones"* — y la herramienta que
se lo permita a ÉL, no una IA que adivine qué ligar con qué.

El ADR 0043 había diferido "edición desde la UI" al horizonte. El horizonte llegó: la vista probó
valor (Gemba GO del F5, 2026-07-20) y el cliente pidió la autoría.

## Decisión

**La extensión AUTORA; el gate EJECUTA.** Tres piezas con fronteras nítidas:

1. **El ledger `tools/ligas.json`** — declaraciones del cliente: `{ id, codigo[], capacidades[],
   direccion (codigo-a-capacidad | capacidad-a-codigo | ambas), fuerza (avisa | bloquea) }`.
   Es **dato de instancia**: NO se siembra (sembrarlo como mecánica haría que `-Actualizar`
   pisara las declaraciones del hijo — el contraste deliberado con `docs-gobernados.json`).
2. **El evaluador `tools/estado-ligas.ps1`** (mecánica, se siembra) — mide co-ocurrencia sobre el
   rango git con el matcher byte-fiel de `verificar.ps1`. `[BLOQUEA]` se imprime siempre; solo
   `-Estricto` (pre-push, CI) lo vuelve exit 1. Ligas **rotas** avisan y quedan excluidas — un
   medidor con metadatos podridos no emite veredicto. Falla cerrado (exit 2) ante ledger ilegible.
   En CI, evaluador **y** ledger se leen **desde la base** (ADR 0003): un PR no puede desactivar
   la liga que lo juzga; las ligas que un PR estrena juzgan al siguiente.
3. **La extensión de VS Code** (`extension/`, JS plano, Jidoka-only) — clic derecho → *"Jidoka:
   ligar a capacidad..."* → QuickPicks (capacidades, dirección, fuerza) → `ligas.js` escribe el
   ledger. La UI **nunca** es el muro: escribe archivos que git versiona y los gates deterministas
   leen. ADR 0002 queda intacto — no hay servidor, ni API, ni nada que un gate invoque; el punto
   de control sigue fuera del LLM y fuera de la UI.

El contrato entre stacks (JS escribe, PS lee) es UTF-8 **sin BOM** + newline final, y lo vigila
un caso de `probar-ligas.ps1` que escribe con `node -e` y evalúa con el `.ps1`.

## Por qué

- La linterna devolvió los ojos al cliente, y con ellos dos hallazgos medidos: el grafo se satura (132 objetos) y el aviso del gobierno es grueso (avisa sobre las 89 capacidades sin nombrar cuál).
- El juicio de qué ligar con qué es del humano, no de la IA: la herramienta deja que el cliente declare las ligas, no las adivina.
- Concreta el principio ya establecido "la UI autora, el gate ejecuta" (ADR 0002) al grafo de ligas: clic entonces JSON en git entonces gate determinista; nada depende del modelo.

## El camino que NO se toma

- **Marketplace / sembrar la extensión** — regla 2-3, como el atlas. La **mecánica** (evaluador +
  test) sí baja a los hijos; el `.vsix` se instala a mano (guía en `extension/README.md`). El
  invariante lo vigila `probar-extension.ps1` (falla si `extension/` entra al manifiesto).
- **Que la herramienta sugiera qué ligar** — el juicio es del humano (decisión del cliente en el
  descubrimiento: *"eso lo vas a tener que saber tú"*). La UI lista, el cliente decide.
- **Que el gate juzgue contenido** — sigue midiendo co-ocurrencia (límite conocido, grieta #3).
- **Tocar `verificar.ps1`** — los hijos lo customizan; `estado-ligas` es pieza aparte, como
  `estado-docs` (ADR 0042).

## Consecuencias

- La métrica del QUÉ se cumple: el aviso pasa de "las 89 capacidades" a **la capacidad exacta**
  (el dogfood mordió en este mismo sprint: la liga `linterna-extension` acusó `extension/*` sin
  `AND-1-muro-andon.md`, nombrándola).
- Primer gate cuya ley la autora el cliente desde una UI. La cadena completa: **clic → JSON en
  git → pre-push/CI**. Nada en ella depende de la cooperación del modelo.
- Prueba de vida: `probar-ligas.ps1` (26 casos, incl. contrato entre stacks y rango real con
  `-Base`), `probar-extension.ps1` (contrato manifiesto↔código + `node --test`), casos de ligas
  en `probar-linterna.ps1` (el grafo las pinta; rotas en rojo).
- **Ventana fundacional conocida:** el PR que estrena el gate corre el evaluador del PR (la base
  aún no lo trae) — la misma ventana que tuvo el andon original; se cierra sola al mergear.
