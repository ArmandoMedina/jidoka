# LOG de la corrida — juez-falla-cerrado-20260716

> El artefacto que los gates de evidencia exigen: **este `LOG.md`**. El gate mide que exista, esté fresco y rastreado por git; su **contenido** lo juzga el humano en el Gemba. Datos 100 % sintéticos.

- **Corrida:** juez-falla-cerrado-20260716
- **Fecha:** 2026-07-16
- **Rama:** `sprint-juez-falla-cerrado`
- **Asiento:** escribano (en sesión, casting neutral de la nave nodriza) + subagentes (motor en Opus, docs en Sonnet)

## Método reproducible

1. **#78 ROJO:** agregar el caso `preflight: guarda Test-Path` a `tools/probar-publicar.ps1` y correrlo contra el `publicar.ps1` **viejo** → el caso debe FALLAR (la prueba distingue el bug).
2. **#78 VERDE:** aplicar la guarda `Test-Path` + reset de `$LASTEXITCODE` en `tools/publicar.ps1` y re-correr → 7/7.
3. **#78 en vivo (simulación de cuarentena):** `Rename-Item tools\probar-version.ps1 probar-version.ps1.cuarentena` → correr `tools\publicar.ps1 -SoloVerificar` → debe plantarse de inmediato (exit 1) → restaurar el archivo.
4. **#73 ROJO:** agregar los 2 casos del salvavidas a `tools/probar-gate.ps1` (manifiesto sintético + `-BorradosInyectados`) y correrlos contra el `verificar.ps1` viejo → deben FALLAR.
5. **#73 VERDE:** implementar el salvavidas en `verificar.ps1` y re-correr `probar-gate` → 12/12.
6. **Suite completa** en esta máquina (sin AV que interfiera; verificado: cero `skip-worktree`, motor entero en disco).

## Resultados

| # | Caso | Check | Resultado (obtenido / esperado) |
|---|---|---|---|
| 1 | #78 ROJO — caso nuevo vs publicar viejo | `probar-publicar` detecta la falta de guarda | `[FALLA] preflight: guarda Test-Path…` 6/7, exit 1 / FALLA ✅ |
| 2 | #78 VERDE — caso nuevo vs publicar curado | 7/7 | `publicar.ps1 sano: los 7 casos…`, exit 0 / PASA ✅ |
| 3 | #78 en vivo — `probar-version.ps1` fuera del disco | el preflight se planta, no `[OK]` mudo | `[ERROR] probar-version.ps1 no existe en disco (AV/cuarentena?)…`, exit 1, cero `[OK]` falsos / PLANTADO ✅ |
| 4 | #73 ROJO — casos del salvavidas vs verificar viejo | `probar-gate` detecta el hueco | `[FALLA] bloquea: BORRAR pieza del motor sin ADR nuevo (no-borres-el-motor) (exit 0, esperaba 1)` — 11/12, exit 1 / FALLA ✅ |
| 5 | #73 VERDE — salvavidas implementado | `probar-gate` 12/12 | `Gate sano: los 12 casos se comportan como se espera.`, exit 0 / PASA ✅ |
| 6 | Suite completa (preflight `publicar -SoloVerificar`) | probar-version · gate (12) · hooks (29) · auditor · disparos (15) · instalador (51) · sembrar (26) · auditar | `[OK]` × 8, `Verificado: suite verde`, exit 0 ✅ |
| 7 | Meta-test del publicador | `probar-publicar` 7/7 | `publicar.ps1 sano: los 7 casos…`, exit 0 ✅ |
| 8 | El gate sobre este mismo cambio | `verificar.ps1` (working tree) | exit 0; 3 avisos no bloqueantes, acusados en el PR (cita no tocada; nota AND-1 actualizada tras el aviso; package.json = bump del SSOT) ✅ |

## Artefactos

Salida cruda del caso #78 en vivo (transcripción fiel, esta máquina 2026-07-16):

```
== Publicar v1.14.0  (derivado del SSOT tools/version.txt) ==
  titulo: v1.14.0 - El instalador AV-seguro se vuelve completo — `sembrar-manual.ps1` siembra la instancia entera (ADR 0027, enmienda)
  rama: sprint-juez-falla-cerrado | arbol limpio: False | tag v1.14.0 ya existe: True
== Suite de self-tests (evidencia-no-palabra antes de publicar) ==
[ERROR] probar-version.ps1 no existe en disco (AV/cuarentena?): no se publica a ciegas desde esta maquina. La evidencia server-side vive en el CI (andon.yml lo corre); release en dos pasos como v1.14.0 (preflight en CI + gh release create).
exit=1
```

(El archivo se restauró de inmediato: `Test-Path tools\probar-version.ps1` → `True`.)

Salida cruda del caso #73 ROJO (casos escritos primero, `verificar.ps1` viejo — fragmento relevante):

```
  [FALLA] bloquea: BORRAR pieza del motor sin ADR nuevo (no-borres-el-motor) (exit 0, esperaba 1)
== 1 de 12 caso(s) fallidos. El gate tiene un bug: no lo estrenes. ==
EXIT=1
```

Nota honesta del ROJO: contra el gate viejo, el parámetro `-BorradosInyectados` no existe → binding error dentro de `&`, salida vacía y `$LASTEXITCODE` viciado en 0. El caso (a) falla con "exit 0, esperaba 1" (ROJO válido); el caso (b) pasa **vacuamente**. El ROJO significativo es el caso (a) — exactamente la clase de mecanismo (#78) que este mismo sprint cura en el preflight.

Salida cruda del caso #73 VERDE:

```
  [PASA]  bloquea: BORRAR pieza del motor sin ADR nuevo (no-borres-el-motor)
  [PASA]  pasa: BORRAR pieza del motor CON ADR nuevo en el mismo cambio (no-borres-el-motor)
== Gate sano: los 12 casos se comportan como se espera. ==
EXIT=0
```

## Veredicto

Ambos jueces fallan cerrado con evidencia ROJO→VERDE: el preflight se planta ante un test ausente (#78, probado en vivo con simulación de cuarentena) y el gate bloquea el borrado de motor sin ADR / lo aprueba con ADR (#73, `probar-gate` 12/12). Suite completa verde en esta máquina (2026-07-16, sin `skip-worktree`, motor entero en disco). El "¿se ve bien?" final lo responde el cliente en el Gemba.
