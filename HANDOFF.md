# HANDOFF — relevo entre sesiones

> Estado en vuelo y pendientes. **Se llena al cerrar**, **se lee y se limpia al abrir.** Nada de memorias de la IA — todo va aquí.

## En una frase

**Jidoka** — el Sistema de Producción Toyota para agentes de IA: fusión de doctrina + método + ritual de sprint, instalable con `npx jidoka init`. Se construye por sprints, usando su propio ritual (dogfooding).

## Dónde estamos (2026-07-10)

- **Sprint 0 — Esqueleto + identidad: HECHO y PÚBLICO.** Repo en https://github.com/ArmandoMedina/jidoka, tag `v0.1.0-beta`. Commit firmado con correo profesional (`amedina@arcadial.lat`), no el personal. README (pitch TPS + linaje de aviación + diferenciadores propios), ADR 0001, doctrina embebida, índices `kanban/` y `andon/`, 13 disparos sembrados.

## Qué falta / siguiente (en orden de valor)

1. **Sprint 1 — El motor Andon:** `blast-radius.json` + `verificar.*` + `auditar.*` + `probar-gate.*` + CI + hooks, corriendo sobre el propio Jidoka. *Demo: un cambio que rompe la ley → el gate lo bloquea; `probar-gate` verde.*
2. **Sprint 2 — El ritual Kanban + roles:** comandos `/jidoka:*`, skills, templates de sprint, hook `gemba-stop`, `qa_runs/`.
3. **Sprint 3 — El instalador `npx jidoka init`** (CLI Node + `kit/`).
4. **Sprint 4 — Estabilizar la beta:** guías completas, pulido, README de instalación real.

> Nota de flujo: `git push` a public lo bloquea el clasificador de modo automático; los pushes los corres tú con `!` (o das permiso a `gh`).
