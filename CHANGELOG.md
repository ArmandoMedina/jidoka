# Changelog — Jidoka

Formato: [Keep a Changelog](https://keepachangelog.com/es-ES/1.0.0/) · Versionado: [SemVer](https://semver.org/lang/es/).

## [Sin publicar]

### Sprint 1 — El motor Andon (dogfooding)
- Motor de gate en `tools/`: `blast-radius.json` (la ley), `verificar.ps1` (avisa/bloquea) y `probar-gate.ps1` (self-test con caso que DEBE bloquear).
- Hooks locales en `.claude/`: `no-memorias-pretooluse` (deny a memorias, todo al repo) y `andon-stop` (frena el cierre ante doc-drift), cableados en `settings.json`.
- Muro server-side: workflow `andon` (CI en `windows-latest`) + `.githooks/pre-push` (UX local, saltable).
- **La ley con un bloqueo real:** un ADR nuevo debe listarse en `docs/decisions/README.md` o el push se detiene (único `doc_bloquea`; el resto avisa — doctrina anti-fatiga). Ver ADR 0002.
- `andon/README.md` deja de ser solo doctrina: mapea el motor concreto y cómo encenderlo (hooks + required check).

## [0.1.0-beta] — 2026-07-10

### Sprint 0 — Esqueleto + identidad
- Repo público con historial limpio (ADR 0001).
- README con el pitch (Sistema de Producción Toyota para IA), el linaje de aviación destacado (AF447, Airbus/Boeing → deny/ask, Bainbridge) y los diferenciadores propios.
- **Licencia MIT** — permisiva, para máxima adopción.
- Doctrina embebida (`doctrina/`, 9 documentos, self-contained) desde el linaje poka-yoke.
- Índices del sistema TPS: `kanban/` (ritual de sprint), `andon/` (gates deterministas).
- Los 13 disparos sembrados en `kit/.jidoka/disparos/`.
