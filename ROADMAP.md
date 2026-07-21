# Roadmap — Jidoka

> Norte: **la disciplina en el robot, el juicio en el humano** — empaquetado para que cualquiera lo instale. Cada sprint entrega un incremento demostrable (Gemba); este roadmap es el récord de hacia dónde va la beta. Regla del repo: *evidencia-no-palabra* — nada se anuncia como existente hasta que corre.

## Frontera: Jidoka Core vs. familias opcionales (issue #71)

Una revisión externa (2026-07-15) pidió declarar esta frontera **antes** de seguir ampliando familias — es
documentación, nada se reorganiza ni se retira. La regla: una capacidad válida no necesariamente pertenece al
núcleo; el estado de madurez se declara (`experimental` / `1 caso real` / `2-3 casos` / `estable`), no se asume.

| Capa | Contenido | Madurez |
|---|---|---|
| **Jidoka Core** | Memoria por artefactos (HANDOFF/ADRs), plan aprobado como contrato, gates deterministas fuera del LLM (Andon/blast-radius), CI + protección de rama + self-tests, Gemba humano, ritual mínimo (arranca/planea/cierra), instalador + sello + actualización de tres vías | **estable** |
| **Discovery** (`/jidoka:descubre`, brief, kit de entrevista) | La capa de consultoría — sacar el QUÉ borroso | 1 caso real; demo de campo pendiente |
| **Docs** (arquetipo `doc-only`) | Ley `capacidad→evidencia` + gobernanza `borrador→referencia→oficial` | diferido, sin consumidor (regla 2-3) |
| **Operations** (arquetipo `operacion`) | Gates de lo irreversible, ledger, prueba de vida | registrado (#44), sin construir |
| **Observability** | Telemetría de lecturas, prueba de vida de gates, costo neto | registrado (#46), sin construir |

## Sprint 0 — Identidad · ✅ Publicado (`v0.1.0-beta`)
- Doctrina embebida (`doctrina/`, 9 docs, self-contained), el sistema TPS (Jidoka·Andon·Kanban·Kaizen·Gemba·Poka-yoke), README, licencia MIT, los 12 disparos.

## Sprint 1 — El motor Andon · ✅ Mergeado (`v0.2.0-beta`)
- La ley única (`tools/blast-radius.json`), verificador que **falla cerrado**, self-test con caso que DEBE bloquear, hooks (`no-memorias`, `andon-stop`), `pre-push`, check `andon` en CI **con la ley leída desde la rama base** (un PR no puede editar la ley que lo juzga — ADR 0003).
- Cierre auditado: ver ADR 0003 y el Kaizen en `docs/sprints/sprint-1-plan.md`.

## Sprint 1.5 — Vitrina + centralización del conocimiento · ✅ Mergeado (`v0.3.0-beta`)
- Vitrina en español con bandera (badges, release, topics); el andamio documentado (`kanban/lazo|jerarquia|roles|auditoria`); los 4 ADRs de la doctrina; templates y `qa_runs/` al kit; hardening ALTO-04 + área `raiz`. Ver ADR 0004.

## Sprint 2 — El ritual Kanban ejecutable · ✅ Publicado (`v0.5.0-beta` Fase A · `v0.6.0-beta` Fase B)
- Comandos `/jidoka:planea`, `/jidoka:gemba`, `/jidoka:cierra` (+ `/jidoka:que-sigue`, el "¿y ahora qué?"; + `/jidoka:arranca` con las reglas duras de sesión — incl. "desconfía del resumen de compactación", caso real).
- **Skills-asiento** (escribano, validador, revisor-visual; arquitecto-doc para doc-heavy) — el conocimiento ya está en `kanban/roles.md`; aquí se vuelven ejecutables. Referencia probada en el laboratorio de campo.
- Hooks: `gemba-stop` (no se cierra con cambio visual sin evidencia fresca en `qa_runs/` — probado en el linaje) y `review-stop` (código sin `/code-review` frena el cierre; marcador SHA con sus grietas documentadas).
- **Auditor determinista del grafo de docs** (frontmatter + wikilinks + Gherkin de capacidades vigentes + huérfanas, modulado por estado) + dimensión `product_avisa` en la ley.
- Templates de sprint: ya sembrados en `kit/.jidoka/templates/` (Sprint 1.5); aquí los comandos los usan.
- Especificación fina heredada del linaje (ADR 0005): mecánica del `gemba-stop` auto-configurado desde la ley; `recursos-del-proyecto.md` que `/jidoka:arranca` lee al abrir; la rebanada **R0 con STOP** en `/jidoka:planea`; anatomía probada de skill ("Entorno" embebido, no son `subagent_type`); regla doc-only (sin `/arranca`); **zanjar la contradicción del plan efímero** (válvula de excepción para tareas largas).

## Sprint 3 — El instalador · 🔨 en curso (faseado)

Enorme; se fasea. El hallazgo fundacional: el ancestro (`project-starter`) **no tenía instalador** (sembraba con "Use this template" de GitHub) — el acto de sembrar es invención de Jidoka. Lo reutilizable del starter es *qué* sembrar (13 templates, la ley ejecutable, hooks auto-desactivables) y los **3 arquetipos** (code-first · docs-as-code · doc-only), hoy prosa.

### Fase 3.A — El instalador mínimo que corre · ✅ Publicado (`v0.7.0-beta`) — ADR 0008
- `tools/instalar.ps1` (PowerShell, Windows-first): siembra el método en un repo destino leyendo el motor genérico del árbol de Jidoka (sin duplicar la ley), cambiando solo la ley por una **plantilla de arquetipo**. Regla dura **no-clobber**. Enciende `core.hooksPath`, crea stubs, guía la branch protection.
- Un arquetipo (`docs-as-code`), su ley-plantilla y el manifiesto de siembra en `kit/.jidoka/`. Smoke `tools/probar-instalador.ps1` (instala en repo temporal, corre los self-tests sembrados). Área `kit` en la ley.

### Fase 3.B — Los arquetipos ejecutables + los templates · ✅ Publicado (`v0.8.0-beta`) — ADR 0009
- **La matriz vive como manifiesto ejecutable** (`kit/.jidoka/instalar/manifiesto.json`): el instalador pregunta el arquetipo y siembra distinto. Es el mayor valor sobre el ancestro (allá la matriz era prosa).
- **Podado a 2 arquetipos** (decisión delegada, revisable — ADR 0009): `docs-as-code` (probado) + `code-first` (grafo vs `PRODUCT_BRIEF`). `doc-only` diferido (method-ficción: sin consumidor real).
- **Los 12 templates de producto** portados como librería *menú, no molde* (`kit/.jidoka/templates/producto/`) + `PRODUCT_BRIEF` con *Landscape* + HANDOFF stub con columna *Validación*.

### Fase 3.C — lo que falta (diferido a propósito, que no se olvide)
- **El arquetipo `doc-only`/regulado** (ley `capacidad→evidencia` + gobernanza `borrador→referencia→oficial`) — se estrena cuando un repo regulado real lo pida (regla 2–3). **Primer uso real llegado (2026-07-13, #41):** una base de conocimiento PLD/CNBV lo pidió y adoptó `docs-as-code` a mano; queda esperando el 2º (ver *Tercera cosecha por el lazo*).
- ~~**El instalador que de verdad pregunta el arquetipo**~~ ✅ **HECHO (`v0.13.0-beta`, ADR 0014):** `Read-Host` interactivo cuando no se pasa `-Arquetipo` ni `-Yes`; con `-Yes` cae a `docs-as-code`.
- **El lazo de sincronización labs↔Jidoka** — ✅ **HECHO (2026-07-11, `v0.11.0-beta`, ADR 0012).** *La lección sube, la máquina baja.* Implementado y probado (smoke 32/32):
  1. ✅ **Sello de versión sembrado** (`tools/jidoka-motor.json`: versión + SHA256 por pieza) con `tools/version.txt` como SSOT, atado al CHANGELOG por `probar-version.ps1`.
  2. ✅ **Modo `-Actualizar` con conciencia de tres vías** (estilo `dpkg conffiles`): re-siembra SOLO `clase: mecanica`; ausente→agrega, ==Jidoka→al día, ==hash-sembrado→actualiza, ≠hash-sembrado→**divergencia** (no pisa, deja `.jidoka-nuevo`). La instancia nunca se toca.
  3. ✅ **Aviso de divergencia** (`tools/estado-motor.ps1`, sembrado): aviso, no muro. *Diferido a propósito:* cablearlo dentro de `verificar.ps1` (el gate de push) se evitó para no clobbear el verificador del hijo; queda como follow-up si madura (regla 2–3).
  4. ✅ **Canal de subida** (`tools/reportar-leccion.ps1` + `docs/guias/reportar-leccion-a-jidoka.md`): el hijo reporta al issue `leccion.md` en vez de parchear local. Precedente (cosecha de SGI, ADR 0011) ahora es máquina. **SGI = primer consumidor.**
  - **Costura `.local`** añadida (`verificar.ps1` dot-sourcea `verificar.local.ps1`): la vía sostenible para que un motor divergente (el `verificar` de SGI con ruff+pytest) converja sin clobber. *Follow-through:* refactorizar el `verificar.ps1` de SGI a data-driven + `.local` (no en este sprint por sus 453 tests).
- ~~**El quickstart del README como caso end-to-end del self-test**~~ ✅ **HECHO (`v0.13.0-beta`, ADR 0014):** `probar-gate.ps1` ejercita el flujo real commit→verificar por git en un repo fixture (paso 3 del README).
- **La matriz de piezas más fina** (qué skills/tests/UI por arquetipo, más allá de ley+semilla).
- **benchmark** verificado en vivo — portar/formalizar.
- **Multiplataforma**: gemelos `.sh` o unificar en `pwsh` Core (decisión abierta); despacho de hooks por SO. Hoy el motor es Windows/PS 5.1.
- **CLI npm `npx jidoka-method init`** (distribución cross-platform) + **SSOT de versión** + **CI de release** + **smoke del instalador en CI** (lección: *un workflow que solo corre al cortar release se pudre en silencio* → `workflow_dispatch` de rescate) + **ensayo del empaquetado** (el build se autoverifica contra el manifiesto que el runtime usa).
  - ✅ **SSOT de versión + release derivado HECHO (`v1.3.0`, ADR 0020):** `tools/publicar.ps1` deriva tag+notas del SSOT (`version.txt`+CHANGELOG) y corre la suite antes de publicar (Jidoka-only). Extendido en `v1.8.0`: `probar-version` exige `package.json.version == version.txt`.
  - 🔨 **CLI `npx jidoka-method` CONSTRUIDO (`v1.8.0`):** `package.json` + `bin/jidoka-method.js` (wrapper Node que reusa `instalar.ps1` vía PowerShell). **Probado en Windows** (siembra 76 archivos). **Pendiente**: (a) `npm publish` (necesita la cuenta npm del cliente) — hasta entonces se usa con `node bin/jidoka-method.js init <ruta>`; (b) **verificar la ruta Mac/Linux** (pwsh Core) — no se declara cross-platform sin evidencia; hace falta un entorno no-Windows.
  - ⏳ **Multiplataforma del motor** (que los gates PS corran en Mac/Linux vía pwsh Core): sigue pendiente de un entorno no-Windows para probarse.
- **Barreras code-first**: lint/formato/tests/cobertura/CHANGELOG-gate; **gate de UX en 3 capas**; **lint de alta señal** (set corto).
- ~~**Dogfood completo del ADR 0003**: mover el motor a vivir SOLO en `kit/` y que Jidoka se auto-instale.~~ ✅ **RESUELTO — NO se migra (`v1.8.1`, ADR 0024).** La premisa no se sostiene contra el artefacto: hoy no hay dos copias (el motor se lee del árbol; `kit/` solo trae plantillas de instancia); migrar crearía la duplicación que buscaba evitar, y el dogfood ya lo cubre `probar-instalador`. Leer-del-árbol pasa de provisional a decisión deliberada.
- ~~Los comandos/skills sembrados citan docs de método que no se siembran: enlaces muertos en un repo ajeno~~ ✅ **HECHO (`v0.13.0-beta`, ADR 0014):** el manifiesto siembra el método completo (`kanban/` + `andon/` + `doctrina/` + guía de entorno); un verificador de enlaces en `probar-instalador.ps1` lo vuelve invariante. Límite conocido: las citas a ADR de Jidoka (procedencia) apuntan a la fuente.

## Sprint 4 — Beta estable · 🔜
- ~~Guías completas (`docs/guias/empezar-de-cero.md` deja de ser esqueleto)~~ ✅ **HECHO (`v0.13.0-beta`, ADR 0014):** la guía de instalación desde cero, completa y verificada contra el flujo real.
- Presentación pública: badges, Quick Start, banner, social preview.
- Decisión abierta: comunidad (Discussions / Discord).
- ~~Candidato a `v1.0` cuando el método completo corra end-to-end en un repo ajeno.~~ ✅ **CUMPLIDO — `v1.0.0` (2026-07-11, ADR 0017).** El programa hacia 1.0 (Sprints A/B/C) bajó el núcleo a **dos labs ajenos reales** con CI verde server-side: **SGI `v2.6.0`** (Python) + **TF `v0.2.0`** (JS/PWA), evidencia en el `qa_runs/` de cada lab. Jidoka **sale de beta**. Lo público de este Sprint 4 (badges, social preview, banner, comunidad) se difiere post-1.0.

## Vitrina pública — dejar el repo listo para compartirse (sesión 2026-07-10)

Trabajo de presentación surgido de la auditoría externa y de la entrada del autor a una comunidad. Lo pendiente lleva receta completa para que cualquier sesión (o el propio autor) lo retome sin re-explicación.

### Hecho ✅ (2026-07-10, en el working tree de la sesión)

- **Ko-fi cableado en tres puntos**: `.github/FUNDING.yml` (`ko_fi: armandomedina2255`) — enciende el botón *Sponsor* del repo al llegar a `main`; badge Ko-fi en el bloque de badges del README (mismo estilo que SimGhostInputs); invitación al café en la línea de la licencia del README.
- **Template de PR** (`.github/PULL_REQUEST_TEMPLATE.md`): el punto de inyección de disparos en PRs que `andon/README.md` ya prometía. Lleva evidencia-no-palabra, el recordatorio ADR→índice y el disparo `no-verify-es-teatro`. Corto a propósito — `doctrina/04`: un checklist largo entrena el click-para-pasar.
- **Templates de issues** (`.github/ISSUE_TEMPLATE/`): `reporte.md` (redactado para que un **no-programador** reporte sin miedo; pide evidencia, no jerga) y `leccion.md` (el canal de homologación abierto al público — regla 2–3 de maduración y disparo `frontera-nda` embebidos).

### Pendiente ⏳ (en orden de valor)

1. ~~El GIF del gate mordiendo~~ **HECHO (2026-07-11):** `docs/assets/gate-bloqueando.gif`, incrustado en el README (*Velo bloquear un cambio malo*). Generado de una **corrida real** en un clon de SGI (bloqueo auténtico `PUSH DETENIDO` + desbloqueo); procedencia y regeneración en [`docs/guias/guion-gif-del-gate.md`](docs/guias/guion-gif-del-gate.md), evidencia en `qa_runs/gif-gate-20260711/`.
2. **Social preview** (solo humano, ya estaba en la checklist): Settings → General → Social preview, imagen 1280×640 px. Es lo primero que se ve al pegar el link en Discord/foros — sin imagen el link se ve pobre. Una provisional generada por IA sirve ya; el banner definitivo es del Sprint 4.
3. **`CODE_OF_CONDUCT.md`** — [Contributor Covenant 2.1 en español](https://www.contributor-covenant.org/es/version/2/1/code_of_conduct/). GitHub lo muestra en la pestaña de comunidad y da un mecanismo neutro de moderación *antes* de que llegue el primer conflicto con extraños.
4. **Decisión abierta del cliente — el párrafo en inglés del README.** Distinguir dos cosas: *el método se escribe y se defiende en español* (postura de identidad, se mantiene) vs. *el visitante anglófono no entiende ni de qué va el repo* (un bounce). Propuesta sobre la mesa: un único párrafo en inglés — qué es Jidoka y por qué está en español a propósito. Solo el autor decide; si se decide que no, se registra y no se re-litiga.
5. ~~**Decisión abierta del cliente — el ADR de la licencia.**~~ ✅ **RESUELTO (2026-07-11, ADR 0016):** se mantiene **MIT** como decisión **consciente** (no heredada), con el camino copyleft (GPL/AGPL) registrado como el-que-no-se-tomó. Para una *metodología* (conocimiento más que código), adopción máxima > reciprocidad forzada; revisable si aparece evidencia de enclosure dañino. `LICENSE` sin cambio. (El punto del ADR 0001 —doctrina rebrandeada "Poka-yoke"— heredará esta misma postura si se publica suelta.)

## Grietas de la auditoría externa (2026-07-10) — registradas, no resueltas

Hallazgos de una auditoría de terceros sobre este repo (evidencia: corrió `probar-gate.ps1` 6/6 y leyó el motor completo). Se registran con destino para que no se pierdan entre sesiones:

1. **El muro real hoy protege muy poco.** ✅ **CERRADA (Fase 2·B, `v0.6.0-beta`)**: los avisos suben al summary del PR. La re-evaluación de qué avisos maduran a bloqueo (regla 2–3) sigue abierta como práctica continua.
2. ~~**El hook `no-memorias` no es muro: solo intercepta `Write|Edit`.**~~ ✅ **CERRADA EN PARTE (`v1.1.0`, ADR 0018):** el matcher pasa a `Write|Edit|Bash` y el hook deniega la **escritura** a la memoria vía Bash (`Set-Content`/redirección `>`/etc.); la lectura no se bloquea. Prueba de vida en `probar-hooks.ps1` (casos Bash). **Residual honesto** (confesado en `andon/README.md`): aliases (`sc`/`ac`/`ni`) y rutas ofuscadas evaden el matcher heurístico, y no hay cobertura server-side (la memoria es conducta del agente, no estado del repo).
3. **El gate mide co-ocurrencia, no contenido.** Tocar el doc dueño con un cambio trivial satisface el gate — proxy gameable (Goodhart, `doctrina/04` aplicado a nosotros mismos). → Aceptada como límite conocido del diseño v0, documentada en las fronteras de `andon/README.md`. Cualquier verificación de contenido es decisión aparte (riesgo de over-governance).
4. **El linaje es evidencia privada.** ~~Los 4 repos de origen no son públicos~~ **Avance (2026-07-11):** el caso 1 (SimGhostInputs) **es público** y quedó nombrado y linkeado en el README y en `docs/casos-de-exito.md` — evidencia clickeable (releases, ADRs, `qa_runs/`, la maquinaria de gates en su árbol). El ancestro (`project-starter`) y el caso 2 siguen privados y se citan anónimos. → **Sprint 4**: decidir si algo más del linaje se puede mostrar; el discurso del README ya está ajustado a lo verificable.
5. ~~**11 de los 12 disparos son catálogo, no máquina.**~~ ✅ **CERRADA (`v1.1.0`, ADR 0018):** el diagnóstico fino resultó ser que la mayoría **ya se referenciaban** — faltaba **verificarlo**. Ahora cada disparo declara `Cableado en: <punto>` (que nombra su slug) o `Catalogo-solo: <razón>`, y `tools/probar-disparos.ps1` (en CI) falla si un cableado se cae de su punto (detección de rot). 10 cableados verificados + 2 catálogo-solo por diseño (`deny-vs-ask`, `capacita-desde-el-artefacto`, principios sin gate en runtime).

## Backlog (sin sprint asignado)

### El descubrimiento del sistema configurable (2026-07-20) — la visión aterrizada, esperando el ADR nombrado

Dos sesiones de descubrimiento con el cliente aterrizaron la visión que el follow-up del "ligar
genérico" (abajo) venía anunciando — y la subsume: **Jidoka evoluciona de metodología con comandos
fijos a sistema de gobierno configurable con UI guiada** (la UI autora, el gate ejecuta — ADRs
0002/0044 intactos). El récord completo, con las 5 ideas fuerza (las 5 relaciones de "ligar", los 3
regímenes de gobierno por pieza, la bandeja "pendiente de parametrizar", el formulario de alta, los
hallazgos del censo) y las candidatas de rebanada:
[`docs/analisis/descubrimiento-sistema-configurable-202607.md`](docs/analisis/descubrimiento-sistema-configurable-202607.md).
Su artefacto validado por el cliente ("me gustó", 2026-07-20): la maqueta clickeable
[`docs/analisis/maqueta-tuberia-202607.html`](docs/analisis/maqueta-tuberia-202607.html). **Nada se
construye hasta que el cliente nombre el ADR de identidad y el orden de rebanadas** (las decisiones
pendientes están listadas al final del informe).

### Tercera cosecha por el lazo — brownfield regulado + operación (2026-07-13, ADR 0027)
Siete issues (#40–#46) de dos despliegues reales: un repo de conocimiento **regulado (PLD/CNBV)** y un proceso de **operación ("Caso F")**. Dos se atendieron ya (`v1.10.0`); los otros cinco se registran con marca **regla 2-3** (primer/segundo uso real, esperando el siguiente) — no se construyen por método-ficción.

- ✅ **[#40/#43] La ruta de actualización no cuelga del instalador** — HECHO (`v1.10.0`, ADR 0027): fallback `tools/sembrar-manual.ps1` (independiente de `instalar.ps1`, sin `Bypass`, menor superficie de AV) + `estado-motor.ps1` degrada con gracia apuntando a él. **Parte diferida (regla 2-3, esperando 2º entorno endurecido):** reducir la superficie de sospecha del artefacto *original* — renombrar/firmar `instalar.ps1`, o la ruta `npx jidoka-method` (ya en Fase 3.C) — **alto blast-radius / recurso del cliente** (cert de firma).
- ✅ **[#42] `scanDirs` del auditor configurables desde la instancia** — HECHO (`v1.10.0`): campo `scanDirsExtra` en la ley (`tools/blast-radius.json`) amplía el índice de wikilinks del auditor a capas de docs propias del repo (p.ej. `engineering/`) sin tocar el motor. Sin el campo, comportamiento idéntico.
- **[#41] Un repo regulado real pide `doc-only`** (hoy `disponible:false`). **Regla 2-3: el primer uso real llegó** (base de conocimiento PLD/CNBV, sin `src/`; adoptó `docs-as-code` a mano). Queda esperando el **2º** repo regulado que lo pida antes de estrenar el arquetipo (ver Fase 3.C).
- **[#44] Arquetipo `operacion` (4º arquetipo)** — la "segunda familia de barreras" (proteger el **proceso irreversible**, no el repo) como pieza **sembrable**: ley operacional (severidades `deny`/`ask`, umbrales/catálogos como **dato**), gate ante lo irreversible, contrato de ledger (registrar **solo tras la acción real**), tablero de leading indicators + prueba de vida, TIP con fail-safe. Existe como **doctrina** (`doctrina/07`, `andon/README`) pero **no como motor**. **Regla 2-3: 1er uso real** (Caso F, en producción, implementado a mano). Esperando el 2º caso de operación.
- **[#45] Gobernanza compuesta** — la presencia de una **línea de operación** (un gate ante lo irreversible) debería **encender** la gobernanza aunque el arquetipo de *documentación* base la traiga apagada; separar el eje gobernanza-on/off del arquetipo de docs (o que `operacion` la traiga encendida y se **componga** con cualquier arquetipo). **Regla 2-3: 2º apunte del patrón** (reformula la "desviación deliberada" anotada al sembrar). Esperando el 3º.
- **[#46] Prueba de vida ≠ tests verdes** — un gate puede estar **verde y muerto** (pasa self-tests pero lleva semanas sin rechazar nada real). Añadir a la doctrina un **patrón/disparo de "prueba de vida"** para barreras de operación: *leading indicators* (intercepciones reales, desacuerdos del revisor, tiempo de revisión) y dictaminar **podrido** cuando el gate deja de rechazar. El self-test prueba la **mecánica**; la prueba de vida prueba la **vigencia**. **Regla 2-3: 1er uso real** (Caso F). Esperando el 2º.

### Follow-ups sueltos — a la espera de que se acumulen más issues (2026-07-13)
Modo deliberado: **dejar que se junten más lecciones antes de la próxima cosecha** (batch, no goteo). Registrados para no perderlos:
- **"Ligar" como verbo genérico de las TRES relaciones (2026-07-20, re-Gemba de `v1.25.0`, opción b del cliente):** en el repo "ligan" tres cosas — blast-radius (área↔doc), wikilinks (capacidad↔capacidad) y ligas (código↔capacidad; la única que la extensión autora hoy). La opción (a) ya se aplicó (el comando se estrechó a "ligar código a capacidad..."); la (b) —que la extensión autore las tres relaciones y el verbo genérico se justifique— es **un sprint, no una etiqueta**: esperaría el siguiente uso real que lo pida (regla 2-3). También pendientes de esa familia: hallazgo B2 del review (conteo del reparto case-insensitive) y la deuda compartida del `Out-File -Encoding ascii` en los steps desde-la-base.
- **El cuadro de cierre como plantilla sembrable** (2026-07-17): el detalle del cuadro (las ~23 filas) hoy vive inline en `cierra.md` y su annotation en `16-cierra` quedó cargada de texto. Mover el detalle a una plantilla `kit/.jidoka/templates/cierre-cuadro.md` que `cierra.md` **inyecte con `@`** (mismo patrón que `sprint-plan.md` en el planea — cumple ADR 0040: inyección, no puntero) y que el diagrama solo **referencie por nombre**. De paso viaja a los hijos como plantilla, no como prosa del comando.
- **`publicar.ps1` no incluye `probar-sembrar` en su preflight** — el próximo release no auto-probaría el fallback anti-AV. Arreglo de una línea (agregarlo a la suite); cazado al cortar `v1.10.0`. Bajo riesgo (el test corre a mano verde), pero el gate de release debería ejercerlo.
- **[#47] El pre-push del motor gatea el contenido pero no protege la rama default** — lección nueva, etiquetada `leccion`, **sin triar** (¿construir o regla 2-3?). Se decide en la próxima cosecha.
- ~~**Documentos gobernados: la lógica del ritual no debe desviarse en los hijos (2026-07-17).**~~ ✅ **RESUELTO (`v1.22.0`, ADR 0042, KIT-2), pero el diagnóstico cambió al medir:** los `.md` del **ritual** NO divergen — son motor, gobernados por hash, `-Actualizar` los cubre. El hueco real eran los documentos **instancia-de-template** que el ritual inyecta con `@` (`brief`/`infra`/`CONTRIBUTING`): su contenido varía a propósito (el hash es la herramienta equivocada) y `CONTRIBUTING` no tenía template. Se construyó el **hermano estructural del sello** (gobierno por **secciones**, modelo SAP): ledger `docs-gobernados.json`, detector `estado-docs.ps1` (aviso en arranca + muro opt-in en CI), template real de CONTRIBUTING. **Follow-up vivo:** el muro CI lee el ledger del PR, no de la base (a diferencia de ADR 0003) — endurecer a lectura-desde-base si madura (regla 2-3). Bajar KIT-2 a los labs con `-Actualizar`.
- **El preflight `!` no debe usar expansión de shell (2026-07-17, atendido en 1.21.1 antes de release).** El preflight de inyección que metió #104 usaba `for f in …; do [ -f "$f" ] …` — el clasificador de permisos de Claude Code lo marca `simple_expansion` y **se niega a auto-correrlo**, tronando el comando entero al abrir. Reescrito al idioma que el clasificador SÍ auto-corre y que el propio `arranca.md` ya usaba en la guardia del plan-de-trabajo: `test -f X || echo "[FALTA] X"` por archivo (nombra el que falta). El guardián `probar-preflight.ps1` se amplió para aceptar `test -f` además de `[ -f`. **Lección durable:** todo `!`-inline sembrado debe evitar variables/`for` de shell — el clasificador los bloquea; usar `test -f … || echo …` o `powershell -File`.
- **El plan debe declarar QUÉ pruebas se harán** (2026-07-17, pedido del cliente): que `.claude/commands/jidoka/planea.md` exija, como parte del plan aprobado, una sección explícita de **qué pruebas/evidencia** va a producir cada rebanada (test, demo Gemba, `qa_runs/LOG.md`) — no dejar la verificación implícita. Alinea con *evidencia-no-palabra* y el listón del `LOG.md`: el plan-contrato ya nombra el cómo-verificar antes de escribir código, en vez de improvisarlo al cerrar.

### Segunda cosecha por el lazo — refinamientos del mecanismo (2026-07-11, ADR 0015; post-1.0)
Cuatro lecciones que subieron al bajar el núcleo a los dos labs en Sprint B. Ninguna bloqueó la 1.0; todas con contexto para retomarse sin re-explicación.
- ~~**Generalizar el sello bootstrap (pristina-vs-customizada).**~~ ✅ **HECHO (`v1.2.0`, ADR 0019):** `instalar.ps1 -Sellar` clasifica cada pieza contra el Jidoka actual — pristina → registrada, customizada → omitida (se preserva). Generaliza el parche manual de SGI/TF.
- ~~**`estado-motor.ps1 -Detallado` por-hash.**~~ ✅ **HECHO (`v1.2.0`, ADR 0019):** compara pieza por pieza (por hash) contra el motor de Jidoka y lista las que divergen o faltan.
- ~~**Drift estructural núcleo↔labs.**~~ ✅ **RESUELTO en tres piezas:** (a) clasificación genérico-vs-customizado → fix EOL (ADR 0021) + re-sellado limpio; (b) re-agregado recurrente → **lista de exclusión del hijo** (`v1.5.0`, ADR 0022); (c) **forma canónica declarada** (`v1.7.0`, ADR 0023): comandos namespaced, rol neutral el mecanismo, nombre del skill de instancia. **Implementación pendiente en labs**: converger sus comandos a namespaced + declarar su `excluir` (SGI: quitar comandos/skills duplicados; TF: comandos a `jidoka/*`).
- **Épica: reconciliación del motor code-first vía costura `.local`.** verificar/auditar/probar-gate convergen al motor genérico + `verificar.local.ps1` para lo del lenguaje (ruff/pytest en SGI, node/`-SoloDocGate` en TF), sin romper los 453 tests de SGI. La "mecánica igual" completa; subsume la vieja "convergencia profunda del gate de SGI".

- ~~**Método — claridad del límite orquestador↔subagente**~~ ✅ **HECHO (2026-07-11, `v0.12.0-beta`, ADR 0013):** sección "Qué va a subagente vs qué se queda" en `kanban/roles.md` con tabla al vistazo + la sesión del lazo como ejemplo trabajado. Fue una de las tres lecciones de la primera cosecha por el lazo.
- **Panorama — OpenWiki (LangChain, 2026-06, MIT, ~10.5k stars):** genera y mantiene un wiki del repo *para agentes* con una Action diaria que abre PRs anti-drift. **Complemento, no competidor**: su flecha va código→doc (generativa, palabra de LLM); la nuestra doc→código (normativa, gate determinista). Si algún día se integra: su wiki es capa descriptiva *fuera* de la ley — doc auto-generada dentro del blast-radius dejaría al gate satisfecho con palabra-no-evidencia. Fuentes: github.com/langchain-ai/openwiki · langchain.com/blog/introducing-openwiki. (Vecinos: DeepWiki de Cognition —visor hosted—, OpenDeepWiki — irrelevantes como competencia.)
- **Panorama — GBrain (Garry Tan, 2026-04, MIT, ~26k stars):** grafo de conocimiento auto-enlazado sobre Markdown local git-nativo, con consulta en lenguaje llano (`gbrain think "pregunta"` → respuesta sintetizada **con citas** y detección de lagunas) y exposición vía MCP a Claude Code. Interés para Jidoka: montar la interfaz "pregúntale al proyecto" sobre las docs curadas del método (HANDOFF, ADRs, grafo `product/`) para que el cliente no-técnico consulte *"¿por qué se decidió X?"* sin navegar el repo — aquí y en cada repo donde se instale el método. Límite conocido: self-hosted, operador único (exponerlo a un cliente externo pide un frente extra). Fuentes: github.com/garrytan/gbrain · vectorize.io/articles/what-is-gbrain. (Vecino del mismo autor: `gstack`, sus 23 skills de Claude Code — para devs, no para este caso.)
- ~~**Doctrina — matiz de la cita Airbus**~~ ✅ **HECHO (`v1.5.1`):** `doctrina/03-aviacion.md` ahora dice que los límites duros valen en *normal law* y degradan en *alternate/direct law* (el piloto sí puede exceder el envelope) — con la lección para el gate (*hasta un `deny` duro tiene modo degradado; confiésalo*). Registrado como cita #9 en `doctrina/citas-verificadas.md`.
- Publicar la doctrina suelta rebrandeada **"Poka-yoke"** (ADR 0001 lo deja abierto; solo entonces Jidoka la enlazaría como *further reading*).
- `SECURITY.md` para colaboración externa (`CONTRIBUTING.md` ya existe — Sprint 1.5).
- Tablero de instrumentación (leading vs lagging, las 5 series de `doctrina/05`) — no existe en ningún repo del linaje; construirlo es frontera.
