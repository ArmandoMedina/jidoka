---
tipo: casting
estado: vigente
---
# Casting — [nombre del proyecto]

> **Quién hace qué, y qué NO le toca a cada quien.** El reparto de funciones —humanos y agentes—, cada asiento con su carta de alcance positivo y **negativo**. `/jidoka:arranca` lo inyecta al abrir. El *rol* es el mecanismo neutral que la ley y los hooks entienden (`kanban/roles.md`); el *nombre* es sabor de instancia — mapearlo a una persona lo vuelve memorable y deja claro quién responde por qué (ADR 0023). El CÓMO-operativo (identidades, máquinas) vive aparte, en `infra.md`.
>
> **Cómo llenar este molde:** parte el humano en **dos roles** (la autoridad del dominio / el dueño-operador). Si una sola persona ocupa ambos, dilo explícito. Nombra a cada quien y —clave— **la unidad en que se mide su restricción**: horas/semana no es lo mismo que ventanas asíncronas de N días, y el WIP se calcula distinto según cuál sea. Los asientos-agente vienen neutrales a propósito; enciende solo los que este repo merece.

## El reparto humano

> El cuello de botella del sistema **no es producir código: es revisar y aceptar** (Teoría de Restricciones). Por eso se separan dos roles: quien sabe del negocio no tiene por qué ser quien opera el método.

### La autoridad del dominio — «el que sabe»

- **SÍ le toca:** ser el único juez de «esto está bien» en las reglas del negocio; responder las preguntas del dominio; validar que el incremento dice la verdad sobre su realidad. En este proyecto: **[AUTORIDAD: nombre de la persona que sabe del negocio]**.
- **NO le toca:** operar la IA; priorizar; correr el método; decidir el CÓMO técnico. **No es usuario del agente** — sus respuestas entran por el kit de entrevista y dejan evidencia en `docs/gemba/`.
- **Su restricción (el cuello de botella):** su disponibilidad de atención — **LA** restricción de Goldratt. **Unidad:** [UNIDAD DE SU RESTRICCIÓN: horas de revisión/semana | ventanas asíncronas de N días | …]. El WIP y el apetito se subordinan a este número, no al del agente.

### El dueño-operador

- **SÍ le toca:** priorizar; fijar el apetito y el presupuesto de contexto; correr el método (`/jidoka:*`); disparar sesiones; **aceptar el FLUJO** (que el incremento cumple la DoD y se puede entregar); firmar alcances; autorizar merges/releases. En este proyecto: **[NOMBRE del dueño-operador]**.
- **NO le toca:** dictar las **reglas de negocio** (eso es de la autoridad del dominio); juzgar calidad técnica/visual línea por línea (eso es del `validador` y el `revisor-visual`).
- **Su restricción:** su presupuesto de revisión por ciclo — el **apetito** (Shape Up), medido en horas de su atención.

### ¿Los dos roles coinciden?

[Di explícito quién ocupa cada asiento. Si UNA persona es autoridad **y** dueño-operador, dilo: «X ocupa ambos». Si la autoridad es OTRA persona y tú solo operas, dilo también: eso es correcto, no un hueco — optimizar tus horas no sube el throughput si el cuello de botella es la ventana de la autoridad.]

## Los asientos-agente

Los mismos en todos los proyectos: la maquinaria es neutral; el nombre es una capa cosmética (`kanban/roles.md` → *Personalizar el casting*). El detalle conductual de cada asiento vive en su artefacto (`.claude/agents/*.md` para los subagentes; el `SKILL.md` para las skills); aquí va **una línea** por asiento. Mapea el nombre de tu casting en la columna correspondiente.

**Los cuatro asientos-subagente por tier** — `.claude/agents/*.md` con `model:` fijo (ADR 0033); `tools/asientos.ps1` los imprime al abrir:

| Asiento | Tier | Su carta en una línea |
|---|---|---|
| **explorador** | haiku (pequeño) | barre y localiza; devuelve dónde vive algo, no un juicio. |
| **mecanico** | haiku (pequeño) | aplica un edit ya especificado; no decide el QUÉ ni el CÓMO. |
| **auditor** | sonnet (medio) | juicio acotado: revisa contra spec, corre un test; no rediseña. |
| **arquitecto** | opus (grande) | trade-offs: diseño, alternativas, riesgos; no ejecuta a ciegas. |

**Los asientos-skill** (`skills/<nombre>/`) — nombra al ocupante si casteas con personas:

| Asiento | Nombre | Su carta en una línea |
|---|---|---|
| **escribano** | [nombre] | sincroniza docs↔código según la ley; no decide alcance ni inventa decisiones. |
| **validador** | [nombre] | corre pruebas y juzga solo lo ambiguo; no re-valida lo cubierto, no toca lo visual. |
| **revisor-visual** | [nombre] | aceptación UI/UX con evidencia en `qa_runs/`; es checkpoint, no portero. |
| **arquitecto-doc** *(opcional, doc-heavy)* | [nombre] | formato y consistencia del grafo de docs; conserva, no inventa alcance. |

**Los roles del método que NO son skill:**

| Rol | Nombre | Su carta en una línea |
|---|---|---|
| **orquestador** | [nombre] | la sesión principal: decide y teje, delega lo pesado; no pica código en el hilo. |
| **desarrollador** | [nombre] | el trabajo por defecto: escribir código; opcionalmente un skill de delegación. |
| **devops** | [nombre] | la máquina y el entorno (VMs, CI, deploys, secretos); no toca código de negocio ni vive en el repo. |

## La carta del asiento coordinador que NO existe

**No falta un PM.** En Toyota no hay ningún rol humano que gestione el flujo caso por caso, y el Scrum Master «no decide alcance ni prioridad». Contratar un asiento que persiga el trabajo a mano reproduciría el problema con otro nombre. Sus funciones útiles se descomponen en **mecanismos deterministas** (gate, no ritual):

- **Límite WIP** → `tools/estado-flujo.ps1 -Gate`; **expiración** → `tools/expirar.ps1`; **vista** → `tools/estado-flujo.ps1` + hook `SessionStart`; **reporte** → `tools/reporte-avance.ps1`.

Lo **indelegable** queda en los humanos de arriba: decidir alcance y prioridad, interpretar reglas de negocio, aceptar el trabajo, negociar dinero. Ninguna es un asiento-agente.

---

> **Procedencia.** [Enlaza el diagnóstico/benchmark que originó tu reparto, si lo hay, y la fecha del acuerdo con el cliente.]
