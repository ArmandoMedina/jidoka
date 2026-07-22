# Sprint "El juez falla cerrado" — cosecha #6 (issues #78, #73, #79, #74-R2, #71)

> Plan aprobado en plan mode el 2026-07-16. **Este plan ES el sprint**: lo que no está aquí, no entra (se anota abajo en "Lo que NO entra").

## Contexto (por qué)

Cortando `v1.14.0` se cazaron en vivo dos fallas de la misma familia: **jueces del motor que aprueban lo que no midieron**.

1. **#78** — El preflight de `publicar.ps1` imprimió `[OK] probar-instalador` cuando el archivo **ni existía en disco** (el antivirus se lo llevó a cuarentena). El mecanismo: PowerShell lanza un error no-terminante, `$LASTEXITCODE` conserva el 0 del test anterior, y el check pasa. Un release "suite verde" donde un test jamás corrió.
2. **#73** — En el sprint descartado, un subagente **borró** 2 archivos del motor (750 líneas) y ningún gate lo cazó; el review pasó verde por encima. La ley cubre *tocar* un área sin su doc, pero no cubre *borrar* una pieza del motor.

Más 3 deudas de documentación baratas: la receta `skip-worktree` del AV no está escrita (#79), el README no menciona la ruta de instalación AV-segura `sembrar-manual.ps1` (#74-R2), y una revisión externa pidió declarar la frontera "Jidoka Core vs familias opcionales" (#71, primer paso doc-only).

## Encuadre de producto (validado con el cliente)

Ningún juez del motor aprueba lo que no midió — ni el preflight del release, ni el gate ante un motor mutilado; y las rutas AV quedan documentadas como camino de primera clase.

## Decisiones del cliente

- **2026-07-16 — Alcance:** Sprint A (esta cosecha); #75 (reconstrucción conciencia-del-agente) queda como sprint aparte.
- **2026-07-16 — Matiz #78 (Opción A):** ante un test ausente del disco, el preflight **se planta** (falla cerrado); no publica localmente confiando en el CI. El mensaje apunta al CI y a la mecánica de dos pasos que ya funcionó en v1.14.0. (Va además al ADR 0032.)

## Alcance (rebanadas verticales)

1. **R1 — #78:** guarda `Test-Path` en el loop del preflight de `publicar.ps1` (falla cerrado) + reset de `$LASTEXITCODE` antes de cada test + caso nuevo en `probar-publicar.ps1` (ROJO→VERDE).
2. **R2 — #73:** salvavidas `no-borres-el-motor` en `verificar.ps1` (detección de borrados vía `--diff-filter=D`; bloquea si borra `tools/*.ps1` o `tools/blast-radius.json` sin ADR nuevo en el mismo cambio; param `-BorradosInyectados` para pruebas — gotcha PS 5.1: la local no puede llamarse `$borrados`) + disparo 15.º en el catálogo + 2 casos en `probar-gate.ps1` (ROJO→VERDE) + `probar-disparos` a `-ge 15` + `andon/README.md` + **ADR 0032** + índice.
3. **R3 — docs:** #79 receta oficial `skip-worktree` en la guía del motor (cura mecánica queda regla 2-3) · #74-R2 `sembrar-manual.ps1` como ruta AV-independiente de primera clase en el README · #71 frontera "Jidoka Core vs familias opcionales" con estado de madurez en README + ROADMAP (solo documentación).
4. **R4 — cierre:** CHANGELOG `v1.15.0` + SSOT + este plan archivado + índice de sprints (curando la fila atrasada de v1.14.0) + evidencia en `qa_runs/juez-falla-cerrado-20260716/LOG.md` + acuse en cada issue (3.er paso del lazo) + PR.

## Archivos

`tools/publicar.ps1` · `tools/verificar.ps1` · `tools/probar-publicar.ps1` · `tools/probar-gate.ps1` · `tools/probar-disparos.ps1` · `kit/.jidoka/disparos/README.md` · `andon/README.md` · `doctrina/00-tesis.md` (solo si la tesis no respalda ya el disparo) · `docs/decisions/0032-*.md` + índice · `docs/guias/mantener-el-motor-al-dia.md` · `README.md` · `ROADMAP.md` · `CHANGELOG.md` · `tools/version.txt` · `docs/sprints/*` · `qa_runs/juez-falla-cerrado-20260716/LOG.md`

Áreas de la ley: **barreras** (doc_avisa `andon/README.md` + product_avisa), **disparos** (doc_avisa tesis), **decisiones** (ADR → índice, único bloqueo), **raiz** (canónicos excluidos). Todo rutea al asiento **escribano**.

## Verificación (el demo que corre el cliente) — `owner: cliente`

**Cómo lo corre (sin código ni terminal):** abrir el PR en GitHub → ver el check `andon` verde sobre el head, y abrir `qa_runs/juez-falla-cerrado-20260716/LOG.md` para **leer** la corrida ROJO→VERDE de ambos jueces: el preflight plantándose ante el test ausente (simulación de cuarentena) y el gate bloqueando el borrado de motor sin ADR / aprobándolo con ADR.

## Lo que NO entra (siguientes)

#75 (reconstrucción conciencia-del-agente — sprint aparte) · #63/#64/#66/#67/#68 (regla 2-3) · cura mecánica de #79 en `estado-motor` (regla 2-3) · #74 R3 (quitar `-ExecutionPolicy Bypass` — evaluar aparte) · #72 análisis de costo neto y #70 piloto independiente (owner: cliente) · npm publish / firma Authenticode (recursos del cliente).
