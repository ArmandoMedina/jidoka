---
tipo: brief
estado: en_definicion
---

# <Nombre del producto> — Brief

> El QUÉ y el PORQUÉ, en una página. Para el arquetipo **code-first** este es el único doc de producto (no la jerarquía de notas). Regla de oro: define el comportamiento con suficiente claridad para que cualquiera implemente sin inventar reglas de negocio. Si el QUÉ está borroso, no lo rellenes a mano: `/jidoka:descubre` lo saca con una entrevista y deja estos campos llenos.

## En una frase
<Qué es y para quién, en una sola oración.>

## El problema
<Qué dolor real resuelve. Sin esto, el producto no tiene razón de ser.>

## El caso concreto (citable)
<La última vez REAL que este dolor costó tiempo o dinero, contada con las palabras del cliente — un hecho pasado con fecha aproximada, no una hipótesis. El QUÉ vive aquí, no en las features.>

## Métrica objetivo (con número)
<Con qué número se sabrá que mejoró: minutos, pesos, errores. Un número, no un adjetivo ("más rápido" no es métrica).>

## La autoridad del dominio
<Quién es el juez de verdad de las reglas de negocio (puede NO ser quien opera la IA), qué disponibilidad tiene, y EN QUÉ FORMATO validará el resultado (lo que esa persona pueda abrir y mirar, sin código ni terminal). Si es un tercero: sus respuestas entran como evidencia rastreada (docs/gemba/), no como recuerdo.>

## Criterio de "hecho"
<Cómo sabrá el cliente, VIÉNDOLO, que ya quedó. Ej: "abro la página, subo el archivo una vez, y veo el saldo sin volver a subir nada".>

## Apetito
<Cuánto tiempo/dinero vale la pena invertir ANTES de reconsiderar. No es una estimación: es la apuesta máxima que el cliente decide.>

## Qué hace (capacidades ancla)
- <Capacidad 1 — en lenguaje de usuario, no de sistema.>
- <Capacidad 2.>

## Criterios de aceptación (Gherkin)
- Dado que <contexto>, cuando <acción>, entonces <resultado esperado>.

## Landscape — qué más existe y por qué esto
<Las alternativas reales (verificadas en vivo, no de memoria) y qué hace distinto a esto. Nombra 2-3 opciones y en una línea por qué no bastan. Esta sección evita reinventar y ancla el diferenciador.>

| Opción | Qué hace | Por qué no basta |
|---|---|---|
| <alternativa> | <en una línea> | <la brecha que este producto llena> |

## Fuera de alcance (no-metas)
- <Lo que este producto NO intenta ser — dicho por el cliente AHORA, para que nadie lo "descubra" construido después.>

## Decisiones abiertas
- <Lo que aún no se decide y quién lo decide.>

## Aprobación del QUÉ
<Vacío hasta que el cliente apruebe NOMBRANDO lo que aprueba (disparo `aprobacion-nombrada`): "Apruebo <qué> con <métrica> y que el primer sprint ataque <rebanada>" — con fecha. Un "dale" no llena este campo.>

<!--
tipo: brief · estado. El brief code-first. La seccion Landscape se llena con alternativas
VERIFICADAS en vivo (no de memoria): licencias y features se confirman visitando la fuente.
Los campos "caso concreto / metrica / autoridad / hecho / apetito / aprobacion" los puebla
/jidoka:descubre cuando el QUE nace borroso. Borra este comentario al usar la plantilla.
-->
