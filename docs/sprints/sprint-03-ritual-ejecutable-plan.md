# Sprint 2 · Fase A — El ritual Kanban ejecutable

> Plan aprobado en plan mode el 2026-07-10. **Este plan ES el sprint**: lo que no está aquí, no entra (ver "Lo que NO entra"). Candidato a `v0.5.0-beta`.

## Contexto (por qué)

Jidoka predica un ritual Kanban (`arranca → planea → gemba → cierra`) y un reparto por asientos (`kanban/roles.md`), pero **nada de eso era ejecutable**: el conocimiento estaba escrito, la máquina no existía. El propio cliente notó que `/jidoka:arranca` no estaba — correcto, era un entregable de este sprint, no un bug. El Sprint 2 completo (comandos + skills + 2 hooks + auditor del grafo + 3 grietas) es grande y toca la ley repetidamente; se parte en dos releases. **Esta Fase A** entrega la capa de artefacto-prompt (comandos + skills), de bajo riesgo de máquina y con un demo end-to-end coherente: una sesión que corre el lazo completo. Los muros deterministas van a la Fase B (`v0.6.0-beta`).

Además salda una deuda heredada del ADR 0005: la **contradicción del plan efímero**.

## Encuadre de producto (validado con el cliente)

Quien instale Jidoka gana **el ritual como comandos que se invocan** (`/jidoka:*`) y **los asientos como skills que se autoinvocan por contexto**, con sus límites escritos. El método deja de ser prosa que hay que recordar y se vuelve maquinaria que la sesión ejecuta — dogfooding.

## Decisiones del cliente (2026-07-10)

- **Alcance:** Fase A (el ritual) en este corte → `v0.5.0-beta`. Fase B (los muros) queda para después.
- **Plan efímero (ADR 0006):** hogar persistente gitignored — el plan-de-trabajo vive en `/.jidoka/plan-actual.md`, fuera de git pero persistente. Se ancla al disparo `desconfia-de-la-compactacion`.
- Autorización de release vigente (HANDOFF): publicar tag + release no requiere re-autorización. Merge de PR y cambios de config/permisos **sí** requieren orden nombrada cada vez.

## Alcance (rebanadas verticales — cada una commiteable y verde)

- **A0 · Gobernar los artefactos + zanjar el plan efímero (ADR 0006)** `[LEY]` — área `ritual` en la ley (`.claude/commands/*`, `.claude/skills/*` → avisan CHANGELOG); ADR 0006 + índice; `.gitignore` anclado `/.jidoka/`; plantilla plan-de-trabajo afinada; caso 7 en `probar-gate.ps1`.
- **A1 · `/jidoka:arranca` + `recursos-del-proyecto.md`** — comando que abre leyendo el estado real; plantilla + instancia en `product/`; regla doc-only registrada en ADR 0006.
- **A2 · `/jidoka:planea`** — la rebanada R0 con STOP.
- **A3 · `/jidoka:gemba`** — el demo, evidencia en `qa_runs/`.
- **A4 · `/jidoka:cierra`** — registro por caducidad, poda, `git add -f`, release.
- **A5 · `/jidoka:que-sigue`** — propuesta en orden de valor.
- **A6 · Skills-asiento** — escribano, validador, revisor-visual, arquitecto-doc.

## Archivos

- **Ley + motor:** `tools/blast-radius.json`, `tools/probar-gate.ps1`, `.gitignore`.
- **Comandos:** `.claude/commands/jidoka/{arranca,planea,gemba,cierra,que-sigue}.md`.
- **Skills:** `.claude/skills/{escribano,validador,revisor-visual,arquitecto-doc}/SKILL.md`.
- **Plantillas / instancias:** `kit/.jidoka/templates/recursos-del-proyecto.md`, `product/recursos-del-proyecto.md`, `kit/.jidoka/templates/plan-de-trabajo.md`.
- **Registro:** `docs/decisions/0006-plan-efimero.md` (+ índice), `docs/sprints/sprint-03-ritual-ejecutable-plan.md` (+ `README.md`), `CHANGELOG.md`, `andon/README.md`.

## Verificación (el demo que corre el cliente) — `owner: cliente`

1. `./tools/probar-gate.ps1` → **7/7 verde** (incluye el caso del área `ritual`).
2. Crear un `.claude/commands/jidoka/x.md` dummy y correr `./tools/verificar.ps1` → `[AVISO]` del área `ritual` pidiendo CHANGELOG; borrarlo.
3. Sesión nueva: `/jidoka:arranca` → lee HANDOFF + recursos y enuncia las reglas de sesión.
4. `/jidoka:planea` → genera el borrador de sprint-plan y **se detiene** (R0 con STOP).
5. `/jidoka:gemba` → deja evidencia en `qa_runs/`; `/jidoka:cierra` → actualiza HANDOFF + entrega; `/jidoka:que-sigue` → propuesta priorizada.
6. Frase natural dispara una skill-asiento con sus límites visibles.
7. El plan-de-trabajo vive en la ruta gitignored (`git status` no lo ve) y `/arranca` lo referencia.

## Lo que NO entra (Fase B → v0.6.0-beta, y Sprint 3)

- **Fase B (los muros):** `gemba-stop`, `review-stop`, harness de self-test de hooks, auditor del grafo + `product_avisa`, grietas 1/2/5.
- **Sprint 3:** el instalador `npx jidoka-method init`, plantillas de producto, gemelos `.sh`.
- Decisiones humanas pendientes (README en inglés, ADR de licencia, GIF del gate, social preview) — viven en el HANDOFF.
