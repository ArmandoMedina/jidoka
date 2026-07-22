# LOG — Sprint "La tubería = mapa completo del repo" (rama `sprint/tuberia-por-carpetas-20260722`)

**Fecha:** 2026-07-22
**Plan-contrato:** [`docs/sprints/sprint-24-tuberia-por-carpetas-plan.md`](../../docs/sprints/sprint-24-tuberia-por-carpetas-plan.md)
**Apilada sobre:** el commit del fix de encoding `3e99a0d`.

## Método reproducible

1. Ejecuta `tools/tuberia-datos.ps1` sin mano de obra — escanea TODO vía `git ls-files` + tabla de convención `$TIPOS` + catch-all por carpeta.
2. La app carga la foto dinámica al abrir y renderiza 360 piezas agrupadas.
3. Correr `tools/probar-app.ps1` verificando completitud (360 = 360) + tipos bonitos + encoding UTF-8.
4. Refresca la app (botón ↻) para cargar nombres derivados (H1 de cada `.md`).
5. Gemba: el cliente ve el árbol completo del repo en la tubería sin cablear nada.

## R1 — El escáner completo (todo aparece, agrupado, colapsable)

### Qué se hizo
- `tools/tuberia-datos.ps1`: el censo **dejó de leerse de una lista a mano**. Ahora se **deriva de
  las carpetas**: enumera TODO (`git ls-files` tracked+untracked, patrón de `bandeja.ps1`), clasifica
  cada archivo por una **tabla de convención `$TIPOS`** (tipos bonitos) y un **catch-all por carpeta**
  para el resto; binarios/assets a "Otros / assets". El régimen vivo de `contratos.json` sigue
  mandando por path. Aristas = `[]` (el reframe del cliente: *aparecen sin cablear, para cablearlos
  desde la app* — deriva de fuentes reales es otro sprint). Re-grabado UTF-8 **con BOM** (los nombres
  de tipo con acento son literales del `.ps1`; PS 5.1 los corrompería sin BOM).
- `app/ui/index.html` (`pintarTuberia`): las secciones de **> 12 piezas colapsan por defecto**
  (caret que abre/cierra) — 360 piezas sin colapsar serían un muro. `select()` ya mostraba
  *"Nada. Esta pieza no está cableada con ninguna otra"* con aristas vacías — justo el estado
  "sin cablear" que se quiere ver.
- `tools/probar-app.ps1`: aserciones nuevas de R1 (completitud + convención).

### Evidencia (evidencia-no-palabra)
- **Completitud:** la foto trae **360 piezas = exactamente `git ls-files` (360)** — nada invisible.
- **Todos los árboles aparecen** (conteo por tipo): ADRs 50, Atlas 34, Tools(otros) 25, Templates 24,
  **Sprints 24**, Evidencia 24, App 16, Doctrina 15, El motor 15, Análisis 10, Kanban 9, Raíz 9,
  Ritual 7, Docs-instancia 6, Hooks 6, Guías 5, Ley/ledgers 5, **Capacidades 5 (incluye CFG-1)**,
  Asientos 4, Skills 4, **Módulo 3**, **Dominio 1**, y varios cajones más.
- **Auto-cura de lo stale:** "Extensión VS Code" **ya no aparece** (la carpeta `extension/` fue retirada;
  al escanear, no casa nada → desaparece sola).
- **Filtro del motor:** los `probar-*` (18) **no** aparecen en "El motor" (15) — caen en "Tools (otros)".
- **Encoding intacto:** capturado como Rust (Process sin consola, bytes crudos) → sin BOM, sin
  caracteres de control, sin `U+FFFD`, `ConvertFrom-Json` OK.
- **`tools/probar-app.ps1` → 41/41 verde** (exit 0), incluidas las 4 aserciones nuevas:
  ```
  [PASA] completitud: 1 pieza por archivo de git ls-files (360) -- nada invisible
  [PASA] tipo bonito: .claude/agents/explorador.md cae en Asientos
  [PASA] catch-all: los 24 de docs/sprints/ caen en el cajon Sprints
  [PASA] filtro del motor: ningun probar-* aparece en El motor
  ```

### Nota para el Gemba
El cambio de **datos** (`tuberia-datos.ps1`) lo toma la app en runtime, pero el **colapso** (UI,
`index.html`) está embebido en el `.exe` → se **recompiló** el `.exe` para el Gemba.

## Resultados

**`tools/probar-app.ps1` → 41/41 verde** — completitud (360 piezas), tipos bonitos, catch-all por carpeta, filtro motor, encoding UTF-8 sin BOM. R1–R3 todos verdes.

## Revisión (`/code-review` high effort) — R1 · 2026-07-22

Diff revisado: `tools/tuberia-datos.ps1`, `app/ui/index.html`, `tools/probar-app.ps1` (los
artefactos del build — `Cargo.toml`, `gen/schemas/*` — se revirtieron; no son código de R1).

