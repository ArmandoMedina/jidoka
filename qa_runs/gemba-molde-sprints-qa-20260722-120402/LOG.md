# LOG — Gemba del molde de sprints y qa_runs (R1–R4)

- **Corrida:** gemba-molde-sprints-qa-20260722-120402
- **Fecha:** 2026-07-22
- **Rama:** `sprint/molde-sprints-qa-20260722` (apilada sobre `consolida-tuberia-adrs-20260722` / PR #125)
- **Asiento:** orquestador (en sesión) + delegaciones a explorador×3, arquitecto×1, mecanico×2

## Método reproducible

Sin código para el cliente — abrir archivos con doble clic:

1. Abre **`docs/sprints/README.md`** — los sprints están numerados en orden (columna `#`, 0–25); los `cierre-*` con `·`.
2. Abre dos **`-entrega.md`** cualesquiera de `docs/sprints/` (p. ej. `sprint-molde-adrs-entrega.md` y `sprint-tuberia-por-carpetas-entrega.md`) — comparten las mismas secciones canónicas (`Qué se entregó`, `Verificación`, `Lo aprendido`).
3. Abre dos **`LOG.md`** de `qa_runs/` (p. ej. este y `qa_runs/adrs-20260722/LOG.md`) — comparten `Método reproducible` · `Resultados` · `Veredicto`.
4. Un sprint nuevo nace conforme por **`/jidoka:planea`** (que copia el template ya conforme y pliega el scaffolder `tools/nuevo-sprint.ps1`) — el comando aparte `/jidoka:nuevo-sprint` se retiró en el Rework-C (ADR 0056) por redundante.
5. Abre **`kit/.jidoka/templates/README.md`** — la tabla "Gobierno del molde" dice dónde vive la regla de verdad de cada familia (ledger / `probar-adrs.ps1` / `auditar.ps1`); si alguien toca un template y le quita una sección que el muro exige, **truena un self-test** (el molde no puede desviarse en silencio).

Para el equipo (con terminal, E2E desde el pipeline real): `tools/estado-docs.ps1`, `tools/probar-docs.ps1`, `tools/probar-auditor.ps1`, `tools/verificar.ps1`.

## Resultados

| # | Caso | Check | Resultado (N/N) |
|---|---|---|---|
| 1 | Motor valida familias por glob | `probar-docs.ps1` (3 casos de familia: conforme, desviado, familia vacía) | **39/39** verde |
| 2 | Glob que no matchea no da verde en falso | caso `[FAMILIA VACIA]` en el self-test | pasa (avisa, no CONFORME) |
| 3 | Sprints homologados | `estado-docs.ps1` sobre `docs/sprints/*` | 22/22 CONFORME (11 homologados) |
| 4 | qa_runs homologados | `estado-docs.ps1` sobre `qa_runs/*/LOG.md` | 20/20 CONFORME (11 homologados) |
| 5 | Conformidad total del ledger | `estado-docs.ps1` | **49 CONFORME, 0 desviados** |
| 6 | Skill generadora produce conforme | `nuevo-sprint.ps1` + `estado-docs` sobre el recién nacido | CONFORME sin tocar nada |
| 7 | Molde de módulo/dominio en su dueño | `probar-auditor.ps1` (4 casos nuevos: bloquea/no/modula) | **11/11** verde |
| 8 | Sin regresión en gates existentes | `probar-ritual` 19/19 · `probar-preflight` 8/8 · `probar-gate` 14/14 · `auditar` grafo íntegro | verde |
| 9 | Andon del árbol | `verificar.ps1` | exit 0, todo limpio |
| 10 | Template atado a su guardián | `probar-adrs.ps1` (`$REQUERIDAS` ⊆ plantilla), `probar-docs.ps1` Parte B (cada `requerida` existe en el molde), `probar-auditor.ps1` casos 12-13 (sección núcleo en modulo/dominio.md) | **14/14 · 39/39 · 13/13** verde |
| 11 | Capacidades: sin trabajo, por doctrina | el propio `capacidad.md` ordena "en proyecto chico bastan Propósito + Reglas + Criterios; el resto para lo crítico/regulado" — Jidoka es chico y no regulado → set mínimo correcto; `auditar` ya las exige (Gherkin) | consistente (no se agregan secciones huecas) |

Antes: 11 sprints + 11 LOG DESVIADO. Después: 0 desviados. Solo se tocaron encabezados (`## `), nunca la prosa. Total ledger tras reworks: **50 CONFORME**.

## Artefactos

- Este `LOG.md` (la corrida).
- El árbol homologado en `docs/sprints/` y `qa_runs/` (commits R1–R4 en la rama).
- La salida de `estado-docs.ps1` (49 CONFORME) y de los self-tests, citada arriba.

## Veredicto

**Pendiente de los ojos del cliente.** Construcción R1–R4 verde de punta a punta. El veredicto nombrado (aceptar/rechazar) abre el cierre (R5: ADR, cableado, CHANGELOG, bump v1.30.0) y, con tu orden nombrada, el merge y el release.
