---
tipo: analisis
estado: en_revision
---
# Veredicto — ¿Toyota y Scrum de verdad, o puro teatro? (2026-07-16)

> **Qué es esto:** la síntesis de las 5 auditorías de la sesión del 2026-07-16 (documentos+ley, atlas, kit, prueba de vida — informes hermanos en este directorio), respondiendo la pregunta central del cliente: *"¿realmente se está usando la metodología de Toyota y Scrum o es puro teatro?"*. La responde el orquestador con la evidencia cruzada, no con fe. Sobre `v1.18.0` (`affb44e`).

## El veredicto, sin anestesia

**No es puro teatro — el núcleo Toyota es maquinaria real con mordidas documentadas. Pero el método tiene tres zonas, y solo una es muro:**

1. **La zona determinista (Toyota/jidoka): REAL.** Es la más fuerte y está probada.
2. **La zona conductual (Scrum/ritual): REAL PERO FRÁGIL.** Funciona porque el operador la respeta, no porque algo la haga cumplir — y la evidencia muestra dónde se dobla.
3. **La zona ceremonial: TEATRO ACUMULÁNDOSE EN LOS BORDES.** Piezas y prosa que existen para que el método "esté completo", sin consumidor real.

La doctrina propia del repo predice exactamente esto (`doctrina/00-tesis.md`: *"si depende de que el modelo coopere, no es muro — es una sugerencia"*). El repo cumple su tesis donde la aplicó — y las zonas 2 y 3 son donde no la aplicó.

## Zona 1 — Lo Toyota es real (evidencia, no opinión)

- **Stop-the-line existe y ha parado la línea:** 3 doc-drifts reales frenados antes del merge en SGI (análisis #72); el GIF del README es una corrida real; el salvavidas `no-borres-el-motor` nació de un incidente real (un subagente borró 750 líneas del motor y el review pasó verde — #75) y hoy bloquea con test ROJO→VERDE. El juez falla cerrado (exit 2; ADR 0032 nació de verlo fallar abierto en vivo, #78).
- **El muro vive fuera del LLM de verdad:** branch protection + check `andon` required sin bypass, la ley se lee desde la rama base (un PR no puede editar la ley que lo juzga). Esta sesión misma lo comprobó: el pull tropezó con el AV y ninguna pieza del método dependió de mi palabra para detectarlo.
- **Kaizen genuino, no de póster:** 7 cosechas documentadas donde lecciones de uso real maduraron a mecanismo (ADRs 0013→0037), incluyendo las incómodas — el #75 está contado con honestidad brutal en el HANDOFF y curado con maquinaria, no con promesas. Eso es exactamente el ciclo de mejora de TPS.
- **Genchi genbutsu parcial:** 13 corridas en `qa_runs/` con LOGs; el listón LOG.md (ADR 0030) cerró un Goodhart real.

## Zona 2 — Lo Scrum es conductual, y ahí está doblándose

Los diagramas y comandos ponen los STOPs del cliente en el carril correcto (verificado en el atlas), pero **ningún hook detecta un R0 saltado, un demo diferido o un Kaizen sin escribir**. Lo que la evidencia muestra:

- **La Verificación del sprint la está absorbiendo el CI, no el Gemba del cliente.** Los demos del cliente se acumulan como pendientes en el HANDOFF (demo de `v1.16.0`, demo de la cosecha #7, demo de campo de `descubre` desde el 14-jul). Los sprints cierran y liberan con suite verde; el "lo viste funcionar" — el criterio de hecho del propio brief — queda debiéndose. **Esto es lo más parecido a teatro Scrum que tiene el repo: la review existe en el papel y se difiere en la práctica.**
- **La retro tiene formato y no se usa:** `sprint-entrega.md` (el artefacto del Kaizen) se llenó 1 vez en 10 sprints — y esa vez, a mano. El Kaizen real sí ocurre (las cosechas lo prueban) pero fluye por HANDOFF+issues, no por el artefacto prescrito. El método prescribe una ceremonia que ni su propia nave usa.
- **El R0 con aprobación nombrada sí se practica** (los 10 planes archivados lo registran, y el #68 documenta al cliente cazando al agente doblando su contrato — el control funcionó porque el humano estaba mirando). Honesto: es disciplina de operador, y con otro operador no hay nada que la sostenga. El brief además sigue con sus 2 huecos (métrica y apetito) — el QUÉ del propio método está incompleto río arriba.

## Zona 3 — El teatro localizado (dónde sí hay adorno)

- **El canal formal del lazo nunca se ha usado:** `reportar-leccion.ps1` tiene 0 usos totales (nodriza y SGI). "La lección sube" es verdad — pero sube por sesiones del autor. El canal es utilería mientras nadie lo corra.
- **Piezas construidas contra la propia regla 2-3:** `/jidoka:desatendido` (5 semanas, 0 LOGs — el comando de mayor riesgo, jamás ejercitado), `/jidoka:que-sigue` (0 invocaciones; el `arranca` cubre su territorio), `validar-dominio.ps1` (dormida, sin hijo que la pida). La regla se aplicó con rigor hacia las familias (doc-only diferido) y se relajó hacia adentro.
- **Prosa de método sin lector:** `kanban/jerarquia.md` y `verificacion.md` — nada de maquinaria los lee, cero consultas documentadas.
- **El atlas driftea a 24 horas de nacer:** 7 de 11 diagramas del motor omiten dientes reales, dos quedaron atrás de la cosecha #7 el mismo día — y la ley no vigila esa dirección (los scripts no son fuente del área `atlas`). Matiz importante: el sesgo es *quitarle* rigor al papel, no pintarle rigor falso — es drift honesto, no maquillaje. Pero un atlas que miente por omisión pierde su función de mapa.

## Qué haría yo (en orden de valor)

1. **Pagar la deuda del Gemba humano** — correr los 3 demos pendientes del cliente. Es la pata Scrum coja y no la puede correr la IA; mientras no pase, "hecho = lo viste funcionar" es aspiracional.
2. **La cosecha de poda** — decidir sobre la tabla de la prueba de vida (canal de lecciones, sprint-entrega, desatendido, que-sigue, validar-dominio, kanban muertos). Podar también es kaizen; un método más chico y todo vivo es más creíble que uno completo y medio muerto.
3. **Reconciliar el atlas del motor + declarar `tools/*` fuente del área `atlas`** — o aceptar explícitamente (ADR) que el atlas cubre solo el ritual.
4. **Cerrar los huecos chicos de la ley y los tests** — bin/ sin área, 4 exclusiones de raíz, `sello.producto` sin check, `tools:` sin validar (todo registrado en issues de esta sesión).
5. **Los 2 huecos del brief** (métrica y apetito) — siguen siendo del cliente.

## Limitaciones

- Un solo repo, operado por el autor del método; transferibilidad no medida (#70).
- "Conductual" no es un defecto per se — la doctrina misma reserva el juicio al humano; el hallazgo es la brecha entre lo prescrito y lo practicado, no la existencia de juicio.
- Corte: 2026-07-16, `v1.18.0` (`affb44e`); informes hermanos: `auditoria-documentos-y-ley`, `auditoria-atlas`, `auditoria-kit`, `prueba-de-vida-nodriza` (mismo sufijo 202607).
