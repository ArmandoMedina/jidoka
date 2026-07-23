---
tipo: analisis
estado: vigente
---
# Exploración — de dónde vino cada pendiente del ROADMAP (2026-07-23)

> **Qué es.** Segunda vuelta de la kata de mejora (`doctrina/08-kata-de-mejora.md`). Su pregunta
> nace de un síntoma que el dueño reportó el 2026-07-23: al abrir el ROADMAP no reconoce la
> mayoría de sus pendientes, y declara no tener contexto suficiente para ejecutarlos ni
> validarlos. La exploración mide **si el ROADMAP conserva la procedencia de sus ítems** — y
> concluye que no la conserva, ni en el documento ni en git. El informe se queda en medición y
> decisión; **no construye el mecanismo** (decisión del dueño el mismo día: la cura se encola,
> no se ejecuta durante una exploración).

## Las cinco preguntas de la kata

> **Confesión de método, primero.** Estas cinco preguntas son el cuestionario de
> `doctrina/08-kata-de-mejora.md` y **no se hicieron al empezar**: se respondieron al final, cuando
> el dueño notó que faltaban. La causa está medida abajo (*Rojo honesto*): el molde
> `kit/.jidoka/templates/exploracion.md`, escrito el 2026-07-23 a partir de ese mismo capítulo,
> **no incluye las cinco preguntas** — así que seguir el molde garantiza saltárselas. La respuesta
> 4 se marca como fallada a propósito; no se inventa una hipótesis retroactiva.

1. **¿Cuál es la condición objetivo?** Que el dueño pueda abrir el ROADMAP y, de cualquier ítem,
   llegar en un clic a la evidencia que lo originó — sin preguntarle a nadie y sin depender de la
   memoria de una sesión. Un pendiente que no puede decir su origen no es cola de trabajo: es
   inventario.
2. **¿Cuál es la condición actual?** Medida abajo. En corto: 41 de 62 ítems (66 %) no citan nada,
   git no puede suplirlo porque el reformateo de FLU-1 aplanó la historia, y el contrato del
   ROADMAP no exige procedencia.
3. **¿Qué obstáculos, y cuál atacas AHORA?** Obstáculos hallados: (a) el contrato no exige
   puntero; (b) la ventana de vencimiento de 90 días deja sobrevivir lo huérfano; (c) los informes
   de análisis pueden no commitearse y morir con la sesión; (d) el molde de exploración no obliga
   a la kata. **Se ataca (a)** — es el que produce el síntoma que el dueño reportó, y los otros
   tres quedan escritos aquí sin tocarse.
4. **¿Cuál es tu siguiente paso y qué esperabas que pasara?** **Fallada.** No se escribió
   hipótesis antes de medir; se midió primero y se concluyó después. La medición sigue siendo
   válida (es aritmética sobre el documento, reproducible con los comandos del *Método*), pero
   esta vuelta **no fue un experimento**, fue un censo. Nombrarlo es el único modo de que la
   siguiente vuelta no repita el atajo.
5. **¿Cuándo vemos qué aprendiste?** Al cierre de esta sesión, con el guion de revisión de abajo.
   La cita de seguimiento que este informe pide: **volver a contar los ítems huérfanos cuando el
   candado esté cableado** — si el número no es cero, el gate no sirve.

## La pregunta

**¿El ROADMAP puede decir de dónde vino cada uno de sus pendientes?**

**Timebox declarado:** una sesión · **Corte:** 2026-07-23 · v1.32.0

## Método

Dos mediciones independientes sobre el mismo objeto, más una lectura de fuentes primarias:

1. **Procedencia declarada.** Parseo de `ROADMAP.md` (todas las clases de servicio menos
   `Referencia`) contando, por ítem, referencias a `docs/analisis/*`, ADRs e issues del repo.
2. **Procedencia rastreable en git.** Por cada ítem, `git log --reverse -S"<fragmento del
   título>" -- ROADMAP.md` para hallar el commit que lo introdujo.
3. **Lectura de las 6 sesiones de trabajo del 2026-07-22 y 2026-07-23** (transcripts `.jsonl` de
   la herramienta, destilados a turnos humano/agente y leídos por cuatro subagentes `auditor` en
   paralelo, con acta de formato fijo). Fuente de los patrones de la sección siguiente.

## Condición actual (medida)

- **62 ítems vivos.** 11 citan un doc de `docs/analisis/`; 10 citan un ADR o un issue; **41 no
  citan nada** (66 %).
- **Git no puede suplir el hueco.** El commit `8915973` (`feat(flujo): R2 -- el contrato del
  ROADMAP con gate`) reescribió el documento completo al formato del contrato FLU-1, así que
  ~30 ítems tienen ese commit como único origen rastreable. **La reformateada aplanó la
  historia:** el commit que introdujo la línea ya no es el commit que originó la idea.
