# Changelog — Jidoka

Formato: [Keep a Changelog](https://keepachangelog.com/es-ES/1.0.0/) · Versionado: [SemVer](https://semver.org/lang/es/).

## [1.8.0] — 2026-07-11

### El CLI `npx jidoka-method` (construido, listo para publicar) + párrafo en inglés

Dos piezas de distribución/presentación.

- **CLI npm** (`package.json` + `bin/jidoka-method.js`): un **wrapper Node** que reusa `tools/instalar.ps1` vía
  PowerShell (`pwsh` en Mac/Linux, `powershell` en Windows) en vez de duplicar el instalador. Subcomandos
  `init` / `actualizar` / `sellar`. **Probado en Windows** (siembra 76 archivos vía el wrapper); la ruta
  Mac/Linux (pwsh Core) **debería** funcionar pero **NO está verificada** — no afirmamos cross-platform sin
  evidencia. **`npm publish` pendiente** (necesita la cuenta npm del mantenedor); hasta entonces, usable en el
  repo con `node bin/jidoka-method.js init <ruta>`. **SSOT extendido**: `probar-version.ps1` ahora exige
  `package.json.version == version.txt` (el CLI no puede mentir sobre qué versión instala).
- **Párrafo en inglés** en el README (decisión del autor): un solo párrafo para el visitante anglófono —
  qué es Jidoka y por qué está en español a propósito. La maquinaria es language-agnostic.

## [1.7.1] — 2026-07-11

### Comunidad — `CODE_OF_CONDUCT.md` (Contributor Covenant 2.1 ES)

Archivo de salud de comunidad para el repo público (GitHub lo muestra en la pestaña de comunidad y da un
mecanismo neutro de moderación antes del primer conflicto con extraños). Contacto vía el perfil de GitHub del
mantenedor / issue del repo — **no publica un correo personal** (esa elección queda del autor; cambiable a
email si lo prefiere). No se siembra (cada repo tiene su propia política).

## [1.7.0] — 2026-07-11

### La estructura canónica — comandos namespaced, rol neutral el mecanismo (ADR 0023)

Cierra la **segunda mitad** del drift estructural (ADR 0015 #3): faltaba declarar cuál FORMA es canónica entre
Jidoka y los labs (que divergían, con cruft — SGI tenía los mismos comandos y skills duplicados).

- **Comandos namespaced** (`.claude/commands/jidoka/*`, `/jidoka:*`) = canónico: un método instalado no debe
  colisionar con los comandos propios del proyecto anfitrión.
- **El rol neutral es el mecanismo** (la ley referencia roles); el **nombre del skill es sabor de instancia** —
  neutral (Jidoka) o persona (labs, si declaran su asiento neutral; ADR 0035). La autoridad la da la ley, no el
  nombre.
- **Los labs convergen la forma, conservan el sabor** — usando la exclusión (ADR 0022) para su familia de
  skills. Jidoka ya es namespaced+neutral: no cambia; el trabajo es reconciliar los labs.

## [1.6.0] — 2026-07-11

### Guía — "Mantener el motor al día" (el canal de bajada, documentado)

Cierra un hueco de doc: los mecanismos del lazo shippeados post-1.0 (`-Sellar`, `estado-motor -Detallado`,
`excluir`, el EOL-agnóstico, y `publicar.ps1`) no estaban en ninguna guía. `docs/guias/mantener-el-motor-al-dia.md`
(nueva, `estado: vigente`, **sembrada** a los labs) es la guía operativa para quien mantiene un repo instalado:
cuándo y cómo `-Actualizar`, leer la salida (`[ACTUALIZA]`/`[NUEVO]`/`[DIVERGE]`/`[EXCLUIDA]`), manejar
divergencias (`.jidoka-nuevo` / costura `.local`), declarar `excluir`, ver la divergencia fina con `-Detallado`,
y sellar con `-Sellar` (con su límite: no para repos atrasados). Más una sección para el mantenedor de Jidoka
(`publicar.ps1`). `probar-instalador.ps1` 45/45 (siembra + verificador de enlaces).
- **Fix `publicar.ps1`** (dogfood, cazado al cortar este release): el título derivado del CHANGELOG llevaba
  comillas dobles y PS 5.1 rompe el paso de un argumento con `"` embebido a `gh`. Se **sanea** el título (las
  notas, que van por `--notes-file`, las conservan). Caso nuevo en `probar-publicar.ps1`.

## [1.5.1] — 2026-07-11

### Doctrina — matiz de la cita Airbus (fact-check)

`doctrina/03-aviacion.md`: los límites duros del envelope Airbus (la analogía del `deny`) valen en **Normal
Law**; bajo fallas el avión degrada a **Alternate/Direct Law** y las protecciones se pierden — el piloto sí
puede exceder el envelope. La 'dureza' del `deny` es condicional al modo. Con la lección para el gate: **hasta
un `deny` duro tiene modo degradado; confiésalo** (como las *fronteras del muro*). Registrado como cita #9 en
`doctrina/citas-verificadas.md`. Doc-only.

## [1.5.0] — 2026-07-11

### La lista de exclusión del hijo — el lazo no re-agrega lo que el hijo no quiere (ADR 0022)

Cierra la mitad "re-agregado" del drift estructural (ADR 0015 #3), lección de la ventana de bajada: en cada
`-Actualizar` los labs rehacían los mismos back-outs (`probar-gate`, `andon.yml`, comandos namespaced, skills
genéricos) porque el lazo los re-agregaba como piezas nuevas.

- **El sello gana `excluir: [rutas]`**: las piezas de mecánica que el hijo declara que **no quiere**.
  `-Actualizar` no las re-agrega, no las toca (reporta `[EXCLUIDA]`); `-Sellar` las salta; ambos **preservan**
  la lista entre bajadas. Sin `excluir` (sellos viejos): comportamiento idéntico (retro-compatible).
- **Seguro**: solo omite, nunca borra ni pisa. El hijo declara una vez y el lazo lo honra siempre.
- Evidencia: `probar-instalador.ps1` 45/45 (3 casos nuevos). **Siguiente**: los labs añaden su `excluir` una vez
  → su próxima bajada no pedirá back-outs.

## [1.4.0] — 2026-07-11

### El lazo es agnóstico al fin de línea — `Get-MotorHash` normaliza a LF (ADR 0021)

Bug estructural del lazo, cazado al bajar el batch a los labs: **un hijo con `eol=lf` divergía en TODAS las
piezas** porque el three-way comparaba `hash(LF del hijo)` vs `seed(CRLF de Jidoka)` — nunca casan, aunque el
contenido sea idéntico. TF (LF) reportó `0 al día | 62 divergen`; SGI (CRLF, casa Jidoka) funcionó.

- **`Get-MotorHash` hashea el contenido normalizado a LF** (quita `0x0D` antes de SHA256) → el hash es
  agnóstico al fin de línea. Aplicado en `instalar.ps1` (`-Actualizar`/`-Sellar`/sembrado), `estado-motor.ps1`
  (`-Detallado`) y `probar-instalador.ps1`. La política de EOL es del hijo, no de Jidoka.
- **Caso nuevo en `probar-instalador.ps1`** (42/42): convierte un hijo entero a LF y verifica que `-Actualizar`
  reporta **0 divergencias** (antes del fix: todo divergía).
- **Consecuencia**: los sellos de SGI/TF (hashes CRLF de la bajada previa) se re-clasifican una vez; la bajada
  del batch se **rehace** con el instalador arreglado en ambos labs.

## [1.3.0] — 2026-07-11

### El release se deriva del SSOT — `publicar.ps1` (ADR 0020)

Quita el tipeo manual de versión del ritual de release: la versión se escribe UNA vez en `tools/version.txt`
(el SSOT) y el tag, el título y las notas del release **derivan** de ahí + del CHANGELOG.

- **`tools/publicar.ps1`** (Jidoka-only): lee la versión del SSOT, extrae su sección del CHANGELOG (leída como
  UTF-8, para no corromper acentos/flechas en las notas), corre **la suite completa** de self-tests
  (evidencia-no-palabra: no publica un motor roto, bajo `ErrorActionPreference=Continue` para que un warning
  benigno de git no aborte), y crea el tag + release. `-DryRun` muestra todo sin correr nada; `-SoloVerificar`
  corre el preflight (suite) sin publicar. *(El estreno cazó un bug del propio `publicar.ps1` —el `Stop` volvía
  fatal un warning `LF→CRLF`— antes de crear el tag: `prueba-de-humo-del-gate` en acción.)*
- **`tools/probar-publicar.ps1`** (Jidoka-only, 4 casos): prueba de vida del `-DryRun` (deriva el tag del SSOT,
  no crea tags). Junto con `probar-version` quedan CI-gateados en Jidoka vía una guarda `Test-Path` en
  `andon.yml` (se saltan en un hijo que no los tiene).
- **Dogfood**: este `v1.3.0` se cortó con `publicar.ps1` — su primera corrida real es su prueba de vida.
- Primer peldaño del CLI npm (cuando se retome): la versión ya está centralizada y derivable.

## [1.2.0] — 2026-07-11

### El lazo ve la divergencia — sello bootstrap clasificador + `estado-motor -Detallado` (ADR 0019)

Ejecuta dos de las cuatro lecciones de la segunda cosecha (ADR 0015): mejoras a la mecánica del lazo, sin tocar
los labs. Son la herramienta de la propia bajada — conviene tenerlas antes de la próxima ventana de bajada.

- **`instalar.ps1 -Sellar`**: sella un hijo que convergió a mano **clasificando cada pieza** contra el Jidoka
  actual — pristina (== Jidoka) → registrada; customizada (!= Jidoka) → omitida de la semilla, así el próximo
  `-Actualizar` la ve DIVERGE y la **preserva**. Generaliza en la máquina el arreglo que en Sprint B se hizo a
  mano en SGI/TF (mejor que asumir-pristina —el bug que casi pisa SGI— y que semilla-vacía —que no actualiza
  lo pristino—).
- **`estado-motor.ps1 -Detallado`**: compara **pieza por pieza (por hash)** contra el motor de Jidoka y lista
  las que DIVERGEN o faltan; la versión sola era de grano grueso (decía "al día" aunque una pieza divergiera).
  El mensaje de versión pasa a *"declara la versión X"* — más honesto.
- Evidencia: `probar-instalador.ps1` 41/41 (6 casos nuevos). **Follow-through**: ambas son mecánica → bajan a
  SGI y TF en la próxima ventana de bajada, y el re-sellado usará `-Sellar`.

## [1.1.1] — 2026-07-11

### Fix — el matcher Bash de `no-memorias` bloqueaba lecturas con `2>&1`/`2>/dev/null`

Regresión de `v1.1.0` (ADR 0018), cazada por dogfooding minutos después de publicar: el token `>` de la lista
de escritura casaba con `2>&1` y `2>/dev/null` (redirecciones de **stderr**, no escrituras a memoria), así que
un comando de **lectura** común (`cat …/memory/x 2>&1`) se denegaba en falso.

- **Fix**: la redirección se maneja aparte del `>` suelto — solo cuenta como escritura una redirección **cuyo
  destino es la ruta de memoria** (`>`/`>>` seguido de la ruta, sin cruzar otro redirect/pipe), o un cmdlet de
  escritura (`Set-Content`/`Out-File`/`cp`/`mv`/`tee`…) con la ruta. `2>&1`/`2>/dev/null` ya no cuentan.
- Dos casos de regresión nuevos en `probar-hooks.ps1` (17/17): lectura de memoria con `2>&1` y con
  `2>/dev/null` → **allow**; las escrituras siguen **deny**.

## [1.1.0] — 2026-07-11

### El muro cumple lo que promete — grietas 2 y 5 cerradas con invariantes testeables (ADR 0018)

Endurece la promesa central (*los gates son deterministas, no teatro*) cerrando dos huecos confesados de la
auditoría externa, con tests y no con prosa.

- **`no-memorias` cubre Bash** (grieta 2, cerrada en parte): el hook inspecciona `tool_input.command` y deniega
  la **escritura** a la memoria de Claude vía Bash (`Set-Content`/`Out-File`/redirección `>`/`cp`/`mv`/`tee`);
  la lectura/recall no se bloquea. Matcher `Write|Edit` → `Write|Edit|Bash`. Cuatro casos nuevos en
  `probar-hooks.ps1` (15/15). **Residual honesto** (confesado en `andon/README.md`): aliases y rutas ofuscadas
  evaden el matcher; server-side no es gateable (la memoria es conducta del agente, no estado del repo).
- **El registro de disparos cableados** (grieta 5, cerrada): cada disparo de `kit/.jidoka/disparos/` declara
  `Cableado en: <punto>` (que nombra su slug) o `Catalogo-solo: <razón>`. `tools/probar-disparos.ps1` (nuevo,
  4/4, con caso sintético de rot) verifica que ningún cableado se caiga de su punto — la grieta real era la
  falta de verificación, no de cableado. Tolerante a puntos no sembrados en un hijo (los omite con aviso
  visible). Registrado en CI (`andon.yml`) y en el manifiesto (`mecanica`); `probar-instalador` 35/35.
- **Follow-through**: el hook y `probar-disparos` son mecánica → bajarán a SGI y TF por `-Actualizar`.

## [1.0.0] — 2026-07-11

### Jidoka sale de beta — el método corre end-to-end en repos ajenos (ADR 0017)

Se cumple, **con evidencia**, la vara de 1.0 del ROADMAP: *el método completo corre end-to-end en un repo
ajeno*. El programa hacia 1.0 lo remató bajando el núcleo a **dos labs reales** por el lazo de sincronización.

- **Los dos labs bajaron el núcleo `0.13.0-beta`** (ADR 0015): **SimGhostInputs `v2.6.0`** (Python) actualizó
  el núcleo y curó un bug del sello; **tracker-financiero `v0.2.0`** (JS/PWA) se cableó al lazo (sello + canal
  de subida + `core.hooksPath`). Ambos PRs con **CI verde server-side** —el `audit` de blast-radius y el
  `gate-smoke` bloqueando de verdad, self-tests verdes— y evidencia en el `qa_runs/` de cada lab. Lo
  code-first se preservó sin pisar una pieza.
- **Segunda cosecha por el lazo** (ADR 0015): el mecanismo **probado en producción**; cuatro refinamientos que
  suben (generalizar el sello bootstrap pristina-vs-customizada, `estado-motor -Detallado` por-hash, el drift
  estructural núcleo↔labs, la épica `.local` code-first) quedan **registrados post-1.0** — ninguno bloquea.
- **Licencia MIT consciente** (ADR 0016): se mantiene MIT sobre copyleft, ahora como decisión razonada con su
  camino no tomado — no herencia.
- **`tools/version.txt` → `1.0.0`** (sin `-beta`). Alcance **1.0 funcional**: lo público (social preview,
  párrafo en inglés, `CODE_OF_CONDUCT`), el CLI npm/SSOT, multiplataforma y la reconciliación code-first vía
  `.local` se difieren **explícitos** a post-1.0 (ROADMAP).
- Evidencia: suite completa verde (`probar-version`/`gate`/`hooks`/`instalador`/`auditor` + `auditar` +
  `verificar -Base main`); required check `andon` verde en el PR de release.

## [0.13.0-beta] — 2026-07-11

### Jidoka listo para 1.0 — los cuatro bloqueantes de "corre en un repo ajeno" (ADR 0014)

Cierra los bloqueantes duros del criterio de 1.0 (*el método corre end-to-end en un repo ajeno*). Alcance **1.0 funcional**: lo público y el CLI npm quedan post-1.0.

- **El instalador pregunta el arquetipo** (`tools/instalar.ps1`): si no pasas `-Arquetipo` ni `-Yes`, menú interactivo (`docs-as-code`/`code-first`); con `-Yes` cae a `docs-as-code`. Antes el default silencioso sembraba el arquetipo equivocado a un repo code-first.
- **El método se siembra** (fin de los enlaces muertos): el manifiesto ahora siembra `kanban/` + `andon/` + `doctrina/` + la guía de entorno como `mecanica` → el hijo es autocontenido. Un **verificador de enlaces** en `probar-instalador.ps1` lo vuelve invariante (ningún doc sembrado cita un doc de método ausente).
- **Fixture del quickstart** (`probar-gate.ps1`): un caso que ejercita el flujo real commit→verificar por git, replicando el paso 3 del README (ADR sin listar → `[BLOQUEA]`; listarlo → pasa). La demo copy-paste no se rompe en silencio.
- **Guía `docs/guias/empezar-de-cero.md` completa** (`estado: vigente`): walkthrough de instalación desde cero verificado contra el flujo real.
- Evidencia: `probar-instalador.ps1` 34/34, `probar-gate.ps1` 10/10, suite completa verde.

## [0.12.0-beta] — 2026-07-11

### Primera cosecha por el lazo — tres lecciones de campo absorbidas (ADR 0013)

La primera cosecha que pasa **por el canal** que el lazo (ADR 0012) abrió — la máquina en uso. SGI (primer consumidor) reportó lecciones de campo y la sesión destapó una meta-lección del cliente; tres maduraron a mejora de método.

- **`gemba-stop` exige evidencia rastreada por git** (`.claude/hooks/gemba-stop.ps1`): antes validaba por *mtime del working tree* y `qa_runs/` está gitignoreado → un archivo que nunca se commitea satisfacía el gate (Goodhart). Ahora solo cuenta la evidencia que `git ls-files -- qa_runs` rastrea (`git add -f`), alineado con el disparo `evidencia-no-palabra`. Self-test nuevo: bloquea evidencia no-trackeada, pasa la forzada al índice (`probar-hooks.ps1` 11/11).
- **Excepción de dominio con nombre para el mandato sintético** (`revisor-visual` SKILL, `gemba.md`, `verificacion.md`): "datos 100% sintéticos siempre" → **"sintético por defecto, salvo excepción de dominio cableada con nombre"** (disparo `excepciones-cableadas`) para cuando lo sintético no ejercita el artefacto (HUD/render sobre telemetría) — dato real fuera del repo, solo capturas entran, excepción nombrada.
- **Criterio operativo de delegación** (`kanban/roles.md`): sección nueva "Qué va a subagente vs qué se queda" con tabla al vistazo + la sesión del lazo como ejemplo trabajado. Vuelve operativa una regla que era principio disperso (meta-lección del cliente).

## [0.11.0-beta] — 2026-07-11

### El lazo de sincronización labs↔Jidoka (Sprint 3 · Fase 3.C — ADR 0012)

*La lección sube, la máquina baja.* El primer canal mecanizado para que un repo hijo baje correcciones del motor sin que las versiones diverjan. Regla dura: **la mecánica converge idéntica; la estética/instancia nunca se sobrescribe; la divergencia se detecta y se preserva, no se pisa.**

- **Sello de versión sembrado** (`tools/jidoka-motor.json`): el instalador escribe en cada hijo de qué versión de Jidoka viene su motor + el SHA256 de cada pieza. La fuente única es **`tools/version.txt` (SSOT)**, atada al tope del CHANGELOG por el self-test `tools/probar-version.ps1` para que el sello no mienta.
- **Modo `-Actualizar` con conciencia de tres vías** (`tools/instalar.ps1`, estilo `dpkg conffiles`): re-siembra SOLO la mecánica (`clase: mecanica`). Por pieza — ausente→agrega; `hijo==Jidoka`→al día; `hijo==hash sembrado`→actualiza; `hijo!=hash sembrado`→**divergencia** (no pisa, deja `<archivo>.jidoka-nuevo` y reporta). La instancia (ley, `product/`, HANDOFF, ADRs) nunca se toca.
- **Aviso de divergencia** (`tools/estado-motor.ps1`, sembrado): compara el sello contra un Jidoka alcanzable (`-Jidoka`/`$env:JIDOKA_HOME`) y avisa "al día / atrás". Aviso, no muro (exit 0).
- **Canal de subida** (`tools/reportar-leccion.ps1` + `docs/guias/reportar-leccion-a-jidoka.md`): el hijo reporta la lección al issue `leccion.md` de Jidoka en vez de parchear su motor local.
- **Costura `.local`**: `verificar.ps1` dot-sourcea `tools/verificar.local.ps1` si existe — el hijo extiende la mecánica (ruff/pytest) sin bifurcar el genérico; la vía para converger sin clobber.
- **Manifiesto**: cada pieza de motor marcada `clase: mecanica`. **Smoke `tools/probar-instalador.ps1`: 32/32** (siembra + sello + tres vías + aviso + `.local` + canal). SGI queda como primer consumidor del lazo.

## [0.10.1-beta] — 2026-07-11

### Vitrina — el README, aterrizado (PR #12)
- **README reescrito con lectores en frío como evidencia** (7 lentes: técnico escéptico, vibe-coder ×2, cliente no-técnico, fact-checker hostil, dev Mac/Linux, experta DX — corridas en `qa_runs/lector-en-frio-readme-20260711/`): los dolores del usuario antes de la marca (*¿Te suena?*, 5 viñetas), *Qué hace por ti* en positivo con glosario de una línea, requisitos explícitos (Claude Code; Windows/PS 5.1 hoy + qué sirve ya en Mac/Linux), techo de gasto por suscripción (verificado contra fuentes), aviación comprimida a Airbus/Boeing, *Empezar* como router por lector.
- **El GIF del gate mordiendo** (`docs/assets/gate-bloqueando.gif`): render fiel de una **corrida real** en SimGhostInputs — el agente toca la UI sin la guía de usuario → `[BLOQUEA] PUSH DETENIDO` → actualiza la guía → pasa. Evidencia cruda y generador en `qa_runs/gif-gate-20260711/`.
- **SimGhostInputs, público, se nombra y linkea** como evidencia del linaje (README + `docs/casos-de-exito.md`, retitulado *De dónde viene*) — avanza la grieta 4 de la auditoría externa.
- **El quickstart ahora bloquea de verdad** (hallazgo del fact-check, reproducido): el snippet anterior no commiteaba y el verificador no ve archivos sin commit — imprimía `Todo limpio`. El paso 3 curado se probó en clon (`[BLOQUEA]`, exit 1, limpieza incluida).
- **Doc-drift interno curado**: versión real (`v0.10.0-beta` vs el `v0.9.0` anunciado), tabla de sprints con versiones correctas + fila de homologación, índice de `docs/sprints/` descongelado (+4 filas y el hueco de planes sin archivar, confesado), `kanban/README` y `empezar-de-cero.md` al día, ROADMAP con grietas 1–3 en su estado real. El README ya no afirma que el instalador "pregunta" el arquetipo (es parámetro; el interactivo quedó en Fase 3.C). `andon/README` documenta el nombre real del required check.
- **Panorama al backlog**: OpenWiki (LangChain — complemento, no competidor) y GBrain (Garry Tan — "pregúntale al proyecto" para no-técnicos), con fuentes.

## [0.10.0-beta] — 2026-07-11

### Homologación · Etapa 2 — Cosecha de SGI (ADR 0011)
- **Auditoría "full join" contra un repo hijo real (SGI):** la maquinaria descendió byte-idéntica (hooks, `settings.json`, comandos, esquema de la ley); el hijo, en cambio, **corrigió y maduró** dos cosas que ascienden al método.
- **Token neutral en la ley:** `tools/blast-radius.json` baja `"rol": "Escribano"` → `"escribano"` (minúscula) en las 8 áreas, para **cumplir la propia regla** de `kanban/roles.md` (la ley usa el token genérico). Cosmético-seguro: ningún gate ramifica sobre ese literal — el único que ramifica busca `revisor-visual`; el resto solo lo interpola en el mensaje.
- **Tres maduraciones al casting neutral** (regla 2–3, cosechadas del hijo): `arquitecto-doc` gana "criterios Gherkin derivados de tests reales; si no hay test, se declara"; `escribano` gana "propone, no commitea; el humano aprueba" (alinea con "nada irreversible sin checkpoint"); `revisor-visual` gana la nota de regresión de snapshot en CI para lo medible (lo subjetivo sigue siendo checkpoint humano).
- Confirmado que **no hay lección de método del hijo que Jidoka desconozca**; los huecos restantes son de arquetipo *code-first* (barreras de stack, gate UX 3-capas, SSOT de versión), ya en el ROADMAP 3.C.

## [0.9.0-beta] — 2026-07-10

### Homologación · Etapa 1 — Jidoka como superset del método (ADR 0010)
- **Rumbo a una sola metodología** (no versiones paralelas entre Jidoka, SGI y TF). El diagnóstico de delta mostró que en el motor Jidoka ya es la versión más nueva; solo faltaban tres piezas de método para ser el superset y que los labs puedan adoptarlo sin regresión. Esta etapa las sube.
- **El asiento `devops`** al roster (`kanban/roles.md`): agente de plataforma/máquina (VMs, SSH, CI, deploys, secretos, `hooksPath`, branch protection), **no skill del repo** — como el orquestador y el desarrollador. Tres asientos no-skill ahora.
- **El modo desatendido, generalizado** (`kanban/desatendido.md` + comando **`/jidoka:desatendido`** + plantilla): las dos lanes `[agente]`/`[humano]`, prioridad declarada, click-it-down y las reglas duras (nada irreversible sin el humano; el agente **no edita sus propios gates**) — para cualquier trabajo autónomo, no solo auditar.
- **El modelo de casting neutral+persona** (`roles.md` → *Personalizar el casting*): la maquinaria usa roles neutrales siempre (ahí vive la única metodología); el nombre propio es una capa cosmética por repo. Dos repos con castings distintos corren el mismo método — cero paralelo, cero alias en runtime.
- Reconciliación de doctrina (anti-sobreingeniería): `devops` y `desarrollador` se documentan como **asientos, no skills** (respeta `asiento ≠ skill`); nada de maquinaria especulativa.

## [0.8.0-beta] — 2026-07-10

### Sprint 3 · Fase 3.B — Los arquetipos ejecutables + los templates de producto (ADR 0009)
- **El instalador pregunta el arquetipo y siembra distinto.** La matriz pieza×arquetipo deja de ser prosa (como en el ancestro) y vive como **manifiesto ejecutable** (`kit/.jidoka/instalar/manifiesto.json`) — el mayor valor de Jidoka sobre el starter.
- **Dos arquetipos** (poda consciente, decisión delegada-revisable — regla 2–3 contra el method-ficción): **`docs-as-code`** (grafo de notas) + **`code-first`** (`PRODUCT_BRIEF` en vez del grafo). `doc-only` **diferido** al ROADMAP hasta que un repo regulado real lo pida.
- **Los 12 templates de producto** portados del starter como librería *menú, no molde* (`kit/.jidoka/templates/producto/`: capacidad, módulo, dominio, ecosistema, solución, componente, spec técnica, modelo-de-datos, requerimiento, proceso, glosario, propuesta-gate-proceso) + **`PRODUCT_BRIEF`** con sección *Landscape* + el HANDOFF sembrado gana la columna **Validación**.
- Smoke del instalador a **12 casos** (los 2 arquetipos instalan, siembran distinto, y su gate sembrado pasa).

## [0.7.0-beta] — 2026-07-10

### Sprint 3 · Fase 3.A — El instalador mínimo que corre (ADR 0008)
- **Jidoka ya se puede instalar en otro repo.** `tools/instalar.ps1` (PowerShell, Windows-first) siembra el método —ritual + motor Andon— en un repo destino. Meta: el primer paso verificable hacia la 1.0 (*corre en un repo ajeno*, probable en las VMs del autor).
- **Sin duplicar la ley**: el instalador **lee el motor genérico del árbol de Jidoka** (`verificar.ps1`/`auditar.ps1` ya son data-driven) y solo cambia la ley por una **plantilla de arquetipo**. Un arquetipo en el MVP: **`docs-as-code`** (`kit/.jidoka/leyes/blast-radius.docs-as-code.json` + `kit/.jidoka/instalar/manifiesto.json`).
- **Regla dura NO CLOBBER**: nunca sobrescribe un archivo existente en el destino. Enciende `core.hooksPath`, crea stubs, guía la branch protection.
- **Smoke `tools/probar-instalador.ps1`** (9 casos): instala en un repo temporal, commitea, y corre los self-tests **sembrados** + `verificar` ahí — un instalador que siembra un motor roto se caza en su prueba de vida.
- La ley gana el área **`kit`**. `probar-gate.ps1` se hace **agnóstico al arquetipo** (se siembra y pasa en el repo instalado).
- Lo diferido (otros 2 arquetipos + matriz ejecutable, 12 templates de producto, multiplataforma, CLI npm + SSOT de versión + release-CI, barreras code-first, dogfood completo del ADR 0003) queda registrado en `ROADMAP.md` → Sprint 3, fases 3.B/3.C.

## [0.6.0-beta] — 2026-07-10

### Sprint 2 · Fase B — Los muros, cosechados de los casos de éxito (ADR 0007)
- **Jidoka alcanza a sus labs.** El descubrimiento de la sesión: los dos casos de éxito vivos ya tenían los muros probados en producción; se homologan hacia arriba (labs → Jidoka, ADR 0005), genéricos y anonimizados (frontera NDA: cero nombres propios ni términos del trabajo).
- **`review-stop`**: código sin `/code-review` frena el cierre. "Código" se lee de la ley (áreas con `revisa: true`), no hardcodeado. Marcador humano `.claude/.review-marker` (no auto-firma: el hook verifica el SHA del diff real).
- **`gemba-stop`**: cambio visual sin evidencia fresca en `qa_runs/` (mtime posterior) frena. Se auto-configura desde `rol: revisor-visual`; **dormido** en Jidoka (sin UI). Marcador `.claude/.gemba-marker`.
- **Auditor del grafo** (`tools/auditar.ps1`): frontmatter + wikilinks + Gherkin de capacidades `vigente` + huérfanas, modulado por estado. Corre en CI (`-Range base...HEAD -Bloquea`).
- **Dimensión `product_avisa`** en la ley (sincronía del grafo de `product/`) en los dos motores; **flag `revisa`** por área.
- **Grieta 1 cerrada**: los avisos suben al **summary del PR** (antes invisibles en un check verde).
- **Prueba de vida nueva**: `tools/probar-hooks.ps1` y `tools/probar-auditor.ps1` (los labs no tenían harness de hooks — invención de Jidoka), con casos que DEBEN bloquear.
- **Grafo `product/` sembrado**: dominio Método → módulos → capacidades RIT-1 (el ritual) y AND-1 (el muro), para que el auditor muerda (dogfooding).

## [0.5.0-beta] — 2026-07-10

### Sprint 2 · Fase A — El ritual Kanban ejecutable
- **El ritual deja de ser prosa y se vuelve máquina.** Cinco comandos en `.claude/commands/jidoka/`: **`/jidoka:arranca`** (abre leyendo el estado real — HANDOFF + `product/recursos-del-proyecto.md` + plan-de-trabajo + git — y fija las reglas duras de sesión), **`/jidoka:planea`** (la rebanada **R0 con STOP**: el QUÉ con criterios aprobado por el cliente antes de la primera línea de código), **`/jidoka:gemba`** (el demo desde el producto real, evidencia a `qa_runs/`), **`/jidoka:cierra`** (registra por caducidad, poda, `git add -f` de la evidencia, ritual de release) y **`/jidoka:que-sigue`** (propone en orden de valor, separando lo que decide la IA de lo que firma el cliente).
- **Las cuatro skills-asiento** (`.claude/skills/`): `escribano`, `validador`, `revisor-visual` y `arquitecto-doc` (opcional, doc-heavy). Cada `SKILL.md` lleva sus límites ("lo que NO hace") de `kanban/roles.md`, la sección **Entorno de 5 líneas embebida** (porque los subagentes no leen la config global) y la declaración de que **no son `subagent_type`**.
- **La ley crece a 7 áreas** con `ritual` (`.claude/commands/*` y `.claude/skills/*` avisan CHANGELOG — el output del sprint queda bajo el propio Andon, dogfooding). El self-test sube a **7 casos**.
- **Zanjada la contradicción del plan efímero** (deuda del ADR 0005): **ADR 0006** — el plan-de-trabajo vive en `/.jidoka/plan-actual.md`, fuera de git pero persistente (sobrevive la compactación); patrón `.gitignore` anclado `/.jidoka/` para no ignorar el kit.
- Los muros deterministas (gemba-stop, review-stop, auditor del grafo, grietas de auditoría) quedan para la **Fase B** (`v0.6.0-beta`).

## [0.4.0-beta] — 2026-07-10

### Auditoría externa + vitrina pública
- **Primera auditoría de terceros del repo** (evidencia: corrió el self-test 6/6 y comparó contra el panorama 2026 — Spec Kit, BMAD, Agent OS). Veredicto citable: el diferenciador real de Jidoka es el muro server-side; ninguno de los frameworks grandes tiene uno. Las **5 grietas** encontradas quedaron registradas con destino en `ROADMAP.md` → *Grietas de la auditoría externa* (avisos invisibles en CI verde; `no-memorias` no es muro por la propia ley; co-ocurrencia gameable; el linaje privado es palabra; 11 de 12 disparos sin cablear).
- **Ko-fi cableado en tres puntos**: `.github/FUNDING.yml` (botón *Sponsor*), badge en el README e invitación al café en la línea de la licencia.
- **Template de PR** (`.github/PULL_REQUEST_TEMPLATE.md`): el punto de inyección de disparos en PRs que `andon/README.md` prometía — evidencia-no-palabra, ADR→índice, `no-verify-es-teatro`. Corto a propósito (anti click-para-pasar).
- **Templates de issues**: `reporte.md` (para no-programadores, pide evidencia) y `leccion.md` (la homologación abierta al público, con regla 2–3 y `frontera-nda` embebidas).
- **ROADMAP** gana dos secciones con receta completa: *Vitrina pública* (GIF del gate mordiendo con guion de una toma, social preview, CODE_OF_CONDUCT, y las dos decisiones abiertas del cliente: párrafo en inglés y ADR de la licencia) y *Grietas de la auditoría*. **HANDOFF** podado a puntero (lo atendido se borró; el detalle vive en el ROADMAP).

### El exprimido final del linaje (ADR 0005)
- **Jidoka es la fuente de verdad definitiva del método.** Última cosecha de los 4 repos del linaje (letra por letra, con agentes de extracción); los 2 repos de **método** se archivan con lápida; los 2 **casos de éxito** siguen vivos — no es una migración, se construye una metodología.
- `kanban/` crece de 4 a 7 docs: **`homologacion.md`** (el protocolo de 5 pasos + regla 2–3 de maduración), **`verificacion.md`** (dos capas, entrada hostil, e2e por clave, cerrar por medición) y **`estados.md`** (`vigente` ≠ construido, gate modulado por estado, gobernanza documental).
- **`docs/casos-de-exito.md`**: los dos casos de campo con números (32 versiones / 34 ADRs / 453 tests; 6 sprints del ritual con cliente que no lee código), anonimizados.
- **`docs/guias/entorno-windows-powershell51.md`**: el recetario de trampas pagadas (commits con acentos vía `-F` sin BOM, ASCII en scripts de barrera, "los subagentes no leen la config global").
- Ampliaciones: paso 0 y poda en `lazo.md`; grafo en disco + TBL/TEC + mapa a marcos en `jerarquia.md`; reglas duras nuevas en `roles.md` (diseño del tope; una sola escritora por working tree); familia de drift + GO condicionado + **corrida nocturna desatendida** en `auditoria.md`; cuatro reglas de campo en `andon/`; estados de ADR ampliados y "Qué NO resuelve" en el template; ritual de release en `CONTRIBUTING.md`.
- Limpieza: referencias colgantes a `../fuentes/` en la doctrina reescritas; el índice del corpus interno (7 frentes) registrado en `doctrina/decisiones/README.md`.

## [0.3.0-beta] — 2026-07-10

### Sprint 1.5 — Vitrina en español + centralización del conocimiento (ADR 0004)
- **Todo en español, a propósito** — decisión de identidad, declarada en el README. Badges, topics, wiki apagada, release `v0.1.0-beta` publicado; el claim del hero ahora es verificable ("este repo se gobierna con su propio Andon").
- **El andamio documentado:** `kanban/lazo.md` (Intención→Construcción→Verificación→Registro), `kanban/jerarquia.md` (QUÉ/CÓMO, 5 niveles, capacidad con Gherkin), `kanban/roles.md` (asiento ≠ skill, model-routing, reglas duras con incidentes) y `kanban/auditoria.md` (el ritual de auditoría en rama).
- **Los porqués de la doctrina:** sus 4 ADRs heredados a `doctrina/decisiones/` (destaca 0002: no API propia como gobierno; 0003: disparos, no lectura).
- **Templates probados al kit** (`kit/.jidoka/templates/`: sprint-plan, sprint-entrega, plan-de-trabajo efímero, adr) y la convención **`qa_runs/`** de evidencia Gemba (artefactos, no actas; `git add -f` de lo citado).
- **Hardening del laboratorio de campo:** ALTO-04 en `andon-stop` (git roto → aviso, no silencio), área `raiz` en la ley (6 áreas), mensajes que enseñan cuándo NO aplican.
- `CONTRIBUTING.md` (flujo + tabla SSOT), `docs/sprints/README.md` (índice-récord), plantilla de ADR con "El camino que NO se toma".

## [0.2.0-beta] — 2026-07-10

### Sprint 1 (cierre) — Auditoría del motor (ADR 0003)
- **El verificador falla cerrado:** si git no puede calcular el rango (base inexistente, historia incompleta), exit 2 con `[ERROR]` — antes aprobaba a ciegas. Self-test ampliado a 6 casos.
- **El juez viaja en la base:** el check `andon` de CI ejecuta la ley y el verificador de la rama base — un PR ya no puede editar la ley que lo juzga.
- **`jidoka-method`:** el paquete anunciado deja de ser `jidoka` (nombre ocupado en npm por un tercero desde 2017).
- Rama default renombrada a `main`; `.gitattributes` gobierna line endings (hooks LF, ps1 CRLF); `andon-stop` entrega su mensaje completo en `reason`; `ROADMAP.md` con los sprints 2–4; `andon/README.md` gana "Fronteras del muro" y el encendido completo de branch protection; README con tabla "Dónde va la beta" (evidencia, no palabra).
- Exactitud: los disparos son **12**, no 13 (nunca se contaron contra el artefacto); rutas del disparo `anti-memoria` actualizadas.

### Sprint 1 — El motor Andon (dogfooding)
- Motor de gate en `tools/`: `blast-radius.json` (la ley), `verificar.ps1` (avisa/bloquea) y `probar-gate.ps1` (self-test con caso que DEBE bloquear).
- Hooks locales en `.claude/`: `no-memorias-pretooluse` (deny a memorias, todo al repo) y `andon-stop` (frena el cierre ante doc-drift), cableados en `settings.json`.
- Muro server-side: workflow `andon` (CI en `windows-latest`) + `.githooks/pre-push` (UX local, saltable).
- **La ley con un bloqueo real:** un ADR nuevo debe listarse en `docs/decisions/README.md` o el push se detiene (único `doc_bloquea`; el resto avisa — doctrina anti-fatiga). Ver ADR 0002.
- `andon/README.md` deja de ser solo doctrina: mapea el motor concreto y cómo encenderlo (hooks + required check).

## [0.1.0-beta] — 2026-07-10

### Sprint 0 — Esqueleto + identidad
- Repo público con historial limpio (ADR 0001).
- README con el pitch (Sistema de Producción Toyota para IA), el linaje de aviación destacado (AF447, Airbus/Boeing → deny/ask, Bainbridge) y los diferenciadores propios.
- **Licencia MIT** — permisiva, para máxima adopción.
- Doctrina embebida (`doctrina/`, 9 documentos, self-contained) desde el linaje poka-yoke.
- Índices del sistema TPS: `kanban/` (ritual de sprint), `andon/` (gates deterministas).
- Los 12 disparos sembrados en `kit/.jidoka/disparos/`. *(Esta línea decía "13"; el conteo real contra el artefacto es 12 — corregido en el cierre del Sprint 1.)*
