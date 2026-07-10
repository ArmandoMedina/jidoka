# HANDOFF — relevo entre sesiones

> Estado en vuelo y pendientes. **Se llena al cerrar**, **se lee y se limpia al abrir.** Nada de memorias de la IA — todo va aquí.

## En una frase

**Jidoka** — el Sistema de Producción Toyota para agentes de IA: fusión de doctrina + método + ritual de sprint. Instalador `npx jidoka-method init` en camino (Sprint 3, ver `ROADMAP.md`). Se construye por sprints, usando su propio ritual (dogfooding).

## Dónde estamos (2026-07-10)

- **Sprint 0 — Identidad: HECHO y PÚBLICO.** https://github.com/ArmandoMedina/jidoka, tag `v0.1.0-beta` (release publicado).
- **Sprint 1 — Motor Andon: MERGEADO a `main` (PR #1, 2026-07-10)**, cierre auditado, check `andon` verde, `main` protegido (require PR + check required + no bypass). Tag `v0.2.0-beta`.
- **Sprint 1.5 — Vitrina + centralización del conocimiento: en Revisión (PR #2)** (ADR 0004). Vitrina ES con bandera; `kanban/lazo|jerarquia|roles|auditoria`; 4 ADRs de doctrina heredados; templates + `qa_runs/` al kit; ALTO-04 + área `raiz` (probar-gate 6/6). Primer PR juzgado con la ley desde la base (estreno del juez de ADR 0003).

## Checklist humana (el cordón es tuyo — nada de esto lo hace la IA)

- [x] ~~Branch protection de `main`~~ — hecha y verificada (2026-07-10).
- [x] ~~Publicar el release `v0.1.0-beta`~~ — publicado por el cliente (2026-07-10): <https://github.com/ArmandoMedina/jidoka/releases/tag/v0.1.0-beta>.
- [x] ~~Merge del PR #1~~ — mergeado por el cliente (2026-07-10); CHANGELOG movido a `[0.2.0-beta]` y tag puesto.
- [ ] **Merge del PR #2** cuando el Gemba del Sprint 1.5 te convenza (pasos en `docs/sprints/sprint-1.5-plan.md` § Verificación).
- [ ] **Social preview** del repo (Settings → General → Social preview): solo se puede desde la UI. Banner definitivo = Sprint 4.

## Qué sigue (en orden de valor — detalle en ROADMAP.md)

1. **Sprint 2 — El ritual Kanban ejecutable:** comandos `/jidoka:*` (incl. `/jidoka:arranca` y `/jidoka:que-sigue`), skills-asiento, `gemba-stop` + `review-stop`, auditor del grafo, `product_avisa`. El conocimiento ya está en `kanban/` — solo falta volverlo máquina.
2. **Sprint 3 — El instalador** `jidoka-method` + kit completo + gemelos `.sh` + `setup -Yes` + CI de release; decisión abierta ADR 0003: el motor vive solo en `kit/` y este repo se instala su propio kit.
3. **Sprint 4 — Beta estable:** guías, banner/social preview definitivos, decisión de comunidad (Discussions/Discord).
