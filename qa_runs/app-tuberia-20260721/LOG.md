# LOG — Sprint "La app de la tubería"

> El listón de evidencia de la corrida (evidencia-no-palabra). Se llena **por rebanada**, no al cierre.
> Rama: `sprint/sistema-configurable-20260721` (R1 cierra el legado sobre la misma rama; la rama `sprint/app-tuberia-<fecha>` nace desde `main` tras el merge). Plan-contrato: `docs/sprints/sprint-app-tuberia-plan.md`.

## Contexto de la sesión

- **R0 ratificado** por el cliente el 2026-07-21 en plan mode formal ("en plan mode porfa y te autorizo"); STOP 2 del plan aprobado el mismo día.
- **El giro de superficie:** el Gemba del sprint "sistema configurable" reprobó la cara fragmentada en comandos de VS Code; el cliente ordenó la superficie como **app de escritorio Tauri fiel a la maqueta** (ADR 0048, supersede 0044 en la superficie). El motor PS del sprint pasado (bandeja, estatuto del ritual, candado) es la **base de la app**.
- **Regla de modelos (orden del cliente):** Fable orquesta y pone criterio en el hilo; opus/sonnet/haiku hacen TODA la mecánica en subagentes.

---

## R1 — Cerrar el legado + la ley nueva — ✅ VERDE

**Qué se entregó (solo documentos — .md, version.txt, package.json; nada de código):**
- `docs/decisions/0048-superficie-app-tuberia.md` — la superficie del gobierno es la app de la tubería (Tauri v2); supersede el ADR 0044 **en la superficie** (cambia el QUIÉN autora: la app, ya no la extensión; el principio "la UI autora, el gate ejecuta" sigue vivo). Alternativas descartadas con porqués: extensión VS Code (fragmenta), web local (arranca proceso), File System Access API (Chromium-only, no ejecuta procesos, duplicaría el motor, firma `git config` inaccesible), Electron (~10x más pesado). Lección de proceso registrada.
- `docs/decisions/README.md` — fila del 0048 agregada (el `decisiones` BLOQUEA sin índice en el mismo commit); fila del 0044 actualizada a "reemplazado **en la superficie** por [0048]".
- `CHANGELOG.md` — entrada `## [1.26.0] — 2026-07-21` ("El sistema configurable, fase 1 — el motor del gobierno configurable"): los 3 ADRs + CFG-1 + rename estatuto (R1), la bandeja (R2, 15/15), el estatuto del ritual (R3, 13/13), el candado IA (R5, hooks 42/42), el formulario y modo avanzado (R4/R6, extensión 26/26), + la nota honesta de que la superficie de extensión queda supersedida por el ADR 0048 y se retira en `v1.27.0`.
- `tools/version.txt` → `1.26.0` (SSOT).
- `package.json` (raíz) → `version` `1.26.0`.
- `HANDOFF.md` — sección nueva "Dónde estamos (2026-07-21 tarde — Sistema configurable CONSTRUIDO + giro de superficie a la app Tauri)" insertada antes de la del descubrimiento; la vieja renombrada a "Dónde estuvimos" con la nota "git gana: mergeada vía PR #119".
- `docs/sprints/sprint-app-tuberia-plan.md` — plan archivado (blockquote de archivo); fila agregada a `docs/sprints/README.md`.
- `qa_runs/app-tuberia-20260721/LOG.md` — este listón.

**Evidencia (esta máquina, 2026-07-21):**

| Gate | Exit | Nota |
|---|---|---|
| `tools/probar-version.ps1` | **0** | version.txt (1.26.0) = tope de CHANGELOG (1.26.0) = package.json (1.26.0). SSOT consistente. |
| `tools/verificar.ps1` | **0** | Sin bloqueo. **2 avisos no bloqueantes** por tocar `tools/version.txt` (área `barreras`): "considera actualizar `andon/README.md`" y "sin tocar el grafo de producto" — ambos por el bump de versión, NO por un gate nuevo ni un cambio de capacidad → aplica el criterio de excepción del propio aviso ("si fue interno, este aviso no es para ti"). |
| `tools/auditar.ps1` | **0** | Grafo íntegro. El ADR 0048 resuelve sus wikilinks; el índice de ADRs lo lista (no huérfano). |

**Demo del cliente (owner: cliente, sin código ni terminal):** leer el ADR 0048 en el PR — la superficie = app Tauri, con las alternativas descartadas y la lección de proceso.

**Pendiente del cliente (nada bloquea al agente):** orden nombrada para el PR + merge del sprint legado (`sprint/sistema-configurable-20260721` a `main`, corta `v1.26.0`); Gemba de fidelidad en R2.

---

## R2 — El cascarón fiel (GEMBA temprano) — ✅ VERDE

**Qué se entregó (el cascarón Tauri v2 en `app/`; la maqueta se vuelve el producto):**
- `app/ui/index.html` — **copia byte-fiel** de la maqueta congelada `docs/analisis/maqueta-tuberia-202607.html` (copiada con `Copy-Item`, no regenerada; datos aún hardcodeados = teatro). El original NO se tocó (spec congelada, la vara del Gemba).
- `app/src-tauri/` — cascarón Rust/Tauri v2: `Cargo.toml` (tauri v2 + `tauri-plugin-shell` + `tauri-plugin-dialog` ya registrados en `lib.rs` aunque R2 no los use — R3+ los necesita), `tauri.conf.json` (frontendDist `../ui`, título "Jidoka - la tuberia", identifier neutro `com.jidoka.tuberia`, ventana 1280x800 resizable), `capabilities/default.json`, `build.rs`, `src/main.rs` + `src/lib.rs`, `icons/` (set default generado por `tauri icon`, sin warnings).
- `app/package.json` (version `0.0.0`, sin confundir el SSOT del repo) + `app/README.md` (cómo compilar; Jidoka-only, no se siembra).
- `tools/probar-app.ps1` — lint del cascarón (fidelidad byte-fiel + invariante "app/ no se siembra" + config Tauri + piezas Rust; NO invoca cargo, el CI no tiene Rust). ASCII puro.
- **Cableado (las DOS listas + ley + gitignore):** `tools/publicar.ps1` (foreach del preflight) y `.github/workflows/andon.yml` (smoke condicional if-exists) ganan `probar-app`; `tools/blast-radius.json` gana el área nueva `app` (`fuente:["app/*"]`, `revisa:true`, `doc_avisa:["CHANGELOG.md"]`, calcando el área `extension`); `.gitignore` gana `app/src-tauri/target/` + `app/node_modules/`. El manifiesto de siembra NO se tocó.

