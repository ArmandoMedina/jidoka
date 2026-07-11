# Roadmap — Jidoka

> Norte: **la disciplina en el robot, el juicio en el humano** — empaquetado para que cualquiera lo instale. Cada sprint entrega un incremento demostrable (Gemba); este roadmap es el récord de hacia dónde va la beta. Regla del repo: *evidencia-no-palabra* — nada se anuncia como existente hasta que corre.

## Sprint 0 — Identidad · ✅ Publicado (`v0.1.0-beta`)
- Doctrina embebida (`doctrina/`, 9 docs, self-contained), el sistema TPS (Jidoka·Andon·Kanban·Kaizen·Gemba·Poka-yoke), README, licencia MIT, los 12 disparos.

## Sprint 1 — El motor Andon · ✅ Mergeado (`v0.2.0-beta`)
- La ley única (`tools/blast-radius.json`), verificador que **falla cerrado**, self-test con caso que DEBE bloquear, hooks (`no-memorias`, `andon-stop`), `pre-push`, check `andon` en CI **con la ley leída desde la rama base** (un PR no puede editar la ley que lo juzga — ADR 0003).
- Cierre auditado: ver ADR 0003 y el Kaizen en `docs/sprints/sprint-1-plan.md`.

## Sprint 1.5 — Vitrina + centralización del conocimiento · ✅ Mergeado (`v0.3.0-beta`)
- Vitrina en español con bandera (badges, release, topics); el andamio documentado (`kanban/lazo|jerarquia|roles|auditoria`); los 4 ADRs de la doctrina; templates y `qa_runs/` al kit; hardening ALTO-04 + área `raiz`. Ver ADR 0004.

## Sprint 2 — El ritual Kanban ejecutable · 🔜
- Comandos `/jidoka:planea`, `/jidoka:gemba`, `/jidoka:cierra` (+ `/jidoka:que-sigue`, el "¿y ahora qué?"; + `/jidoka:arranca` con las reglas duras de sesión — incl. "desconfía del resumen de compactación", caso real).
- **Skills-asiento** (escribano, validador, revisor-visual; arquitecto-doc para doc-heavy) — el conocimiento ya está en `kanban/roles.md`; aquí se vuelven ejecutables. Referencia probada en el laboratorio de campo.
- Hooks: `gemba-stop` (no se cierra con cambio visual sin evidencia fresca en `qa_runs/` — probado en el linaje) y `review-stop` (código sin `/code-review` frena el cierre; marcador SHA con sus grietas documentadas).
- **Auditor determinista del grafo de docs** (frontmatter + wikilinks + Gherkin de capacidades vigentes + huérfanas, modulado por estado) + dimensión `product_avisa` en la ley.
- Templates de sprint: ya sembrados en `kit/.jidoka/templates/` (Sprint 1.5); aquí los comandos los usan.
- Especificación fina heredada del linaje (ADR 0005): mecánica del `gemba-stop` auto-configurado desde la ley; `recursos-del-proyecto.md` que `/jidoka:arranca` lee al abrir; la rebanada **R0 con STOP** en `/jidoka:planea`; anatomía probada de skill ("Entorno" embebido, no son `subagent_type`); regla doc-only (sin `/arranca`); **zanjar la contradicción del plan efímero** (válvula de excepción para tareas largas).

## Sprint 3 — El instalador · 🔨 en curso (faseado)

Enorme; se fasea. El hallazgo fundacional: el ancestro (`project-starter`) **no tenía instalador** (sembraba con "Use this template" de GitHub) — el acto de sembrar es invención de Jidoka. Lo reutilizable del starter es *qué* sembrar (13 templates, la ley ejecutable, hooks auto-desactivables) y los **3 arquetipos** (code-first · docs-as-code · doc-only), hoy prosa.

### Fase 3.A — El instalador mínimo que corre · ✅ (en PR, candidato `v0.7.0-beta`) — ADR 0008
- `tools/instalar.ps1` (PowerShell, Windows-first): siembra el método en un repo destino leyendo el motor genérico del árbol de Jidoka (sin duplicar la ley), cambiando solo la ley por una **plantilla de arquetipo**. Regla dura **no-clobber**. Enciende `core.hooksPath`, crea stubs, guía la branch protection.
- Un arquetipo (`docs-as-code`), su ley-plantilla y el manifiesto de siembra en `kit/.jidoka/`. Smoke `tools/probar-instalador.ps1` (instala en repo temporal, corre los self-tests sembrados). Área `kit` en la ley.

