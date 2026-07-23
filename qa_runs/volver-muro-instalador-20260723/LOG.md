# LOG de la corrida — volver-muro-instalador-20260723

> El artefacto que los gates de evidencia exigen: **este `LOG.md`**. Su contenido lo juzga el humano en el Gemba.

- **Corrida:** volver-muro-instalador-20260723
- **Fecha:** 2026-07-23
- **Rama:** `sprint/volver-muro-exploraciones-20260723`
- **Asiento:** mecánico (cura de seguridad R8: el contenedor anidado da falso-verde en `-Sellar`)

## Método reproducible

1. Montar un lab MIGRADO A MANO con la maquinaria ANIDADA bajo un contenedor: `mkdir <lab>/jidoka/tools`, copiar `verificar.ps1`/`auditar.ps1` ahí (NADA en `<lab>/tools/` raíz), `git init <lab>`.
2. `./tools/instalar.ps1 -Destino <lab> -Sellar` — el modo que crea el sello desde cero (no exige sello previo, a diferencia de `-Actualizar`).
3. Observar el veredicto (exit code) y si escribió un sello en `<lab>/tools/jidoka-motor.json`.
4. `./tools/probar-instalador.ps1` — la smoke completa del instalador con el caso rojo→verde nuevo (5i anidado / 5j aplanado) + los casos existentes.

## Resultados

| # | Caso | Check | Resultado |
|---|---|---|---|
| 1 | A — ANTES (sin la cura) | `-Sellar` contra lab anidado | **FALSO-VERDE:** `exit 0`, "0 pristina(s) \| 0 divergen \| 110 ausente(s)", escribe `tools/jidoka-motor.json` con `sembrado_hashes: {}` en un `tools/` raíz NUEVO (segundo motor). Aprueba sin mirar nada. |
| 2 | B — DESPUÉS (con la cura) | `-Sellar` contra lab anidado | **FALLA CERRADO:** `exit 1`, `[ERROR] no encontre ninguna pieza de motor... la maquinaria puede estar ANIDADA bajo un contenedor...`; **NO** crea `tools/` raíz ni escribe sello. |
| 3 | Caso sano (aplanado/normal) | `-Sellar` contra motor en `tools/` raíz | `exit 0`, re-crea el sello con `sembrado_hashes` no vacío. La cura no rompe el sellado normal. |
| 4 | Smoke del instalador | `probar-instalador.ps1` | **72/72 [PASA]**, `exit 0` (+4 casos nuevos: 5i anidado rojo→cerrado, 5j aplanado verde) |
| 5 | Otros modos ya cerrados (regresión) | `-Actualizar` sin sello / instalación normal | `-Actualizar` ya fallaba cerrado (`no hay sello... no parece un hijo instalado`); la instalación limpia sigue sembrando y sellando — intactos entre los 72 casos. |

## Artefactos

- Cura: `tools/instalar.ps1` — guarda en `Invoke-Sellar`: si `pristinas == 0 && divergen == 0` (ninguna pieza de motor hallada en la raíz esperada), `Die` en vez de escribir el sello ciego.
- Evidencia rojo→verde: `tools/probar-instalador.ps1` — bloques `5i` (anidado FALLA CERRADO + no escribe sello ciego) y `5j` (aplanado sigue sellando, sello no vacío).
- Las corridas A/B se reproducen textualmente con los pasos 1–3 del método (fixtures desechables en `%TEMP%`, borrados al terminar).

## Veredicto

La causa raíz del falso-verde queda cerrada: `-Sellar` calculaba la raíz del hijo asumiendo `<Destino>/tools/...` y, cuando la maquinaria estaba anidada bajo un contenedor, hallaba **cero** piezas, sellaba a ciegas (sello vacío + segundo motor) y salía `exit 0`. Ahora falla cerrado con un mensaje que nombra la causa. El caso sano (motor en `tools/` raíz) sigue sellando; los 72 casos de la smoke pasan sin romper los existentes. **El checkpoint «¿se ve bien?» es del cliente** — la cura es SOLO el cierre del agujero de seguridad; NO migra carpetas ni mueve nada bajo `jidoka/`.
