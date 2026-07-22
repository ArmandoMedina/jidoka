# ADR 0054 — La doctrina se consume vía disparos (mensajes de gate), no vía lectura

- **Estado:** aceptado
- **Fecha:** 2026-07-04
- **Nota:** heredado del repo interno de doctrina (número original: 0003); consolidado en `docs/decisions/` el 2026-07-22.

## Contexto

Hallazgo pagado en el laboratorio de campo: la IA no lee docs de metodología de forma
consistente, y las reglas repetidas en prosa fallan (la regla anti-memoria falló 4 veces dicha
en prosa; funcionó al cablearse como hook). El contexto efectivo es el que llega **en el momento
del disparo** — como razón de un deny, mensaje de un Stop hook, o texto de un required check
fallido — no el que "debería leerse" al inicio de sesión.

## Decisión

El corpus mantiene dos capas con roles distintos:

- `doctrina/` — el **porqué** citable, para humanos y para redactar/publicar. Ninguna maquinaria
  depende de que una IA lo lea.
- los **disparos** ([`kit/.jidoka/disparos/`](../../kit/.jidoka/disparos/) en este repo) — la
  doctrina **compilada a mensajes de gate**: fragmentos cortos, autocontenidos, con la regla + el
  porqué en 2-4 líneas, listos para pegarse en hooks, mensajes de CI y
  `permissionDecisionReason`. Es el único formato en que la doctrina llega a la IA.

## Por qué

- **La lectura voluntaria no es muro.** La IA no lee la metodología de forma consistente y las
  reglas en prosa dependen de su cooperación — el mismo modo de falla que las memorias.
- **El disparo llega cuando importa.** Un mensaje en el momento del deny/Stop/check fallido es
  contexto que la IA no puede ignorar; el doc de inicio de sesión sí.
- **Cada capa hace lo que hace bien.** El porqué largo y citable vive para el humano; la regla
  corta y accionable vive compilada para la máquina. Separarlas evita inflar una con la otra.

## Regla de mantenimiento

Cada vez que la doctrina cambie una regla accionable, el disparo correspondiente se actualiza en
el mismo commit. Un disparo sin doctrina que lo respalde se poda; una doctrina accionable sin
disparo está incompleta. (En Jidoka, esta regla la recuerda el área `disparos` de la ley
[`tools/blast-radius.json`](../../tools/blast-radius.json).)

## El camino que NO se toma

CLAUDE.md gigante o "comando de arranque" que ordene leer la doctrina. Probado y fallido: es el
enfoque persona (pedir cooperación), no el enfoque sistema.

## Consecuencias

Toda regla accionable de la doctrina existe **dos veces** —como porqué citable en `doctrina/` y
como disparo compilado— y el área `disparos` de la ley (`tools/blast-radius.json`) hace cumplir
que se mantengan sincronizadas. La prosa de la doctrina **nunca** es el muro; el disparo cableado
en un hook o en CI sí. El costo aceptado es esa duplicación disciplinada, vigilada por el gate.
