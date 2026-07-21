# HANDOFF — relevo entre sesiones

> Estado en vuelo y pendientes. **Se llena al cerrar**, **se lee y se limpia al abrir.** Contrato del relevo (FLU-1): **1 sección «Dónde estamos» + máximo 2 históricas + techo de líneas** — lo hace cumplir el check `[contrato-handoff]` de `tools/verificar.ps1` (límites en `tools/flujo.json`). Lo cerrado se archiva ÍNTEGRO en [`docs/handoff-historico.md`](docs/handoff-historico.md), que **no se inyecta al abrir**. Nada de memorias de la IA — todo va aquí.

## En una frase

**Jidoka** — el Sistema de Producción Toyota para agentes de IA: fusión de doctrina + método + ritual de sprint. Estable en `v1.x`. Instalador PowerShell + CLI `npx jidoka-method` construido (pendiente `npm publish`). Se construye por sprints, usando su propio ritual (dogfooding).

## Dónde estamos (2026-07-21 — sprint «El pilar de flujo» FLU-1 · CONSTRUIDO, en cierre)

**El QUÉ aprobado (plan mode, 2026-07-21):** el pilar JIT de la Casa — los documentos de estado dejan de crecer solos, el trabajo entra con límite, y el avance y el reparto de roles se ven sin terminal. Plan-contrato: [`docs/sprints/sprint-pilar-de-flujo-plan.md`](docs/sprints/sprint-pilar-de-flujo-plan.md). **Apetito: 6 horas de revisión del cliente, muerte por defecto.** Rama: `sprint/pilar-de-flujo-20260721`. Insumos: el diagnóstico y el benchmark en `docs/analisis/`.

**Avance — las 9 rebanadas CONSTRUIDAS y verdes:**
- ✅ **M1**: R1 contrato del HANDOFF (419→40 líneas, gate mordiendo) · R2 contrato del ROADMAP (140→55, 32 vivos en 4 clases) · R3 expiración automática (`expirar.ps1` → `docs/MUERTOS.md`).
- ✅ **M2**: R4 cierre con orden fijo + `[contrato-changelog]` · R5 límite WIP (`estado-flujo.ps1 -Gate` planta a `planea`).
- ✅ **M3**: R6 vista `-Json` + primer hook `SessionStart` · R7 reporte sin jerga con hill chart · R8a reparto (`product/casting.md`: autoridad-del-dominio ≠ dueño-operador) · R8b los 4 asientos piensan distinto («Lo que noté por mi cuenta» obligatorio).
- ✅ Kit cableado (mordida real: los stubs viejos violaban los contratos — un hijo nacía bloqueado; curado, `probar-sembrar` 38/38, `probar-instalador` 67/67) · capacidad `FLU-1` al grafo (`auditar` íntegro) · **merge de `origin/main` (PR #119, el descubrimiento) reconciliado bajo los contratos nuevos**.
- 🔨 **Falta del cierre:** review adversarial del diff completo · suite completa post-merge · evidencia `qa_runs/flujo-20260721/LOG.md` · registrar el Gemba del sprint en `flujo.json` · PR (merge con orden nombrada del cliente).

**Kaizen vigente:** ante la señal «voy más lento que tú», el agente por defecto se detiene en vez de absorber más trabajo — el ritmo lo marca quien absorbe; el volumen, no.

## Dónde estuvimos (2026-07-21 — El descubrimiento del sistema configurable · CERRADO · mergeado en PR #119)

**La visión aterrizada por la otra sesión:** Jidoka evoluciona de metodología a **sistema de gobierno configurable con UI guiada** (la UI autora, el gate ejecuta — ADRs 0002/0044 intactos). Artefactos: el plan-contrato [`sprint-sistema-configurable-plan.md`](docs/sprints/sprint-sistema-configurable-plan.md) (6 rebanadas, 3 trampas confesadas, trae su «Arranque en el chat nuevo»), el informe [`descubrimiento-sistema-configurable-202607.md`](docs/analisis/descubrimiento-sistema-configurable-202607.md), la maqueta clickeable validada en 6 Gembas, y el cierre [`cierre-20260721.md`](docs/sprints/cierre-20260721.md). **Correr los tours de la maqueta ES el onboarding de la sesión de construcción.** Nota de trato que funcionó: ante un malentendido, leer ÍNTEGRO el transcript; artefactos concretos clickeables > menús abstractos. Pendientes → ya clasificados en el ROADMAP (construir fase 1 con R0 por ratificar · destino del spike · issues del censo).

## Dónde estuvimos (2026-07-20 — El editor del gobierno, parte 2 · `v1.25.0` LIBERADO · PR #115)

El gate granular código↔capacidad (`ligas.json` + `estado-ligas.ps1`) + la extensión que lo autora + la linterna con 4 modos + `.vsix` + ADR 0044. Récord: [`sprint-editor-gobierno-2-entrega.md`](docs/sprints/sprint-editor-gobierno-2-entrega.md); evidencia `qa_runs/editor-r2r4-20260720/LOG.md`. Pendientes vivos: bajar `v1.25.0`+`v1.26.x` a los labs (en ROADMAP, Con fecha) · ¿estrechar el área `raiz`? (decisión del cliente; el modo Reparto es el instrumento) · Gemba visual de entisoft (`gobierno-entisoft.html`, 15 huérfanos) espera ojos del cliente.

## Autorizaciones vigentes del cliente (dichas con nombre)

- **Publicar releases de GitHub** (2026-07-10): «Eres libre y autorizado para publicar versiones» — tag + release del cierre no necesita re-autorización.
- **Merges de PR y cambios de configuración/permisos**: SIGUEN necesitando orden nombrada cada vez («no me muevas configuración», dicho explícito).
