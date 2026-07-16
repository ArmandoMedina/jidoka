# Sprint "Conciencia del agente — reconstrucción limpia" (#75, cierra #63) — v1.16.0

> Plan aprobado en plan mode el 2026-07-16. **Este plan ES el sprint**: lo que no está aquí, no entra (ver "Lo que NO entra").

## Contexto (por qué)

La rama `sprint-conciencia-del-agente` se descartó completa: arrastraba la regresión enmascarada del borrado del motor (#73 — cuyo salvavidas ya construimos en v1.15.0/ADR 0032). **El trabajo de features estaba construido y validado en verde**; el issue #75 es el inventario para reconstruirlo sobre cimiento limpio sin re-derivarlo. Son 4 piezas de la familia "conciencia del agente" (principio de la cosecha #5 / ADR 0029: *nada de conciencia depende de la iniciativa del agente — se instala como maquinaria determinista o no está instalada*):

1. **Agentes-asiento tiereados (cierra #63).** Hoy la regla de tiers vive solo en prosa (`kanban/roles.md:52-54`, "pequeño para lo mecánico…") y el default silencioso del harness es heredar el modelo caro. Nada la instala.
2. **Reframe rol-teatro en `arranca.md`.** Hoy el arranca hace que el orquestador "se siente" en asientos — teatro; el asiento con dientes lo ocupa el subagente al que se delega.
3. **Payload inyecta-directo.** Un puntero "lee X" queda a criterio del agente; lo que debe leerse al abrir se inyecta con `@`.
4. **Split de `product/recursos-del-proyecto.md`** en el QUÉ (`PRODUCT_BRIEF.md`) y el CÓMO-operativo (`infra.md`) — hoy mezcla casting, referencia, identidades, máquinas y convenciones.

Nota sobre #63 (`regla-2-3`, "primera ocurrencia"): se construye porque **el cliente lo nombró en el alcance** ("Sprint A + B: la reconstrucción (#75/#63)", 2026-07-16) y la rama descartada ya lo había validado — no es iniciativa del agente.

**Correcciones al inventario del #75 (verificadas hoy):** no existe `$metadocs` en `tools/auditar.ps1` (esa ref colgante ya no aplica) — el auditor escanea `product/*.md` completo automáticamente (`auditar.ps1:101-105`); el punto real es `$exentTipos` (`auditar.ps1:183`): `tipo: brief`/`infra` no están exentos del check de huérfana. Y ningún `tools/*.ps1` ni test referencia `recursos-del-proyecto` por nombre — el split no rompe siembra ni tests.

## Decisiones del cliente que este plan asume

- **2026-07-16** — "adelante con el siguiente sprint" (#75) tras el menú de alcance donde B = reconstrucción #75/#63.
- **2026-07-14** — el casting de la nave nodriza usa nombres neutrales a propósito (se preserva: el casting **nombrado** sobrevive solo como plantilla en `kit/`).
- El matiz del #74 ("PLD/CNBV no confirmado") no entra aquí.

## Rebanadas (cada una commiteable y verde por sí sola)

### R1 — Agentes-asiento tiereados + lint (cierra #63) — ADR 0033 · **toca la ley**
- **`.claude/agents/{explorador,mecanico,auditor,arquitecto}.md`** (nuevos): frontmatter con `model:` y `tools:` fijos — `explorador → haiku` (barridos de lectura), `mecanico → haiku` (edits mecánicos), `auditor → sonnet` (juicio acotado), `arquitecto → opus` (trade-offs). `description` con el criterio de cuándo usarlo (para que el orquestador elija por nombre de asiento, no por iniciativa). El cuerpo, mínimo: el asiento, lo que NO hace, y el retorno esperado (datos, no prosa).
- **`tools/probar-agentes.ps1`** (nuevo lint): cada agente declara `model:` con un **alias real** (`haiku|sonnet|opus`, no un model-id inventado) y `tools:`; todo asiento esperado existe. ASCII, PS 5.1, patrón `Check` de los `probar-*` existentes.
- **Gotcha de release (documentado en #75, descubierto tarde en la rama):** agregar `'probar-agentes'` al `foreach` del preflight de `tools/publicar.ps1` — `probar-publicar.ps1` exige que todo `probar-*.ps1` esté en el preflight (meta-test) y pondría el release en rojo.
- **La ley:** `tools/blast-radius.json`, área `ritual` gana `".claude/agents/*"` en su `fuente` (los agentes-asiento son ritual ejecutable). `rutear.ps1` no cambia (lee la ley).
- **`kanban/roles.md`:** la sección model-routing gana la tabla asiento→tier (la prosa se mantiene; la tabla la aterriza).
- **ADR 0033 — "Los tiers de modelo se instalan como agentes-asiento"** + índice.

### R2 — Split del brief: `product/PRODUCT_BRIEF.md` + `product/infra.md` — parte del ADR 0034
- **`product/PRODUCT_BRIEF.md`** (nuevo): el QUÉ de Jidoka con la estructura de la plantilla `kit/.jidoka/templates/PRODUCT_BRIEF.md` (frontmatter `tipo: brief`), **llenado desde lo ya escrito** (README/ROADMAP/doctrina — la nave nodriza tiene su QUÉ definido; nada se inventa). Vive en `product/` (la nave usa el grafo; los hijos arquetipo `brief` lo siembran en raíz — diferencia acusada en el ADR).
- **`product/infra.md`** (nuevo, `tipo: recursos`): identidades por servicio, máquinas/ambientes, convenciones — el CÓMO-operativo que hoy vive en `recursos-del-proyecto.md`.
- **El casting:** desaparece de la instancia (la nave usa los roles neutrales de `kanban/roles.md` vía fallback del arranca — decisión 2026-07-14); la sección `## El casting` **sobrevive en la plantilla** `kit/.jidoka/templates/recursos-del-proyecto.md` (los hijos sí castean con nombres).
- **`product/recursos-del-proyecto.md`** se elimina (su contenido migró). No es pieza del motor (`tools/*`) — el salvavidas de ADR 0032 no aplica, pero el ADR 0034 del mismo cambio documenta la decisión de todos modos.
- **Refs colgantes** (verificadas): `product/README.md` (línea final), `.claude/skills/arquitecto-doc/SKILL.md:12`, y el propio `arranca.md` (se cura en R3). `auditar.ps1`: `brief` ya nace enlazado desde `product/README.md` e `infra` se agrega a `$exentTipos` (o se enlaza — decidir por lo que menos toque el motor; preferencia: enlazar desde `product/README.md`, cero cambio de código).
- **`kit/.jidoka/templates/infra.md`** (nueva plantilla): viaja a los hijos por el manifiesto sin tocarlo (siembra el dir de templates completo).

### R3 — `arranca.md`: reframe rol-teatro + payload inyecta-directo — ADR 0034
- **Reframe:** el orquestador **no se sienta** — decide y teje; el **router es un preview de gates** (qué te va a vigilar al cerrar según lo que toques); el **casting es el roster de responsables**; el asiento con dientes lo ocupa el **subagente** al que se delega (y ahora existen los agentes-asiento de R1 con su tier fijo). La regla de tiers se **enuncia junto al roster** (la mecánica que ADR 0029 usó para los asientos — cura candidata del #63 que la rama validó).
- **Payload inyecta-directo:** `@HANDOFF.md` (ya está) + `@product/PRODUCT_BRIEF.md` + `@CONTRIBUTING.md` inyectados; `@product/infra.md` reemplaza al viejo `@product/recursos-del-proyecto.md`.
- **ADR 0034 — "El arranca inyecta, no encarga; el asiento lo ocupa el subagente"** (reframe + payload + split del brief) + índice.

### R4 — Cierre
- `CHANGELOG.md` v1.16.0 + `tools/version.txt` + `package.json` (probar-version exige los tres).
- Plan archivado (`docs/sprints/sprint-conciencia-del-agente-plan.md`) + fila en `docs/sprints/README.md`.
- Evidencia: `qa_runs/conciencia-del-agente-20260716/LOG.md` (ROJO→VERDE del lint `probar-agentes`, corrida de suite completa, y el render del arranca nuevo).
- HANDOFF honesto (pide el #75: sin la narrativa "falso positivo de AV" que enmascaró el borrado original).
- Acuse del lazo: #75 y #63 se cierran con el PR; #68 recibe comentario (la familia queda con el reframe instalado; el issue sigue como lente).
- Rama `sprint-conciencia-del-agente-2`, un PR, merge con orden nombrada.

## Archivos

Nuevos: `.claude/agents/*.md` ×4 · `tools/probar-agentes.ps1` · `product/PRODUCT_BRIEF.md` · `product/infra.md` · `kit/.jidoka/templates/infra.md` · ADRs 0033/0034 · plan + LOG.
Tocados: `tools/blast-radius.json` (ley — área ritual) · `tools/publicar.ps1` (preflight +1) · `.claude/commands/jidoka/arranca.md` · `kanban/roles.md` · `product/README.md` · `.claude/skills/arquitecto-doc/SKILL.md` · `docs/decisions/README.md` · `CHANGELOG.md` · `tools/version.txt` · `package.json` · `docs/sprints/README.md` · `HANDOFF.md`.
Borrado: `product/recursos-del-proyecto.md` (migrado; documentado en ADR 0034).

Áreas de la ley: **ritual** (arranca, agents) · **barreras** (ley, publicar, probar-*) · **decisiones** (ADRs → índice, bloqueo) · **metodo** (roles.md → CHANGELOG avisa). Todo rutea al escribano; `andon-stop`/`review-stop` vigilan.

## Verificación (el demo que corre el cliente) — `owner: cliente`

**Sin código ni terminal:** tras el merge, abrir una **sesión nueva** de Claude Code en este repo y escribir `/jidoka:arranca`: ver (1) el estado inyectado sin encargos de lectura, (2) el roster de responsables con su **tier de modelo al lado** (nada de "el orquestador se sienta"), (3) el router como preview de gates. En el PR: leer `qa_runs/conciencia-del-agente-20260716/LOG.md` (ROJO→VERDE del lint + suite verde) y el diff del arranca.

## Lo que NO entra

La reorganización de producto de #71 (solo quedó declarada la frontera) · #64/#66/#67 (regla 2-3) · la parte no-doc de #79 · #74-R3 · portar "docotes" de flujo de trabajo (la nota de diseño del #51 lo prohíbe: el fix es lean) · npm publish / firma (cliente) · bajada a los labs (ventana aparte).
