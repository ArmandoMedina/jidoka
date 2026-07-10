# HANDOFF — relevo entre sesiones

> Estado en vuelo y pendientes. **Se llena al cerrar**, **se lee y se limpia al abrir.** Nada de memorias de la IA — todo va aquí.

## En una frase

**Jidoka** — el Sistema de Producción Toyota para agentes de IA: fusión de doctrina + método + ritual de sprint. Instalador `npx jidoka-method init` en camino (Sprint 3, ver `ROADMAP.md`). Se construye por sprints, usando su propio ritual (dogfooding).

## Dónde estamos (2026-07-10, cierre de la sesión de auditoría y vitrina)

- **Sprints 0, 1, 1.5 y el exprimido final del linaje (PR #4): MERGEADOS y PUBLICADOS.** Tags `v0.1.0-beta` → `v0.3.0-beta` en releases; `main` protegido (require PR + check `andon` required + no bypass). Los repos de método del linaje quedaron archivados; los 2 casos de éxito siguen vivos (sus pendientes viven en SUS HANDOFFs, no aquí).
- **Sesión de hoy (auditoría externa + vitrina pública):** una auditoría de terceros corrió el motor (self-test 6/6) y lo comparó contra el panorama 2026 (Spec Kit, BMAD, Agent OS); veredicto: el diferenciador real es el muro server-side, las 5 grietas encontradas quedaron en `ROADMAP.md` → *Grietas de la auditoría externa*. Además se preparó la vitrina: Ko-fi/FUNDING, template de PR con disparos, templates de issues — detalle en `ROADMAP.md` → *Vitrina pública* (hecho ✅ / pendiente ⏳ con receta).
- **Sesión consolidada y versionada**: la vitrina + auditoría viajó en su PR, se mergeó con orden nombrada del cliente y se publicó como `v0.4.0-beta` (que también libera el exprimido final, ADR 0005, que esperaba en `[Sin publicar]`).
- **Sprint 2 sigue sin plan.** El alcance está en `ROADMAP.md` y la especificación fina en el ADR 0005. Debe **zanjar la contradicción del plan efímero** (deuda heredada, ADR 0005).

## Autorizaciones vigentes del cliente (dichas con nombre, 2026-07-10)

- **Publicar releases de GitHub**: "Eres libre y autorizado para publicar versiones" — el ritual tag + release del cierre de sprint no necesita re-autorización.
- **Merges de PR y cambios de configuración/permisos**: SIGUEN necesitando orden nombrada cada vez ("no me muevas configuración", dicho explícito).

## Checklist humana (el cordón es tuyo)

- [ ] **Grabar el GIF del gate mordiendo** — guion paso a paso en `ROADMAP.md` → *Vitrina pública* ⏳1. La pieza más valiosa antes de compartir el repo.
- [ ] **Social preview** (solo se puede desde la UI) — receta en `ROADMAP.md` → *Vitrina pública* ⏳2.
- [ ] **Dos decisiones que solo tú puedes tomar**: el párrafo en inglés del README y el ADR de la licencia (MIT vs copyleft) — argumentos completos en `ROADMAP.md` → *Vitrina pública* ⏳4 y ⏳5.
- [ ] **Aprobar el plan del Sprint 2** cuando la IA lo presente (modo plan).

## Qué sigue (en orden de valor — detalle en ROADMAP.md)

1. **Rematar los ⏳ de *Vitrina pública*** que no requieran humano (CODE_OF_CONDUCT, preparar archivos del GIF).
2. **Sprint 2 — El ritual Kanban ejecutable**: comandos `/jidoka:*`, skills-asiento, `gemba-stop` + `review-stop`, auditor del grafo, `product_avisa` — y las grietas 1, 2 y 5 de la auditoría, que tienen destino Sprint 2.
3. **Sprint 3 — El instalador**; **Sprint 4 — Beta estable** (incluye la grieta 4: evidencia pública del linaje).
