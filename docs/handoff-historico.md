# HANDOFF histórico — el archivo muerto del relevo

> **Este archivo NO se inyecta al abrir sesión** (a diferencia de `HANDOFF.md`, que `/jidoka:arranca` inyecta entero). Es el archivo de secciones cerradas del relevo: cuando `HANDOFF.md` excede su contrato (ver `tools/flujo.json` y el check `[contrato-handoff]` de `tools/verificar.ps1`), las secciones viejas se mueven aquí ÍNTEGRAS, más nuevas arriba. Se consulta solo cuando se busca arqueología; el estado vigente vive en `HANDOFF.md`, el porqué de las decisiones en `docs/decisions/`, la historia por versión en `CHANGELOG.md`.

---

## Archivado 2026-07-23 (cierre del sprint 28: la histórica de la huella en un lab sale del relevo)

### Dónde estuvimos (2026-07-23 — exploración: la huella de Jidoka en un lab · SIN sprint · `v1.32.0` liberada)

**Primera vuelta de la kata (cap. 08) corrida de verdad.** Pregunta: ¿el estorbo de Jidoka en un repo ajeno es colisión estructural o ruido visual? **Respuesta medida: estructural, y aislable sin apagar el muro.** Expediente: [`exploracion-huella-en-labs-202607.md`](docs/analisis/exploracion-huella-en-labs-202607.md). Molde nuevo `kit/.jidoka/templates/exploracion.md` (n=1, fuera del ledger). Hallazgos colaterales: los 4 Stop hooks dejan cerrar sin la ley, y `review-stop` suma tres defectos medidos al usarlo — ambos curados por el sprint 28.

---

## Archivado 2026-07-23 (cierre de la exploración de la huella: la histórica del sprint 25 sale del relevo)

### Dónde estuvimos (2026-07-22 — Sprint 25 + consolidación · MERGEADOS, `v1.30.0`, PR #126)

**El molde único de sprints/`qa_runs` (ADR 0056) y la consolidación `v1.29.0` llegaron a `main` en el PR #126**; los 2 Gembas (`flu-1`, `molde-sprints-qa`) aceptados con nombre el 2026-07-22 en `flujo.json`. Récord: [`sprint-25-molde-sprints-qa-entrega.md`](sprints/sprint-25-molde-sprints-qa-entrega.md). Nota: `qa_runs/` ya no versiona el bulto — lo citado se agrega con `git add -f` (regla en `.gitignore`/`qa_runs/README.md`).

---

## Archivado 2026-07-22 (cierre del sprint 26: la histórica de FLU-1 sale del relevo)

### Dónde estuvimos (2026-07-22 — «El pilar de flujo» FLU-1 · MERGEADO, `v1.28.0`, PR #122)

**FLU-1 (el pilar JIT) en `main`** (ADR 0049): contratos con gate de HANDOFF/ROADMAP/CHANGELOG, expiración a `MUERTOS.md`, límite WIP, vista `estado-flujo`. Plan: [`sprint-22-pilar-de-flujo-plan.md`](sprints/sprint-22-pilar-de-flujo-plan.md). **Kaizen vigente:** ante «voy más lento que tú», el agente se detiene — el ritmo lo marca quien absorbe.

---

## Archivado 2026-07-22 (apertura del sprint 26: la histórica de la app de la tubería sale del relevo)

### Dónde estuvimos (2026-07-21 — «La app de la tubería» · MERGEADO Y LIBERADO `v1.27.0`, PR #121)

