# LOG de la corrida — flujo-20260721

> El artefacto que los gates de evidencia exigen: **este `LOG.md`**. Su contenido lo juzga el humano en el Gemba.

- **Corrida:** flujo-20260721
- **Fecha:** 2026-07-21
- **Rama:** `sprint/pilar-de-flujo-20260721` (post-merge de `origin/main` PR #119)
- **Asiento:** validador (en sesión, orquestador) + 8 subagentes constructores/revisores (opus/sonnet)

## Método reproducible

1. `.\tools\publicar.ps1 -SoloVerificar` — la suite completa del preflight sobre el árbol del sprint.
2. `.\tools\probar-flujo.ps1` — los 94 casos ROJO→VERDE del pilar (contratos handoff/roadmap/changelog, expirar, -Gate, -Json, reporte).
3. `.\tools\verificar.ps1` — los 3 contratos sobre los archivos REALES del repo.
4. `.\tools\expirar.ps1 -Simular` — dry-run sobre el ROADMAP real.
5. `.\tools\estado-flujo.ps1` / `-Json` — resumen y contrato sobre el repo real.
6. `.\tools\reporte-avance.ps1` — genera `.jidoka/reporte-avance.html` (abrirlo con doble clic: el demo sin terminal).
7. Demo del muro WIP: entrada de Gemba en `tools/flujo.json` → `estado-flujo -Gate` bloquea nombrándola (hecho manualmente en R5 y ahora permanente con el registro del Gemba de este sprint).

## Resultados

| # | Caso | Check | Resultado |
|---|---|---|---|
| 1 | Suite del preflight | 15 `probar-*` + `auditar` | **16/16 [OK]**, exit 0 |
| 2 | Self-test del pilar | `probar-flujo.ps1` | **94/94 PASA**, exit 0 |
| 3 | Contrato del HANDOFF (real) | `[contrato-handoff]` | [OK] 2/2 históricas, 33/120 líneas (era 419) |
| 4 | Contrato del ROADMAP (real) | `[contrato-roadmap]` | [OK] 36 ítems clasificados, 59/90 líneas (era 140-diario) |
| 5 | Contrato del CHANGELOG (real) | `[contrato-changelog]` | [OK] sección [1.26.0]: 13 bullets tipados, prosa 1/8 |
| 6 | Expiración (real, dry-run) | `expirar.ps1 -Simular` | 0 vencidos hoy (ítems de julio 2026); mecánica probada ROJO→VERDE en casos s–y |
| 7 | Muro WIP | `estado-flujo.ps1 -Gate` | BLOQUEA nombrando el Gemba (demo R5 + casos w1–w6); con ledger despejado, [OK] |
| 8 | Vista qué sigue | resumen + `-Json` + hook `SessionStart` | Emite sprint activo, 3 siguientes, cola por tercero; `probar-hooks` 37/37 |
| 9 | Reporte para terceros | `reporte-avance.ps1` | HTML con 5 secciones + hill chart; **cero jerga prohibida** (verificado por test r1) |
| 10 | Kit / siembra | `probar-sembrar` + `probar-instalador` | 38/38 y 67/67 — mordida real cazada: stubs viejos violaban los contratos (hijo nacía bloqueado); curados |
| 11 | Grafo de producto | `auditar.ps1` | Íntegro con [[FLU-1-pilar-de-flujo]] y sus 5 Gherkin |
| 12 | Reviews adversariales | R1 (3 hallazgos curados: config incompleta falla-cerrado, «Antes» anclado, 0-estamos bloquea) + review final de rama | R1 curado con regresiones; el veredicto del review final viaja en el PR |

## Artefactos

- `.jidoka/reporte-avance.html` (regenerable con el paso 6 — gitignoreado a propósito, como los demos de la linterna).
- Las salidas de los gates están citadas textuales en los mensajes de commit de la rama (R1–R8b) y en el CHANGELOG `[1.26.0]`.

## Veredicto

Las 9 rebanadas del plan construidas y verdes; los 3 contratos miden los archivos reales del repo; el muro WIP queda armado con el Gemba de este sprint registrado (`aceptado:false`) — **el checkpoint «¿se ve bien?» es del cliente**, con los pasos del plan (sección Verificación, sin código ni terminal).
