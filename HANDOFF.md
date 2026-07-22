# HANDOFF — relevo entre sesiones

> Estado en vuelo y pendientes. **Se llena al cerrar**, **se lee y se limpia al abrir.** Contrato del relevo (FLU-1): **1 sección «Dónde estamos» + máximo 2 históricas + techo de líneas** — lo hace cumplir el check `[contrato-handoff]` de `tools/verificar.ps1` (límites en `tools/flujo.json`). Lo cerrado se archiva ÍNTEGRO en [`docs/handoff-historico.md`](docs/handoff-historico.md), que **no se inyecta al abrir**. Nada de memorias de la IA — todo va aquí.

## En una frase

**Jidoka** — el Sistema de Producción Toyota para agentes de IA: fusión de doctrina + método + ritual de sprint. Estable en `v1.x`. Instalador PowerShell + CLI `npx jidoka-method` construido (pendiente `npm publish`). Se construye por sprints, usando su propio ritual (dogfooding).

## Dónde estamos (2026-07-22 — sprint «El pilar de flujo» FLU-1 · CONSTRUIDO · reconciliando `main` v1.27.0 antes de su PR)

**El QUÉ aprobado (plan mode, 2026-07-21):** el pilar JIT de la Casa — los documentos de estado dejan de crecer solos, el trabajo entra con límite, y el avance y el reparto de roles se ven sin terminal. Plan-contrato: [`docs/sprints/sprint-pilar-de-flujo-plan.md`](docs/sprints/sprint-pilar-de-flujo-plan.md). **Apetito: 6 horas de revisión del cliente, muerte por defecto.** Rama: `sprint/pilar-de-flujo-20260721`.

**Las 9 rebanadas CONSTRUIDAS y verdes** (evidencia `qa_runs/flujo-20260721/LOG.md`):
- ✅ **M1**: R1 contrato del HANDOFF (419→40 líneas, gate mordiendo) · R2 contrato del ROADMAP (140→55, 32 vivos en 4 clases) · R3 expiración automática (`expirar.ps1` → `docs/MUERTOS.md`).
- ✅ **M2**: R4 cierre con orden fijo + `[contrato-changelog]` · R5 límite WIP (`estado-flujo.ps1 -Gate` planta a `planea`).
- ✅ **M3**: R6 vista `-Json` + primer hook `SessionStart` · R7 reporte sin jerga con hill chart · R8a reparto (`product/casting.md`: autoridad-del-dominio ≠ dueño-operador) · R8b los 4 asientos piensan distinto.
- ✅ Kit cableado (`probar-sembrar` 38/38, `probar-instalador` 67/67) · capacidad `FLU-1` al grafo · **Gemba del sprint REGISTRADO** en `flujo.json` (`flu-1-pilar-de-flujo`, `aceptado:false` — `planea` queda plantado hasta que el cliente lo acepte).

**Reconciliación con `main` v1.27.0 (ESTA sesión, 2026-07-22 — EN CURSO):** se mergeó `origin/main` (release `v1.27.0`, la app de la tubería) a la rama del sprint antes de su PR. Los 6 conflictos se resolvieron preservando FLU-1:
- **CHANGELOG/ROADMAP/HANDOFF** bajo los contratos del propio pilar (FLU-1 lidera; v1.27.0/sistema-configurable a histórico; el diario viejo ya vive en `docs/{roadmap,handoff}-historico.md`).
- **Colisión de ADR resuelta:** ambas ramas usaron 0045. Como `main` liberó 0045-0048 en `v1.27.0` (inmutable), **el ADR del pilar se renumeró 0045 → 0049** (archivo + ~10 refs en tools/kit/capacidad/plan). La versión objetivo del sprint pasa de `v1.26.0` (tomada) a **`v1.28.0`**.
- **Falta (esta sesión):** ✅ merge resuelto → **correr suite + `verificar.ps1` (gates de contrato) verde** → **`/code-review` sobre el diff + marcar revisado** → commit del merge.
- **Falta (cierre del sprint):** el Gemba `flu-1-pilar-de-flujo` que el cliente corre sin terminal (pasos en el plan) · push + PR · **merge con orden nombrada** · release `v1.28.0`.

