# Sprint Brownfield II — el fallback anti-AV + el auditor configurable

> Plan aprobado en R0 el 2026-07-13. **Este plan ES el sprint**: lo que no está aquí, no entra (ver "Lo que NO entra"). Cosecha del lazo: issues #40–#46.

## Contexto (por qué)

El lazo trajo 7 issues desde dos despliegues reales: un repo de conocimiento **regulado (PLD/CNBV)** y el **"Caso F"** de operación. Dos tienen **daño activo y son Windows-verificables hoy**:

- **#40 (bug) + #43 (lección):** en Windows 11 / PS 5.1 con AV de terceros, `instalar.ps1` es el **único** archivo del clon al que el SO niega lectura/ejecución, intermitentemente. El instalador queda **mudo**: no siembra, no da error, no hay fallback guiado. El hijo se queda sin ruta de siembra/actualización. La hipótesis: heurística de AV que marca un script llamado *"instalar"* que hace `core.hooksPath` + copia hooks + `-ExecutionPolicy Bypass`. El mecanismo de actualización **no debería ser a la vez único punto de falla y el artefacto más sospechoso** del kit.
- **#42:** en `docs-as-code` con `product/` narrativo, un `[[wikilink]]` de `product/` hacia una capa propia (`engineering/`) se marca **roto** y **bloquea** el CI, porque `auditar.ps1:67` tiene `$scanDirs` hardcodeado (`product docs kanban doctrina kit/.jidoka/templates`). Verificado: el original de SGI sí escaneaba `engineering/`.

