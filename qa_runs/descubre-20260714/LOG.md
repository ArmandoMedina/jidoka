# LOG de la corrida — descubre-20260714

> El artefacto que los gates de evidencia exigen: **este `LOG.md`** (plantilla `kit/.jidoka/templates/qa-log.md`, ADR 0030). Evidencia del sprint Descubre (`v1.13.0`, ADR 0031).

- **Corrida:** descubre-20260714
- **Fecha:** 2026-07-14
- **Rama:** `sprint-descubre`
- **Asiento:** desarrollador+escribano (en sesión, anunciado) — casting neutral

## Método reproducible

Desde la raíz del repo, Windows 11 / PowerShell 5.1:

```
powershell -NoProfile -ExecutionPolicy Bypass -File tools\probar-disparos.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File tools\publicar.ps1 -SoloVerificar
```

Sin datos de entrada: la suite es self-test del motor. El caso del disparo 14.º corrió **ROJO primero** (expectativa subida a 14 con el catálogo aún en 13: `[FALLA] ... leidos: 13`) y **VERDE después** de registrar `aprobacion-nombrada` cableado en `descubre.md`.

## Resultados

| # | Caso | Check | Resultado (N/N) |
|---|---|---|---|
| 1 | `probar-disparos.ps1` | catálogo con 14 disparos, cada `Cableado en` nombra su slug en su punto (incluye `aprobacion-nombrada` → `descubre.md`) | 4/4 (ROJO→VERDE) |
| 2 | `publicar.ps1 -SoloVerificar` | preflight completo sobre la rama del sprint | 8/8 [OK] (version, gate, hooks, auditor, disparos, instalador, sembrar, auditar) |
| 3 | `probar-version` (en el preflight) | SSOT 1.13.0 consistente (version.txt + tope CHANGELOG + package.json) | [OK] |
| 4 | `auditar` (en el preflight) | grafo de docs íntegro con ADR 0031 + índices nuevos | [OK] |

## Artefactos

Las piezas del sprint: `.claude/commands/jidoka/descubre.md` (el harness lo registró como skill viva al crearse), `kit/.jidoka/templates/kit-entrevista.md`, campos nuevos en `PRODUCT_BRIEF.md`, disparo `aprobacion-nombrada`, ruteo en `planea.md`. Salidas íntegras reproducibles con el método de arriba.

## Veredicto

Suite verde con el sprint completo en la rama — **condición necesaria, no suficiente**: el criterio real de cierre es el **demo de campo que corre el cliente** (correr `/jidoka:descubre` en un proyecto con niebla real, post-merge; ver el plan del sprint). El veredicto viaja a `CHANGELOG.md [1.13.0]` y `HANDOFF.md` citando esta corrida.
