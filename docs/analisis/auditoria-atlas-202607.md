---
tipo: analisis
estado: en_revision
---
# Auditoría 2 — Fidelidad del atlas BPMN contra el repo real (2026-07-16)

> **Qué es esto:** auditoría hostil de los 24 BPMN + 1 DMN de `docs/atlas/` (v1.17.0, ADRs 0035/0036) contra sus fuentes reales — los comandos `/jidoka:*`, las skills, `kanban/` y los scripts del motor. El atlas se había validado solo "a la vista" al cortarse; esta es su primera verificación elemento por elemento. Dos subagentes `auditor` (uno por mitad), sobre `v1.18.0` (`affb44e`).

## Veredicto en una línea

**El atlas no inventa procesos — pero maquilla el motor por omisión.** La familia del ritual (comandos) salió fiel: 12 de 14 diagramas sin drift. La familia del motor (scripts) no: 7 de 11 con drift, y el patrón es consistente: **los diagramas omiten justo las ramas de fallo** — los `Die`, los exits ≠ 0, los preflights — que son los dientes del método. Ningún diagrama dibuja un control que no exista (cero INVENTA); varios esconden controles que sí existen.

## Los hallazgos ALTOS

| # | Diagrama | Hallazgo |
|---|---|---|
| 1 | `80-publicar-release` | **Omite la suite de 9 self-tests** que `publicar.ps1` corre y que puede abortar el release (`Die`). El diagrama muestra "el dueño aprueba → se publica"; la realidad tiene un muro técnico en medio. Además dibuja un userTask "OK nombrado" que el script no tiene (el OK es invocar el script). |
| 2 | `44-reportar-leccion` | **Carriles invertidos** — único caso: "anonimizar" y "redactar" están en el carril del agente, pero el script solo abre una URL; ese trabajo es del humano en el navegador. Afirma automatización inexistente. |
| 3 | `41-actualizar-motor` | **No refleja la migración `[MIGRA]` de la cosecha #7** (ADR 0037, un día antes de esta auditoría): modela el `-Actualizar` viejo, sin siembra de stubs faltantes ni la rama `[EXCLUIDA]` (ADR 0022) ni el `Die` sin sello. |
| 4 | `01-operar-sesion` (nivel 1) | **Tres gateways dibujados como checkpoints deterministas que son juicio del agente**: `¿Requiere plan?`, `¿QUÉ aprobado?` (duplicado del control que vive dentro de `descubre`), `¿Incremento aceptado?`. Quien lea el atlas como spec sobreestimará la robustez del método. |

## Los MEDIA que valen registrar

- `15-gemba`: **happy-path encubierto** — si el cliente dice "no se ve bien" no hay camino de rechazo dibujado; el diagrama presupone aprobación. (El HANDOFF del atlas presumía "sin happy-path".)
- `18-desatendido`: la regla dura "NO edites tus propios gates" del comando no tiene gateway ni representación.
- `30-instalar`: dibuja un smoke final con `Gw_Smoke → End_Roto` que `instalar.ps1` no ejecuta (el smoke vive en `publicar.ps1`); omite el aviso brownfield real (hooks sin cablear) y el `Die` de arquetipo inválido.
- `40-estado-motor`: omite los 3 exits tempranos reales (sin sello, sin `JIDOKA_HOME`, sin `version.txt`) y fuerza `-Detallado` como paso obligatorio cuando es opcional.
- `81-preflight-release`: falta `probar-agentes` (cosecha #7) y el guard `Test-Path` que falla cerrado (issue #78/#88 — el hallazgo estrella de la cosecha #6, ausente de su propio diagrama).
- `01-operar-sesion`: el loop de rechazo del incremento no tiene salida de abandono.

Fieles sin hallazgos relevantes: `00/02/03/04-arquitectura`, `10-arranca`, `11-descubre`, `12-planea`, `13-construye`, `14-revision`, `16-cierra`, `17-que-sigue`, `70/71/72-auditoria`, `90-regla-2-3.dmn` (la tabla DMN coincide con la doctrina).

## Por qué pasó (y por qué va a volver a pasar)

El atlas (`v1.17.0`) y la cosecha #7 (`v1.18.0`) se construyeron **en paralelo el mismo día** y nadie reconcilió los diagramas del motor tras el merge. El acoplamiento del ADR 0036 es comando→diagrama (aviso); **los scripts de `tools/` no son fuente del área `atlas`**, así que cambiar `instalar.ps1` jamás avisará que `30/40/41/42` quedaron atrás. Con la ley actual, la familia del motor va a driftear con cada cosecha — esto no es un descuido puntual, es estructural.

## Insumo para el veredicto teatro-vs-real

- El sesgo del atlas es **quitarle dientes al método en el papel, no pintarle dientes falsos**: la maquinaria real (review-stop con SHA, CI required, preflight que muere) es MÁS dura que su diagrama. Es el drift honesto, no el maquillaje.
- Los controles conductuales (R0, señal del cliente, demo) están correctamente dibujados como userTasks del carril humano — el atlas no los disfraza de automáticos, salvo los 3 gateways del nivel 1.

## Limitaciones

- Verificación XML vs texto de fuentes; no se ejecutaron los procesos.
- `instalar.ps1`/`probar-instalador.ps1` se leyeron desde git (cuarentena AV local).
- Corte: 2026-07-16, `v1.18.0` (`affb44e`).
