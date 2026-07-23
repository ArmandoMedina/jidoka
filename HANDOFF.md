# HANDOFF — relevo entre sesiones

> Estado en vuelo y pendientes. **Se llena al cerrar**, **se lee y se limpia al abrir.** Contrato del relevo (FLU-1): **1 sección «Dónde estamos» + máximo 2 históricas + techo de líneas** — lo hace cumplir el check `[contrato-handoff]` de `tools/verificar.ps1` (límites en `tools/flujo.json`). Lo cerrado se archiva ÍNTEGRO en [`docs/handoff-historico.md`](docs/handoff-historico.md), que **no se inyecta al abrir**. Nada de memorias de la IA — todo va aquí.

## En una frase

**Jidoka** — el Sistema de Producción Toyota para agentes de IA: fusión de doctrina + método + ritual de sprint. Estable en `v1.x`. Instalador PowerShell + CLI `npx jidoka-method` construido (pendiente `npm publish`). Se construye por sprints, usando su propio ritual (dogfooding).

## Dónde estamos (2026-07-22 — Sprint 26 «La 2.0 estable» · CERRADO: mergeado PR #127, `v1.31.0` liberada · la etiqueta «2.0» NO se declaró)

**El sprint TERMINÓ (3/3 + review + Gemba aceptado) y se cerró con orden nombrada del cliente** (merge + release + poda). Salió como **`v1.31.0`** — decisión del cliente al cierre: los mecanismos no bastan para la etiqueta «estable»; la declara él, no un sprint. Récord completo: [`sprint-26-la-2-0-estable-entrega.md`](docs/sprints/sprint-26-la-2-0-estable-entrega.md) (con cuadro de cierre). Dos reglas nuevas de la sesión, ya operativas: **toda superficie del gobierno debe ser la app** (linterna descartada, ADR 0043 reemplazado) y **ninguna frase textual del cliente va al repo público** (barrido hecho; la historia de la rama se reescribió antes del merge).

**Qué sigue (en orden de valor):**
1. **Sprint 27 — la ola de UI** (ya decidido): la app dice la verdad por documento (4 ledgers) · pantalla del mapa de enforcement · parametrizar secciones (`-Requeridas` + ADR no-clobber). Ahí se retira `estado-gobierno.ps1` y el tablero interino.
2. **Bajar el batch a los labs** — vence **2026-08-04** (el único reloj).
3. Cola del cliente: decidir el barrido de citas textuales de sesiones ANTERIORES (`docs/handoff-historico.md`, contexto del ADR 0043) — hoy solo se limpió lo de esta sesión.

## Dónde estuvimos (2026-07-22 — Sprint 26, la construcción · el detalle ÍNTEGRO vive en la entrega y el LOG)

Plan-contrato [`sprint-26-la-2-0-estable-plan.md`](docs/sprints/sprint-26-la-2-0-estable-plan.md), nacido de 4 escaneos `arquitecto` ([`escaneo-camino-2.0-202607.md`](docs/analisis/escaneo-camino-2.0-202607.md); 8 ítems al ROADMAP). R1 corte honesto (os `win32`, badge gateado, aviso del muro) · R2 fiabilidad (`probar-gemelas` estrenó en rojo con 3 drifts reales curados; `auditar` fail-closed; salvavidas ampliado) · R3 superficies (`conformidad-docs.html` interino; [`matriz-carriles-202607.md`](docs/analisis/matriz-carriles-202607.md)) · review adversarial 2M+2B curados. Evidencia rojo→verde: [`qa_runs/la-2-0-estable-20260722/LOG.md`](qa_runs/la-2-0-estable-20260722/LOG.md).

## Dónde estuvimos (2026-07-22 — Sprint 25 + consolidación · MERGEADOS, `v1.30.0`, PR #126)

**El molde único de sprints/`qa_runs` (ADR 0056) y la consolidación `v1.29.0` llegaron a `main` en el PR #126**; los 2 Gembas (`flu-1`, `molde-sprints-qa`) aceptados con nombre el 2026-07-22 en `flujo.json`. Récord: [`sprint-25-molde-sprints-qa-entrega.md`](docs/sprints/sprint-25-molde-sprints-qa-entrega.md). Nota: `qa_runs/` ya no versiona el bulto — lo citado se agrega con `git add -f` (regla en `.gitignore`/`qa_runs/README.md`).

## Autorizaciones vigentes del cliente (dichas con nombre)

- **Publicar releases de GitHub** (2026-07-10): «Eres libre y autorizado para publicar versiones» — tag + release del cierre no necesita re-autorización.
- **Merges de PR y cambios de configuración/permisos**: SIGUEN necesitando orden nombrada cada vez («no me muevas configuración», dicho explícito).
