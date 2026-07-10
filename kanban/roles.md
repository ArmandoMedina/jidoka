# Los asientos — roles acotados, no enjambre

> Una sola sesión que lee 50 archivos, corre tests y escribe docs se llena de contexto y se degrada (*context rot*). La cura es repartir el trabajo en **asientos**: cada uno con UNA responsabilidad y un "lo que NO hace" explícito. Heredado del andamio del linaje y probado en producción (ADR [0004](../docs/decisions/0004-centralizacion-del-conocimiento.md)).

## Asiento ≠ skill

Un **asiento** es el rol que alguien ocupa (el *quién*); una **skill** es un comportamiento disparable con límites escritos (el *cómo*). Un asiento puede ocuparse **en la sesión principal** o **como subagente**. Por eso dos asientos NO son skills:

- El **orquestador** — es la sesión misma: decide y teje, delega lo pesado. Su antipatrón tiene nombre: *el orquestador desarrollando* — picar código en el hilo principal lo envenena.
- El **desarrollador** — es el trabajo por defecto: escribir código.

Convención 🎭: cuando el orquestador hace en sesión el trabajo de otro asiento, lo **anuncia** (`🎭 Asiento: <rol> (en sesión) — <por qué>`) — así se distingue la elección deliberada del olvido.

## El menú de asientos

Menú, no molde: cada arquetipo de repo enciende solo los que merece.

| Asiento | Dueño de | Lo que NO hace |
|---|---|---|
| **orquestador** | decidir y tejer; delegar lo pesado | picar código en el hilo principal |
| **desarrollador** | escribir el código | — |
| **escribano** | sincronizar docs↔código según la ley ([blast-radius](../tools/blast-radius.json)) | no decide alcance; no inventa decisiones (eso es un ADR) |
| **validador** | correr pruebas y juzgar **solo lo ambiguo** que el test no resuelve | no re-valida lo que un test ya cubre; no toca lo visual |
| **revisor-visual** | aceptación UI/UX, evidencia en `qa_runs/` | no juzga lógica; **es checkpoint, no portero** — "¿se ve bien?" la responde el humano |
| **arquitecto-doc** *(opcional, arquetipo doc-heavy)* | formato, jerarquía y consistencia del grafo de docs | no decide negocio; conserva, no inventa alcance |

Los asientos como skills ejecutables llegan en el **Sprint 2** ([ROADMAP](../ROADMAP.md)). El conocimiento de qué es cada uno no espera a la máquina.

## Model-routing: no uses Ferrari para ir por tortillas

El orquestador elige el modelo según la tarea: **pequeño** para lo mecánico, **medio** para juicio acotado, **grande** para decisiones con trade-offs. Si dudas entre dos, sube uno.

## Las reglas duras (pagadas con incidentes reales del linaje)

1. **La lectura voluminosa SIEMPRE va a un subagente.** El subagente quema *su* contexto y devuelve solo el veredicto. Caso real: dos transcripts de ~250 KB leídos en el hilo principal degradaron la sesión entera.
2. **Sobre-orquestar también es error.** No todo merece subagente — y **no todo rol merece hook**. Caso real: se decidió NO cablear el rol de validación numérica porque *"sus tests SON el asiento; cablearlo sería sobre-orquestar"*.
3. **El paralelismo tiene tope.** Caso real: 5 subagentes con worktree en paralelo agotaron la cuota de la sesión; nació un gate determinista de concurrencia. El entusiasmo también se gobierna. Y el diseño de ese gate enseña tres cosas: el criterio de "pesado" es un **campo existente de la llamada**, no un juicio de la IA (*"pedirle a la sesión que se autorregule no es una barrera, es esperanza"*); la ventana de tiempo **se autolimpia** en vez de depender de un evento de cierre que puede no llegar; y vive en la config de la **cuenta**, no del repo — porque gobierna cuota de cuenta.
4. **Delegación coherente.** Caso real: commit delegado a un subagente pero push hecho en sesión — la mitad de la ceremonia no cuenta. Si delegas una cadena, delega la cadena.
5. **Una sola sesión escritora por working tree.** Caso real: el commit de una sesión paralela dejó **ciegos** los Stop hooks de la otra (solo ven lo no commiteado) y produjo un lost-update del HANDOFF. La segunda sesión es solo-lectura o se lleva su propio worktree; el HANDOFF tiene un solo dueño a la vez.

## La ley que gobierna todo el reparto

> **El determinismo bloquea; el juicio orquesta; nada irreversible se automatiza sin checkpoint humano.**

El cálculo crítico lo hace un motor determinista con tests, nunca un LLM. El gate se evalúa sobre el **artefacto** (el diff, el archivo, el log), no sobre confiar en el agente — por eso en Jidoka no existen archivos de auto-firma ("el rol X validó"): lo que se cuela, se atrapa.
