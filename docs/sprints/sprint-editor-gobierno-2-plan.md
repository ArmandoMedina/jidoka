# Sprint — El editor del gobierno, parte 2: R2–R4 (las ligas, la autoría y el empaquetado) · `v1.25.0`

## Contexto

El contrato del sprint (`docs/sprints/sprint-editor-gobierno-plan.md`, R0 aprobado 2026-07-19 en plan mode) definió 4 rebanadas. **R1 ya se entregó** (3 modos de grafo + extensión VS Code, PR #114 mergeado, Gemba del cliente **GO** el 2026-07-20). Este plan ejecuta **lo que falta del mismo QUÉ aprobado**: R2 (ledger de ligas + gate), R3 (la extensión autora) y R4 (empaquetado y gobierno).

**El QUÉ (sin cambios, ya aprobado):** *el usuario declara, desde una interfaz visual, qué código sostiene qué capacidad — y con qué fuerza y en qué dirección se vigila esa relación — sin editar JSON a mano.* Métrica: el aviso de "cambié código" pasa de **89 capacidades** (caso entisoft) a **las declaradas (1–5)**. Línea doctrinal: **la extensión AUTORA, el gate EJECUTA** (ADR 0002 intacto).

## R2 — El modelo de ligas + el gate que las hace cumplir

**`tools/ligas.json`** (nace semilla `{"ligas":[]}`): `{ "ligas": [ { "id", "codigo": [globs], "capacidades": [rutas .md], "direccion": "codigo-a-capacidad|capacidad-a-codigo|ambas", "fuerza": "avisa|bloquea" } ] }`.

**`tools/estado-ligas.ps1`** (espejo de `estado-docs.ps1` + firma de `verificar.ps1`):
- Params: `-Base` (CI), `-Cambiados` (tests, sin git), `-Ledger` (gemelo de `-Manifiesto`, para leer desde la base), `-Repo`, `-Estricto`.
- Rango: réplica byte-fiel del triple fallback de `verificar.ps1` (`-Cambiados` → `-Base` con `git diff --name-only base...HEAD` → upstream/working tree). Matcher `Test-Pattern` copiado byte-fiel (no mentir sobre lo que ve el gate).
- **Violación por co-ocurrencia:** `codigo-a-capacidad` = cambió algo que casa `codigo[]` y nada que case `capacidades[]`; `capacidad-a-codigo` = la espejo; `ambas` = las dos reglas, cada dirección se reporta.
- **Exits:** 0 default (aviso; también ledger ausente), 1 solo `-Estricto` + liga `bloquea` violada (**nombrando la capacidad exacta**), 2 falla cerrado (rango incalculable / ledger que no parsea). `[BLOQUEA]` se imprime siempre aunque sin `-Estricto` no mate — la verdad se dice.
- **Ligas rotas** (glob que no casa nada trackeado / capacidad inexistente): `[ROTA]` = **aviso siempre, nunca bloqueo**, y la liga rota queda excluida de la evaluación (un medidor podrido no emite veredicto; bloquear por un renombre legítimo sería muro falso). Criterio del contrato: "avisa que la liga está rota".
- Encoding: ledger leído con `[System.IO.File]::ReadAllText` (UTF-8 sin BOM — lo que `fs.writeFileSync` de Node produce; ese es el contrato de encoding entre stacks).

**`tools/probar-ligas.ps1`** — fixture **git** temporal (molde `probar-linterna.ps1`, no el fixture simple de `probar-docs`, porque el evaluador consulta git), matriz de co-ocurrencia con `-Cambiados` inyectados. Casos: ledger ausente→0 · malformado→2 · avisa nunca bloquea (ni con `-Estricto`) · `bloquea`+`-Estricto`→1 nombrando la capacidad (ROJO) y tocando ambas→0 (VERDE) · direccionalidad real de `capacidad-a-codigo` · `ambas` por dirección · cambio sin liga→0 · regresión del matcher (`*.ps1` no casa `tools/x.ps1`) · liga rota no genera falso `[BLOQUEA]` · rango git real con `-Base` (2 commits). Parte B sobre el ledger real (enums válidos, cero rotas; se salta si no existe).

**Cableado:**
- `.github/workflows/andon.yml`: `probar-ligas` a la lista incondicional del smoke + **step nuevo leyendo evaluador Y ledger DESDE LA BASE** (molde exacto del step del blast-radius: `git cat-file -e` + `git show "${ref}:tools/..."` + correr la copia con `-Estricto`, hallazgos al job summary, fallback fundacional al del PR mientras la base no traiga el evaluador). Las ligas **bloquean** → base obligatoria (ADR 0003; `estado-docs` no lo hace porque su muro es opt-in — contraste ya registrado).
- `.githooks/pre-push`: tercera invocación `estado-ligas.ps1 -Estricto` (patrón `rc=$?` existente).
- `tools/publicar.ps1`: `'probar-ligas'` al array del preflight — **mismo commit que crear el test** (el poka-yoke `probar-publicar` enumera `probar-*.ps1` del disco y falla si falta del array).
- `kit/.jidoka/instalar/manifiesto.json`: `estado-ligas.ps1` y `probar-ligas.ps1` como `clase:"mecanica"`. **`ligas.json` NO se siembra** (decisión de este plan, matiz al contrato): es dato de instancia que autora el cliente — sembrarlo como mecánica haría que `-Actualizar` pisara sus declaraciones; el evaluador ya tolera ledger ausente.
- **Liga dogfood inicial** escrita a mano: `codigo: ["tools/estado-gobierno.ps1", "extension/*"]` ↔ `AND-1-muro-andon.md`, `codigo-a-capacidad`, `avisa` (avisa, no bloquea — no amurallar el propio sprint).
- **NO se toca `verificar.ps1`** ni `.claude/settings.json`.

## R2c — La linterna pinta las ligas

En `tools/estado-gobierno.ps1`: **nodo nuevo `liga:<id>`** por liga (ni arista área→cap — pierde dirección/fuerza/rotura — ni nodo por archivo — explota). Tipo `liga` (o `liga-rota` en rojo); tooltip con globs/dirección/fuerza. Aristas `liga:<id> → cap:<basename>` kind `liga-bloquea` (roja sólida) / `liga-avisa` (ámbar punteada); capacidad inexistente → nodo `capglob:` (la mentira no se omite). Ancla al cluster: por cada glob de `codigo[]`, `Get-Cobertura` resuelve su área → arista `area → liga` (el cluster la adopta); sin área, nodo suelto (honesto). Payload por el marcador único `/*__PAYLOAD__*/` (un solo `.Replace` — no reintroducir el doble-replace cazado en review). Leyenda: visible por defecto (son 1–5, no ruido). Casos nuevos en `probar-linterna.ps1` (nodo presente, arista tipada, rota en rojo, cero aristas colgadas).

## R3 — La extensión autora (el corazón)

**`extension/ligas.js`** — módulo JS plano **sin `require('vscode')`** (testeable con `node --test` e invocable con `node -e` desde PowerShell): `leer` (ausente → `{ligas:[]}`), `validar` (enums), `upsert` (mismo codigo+direccion+fuerza → une capacidades; id = slug del basename, `-2/-3` si colisiona), `quitar` (vacía `codigo[]` → elimina la liga). Escribe `JSON.stringify(obj, null, 2) + '\n'` UTF-8 sin BOM. Test: `extension/ligas.test.js` (`node:test`).

**Comandos** (declarados en `contributes.commands` Y registrados con `registerCommand` — `probar-extension.ps1` vigila el contrato):
- `jidoka.ligarCapacidad` — "Jidoka: ligar a capacidad…"
- `jidoka.quitarLiga` — "Jidoka: quitar liga…"
- Menú contextual del explorador: `contributes.menus["explorer/context"]`, `when: resourceScheme == file`, grupo `9_jidoka`. Handler `(uri, uris)` acepta multi-selección; carpeta → glob `<ruta>/*`; desde paleta → archivo del editor activo.

**Flujo:** QuickPick multi-select de `product/capacidades/*.md` (label = `clave:` del frontmatter — misma regex que la linterna —, pre-seleccionadas las ya ligadas) → QuickPick dirección (3 opciones explicadas en cristiano) → QuickPick fuerza (`avisa` / `bloquea — detiene el push`) → `upsert` → status bar "liga escrita en tools/ligas.json — el gate la hace cumplir en el próximo push". **Source Control:** basta `fs.writeFileSync` (el provider git de VS Code observa el working tree — confirmado). **Refresco:** se extrae `refrescarGobierno()` de `verGobierno`; tras upsert/quitar, si el panel está abierto, repinta.

**Contrato entre stacks:** caso nuevo en `probar-ligas.ps1` — `node -e "require('extension/ligas.js').upsert(...)"` y el evaluador PS lee ese archivo y reproduce el caso ROJO (`[SKIP]` sin node, patrón existente). `probar-extension.ps1` gana `node --test extension/`.

## R4 — Empaquetar y gobernar

- `.vsix` con `npx --yes @vscode/vsce package` + guía de instalación. **NO** marketplace, **NO** sembrar la extensión (regla 2-3; `probar-extension` ya lo vuelve invariante).
- **ADR 0044** "el editor autora, el gate ejecuta" — **hallazgo de la exploración: ya está citado por `extension.js`, `blast-radius.json` y `probar-extension.ps1` pero NO existe**; se escribe y se lista en el índice **en el mismo commit** (área `decisiones` bloquea si no). El área `extension` de la ley ya existe desde R1 — no se re-agrega.
- CHANGELOG cerrado, `andon/README.md`, HANDOFF, SSOT (`tools/version.txt` + `package.json`) a **`1.25.0`**.

## Orden de commits (cada uno verde)

1. **C1 (R2a):** evaluador + ledger semilla + `probar-ligas.ps1` + array de `publicar.ps1` + smoke de `andon.yml` + manifiesto — todo junto (el poka-yoke obliga).
2. **C2 (R2b):** step CI desde-la-base + pre-push + liga dogfood. *Demo R2 disponible.*
3. **C3 (R2c):** la linterna pinta ligas + casos en `probar-linterna.ps1`.
4. **C4 (R3a):** `ligas.js` + `ligas.test.js` + `node --test` en `probar-extension` + contrato entre stacks en `probar-ligas`.
5. **C5 (R3b):** comandos ligar/quitar + `package.json` (commands+menus). *Demo R3 disponible.*
6. **C6 (R4):** `.vsix` + guía + ADR 0044 + índice + CHANGELOG/HANDOFF/SSOT `1.25.0`.

Cada rebanada pasa `/code-review` antes de cerrar (gate `review-stop`; áreas `barreras` y `extension` son `revisa:true`).

## Verificación (el demo que corre el cliente — owner: cliente, sin código ni terminal)

1. F5 → clic derecho sobre un archivo → "Jidoka: ligar a capacidad…" → elegir 2 capacidades, dirección y fuerza → ver el diff de `tools/ligas.json` en *Source Control* y la liga pintada en el grafo.
2. Cambiar un archivo ligado `bloquea` sin tocar su capacidad → push desde el panel de git → el gate lo detiene **nombrando la capacidad exacta** (no "revisa las 89").
3. Quitar la liga desde la UI → el grafo deja de pintarla.

Evidencia de agente por rebanada: suite completa (`probar-ligas`, `probar-linterna`, `probar-extension`, `probar-gate`, `verificar`) + corrida en `qa_runs/editor-r2r4-<fecha>/LOG.md`.

## Lo que NO entra (frontera del contrato, sin cambios)

Marketplace · sembrar la extensión · otros editores · que la herramienta **sugiera** qué ligar (el juicio es del humano) · migrar la ley de entisoft (lo lleva otro agente) · que el gate juzgue contenido · tocar `verificar.ps1`.

## Riesgos declarados

- Primer gate que **bloquea** leyendo un ledger de instancia: el step desde-la-base lo protege de auto-desactivación (ADR 0003), pero el fallback fundacional (base sin evaluador) corre el del PR — ventana conocida de un PR, la misma que tuvo el andon original.
- El contrato de encoding JS↔PS (UTF-8 sin BOM) es el punto frágil entre stacks; lo vigila el caso de contrato en `probar-ligas.ps1`.
