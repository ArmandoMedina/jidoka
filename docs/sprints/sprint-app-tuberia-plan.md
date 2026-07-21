# Sprint — La app de la tubería: la maqueta se vuelve el producto (Tauri)

> Plan-contrato aprobado por el cliente el 2026-07-21 (STOP 2 en plan mode). R0 aprobado el mismo día.

## Contexto (por qué ahora)

El sprint pasado entregó el motor verde (bandeja, estatuto del ritual, candado) pero la cara
del producto quedó fragmentada en comandos de VS Code — lo contrario de lo que el cliente
validó en 6 Gembas: **la maqueta como una sola app navegable**. La retro del transcript
identificó la causa (el plan decía "la maqueta no se porta" y nadie lo resaltó). Decisión del
cliente (2026-07-21): **la superficie es una app de escritorio Tauri cuya interfaz ES la
maqueta**; VS Code queda limpio. Supersede al ADR 0044 → **ADR 0048**.

## El QUÉ aprobado (R0, resumen)

El usuario abre UNA app (doble clic) idéntica a `docs/analisis/maqueta-tuberia-202607.html`
— tubería, bandeja, formulario, modo avanzado en la misma ventana — leyendo/escribiendo los
datos reales del repo vía el motor. 6 criterios Gherkin aprobados; el 6º manda: **Gemba de
fidelidad visual ANTES de cablear datos**. Fase 1 = Windows.

## Reglas duras del sprint

- **Modelos (orden del cliente):** Fable = solo criterio/orquestación en el hilo; TODA la
  mecánica en subagentes **opus** (diseño/piezas delicadas), **sonnet** (construcción/tests),
  **haiku** (edits triviales). Ningún subagente en Fable. Infra (rustup) → agente `oscar`.
- **Merges a `main` y release = orden nombrada del cliente, cada vez.**
- El original `docs/analisis/maqueta-tuberia-202607.html` es **spec congelada: no se toca**;
  es la vara del Gemba de fidelidad.
- Encoding: ledgers y JSON UTF-8 **sin BOM** + newline final; motor ASCII; PS 5.1 (`powershell.exe`,
  nunca `pwsh`), calcando `extension.js:22,48`.

## Decisiones de diseño (validadas contra el código real)

1. **Datos → la app:** nuevo `tools/tuberia-datos.ps1 -Repo -Json` consolida UNA foto
   (piezas+aristas+regímenes+bandeja+ritual) en una llamada. **No recalcula**: `bandeja.ps1` y
   `estado-ritual.ps1` ganan un switch `-Json` aditivo (los objetos ya existen en memoria:
   `bandeja.ps1:189-203`). Piezas/aristas de la maqueta (37+42, censo curado a mano) se
   extraen UNA vez a `tools/tuberia-piezas.json` (semilla versionada); el estado VIVO
   (régimen/candado/firma/cola/conformidad) se calcula fresco de `contratos.json` + ley.
2. **Escrituras ← la app:** el motor PS es el **único escritor**. Port de
   `extension/contratos.js` (113 líneas) + `extension/ritual.js` (53) a:
   - `tools/parametrizar.ps1 -Repo -Path -Tipo -Regimen -Area -Fuerza -Comandos -Json`
     (upsert contrato + agregarAFuente + insertarArroba; acumula avisos, jamás éxito falso)
   - `tools/override.ps1 -Repo -Path -Accion -Quien -Email -Motivo -Json`
     (registrarOverride + firma derivada de `git config`, ADR 0047)
   Emiten JSON `{ok, error?, avisos[]}` + exit code. Los casos sutiles viajan con sus tests
   (idempotencia por token de `ritual.js:24`, firma que aborta sin `quien`/`motivo`).
   Rechazados: Rust (tercera lengua, duplica verdad) y node runtime (dependencia en usuario final).
