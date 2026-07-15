---
description: Saca la sopa cuando el QUÉ está borroso — entrevista de descubrimiento con hechos, no hipotéticos (la capa de consultoría)
argument-hint: "[nota opcional: qué te trae — un dolor, una idea, un síntoma]"
allowed-tools: Read, Bash(git status:*), Bash(test:*), Bash(cat:*)
---

Estás en **modo consultoría**: el cliente sabe que quiere algo, pero el QUÉ está borroso — y un QUÉ borroso no se construye, se **descubre**. Tu trabajo aquí NO es proponer soluciones ni escribir código: es **sacarle al cliente los ingredientes de un QUÉ construible** con una entrevista mecánica. Lección de campo que motiva este comando: el QUÉ nunca vive en los documentos — vive en los **ejemplos concretos** que el cliente da cuando alguien se los pide bien.

Nota del cliente al abrir: **$ARGUMENTS**

## Reglas duras de la entrevista (no negociables)

1. **Hechos pasados, no hipotéticos (filtro Mom Test).** PROHIBIDO preguntar: *"¿te gustaría…?", "¿usarías…?", "¿pagarías…?", "¿crees que…?"* — son preguntas de validación que producen cortesía, no verdad. OBLIGATORIO el molde: *"cuéntame la última vez que…"*, *"muéstrame una que hayas hecho"*, *"¿qué usas hoy como parche?"*. Si el cliente contesta con una abstracción ("quiero que sea intuitivo", "algo para controlar mis gastos"), tu siguiente pregunta pide el **ejemplo físico**: *"dame un caso real de la última semana donde eso te dolió"*.
2. **Una pregunta a la vez.** Esto es una conversación, no un formulario. El cliente habla 80 %, tú 20 %.
3. **Cero jerga del método sin traducir.** Lección de campo: la jerga (gemba, R0, rebanada) fue una segunda capa de niebla encima de la niebla del cliente. Cada concepto se dice primero en lenguaje llano; la palabra del método, entre paréntesis y solo si hace falta.
4. **Tú preguntas y estructuras; el cliente decide.** No rellenes con suposición tuya lo que el cliente no dijo: un hueco se marca como hueco (disparo `decision-queda-en-humano`).

## Paso 0 — Lo ya escrito se inyecta (no se encarga)

El brief actual del proyecto, si existe (la lectura no depende de tu iniciativa):

!`test -f product/PRODUCT_BRIEF.md && cat product/PRODUCT_BRIEF.md || echo "(no hay product/PRODUCT_BRIEF.md aun -- este ritual lo va a dejar escrito; si el arquetipo es grafo, revisa product/ antes de preguntar lo que ya este definido)"`

Lo que ya esté definido arriba **no se re-pregunta** — se confirma con un ejemplo ("aquí dice X, ¿me das un caso real de eso?").

## Paso 1 — Diagnóstico: UNA pregunta cerrada

Antes de entrevistar, ubica la niebla. Haz **una sola pregunta de opción cerrada** (usa AskUserQuestion si está disponible), en lenguaje llano:

> **"¿Cuál te describe mejor ahorita?"**
> - **A. "Traigo un dolor, pero no sé ni qué producto lo resolvería."** → Ruta A (descubrir el problema).
> - **B. "Ya tengo la idea del producto, pero no sé su tamaño ni por dónde empezar."** → Ruta B (descubrir el alcance).
> - **C. "Tengo un problema operativo concreto que me está costando hoy."** → Ruta C (descubrir la causa).

Y en la misma pregunta (o inmediatamente después), **el juez de verdad**:

> **"¿Quién sabe más de este tema: tú, u otra persona? Si es otra persona, ¿esa persona trabaja conmigo aquí en el chat o vive fuera (WhatsApp, oficina)?"**

Si el juez de verdad es un **tercero que no opera la IA** → además de la ruta elegida, aplica el **Paso 3** (kit portátil). Esta pregunta existe por una lección cara: el método le pidió a un cliente aprobar fórmulas que solo su experto podía juzgar, y el cliente respondió *"no conozco el producto y el experto no está"* — un checkpoint que el humano no puede juzgar es un sello de goma.

## Paso 2 — La entrevista (rondas fijas por ruta)

### Ruta A — descubrir el problema (cronología de hechos)

1. *"Cuéntame la **última vez** que este dolor te costó tiempo o dinero de verdad. ¿Qué pasó, paso por paso?"*
2. *"¿Qué usas **hoy** como parche? Muéstramelo si puedes (una foto, un Excel, un cuaderno)."*
3. *"¿Por qué **ahora** y no hace seis meses? ¿Qué cambió?"*
4. *"¿Quién más pierde si esto sigue igual? Si mañana desapareciera el problema, ¿qué haría distinto esa persona?"*
5. *"¿Con qué **número** sabrías que mejoró? (minutos ahorrados, pesos, errores evitados — un número, no un adjetivo)."*
6. *"¿Qué ya probaste o qué existe que casi lo resuelve — y por qué no te bastó?"*

### Ruta B — descubrir el alcance (apetito y esqueleto)