**Fidelidad (la vara del Gemba):** `Get-FileHash` SHA256 idéntico original vs copia:
`AA2F6268C73AC168D71782EF1AF95B287C7957D2CD4A6182E33E0FD1E5286CCC` (byte-fiel confirmado).

**El `.exe` (build local de verificación):** `npx tauri build --debug --no-bundle` compiló a la primera (~400 crates, 8m30s). Ruta verificada:
`app/src-tauri/target/debug/jidoka-tuberia.exe` (17.16 MB, existe; sin cuarentena de AV). Un único warning benigno de linker (mensaje MSVC en español al crear la import library del `.dll`), no error.

**Evidencia (esta máquina, 2026-07-21):**

| Gate | Exit | Nota |
|---|---|---|
| `tools/probar-app.ps1` | **0** | 8/8 verdes: fidelidad byte-fiel, config Tauri parsea + frontendDist a la UI, Cargo.toml/main.rs presentes, app/ NO se siembra (ADR 0048). |
| `tools/probar-publicar.ps1` | **0** | 7/7. El meta-test exige TODOS los `probar-*.ps1` en la lista de `publicar.ps1`: `probar-app` ya está → verde. |
| `tools/probar-extension.ps1` | **0** | 26/26. La extensión no se toca en R2; sigue sana. |
| `tools/verificar.ps1` | **0** | Sin bloqueo. **3 avisos no bloqueantes** por tocar el cableado del motor (`publicar.ps1`, `andon.yml`, `blast-radius.json` → áreas `barreras`/`atlas`): "actualiza andon/README.md", "sin tocar el grafo de producto", "docs/atlas/". Son consecuencia de cablear un test nuevo en las listas del motor, no doc-drift accionable en R2; el CHANGELOG del release es R7. |

**Demo del cliente (owner: cliente):** doble clic al `.exe` (`app/src-tauri/target/debug/jidoka-tuberia.exe`) → ver la maqueta tal cual en ventana propia (tubería, bandeja, flujos, huecos, modo avanzado); **STOP de fidelidad** — el cliente aprueba con sus ojos que la app ES su maqueta ANTES de que se cablee un solo dato (R3).

**Pendiente del cliente:** Gemba de fidelidad (doble clic al `.exe`, aprobar con los ojos). Nada bloquea al agente para R3 salvo esa aprobación de fidelidad (STOP del plan).

**Gemba del cliente (2026-07-21): APROBADO** — "Sí es fiel... abre y se ve como me gustó".

---

## R3 (mitad motor) — el contrato de datos app↔motor — ✅ VERDE

> **La mitad UI (app.js con `invoke`) espera el STOP de fidelidad de R2.** Esta rebanada entrega SOLO la mitad MOTOR: la foto de datos que la app leerá al abrir. `app/` no se tocó (la mitad UI viaja tras la aprobación de fidelidad del cliente).

**Qué se entregó (solo motor PS + una semilla JSON; nada de `app/`, nada de la maqueta):**
- `tools/bandeja.ps1` — switch **`-Json` aditivo**: con `-Json` emite a stdout SOLO `{"cola":[...],"aceptados":[...]}` (UTF-8 sin BOM, `ConvertTo-Json -Depth 6`) y sale con el exit 0 de siempre. El hashtable raíz envuelve con `@($cola)`/`@($aceptados)` para que un array de 1 elemento NO se colapse a objeto (trampa PS 5.1). Sin `-Json`, la salida de consola es **byte-idéntica** a la de antes (aditivo puro).
- `tools/estado-ritual.ps1` — mismo `-Json` aditivo: emite `{"comandos":[{"comando","conforme","faltan":[]}]}`. Silencia el `Write-Host` legado solo cuando `-Json` está presente; respeta `-Estricto` en el exit code. Sin `-Json`, byte-idéntico.
- `tools/tuberia-piezas.json` — **la semilla curada** (spec congelada): las **49 piezas** (`pz`) + **57 aristas** (`E`) + los regímenes (`REGBY`/`REGOVR`/`REGTXT`/`REGCOLOR` → `regimenes.{porTipo,override,texto,color}`) extraídas VERBATIM del bloque de datos de la maqueta. Textos en español con acentos (es CONTENIDO, no motor); UTF-8 **sin BOM**. Campo `path` = ruta real donde la pieza conceptual tiene traza evidente (deducida con `Test-Path`: comandos→`.claude/commands/jidoka/*.md`, asientos→`.claude/agents/*.md`, skills→`.claude/skills/*/SKILL.md`, ley/motor→`tools/*` o `kit/*`, docs→su canónico); `path:null` para conceptos sin archivo único dueño (git/GitHub/CI, disparos/templates/capacidades-como-grupo).
- `tools/tuberia-datos.ps1` — **el consolidador** (`param([string]$Repo=''`, resuelto como en `bandeja.ps1`). Emite UN JSON consolidado (UTF-8 sin BOM) con las 9 claves `version/repo/generado/piezas/aristas/regimenes/bandeja/ritual/areas`. **No recalcula**: invoca `bandeja.ps1 -Json` y `estado-ritual.ps1 -Json` **en proceso aparte** (`& powershell -NoProfile -ExecutionPolicy Bypass -File ... -Json`) y parsea su stdout. Superpone el estado VIVO sobre cada pieza (`regimen` con override por path de `contratos.json`, `candado` bool, `firma`). Falla CERRADO (exit 1, stderr) sin `blast-radius.json`; `contratos.json` ausente = normal (instancia, sin overrides).
- Tests extendidos: `probar-bandeja.ps1` (+casos `-Json`), `probar-ritual.ps1` (+caso `-Json`), `probar-app.ps1` (+sección R3-motor). `tuberia-datos.ps1` **no** es un `probar-*` (no entra a las listas de `publicar.ps1`/`andon.yml`).