### Fase 3.B — Los arquetipos ejecutables + los templates · ✅ (en PR, candidato `v0.8.0-beta`) — ADR 0009
- **La matriz vive como manifiesto ejecutable** (`kit/.jidoka/instalar/manifiesto.json`): el instalador pregunta el arquetipo y siembra distinto. Es el mayor valor sobre el ancestro (allá la matriz era prosa).
- **Podado a 2 arquetipos** (decisión delegada, revisable — ADR 0009): `docs-as-code` (probado) + `code-first` (grafo vs `PRODUCT_BRIEF`). `doc-only` diferido (method-ficción: sin consumidor real).
- **Los 12 templates de producto** portados como librería *menú, no molde* (`kit/.jidoka/templates/producto/`) + `PRODUCT_BRIEF` con *Landscape* + HANDOFF stub con columna *Validación*.

### Fase 3.C — lo que falta (diferido a propósito, que no se olvide)
- **El arquetipo `doc-only`/regulado** (ley `capacidad→evidencia` + gobernanza `borrador→referencia→oficial`) — se estrena cuando un repo regulado real lo pida (regla 2–3).
- **La matriz de piezas más fina** (qué skills/tests/UI por arquetipo, más allá de ley+semilla).
- **benchmark** verificado en vivo — portar/formalizar.
- **Multiplataforma**: gemelos `.sh` o unificar en `pwsh` Core (decisión abierta); despacho de hooks por SO. Hoy el motor es Windows/PS 5.1.
- **CLI npm `npx jidoka-method init`** (distribución cross-platform) + **SSOT de versión** (un literal, `package.json`, todo deriva — hoy la versión vive en tags/CHANGELOG/ROADMAP) + **CI de release** + **smoke del instalador en CI** (lección: *un workflow que solo corre al cortar release se pudre en silencio* → `workflow_dispatch` de rescate) + **ensayo del empaquetado** (el build se autoverifica contra el manifiesto que el runtime usa).
- **Barreras code-first**: lint/formato/tests/cobertura/CHANGELOG-gate; **gate de UX en 3 capas**; **lint de alta señal** (set corto).
- **Dogfood completo del ADR 0003**: mover el motor a vivir SOLO en `kit/` y que Jidoka se **auto-instale** (cero duplicación). La Fase 3.A lo evita leyendo del árbol, pero no completa la mudanza.
- Los comandos/skills sembrados citan docs de método de Jidoka (`kanban/`, `docs/guias/`) que hoy **no** se siembran: enlaces muertos en un repo ajeno (los `@`-refs duros sí resuelven). Sembrar un set genérico o apuntar a los docs públicos es parte de esta deuda (ADR 0008 → "Qué NO resuelve").

## Sprint 4 — Beta estable · 🔜
- Guías completas (`docs/guias/empezar-de-cero.md` deja de ser esqueleto).
- Presentación pública: badges, Quick Start, banner, social preview.
- Decisión abierta: comunidad (Discussions / Discord).
- Candidato a `v1.0` cuando el método completo corra end-to-end en un repo ajeno.

## Vitrina pública — dejar el repo listo para compartirse (sesión 2026-07-10)

Trabajo de presentación surgido de la auditoría externa y de la entrada del autor a una comunidad. Lo pendiente lleva receta completa para que cualquier sesión (o el propio autor) lo retome sin re-explicación.

### Hecho ✅ (2026-07-10, en el working tree de la sesión)

- **Ko-fi cableado en tres puntos**: `.github/FUNDING.yml` (`ko_fi: armandomedina2255`) — enciende el botón *Sponsor* del repo al llegar a `main`; badge Ko-fi en el bloque de badges del README (mismo estilo que SimGhostInputs); invitación al café en la línea de la licencia del README.
- **Template de PR** (`.github/PULL_REQUEST_TEMPLATE.md`): el punto de inyección de disparos en PRs que `andon/README.md` ya prometía. Lleva evidencia-no-palabra, el recordatorio ADR→índice y el disparo `no-verify-es-teatro`. Corto a propósito — `doctrina/04`: un checklist largo entrena el click-para-pasar.
- **Templates de issues** (`.github/ISSUE_TEMPLATE/`): `reporte.md` (redactado para que un **no-programador** reporte sin miedo; pide evidencia, no jerga) y `leccion.md` (el canal de homologación abierto al público — regla 2–3 de maduración y disparo `frontera-nda` embebidos).

### Pendiente ⏳ (en orden de valor)

