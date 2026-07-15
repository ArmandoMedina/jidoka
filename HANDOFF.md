# HANDOFF — relevo entre sesiones

> Estado en vuelo y pendientes. **Se llena al cerrar**, **se lee y se limpia al abrir.** Nada de memorias de la IA — todo va aquí.

## En una frase

**Jidoka** — el Sistema de Producción Toyota para agentes de IA: fusión de doctrina + método + ritual de sprint. Estable en `v1.x` (salió de beta en `v1.0.0`). Instalador PowerShell + CLI `npx jidoka-method` construido (pendiente `npm publish`). Se construye por sprints, usando su propio ritual (dogfooding).

## Dónde estamos (2026-07-14 — Sprint Descubre CONSTRUIDO · pendiente merge + release `v1.13.0` + demo de campo)

**Sesión del 14-jul (tarde): dos entregas.**

1. **`v1.12.1` — dogfooding al día (CERRADO Y LIBERADO).** La nave nodriza respeta su doctrina: `## El casting` sembrado en `product/recursos-del-proyecto.md` (nombres neutrales a propósito — decisión del cliente: la ruta del usuario recién sembrado), `probar-sembrar` en el preflight de `publicar.ps1` (+ caso invariante en `probar-publicar`: todo `probar-*.ps1` debe estar en el preflight), listón `LOG.md` adoptado en casa (`qa_runs/dogfood-20260714/LOG.md`, primer uso propio). PR #62 mergeado, [release v1.12.1](https://github.com/ArmandoMedina/jidoka/releases/tag/v1.12.1). Issues registrados: [#63](https://github.com/ArmandoMedina/jidoka/issues/63) (lección: la regla de tiers de modelo depende de la iniciativa del agente, `leccion`+`regla-2-3`) y [#64](https://github.com/ArmandoMedina/jidoka/issues/64) (aviso "no hay sello" en la nave nodriza, cosmético, `regla-2-3`).
2. **Sprint Descubre — la capa de consultoría (`v1.13.0`, ADR 0031) — CONSTRUIDO en rama `sprint-descubre`, PENDIENTE: merge (orden nombrada) → release → demo de campo.** Nace de 3 diagnósticos sobre chats reales (2 despliegues con QUÉ borroso que patinaron vs. el caso de éxito) + investigación de metodologías: el QUÉ vive en **ejemplos**, no en docs; **STOP no es comprensión**; a veces la autoridad es **un tercero sin IA**. Piezas: comando `/jidoka:descubre` (3 nieblas + juez de verdad, rondas fijas, filtro Mom Test escrito, @-include del brief — la lectura se inyecta), campos del descubrimiento en `PRODUCT_BRIEF.md` (caso citable · métrica con número · autoridad · criterio de "hecho" · apetito · no-metas · aprobación), plantilla `kit-entrevista.md` (kit portátil para el experto tipo Marcelo: autoridad, no usuario), disparo 14.º `aprobacion-nombrada` ("dale"/"a tu criterio" no cierran un QUÉ), ruteo desde `planea` R0. Plan-contrato: `docs/sprints/sprint-descubre-plan.md`.

**Evidencia (verde, esta máquina 2026-07-14):** `probar-disparos` 4/4 (**14** disparos, ROJO→VERDE) · preflight `-SoloVerificar` 8/8 · SSOT 1.13.0. LOGs: `qa_runs/dogfood-20260714/` y `qa_runs/descubre-20260714/`.

**Pendiente inmediato (gatillado por el cliente):**
1. **Merge del PR del sprint** (orden nombrada) → **release `v1.13.0`** (`publicar.ps1`, orden nombrada del release).
2. **El demo de campo** — criterio real de cierre (owner: cliente): correr `/jidoka:descubre` en un proyecto con niebla real; ver el brief sin huecos + el kit portátil; probar que un "dale" no cierra.
3. **Issues por registrar al cierre**: gate anti-placeholders del brief (regla 2-3) y **telemetría de lecturas del método** (pedido del cliente: contar qué docs lee la IA — post-hoc desde los transcripts JSONL o hook PreToolUse; regla 2-3).
4. La bajada de `v1.12.x`/`v1.13.0` a los labs (ventana aparte; el lab de reconstrucción SOLO cuando cierre la sesión del otro agente).

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

**Sesión que atendió la cosecha de issues del lazo (#40–#46). Todo mergeado y liberado; `main` limpio.** PR #48 mergeado (836b14d), [release `v1.10.0`](https://github.com/ArmandoMedina/jidoka/releases/tag/v1.10.0) publicado (suite verde en el preflight). Plan-contrato: `docs/sprints/sprint-brownfield-2-plan.md`. Los 7 issues **acusados uno por uno** (el 3er paso del lazo); #40/#42/#43 cerrados con el release, #41/#44/#45/#46 abiertos con `regla-2-3`.

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