**Regla de modelos (orden del cliente):** Fable orquesta y pone criterio en el hilo; opus/sonnet/haiku hacen TODA la mecánica en subagentes. Ningún subagente en Fable.

**Kaizen vigente:** ante la señal «voy más lento que tú», el agente por defecto se detiene en vez de absorber más trabajo — el ritmo lo marca quien absorbe; el volumen, no.

## Dónde estuvimos (2026-07-21 noche — «La app de la tubería» · MERGEADO Y LIBERADO `v1.27.0`, PR #121)

**El sprint "La app de la tubería" TERMINÓ (7/7 rebanadas), mergeado y liberado el 2026-07-22 con orden nombrada del cliente.** La superficie del gobierno dejó de ser comandos de VS Code y es ahora una **app de escritorio Tauri fiel a la maqueta** (ADR 0048): 49 piezas con estado real, bandeja, formulario que escribe de verdad y modo avanzado que firma derivando de `git config`. La extensión se retiró completa (`v1.26.0` sistema-configurable subsumida sin tag propio, PR #120). Récord: [`docs/sprints/sprint-app-tuberia-entrega.md`](docs/sprints/sprint-app-tuberia-entrega.md); evidencia [`qa_runs/app-tuberia-20260721/LOG.md`](qa_runs/app-tuberia-20260721/LOG.md).

- Código en `app/` (Tauri v2; `ui/index.html` = la maqueta viva, `src-tauri/` el puente Rust). Es **Jidoka-only** (no se siembra). El `.exe`/instalador NSIS son locales, NO versionados (`app/src-tauri/target/` en `.gitignore`); el instalador subió como asset del release.
- **[PENDIENTE del cliente] Gemba completo end-to-end** (glosario por fuera → bandeja → parametrizar → candado → ver a la IA rebotar; sin código ni terminal). La fidelidad de R2 ya la aprobó; el flujo completo NO lo ha corrido.
- **Pendientes técnicos (nada bloquea):** certificado Authenticode del `.exe` (SmartScreen/Bitdefender) · autoría de ligas en la app (se perdió al retirar `ligas.js`; `estado-ligas.ps1` sigue vivo) · atlas de los tools nuevos (`tuberia-datos`, `parametrizar`, `override`) · reconciliar/alta aún cartón · multiplataforma del motor (fase 2).

## Dónde estuvimos (2026-07-20/21 — El sistema configurable, fase 1 + su descubrimiento · en `v1.26.0` y PR #119)

**La visión aterrizada:** Jidoka evoluciona de metodología a **sistema de gobierno configurable con UI guiada** (la UI autora, el gate ejecuta — ADRs 0002/0044 intactos). El **motor** se construyó en `v1.26.0` (3 ADRs 0045-0047 identidad/contratos/meta-gobierno + CFG-1, bandeja, estatuto del ritual, candado IA), pero **el Gemba del cliente REPROBÓ la superficie** fragmentada en comandos de VS Code — de ahí el giro a la app Tauri (ADR 0048, arriba). El descubrimiento (informe + maqueta clickeable validada en 6 Gembas) cerró y se mergeó en PR #119; su récord: [`cierre-20260721.md`](docs/sprints/cierre-20260721.md). Nota de trato que funcionó: ante un malentendido, leer ÍNTEGRO el transcript; artefactos concretos clickeables > menús abstractos; **el Gemba temprano funciona** (la fidelidad visual se aprueba ANTES de cablear).

## Autorizaciones vigentes del cliente (dichas con nombre)

- **Publicar releases de GitHub** (2026-07-10): «Eres libre y autorizado para publicar versiones» — tag + release del cierre no necesita re-autorización.
- **Merges de PR y cambios de configuración/permisos**: SIGUEN necesitando orden nombrada cada vez («no me muevas configuración», dicho explícito).
