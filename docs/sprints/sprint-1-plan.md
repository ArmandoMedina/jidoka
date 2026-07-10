# Sprint 1 — El motor Andon (dogfooding sobre el propio Jidoka)

> Plan aprobado en plan mode (el ritual Kanban: *sprint planning* = plan mode; el plan aprobado **es** el sprint y se archiva aquí). Estado de la tarjeta: **Aprobado → En curso**.

## Contexto (por qué)

Jidoka ya tenía la doctrina, el discurso y su identidad (Sprint 0, público), pero no corría ni un gate. La tesis —*un gate es muro solo si vive FUERA del LLM*— sin motor es prosa. Este sprint construye el motor y lo pone a correr sobre el propio repo (dogfooding). No se reescribe: se **adapta** el motor ya probado de `poka-yoke-ia`.

## Alcance entregado

**Motor** (`tools/`, PS 5.1, ASCII no-BOM):
- `blast-radius.json` — la ley: 5 áreas (decisiones, doctrina, disparos, metodo, barreras); casi todo `avisa`, un `doc_bloquea` real.
- `verificar.ps1` — verificador local + CI; avisa `doc_avisa`, bloquea `doc_bloquea`.
- `probar-gate.ps1` — self-test de 5 casos (incluye el bloqueo real de la ley + uno sintético).

**Hooks** (`.claude/`): `no-memorias-pretooluse.ps1`, `andon-stop.ps1`, `settings.json`.

**Muro + UX**: `.github/workflows/andon.yml` (check de PR), `.githooks/pre-push`.

**Docs (dogfood)**: `docs/decisions/README.md` (índice, dueño del bloqueo), `docs/decisions/0002-motor-andon.md`, `andon/README.md` (mapea el motor + cómo encenderlo), `CHANGELOG.md`.

## Decisión de diseño

Fiel a la doctrina anti-fatiga: el manifiesto arranca casi todo en `avisa`, con **un único `doc_bloquea` real** — un ADR nuevo debe listarse en `docs/decisions/README.md`. Alto valor (un ADR fuera del índice es una decisión perdida), baja fatiga (los ADR son append-only). El camino de bloqueo se guarda además con un manifiesto sintético en `probar-gate.ps1`. (Ver ADR 0002.)

## Fuera de alcance (por qué)

- **Gemelos `.sh`** → Sprint 3 (instalador multiplataforma). Aquí PS 5.1 + CI `windows-latest`, idéntico a poka-yoke.
- **`auditar.ps1` / auditor de grafo** → Jidoka aún no tiene grafo de producto que auditar.
- **Roles, comandos `/jidoka:*`, `gemba-stop`, templates** → Sprint 2.

## Verificación (demo Gemba — lo corre el cliente)

1. `.\tools\probar-gate.ps1` → **verde** (y muestra el caso `[BLOQUEA]`).
2. Crear `docs/decisions/0003-prueba.md` sin meterlo al índice → `.\tools\verificar.ps1` **BLOQUEA** (exit 1). Agregarlo al índice → **pasa** (exit 0).
3. Editar `doctrina/00-tesis.md` sin tocar disparos → `verificar.ps1` **AVISA** (no bloquea).
4. (Opcional) PR de juguete → el check `andon` corre en GitHub; marcarlo como required en la protección de `main`.

## Lo aprendido (Kaizen)

_(Se llena al cerrar el sprint.)_
