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

## Sprint 3 — El instalador · 🔜
- CLI **`jidoka-method`** en npm (`npx jidoka-method init`): pregunta el arquetipo (code-first · docs-as-code · doc-only) y siembra solo la maquinaria que el proyecto merece.
- El `kit/` completo (incl. jerarquía de templates de producto); **gemelos `.sh`** del motor (multiplataforma); `setup` desatendido (`-Yes`).
- Barreras extra del verificador para repos code-first: lint/formato/tests/cobertura/CHANGELOG-gate (probadas en el laboratorio de campo).
- CI de release + smoke del instalador (lección pagada: *un workflow que solo corre al cortar release se pudre en silencio* — `workflow_dispatch` como rescate).
- Decisión abierta (ADR 0003): el motor vive SOLO en `kit/` y este repo **se instala su propio kit** — cero copias duplicadas de la ley.
- El instalador enciende lo que hoy es manual: `core.hooksPath`, y guía la branch protection.

## Sprint 4 — Beta estable · 🔜
- Guías completas (`docs/guias/empezar-de-cero.md` deja de ser esqueleto).
- Presentación pública: badges, Quick Start, banner, social preview.
- Decisión abierta: comunidad (Discussions / Discord).
- Candidato a `v1.0` cuando el método completo corra end-to-end en un repo ajeno.

## Backlog (sin sprint asignado)
- Publicar la doctrina suelta rebrandeada **"Poka-yoke"** (ADR 0001 lo deja abierto; solo entonces Jidoka la enlazaría como *further reading*).
- `SECURITY.md` para colaboración externa (`CONTRIBUTING.md` ya existe — Sprint 1.5).
- Tablero de instrumentación (leading vs lagging, las 5 series de `doctrina/05`) — no existe en ningún repo del linaje; construirlo es frontera.
