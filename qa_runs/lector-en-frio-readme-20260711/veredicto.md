# Gemba de prosa — lector en frío sobre el README (2026-07-11)

> Corrida del ritual de verificación de la reescritura del README (rama `vitrina-readme-aterrizado`).
> Método: un subagente-persona "vibe coder" (construye con IA, sin contexto de TPS/Jidoka/manufactura,
> con los 3 dolores típicos) lee el README de arriba a abajo como visitante de GitHub, sin sesgo de
> confirmación, y emite veredicto. Misma persona y mismas preguntas en ambas corridas.

## Criterio de aceptación (del plan aprobado)

Entiende qué es en 30 segundos · sabe qué hacer hoy · el veredicto mejora de "star y cerrar pestaña" a "probar".

## Resultado: PASA

| | README anterior (main) | README nuevo (esta rama) |
|---|---|---|
| Primeros 30 s | "Me perdí en la línea 1 [...] si hubiera llegado de Google, ahí mismo la cierro" | "Me enganché en la línea 3, literalmente la primera frase [...] Esa frase me compró" |
| ¿Sabe qué hacer hoy? | "No [...] ¿Copia lo que te sirva? Yo no sé qué me sirve, por eso estoy aquí" | "SÍ hay un bloque 'instala esto y corre esto', está arriba, es corto [...] Correría el instalador y el verificar.ps1 hoy mismo" |
| Veredicto | "⭐ star... y pestaña cerrada por ahora" | "STAR + probar los pasos 1 y 3 [...] No cierro la pestaña" |
| Resumen en una línea | "diagnóstico perfecto de mi enfermedad, escrito en el idioma del doctor y no del paciente, con la receta todavía en el horno" | "me diagnosticaron en mi idioma y me recetaron en el suyo" (hallazgo restante, curado en la iteración final: glosario de una línea para CI/branch protection/ADR, paso 3 copy-paste completo, cita académica desinflada) |

## Hallazgos de la segunda corrida y su destino

- **Curados en la iteración final de esta rama:** jerga sin traducir en "Qué hace por ti" (CI, branch protection, ADR, "rebanadas verticales"); el paso 3 del quickstart exigía saber crear un ADR (ahora es copy-paste completo con limpieza); la cita "Bainbridge (1983)" con aire académico (ahora la idea primero, sin nombre propio).
- **Pendientes con destino ya registrado:** el GIF del gate (checklist humana, guion en `docs/guias/guion-gif-del-gate.md`); la guía "empezar de cero" / "tu primer día" (Sprint 4); Mac/Linux (Fase 3.C); evidencia de un adoptante tercero ("repo ajeno", criterio de la v1.0).
- **Señales positivas nuevas:** la sección "¿Te suena?" descrita como "el mejor diagnóstico que he leído de mi problema"; el techo de gasto por suscripción "responde mi miedo número 2"; la honestidad de las fronteras "me hace creerle lo demás"; Airbus/Boeing "la mejor explicación de deny/ask de todo el repo".

## Fuente

Los reportes completos de ambas corridas (persona técnico-escéptico + persona vibe-coder sobre el README
anterior; persona vibe-coder sobre el nuevo) corrieron como subagentes de la sesión 2026-07-11. Este
artefacto resume lo citable; el texto íntegro de la corrida final respalda cada cita de arriba.
