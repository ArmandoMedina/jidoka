# ADR 0029 — La conciencia se instala: el `arranca` sienta y rutea (router determinista + casting sembrado + dormancia visible)

- **Estado:** aceptado
- **Fecha:** 2026-07-14

## Contexto

Una instalación fresca de Jidoka entrega la capa **máquina** (hooks, CI, gates, la ley) y funciona: el `blast-radius.json` juzga, los Stop hooks frenan. Pero la capa de **conciencia** —quién se sienta en qué asiento, qué cambio se rutea a qué rol, qué Stop hooks están vivos o dormidos según la ley— viajaba como prosa en `kanban/roles.md` y en el `arranca`, y **nada obligaba a usarla**. El `arranca` canónico leía el estado (HANDOFF, git, recursos) pero no sentaba a la sesión ni le decía el ruteo (lección #53).

El costo se vio en campo. En un lab donde el `arranca` sí orientaba pero no routeaba, la calidad de la evidencia se degradó dentro del mismo día (un `LOG.md` rico en la mañana, un `veredicto.txt` pelón en la tarde) porque nada forzaba el asiento correcto. En otro lab la brecha la tapaba el usuario **a mano**, con un párrafo de apertura escrito cada sesión ("Arrancas como Mau (orquestador)… lee `CONTRIBUTING §8`… síguelo, no me lo resumas"). Ese párrafo *era* la conciencia — hecha por iniciativa humana, no por la máquina. Y una lección hermana (#51): un Stop hook **dormido** sale limpio y en silencio; nadie sabía que la ley no lo encendía, así que la dormancia era invisible.

El principio que gobierna la cosecha: **nada puede depender de la iniciativa del agente**. Si la conciencia depende de que el agente (o el usuario) recuerde sentarse y routear, no está instalada.

## Decisión

La conciencia se vuelve **maquinaria determinista**, sembrada como motor:

1. **`tools/rutear.ps1` (nuevo, mecánica).** Fuente única de la lógica router + vivo/dormido. Lee la ley y reporta, por área, qué asiento la ocupa y qué gate la vigila; y por Stop hook, si está **VIVO o DORMIDO** con la **razón** de cada dormido (misma lógica que cada hook filtra de la ley: `revisa:true`→review-stop, `rol:revisor-visual`→gemba-stop, `rol:validador`→validador-stop, doc dueños→andon-stop). **Falla cerrado** (exit 1) sin ley legible. `-Gates` emite solo la sección de gates.
2. **`/jidoka:arranca` sienta y rutea.** Una sección nueva ("Siéntate y rutea") hace que la sesión **adopte el casting** de `recursos-del-proyecto.md` y **anuncie su asiento por nombre**, y **lea el router** (bloque inline `!` a `rutear.ps1`, sin `-ExecutionPolicy Bypass` — postura AV del ADR 0027). Regla dura: *"adopta, no resumas"*.
3. **El casting se siembra.** El template `recursos-del-proyecto.md` gana la sección **## El casting** (asiento→nombre→cuándo), para que el arranca tenga qué adoptar desde el día cero.
4. **La dormancia se hace visible.** `estado-motor.ps1` imprime la sección Gates (vía `rutear -Gates`) **siempre**, antes del sello — un gate dormido ya no es invisible.

Cuatro casos de prueba de vida nuevos en `probar-hooks.ps1` (rutear dormido/vivo, falla cerrado, estado-motor imprime Gates). Cierra #53.

## Por qué

- **La conciencia instalada no depende de iniciativa.** Antes vivía en un párrafo que el humano escribía cada sesión, o no existía. Ahora la siembra el motor: el `arranca` la ejecuta, `rutear` la calcula desde la ley, el casting llega en el template. Instalar = funcionar también para la capa de conciencia, no solo para los gates.
- **Una sola fuente de la lógica vivo/dormido.** `rutear.ps1` la centraliza (la leen arranca y estado-motor); los hooks siguen filtrando la ley por su cuenta, pero el reporte al humano sale de un solo lugar — no hay dos verdades que puedan divergir.
- **La dormancia invisible era el hueco de #51.** Un gate que nunca se enciende porque la ley no lo declara se veía idéntico a uno sano. Verlo listado como DORMIDO con su razón lo vuelve una decisión consciente, no un olvido.

## El camino que NO se toma (y por qué tienta)

**Portar el párrafo de apertura del lab como un `docote` fijo dentro del `arranca`** — copiar el texto que el usuario escribía a mano ("arrancas como Mau… síguelo, no me lo resumas") y hornearlo en el comando. Tienta porque ese párrafo *funcionaba*. Se descarta porque es **instancia disfrazada de método**: nombra personas y docs de un repo concreto, y volvería a depender de que el texto siga vigente. La conciencia correcta se **deriva de la ley** (rutear) y del casting **del repo** (recursos-del-proyecto.md), no de un guion fijo. El método siembra el mecanismo; el nombre es sabor de instancia (ADR 0023).

## Consecuencias

- **Más fácil:** una sesión fresca sabe, sin que nadie se lo diga, en qué asiento va y qué gate la vigila; la dormancia de un gate es legible en `estado-motor`.
- **Más difícil / deuda:** los hijos con un `arranca` personalizado (p.ej. un lab con su propio ritual de apertura) reciben la sección del router como `.jidoka-nuevo` al actualizar — la bajada debe decir explícitamente "mergea la sección del router a tu arranca". El `LOG.md` como listón de evidencia y el demo que corre el cliente son la otra mitad de esta cosecha, en el ADR 0030.
