# HANDOFF — relevo entre sesiones

> Estado en vuelo y pendientes. **Se llena al cerrar**, **se lee y se limpia al abrir.** Contrato del relevo (FLU-1): **1 sección «Dónde estamos» + máximo 2 históricas + techo de líneas** — lo hace cumplir el check `[contrato-handoff]` de `tools/verificar.ps1` (límites en `tools/flujo.json`). Lo cerrado se archiva ÍNTEGRO en [`docs/handoff-historico.md`](docs/handoff-historico.md), que **no se inyecta al abrir**. Nada de memorias de la IA — todo va aquí.

## En una frase

**Jidoka** — el Sistema de Producción Toyota para agentes de IA: fusión de doctrina + método + ritual de sprint. Estable en `v1.x`. Instalador PowerShell + CLI `npx jidoka-method` construido (pendiente `npm publish`). Se construye por sprints, usando su propio ritual (dogfooding).

## Dónde estamos (2026-07-23 — exploración: la huella de Jidoka en un lab · SIN sprint · commit `0511f46` en `doctrina/kata-de-mejora-20260723`, sin PR)

**Primera vuelta de la kata (cap. 08) corrida de verdad, no como ejemplo.** Pregunta: ¿el estorbo de Jidoka en un repo ajeno es colisión estructural o ruido visual? **Respuesta medida: estructural, y aislable sin apagar el muro.** El expediente completo —condición actual, rojo→verde, lo NO medido, el guion de revisión del dueño y qué mata— vive en [`exploracion-huella-en-labs-202607.md`](docs/analisis/exploracion-huella-en-labs-202607.md); en el ROADMAP quedan **9 tarjetas, todas con puntero** al informe. Molde nuevo `kit/.jidoka/templates/exploracion.md` (n=1, fuera del ledger a propósito).

**Hallazgos que no eran la pregunta:** los 4 Stop hooks dejan cerrar si falta la ley (intención sin determinar — la clasifica el cliente) y `review-stop` suma **tres defectos propios** medidos al usarlo. Se retiró del ROADMAP la tarjeta del fail-open de `auditar.ps1`: ya estaba curada en `v1.31.0`.

**Cola de decisiones del cliente (ninguna es del agente):**
1. `[PENDIENTE]` **Las otras dos exploraciones** que anunció al abrir y nunca describió — se pierden si no las dicta.
2. `[PENDIENTE]` ¿El contenedor entra **antes o después** del batch que vence **2026-08-04**? Después = los labs migran dos veces.
3. `[PENDIENTE]` Los 4 Stop hooks: ¿falla-abierta por **diseño** (se documenta) o **defecto** (se cura)?
4. `[PENDIENTE]` Las **tres contradicciones del capítulo 08**: el Gemba (innegociable vs prohibido), la dirección de la página de hallazgos, y media cuartilla vs los informes durables de `docs/analisis/`.
5. `[PENDIENTE]` `/code-review` del diff con **tus** ojos: el marcador lo firmó el agente por orden tuya, no es tu revisión.
6. `[PENDIENTE]` **Elegir boceto del tablero Operar (A/B/C)** — desbloquea el Sprint 27, pausado desde el 2026-07-22 sin reloj. Los tres viven ya en `docs/analisis/boceto-andon-{a,b,c}-202607.html` (rescatados a `main` el 2026-07-23; antes solo existían en la rama pausada y eran invisibles desde `main`). La rama `sprint/tableros-spec-20260722` **sigue viva** para reanudar la construcción.

## Dónde estuvimos (2026-07-22 — Sprint 26 «La 2.0 estable» · CERRADO: mergeado PR #127, `v1.31.0` liberada · la etiqueta «2.0» NO se declaró)

**El sprint TERMINÓ (3/3 + review + Gemba aceptado) y se cerró con orden nombrada del cliente** (merge + release + poda). Salió como **`v1.31.0`** — decisión del cliente al cierre: los mecanismos no bastan para la etiqueta «estable»; la declara él, no un sprint. Récord completo: [`sprint-26-la-2-0-estable-entrega.md`](docs/sprints/sprint-26-la-2-0-estable-entrega.md) (con cuadro de cierre). Dos reglas nuevas de la sesión, ya operativas: **toda superficie del gobierno debe ser la app** (linterna descartada, ADR 0043 reemplazado) y **ninguna frase textual del cliente va al repo público** (barrido hecho; la historia de la rama se reescribió antes del merge).

**Qué sigue (en orden de valor):**
1. **Sprint 27 — la ola de UI** (ya decidido): la app dice la verdad por documento (4 ledgers) · pantalla del mapa de enforcement · parametrizar secciones (`-Requeridas` + ADR no-clobber). Ahí se retira `estado-gobierno.ps1` y el tablero interino.
2. **Bajar el batch a los labs** — vence **2026-08-04** (el único reloj).
3. Cola del cliente: decidir el barrido de citas textuales de sesiones ANTERIORES (`docs/handoff-historico.md`, contexto del ADR 0043) — hoy solo se limpió lo de esta sesión.

## Dónde estuvimos (2026-07-22 — Sprint 26, la construcción · el detalle ÍNTEGRO vive en la entrega y el LOG)

Plan-contrato [`sprint-26-la-2-0-estable-plan.md`](docs/sprints/sprint-26-la-2-0-estable-plan.md), nacido de 4 escaneos `arquitecto` ([`escaneo-camino-2.0-202607.md`](docs/analisis/escaneo-camino-2.0-202607.md); 8 ítems al ROADMAP). R1 corte honesto (os `win32`, badge gateado, aviso del muro) · R2 fiabilidad (`probar-gemelas` estrenó en rojo con 3 drifts reales curados; `auditar` fail-closed; salvavidas ampliado) · R3 superficies (`conformidad-docs.html` interino; [`matriz-carriles-202607.md`](docs/analisis/matriz-carriles-202607.md)) · review adversarial 2M+2B curados. Evidencia rojo→verde: [`qa_runs/la-2-0-estable-20260722/LOG.md`](qa_runs/la-2-0-estable-20260722/LOG.md).

## Autorizaciones vigentes del cliente (dichas con nombre)

- **Publicar releases de GitHub** (2026-07-10): «Eres libre y autorizado para publicar versiones» — tag + release del cierre no necesita re-autorización.
- **Merges de PR y cambios de configuración/permisos**: SIGUEN necesitando orden nombrada cada vez («no me muevas configuración», dicho explícito).
