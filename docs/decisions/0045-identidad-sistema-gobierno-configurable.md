# ADR 0045 — Jidoka es un sistema de gobierno configurable, no solo una metodología: la UI autora los caminos, el gate los ejecuta

- **Estado:** aceptado
- **Fecha:** 2026-07-21
- **Relacionado:** [ADR 0002](0002-motor-andon.md) (el muro determinista, intacto) · [ADR 0044](0044-editor-del-gobierno-autora-gate-ejecuta.md) (la UI autora, el gate ejecuta) · [ADR 0046](0046-contratos-y-regimenes.md) · [ADR 0047](0047-meta-gobierno-contrasena-firma-candado.md) · [[CFG-1-gobierno-configurable]]

## Contexto

Dos sesiones de descubrimiento (2026-07-20/21) aterrizaron una visión que el cliente venía persiguiendo desde el re-Gemba de `v1.25.0`. Su tesis, textual: *"La IA puede hacer todo, pero alguien que hace todo no hace nada. La idea es conectar tubería que no sea una caja negra, que se pueda guiar al usuario y a la IA por los caminos que nosotros determinamos como correctos. Toda la maquinaria es configurable."* Y el marco: *"estamos haciendo un sistema configurable — ya no lo veas solo como una metodología."*

El camino enseñó qué **no** es: se intentó resolver con visualización (un spike de "Capas" de enforcement) y el cliente lo rechazó con sus ojos —*"la verdad es que no"*—. El problema nunca fue de mapas: un mapa responde *"¿cómo se ve todo?"*; la pregunta del cliente es *"¿qué hago con ESTO, ahora?"*. La visión se validó con las manos sobre una maqueta clickeable de 6 iteraciones (censo de la tubería, bandeja de pendientes, regímenes de gobierno, formulario de alta, modo avanzado): *"me gustó — hay que aterrizarlo."*

## Decisión

Jidoka **es un sistema de gobierno configurable con UI guiada**, no solo una metodología con comandos fijos. El usuario parametriza el gobierno de su repo desde la interfaz —qué se vigila, qué se lee, qué régimen tiene cada pieza y qué no puede tocar la IA— sin editar JSON a mano, y todo lo que nazca por fuera cae a una bandeja de pendientes. Esta es la capacidad ancla **[[CFG-1-gobierno-configurable]]**, construida en fase 1 por seis rebanadas (contrato del sprint en `docs/sprints/sprint-sistema-configurable-plan.md`).

La línea doctrinal **no se dobla**: la UI **autora**, el gate **ejecuta**. La interfaz nunca es el muro; el único enforcement sigue siendo el gate determinista *fuera* del LLM (ADR 0002). Clic en la UI → escribe un ledger en git → el gate lo hace cumplir. Nada depende de que el modelo coopere.

## Por qué

- **El dolor real es la caja negra.** El cliente entra a proyectos avanzados, mete Jidoka, y queda *juez y parte*: no ve la máquina, la IA se la narra. La UI le devuelve el juicio — ve y configura la máquina con sus ojos, no con la palabra del agente.
- **"Ligar" era genérico desde el principio.** El censo halló cinco relaciones (vigilancia, wikilinks, ligas, lectura `@`, y la prohibición nueva); solo una se autora hoy. El marco "metodología" era demasiado estrecho para lo que el cliente quiere gobernar.
- **La maqueta ya lo probó con las manos.** No es hipótesis: seis Gembas vivos, dos hallazgos del propio cliente curados en caliente. El artefacto concreto destrabó lo que los menús abstractos no.

## El camino que NO se toma (y por qué tienta)

- **Resolver con visualización / mapas del todo.** Tentaba porque "ver el grafo completo" parece dar control. Se rechazó en Gemba: el cliente no quiere un mapa, quiere guía en el momento concreto (*"¿qué hago con ESTO, ahora?"*). El spike de "Capas" quedó aparcado sin mergear.
- **Hacer la UI el muro.** Tentaba porque una UI que *bloquea* se siente más segura. Viola ADR 0002: un punto de control dentro del LLM/la app es sugerencia, no muro. La UI autora; el gate —server-side, sin bypass— ejecuta.
- **Una API/MCP propia como capa de gobierno.** Tentaba por "integración". Se rechazó (ADR 0002, decisión congelada): reintroduce la amnesia entre sesiones que el método resolvió con artefactos en git.

## Consecuencias

- Nace **[[CFG-1-gobierno-configurable]]** (bajo [[MOD-andon]]): la ley se vuelve configurable desde la UI sin dejar de ser gate.
- La **fase 1** cubre documentos + ritual + candados + regímenes (las 6 rebanadas). Ver agentes/modelos/hooks como piezas parametrizables desde la UI —"toda la maquinaria"— es **fase 2 de la visión**, diferida.
- La **maqueta** (`docs/analisis/maqueta-tuberia-202607.html`) queda como spec visual y onboarding del cartón; el tour productivo no se porta en fase 1.
- Los dos ADRs hermanos concretan la mecánica: [ADR 0046](0046-contratos-y-regimenes.md) (los regímenes y el ledger de contratos) y [ADR 0047](0047-meta-gobierno-contrasena-firma-candado.md) (el meta-gobierno).
