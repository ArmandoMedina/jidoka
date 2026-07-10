# Sprint 1.5 — Vitrina en español + centralización del conocimiento del linaje

> Plan aprobado por el cliente el 2026-07-10. **El plan de sprint se archiva** (es el contrato); el plan de trabajo del día a día es efímero y no se versiona (ver `kit/.jidoka/templates/README.md`). Registro de la decisión: [ADR 0004](../decisions/0004-centralizacion-del-conocimiento.md).

## Contexto (por qué)

La auditoría externa (BMAD + panorama 2026) confirmó que el nicho de Jidoka —gates deterministas fail-closed como núcleo + revisión por demo— está **desocupado**, pero la vitrina no estaba a la altura (cero topics, sin releases, wiki vacía, sin badges) y buena parte del método vivía fuera del repo: el lazo, la jerarquía QUÉ/CÓMO y los roles eran una línea del ADR 0001; los porqués de la doctrina (sus 4 ADRs) no estaban; y los patrones probados en producción (el tracker del ritual: 5 sprints; **el laboratorio de campo: el más maduro** — 34 ADRs, auditoría integral multi-agente, `qa_runs/` con diente) tampoco. Cuatro inventarios con agentes de exploración mapearon exactamente qué faltaba y qué NO traer (lo que ya maduró río abajo en jidoka).

## Decisiones del cliente (2026-07-10)

1. **Todo en español** — identidad, no barrera: se defiende.
2. **Centralizar todo el conocimiento aprovechable** de los cuatro repos del linaje, de forma inteligente.

Regla de clasificación (protocolo de homologación del linaje): **asciende-ya** (conocimiento, templates, hardening puntual) / **espera-con-registro** (maquinaria que exige el ritual ejecutable → Sprints 2-3) / **no-asciende** (PII, específico de dominio). **Frontera NDA:** nada de nombres propios del casting de los repos privados, ni clientes, ni correo personal; origen = "caso N" / "laboratorio de campo". Barrido `git grep` antes de cada commit.

## Bloque V — Vitrina (en español, con bandera)

- **V1. Topics** (`gh repo edit --add-topic`): `ai-agents`, `claude-code`, `methodology`, `quality-gates`, `ci`, `toyota-production-system`, `jidoka`, `andon`, `espanol`, `spanish` (keywords mixtas EN/ES a propósito: que nos encuentren ambos mundos aunque el contenido sea ES).
- **V2. GitHub Release `v0.1.0-beta`** desde el tag existente (`gh release create --verify-tag`), notas narrativas en español (headline + qué trae + qué NO trae aún). Al mergear PR #1: el cliente taggea `v0.2.0-beta` y se repite.
- **V3. Wiki OFF** (`gh repo edit --enable-wiki=false`). Discussions sigue apagado (decisión Sprint 4, ya en roadmap).
- **V4. README raíz:** badges estáticos (MIT · beta · Windows PS 5.1 · roadmap); declaración bajo el hero: **"En español, a propósito."**; reframe del claim no falsable "probado en repos reales" → verificable: *"nacido de cuatro repos internos; **este repo se gobierna con su propio Andon** — los PRs, checks y sprints archivados son la evidencia"*; "cinco roles" → ajustar a los asientos reales (A3).
- **V5. `docs/guias/empezar-de-cero.md`**: `npx jidoka init` → `npx jidoka-method init` (2×, residuo del rename).
- **V6. Social preview** = solo-UI de GitHub → checklist humana del HANDOFF. Banner definitivo = Sprint 4.

## Bloque A — El andamio documentado (de la plantilla interna)

Tres docs nuevos en `kanban/`, voz de jidoka:

