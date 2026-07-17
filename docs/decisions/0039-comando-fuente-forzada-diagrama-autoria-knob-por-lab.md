# ADR 0039 — El comando es la fuente forzada; el diagrama-primero es hábito de autoría; la dirección del acoplamiento es un knob por-lab

- **Estado:** aceptado
- **Fecha:** 2026-07-17

## Contexto

ADR 0036 fijó el acoplamiento proceso↔docs↔diagrama como **asimétrico**: el `.md` del comando es la fuente, el diagrama es una vista, y se cablea un **aviso** (área `atlas`) cuando tocas un comando sin actualizar su diagrama. Durante la sesión de re-estilo del atlas (2026-07-17, `10-arranca` a Method & Style), el cliente cuestionó esa dirección: para él lo correcto sería **dibujar el BPMN primero y luego escribir el `.md`** — es decir, que el diagrama fuese la fuente de verdad. La escuela de modelado (Bruce Silver: modelar el proceso como plano compartido antes de implementarlo) respalda ese instinto.

Dos hechos tensan la pregunta:

1. **El `.md` es el ejecutable.** Cuando se corre `/jidoka:arranca`, lo que ejecuta es el `.md`. El `.bpmn` declara `isExecutable="false"` — es documentación, un dibujo. Nada ejecuta el BPMN.
2. **No existe generador `bpmn → md`.** Ninguna herramienta compila el diagrama en el prompt del comando, ni valida que el `.md` conforme al `.bpmn`. La fidelidad entre ambos la juzga hoy un humano a ojo (por eso existió el sprint "atlas fiel": los diagramas habían derivado y ningún gate los frenó).

Además surgió que esta lógica es compleja y **podría ser legítimamente distinta en cada lab hijo**: un proyecto model-driven (donde el diagrama es el entregable) no tiene por qué acoplarse igual que uno code-first.

## Decisión

Cuatro puntos, un solo reframe — **separar dónde se autora de qué se fuerza, y reconocer que la dirección es política, no física**:

1. **La dirección FORZADA por la ley (`tools/blast-radius.json`) se queda comando→diagrama** (reafirma ADR 0036): el `.md` es la `fuente` porque es el ejecutable; ahí es donde el drift rompe la sesión. El diagrama es el `doc_avisa` que queda atrás.
2. **Se distingue autoría de enforcement.** *Dibujar el BPMN primero* es un hábito de autoría sano y recomendado (piensas el flujo antes de escribir la prosa). *La dirección que vigila el gate* es comando-primero. No son lo mismo y no se contradicen: puedes modelar primero y aun así declarar el `.md` como fuente forzada.
3. **La dirección del acoplamiento es un knob por-lab**, declarado en `blast-radius.json`. Un lab genuinamente model-driven puede voltear su propia ley (`docs/atlas/*` como `fuente`, `.claude/commands/*` como `doc_avisa`) sin tocar el motor — la arquitectura ya lo permite, no está hard-codeado. Jidoka (la nave) es comando-primero a propósito, porque sus comandos tienen dientes y dogfoodea un método code-first.
4. **Hacer del BPMN la fuente MECÁNICA exige un mecanismo real, no una re-etiqueta:** (a) generar el `.md` desde el `.bpmn`, o (b) un validador de conformidad `md`↔`bpmn`. Sin (a) ni (b), llamar "fuente" al diagrama es confianza falsa y se rechaza.

## Por qué

- **La verdad debe vivir donde vive la conducta.** El `.md` es lo que corre; un `.md` equivocado rompe la sesión, un diagrama equivocado solo confunde. Poner la `fuente` en el artefacto con dientes es lo que hace que el aviso de drift apunte a algo que importa.
- **Sin generador, "el diagrama es la fuente" no es un muro — es una etiqueta.** El `.md` se seguiría editando directo (es el ejecutable, es lo natural en una sesión), y nada garantizaría que conforma al dibujo. Un punto de control que depende de disciplina humana no es muro: es sugerencia — exactamente lo que Jidoka existe para no fingir (`doctrina/00-tesis.md`).
- **La fidelidad es humana en AMBAS direcciones.** Ni comando-primero ni diagrama-primero regalan un generador. Reconocerlo evita la ilusión de que voltear la flecha "resuelve" el drift; no lo hace, solo mueve a quién le toca acordarse.
- **El acoplamiento es política, no física.** Que dependa del tipo de lab (model-driven vs code-first) es la señal de que pertenece a la ley editable por-repo, no al motor. Declararlo así responde "en cada lab podría ser distinta" sin fragmentar el método.

## El camino que NO se toma (y por qué tienta)

- **Re-etiquetar el `.bpmn` como `fuente` en la ley (voltear la flecha) sin generador ni validador.** Tienta porque satisface barato el instinto model-first y "se siente" más correcto para un producto cuyo entregable es el proceso. Se rechaza: el `.md` seguiría siendo el ejecutable editable, nada garantizaría la conformidad, y quedaría un muro falso que da confianza sin respaldarla. Voltear la dirección es válido **solo** acompañado de (a) o (b).
- **Acoplamiento simétrico de tres vías (proceso↔prosa↔diagrama, todos fuente de todos).** Ya descartado en ADR 0036 y sigue descartado: multiplica los avisos sin un dueño claro de la verdad, y sin generador tampoco garantiza nada.
- **Hard-codear una única dirección para todos los labs.** Tienta por simplicidad, pero niega que un lab model-driven tenga una necesidad legítima distinta; la respuesta correcta es un knob en la ley, no una imposición del motor.

## Consecuencias

- **Más fácil:** queda escrito por qué el gate vigila el comando y no el diagrama, para que una sesión futura no re-litigue "¿no debería el bpmn ser la fuente?" cada vez que retoca el atlas. El hábito diagrama-primero se recomienda sin forzarse.
- **Más difícil / deuda:** la fidelidad `.md`↔`.bpmn` sigue siendo responsabilidad humana (render + inspección a ojo); nadie la bloquea. Si algún día un lab quiere el BPMN como fuente mecánica, hereda la tarea seria de construir (a) o (b) antes de voltear su ley.
- **Aclaraciones de la ley que quedan asentadas:** `CHANGELOG.md` lo apuntan **ambas** áreas a propósito — `ritual` (al tocar el comando) y `metodo` (al tocar el diagrama) —, así que cualquier cambio de método pide su línea de historia por cualquiera de las dos puertas. La capacidad `product/capacidades/RIT-*` la apunta **solo** el comando (`ritual`), no el diagrama: retocar el retrato no cambia la capacidad.

---

> Reglas del registro: una decisión = un archivo · al agregarlo, **listalo en el [índice](README.md) en el mismo commit** (el gate lo exige) · nunca borres una decisión: márcala *reemplazada* y enlaza la nueva.
