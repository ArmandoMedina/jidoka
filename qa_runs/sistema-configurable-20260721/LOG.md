# LOG — Sprint "El sistema configurable, fase 1"

> El listón de evidencia de la corrida (evidencia-no-palabra). Se llena **por rebanada**, no al cierre.
> Rama: `sprint/sistema-configurable-20260721`. Plan-contrato: `docs/sprints/sprint-20-sistema-configurable-plan.md`.

## Método reproducible

6 rebanadas de construcción (R1–R6):
1. **R1:** 3 ADRs (0045-0047) + capacidad CFG-1 + rename del concepto a "estatuto".
2. **R2–R5:** Bandeja (`bandeja.ps1`), estatuto del ritual (`estado-ritual.ps1`), candado IA (hook PreToolUse), formulario en extensión con webview.
3. **R6:** Modo avanzado en extensión (firma derivada de git, reclasificar con firma).
4. Cada rebanada corre su suite de tests; el motor cablea en `andon.yml`.

Criterio final: el **Gemba F5** del cliente (sin código ni terminal) en VS Code.

## Contexto de la sesión

- **R0 ratificado** por el cliente el 2026-07-21 en plan mode formal (*"el plan en mode plan formal y te autorizo"*).
- **Cambio de naming ordenado en vuelo:** el cliente pidió retirar toda mención de "SAP" (marca de un tercero) y nombrar el concepto. Elegido: **`estatuto`** (el régimen del medio) / **"gobierno por estatuto"** (el modelo). Barrido a TODO el repo (alcance elegido por el cliente): 17 puntos + 2 valores de régimen en minúscula, con el ADR 0042 enmendado (nota honesta, no reescritura muda) y la maqueta con la clave `estatuto` consistente en sus 5 sitios. Verificado: `grep -i "\bsap\b"` = 0.

---

## R1 — Los 3 ADRs + la capacidad CFG-1 — ✅ VERDE

**Qué se entregó:**
- `docs/decisions/0045-identidad-sistema-gobierno-configurable.md` — identidad: metodología → sistema de gobierno configurable (la UI autora, el gate ejecuta; ADR 0002/0044 intactos).
- `docs/decisions/0046-contratos-y-regimenes.md` — los 3 regímenes por pieza (`motor`/`estatuto`/`libre`), el régimen efectivo = fábrica + overrides, `tools/contratos.json` como INSTANCIA no-clobber, el rename `estatuto`, y R3b diferida.
- `docs/decisions/0047-meta-gobierno-contrasena-firma-candado.md` — meta-gobierno: contraseña-ritual + firma (derivada de git config) + candado IA (hook PreToolUse = único muro; `permissions.deny` = capa estática barata por prefijo, no ruta).
- `product/capacidades/CFG-1-gobierno-configurable.md` — capacidad ancla, `estado: en_revision` (pasa a `vigente` tras el Gemba), con los 6 Gherkin de R0. Declarada en `product/modulos/MOD-andon.md`.
- `docs/decisions/README.md` — las 3 filas del índice (el `decisiones` BLOQUEA sin índice en el mismo commit).
- Enmienda de `docs/decisions/0042-*` (rename del concepto) + su fila del índice.

**Evidencia (esta máquina, 2026-07-21; corrida por el asiento `auditor`):**

| Gate | Exit | BLOQUEA | AVISA | Nota |
|---|---|---|---|---|
| `tools/auditar.ps1` | **0** | 0 | 0 | Grafo íntegro. CFG-1 resuelve `[[MOD-andon]]`/`[[Metodo]]`/`[[AND-1-muro-andon]]`/`[[KIT-2-gobierno-documental]]`; no huérfana (MOD-andon la lista); ADRs sin wikilinks rotos. |
| `tools/verificar.ps1` | **0** | 0 | 2 | Avisos no bloqueantes: `[ritual]` y `[atlas]` por tocar `arranca.md` en el barrido de texto (rename, no cambio de flujo → criterio de excepción del propio aviso aplica). |

**Demo del cliente (owner: cliente, sin código ni terminal):** leer los 3 ADRs en el PR — 0045 (identidad), 0046 (contratos y regímenes), 0047 (meta-gobierno).

**Deuda anotada:** los 2 avisos de `verificar` sobre `arranca.md` son del rename (texto). Si en una rebanada futura se cambia el *flujo* del `arranca`, ahí sí toca revisar su diagrama de atlas y su RIT-*.

---

## R2 — La bandeja "pendiente de parametrizar" — ✅ VERDE

