# Sprint 25 — El molde único de sprints y `qa_runs` · Entrega

> El récord del sprint. Se llena al cerrar; las lecciones viajan al siguiente `planea`, el contexto no.

## Objetivo

Homologar el formato de los sprints y los `LOG.md` de `qa_runs` (y reforzar módulos/dominios) con el mismo patrón anti-drift de los ADRs, pero **extendiendo el motor genérico** `estado-docs.ps1` por datos — sin clonar guardianes ni construir un `.ps1` monolítico.

## Decisiones

- **[ADR 0056](../decisions/0056-molde-de-sprints-qa-por-el-motor-generico.md)** — el molde se gobierna extendiendo el motor genérico (glob de familia en el ledger), no clonando `probar-<familia>.ps1` ni con un monolito; `probar-adrs` se queda aparte; módulos/dominios se refuerzan en `auditar` (ADR 0042, sin doble-gobierno); el generador es `planea` + plantilla + scaffolder.
- **Decisiones del cliente (2026-07-22):** numerar los sprints **también en el nombre de archivo** (no solo el índice); **una sola carpeta de ADRs** (consolidar `doctrina/decisiones` en `docs/decisions/`); **retirar** el comando redundante `/jidoka:nuevo-sprint`; **capacidades sin trabajo** — el propio template `capacidad.md` ordena el set mínimo (Propósito + Reglas + Criterios) para un proyecto chico/no regulado.

## Qué se entregó

- **R1 — motor por glob-familia:** `tools/docs-gobernados.json` acepta globs; `estado-docs.ps1` los expande y valida cada miembro; `[FAMILIA VACIA]` como guarda del verde mentiroso. Self-test de familia en `probar-docs.ps1`.
- **R2 — sprints:** los 25 numerados en `docs/sprints/README.md` (columna `#`), archivos renombrados `sprint-NN-<slug>`, 11 docs homologados (solo encabezados); 3 filas al ledger (plan/entrega/LOG). Generación por `/jidoka:planea` + `tools/nuevo-sprint.ps1`.
- **R3 — `qa_runs`:** cada `LOG.md` valida `Método reproducible · Resultados · Veredicto`.
- **R4 — módulos/dominios en `auditar.ps1`:** `vigente` exige la sección núcleo (`## Capacidades` / `## Módulos`), modulado por estado; NO al ledger.
- **Reworks:** consolidación de doctrina (0052-0055 en una sola carpeta), retiro del comando `nuevo-sprint` (ADR 0056), y **cada template atado a su guardián** con `kit/.jidoka/templates/README.md` documentando dónde vive la regla de verdad.
- **Desviación honesta del alcance:** las capacidades **no se tocaron** — su bareness es correcta por doctrina del propio template (set mínimo para proyecto chico); agregar secciones huecas la contradiría (ADR 0042, click-para-ignorar).

## Evidencia (review)

Todos los gates verdes: `verificar` exit 0 (contratos handoff/roadmap/changelog OK), `estado-docs` **50 CONFORME / 0 DESVIADO**, self-tests `probar-docs` 43, `probar-auditor` 13, `probar-adrs` 14 (corpus conforme), `probar-flujo` 94. Corrida del Gemba con artefactos: [`qa_runs/gemba-molde-sprints-qa-20260722-120402/LOG.md`](../../qa_runs/gemba-molde-sprints-qa-20260722-120402/LOG.md).

## Hallazgos de la data real

- El template `capacidad.md` **ya resolvía** la sospecha de "capacidades desviadas": su nota de escalado ("en proyecto chico bastan Propósito + Reglas + Criterios; el resto para lo crítico/regulado") hace que el mínimo sea lo correcto — la inconsistencia percibida era comparar 1 sección vs 12 sin leer esa regla.
- El gate `no-borres-el-motor` cazó el intento de borrar `tools/nuevo-sprint.ps1` junto con el comando: la cura fue conservar el scaffolder y solo retirar el comando, documentándolo en ADR 0056.

## Verificación (el demo que corre el cliente) — `owner: cliente`

**Pendiente de los ojos del cliente** (sin código ni terminal):

1. Abre `docs/sprints/README.md` → sprints numerados en orden (`sprint-01…25`).
2. Abre dos `-entrega.md` → mismas secciones canónicas.
3. Abre dos `LOG.md` de `qa_runs/` → misma estructura (Método · Resultados · Veredicto).
4. Abre `kit/.jidoka/templates/README.md` → la tabla "Gobierno del molde".
5. Abre el reporte de conformidad → tabla CONFORME/DESVIADO (50 CONFORME hoy).

Registrado en `tools/flujo.json` (`aceptado: false`): planta a `/jidoka:planea` hasta la aceptación nombrada.

## Pendiente que dejó

- [ ] Gemba del cliente (los 5 pasos de arriba) + aceptación nombrada.
- [ ] Estrategia de PR + merge + release (v1.29.0 + v1.30.0) con orden nombrada; cerrar/retargetear PR #124 y #125.
- [ ] `andon/README.md`: nota de que sprints/qa_runs se validan como filas del ledger (no como `probar-sprints.ps1`) — aviso no bloqueante.

