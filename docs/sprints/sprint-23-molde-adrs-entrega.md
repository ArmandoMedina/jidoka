# Entrega — El molde único de los ADRs

> Récord de cierre del sprint `molde-adrs`. Plan-contrato: [`sprint-23-molde-adrs-plan.md`](sprint-23-molde-adrs-plan.md) · Decisión: [ADR 0050](../decisions/0050-molde-unico-de-los-adrs.md) · Evidencia: [`qa_runs/adrs-20260722/`](../../qa_runs/adrs-20260722/LOG.md).

## Qué se entregó

Los ADRs de Jidoka salen y se mantienen con **un molde único**, y el mecanismo que lo garantiza dejó de ser una skill personal fuera del repo: es un **guardián residente que bloquea**.

- **R1 — molde canónico único:** `0000-plantilla.md` reconciliado con `kit/.jidoka/templates/adr.md` (las 5 secciones + estado enum + `Qué NO resuelve` opcional).
- **R2 — el guardián `tools/probar-adrs.ps1` (MURO):** valida por ADR (a) las 5 secciones, (b) coherencia de la clase de estado header↔índice, (c) sin huérfanos; `exit 1` ante desvío. Self-test 9/9. Falla-suave (no aplica) si un repo no tiene ADRs.
- **R3 — campo completo:** los 13 ADRs desviados alineados al molde **sin reescribir decisiones** (extracción de lo embebido, renombres, enmienda donde faltaba; estado de 0044 corregido a `reemplazado` por 0048).
- **R4 — vista + cableado:** el guardián corre en `andon.yml` (CI) y en el preflight de `publicar.ps1`, sembrado en `manifiesto.json` (mecánica); **ADR 0050**; tablero `conformidad-adrs.html` (49 verde) para el Gemba.

## Verificación (el demo que corre el cliente)

**PENDIENTE del cliente** — el Gemba no lo ha corrido aún. Los pasos, sin código ni terminal:
1. Abrir `qa_runs/adrs-20260722/conformidad-adrs.html` (doble clic) → 50 ADRs, todos "conforme".
2. Abrir en GitHub `0044` (estado + enlace a 0048), `0001` (fundacional alineado) y `0028` → mismas secciones.
3. Abrir `docs/decisions/0050-molde-unico-de-los-adrs.md` → la decisión, ya con el molde nuevo.

## Lo aprendido (Kaizen) — lo que sube de esta sesión

1. **Rama propia ≠ worktree propio (la lección cara).** Con un agente paralelo, `git checkout -b` en el MISMO working tree no aísla: el otro agente cambió la rama del árbol debajo del trabajo y los cambios de R1/R2 flotaron huérfanos. La regla dura "una sesión escritora por working tree" exige `git worktree add`, no solo una rama. Recuperación: worktree aislado + limpieza quirúrgica de la pollución en el árbol compartido.
2. **Un check determinista es mejor worklist que un juicio de subagente.** El auditor de integridad miscontó los archivos (dijo 0000-0049; eran 0000-0048) y omitió 0004; `probar-adrs` dio la lista exacta de 13 desvíos. El muro que construyes es su propia herramienta de diagnóstico.
3. **El AV es un actor en el working tree.** Bitdefender puso `instalar.ps1`/`probar-instalador.ps1` en cuarentena al intentar `-Sellar`, y `verificar` los leyó como borrados del motor (bloqueo espurio de `no-borres-el-motor`). El sello (`jidoka-motor.json`) NO se trackea en Jidoka — se genera al sembrar/liberar — así que el re-sello no era paso del sprint. Se restauran con `git checkout HEAD -- <archivos>` cuando el AV libere.
4. **El `[contrato-changelog]` fuerza versión válida en la sección tope.** No admite `[Unreleased]`; el CHANGELOG/versión se llenan al cierre con la versión objetivo, coordinando el orden de merge con el sprint paralelo (misma lección del renumerado 0045→0049).
5. **Un muro sembrado necesita review de sus bordes.** El `/code-review` cazó que `probar-adrs` tumbaría el CI de un hijo sin `docs/decisions/` (excepción sin guard) — un bug que bajaría a TODOS los hijos. Curado con falla-suave. Un gate que viaja se revisa por su peor entorno, no por el tuyo.

## Cuadro de cierre

