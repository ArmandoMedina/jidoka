# HANDOFF — relevo entre sesiones

> Estado en vuelo y pendientes. **Se llena al cerrar**, **se lee y se limpia al abrir.** Nada de memorias de la IA — todo va aquí.

## En una frase

**Jidoka** — el Sistema de Producción Toyota para agentes de IA: fusión de doctrina + método + ritual de sprint. Instalador `npx jidoka-method init` en camino (Sprint 3, ver `ROADMAP.md`). Se construye por sprints, usando su propio ritual (dogfooding).

## Dónde estamos (2026-07-10)

- **Sprint 0 — Identidad: HECHO y PÚBLICO.** https://github.com/ArmandoMedina/jidoka, tag `v0.1.0-beta`.
- **Sprint 1 — Motor Andon: en Revisión (PR #1), cierre auditado.** Una auditoría independiente revisó motor + procedimiento + superficies públicas; sus arreglos están en la misma rama (`sprint-1-andon`): el verificador **falla cerrado**, el CI ejecuta **la ley de la rama base** (ADR 0003), `.gitattributes`, paquete renombrado a `jidoka-method` (el nombre `jidoka` en npm es de un tercero), "12 disparos" (eran 12, no 13), `ROADMAP.md`, fronteras del muro documentadas.
- **Rama default renombrada a `main`** (los docs ya la nombraban). Descripción pública del repo corregida.

## Checklist humana (el cordón es tuyo — nada de esto lo hace la IA)

- [ ] **Branch protection de `main`** (GitHub → Settings → Branches): require PR + check `andon` required + **do not allow bypass**. Sin las tres, no hay muro (ver `andon/README.md` § Encenderlo).
- [ ] **Merge del PR #1** cuando el Gemba te convenza (corre tú los pasos de `docs/sprints/sprint-1-plan.md` § Verificación).
- [ ] Al mergear: mover `[Sin publicar]` del CHANGELOG a `[0.2.0-beta]` y taggear.

## Qué sigue (en orden de valor — detalle en ROADMAP.md)

1. **Sprint 2 — El ritual Kanban ejecutable:** comandos `/jidoka:*` (incl. `/jidoka:que-sigue`), roles, `gemba-stop`, `qa_runs/`, templates con ownership por sección.
2. **Sprint 3 — El instalador** `jidoka-method` + kit completo + gemelos `.sh`; decisión abierta ADR 0003: el motor vive solo en `kit/` y este repo se instala su propio kit.
3. **Sprint 4 — Beta estable:** guías, presentación pública (badges, quick start, banner), decisión de comunidad.
