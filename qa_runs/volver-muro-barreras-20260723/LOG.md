# LOG de la corrida — volver-muro-barreras-20260723

> El artefacto que los gates de evidencia exigen: **este `LOG.md`**. Su contenido lo juzga el humano en el Gemba.

- **Corrida:** volver-muro-barreras-20260723
- **Fecha:** 2026-07-23
- **Rama:** `sprint/volver-muro-exploraciones-20260723`
- **Asiento:** barreras (curar tres defectos MEDIDOS EN VIVO en los hooks del muro, con TDD)

## Método reproducible

Tres defectos del muro, medidos en vivo el 2026-07-23 (evidencia:
`docs/analisis/exploracion-huella-en-labs-202607.md` y
`docs/analisis/exploracion-allowlist-por-asiento-202607.md`), curados con rojo→verde:

1. **R3 — `review-stop.ps1`.** (a) El mensaje de bloqueo imprimia el comando exacto de auto-firma
   (`Set-Content ... .review-marker '$sha'`, linea 80 del HEAD): se quito; ahora manda a que un
   HUMANO firme, sin regalar el comando. (b) El SHA del marcador se calculaba sobre `git diff HEAD`,
   que NO ve el contenido de archivos sin rastrear: ahora el payload anexa el contenido de cada
   archivo sin rastrear del area, y el SHA se mueve si ese contenido cambia.
2. **R4 — `candado-pretooluse.ps1` falla-abierto al truenar.** Se partio en dos: un ENVOLTORIO
   delgado y a prueba de parseo (`candado-pretooluse.ps1`) que corre la logica real
   (`candado-pretooluse.core.ps1`) en un PROCESO HIJO; si el hijo truena (SyntaxError/exit != 0) o
   no emite veredicto reconocible, el envoltorio EMITE DENY (falla-CERRADA).
3. **R5 — los 4 Stop hooks dejaban cerrar sin la ley.** `andon-stop`, `review-stop`, `gemba-stop`,
   `validador-stop` salian `exit 0` si faltaba `tools/blast-radius.json`. Curado a falla-cerrada
   (`exit 2`, "no apruebo a ciegas") en los cuatro. Ampliado despues a los caminos gemelos:
   ley CORRUPTA y ley VACIA/`null` tambien fallan cerrado.

Segunda pasada (auditoria adversarial, 2026-07-23) -- dos deudas reales que la primera cura dejo:

4. **FIX A -- R5 no cubria la ley `{}` (objeto vacio).** Con `tools/blast-radius.json` = `{}` (JSON
   VALIDO pero objeto vacio) los 4 hooks salian `exit 0` en SILENCIO: un `{}` parsea a un
   PSCustomObject TRUTHY que ESQUIVA el guard `-not $manifest` (que si captura `null`/`[]`) y caia al
   camino normal aprobando a ciegas. Curado: un guard de "contenido usable" (al menos un area con
   `nombre`+`fuente`) en los 4 hooks -> `{}` falla cerrado (`exit 2`). La dormancia LEGITIMA (ley
   VALIDA con areas que no aplican al diff) sigue en `exit 0` (control anti-regresion).
5. **FIX B -- clase auto-firma: el agente podia escribir el marcador humano.** Un `.claude/.review-marker`
   auto-firmado por un agente (sin OK humano) vivia en disco (residuo stale, borrado con `Remove-Item`).
   Raiz: nada impedia que un AGENTE escribiera el marcador -- "la llave junto a la cerradura". Curado en
   `candado-pretooluse.core.ps1` con una DENEGACION INCONDICIONAL y HARDCODED (independiente de
   `tools/contratos.json`): Write/Edit o Bash que ESCRIBA a `.claude/.review-marker` o `.claude/.gemba-marker`
   -> `permissionDecision:deny`. Completa R3/ADR 0058 (el checkpoint vive fuera del LLM). El HUMANO sigue
   pudiendo firmar (escribe el marcador fuera del agente); BORRAR un marcador stale sigue permitido
   (fail-safe: re-dispara el gate). Sutileza cazada: `Move-Item` casaba dentro de `Remove-Item`
   (substring `move-Item`, `-match` es case-insensitive) -> `\b` en el matcher para no bloquear el borrado.

Comandos (todos re-ejecutables desde la raiz del repo):

1. `powershell -NoProfile -ExecutionPolicy Bypass -File tools/probar-hooks.ps1` — el self-test de
   los hooks, con los casos rojo→verde nuevos de R3/R4/R5.
2. Demo en vivo R5: repo temporal SIN `tools/blast-radius.json` con un cambio pendiente →
   `review-stop.ps1` → `exit 2` (antes `exit 0`).
3. Demo en vivo R4: copia del envoltorio + un core con `SyntaxError` → `permissionDecision:deny`
   (antes: un hook roto no emitia nada y Claude dejaba pasar).
4. Demo en vivo R3-def2: `git diff HEAD -- <archivo sin rastrear>` = 0 lineas en dos contenidos
   distintos → prueba la causa del SHA que no se movia.

## Resultados