Los otros 4 (#41, #44, #45, #46) están marcados por sus propios autores como **regla 2-3** (1er/2º uso real, esperando el siguiente). El método manda **registrarlos, no construirlos**.

## Encuadre de producto (validado con el cliente)

Toca dos capacidades vigentes:

- **[[KIT-1]] — el lazo de sincronización.** Sus criterios asumen un supuesto oculto: *que `instalar.ps1` siempre se puede leer y correr*. #40/#43 rompen ese supuesto. El sprint **añade un criterio** a KIT-1: el lazo degrada con gracia a un fallback independiente del instalador.
- **[[AND-1]] — el muro Andon** (el auditor del grafo). #42 lo vuelve configurable desde la instancia sin tocar la mecánica genérica.

## Decisiones del cliente

- **2026-07-13** — *"tú decides el tamaño del sprint, tú sabes la capacidad que tienes"* (autorización vigente del HANDOFF: el cliente elige dirección, la sesión decide tamaño por capacidad). → **Decidido: R1 + R2 construidas, R3 cosechada al backlog.**
- **2026-07-13** — Forma del fallback (#40/#43): **script chico separado** (`tools/sembrar-manual.ps1`, sin `-ExecutionPolicy Bypass` ni el nombre "instalar"), no receta-solo-doc.
- **Frontera:** renombrar/firmar `instalar.ps1` o la ruta `npx` NO entran (alto blast-radius / recurso del cliente).

## Alcance (rebanadas verticales)

Cada rebanada es commiteable y verde por sí sola.

### R1 — Fallback de siembra independiente del instalador (#40/#43) · **toca motor + siembra**
1. **`tools/sembrar-manual.ps1`** (nuevo, motor): lee `kit/.jidoka/instalar/manifiesto.json`, copia cada pieza `motor` desde un checkout de Jidoka al destino (mismo loop que `estado-motor.ps1 -Detallado`: `origen`/`destino`/`dir`/`clase`), fija `git config core.hooksPath`, y escribe el sello `tools/jidoka-motor.json` con versión + hashes. **No usa `-ExecutionPolicy Bypass`; no se llama "instalar".** Respeta no-clobber (no pisa instancia). Sirve para siembra Y actualización cuando `instalar.ps1` no puede correr.
2. **`tools/estado-motor.ps1`** (motor, edición mínima): al detectar que `instalar.ps1` **no es legible** (try/catch sobre su lectura), emite guía apuntando a `sembrar-manual.ps1` en vez de solo a `instalar.ps1 -Actualizar`.
3. **`kit/.jidoka/instalar/manifiesto.json`**: registrar `sembrar-manual.ps1` como pieza de motor (para que el lazo lo baje a los hijos).
4. **Quickstart / guía**: sección de primera clase *"si el instalador no corre (AV): siembra con `sembrar-manual.ps1`"* en la guía de instalación.

### R2 — `scanDirs` del auditor configurables desde la instancia (#42) · **toca motor + ley (instancia)**
1. **`tools/auditar.ps1`**: `$scanDirs` = default de hoy **+** dirs extra leídas de la instancia (campo opcional en la ley del arquetipo, p.ej. `auditor.scanDirsExtra`). Sin config → comportamiento **idéntico** al actual.
2. **Plantillas de ley** (`kit/.jidoka/leyes/blast-radius.*.json`): documentar el campo opcional (default vacío).

### R3 — Cosecha al backlog (NO se construye) · **solo docs**
1. **`ROADMAP.md`**: registrar #41 (`doc-only`), #44 (`operacion`), #45 (gobernanza compuesta), #46 (prueba de vida), y la parte-3 de #40/#43 (reducir superficie AV: renombrar/firmar/`npx`) — cada uno con su marca de **regla 2-3** y el nº de issue.
2. **Etiquetar los 7 issues** en GitHub (`bug`/`leccion`) — pendiente de autorización nombrada.

## Archivos (blast radius)

- **Nuevos:** `tools/sembrar-manual.ps1`, `tools/probar-sembrar.ps1` (o casos nuevos en `probar-instalador.ps1`), `docs/decisions/0027-*.md`, `docs/sprints/sprint-brownfield-2-<slug>.md` (récord de cierre).
- **Editados (motor):** `tools/estado-motor.ps1`, `tools/auditar.ps1`, `kit/.jidoka/instalar/manifiesto.json`.
- **Editados (ley/instancia):** `kit/.jidoka/leyes/blast-radius.docs-as-code.json`, `blast-radius.code-first.json`.
- **Editados (docs):** el quickstart/guía de instalación, `ROADMAP.md`, `CHANGELOG.md`, `HANDOFF.md`, `docs/sprints/README.md`, índice de ADRs, `product/capacidades/KIT-1-*.md` (criterio nuevo).
- **Versión:** `tools/version.txt` → `1.10.0`.

## Verificación (el demo que corre el cliente) — `owner: cliente`

1. **Fallback siembra igual que el instalador.** En un clon/carpeta de prueba, correr `./tools/sembrar-manual.ps1 -Destino <repo-prueba> -Jidoka <ruta-jidoka>`; luego `./tools/estado-motor.ps1 -Jidoka <ruta-jidoka>` en el destino ⇒ reporta **"[OK] al día"**, con `core.hooksPath` en `.githooks` y el sello escrito. Evidencia en `qa_runs/`.
2. **Degradación con gracia.** Simular instalador ilegible; correr `estado-motor.ps1` ⇒ **apunta a `sembrar-manual.ps1`** en vez de quedar mudo o solo mencionar `-Actualizar`.
3. **Auditor con capa propia.** Repo de prueba con `engineering/` declarado en la ley y un `[[wikilink]]` de `product/` hacia ahí ⇒ `auditar.ps1` **no bloquea**. Sin la config ⇒ salida **idéntica** a hoy (regresión verde).
4. **Suite verde:** `probar-instalador.ps1`, `probar-sembrar.ps1` (o casos añadidos), `probar-version.ps1` todos verdes; `auditar.ps1` sobre el propio repo sin regresión.
5. **Cosecha visible:** los 5 ítems en `ROADMAP.md` con su nº de issue y marca regla 2-3.

## Lo que NO entra (siguientes)

- **`doc-only` (#41)** y **`operacion` (#44/#45/#46)** como arquetipos → regla 2-3, esperan 2º uso real. Solo se cosechan.
- **Renombrar/firmar `instalar.ps1`** o la ruta **`npx`** (#40/#43 parte 3) → alto blast-radius / recurso del cliente (cert, cuenta npm). Se cosecha.
- **Prueba de vida / leading indicators** de barreras (#46) → doctrina, no motor todavía.
- **Tocar la línea de operación del "Caso F".**
- **`npm publish`** y verificación cross-platform → bloqueados por recurso/entorno (sin cambio).
