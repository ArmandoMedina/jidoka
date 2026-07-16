# LOG de la corrida — conciencia-del-agente-20260716

> El artefacto que los gates de evidencia exigen: **este `LOG.md`**. El gate mide que exista, esté fresco y rastreado por git; su **contenido** lo juzga el humano en el Gemba.

- **Corrida:** conciencia-del-agente-20260716
- **Fecha:** 2026-07-16
- **Rama:** `sprint-conciencia-del-agente-2`
- **Asiento:** escribano (en sesión) + subagentes (R1/R3 en Sonnet, R2 en Opus — el sprint usó los tiers que instala)

## Método reproducible

1. **ROJO del lint:** crear en `$env:TEMP` un fixture con agentes rotos (`model: gpt-5`, `model:` ausente, asientos faltantes) y correr `tools\probar-agentes.ps1 -Dir <fixture>` → debe FALLAR.
2. **VERDE del lint:** correr `tools\probar-agentes.ps1` contra `.claude/agents/` real → 28/28.
3. **La ley sigue viva:** `tools\rutear.ps1` exit 0 · `tools\probar-gate.ps1` 12/12 (la ley con `.claude/agents/*` parsea) · `tools\probar-publicar.ps1` 7/7 (el meta-test acepta `probar-agentes` en el preflight — el gotcha de release del #75, cerrado a la primera).
4. **Prueba en vivo del harness:** al aterrizar `.claude/agents/`, el harness registró los 4 tipos nuevos (explorador/mecanico/auditor/arquitecto) con su tier fijo — visible en la sesión que los construyó.
5. **Suite completa** (`publicar -SoloVerificar`) + `auditar` + `verificar` sobre el cambio entero.

## Resultados

| # | Caso | Check | Resultado (obtenido / esperado) |
|---|---|---|---|
| 1 | Lint ROJO — fixture con `model: gpt-5`, `model:` ausente y 2 asientos faltantes | `probar-agentes -Dir` detecta los 4 defectos | exit 1, 4/15 fallidos con detalle / FALLA ✅ |
| 2 | Lint VERDE — `.claude/agents/` real | 28/28 | exit 0 / PASA ✅ |
| 3 | La ley parsea con `.claude/agents/*` en `ritual` | `rutear` exit 0 · `probar-gate` 12/12 | exit 0 ambos ✅ |
| 4 | Gotcha de release del #75 | `probar-publicar` 7/7 con `probar-agentes` en el preflight | exit 0 ✅ |
| 5 | Harness reconoce los agentes-asiento | tipos disponibles con tier fijo | registrados en vivo (explorador/mecanico/auditor/arquitecto) ✅ |
| 6 | Suite completa (preflight `publicar -SoloVerificar`) | version · gate (12) · hooks · auditor · disparos (15) · instalador · sembrar · **agentes (28)** · auditar | `[OK]` × 9, exit 0 ✅ |
| 7 | Auditor del grafo con el split (`brief` + `infra` nuevos, `recursos-del-proyecto` borrado) | `auditar` sin bloqueos ni huérfanas | `Grafo de docs integro.`, exit 0 ✅ |
| 8 | El gate sobre este mismo cambio | `verificar.ps1` (working tree) | exit 0; 2 avisos no bloqueantes acusados en el PR ✅ |
| 9 | Code-review del diff completo (8 ángulos, effort high) | hallazgos atendidos o registrados | 6 hallazgos: 3 curados en el diff (casting coherente arranca↔plantilla, `probar-agentes` al CI, comentario del parser), 3 registrados en [#82](https://github.com/ArmandoMedina/jidoka/issues/82) (siembra a los hijos — decisión de alcance) ✅ |

## Artefactos

Salida cruda de la suite final (esta máquina, 2026-07-16):

```
== Publicar v1.16.0  (derivado del SSOT tools/version.txt) ==
== Suite de self-tests (evidencia-no-palabra antes de publicar) ==
  [OK] probar-version
  [OK] probar-gate
  [OK] probar-hooks
  [OK] probar-auditor
  [OK] probar-disparos
  [OK] probar-instalador
  [OK] probar-sembrar
  [OK] probar-agentes
  [OK] auditar
== Verificado: suite verde. -SoloVerificar no publica. ==
preflight exit=0
```

ROJO del lint (fixture en `$env:TEMP` con `model: gpt-5`, `model:` ausente y 2 asientos faltantes, corrido con `-Dir`): exit 1, 4/15 fallidos con el detalle de cada defecto. VERDE contra `.claude/agents/` real: 28/28, exit 0. (Reporte del subagente constructor; el VERDE re-verificado en la corrida 6 vía preflight.)

## Veredicto

La conciencia quedó instalada, no prometida: los 4 agentes-asiento con tier fijo (el harness los registró en vivo al aterrizar), el lint que caza el alias inventado (ROJO→VERDE) corriendo en preflight y CI, el arranca que inyecta el estado y presenta el router como preview de gates, y el QUÉ/CÓMO separados con el grafo íntegro. El "¿se ve bien?" final lo responde el cliente abriendo una sesión nueva con `/jidoka:arranca` tras el merge.
