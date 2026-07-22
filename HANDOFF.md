# HANDOFF — relevo entre sesiones

> Estado en vuelo y pendientes. **Se llena al cerrar**, **se lee y se limpia al abrir.** Contrato del relevo (FLU-1): **1 sección «Dónde estamos» + máximo 2 históricas + techo de líneas** — lo hace cumplir el check `[contrato-handoff]` de `tools/verificar.ps1` (límites en `tools/flujo.json`). Lo cerrado se archiva ÍNTEGRO en [`docs/handoff-historico.md`](docs/handoff-historico.md), que **no se inyecta al abrir**. Nada de memorias de la IA — todo va aquí.

## En una frase

**Jidoka** — el Sistema de Producción Toyota para agentes de IA: fusión de doctrina + método + ritual de sprint. Estable en `v1.x`. Instalador PowerShell + CLI `npx jidoka-method` construido (pendiente `npm publish`). Se construye por sprints, usando su propio ritual (dogfooding).

## Dónde estamos (2026-07-21 — sprint «El pilar de flujo» FLU-1 · CONSTRUIDO, en cierre · PR #122)

**El QUÉ aprobado (plan mode, 2026-07-21):** el pilar JIT de la Casa — los documentos de estado dejan de crecer solos, el trabajo entra con límite, y el avance y el reparto de roles se ven sin terminal. Plan-contrato: [`docs/sprints/sprint-pilar-de-flujo-plan.md`](docs/sprints/sprint-pilar-de-flujo-plan.md). **Apetito: 6 horas de revisión del cliente, muerte por defecto.** Rama: `sprint/pilar-de-flujo-20260721`. Insumos: el diagnóstico y el benchmark en `docs/analisis/`.

**Avance — las 9 rebanadas CONSTRUIDAS y verdes:**
- ✅ **M1**: R1 contrato del HANDOFF (419→40 líneas, gate mordiendo) · R2 contrato del ROADMAP (140→55, 32 vivos en 4 clases) · R3 expiración automática (`expirar.ps1` → `docs/MUERTOS.md`).
- ✅ **M2**: R4 cierre con orden fijo + `[contrato-changelog]` · R5 límite WIP (`estado-flujo.ps1 -Gate` planta a `planea`).
- ✅ **M3**: R6 vista `-Json` + primer hook `SessionStart` · R7 reporte sin jerga con hill chart · R8a reparto (`product/casting.md`: autoridad-del-dominio ≠ dueño-operador) · R8b los 4 asientos piensan distinto («Lo que noté por mi cuenta» obligatorio).
- ✅ Kit cableado (mordida real: los stubs viejos violaban los contratos — un hijo nacía bloqueado; curado, `probar-sembrar` 38/38, `probar-instalador` 67/67) · capacidad `FLU-1` al grafo (`auditar` íntegro) · review adversarial de la rama (MERGEABLE, 6 BAJOS: 4 curados) · PR #122 abierto, primer CI verde.
- ✅ **Dos merges de `main` reconciliados bajo los contratos nuevos**: PR #119 (el descubrimiento) y `v1.27.0` (la app de la tubería) — este último renumeró el sprint: **ADR 0045→0049, versión `v1.26.0`→`v1.28.0`** (main ya había usado ambos números).
- ✅ Suite completa post-merge (16/16 + auditar) · evidencia `qa_runs/flujo-20260721/LOG.md` · **Gemba del sprint REGISTRADO en `flujo.json`** (`flu-1-pilar-de-flujo`, aceptado:false — `planea` queda plantado hasta que el cliente lo acepte: el muro mordiéndose la cola a propósito).
- 🔨 **Falta:** CI del merge con `v1.27.0` en verde · el Gemba del cliente (pasos en el plan, sin terminal) · **merge de PR #122 con orden nombrada**.

**Kaizen vigente:** ante la señal «voy más lento que tú», el agente por defecto se detiene en vez de absorber más trabajo — el ritmo lo marca quien absorbe; el volumen, no.

## Dónde estuvimos (2026-07-21/22 — La app de la tubería · `v1.27.0` MERGEADA Y LIBERADA · PRs #120/#121/#123)

**La superficie del gobierno dejó de ser comandos de VS Code y es una app de escritorio Tauri fiel a la maqueta** (ADR 0048; la extensión se retiró completa). El camino en dos sprints de la otra sesión: «sistema configurable, fase 1» construyó el motor (ADRs 0045–0047: bandeja, estatuto del ritual, candado IA PreToolUse, `contratos.json` con firma) pero **su Gemba reprobó la superficie fragmentada** → giro a la app (`app/`, Jidoka-only, 49 piezas con estado real, formulario que escribe de verdad, firma derivada de `git config`, instalador NSIS como asset del release). Mergeado y liberado el 2026-07-22 con orden nombrada; `v1.26.0` quedó subsumida sin tag propio. Récord: [`sprint-app-tuberia-entrega.md`](docs/sprints/sprint-app-tuberia-entrega.md) · evidencia `qa_runs/app-tuberia-20260721/LOG.md` · secciones íntegras en el [histórico](docs/handoff-historico.md). **Pendientes → clasificados en el ROADMAP** (Gemba end-to-end de la app —espera:cliente—, certificado Authenticode, autoría de ligas en la app, cartones de reconciliar/alta, atlas de los tools nuevos, destino de la copia scratch de la maqueta).

## Dónde estuvimos (2026-07-21 — El descubrimiento del sistema configurable · CERRADO · mergeado en PR #119)

**La visión aterrizada por la otra sesión:** Jidoka evoluciona de metodología a **sistema de gobierno configurable con UI guiada** (la UI autora, el gate ejecuta — ADRs 0002/0044 intactos). Artefactos: el plan-contrato [`sprint-sistema-configurable-plan.md`](docs/sprints/sprint-sistema-configurable-plan.md) (6 rebanadas, 3 trampas confesadas, trae su «Arranque en el chat nuevo»), el informe [`descubrimiento-sistema-configurable-202607.md`](docs/analisis/descubrimiento-sistema-configurable-202607.md), la maqueta clickeable validada en 6 Gembas, y el cierre [`cierre-20260721.md`](docs/sprints/cierre-20260721.md). Nota de trato que funcionó: ante un malentendido, leer ÍNTEGRO el transcript; artefactos concretos clickeables > menús abstractos; **el Gemba temprano funciona — la fidelidad visual se aprueba ANTES de cablear.** Pendientes → ya clasificados en el ROADMAP.

## Autorizaciones vigentes del cliente (dichas con nombre)

- **Publicar releases de GitHub** (2026-07-10): «Eres libre y autorizado para publicar versiones» — tag + release del cierre no necesita re-autorización.
- **Merges de PR y cambios de configuración/permisos**: SIGUEN necesitando orden nombrada cada vez («no me muevas configuración», dicho explícito).
- **Regla de modelos** (2026-07-21): Fable orquesta y pone criterio en el hilo; opus/sonnet/haiku hacen la mecánica en subagentes — ningún subagente en Fable.
