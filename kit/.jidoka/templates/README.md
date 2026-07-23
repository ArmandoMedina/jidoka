# Templates — los formatos probados del ritual

> Estructuras que sobrevivieron sprints reales en el linaje (no se diseñaron en abstracto: cada sección existe porque faltó alguna vez). Se **copian**, no se redactan de cero — copiar la plantilla es la tarea 0 de cualquier doc nuevo.

| Plantilla | Para qué | ¿Se versiona? |
|---|---|---|
| [`sprint-plan.md`](sprint-plan.md) | El plan que apruebas en plan mode. **El plan aprobado ES el sprint** | **Sí** — se archiva en `docs/sprints/` (es el contrato) |
| [`sprint-entrega.md`](sprint-entrega.md) | El récord de cierre: qué se entregó, la evidencia, el Kaizen | **Sí** — es el récord |
| [`plan-de-trabajo.md`](plan-de-trabajo.md) | Plan persistido para una tarea larga que puede morir a media ejecución | **No** — es efímero (lección del linaje: versionarlo creó contradicción entre plan y realidad). Vive fuera de git y se borra al terminar |
| [`adr.md`](adr.md) | Una decisión y su porqué — incluido el camino que NO se tomó | **Sí** — permanente, y se lista en su índice en el mismo commit |
| [`exploracion.md`](exploracion.md) | La vuelta de la kata (`doctrina/08`): la pregunta, lo medido, **lo NO medido**, el guion de revisión del dueño y qué mata. **n=1 — no es formato probado todavía** | **Sí** — el informe va a `docs/analisis/`; en el ROADMAP solo la tarjeta y el puntero |

## Ownership por sección

Las plantillas de sprint declaran secciones con **dueño**. La regla que importa: la sección de **"Verificación (el demo que corre el cliente)"** y la revisión del stakeholder son **del cliente** — los agentes las proponen, nunca las dan por cumplidas. *"Hecho" = el cliente lo vio funcionar.*

## Gobierno del molde — dónde se cambia la regla de verdad

> **El template es de dónde COPIAS; no es donde vive la regla del muro.** El muro exige un **subconjunto mínimo** de secciones (no todas las del template). Si tocas el template y quitas/renombras una sección que el muro exige, **truena un self-test** (el template no puede desviarse en silencio). Para cambiar **qué es obligatorio**, edita el *lever* de abajo — no basta con editar el template.

| Familia (template) | Dónde vive la regla (el *lever*) | Quién la hace cumplir | Qué truena si cambias el template |
|---|---|---|---|
| `sprint-plan.md`, `sprint-entrega.md`, `qa-log.md` | **el ledger** `tools/docs-gobernados.json` (campo `requeridas`) | `tools/estado-docs.ps1` (aviso; muro opt-in en CI) | `tools/probar-docs.ps1` (Parte B: cada `requerida` debe existir en el template) |
| ADR (`docs/decisions/0000-plantilla.md`) | **el código** `tools/probar-adrs.ps1` (`$REQUERIDAS`) | `tools/probar-adrs.ps1` (MURO, exit 1) | `tools/probar-adrs.ps1` (verifica `$REQUERIDAS` ⊆ la plantilla) |
| `producto/modulo.md`, `producto/dominio.md` | **el código** `tools/auditar.ps1` (sección núcleo por estado) | `tools/auditar.ps1` (a los vigentes) | `tools/probar-auditor.ps1` (verifica la sección núcleo en el template) |

**En una frase:** cambias el formato editando el *lever* (ledger o `.ps1`) **y** el template en el mismo commit; el self-test se planta si divergen. El template solo no gobierna — pero tampoco puede desviarse a escondidas.
