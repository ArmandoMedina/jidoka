# HANDOFF — relevo entre sesiones

> Estado en vuelo y pendientes. **Se llena al cerrar**, **se lee y se limpia al abrir.** Contrato del relevo (FLU-1): **1 sección «Dónde estamos» + máximo 2 históricas + techo de líneas** — lo hace cumplir el check `[contrato-handoff]` de `tools/verificar.ps1` (límites en `tools/flujo.json`). Lo cerrado se archiva ÍNTEGRO en [`docs/handoff-historico.md`](docs/handoff-historico.md), que **no se inyecta al abrir**. Nada de memorias de la IA — todo va aquí.

## En una frase

**Jidoka** — el Sistema de Producción Toyota para agentes de IA: fusión de doctrina + método + ritual de sprint. Estable en `v1.x`. Instalador PowerShell + CLI `npx jidoka-method` construido (pendiente `npm publish`). Se construye por sprints, usando su propio ritual (dogfooding).

## Dónde estamos (2026-07-22 — Sprint 25 «El molde único de sprints y `qa_runs`» · construido y verde · `v1.30.0` · rama `sprint/molde-sprints-qa-20260722`, apilada sobre la consolidación)

**El molde de sprints/`qa_runs`/módulos/dominios se homologó extendiendo el motor genérico `estado-docs.ps1` por datos (ADR 0056), no clonando guardianes ni con un monolito.** Construcción R1–R4 + reworks verde de punta a punta: **50 CONFORME, 0 DESVIADO**; self-tests `probar-docs` 39/39, `probar-adrs` 14/14, `probar-auditor` 13/13; `verificar` exit 0.

1. **R1 — motor por glob-familia:** el ledger acepta globs (`docs/sprints/*-plan.md`, `qa_runs/*/LOG.md`); guarda del verde mentiroso (`[FAMILIA VACIA]`).
2. **R2 — sprints numerados + molde + generación:** los 25 sprints numerados (`sprint-NN`), archivos renombrados, 11 docs homologados (solo encabezados); un sprint nace por `/jidoka:planea` + scaffolder.
3. **R3 — `qa_runs`:** cada `LOG.md` valida Método · Resultados · Veredicto.
4. **R4 — módulos/dominios en su dueño `auditar.ps1`** (no al ledger, ADR 0042); capacidades ya por Gherkin (sin trabajo — el propio template ordena el set mínimo para proyecto chico).
5. **Reworks:** una sola carpeta de ADRs (0052-0055 consolidados), comando `/jidoka:nuevo-sprint` retirado (ADR 0056), cada template atado a su guardián. Récord: [`sprint-25-molde-sprints-qa-entrega.md`](docs/sprints/sprint-25-molde-sprints-qa-entrega.md). Evidencia: `qa_runs/gemba-molde-sprints-qa-20260722-120402/`.

**Apilamiento:** esta rama contiene los commits de la consolidación (`v1.29.0`, PR #125) más el molde (`v1.30.0`). Un solo PR desde ella lleva ambos cortes a `main` (v1.28.0) — encaja con "todos los cambios a un solo PR".

**Cola de decisiones del cliente:**
1. **[PENDIENTE] Gemba del molde** sin terminal (README numerado · dos `-entrega.md` con mismas secciones · dos `LOG.md` · reporte CONFORME/DESVIADO). Registrado en `flujo.json` (`aceptado: false`) — planta a `planea` hasta que lo aceptes con nombre.
2. **[PENDIENTE] Gemba de la consolidación v1.29.0** sin terminal (ADRs: `conformidad-adrs.html`; tubería: abrir la app y ver el censo completo). La fidelidad de la tubería ya la aprobaste en 2 Gembas.
3. **[PENDIENTE] Estrategia de PR + merge + release** con **orden nombrada**: ¿un solo PR (v1.29.0 + v1.30.0 juntos) desde esta rama, o merge escalonado? Cerrar/retargetear PR #124 (ADRs) y #125 (consolidación) según eso.

**Follow-ups técnicos (nada bloquea):** aristas reales de la tubería (otro sprint) · reconciliar `~/.claude/skills/adr-helper` (higiene local) · restaurar `instalar.ps1`/`probar-instalador.ps1` si el AV los dejó en cuarentena (intactos en git).

## Dónde estuvimos (2026-07-22 — «El pilar de flujo» FLU-1 · MERGEADO A `main`, `v1.28.0`, PR #122)

**FLU-1 (el pilar JIT) se construyó (9/9 rebanadas verdes) y se MERGEÓ a `main`** (PR #122, `v1.28.0`, ADR 0049) — su ADR se renumeró 0045→0049 al reconciliar (main tomó 0045-0048). Introdujo los contratos con gate de HANDOFF/ROADMAP/CHANGELOG (`tools/flujo.json`), la expiración a `MUERTOS.md`, el límite WIP y la vista `estado-flujo`. Plan/entrega: [`sprint-22-pilar-de-flujo-plan.md`](docs/sprints/sprint-22-pilar-de-flujo-plan.md). **Kaizen vigente:** ante «voy más lento que tú», el agente por defecto se detiene — el ritmo lo marca quien absorbe.

## Dónde estuvimos (2026-07-21 — «La app de la tubería» · MERGEADO Y LIBERADO `v1.27.0`, PR #121)

**El sprint "La app de la tubería" TERMINÓ (7/7)**, mergeado y liberado el 2026-07-22 con orden nombrada. La superficie del gobierno es ahora una **app de escritorio Tauri fiel a la maqueta** (ADR 0048); la extensión VS Code se retiró (`v1.26.0` subsumida, PR #120). Récord: [`sprint-21-app-tuberia-entrega.md`](docs/sprints/sprint-21-app-tuberia-entrega.md). **[PENDIENTE del cliente] Gemba end-to-end** (la fidelidad de R2 ya la aprobó; el flujo completo no). Pendientes técnicos (nada bloquea): cert Authenticode del `.exe`, autoría de ligas en la app, atlas de los tools nuevos, multiplataforma del motor (fase 2).

## Autorizaciones vigentes del cliente (dichas con nombre)

- **Publicar releases de GitHub** (2026-07-10): «Eres libre y autorizado para publicar versiones» — tag + release del cierre no necesita re-autorización.
- **Merges de PR y cambios de configuración/permisos**: SIGUEN necesitando orden nombrada cada vez («no me muevas configuración», dicho explícito).
