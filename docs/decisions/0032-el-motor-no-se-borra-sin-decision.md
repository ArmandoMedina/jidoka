# ADR 0032 — El motor no se muta en silencio: el juez que no midió no aprueba

- **Estado:** aceptado
- **Fecha:** 2026-07-16

## Contexto

Dos jueces del propio motor aprobaron lo que no habían medido, cazados en vivo en la misma cosecha:

1. **Issue #78 — el preflight de `tools/publicar.ps1` imprimía `[OK]` de un test que no corrió.** Al cortar v1.14.0, `probar-instalador.ps1` estaba en cuarentena de antivirus (no existía en disco). El preflight lo invocaba con `& (Join-Path ... "$t.ps1") *> $null`: `CommandNotFoundException` es no-terminante en PowerShell, así que se tragó silenciosamente contra `*> $null`, y `$LASTEXITCODE` conservó el `0` del test **anterior** — el preflight imprimió `[OK] probar-instalador` de un test fantasma.
2. **Issue #73 — un subagente borró `tools/instalar.ps1` (457 líneas) y `tools/probar-instalador.ps1` (293) y ningún gate lo cazó.** El review pasó verde encima; la regresión se re-narró después como "falso positivo de AV" — el antivirus **sí** existía y **sí** había puesto archivos en cuarentena en el pasado (issue #27/#40), pero eso no justificaba dejar el borrado sin revertir ni instruir al auditor a ignorarlo. La ley del blast-radius (`tools/blast-radius.json`) cubre **tocar** un área sin tocar su doc dueño; no tenía nada que decir sobre que una pieza del motor **desapareciera** del árbol — borrar no es un caso de "tocar sin doc", es un caso que la ley no contemplaba.

El hilo común: en ambos casos un juez (el preflight, el gate del PR) certificó un estado que no había verificado de verdad — por un `$LASTEXITCODE` viciado en un caso, por ausencia de regla en el otro. "Verde" no significaba "medido".

## Decisión

Dos curas, mismo principio — **el juez falla cerrado; el motor no se muta en silencio**:

1. **El preflight de `publicar.ps1` falla cerrado ante un test ausente (issue #78).** Antes de invocar cada `probar-*.ps1` (y `auditar.ps1`), una guarda `Test-Path` verifica que el archivo exista en disco; si no existe, `Die` con el porqué ("no se publica a ciegas desde esta máquina; la evidencia server-side vive en el CI") — nunca "[AUSENTE] y seguir". Además, `$LASTEXITCODE` se resetea a `0` antes de cada test, para que un exit code viciado del test anterior no pueda disfrazar de "paso" a uno que nunca corrió. Caso nuevo en `probar-publicar.ps1` (ROJO→VERDE).
2. **El salvavidas determinista `no-borres-el-motor` en `tools/verificar.ps1` (issue #73).** Si el diff del rango **borra** un archivo que casa con `tools/*.ps1` o `tools/blast-radius.json` (detectado vía `git diff --name-only --diff-filter=D`) y **no** hay un ADR nuevo (`docs/decisions/*.md`, excluyendo el índice `README.md`) en el mismo cambio → **`[BLOQUEA]`** (exit 1). Con un ADR en el cambio, pasa: el borrado queda documentado y con dueño. Parámetro nuevo `-BorradosInyectados` para inyectar casos de prueba sin depender de un commit real. Dos casos nuevos en `probar-gate.ps1` (borrado sin ADR bloquea; borrado con ADR pasa), ROJO→VERDE.

## Por qué

- **Una decisión se documenta; un accidente no.** Restaurar un archivo borrado es seguro y barato — el archivo sigue en git, `git checkout` lo trae de vuelta. Lo que el gate protege no es el borrado en sí (a veces es correcto: código muerto, refactor) sino el borrado **sin que nadie lo haya decidido a propósito**. Exigir un ADR nuevo en el mismo cambio es el costo mínimo de convertir "pasó" en "se decidió".
- **El juez que no midió no aprueba.** Un `[OK]` sin ejecución real (issue #78) y un review verde sin regla que mirara el borrado (issue #73) son la misma falla con dos caras: un gate certificando algo que no verificó. La cura en ambos casos es la misma forma — cerrar la vía de "pasar sin medir", no agregar más prosa pidiendo cuidado.
- **El blast-radius medía tocar, no desaparecer.** La ley existente (`doc_bloquea`/`doc_avisa`) presume que el archivo sigue ahí y solo pregunta si su doc dueño lo acompañó. Necesitaba un caso aparte para "el archivo ya no está" — ese es exactamente el salvavidas nuevo, no una variante del matching existente.

## El camino que NO se toma (y por qué tienta)

- **"[AUSENTE] y seguir" para el preflight (#78).** Tienta porque no bloquea un release por un problema local de antivirus — el CI de todas formas corre la suite completa. Se descarta por decisión explícita del cliente (2026-07-16): morir siempre ante un test ausente es más barato que un `[OK]` que miente, aunque a veces frene una publicación que el CI habría validado igual. El camino de dos pasos (preflight local + `gh release create` cuando el AV interfiere, ya usado en v1.14.0) sigue disponible para ese caso.
- **Proteger `tools/` con permisos del sistema de archivos (solo-lectura, ACL).** Tienta porque parece más fuerte que un gate en git. Se descarta: no viaja con el clon (cada hijo tendría que configurarlo a mano), no lo ve CI (un permiso de FS es local a la máquina), y no dice **por qué** se borró algo — solo lo impide o no, sin dejar rastro de la decisión. El gate en `verificar.ps1` viaja con el repo y corre igual en local y en CI.
- **Marcar el borrado como `doc_avisa` en vez de `doc_bloquea`.** Tienta porque es menos fricción. Se descarta: un aviso es exactamente lo que ya falló en el #73 — "avisar" no distingue de "silencio" si nadie lo lee antes de mergear. Borrar una pieza del motor es irreversible en efecto (aunque no en git) hasta que alguien lo nota; es el tipo de acción que la doctrina reserva para `deny`, no `ask`.

## Consecuencias

- **Más fácil:** un borrado accidental de una pieza del motor (subagente que se equivoca de alcance, un `rm` de más) se cae en el propio push/PR, con un mensaje que dice exactamente qué falta y qué hacer (agregar el ADR o restaurar el archivo). El preflight de publicación ya no puede mentir con un `[OK]` de un test fantasma.
- **Más difícil / deuda:** borrar un `.ps1` obsoleto **a propósito** ahora exige un ADR nuevo en el mismo cambio, aunque la limpieza sea trivial y sin controversia — es fricción extra para el caso legítimo. Se acepta como el costo de que el gate no pueda distinguir "borrado trivial" de "borrado que rompe el motor" sin leer intención; el ADR es barato comparado con el costo de un #73 repetido.
- El preflight de `publicar.ps1` ahora falla también ante problemas transitorios de antivirus que antes solo generaban un `[OK]` falso — el camino de publicación en dos pasos (CI + `gh release create`) queda como la vía de escape documentada, no como excepción silenciosa.

---

> Reglas del registro: una decisión = un archivo · al agregarlo, **listalo en el [índice](README.md) en el mismo commit** (el gate lo exige) · nunca borres una decisión: márcala *reemplazada* y enlaza la nueva.