- **A1. `kanban/lazo.md`** — Intención→Construcción→Verificación→Registro: los 4 tiempos; el Registro repartido por caducidad (ADR = permanente / CHANGELOG = enviado / HANDOFF = efímero con ciclo "se llena al cerrar, se lee y se LIMPIA al abrir"); kit mínimo; "la disciplina escala con el riesgo"; "avisa temprano, bloquea al final".
- **A2. `kanban/jerarquia.md`** — QUÉ/CÓMO: dos sombreros (Producto vs Ingeniería) con **los ADR como puente**; jerarquía de 5 niveles (Ecosistema→Producto→Dominio→Módulo→**Capacidad**, unidad atómica con criterios Gherkin); claves estables (`FAM-MOD-NN`); regla de oro ("que cualquiera implemente sin inventar reglas de negocio; lo ambiguo se marca, no se inventa"); tabla "dónde va cada cosa". El laboratorio de campo es el ejemplo vivo (22 capacidades, 14 módulos auditados por grafo) — se cita como caso, no se copia.
- **A3. `kanban/roles.md`** — asientos: **asiento ≠ skill**; orquestador y dev no son skills (la sesión y el trabajo por defecto); escribano, validador, revisor-visual como skills (Sprint 2) + **arquitecto-doc** opcional para arquetipo doc-heavy (menú, no molde); convención 🎭; model-routing ("no uses Ferrari para ir por tortillas") **con los incidentes reales de orquestación** anonimizados; regla "la lectura voluminosa SIEMPRE va a subagente"; la ley: **"el determinismo bloquea; el juicio orquesta; nada irreversible se automatiza sin checkpoint humano"**; y la lección del laboratorio: **no todo rol merece hook**.
- **A4. `kanban/README.md`**: enlaza los docs + nota "la ejecución llega en Sprint 2".

## Bloque P — La mina de la doctrina

- **P1. `doctrina/decisiones/`** (nuevo, dentro del corpus embebido; números originales, sin chocar con `docs/decisions/`): los 4 ADRs de doctrina + README índice: 0001 (repo propio de doctrina), 0002 (**se mata la API propia como gobierno** — mismo modo de falla que las memorias), 0003 (**la doctrina se consume vía disparos, no vía lectura** — el ADR más citado por jidoka y ausente), 0004 (anonimización mecánica). Enlazado desde `doctrina/README.md`.
- **P2. Provenance restaurada** en `no-memorias-pretooluse.ps1`: "esta regla falló 4 veces en el laboratorio de campo antes de cablearse" (anonimizado, ASCII).
- **P3.** `CONTRIBUTING.md` (estaba en backlog): commits/flujo de PR + tabla SSOT "qué doc es dueño de qué" + modelo de amenaza en una línea. Corto, ES.
- **No asciende:** el corpus de fuentes (~1.2 MB, PII en historial de origen) — registrado en el ADR 0004.

## Bloque S — El hardening del laboratorio de campo (el más maduro)

- **S1. ALTO-04 a `andon-stop.ps1`** (regresión detectada: jidoka quedó pre-ALTO-04): quitar el silencio global de errores; revisar `$LASTEXITCODE` tras cada git real; si git falla de verdad → AVISO en el output (sin `decision:block`), nunca tratarlo como "sin cambios". Es fix de producto (hereda al kit).
- **S2. Área `raiz` al `blast-radius.json`** (patrón anti-tierra-de-nadie): archivos sueltos en la raíz (con `excluye` de los canónicos) **avisan** al Escribano. Solo `avisa` — anti-fatiga intacta. `probar-gate.ps1` debe seguir 6/6.
- **S3. Mensajes que enseñan a auto-descartar falsos positivos**: los `mensaje` de la ley dicen cuándo NO aplican (patrón "si tu cambio es X, este aviso no es para ti").
- **S4. `docs/decisions/0000-plantilla.md`** (+ copia en kit): plantilla MADR con la sección **"El camino que NO se toma (y por qué tienta)"**.
- **Espera-con-registro (lo grande → Sprints 2-3):** auditor de grafo + árbol producto/ingeniería; dimensión `product_avisa`; barreras extra del verificador; hooks `review-stop` y `gemba-stop` con marcador SHA (con sus grietas documentadas); `setup -Yes`; CI de release + smoke del instalador; skills-asiento. **NO traer** (jidoka ya lo hizo mejor): fail-closed, parametrización, self-test, juez-desde-la-base, reason-vs-additionalContext.

## Bloque T — Lo probado en el tracker del ritual

