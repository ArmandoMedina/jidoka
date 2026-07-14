# LOG de la corrida — dogfood-20260714

> El artefacto que los gates de evidencia exigen (`gemba-stop`, `validador-stop`): **este `LOG.md`**, no un veredicto suelto. Primer uso propio de la plantilla `kit/.jidoka/templates/qa-log.md` (ADR 0030) en la nave nodriza.

- **Corrida:** dogfood-20260714
- **Fecha:** 2026-07-14
- **Rama:** `dogfood-al-dia`
- **Asiento:** desarrollador+escribano (en sesión, anunciado) — casting neutral (ver `product/recursos-del-proyecto.md` → El casting)

## Método reproducible

Desde la raíz del repo, Windows 11 / PowerShell 5.1 (el ambiente declarado en `recursos-del-proyecto.md`):

```
powershell -NoProfile -ExecutionPolicy Bypass -File tools\probar-publicar.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File tools\publicar.ps1 -SoloVerificar
powershell -NoProfile -ExecutionPolicy Bypass -File tools\rutear.ps1
```

Sin datos de entrada: la suite es self-test del motor. El caso nuevo de `probar-publicar` se corrió **ROJO primero** (antes del fix en `publicar.ps1:79` acusó `fuera del preflight: probar-sembrar`) y **VERDE después** — distingue el bug.

## Resultados

| # | Caso | Check | Resultado (N/N) |
|---|---|---|---|
| 1 | `probar-publicar.ps1` | dry-run + invariante nueva: todo `probar-*.ps1` del motor está en el preflight | 6/6 (ROJO→VERDE) |
| 2 | `publicar.ps1 -SoloVerificar` | preflight completo, ahora con `probar-sembrar` en la lista | 8/8 [OK] (version, gate, hooks, auditor, disparos, instalador, **sembrar**, auditar) |
| 3 | `rutear.ps1` | router de la ley: 8 áreas VIGILADAS; andon/review VIVOS; gemba/validador DORMIDOS con razón | consistente con el casting sembrado |
| 4 | `probar-version` (dentro del preflight) | SSOT 1.12.1 consistente en `version.txt` + tope CHANGELOG + `package.json` | [OK] |

## Artefactos

Las salidas íntegras de los comandos están en la conversación de la sesión y se reproducen con el método de arriba; este LOG es el artefacto rastreado (el bulto de `qa_runs/` está gitignoreado por convención).

## Veredicto

Suite verde con el preflight completo y el casting sembrado — el veredicto viaja a `CHANGELOG.md [1.12.1]` y `HANDOFF.md` citando esta corrida.
