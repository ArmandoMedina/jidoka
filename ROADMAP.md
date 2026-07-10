# Roadmap — Jidoka

> Norte: **la disciplina en el robot, el juicio en el humano** — empaquetado para que cualquiera lo instale. Cada sprint entrega un incremento demostrable (Gemba); este roadmap es el récord de hacia dónde va la beta. Regla del repo: *evidencia-no-palabra* — nada se anuncia como existente hasta que corre.

## Sprint 0 — Identidad · ✅ Publicado (`v0.1.0-beta`)
- Doctrina embebida (`doctrina/`, 9 docs, self-contained), el sistema TPS (Jidoka·Andon·Kanban·Kaizen·Gemba·Poka-yoke), README, licencia MIT, los 12 disparos.

## Sprint 1 — El motor Andon · ✅ En revisión (PR #1)
- La ley única (`tools/blast-radius.json`), verificador que **falla cerrado**, self-test con caso que DEBE bloquear, hooks (`no-memorias`, `andon-stop`), `pre-push`, check `andon` en CI **con la ley leída desde la rama base** (un PR no puede editar la ley que lo juzga — ADR 0003).
- Cierre auditado: ver ADR 0003 y el Kaizen en `docs/sprints/sprint-1-plan.md`.

## Sprint 2 — El ritual Kanban ejecutable · 🔜
- Comandos `/jidoka:planea`, `/jidoka:gemba`, `/jidoka:cierra` (+ `/jidoka:que-sigue`, el "¿y ahora qué?" que responde el sistema según el estado de la tarjeta).
- **Roles acotados** (orquestador, dev, validador, escribano, revisor-visual) con una responsabilidad cada uno.
- Hook `gemba-stop` (no se cierra sprint sin evidencia visual fresca) + `qa_runs/` (evidencia del demo).
- Templates de sprint con **ownership por sección** (la sección *"Revisión del stakeholder"* con `owner: cliente`).

## Sprint 3 — El instalador · 🔜
- CLI **`jidoka-method`** en npm (`npx jidoka-method init`): pregunta el arquetipo (code-first · docs-as-code · doc-only) y siembra solo la maquinaria que el proyecto merece.
- El `kit/` completo; **gemelos `.sh`** del motor (multiplataforma).
- Decisión abierta (ADR 0003): el motor vive SOLO en `kit/` y este repo **se instala su propio kit** — cero copias duplicadas de la ley.
- El instalador enciende lo que hoy es manual: `core.hooksPath`, y guía la branch protection.

## Sprint 4 — Beta estable · 🔜
- Guías completas (`docs/guias/empezar-de-cero.md` deja de ser esqueleto).
- Presentación pública: badges, Quick Start, banner, social preview.
- Decisión abierta: comunidad (Discussions / Discord).
- Candidato a `v1.0` cuando el método completo corra end-to-end en un repo ajeno.

## Backlog (sin sprint asignado)
- Publicar la doctrina suelta rebrandeada **"Poka-yoke"** (ADR 0001 lo deja abierto; solo entonces Jidoka la enlazaría como *further reading*).
- `CONTRIBUTING.md` / `SECURITY.md` para colaboración externa.
- Tablero de instrumentación (leading vs lagging, las 5 series de `doctrina/05`).
