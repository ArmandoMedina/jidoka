---
tipo: analisis
estado: en_revision
---
# Auditoría 4 — Prueba de vida de la nave nodriza (2026-07-16)

> **Qué es esto:** el espejo del análisis de costo neto de SGI (#72), aplicado a Jidoka mismo: qué piezas del método/motor tienen uso real documentado y cuáles tienen cero señal de vida. Criterio heredado de #46: **un test verde NO es señal de vida**. Evidencia: 13 corridas de `qa_runs/`, HANDOFF, CHANGELOG, git log, issues. Subagente `auditor`, sobre `v1.18.0` (`affb44e`).

## El patrón (idéntico al de SGI)

**Lo cableado y lo determinista vive; lo que requiere iniciativa humana muere.** Los 15 scripts del motor, los 5 hooks y la ley tienen mordidas documentadas (ROJO→VERDE en LOGs, preflights, releases). El canal formal de lecciones, la plantilla de entrega y los comandos "de cobertura" tienen silencio total.

## Vivas con evidencia (sin discusión)

Motor completo (`verificar`, `auditar`, `publicar`, `rutear`, `estado-motor`, `sembrar-manual`, los 9 `probar-*` — varios con ROJO→VERDE de campo), hooks (5, cableados en settings), la ley, `arranca`/`planea`/`gemba`/`cierra` (10 planes archivados, 13 corridas de evidencia, 37 ADRs), plantillas `qa-log`/`adr`/`sprint-plan`, `kanban/lazo.md` y `roles.md`, las guías de motor y entorno, agentes `auditor` y `arquitecto` (recién nacidos, ya con 2 usos).

## Cero señal — las candidatas, con recomendación

### Prueba de vida con plazo (que muerdan o se poden)

| Pieza | Silencio | Prueba de vida propuesta |
|---|---|---|
| `tools/reportar-leccion.ps1` + su guía | **0 usos jamás** — las lecciones del linaje suben por sesiones del autor, no por el canal; las 3 drafts de SGI llevan días sin presentar. Mismo hallazgo que en SGI (#72). | Correrla UNA vez contra una lección draft real. Si el issue aparece en el tracker, vive; si la próxima cosecha llega y sigue en 0, podar y documentar "el canal es abrir el issue a mano". |
| `kit/.jidoka/templates/sprint-entrega.md` | **1 uso en 10 sprints** (y ese lo escribió el humano a mano). En SGI: 0 usos. `cierra.md` la referencia con `@`. | El próximo cierre de sprint la llena o se poda la referencia de `cierra.md`. Dos repos ya demostraron que la entrega se reconstruye de HANDOFF+CHANGELOG+qa_runs. |
| `/jidoka:desatendido` + su plantilla + `kanban/desatendido.md` | 5 semanas, **0 LOGs de sesión desatendida** — el comando de mayor riesgo (trabaja sin humano) es el menos ejercitado. | La próxima corrida autónoma real deja LOG con su plantilla, o se acepta que el patrón de lanes vive dentro de las sesiones normales y se poda el comando. |
| `/jidoka:que-sigue` | 0 invocaciones documentadas; el `arranca` ya cubre ese territorio (sección 6). | O se demuestra un uso donde aporte sobre el `arranca`, o se funde con él. |
| `/jidoka:descubre` + `kit-entrevista.md` | Pendiente de demo de campo desde su nacimiento (#67, ya en el HANDOFF). | El demo con niebla real que el HANDOFF ya pide — es del cliente. |
| `kit/.jidoka/templates/validar-dominio.ps1` | Dormida en Jidoka, sin uso en ningún hijo documentado. | Espera al primer hijo con área `validador` (regla 2-3) — con fecha de revisión, no para siempre. |

### Poda candidata directa (decisión del cliente)

- **`kanban/jerarquia.md` y `kanban/verificacion.md`** — cero lectores de maquinaria, cero consultas documentadas, y su contenido vive mejor donde ya se usa (comandos y `lazo.md`). `auditoria.md` y `homologacion.md` tienen un matiz: son Fuente declarada de 3 diagramas del atlas — podarlos rompe el atlas; la alternativa es reconocerlos como "prosa del atlas" y ya no como docs operativos.
- **`docs/guias/guion-gif-del-gate.md`** — el GIF se generó una vez (2026-07-11); nadie ha vuelto a correr el guión y el gate ya cambió (`-AgregadosInyectados`, v1.15). O se regenera el GIF con el guión (probándolo), o el guión es deuda.
- **`kit/.jidoka/templates/producto/` (12 plantillas)** — cero uso en la nodriza (esperado: son del arquetipo grafo) y sin evidencia de uso en hijos. Revisar contra los hijos reales en la próxima bajada.

### Matices honestos (no podar)

- `auditar.ps1` corre en cada preflight pero **jamás ha bloqueado nada en Jidoka** (el grafo propio es chico y sano) — indistinguible de un gate podrido sin una prueba de vida: meter un wikilink roto en rama y verlo morder. Barato y vale la pena.
- Los `SKILL.md` de asientos (escribano, revisor-visual, validador, arquitecto-doc) quedaron como doc de límites del rol tras la llegada de `.claude/agents/` — redundancia de bajo costo, pero conviene declarar cuál de los dos es el dueño de la definición del asiento.
- `explorador` y `mecanico` (agents), `infra.md` (plantilla): recién nacidos, vida aún no exigible.
- `plan-de-trabajo.md`: efímero por diseño (ADR 0006) — su cero señal en git es la invariante correcta.

## Veredicto

La nave nodriza pasa la prueba de vida en el núcleo con holgura — mejor que SGI: aquí los gates sí muerden y dejan LOG. Pero reproduce **exactamente las mismas 2 piezas muertas que ya se le midieron a SGI** (canal de lecciones, plantilla de entrega) más una cola propia de comandos sin consumidor. La regla 2-3 se aplicó bien hacia afuera (doc-only diferido, gobernanza diferida) y menos bien hacia adentro: `desatendido`, `que-sigue` y `validar-dominio` se construyeron sin esperar su segundo caso. Medir también puede justificar eliminar — esta tabla es el insumo para esa decisión, que es del cliente (#46/#66/#72 convergen aquí).

## Limitaciones

- La lectura humana espontánea no deja rastro; "cero señal" = cero rastro en artefactos (#66).
- Los bloqueos locales de hooks no dejan log persistente (mismo hueco que en SGI).
- Corte: 2026-07-16, `v1.18.0` (`affb44e`).
