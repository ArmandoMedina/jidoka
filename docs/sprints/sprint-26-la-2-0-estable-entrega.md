# Sprint 26 — La 2.0 estable · Entrega

> El récord del sprint. Se llena al cerrar; las lecciones viajan al siguiente `planea`, el contexto no.

## Objetivo

Que «estable» deje de ser sensación: lo instalado == lo prometido, el motor no se miente a sí mismo, y el gobierno se ve sin terminal — con evidencia rojo→verde por escenario.

## Decisiones

- Plan aprobado en plan mode (2026-07-22) con `npx` recortado hasta cuenta npm y la ola de UI diferida al sprint siguiente.
- Evidencia **rojo→verde por escenario** como protocolo del sprint (decisión del cliente durante la construcción).
- **Toda superficie del gobierno debe ser la app** (decisión del cliente, post-construcción): la linterna descartada como superficie; ADR 0043 marcado reemplazado.
- **La versión de salida es `v1.31.0`, no `v2.0.0`** (decisión del cliente al cierre): los mecanismos no bastan para la etiqueta; la declara el cliente, no un sprint. El ADR previsto para el corte se descartó por orden del cliente.
- Ninguna frase textual del cliente se registra en artefactos del repo (es público): las decisiones se parafrasean. Corrección del cliente aplicada con barrido completo e historia de la rama reescrita antes del merge.

## Qué se entregó

- **R1 corte honesto:** `package.json` os `["win32"]` · badge del README gateado al SSOT (`probar-version` 5/5) · aviso ruidoso post-instalar del muro server-side (`post.aviso`, caso en `probar-instalador` 68/68). Matiz confesado: la promesa `npx` del README ya estaba calificada; se dejó.
- **R2 fiabilidad:** `tools/probar-gemelas.ps1` (11 grupos, 21 comparaciones; su estreno en rojo atrapó 3 drifts reales, curados) · `auditar.ps1` fail-closed en `-Range` · salvavidas cubre `.claude/hooks/*`, `settings.json`, `.githooks/*` (`probar-gate` 18/18).
- **R3 superficies:** `estado-docs.ps1 -Reporte` → `conformidad-docs.html` (interino hasta la app) + artefacto de CI · matriz de carriles (11 escenarios: 1 muro, 2 parciales, 6 prosa, 2 nada). **Desviación:** el recableado de la linterna se construyó y se **descartó** en el mismo sprint por decisión del cliente (arriba).

## Evidencia (review)

Review adversarial del asiento `auditor`: 2 MEDIOS + 2 BAJOS, los 4 curados en la rama + 2 regresiones faltantes agregadas. Corrida completa: [`qa_runs/la-2-0-estable-20260722/LOG.md`](../../qa_runs/la-2-0-estable-20260722/LOG.md) — 7 pares rojo→verde ejecutados, 1 matiz confesado, 1 rojo honesto diferido. Suites al cierre: gate 18/18 · hooks 47/47 · auditor 13/13 · docs 43 · flujo 94 · bandeja 21 · linterna 57 · gemelas 21/21 · instalador 68/68 · versión 5/5 · adrs 14/14.

## Hallazgos de la data real

- Los «parámetros» de un documento viven en 4 ledgers con 4 guardianes; el radio «estructura gobernada» del formulario escribe donde el guardián no lee (teatro no confesado) — es el corazón del sprint de UI.
- El registro resucita muertos: un ADR que el pivote a la app no marcó reemplazado (0043) hizo que esta sesión recableara una superficie ya descartada de facto.
- La cadena de instalación estaba mejor de lo temido: no-clobber y tres vías probados por suite; lo que rompía al ajeno era la promesa (os/npx/badge), no el instalador.

## Verificación (el demo que corre el cliente) — `owner: cliente`

El cliente vio `conformidad-docs.html` renderizado en sesión y declaró el Gemba revisado al dar la orden de cierre (merge + release + poda), registrado en `flujo.json` (`aceptado: true`, 2026-07-22). Los pasos 1, 3 y 4 del plan (README en GitHub, matriz, LOG) no constan corridos uno a uno — se dice de frente; el tablero interino queda disponible para re-correrlos cuando quiera.

## Pendiente que dejó

- [ ] Sprint 27 — la ola de UI: la app dice la verdad por documento (4 ledgers) + pantalla del mapa de enforcement + parametrizar secciones (`-Requeridas` + ADR no-clobber de `docs-gobernados.json`).
- [ ] Retirar `estado-gobierno.ps1` del motor (con ADR) cuando la pantalla de la app exista; limpiar gemelas/suites/manifiesto.
- [ ] `conformidad-docs.html` es interino: se retira cuando la app absorba esa verdad.
- [ ] Bajar el batch a los labs antes del 2026-08-04 (reloj del ROADMAP).
- [ ] Decidir si se barren las citas textuales de sesiones ANTERIORES que siguen en el repo público (`docs/handoff-historico.md`, contexto del ADR 0043) — hoy solo se limpió lo de esta sesión.

## Lo aprendido (Kaizen)