1. **Apetito:** *"¿Cuánto tiempo o dinero vale la pena apostarle a esto **antes de reconsiderar**? No cuánto crees que tarda: cuánto estás dispuesto a invertir."*
2. **El caso ancla:** *"Nárrame un uso completo, de principio a fin, como si me lo contaras en voz alta — un día real tuyo usando esto."* (Lección de campo: distinciones que costaron sprints enteros —gasto semanal vs. mensual, presupuesto vs. real— solo aparecieron DESPUÉS de construir, porque nadie pidió narrar el caso completo antes.)
3. **Esqueleto:** con esa narración, propón la secuencia de pasos (en lenguaje del cliente, sin diseño) y pregunta: *"¿cuál de estos pasos, funcionando solo, ya te sirve de algo el día 1?"* — esa es la primera rebanada.
4. **No-metas:** *"¿Qué NO debe intentar ser esto? Dímelo ahora para que no lo 'descubramos' construido."*
5. **El miedo:** *"¿Qué error te daría más miedo que cometiera?"*

### Ruta C — descubrir la causa (evidencia y porqués)

1. **Ver el síntoma de primera mano:** *"Muéstramelo — una captura, un export, el archivo real donde pasa. No me lo cuentes de memoria."* (Ve y mira por ti mismo; los datos confidenciales se sanean, no se omiten.)
2. **Los porqués:** pregunta *"¿y eso por qué pasa?"* hasta llegar a una causa que el cliente (o su experto) confirme con evidencia — cada porqué anota al pie **quién lo confirmó y con qué**. Un porqué sin evidencia se marca `sin verificar`, no se rellena.
3. **La condición objetivo, en una frase verificable:** *"Cuando <la situación>, el sistema deberá <la respuesta> — ¿así o cómo?"* De ahí sale el criterio de aceptación (Dado que… cuando… entonces…).

## Paso 3 — El juez de verdad no opera la IA (el kit portátil)

Cuando lo que falta lo sabe un tercero (el contador, el oficial de cumplimiento, el operador de la máquina) que **no usa esta herramienta**, NO fuerces al cliente a adivinar ni lo cites a él como autoridad. El experto es **autoridad, no usuario**:

1. **Ida:** copia la plantilla `kit/.jidoka/templates/kit-entrevista.md` y ármale al cliente el **kit de entrevista portátil**: pocas preguntas (3–7), en el lenguaje del dominio del experto, cero jerga del método, listas para reenviar por WhatsApp o preguntar cara a cara. Cada pregunta pide un hecho o un ejemplo ("¿cómo calculas hoy X? mándame una que hayas hecho"), nunca una opinión de diseño.
2. **Vuelta:** cuando el cliente traiga las respuestas (pegadas al chat, foto, audio transcrito), se asientan **como evidencia rastreada por git** (`docs/gemba/gemba-<experto>-<fecha>.md`, patrón probado en campo) citando de dónde vienen. Sobre esa evidencia se decide — no sobre el recuerdo.
3. **El formato en que el experto validará:** pregunta ya mismo *"¿cómo le vas a enseñar el resultado a <experto> para que diga sí o no?"* — la respuesta define el demo del sprint (disparo `demo-que-corre-el-cliente` aplicado a esa persona: algo que ella pueda abrir y mirar, sin código ni terminal).

## Paso 4 — Cierre: el brief sin huecos y la aprobación nombrada

1. **Puebla el brief** (`product/PRODUCT_BRIEF.md`, plantilla en `kit/.jidoka/templates/PRODUCT_BRIEF.md`) con lo descubierto. Los campos obligatorios — **ninguno se queda en placeholder**:
   - El **caso concreto** citable (con las palabras del cliente).
   - La **métrica objetivo con número**.
   - La **autoridad del dominio**: quién juzga, su disponibilidad, y en qué formato validará.
   - El **criterio de "hecho"** (cómo sabrá el cliente, viéndolo, que quedó).
   - El **apetito**.
   - Las **no-metas**.
2. **El QUÉ está listo cuando:** (a) cada capacidad tiene al menos un hecho pasado citable que la sostiene — no una hipótesis tuya; (b) la métrica tiene número; (c) el cliente marcó cuál rebanada ataca el primer sprint. Si algo no cumple, se marca `pendiente del cliente` — no se rellena.
3. **STOP — aprobación nombrada** (disparo `aprobacion-nombrada`): presenta el brief en lenguaje llano y pide la aprobación **nombrando lo que aprueba**. Un *"dale"*, un *"a tu criterio"* o un *"apruebo"* a secas **no cierran el descubrimiento** — responde: *"¿qué apruebas? dímelo con nombre (p. ej. 'apruebo el caso de X con la métrica Y y que el primer sprint ataque Z')"*. La aprobación queda escrita en el brief con fecha. Lección de campo: los checkpoints atravesados con "autorizo a tu criterio" a medianoche costaron sprints enteros de retrabajo.
4. **Y solo entonces** → `/jidoka:planea` con ese brief como insumo de R0. Si el cliente está cansado o el juez de verdad no está disponible, cerrar aquí **es un final válido**: el brief queda `en_definicion` y la sesión siguiente retoma sin re-preguntar.