**Decisiones tomadas:**
- **49 piezas / 57 aristas, no 37+42.** El texto del plan estimó "37+42"; el bloque de datos REAL de la maqueta congelada tiene **49 `pz` y 57 tuplas `E`**. La semilla es fiel al artefacto (todos los 49 ids verificados idénticos a la maqueta), no a la estimación. El umbral del test es `>=37` → 49 lo cumple con holgura.
- **Invocación en proceso aparte, NO dot-source.** `bandeja.ps1`/`estado-ritual.ps1` terminan con `exit 0`; dot-sourcearlos correría ese `exit` en el proceso del consolidador y lo mataría antes de emitir. El sub-proceso `& powershell -File ... -Json` aísla el `exit` y deja capturar solo su stdout JSON (calca el molde de `probar-bandeja.ps1`).
- **El estado vivo manda sobre la spec:** el régimen efectivo por pieza = default de la semilla (`override[id]` o `porTipo[tipo]`), sobrescrito por `contratos.json` si hay un contrato con `regimen` para el `path` real de la pieza. Piezas con `path:null` nunca reciben override.

**Evidencia (esta máquina, 2026-07-21):**

| Gate | Exit | Nota |
|---|---|---|
| `tools/probar-bandeja.ps1` | **0** | 21/21. Nuevos: `-Json` exit 0, sin BOM (primer byte ≠ 0xEF), parsea `{cola,aceptados}`, `cola` es array, **`aceptados` array de 1 elemento** (el caso crítico del colapso PS 5.1), y sin `-Json` la consola es idéntica. |
| `tools/probar-ritual.ps1` | **0** | 19/19. Nuevos: `-Json` sin BOM, parsea `{comandos}`, `comandos` es array, `conforme` es bool, `faltan=[B.md]`, y consola idéntica sin `-Json`. |
| `tools/probar-app.ps1` | **0** | 14/14. Nueva sección R3-motor: `tuberia-datos.ps1` corre sobre el repo real (exit 0), stdout sin BOM, parsea, trae las claves raíz, **49 piezas (>=37)**. |
| `tools/probar-publicar.ps1` | **0** | 7/7. El meta-test "todos los `probar-*` en la lista" sigue verde: `tuberia-datos` NO es `probar-*`, no rompe la lista. |
| `tools/verificar.ps1` | **0** | Sin bloqueo. **3 avisos no bloqueantes** por tocar scripts del motor (`bandeja.ps1`, `estado-ritual.ps1`, `probar-app.ps1` → áreas `atlas`/`barreras`): atlas, `andon/README.md`, grafo de producto. Son consecuencia de extender el motor con un switch aditivo, no doc-drift accionable; el CHANGELOG del release es R7. |
| `tools/tuberia-datos.ps1` (corrida real) | **0** | Foto consolidada emitida; forma abajo. (El `\| Select -First 5` reporta 255 por cerrar el pipe temprano — SIGPIPE del upstream, no fallo del script; la corrida completa sale 0.) |

**Forma del JSON consolidado (primeras líneas de la corrida real):**
```
{
    "version":  "1.26.0",
    "repo":  "C:/Repositorio personal/jidoka",
    "generado":  "2026-07-21T19:09:12Z",
    "piezas":  [
      ... 49 piezas con {id,tipo,nombre,tag,desc,confHoy,confVision,path,regimen,candado,firma} ...
    ],
    "aristas":  [ ... 57 {de,a,rel} ... ],
    "regimenes":  { porTipo{13}, override{5}, texto{4}, color{4} },
    "bandeja":  { cola[34], aceptados[] },   // de bandeja.ps1 -Json (reuso)
    "ritual":  [ 7 {comando,conforme,faltan} ],  // de estado-ritual.ps1 -Json (reuso)
    "areas":  [ 12 nombres de blast-radius.json ]
}
```

**Demo del cliente (owner: cliente):** abrir la app → la tubería muestra las 49 piezas con SU estado real; crear un doc por fuera → refrescar → aparece en la bandeja. **Requiere la mitad UI (`app/ui/app.js` con `invoke`), que espera el STOP de fidelidad de R2.**

**Pendiente:** el STOP de fidelidad de R2 (Gemba del `.exe`) antes de cablear la mitad UI. La mitad MOTOR (esta rebanada) queda verde y lista para que `app.js` la consuma vía `invoke('cargar_datos')`.

---

## R4 (mitad motor) — parametrizar.ps1, el escritor único — ✅ VERDE

> **La mitad UI** (cablear el formulario de alta `altaResumen` + el wizard 'doc' con escritura real vía `invoke`, refresco automático) **espera el STOP de fidelidad de R2.** Esta rebanada entrega SOLO la mitad MOTOR: el comando que se vuelve el único escritor de los ledgers. La app lo invocará. `app/` y `extension/` NO se tocaron.

**Qué se entregó (solo motor PS + su self-test; nada de `app/`, nada de `extension/`):**
- `tools/parametrizar.ps1` — **el escritor único** (`param -Repo -Path -Tipo -Regimen -Area -Fuerza -Comandos -Json`). Port fiel de `extension/contratos.js` (`escribir`/`leerContratos`/`upsertContrato`/`leerLey`/`agregarAFuente`, 113 líneas) + `extension/ritual.js` (`insertarArroba`/`MARCADOR`, 53 líneas). Hace, en orden, calcando `extension.js:409-458` ("acumula avisos, jamás éxito falso"): (1) **upsert** del contrato en `tools/contratos.json` (merge por path, estado `parametrizado`; crea el archivo si no existe — INSTANCIA no-clobber, ADR 0046); (2) si `-Area`: agrega `-Path` a la fuente del área en `tools/blast-radius.json` (idempotente; área inexistente → AVISO); (3) por cada comando de `-Comandos` (csv): `insertarArroba` en `.claude/commands/jidoka/<c>.md` bajo el marcador `<!-- jidoka:arrobas -->` (**idempotencia por token con borde**; garantiza newline final; sin marcador o comando ausente → AVISO). Los pasos 2-3 acumulan avisos **sin revertir el paso 1** (el contrato queda; jamás éxito falso, jamás silencio). Toda escritura UTF-8 **sin BOM** + newline final vía `[System.IO.File]::WriteAllText(...UTF8Encoding($false))`; JSON con `ConvertTo-Json -Depth 8` y arrays protegidos con `@()`. Salida `-Json`: `{ok,contrato,avisos,arrobas}` a stdout; error duro → `{ok:false,error}` + exit 1. ASCII puro, PS 5.1.
- `tools/probar-parametrizar.ps1` — self-test con fixture temporal (TEMP, jamás toca el repo real), contador Ok/No, exit por veredicto (molde `probar-bandeja.ps1`). Trae los casos de los dos `.test.js` + los del plan R4. ASCII puro.
- **Cableado (las DOS listas):** `tools/publicar.ps1` (foreach del preflight) y `.github/workflows/andon.yml` (smoke condicional if-exists) ganan `probar-parametrizar`.

