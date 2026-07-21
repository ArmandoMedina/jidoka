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
