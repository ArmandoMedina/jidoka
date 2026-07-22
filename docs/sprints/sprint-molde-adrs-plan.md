# Plan de sprint — El molde único de los ADRs (pasado alineado, futuro garantizado)

> Contrato del sprint (aprobado en plan mode, 2026-07-22). Rama: `review/adrs-20260722` (worktree aislado `../jidoka-adrs`).
> Apetito: la revisión del cliente; muerte por defecto. El QUÉ lo aprobó el cliente con el
> enfoque "campo completo y alinea de una vez la plantilla para que siempre salgan con el mismo
> formato los siguientes" + la decisión de gate **bloquea todo**.

## Contexto (por qué ahora)

La flota de auditoría (3 asientos, 2026-07-22) barrió los 49 ADRs y encontró un corpus **sano de vigencia y limpio mecánicamente**, pero con la **forma no uniforme** y —lo más grave— **sin nada que garantice que el próximo ADR salga bien**:

- **4 ADRs** sin las secciones de valor (`Por qué`, `El camino que NO se toma`): 0001, 0002, 0003 (excusa pre-plantilla) y **0028** (sin excusa, corpus maduro).
- **~9 ADRs** con la sección renombrada (`Razones`, `El principio`, `Lecciones de campo`) — el scan mecánico manda sobre la lista de la flota: 0004, 0005, 0027, 0033, 0040, 0042, 0043, 0044 (el auditor omitió 0004; el scan lo caza).
- **0044** con el estado desincronizado: header dice `aceptado`, el índice dice `reemplazado en superficie por 0048` (enlace unidireccional). Confirmado por 2 auditores + el guardián.
- Staleness puntual: 0001 (`npx jidoka init`→`jidoka-method`), 0002 (`aún no hay grafo`, ya lo hay).

**Causa raíz (hallazgo del sprint):** el mecanismo que crea ADRs —la skill personal `adr-helper`— **vive fuera del repo** (`~/.claude/skills/`, no viaja, otro clon/agente no la tiene) y **ya divergió de la plantilla gobernada**: escribe `## Razones` donde el repo usa `## Por qué`, y estados femeninos (`Aceptada`). Los ADRs con "Razones" nacieron de ahí. Alinear el pasado (Mitad A) y garantizar el futuro (Mitad B) son **el mismo problema**: la fuente del molde no está gobernada ni residente.

**Resultado buscado:** los ADRs salen y se mantienen con un molde único; el mecanismo que lo garantiza **vive en el repo y viaja**, y bloquea el merge si un ADR se desvía del formato o su estado no cuadra con el índice.

## Encuadre de producto

Refuerza dos capacidades ancla del brief: *"la memoria vive en artefactos… los ADRs con el camino que NO se tomó"* y el muro Andon (**[[AND-1-muro-andon]]**) — el guardián es un check determinista **fuera del LLM**, coherente con la tesis (`doctrina/00-tesis.md`: *"si depende de que alguien se acuerde, no es muro"*). No estrena un QUÉ nuevo; es **hardening del corpus de decisiones + su mecanismo de autoría**.

## Decisiones del cliente (2026-07-22)

1. **Enfoque:** campo completo → los fundacionales 0001-0003 **entran** a la alineación.
2. **Fuerza del gate: BLOQUEA TODO.** `probar-adrs.ps1` tumba el merge (exit 1 en CI) si un ADR se desvía del molde **o** su estado no cuadra con el índice. Segundo muro real del repo. Nace verde porque el sprint alinea el baseline primero.
3. **Principio del CÓMO (no se reescriben decisiones):** contenido embebido → se extrae/renombra; falta → **enmienda fechada**; staleness → **nota de enmienda**; nunca borrado. El texto original de cada decisión queda intacto.
4. La decisión (molde único + muro) se asienta en un **ADR nuevo (0050)**, escrito bajo el molde nuevo (dogfood).

## El molde canónico (la fuente única)

Las 5 secciones **requeridas** (orden fijo) + frontmatter inline:
`- **Estado:**` (`propuesta | aceptado | aceptado (… · revisable) | reemplazado por [NNNN]`) · `- **Fecha:**` → `## Contexto` → `## Decisión` → `## Por qué` → `## El camino que NO se toma (y por qué tienta)` → `## Consecuencias`.
`## Qué NO resuelve` queda **opcional**. El molde rico de `kit/.jidoka/templates/adr.md` es la fuente; `0000-plantilla.md` converge a él.

## Alcance en rebanadas verticales

### M1 — La fuente y el guardián

**R1 · Molde canónico único** *(áreas `decisiones` + `kit`)* — reconciliar `0000-plantilla.md` ↔ `kit/.jidoka/templates/adr.md` a una sola estructura. **Prueba:** diff; ambos moldes con las mismas secciones requeridas; a ojo. **[HECHO]**

