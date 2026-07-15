# Kit de entrevista — <experto> · <tema> · <AAAA-MM-DD>

> **Para cuando el que sabe no opera la IA.** El experto del dominio (el contador, el oficial de cumplimiento, el operador) es **autoridad, no usuario**: no se le pide usar la herramienta — se le llevan estas preguntas por WhatsApp o cara a cara, y sus respuestas regresan como evidencia. Lo genera `/jidoka:descubre` (Paso 3); lo lleva el cliente.

## Reglas de armado (para quien genera el kit)

- **3 a 7 preguntas.** Más es un examen, no una conversación.
- **En el lenguaje del dominio del experto.** Cero jerga del método, cero jerga técnica que el experto no use.
- **Cada pregunta pide un hecho o un ejemplo**, nunca una opinión de diseño: *"¿cómo calculas hoy X? mándame una que hayas hecho"* — no *"¿cómo te gustaría que funcionara?"*.
- **Formato mensajeable:** el bloque de abajo debe poder copiarse y reenviarse tal cual.

---

## El mensaje (copiar y reenviar tal cual)

> Hola <experto>, ando documentando <tema en sus palabras> y tú eres quien lo domina. ¿Me ayudas con estas preguntas? Con ejemplos reales me sirve más que con la teoría:
>
> 1. <Pregunta 1 — pide el proceso real de hoy: "¿cómo haces hoy…?">
> 2. <Pregunta 2 — pide un ejemplo hecho: "¿me mandas una foto/archivo de la última que hiciste?">
> 3. <Pregunta 3 — pide el caso raro: "¿cuándo fue la última vez que esto salió distinto de lo normal, y qué hiciste?">
> 4. <Pregunta 4 — pide el límite: "¿qué es lo que NUNCA debe pasar aquí?">
>
> Si algo aplica "depende", dime de qué depende con un ejemplo. ¡Gracias!

---

## La vuelta (cuando lleguen las respuestas)

1. Las respuestas se pegan **tal cual** (texto, foto transcrita, audio transcrito) en `docs/gemba/gemba-<experto>-<AAAA-MM-DD>.md`, citando fecha y canal ("WhatsApp, 14-jul"). **Se commitean**: son la evidencia de dominio sobre la que se decide — no el recuerdo de nadie.
2. Lo que el experto NO respondió queda como `pendiente del cliente`, no se rellena con suposición.
3. **El formato de validación del experto** (definido al armar el kit): cuando el incremento exista, a <experto> se le enseña <formato: una página que abre, un reporte que mira — sin código ni terminal> y su sí/no cierra la verificación de negocio.
