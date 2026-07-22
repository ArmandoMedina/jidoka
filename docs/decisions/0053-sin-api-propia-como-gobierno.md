# ADR 0053 — Nada de API/MCP propio como capa de gobierno; sustrato git/GitHub + hooks

- **Estado:** aceptado
- **Fecha:** 2026-07-04
- **Nota:** heredado del repo interno de doctrina (número original: 0002); consolidado en `docs/decisions/` el 2026-07-22.

## Contexto

Para portar la metodología de gates (probada en el laboratorio de campo) a trabajo no-código
(p. ej. un equipo de soporte con IA como coworker), se evaluó construir una API o MCP propio que
actuara como "githook" del nuevo dominio. Se corrió un benchmark en 4 frentes: enforcement,
validadores no-código, gobernanza de agentes, sustratos de trabajo.

## Decisión

**Se mata la opción de API/MCP propio como capa de gobierno.** Stack: git/GitHub como sustrato
(docs-as-code; el merge es la publicación), hooks del agente como muro local (`PreToolUse`
ask/deny, `Stop`), required checks + required reviews + CODEOWNERS como muro server-side,
Vale/JSON Schema/linters como validadores de forma en hook y CI.

## Por qué

1. Una API propia que la IA llama voluntariamente tiene el mismo modo de falla que las memorias:
   depende de cooperación del modelo → no es muro (ley del muro, [`../../doctrina/00-tesis.md`](../../doctrina/00-tesis.md)).
2. La IA no conoce la API de fábrica → la reaprende cada sesión → reintroduce amnesia y
   bifurcación, exactamente lo que los gates resolvieron.
3. No existe a 2026 sustrato multi-persona con gate inmutable que la IA domine mejor que
   git/GitHub — ni para trabajo no-código (benchmark verificado).

## Matiz que sobrevive

MCP como **puente delgado** hacia artefactos cautivos en sistemas propietarios (CRM/ticketing)
es a veces inevitable. Regla: el puente transporta, el muro decide, y el muro (hook/required
check/OPA) vive fuera del modelo y DELANTE de esa tool. Mantener el puente aburrido y
convencional.

## El camino que NO se toma

- API/MCP de validación que la IA "debe llamar".
- Meter a la IA a operar Jira/ServiceNow/Zendesk como sustrato primario (los conoce mucho peor
  que git; obliga a construir el MCP que se quería evitar).

## Consecuencias

El gobierno de Jidoka se apoya **solo** en primitivas git/GitHub + hooks del agente: no hay una
capa de servicio propia que mantener, versionar ni que la IA deba reaprender. La contrapartida
aceptada es que Jidoka queda **acoplado a lo que git/GitHub ofrecen** (branch protection, required
checks, CODEOWNERS) y que la integración con sistemas propietarios se hace por un puente MCP
delgado —nunca como muro—. Es la decisión congelada que la tesis del método (`doctrina/00-tesis.md`)
cita como su piso: *el punto de control vive FUERA del LLM*.
