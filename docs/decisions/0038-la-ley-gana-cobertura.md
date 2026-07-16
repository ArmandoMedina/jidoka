# ADR 0038 — La ley gana cobertura: el atlas se acopla en ambas direcciones, `bin/` entra a barreras, las guías ganan área y la raíz cura sus falsos avisos

- **Estado:** aceptado
- **Fecha:** 2026-07-16

## Contexto

La auditoría de la nave nodriza del 2026-07-16 (PR #94, issue #97) cotejó la ley (`tools/blast-radius.json`) contra el árbol real y encontró superficie sin vigilar: el CLI npx (`bin/jidoka-method.js`) no era fuente de ninguna área; cuatro archivos legítimos de raíz (`CODE_OF_CONDUCT.md`, `package.json`, `package-lock.json`, `jidoka.code-workspace`) disparaban el aviso falso de "archivo suelto"; las guías que viajan como motor a los hijos se editaban sin aviso; y el acoplamiento del atlas (ADR 0036) era unidireccional — cambiar un comando avisaba al diagrama, pero cambiar un script del motor o el atlas mismo no disparaba nada. El costo de esa última asimetría se pagó en 24 horas: el atlas `v1.17.0` y la cosecha #7 `v1.18.0` se cruzaron el mismo día y 7 diagramas del motor quedaron atrás sin que ningún gate lo acusara (issue #95).

## Decisión

Cinco cambios a la ley, todos avisos (ninguna área nueva bloquea — la doctrina del único bloqueo duro se conserva):

1. **El área `atlas` gana `tools/*.ps1` como fuente**: cambiar un script del motor avisa que su diagrama puede haber quedado atrás (amplía el ADR 0036 de comando→diagrama a proceso→diagrama).
2. **El área `metodo` gana `docs/atlas/*` como fuente**: editar el atlas o su toolchain avisa CHANGELOG — el atlas ES método escrito, en visual.
3. **El área `barreras` gana `bin/*`**: el CLI es motor publicable y ahora lo vigila el mismo gate (con `revisa: true` heredado del área).
4. **Área nueva `guias`** (`docs/guias/*` → avisa CHANGELOG): tres guías viajan a los hijos vía el manifiesto; una guía desactualizada se propaga en cada siembra.
5. **La raíz excluye sus canónicos reales**: `CODE_OF_CONDUCT.md`, `package.json`, `package-lock.json` y `jidoka.code-workspace` dejan de disparar el aviso de tierra-de-nadie.

## Por qué

- **Un aviso que grita en falso entrena el click-para-pasar** (`andon/README.md`, regla de campo): los 4 falsos de raíz eran fatiga pura en cada release.
- **El drift del atlas ya no es hipótesis**: la ventana v1.17/v1.18 lo produjo y la auditoría lo midió. Un aviso barato en la dirección que faltaba es la cura proporcional (aviso, no bloqueo — regla 2-3: si el aviso resulta ruidoso en la práctica, se recalibra).

## El camino que NO se toma (y por qué tienta)

- **`product/**` como fuente de un área**: tienta cerrar TODA la superficie, pero editar el brief o una capacidad ya tiene vigilancia estructural (`auditar.ps1`) y un aviso de co-ocurrencia hacia el código no tiene un doc dueño natural que señalar — sería ruido sin acción clara. Queda registrado en #97; si un drift real de product lo paga, se diseña con ese caso.
- **Bloquear en vez de avisar el drift del atlas**: un diagrama atrasado no rompe el motor; bloquear por él violaría "alto valor, baja fatiga". El único bloqueo sigue siendo el índice de ADRs.

## Consecuencias

- **`package.json` queda deliberadamente sin área** (lo señaló el propio code-review de este cambio): al excluirlo de `raiz`, ninguna área lo vigila. Se acepta porque su invariante con dientes —la versión— ya tiene un gate determinista más fuerte que un aviso (`probar-version` muere en preflight y CI si diverge del SSOT `tools/version.txt`), y re-incluirlo en `raiz` restauraría el falso aviso en cada release, que es lo que este ADR cura. Si un cambio no-de-versión a `package.json` (scripts, bin, deps) produce un drift real algún día, ese caso paga el diseño de su vigilancia.

- La ley pasa de 9 a 10 áreas; `andon/README.md` se actualiza en el mismo cambio (su propio gate lo exige).
- Tocar cualquier `tools/*.ps1` ahora produce un aviso más (atlas) — el mensaje enseña cuándo no aplica.
- Las leyes-plantilla de los arquetipos NO cambian: `atlas`, `guias` y `bin/` son piezas de la nave nodriza, no de los hijos (el atlas no viaja en el manifiesto).