**Qué se entregó:**
- `tools/bandeja.ps1` (mecánica, sembrada) — vista de solo lectura que reúne en UNA cola lo que ninguna regla gobierna. Calca `Test-Pattern`/enumeración git de `estado-gobierno.ps1` y `Normaliza`/`Get-Secciones` de `estado-docs.ps1` (funciones gemelas, documentadas en el header). Tres motivos: **huérfano** · **solo existe** (árbol auditado sin regla; el hueco de `docs/`) · **desviado** (doc capa-2). `product/` NO cae en la cola (lo gobierna el grafo de `auditar`). Resta lo firmado en `contratos.json` (INSTANCIA). Exit 0 siempre; exit 2 si no-git. `-Salida` HTML sin BOM.
- `tools/probar-bandeja.ps1` — 15 verificaciones.
- Cableado: manifiesto (mecánica), `andon.yml` (humo CI), `publicar.ps1` (preflight — el invariante de `probar-publicar`), `andon/README.md` (el mapa del motor).

**Evidencia (esta máquina, 2026-07-21):**

| Gate | Exit | Nota |
|---|---|---|
| `tools/probar-bandeja.ps1` | **0** | 15/15: los 3 motivos, capa-2 CONFORME fuera, contrato/firmado fuera, no-git exit 2, HTML sin BOM, Parte B real (invariante: pieza de motor no está en cola; product/ no inunda). |
| `tools/probar-publicar.ps1` | **0** | 7/7: `probar-bandeja` en el preflight (invariante satisfecho). |
| `tools/verificar.ps1` | **0** | 3 avisos no bloqueantes (CHANGELOG diferido al cierre + product_avisa de barreras). |

**Corrida sobre el repo real:** 34 elementos en la cola, todos "solo existe". **El hallazgo:** los árboles `docs/analisis` y `docs/sprints` no tienen ninguna regla que los gobierne. El caso real `docs/analisis/costo-neto-sgi-202607.md` aflora, como pedía el descubrimiento. Decisión de diseño del cliente (Gemba pendiente): ¿esos árboles merecen su propia regla de área, o se aceptan en bloque?

**Review (2 pases adversariales — correctitud + cableado/reuso):** curados en la rama — (a) el assert de Parte B acoplaba el CI a que `costo-neto-sgi` siguiera sin parametrizar (cuando R4 lo parametrice, el CI se rompería) → reemplazado por un invariante permanente; (b) faltaba fixture capa-2 CONFORME (agregado, cierra un punto ciego); (c) nota de funciones gemelas en el header (riesgo de drift). No cambiados con razón: el `2>&1`/BOM del fixture calcan el molde `probar-docs`; `product/` en `$arbolesAuditados` mantiene paridad con `estado-gobierno`.

**Demo del cliente (owner: cliente, sin código ni terminal):** doble clic al HTML de la bandeja (`bandeja.ps1 -Salida`) → ver `costo-neto-sgi` y los árboles sin regla confesados en la cola.

---

## R3 — El estatuto del ritual — ✅ VERDE

**Qué se entregó:**
- `tools/ritual-gobernado.json` (mecánica) — el ledger de los `@`-includes de fábrica por comando (`arranca`, `planea`, `que-sigue` con sus `@`; `gemba`/`descubre`/`cierra`/`desatendido` con `[]` explícito).
- `tools/estado-ritual.ps1` (mecánica) — el detector, hermano de `estado-docs`. `Get-Arrobas` extrae el token `@<ruta.ext>` fuera de fences (bare **o** backtickeado — `que-sigue` los escribe backtickeados). Aditiva = OK; falta un `@` de fábrica = DESVIADO nombrándolo. `-Estricto` = muro opt-in.
- `tools/probar-ritual.ps1` — 13 verificaciones.
- `arranca.md` §1b — surtido del detector (bang classifier-safe, junto al de `estado-docs`) → el demo confiesa la desviación en la sesión.
- Cableado: manifiesto, `andon.yml` (humo + **step `-Estricto` dedicado**, paridad con `estado-docs`), `publicar.ps1`, `andon/README.md`.

**Evidencia (esta máquina, 2026-07-21):**

| Gate | Exit | Nota |
|---|---|---|
| `tools/probar-ritual.ps1` | **0** | 13/13: conforme, faltante nombrado, aditiva, **backtickeado** (lock de `que-sigue`), fence, `-Estricto` muerde/no-muerde, Parte B (arranca CONFORME + 0 desviados en todo el ritual real). |
| `tools/estado-ritual.ps1` (repo real) | **0** | 7 conforme / 0 desviado. |
| `tools/probar-publicar.ps1` | **0** | 7/7 (invariante). |
| `tools/verificar.ps1` | **0** | 6 avisos no bloqueantes (CHANGELOG diferido; atlas/RIT deferibles). |