**Decisiones del port (divergencias con los `.js`, confesadas):**
- **`agregarAFuente` NO crea el área.** `contratos.js:96-105` CREA el área si no existe; el plan R4 ordena lo contrario ("si el área no existe → AVISO, no error"). El port respeta el plan: si el área no está en la ley, no la crea a ciegas — reporta AVISO y el contrato queda escrito. (El port de `registrarOverride`/`firmaDeterminista` NO se hizo: es R5, `override.ps1`.)
- **Trampa PS 5.1 en el retorno de funciones:** una función que retorna `@($x)` con 1 elemento lo **re-desenvuelve a escalar** al salir. Un área sola llegaba como `PSCustomObject` (`.Count` vacío → el `for` nunca corría → área existente reportada como inexistente). Fix: `@()` en el **sitio de llamada** (`$arr = @(Leer-Ley $p)`). Cazado por el caso 6a del self-test antes de cablear.
- La idempotencia del `@` es **byte-fiel** a `ritual.js:24`: regex `'@' + [regex]::Escape(arroba) + '(?![\w./-])'` sobre la línea sin espacios — el borde por token muerde (`glo.md` se inserta pese a existir `glosario.md`), verificado en el caso 4.

**Evidencia (esta máquina, 2026-07-21):**

| Gate | Exit | Nota |
|---|---|---|
| `tools/probar-parametrizar.ps1` | **0** | **25/25** verdes. Alta nueva (crea contratos.json sin BOM + newline); upsert merge (2do gana, no duplica); @ bajo el marcador + idempotente; **la sutileza** (`glo.md` inserta pese a `glosario.md`); comando sin marcador → aviso + contrato igual; área existente idempotente vs área inexistente → aviso; array de 1 sale como array; `-Json` parsea sin BOM; validaciones (regimen/fuerza inválidos, ley ausente) → exit 1 + `{ok:false,error}`. |
| `tools/probar-publicar.ps1` | **0** | 7/7. El meta-test "todos los `probar-*` en la lista del preflight" sigue verde con `probar-parametrizar` agregado. |
| `tools/probar-app.ps1` | **0** | 14/14. La app no se tocó; sigue sana (49 piezas ≥ 37). |
| `tools/anti-pii.ps1` (con los 2 archivos nuevos vía `git add -N`) | **0** | Sin fugas en 265 archivos. Los fixtures respetan la ley anti-PII: ningún token `@X.md` precedido de char-de-palabra (regex de email de la base). |
| `tools/verificar.ps1` | **0** | Sin bloqueo. **3 avisos no bloqueantes** por tocar el cableado del motor (`publicar.ps1`, `andon.yml` → áreas `atlas`/`barreras`): atlas, `andon/README.md`, grafo de producto. Son consecuencia de cablear un test nuevo en las listas, no doc-drift accionable; el CHANGELOG del release es R7 (mismo patrón que R2/R3). |

**Demo del cliente (owner: cliente):** parametrizar el doc de R3 desde el formulario → verlo salir de la bandeja, el `@` en `arranca.md`, la regla en la ley — sin salir de la app. **Requiere la mitad UI** (cablear `altaResumen` + wizard 'doc' con `invoke`), **que espera el STOP de fidelidad de R2.**

**Pendiente:** el STOP de fidelidad de R2 (Gemba del `.exe`) antes de cablear la mitad UI. La mitad MOTOR (esta rebanada) queda verde y lista para que `app.js` invoque `parametrizar.ps1` y muestre sus avisos reales (nada de éxito falso).

---

## R5 (mitad motor) — override.ps1, la firma que no se inventa — ✅ VERDE

> **La mitad UI** (cablear `reclasResumen`: reclasificar / candado / aceptar desviación con escritura real vía `invoke`, refresco automático) **espera el STOP de fidelidad de R2.** Esta rebanada entrega SOLO la mitad MOTOR: el comando que autora una acción firmada del modo avanzado. La app lo invocará. `app/` y `extension/` NO se tocaron. El hook candado (`candado-pretooluse.ps1`) ya existe (R5 del sprint pasado) y leerá el `candado:true` que este comando escribe.

**Qué se entregó (solo motor PS + su self-test; nada de `app/`, nada de `extension/`):**
- `tools/override.ps1` — **el escritor único de las acciones firmadas** (`param -Repo -Path -Accion -Motivo -Json`). Port fiel de `extension/contratos.js`: `registrarOverride` + `firmaDeterminista` (ADR 0047). Deriva la firma de git, hace **UPSERT** del contrato en `tools/contratos.json` (merge por path que **preserva campos previos** — un `candado:true` nuevo no pisa el `regimen`/`comandos` que ya estaban; crea un contrato mínimo `{path, cambio, firma}` si el path no tenía; crea el archivo si no existe — INSTANCIA no-clobber, ADR 0046). El cambio por acción calca `porAccion` de `contratos.js:68-74`: `aceptar-desviacion → estado='aceptado'`, `candado-on → candado=true`, `candado-off → candado=false`, `reclasificar-estatuto → regimen='estatuto'`, `reclasificar-libre → regimen='libre'` (NUNCA ofrece `'motor'`: ese régimen solo lo trae Jidoka de fábrica). Toda escritura UTF-8 **sin BOM** + newline final vía `[System.IO.File]::WriteAllText(...UTF8Encoding($false))`; JSON con `ConvertTo-Json -Depth 8`, arrays protegidos con `@()`. Salida `-Json`: `{ok:true,contrato}` | `{ok:false,error}` + exit code coherente. ASCII puro, PS 5.1. Calca el molde de encoding/validación de `parametrizar.ps1` (R4).
- `tools/probar-override.ps1` — self-test con fixture temporal (TEMP, jamás toca el repo real) que hace `git init` + `git config --local user.name/user.email` **del propio fixture**, y aísla la config global/system del operador (`GIT_CONFIG_GLOBAL`/`GIT_CONFIG_SYSTEM` a rutas inexistentes) para que la firma solo pueda venir de la config local — el caso "sin `user.name`" es determinista aunque el operador SÍ tenga nombre en su `~/.gitconfig`. Trae los casos de `contratos.test.js` que tocan override/firma + los del plan R5. Anti-PII: el email del fixture se construye por **concatenación** (`'prueba@' + 'ejemplo.local'`) para que el escaneo estático nunca vea un correo entero. ASCII puro.
- **Cableado (las DOS listas):** `tools/publicar.ps1` (foreach del preflight) y `.github/workflows/andon.yml` (lista `$jt`, smoke condicional if-exists) ganan `probar-override`.