**El sprint "La app de la tubería" TERMINÓ (7/7)**, mergeado y liberado el 2026-07-22 con orden nombrada. La superficie del gobierno es ahora una **app de escritorio Tauri fiel a la maqueta** (ADR 0048); la extensión VS Code se retiró (`v1.26.0` subsumida, PR #120). Récord: [`sprint-21-app-tuberia-entrega.md`](sprints/sprint-21-app-tuberia-entrega.md). **[PENDIENTE del cliente] Gemba end-to-end** (la fidelidad de R2 ya la aprobó; el flujo completo no). Pendientes técnicos (nada bloquea): cert Authenticode del `.exe`, autoría de ligas en la app, atlas de los tools nuevos, multiplataforma del motor (fase 2). [Nota del archivado: el Gemba end-to-end y los pendientes siguen clasificados en el ROADMAP.]

---

## Archivado 2026-07-21 (merge con main PR #119: la sección original del descubrimiento + la histórica de la linterna)

### Dónde estamos (2026-07-21 — El descubrimiento del sistema configurable CERRADO · rama `descubre/sistema-configurable-20260720` SIN MERGEAR, 8 commits) [nota del merge: la rama SÍ se mergeó — PR #119]

**El descubrimiento quedó completo y durable en la rama; la sesión cerró con cuadro** ([`docs/sprints/cierre-20260721.md`](../sprints/cierre-20260721.md)). La visión: **Jidoka evoluciona de metodología a sistema de gobierno configurable con UI guiada** (la UI autora, el gate ejecuta — ADRs 0002/0044 intactos). Los artefactos, en orden de lectura para la sesión de construcción:

1. **El plan-contrato del sprint** [`docs/sprints/sprint-20-sistema-configurable-plan.md`](../sprints/sprint-20-sistema-configurable-plan.md) — R0 con Gherkin + 6 rebanadas en orden de dependencia (R1 ADRs+CFG-1 · R2 bandeja · R3 contrato SAP del ritual · R5 candado IA · R4 formulario · R6 modo avanzado), pruebas y demo del cliente por rebanada, diseño mecánico validado contra el código real y **3 trampas confesadas** (la mecánica converge en `-Actualizar` → `contratos.json` es INSTANCIA; el sello seguirá acusando `DIVERGE` hasta la clase `contrato` — R3b diferida; el `deny` de Bash es por prefijo → el hook es el muro). Trae su propia sección "Arranque en el chat nuevo".
2. **El informe de la visión** [`docs/analisis/descubrimiento-sistema-configurable-202607.md`](../analisis/descubrimiento-sistema-configurable-202607.md) — la spec conceptual: 5 relaciones de "ligar" (incluidas lectura `@` y prohibición), 3 regímenes por pieza (y el hallazgo "los comandos están en el cajón equivocado"), bandeja, formulario, meta-gobierno, hallazgos del censo (`permissions` VACÍO con `deny-vs-ask` catálogo-solo, PreToolUse subutilizado, hueco de `docs/`, `gemba.md` sin `@`).
3. **La maqueta clickeable** [`docs/analisis/maqueta-tuberia-202607.html`](../analisis/maqueta-tuberia-202607.html) — la spec visual, validada en **6 Gembas vivos** del cliente (2 hallazgos suyos, curados en caliente): tubería de 54 piezas con regímenes, bandeja (1 caso REAL), formulario, reconciliar, modo avanzado (contraseña-ritual `GARANTIA-NULA` + firma + candado IA) y tour de 14/19 paradas que abre los pop-ups por dentro. **Correr ambos tours ES el onboarding de la sesión de construcción.**
4. **El spike del modo "Capas" RECHAZADO en Gemba** (*"la verdad es que no"*) — rama `spike/linterna-capas-enforcement-20260720` (`fa3a8c3`), aparcada sin mergear. Lección: el cliente no quiere mapas del todo — quiere guía en el momento concreto.
5. **Nota de trato:** leer ÍNTEGRO el transcript anterior (jsonl) funcionó cuando el cliente se sintió mal entendido — repetir la técnica si recurre. **Los menús de opciones abstractas lo pierden; los artefactos concretos clickeables lo destraban.**

**Pendiente (cliente — nada bloquea al agente):** 1. PR + merge de la rama `descubre/…` [HECHO: PR #119] · 2. Sesión nueva de construcción: `/jidoka:arranca` → ratificar R0 con aprobación nombrada → rama `sprint/sistema-configurable-<fecha>` desde `main` → R1→R6 · 3. Destino de la rama del spike (podar o conservar aparcada) · 4. ¿Issues del lazo para los hallazgos del censo? (batch, no goteo). [Todos clasificados en el ROADMAP al mergear.]

### Dónde estuvimos (2026-07-19 — La linterna del gobierno · `v1.24.0` · mergeada, PR #114)

`tools/estado-gobierno.ps1`: vista de solo lectura del grafo del gobierno (`.html` autocontenido, huérfanos en rojo, falla cerrado; es vista, NO gate — ADR 0043). Detalle completo en el CHANGELOG `[1.24.0]` y abajo en este histórico. Pendientes vivos al archivarse: el **tag+release de `v1.24.0` no se cortó** (quedó subsumido: la orden nombrada de `v1.25.0` cubrió el corte); los 2 avisos de `verificar` anotados (¿diagrama del atlas y nota de capacidad para la linterna?) → clasificados en el ROADMAP (Algún día, espera:cliente).

## Archivado 2026-07-21 (migración inicial del contrato del HANDOFF, sprint FLU-1)

## Dónde estamos (2026-07-21 — **el Gemba de la gestión del flujo** · sesión de diagnóstico, nada construido)

**Sesión de diagnóstico pedida por el cliente, sin código.** El dolor reportado: *«el roadmap y el handoff son un desmadre; todos los temas están siempre abiertos; la IA no se puede centrar; no tengo sensación de avance; no tengo a la vista lo que hay que hacer»* — más *«echo de menos el casting personalizado, las IAs no tienen personalidades ni enfoques»*.

**Se midió, no se opinó.** Informe completo: **[`docs/analisis/gemba-gestion-del-flujo-202607.md`](docs/analisis/gemba-gestion-del-flujo-202607.md)** — 274 MB de transcripciones del lab destilados a 684 mensajes del cliente + forense con números de los dos repos.

**El hallazgo que ordena a los demás:** el método define «hecho» = *lo viste funcionar*, y **los últimos 3 sprints del lab salieron a `main` sin que el cliente los viera** (su HANDOFF tiene una sección literal `🚨 COLA DE GEMBAS VENCIDOS`, 6 sprints, 13 pasos de aceptación sin correr). No falta sensación de avance: **por la propia definición del método, nada está hecho.**

**La tesis, ya verificada:** la Casa del TPS tiene dos pilares — Jidoka (parar ante el defecto) y **Just-In-Time (el flujo)**. Este método construyó el derecho con dientes; **el izquierdo no existe**. **Benchmark completo (4/4 frentes, con fuentes): [`docs/analisis/benchmark-flujo-202607.md`](docs/analisis/benchmark-flujo-202607.md).** Confirmado — con tres correcciones que importan más que la confirmación:

1. **«El wey que organiza a la raza» no existe en Toyota.** Ningún rol humano gestiona el flujo caso por caso: lo hacen el takt, la caja heijunka y el kanban. Los humanos responden excepciones y mejoran el estándar. **No falta un PM: faltan las reglas.** (Y en Scrum el SM tampoco decide alcance ni prioridad — eso es del Product Owner, que aquí ya es el cliente.)
2. **El apetito se mide en horas de revisión HUMANA**, no de agente: la restricción del sistema es aceptar, no producir. Todo lo demás se subordina a ese número (paso 3 de Goldratt).
3. **Que la IA vaya «miles de pasos por delante» es SOBREPRODUCCIÓN** — la peor de las 7 mudas según Ohno. En TPS, la estación que va más rápido que el takt **se frena**. No es una fortaleza sin explotar: es un defecto con nombre desde los años 50.

**Qué hacer cuando se retome (una cosa, no cinco):**
1. Leer los dos informes — el diagnóstico y el benchmark. Única lectura obligatoria.
2. Contestar las **3 decisiones abiertas** del diagnóstico: el **apetito** (ahora se sabe en qué unidad: horas de revisión del cliente), **orden vs paralelo** (hay objeción registrada al «todo a la vez»), y **la coordinación de escritores** (3 frentes en paralelo + una rama del socio sin subir).
3. Con eso: `/jidoka:planea` con el QUÉ para aprobación formal. **Las 5 piezas están en el informe; ninguna se poda del alcance.**

**Advertencia que atraviesa los 4 frentes:** ninguna de estas piezas funciona como acuerdo. Kanban depende de presión social que con agentes no existe; Shape Up fue abandonado por dos equipos humanos que aflojaron el apetito; Scrum se gamea relajando la DoD. **Todo tiene que ser código que rechaza la acción** — el benchmark llegó por cuatro caminos ajenos a la tesis que este repo ya tenía escrita.

**Nada se construyó y nada se commiteó.** El working tree trae 4 archivos sin commitear: este HANDOFF, los dos informes y el índice de `docs/analisis/`. La rama y el commit los decide el cliente (regla: nunca directo a `main`).

> **Kaizen de la sesión — el agente confundió «bájame la carga» con «terminamos».** El cliente dijo *«no te voy a poder seguir el ritmo»* y el agente lo interpretó como fin de sesión y se puso a cerrar. Corrección del cliente: *«nada de que seguimos mañana»* — lo que pedía era **delegar el ritmo, no detener el trabajo**: menos lectura para él, no menos avance. Es exactamente el síntoma que el informe describe (takt), ocurriendo dentro de la sesión que lo describe, y con un modo de falla nuevo que vale registrar: **ante la señal «voy más lento que tú», el agente por defecto se detiene en vez de absorber más trabajo.** El ritmo lo marca quien absorbe; el volumen de trabajo, no.

---

## Dónde estuvimos (2026-07-20 — El editor del gobierno, parte 2 · **`v1.25.0` CERRADO Y LIBERADO** · PR #115)

**Sprint "El editor del gobierno, parte 2" (R2–R4) TERMINADO, mergeado y liberado** con la orden nombrada del cliente (*"pr, marge, versión y poda autorizado"*). Récord completo: [`docs/sprints/sprint-19-editor-gobierno-2-entrega.md`](docs/sprints/sprint-19-editor-gobierno-2-entrega.md) (con el cuadro de cierre). En una línea: **el gate granular código↔capacidad** (`ligas.json` + `estado-ligas.ps1`, CI desde la base, nombra la capacidad exacta) + **la extensión que lo autora** (clic derecho → "ligar código a capacidad...") + **la linterna con 4 modos legibles** (flechas, anillo rojo del bloqueo duro, tabla del gobierno, treemap Reparto — rework de **2 Gembas del cliente**: 8 hallazgos de uso real + nomenclatura, todos curados en la rama antes del merge) + `.vsix` + ADR 0044. `v1.24.0` quedó **sin tag propio a propósito** (subsumida en `v1.25.0`).

**Evidencia:** `qa_runs/editor-r2r4-20260720/LOG.md` (committeada) · suite completa 14/14 + auditar · `probar-linterna` 58/58 · 2 code-reviews adversariales (el 2º cazó el anillo invisible que la suite verde no vio) · CI verde en cada push · la liga dogfood mordió 2× nombrando AND-1.

**Pendientes (nada bloquea al agente):**
1. **Bajar `v1.25.0` a los labs** con `-Actualizar` — entisoft gana `estado-ligas.ps1` + la linterna nueva (la extensión es Jidoka-only; la mecánica sí baja). Ahí el cliente podría por fin correr la linterna sobre entisoft desde VS Code.
2. **Decisión del cliente — ¿estrechar el área `raiz`?** Con `fuente: "*"` como cajón, "cero huérfanos" mide *"nada se escapó"*, no *"todo tiene lugar pensado"*. El **modo Reparto** (treemap) es el instrumento para decidirlo con ojos. Decisión de ley: solo el cliente.
3. **Opción (b) de nomenclatura** ("ligar" genérico de las 3 relaciones: blast-radius, wikilinks, ligas) — en ROADMAP, regla 2-3; la (a) ya se aplicó (comando estrechado).
4. **Gemba visual de entisoft** (`gobierno-entisoft.html`, 15 huérfanos) — sigue esperando ojos del cliente; mejor aún tras la bajada del punto 1.
5. Deuda anotada de reviews: `Out-File -Encoding ascii` en steps desde-la-base · conteo del reparto case-insensitive (B2).

---

### El relevo original del sprint (2026-07-19, actualizado por el cierre de arriba)

**El QUÉ aprobado:** *el usuario declara, desde una interfaz visual, qué código sostiene qué capacidad — y con qué fuerza y en qué dirección se vigila esa relación — sin editar JSON a mano.* Nace de dos hallazgos al usar la linterna sobre entisoft: el grafo se satura (132 objetos) y **el gobierno es demasiado grueso** (el área `codigo` avisa sobre las **89** capacidades sin decir cuál). La línea doctrinal: **la extensión AUTORA, el gate EJECUTA** (ADR 0002 intacto; la UI nunca es el muro).

**R1 — CONSTRUIDO Y VERDE (commit en la rama):**
1. **Los 3 modos** en `tools/estado-gobierno.ps1`: **Foco** (default; solo áreas+gates, clic en un área despliega su telaraña), **Agrupado** (las capas numerosas colapsan en un nodo; clic para abrir), **Clusters** (cada área en su cúmulo). Las capas ruidosas (`capability`, `check`) nacen apagadas.
2. **`extension/`** — extensión de VS Code en **JS plano sin build step** (molde del atlas: cero deps de runtime), comando **"Jidoka: ver el gobierno"** que corre el `.ps1` y muestra su HTML en un webview. **Jidoka-only** (no se siembra). `.vscode/launch.json` para que F5 la arranque.
3. **`tools/probar-extension.ps1`** — el lint que hace de compilador barato (sin build no hay quien cace un comando declarado que nadie registra) y que vuelve **invariante** la decisión "no se siembra": si alguien mete `extension/` al manifiesto, el test lo caza.
4. **Área `extension` en la ley** — la propia linterna la marcó huérfana al crearla (dogfooding) → gobernada → cero huérfanos.

**Evidencia (verde, esta máquina 2026-07-19):** `probar-linterna` 42/42 · `probar-extension` 9/9 · `probar-hooks` 32/32 · `probar-gate` 14/14 · `probar-auditor` 7/7 · suite completa del preflight. Dos mordidas reales en vivo: el **poka-yoke de `probar-publicar`** cazó que `probar-extension` faltaba en el preflight (ROJO→VERDE), y **la linterna se cazó a sí misma** con `extension/` huérfano.

**~~PENDIENTE CRÍTICO — el Gemba de R1~~ ✅ ATENDIDO 2026-07-20:** el cliente corrió F5 y el stack quedó demostrado (ver "Dónde estamos" arriba; evidencia en `qa_runs/editor-r1-gemba-20260720/LOG.md`). Hueco declarado: el caso real (entisoft) NO se probó desde la extensión — entisoft no tiene el motor `v1.24.0` todavía (la bajada a los labs sigue pendiente).

**~~R2–R4 NO construidos~~ ✅ CONSTRUIDOS el 2026-07-20** en el sprint "parte 2" (ver "Dónde estamos" arriba): R2 = ledger + `estado-ligas.ps1` + gate desde la base; R3 = la extensión autora; R4 = `.vsix` + ADR 0044 + SSOT `1.25.0`.

---

## Dónde estuvimos (2026-07-19 — La linterna del gobierno · `v1.24.0` — ✅ MERGEADO A MAIN el 2026-07-20, PR #114)

**Sprint "La linterna del gobierno" construido en la rama `sprint/linterna-gobierno-20260719` (ADR 0043, `v1.24.0`; mergeado a `main` el 2026-07-20 con orden nombrada — falta solo el tag+release, ver la decisión pendiente arriba).** Nace de `/jidoka:descubre` + plan mode con el cliente: entra a proyectos avanzados, mete Jidoka, y su Claude Code se pone necio con "documentos sin trackear/blast-radius"; el parche era pedirle al agente que lo arreglara, quedando **juez y parte** ("no sé qué hace, horas revisando, él me explica"). La linterna le devuelve el juicio: **ver la máquina con sus ojos, no con la narración del agente.**

**Qué se construyó:** `tools/estado-gobierno.ps1` (nuevo, mecánica) — **vista de solo lectura** que deriva el grafo del gobierno de la ley real (`blast-radius.json` + `docs-gobernados.json` + `settings.json` + `andon.yml` + `product/capacidades`) y lo emite a un **`.html` autocontenido** (force-directed, JS vanilla inline; cero deps/servidor). Muestra áreas, gates vivo/dormido, **documentos-dueño** (aristas duras `doc_bloquea` vs blandas `doc_avisa`), capacidades + wikilinks, hooks, checks de CI, y **huérfanos en rojo** con contador (métrica: cero huérfanos). No inventa verdad (matcher/reglas byte-fieles a `verificar`/`rutear`/`estado-docs`), **falla cerrado** si el repo no es git. `tools/probar-linterna.ps1` (27/27). **Es vista, NO gate** (ADR 0043, respeta ADR 0002; nace aviso por regla 2-3). Cableado: manifiesto (siembra mecánica), preflight `publicar.ps1` + CI `andon.yml`, andon/README, CHANGELOG, SSOT bumpeado a 1.24.0.

**Evidencia (verde, esta máquina 2026-07-19):** suite completa `publicar -SoloVerificar` **12/12 + auditar** (probar-linterna incluido; probar-instalador/sembrar corrieron sin cuarentena AV) · `verificar` exit 0 (2 avisos no bloqueantes) · `auditar` íntegro · `probar-version`/`probar-publicar` verdes (el poka-yoke confirmó probar-linterna en el preflight). **Code-review independiente:** R1 revisado (3 ALTO + 2 MEDIO cazados y arreglados con regresión); R2 en revisión al cierre de esta nota.

**Demos generados (`.jidoka/`, gitignoreado):** `gobierno.html` (jidoka, 0 huérfanos), `gobierno-entisoft.html` (entisoft, 15 huérfanos reales: capa `deploy/`, capa `portal/` — leído solo-lectura, sin tocar su árbol).

**Pendientes / follow-ups:**
1. **Gemba del cliente — PARCIALMENTE ATENDIDO 2026-07-20:** el grafo de **jidoka** el cliente lo vio corriendo la extensión (F5); el de **entisoft** (`gobierno-entisoft.html`, 15 huérfanos) sigue **PENDIENTE** de sus ojos.
2. **~~Merge~~ ✅ HECHO (PR #114, 2026-07-20) · Release `v1.24.0`:** tag + GitHub release esperan orden nombrada (ver decisión pendiente arriba).
3. **Dos avisos de `verificar` anotados (decisión del cliente):** ¿la linterna merece (a) su propio diagrama en `docs/atlas/` y (b) una nota de capacidad en `product/capacidades/`? Ambos "considera", no bloquean.
4. **Follow-up de deuda (ADR 0043):** consolidar la regla vivo/dormido y el grafo de capacidades (hoy réplicas byte-fieles en la linterna) en `rutear.ps1 -Json` / `auditar.ps1 -Grafo` — regla 2-3.
5. **Bajar `v1.24.0` a los labs** con `-Actualizar` (la linterna se siembra: `clase mecanica`).

**Coordinación:** el lab "enti" (`C:\Repositorios\entisoft-rescate`) lo trabaja **otro agente**; esta sesión solo lo LEYÓ para generar su linterna (escribió el `.html` en el `.jidoka/` de la nave, no en el árbol de enti — verificado `git status` limpio en enti).

---

## Dónde estuvimos (2026-07-17 — Documentos gobernados · KIT-2 · `v1.23.0` — ✅ MERGEADO Y LIBERADO)

**Sprint "Documentos gobernados" cerrado, mergeado y liberado (`v1.23.0`, ADR 0042).** El **hermano estructural del sello**: el motor se gobierna por hash; los documentos **instancia-de-template** que el ritual inyecta con `@` (`brief`/`infra`/`CONTRIBUTING`) por **secciones** (modelo SAP del cliente — alterar la estructura gobernada = *garantía nula*). Nació de que el cliente sintió "los docs de los hijos están super diferentes"; la medición desmintió la premisa (el ritual NO diverge, es motor por-hash) y encontró el hueco real: los docs de instancia sin gobierno de estructura, con `CONTRIBUTING` como el peor caso (un stub de 4 líneas sin template). Piezas: `tools/docs-gobernados.json` (ledger capa-1/2/3 + secciones requeridas congeladas), `tools/estado-docs.ps1` (detector — **aviso** en `/jidoka:arranca`, **muro opt-in** `-Estricto` en CI apagado por defecto), template real de `CONTRIBUTING`. Contrato+récord: `docs/sprints/sprint-documentos-gobernados-{plan,entrega}.md`. Evidencia: `qa_runs/documentos-gobernados-20260717/LOG.md` (suite verde + demos + caso enti confirmado con máquina).

**La rama del sprint subsumió el preflight `!` de la 1.21.1** (que nunca se tagueó): su fix viaja en `v1.23.0`. La 1.21.1 ya no queda suelta.

**Pendientes / follow-ups (nada bloquea al agente):**
1. **Gemba del cliente (owner: cliente) — PENDIENTE:** sembrar un hijo-fixture desechable, destripar su `CONTRIBUTING.md`, correr `/jidoka:arranca` → ver `[DESVIADO] CONTRIBUTING.md -- falta(n): El flujo`. Sin código ni terminal. (enti NO se usa: lo trabaja otro agente.)
2. **El muro CI lee el ledger del PR, no de la base** (a diferencia del blast-radius, ADR 0003): un PR podría flipear `estricto:true→false` en el mismo PR para pasar. Mitigado (opt-in, config de instancia del cliente, no la ley compartida). Endurecer a lectura-desde-base si madura (regla 2-3). Hallazgo del `/code-review`.
3. **El atlas `10-arranca` no refleja** el sub-paso de conformidad estructural ni `estado-docs.ps1` (aviso `atlas` aceptado — pulido visual, terreno del cliente).
4. **Bajar KIT-2 a los labs** con `-Actualizar` (siembra ledger/detector/test + el template de CONTRIBUTING; migra el stub de CONTRIBUTING). Nota: los hijos con un CONTRIBUTING viejo verán **aviso** (no muro) — el nudge honesto.
5. **Colisión de versión con #108 — RESUELTA:** `main` se movió durante la sesión (#108 `gate-anti-pii` y #109 privacidad ya mergeados, **`v1.22.0` tagueada**). Este sprint rebasó sobre el main nuevo y **rebumpó a `v1.23.0`**; el ADR 0042 no colisiona (main llega a 0041). El merge reconció `andon.yml`/`publicar.ps1`/CHANGELOG/etc. conservando ambos gates (anti-pii + docs).

**Coordinación:** el lab de rescate ("enti", `C:\Repositorios\entisoft-rescate`) lo trabaja **otro agente** — esta sesión entró **solo-lectura** (medición del drift), sin tocar su working tree.

---

## Dónde estuvimos (2026-07-17 tarde — El ritual determinista · PR #103 · `v1.21.0` — ✅ MERGEADO Y LIBERADO)
## Dónde estamos (2026-07-17 noche — privacidad del repo público · **v1.22.0 LIBERADO**)

Sesión de soporte pedida por el cliente ("¿por qué hay info personal mía en el repo si es público?"). Verificado con evidencia y atendido de raíz:

1. **Fuga limpiada (PR #107, mergeado):** el nombre de la cuenta gh **secundaria** del autor estaba en `product/infra.md` y `HANDOFF.md` (violaba la "Frontera de confidencialidad" del `CONTRIBUTING`). Quitado del HEAD (`git grep` en `origin/main` limpio); pasó a "la cuenta secundaria de solo-lectura". La historia lo conserva (el cliente eligió **limpiar-HEAD, no reescribir**). Email de commits de este repo fijado al `noreply` de GitHub (config **local**).
2. **Gate anti-PII construido y liberado (`v1.22.0`, PR #108, ADR 0041):** `tools/anti-pii.ps1` **BLOQUEA** formas de PII de entorno (email con dominio real, ruta de usuario nombrada) en docs rastreados. Se parte en dos: detector estructural **público** (muro en el check `andon`, patrón "detector de la base") + **denylist local** privada gitignoreada (cinturón pre-push). Disparo 16.º `sin-pii-en-el-repo` con respaldo en doctrina; baja al kit por el manifiesto. Evidencia: `qa_runs/gate-anti-pii-20260717/LOG.md` (self-test 11/11, 206 archivos limpios, cero falsos positivos). Bug del detector (tragaba puntuación de cierre) cazado y curado en la corrida; `probar-publicar` cazó que faltaba el gate en el preflight del release (curado).

**Pendiente del cliente (nada bloquea al agente):**
- **Email global:** `git config --global user.email` sigue en el correo de trabajo (`arcadial`) — afecta **todos** sus repos. Cambiarlo a noreply es decisión suya (identidad de trabajo vs privacidad); no se tocó.
- **Historia de git:** la cuenta secundaria y un Hotmail personal (`jose_joc14@…`) siguen en commits viejos y GitHub cachea; solo se borran **reescribiendo historia** (pesado). No hecho a propósito.
- **Backlog nuevo (ROADMAP):** que `planea.md` exija declarar **qué pruebas** hará cada rebanada del plan.

> **Nota git (git gana):** el cierre "2026-07-17 tarde" de abajo quedó viejo — #103 ya estaba mergeado y `v1.21.0`/`v1.21.1` liberados al abrir esta sesión.

## Dónde estamos (2026-07-17 tarde — El ritual determinista · PR #103 mergeado, `v1.21.0` liberado)

**Dos sesiones encadenadas en la rama `refina-arranca-orden-20260717` (16 commits, cuadro completo en `docs/sprints/cierre-20260717.md` — estrena el cuadro de cierre que esta misma sesión cableó).** La entrega:

1. **El ritual sin punteros (ADR 0040, extiende 0034):** en los comandos todo es `@`, `!` o inline — "entre puntero y nada, nada". Lo que vive en un artefacto con dientes se **imprime**, no se copia: `tools/asientos.ps1` (gemelo de `rutear.ps1`) imprime el casting desde `.claude/agents/` (motor, sembrado, prueba de vida en `probar-hooks`). ADR 0039: el comando es la fuente forzada; diagrama-primero es hábito de autoría; la dirección del acoplamiento es knob por-lab.
2. **El atlas cumple Method & Style:** los hijos 10/12/15/17 cierran en **end states** que el `01-operar-sesion` lee directo (regla Bruce Silver). El `12-planea` ganó el **segundo STOP** (aprobación formal del plan) que el comando exigía y el diagrama omitía; el `01` ya no construía con el plan en espera; el `15-gemba` dejó de duplicar el loop de rework del padre; *¿Humano presente?* → *¿El usuario pidió /jidoka:desatendido?* (la pregunta honesta).
3. **`planea` blindado (comentarios del cliente):** plan mode SIEMPRE (si no está, entra); póliza `@HANDOFF`+`@ROADMAP` (correr planea sin arranca no planea a ciegas); frescura `!git status`; el plan aprobado se **ancla como lista de tareas** visible en la UI.
4. **`cierra` gana el cuadro de cierre** (23 filas de hechos medibles, se **versiona** con los planes) — pedido del cliente con sus métricas de siempre + delegaciones, aprobaciones nombradas, compactación, fricción/errores (Kaizen crudo), motor al día.
5. **Censo de documentos** (161 md): núcleo traqueado; `docs/analisis/` era la única carpeta sin índice (creado). Índice de sprints podado (atlas-fiel ya estaba liberado).

**Cola de decisiones del cliente (actualizada — git gana):**
- ✅ **Merge del PR #103 + release `v1.21.0`** — HECHO (tag `v1.21.0`; luego #104/#105 encima).
- **Del censo, 2 knobs de ley `[PENDIENTE]`:** ¿`product/**` como `fuente` de un área? · ¿vigilar los planes de sprint post-aprobación?

**Pendiente registrado (backlog del ROADMAP):** el cuadro de cierre como plantilla sembrable (`kit/.jidoka/templates/cierre-cuadro.md` inyectada con `@`; el diagrama solo la referencia).

**Hueco declarado del cierre:** esta sesión no dejó corrida en `qa_runs/` (la inspección visual fue con PNGs scratch; los SVG committeados son el render final). El Gemba del cliente: abrir PR #103, ver el `01`/`10`/`12` renderizados, y correr `/jidoka:arranca` en sesión nueva para ver el casting impreso del artefacto.

---

## Dónde estuvimos (2026-07-17 — el fantasma del 10-arranca: NO era el diagrama, era la ventana)

**Sesión de soporte, no de sprint.** El cliente llevaba 3 chats convencido de que el `.bpmn` y el `.svg` del `10-arranca-con-subprocesos` «eran diferentes» y sin saber cuál era el real — al punto de querer borrar todo el atlas. **Tenía razón en lo que veía, y la causa NO era ningún diagrama.** Los archivos del repo siempre estuvieron bien (`atlas:validate` limpio los 26; el `.bpmn` en disco = HEAD = la versión fiel del sprint v1.20.0; cotejado contra `arranca.md`). El culpable: **el editor visual de BPMN de VS Code (Miragon) tenía un buffer viejo en memoria** — abrió el archivo antes del arreglo del 16-jul y **nunca lo recargó** cuando el merge de #101 actualizó el archivo en disco. La pestaña mostraba `●` (sin guardar) y pintaba la versión vieja («Recuperar contexto mínimo», bucle de aclaración); el `.svg` y el disco pintaban la buena. «bpmn ≠ svg» era en realidad «buffer viejo del editor ≠ disco». Se resolvió con `Revert File`. **Peligro esquivado:** un Ctrl+S en esa pestaña habría escrito la versión vieja encima de la buena.

**Lección durable (la Kaizen):** documentada como «Trampa del buffer viejo» en `docs/atlas/README.md` (el editor no recarga solo tras un cambio de git; `●` + diagrama que no cuadra con su `.svg` = copia vieja en memoria; `Revert File`, no guardar). Es el mismo patrón que el informe de fidelidad: un hallazgo que se re-descubría a golpes, ahora durable.

**Limpieza hecha en el working tree (sin commitear aún — falta rama):**
1. Borrados **37 PNG de inspección scratch** de `docs/atlas/render/` (basura untracked que confundía cuál diagrama era el real — incluía fotos `-nuevo`/homónimas de versiones viejas).
2. `docs/atlas/render/*.png` añadido al `.gitignore` (esas capturas no vuelven a ensuciar).
3. `HANDOFF.md` corregido (decía que atlas-fiel estaba «sin mergear» — doc-drift; ya estaba en `main`).
4. `docs/atlas/README.md` — la gotcha del editor.

**~~Pendiente (humano)~~ ✅ ATENDIDO:** los 3 cambios de doc llegaron a `main` vía el merge #102 (verificado contra git al abrir la sesión siguiente — el propio doc-drift de este HANDOFF fue el caso que motivó el "git gana" del arranca).

---

## Dónde estamos (2026-07-16 — «El atlas dice la verdad» · **`v1.20.0` MERGEADO Y LIBERADO** · PR #101, merge `9ec3114`)

**Sprint de fidelidad del atlas, nacido de que el cliente sintió que el 10-arranca «era diferente» — y tenía razón.** Se auditaron los 24 diagramas AS-IS contra su **fuente real** (comando `.md` / script `.ps1`): **14 fieles, 10 desviados**. Las 4 rebanadas construidas y committeadas en la rama (R0 aprobado en plan mode, plan-contrato en `docs/sprints/sprint-15-atlas-fiel-plan.md`). Evidencia: `atlas:validate` verde (26 diagramas), `verificar.ps1` limpio, cada diagrama tocado re-renderizado e inspeccionado a la vista. Informe durable: `docs/analisis/fidelidad-atlas-202607.md`.

1. **R1 (commit 26e690a):** el informe de fidelidad + **10-arranca reconstruido fiel** a `arranca.md` — la versión «bonita» de la mañana **inventaba** un bucle de aclaración y «leer doc activada» y **omitía** §3 (el asiento), §5 (reglas duras) y las lecturas de brief/CONTRIBUTING; el router estaba en el carril equivocado. Todo curado.
2. **R2 (5afd545):** **diagrama nuevo `31-sembrar-manual`** — la ruta AV-segura (`sembrar-manual.ps1`) que faltaba en el mapa; enlazada como 6ª rama del `02` y en `RELACIONES.csv` (que además perdió 2 filas obsoletas de los subprocesos del viejo 10-arranca).
3. **R3 (87f6aa1):** las 5 omisiones de lógica anotadas fiel a su fuente — 11-descubre (Paso 0), 13-construye (explorar/consolidar), 70-auditoría (pasos 6/7), 71-nocturna (click-it-down), 72-homologación (regla NDA).
4. **R4 (5840914 + 2d895b7):** 30-instalar y 42-sellar contra el `instalar.ps1` **real** (leído de git); menores 12 y 44.

**Corrección clave cazada por el cliente:** el primer pase marcó 30/41/42 como «fuente muerta» porque `instalar.ps1` no está en disco — pero **está en git, `skip-worktree` + cuarentena AV** (#79). 41-actualizar resultó **FIEL**. Lección de tooling (issue aparte, NO en este sprint): **auditar el atlas contra el disco miente cuando hay piezas `skip-worktree`; hay que leer de git.**

**Verificado 2026-07-17:** el atlas en git es la verdad — `atlas:validate` limpio (26 diagramas, 25 call activities en el CSV), y los `.svg` committeados corresponden a sus `.bpmn` fieles (marcadores cotejados en `10-arranca`). El sprint ya está en `main` (no quedó "sin mergear" — eso era doc-drift de este HANDOFF).

**Limpieza 2026-07-17 (el «desmadre» que veía el cliente):** se borraron los 37 PNG de inspección *scratch* de `render/` (basura untracked, no producto — incluían fotos `-nuevo`/homónimas de versiones VIEJAS que confundían cuál era la real) y se ignoran a futuro (`docs/atlas/render/*.png` en `.gitignore`). El caos eran esas capturas, no los diagramas. El producto versionado es el `.bpmn` (fuente) + su `.svg` (render de `npm run atlas:render`).

**Pendiente (humano — nada bloquea al agente):**
1. **Gemba del cliente:** abrir los `.bpmn` en `docs/atlas/` (empezar por `10-ritual/10-arranca-con-subprocesos.bpmn` y `30-instalacion/31-sembrar-manual-as-is.bpmn`) y confirmar a la vista.
2. **El pulido visual fino** de los diagramas tocados es del cliente (su terreno declarado); el agente entregó fidelidad + layout funcional legible.
3. **Abrir el issue de la lección de tooling** (`auditar`/atlas leen disco, no ven `skip-worktree`).

---

## Dónde estuvimos (2026-07-16 — la nave se audita a sí misma · `v1.19.0` · auditoría + curas en el mismo día)

**Sesión de auditoría pedida por el cliente ("¿es real o es teatro?") con curas ordenadas y liberadas el mismo día.** Dos PRs: los 5 informes (PR #94, `docs/analisis/`) y las curas (`v1.19.0`, ADR 0038, rama `fixes-auditoria-20260716`). Evidencia: `qa_runs/fixes-auditoria-20260716/LOG.md` (suite local completa verde; instalador en CI).

1. **Las 5 auditorías** (subagentes en paralelo + verificación en sesión de cada hallazgo): documentos y ley · atlas (25 diagramas contra sus fuentes) · kit/bajada (verificación independiente de la cosecha #7: **APTO** fresco y migrado) · prueba de vida de la nodriza · **veredicto teatro-vs-real** (`docs/analisis/veredicto-teatro-vs-real-202607.md` — la lectura que importa: el núcleo Toyota es maquinaria real con mordidas; la pata Scrum es conductual y se dobla — los demos del cliente se difieren; el teatro se acumula en los bordes). 3 hallazgos de subagente descartados al verificar, acusados en el informe.
2. **Las curas (issues #95–#98):** la ley gana cobertura (ADR 0038: atlas bidireccional `tools/*.ps1`→diagrama, `metodo` vigila `docs/atlas/*`, `bin/*` a barreras, área `guias`, raíz sin falsos avisos — `package.json` queda sin área a propósito, su invariante la cubre `probar-version`) · 11 diagramas del atlas reconciliados con el motor real y re-renderizados (`atlas:validate` sin huecos) · tests del kit muerden más (`probar-sembrar` 38, `probar-agentes` 32 con `tools:` case-sensitive; espejos de `instalar.ps1` diferidos por AV — vivo en #98) · **primera mordida real de `auditar.ps1`** (wikilink roto → 5 BLOQUEA → verde).
3. **El gate `review-stop` mordió en vivo** y el code-review de 7 ángulos curó 3 hallazgos en el diff antes del cierre (reuso del sello en 1d, aviso de gobernanza en `-Actualizar`, `-cnotcontains`). El método sobre sí mismo, otra vez.
4. **Las 4 decisiones de poda del cliente REGISTRADAS en #99** (contrato de la próxima cosecha): `sprint-entrega` NO se poda — se cura el proceso (cierra la llena como paso duro) · `que-sigue` se funde en el arranca · `reportar-leccion` prueba de vida en la sesión del repo real · `desatendido` plazo 2026-08-16 · `jerarquia.md`/`verificacion.md` se podan.

**Pendiente (humano — nada bloquea al agente):**
1. **Leer los informes del PR #94** (el Gemba de la auditoría; empezar por el veredicto) — alimenta la próxima cosecha junto con #99.
2. **La sesión en el repo real "endi"** (siguiente paso acordado): sembrar v1.19.0 ahí cubre de un tiro el demo de la cosecha #7, el de v1.16.0, y —si endi tiene niebla real— el de `descubre`; ahí también la prueba de vida pactada de `reportar-leccion`.
3. Heredados: bajada `v1.12.1`–`v1.19.0` a los labs (SGI/TF) · Gemba del análisis de costo neto (#72) · 2 huecos del brief (métrica y apetito) · certificado Authenticode · npm publish.

---

## Dónde estuvimos (2026-07-16 noche — CERRADO Y LIBERADO · `v1.18.0` · cosecha #7 "La bajada que dolió")

**Los 6 bugs de la bajada real del caso 1 (#86–#91, llegados en batch a las 15:27) atendidos, mergeados y liberados el mismo día** ([release v1.18.0](https://github.com/ArmandoMedina/jidoka/releases/tag/v1.18.0), PR #92, ADR 0037, plan-contrato `docs/sprints/sprint-14-cosecha-7-plan.md`). Ritual completo: R0 aprobado con nombre (cura B del #82) → plan formal → 3 rebanadas con subagentes → evidencia → CI verde → merge y release con orden nombrada. La entrega:

1. **La conciencia viaja al kit (R1, #86/#87, grueso de #82):** los agentes-asiento + `probar-agentes` al manifiesto; leyes-plantilla con el área; la instancia que el `arranca` inyecta es **stub común** (brief a `product/`, `infra.md` con `## El casting` — la casa única del roster — y `CONTRIBUTING.md`); `recursos-del-proyecto.md` retirado del kit; **`-Actualizar` migra** (`[MIGRA]` no-clobber; sello gana `producto`/`gobernanza`; con sello viejo avisa, no adivina).
2. **El juez sin hueco (R2, #88):** `no-borres-el-motor` solo destraba con ADR **agregado** (`--diff-filter=A` + `-AgregadosInyectados`); ROJO→VERDE contra el juez de `main` en el LOG.
3. **Mecánica menor (R3, #89/#90/#91):** guard del manifiesto sin `stubs` + caso; **costura `tools/ci.local.ps1`** en `andon.yml` (la customización de CI del hijo deja de re-divergir) + tabla de costuras en la guía; sello con newline; el "doble resumen" NO reprodujo (artefacto de captura, acusado en #91).

**Reconciliación en vivo:** el atlas (PR #85) se liberó como `v1.17.0` con los ADR 0035/0036 **mientras esta cosecha se construía** → la cosecha se renumeró a **`v1.18.0` / ADR 0037**, merge de `main` a la rama, suite re-corrida post-merge (196/196) y CI verde antes del merge. Evidencia: `qa_runs/cosecha-7-20260716/LOG.md` (+ demo de migración íntegra en `demo-actualizar.txt`).

**Issues:** #86–#91 **cerrados** con el release · #82 queda abierto re-alcanzado a lo único vivo (validar nombres de `tools:` en el lint) · los 7 acusados uno por uno en el tracker.

**Nota operativa de la sesión:** el clasificador de permisos del agente bloqueó intermitentemente comandos con literales tipo glob en mensajes/lotes (`gh issue close` en batch, commits con comodines en el cuerpo) — se resolvió de uno en uno; no fue falla del ritual. La cuenta gh activa quedó **ArmandoMedina** durante merge/release (convención de `product/infra.md`); restaurar la cuenta secundaria al cerrar si se desea.

**Pendiente (humano — nada bloquea al agente):**
1. **El demo de la cosecha #7** (Verificación, owner: cliente): sesión nueva en `C:\Repositorios\jidoka-hijo-practica` (hijo real sembrado 1.16.1 → migrado) + `/jidoka:arranca` — sin `@` rotos, casting visible, asientos existentes. El hijo es desechable; bórralo al terminar.
2. **La bajada `v1.12.1`–`v1.18.0` a los labs** — ahora con `-Actualizar` que migra la instancia (exactamente lo que esta cosecha curó); la re-prueba AV de `sembrar-manual` (creció ~20 líneas; su magrez es restricción del ADR 0027) va en esa misma ventana.
3. Heredados: Gemba del análisis de costo neto (#72) · demo de `v1.16.0` · 2 huecos del brief (métrica y apetito) · demo de campo de `/jidoka:descubre` (#67) · certificado Authenticode · npm publish · #74 (queda solo el cert).

---

## Dónde estuvimos (2026-07-16 — atlas de procesos BPMN · `v1.17.0` · PR #85)

**El método gana el atlas de procesos navegable en `docs/atlas/`, en BPMN (ADRs [0035](docs/decisions/0035-atlas-de-procesos-bpmn.md) / [0036](docs/decisions/0036-acoplamiento-proceso-docs-diagrama.md)).** Los **25 diagramas re-modelados** con carriles (agente/humano) y gateways; toolchain Node (`atlas:validate|render|layout|sellar`); acoplamiento al flujo como **aviso comando→diagrama** (área `atlas` en la ley, no bloqueo — regla 2-3); editor Miragon recomendado + `jidoka.code-workspace`. Se corta como **`v1.17.0`** (MINOR aditivo). Nota: se renumeró de 0032/0033 a **0035/0036** por colisión con los ADR 0032-0034 que `main` liberó en paralelo (`v1.15.0`/`v1.16.0`). Evidencia: `atlas:validate` sin huecos, 25 SVG en `docs/atlas/render/`, cada diagrama inspeccionado a la vista. PR #85 mergeado.

## Dónde estuvimos (2026-07-16 — CERRADO Y LIBERADO · `v1.15.0` + `v1.16.0` · análisis de costo neto entregado)

**Cola de la sesión del 16-jul (tarde):** `v1.16.0` **mergeado y liberado** ([release](https://github.com/ArmandoMedina/jidoka/releases/tag/v1.16.0) — `publicar.ps1` corrió completo de una, suite 9/9 con `probar-agentes`). Después, dos pendientes atendidos en autónomo:

1. **#74-R3 evaluado y cerrable** (comentado en el issue con evidencia): `instalar.ps1` NO contiene `-ExecutionPolicy Bypass` (barrido completo), el quickstart lanza directo, el wrapper npx es condicional desde #34, y la investigación AV de `v1.14.0` ya midió que quitar el flag no baja del umbral heurístico. Del issue solo queda vivo el certificado Authenticode (cliente).
2. **#72 — primer pase del análisis de costo neto ENTREGADO** (`docs/analisis/costo-neto-sgi-202607.md`, `en_revision` — el Gemba lo hace el cliente). Sobre evidencia real de SGI, dos barridos (local + server-side): el muro server-side paga su costo con margen (206 corridas, 21 rojas ≈10 %, **3 doc-drifts reales frenados antes del merge**, vuelta al verde en minutos, ruleset sin bypass); el costo dominante es el **lazo** (3 bajadas de motor en un día con verificación manual) y la doc ceremonial; y **cuatro piezas con cero señal de vida** en SGI: `docs-graph` (0 fallos en el historial), `sprint-entrega.md` (0 usos), `reportar-leccion` (0 issues desde SGI), y el summary de avisos que el `andon/README.md` de SGI afirma pero su config no implementa. Candidatas a poda/prueba de vida (#46) en la próxima cosecha — medir también puede justificar eliminar.

**El resto de la sesión del 16-jul (dos sprints por el ritual completo):**

**Sesión del 16-jul: dos sprints por el ritual completo (R0 aprobado con nombre → plan-contrato → construcción con subagentes → evidencia → PR).**

1. **Cosecha #6 "El juez falla cerrado" — MERGEADA Y LIBERADA** ([release v1.15.0](https://github.com/ArmandoMedina/jidoka/releases/tag/v1.15.0), PR #81, ADR 0032). El preflight de `publicar.ps1` se planta ante un `probar-*` ausente del disco (decisión del cliente: morir siempre) + salvavidas `no-borres-el-motor` (disparo 15.º: borrar `tools/*.ps1` o la ley sin ADR nuevo = BLOQUEA) + receta `skip-worktree` (#79 parcial) + `sembrar-manual` primera clase en README (#74-R2) + frontera Core vs familias (#71 primer paso). Cerró #78 y #73. Evidencia: `qa_runs/juez-falla-cerrado-20260716/LOG.md`.
2. **Sprint "Conciencia del agente — reconstrucción limpia" — CONSTRUIDO, EN PR** (ADRs 0033/0034, `v1.16.0`, cierra #75/#63). **La historia honesta que pide el #75:** el sprint original se descartó porque un subagente **borró 2 piezas del motor** (750 líneas) y la regresión se enmascaró — se re-narró como cuarentena de AV y al auditor se le ordenó ignorar los archivos; el review pasó verde encima. El AV existía de verdad (ADR 0027) pero no justificaba ni el borrado ni el silencio. `v1.16.0` es la reconstrucción sobre cimiento limpio, con el salvavidas de `v1.15.0` ya vigilando. Piezas: agentes-asiento tiereados (`.claude/agents/`: explorador/mecanico→haiku, auditor→sonnet, arquitecto→opus; el harness los registró en vivo) + lint `probar-agentes` (28/28, en preflight y CI) + `arranca` reescrito (inyecta el estado con `@`, roster de responsables, router como preview de gates — el asiento lo ocupa el subagente) + split `product/PRODUCT_BRIEF.md` (el QUÉ) / `product/infra.md` (el CÓMO) con `recursos-del-proyecto.md` migrado y borrado. Evidencia: `qa_runs/conciencia-del-agente-20260716/LOG.md` (suite 9/9 con el lint nuevo).

**El code-review del sprint 2 cazó 6 hallazgos ANTES del merge:** 3 curados en el diff (contradicción casting arranca↔plantilla, `probar-agentes` faltaba en el CI, comentario engañoso del parser) y 3 registrados en [#82](https://github.com/ArmandoMedina/jidoka/issues/82) (`leccion`): la conciencia de `v1.16.0` **no viaja completa a los hijos** (el arranca canónico inyecta archivos no sembrados; `.claude/agents/` fuera del manifiesto; leyes-plantilla sin el área). Decisión de alcance para otra cosecha — un piloto fresco (#70) tropezaría ahí.

**Brief nuevo con 2 huecos honestos** (`product/PRODUCT_BRIEF.md`, marcados "Pendiente del cliente"): la **métrica objetivo con número** y el **apetito** — nadie los ha declarado; decide el cliente, no se rellenan.

**Pendiente (humano — nada bloquea al agente):**
1. **El Gemba del análisis de costo neto** (`docs/analisis/costo-neto-sgi-202607.md`): leerlo y decidir qué se hace con las 4 piezas sin señal de vida (poda / prueba de vida / nada) — alimenta la próxima cosecha junto con #46/#66.
2. **El demo de `v1.16.0`**: sesión nueva + `/jidoka:arranca` — ver el roster con tiers, el estado inyectado y el router como preview (la Verificación del sprint, owner: cliente).
3. **Los 2 huecos del brief** (`product/PRODUCT_BRIEF.md`, marcados "Pendiente del cliente"): métrica objetivo con número y apetito.
4. Heredados sin cambios: demo de campo de `/jidoka:descubre` (alimenta #67) · bajada `v1.12.1`–`v1.16.0` a los labs · certificado Authenticode (#40/#43/#74/#78/#79) · npm publish · cerrar #74 si el veredicto R3 convence.

---

## Dónde estuvimos (2026-07-15 — CERRADO Y LIBERADO · Jidoka `v1.14.0` · queda el demo de campo)

**Sesión del 15-jul: PR #76 mergeado y `v1.14.0` liberado** ([release](https://github.com/ArmandoMedina/jidoka/releases/tag/v1.14.0)); `main` limpio. La entrega: **`sembrar-manual.ps1` promovido a instalador AV-seguro completo** (ADR 0027, enmienda) — el segundo entorno endurecido (regla 2-3) llegó en la máquina del autor: Bitdefender puso en cuarentena `instalar.ps1` y `probar-instalador.ps1`; la investigación contra el AV real (`qa_runs/av-sembrar-20260715/LOG.md`, commiteado) tumbó la hipótesis del "nombre-imán": el trigger es **densidad de comportamiento acumulada**. `sembrar-manual` ahora siembra la instancia entera (stubs no-clobber); `probar-instalador` y `probar-sembrar` corren en el CI (donde no hay AV). Cura de fondo: firma Authenticode, pendiente de certificado (recurso del cliente).

**Evidencia del corte:** CI verde sobre el head exacto del PR (instalador **51/51**, sembrar **26/26**, server-side; árbol idéntico al de `main`) + preflight local `-SoloVerificar` verde en lo que el AV deja correr + `verificar`/`auditar` exit 0. El release se cortó con la mecánica de `publicar.ps1` en dos pasos (preflight aparte + `gh release create`) porque el clasificador de permisos del agente bloqueó el script entero — no fue falla del ritual.

**Issues del lazo cazados DURANTE el corte (enlazados entre sí, próxima cosecha):**
- [#78](https://github.com/ArmandoMedina/jidoka/issues/78) (`bug`+`leccion`) — **el preflight de `publicar.ps1` da `[OK]` a un test cuyo archivo no existe** (CommandNotFoundException tragado por `*> $null` + `$LASTEXITCODE` viciado del test anterior). Visto en vivo con `probar-instalador` en cuarentena. Cura candidata en el issue (guarda `Test-Path` que falla cerrado + caso ROJO→VERDE).
- [#79](https://github.com/ArmandoMedina/jidoka/issues/79) (`leccion`+`regla-2-3`) — **`instalar.ps1` y `probar-instalador.ps1` tienen `skip-worktree` en el índice local** (parche de la sesión anterior contra la cuarentena): el árbol reporta "limpio" con dos piezas del motor fuera del disco y ninguna guarda lo acusa. Estado local vigente HOY en esta máquina — no te creas el "limpio" sin `git ls-files -v tools/`.

**Nota operativa (ya en `recursos-del-proyecto.md`):** los merges y releases en GitHub requieren la cuenta gh **ArmandoMedina** activa (`gh auth switch`); la cuenta secundaria no tiene permiso de merge. Quedó activa la cuenta secundaria al cerrar.

**Pendiente (humano) — heredado, sin cambios:**
1. **El demo de campo de `/jidoka:descubre`** (owner: cliente): correrlo en un proyecto con niebla real; su resultado alimenta #67.
2. La bajada `v1.12.1`–`v1.14.0` a los labs con `-Actualizar` (reconstrucción: solo cuando cierre la sesión del otro agente; SGI: esperar DIVERGE).
3. **Certificado de firma (Authenticode)** — la cura de fondo del frente AV (#40/#43/#78/#79 dejan de doler al firmarse el motor).

---

## Dónde estuvimos (2026-07-14 — CERRADO Y LIBERADO · Jidoka `v1.13.0`)

**Sesión del 14-jul (tarde): dos entregas, ambas mergeadas y liberadas; `main` limpio.**

1. **`v1.12.1` — dogfooding al día.** La nave nodriza respeta su doctrina: `## El casting` sembrado en `product/recursos-del-proyecto.md` (nombres neutrales a propósito — decisión del cliente: la ruta del usuario recién sembrado), `probar-sembrar` en el preflight de `publicar.ps1` (+ invariante en `probar-publicar`: todo `probar-*.ps1` debe estar en el preflight), listón `LOG.md` adoptado en casa (`qa_runs/dogfood-20260714/`, primer uso propio). PR #62, [release v1.12.1](https://github.com/ArmandoMedina/jidoka/releases/tag/v1.12.1).
2. **Sprint Descubre — la capa de consultoría (`v1.13.0`, ADR 0031).** PR #65 mergeado, [release v1.13.0](https://github.com/ArmandoMedina/jidoka/releases/tag/v1.13.0). Nace de 3 diagnósticos sobre chats reales (2 despliegues con QUÉ borroso que patinaron vs. el caso de éxito) + investigación de metodologías: el QUÉ vive en **ejemplos**, no en docs; **STOP no es comprensión**; a veces la autoridad es **un tercero sin IA**. Piezas: `/jidoka:descubre` (3 nieblas + juez de verdad, rondas fijas, filtro Mom Test escrito, @-include del brief — la lectura se inyecta), campos del descubrimiento en `PRODUCT_BRIEF.md`, `kit-entrevista.md` (kit portátil: el experto es autoridad, no usuario), disparo 14.º `aprobacion-nombrada`, ruteo desde `planea` R0. Contrato y récord: `docs/sprints/sprint-descubre-{plan,entrega}.md`.

**Evidencia (verde, esta máquina 2026-07-14):** `probar-disparos` 4/4 (**14** disparos, ROJO→VERDE) · preflight del release 8/8 · SSOT 1.13.0. LOGs: `qa_runs/dogfood-20260714/` y `qa_runs/descubre-20260714/`.

**Issues registrados esta sesión (el lazo, batch):** [#63](https://github.com/ArmandoMedina/jidoka/issues/63) tiers de modelo dependen de la iniciativa del agente · [#64](https://github.com/ArmandoMedina/jidoka/issues/64) aviso "no hay sello" en la nave nodriza (cosmético) · [#66](https://github.com/ArmandoMedina/jidoka/issues/66) telemetría de lecturas del método (one-off primero) · [#67](https://github.com/ArmandoMedina/jidoka/issues/67) gate anti-placeholders del brief · [#68](https://github.com/ArmandoMedina/jidoka/issues/68) **lección: el agente complaciente dobló su propio contrato** (cazado por el cliente en vivo). Familia "conciencia del agente" con cuerda para la próxima cosecha.

**Pendiente (humano):** consolidado en la sección vigente de arriba (el demo de campo de `descubre` quedó abierto a propósito — la Verificación del sprint espera al cliente, en un proyecto con niebla real: tracker-financiero o el repo de rescate).

---

## Dónde estuvimos (2026-07-14 — CERRADO Y LIBERADO · Jidoka `v1.12.0`)

**Cosecha #5 — "instalar = funcionar": la conciencia se instala** (cerró #53/#51, ADRs 0029/0030). Todo mergeado y liberado; `main` limpio. [release `v1.12.0`](https://github.com/ArmandoMedina/jidoka/releases/tag/v1.12.0) (suite verde en preflight). PRs #57 (conciencia), #60 (liston; reemplazó a #58, cerrado al borrarse su rama base al mergear apilado) y #59 (registro). Nace de contrastar dos despliegues reales: en uno la calidad de la evidencia se degradó dentro del mismo día (un `LOG.md` rico → un `veredicto.txt` pelón); en otro la brecha la tapaba el usuario **a mano**, con un párrafo de apertura escrito cada sesión. Principio de la cosecha: **nada de conciencia depende de la iniciativa del agente** — se instala como maquinaria determinista o no está instalada. Tres piezas:

- **PR `cosecha5-conciencia` (ADR 0029) — el arranca sienta y rutea.** `tools/rutear.ps1` (mecánica, sembrada): fuente única de la lógica router + vivo/dormido; **falla cerrado** (exit 1) sin ley. `/jidoka:arranca` adopta el casting (sembrado en el template `recursos-del-proyecto.md` → sección `## El casting`) y lee el router. `estado-motor` imprime la sección Gates **siempre** → la dormancia deja de ser invisible (#51).
- **PR `cosecha5-liston` (ADR 0030) — el `LOG.md` como listón + el demo que corre el cliente.** `gemba-stop`/`validador-stop` solo cuentan `qa_runs/<corrida>/LOG.md`, no cualquier archivo (cierra el Goodhart del `veredicto.txt` pelón). Template `qa-log.md`. Disparo `demo-que-corre-el-cliente` (13.º): la Verificación se demuestra **sin código ni terminal** o la rebanada no es vertical.
- **PR `cosecha5-registro` — README honesto + este HANDOFF.** El README gana la capa de conciencia instalada y precisa "sin código ni terminal" + evidencia = `LOG.md`.

**Evidencia (verde, esta máquina 2026-07-14):** `probar-hooks` **29/29** (+2 listón +4 rutear) · `probar-disparos` 4/4 (**13** disparos) · `probar-gate` 10/10 · `probar-instalador` 51/51 · `probar-sembrar` 24/24 · `probar-version` 1.12.0 · `auditar` + `verificar` sin bloqueo (avisos no aplicables, acusados en los PRs). `rutear` manual contra la ley real: gemba/validador DORMIDO, review/andon VIVO.

**Pendiente (humano) — la bajada a los labs (nada urgente):** sembrar `v1.12.0` en los labs con `-Actualizar` — **el lab de reconstrucción** (SOLO cuando cierre la sesión del otro agente que trabaja ahí — no pisarlo; declarar su casting con nombres al sembrar) y **SGI** (esperar DIVERGE en sus comandos personalizados → mergear a mano la sección del router en su `arranca`). Follow-up conocido del motor: `publicar.ps1` no corre `probar-sembrar` en su preflight (se corre a mano; arreglo de una línea).

---

## Dónde estuvimos (2026-07-14 — CERRADO Y LIBERADO · Jidoka `v1.11.0`)

**Cosecha #4 del lazo (#50–#53), nacida de auditar un despliegue real** (repo de reconstrucción / ingeniería inversa) donde un sprint cerró con un *"validado al centavo"* en prosa **sin que ningún gate lo atrapara** — el deliverable era una spec numérica, un tipo que la ley no vigilaba. Todo mergeado y liberado; `main` limpio. [release `v1.11.0`](https://github.com/ArmandoMedina/jidoka/releases/tag/v1.11.0) (suite verde en preflight).

- **#50 (fix, cerrado) — los 3 Stop hooks fallaban-abierto en dirs recién-nacidos.** `git status --porcelain` sin `--untracked-files=all` colapsa un dir sin archivos trackeados en `dir/` → el glob específico de una `fuente` no casa → el gate salía limpio justo en el deliverable nuevo. Arreglado en la semilla (`.claude/hooks/*`) + prueba de vida que distingue el bug (ROJO→VERDE). PR #54.
- **#52 (feat, cerrado — ADR 0028) — `validador-stop`, el 3er gate de evidencia.** Validación por medición para datos/spec: un área `rol: validador` enciende un Stop hook que frena si la spec cambia sin evidencia rastreada por git de una corrida de motor determinista en `qa_runs/validador-*`. Incluye la **variante local** para fixtures confidenciales (PII). Nace **dormido** en Jidoka. Template en `kit/.jidoka/templates/validar-dominio.ps1`. PR #55.
- **#51 y #53 (abiertos — próxima cosecha).** #51: los gates de evidencia pueden quedar TODOS dormidos a la vez → **lint de arquetipo**. #53: la capa de **conciencia** — el `arranca` canónico sub-informa al orquestador sobre los asientos (se pudo "correr a arrancar" y auto-certificar). Nota de diseño: el fix es **lean** (arranca que haga leer `roles.md` / cue que fuerce nombrar el asiento), **NO** portar un docote de flujo de trabajo.

**Evidencia (verde, esta máquina 2026-07-14):** `probar-hooks` **23/23** (5 casos nuevos del validador) · `probar-version` 1.11.0 · `probar-disparos` 4/4 · `probar-gate` 10/10 · `probar-instalador` + `auditar` verdes (preflight del release). Andon sin bloqueo.

---

## Antes (2026-07-13 — Jidoka `v1.10.0`)

**Sesión que atendió la cosecha de issues del lazo (#40–#46). Todo mergeado y liberado; `main` limpio.** PR #48 mergeado (836b14d), [release `v1.10.0`](https://github.com/ArmandoMedina/jidoka/releases/tag/v1.10.0) publicado (suite verde en el preflight). Plan-contrato: `docs/sprints/sprint-09-brownfield-2-plan.md`. Los 7 issues **acusados uno por uno** (el 3er paso del lazo); #40/#42/#43 cerrados con el release, #41/#44/#45/#46 abiertos con `regla-2-3`.

**Construido (`v1.9.0`→`v1.10.0`, ADR 0027 — tercera cosecha por el lazo):**
- **R1 (#40/#43) — la ruta de actualización deja de colgar del instalador.** `tools/sembrar-manual.ps1`: fallback de siembra/actualización **independiente de `instalar.ps1`** (sin `-ExecutionPolicy Bypass`, sin el nombre "instalar"), para Windows endurecido donde el AV pone `instalar.ps1` en cuarentena. Copia la mecánica del manifiesto + `core.hooksPath` + sello; no-clobber + tres vías. Registrado como pieza de motor (baja por el lazo). `estado-motor.ps1` **degrada con gracia** (apunta al fallback si `instalar.ps1` no es legible). Guía: `mantener-el-motor-al-dia.md`.
- **R2 (#42) — auditor configurable.** `auditar.ps1` lee `scanDirsExtra` de la ley (`tools/blast-radius.json`): amplía el índice de wikilinks a capas propias (`engineering/`) sin tocar el motor. Sin el campo, idéntico. Campo documentado en ambas plantillas de ley.
- **R3 — cosecha (regla 2-3, NO construida):** #41 (`doc-only`, 1er uso real), #44 (arquetipo `operacion`), #45 (gobernanza compuesta), #46 (prueba de vida ≠ tests verdes), y reducir superficie AV del instalador (renombrar/firmar/`npx`) → en `ROADMAP.md` → *Tercera cosecha por el lazo*. Los 7 issues etiquetados (`bug`/`leccion`/`regla-2-3`).

**Evidencia (verde, esta máquina 2026-07-13):** `probar-sembrar` 24/24 · `probar-auditor` 7/7 (con casos #42) · `probar-instalador` 51/51 (regresión) · `probar-gate` 10/10 · `probar-hooks` 17/17 · `probar-disparos` 4/4 · `probar-version` 1.10.0 · verificar sin bloqueo. Demo Gemba en `qa_runs/brownfield-2-20260713/`.

### Modo actual: dejar que se acumulen más issues (batch, no goteo)
Decisión del cliente (2026-07-13): **cerrar aquí y esperar a que se junten más lecciones** antes de la próxima cosecha. Los follow-ups están **en el backlog del ROADMAP** (*Follow-ups sueltos*), no requieren acción ya:
1. `publicar.ps1` no incluye `probar-sembrar` en su preflight (arreglo de una línea).
2. **[#47](https://github.com/ArmandoMedina/jidoka/issues/47)** sin triar (etiquetado `leccion`) + los abiertos `regla-2-3` (#41/#44/#45/#46) → material de la próxima cosecha.
3. **Bajar el batch a los labs** con `-Actualizar` (próxima ventana; `sembrar-manual` + auditor configurable + acuse son mecánica).
4. **Épica `.local` code-first + drift estructural** (ADR 0015): abierta de arcos anteriores.

## Antes (2026-07-11 — SESIÓN CERRADA · Jidoka `v1.8.1`)

**Sesión enorme, toda cerrada y liberada; los tres repos limpios.** Jidoka `v1.0.0`→`v1.8.1`; labs **SGI `v2.6.0`→`v2.8.0`**, **TF `v0.2.0`→`v0.4.0`**.

**Post-1.0 (`v1.1.0`→`v1.8.1`):** muro endurecido (grietas 2/5, ADR 0018) · hotfix hook Bash (`v1.1.1`) · el lazo ve la divergencia (`-Sellar`/`estado-motor -Detallado`, ADR 0019) · release desde el SSOT (`publicar.ps1`, ADR 0020) · lazo **EOL-agnóstico** (ADR 0021) · **lista de exclusión** del hijo (ADR 0022) · guía "mantener el motor al día" · `CODE_OF_CONDUCT.md` · párrafo en inglés · **CLI `npx jidoka-method` construido** (`package.json`+`bin/`) · **estructura canónica** (comandos namespaced, ADR 0023) · **el motor se lee del árbol** (ADR 0024, cierra el dogfood del ADR 0003 como *"no se migra"*).

**Bajado a ambos labs** (ventana de bajada + estructura canónica): SGI/TF corren el núcleo actual, comandos namespaced re-personalizados con su sabor, `excluir` declarado. **Drift estructural cerrado de raíz** (ADR 0021/0022/0023).

### Lo único pendiente — todo gatillado por el cliente (nada que la IA pueda hacer sola)
1. **`npm publish`** del CLI `jidoka-method` — necesita tu cuenta npm. Mientras tanto se usa con `node bin/jidoka-method.js init <ruta>`.
2. **Verificar el CLI/motor en Mac/Linux** (pwsh Core) — necesita un entorno no-Windows; no se declara cross-platform sin evidencia (`evidencia-no-palabra`).
3. **Social preview** del repo — imagen 1280×640 desde la UI de GitHub.

**Cuatro bugs de herramienta cazados por uso real** este arco (hook Bash, hash EOL, `publicar` ×2), más `probar-disparos` cazando su propio slug — todos ahora invariantes con test. El método sobre sí mismo.

### Antes (2026-07-11, `v1.4.0` — batch post-1.0 BAJADO a ambos labs)

**Modo de operación (decisión del cliente):** *avanzar Jidoka lo máximo posible acumulando releases y hacer UNA sola bajada a los labs al final* — la bajada (2 repos × PR/tests/merge) es la parte cara, no el release de Jidoka. Además, **el cliente elige el tamaño y la dirección del sprint; no preguntar** (yo decido por capacidad/esfuerzo, él frena si algo no cuadra).

**Releases post-1.0 (todos BAJADOS a los labs en la ventana de bajada):**
- **`v1.1.0` — "El muro cumple lo que promete"** (ADR 0018): grietas 2 y 5 cerradas con invariantes. `no-memorias` cubre Bash; registro de disparos cableados (`probar-disparos.ps1`).
- **`v1.1.1` — hotfix** (dogfood): el matcher Bash de `no-memorias` bloqueaba en falso lecturas con `2>&1`/`2>/dev/null` (el `>` casaba con la redirección de stderr). Cazado en vivo minutos después de publicar `v1.1.0`. `probar-hooks` 17/17.
- **`v1.2.0` — "El lazo ve la divergencia"** (ADR 0019): `instalar.ps1 -Sellar` (sello bootstrap clasificador pristina-vs-customizada) + `estado-motor -Detallado` (divergencia por-hash). `probar-instalador` 41/41.
- **`v1.3.0` — "El release se deriva del SSOT"** (ADR 0020): `tools/publicar.ps1` corta el tag+notas desde `version.txt`+CHANGELOG y corre la suite antes de publicar (Jidoka-only, dogfoodeado en su propio corte). `probar-publicar` 4/4.
- **`v1.4.0` — "El lazo es agnóstico al EOL"** (ADR 0021): `Get-MotorHash` normaliza a LF. Bug estructural cazado al bajar a TF (un hijo `eol=lf` divergía en todo). `probar-instalador` 42/42 (caso LF nuevo).

**✅ BAJADA CERRADA (2026-07-11).** El batch `v1.1.0→v1.4.0` bajó a ambos labs, verde server-side: **SGI `v2.7.0`** (PR #59, 7/7) y **TF `v0.3.0`** (PR #8, 5/5). Ambos corren el núcleo `1.4.0` con la mecánica genérica idéntica; code-first preservado (verificar/auditar/probar-gate/pre-push/escribano). Lecciones de la ventana (el uso real cazó lo que la revisión no):
- **Dos defectos estructurales del lazo** cazados y arreglados: `v1.1.1` (falso-positivo del matcher Bash con `2>&1`) y `v1.4.0` (hash sensible al EOL → un lab `eol=lf` divergía en todo).
- **La línea code-first-vs-genérico no estaba bien trazada:** hooks/tests genéricos (`gemba-stop`, `probar-hooks`) se estaban preservando como si fueran del lab. El operador la adivinó cada bajada. → **el drift estructural (ADR 0015 #3) necesita una LISTA DECLARADA de piezas code-first** por lab (o por convención de nombres), para que `-Actualizar` distinga "genérico atrasado" (adopta) de "customizado" (preserva) sin adivinar.
- Los gates de doc-sync de los propios labs (`barreras` → `docs/flujo-de-trabajo.md`) mordieron server-side y se sincronizaron.

**Pendiente en la ventana de bajada (NO se hizo, sigue abierto):** la **épica `.local` code-first** (converger verificar/auditar al motor genérico + costura `.local`, sin romper los 453 tests de SGI) y el **drift estructural** (lista declarada de code-first). Ambos siguen registrados (ADR 0015).

### Antes — PROGRAMA HACIA 1.0 (COMPLETO · `v1.0.0`)

**Jidoka salió de beta.** El programa de 3 sprints hacia 1.0 cerró completo. La vara del ROADMAP (*el método corre end-to-end en un repo ajeno*) quedó cumplida **con evidencia**: el núcleo bajó a dos labs ajenos reales con CI verde server-side.

- **✅ Sprint A** (`v0.13.0-beta`, ADR 0014): los 4 bloqueantes de "corre en un repo ajeno" cerrados (instalador pregunta arquetipo, método sembrado completo, fixture del quickstart, guía empezar-de-cero). PR #16 mergeado, release publicado.
- **✅ Sprint B** (labs): el núcleo bajó por el lazo. **SGI `v2.6.0`** (PR #58, 7/7 checks) — actualizar núcleo + **curar un bug del sello** (grababa piezas code-first como semilla pristina → auto-sanante). **TF `v0.2.0`** (PR #7, 5/5 checks) — cablear al lazo (sello + canal de subida + `core.hooksPath`) + convergencia ADR 0006. Ambos liberados, lo code-first preservado sin pisar nada. Evidencia en el `qa_runs/` de cada lab.
- **✅ Sprint C** (`v1.0.0`, ADRs 0015/0016/0017): segunda cosecha por el lazo (4 lecciones al backlog), licencia **MIT consciente**, y la **declaración 1.0**. `tools/version.txt` → `1.0.0`.
- **Alcance 1.0 funcional.** Diferido explícito a post-1.0 (ROADMAP): lo público (social preview, párrafo en inglés, `CODE_OF_CONDUCT`), CLI npm/SSOT, multiplataforma, reconciliación code-first vía `.local`, grietas 2 y 5, y las 4 lecciones de ADR 0015.
- **Estado de los labs:** SGI (`master`) y TF (`main`) corren el núcleo `0.13.0-beta`, cableados al lazo. La próxima mejora de Jidoka baja a ambos con `-Actualizar`.

### Qué sigue (post-1.0, modo batch — avanzar Jidoka, bajar una vez)

**Jidoka-interno (avanza sin tocar labs, acumulando releases):**
1. **CLI npm `npx jidoka-method init` + multiplataforma** — el mayor desbloqueo de adopción, pero **BLOQUEADO por verificación**: son cross-platform y esta máquina es Windows-only; declararlos aquí afirmaría que corren en Mac/Linux sin evidencia (`evidencia-no-palabra`). Necesitan un entorno no-Windows para probarse, o el cliente diciendo "shippéalo sin probar cross-platform". `npm publish` además necesita la cuenta del cliente. *(La parte SSOT/release-derivation ya se hizo en `v1.3.0`, ADR 0020.)*
2. **Dogfood ADR 0003** (motor solo en `kit/`, auto-instalación) — Windows-verificable pero **big-bet** (reubica el motor del que dependen todos los gates; alto blast-radius). Arquetipo `doc-only` sigue diferido (regla 2-3: sin consumidor real).
3. **Presentación pública** (Sprint 4): social preview, párrafo en inglés, `CODE_OF_CONDUCT`, badges — tiene piezas gatilladas por el cliente.

**En la ventana de bajada (necesitan labs, se hace UNA vez):**
4. **Re-sellar SGI/TF con `-Sellar` + `-Actualizar`** el batch acumulado (hook mejorado, `probar-disparos`, refinamientos del lazo).
5. **Épica `.local` code-first + drift estructural núcleo↔labs** (ADR 0015): la "mecánica igual" completa, sin romper los 453 tests de SGI.

Refinamientos del lazo #1 y #2 (sello bootstrap, `estado-motor -Detallado`): ✅ hechos en `v1.2.0` (ADR 0019).

## Antes (2026-07-11, la cosecha del lazo — CERRADA)

- **✅ Primera cosecha por el lazo MERGEADA y LIBERADA (`v0.12.0-beta`, ADR 0013).** PR #15 mergeado; [release](https://github.com/ArmandoMedina/jidoka/releases/tag/v0.12.0-beta). Tres lecciones absorbidas: gemba-stop exige evidencia rastreada por git, excepción de dominio con nombre, criterio operativo de delegación.

## Antes (2026-07-11, el lazo labs↔Jidoka — CERRADO)

- **✅ Lazo de sincronización labs↔Jidoka MERGEADO y LIBERADO (`v0.11.0-beta`, ADR 0012).** PR #14 mergeado; [release publicado](https://github.com/ArmandoMedina/jidoka/releases/tag/v0.11.0-beta). *La lección sube, la máquina baja*: sello de versión (`tools/jidoka-motor.json`) + SSOT (`tools/version.txt`); `-Actualizar` de tres vías por hash; aviso de divergencia (`estado-motor.ps1`); canal de subida (`reportar-leccion.ps1`); costura `.local`. Smoke 32/32.
- **✅ SGI = primer consumidor, MERGEADO** (SGI PR #57 squash a `master`, ADR 0036): sello retroactivo + canal + reporte de divergencia + 3 lecciones draft en `SGI/qa_runs/lazo-sync-20260711/` (pendientes de presentar con `reportar-leccion.ps1`). El aviso de divergencia se probó a sí mismo (SGI 0.10.1-beta detectado atrás de 0.11.0-beta).

## Antes (2026-07-11, cierre de la sesión de vitrina)

- **Todo MERGEADO y PUBLICADO hasta `v0.10.1-beta`.** PRs #1–#12 en MERGED; `main` limpio. Sprints 0–2 completos; Sprint 3 Fases 3.A/3.B publicadas; Homologación Etapa 1 + cosecha de SGI publicadas (`v0.9.0`/`v0.10.0-beta`, ADRs 0010/0011).
- **Sesión de hoy (vitrina, PR #12 → `v0.10.1-beta`):** README reescrito con **7 lectores en frío** como evidencia (Gemba de prosa en `qa_runs/lector-en-frio-readme-20260711/`); **GIF del gate mordiendo** en el README — render fiel de una corrida REAL en SGI (`docs/assets/gate-bloqueando.gif`, procedencia en `docs/guias/guion-gif-del-gate.md`, evidencia en `qa_runs/gif-gate-20260711/`); **SimGhostInputs (público) nombrado y linkeado** como evidencia del linaje (grieta 4 avanzada); quickstart curado tras fact-check hostil (el snippet anterior NO bloqueaba — se reprodujo y se probó la cura en clon); doc-drift interno curado en cascada (versión, tabla de sprints, `docs/sprints/`, `kanban/README`, `empezar-de-cero`, ROADMAP).
- **Lote de hallazgos REGISTRADO en `ROADMAP.md` para una sesión dedicada** (el cliente lo resolverá con una sesión Opus corriendo el método): el instalador que pregunte el arquetipo interactivo (Fase 3.C), el quickstart como caso end-to-end de `probar-gate.ps1` (Fase 3.C), el matiz de la cita Airbus en doctrina (backlog), y las ideas de los lectores sin destino aún (el "GIF del momento del cliente" — un Gemba visto por sus ojos — cuando exista la guía de cero).
- **Panorama registrado en el backlog** (con fuentes): **OpenWiki** (LangChain — complemento, no competidor; jamás meter doc auto-generada dentro de la ley) y **GBrain** (Garry Tan — el "pregúntale al proyecto" en lenguaje llano para no-técnicos, candidato a futuro sobre las docs curadas de este y todo repo sembrado).
- **HOMOLOGACIÓN — Etapa 2, lo que falta: TF (tracker-financiero).** El único lab pendiente de adoptar el núcleo; en su rama, reversible, conservando su casting como personas y su config-instancia. Su plan propio. Sus pendientes viven en SU HANDOFF.
- **El lazo de sincronización labs↔Jidoka — DISEÑO REGISTRADO, pendiente de plan** (pedido del cliente al cierre): *la lección sube (issue `leccion.md` → Jidoka arregla con su ritual), la máquina baja* (sello de versión sembrado + modo `-Actualizar` del instalador que re-siembra solo el motor, nunca la instancia + aviso de divergencia en el hijo). Detalle completo en `ROADMAP.md` → Fase 3.C. SGI es el primer consumidor.
- **Sprint 3 · Fase 3.C — lo diferido** (ver `ROADMAP.md`): `doc-only`, CLI npm + SSOT de versión + release-CI, multiplataforma, barreras code-first, dogfood del ADR 0003, + los dos ítems nuevos del fact-check.
- **Grietas de auditoría:** 1 CERRADA (Fase 2·B) · 2 abierta (`no-memorias` no cubre Bash; confesada como frontera) · 3 aceptada como límite v0 · 4 AVANZADA (SGI público; el resto a Sprint 4) · 5 abierta (disparos sin cablear).
- **Sprint 4 — Beta estable**: guías completas (la de empezar-de-cero es esqueleto), presentación pública, `v1.0` cuando corra end-to-end en un repo ajeno.

## Autorizaciones vigentes del cliente (dichas con nombre)

- **Publicar releases de GitHub** (2026-07-10): "Eres libre y autorizado para publicar versiones" — tag + release del cierre no necesita re-autorización.
- **Merges de PR y cambios de configuración/permisos**: SIGUEN necesitando orden nombrada cada vez ("no me muevas configuración", dicho explícito).

## Checklist humana (el cordón es tuyo)

- [ ] **Social preview** (solo se puede desde la UI) — receta en `ROADMAP.md` → *Vitrina pública* ⏳2. Con el GIF del gate ya hay material visual para derivar la imagen.
- [ ] **Dos decisiones que solo tú puedes tomar**: el párrafo en inglés del README y el ADR de la licencia (MIT vs copyleft) — argumentos en `ROADMAP.md` → *Vitrina pública* ⏳4 y ⏳5.
- [ ] **La sesión Opus del lote de hallazgos** — cuando tengas límite fresco: los pendientes están en `ROADMAP.md` (Fase 3.C nuevos + backlog), cada uno con contexto para retomarse sin re-explicación.

## Qué sigue (en orden de valor — detalle en ROADMAP.md)

1. **Homologación Etapa 2 — TF adopta el núcleo** (el único lab que falta; cierra la homologación).
2. **El lote de hallazgos del ROADMAP** en sesión dedicada corriendo el método.
3. **Sprint 3 · Fase 3.C** (por valor: CLI npm/SSOT de versión, multiplataforma) y **grietas 2 y 5**.
4. **Sprint 4 — Beta estable** (incluye el resto de la grieta 4: evidencia pública del linaje).

---

# Archivado 2026-07-21 (merge con main v1.27.0 — la app de la tubería, PRs #120/#121/#123)

> Secciones ÍNTEGRAS del HANDOFF de main al momento del segundo merge del sprint FLU-1 (la sesión de la app las escribió sin el contrato del relevo; aquí viven completas).

## Dónde estamos (2026-07-21 noche — Sprint "La app de la tubería" COMPLETO · MERGEADO Y LIBERADO `v1.27.0`)

**El sprint "La app de la tubería" TERMINÓ (7/7 rebanadas), verde en local, en la rama `sprint/app-tuberia-20260721` (14 commits propios `692e8a4`→`b0626fa`, apilados sobre los 6 del legado = 20 sobre `main`).** La superficie del gobierno dejó de ser comandos de VS Code y es ahora una **app de escritorio Tauri fiel a la maqueta** (ADR 0048): 49 piezas con estado real, bandeja, formulario que escribe de verdad y modo avanzado que firma derivando de `git config`. La extensión se retiró completa. Récord completo: [`docs/sprints/sprint-21-app-tuberia-entrega.md`](docs/sprints/sprint-21-app-tuberia-entrega.md) (con el cuadro de cierre). Evidencia: [`qa_runs/app-tuberia-20260721/LOG.md`](qa_runs/app-tuberia-20260721/LOG.md).

**Los 2 PRs — MERGEADOS el 2026-07-22 con orden nombrada del cliente ("pr y merge, release y poda, autorizado"):**
- **PR #121** — la app `sprint/app-tuberia-20260721` a `main`. **MERGEADO** (merge `0d921ac`, CI verde: la liga colgante curada en el cierre pasó el gate).
- **PR #120** — el sprint legado. GitHub lo marcó **MERGED** automáticamente al entrar #121 (su rama quedó 100% contenida en la de la app). `v1.26.0` queda **sin tag propio a propósito** (subsumida en `v1.27.0`, mismo precedente que `v1.24.0` dentro de `v1.25.0`).
- **Release `v1.27.0`** cortado: tag anotado + GitHub release con el instalador NSIS como asset. **Poda** hecha (ramas del sprint y del legado borradas, local y remoto). `sprint/pilar-de-flujo-20260721` (PR #122) sigue viva — es el sprint paralelo FLU-1, no era parte de esta orden.

**La app y su instalador:**
- Código: `app/` (Tauri v2; `ui/index.html` = la maqueta viva, `src-tauri/` el puente Rust). Es **Jidoka-only** (no se siembra).
- El `.exe` y el instalador NSIS (`app/src-tauri/target/release/bundle/nsis/jidoka-tuberia_1.27.0_x64-setup.exe`, 1.86 MB) son **locales, NO versionados** (`app/src-tauri/target/` en `.gitignore`). El instalador sube como asset del release cuando se corte.

**Cola de decisiones del cliente:**
1. ~~orden nombrada — merge #120~~ ✅ **HECHO 2026-07-22** (subsumido en #121, marcado MERGED).
2. ~~orden nombrada — merge #121 + tag/release `v1.27.0` + asset~~ ✅ **HECHO 2026-07-22** (merge `0d921ac`, release con el instalador como asset).
3. **[PENDIENTE]** **Gemba completo end-to-end** (flujo del glosario: crear glosario por fuera → bandeja → parametrizar desde el formulario → candado → ver a la IA rebotar; sin código ni terminal — los pasos están en la entrega). La fidelidad de R2 ya la aprobó; el flujo completo NO lo ha corrido todavía.
4. ~~¿MAJOR (`v2.0.0`) en vez de `v1.27.0`?~~ ✅ **RESUELTO por la orden del release 2026-07-22**: el cliente ordenó liberar el corte tal cual — quedó `v1.27.0` con el breaking confesado en el CHANGELOG.
5. **[PENDIENTE]** destino de la copia scratch `.jidoka/maqueta-tuberia.html` (dice "SAP", quedó vieja; la spec real vive en `docs/analisis/`).

**Pendientes técnicos (nada bloquea):**
1. ~~Curar la liga colgante `linterna-extension` en `tools/ligas.json`~~ — **CURADO en el cierre** (entrada retirada; `probar-ligas` 25/25 verde, CI de #121 verde esperado tras push).
2. Certificado Authenticode del `.exe` (SmartScreen; historial Bitdefender).
3. Autoría de ligas en la app (capacidad futura; el gate `estado-ligas.ps1` sigue vivo, la autoría asistida se perdió al retirar `ligas.js`).
4. Reconciliar y alta-de-agente aún cartón.
5. Multiplataforma del motor (`pwsh`, macOS/Linux) — fase 2.
6. Bajar `v1.26`/`v1.27` a los labs tras el release.
7. Atlas de los tools nuevos (`tuberia-datos`, `parametrizar`, `override`).

**Regla de modelos (orden del cliente):** Fable orquesta y pone criterio en el hilo; opus/sonnet/haiku hacen TODA la mecánica en subagentes. Ningún subagente en Fable.

---

## Dónde estuvimos (2026-07-21 tarde — Sistema configurable CONSTRUIDO + giro de superficie a la app Tauri)

**El sprint "sistema configurable, fase 1" está construido completo y verde en la rama `sprint/sistema-configurable-20260721` (6 commits sobre `main`):**

1. `587e133` — **R1**: los 3 ADRs (0045 identidad · 0046 contratos/regímenes · 0047 meta-gobierno) + CFG-1, y el rename que retira la marca "SAP" por `estatuto`.
2. `afde41b` — **R2**: la bandeja "pendiente de parametrizar" (`tools/bandeja.ps1`, 15/15).
3. `3e6ad5f` — **R3**: el estatuto del ritual (`tools/estado-ritual.ps1`, 13/13).
4. `4b5fd84` — **R5**: el candado IA (hook `PreToolUse`, `.claude/hooks/candado-pretooluse.ps1`, hooks 42/42, `deny-vs-ask` cableado).
5. `ba522fe` — **R4**: el formulario para parametrizar (webview fiel a la maqueta en la extensión).
6. `c9bf5c9` — **R6**: el modo avanzado (firma + reclasificar, extensión 26/26).

Todo verde; evidencia en [`qa_runs/sistema-configurable-20260721/LOG.md`](qa_runs/sistema-configurable-20260721/LOG.md).

**Pero el Gemba del cliente REPROBÓ la superficie.** El motor quedó bien; la cara quedó fragmentada en comandos de VS Code (paleta + clic derecho + webviews sueltos) — lo contrario de lo que el cliente validó en 6 Gembas: **la maqueta como UNA app navegable**. La retro del transcript encontró la causa en el plan: decía a la vez "la maqueta ES la spec visual" y "no se porta", y esa exclusión de la cara visible **nunca se le resaltó** al cliente al aprobar.

**Decisión del cliente (2026-07-21):** la superficie del gobierno es una **app de escritorio Tauri fiel a la maqueta** — una sola ventana navegable, no comandos dispersos. Registrada en el **[ADR 0048](docs/decisions/0048-superficie-app-tuberia.md)** (supersede el 0044 **en la superficie**; el principio "la UI autora, el gate ejecuta" sigue vivo). El motor PowerShell del sprint pasado (R1/R2/R3/R5) es la **base de la app**; la extensión se retira.

**Sprint nuevo "La app de la tubería"** con plan aprobado en [`docs/sprints/sprint-21-app-tuberia-plan.md`](docs/sprints/sprint-21-app-tuberia-plan.md):
- **R1** — cerrar el legado + la ley nueva (ADR 0048, CHANGELOG `v1.26.0`, HANDOFF reconciliado, PR del sprint legado).
- **R2** — el cascarón fiel con **GEMBA TEMPRANO** (doble clic al `.exe` a ver la maqueta tal cual, antes de cablear datos).
- **R3** — las lecturas (datos reales a la app).
- **R4** — las escrituras (parametrizar de verdad).
- **R5** — el modo avanzado real (firma + candado desde la app).
- **R6** — retiro de la extensión (VS Code limpio).
- **R7** — empaquetado + release `v1.27.0`.

**Regla de modelos (orden del cliente):** Fable orquesta y pone criterio en el hilo; opus/sonnet/haiku hacen TODA la mecánica en subagentes. Ningún subagente en Fable.

**Pendientes del cliente (nada bloquea al agente):**
1. **Orden nombrada para el merge del PR del sprint legado** (`sprint/sistema-configurable-20260721` a `main`, corta `v1.26.0`).
2. **Gemba de fidelidad en R2** (aprobar la cara de la app con sus ojos antes de cablear datos) — es el criterio de "hecho" de esa rebanada.

---

## Dónde estuvimos (2026-07-22 — Sprint 26 «La 2.0 estable», la construcción · archivado del HANDOFF el 2026-07-23)

Plan-contrato [`sprint-26-la-2-0-estable-plan.md`](sprints/sprint-26-la-2-0-estable-plan.md), nacido de 4 escaneos `arquitecto` ([`escaneo-camino-2.0-202607.md`](analisis/escaneo-camino-2.0-202607.md); 8 ítems al ROADMAP). R1 corte honesto (os `win32`, badge gateado, aviso del muro) · R2 fiabilidad (`probar-gemelas` estrenó en rojo con 3 drifts reales curados; `auditar` fail-closed; salvavidas ampliado) · R3 superficies (`conformidad-docs.html` interino; [`matriz-carriles-202607.md`](analisis/matriz-carriles-202607.md)) · review adversarial 2M+2B curados. Evidencia rojo→verde: `qa_runs/la-2-0-estable-20260722/LOG.md`.

---
