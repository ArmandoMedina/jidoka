# ADR 0057 — El candado de procedencia del ROADMAP: todo ítem vivo cita de dónde vino, con gate

- **Estado:** aceptado
- **Fecha:** 2026-07-23

> **Enmienda (ADR 0057, 2026-07-23):** el candado gana un **segundo requisito hermano** — el guion de revisión (`roadmap.guion_revision`, R2). La decisión de procedencia sigue vigente sin cambio; lo que se agrega es que un ítem **ejecutable** además declare *cómo se revisa*. Detalle abajo, en «Decisión — segundo requisito».

## Contexto

El 2026-07-23 el dueño no reconocía la mayoría de sus pendientes: 41 de 62 ítems del ROADMAP no citaban ninguna fuente y git no lo suplía (el reformateo de FLU-1 había aplanado la historia). La poda por procedencia (32 huérfanos a `docs/MUERTOS.md`, 9 rescatados con puntero verificado) aplicó la regla a mano, pero **al no ser mecanismo el hueco volvió al día siguiente** — un ítem sin origen se coló de nuevo. El contrato del ROADMAP (ADR 0049) ya exige `alta:`/`apetito:`/`vence:` con gate en `verificar.ps1`; falta el campo que dice **de dónde viene** el pendiente. Evidencia y método: [`exploracion-procedencia-del-backlog-202607.md`](../analisis/exploracion-procedencia-del-backlog-202607.md).

## Decisión

Se extiende el contrato del ROADMAP (ADR 0049) con un requisito nuevo, gateado en `verificar.ps1` (check `[contrato-roadmap]`): **cada ítem vivo debe citar su procedencia** — un puntero a una fuente durable y trazable. Las fuentes aceptadas son: un informe de `docs/analisis/`, un récord de `docs/sprints/`, un ADR (`docs/decisions/` o `ADR NNNN` textual) o un issue (`#NNN`). Aplica a **toda clase viva**, incluido el icebox «Algún día» (como el `alta:`). Un ítem sin ninguna de esas fuentes bloquea el push (exit 1).

El requisito es **opt-in por instancia**: se activa con `roadmap.procedencia: true` en `tools/flujo.json`. Esta nave lo enciende; un repo hijo lo adopta cuando su ROADMAP esté listo. La regla la dictó el dueño el 2026-07-23.

### Decisión — segundo requisito (guion de revisión, R2)

Además de citar su origen, cada ítem **ejecutable** (Urgente/Con fecha/Normal) debe **declarar cómo se revisa**: citar un informe de `docs/analisis/` que traiga una sección de guion de revisión (encabezado «Qué debe revisar el dueño» / «guion de revisión»), **o** un récord de `docs/sprints/` (cuya sección Verificación es el guion por molde). Sin guion, un pendiente no es *ejecutable*. Gateado en el mismo check `[contrato-roadmap]`, opt-in con `roadmap.guion_revision: true`. Dos fronteras deliberadas:

- **El icebox «Algún día» va exento.** Su justificación es la propia palabra del dueño: «un pendiente sin guion no es *ejecutable*». El icebox no es ejecutable por definición — espera al N-ésimo caso real — así que exigirle guion sería método-ficción. La procedencia (R1) sí lo cubre; el guion (R2) no.
- **Un récord de sprint cuenta como guion.** El molde de sprint garantiza una sección Verificación/demo; es un guion de revisión legítimo. Un ADR o un `#issue` **no** cuentan para R2 (son procedencia/razón, no pasos de revisión) — esto mantiene R2 más estricto que R1.

## Por qué

- **La regla en prosa ya falló, medido:** se aplicó a mano y el hueco volvió en 24h. Un mecanismo de gobierno es muro solo si el punto de control vive fuera del criterio voluntario (`doctrina/00-tesis.md`); una regla de backlog que depende de recordarla no es muro.
- **Espeja el mecanismo que ya funciona:** `alta:`/`apetito:`/`vence:` se hacen cumplir así desde el 0049; la procedencia es el mismo patrón, un campo obligatorio más.
- **Opt-in protege el lazo:** un hijo con ROADMAP sin punteros no se rompe al `-Actualizar` (gentileza no-clobber, KIT-1 / ADR 0012). La disciplina se enciende cuando el hijo la adopta, no se le impone al bajar la máquina.

## El camino que NO se toma (y por qué tienta)

**Hacer el candado always-on** (sin flag). Tienta porque es una línea menos de config y «la regla debería valer para todos». Se descarta: reventaría el ROADMAP de cualquier hijo ya sembrado en cuanto actualice el motor, exactamente el back-out recurrente que el ADR 0022 y el lazo por-hash existen para evitar. La regla es doctrina de esta nave; su *enforcement* viaja apagado y cada instancia lo enciende — igual que el muro de docs-gobernados es opt-in en CI.

También se consideró **restringir las fuentes a solo `docs/analisis/`/ADR/issue** (la formulación literal del dueño). Se amplió a `docs/sprints/` al medir: el ítem «Gemba end-to-end de la app» cita su récord de sprint como origen legítimo y trazable. El gate mide *presencia de un puntero durable*, no juzga la calidad del origen (esa la pone el humano) — negarle valor a un récord de sprint sería un falso rojo.

## Consecuencias

- **Más fácil:** auditar de dónde salió cada pendiente; el ROADMAP no se vuelve a llenar de ítems sin dueño de origen.
- **Más difícil:** agregar un ítem al vuelo — ahora exige nombrar su fuente antes del push. Es el costo buscado.
- **Deuda abierta:** el gate de procedencia verifica que el puntero a `docs/…` o `ADR NNNN` **resuelva a un archivo existente** (endurecido en el cierre de deuda del sprint 28), no que ese archivo *tenga contenido de origen real* — un puntero a un `docs/analisis/` que existe pero no habla del ítem pasaría; y el `#issue` no se verifica localmente. El requisito de guion (R2, arriba) sí abre el informe citado y exige la sección de revisión; pero tampoco juzga que el guion sea *bueno* (solo que existe el encabezado).

## Qué NO resuelve

- **Sí** valida que un puntero a `docs/…` o `ADR NNNN` **resuelva** a un archivo existente (endurecido en el cierre de deuda del sprint 28); lo que **no** valida es que ese contenido *justifique* el ítem, ni la existencia del `#issue` (no verificable localmente). La verdad de fondo la pone el humano.
- No cubre el `HANDOFF` ni el `CHANGELOG`: la procedencia es del ROADMAP, la cola de trabajo.
- **No resuelve el junction/symlink NTFS local en la resolución de punteros (R1/R2).** El gate normaliza `..` y confirma que la ruta resuelta cae dentro de `docs/` (R1) o `docs/analisis/` (R2), pero un *reparse point* (junction/symlink) plantado dentro de esos árboles hace que la comparación léxica `StartsWith` acepte un archivo físicamente fuera del repo. Límite consciente por **proporcionalidad**: (a) exige control local del working tree — quien puede plantar un junction ya puede editar el ROADMAP directo o `--no-verify`; (b) git no versiona el *target*, no viaja por PR, y el CI (el muro real, ADR 0003) hace checkout de un árbol limpio sin el junction; (c) el gate mide *procedencia* (autodisciplina), no es superficie de ataque remota. Resolver reparse points en PS 5.1 es frágil (`.ResolveLinkTarget` no existe) y no compra nada que el muro server-side no cubra.