- **T1. Templates al kit** (`kit/.jidoka/templates/`), estructura probada en 5 sprints reales: `sprint-plan.md`, `sprint-entrega.md`, `plan-de-trabajo.md` (**efímero, no se versiona**; el plan de SPRINT sí se archiva — distinción explícita en el README de templates), `adr.md`; README con ownership por sección (la sección del cliente la escribe el cliente).
- **T2. `qa_runs/` — evidencia Gemba**: `kit/.jidoka/qa_runs/README.md` + `qa_runs/README.md` en el repo (dogfood). Reglas: un directorio por corrida `<rol>-<YYYYMMDD-HHMMSS>`; **"un archivo que diga 'validé y todo bien' no es evidencia"** — artefactos, no actas; datos 100 % sintéticos; el veredicto vive en HANDOFF/CHANGELOG **citando** la corrida; bulto gitignored y **`git add -f` de lo citado como paso obligatorio de cierre**.
- **T3. `docs/sprints/README.md`** — índice-récord: tabla `Sprint | Qué entregó | Estado` (estado real).
- **T4. `kanban/auditoria.md`** — ritual de auditoría en rama, versión madura: fan-out de auditores por área → **síntesis con dedupe y reconciliación de contradicciones** ("gana la evidencia más directa") → severidad única → paquetes de remediación → **veredictos GO/NO-GO separados por acción** (merge ≠ release) → "Descartado a propósito" → "Decisiones que necesitan al humano" separadas del trabajo autónomo.
- **T5. Lecciones de campo al ADR 0004** (anonimizadas): la mayor — *"sprints sin criterios de aceptación aprobados → el QUÉ se escribe ANTES de construir"*; la desconfianza del resumen de compactación; "los Stop hooks son ciegos al código ya commiteado — se mitiga por proceso, no por código".

## Bloque R — Registro

- **R1. ADR `docs/decisions/0004-centralizacion-del-conocimiento.md`** + índice en el mismo commit (el `doc_bloquea` lo exige).
- **R2. ROADMAP** enriquecido: Sprint 2 con nombres reales de lo inventariado; Sprint 3 suma `setup -Yes` y CI de release; backlog poda CONTRIBUTING (cumplido).
- **R3. CHANGELOG + HANDOFF** al día (checklist humana: release vía `!`, social preview, merge PR #1 → tag `v0.2.0-beta`, luego abrir PR #2).
- **R4.** Este plan se archiva como `docs/sprints/sprint-1.5-plan.md` (el plan aprobado ES el sprint).

## Bloque G — Git / ops

- Rama **`sprint-1.5-vitrina-y-conocimiento`** desde `sprint-1-andon`. Commits por bloque (V, A, P, S, T, R). Push normal (si el clasificador frena → comando `!` al cliente).
- **PR #2 → `main` después del merge del PR #1** — primer PR juzgado con la ley desde la base (estreno real del juez de ADR 0003).
- Ajustes de repo (topics, wiki, release) = instantáneos, sin rama.
- **Barrido NDA por commit**: `git grep` de nombres sensibles, correo personal y términos de trabajo.

## Verificación (demo Gemba — lo corre el cliente)

1. Página del repo: topics, release `v0.1.0-beta`, wiki apagada, README con badges y "En español, a propósito."
2. `.\tools\probar-gate.ps1` → **6/6 verde** con la ley ampliada (área `raiz`).
3. Toca un archivo suelto en la raíz → `verificar.ps1` **avisa** área `raiz`; el rango de la rama pasa (ADR 0004 indexado).
4. `kanban/{lazo,jerarquia,roles,auditoria}.md`, `doctrina/decisiones/` (4 ADRs), `kit/.jidoka/templates/`, `qa_runs/README.md` — legibles y enlazados.
5. `andon-stop` con ALTO-04: simular git roto (PATH sin git) → el hook avisa en vez de callar.
6. Barrido NDA: `git grep` de términos sensibles sobre la rama → cero resultados.

## Fuera de alcance

- Skills/hooks/comandos ejecutables, auditor de grafo, `product_avisa`, barreras extra → **Sprint 2** (registrado en ADR 0004 + ROADMAP).
- Instalador, `.sh`, `setup -Yes`, CI de release, jerarquía completa de templates de producto → **Sprint 3**.
- Corpus de fuentes de la doctrina → bloqueado por PII de historial (no-asciende, registrado).
- Banner/identidad visual y comunidad → **Sprint 4**.
