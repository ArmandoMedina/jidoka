# Changelog — Jidoka

Formato: [Keep a Changelog](https://keepachangelog.com/es-ES/1.0.0/) · Versionado: [SemVer](https://semver.org/lang/es/).

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
