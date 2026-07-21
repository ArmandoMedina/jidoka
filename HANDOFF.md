# HANDOFF — relevo entre sesiones

> Estado en vuelo y pendientes. **Se llena al cerrar**, **se lee y se limpia al abrir.** Contrato del relevo (FLU-1): **1 sección «Dónde estamos» + máximo 2 históricas + techo de líneas** — lo hace cumplir el check `[contrato-handoff]` de `tools/verificar.ps1` (límites en `tools/flujo.json`). Lo cerrado se archiva ÍNTEGRO en [`docs/handoff-historico.md`](docs/handoff-historico.md), que **no se inyecta al abrir**. Nada de memorias de la IA — todo va aquí.

## En una frase

**Jidoka** — el Sistema de Producción Toyota para agentes de IA: fusión de doctrina + método + ritual de sprint. Estable en `v1.x`. Instalador PowerShell + CLI `npx jidoka-method` construido (pendiente `npm publish`). Se construye por sprints, usando su propio ritual (dogfooding).

## Dónde estamos (2026-07-21 — sprint «El pilar de flujo» FLU-1 · EN CONSTRUCCIÓN)

**El QUÉ aprobado por el cliente (plan mode, 2026-07-21):** el pilar JIT que le falta a la Casa — los documentos de estado dejan de crecer solos, el trabajo entra con límite, y el avance y el reparto de roles se ven sin terminal. Plan-contrato: [`docs/sprints/sprint-pilar-de-flujo-plan.md`](docs/sprints/sprint-pilar-de-flujo-plan.md) — 9 rebanadas en 3 movimientos, orden M1→M2→M3 por dependencia. **Apetito: 6 horas de revisión del cliente, tope duro con muerte por defecto.** Rama: `sprint/pilar-de-flujo-20260721`.

**Los insumos (committeados en la rama):** el diagnóstico [`docs/analisis/gemba-gestion-del-flujo-202607.md`](docs/analisis/gemba-gestion-del-flujo-202607.md) y el benchmark [`docs/analisis/benchmark-flujo-202607.md`](docs/analisis/benchmark-flujo-202607.md). Decisiones del cliente registradas en el plan (apetito 4h/1h diarias → WIP ~8/~3; «quiero todo»; Tauri solo la tubería; CHANGELOG con estructura fija; roles: autoridad-del-dominio ≠ dueño-operador).

**Avance:**
- ✅ R0 plan aprobado y archivado · ✅ **M1 COMPLETO**: R1 contrato del HANDOFF (este archivo, 419→40 líneas, gate mordiendo), R2 contrato del ROADMAP (140→55, 32 vivos en 4 clases), R3 expiración automática (`expirar.ps1` → `docs/MUERTOS.md`, paso duro del cierre + aviso del arranca).
- ✅ **M2 COMPLETO**: R4 cierre con orden fijo + CHANGELOG bajo contrato (`[contrato-changelog]`: bullets tipados, prosa con techo) · R5 límite WIP (`estado-flujo.ps1 -Gate` planta a `planea` nombrando el Gemba pendiente; aceptación = booleano con fecha en `gemba`; el cierre registra el Gemba nuevo).
- ⬜ M3 (R6 vista `-Json`+SessionStart, R7 reporte, R8a reparto, R8b casting). Diseño fijado en el plan-contrato; insumo de enti levantado.

**Kaizen vigente de la sesión anterior:** ante la señal «voy más lento que tú», el agente por defecto se detiene en vez de absorber más trabajo — el ritmo lo marca quien absorbe; el volumen de trabajo, no. (Registrado también como contexto del sprint: es el síntoma que FLU-1 ataca.)

## Dónde estuvimos (2026-07-20 — El editor del gobierno, parte 2 · `v1.25.0` LIBERADO · PR #115)

**Sprint R2–R4 terminado, mergeado y liberado** con orden nombrada. Récord: [`docs/sprints/sprint-editor-gobierno-2-entrega.md`](docs/sprints/sprint-editor-gobierno-2-entrega.md). En una línea: el gate granular código↔capacidad (`ligas.json` + `estado-ligas.ps1`) + la extensión que lo autora (clic derecho) + la linterna con 4 modos legibles + `.vsix` + ADR 0044. Evidencia: `qa_runs/editor-r2r4-20260720/LOG.md`.

**Pendientes vivos (nada bloquea al agente):**
1. **Bajar `v1.25.0` a los labs** con `-Actualizar` (entisoft gana `estado-ligas.ps1` + linterna).
2. **Decisión del cliente:** ¿estrechar el área `raiz`? (el modo Reparto/treemap es el instrumento).
3. Opción (b) de nomenclatura «ligar» — en ROADMAP, regla 2-3.
4. **Gemba visual de entisoft** (`gobierno-entisoft.html`, 15 huérfanos) — espera ojos del cliente.
5. Deuda de reviews: `Out-File -Encoding ascii` en steps desde-la-base · conteo del reparto case-insensitive.

## Dónde estuvimos (2026-07-19 — La linterna del gobierno · `v1.24.0` · mergeada, PR #114)

`tools/estado-gobierno.ps1`: vista de solo lectura del grafo del gobierno (`.html` autocontenido, huérfanos en rojo, falla cerrado; es vista, NO gate — ADR 0043). Detalle completo en el CHANGELOG `[1.24.0]` y en el histórico. Pendientes vivos: el **tag+release de `v1.24.0` no se cortó** (quedó subsumido: la orden nombrada de `v1.25.0` cubrió el corte); los 2 avisos de `verificar` anotados (¿diagrama del atlas y nota de capacidad para la linterna?) siguen como decisión del cliente.

## Autorizaciones vigentes del cliente (dichas con nombre)

- **Publicar releases de GitHub** (2026-07-10): «Eres libre y autorizado para publicar versiones» — tag + release del cierre no necesita re-autorización.
- **Merges de PR y cambios de configuración/permisos**: SIGUEN necesitando orden nombrada cada vez («no me muevas configuración», dicho explícito).