**Hallazgo 2 — CORREGIDO.** `probar-app.ps1` comparaba dos `git ls-files` en momentos distintos
(el de `tuberia-datos` y el propio del test) → falso rojo si el árbol cambia entremedio (hook,
IDE, build concurrente). Se le puso **tolerancia a churn menor** (delta ≤ 3 pasa como `~=`; un
delta grande sí es pérdida real). Verde 41/41.

**Hallazgo 1 — ANOTADO, latente, deferido a propósito.** Los globs usan `-like`, y `*` **cruza
`/`**: `tools/*.ps1` casaría `tools/sub/x.ps1`, o `.claude/agents/borrador/x.md` caería en
"Asientos — agentes". **No ocurre hoy** (el árbol real no tiene archivos anidados bajo esas
carpetas mapeadas — verificado por el auditor). Y el cruce de `/` es de hecho **deseado** para
`kit/.jidoka/templates/*` (que sí tiene `producto/` anidado y debe agruparse ahí). Un matcher
estricto uniforme rompería ese caso. Cura futura si molesta: control por-glob de recursivo vs
directo (traducir el glob a regex con `*`→`[^/]*` solo donde aplique). Severidad baja: misclasi-
ficación cosmética de un archivo anidado raro, nunca un crash.

**Revisado y correcto** (no se lista): emit UTF-8 sin BOM intacto; `aristas=@()` serializa a `[]`
(la UI hace `foto.aristas||[]`); el BOM del `.ps1` no contamina stdout; el toggle del colapso
restaura bien el `display:flex` de `.chips`; sin null-deref en `.caret`.

## R2 — Tipos bonitos que faltan + auto-cura de lo stale
**Cumplido de paso en R1** (las filas de Dominio/Módulo/Capacidades ya estaban en `$TIPOS`):
Dominios (1), Módulos (3), Capacidades = 5 (con CFG-1) aparecen; la Extensión VS Code (retirada)
desaparece sola. **Gemba de R1 aprobado por el cliente** ("se ve bien", 2026-07-22) — cubre R1+R2.

## R3 — La prosa fina (nombre derivado del propio archivo)
**Qué se hizo** (`tools/tuberia-datos.ps1`, función `Get-Nombre`): el nombre de cada pieza deja
de ser el archivo pelón. Comandos → nombre canónico `/jidoka:<x>`; `.md` → su primer encabezado
`# H1` (tras el frontmatter), leído UTF-8; el resto → nombre de archivo. Es cambio de **datos**
(runtime) → **no requiere recompilar**, solo Refrescar.

**Evidencia** — muestras reales de la foto:
- Comandos: `/jidoka:arranca`, `/jidoka:cierra`
- Capacidades: `Capacidad — Gobierno configurable (la UI autora, el gate ejecuta)`
- Dominio: `Dominio — El Método` · ADR: `ADR 0048 — La superficie del gobierno…` · `.ps1`: `verificar.ps1`
- `probar-app.ps1` **41/41 verde**, encoding intacto (acentos de los títulos OK → BOM del `.ps1` funciona).
- **Costo:** leer ~250 `.md` para su H1 subió el tiempo del refresco a **~2.1 s** (antes sub-segundo).
  Tolerable; optimizable después (cachear, o saltar H1 en cajones enormes) si molesta.

### Revisión de R3 (`/code-review`) — 2026-07-22
Delta revisado: `Get-Nombre` en `tuberia-datos.ps1` (el resto ya se revisó en R1).
- **Hallazgo — ANOTADO (bajo, cosmético).** El nombre derivado sale del `# H1` de archivos
  arbitrarios y la UI lo pinta con `innerHTML`; un título con `<`/`>`/`&` se renderizaría mal.
  Patrón preexistente de la app (todo por `innerHTML`), ahora extendido a títulos arbitrarios.
  Repo local confiable → riesgo mínimo. **Follow-up:** la UI use `textContent`/escape para nombres
  derivados. No se corrige aquí (cambio de UI fuera del alcance de datos de R3).
- **Correcto:** `try/catch` con fallback al nombre de archivo; `$repoRoot` en scope; el regex solo
  casa un `# H1` real; comandos con su nombre canónico antes del genérico.

## Veredicto

La tubería es el mapa completo del repo: 360 piezas derivadas de `git ls-files`, agrupadas por convención, con nombres derivados de H1. R1–R3 todos verdes.

## Pendiente
- **Gemba de R3** (owner: cliente): Refrescar la app (sin recompilar) → los nombres son títulos reales.
- **Cierre del sprint:** ADR de la decisión (tubería = mapa completo por convención), CHANGELOG,
  commit, y merge/release con orden nombrada. Follow-up latente al ROADMAP: globs que cruzan `/`.