1. **El GIF del gate mordiendo — la pieza más valiosa de toda la vitrina.** Hoy "míralo morder" en el README es *palabra*. Guion de una toma (~20 s): (a) crear `docs/decisions/0006-prueba.md` sin listarlo en el índice; (b) `./tools/verificar.ps1` → capturar el `[BLOQUEA]` rojo; (c) listarlo en el índice, correr de nuevo → verde; (d) revertir todo. Herramienta sugerida: ScreenToGif (Windows, gratis). Destino: README, junto a "míralo morder" en la tabla de sprints. La grabación es humana; una sesión de IA puede dejar preparados los archivos del antes/después.
2. **Social preview** (solo humano, ya estaba en la checklist): Settings → General → Social preview, imagen 1280×640 px. Es lo primero que se ve al pegar el link en Discord/foros — sin imagen el link se ve pobre. Una provisional generada por IA sirve ya; el banner definitivo es del Sprint 4.
3. **`CODE_OF_CONDUCT.md`** — [Contributor Covenant 2.1 en español](https://www.contributor-covenant.org/es/version/2/1/code_of_conduct/). GitHub lo muestra en la pestaña de comunidad y da un mecanismo neutro de moderación *antes* de que llegue el primer conflicto con extraños.
4. **Decisión abierta del cliente — el párrafo en inglés del README.** Distinguir dos cosas: *el método se escribe y se defiende en español* (postura de identidad, se mantiene) vs. *el visitante anglófono no entiende ni de qué va el repo* (un bounce). Propuesta sobre la mesa: un único párrafo en inglés — qué es Jidoka y por qué está en español a propósito. Solo el autor decide; si se decide que no, se registra y no se re-litiga.
5. **Decisión abierta del cliente — el ADR de la licencia.** MIT corre en ambas direcciones: cualquier empresa puede tomar Jidoka, cerrarlo y venderlo sin devolver nada. La alternativa alineada con "el que tome, comparte de vuelta" es copyleft (GPL/AGPL — que el autor ya usa en SimGhostInputs). Sin recomendación de cambio: para una *metodología* (conocimiento más que código), MIT-para-máxima-adopción es defendible. Pero la decisión debe existir como ADR con "el camino que NO se tomó" — consciente, no heredada. Toca también el punto abierto del ADR 0001 (doctrina rebrandeada "Poka-yoke").

## Grietas de la auditoría externa (2026-07-10) — registradas, no resueltas

Hallazgos de una auditoría de terceros sobre este repo (evidencia: corrió `probar-gate.ps1` 6/6 y leyó el motor completo). Se registran con destino para que no se pierdan entre sesiones:

1. **El muro real hoy protege muy poco.** Un solo `doc_bloquea` en la ley; los `doc_avisa` salen con exit 0 y **en CI un aviso es invisible salvo que alguien lea el log** — el check `andon` puede estar verde con avisos ignorados sesión tras sesión (modo de falla #3 de `doctrina/04`: gate que nunca dice que no). → **Sprint 2**: subir los avisos a la superficie del PR (summary/comentario), y re-evaluar qué avisos maduran a bloqueo (regla 2–3).
2. **El hook `no-memorias` no es muro según la propia ley del muro.** Solo intercepta `Write|Edit`; una escritura vía Bash (`Set-Content`) lo rodea, y no hay cobertura server-side. Es un aviso disfrazado de deny. → **Sprint 2**: ampliar el matcher a Bash o confesarlo como frontera en `andon/README.md` (hoy no está en la lista de fronteras).
3. **El gate mide co-ocurrencia, no contenido.** Tocar el doc dueño con un cambio trivial satisface el gate — proxy gameable (Goodhart, `doctrina/04` aplicado a nosotros mismos). → Se acepta como límite conocido del diseño v0; documentarlo en las fronteras de `andon/README.md`. Cualquier verificación de contenido es decisión aparte (riesgo de over-governance).
4. **El linaje es evidencia privada.** Los 4 repos de origen no son públicos: para un auditor externo, "nacido de cuatro repos internos" es *palabra*, en un repo que predica evidencia-no-palabra. → **Sprint 4** (presentación pública): decidir qué evidencia del linaje se puede mostrar (números anonimizados de `docs/casos-de-exito.md` ya son el primer paso) y ajustar el discurso del README a lo verificable.
5. **11 de los 12 disparos son catálogo, no máquina.** Solo `anti-memoria` está cableado a un hook real; el resto vive en `kit/.jidoka/disparos/README.md` sin punto de inyección. → **Sprint 2**: cada hook/comando nuevo debe consumir sus disparos del catálogo (el `gemba-stop`, `review-stop` y `/jidoka:arranca` ya tienen los suyos esperando).

## Backlog (sin sprint asignado)
- Publicar la doctrina suelta rebrandeada **"Poka-yoke"** (ADR 0001 lo deja abierto; solo entonces Jidoka la enlazaría como *further reading*).
- `SECURITY.md` para colaboración externa (`CONTRIBUTING.md` ya existe — Sprint 1.5).
- Tablero de instrumentación (leading vs lagging, las 5 series de `doctrina/05`) — no existe en ningún repo del linaje; construirlo es frontera.