**DIVERGENCIA DE DISEÑO CONFESADA (diverge del plan R5 a propósito):**
El plan R5 listaba `-Quien -Email` como parámetros de `override.ps1`. **Aquí NO.** La firma se **DERIVA** de `git config user.name` / `git config user.email` **DENTRO** del script (corriendo `git -C $Repo`), y **aborta con error si `user.name` está vacío** (`{ok:false, error:"sin git user.name -- la firma no se inventa (ADR 0047)"}`, exit 1). Razón: el ADR 0047 manda "firma derivada de git, nunca inventada"; si el llamador (la app) pudiera pasar `-Quien`, la app podría **inventar** al firmante. El escritor único es dueño de la regla — no hay forma de que la app pase por encima. El `email` vacío **sí se tolera** (string vacío), calcando `contratos.js:54` (`email || ''`: email y cuándo pueden ir vacíos pero se incluyen en la firma). El `cuando` se deriva con `Get-Date` en **ISO 8601 UTC** (jamás tecleado). Firma resultante: `{quien, email, cuando, motivo}`.

**Otras decisiones del port (fidelidad vs `contratos.js`):**
- **`registrarOverride` byte-fiel** en el efecto por acción y en el merge por path que preserva campos previos (`upsertContrato`). Verificado: `candado-on` sobre un contrato con `regimen`+`comandos` deja ambos intactos; `reclasificar-*` no borra el `candado` previo.
- **`firmaDeterminista` byte-fiel** en el aborto: lanza sin `quien` y sin `motivo` (calca `contratos.js:52-53`); `email`/`cuando` vacíos se toleran pero se incluyen. El plan además ordena `-Motivo` obligatorio no-vacío como parámetro → validado antes de derivar la firma.
- Guarda **anti-traversal** en `-Path` (sin `..` ni absoluto), calcada de `parametrizar.ps1`.

**Evidencia (esta máquina, 2026-07-21):**

| Gate | Exit | Nota |
|---|---|---|
| `tools/probar-override.ps1` | **0** | **26/26** verdes. candado-on sobre contrato existente (candado true + firma completa, regimen+comandos previos intactos); candado-off (false + firma actualizada); aceptar-desviacion sin previo (contrato mínimo `estado:aceptado`); reclasificar-estatuto/-libre (regimen cambia, candado previo intacto); **sin `user.name` → {ok:false} + exit 1 + contratos.json NO tocado**; motivo vacío → exit 1; acción inválida → exit 1; path inseguro → exit 1; JSON sin BOM; contratos.json termina en newline; array de 1 queda como array. |
| `tools/probar-parametrizar.ps1` | **0** | **25/25**. El hermano R4 no se tocó; sigue sano. |
| `tools/probar-publicar.ps1` | **0** | 7/7. El meta-test "todos los `probar-*` en la lista del preflight" sigue verde con `probar-override` agregado. |
| `tools/anti-pii.ps1` | **0** | Sin fugas. El fixture construye el email por concatenación → ningún token `<char>@X.Y` literal en el árbol. |
| `tools/verificar.ps1` | **0** | Sin bloqueo. Avisos no bloqueantes por tocar el cableado del motor (`publicar.ps1`, `andon.yml` → áreas del motor), consecuencia de cablear un test nuevo en las listas, no doc-drift accionable; el CHANGELOG del release es R7 (mismo patrón que R2/R3/R4). |

**Demo del cliente (owner: cliente):** candado a una pieza desde la app (modo avanzado, tecleando el nombre del repo) → pedir a la IA editarla → verla rebotar (el hook candado la para). **Requiere la mitad UI** (cablear `reclasResumen` con `invoke`), **que espera el STOP de fidelidad de R2.**

**Pendiente:** el STOP de fidelidad de R2 (Gemba del `.exe`) antes de cablear la mitad UI. La mitad MOTOR (esta rebanada) queda verde y lista para que `app.js` invoque `override.ps1` y muestre la firma real (nada inventado).

---

## R3 (mitad UI) — la tubería con datos reales — ✅ VERDE

> El STOP de fidelidad de R2 quedó **APROBADO** por el cliente ("Sí es fiel... abre y se ve como me gustó"). Con eso, esta rebanada cablea la **mitad UI**: la app deja de ser teatro **EN LAS LECTURAS**. Al abrir, corre el motor PS real (`tools/tuberia-datos.ps1`) vía el puente Rust y pinta la tubería/bandeja con SUS piezas/regímenes/candados/cola reales. Las **escrituras siguen teatro** (los wizards) — son R4/R5-UI.

