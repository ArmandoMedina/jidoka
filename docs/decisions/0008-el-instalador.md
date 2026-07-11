# ADR 0008 — El instalador mínimo: PowerShell-first, siembra leyendo del árbol, un arquetipo

- **Estado:** aceptado
- **Fecha:** 2026-07-10
- **Sprint:** 3 · Fase 3.A

## Contexto

Jidoka ya tiene el ritual (Fase A) y los muros (Fase B), pero no había forma de **instalarlo** en otro repo — la meta del cliente (probarlo en un repo/VM limpio, el criterio de la 1.0) lo exige. La exploración reveló que el ancestro (`project-starter`) **no tiene instalador**: siembra con "Use this template" de GitHub + borrado manual. Así que el acto de sembrar programáticamente es invención nueva. El Sprint 3 completo es enorme (CLI npm cross-platform + matriz de 3 arquetipos + 12 templates de producto + multiplataforma + SSOT de versión + release-CI); se fasea, y esta Fase 3.A entrega el **instalador mínimo que corre**.

## Decisión

1. **El instalador MVP es un script PowerShell** (`tools/instalar.ps1`), Windows-first — consistente con el motor (todo es PS 5.1) y sin dependencia de Node/npm. El cliente lo corre local o en su VM.
2. **Siembra leyendo el motor genérico del propio árbol de Jidoka**, sin duplicarlo. `verificar.ps1` y `auditar.ps1` ya son data-driven (`-Repo`/`-Manifiesto`); los hooks, `settings.json`, `pre-push` y `andon.yml` son plantillas con rutas. Lo **único nuevo** en el kit es la **ley-plantilla por arquetipo** — la de Jidoka es una instancia con áreas propias (`doctrina`, `kanban`, `kit`…) que no sirven a un repo ajeno.
3. **Un arquetipo en el MVP: `docs-as-code`** (el que Jidoka mismo es). `code-first` y `doc-only` avisan "en camino" y viven en el ROADMAP.
4. **Regla dura NO CLOBBER:** el instalador nunca sobrescribe un archivo existente en el destino (lo salta y lo reporta). Instalar sobre un repo con trabajo no borra nada.
5. **El smoke (`tools/probar-instalador.ps1`) es obligatorio:** instala en un repo temporal, commitea, y corre los self-tests **sembrados** + `verificar` ahí. Un instalador que siembra un motor roto se caza en su propia prueba de vida (disparo `prueba-de-humo-del-gate`).

## Por qué

- **Windows-first + PowerShell** es coherente con dónde vive Jidoka hoy (dev y VMs del cliente son Windows/PS 5.1) y evita meter Node/npm antes de que el instalador esté sólido — el cliente ni usa npm todavía.
- **Leer del árbol en vez de duplicar** esquiva la deuda del ADR 0003 (motor solo en `kit/`, cero copias de la ley) **sin** el gran restructure riesgoso: hay una sola copia del motor (la de Jidoka), y el instalador la copia hacia afuera. El dogfood completo (Jidoka auto-instalándose) queda para después, documentado.
- **Un arquetipo bien hecho > tres a medias.** El `docs-as-code` es el que Jidoka dogfoodea; probarlo end-to-end da más señal que tres leyes-plantilla sin ejercitar.

## El camino que NO se toma (y por qué tienta)

- **El CLI npm (`npx jidoka-method init`) de una.** Tienta porque es lo que el ROADMAP prometió y da distribución cross-platform. Se descarta para el MVP: exige cuenta/registro npm, SSOT de versión publicable, CI de release + smoke, y reescribir el motor a multiplataforma — semanas antes de que el cliente pueda *probar algo*. El PowerShell corre hoy; el npm es la envoltura de una fase posterior con la misma lógica.
- **Mover todo el motor a `kit/` ya (dogfood completo del ADR 0003).** Tienta por pureza ("cero duplicación"). Se descarta ahora: es un restructure grande que tocaría el CI y los hooks de Jidoka en el mismo corte que estrena el instalador — demasiado riesgo junto. Leer del árbol logra "cero duplicación" de facto sin mover nada.

## Consecuencias

- El cliente puede correr `./tools/instalar.ps1 -Destino <repo-limpio>` y tener Jidoka sembrado y verde en una VM — el primer paso verificable hacia la 1.0 ("corre en un repo ajeno").
- La ley gana el área `kit` (gobierna el instalador y el kit sembrable).
- Deuda abierta grande, registrada en el ROADMAP (Sprint 3, fases siguientes): los otros 2 arquetipos + la matriz ejecutable; los 12 templates de producto + PRODUCT_BRIEF + benchmark; multiplataforma (`.sh`/`pwsh`); el CLI npm + SSOT de versión + release-CI + smoke en CI + ensayo del empaquetado; barreras code-first; el dogfood completo del ADR 0003.

## Qué NO resuelve

- **Los comandos/skills sembrados citan docs de método de Jidoka** (`kanban/`, `docs/guias/`) que **no se siembran** en el MVP: sus enlaces de prosa quedan muertos en un repo ajeno (los `@`-refs duros —HANDOFF, plantillas del kit— sí resuelven). Sembrar un set de método genérico, o apuntar a los docs públicos de Jidoka, es trabajo de una fase siguiente.
- **No hay distribución todavía**: se corre desde el árbol de Jidoka. El empaquetado que viaja solo (npm/tarball) es la fase npm.

---

> Reglas del registro: una decisión = un archivo · al agregarlo, **listalo en el [índice](README.md) en el mismo commit** (el gate lo exige) · nunca borres una decisión: márcala *reemplazada* y enlaza la nueva.
