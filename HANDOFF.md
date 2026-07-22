# HANDOFF — relevo entre sesiones

> Estado en vuelo y pendientes. **Se llena al cerrar**, **se lee y se limpia al abrir.** Contrato del relevo (FLU-1): **1 sección «Dónde estamos» + máximo 2 históricas + techo de líneas** — lo hace cumplir el check `[contrato-handoff]` de `tools/verificar.ps1` (límites en `tools/flujo.json`). Lo cerrado se archiva ÍNTEGRO en [`docs/handoff-historico.md`](docs/handoff-historico.md), que **no se inyecta al abrir**. Nada de memorias de la IA — todo va aquí.

## En una frase

**Jidoka** — el Sistema de Producción Toyota para agentes de IA: fusión de doctrina + método + ritual de sprint. Estable en `v1.x`. Instalador PowerShell + CLI `npx jidoka-method` construido (pendiente `npm publish`). Se construye por sprints, usando su propio ritual (dogfooding).

## Dónde estamos (2026-07-22 — sprint «El molde único de los ADRs» · CONSTRUIDO en worktree aislado · Gemba + PR + release pendientes)

**El QUÉ aprobado (plan mode, 2026-07-22):** los ADRs salen y se mantienen con un molde único, y el mecanismo que lo garantiza deja de ser una skill personal fuera del repo — un **guardián residente que bloquea**. Enfoque del cliente: *"campo completo y alinea de una vez la plantilla… bloquea todo"*. Plan: [`docs/sprints/sprint-molde-adrs-plan.md`](docs/sprints/sprint-molde-adrs-plan.md) · Entrega: [`sprint-molde-adrs-entrega.md`](docs/sprints/sprint-molde-adrs-entrega.md) · Decisión: [ADR 0050](docs/decisions/0050-molde-unico-de-los-adrs.md).

**Las 4 rebanadas CONSTRUIDAS y verdes** (evidencia `qa_runs/adrs-20260722/LOG.md`):
- ✅ R1 molde único (`0000-plantilla.md` ↔ `kit/.jidoka/templates/adr.md`) · R2 guardián `tools/probar-adrs.ps1` (MURO: secciones + estado header↔índice + huérfanos; self-test 9/9; falla-suave sin ADRs).
- ✅ R3 los 49 ADRs alineados sin reescribir decisiones (0044 estado corregido) · R4 cableado a `andon.yml` + `publicar.ps1` + sembrado (mecánica), ADR 0050, tablero `conformidad-adrs.html`.
- ✅ `/code-review` corrido: 6 hallazgos del guardián curados (el clave: no tumbar el CI de un hijo sin ADRs). Suite verde (probar-adrs 9/9, docs 27, flujo 94, gate 14).

**Aislamiento (otro agente en paralelo en FLU-1):** se trabaja en el worktree `C:\Repositorio personal\jidoka-adrs` (rama `review/adrs-20260722`, 4 commits desde `5a464bc`). Lección: rama propia NO basta con un escritor paralelo — hace falta `git worktree add` (un `checkout -b` en el árbol compartido colisionó).

**Falta (cierre del sprint):**
- **Gemba del cliente** (sin terminal): abrir `conformidad-adrs.html` + ojear 0044/0001/0028 + el ADR 0050 (pasos en la entrega).
- **PR + merge (orden nombrada) + release `v1.29.0`** (MINOR) — **coordinar el orden de merge con FLU-1**: FLU-1 toma `v1.28.0`, este sprint `v1.29.0`; deben mergear en ese orden (misma lección del renumerado 0045→0049).
- **Restaurar** `tools/instalar.ps1` y `tools/probar-instalador.ps1` — el AV (Bitdefender) los puso en cuarentena al intentar `-Sellar`; intactos en git (`git checkout HEAD -- <archivos>` cuando el AV libere). El sello no se trackea en Jidoka; el re-sello NO era paso del sprint.
- **Opcional:** reconciliar `~/.claude/skills/adr-helper` (skill personal, `Razones`→`Por qué`) — higiene local fuera del repo.

**Regla de modelos (orden del cliente):** Fable orquesta y pone criterio en el hilo; opus/sonnet/haiku hacen TODA la mecánica en subagentes. Ningún subagente en Fable.

## Dónde estuvimos (2026-07-22 — «El pilar de flujo» FLU-1 · CONSTRUIDO, rama paralela `sprint/pilar-de-flujo-20260721`, aún sin merge)

**FLU-1 (el pilar JIT) está CONSTRUIDO (9/9 rebanadas verdes)** y reconciliado bajo `main` v1.27.0; lo lleva el **agente paralelo**. Su ADR se renumeró 0045→0049 al reconciliar (main tomó 0045-0048); versión objetivo **`v1.28.0`**. Plan/entrega: [`sprint-pilar-de-flujo-plan.md`](docs/sprints/sprint-pilar-de-flujo-plan.md). **Pendiente de FLU-1:** su Gemba (`flu-1-pilar-de-flujo`, `aceptado:false` — planta a `planea`), PR, merge con orden nombrada, release `v1.28.0`. **Kaizen vigente:** ante «voy más lento que tú», el agente por defecto se detiene — el ritmo lo marca quien absorbe.

## Dónde estuvimos (2026-07-21 — «La app de la tubería» · MERGEADO Y LIBERADO `v1.27.0`, PR #121)

**El sprint "La app de la tubería" TERMINÓ (7/7)**, mergeado y liberado el 2026-07-22 con orden nombrada. La superficie del gobierno es ahora una **app de escritorio Tauri fiel a la maqueta** (ADR 0048); la extensión VS Code se retiró (`v1.26.0` subsumida, PR #120). Récord: [`sprint-app-tuberia-entrega.md`](docs/sprints/sprint-app-tuberia-entrega.md). **[PENDIENTE del cliente] Gemba end-to-end** (la fidelidad de R2 ya la aprobó; el flujo completo no). Pendientes técnicos (nada bloquea): cert Authenticode del `.exe`, autoría de ligas en la app, atlas de los tools nuevos, multiplataforma del motor (fase 2).

## Autorizaciones vigentes del cliente (dichas con nombre)

- **Publicar releases de GitHub** (2026-07-10): «Eres libre y autorizado para publicar versiones» — tag + release del cierre no necesita re-autorización.
- **Merges de PR y cambios de configuración/permisos**: SIGUEN necesitando orden nombrada cada vez («no me muevas configuración», dicho explícito).
