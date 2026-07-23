# ADR 0058 — Los hooks del muro fallan cerrado: crash y ley ausente ya no son un pase silencioso

- **Estado:** aceptado
- **Fecha:** 2026-07-23

## Contexto

La kata de la huella en labs (2026-07-23, [`exploracion-huella-en-labs-202607.md`](../analisis/exploracion-huella-en-labs-202607.md)) y el spike de allowlist ([`exploracion-allowlist-por-asiento-202607.md`](../analisis/exploracion-allowlist-por-asiento-202607.md)) midieron en vivo dos fallas-abiertas en los propios hooks del muro:

- Los **4 Stop hooks** (`andon-stop`, `review-stop`, `gemba-stop`, `validador-stop`) salían `exit 0` cuando faltaba `tools/blast-radius.json` — sin la ley, silencio, y dejaban cerrar (medido A/B: con ley `decision:block`; sin ley, nada).
- Un **`SyntaxError` en el hook `PreToolUse`** (`candado-pretooluse.ps1`) dejó pasar la escritura que debía bloquear, sin ruido: el propio hook confesaba su falla-abierta (`:26`). Un hook del muro que se abre cuando truena no es muro.

La tesis del producto es explícita (`doctrina/00-tesis.md`): *un muro que ante fallo interno se abre no es muro, es una sugerencia.* El verificador ya lo cumple (`Fail` → exit 2). Los hooks no.

## Decisión

Los hooks del muro **fallan cerrado** ante ausencia de ley o crash propio:

- **Los 4 Stop hooks** salen **`exit 2` («no apruebo a ciegas»)** cuando falta `tools/blast-radius.json`, en vez de `exit 0`. Con la ley presente, comportamiento intacto.
- **El candado `PreToolUse` se parte en dos**: un **envoltorio delgado a prueba de parseo** (`candado-pretooluse.ps1`) que corre la lógica real (`candado-pretooluse.core.ps1`) en un **proceso hijo**. Si el core truena (exit ≠ 0) o **no emite un centinela de veredicto reconocible** (`<<<JIDOKA-CANDADO-OK>>>` en cada camino de paso), el envoltorio **emite DENY**. El «silencio» deja de significar «pase». El core corre con `$ErrorActionPreference='Stop'`.
- **Frontera deliberada:** si el `.core` **no existe**, el envoltorio deja pasar — un repo sin el motor del hook (hijo sin sembrar del todo) no se brickea. La falla-cerrada es ante *crash*, no ante *ausencia de instalación*.

## Por qué

- **La regla ya está probada en el verificador:** «el gate que no puede medir no aprueba» (exit 2). Esto la extiende a los hooks, que eran la excepción incoherente.
- **El crash es el vector más silencioso:** un `SyntaxError` no deja ni log; el envoltorio-en-proceso-hijo es la única forma de atrapar un fallo de *parseo* del propio hook (un `try/catch` en el mismo archivo no atrapa su propio error de sintaxis).
- **Decisión del cliente:** el informe marcó el fail-open de los Stop hooks como decisión pendiente del dueño (diseño vs defecto); el dueño la resolvió como **defecto** el 2026-07-23.

## El camino que NO se toma (y por qué tienta)

**Envolver la lógica en un `try/catch` dentro del mismo `candado-pretooluse.ps1`** (sin archivo core aparte). Tienta porque es un archivo menos. Se descarta: un `try/catch` **no atrapa un `SyntaxError` de su propio archivo** — el parser falla antes de que el `try` exista, y el hook nunca corre. Solo un envoltorio separado, que no comparte parseo con la lógica y la ejecuta como proceso hijo, puede convertir «el hook no parseó» en «DENY». El costo (un archivo `.core` que viaja a los hijos) es el precio de atrapar el fallo más silencioso.

También se consideró **exit 1** para los Stop hooks sin ley; se usó **exit 2** para distinguir «falla cerrado por no poder medir» de «bloqueo por incumplimiento» (exit 1), coherente con el verificador.

## Consecuencias

- **Más fácil:** confiar en que un cierre no pasa sin la ley, y en que un hook roto bloquea en vez de abrir.
- **Más difícil:** un repo con los hooks instalados pero sin `blast-radius.json` ya no cierra — es el comportamiento buscado, pero exige que la ley viaje con los hooks (el manifiesto ya siembra `.claude/hooks` como directorio, y el `.core` con él).
- **Deuda:** el envoltorio confía en un centinela de texto (`<<<JIDOKA-CANDADO-OK>>>`); un core comprometido podría imprimirlo. El modelo de amenaza es «hook que truena por error», no «core adversario» — la integridad del core la cubre el salvavidas `no-borres-el-motor` y el required check server-side.

## Qué NO resuelve

- No cubre un hook que **cuelga** (proceso hijo que no retorna): el envoltorio depende del timeout del harness, no propio. Queda como deuda si se mide en vivo.
- No toca la falla-abierta del **matcher heurístico de Bash** de `candado-pretooluse` (límite conocido, ya documentado): esto endurece el *crash*, no la cobertura del matcher.