**Qué se entregó (fidelidad quirúrgica: solo el bloque de datos + 2 controles discretos + el puente Rust):**
- `app/ui/index.html` — el bloque de datos hardcodeado (las ~49 `pz()`, el array `E`, `REGBY/REGOVR/REGTXT/REGCOLOR`, `AREAS`) se reemplazó por **carga dinámica** desde la foto real, marcado con los sentinelas `/* JIDOKA:DATOS-INICIO ... JIDOKA:DATOS-FIN */`. `jidokaCargar(foto)` reconstruye `P`/`E`/`ADJ`/`REG*`/`AREAS`/`BANDEJA` **con la misma forma** que producía la maqueta y repinta. `regOf(id)` ahora prefiere el `regimen` VIVO por pieza (override de `contratos.json` incluido) que trae la foto, cayendo al derivado por-id/por-tipo. El render de `#cats` se convirtió en `pintarTuberia()` (reinvocable). Los **5 items hardcodeados** del tab `#bandeja` se reemplazaron por `pintarBandeja()` con render dinámico desde `BANDEJA.cola`/`aceptados` — **mismas clases/estilos** (`.bitem`, `.et` coloreado por motivo, botón Parametrizar); el contador del tab (`#bandejaCont`) refleja la cola real. En el panel de detalle, una pieza con `candado:true` muestra el indicador 🔒 (el mismo emoji del modo avanzado; sin estilos nuevos). **Todo lo demás quedó INTACTO** (CSS, tabs, wizards, tour, modo avanzado, textos).
- **2 controles discretos en la nav** (clases inline, estilo consistente, no protagonistas): `↻ Refrescar` (re-invoca `cargar_datos`) y `📁 Cambiar repo` (re-invoca `elegir_repo`+`cargar_datos`). Un banner de aviso (`#jidokaAviso`, estilo `.et sin` de la paleta) muestra errores del puente en la UI (nada de `alert()`).
- `app/src-tauri/src/lib.rs` — **el puente Rust**: `cargar_datos(repo)` ejecuta `powershell.exe -NoProfile -ExecutionPolicy Bypass -File <repo>/tools/tuberia-datos.ps1 -Repo <repo>` con `std::process::Command` (**NO** el plugin shell — menos superficie), con `creation_flags(0x08000000)` CREATE_NO_WINDOW en Windows (sin parpadeo de consola); stdout→String, exit≠0→Err con stderr. `repo_actual()`/`elegir_repo()` recuerdan el último repo en `app_data_dir()/repo.txt`; `elegir_repo` abre el selector (`tauri-plugin-dialog`, `blocking_pick_folder`) y **valida** que `<carpeta>/tools/blast-radius.json` exista (si no: Err con el mensaje pedido). El **plugin shell se retiró** de `lib.rs` y `Cargo.toml` (quedó registrado sin usarse en R2; menos superficie).
- `app/src-tauri/tauri.conf.json` — `app.withGlobalTauri: true` (sin bundler, el JS usa `window.__TAURI__.core.invoke`).
- `app/src-tauri/capabilities/default.json` — suma **solo** `dialog:default` (lo que usa el selector). **Nada de shell** (`std::process` no necesita permiso) — respeta el hallazgo de review de R2 (permisos mínimos).
- `tools/probar-app.ps1` — el assert byte-idéntico (que el propio test anunciaba que se relajaría) se **reemplazó por paridad estructural** contra la spec congelada: mismos IDs de tabs (`#tuberia #bandeja #flujos #huecos`), `#ovl`/`#wiz`, variables CSS de la paleta, funciones clave del JS (`wizStart`/`tourStart`/`rootCheck`/`wizRender`), los sentinelas `JIDOKA:DATOS-INICIO/FIN`, **el `<style>` byte-idéntico al de la spec** (hash del bloque; los 2 botones nuevos usan clases inline → el CSS no cambió) y `withGlobalTauri true`. Se mantienen: no-se-siembra, JSON válido, Cargo/main.rs, y los asserts R3-motor (foto parsea, sin BOM, ≥37 piezas).

**Decisiones tomadas:**
- **`std::process::Command`, no el plugin shell** (menos superficie de permisos; el hallazgo de review R2 fue "permisos mínimos"). El plugin shell se retiró por completo. Solo `dialog:default` en las capacidades.
- **La foto manda sobre la spec en el régimen:** `regOf` prefiere el `regimen` que la foto ya calculó por pieza (incluye el override vivo de `contratos.json`), calcando la semántica del motor de R3-mitad-motor.
- **Bandeja dinámica con los mismos estilos:** el motivo colorea el `.et` (existe/desviado/huérfano → rojo `sin`; aceptado → ámbar `dor`; simulado/dato → azul `dat`), reusando la paleta de la maqueta sin inventar clases.
- **CSS intacto a propósito:** los 2 botones nuevos llevan estilo inline para que el `<style>` quede byte-idéntico y el assert de CSS sea posible (petición del listón).

**Evidencia (esta máquina, 2026-07-21):**

| Gate | Exit | Nota |
|---|---|---|
| `npx tauri build --debug --no-bundle` (en `app/`) | **0** | El `.exe` se regeneró: `app/src-tauri/target/debug/jidoka-tuberia.exe` (12.75 MB, 14:30). Compiló con el plugin dialog (shell ya no compila). Único warning benigno de linker (mensaje MSVC en español al crear la import library), no error. |
| `tools/probar-app.ps1` | **0** | **28/28** verdes: paridad estructural (12 marcadores), sentinelas presentes, **`<style>` byte-idéntico a la spec**, `withGlobalTauri true`, `dialog` sin shell implícito, no-se-siembra, y la sección R3-motor (foto parsea, sin BOM, 49 piezas ≥ 37). |
| `tools/probar-publicar.ps1` | **0** | 7/7. El meta-test "todos los `probar-*` en la lista del preflight" sigue verde. |
| `tools/anti-pii.ps1` | **0** | Sin fugas. |
| `tools/verificar.ps1` | **0** | Sin bloqueo. **4 avisos no bloqueantes** por tocar `probar-app.ps1` (áreas `atlas`/`barreras`: atlas, `andon/README.md`, grafo) y `app/*` (área `app`: "registra en CHANGELOG"). Son consecuencia de extender el motor/app; el CHANGELOG del release es R7 (mismo patrón que R2–R5). |
| Smoke del contrato JS↔motor | **—** | `JSON.parse` del stdout de `tuberia-datos.ps1` OK (49 piezas, 57 aristas, cola=34); syntax-check del `<script>` con `node vm` → SYNTAX OK; **demo de la bandeja verificado por la mitad PS**: creé `docs/glosario-del-dominio-DEMO-R3.md` por fuera → la foto lo trae en `bandeja.cola` con `motivo=existe` (que la UI pinta como `.et sin` rojo) → borrado. |

