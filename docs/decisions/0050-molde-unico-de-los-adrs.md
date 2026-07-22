# ADR 0050 — El molde único de los ADRs: un guardián residente que bloquea, no una skill personal

- **Estado:** aceptado
- **Fecha:** 2026-07-22

## Contexto

Una flota de auditoría (3 asientos, 2026-07-22) barrió los 49 ADRs y encontró el corpus **sano de vigencia y limpio mecánicamente**, pero con la **forma no uniforme**: 4 ADRs sin las secciones de valor (`Por qué`, `El camino que NO se toma`), ~9 con la sección renombrada (`Razones`, `El principio`, `Lecciones de campo`), y el 0044 con el **estado desincronizado** entre su header (`aceptado`) y el índice (`reemplazado en superficie por 0048`) — enlace unidireccional.

La causa raíz no era descuido puntual: el mecanismo que crea ADRs —la skill personal `adr-helper`— **vive fuera del repo** (`~/.claude/skills/`, máquina local del autor), **no viaja** a otro clon ni a otro agente, y **ya había divergido** del molde gobernado (escribe `## Razones` donde la plantilla del repo usa `## Por qué`, y estados femeninos). Los ADRs con "Razones" nacieron de ahí. Alinear el pasado y garantizar el futuro eran el **mismo problema**: la fuente del molde no estaba ni gobernada ni residente en el repo.

## Decisión

1. **Un molde canónico único.** `docs/decisions/0000-plantilla.md` y `kit/.jidoka/templates/adr.md` convergen a una sola estructura: las 5 secciones requeridas (`Contexto` → `Decisión` → `Por qué` → `El camino que NO se toma (y por qué tienta)` → `Consecuencias`), el enum de estado y `Qué NO resuelve` como opcional.
2. **Un guardián residente que bloquea.** `tools/probar-adrs.ps1` (sembrado, clase `mecanica`) valida, por cada `docs/decisions/NNNN-*.md`: (a) las 5 secciones canónicas; (b) que la **clase de estado** del header (`propuesta|aceptado|reemplazado|obsoleto`) coincida con la del índice; (c) que no haya huérfanos (archivo sin fila / fila sin archivo). `exit 1` ante cualquier desvío — es **MURO**, cableado en `.github/workflows/andon.yml` (CI) y en el preflight de `tools/publicar.ps1`. Trae su self-test sintético (quien valida se valida).
3. **El baseline se alinea primero.** Los 49 ADRs existentes se alinearon al molde **sin reescribir decisiones** (extracción de lo embebido, renombre de headings, enmienda fechada donde faltaba); así el muro nace verde.

## Por qué

- **"Si depende de que alguien se acuerde, no es muro"** (`doctrina/00-tesis.md`). El estado de un ADR vivía en dos fuentes de verdad —header e índice— sincronizadas a mano; el 0044 probó que se desincronizan en silencio. Un check determinista lo cierra.
- **Una skill personal no puede ser la garantía.** No viaja, otro clon/agente no la tiene, y ya divergió. La garantía tiene que vivir **en el repo** (mecánica, sembrada) y bloquear — no en una herramienta de autoría que corre en una sola máquina.
- **El muro nace verde.** Alinear el corpus antes de encender el gate hace que bloquear no cueste fatiga: el listón ya se cumple, y de ahí en adelante solo muerde lo que se desvía.

## El camino que NO se toma (y por qué tienta)

- **Solo avisar** (como `estado-docs.ps1`, ADR 0042) tienta por anti-fatiga, pero un aviso depende de que alguien lo lea — justo el fallo que Jidoka combate. El cliente eligió **bloquear todo** (2026-07-22), y el baseline verde vuelve barato ese muro.
- **Dejar `adr-helper` (la skill personal) como el mecanismo** tienta porque ya existe y funciona en esta PC, pero sería poner la disciplina en la herramienta/el modelo, no en el gate: no viaja ni se gobierna. Queda como conveniencia de autoría, reconciliada al molde; ya no es la garantía.
- **Meter el enforcement en `verificar.ps1`** (el gate de push) tienta por centralización, pero se evita a propósito: el muro de conformidad de ADRs vive como un `probar-*` en CI (igual que `probar-disparos`), para no clobbear el `verificar` customizado del hijo — el mismo principio de ADR 0042.

## Consecuencias

- **Segundo muro real del repo.** Antes solo el índice de ADRs bloqueaba (el único `doc_bloquea`); ahora un ADR fuera de molde o con estado incoherente tampoco llega a `main`.
- **Viaja a los hijos** (mecánica): la disciplina de ADR baja con la máquina. Un hijo que no la quiera customiza su `andon.yml` sembrado (no-clobber, `-Actualizar` no lo pisa).
- **El `adr-helper` personal** se reconcilia a `Por qué` como higiene local (fuera del repo); deja de ser fuente de drift.

## Qué NO resuelve

El gate mide **forma + coherencia de estado, no verdad**: un ADR con las 5 secciones pero con un `Por qué` hueco pasaría el muro. El listón de contenido lo pone el revisor humano, no el gate — el mismo límite conocido que el resto del motor confiesa (`andon/README.md`). Tampoco impone el molde a los ADRs *ya escritos* de un hijo que instale Jidoka con historia previa: el muro muerde desde que se enciende, y alinear el pasado del hijo es decisión del hijo.
