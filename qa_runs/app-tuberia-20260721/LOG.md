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
