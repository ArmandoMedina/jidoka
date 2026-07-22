# HANDOFF — relevo entre sesiones

> Estado en vuelo y pendientes. **Se llena al cerrar**, **se lee y se limpia al abrir.** Contrato del relevo (FLU-1): **1 sección «Dónde estamos» + máximo 2 históricas + techo de líneas** — lo hace cumplir el check `[contrato-handoff]` de `tools/verificar.ps1` (límites en `tools/flujo.json`). Lo cerrado se archiva ÍNTEGRO en [`docs/handoff-historico.md`](docs/handoff-historico.md), que **no se inyecta al abrir**. Nada de memorias de la IA — todo va aquí.

## En una frase

**Jidoka** — el Sistema de Producción Toyota para agentes de IA: fusión de doctrina + método + ritual de sprint. Estable en `v1.x`. Instalador PowerShell + CLI `npx jidoka-method` construido (pendiente `npm publish`). Se construye por sprints, usando su propio ritual (dogfooding).

## Dónde estamos (2026-07-22 — PR único de consolidación `consolida-tuberia-adrs-20260722` · dos sprints + el fix, todo hacia `v1.29.0` · listo para push)

**Un solo PR consolida sobre `main` (v1.28.0) dos sprints paralelos ya construidos y verdes + un fix — por orden del cliente ("todos los cambios a un solo PR").**

1. **El molde único de los ADRs (ADR 0050, MINOR):** guardián residente `tools/probar-adrs.ps1` que **BLOQUEA** (5 secciones canónicas + estado header↔índice + huérfanos; self-test 9/9; falla-suave sin ADRs), los 49 ADRs alineados al molde sin reescribir decisiones (0044 corregido), molde `0000` ↔ kit reconciliado, cableado a `andon.yml`+`publicar.ps1`+sembrado. Récord: [`sprint-molde-adrs-entrega.md`](docs/sprints/sprint-molde-adrs-entrega.md).
2. **La tubería = mapa completo del repo (ADR 0051, MINOR):** `tuberia-datos.ps1` deriva el censo de las carpetas — 49 piezas a mano → 360 = `git ls-files` exacto; `probar-app.ps1` 41/41; **2 Gembas del cliente aprobados**. Récord: [`sprint-tuberia-por-carpetas-entrega.md`](docs/sprints/sprint-tuberia-por-carpetas-entrega.md).
3. **Fix de encoding de la foto (PATCH):** los 5 emits a stdout escriben bytes UTF-8 crudos (`Emit-Utf8Json`); ya no cae a CP437. `probar-app.ps1` endurecido. Evidencia: `qa_runs/curas-tuberia-20260722/LOG.md`.

**Reconciliación hecha en la rama:** el ADR de tubería se renumeró **0050 → 0051** (el sprint de ADRs se quedó con 0050); versión unificada **`v1.29.0`**; CHANGELOG y HANDOFF fusionados bajo un solo corte y el HANDOFF migrado al contrato FLU-1. FLU-1 (`v1.28.0`, ADR 0049) ya está en `main` (PR #122) — deja de estar suelto.

**Cola de decisiones del cliente:**
1. **[PENDIENTE] Gemba** de ambos sprints sin terminal (ADRs: `conformidad-adrs.html` + ojear 0044/0001/0028; tubería: abrir la app y ver el censo completo). La fidelidad de la tubería ya la aprobó en 2 Gembas.
2. **[PENDIENTE] Merge del PR + release `v1.29.0`** con **orden nombrada** (los merges la siguen necesitando).
3. **[PENDIENTE] Cerrar la PR #124** (la de ADRs, del otro agente) apuntando a este PR consolidado — su trabajo viaja aquí.

**Follow-ups técnicos (nada bloquea):** aristas reales de la tubería (otro sprint) · latencia ~2s del refresco · `textContent` para nombres derivados en la UI · adelgazar `tuberia-piezas.json` a overrides · reconciliar `~/.claude/skills/adr-helper` (higiene local) · restaurar `instalar.ps1`/`probar-instalador.ps1` si el AV los dejó en cuarentena (intactos en git).

## Dónde estuvimos (2026-07-22 — «El pilar de flujo» FLU-1 · MERGEADO A `main`, `v1.28.0`, PR #122)

**FLU-1 (el pilar JIT) se construyó (9/9 rebanadas verdes) y se MERGEÓ a `main`** (PR #122, `v1.28.0`, ADR 0049) — su ADR se renumeró 0045→0049 al reconciliar (main tomó 0045-0048). Introdujo los contratos con gate de HANDOFF/ROADMAP/CHANGELOG (`tools/flujo.json`), la expiración a `MUERTOS.md`, el límite WIP y la vista `estado-flujo`. Plan/entrega: [`sprint-pilar-de-flujo-plan.md`](docs/sprints/sprint-pilar-de-flujo-plan.md). **Kaizen vigente:** ante «voy más lento que tú», el agente por defecto se detiene — el ritmo lo marca quien absorbe.

## Dónde estuvimos (2026-07-21 — «La app de la tubería» · MERGEADO Y LIBERADO `v1.27.0`, PR #121)

**El sprint "La app de la tubería" TERMINÓ (7/7)**, mergeado y liberado el 2026-07-22 con orden nombrada. La superficie del gobierno es ahora una **app de escritorio Tauri fiel a la maqueta** (ADR 0048); la extensión VS Code se retiró (`v1.26.0` subsumida, PR #120). Récord: [`sprint-app-tuberia-entrega.md`](docs/sprints/sprint-app-tuberia-entrega.md). **[PENDIENTE del cliente] Gemba end-to-end** (la fidelidad de R2 ya la aprobó; el flujo completo no). Pendientes técnicos (nada bloquea): cert Authenticode del `.exe`, autoría de ligas en la app, atlas de los tools nuevos, multiplataforma del motor (fase 2).

## Autorizaciones vigentes del cliente (dichas con nombre)

- **Publicar releases de GitHub** (2026-07-10): «Eres libre y autorizado para publicar versiones» — tag + release del cierre no necesita re-autorización.
- **Merges de PR y cambios de configuración/permisos**: SIGUEN necesitando orden nombrada cada vez («no me muevas configuración», dicho explícito).