| Hecho | Valor |
|---|---|
| Sprint · ¿terminó? | `molde-adrs` "El molde único de los ADRs" · **CONSTRUIDO** (Gemba + PR + release pendientes) |
| Rebanadas: planeadas / entregadas / desviadas | 4 / 4 / 0 (R4 difirió CHANGELOG+versión al release; el re-sello se dropeó como no-paso del árbol de Jidoka) |
| Rama · commits | `review/adrs-20260722` (worktree aislado `../jidoka-adrs`) · 4: `f6dee34` R1+R2, `e85e6f4` R3, `d563726` R4, `07d3aeb` curas review |
| Working tree · duración | **No limpio**: 2 borrados de AV sin commitear (`instalar.ps1`, `probar-instalador.ps1`), intactos en git · sesión de ~1 día (2026-07-22) |
| PR · rama eliminada | Ninguno aún (pendiente) · no |
| Ritual corrido | arranca · planea (2 STOPs, plan mode) · cierra · (+ skill `code-review`) |
| Delegaciones | `auditor`×3 (flota inicial: integridad/vigencia/conformidad) · `auditor`×1 (análisis R3) · `mecanico`×3 (inserción R3) · `auditor`×2 (code-review). 🎭 hilo en sesión: composición de secciones R3, `probar-adrs.ps1` (build+test acoplado), curas del review |
| Aprobaciones nombradas | El QUÉ del molde único (plan mode, aprobado) · la decisión de gate **"bloquea todo"** (elegida explícitamente) · "campo completo" (fundacionales dentro) |
| Pruebas automáticas: altas/cambios/bajas | +1 alta (`probar-adrs.ps1`, 9 casos) · 1 cambio (`probar-sembrar` +1 test) · 0 bajas |
| Suites corridas | probar-adrs 9/9 · probar-docs 27 · probar-flujo 94 · probar-disparos 4 · probar-gate 14 — todo verde |
| Pruebas E2E | N/A (no hay harness E2E en este repo) |
| Evidencia en `qa_runs/` | Sí: `qa_runs/adrs-20260722/LOG.md` + `conformidad-adrs.html`, citadas y commiteadas (`git add -f`) |
| Archivos creados/editados/eliminados | Creados: `probar-adrs.ps1`, ADR 0050, plan, entrega, LOG, tablero · Editados: ~14 ADRs, índice, `andon.yml`, `publicar.ps1`, `manifiesto.json`, `andon/README.md`, sprints README, `probar-sembrar.ps1` · Eliminados: 0 por mí (2 por el AV) |
| Gates: verificar/auditar/self-tests | Self-tests verdes · `verificar` bloqueó SOLO por los borrados de AV (no-aplicable, espurio) · avisos `[metodo]`/`[kit]`→CHANGELOG atendidos al cierre |
| ¿Compactación? · ¿re-verificó? | No hubo compactación esta sesión |
| ADRs creados/enmendados | 1 creado (**0050**) · 13 alineados estructuralmente sin cambiar decisiones (0044 estado corregido) |
| CHANGELOG · versión | Al día (sección `[1.29.0]` al cierre) · **MINOR** (agrega un gate) — coordinar orden de merge con FLU-1 (1.28.0) |
| Motor Jidoka al día | N/A (Jidoka es la nave nodriza) |
| Issues/hallazgos | Flota: estado 0044 desincronizado, corpus no uniforme, 0004 omitido por el auditor · code-review: 6 en el guardián (todos curados) · no se abrieron issues de GitHub |
| Fricción (Kaizen crudo) | 3 correcciones del cliente: "¿no estás en tu propio worktree?" (cazó el fallo de aislamiento), "cuidado con las ramas no mezcles", "¿es un sprint verdad?" · errores del agente reparados: `checkout -b` sin worktree (recuperado), re-sello mal supuesto (dropeado) |
| Pendientes al HANDOFF | Gemba del cliente · PR + merge (orden nombrada) + release v1.29.0 (coordinar con FLU-1) · restaurar los 2 archivos de AV · reconciliar `adr-helper` personal |
| Resumen de cambios | Un molde único de ADR + un guardián que bloquea (secciones + estado + huérfanos), sembrado; los 49 ADRs alineados sin reescribir decisiones; ADR 0050; tablero para el Gemba |
| Resumen de la conversación | El cliente pidió revisar los ADRs en rama propia con un agente paralelo; se auditó el corpus (flota), se planeó y aprobó "campo completo + alinear la plantilla de una vez, bloquea todo"; se construyó en worktree aislado tras un incidente de ramas compartidas |
