---
tipo: casting
estado: vigente
---
# Casting — Jidoka

> **Quién hace qué, y qué NO le toca a cada quien.** El reparto de funciones del proyecto —humanos y agentes—, cada asiento con su carta de alcance positivo y **negativo**. Sale de `product/infra.md` (que se queda con identidades y máquinas) para tener casa propia: `/jidoka:arranca` lo inyecta al abrir. El *rol* es el mecanismo neutral que la ley y los hooks entienden (`kanban/roles.md`); el *nombre* es sabor de instancia. Molde sembrable en `kit/.jidoka/templates/casting.md`.
>
> **Por qué existe este doc.** Nace del pedido del cliente (2026-07-21): *«analizas qué funciones existen en los proyectos, qué función voy a tomar yo… para saber qué hace cada quien»*, y de su duda: *«el usuario debería ser siempre el que sabe… pero en el caso de enti no sé cómo ponerme a mí»*. La respuesta es partir el humano en **dos roles separados** (abajo): quien sabe del negocio no tiene por qué ser quien opera el método.

## El reparto humano

Dos roles, no uno. El diagnóstico de flujo (2026-07) mostró que el cuello de botella del sistema **no es producir código: es revisar y aceptar** — y quien acepta el *negocio* no siempre es quien corre el *método*. Separarlos responde la duda del cliente: en un proyecto puedes ser el operador sin ser «el que sabe», y no pasa nada.

### La autoridad del dominio — «el que sabe»

- **SÍ le toca:** ser el único juez de «esto está bien» en las reglas del negocio; responder las preguntas del dominio; validar que el incremento dice la verdad sobre su realidad.
- **NO le toca:** operar la IA; priorizar el backlog; correr el ritual; decidir el CÓMO técnico. **No es usuario del agente** — sus respuestas entran por el kit de entrevista y dejan evidencia en `docs/gemba/`.
- **Su restricción (el cuello de botella del sistema):** su disponibilidad de atención. Es **LA** restricción de Goldratt — optimizar la producción del agente no sube el throughput si esta ventana no se mueve (paso 3 de focalización). **Unidad:** horas de revisión / semana **o** ventanas asíncronas de N días, según cómo trabaje la persona. El WIP y el apetito se subordinan a este número, no al del agente.

### El dueño-operador

- **SÍ le toca:** priorizar; fijar el apetito y el presupuesto de contexto; correr el método (`/jidoka:*`); disparar sesiones; **aceptar el FLUJO** (que el incremento cumple la DoD y se puede entregar); firmar alcances; autorizar merges/releases.
- **NO le toca:** dictar las **reglas de negocio** (eso es de la autoridad del dominio); juzgar calidad técnica/visual línea por línea (eso es del `validador` y el `revisor-visual`).
- **Su restricción:** su presupuesto de revisión por ciclo — el **apetito** (Shape Up), medido en horas de su atención. Es el número que la plantilla del brief exige y que gobierna cuánto trabajo puede estar abierto a la vez.

### En esta nave, los dos roles coinciden

En Jidoka (nave nodriza) **el cliente ocupa ambos asientos**: es la autoridad del dominio (sabe qué debe hacer el método) **y** el dueño-operador (lo corre). Se dice explícito porque no siempre es así: en un proyecto de rescate o de un dominio ajeno, la autoridad es **otra persona** y el cliente es solo el dueño-operador — y ese reparto es correcto, no un hueco (ver `docs/analisis/reparto-enti-202607.md`).

## Los asientos-agente

Los mismos en todos los proyectos (decisión del cliente): la maquinaria es neutral; el nombre es una capa cosmética encima (`kanban/roles.md` → *Personalizar el casting*). El **detalle conductual** de cada asiento vive en su artefacto con dientes; aquí va **una línea** por asiento.

**Los cuatro asientos-subagente por tier** — viven instalados en `.claude/agents/*.md` con su `model:` fijo (ADR 0033); `tools/asientos.ps1` los imprime al abrir sin poder mentir sobre ellos:

| Asiento | Tier | Su carta en una línea |
|---|---|---|
| **explorador** | haiku (pequeño) | barre y localiza; devuelve dónde vive algo, no un juicio sobre ello. |
| **mecanico** | haiku (pequeño) | aplica un edit ya especificado; no decide el QUÉ ni el CÓMO. |
| **auditor** | sonnet (medio) | juicio acotado: revisa contra una spec dada, corre un test; no rediseña. |
| **arquitecto** | opus (grande) | trade-offs: diseño, alternativas, riesgos; no ejecuta a ciegas. |

**Los asientos-skill** — comportamientos disparables con límites escritos (`kanban/roles.md`):

| Asiento | Vive como | Su carta en una línea |
|---|---|---|
| **escribano** | `skills/<nombre>/` | sincroniza docs↔código según la ley (`blast-radius.json`); no decide alcance ni inventa decisiones. |
| **validador** | `skills/<nombre>/` | corre pruebas y juzga solo lo ambiguo que un test no resuelve; no re-valida lo cubierto, no toca lo visual. |
| **revisor-visual** | `skills/<nombre>/` | aceptación UI/UX con evidencia en `qa_runs/`; es checkpoint, no portero — «¿se ve bien?» la responde el humano. |
| **arquitecto-doc** *(opcional, doc-heavy)* | `skills/<nombre>/` | formato y consistencia del grafo de docs; conserva, no inventa alcance. |

**Los roles del método que NO son skill** (`kanban/roles.md`):

| Rol | Vive como | Su carta en una línea |
|---|---|---|
| **orquestador** | la sesión principal | decide y teje, delega lo pesado; no pica código en el hilo principal. |
| **desarrollador** | el trabajo por defecto | escribir el código; opcionalmente un skill de delegación con nombre. |
| **devops** | agente de plataforma (fuera del repo) | la máquina y el entorno: VMs, SSH, CI, deploys, secretos, branch protection; no toca código de negocio ni decide producto. |

## La carta del asiento coordinador que NO existe

El benchmark de flujo (2026-07, `docs/analisis/benchmark-flujo-202607.md` → *Frente 4* y *La carta del asiento que falta*) confirmó por cuatro caminos ajenos que **no falta un PM que persiga el trabajo a mano** — en Toyota no hay ningún rol humano que gestione el flujo caso por caso, y el Scrum Master «no decide alcance ni prioridad». Contratar un asiento que persiga el trabajo reproduciría el problema con otro nombre.

Sus funciones útiles se **descomponen en mecanismos deterministas** (gate, no ritual), que el pilar de flujo ya cablea:

- **Límite WIP** (drum-buffer-rope) → `tools/estado-flujo.ps1 -Gate`: nada nuevo arranca si hay un Gemba sin aceptar.
- **Expiración** (circuit breaker) → `tools/expirar.ps1`: lo vencido muere por script, no por juicio.
- **Vista del estado** → `tools/estado-flujo.ps1` + el hook `SessionStart`: el «qué sigue» se empuja a la vista.
- **Reporte de avance** → `tools/reporte-avance.ps1`: las 5 secciones en lenguaje llano para terceros.

Lo **indelegable** queda en los humanos de arriba: decidir alcance y prioridad, interpretar reglas de negocio, aceptar el trabajo, negociar dinero. Ninguna de esas es un asiento-agente; ninguna es un PM.

---

> **Procedencia.** Este casting nace del diagnóstico y el benchmark de flujo de 2026-07 ([`gemba-gestion-del-flujo-202607.md`](../docs/analisis/gemba-gestion-del-flujo-202607.md), [`benchmark-flujo-202607.md`](../docs/analisis/benchmark-flujo-202607.md)) y del pedido del cliente del 2026-07-21 (el reparto de funciones y la duda de «cómo ponerme a mí en enti»). La aplicación a un proyecto de dominio ajeno vive, solo-lectura, en [`reparto-enti-202607.md`](../docs/analisis/reparto-enti-202607.md).
