# ADR 0001 — Jidoka: fusión de la doctrina, el método y el ritual de sprint

- **Estado:** aceptado
- **Fecha:** 2026-07-10

## Contexto

Existían tres activos privados que, juntos, ya eran una metodología completa de desarrollo asistido por IA — pero dispersa:

1. **La doctrina** (`poka-yoke-ia`): la tesis de que un gate solo es muro si vive fuera del LLM, sus tres linajes (manufactura, software, aviación) y los 13 *disparos* (doctrina compilada a mensajes de gate). El **porqué**.
2. **El andamio** (`project-starter`): el lazo Intención→Construcción→Verificación→Registro, la jerarquía QUÉ/CÓMO, los roles multiagente y los gates deterministas ejecutables (`blast-radius.json` + auditores + CI). El **cómo**.
3. **El ritual de sprint** (probado en `tracker-financiero`): plan mode = sprint, el plan aprobado se archiva, se construye en rebanadas verticales, y el cliente valida un **incremento visual que corre él solo**. El **ritmo**.

Los frameworks agentic actuales resuelven la pérdida de contexto con equipos de agentes, pero dejan dos huecos: el control de calidad depende de que el agente coopere (no hay muro fuera del LLM) y no hay una ceremonia de demo visual para quien no lee código. Nuestros tres activos ya cubrían justo esos dos huecos.

## Decisión

Fusionar los tres en **Jidoka**, un repo público e instalable (`npx jidoka init`): el Sistema de Producción Toyota para agentes de IA, con un diferenciador propio frente a lo que existe hoy: **gates deterministas fuera del LLM + revisión por demo visual**.

Sub-decisiones:

- **Repo nuevo con historial limpio.** Nace desde cero, no reescribimos la historia de ningún repo viejo. Esto esquiva el bloqueo de PII que arrastran los historiales de `poka-yoke-ia` y `project-starter`.
- **La doctrina vive embebida.** `doctrina/` se copia dentro de Jidoka (contenido ya anonimizado en origen por su ADR 0004). Jidoka es *self-contained*: el instalador no clona ni depende de ningún otro repo.
- **Nombre = sistema TPS.** Jidoka (método) · Andon (gates) · Kanban (sprint) · Kaizen (retro) · Gemba (demo) · Poka-yoke (doctrina). Coherente y memorable.
- **Técnicas prestadas del ecosistema agentic** (crédito neutral, sin definirnos contra nadie): ownership por sección en artefactos, sharding de contexto (`devLoadAlwaysFiles`) y los estados de tarjeta. Se descartan los patrones pesados: planificación ceremoniosa, enjambre de roles, gates que no bloquean.

## Por qué

- Los frameworks agentic actuales dejan dos huecos: el control de calidad depende de que el agente coopere, y no hay ceremonia de demo visual para quien no lee código.
- Los tres activos ya cubrían exactamente esos dos huecos: gates deterministas fuera del LLM + revisión por demo visual.
- Fusionarlos en un repo público e instalable elimina la dispersión que impedía usar la metodología en repos ajenos.

## El camino que NO se toma (y por qué tienta)

Los patrones pesados del ecosistema agentic —planificación ceremoniosa, enjambre de roles, gates que no bloquean— tientan porque prometen estructura y cobertura. Se descartan: un gate que no bloquea es una sugerencia, no un muro (la tesis del método), y la ceremonia pesada reintroduce la fricción que el ritual mínimo evita.

## Consecuencias

- `project-starter` y `poka-yoke-ia` quedan como **fuentes internas**; no se publican tal cual. `tracker-financiero` sigue privado (solo se toma el patrón del ritual).
- Queda abierta —sin bloquear la beta— la opción de publicar el repo de doctrina suelto rebrandeado **"Poka-yoke"**; solo entonces Jidoka lo enlazaría como *further reading*.
- Jidoka corre sus **propios gates** (dogfooding) y se construye **usando su propio ritual de sprint**.
