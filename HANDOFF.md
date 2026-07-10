# HANDOFF — relevo entre sesiones

> Estado en vuelo y pendientes. **Se llena al cerrar**, **se lee y se limpia al abrir.** Nada de memorias de la IA — todo va aquí.

## En una frase

**Jidoka** — el Sistema de Producción Toyota para agentes de IA: fusión de doctrina + método + ritual de sprint. Instalador `npx jidoka-method init` en camino (Sprint 3, ver `ROADMAP.md`). Se construye por sprints, usando su propio ritual (dogfooding).

## Dónde estamos (2026-07-10)

- **Sprint 0 — Identidad: HECHO y PÚBLICO.** https://github.com/ArmandoMedina/jidoka, tag `v0.1.0-beta` (release publicado).
- **Sprint 1 — Motor Andon: en Revisión (PR #1), cierre auditado, check `andon` verde, `main` protegido** (require PR + check required + no bypass — hecho por la IA vía API, verificado).
- **Sprint 1.5 — Vitrina + centralización del conocimiento: CONSTRUIDO en rama `sprint-1.5-vitrina-y-conocimiento`** (ADR 0004). Vitrina ES con bandera; `kanban/lazo|jerarquia|roles|auditoria`; 4 ADRs de doctrina heredados; templates + `qa_runs/` al kit; ALTO-04 + área `raiz` (probar-gate 6/6). PR #2 se abre **después** del merge del PR #1.

## Checklist humana (el cordón es tuyo — nada de esto lo hace la IA)

- [x] ~~Branch protection de `main`~~ — hecha y verificada (2026-07-10).
- [x] ~~Publicar el release `v0.1.0-beta`~~ — publicado por el cliente (2026-07-10): <https://github.com/ArmandoMedina/jidoka/releases/tag/v0.1.0-beta>.
- [ ] **Merge del PR #1** cuando el Gemba te convenza (pasos en `docs/sprints/sprint-1-plan.md` § Verificación).
- [ ] Al mergear PR #1: mover del CHANGELOG las secciones de Sprint 1 a `[0.2.0-beta]` y taggear.
- [ ] **Abrir PR #2** (`sprint-1.5-vitrina-y-conocimiento` → `main`) tras el merge del #1 — estreno real del juez-desde-la-base.
- [ ] **Social preview** del repo (Settings → General → Social preview): solo se puede desde la UI. Banner definitivo = Sprint 4.

## Qué sigue (en orden de valor — detalle en ROADMAP.md)

1. **Sprint 2 — El ritual Kanban ejecutable:** comandos `/jidoka:*` (incl. `/jidoka:arranca` y `/jidoka:que-sigue`), skills-asiento, `gemba-stop` + `review-stop`, auditor del grafo, `product_avisa`. El conocimiento ya está en `kanban/` — solo falta volverlo máquina.
2. **Sprint 3 — El instalador** `jidoka-method` + kit completo + gemelos `.sh` + `setup -Yes` + CI de release; decisión abierta ADR 0003: el motor vive solo en `kit/` y este repo se instala su propio kit.
3. **Sprint 4 — Beta estable:** guías, banner/social preview definitivos, decisión de comunidad (Discussions/Discord).
