# Atlas de procesos de Jidoka (BPMN)

Traducción **AS-IS** del método Jidoka a diagramas de proceso navegables. Es documentación
del método (para leerlo y auditarlo como un proceso), **no** una afirmación de que la
metodología actual sea óptima. La decisión de adoptar esta capa vive en
[`docs/decisions/0035-atlas-de-procesos-bpmn.md`](../decisions/0035-atlas-de-procesos-bpmn.md).

## Por qué BPMN

Se comparó el mismo proceso en BPMN, Mermaid y D2. BPMN ganó por **fidelidad**: da carriles
(swimlanes) reales de banda completa e iconografía estándar que cae justo en Jidoka —
**tarea de servicio (engrane) = lo que hace el agente**, **tarea de usuario (persona) = el
checkpoint humano (STOP)**, **rombo con X = gateway exclusivo**. Mermaid rompía los carriles;
D2 se veía bonito pero los carriles eran cajas, no bandas.

El costo de BPMN (coordenadas a mano) se neutraliza con el toolchain de abajo.

## Cómo se navega

1. Empieza en [`00-arquitectura/00-arquitectura-procesos-jidoka.bpmn`](00-arquitectura/00-arquitectura-procesos-jidoka.bpmn):
   es un **router de necesidad** (gateway), no una secuencia — no implica que las cuatro
   familias ocurran una tras otra.
2. Una actividad de **borde grueso** es una **Call Activity**: su detalle vive en otro archivo
   (el nombre aparece debajo). bpmn.io no abre el archivo hijo solo; usa el índice.
3. Una actividad con **`+`** es un **subproceso embebido**: drill-down dentro del mismo archivo.
4. [`RELACIONES.csv`](RELACIONES.csv) es el índice exacto padre → hijo (`calledElement` → `process id`).
5. [`RUTA-SUGERIDA.md`](RUTA-SUGERIDA.md) da rutas de lectura por objetivo.

Niveles: **0** arquitectura → **1** familias (`00-arquitectura/01`–`04`) → **2** detalle
(`10-ritual/`, `30-instalacion/`, `40-lazo-motor/`, `70-auditoria/`, `80-release/`) →
**3** subprocesos embebidos (`10-ritual/10-arranca-con-subprocesos.bpmn`).

## Cómo trabajamos juntos en un diagrama

El **archivo `.bpmn` es la interfaz compartida**: Claude edita el XML (semántica), tú lo ves
renderizado y afinas la posición si hace falta.

1. **Editor visual (recomendado):** instala la extensión de VS Code **Miragon "BPMN Modeler"**
   (`miragon-gmbh.vs-code-bpmn-modeler`). Al abrir este repo, VS Code la ofrece sola
   (ver `.vscode/extensions.json`). Abre cualquier `.bpmn`/`.dmn` como editor visual, con diff
   visual en los PRs. Cuando Claude guarda un cambio, recarga la pestaña para verlo.
   - ⚠️ **Trampa del buffer viejo (costó 3 sesiones de confusión):** el editor visual **no
     recarga solo** cuando git cambia el `.bpmn` por debajo (un merge, un `checkout`, un
     `-Actualizar`). Si la pestaña muestra `●` (sin guardar) y el diagrama **no cuadra con su
     `.svg`**, estás viendo una **copia vieja en la memoria del editor**, no lo que hay en disco.
     **NO guardes** (un Ctrl+S escribiría la versión vieja encima de la buena) — usa **`Revert
     File`** (Ctrl+Shift+P) para recargar del disco. El disco y su `.svg` mandan; el buffer del
     editor, no.
   - Sin VS Code: **Camunda Modeler** (escritorio) o **demo.bpmn.io** (arrastrar y soltar, cero instalación).
2. **Regenerar geometría sin acomodar cajas a mano** (diagramas nuevos o muy editados):
   ```
   npm run atlas:layout -- docs/atlas/10-ritual/16-cierra-as-is.bpmn
   ```
   Usa `bpmn-auto-layout`. Revisa el resultado en el editor; los lanes a veces necesitan un retoque.
3. **Ver los diagramas en el PR / GitHub** (que no pinta `.bpmn`): renderiza a SVG versionado.
   ```
   npm run atlas:render                                      # todos
   npm run atlas:render -- 10-ritual/16-cierra-as-is.bpmn    # uno
   ```
   Salen a [`render/`](render/). Usa `npx bpmn-to-image` on-demand (baja Chromium solo la 1ª vez).
4. **Validar la integridad estructural** (todo `calledElement` resuelve, toda Call Activity en el CSV):
   ```
   npm run atlas:validate
   ```

### Borrador de lógica: Mermaid

Para discutir *qué pasos y decisiones* van antes de formalizar, un boceto en **Mermaid** dentro
de un `.md` es más barato de iterar (GitHub lo pinta solo). Una vez acordado el flujo, se
"compila" a BPMN. **BPMN = entregable formal; Mermaid = borrador.** No se versionan borradores
Mermaid como si fueran el atlas.

## Contenido

- 5 mapas de arquitectura/familia · 20 procesos detallados · 1 tabla DMN (`90-decisiones/`) ·
  1 modelo con subprocesos embebidos · `referencia/` (propuesta del usuario, no canónica).
- `tools/` — scripts del atlas (render, validar, layout). `render/` — SVG generados.
