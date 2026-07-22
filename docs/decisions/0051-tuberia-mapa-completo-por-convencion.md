# ADR 0051 — La tubería es el mapa completo del repo, derivado por convención (no una lista a mano)

- **Estado:** aceptado
- **Fecha:** 2026-07-22
- **Relacionado:** [ADR 0048](0048-superficie-app-tuberia.md) (la app es la superficie del gobierno) · [ADR 0046](0046-contratos-y-regimenes.md) (los tres regímenes por pieza) · [[CFG-1-gobierno-configurable]] (extiende: "la UI autora, sin editar JSON a mano")

## Contexto

La app de la tubería (ADR 0048) pintaba **49 piezas de una lista curada a mano** (`tools/tuberia-piezas.json`, extraída verbatim de la maqueta). Al usarla, el cliente notó que **mentía por omisión**: no aparecían los **sprints**, los ADRs, los análisis, las guías, los **dominios**, los **módulos** ni la 5ª capacidad (CFG-1) — y seguía mostrando la **Extensión VS Code** ya retirada en la `v1.27.0`. Es el mismo drift que Jidoka combate (el doc dice una cosa, la realidad otra), esta vez **dentro de la propia app de gobierno**. El cliente lo dijo directo: *"deben salir todos absolutamente todos los documentos"* — y el chiste es que aparezcan **sin cablear**, para verlo y **cablearlos desde la app**.

## Decisión

La tubería **deja de leer una lista a mano** y se vuelve el **mapa completo del repo, derivado por escaneo**: `tools/tuberia-datos.ps1` enumera **todos** los archivos (`git ls-files` tracked + untracked, el patrón de `bandeja.ps1`) y clasifica cada uno por su ruta.

Las reglas de clasificación viven **en el lector** (convención, no un JSON de piezas):
- una **tabla `$TIPOS`** (~14 filas `carpeta → tipo bonito → régimen por defecto`) para los árboles conocidos;
- un **catch-all por carpeta** para todo lo demás (docs/sprints → "Sprints", docs/decisions → "ADRs", kanban, doctrina, qa_runs…), régimen `libre`; binarios/assets a un cajón "Otros";
- el nombre de cada pieza se **deriva del propio archivo** (comandos → `/jidoka:<x>`, `.md` → su `# H1`, el resto → nombre de archivo);
- el estado vivo (`contratos.json`) sigue mandando el régimen **por path** encima del default.

**Consecuencia por construcción:** soltar un archivo en su carpeta lo hace **aparecer solo** (sin editar JSON); retirar una carpeta lo hace **desaparecer solo** (auto-cura del stale). Un tipo nuevo = una fila en `$TIPOS`.

## Por qué

- **La lista a mano es justo el drift que Jidoka combate.** Alguien agregó dominios, módulos y CFG-1 al repo, pero nadie los copió al censo → la app mintió. Derivar de la estructura real elimina la clase entera de bug.
- **Extiende CFG-1 al censo.** "La UI autora, sin editar JSON a mano" pasa del contrato al inventario: la estructura del repo **es** la fuente.
- **Completitud verificable.** El test afirma `piezas ≈ git ls-files` — nada puede quedar invisible en silencio.
- **Las aristas vacías son una feature, no una carencia.** Todo aparece "sin cablear"; la app dirá *"esta pieza no está cableada con ninguna otra"* — el trabajo por hacer, visible, para autorar las conexiones desde la app (sprint futuro).

## El camino que NO se toma (y por qué tienta)

- **(a) Mantener la lista curada `tuberia-piezas.json`.** Tienta porque trae prosa curada linda (`confHoy`/`confVision`). Se rechaza: es exactamente lo que se desincronizó. Queda adelgazada como "notas al margen" opcionales (overrides), no como el censo.
- **(b) Frontmatter por archivo** (cada archivo declara su tipo/régimen). Tienta por "cero mapa central". Se rechaza: obliga a meter y mantener una cabecera en **~40 scripts `.ps1`** que no usan frontmatter natural — más costo de mantenimiento que la convención en un lugar.
- **(c) Convención en un JSON de configuración** (folder→tipo). Se rechaza por pedido explícito del cliente: la regla vive **en el lector** (código), no en otro JSON que mantener.

## Consecuencias

- `tools/tuberia-datos.ps1` se re-graba **UTF-8 con BOM**: los nombres de tipo con acento son literales del `.ps1` y PS 5.1 los corrompería sin BOM. No contamina el stdout (el emit escribe bytes aparte, ADR del fix de encoding).
- **Costo de latencia:** leer el `# H1` de ~250 `.md` sube el refresco a ~2 s. Tolerable; optimizable (cache / saltar H1 en cajones enormes) si molesta.
- **Límite conocido (latente):** los globs usan `-like` y `*` cruza `/` — un archivo anidado bajo una carpeta mapeada se clasifica por el tipo del padre. Hoy no ocurre (el árbol no tiene esos anidados) y de hecho se **desea** para `kit/.jidoka/templates/` (con `producto/` anidado). Cura futura si molesta: matcher por-glob recursivo vs directo.
- **Nombres derivados en `innerHTML`:** un `# H1` con `<`/`&` se renderizaría mal (patrón preexistente de la UI). Follow-up: la UI use `textContent`/escape para nombres derivados.
- **Deuda futura (otro sprint):** derivar las **aristas** reales desde sus fuentes (`@` del ritual, `ligas.json`, wikilinks) — mejores que las 57 a mano, que se retiran.

---

> Reglas del registro: una decisión = un archivo · al agregarlo, **listalo en el [índice](README.md) en el mismo commit** (el gate lo exige) · nunca borres una decisión: márcala *reemplazada* y enlaza la nueva.
