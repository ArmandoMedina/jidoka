# HANDOFF — relevo entre sesiones

> Estado en vuelo y pendientes. **Se llena al cerrar**, **se lee y se limpia al abrir.** Nada de memorias de la IA — todo va aquí.

## En una frase

**Jidoka** — el Sistema de Producción Toyota para agentes de IA: fusión de doctrina + método + ritual de sprint, instalable con `npx jidoka init`. Se construye por sprints, usando su propio ritual (dogfooding).

## Dónde estamos (2026-07-10)

- **Sprint 0 — Esqueleto + identidad: HECHO y PÚBLICO.** Repo en https://github.com/ArmandoMedina/jidoka, tag `v0.1.0-beta`. Commit firmado con correo profesional (`amedina@arcadial.lat`), no el personal. README (pitch TPS + linaje de aviación + diferenciadores propios), ADR 0001, doctrina embebida, índices `kanban/` y `andon/`, 13 disparos sembrados.
- **Sprint 1 — El motor Andon: CONSTRUIDO, demo verde (pendiente commit + push).** Motor en `tools/` (`blast-radius.json`, `verificar.ps1`, `probar-gate.ps1`), hooks (`no-memorias`, `andon-stop`) + `settings.json`, CI `andon.yml`, `.githooks/pre-push`. ADR 0002 + índice de decisiones. `probar-gate` 5/5 verde; bloqueo real verificado (ADR sin índice → PUSH DETENIDO). **Paso humano pendiente:** marcar el check `andon` como *required* en la protección de `main` (ver `andon/README.md`).

## Qué falta / siguiente (en orden de valor)

1. **Cerrar Sprint 1:** commit + push (los corres tú con `!`), y marcar el required check en GitHub.
2. **Sprint 2 — El ritual Kanban + roles:** comandos `/jidoka:*`, skills, templates de sprint, hook `gemba-stop`, `qa_runs/`.
3. **Sprint 3 — El instalador `npx jidoka init`** (CLI Node + `kit/`).
4. **Sprint 4 — Estabilizar la beta:** guías completas, pulido, README de instalación real.

## Backlog (ideas fuera de sprint)

- **Presentación pública / "cómo se vende" estilo BMAD** (petición del cliente, 2026-07-10): landing/README más visual de cara al público — badges (MIT, beta, Windows/PS), bloque Quick Start, banner/identidad visual, `ROADMAP.md`, y el device tipo `bmad-help` ("¿qué sigue?" → `/jidoka:que-sigue`, encaja en Sprint 2). Decisión abierta: comunidad (Discord/YouTube/Discussions). Encaja natural en Sprint 4 (beta pública), pero el device de ayuda es Sprint 2.
- **Descripción del repo en GitHub** aún dice "Nuestra version de BMAD" — corregir con: `gh repo edit ArmandoMedina/jidoka --description "Jidoka - el Sistema de Produccion Toyota para agentes de IA. Gates deterministas fuera del LLM + revision por demo visual. npx jidoka init"`

> Nota de flujo: `git push` a public lo bloquea el clasificador de modo automático; los pushes los corres tú con `!` (o das permiso a `gh`).
