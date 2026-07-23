# LOG de la corrida — auditor-gemba-volver-muro-20260723

- **Corrida:** auditor-gemba-volver-muro-20260723
- **Fecha:** 2026-07-23
- **Rama:** sprint/volver-muro-exploraciones-20260723
- **Asiento:** auditor

## Metodo reproducible

Fixtures temporales aislados bajo el scratchpad de la sesion (NUNCA el repo real; solo lectura de sus tools/*.ps1 y .claude/hooks/*.ps1). Un solo script `run-gemba.ps1` (no versionado) corrio los 5 casos en secuencia:

1. **Candado ROADMAP:** fixture con `tools/flujo.json` (`roadmap.procedencia:true`) + `ROADMAP.md`. `powershell tools/verificar.ps1 -Repo <fixture> -Cambiados ROADMAP.md`.
2. **Stop fail-closed (R5):** repo git temporal, `tools/motor.ps1` cambiado sin commitear, `'{}' | powershell .claude/hooks/andon-stop.ps1` con `CLAUDE_PROJECT_DIR` apuntando al repo temporal.
3. **Candado del marcador (R3):** JSON PreToolUse por stdin al CORE directo `powershell .claude/hooks/candado-pretooluse.core.ps1` (sin el envoltorio; no escribe nada, solo evalua el veredicto).
4. **R7 (raiz vs cwd):** parado en una carpeta neutral fuera del fixture, `powershell tools/estado-flujo.ps1 -Gate -Repo <fixture>`. Mas barato que levantar el harness completo de `probar-flujo.ps1`; replica su caso `cwd1` (mismo fixture, mismo assert).
5. **R8 (instalador falso-verde):** reproduccion a mano del caso 5i/5j de `tools/probar-instalador.ps1` (mas barato que correr el suite completo): maquinaria copiada bajo `jidoka/tools/*` (anidada) vs. instalacion limpia en `tools/` (aplanada), ambas con `powershell tools/instalar.ps1 -Sellar`.

## Resultados

| # | Muro | Provocacion (input malo) | Money-line del mordisco | Control (input bueno) -> money-line | Veredicto |
|---|---|---|---|---|---|
| 1 | Candado ROADMAP (contrato-roadmap) | item vivo sin puntero, `roadmap.procedencia:true` | exit 1 — `[BLOQUEA] [contrato-roadmap] ... falta(n) procedencia (informe docs/analisis/, record de sprint, ADR o #issue)` | item con `docs/analisis/algo-202607.md` existente -> exit 0 — `[OK] [contrato-roadmap] ROADMAP.md dentro de contrato (1 items clasificados, 4/90 lineas)` | Verifique ambos tiros: cumple |
| 2 | Stop fail-closed (R5, andon-stop.ps1) | ley `tools/blast-radius.json` = `{}` (vacia, JSON valido) + diff sin commitear | exit 2 — `BLOQUEO (andon-stop): la ley ... no tiene contenido usable (... '{}' ...). No apruebo a ciegas` | ley REAL (`tools/blast-radius.json` del repo) + mismo diff -> exit 0 (silencio, deja cerrar) | Verifique ambos tiros: cumple |
| 3 | Candado del marcador (R3 + ADR 0058) | Write a .claude/.review-marker (+ variante evasion traversal `.claude/x/../.review-marker`) | `"permissionDecision":"deny"` — "el marcador ... lo pone un HUMANO fuera del agente; el agente no se auto-firma" (identico en la variante traversal) | Write a `tools/foo.ps1` (archivo normal) -> `<<<JIDOKA-CANDADO-OK>>>` (allow) | Verifique los 3 tiros (malo, evasion, control): cumple |
| 4 | Resuelve contra la raiz, no el cwd (R7) | `estado-flujo.ps1 -Gate -Repo <fixture>` invocado parado en una carpeta neutral ajena al fixture | `[OK] flujo despejado: 0 Gembas pendientes (WIP limite: 3)` — SIN "no aplica" (si hubiera resuelto contra el cwd, el fixture no tiene `tools/flujo.json` ahi y hubiera dicho `[no aplica]`) | mismo run: la ausencia de "no aplica" ES el control (mecanismo de resolucion unica, no par malo/bueno separable) | Verifique: cumple |
| 5 | Instalador no sella a ciegas (R8) | maquinaria ANIDADA (`jidoka/tools/verificar.ps1`, `auditar.ps1`) + `instalar.ps1 -Sellar` | exit 1, sello NO escrito — `[ERROR] no encontre ninguna pieza de motor ... NO sello a ciegas -- eso dejaria un sello vacio y un segundo motor` | maquinaria APLANADA en `tools/` raiz + `-Sellar` -> exit 0 — `Sello escrito: 111 pristina(s) registrada(s)` | Verifique ambos tiros: cumple |

## Artefactos

- Script de corrida (efimero, no versionado): `%TEMP%\claude\...\scratchpad\run-gemba.ps1` y su salida completa en `scratchpad\gemba-output.txt` (session-scoped, no toca el repo real).
- Fixtures bajo `scratchpad\gemba\{m1-malo,m1-control,m2-repo,m4-fixture,m5-anidado,m5-aplanado,neutral}` — todos creados y destruidos en el scratchpad de la sesion, nunca dentro de `C:\Repositorios\jidoka`.
- Este LOG resume las money-lines; la salida cruda completa (76 lineas) queda en el scratchpad de la sesion, no en este directorio (regla de brevedad).

## Veredicto

Los 5 muros del sprint "volver muro" MUERDEN: cada uno rechazo el tiro malo (money-line de bloqueo/deny/fail-closed) y dejo pasar el tiro de control (money-line de OK/allow/exit 0) en la misma corrida. 5/5 verde, 0 hallazgos de muro que deje pasar lo que deberia frenar.

## Actualizacion tras el cierre del /code-review (orquestador, 2026-07-23)

El /code-review posterior cazo 4 huecos de borde que se curaron y se re-verificaron de forma independiente (probar-flujo 140/140, probar-hooks 87/87, verificar -Base main verde):

- La rama de guion (R2) que aceptaba un record docs/sprints/ SIN verificar existencia ahora MUERDE: un guion que apunta a un sprint inexistente BLOQUEA (test g9).
- La procedencia (R1) ya no acepta un '#' incidental pegado a palabra: 'page#2' BLOQUEA (test r12p); ' #67' legitimo sigue pasando (r13p).
- La vista del apetito ya no extrae un valor truncado de 'apetito:30m5h' (test m11).
- Los hooks gemba-stop/validador-stop ganaron el quotepath=false que le faltaba a sus hermanos (nombres no-ASCII ya no se les escapan).

Los 5 muros de la tabla siguen mordiendo; estos fixes solo cerraron holguras de borde. Evidencia: suites verdes + auditor independiente (no el que aplico los fixes).