**Hallazgo del build:** `que-sigue.md` escribe sus `@` **backtickeados en viñeta**, distinto de `arranca`/`planea` (bare, columna 0). El detector se amplió a matchear el token `@<ruta.ext>` (ambas formas). Límite conocido: un `@` backtickeado en prosa es sintácticamente idéntico a uno backtickeado directiva — la mitigación es que el ledger solo liste directivas reales (documentado).

**Review (2 pases adversariales):** curados — (a) **asimetría CI**: faltaba el step `-Estricto` de `estado-ritual` en `andon.yml` (el muro opt-in estaba en prosa, no en el YAML) → cableado; (b) **Parte B débil**: solo aseguraba `arranca` → agregado assert "0 desviado" que cubre todos los comandos; (c) regex sobre-matcheaba emails (`user@host.com`) → lookbehind negativo; (d) asserts DESVIADO sin ancla `cmd/` → anclados. No cambiados con razón: fences de 4 backticks (el regex ya matchea la apertura; calca `estado-docs`); la ambigüedad backtick directiva-vs-prosa es indistinguible sintácticamente.

**Trampa confesada (fase 1):** un `@` legal hace DIVERGER el sello por hash del comando aunque el estatuto sea CONFORME — el estatuto manda sobre la legalidad del `@`; el detector lo confiesa en su salida. Cura completa: R3b (clase `contrato` en la siembra, ADR 0046, diferida).

**Demo del cliente (owner: cliente, sin código ni terminal):** quitarle el `@product/PRODUCT_BRIEF.md` a su `arranca.md` → el siguiente `/jidoka:arranca` lo confiesa `DESVIADO` nombrándolo; restaurarlo → `CONFORME`.

---

## R5 — El candado IA (hook PreToolUse) — ✅ VERDE

**Qué se entregó:**
- `.claude/hooks/candado-pretooluse.ps1` (mecánica, viaja en la carpeta `.claude/hooks` sembrada) — calca `no-memorias-pretooluse.ps1`: stdin JSON, **falla-abierta** (exit 0) si no parsea, o si `tools/contratos.json` no existe / está podrido (el hook viaja a hijos sin ledger). Deniega (`permissionDecision=deny`) que la IA edite (Write/Edit/Bash) una pieza con `candado:true` en `contratos.json`, nombrando el contrato y el camino legal (modo avanzado con firma). Write/Edit por ruta (comparación **literal** `EndsWith`); Bash por heurística (cmdlet/redirección a la ruta).
- `.claude/settings.json` — 2ª entrada `PreToolUse` (matcher `Write|Edit|Bash`) que corre el candado, junto a `no-memorias`.
- El disparo **`deny-vs-ask`** pasa de **catálogo-solo a cableado** (`kit/.jidoka/disparos/README.md` → `.claude/hooks/candado-pretooluse.ps1`, que nombra el slug): el candado es el lado DENY del eje. `probar-disparos` lo vigila contra rot.
- `tools/probar-hooks.ps1` — 10 casos nuevos de candado. `andon/README.md` — documentado.

**Evidencia (esta máquina, 2026-07-21):**

| Gate | Exit | Nota |
|---|---|---|
| `tools/probar-hooks.ps1` | **0** | 42/42 (10 candado: deny Write/Edit/Bash, silencio sin candado, leer no bloquea, `2>&1` no falso positivo, sin ledger falla-abierta, ledger podrido falla-abierta, `candado:false` no muerde, Edit explícito, backslash normalizado). |
| `tools/probar-disparos.ps1` | **0** | 15 cableados + 1 catálogo-solo (deny-vs-ask cableado, rot-check verde). |
| `tools/probar-publicar.ps1` | **0** | 7/7 (probar-hooks ya en el preflight). |
| `tools/verificar.ps1` | **0** | 4 avisos no bloqueantes (CHANGELOG diferido; atlas deferible; disparos→tesis no aplica: no cambió la regla). |

**Nota de seguridad:** el candado es el único muro determinista del meta-gobierno (el `permissions.deny` de settings es capa estática por prefijo, no por ruta — no lo cablé para no sembrar sintaxis sin verificar; el hook es el enforcement). Límite confesado (heredado de `no-memorias`): aliases y rutas ofuscadas evaden la heurística de Bash — poka-yoke fuerte, no jaula perfecta; el muro server-side protege la rama.