- **El contrato del ROADMAP no exige procedencia.** `tools/verificar.ps1:300` valida `alta:`,
  `apetito:\d+h` y `vence:`. Ningún check exige un puntero. La regla existe en prosa —el dueño la
  dictó el 2026-07-23 al pedir que ningún ítem del backlog quede sin referencia— y se aplicó a
  mano a 9 tarjetas ese día; nunca se volvió mecanismo, y por eso reaparece como pedido al día
  siguiente.
- **El circuit breaker no alcanza a disparar.** `tools/flujo.json` fija
  `vencimiento_dias.normal = 90`. Con esa ventana, un ítem sin dueño ni contexto sobrevive tres
  meses. Al correr `expirar.ps1 -Simular` el 2026-07-23: 0 vencidos, 0 por vencer en ≤7 días.
  El mecanismo está vivo y correcto; el parámetro lo deja sin morder.
- **La procedencia se pierde también fuera del ROADMAP.** El informe
  `docs/analisis/benchmark-panorama-202607.md`, producido el 2026-07-22 y citado en esa sesión
  como origen de una dirección de producto, **nunca se commiteó y no existe en disco**
  (`git log -- <ruta>` vacío). El razonamiento que lo respaldaba murió con la sesión.

### El patrón, en las seis sesiones leídas

El síntoma no es de memoria: es de flujo. En las tres sesiones el freno a la producción de
ítems lo puso el dueño, no el método — el 2026-07-22 al declarar que no alcanzaba a leer lo
producido y mandar todo al backlog; el 2026-07-23 al cortar dos veces el escalamiento a lenguaje
de línea de producción y pedir que la sesión se quedara en exploración. En dos sesiones distintas
el dueño se autodiagnosticó lo mismo con un día de diferencia: que estaba usando la línea de
producción para aprender. **El ROADMAP es donde esa sobreproducción se acumula**: cada ítem
cuesta minutos de escribirse y horas de la atención del dueño, que es la restricción declarada
del sistema (`product/casting.md`).

## Resultado — rojo → verde

**Ninguno. Esta vuelta no curó nada, a propósito.** El dueño decidió el 2026-07-23 que el
mecanismo (el candado de procedencia) no se construye durante la exploración: se encola con
puntero a este informe. Lo único ejecutado fue la poda, que es una decisión suya, no un
mecanismo.

## Rojo honesto (medido, sin cura)

- **32 ítems sin procedencia declarada** y sin forma de reconstruirla desde git. Se podaron a
  `docs/MUERTOS.md` por orden del dueño (2026-07-23), con su texto íntegro: revivir es
  re-proponer con alta nueva. **La poda dejó 30 supervivientes (62 − 32); el ROADMAP nunca
  estuvo en 30**: el mismo commit agregó las tarjetas que esta vuelta graduó, así que el estado
  real en disco fue 36. Se dice así porque «quedó en 30» describe un momento que ningún artefacto
  respalda — corregido tras la auditoría de cifras del 2026-07-23.
- **9 de los 41 huérfanos tenían procedencia real pero no la citaban.** Se verificó por búsqueda directa en el
  doc respaldante (`escaneo-camino-2.0-202607.md`, `senales-tableros-202607.md`,
  `gemba-gestion-del-flujo-202607.md`) y se les escribió el puntero en vez de matarlos. Esto
  demuestra que **el hueco era de escritura, no de existencia**: la evidencia estaba, la liga no.
- **La ventana de vencimiento de 90 días no se tocó.** Queda sin clasificar si es un valor
  deliberado o un default heredado; lo decide el dueño.
- **El molde de exploración no obliga a la kata (defecto medido en esta vuelta).**
  `kit/.jidoka/templates/exploracion.md` nació el 2026-07-23 del capítulo
  `doctrina/08-kata-de-mejora.md`, pero **ninguna de sus secciones corresponde a las cinco
  preguntas** de ese capítulo: tiene «La pregunta» (que cubre la 1 a medias y omite la condición
  objetivo), «Condición actual» (la 2) y un timebox (parte de la 5); **no tiene condición
  objetivo, ni elección de un solo obstáculo, ni hipótesis-antes-de-moverse, ni cita de
  revisión**. Consecuencia observada en vivo: esta exploración siguió el molde al pie de la letra
  y aun así se saltó la kata, hasta que el dueño lo notó. El molde está en n=1 y fuera del ledger
  de gobierno, así que corregirlo es barato — pero **ya se siembra a todos los hijos**, y hoy
  distribuye el atajo.

## Lo NO medido

