# Sprint — La 2.0 estable

> Plan aprobado en plan mode el 2026-07-22. **Este plan ES el sprint**: lo que no está aquí, no entra (se anota abajo en "Lo que NO entra").

## Contexto (por qué)

El kit aún no se considera listo para instalarse en repos ajenos, y «estable» sin definición es una meta que nunca llega. Cuatro escaneos `arquitecto` (2026-07-22, síntesis en `docs/analisis/escaneo-camino-2.0-202607.md`) mostraron que entre `v1.30.0` y una 2.0 instalable sin miedo no hay un cerro de features: hay un corte de honestidad (~5h), tres curas de fiabilidad y las superficies para absorber sin terminal. La restricción vigente del proyecto es la capacidad de absorción del dueño (el diagnóstico de flujo de 2026-07): la sobreproducción es el riesgo, no la falta de features.

## Encuadre de producto (validado con el cliente)

**«2.0 estable» deja de ser sensación y se vuelve una lista cerrada de 3 promesas:** (1) lo que se instala == lo que se promete; (2) el motor no se miente a sí mismo (fail-closed en todos los gates, copias gemelas vigiladas); (3) el cliente puede VER el gobierno sin terminal. Al cumplirse y aceptarse en Gemba, se libera `v2.0.0` con un ADR que deja escrito qué significa «2.0» (Windows-only, honesto, verificado).

Criterios de aceptación (Gherkin):

- Dado un repo Windows ajeno, cuando sigo el README tal cual, entonces el comando de instalación funciona y al terminar me dice qué muro aún NO muerde (branch protection manual).
- Dado que git falla dentro de `auditar.ps1`, cuando corre el gate, entonces falla cerrado (exit 2) — no aprueba a ciegas.
- Dado que una copia gemela (`Test-Pattern`, parser del ROADMAP, `Normaliza`…) diverge, cuando corre la suite, entonces un self-test lo marca en rojo y el CI bloquea.
- Dado el cliente sin terminal, cuando abre `conformidad-docs.html` y el mapa de enforcement, entonces ve CONFORME/DESVIADO por documento y qué bloquea / qué avisa / qué duerme.

## Decisiones del cliente

- 2026-07-22 — Plan aprobado en plan mode (STOP 2) con las recomendaciones escritas dentro del plan aprobado.
- 2026-07-22 — La promesa `npx` se **recorta** del README hasta que haya cuenta npm (opción recomendada dentro del plan aprobado); `npm publish` sigue en ROADMAP con `espera:cliente-cuenta-npm`.
- 2026-07-22 — Las rebanadas de UI (verdad por documento + parametrizar secciones, 12h) van al **sprint siguiente** (opción recomendada dentro del plan aprobado): la restricción del cliente es absorción y la UI merece su propio Gemba.
- 2026-07-22 — Apetito: ~17h de agente / ~2h de revisión del cliente. La decisión «qué significa 2.0» es de las gordas → ADR propio al cierre.
- 2026-07-22 — **Toda superficie del gobierno debe ser la app** (decisión del cliente, post-construcción): la linterna (`estado-gobierno.ps1` → `gobierno.html`) se **descarta como superficie** — un HTML suelto no es la app (ADR 0048). Se descableó del CI y de la evidencia del Gemba; el mapa de enforcement pasa al sprint de UI como **pantalla de la app**, y ahí se decide (con ADR) el retiro de la pieza del motor. `conformidad-docs.html` queda **interino** hasta que la app absorba la verdad por documento.
- 2026-07-22 — **Evidencia rojo→verde por escenario** (decisión del cliente): cada hallazgo de los escaneos que este sprint toca se **reproduce primero en rojo** (el defecto demostrado corriendo, con salida capturada) y se **cierra en verde** (la cura verificada corriendo), ambos registrados en `qa_runs/la-2-0-estable-20260722/LOG.md`. Los escenarios diferidos (carriles sin muro, huecos que no se curan aquí) quedan demostrados **en rojo honesto** en la matriz de carriles — sin verde fingido.
- 2026-07-22 — **La versión de salida es `v1.31.0`, no `v2.0.0`** (decisión del cliente al cierre): el corte entrega los mecanismos pero aún no merece la etiqueta «estable» — esa etiqueta la declara el cliente, no un sprint. El ADR previsto en la decisión de apertura se descartó por orden del cliente en el mismo cierre.

## Alcance (rebanadas verticales)