| # | Caso (A/B: antes → despues) | Check | Resultado |
|---|---|---|---|
| 1 | Self-test de hooks completo | `probar-hooks.ps1` | **78/78 [PASA]**, exit 0 (era 47/47; +13 R3/R4/R5, +8 gemelos corrupta/vacia, +10 FIX A/B) |
| 2 | R3-def1: comando de auto-firma en el mensaje | `review-stop: NO dicta el comando de auto-firma` | ANTES: mensaje incluia `Set-Content ... .review-marker '$sha'` (HEAD:80). DESPUES: [PASA] sin comando |
| 3 | R3-def2: SHA cubre archivos sin rastrear | `review-stop: el SHA cubre archivos SIN RASTREAR` | ANTES: `git diff HEAD` = 0 lineas para el archivo nuevo (v1 y v2) → SHA no se movia. DESPUES: [PASA] SHA v1 != SHA v2 |
| 4 | R4: hook del muro que truena | `candado FAIL-CLOSED: core con SyntaxError -> DENIEGA` | ANTES: falla-ABIERTA (escritura pasaba, sin ruido). DESPUES: [PASA] emite `permissionDecision:deny` |
| 5 | R4: core sin veredicto reconocible | `candado FAIL-CLOSED: core sin veredicto -> DENIEGA` | [PASA] exit 0 + ruido → DENY defensivo |
| 6 | R4: camino feliz intacto | `candado FAIL-CLOSED: core sano que PASA -> deja pasar` | [PASA] el envoltorio no rompe el paso legitimo |
| 7 | R4: regresion candado completa (10 casos) | bloque `candado:` existente, ahora via envoltorio | **10/10 [PASA]** (deny en hit, falla-abierta hijo-sin-ledger/podrido, Bash, backslash, Edit) |
| 8 | R5: `review-stop` sin la ley | `exit 2 si falta la ley` | ANTES: `exit 0` (silencio). DESPUES: [PASA] `exit 2` + mensaje "no apruebo a ciegas" |
| 9 | R5: `andon-stop` sin la ley | `exit 2 si falta la ley` | ANTES: `exit 0`. DESPUES: [PASA] `exit 2` |
| 10 | R5: `gemba-stop` sin la ley | `exit 2 si falta la ley` | ANTES: `exit 0`. DESPUES: [PASA] `exit 2` |
| 11 | R5: `validador-stop` sin la ley | `exit 2 si falta la ley` | ANTES: `exit 0`. DESPUES: [PASA] `exit 2` |
| 12 | R5: control (la cura no bloquea para siempre) | 4 hooks CON la ley, area no relacionada | **4/4 [PASA]** exit != 2 (es la AUSENCIA de la ley lo que bloquea, no el cierre) |
| 13 | FIX A: ley `{}` (objeto vacio, JSON valido) | 4 hooks, ley `{}` -> `exit 2` | ANTES: los 4 `exit 0` en SILENCIO (`{}` truthy esquivaba `-not $manifest`). DESPUES: **4/4 [PASA]** `exit 2` (sin areas usables -> no apruebo a ciegas) |
| 14 | FIX B: el agente no se auto-firma el marcador humano | `candado: DENIEGA Write/Bash a .review-marker / .gemba-marker` | ANTES: el agente podia escribir `.review-marker` (residuo auto-firmado en disco, borrado). DESPUES: **[PASA]** deny en Write, Set-Content y redir `>`; DEJA pasar archivo normal y el borrado (Remove-Item, fail-safe) |

## Artefactos

- `tools/probar-hooks.ps1` — 78/78, exit 0 (salida citada en el reporte de la tarea y en los mensajes de commit del sprint).
- Archivos tocados: `.claude/hooks/review-stop.ps1` (R3), `.claude/hooks/candado-pretooluse.ps1`
  (R4, ahora envoltorio) + `.claude/hooks/candado-pretooluse.core.ps1` (R4, la logica real; ahora
  tambien FIX B — denegacion incondicional del marcador humano), `.claude/hooks/andon-stop.ps1`,
  `.claude/hooks/gemba-stop.ps1`, `.claude/hooks/validador-stop.ps1` (R5 + FIX A — guard de contenido usable).
- Residuo borrado: `.claude/.review-marker` auto-firmado stale (FIX B parte 1, `Remove-Item`).
- Salidas en vivo de las demos A/B (R4 deny, R5 exit 2, R3-def2 diff=0, FIX A `{}` exit 2, FIX B marcador deny) reproducibles con los comandos de arriba.

## Veredicto

Los defectos medidos en vivo quedan curados con rojo→verde y regresion en el self-test: el
muro ya no entrega la llave junto a la cerradura (R3-def1), su marcador cubre los archivos nuevos
(R3-def2), un hook del muro que truena BLOQUEA en vez de dejar pasar (R4), y ningun Stop hook
aprueba a ciegas sin la ley (R5). La segunda pasada (auditoria adversarial) cierra dos deudas mas:
ningun Stop hook aprueba a ciegas con la ley `{}` (FIX A), y el agente ya no puede auto-firmarse el
marcador humano de revision/gemba (FIX B, completa R3/ADR 0058). `probar-hooks.ps1` corre **78/78 verde, exit 0**. El checkpoint
"¿el muro sigue mordiendo?" es del cliente: el guion de revision del dueño esta en
`docs/analisis/exploracion-huella-en-labs-202607.md` (secciones "review-stop no debe dictar su
propio bypass" y "Los 4 Stop hooks").