3. **Fidelidad como invariante:** `app/ui/index.html` nace copia byte-fiel de la maqueta (R2);
   en R3+ solo se sustituye el bloque de datos (`P`/`E`, líneas 262-373) y los 5 puntos de
   teatro (`altaResumen`, `reclasResumen`, wizards) por `invoke()`. `probar-app.ps1` afirma
   paridad estructural con la spec (tabs `#tuberia #bandeja #flujos #huecos`, `#ovl/#wiz`, paleta).
4. **Localización del repo:** recuerda el último (app-data de Tauri) → si no, selector de
   carpeta; valida `tools/blast-radius.json` con error que dice qué falta. `--repo` opcional.
5. **Contraseña del modo avanzado = nombre del repo** (ADR 0047, ya en `extension.js:505-515`)
   — no el `GARANTIA-NULA` teatral de la maqueta.
6. **`app/` es Jidoka-only** (no se siembra; invariante en `probar-app.ps1`, migrado del de
   `probar-extension.ps1:87-98`). Área nueva **`app`** en la ley con `revisa:true`.

## Rebanadas (orden de dependencia; cada una commiteable y verde)

### R1 — Cerrar el legado + la ley nueva (talla S) — toca `decisiones`
- **ADR 0048**: superficie = app Tauri, supersede 0044; alternativas descartadas (web local,
  File System Access API) con porqués. Índice en el mismo commit (muro duro).
- CHANGELOG `v1.26.0` del sprint anterior (R1–R6 ya en la rama) + `version.txt` + HANDOFF
  reconciliado (la sesión pasada no corrió cierre).
- **PR de `sprint/sistema-configurable-20260721` → merge a `main` (⏸ orden nombrada)**.
  Rama nueva `sprint/app-tuberia-<fecha>` desde `main`.
- Demo cliente: leer el ADR 0048 en el PR.

### R2 — El cascarón fiel: GEMBA TEMPRANO (talla M) — toca `app` (área nueva)
- Prerequisito: `rustup` (agente oscar; VS2022 C++ y WebView2 ya están).
- `app/` completo (src-tauri con shell+dialog plugins, `ui/index.html` = **copia byte-fiel**
  de la maqueta, datos aún hardcodeados). `cargo tauri build` local → `.exe`.
- `probar-app.ps1` (paridad estructural + "app/ no se siembra") cableado en `publicar.ps1:79`
  **y** `andon.yml:54` (las DOS listas). `.gitignore` + `app/src-tauri/target/`. Área `app` en la ley.
- **⏸ STOP — Demo cliente: doble clic al `.exe`, ver SU maqueta tal cual en ventana propia.
  Aprueba fidelidad con sus ojos antes de que se cablee un solo dato.**

### R3 — Los datos reales (lecturas) (talla L) — toca `barreras`
- `tools/tuberia-datos.ps1` + `-Json` en `bandeja.ps1`/`estado-ritual.ps1` +
  `tools/tuberia-piezas.json` (semilla extraída de la maqueta) + tests extendidos
  (`probar-bandeja`/`probar-ritual` ganan casos `-Json`; `probar-app` valida JSON sin BOM).
- `app/ui/app.js`: `P`/`E`/bandeja/ritual desde `invoke('cargar_datos')` al abrir + botón
  refrescar discreto. Localización del repo (§4).
- Demo cliente: abrir la app → la tubería muestra las piezas con SU estado real; crear un doc
  nuevo por fuera → refrescar → aparece en la bandeja.

### R4 — Parametrizar de verdad (escrituras) (talla L) — toca `barreras`
- `tools/parametrizar.ps1` (port fiel de `contratos.js`+`ritual.js` con sus casos sutiles) +
  `tools/probar-parametrizar.ps1` (fixture temporal, calca molde `probar-docs`; en ambas listas).
- Cablear el formulario de alta (`altaResumen`) y el wizard 'doc': escritura real + avisos
  reales en la UI (nada de éxito falso). Refresco automático tras escribir.
