# ADR 0047 — El meta-gobierno son tres piezas (contraseña-ritual, firma, candado IA); el único muro es el hook PreToolUse, el `permissions.deny` es capa estática barata

- **Estado:** aceptado
- **Fecha:** 2026-07-21
- **Relacionado:** [ADR 0045](0045-identidad-sistema-gobierno-configurable.md) (la identidad) · [ADR 0046](0046-contratos-y-regimenes.md) (`contratos.json`, donde vive el candado y la firma) · [ADR 0002](0002-motor-andon.md) (el muro vive fuera del LLM) · [ADR 0018](0018-muro-grietas-2-5.md) (el hook `no-memorias` que este calca) · [[CFG-1-gobierno-configurable]]

## Contexto

Si el usuario puede reclasificar regímenes y aceptar desviaciones desde la UI, aparece la pregunta del **meta-gobierno**: ¿qué evita el cambio ciego, la atribución inventada, o que la **IA** edite una pieza que el cliente marcó intocable? El censo halló el terreno sin usar: `permissions` de `settings.json` **vacío**, `PreToolUse` subutilizado (solo `no-memorias` lo usa), y el disparo `deny-vs-ask` lleva meses **catálogo-solo** — la doctrina lo pedía, nadie lo cableó. La regla del cliente: *"bajo su propio riesgo" = garantía nula, nunca desviación muda.*

## Decisión

El meta-gobierno se arma con **tres piezas de dureza creciente**:

1. **Contraseña-ritual** — pública en el README, es **deliberación, no seguridad**: *"no le muevas si no le sabes"*. En VS Code el humano ya es humano (la extensión corre fuera del LLM), así que se pide como **confirmación tipeada del disclaimer** (patrón "escribe el nombre del repo"). Fricción deliberada que obliga a leer antes de reclasificar.
2. **Firma** — a registro, para **atribución**: quién/cuándo/porqué, **derivada de `git config user.name/email` + fecha ISO** (determinista, no inventada por el agente). Sin **motivo** no hay reclasificación. Se escribe en `contratos.json` (ADR 0046).
3. **Candado IA** — el **hook `PreToolUse`** que **deniega en el momento** (`hookSpecificOutput.permissionDecision='deny'`) cuando el agente intenta editar (Write/Edit/Bash) una pieza con candado, nombrando el contrato y el camino legal. **Es el único muro determinista.** Calca `no-memorias-pretooluse.ps1` línea por línea: stdin JSON, **falla-ABIERTA** (exit 0) si no parsea o si `contratos.json` no existe (el hook viaja a hijos sin ledger).

El **`permissions.deny` de `settings.json` es capa estática barata, no el enforcement.** Se documenta honesto su límite: el `deny` de Bash matchea por **prefijo de comando**, **no por ruta destino** — un `Set-Content` a la ruta prohibida no lo caza por `deny`; el **hook sí** (con la misma heurística confesada del `no-memorias`, cuyo residual —aliases, rutas ofuscadas— ya vive en `andon/README.md`). Los `deny` estáticos de motor entran al `settings.json` sembrado **solo si su sintaxis se verifica contra la doc vigente al implementar**; los `deny` del cliente van a `settings.local.json`, **nunca** al sembrado.

## Por qué

- **Doctrina del único muro** (`doctrina/00-tesis.md`): el punto de control es muro real solo si vive **fuera del LLM**. El hook `PreToolUse` corre en el harness, no en el modelo — por eso es el enforcement, y el `deny` estático (que el modelo podría rodear con un alias) es solo un cinturón barato.
- **El hook intercepta en la estación, no al final de la línea.** `PreToolUse` frena *cada* edición en el momento (poka-yoke); los cuatro gates gordos son inspectores al cierre (Stop). Para "la IA no toca esto", el momento correcto es antes del Write, no en el push.
- **La atribución no se inventa.** Derivar la firma de `git config` la vuelve determinista y auditable; una firma que el agente teclea es palabra-no-evidencia.

## El camino que NO se toma (y por qué tienta)

- **Confiar solo en `permissions.deny`.** Tienta porque es declarativo y nativo del harness. Se rechaza como muro: matchea por prefijo de comando, es gameable con aliases/rutas ofuscadas, y **no** protege una ruta destino. Se conserva como capa estática barata, no como enforcement.
- **La contraseña-ritual como seguridad real.** Tienta por "candado con clave". Se rechaza: no es criptografía sino deliberación; el humano en VS Code ya está autenticado como humano. Pedir más sería teatro de seguridad.
- **Firma inventada / editable por el agente.** Tienta por simplicidad. Se rechaza: rompe la atribución. Se deriva de `git config`, fuente única y determinista.
- **Hook que falla-cerrado si falta `contratos.json`.** Tienta por "seguro por defecto". Se rechaza: el hook se siembra a hijos que **no** tienen el ledger; fallar-cerrado ahí bloquearía toda edición en un repo sin candados. Falla-**abierta** (como `no-memorias`), documentado.

## Consecuencias

- El disparo **`deny-vs-ask` pasa de catálogo-solo a cableado** (R5): se actualiza su ficha y `probar-disparos` lo vigila contra rot.
- Nace **`.claude/hooks/candado-pretooluse.ps1`** (R5) + su prueba de vida en `probar-hooks`; `settings.json` gana una 2ª entrada `PreToolUse`.
- El **modo avanzado** (R6) escribe candado/reclasificación/desviación con firma en `contratos.json`; la **bandeja** (R2) resta lo firmado y pinta el badge.
- Límite v0 aceptado (heredado del `no-memorias`, confesado en `andon/README.md`): la heurística de Bash no cubre todos los aliases ni rutas ofuscadas — el candado es un poka-yoke fuerte, no una jaula perfecta; el muro server-side sigue siendo la protección de la rama.
