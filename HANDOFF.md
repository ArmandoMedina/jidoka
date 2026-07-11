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
- **Sprint 3 · Fase 3.A — CONSTRUIDA, en PR #8 (candidato `v0.7.0-beta`), CI verde.** Rama `sprint-3a-instalador`. `tools/instalar.ps1` siembra el método en un repo destino (Windows-first, PowerShell, arquetipo `docs-as-code`, no-clobber). Smoke `probar-instalador.ps1` verde. Hallazgo fundacional: el `project-starter` (ancestro) **no tenía instalador** (sembraba con "Use this template") — el acto de sembrar es invención de Jidoka. Decisión: MVP PowerShell que lee del árbol sin duplicar la ley (ADR 0008); el npm CLI + multiplataforma quedan diferidos. **Falta:** que el cliente lo pruebe en su VM (`./tools/instalar.ps1 -Destino <repo-limpio>`) + **orden nombrada de merge** + release `v0.7.0-beta`.
- **Sprint 3 · Fase 3.B — CONSTRUIDA, en PR #9 (candidato `v0.8.0-beta`), CI verde.** El instalador pregunta el arquetipo y siembra distinto (matriz como manifiesto ejecutable). **Podado a 2 arquetipos** (`docs-as-code` + `code-first`; `doc-only` diferido) por una decisión **delegada-revisable** del cliente (ADR 0009) tras preguntar por sobreingeniería — se aplicó la regla 2–3. Los 12 templates de producto portados como librería *menú*. Smoke x2 (12 casos). **Falta:** orden nombrada de merge + release `v0.8.0-beta`.
- **HOMOLOGACIÓN (una sola metodología entre Jidoka, SGI y TF) — EN CURSO.**
  - **Etapa 1 — CONSTRUIDA, en PR #10 (candidato `v0.9.0-beta`), CI verde.** Jidoka se vuelve el superset del método: asiento `devops` en el roster, el modo desatendido generalizado (`kanban/desatendido.md` + `/jidoka:desatendido`), y el modelo de casting neutral+persona (ADR 0010). El diagnóstico de delta (2 agentes) confirmó que en el motor Jidoka YA es la versión más nueva de los labs; solo faltaban esas piezas. **Falta:** orden nombrada de merge + release `v0.9.0-beta`.
  - **Etapa 2 — PENDIENTE (que SGI y TF adopten el núcleo de Jidoka).** Cada lab, en rama, reversible, conservando su casting como **personas** (Mariana/Charbel/Ahiram/Oscar sobre maquinaria neutral) y su config-instancia (áreas de ley `fantasma/`/PWA, su grafo, sus ADRs). Un lab a la vez, su propio plan. Decisión de casting: **neutral en la maquinaria, nombres como personas** (revisable). Diferido a la Etapa 2: el instalador pregunta neutral/nombres; las barreras de stack (lint/tests) quedan como config code-first de cada lab; `auditar-radius` descartado (redundante con `verificar -Base`).
- **Sprint 3 · Fase 3.C — lo diferido:** el arquetipo `doc-only`/regulado, la matriz de piezas más fina, el CLI npm + SSOT de versión + release-CI + ensayo del empaquetado, multiplataforma (`.sh`/`pwsh`), barreras code-first de stack, y el dogfood completo del ADR 0003. Las VMs del equipo son el ambiente ideal para probar el instalador.

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