## Lo aprendido (Kaizen)

1. **Extender el motor por datos vence a clonar guardianes:** una fila de ledger cubrió 3 familias sin reproducir la mecánica frágil de PS 5.1 seis veces.
2. **El template es la doctrina, no solo el formato:** leer su nota de escalado evitó "corregir" capacidades que estaban bien — el molde ya decía por qué.
3. **"Blindar el molde" es ambiguo:** el cliente lo entendió como "poner la estructura en cada doc"; yo como "guardar la sección núcleo". Nombrar qué se blinda evita el rework.
4. **`git add -A` con un temp file suelto contamina el commit:** usar `git add` selectivo cuando hay archivos no rastreados en vuelo (lección cazada en `d451175`).
5. **El verde mentiroso vive en los globs:** un glob que no matchea daría CONFORME en falso para toda la familia; el `[FAMILIA VACIA]` es la guarda que lo impide.

## Cuadro de cierre

| Hecho | Valor |
|---|---|
| Sprint · ¿terminó o en curso? | 25 «El molde único de sprints y `qa_runs`» · **construcción terminada**; Gemba del cliente pendiente |
| Rebanadas: planeadas / entregadas / desviadas | 5 planeadas (R1-R4 + cierre) + 3 reworks (A/B/C) · todas entregadas · 1 desviación (capacidades: sin trabajo, por doctrina del template) |
| Rama · commits | `sprint/molde-sprints-qa-20260722` · ~11 commits (R0 plan → R1-R4 → reworks → gobierno template → cierre) |
| Working tree al cerrar · duración | Limpio tras el commit de cierre · ~1 día (2026-07-22) |
| PR · ¿rama mergeada eliminada? | Sin PR propio aún (apilada sobre PR #125); estrategia pendiente de orden · no |
| Ritual corrido | planea (plan mode) · gemba · cierra |
| Delegaciones | explorador×3 (barridos), arquitecto×1 (la tercera vía: motor genérico vs clon vs monolito), mecanico×2 (renombres/homologación); 🎭 el hilo hizo la redacción de docs y el registro del cierre en sesión |
| Aprobaciones nombradas | Plan del sprint aprobado en plan mode (2026-07-22); 4 correcciones del cliente aplicadas (numerar archivos, una carpeta de ADRs, quitar comando, mostrar módulo/dominio/capacidad). Gemba del molde **aún no aceptado** |
| Pruebas automáticas: altas/cambios/bajas · suites | Altas: fixtures de familia en `probar-docs`, casos 8-13 en `probar-auditor`, self-test de plantilla en `probar-adrs` · `probar-docs` 43, `probar-auditor` 13, `probar-adrs` 14, `probar-flujo` 94 — todo verde |
| Pruebas E2E | N/A (sin Playwright; el harness son los self-tests PS + `estado-docs` sobre el árbol real) |
| Evidencia en `qa_runs/` · ¿citada y commiteada? | `qa_runs/gemba-molde-sprints-qa-20260722-120402/LOG.md` · citada; commiteada con `git add -f` en el cierre |
| Archivos: creados/editados/eliminados | Creados: ADR 0056, esta entrega, fixtures · Editados: ledger, `estado-docs`, `auditar`, `probar-*`, `planea.md`, templates README, 11 docs homologados + 25 renombrados · Eliminados: `.claude/commands/jidoka/nuevo-sprint.md` |
| Gates · avisos | `verificar` exit 0, `estado-docs` 50 CONFORME, self-tests verdes · 2 avisos **no-aplicables** (tocar `flujo.json` para registrar el Gemba no cambió lógica de gate ni capacidad) |
| ¿Compactación? · ¿re-verificado? | Sí (esta sesión viene de compactación) · sí: re-verificado contra git (topología de ramas, estado de PR #122/#125) antes de escribir |
| ADRs creados/enmendados | ADR 0056 creado; 0052-0055 consolidados y homologados al molde canónico |
| CHANGELOG · versión | Al día · **v1.30.0** (MINOR: agrega el motor de familias + guardianes, sin breaking) |
| Motor Jidoka al día con la nave | Es la nave nodriza (no aplica bajada) |
| Issues/hallazgos | Ver «Hallazgos de la data real»; sin issues nuevos de GitHub |
| Fricción (Kaizen crudo) | Correcciones del cliente: 4 (alcance/over-eagerness) + 1 (ambigüedad "blindar el molde") · errores del agente reparados: `git add -A` metió un temp file (curado en `d451175`), intento de borrar el scaffolder (revertido) |
| Pendientes al HANDOFF | Gemba del molde + estrategia PR/merge/release + nota en `andon/README.md` (cola de decisiones actualizada) |
| Resumen de cambios | El molde de 3 familias de docs se gobierna por datos (ledger con glob); sprints numerados; módulos/dominios reforzados en `auditar`; doctrina consolidada en una carpeta; comando redundante retirado; cada template atado a su guardián |
| Resumen de la conversación | El cliente pidió homologar sprints/QA/módulo/dominio/capacidad al estilo de los ADRs; tras el primer Gemba corrigió 4 cosas; se resolvió que las capacidades no se tocan (doctrina del template); disparó el cierre |
