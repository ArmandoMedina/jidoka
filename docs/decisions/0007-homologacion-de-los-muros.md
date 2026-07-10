# ADR 0007 — La homologación de los muros: los gates de cierre y el auditor, cosechados de los casos de éxito

- **Estado:** aceptado
- **Fecha:** 2026-07-10
- **Sprint:** 2 · Fase B

## Contexto

La Fase A volvió ejecutable el *ritual* (comandos + skills), pero faltaban los **muros** que lo hacen cumplir. Al ir a construirlos se descubrió que los dos casos de éxito vivos del linaje (`docs/casos-de-exito.md`) **ya los tenían, probados en producción** — Jidoka, la destilación pública, se había quedado atrás. La dirección correcta la fija el ADR 0005: los casos vivos **alimentan** el método (labs → Jidoka), nunca al revés. Así que esta fase no fue diseño desde cero, sino **homologación** (`kanban/homologacion.md`): cosechar hacia arriba lo ya probado, neutralizado y anonimizado.

El dolor que estos muros previenen, pagado en los labs: un "probé clic por clic" sin artefacto convivió con una UI rota a ojo; y código sin revisar se cerró más de una vez. *Lo que el dueño corrigió más de una vez es lo que la metodología debe prevenir.*

## Decisión

Ascienden a Jidoka, **genéricos y auto-configurables desde la ley** (criterio-no-copia — nada hardcodea el layout de un hijo):

1. **`review-stop`** — Stop hook: código sin `/code-review` frena el cierre. "Código" se lee de la ley (áreas con `"revisa": true`), no de una ruta fija. Marcador `.claude/.review-marker`.
2. **`gemba-stop`** — Stop hook (el gate visual, antes con nombre propio de persona en el lab): se auto-configura desde las áreas `rol: revisor-visual`; si no hay ninguna, queda **dormido**. Evidencia fresca = artefacto en `qa_runs/` con mtime posterior al cambio visual. Marcador `.claude/.gemba-marker`.
3. **El auditor del grafo** (`tools/auditar.ps1`) — frontmatter, wikilinks, Gherkin de las capacidades `vigente`, huérfanas; modulado por estado. Corre en CI (`-Range base...HEAD -Bloquea`).
4. **La dimensión `product_avisa`** en la ley — sincronía del grafo de producto, no solo de docs técnicos.
5. **Los avisos suben a la superficie del PR** (job summary) — cierra la **grieta 1** de la auditoría externa (un aviso ignorado dejaba el check verde e invisible).
6. **Prueba de vida** para todo lo nuevo: `tools/probar-hooks.ps1` y `tools/probar-auditor.ps1` (los labs no tenían harness de hooks — es invención de Jidoka).

También se siembra un **grafo `product/` mínimo** (dominio Método → módulos → capacidades RIT-1 y AND-1) para que el auditor tenga qué morder (dogfooding), y `product/` deje de ser el vacío.

## Por qué

- **Cosechar lo probado supera diseñar desde cero.** La mecánica fina que preocupaba (cómo medir "evidencia fresca") ya estaba resuelta en los labs: mtime del `qa_runs/` contra el cambio visual, corriendo local en el Stop donde el mtime es fiable.
- **El marcador SHA no es auto-firma.** La doctrina prohíbe archivos de "el rol X validó" (`kanban/roles.md`). Aquí el marcador lo pone **el humano** tras revisar, y el hook **verifica** que el SHA sea el del diff real: lo que se cuela, se atrapa. Es válvula humana, no sello del agente.
- **Anonimización real.** Los nombres propios de persona del casting de los labs bajan a roles genéricos (`revisor-visual`); un grep de frontera NDA sobre lo ascendido confirmó cero términos del trabajo (`kanban/homologacion.md` paso 4).

## El camino que NO se toma (y por qué tienta)

- **Un `auditar-radius.ps1` aparte** (auditoría de blast-radius por rango/por-commit, como en los labs). Tienta por paridad con el origen. Se descarta: sería un **tercer copia del matcher** de blast-radius (contra "elimina la redundancia, no automatices la sincronización", `docs/casos-de-exito.md`). El blast-radius sobre el rango del PR ya lo cubre `verificar.ps1 -Base` en CI; la única ganancia real —granularidad por-commit— es marginal frente al costo de mantener tres copias sincronizadas. Queda como candidato "espera maduración" (regla 2–3).
- **Portar el casting con nombres propios.** Mismo criterio del ADR 0005: Jidoka ya genericizó los asientos; no se retrocede.

## Consecuencias

- Jidoka alcanza a sus labs en los muros de cierre y el auditor del grafo; el ritual (Fase A) ya tiene quién lo haga cumplir.
- La ley crece: `product_avisa` y el flag `revisa` por área; dos hooks nuevos cableados en `.claude/settings.json`.
- Deuda abierta (Sprint 3): el auditor code-first (lint/formato/cobertura/CHANGELOG-gate) y el instalador `npx jidoka-method init` — los labs **no** tienen sembrador (se homologaron de un *starter*); ese es el ancestro del instalador.

## Qué NO resuelve

- **`gemba-stop` nace dormido en Jidoka** (no hay áreas visuales): su prueba de vida vive en el self-test (área visual sintética), no en el repo. Cuando Jidoka tenga UI, se enciende con un `rol: revisor-visual` en la ley.
- **La frontera del mtime:** un `git checkout`/clone reescribe mtimes; por eso `gemba-stop` corre **local en el Stop** (mtime fiable), no en CI. Documentado en `andon/README.md`.
- **Bordes conocidos del `/code-review` de la Fase B** (registrados para que nadie los redescubra a golpes, no silenciados): el marcador SHA de `review-stop` es ciego al contenido de archivos **untracked** (`git diff HEAD` no los ve); un archivo visual **eliminado** deja que `gemba-stop` acepte evidencia vieja como fresca; y el parseo de `git status --porcelain` no casa código dentro de un **directorio nuevo untracked**. Los tres son bordes heredados del código probado de los labs (6 sprints sin morder) — se documentan como límites, no se divergen del origen probado. El auditor colisiona stems de notas con el mismo nombre en carpetas distintas: irrelevante en el grafo actual, re-evaluar si crece.

---

> Reglas del registro: una decisión = un archivo · al agregarlo, **listalo en el [índice](README.md) en el mismo commit** (el gate lo exige) · nunca borres una decisión: márcala *reemplazada* y enlaza la nueva.
