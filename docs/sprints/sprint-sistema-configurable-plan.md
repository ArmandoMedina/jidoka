# Plan de sprint — El sistema configurable, fase 1: de la maqueta al fierro

> **Contrato del sprint.** Archivado el 2026-07-21 por orden del cliente ("genérame el plan…
> aterriza todo… la ejecución va a ser en otro chat"). **La construcción arranca en una sesión
> nueva**, que debe ratificar el R0 con aprobación nombrada antes de la primera línea de código
> (disparo `aprobacion-nombrada`). La sección "Arranque" de abajo le dice a esa sesión qué leer.

## Contexto — por qué ahora

Dos sesiones de descubrimiento (2026-07-20/21) aterrizaron la visión: **Jidoka evoluciona de
metodología con comandos fijos a sistema de gobierno configurable con UI guiada**. El cliente la
validó con las manos sobre una maqueta clickeable de 6 iteraciones (bandeja, formulario,
regímenes/contratos, modo avanzado con contraseña-ritual + firma + candado IA, tour): *"ya es un
camino muy cercano, me encanta"* (2026-07-21). Récord completo:
[`docs/analisis/descubrimiento-sistema-configurable-202607.md`](../analisis/descubrimiento-sistema-configurable-202607.md)
+ [`docs/analisis/maqueta-tuberia-202607.html`](../analisis/maqueta-tuberia-202607.html)
(rama `descubre/sistema-configurable-20260720`). Este sprint construye la fase 1 productiva.
**La maqueta ES la spec visual; el informe ES la spec conceptual.**

## Encuadre de producto

- Línea doctrinal intacta: **la UI autora, el gate ejecuta** (ADR 0002, ADR 0044). Nada de este
  sprint convierte a la UI en muro.
- Vecino de [[AND-1-muro-andon]] y [[KIT-2-gobierno-documental]] (extiende el modelo SAP del
  KIT-2 al ritual). Nace la capacidad **CFG-1** (gobierno configurable) con los criterios de R0.
- Subsume el follow-up del ROADMAP "ligar como verbo genérico, opción (b)".

## Decisiones del cliente (con fecha; las tres primeras van a ADR en R1)

| Fecha | Decisión |
|---|---|
| 2026-07-20 | **Cambio de identidad**: Jidoka = sistema de gobierno configurable ("conectar tubería que no sea caja negra; guiar al usuario y a la IA por los caminos que nosotros determinamos; toda la maquinaria es configurable"). |
| 2026-07-21 | **Los 3 regímenes + contrato por pieza** (motor sellado / contrato SAP / libre) con el hallazgo: los comandos del ritual salen del gobierno por hash (que no distingue extensión legal de mutilación) y ganan contrato SAP. |
| 2026-07-21 | **Meta-gobierno en 3 piezas**: contraseña-ritual pública en el README (deliberación: "no le muevas si no le sabes"), firma a registro (atribución), candado IA = permissions.deny + hook PreToolUse (el único muro). "Bajo su propio riesgo" = garantía nula, nunca desviación muda. |
| 2026-07-20 | La bandeja: "si se da de alta por fuera, sale en pendiente de parametrizar". |
| 2026-07-21 | Wizard corto y formulario completo **conviven** (aviso vs alta consciente) — confirmar en el Gemba de R4. |

## R0 — El QUÉ (criterios de aceptación)

> **El usuario parametriza el gobierno de su repo desde la UI — qué se vigila, qué se lee, qué
> régimen tiene cada pieza y qué no puede tocar la IA — y todo lo que nazca por fuera cae a una
> bandeja de pendientes. Sin editar JSON a mano.**

- **Dado** que existe un archivo en un árbol auditado sin regla que lo gobierne (el hueco de
  `docs/`), **cuando** abro la bandeja, **entonces** aparece como "cubierto solo por existir" —
  el verde deja de mentir.
- **Dado** un elemento en la bandeja, **cuando** lo parametrizo desde VS Code (tipo → régimen →
  cajón → fuerza → qué comandos lo leen), **entonces** la regla queda escrita en los ledgers
  reales y el elemento sale de la cola — yo nunca abrí un JSON.
- **Dado** que marco qué comandos leen un doc, **cuando** guardo, **entonces** el `@` queda
  escrito en el comando y el detector del ritual NO lo acusa (extensión legal ≠ mutilación).
- **Dado** que alguien quita un `@` de fábrica de `arranca.md`, **cuando** corre el detector,
  **entonces** sale `DESVIADO` nombrando el invariante perdido (garantía nula) — y reconciliar
  tiene dos salidas: restaurar o aceptar con firma. La desviación muda no existe.
- **Dado** que una pieza tiene candado IA, **cuando** el agente intenta editarla (Write/Edit/Bash),
  **entonces** el hook lo deniega EN EL MOMENTO nombrando el contrato y el camino legal.
- **Dado** que reclasifico un régimen en modo avanzado, **cuando** confirmo, **entonces** queda
  firma (quién/cuándo/porqué, derivada de git config — no inventada) en el registro; sin motivo
  no hay reclasificación.

## Alcance — 6 rebanadas verticales (orden = dependencia; diseño mecánico validado contra el código real)

> Regla del plan (pedida por el cliente 2026-07-17): cada rebanada declara **qué pruebas/evidencia**
> produce. Molde de self-test: `probar-docs.ps1` (fixture temporal + Parte B contra el repo real).

### R1 — Los ADRs + la capacidad (S) — primero: es la ley de todo lo demás
- **ADR "identidad"**: metodología → sistema configurable (decisión 2026-07-20; UI autora, gate ejecuta).
- **ADR "contratos y regímenes"**: régimen efectivo = fábrica + overrides. NO se duplica la fuente
  de verdad: motor = sello (hash), SAP = ledgers por secciones/invariantes, libre = capa 3.
  `tools/contratos.json` es **INSTANCIA** (no-clobber, jamás en la lista mecánica del manifiesto —
  la mecánica converge en `-Actualizar` y pisaría datos del cliente). Registra solo overrides con
  firma: candado, reclasificación, desviación aceptada. Incluye la decisión diferida **R3b**
  (clase `contrato` en la siembra) con su porqué.
- **ADR "meta-gobierno"**: contraseña-ritual (README, deliberación) + firma (atribución) + candado
  (muro). Documenta honesto el límite del `permissions.deny` con Bash (por prefijo de comando, no
  por ruta destino → el hook es el enforcement determinista; deny = capa estática barata).
- `product/capacidades/CFG-1-gobierno-configurable.md` (estado `en_construccion` hasta el Gemba)
  con los Gherkin de R0.
- **Ley que muerde**: `decisiones` **BLOQUEA** — cada ADR con su índice en el mismo commit.
- **Evidencia**: `auditar.ps1` verde (wikilinks + Gherkin de CFG-1). **Demo cliente**: leer los 3
  ADRs en el PR.

### R2 — La bandeja (M) — `tools/bandeja.ps1` + `tools/probar-bandeja.ps1`
- Script APARTE (no un modo de la linterna: la linterna es mapa, la bandeja es COLA; y
  `estado-gobierno.ps1` es pieza sellada de 852 líneas — no se engorda). Duplicación byte-fiel de
  `Test-Pattern`/enumeración git/`Get-Cobertura` (patrón de la casa) con UNA diferencia deliberada:
  los `arbolesAuditados` (`estado-gobierno.ps1:132`) **NO cuentan como parametrizados** — cura el
  hueco de `docs/` sin tocar la linterna ni su conteo en los hijos.
- Cola v1: (a) huérfano puro, (b) "cubierto solo por existir", (c) doc capa-2 DESVIADO. (d) ligas
  rotas y DIVERGE del motor: fase posterior (regla 2-3). Resta lo firmado en `contratos.json`
  (ausente → cola completa); lo aceptado sale de cola con badge. Exit 0 siempre (cola, no muro);
  exit 2 si no-git (falla cerrada).
- Salida: consola + `-Salida` HTML de tabla simple (here-string `@'...'@` + `.Replace` de payload,
  UTF-8 sin BOM). Estrena `contratos.json` como **lector**.
- Manifiesto: `bandeja.ps1` + `probar-bandeja.ps1` como mecánica sembrada; humo en `andon.yml`.
- **Pruebas** (probar-bandeja): huérfano → en cola · `docs/` sin regla → "cubierto solo por
  existir" · DESVIADO → en cola · con contrato → fuera · firmado → fuera con badge · no-git →
  exit 2 · Parte B: cola del repo real corre. **Demo cliente**: doble clic al HTML — ver el caso
  REAL (`docs/analisis/costo-neto-sgi-202607.md`) confesado en la cola.

### R3 — Contrato SAP del ritual (M) — `tools/ritual-gobernado.json` + `tools/estado-ritual.ps1`
- Ledger APARTE (no extender `docs-gobernados.json`: extracción distinta —`@`/`!` por regex fuera
  de fences vs `## `— y ese ledger es mecánica-que-converge). Por comando: `arrobas_requeridas` +
  `estricto:false`. `gemba.md` se declara con `[]` explícito — el "no inyecta nada" deja de ser
  ambiguo. Detector calca `estado-docs.ps1` entero (CONFORME/DESVIADO, "garantía nula", aviso
  local, `-Estricto` muro opt-in; paso CI calcando el step de estado-docs).
- **Aditiva = OK** (el corazón): un `@` extra del cliente es CONFORME; quitar uno de fábrica es
  DESVIADO nombrándolo. Marcador de inserción estándar en los comandos (comentario HTML) para que
  R4 inserte determinista.
- **Trampa heredada, confesada**: el sello por hash seguirá marcando `DIVERGE` en hijos que
  agreguen `@` legales — la cura completa es la clase `contrato` en `instalar.ps1`/`sembrar-manual.ps1`
  (**R3b, DIFERIDA** con ADR: sembrar-manual es AV-frágil por diseño). En fase 1 el mensaje del
  detector explica cuál manda.
- **Pruebas** (probar-ritual): fábrica → CONFORME · sin un `@` requerido → DESVIADO nombrándolo ·
  `@` extra → CONFORME · `@` en fence no cuenta · `-Estricto` → exit 1 solo estrictos · Parte B:
  ledger real ↔ comandos reales. **Demo cliente**: quitarle el `@PRODUCT_BRIEF` a su arranca →
  siguiente `/jidoka:arranca` lo confiesa DESVIADO; restaurarlo → CONFORME.

### R5 — El candado IA (S/M) — `.claude/hooks/candado-pretooluse.ps1` (antes que R4: solo necesita el esquema de contratos.json)
- Calca `no-memorias-pretooluse.ps1` línea por línea: stdin JSON, falla-ABIERTA (exit 0) si no
  parsea o si `contratos.json` no existe (crítico: el hook viaja a hijos sin ledger), deny vía
  `hookSpecificOutput.permissionDecision='deny'` con razón que nombra el contrato y el camino
  legal ("quitarlo = modo avanzado con firma"). Write/Edit por ruta (normalizar `\`→`/`,
  case-insensitive, raíz con espacio); Bash con la misma heurística confesada del existente
  (límite de aliases documentado en `andon/README.md`).
- `settings.json`: segunda entrada PreToolUse (mismo formato) + denies estáticos de motor en
  `permissions` SOLO si la sintaxis se verifica contra la doc vigente al implementar; los denies
  del cliente van a `settings.local.json`, nunca al sembrado. El disparo `deny-vs-ask` pasa de
  catálogo-solo a **cableado** (actualizar su ficha + probar-disparos).
- **Pruebas** (extender probar-hooks): Write a pieza con candado → deny con razón · sin candado →
  silencio · ledger ausente → exit 0 (caso hijo) · Bash `Set-Content` a la ruta → deny · `2>&1`
  no dispara falso positivo · ledger podrido → permite (falla-abierta, documentada). **Demo
  cliente**: pedirle al agente en el chat "edita tal archivo" → verlo rebotar con la razón.

### R4 — El formulario en la extensión (L) — consume R2+R3
- Patrón real de la casa: **cascada de QuickPicks + módulo JS puro** (calca `ligarCapacidad` →
  `ligas.upsert`), NO webview-formulario. Nuevos: `extension/contratos.js` (ledger contratos +
  escritores de `blast-radius.json` —respetando su forma: array raíz— y `docs-gobernados.json`) y
  `extension/ritual.js` (insertar `@` en el marcador de R3; jamás regex-replace del cuerpo), con
  `*.test.js` (node --test, como `ligas.test.js`).
- Comando `jidoka.parametrizar` (clic derecho + paleta): tipo (del catálogo de templates) →
  régimen (**solo sap|libre — "motor" jamás se ofrece**) → cajón (áreas reales de la ley; opción
  "cajón nuevo") → fuerza (avisa/bloquea) → comandos que lo leen (canPickMany del ledger R3) →
  **confirmación antes de escribir** (el OK del cliente). + `jidoka.verBandeja` (webview del HTML
  de R2, calca verGobierno). Reusa `rutaRelativa` y `refrescarGobierno` existentes.
- Encoding cross-stack: todo lo que escribe JS = UTF-8 sin BOM + `\n` final (calcar el caso A4 de
  probar-ligas para contratos.json).
- **Pruebas**: `probar-extension.ps1` caza declarado↔registrado gratis · node --test de los 2
  módulos · caso cross-stack JS→PS. **Demo cliente (el Gemba central del sprint)**: crear
  `docs/glosario-del-dominio.md` → aparece en la bandeja → clic derecho → contestar los QuickPicks
  → ver el `@` en su arranca, la regla en la ley y la bandeja limpia. Sin JSON, sin terminal.

### R6 — El modo avanzado (M) — reusa contratos.js y la bandeja
- Comando `jidoka.reclasificar` (o `modoAvanzado`): pieza (leyendo ledgers directo en JS, no
  parseando texto) → acción (aceptar desviación / candado on-off / reclasificar sap↔libre; "motor"
  no se ofrece) → **motivo obligatorio** (`showInputBox` no vacío) → **firma = `git config
  user.name/email` + fecha ISO** (determinista, no inventada) → confirmación modal → escribe
  `contratos.json`. La contraseña-ritual del README aplica al flujo según el ADR de R1 (en VS Code
  el humano ya es humano — la extensión corre fuera del LLM; la contraseña se pide como
  confirmación tipeada del disclaimer, patrón "escribe el nombre del repo").
- La bandeja (R2) ya resta y pinta badges de lo firmado. Los detectores aprenden `ACEPTADO(badge)`
  en fase posterior — no aquí.
- **Pruebas**: contratos.test.js (firma incompleta → throw; upsert no duplica) + caso badge en
  probar-bandeja. **Demo cliente**: aceptar con firma la desviación de un doc → sale de la cola
  con badge y su nombre.

## Cableado transversal (muerde en cada rebanada — no dejarlo para el final)

- `andon/README.md` (doc_avisa de `barreras`) se actualiza con cada gate/detector nuevo.
- `CHANGELOG.md` por rebanada; SSOT a **v1.26.0** al cierre (MINOR aditivo). Corte opcional de
  release tras R3 si el cliente quiere bajar temprano.
- Atlas: diagrama nuevo del flujo parametrizar + bandeja (área `atlas` avisa; `npm run atlas:render`).
- `review-stop` va a exigir code-review (barreras/kit/extension tienen `revisa:true`) — planear el
  `/code-review` por rebanada, no al final. `probar-instalador` solo se valida en CI (AV local).
- Evidencia del sprint: `qa_runs/sistema-configurable-<fecha>/LOG.md` (el listón; se llena por
  rebanada, no al cierre).

## Lo que NO entra (frontera explícita)

- **Prohibiciones** ("esto no se conecta con esto") — mecánica nueva; diseño + ADR propios cuando
  la fase 1 esté en uso real (regla 2-3). Dos de sus tres variantes ya quedan cubiertas por R5.
- **R3b**: clase `contrato` en la siembra (instalar/sembrar-manual) — ADR propio, ventana con
  re-prueba AV.
- **El tour productivo** — la maqueta queda como spec/onboarding del cartón; no se porta.
- **Wizard corto vs formulario**: conviven como hipótesis; se decide con el Gemba de R4, no aquí.
- **Bajada a labs** de la fase 1 — hasta que el Gemba del cliente pase en la nave.
- Ver agentes/modelos/hooks como piezas parametrizables desde la UI (el "toda la maquinaria") —
  fase 2 de la visión; esta fase 1 cubre documentos + ritual + candados + regímenes.

## Arranque en el chat nuevo (instrucciones para esa sesión)

1. `/jidoka:arranca` normal. Rama nueva `sprint/sistema-configurable-<fecha>` desde `main`
   **después de mergear** la rama `descubre/sistema-configurable-20260720` (PR pendiente de orden
   nombrada — este plan viaja en ella).
2. **Ratificar R0 con el cliente** (aprobación nombrada) antes de la primera línea de código.
3. Leer: este plan + el informe del descubrimiento + la maqueta (abrirla, correr el tour normal y
   el root — es la spec visual).
4. Construir en el orden **R1 → R2 → R3 → R5 → R4 → R6**, cada rebanada verde y commiteada sola.
5. La rama del spike `spike/linterna-capas-enforcement-20260720` NO se toca (decisión de poda
   pendiente del cliente, aparte).

## Verificación final — el demo que corre el cliente (owner: cliente, sin código ni terminal)

El flujo del glosario, end-to-end, en VS Code: crear `docs/glosario-del-dominio.md` → comando
"ver la bandeja" lo muestra pendiente → clic derecho → "Jidoka: parametrizar…" → 5 QuickPicks →
confirmar → la bandeja queda limpia, el `@` está en su arranca, la regla en su ley — y al pedirle
al agente que edite una pieza con candado, el agente rebota nombrando el contrato. Evidencia:
`qa_runs/sistema-configurable-<fecha>/LOG.md` con la corrida.
