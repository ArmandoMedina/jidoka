# ADR 0030 — El listón de evidencia (el `LOG.md` de la corrida) y el demo que corre el cliente

- **Estado:** aceptado
- **Fecha:** 2026-07-14

## Contexto

Los gates de evidencia (`gemba-stop` para lo visual, `validador-stop` para la medición) exigían "evidencia fresca y rastreada por git bajo `qa_runs/`". Pero aceptaban **cualquier** archivo: un `veredicto.txt` con la línea *"PASA — se ve bien"*, forzado al índice con `git add -f`, satisfacía el gate igual que un `LOG.md` con método reproducible, tabla de casos y capturas. En campo se vio la degradación: el mismo día, un `LOG.md` rico por la mañana (arco FALLA→causa raíz→PASA, tablas de casos) y un `veredicto.txt` pelón por la tarde — ambos pasaban el gate. Es Goodhart: cuando la medida es "existe un archivo en `qa_runs/`", el archivo se vacía hasta el mínimo que pasa.

En paralelo, el otro extremo del mismo hueco: los sprints cerraban su "Verificación" con demos que **solo el agente podía correr** (un script de PowerShell, un comando de terminal). El cliente —un stakeholder de negocio— no podía tocar el incremento. Una "demo" que solo el que la construyó puede correr no es aceptación: es el agente validándose a sí mismo.

## Decisión

Dos listones, ambos deterministas donde se puede y de proceso donde no:

1. **El listón de evidencia: el `LOG.md` de la corrida.** `gemba-stop` y `validador-stop` ya no cuentan cualquier archivo — solo `qa_runs/<corrida>/LOG.md` (para validación, `qa_runs/validador-*/LOG.md`). El gate mide **presencia + frescura (mtime) + tracking (git)** del `LOG`; su **contenido** lo juzga el humano en el Gemba. Se siembra la plantilla `kit/.jidoka/templates/qa-log.md` (corrida, fecha, rama, asiento, método reproducible, tabla de casos, artefactos, y el recordatorio de que el veredicto viaja a HANDOFF/CHANGELOG citando la corrida).
2. **El demo que corre el cliente, sin código ni terminal.** El disparo nuevo `demo-que-corre-el-cliente` (cableado en `planea.md`): la Verificación de una rebanada debe poder demostrarse sin código ni terminal (abrir una URL, hacer clic, mirar un reporte). Si no se puede, la rebanada **no es vertical** — se re-rebana o se marca como decisión pendiente. Cableado en las plantillas `sprint-plan`/`sprint-entrega`, en `planea` y en el cierre de `cierra`.

Ambos gates se prueban de vida en ROJO→VERDE (`probar-hooks.ps1`: un `veredicto.txt` rastreado y fresco que no es `LOG.md` debe bloquear — falla contra los hooks viejos, pasa contra los nuevos). El catálogo de disparos sube a 13.

## Por qué

- **El listón cierra el Goodhart sin volverse un juez de contenido.** Exigir el `LOG.md` por nombre sube el piso (un `veredicto.txt` ya no cuela) sin que el gate pretenda leer si el contenido es bueno — eso lo hace el humano. Presencia + frescura + tracking es lo que una máquina puede medir con honestidad; el resto es checkpoint humano.
- **"Sin código ni terminal" es el criterio operativo de rebanada vertical.** La verticalidad se predicaba pero no se medía. Atarla a "¿el cliente puede correrlo con sus propios ojos?" la vuelve una prueba concreta, no una aspiración — y caza las rebanadas que quedaron a medias (un motor sin la interfaz que lo hace tocable).

## El camino que NO se toma (y por qué tienta)

**Parsear el contenido del `LOG.md`** — hacer que el gate verifique que el LOG tiene tabla de casos, método reproducible, ≥N filas, etc. Tienta porque atraparía un `LOG.md` que solo cambió de nombre pero sigue pelón. Se descarta: un gate que juzga contenido con reglas frágiles (regex sobre prosa) genera falsos positivos, invita a maquillar el texto para pasar, y usurpa el juicio que es del humano en el Gemba. El gate mide lo que una máquina mide sin ambigüedad (existe, es fresco, está en git); la calidad del contenido es del checkpoint humano — por diseño, no por límite técnico.

## Consecuencias

- **Más fácil:** la evidencia no se puede degradar a un archivo pelón; una rebanada no-vertical se caza en el plan, no en la entrega.
- **Más difícil / deuda:** las corridas viejas con evidencia que no se llama `LOG.md` dejan de contar para trabajo nuevo (retrocompatible: la frescura ya las hacía inertes para cambios nuevos). En Jidoka ambos gates nacen dormidos, así que el auto-impacto es cero; el listón se estrena en los hijos que declaran áreas visuales o de datos.