**R2 · El guardián `tools/probar-adrs.ps1`** *(`barreras`/tools + `kit`)* — lint estilo `probar-disparos.ps1`: (a) 5 secciones canónicas, (b) `Estado:` del header coincide con la columna del índice, (c) sin huérfanos. `exit 1` = **MURO**. Self-test con fixture. Cablear en `andon.yml` + `publicar.ps1`; registrar en `manifiesto.json` clase `mecanica` + re-sellar. **Prueba:** self-test verde; corpus HOY rojo (lista ~13) → `qa_runs/adrs-20260722/LOG.md`. **[HECHO — el muro muerde: 5/5 self-test verde, 13 desvíos cazados]**

### M2 — El campo completo

**R3 · Alinear los ~13 ADRs** *(`decisiones`)* — extraer descartes embebidos (0001-0003), enmienda donde falte (0028), `Razones`/`El principio`/`Lecciones de campo`→`Por qué` (0004, 0005, 0027, 0033, 0040, 0042, 0043), alinear header 0044 + enlace, notas de staleness (0001, 0002). Delegable a `mecanico`. **Prueba:** `probar-adrs.ps1` verde sobre todo el corpus.

### M3 — La vista y el sello

**R4 · El tablero + el ADR de la decisión** *(`decisiones` + tools)* —
- `probar-adrs.ps1 -Reporte` → artefacto committeado (HTML autocontenido, patrón `estado-gobierno.ps1`): 49 ADRs × conformidad, verde. El cliente lo abre sin terminal.
- **ADR 0050** (molde único + muro), con `El camino que NO se toma` = "solo avisa" (descartado) + "skill personal como garantía" (descartado). Bajo el molde nuevo.
- Adjacente (fuera de repo, opcional): reconciliar `~/.claude/skills/adr-helper/SKILL.md`.
- **Prueba:** reporte verde; 0050 pasa `probar-adrs`; suite completa verde (`verificar` + los `probar-*` + `probar-adrs` + `probar-instalador`/`probar-sembrar`).

## Archivos (blast radius)

Molde: `docs/decisions/0000-plantilla.md`, `kit/.jidoka/templates/adr.md` · Guardián: `tools/probar-adrs.ps1` (NUEVO), `.github/workflows/andon.yml`, `tools/publicar.ps1`, `kit/.jidoka/instalar/manifiesto.json`, `tools/jidoka-motor.json` · Campo: ~13 × `docs/decisions/00NN-*.md`, `docs/decisions/README.md` · Vista/decisión: `docs/decisions/0050-*.md` (NUEVO) + fila en README, reporte committeado, `CHANGELOG.md`, `tools/version.txt` (al release) · Adjacente: `~/.claude/skills/adr-helper/SKILL.md` · Evidencia: `qa_runs/adrs-20260722/LOG.md`.

**Gates (router):** `decisiones`/`kit`/`barreras` → `andon-stop` + `review-stop`. ADR 0050 satisface el `doc_bloquea` (índice). Código en tools/ → `review-stop`.

## Verificación — el demo que corre el cliente (`owner: cliente`, sin código ni terminal)

1. **El tablero en verde:** abre el reporte committeado (doble clic → navegador): 49 ADRs, todos "conforme".
2. **Uniformidad a ojo:** abre en GitHub 0044 (estado + enlace a 0048), 0001 (fundacional alineado), 0028 — mismas secciones.
3. **El futuro nace alineado:** abre el ADR 0050 — la decisión, ya con el molde nuevo.
4. **El muro muerde** (evidencia): `qa_runs/adrs-20260722/LOG.md` con la corrida en rojo (exit 1) de un ADR mal formado.

## Lo que NO entra (frontera)

- No se reescribe ninguna decisión ni el texto original de un ADR — solo relocalizar/nombrar lo existente + enmienda fechada.
- No se construye una skill de método nueva en el repo — la garantía es el muro, no una herramienta de autoría (regla 2-3).
- No se toca el contenido/juicio de las decisiones (forma + coherencia de estado, no verdad).
- No se cambia `blast-radius.json` (el nuevo muro es un `probar-*` en CI, no un área nueva).
- Multiplataforma del guardián fuera de alcance — Windows/PS 5.1.

## Aislamiento (otro agente en paralelo) — CORREGIDO 2026-07-22

Se trabaja en un **git worktree aislado** `C:\Repositorio personal\jidoka-adrs` (rama `review/adrs-20260722` @ 5a464bc). El otro agente tiene el árbol original `C:\Repositorio personal\jidoka` en su rama `app/curas-tuberia-20260722`. Un intento previo con solo `checkout -b` (mismo working tree) colisionó — el otro agente cambió la rama del árbol debajo del trabajo. Lección: rama propia NO basta; hace falta worktree propio cuando hay escritor paralelo.

**Riesgo de colisión de número de ADR (0050) y de versión** — misma lección del renumerado 0045→0049. Mitigación: verificar al merge que 0050 y la versión objetivo (probable `v1.29.0`, MINOR) sigan libres; derivar del SSOT al cortar release, coordinando el orden de merge con FLU-1.
