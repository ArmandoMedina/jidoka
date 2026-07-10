# ADR 0006 — El plan de trabajo: efímero, con hogar persistente fuera de git

- **Estado:** aceptado
- **Fecha:** 2026-07-10
- **Sprint:** 2 · Fase A

## Contexto

El linaje dejó una contradicción sin zanjar (registrada en el ADR [0005](0005-exprimido-final-del-linaje.md)): la plantilla `plan-de-trabajo.md` declara *"efímero: no se versiona"*, pero el comando de arranque decía *"escríbelo en el repo"*. En tareas largas multi-asiento la práctica violó la regla **dos veces**, citando el riesgo real de perder el hilo tras un corte de contexto (compactación o cierre de sesión). Al construir `/jidoka:arranca` (Sprint 2) la contradicción se vuelve código: el comando tiene que apuntar a *algún* lugar concreto. Había tres opciones sobre la mesa (efímero estricto en contexto; versionado con válvula; hogar persistente fuera de git).

## Decisión

El plan de trabajo del día es **efímero pero con hogar persistente en disco, fuera de git**: vive en **`/.jidoka/plan-actual.md`** (raíz del repo, ignorado por `.gitignore` con patrón anclado `/.jidoka/`). No se versiona —el historial de git queda limpio— pero **sobrevive la compactación y el cierre de sesión**, porque está en el filesystem, no en el contexto del modelo. `/jidoka:arranca` lo lee al abrir; `/jidoka:cierra` lo poda al terminar. Se ancla al disparo `desconfia-de-la-compactacion`: al retomar, se verifica contra el artefacto real (el código, este archivo), nunca contra el resumen de la sesión anterior.

Distinción que el ADR fija: el **plan de SPRINT** (`docs/sprints/sprint-N-plan.md`) **sí se versiona** —es el contrato aprobado, permanente—; el **plan de TRABAJO** del día no. Son dos artefactos distintos con caducidades distintas; confundirlos fue la raíz de la contradicción.

## Por qué

- **Resuelve las dos fuerzas a la vez.** La necesidad de "no ensuciar el historial con notas de andamiaje" y la de "no perder el hilo en tareas largas" no eran incompatibles: lo eran solo mientras "persistente" se leyera como "versionado". El filesystem persiste sin que git registre.
- **Un lugar concreto elimina la deriva.** Mientras el hogar era ambiguo ("en el repo" vs "en ninguna parte"), cada sesión improvisaba y la regla se violaba en silencio. Una ruta con nombre no se puede malinterpretar.
- **El patrón anclado `/.jidoka/`** protege el kit: sin la barra inicial, el patrón habría ignorado también `kit/.jidoka/` (el kit versionado). La barra fija la ignorancia a la raíz.

## El camino que NO se toma (y por qué tienta)

- **Efímero estricto (solo en contexto).** Tienta por pureza: cero rastro en disco, imposible de "olvidar borrar". Se descarta porque es exactamente lo que falló: en una tarea larga, un corte de contexto se lleva el plan y la sesión retoma a ciegas — el modo de falla que este ADR existe para cerrar.
- **Versionado con válvula de excepción.** Tienta porque git ya persiste y da trazabilidad. Se descarta porque ensucia el historial con andamiaje que no es contenido (contra `kanban/lazo.md` → Podar) y porque una "válvula de excepción" exige disciplina de poda que la práctica ya demostró que no se cumple: se convertiría en planes de trabajo fósiles commiteados.

## Consecuencias

- `/jidoka:arranca` y `/jidoka:cierra` tienen un contrato claro sobre dónde vive el estado del día.
- La plantilla `kit/.jidoka/templates/plan-de-trabajo.md` se afina para nombrar el hogar `/.jidoka/plan-actual.md` en vez de decir solo "no se versiona".
- Deuda abierta: en el arquetipo **doc-only** (Sprint 3, matriz del instalador) `/arranca` no se siembra — por tanto tampoco su plan de trabajo; queda anotado para la matriz pieza×arquetipo.

---

> Reglas del registro: una decisión = un archivo · al agregarlo, **listalo en el [índice](README.md) en el mismo commit** (el gate lo exige) · nunca borres una decisión: márcala *reemplazada* y enlaza la nueva.