**Confesión honesta (el click end-to-end):** no puedo clickear la ventana Tauri en headless. Verifiqué la **mitad PS** del puente (la foto corre, parsea, trae ≥49 piezas, sin BOM; el doc por fuera aparece en la cola) y que **el JS parsea** (node vm). **El click real — abrir el `.exe`, ver SUS piezas, crear un doc y darle ↻ Refrescar para verlo caer en la bandeja — lo hace el cliente en su Gemba** (la app arrancó y compiló; el cableado JS↔Rust↔PS está afirmado por partes, no por un clic mío).

**Demo del cliente (owner: cliente):** doble clic al `.exe` nuevo → al abrir, el selector de carpeta (primera vez) o el último repo recordado → **la tubería muestra SUS 49 piezas con su régimen/candado real** y la bandeja SU cola real (34 pendientes hoy). Crear un doc por fuera (ej. `docs/mi-nota.md`) → `↻ Refrescar` → verlo **aparecer en la bandeja** con su badge de motivo. `📁 Cambiar repo` para apuntar a otro repo Jidoka. Los botones de "configurar" **siguen siendo teatro** (escrituras = R4/R5-UI).

**Pendiente:** cablear las **escrituras** (R4-UI: `altaResumen`/wizard 'doc' → `parametrizar.ps1`; R5-UI: `reclasResumen` → `override.ps1`) — los comandos motor ya están verdes desde R4/R5-mitad-motor.

---

## R4 (mitad UI) — el formulario de alta ESCRIBE de verdad — ✅ VERDE

**Qué se entregó (cirugía mínima, `<style>` intacto):**
- **`app/src-tauri/src/lib.rs`** — dos comandos nuevos calcando `cargar_datos` (helper compartido `correr_script_ps`: `std::process::Command`, args **SEPARADOS sin shell**, `CREATE_NO_WINDOW` en Windows). `parametrizar(repo, ruta, tipo, regimen, area, fuerza, comandos)` → `tools/parametrizar.ps1 -Json` (**omite `-Area` si viene vacía**; `-Comandos` como csv). Detalle honesto: cuando el motor sale `exit 1` con `{ok:false,error}` en **stdout** (validación), el puente devuelve ese stdout (no el stderr) para que el JS lea el error real. Ambos comandos registrados en `generate_handler!`.
- **`app/ui/index.html`** — el paso final de `wizStart('alta')` (paso 2) gana el botón real **"✍️ Escribir el contrato"** → `altaEscribir()` invoca `parametrizar` con los datos de `W.r` (ruta/tipo/régimen/cajón→área/fuerza/comandos). El **preview "qué escribiría" se queda** (buena UX); el `.carton` se volvió honesto ("Esto escribe en tu repo de verdad: contratos.json, la ley y los @…"). Éxito → mensaje verde + **lista de `avisos`** del JSON si los hay (jamás éxito falso: `ok:false` o error del puente → error tal cual en rojo); **tras éxito re-invoca `jidokaRefrescar()`** (la bandeja resta la pieza). `FOTOREPO` (de `foto.repo`) es el `-Repo`.
- El texto del **header** dejó de mentir ("El formulario de alta y el modo avanzado ya escriben de verdad… el resto siguen de teatro y lo confiesan").

**Teatro CONFESADO (fuera de alcance del reuso limpio):**
- **Wizard `'doc'`** (alta guiada de 3 preguntas): queda teatro. Su `W.r` tiene otra forma (sin `ruta`/`régimen`/`cajón` reales; caso fijo `glosario`), así que cablearlo sería **más invasivo que reutilizar el mismo invoke** (el escape del propio listón). Su `.carton` lo confiesa y su botón final ahora **lleva al formulario real** (`wizStart('alta',…)`), que sí escribe.

**Evidencia (esta máquina, 2026-07-21):**

| Gate | Exit | Nota |
|---|---|---|
| `npx tauri build --debug --no-bundle` (en `app/`) | **0** | El `.exe` **se regeneró** (assets embebidos): `app/src-tauri/target/debug/jidoka-tuberia.exe` (12.78 MB, 14:54). Único warning benigno de linker (MSVC en español al crear la import library), no error. |
| `tools/probar-app.ps1` | **0** | **35/35** verdes. Asserts nuevos verdes: el JS invoca `parametrizar`; `lib.rs` define+registra `parametrizar`; **`<style>` byte-idéntico** (SHA256 `0BF53EE3…59AD7A`). |
| `tools/probar-parametrizar.ps1` | **0** | 27/27 (el motor no se tocó, sigue verde). |
| Smoke JS↔Rust↔motor | **—** | Corrí `parametrizar.ps1` **con los args exactos que arma el puente** (`-Repo … -Path docs/glosario-del-dominio.md -Tipo glosario -Regimen estatuto -Fuerza avisa -Comandos arranca,planea -Area dominio -Json`) → `ok:true`, contrato `estado=parametrizado`, **2 @ insertados**, aviso honesto ("el área 'dominio' no existe… no la agregué"). Escrituras del smoke **revertidas** (ledgers instancia + los .md de comandos). `node vm` del `<script>` → **SYNTAX OK**. |

**Demo del cliente (owner: cliente):** doble clic al `.exe` → pestaña **La bandeja** → en un pendiente (ej. el glosario) darle **"Parametrizar →"** → llenar el formulario (tipo, régimen, cajón, fuerza, qué comandos lo leen) → **"✍️ Escribir el contrato"** → ver el mensaje de éxito con los @ insertados y **la pieza SALE de la bandeja** (refresco automático). El verde deja de mentir de verdad.

---

## R5 (mitad UI) — el modo avanzado reclasifica/firma/pone candado de verdad — ✅ VERDE

