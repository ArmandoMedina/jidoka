# Kanban — el ritual de sprint

> Adaptación mínima de Scrum a **cliente + IA**, sin ceremonia de equipo. Sin sprints calendarizados, puntos ni standups: eso es coordinación de equipos. Aquí el sprint es un **lazo corto de valor demostrable**.

## Los estados de la tarjeta

```
Borrador → Aprobado → En curso → Revisión → Hecho
```

## El lazo de cuatro tiempos

| Ceremonia Scrum | Aquí |
|---|---|
| **Sprint planning** | **Plan mode** (`/jidoka:planea`): la IA explora, decide y escribe el plan; el cliente lo **aprueba** (ExitPlanMode). El plan aprobado **es** el sprint, y se **archiva** en `docs/sprints/sprint-N-plan.md`. → *Aprobado* |
| **El sprint** | El `dev` construye en **rebanadas verticales**, cada paso commiteable y verde (Andon local avisa, CI bloquea). → *En curso* |
| **Sprint review** | Dos capas. **Robots:** `/code-review` + gates de CI → veredicto de 1 línea. **Gemba** (`/jidoka:gemba`): el incremento **visual** que el cliente corre solo. → *Revisión* |
| **Retro (Kaizen)** | `/jidoka:cierra`: la sección *"Lo aprendido"* al `sprint-N-<slug>.md`; HANDOFF y CHANGELOG al día. → *Hecho* |

## La regla de oro

> **El cliente revisa el _demo_, nunca el PR.** El PR lo revisan los agentes; al cliente le llega el incremento funcionando y un veredicto de una línea. *"Hecho" = el cliente lo vio funcionar.*

Es la tesis de los dos pájaros hecha ritual: la disciplina (revisión de código, gates) sobre los robots; el juicio (¿esto resuelve mi problema? lo veo) sobre el humano.

## Ownership por sección

Los artefactos de sprint declaran, por sección, quién es su **dueño** y quién puede **editarla** — para que los agentes no se pisen. La sección *"Revisión del stakeholder"* tiene `owner: cliente`: los agentes no la escriben, es tuya.

## El contexto que viaja

Entre sprints viaja la **lección** (la retro Kaizen que el siguiente `/jidoka:planea` lee), no la ventana de contexto entera. El `dev` arranca cada sprint cargando solo el mínimo (`devLoadAlwaysFiles`) + el plan. Así el contexto no revienta.

*(El formato concreto de los docs de sprint llega en Sprint 2, con los templates.)*