1. **R1 — Corte honesto (~5h)** `[toca kit/raíz → review-stop]` — `package.json` os a `["win32"]` (hoy declara darwin/linux sin evidencia, contra la propia ley del repo) · recortar la promesa `npx` del README dejando `node bin/jidoka-method.js init` como camino documentado · aviso ruidoso al final de `instalar.ps1`: «el muro server-side aún NO muerde — branch protection es manual, esto falta» · badges/claims del README a la verdad. **Pruebas:** `probar-version.ps1` + `probar-instalador.ps1` verdes; grep de `npx jidoka-method` sin coincidencias en README.
2. **R2 — Fiabilidad del motor (~6h)** `[toca barreras → review-stop]` — nuevo `tools/probar-gemelas.ps1`: falla si las copias byte-fieles divergen (`Test-Pattern` ×8, `Match-Any` ×3, `Normaliza` ×3, `Get-Secciones` ×4, parser del ROADMAP ×3 semántico, `Clase-Display` ×2 — curando la divergencia ya existente de claves) · `auditar.ps1` checa `$LASTEXITCODE` del `git diff` en `-Range` y falla cerrado (exit 2) · el salvavidas `no-borres-el-motor` de `verificar.ps1` cubre también `.claude/hooks/*.ps1`, `.claude/settings.json` y `.githooks/*`. **Pruebas:** `probar-gemelas` en CI (`andon.yml`) + `probar-auditor` con caso git-roto + self-tests existentes verdes.
3. **R3 — Superficies de absorción (~6h)** `[toca kit → review-stop]` — `conformidad-docs.html` doble-clic (espejo del `conformidad-adrs.html`, cierra el ítem del ROADMAP; **interino** hasta la pantalla de la app) · matriz de carriles de la IA (11 casos: muro/prosa/nada) como doc vivo `docs/analisis/matriz-carriles-202607.md` · ~~cablear el HTML de `estado-gobierno.ps1`~~ **descartado por decisión del cliente** (toda superficie debe ser la app; ver Decisiones) — el drift vista-vs-gate queda vigilado por `probar-gemelas.ps1` mientras la pieza exista. **Pruebas:** el HTML de conformidad como evidencia en `qa_runs/`.

## Archivos

`package.json` · `README.md` · `bin/jidoka-method.js` · `tools/instalar.ps1` · `tools/auditar.ps1` · `tools/verificar.ps1` · `tools/estado-gobierno.ps1` · nuevos `tools/probar-gemelas.ps1` y generador `conformidad-docs` · `.github/workflows/andon.yml` · `docs/analisis/matriz-carriles-202607.md` · siembra en `kit/.jidoka/` de lo que aplique · ADR nuevo «qué significa 2.0» al cierre. Áreas `kit`/`barreras` → `review-stop` exigirá `/code-review`.

## Verificación (el demo que corre el cliente) — `owner: cliente`

**Cómo lo corre (sin código ni terminal):**

1. Abres el README en GitHub: el comando de instalación funciona tal cual está escrito — ya no promete `npx` sin registro ni Mac/Linux sin evidencia.
2. Doble clic a `conformidad-docs.html` (en `qa_runs/` del sprint): ves CONFORME/DESVIADO documento por documento (interino: esta verdad se muda a la app en el sprint de UI).
3. Lees la matriz de carriles (`docs/analisis/matriz-carriles-202607.md`): sabes exactamente qué caminos de la IA tienen muro y cuáles son prosa.
5. En el PR, los checks nuevos (`probar-gemelas`, auditor fail-closed) aparecen verdes en el CI.
6. Abres `qa_runs/la-2-0-estable-20260722/LOG.md`: por cada escenario de los escaneos ves su par **rojo** (el defecto reproducido, con la salida real) y **verde** (la cura corriendo) — o su rojo honesto si quedó diferido.

> **Regla del demo tangible:** si el cliente no puede correr el demo **sin código ni terminal**, la rebanada **no es vertical** — re-rebánala hasta que entregue algo que él pueda tocar, o márcala como decisión pendiente del cliente (no la cierres con una demo de terminal que solo tú puedes correr). Nace aquí y se cierra idéntico en la entrega: es el criterio de aceptación del sprint.

## Lo que NO entra (siguientes)

- Multiplataforma real (Mac/Linux) — el repo la difiere bajo regla 2-3 (`espera:entorno-no-windows`).
- Firma Authenticode — mitigada por `sembrar-manual.ps1` probado.
- Cartones teatro de la app (reconciliar/alta-agente) — `app/` es Jidoka-only, no se siembra.
- `npm publish` — espera la cuenta npm del cliente (ítem propio del ROADMAP).
- La ola de UI: verdad por documento (`tuberia-datos` consolida los 4 ledgers) + parametrizar secciones (`-Requeridas` + ADR no-clobber de `docs-gobernados.json`) — sprint siguiente.
- Suite `probar-caminos.ps1` de simulacros off-path y permisos `allow/ask/deny` + plan mode inescapable — se deciden DESPUÉS, con la matriz de carriles en la mano (regla 2: no sobre-cablear).
- Comunidad, presentación pública.
