# 08 — La kata de mejora: cómo se explora

La línea de producción es para producir lo que ya se sabe; la exploración es para producir el saber.
Correr reglas de línea (gates, Gemba, aceptación) sobre trabajo de aprendizaje genera la peor forma
de sobreproducción: inventario que nadie pidió y que nadie puede juzgar todavía. Toyota resuelve esto
con una asimetría deliberada: **estandariza las preguntas, nunca el camino**. El explorador va a donde
quiera y tira lo que quiera — pero al moverse responde siempre el mismo cuestionario corto.

La frontera que este capítulo carga, en una línea:

> **La línea nunca recibe un QUÉ borroso; la exploración nunca entrega producto final.**
> El único peaje entre los dos mundos es la graduación: el hallazgo que madura entra a la línea
> como tarjeta con QUÉ claro — nunca como código, nunca como prosa voluminosa.

## Procedencia (honesta)

- **"Kata de mejora" y "kata de coaching"** son la codificación de **Mike Rother** (*Toyota Kata*,
  McGraw-Hill, 2010), tras investigación de campo en Toyota y plantas comparadas. Toyota **no usa el
  término internamente** — es el modelo de un observador externo sobre cómo Toyota gestiona y enseña
  la mejora. Se cita como lo que es: síntesis ajena de práctica real, no documento interno de Toyota.
- Las raíces que sí son de la casa Toyota: **PDCA** (el ciclo de experimento de Deming), **genchi
  genbutsu** (ir a ver por ti mismo), el **A3** (el hallazgo cabe en una hoja) y el **set-based
  concurrent engineering** del desarrollo de producto (explorar varias opciones baratas en paralelo;
  quemar a los perdedores es el plan, no un desperdicio).
- Estado de citas: pendientes de verificación adversarial contra fuente primaria — al ledger
  [`citas-verificadas.md`](citas-verificadas.md) cuando se verifiquen (regla de la casa: ante
  discrepancia, manda el ledger).

## Las cinco preguntas

Las cinco preguntas de la kata de coaching — el cuestionario que el mentor de Toyota (según Rother)
hace al aprendiz en cada vuelta. Son la **página de hallazgos vista desde antes**, en lugar de desde
después:

1. **¿Cuál es la condición objetivo?** No "el plan": cómo se ve el mundo cuando esto esté resuelto.
   Sin objetivo escrito, la exploración es vagar.
2. **¿Cuál es la condición actual?** Hechos observados — genchi genbutsu — no opiniones ni recuerdos.
3. **¿Qué obstáculos te separan del objetivo, y cuál atacas AHORA?** Uno, no la lista entera. El
   obstáculo elegido es el kanban de la exploración: una pregunta a la vez.
4. **¿Cuál es tu siguiente paso (experimento) y qué esperas que pase?** La hipótesis se escribe
   *antes* de moverse — es lo que separa el experimento del manotazo. Esto es el Plan-Do de PDCA.
5. **¿Cuándo vemos qué aprendiste?** El timebox y la cita para revisar. Esto es el Check-Act: sin
   fecha de revisión, el aprendizaje se evapora y el prototipo se momifica en inventario.

## La receta de exploración (la forma ejecutable mínima)

Cinco reglas — y nótese que ninguna es "instalar" ni "configurar":

1. **Una pregunta escrita, una sola.** La pregunta es el kanban.
2. **Timebox declarado antes de empezar.** Una tarde, un día. Cuando suena, se acabó — lo que no se
   aprendió cabe en otra pregunta, otra tarjeta.
3. **El medio más barato que pueda responder la pregunta.** Papel, un HTML a mano, un script
   desechable, una maqueta, una conversación. Alta fidelidad solo si la pregunta la exige.
4. **Todo nace muerto.** El prototipo no se cuida, no se testea, no se documenta, no pasa por gates.
   Se le exprime la respuesta y se tira; nadie lo va a mantener.
5. **El único entregable es la página de hallazgos.** Media cuartilla al cerrar — un A3 en
   miniatura: la pregunta, qué aprendí, qué decido, qué descarto, y qué gradúa (si algo) como
   tarjetas hacia la línea. Este papel es **el producto real**: el desarrollo de producto de Toyota
   mide su output en conocimiento, no en piezas.

## Qué NO es este capítulo

- **No es un proceso a instrumentar antes de usarse.** La herramienta de exploración (el arquetipo,
  su tablero, su carpeta) se construye cuando varias exploraciones reales hechas a mano hayan
  enseñado qué debe hacer — regla 2-3: consumidores reales primero. Las primeras exploraciones SON
  la spec.
- **No es una licencia para que la línea acepte borroso.** La kata no reemplaza el QUÉ aprobado de
  la línea; lo *produce*. La definición es el output de explorar, no el prerequisito.
- **No es Gemba ni gate.** La exploración no le debe evidencia formal al sistema — solo su página de
  hallazgos. Exigirle ceremonia de producción es re-crear la sobreproducción que este capítulo cura.