1. **Nada de frases textuales del chat en el repo: es público.** Las decisiones del cliente se parafrasean con fecha; citar literal es fuga de contexto privado (corrección del cliente, con barrido e historia reescrita como cura).
2. Un pivote que no marca reemplazados TODOS sus ADRs siembra resurrecciones: marcar el estado es parte del pivote, no cosmética.
3. Estrenar una suite en rojo contra el estado real la convierte en evidencia, no en adorno: `probar-gemelas` atrapó 3 drifts reales en su primera corrida.
4. En PS 5.1 los mensajes de commit van por `-F <archivo>` — las comillas embebidas en argumentos a exe nativos se manglean.
5. Las etiquetas de versión también son claims que envejecen: gatearlas al SSOT (badge) cuesta 10 líneas y mata mentiras de 30 releases; y la etiqueta «estable» la declara el cliente, no la produce un sprint.

## Cuadro de cierre

| Hecho | Valor |
|---|---|
| Sprint · ¿terminó? | 26 «La 2.0 estable» · TERMINÓ (cerrado 2026-07-22) |
| Rebanadas: planeadas / entregadas / desviadas | 3 / 3 / 1 (el recableado de la linterna se construyó y se descartó por decisión del cliente en el mismo sprint) |
| Rama · commits | `sprint/la-2-0-estable-20260722` · 2 commits finales (la historia se **reescribió antes del merge** para retirar mensajes/archivos con texto del chat privado; los 10 commits originales se consolidaron) |
| Working tree al cerrar · duración | limpio · ~1 día (2026-07-22, sesión única) |
| PR · ¿rama eliminada? | #127 mergeado con orden nombrada · rama eliminada |
| Ritual corrido | arranca (con nota de enfoque) · planea (R0 + STOP 2 en plan mode) · cierra; el Gemba se aceptó por declaración nombrada del cliente en la orden de cierre |
| Delegaciones | 4×`arquitecto` (escaneos en paralelo) · 1×`auditor` (review adversarial) · hilo con 🎭 desarrollador (bucle rojo→verde acoplado a evidencia) |
| Aprobaciones nombradas del cliente | plan del sprint (plan mode) · protocolo rojo→verde · descarte de la linterna (toda superficie = app) · orden de cierre: PR autorizado, Gemba revisado, release, merge y poda · versión final `v1.31.0` (no 2.0) · eliminación del ADR del cierre |
| Pruebas automáticas | Altas: `probar-gemelas` (21 comparaciones) + 4 casos en `probar-gate` + 1 en `probar-instalador` + 1 check en `probar-version` · 11 suites corridas, todas verdes (detalle en Evidencia) |
| Pruebas E2E | No corrieron — no aplica (sin cambios de UI en este sprint) |
| Evidencia en `qa_runs/` | Sí: `la-2-0-estable-20260722/` (LOG.md + conformidad-docs.html), citada y commiteada con `git add -f` |
| Archivos | ~25 tocados; clave: `package.json`, `README.md`, `tools/probar-gemelas.ps1` (nuevo), `tools/auditar.ps1`, `tools/verificar.ps1`, `tools/estado-docs.ps1`, `tools/expirar.ps1`, `.claude/hooks/andon-stop.ps1`, `andon.yml`, `manifiesto.json` · eliminados: `gobierno.html` (evidencia descartada), ADR 0057 (orden del cliente) |
| Gates | `verificar` 0 · `auditar` 0 · self-tests verdes · avisos [atlas]/[barreras] evaluados: cambios internos sin cambio de proceso ni capacidad — no aplican (dicho aquí, no ocultado) |
| ¿Compactación? | Sí, al abrir (el resumen traía estado de otra máquina); se re-verificó contra git — el pull de 26 commits fue el primer acto |
| ADRs | 0043 enmendado a **reemplazado** · el ADR nuevo del cierre se creó y se **eliminó por orden del cliente** |
| CHANGELOG · versión | Al día · `[1.31.0]` (MINOR — la etiqueta 2.0 no se declaró) |
| Motor al día con la nave | Sí (esta ES la nave) |
| Issues/hallazgos | 8 ítems nuevos al ROADMAP desde los escaneos; sin issues de GitHub abiertos (batch, no goteo) |
| Fricción y errores (Kaizen crudo) | Correcciones del cliente: 4 (protocolo rojo→verde en vivo · descarte de linterna · versión no-2.0 · **citas textuales en repo público** — la grave) · errores del agente reparados: quoting PS 5.1 en commits (×2), captura de salida con `Run-PS` equivocado (×1), fila desordenada en índice de sprints (×1), y el de fondo: citar chat privado en artefactos públicos (barrido + historia reescrita) |
| Pendientes al HANDOFF | Sprint 27 (ola de UI) · retiro de linterna con ADR · batch labs vence 2026-08-04 · barrido de citas antiguas (decisión del cliente pendiente) |
| Resumen de cambios | El corte de honestidad/fiabilidad rumbo a la 2.0: promesas alineadas a la realidad (os/badge/aviso), motor que no se miente (gemelas vigiladas, fail-closed completo, salvavidas ampliado), y el tablero interino de conformidad — todo con evidencia rojo→verde. |
| Resumen de la conversación | El cliente pidió aterrizar todo al ROADMAP y mapear el camino a una salida estable; aprobó el plan; endureció el protocolo de evidencia; fijó que toda superficie debe ser la app; juzgó que el corte aún no es «2.0» y ordenó salir como `v1.31.0` con merge, release y poda; ordenó eliminar frases textuales del repo y el ADR del cierre. |
