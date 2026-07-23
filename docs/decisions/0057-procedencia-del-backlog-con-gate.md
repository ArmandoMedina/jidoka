# ADR 0057 — El candado de procedencia del ROADMAP: todo ítem vivo cita de dónde vino, con gate

- **Estado:** aceptado
- **Fecha:** 2026-07-23

## Contexto

El 2026-07-23 el dueño no reconocía la mayoría de sus pendientes: 41 de 62 ítems del ROADMAP no citaban ninguna fuente y git no lo suplía (el reformateo de FLU-1 había aplanado la historia). La poda por procedencia (32 huérfanos a `docs/MUERTOS.md`, 9 rescatados con puntero verificado) aplicó la regla a mano, pero **al no ser mecanismo el hueco volvió al día siguiente** — un ítem sin origen se coló de nuevo. El contrato del ROADMAP (ADR 0049) ya exige `alta:`/`apetito:`/`vence:` con gate en `verificar.ps1`; falta el campo que dice **de dónde viene** el pendiente. Evidencia y método: [`exploracion-procedencia-del-backlog-202607.md`](../analisis/exploracion-procedencia-del-backlog-202607.md).

## Decisión

Se extiende el contrato del ROADMAP (ADR 0049) con un requisito nuevo, gateado en `verificar.ps1` (check `[contrato-roadmap]`): **cada ítem vivo debe citar su procedencia** — un puntero a una fuente durable y trazable. Las fuentes aceptadas son: un informe de `docs/analisis/`, un récord de `docs/sprints/`, un ADR (`docs/decisions/` o `ADR NNNN` textual) o un issue (`#NNN`). Aplica a **toda clase viva**, incluido el icebox «Algún día» (como el `alta:`). Un ítem sin ninguna de esas fuentes bloquea el push (exit 1).

El requisito es **opt-in por instancia**: se activa con `roadmap.procedencia: true` en `tools/flujo.json`. Esta nave lo enciende; un repo hijo lo adopta cuando su ROADMAP esté listo. La regla la dictó el dueño el 2026-07-23.

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
- **Deuda abierta:** el gate verifica que el puntero *exista*, no que el archivo apuntado *tenga contenido de origen real* — un puntero a un `docs/analisis/` que no habla del ítem pasaría. El segundo requisito (que el puntero alcance una sección «Qué debe revisar el dueño») es la tarjeta hermana R2 de este mismo sprint.

## Qué NO resuelve

- No valida que el puntero **resuelva** a un archivo existente ni que su contenido justifique el ítem — solo mide co-ocurrencia de un patrón de fuente (límite conocido del muro, `andon/README.md` grieta #3). La verdad la pone el humano.
- No cubre el `HANDOFF` ni el `CHANGELOG`: la procedencia es del ROADMAP, la cola de trabajo.
