# LOG de la corrida — fixes-auditoria-20260716

> El artefacto que los gates de evidencia exigen. Datos 100 % sintéticos.

- **Corrida:** fixes-auditoria-20260716
- **Fecha:** 2026-07-16
- **Rama:** `fixes-auditoria-20260716`
- **Asiento:** orquestador (suite y prueba de vida en sesión); subagentes general-purpose/sonnet (atlas, tests del kit); auditor ×7 (code-review)

## Método reproducible

1. Suite local completa sobre la rama, esta máquina (PS 5.1): `probar-version`, `probar-gate`, `probar-hooks`, `probar-auditor`, `probar-disparos`, `probar-publicar`, `probar-agentes`, `probar-sembrar`, más `auditar.ps1 -Bloquea` y `rutear.ps1`. (`probar-instalador` no corre local — cuarentena AV, ADR 0027; corre en el CI del PR.)
2. Prueba de vida de `auditar.ps1` (#99): fixture `product/capacidades/ZZZ-prueba-de-vida.md` con frontmatter incompleto y wikilink roto `[[no-existe-prueba-9999]]` → correr `auditar -Bloquea` → borrar fixture → re-correr.
3. Atlas: `npm run atlas:validate` + `npm run atlas:render` tras editar los 11 BPMN.
4. Code-review (gate `review-stop`): 7 ángulos por subagentes sobre `git diff HEAD` de los archivos de áreas `revisa`.

## Resultados

| # | Caso | Check | Resultado |
|---|---|---|---|
| 1 | probar-version | exit 0, SSOT 1.19.0 (version.txt = CHANGELOG = package.json) | PASA |
| 2 | probar-gate | exit 0 (14 casos) | PASA |
| 3 | probar-hooks | exit 0 | PASA |
| 4 | probar-auditor | exit 0 | PASA |
| 5 | probar-disparos | exit 0 (15 disparos) | PASA |
| 6 | probar-publicar | exit 0 | PASA |
| 7 | probar-agentes | exit 0 — **32 casos** (28→32: `tools:` contra lista cerrada, case-sensitive) | PASA |
| 8 | probar-sembrar | exit 0 — **38 casos** (36→38: `sello.producto` grafo y brief en siembra fresca) | PASA |
| 9 | auditar -Bloquea (grafo real) | exit 0 | PASA |
| 10 | **Prueba de vida de auditar** | VERDE (exit 0) → fixture roto → **ROJO (exit 1, 5 BLOQUEA** incl. wikilink roto**)** → restaurar → VERDE (exit 0) | PASA |
| 11 | atlas:validate | 25 BPMN, 24 Call Activities verificadas en CSV, sin huecos | PASA |
| 12 | rutear | exit 0 — 10 áreas (la nueva `guias` ruteada a escribano/andon-stop) | PASA |

## Artefactos

- Salida cruda de la prueba de vida del auditor: los 5 `[BLOQUEA]` (frontmatter sin clave/modulo/dominio, wikilink roto, vigente sin Gherkin) + 2 avisos — reproducible con el método del punto 2.
- Code-review: 3 hallazgos curados en el diff (reuso de `$sello` en 1d; aviso de gobernanza también en `-Actualizar`; `-cnotcontains` case-sensitive en el lint de `tools:`), 1 decisión documentada en ADR 0038 (package.json sin área, su invariante la cubre `probar-version`), 3 refutados con la semántica real de la ley, espejos de `instalar.ps1` diferidos por AV (#98).

## Veredicto

Suite local completa verde con los casos nuevos mordiendo (ROJO→VERDE demostrado por los subagentes en construcción); el auditor del grafo dio su primera mordida real en la nodriza. El veredicto viaja a CHANGELOG 1.19.0 y HANDOFF citando esta corrida.
