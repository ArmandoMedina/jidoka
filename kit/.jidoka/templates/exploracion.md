# Exploración — `<pregunta en pocas palabras>` (AAAA-MM-DD)

> **Madurez de este molde: n=1.** Nació de la primera exploración real corrida con la kata
> (`doctrina/08-kata-de-mejora.md`) el 2026-07-23; sus secciones existen porque **faltaron ahí**,
> no porque se diseñaran en abstracto. **No está gobernada por `tools/docs-gobernados.json`**
> —como tampoco lo están `adr.md` ni `plan-de-trabajo.md`—: hacerla muro con un solo uso sería
> método-ficción. Tras 2–3 exploraciones reales, se registra en el ledger o se rehace. **Ojo: no
> estar gobernada no es no distribuirse** — este folder se siembra completo a todo repo que
> instale el método, así que el molde llega aunque nadie lo haya pedido.
>
> **Tensión declarada, sin resolver:** la doctrina pide que la exploración entregue *media
> cuartilla* (`doctrina/08-kata-de-mejora.md`), y `docs/analisis/` guarda *informes durables* con
> evidencia `archivo:línea`. Los dos no caben en el mismo documento. Mientras no se decida, escribe
> lo corto que puedas sin perder la evidencia — y si te sale largo, di por qué.
>
> **Dónde vive el informe que salga de aquí:** `docs/analisis/exploracion-<tema>-AAAAMM.md`, con
> su fila en el índice del folder (la carpeta **no se siembra**: créala en su primer uso). En el
> ROADMAP queda **la tarjeta y el puntero**, nunca el detalle: el detalle no cabe (techo de
> líneas) y ahí no lo lee nadie.

## La pregunta

> Una sola, escrita antes de empezar. Si son dos, son dos exploraciones. La pregunta es el kanban.

**Timebox declarado:** `<una tarde / un día>` · **Corte:** `<fecha · versión>`

## Método

> Cómo se midió, con el detalle suficiente para que otro lo repita sin preguntarte nada. Si algo
> se corrió sobre copias, dilo — y di que se borraron.

## Condición actual (medida)

> Hechos observados, con `archivo:línea`. Nada de recuerdos ni de «según creo». Si no lo mediste,
> no va aquí: va en «Lo NO medido».

## Resultado — rojo → verde

> El defecto corriendo y la cura corriendo. Todo comando re-ejecutable: nada de lo afirmado debe
> depender de la palabra del agente.

## Rojo honesto (medido, sin cura)

> Lo que se reprodujo pero no se curó, o cuya **intención** no está determinada. Es un resultado
> admisible, no un fracaso. Di explícitamente qué falta para clasificarlo y **quién** clasifica.

## Lo NO medido

> **Regla dura: lo que no se midió no se afirma, y no entra a un plan.** Enumera los huecos por
> nombre. Un plan construido sobre esta lista es un plan sobre supuestos. Este es el umbral que
> el repo usa para decidir qué se puede prometer.

## Qué debe revisar el dueño (guion)

> **Esta es la sección que más se usa y la que más fácil se degrada.** Reglas, no sugerencias:
>
> 1. **Máximo 7 pasos**, cada uno con su tiempo declarado. El total debe caber en el `apetito` de
>    la tarjeta — el apetito son **horas de revisión del dueño**, no de trabajo del agente.
> 2. **Formato fijo por paso: «Haz esto» / «Debe pasar» / «Recházalo si».** Los tres, siempre. Un
>    paso sin criterio de rechazo no es revisión: es visita guiada.
> 3. **Al menos un paso tiene que provocar un fallo a propósito.** Un guion que solo dice *mira* no
>    prueba nada. Caso real del método: una variante que se veía impecable —raíz limpia, una sola
>    carpeta— tenía el muro muerto y el gate reportaba «Todo limpio». **Ver bonito no es señal de
>    vida; la única prueba de que el gate vive es verlo morder.**
> 4. **Sin terminal ni código si se puede evitar.** Si hace falta un comando, va escrito completo
>    para copiar y pegar, no descrito.
> 5. **Lo escribe quien exploró; lo corre quien acepta.** Nadie declara cumplido un paso que no
>    corrió — el sistema puede obligar a que tu aceptación exista, no a que hayas mirado.
> 6. Si la revisión resulta ser **una decisión y no una inspección**, dilo en el encabezado del
>    guion y ofrece las salidas legítimas. No disfraces una decisión de checklist.

### `<Tema 1>` — `<N min>`

1. **Haz esto:** `<acción concreta>`. **Debe pasar:** `<resultado observable>`. **Recházalo si**
   `<síntoma que invalida>`.

## Qué se descarta (y por qué)

> Los caminos que mueren aquí, con su razón. Quemar a los perdedores es el plan, no un desperdicio
> — pero se escribe, o alguien los vuelve a proponer en tres semanas.

## Qué mata este informe si se adopta

> **Obligatorio, y por una lección pagada en campo:** cuando un pivote no marca qué mata, el
> artefacto viejo sigue declarándose vigente y el siguiente agente lo obedece — y reconstruye
> trabajo que ya estaba descartado. Nombra los ADRs que quedarían superseded, las tarjetas del
> ROADMAP que vuelve falsas y los docs que dejan de decir la verdad.

## Qué gradúa

> Lo que cruza a la línea: **tarjetas con QUÉ claro, y conocimiento al brief o a los criterios de
> aceptación. Nunca código, nunca prosa voluminosa.** Si nada maduró, escribe «nada» — es un
> resultado normal de una vuelta de la kata.
