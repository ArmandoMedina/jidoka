# HANDOFF — relevo entre sesiones

> Estado en vuelo y pendientes. **Se llena al cerrar**, **se lee y se limpia al abrir.** Nada de memorias de la IA — todo va aquí.

## En una frase

**Jidoka** — el Sistema de Producción Toyota para agentes de IA: fusión de doctrina + método + ritual de sprint. Instalador `npx jidoka-method init` en camino (Sprint 3, ver `ROADMAP.md`). Se construye por sprints, usando su propio ritual (dogfooding).

## Dónde estamos (2026-07-10, exprimido final del linaje)

- **Sprints 0, 1 y 1.5: MERGEADOS y PUBLICADOS.** Tags y releases `v0.1.0-beta`, `v0.2.0-beta`, `v0.3.0-beta` en https://github.com/ArmandoMedina/jidoka/releases. `main` protegido (require PR + check `andon` required + no bypass). El PR de relevo (#3) ya se mergeó.
- **El exprimido final del linaje viaja en su PR** (rama `exprimido-final-del-linaje`, ADR 0005): 4 agentes exprimieron los 4 repos letra por letra; todo el conocimiento faltante ascendió. Los 2 repos de **método** (doctrina y andamio) quedan **archivados con lápida**; los 2 **casos de éxito** siguen vivos (orden del cliente: "no es una migración, construimos una metodología").
- **Sprint 2 NO tiene plan aún.** El alcance está en `ROADMAP.md` y la especificación fina en el ADR 0005 — la próxima sesión arranca ahí: modo plan → plan del Sprint 2 → aprobación del cliente → construir. Ojo: el Sprint 2 debe **zanjar la contradicción del plan efímero** (ADR 0005, deuda heredada).

## Autorizaciones vigentes del cliente (dichas con nombre, 2026-07-10)

- **Publicar releases de GitHub**: "Eres libre y autorizado para publicar versiones" — el ritual tag + release del cierre de sprint no necesita re-autorización.
- **Merges de PR y cambios de configuración/permisos**: SIGUEN necesitando orden nombrada cada vez ("no me muevas configuración", dicho explícito).

## Checklist humana (el cordón es tuyo)

- [ ] **Merge del PR del exprimido final** (`exprimido-final-del-linaje` → `main`) — conocimiento y registro, sin maquinaria nueva.
- [ ] **Social preview** del repo (Settings → General → Social preview, imagen 1280×640 px): solo se puede desde la UI. La IA puede generarte una provisional; el banner definitivo es del Sprint 4.
- [ ] **Aprobar el plan del Sprint 2** cuando la IA lo presente (modo plan).
- [ ] **Pendientes de los casos de éxito (viven en SUS repos, no aquí):** el tracker tiene el PR #4 (Sprint 6) abierto, producción sirviendo una versión vieja del SW, y la purga de previews con datos filtrados sin evidencia de ejecutada; el laboratorio tiene decisiones "de oído" pendientes en su HANDOFF. Nada de eso bloquea a Jidoka.

## Qué sigue (en orden de valor — detalle en ROADMAP.md)

1. **Sprint 2 — El ritual Kanban ejecutable:** comandos `/jidoka:*` (incl. `/jidoka:arranca` y `/jidoka:que-sigue`), skills-asiento, `gemba-stop` + `review-stop`, auditor del grafo, `product_avisa`. El conocimiento ya está en `kanban/` y el inventario en el ADR 0004 — solo falta volverlo máquina.
2. **Sprint 3 — El instalador** `jidoka-method` + kit completo + gemelos `.sh` + `setup -Yes` + CI de release; decisión abierta ADR 0003: el motor vive solo en `kit/` y este repo se instala su propio kit.
3. **Sprint 4 — Beta estable:** guías, banner/social preview definitivos, decisión de comunidad (Discussions/Discord).