**Qué se entregó (cirugía mínima, `<style>` intacto):**
- **`app/src-tauri/src/lib.rs`** — `override_accion(repo, ruta, accion, motivo)` → `tools/override.ps1 -Json` (mismo helper `correr_script_ps`, args separados sin shell). Registrado en `generate_handler!`. La **firma NO viaja como parámetro**: el motor la deriva de `git config` (ADR 0047).
- **`app/ui/index.html` — `rootCheck()`:** la contraseña dejó de ser `'GARANTIA-NULA'`. Ahora compara contra el **NOMBRE DEL REPO** (`nombreRepo()` = basename de `FOTOREPO`), con `norm()` **case-insensitive + tolerante a acentos** (NFD + strip de diacríticos, como ya hacía con la `Í`). Prompt y error del modal reescritos a **"teclea el nombre del repo"** (patrón GitHub, ADR 0047). Si **la foto no cargó** (`!FOTOREPO`), `rootToggle()` **no abre** el modo avanzado y avisa.
- **`reclas` (`reclasResumen`/`reclasEscribir`):** el paso final gana **"✍️ Firmar y aplicar"** → invoca `override_accion` mapeando el form: régimen `estatuto`→`reclasificar-estatuto`, `libre`→`reclasificar-libre`; **`motor` se rechaza** (el motor no lo ofrece → botón deshabilitado + nota). Si el candado está marcado, encadena un segundo invoke `candado-on`. **Motivo obligatorio** (`rc-why`). **LA FIRMA NO SE TECLEA:** el `<input id="rc-firma">` se **eliminó** y se reemplazó por la nota *"La firma NO se teclea. Se deriva de tu `git config`…"*; tras el éxito se muestra la **firma REAL** devuelta por el motor (quien/email/cuando/motivo). Si el motor aborta (sin `user.name`) se muestra ese error tal cual. **Refresco tras éxito.**

**Teatro CONFESADO:**
- **Flujo `'rec'` (reconciliar):** queda teatro. Es un **ejemplo fijo del tour** (`arranca.md`) **sin pieza/ruta real ni campo de motivo**, así que no invoca el motor. Su `.carton` lo confiesa **y aclara que `aceptar-desviacion` SÍ existe** en `override.ps1` — se cablea cuando el detector traiga desviaciones reales con su ruta; "restaurar" (re-inyectar el @) **no tiene motor** aún.
- **Wizard `'agente'` (crear agente):** teatro, **fuera de alcance** (no hay motor para dar de alta un agente). `.carton` lo confiesa.

**Nota de corrección (comentario, no lógica, no `<style>`):** el `<script>` traía un typo pre-existente desde R3 — el comentario `…/REG*/AREAS/…` cerraba el bloque `/* */` antes de tiempo (`*/`), rompiendo el parseo JS. Corregido a `REGs/AREAS`. Es un comentario; no toca lógica ni el `<style>`.

**Evidencia (esta máquina, 2026-07-21):**

| Gate | Exit | Nota |
|---|---|---|
| `tools/probar-app.ps1` | **0** | **35/35**. Asserts nuevos verdes: **`'GARANTIA-NULA'` YA NO aparece**; el JS invoca `override_accion`; `lib.rs` define+registra `override_accion`. |
| `tools/probar-override.ps1` | **0** | 26/26 (el motor no se tocó). |
| `tools/probar-publicar.ps1` | **0** | 7/7. |
| `tools/anti-pii.ps1` | **0** | 267 archivos, sin fugas. |
| `tools/verificar.ps1` | **0** | Sin bloqueo. **2 avisos no bloqueantes** (área `app`: "registra en CHANGELOG"; `barreras`: grafo de producto). El CHANGELOG es del release (mismo patrón que R2–R4). |
| Smoke JS↔Rust↔motor | **—** | Corrí `override.ps1` **con los args exactos del puente** (`-Repo … -Path tools/verificar.ps1 -Accion candado-on -Motivo "demo…" -Json`) → `ok:true`, `candado=true` + **firma REAL derivada de git** (`quien=ArmandoMedina`, email noreply, `cuando` ISO-UTC). Escritura revertida. `node vm` del `<script>` → **SYNTAX OK**. |

**Confesión honesta (el click end-to-end):** no puedo clickear la ventana Tauri en headless. Verifiqué **por partes**: la app compila y el `.exe` se regeneró; el `<script>` parsea (`node vm`); y los **motores producen escrituras reales con los args exactos que arma el puente Rust** (smokes arriba). El **clic real** — teclear el nombre del repo, reclasificar/poner candado y ver la firma real + a la IA rebotar — **lo hace el cliente en su Gemba**.

**Demo del cliente (owner: cliente):** doble clic al `.exe` → **🔒 Modo avanzado** → teclear **el nombre del repo** (p. ej. `jidoka`) para entrar → elegir una pieza → **⚙️ Reclasificar régimen** → marcar **🔒 Candado a la IA** + motivo → **"✍️ Firmar y aplicar"** → ver la **firma real** (tu nombre de git) y el candado ON; refrescar y ver el badge. Bonus: en una sesión de Claude Code, pedirle a la IA editar esa pieza → **rebota** (deny del harness + PreToolUse) y cae a la bandeja.

**Fix de review (2026-07-21, misma sesión):** dos correcciones quirúrgicas en `reclasEscribir()` y el form del wizard `reclas` (`app/ui/index.html`; `<style>` intacto, hash SHA256 `0BF53EE3…59AD7A`):
1. **Éxito parcial honesto:** el bucle de acciones rastreo qué se aplicó; en el fail, el mensaje dice explícitamente qué quedó aplicado y qué falló (p. ej. "reclasificar-estatuto: APLICADO — candado-on: FALLÓ: <error>"). Tras éxito parcial también refresca datos (el régimen ya cambió).
2. **Candado-off desde la UI:** el checkbox `rc-lock` se inicializa con el estado real de la pieza (`P[id].candado`); al aplicar, se compara: marcado y no lo estaba → `candado-on`; desmarcado y lo estaba → `candado-off`; sin cambio de ninguno de los dos → "no hay cambios que aplicar" (sin invocar al motor). Si el régimen no cambió (comparado contra `P[id].regimen`) y la única acción es de candado, se emite solo esa. El resumen del paso 2 refleja las acciones reales que se emitirán.
Evidencia: `node vm` SYNTAX OK + `tools/probar-app.ps1` 35/35 (hash intacto) + `npx tauri build --debug --no-bundle` recompilado a `jidoka-tuberia.exe` (12.8 MB, 21/07/2026 15:07:48).

---
