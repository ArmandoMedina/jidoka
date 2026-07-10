# HANDOFF — relevo entre sesiones

> Estado en vuelo y pendientes. **Se llena al cerrar**, **se lee y se limpia al abrir.** Nada de memorias de la IA — todo va aquí.

## En una frase

**Jidoka** — el Sistema de Producción Toyota para agentes de IA: fusión de doctrina + método + ritual de sprint. Instalador `npx jidoka-method init` en camino (Sprint 3, ver `ROADMAP.md`). Se construye por sprints, usando su propio ritual (dogfooding).

## Dónde estamos (2026-07-10, cierre de la sesión de auditoría y vitrina)

- **Sprints 0, 1, 1.5 y el exprimido final del linaje (PR #4): MERGEADOS y PUBLICADOS.** Tags `v0.1.0-beta` → `v0.3.0-beta` en releases; `main` protegido (require PR + check `andon` required + no bypass). Los repos de método del linaje quedaron archivados; los 2 casos de éxito siguen vivos (sus pendientes viven en SUS HANDOFFs, no aquí).
- **Sesión de hoy (auditoría externa + vitrina pública):** una auditoría de terceros corrió el motor (self-test 6/6) y lo comparó contra el panorama 2026 (Spec Kit, BMAD, Agent OS); veredicto: el diferenciador real es el muro server-side, las 5 grietas encontradas quedaron en `ROADMAP.md` → *Grietas de la auditoría externa*. Además se preparó la vitrina: Ko-fi/FUNDING, template de PR con disparos, templates de issues — detalle en `ROADMAP.md` → *Vitrina pública* (hecho ✅ / pendiente ⏳ con receta).
- **Sesión consolidada y versionada**: la vitrina + auditoría viajó en su PR, se mergeó con orden nombrada del cliente y se publicó como `v0.4.0-beta` (que también libera el exprimido final, ADR 0005, que esperaba en `[Sin publicar]`).
- **Sprint 2 · Fase A — CONSTRUIDA, en PR (candidato `v0.5.0-beta`).** Rama `sprint-2a-ritual-ejecutable`. Entregó los 5 comandos `/jidoka:*`, las 4 skills-asiento, el área `ritual` en la ley (self-test 7/7) y el **ADR 0006** que zanja la contradicción del plan efímero (hogar persistente gitignored `/.jidoka/plan-actual.md`). El plan archivado en `docs/sprints/sprint-2a-plan.md`. **Falta:** que el cliente corra el demo Gemba (sección Verificación del plan) y dé la **orden nombrada de merge**; luego el release `v0.5.0-beta`.
- **Sprint 2 · Fase A — MERGEADA y PUBLICADA (`v0.5.0-beta`).** El ritual ejecutable está en `main`.
- **Sprint 2 · Fase B — CONSTRUIDA, en PR #7 (candidato `v0.6.0-beta`), CI verde.** Rama `sprint-2b-muros`. Entregó `review-stop`, `gemba-stop`, el auditor del grafo (`tools/auditar.ps1`), la dimensión `product_avisa`, la **grieta 1** cerrada (avisos al summary del PR), el harness `probar-hooks.ps1`/`probar-auditor.ps1`, y un grafo `product/` sembrado. **Todo cosechado de los labs** (homologación, ADR 0007). Corrí `/code-review`: 5 bordes de baja severidad registrados como límites conocidos en el ADR 0007. **Falta:** tu **orden nombrada de merge** + release `v0.6.0-beta`.
- **HALLAZGO CLAVE de la sesión (2026-07-10):** los dos casos de éxito (`SimGhostInputs`, `tracker-financiero`) están **más avanzados que Jidoka** — son sus papás, no destinos de instalación. La dirección correcta es **labs → Jidoka** (homologación, ADR 0005), nunca Jidoka pisando los labs. El cliente quiso instalar Jidoka en ellos; se frenó y se redirigió a la cosecha. Registrado en `product/recursos-del-proyecto.md`.
- **Grietas de auditoría restantes:** grieta 1 CERRADA (Fase B). Siguen abiertas la **grieta 2** (`no-memorias` solo `Write|Edit`, no Bash — documentada como frontera en `andon/README.md`) y la **grieta 5** (disparos sin cablear — cada hook nuevo ya consume los suyos, pero quedan catálogo sin punto de inyección). Ver `ROADMAP.md`.
- **Sprint 3 — el instalador `npx jidoka-method init`.** Los labs NO tienen sembrador (se homologaron de un *starter*, `C:/Repositorios/project-starter/`) — ese es el ancestro a estudiar para el instalador.

## Autorizaciones vigentes del cliente (dichas con nombre, 2026-07-10)

- **Publicar releases de GitHub**: "Eres libre y autorizado para publicar versiones" — el ritual tag + release del cierre de sprint no necesita re-autorización.
- **Merges de PR y cambios de configuración/permisos**: SIGUEN necesitando orden nombrada cada vez ("no me muevas configuración", dicho explícito).

## Checklist humana (el cordón es tuyo)

- [ ] **Grabar el GIF del gate mordiendo** — guion paso a paso en `ROADMAP.md` → *Vitrina pública* ⏳1. La pieza más valiosa antes de compartir el repo.
- [ ] **Social preview** (solo se puede desde la UI) — receta en `ROADMAP.md` → *Vitrina pública* ⏳2.
- [ ] **Dos decisiones que solo tú puedes tomar**: el párrafo en inglés del README y el ADR de la licencia (MIT vs copyleft) — argumentos completos en `ROADMAP.md` → *Vitrina pública* ⏳4 y ⏳5.
- [x] **Aprobar el plan del Sprint 2 · Fase A** — aprobado en plan mode (2026-07-10).
- [ ] **Correr el demo Gemba de la Fase A** (sección Verificación de `docs/sprints/sprint-2a-plan.md`) y dar la **orden nombrada de merge** del PR; luego release `v0.5.0-beta`.

## Qué sigue (en orden de valor — detalle en ROADMAP.md)

1. **Rematar los ⏳ de *Vitrina pública*** que no requieran humano (CODE_OF_CONDUCT, preparar archivos del GIF).
2. **Sprint 2 — El ritual Kanban ejecutable**: comandos `/jidoka:*`, skills-asiento, `gemba-stop` + `review-stop`, auditor del grafo, `product_avisa` — y las grietas 1, 2 y 5 de la auditoría, que tienen destino Sprint 2.
3. **Sprint 3 — El instalador**; **Sprint 4 — Beta estable** (incluye la grieta 4: evidencia pública del linaje).
