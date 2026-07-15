# ADR 0031 — La capa de descubrimiento: `/jidoka:descubre` (la consultoría se instala)

- **Estado:** aceptado
- **Fecha:** 2026-07-14

## Contexto

El método funciona cuando el cliente trae el QUÉ claro y patina cuando no. Tres diagnósticos sobre los chats reales de tres despliegues lo midieron: en el caso de éxito, el cliente aporta en cada mensaje un **caso concreto con coordenada verificable** ("en el metro 4463 salen los 3 bips y no hay frenada"), la regla de dominio justo después del ejemplo, y un criterio de "hecho" explícito. En los dos casos fallidos, esos ingredientes no estaban — y nadie los pidió: en uno, el cliente confesó literal *"no conozco el producto y el experto no está"* mientras el método le pedía aprobar fórmulas que solo su experto podía juzgar; en el otro, el brief describía features ("5 tarjetas de crédito") y el modelo mental real solo emergió con una anécdota (la llanta ponchada) a medianoche, con código ya construido — y los STOPs se atravesaron con *"autorizo a tu criterio"*.

Tres lecciones: (1) **el QUÉ vive en ejemplos concretos, no en documentos** — el aparato metodológico era idéntico en los tres repos; (2) **STOP no es comprensión** — un checkpoint que el humano no puede juzgar (por dominio, vocabulario o cansancio) es un sello de goma; (3) a veces la autoridad del dominio es **un tercero que no opera la IA**. Hoy `planea.md` detecta la niebla ("el QUÉ ambiguo es un hallazgo, no un permiso para inventar") pero solo la marca — no la disuelve. La investigación de metodologías (Mom Test, JTBD/switch, Shape Up, Impact Mapping, A3/5-porqués/genchi-genbutsu, EARS; literatura LLM 2025 sobre elicitación) confirmó que el valor de un agente entrevistador está en **aplicar el checklist sin fatiga**, no en la genialidad conversacional — exactamente la tesis del método.

## Decisión

La capa de consultoría se instala como mecánica, no como prosa (mismo principio que ADR 0029):

1. **El comando `/jidoka:descubre`.** Diagnóstico de UNA pregunta cerrada (3 nieblas: no sé ni el problema / sé la idea pero no el alcance / sé el síntoma operativo — más ¿quién es el juez de verdad?) y rondas de preguntas fijas por ruta: cronología de hechos (switch/JTBD) para la niebla total; apetito + caso ancla narrado + esqueleto (Shape Up) para la niebla de alcance; evidencia de primera mano + porqués con confirmación (A3/genchi genbutsu) para el síntoma. **Filtro Mom Test como lista negra escrita** en el comando: prohibido "¿te gustaría/usarías/pagarías…?", obligatorio "cuéntame la última vez que… / muéstrame una que hayas hecho". Cero jerga del método sin traducir.
2. **El brief gana los campos que el descubrimiento llena** (`PRODUCT_BRIEF.md`): caso concreto citable · métrica con número · autoridad del dominio (quién juzga, disponibilidad, formato de validación) · criterio de "hecho" · apetito · no-metas · aprobación del QUÉ. La lectura se **inyecta** (el comando @-incluye el brief al abrir), no se encarga.
3. **La autoridad tercera** (plantilla `kit-entrevista.md`): cuando el juez de verdad no opera la IA, el ritual arma un kit portátil (3–7 preguntas en el lenguaje del experto, formato mensajeable) y las respuestas regresan como evidencia rastreada (`docs/gemba/gemba-<experto>-<fecha>.md`). El experto es autoridad, no usuario.
4. **El disparo 14.º `aprobacion-nombrada`** (cableado en `descubre.md`, nombrado también en `planea.md`): lo que se aprueba se nombra — "dale"/"a tu criterio" no cierran un QUÉ.
5. **El ruteo mecánico:** `planea.md` R0 cambia de "la ambigüedad se marca como pendiente" a "→ corre `/jidoka:descubre` primero".

## Por qué

- **La entrevista provoca el ejemplo; el ejemplo trae la regla.** En el caso de éxito la regla de negocio aparece siempre *después* del caso concreto, nunca antes. Pedir features produce briefs huecos; pedir "la última vez que te costó" produce el QUÉ real.
- **Preguntas fijas > iniciativa del agente.** Las preguntas que faltaron en los fracasos (¿quién es el juez de verdad?, ¿en qué formato validará?, ¿cómo sabrás viéndolo que quedó?) no se dejaron de hacer por incompetencia — se dejaron de hacer porque nada las forzaba. Se escriben en el comando.
- **La aprobación nombrada sube el piso del checkpoint sin usurpar la decisión.** El cliente sigue decidiendo todo; solo se le pide decir *qué* decide. Es la misma lógica de la "orden nombrada" que ya rige los merges.

## El camino que NO se toma (y por qué tienta)

**El gate determinista anti-placeholders sobre el brief** (un Stop hook que bloquee si el brief tiene `<...>` o falta la línea de aprobación). Tienta porque sería el muro real — la mecánica pura. Se difiere por regla 2-3: el ritual debe probar valor en un caso de campo antes de ganarse un gate (un gate sobre un ritual que nadie corre es método-ficción). Queda registrado como issue para cuando el uso real lo pida. También se descarta **portar un flujo de discovery completo** (Design Sprint, Continuous Discovery con cadencia semanal): son rituales de equipo con usuarios externos; el molde aquí es un cliente + un agente, y el fix es lean (mismo criterio que el ADR 0029 aplicó al arranca).

## Consecuencias

- **Más fácil:** el proyecto con QUÉ borroso tiene una ruta mecánica en vez de un "pendiente del cliente" que nadie destraba; el experto sin IA entra al lazo como evidencia, no como recuerdo; los briefs nacen con métrica, apetito y no-metas.
- **Más difícil / deuda:** el catálogo de disparos y el brief crecen (más superficie que mantener); la eficacia real del ritual solo se sabrá con el demo de campo (correrlo en un proyecto con niebla real) — ese es el criterio de cierre del sprint, no la suite verde.
