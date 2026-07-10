<h1 align="center">Jidoka</h1>

<p align="center"><strong>El Sistema de Producción Toyota para tu equipo de agentes de IA.</strong><br>
Con un cordón <em>Andon</em> que sí para la línea.</p>

<p align="center"><code>npx jidoka init</code></p>

<p align="center">🧪 <strong>beta</strong> — el método está probado en repos reales; el empaquetado se está estrenando.<br>
<a href="LICENSE">MIT</a> · úsalo, cópialo, modifícalo, hasta comercialmente. Sin ataduras.</p>

---

## Por qué

Programar con agentes de IA falla por dos lados: **pierden el contexto** entre sesiones, y **cooperan con su propia mentira** — te dicen "listo, todo pasa" cuando no. Lo primero se atiende con planificación y documentos como fuente de verdad. Lo segundo casi nadie lo toca de raíz, porque exige algo incómodo: **dejar de confiar en la palabra del agente** — un actor que no recuerda y no tiene nada que perder.

**Jidoka parte de una ley:**

> Un mecanismo de gobierno es **muro real si y solo si el punto de control vive FUERA del LLM.**
> Si depende de que el modelo coopere, no es muro.

Esa ley no es nueva: es la ingeniería de calidad del siglo XX —poka-yoke, jidoka, Deming, el queso suizo de Reason, los checklists de la aviación, maker-checker, CI— reaplicada a un actor falible nuevo: el agente de IA. El detalle, con fuentes verificadas, en [`doctrina/`](doctrina/).

Y sobre esa ley, la tesis que hace a Jidoka **suyo** — los dos pájaros:

1. **La disciplina cae sobre los robots.** Toda la rigidez (gates, evidencia, required checks) recae en la máquina, que no tiene dignidad que reclamar.
2. **El juicio se queda en ti.** El humano se libera de *memoria y procedimiento*, pero se preserva —y se protege— como portador de *juicio*. Tú no revisas el PR. Tú revisas el **demo funcionando**, con tus propios ojos.

## El sistema (por qué se llama Jidoka)

No es solo un nombre pegajoso. Cada pieza es un pilar real del Sistema de Producción Toyota:

| Pieza | Concepto Toyota | Qué es aquí |
|---|---|---|
| **Jidoka** | Autonomación: la máquina se detiene sola ante el defecto; el humano aporta juicio | El método completo |
| **Andon** | El cordón que cualquiera jala para parar la línea | Los **gates deterministas** (hooks + CI + branch protection) |
| **Kanban** | El flujo tirado por tarjetas | El **ritual de sprint** (plan → demo → retro) |
| **Kaizen** | Mejora continua | La **retro** de cada sprint — lo aprendido, versionado |
| **Gemba** | *"El lugar real"*: ve a verlo con tus ojos | El **demo visual** que el cliente corre solo |
| **Poka-yoke** | A prueba de errores | La **doctrina** que lo funda ([`doctrina/`](doctrina/)) |

## De dónde viene esto: la aviación aprendió esto con muertos

Antes que el software, **un campo ya vivió el dilema de la automatización peligrosa a escala — y lo pagó con vidas.** La aviación enfrentó exactamente lo nuestro: una máquina muy capaz que desplaza al humano, pero el humano tiene que seguir siendo el árbitro final. No lo "resolvió"; lo convirtió en **riesgo gestionado**. De ahí sale, casi entera, la mecánica de Jidoka:

- **AF447 (2009)** — el autopiloto se desconectó y los pilotos, que nunca habían volado a mano en esa situación, no reconocieron una pérdida hasta caer al mar. → *La primera vez que operas a mano no puede ser la emergencia.* Por eso Jidoka insiste en el juicio humano **activo**, no en un botón de "aprobar" dormido.
- **"Children of the Magenta"** — cuando la cosa se complica, **baja el nivel de automatización**, no pelees dentro del modo automático. → el gate `click-it-down`.
- **Airbus vs Boeing** — Airbus pone límites **duros** (no puedes cruzarlos) = `deny`; Boeing **avisa y te deja anular** = `ask`. → así se decide cada gate de Jidoka: `deny` para lo irreversible, `ask` para lo que pide juicio.
- **Bainbridge, "La ironía de la automatización" (1983)** — *mientras mejor es la máquina, MÁS hay que invertir en mantener vivo el juicio del humano.* → el segundo pájaro, entero.

Todo verificado contra fuente primaria en [`doctrina/03-aviacion.md`](doctrina/03-aviacion.md). **Ningún framework de IA trae esto** — es lo que vuelve a Jidoka un método de seguridad, no solo de productividad.

## Cómo se trabaja: el ritual Kanban

Un sprint de Jidoka es un lazo corto de cuatro tiempos. La tarjeta pasa por **Borrador → Aprobado → En curso → Revisión → Hecho**:

1. **Planea** (`/jidoka:planea`) — la IA explora y escribe el plan en *plan mode*; **tú lo apruebas**. El plan aprobado *es* el sprint, y se archiva.
2. **Construye** — el agente `dev` avanza en rebanadas verticales, cada paso verde. El **Andon local avisa**; el **CI bloquea**.
3. **Revisa en dos capas** — los **robots** revisan el código (`/code-review` + gates de CI); **tú** revisas el **Gemba**: el incremento visual, corriendo, que verificas contra lo que pediste.
   > **Regla de oro:** el cliente revisa el *demo*, nunca el PR.
4. **Cierra** (`/jidoka:cierra`) — **Kaizen**: la retro al récord del sprint; el estado al HANDOFF. La lección viaja al siguiente sprint; el contexto no.

Detalle del ritual en [`kanban/`](kanban/); la doctrina de gates en [`andon/`](andon/).

## Lo que lo hace distinto

- **El gate vive fuera del LLM.** No le pedimos al agente que se porte bien: CI + branch protection bloquean de verdad. Un veredicto que el propio modelo escribe no es un muro — es una sugerencia.
- **Revisas el demo, no el código.** El incremento te llega funcionando y visual. *"Hecho" = lo viste con tus ojos.* Pensado para quien dirige sin leer código.
- **Un plan ligero es el sprint.** El plan que apruebas en *plan mode* es el contrato. Sin ceremonia de más.
- **Cinco roles acotados**, cada uno con una sola responsabilidad — no un enjambre que se pisa.
- **Fundado en seguridad, no solo en productividad.** El linaje de manufactura y aviación (arriba) es el porqué, no un adorno.

## Empezar

```bash
# En un repo nuevo o existente
npx jidoka init
```

El instalador pregunta el **arquetipo** de tu repo (code-first · docs-as-code · doc-only) y enciende solo la maquinaria que ese proyecto merece. **La disciplina escala con el riesgo:** un experimento personal no necesita la ceremonia de un sistema regulado. Es un menú, no un molde.

¿Primera vez? La guía [`docs/guias/empezar-de-cero.md`](docs/guias/empezar-de-cero.md) no asume nada.

## Licencia

[MIT](LICENSE). © 2026 Armando Medina y colaboradores de Jidoka. Úsalo, estúdialo, modifícalo y compártelo — incluso comercialmente — sin ataduras. Si te sirve, un ⭐ y avisa qué construiste.

---

<p align="center"><em>No puedes hacer infalible al modelo. Puedes cambiar las condiciones —los gates— bajo las que opera.</em></p>
