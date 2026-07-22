# LOG — El molde único de los ADRs (sprint molde-adrs)

- **Fecha:** 2026-07-22
- **Rama / worktree:** `review/adrs-20260722` en worktree aislado `C:\Repositorio personal\jidoka-adrs` (otro agente en paralelo en FLU-1; ver la nota de aislamiento en el plan).
- **Contrato:** [`docs/sprints/sprint-molde-adrs-plan.md`](../../docs/sprints/sprint-molde-adrs-plan.md) · Decisión: [ADR 0050](../../docs/decisions/0050-molde-unico-de-los-adrs.md).

## Método reproducible

1. Corre `tools/probar-adrs.ps1` sobre el corpus de 49 ADRs en `docs/decisions/`.
2. Verifica que cada ADR tenga las 5 secciones requeridas (Qué, Por qué, El camino que NO se toma, Cambios y Conclusión) y estado enum coherente.
3. Compara secciones faltantes contra el índice en `docs/decisions/README.md` y descarta huérfanos en disco.

## R1 — Molde canónico único

`docs/decisions/0000-plantilla.md` reconciliado con `kit/.jidoka/templates/adr.md`. Diff de estructura → `MOLDES ALINEADOS` (mismas 5 secciones requeridas + estado enum + `Qué NO resuelve` opcional).

## R2 — El guardián `tools/probar-adrs.ps1` (el muro muerde)

Self-test sintético **5/5 verde** (caza sección faltante, estado incoherente, huérfano de disco, huérfano de índice; NO marca el sano). Sobre el corpus real, **ANTES** de alinear, el muro cayó en **rojo (exit 1)** listando 13 desvíos — prueba de que muerde:

```
== Conformidad del corpus de ADRs (docs/decisions) ==
  [FALLA] corpus real: los 49 ADRs conforman ...
     - 0001: falta(n) seccion(es): por que, el camino que no se toma
     - 0002: falta(n) seccion(es): por que, el camino que no se toma
     - 0003: falta(n) seccion(es): por que, el camino que no se toma
     - 0004: falta(n) seccion(es): por que
     - 0005: falta(n) seccion(es): por que
     - 0027: falta(n) seccion(es): por que
     - 0028: falta(n) seccion(es): por que, el camino que no se toma
     - 0033: falta(n) seccion(es): por que
     - 0040: falta(n) seccion(es): por que
     - 0042: falta(n) seccion(es): por que
     - 0043: falta(n) seccion(es): por que
     - 0044: falta(n) seccion(es): por que
     - 0044: estado incoherente -- archivo 'aceptado' vs indice 'reemplazado'
     - 0049: falta(n) seccion(es): por que
== 1 de 6 caso(s) fallidos. ==   (EXIT=1)
```

## R3 — Campo completo (los 13 alineados, sin reescribir decisiones)

Renombres (0027 `El principio`, 0040/0042 `Razones` → `Por qué`), extracción/adición de `Por qué` y `El camino que NO se toma` en los fundacionales (0001-0003, 0028) y en 0004/0005/0033/0043/0044/0049, y estado de 0044 alineado al índice (`reemplazado` por [0048]). El texto de cada decisión quedó intacto. **DESPUÉS**, el muro pasa a verde:

```
== Conformidad del corpus de ADRs (docs/decisions) ==
  [PASA]  corpus real: los 49 ADRs conforman (secciones + estado coherente + sin huerfanos)
  [PASA]  sintetico: caza la SECCION faltante ...
  ... (6/6)
== Corpus de ADRs conforme: los 6 casos se comportan como se espera. ==   (EXIT=0)
```

## R4 — La vista y el cableado

- **Cableado:** `probar-adrs.ps1` corre en `.github/workflows/andon.yml` (CI, always-run) y en el preflight de `tools/publicar.ps1`; registrado en `kit/.jidoka/instalar/manifiesto.json` clase `mecanica` (viaja a los hijos). El sello (`jidoka-motor.json`) NO se trackea en Jidoka — se regenera al sembrar/liberar y tomará `probar-adrs` entonces.
- **Tablero (demo del cliente, sin terminal):** [`conformidad-adrs.html`](conformidad-adrs.html) — 49 ADRs × conformidad, todos verde. Se abre con doble clic.
- **La decisión:** [ADR 0050](../../docs/decisions/0050-molde-unico-de-los-adrs.md), escrito bajo el molde nuevo (dogfood; pasa el propio guardián), listado en el índice.
- **Diferido al cierre/release:** el CHANGELOG y `version.txt` (el `[contrato-changelog]` exige versión válida en la sección tope y la versión se coordina con FLU-1 — probable `v1.29.0`). El re-sello ocurre al liberar.

## Resultados

| Gate / suite | Resultado |
|---|---|
| `probar-adrs.ps1` (corpus real) | 9/9 verde. 51 ADRs conforman (secciones + estado coherente + sin huérfanos). |
| `verificar.ps1` | exit 0 |
| `auditar.ps1` | grafo íntegro |

## Suite (evidencia-no-palabra)

Ver el bloque de corrida al pie (verificar.ps1 + suite de self-tests, incluido probar-adrs).

## Veredicto

Los 49 ADRs conforman el molde único. El guardián `probar-adrs.ps1` pasa a verde y corre en CI (always-run).