- **Si un hook `PreToolUse` puede distinguir al subagente que lo invoca.** De esto depende que un
  «asiento de exploración» con allowlist de rutas sea realmente **un asiento** o solo **un modo de
  sesión** (que restringe también al hilo principal). No se probó nada: no hay medición y por lo
  tanto no hay diseño.
- **El costo de la poda.** No se midió cuántos de los 41 podados vuelven a proponerse en las
  próximas semanas. Ese número es el único juez de si la poda fue limpieza o pérdida.
- **Los ítems de `docs/roadmap-historico.md`** no se revisaron: la medición cubrió solo el
  ROADMAP vivo.
- **Si el contrato debe exigir procedencia en todas las clases de servicio o solo en las vivas.**

## Qué debe revisar el dueño (guion)

### La poda — 10 min

1. **Haz esto:** abre `docs/MUERTOS.md` y lee los títulos de la entrada del 2026-07-23.
   **Debe pasar:** ninguno te resulta indispensable, o los que sí reconoces los nombras para
   revivirlos. **Recházalo si** reconoces más de tres como trabajo que sí ibas a hacer — sería
   señal de que la regla cortó demasiado y hay que revivir, no re-podar.
2. **Haz esto:** abre `ROADMAP.md` y recorre los ítems que quedaron. **Debe pasar:** cada uno
   tiene una liga a un informe, un ADR o un issue, y esa liga te dice en un clic de dónde salió.
   **Recházalo si** encuentras un ítem sin liga: la regla no se aplicó completa.

### La prueba de que la regla no vive todavía — 5 min

3. **Haz esto:** agrega a mano al final de la sección `## Normal` del ROADMAP una línea
   inventada, sin liga a nada:
   `- **Prueba del candado** ` + `` `[alta:2026-07-23 · apetito:1h]` `` + ` — sin puntero a nada.`
   Luego corre en la terminal: `powershell -NoProfile -File tools/verificar.ps1`
   **Debe pasar:** el verificador **pasa en verde y acepta el ítem huérfano**. Ese verde es el
   defecto: hoy nada impide que vuelva a llenarse el ROADMAP de pendientes sin origen.
   **Recházalo si** el verificador lo bloquea — significaría que el candado ya existe y esta
   tarjeta del ROADMAP sobra. **Borra la línea de prueba al terminar.**

## Qué se descarta (y por qué)

- **Podar por «tiene referencia a una exploración»**, la regla literal que el dueño propuso
  primero: mataba 51 de 62 ítems, incluidas las cuatro tarjetas de la ola de UI que son el
  siguiente sprint decidido. Se descartó por sobre-corte, con su acuerdo el mismo día.
- **Reconstruir a mano la procedencia de los 41 huérfanos.** Descartado por el dueño: revisó los
  pendientes y declaró no tener contexto suficiente para ejecutarlos ni validarlos, de modo que
  un puntero reconstruido por el agente le daría una tarjeta accionable sobre el papel e
  inaccionable en la práctica. Reiniciar es más barato que arqueología.
- **Construir el candado en esta misma sesión.** Descartado por el dueño: es exploración, y el
  mecanismo se encola con puntero a este informe.

## Qué mata este informe si se adopta

- **Mata 41 tarjetas del ROADMAP** (listadas íntegras en `docs/MUERTOS.md`, entrada 2026-07-23).
  Cualquier documento que las citara por título deja de decir la verdad.
- **Mata la suposición de que git conserva la procedencia** de un documento de estado: el
  reformateo de FLU-1 la borró. Un ADR futuro que reformatee un doc de cola debe migrar la
  procedencia o declarar que la pierde.
- **No supersede ningún ADR.** El contrato del ROADMAP (ADR 0049) sigue vigente: esto lo
  **extiende** con un campo más, no lo reemplaza.

## Qué gradúa

Tres tarjetas al ROADMAP, todas con puntero a este informe:

1. **El candado de procedencia** — `verificar.ps1` exige que todo ítem vivo cite un informe, un
   ADR o un issue, igual que hoy exige `apetito:`.
2. **El asiento (o modo) de exploración con allowlist de rutas** — restringir la escritura a
   `ROADMAP.md` + `docs/analisis/**` por hook `PreToolUse`, con la medición pendiente de la
   sección «Lo NO medido» como primer paso.
3. **El molde de exploración carga las cinco preguntas** — que
   `kit/.jidoka/templates/exploracion.md` abra con la kata del capítulo 08 (condición objetivo,
   condición actual, obstáculo elegido, hipótesis antes de moverse, cita de revisión) en vez de
   dejarlas implícitas. Es la segunda vuelta de la kata la que lo detecta, que es exactamente
   como la regla 2-3 dice que debe madurar un molde.

Al brief no gradúa nada. Ningún criterio de aceptación cambia.