**Review (2 pases adversariales):** curado un **agujero real** — `-like "*/$rel"` interpretaba metacaracteres glob (`[`,`]`,`*`) en la ruta del candado → fallaba-abierto; cambiado a comparación literal `EndsWith`. Reforzado el test con caso `Edit` explícito y caso Bash con backslash (prueba la normalización `\`→`/`). No cambiado: newline-en-redirección (frontera confesada, idéntica a `no-memorias`).

**Demo del cliente (owner: cliente, sin código ni terminal):** con una pieza marcada con candado en `contratos.json`, pedirle al agente en el chat "edita ese archivo" → verlo **rebotar** con la razón que nombra el contrato y el camino legal. *(Requiere R4/R6 para poner el candado desde la UI; en fase de construcción se prueba con un `contratos.json` a mano.)*

---

## R4 — El formulario en la extensión — ✅ VERDE (código; Gemba F5 = cliente)

**DECISIÓN DEL CLIENTE (2026-07-21, en vuelo):** VS Code confirmado (recordó ADR 0044 + su F5-GO del 2026-07-20) **+ formulario FIEL A LA MAQUETA** → webview-formulario, **NO** QuickPicks (supera el "NO webview-formulario" del plan original). Se le mostró una comparativa clickeable (`.jidoka/parametrizar-comparativa.html`, scratch) para decidir con los ojos. Se aclaró: la parte de *ver* (tubería + bandeja) es webview en cualquier caso; el navegador no puede escribir archivos (por eso VS Code, no un HTML suelto).

**Qué se entregó (extension/, Jidoka-only, NO se siembra):**
- `extension/contratos.js` (módulo JS puro) — writers UTF-8 sin BOM + `\n` (calca `ligas.js`): `upsertContrato` (merge por path en `contratos.json` — la bandeja lo resta) y `agregarAFuente` (agrega la ruta a la `fuente` de un área en `blast-radius.json`, crea el área si es "cajón nuevo", array raíz respetado).
- `extension/ritual.js` — `insertarArroba`/`quitarArroba`: inserta el `@` en el marcador `<!-- jidoka:arrobas -->`, jamás regex-replace del cuerpo; idempotencia por token; newline final garantizado.
- **Marcador de inserción** `<!-- jidoka:arrobas -->` en `arranca`/`planea`/`que-sigue` (diferido de R3, va con su consumidor).
- `extension.js`: comando **`jidoka.parametrizar`** (clic derecho) → **webview-formulario** fiel a la maqueta (radios de régimen coloreados, cajón+fuerza, casillas de comandos) → postMessage → escribe contrato + regla + `@`. Comando **`jidoka.verBandeja`** → webview del HTML de `bandeja.ps1`. `package.json`: 2 comandos + menú contextual.
- `extension/contratos.test.js` + `extension/ritual.test.js` (node --test).

**Evidencia (esta máquina, 2026-07-21):**

| Gate | Exit | Nota |
|---|---|---|
| `tools/probar-extension.ps1` | **0** | 24/24: los 5 comandos declarados↔registrados, los 7 JS parsean (`node --check`), `node --test` verde (ligas + contratos + ritual). |
| `node --test` (extension/) | **0** | 24 tests: contratos (upsert merge, encoding sin BOM, agregarAFuente idempotente/crea-área), ritual (inserta en marcador, idempotencia por token, newline final, preserva cuerpo, quitar sin tocar prosa). |
| `tools/verificar.ps1` | **0** | 4 avisos no bloqueantes (CHANGELOG diferido; atlas/RIT deferibles por los marcadores). |

**Cobertura del demo, verificada por piezas:** contrato `parametrizado` → la bandeja lo resta (probar-bandeja) · `@` insertado → el estatuto lo acepta como aditiva (probar-ritual) · encoding cross-stack sin BOM (node --test). El glue de la extensión los teje; el Gemba F5 es del cliente.

**Review (2 pases adversariales):** curado — (a) **[ALTO] escritura parcial silenciada**: si `agregarAFuente`/`insertarArroba` fallaban tras el contrato, el usuario veía "éxito" → ahora **acumula avisos y los reporta** (`showWarningMessage`); (b) `insertarArroba` idempotencia por substring → falso positivo con prefijos → **chequeo por token** (regex con borde); (c) **newline final** no garantizado → asegurado + test; (d) `esc()` sin comilla simple → agregada; (e) **CSP** en el webview. No cambiado: el schema del área nueva es correcto (compatible con verificar/bandeja).

**Demo del cliente (el Gemba central, owner: cliente, sin código ni terminal):** en VS Code (F5), crear `docs/glosario-del-dominio.md` → **"Jidoka: ver la bandeja"** lo muestra pendiente → clic derecho → **"Jidoka: parametrizar..."** → el formulario-webview (fiel a la maqueta) → elegir régimen/cajón/fuerza + marcar "arranca" → **Escribir el contrato** → ver el `@` en `arranca.md`, la regla en `blast-radius.json`, y la bandeja limpia. Sin JSON, sin terminal.

**Nota de método (Kaizen de la sesión, corrección del cliente):** de aquí en adelante el trabajo pesado va a **subagentes** — el orquestador no pica código en el hilo principal. R6 se construyó así (un subagente completo: código + tests), y los fixes de su review los aplicó el `mecanico`. Las rebanadas R2–R5 se picaron demasiado "🎭 en sesión" — deuda de disciplina anotada.

---

## R6 — El modo avanzado (firma + reclasificar) — ✅ VERDE (construido por subagente)

**Qué se entregó (extension/):**
- `extension/contratos.js` — `firmaDeterminista(quien, email, cuando, motivo)` (lanza si falta `quien` o `motivo`; email/cuando pueden ir vacíos) + `registrarOverride(contratosPath, {path, accion, firma})` — merge por path, escribe según la acción: `aceptar-desviacion`→`estado:'aceptado'` (la bandeja lo resta con badge) · `candado-on/off`→`candado:true/false` (lo lee el hook R5) · `reclasificar-estatuto/libre`→`regimen`. **Nunca ofrece 'motor'** (acción desconocida lanza).
- `extension.js` — comando **`jidoka.reclasificar`** (clic derecho): acción (QuickPick) → **motivo obligatorio** → **contraseña-ritual** (teclear el nombre del repo, deliberación) → **firma derivada de git config** (`user.name`/`user.email` + fecha ISO — **aborta si no hay user.name**, no la inventa) → **confirmación modal** → escribe `contratos.json`. Sin éxito falso.
- `package.json` — comando + menú contextual. `contratos.test.js` — 4 casos R6 (node --test).

**Evidencia (esta máquina, 2026-07-21):**

| Gate | Exit | Nota |
|---|---|---|
| `tools/probar-extension.ps1` | **0** | 26/26: `jidoka.reclasificar` declarado↔registrado, node --test verde (28 tests JS). |
| `node --test` (extension/) | **0** | 28: firma lanza sin quien/motivo, override aceptar-desviacion no duplica, candado-on→off mergea, firma incompleta lanza. |

**Review (adversarial, `auditor`):** curado — (a) **[ALTO] firma inventada** `(sin git user.name)` violaba ADR 0047 → ahora **aborta** pidiendo configurar git; (b) `firmaDeterminista` normalizaba pero se descartaba el retorno → usa `firmaValida`; (c) contraseña-ritual asimétrica → `.trim()` a ambos lados. No cambiado con razón: un contrato de solo-candado sin `regimen` no rompe nada (el hook lee `candado`, la bandeja lee `estado`).

**Demo del cliente (owner: cliente, sin código ni terminal):** en VS Code, clic derecho sobre un doc desviado → **"Jidoka: modo avanzado..."** → "aceptar la desviación" → teclear un motivo → teclear el nombre del repo → confirmar el modal → el doc **sale de la bandeja con badge y tu nombre** (la firma de git). Y con "poner candado IA" + luego pedirle al agente que lo edite → **rebota** (el candado de R5).

---

## Resultados

## Cierre del sprint — las 6 rebanadas VERDES

| R | Qué | Evidencia |
|---|---|---|
| R1 | 3 ADRs (0045-0047) + CFG-1 + rename estatuto | auditar 0, verificar 0 |
| R2 | La bandeja (`bandeja.ps1`) | probar-bandeja 15/15 |
| R3 | El estatuto del ritual (`estado-ritual.ps1`) | probar-ritual 13/13 |
| R5 | El candado IA (hook PreToolUse) | probar-hooks 42/42, deny-vs-ask cableado |
| R4 | El formulario (webview fiel a la maqueta) | probar-extension 24/24 |
| R6 | El modo avanzado (firma + reclasificar) | probar-extension 26/26, node --test 28 |

**Pendiente del cliente para cerrar la fase 1:** (1) el **Gemba F5** del flujo del glosario end-to-end en VS Code (owner: cliente, es el criterio de "hecho"); (2) **CHANGELOG + bump a `v1.26.0`** (diferido al cierre, como manda el plan); (3) **PR + merge** con orden nombrada.

## Veredicto

Sistema configurable fase 1 lista: los 3 ledgers (bandeja, ritual, contratos) funcionan; el hook candado bloquea ediciones; la extensión escribe con formulario fiel a la maqueta y firma derivada de git.
