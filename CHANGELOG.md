# Changelog — Jidoka

Formato: [Keep a Changelog](https://keepachangelog.com/es-ES/1.0.0/) · Versionado: [SemVer](https://semver.org/lang/es/).

## [Sin publicar]

### Sprint 1.5 — Vitrina en español + centralización del conocimiento (ADR 0004)
- **Todo en español, a propósito** — decisión de identidad, declarada en el README. Badges, topics, wiki apagada, release `v0.1.0-beta` publicado; el claim del hero ahora es verificable ("este repo se gobierna con su propio Andon").
- **El andamio documentado:** `kanban/lazo.md` (Intención→Construcción→Verificación→Registro), `kanban/jerarquia.md` (QUÉ/CÓMO, 5 niveles, capacidad con Gherkin), `kanban/roles.md` (asiento ≠ skill, model-routing, reglas duras con incidentes) y `kanban/auditoria.md` (el ritual de auditoría en rama).
- **Los porqués de la doctrina:** sus 4 ADRs heredados a `doctrina/decisiones/` (destaca 0002: no API propia como gobierno; 0003: disparos, no lectura).
- **Templates probados al kit** (`kit/.jidoka/templates/`: sprint-plan, sprint-entrega, plan-de-trabajo efímero, adr) y la convención **`qa_runs/`** de evidencia Gemba (artefactos, no actas; `git add -f` de lo citado).
- **Hardening del laboratorio de campo:** ALTO-04 en `andon-stop` (git roto → aviso, no silencio), área `raiz` en la ley (6 áreas), mensajes que enseñan cuándo NO aplican.
- `CONTRIBUTING.md` (flujo + tabla SSOT), `docs/sprints/README.md` (índice-récord), plantilla de ADR con "El camino que NO se toma".

## [0.2.0-beta] — 2026-07-10

### Sprint 1 (cierre) — Auditoría del motor (ADR 0003)
- **El verificador falla cerrado:** si git no puede calcular el rango (base inexistente, historia incompleta), exit 2 con `[ERROR]` — antes aprobaba a ciegas. Self-test ampliado a 6 casos.
- **El juez viaja en la base:** el check `andon` de CI ejecuta la ley y el verificador de la rama base — un PR ya no puede editar la ley que lo juzga.
- **`jidoka-method`:** el paquete anunciado deja de ser `jidoka` (nombre ocupado en npm por un tercero desde 2017).
- Rama default renombrada a `main`; `.gitattributes` gobierna line endings (hooks LF, ps1 CRLF); `andon-stop` entrega su mensaje completo en `reason`; `ROADMAP.md` con los sprints 2–4; `andon/README.md` gana "Fronteras del muro" y el encendido completo de branch protection; README con tabla "Dónde va la beta" (evidencia, no palabra).
- Exactitud: los disparos son **12**, no 13 (nunca se contaron contra el artefacto); rutas del disparo `anti-memoria` actualizadas.

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
- Los 12 disparos sembrados en `kit/.jidoka/disparos/`. *(Esta línea decía "13"; el conteo real contra el artefacto es 12 — corregido en el cierre del Sprint 1.)*