- Demo cliente: parametrizar el doc de R3 desde el formulario → verlo salir de la bandeja,
  el `@` en `arranca.md`, la regla en la ley — sin salir de la app.

### R5 — El modo avanzado real (talla M) — toca `barreras`
- `tools/override.ps1` (port `registrarOverride`+`firmaDeterminista`) + tests.
- Contraseña = nombre del repo; firma derivada de git (aborta sin `user.name`); cablear
  `reclasResumen` (reclasificar/candado/aceptar desviación). El hook candado ya funciona (R5 pasado).
- Demo cliente: candado a una pieza desde la app → pedir a la IA editarla → verla rebotar.

### R6 — VS Code queda limpio (talla M) — toca `extension`
- Retirar TODO de la extensión: `contributes.commands/menus` y los 6 `registerCommand`
  (incluye `verGobierno`/`ligarCapacidad`/`quitarLiga` — decisión "VS Code limpio");
  retirar los `.js` ya portados; `probar-extension.ps1` se retira/migra (su invariante ya
  vive en `probar-app`); ambas listas de tests actualizadas; área `extension` de la ley → retirada.
- Demo cliente: `Ctrl+Shift+P` → "Jidoka:" no ofrece nada; clic derecho limpio.

### R7 — Empaquetado + release (talla S-M)
- Bundle NSIS (`.exe` instalador), asset del GitHub release (no al repo), CHANGELOG `v1.27.0`.
- **⏸ PR + merge + release = orden nombrada.**
- Demo cliente: instalar desde el release y correr el flujo completo del glosario.

## Verificación end-to-end (el demo que corre el cliente, owner: cliente)

Doble clic → SU maqueta viva → crear `docs/glosario-del-dominio.md` por fuera → aparece en
bandeja → parametrizar en el formulario (misma ventana) → `@` en arranca + regla en ley +
bandeja limpia → candado desde modo avanzado (tecleando el nombre del repo) → la IA rebota.
Sin código, sin terminal, sin VS Code.

## Lo que NO entra (frontera explícita)

- Multiplataforma del motor (pwsh/macOS/Linux) — el cascarón queda listo, el motor es fase 2.
- Firma Authenticode del `.exe` (certificado = recurso del cliente; riesgo AV confesado).
- Derivar las 42 aristas del repo (censo curado = semilla; derivación automática es motor futuro).
- Auto-update de la app; siembra de `app/` a los hijos (ADR si algún día se quiere).
- El tour productivo dentro de la app más allá del que la maqueta ya trae.

## Riesgos confesados

1. **AV/SmartScreen**: `.exe` recién compilado sin firma puede caer en cuarentena (historial
   Bitdefender real). Mitigación: excepción documentada, asset de release, certificado anotado fase 2.
2. **Ports sutiles**: idempotencia por token y no-clobber de `contratos.json` — viajan con
   sus tests exactos, no con inspección visual.
3. **Doble lista de tests** (`publicar.ps1` + `andon.yml`): cada test nuevo entra en ambas o
   el muro server-side queda ciego.
4. **rustup**: instalación nueva en la máquina del dev (sin admin); si el AV molesta al
   toolchain, se confiesa y se resuelve antes de R2.

## Archivos críticos

`docs/analisis/maqueta-tuberia-202607.html` (spec congelada) · `tools/bandeja.ps1` ·
`tools/estado-ritual.ps1` · `extension/contratos.js`+`ritual.js` (a portar) ·
`extension/extension.js`+`package.json` (a retirar) · `tools/publicar.ps1:79` ·
`.github/workflows/andon.yml:54` · `tools/blast-radius.json` · `kit/.jidoka/instalar/manifiesto.json` ·
`app/**` (nuevo) · `docs/decisions/0048-*.md` (nuevo) · `qa_runs/app-tuberia-<fecha>/LOG.md` (listón).
