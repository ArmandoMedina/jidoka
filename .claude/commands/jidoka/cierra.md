---
description: Cierra el sprint o la sesión — registra el estado, poda lo muerto, commitea la evidencia y prepara el release
argument-hint: "[sprint/sesión que se cierra]"
allowed-tools: Read, Bash
---

Estás **cerrando**. El cierre es donde el conocimiento se vuelve durable para la próxima sesión (tú en 6 meses, o una IA sin memoria). Lo que no quede en un artefacto se pierde.

Qué se cierra: **$ARGUMENTS**

## 1. Registra (el orden del cierre es FIJO — no depende de memoria)

El registro se reparte por doc dueño (`kanban/lazo.md`) y se escribe **en este orden** — cada doc lleva su contrato que lo hace cumplir:

1. **Poda primero — `tools/expirar.ps1` (ejecutar, no simular).** Corre **ANTES** de escribir cualquier doc: el circuit breaker **edita** el `ROADMAP.md` (mueve lo vencido a `docs/MUERTOS.md` con fecha y motivo, por clase de servicio — `tools/flujo.json`), así lo que registres abajo ya está podado. Lo caduco muere por script, no por juicio.

   ```
   powershell -NoProfile -ExecutionPolicy Bypass -File tools/expirar.ps1
   ```

2. **`HANDOFF.md`** — escribe la nueva **«Dónde estamos»**, degrada la anterior a **«Dónde estuvimos»**, y mueve la histórica sobrante **ÍNTEGRA** a `docs/handoff-historico.md` (que `/jidoka:arranca` nunca inyecta). El check **`[contrato-handoff]`** lo hace cumplir: UNA «Dónde estamos», máximo N históricas, techo de líneas — excedido **BLOQUEA** el push. Una nota vieja que ya no es verdad es peor que no tenerla; las decisiones de juicio del cliente van a su cola propia (`[PENDIENTE]` / `[DECIDIDA-REVISABLE]`).

3. **`ROADMAP.md`** — todo pendiente nuevo entra **CLASIFICADO** en su clase de servicio con `[alta:AAAA-MM-DD · apetito:Nh]` (los «Con fecha» además `vence:AAAA-MM-DD`; el icebox «Algún día» solo `alta:`). El check **`[contrato-roadmap]`** **BLOQUEA** una sección fuera del contrato o un ítem sin sus metadatos.

4. **`CHANGELOG.md`** — la sección de la versión bajo su contrato: **header datado** (`## [X.Y.Z] — AAAA-MM-DD`), **bullets tipados** (un tipo permitido entre backticks — `feat`/`fix`/`test`/`docs`/`chore`/`breaking` — o `ADR `, la voz de la casa) y **prosa al mínimo** (techo `max_prosa_lineas`). El check **`[contrato-changelog]`** mide **solo la sección tope** (no es retroactivo) y **BLOQUEA** lo que se salga: el changelog es registro operativo, no carta. Si tocaste el ritual o los gates, aquí se registra (lo pide la ley: áreas `metodo` y `ritual`).

5. **Índices** — cada ADR nuevo (`docs/decisions/`) **listado en su índice `README.md` en el mismo commit** (único bloqueo duro del blast-radius); el sprint en `docs/sprints/README.md`. Un ADR por cada decisión no obvia; si una regla gobierna decisiones futuras, asciende a ADR (no la dejes en un checkbox). Si hubo sprint: llena la entrega con `@kit/.jidoka/templates/sprint-entrega.md` en `docs/sprints/` — su Kaizen (1-5 lecciones) es lo único que el siguiente `planea` lee completo. La sección **Verificación (el demo que corre el cliente)** se cierra solo si el cliente pudo correr el demo **sin código ni terminal**; si solo corrió por terminal, dilo en «Pendiente que dejó», no la des por cumplida.

6. **Registra el Gemba del sprint — `tools/flujo.json` → `estado.gembas_pendientes`.** Si el sprint entrega algo que el cliente debe ver, **REGISTRA su Gemba** con `{ id, desde: AAAA-MM-DD, que_ver, aceptado: false }`. Un sprint sin Gemba registrado es un sprint que **se auto-declaró aceptado** — eso no existe (el criterio: *hecho = lo viste funcionar*). El booleano `aceptado` queda en `false` hasta que el cliente lo acepte con nombre en `/jidoka:gemba`; mientras tanto, el gate del límite WIP (`estado-flujo.ps1 -Gate`) mantiene plantado el próximo `/jidoka:planea` y lo nombra.

7. **«Cerrado» es veredicto de los gates, no frase del agente.** ANTES de declararlo cerrado: `tools/verificar.ps1` (sin drift ni contratos rotos), `tools/probar-flujo.ps1` (el pilar de flujo sano) y `tools/estado-docs.ps1` (estructura de docs) **verdes**. Un gate rojo significa que el cierre no terminó.

### El cuadro de cierre — los hechos medibles, versionado con los planes

Llena este cuadro con **hechos** (números, nombres, sí/no — nada de "creo que"), preséntalo al cliente y **guárdalo versionado**: si hubo sprint, como sección "Cuadro de cierre" dentro de su entrega; si no, como `docs/sprints/cierre-AAAAMMDD.md`, listado en `docs/sprints/README.md`. Es el insumo de métricas entre sesiones — **un hueco se declara ("no corrió E2E"), no se rellena bonito**: el cuadro solo sirve si dice la verdad.

| Hecho | Valor |
|---|---|
| Sprint (número/nombre, o "sin sprint") · ¿terminó o queda **en curso**? | |
| Rebanadas del plan: **planeadas / entregadas / desviadas** (resumen de una línea — el detalle vive en la entrega del sprint) | |
| Rama (nombre) · commits (cantidad + lista `oneline`) | |
| Working tree al cerrar (¿limpio? qué queda y por qué) · duración aprox (del primer al último commit) | |
| PR (número y estado) · ¿rama mergeada eliminada? | |
| Ritual corrido esta sesión (arranca / descubre / planea / que-sigue / gemba / desatendido / cierra) | |
| Delegaciones: qué asiento-subagente hizo qué · qué hizo el hilo en sesión con 🎭 (excepción acusada) | |
| Aprobaciones **nombradas** que el cliente otorgó en la sesión (qué aprobó, con qué palabras) | |
| Pruebas automáticas: **altas / cambios / bajas** · suites corridas y resultado (N/N) | |
| Pruebas E2E (Playwright u otro harness): ¿corrieron? resultado | |
| Evidencia: ¿corrida en `qa_runs/` con capturas y `LOG.md`? ¿citada y commiteada (`git add -f`)? | |
| Archivos: creados / editados / eliminados (conteo + los clave) | |
| Gates: `verificar` / `auditar` / self-tests — resultado · avisos **atendidos** vs **no-aplicables (con su razón)** | |
| ¿Hubo compactación/resumen de contexto? · ¿se re-verificó contra los artefactos al retomar? | |
| ADRs creados o enmendados | |
| CHANGELOG: ¿al día? · versión propuesta (MAJOR/MINOR/PATCH) o queda `[Unreleased]` | |
| Motor Jidoka: ¿al día con la nave? (`estado-motor.ps1` — clave en repos hijos) | |
| Issues/hallazgos encontrados (detalle) · ¿se abrieron issues de GitHub? | |
| Fricción y errores (**Kaizen crudo**): correcciones del cliente al agente (cuántas, cuáles) · errores del agente cometidos y reparados | |
| Pendientes que van al HANDOFF (incluida la cola de decisiones del cliente) | |
| Resumen de los cambios (3-5 líneas) | |
| Resumen de la conversación con el cliente (qué pidió, qué se decidió) | |

## 2. Poda (la otra mitad de registrar)

Cierra con trazabilidad lo que ya no vive; borra solo el andamiaje que nunca fue contenido. **Si dudas entre borrar y marcar → marca.** El plan de trabajo del día (`/.jidoka/plan-actual.md`) se poda aquí.

**El paso duro de la poda ya corrió en §1 (1): `tools/expirar.ps1`** movió lo vencido del `ROADMAP.md` a `docs/MUERTOS.md` con fecha y motivo, por clase de servicio (`tools/flujo.json`). Así la poda deja de depender de que alguien se acuerde: lo caduco muere por script, no por juicio, y revivir un muerto es re-proponerlo con alta nueva (nada vuelve solo). Si aún no lo corriste, córrelo ahora (el comando está en §1).

## 3. Commitea la evidencia del Gemba (paso obligatorio, no cortesía)

El bulto de `qa_runs/` está gitignored. La evidencia **citada** desde HANDOFF/CHANGELOG se commitea selectivamente:

```
git add -f qa_runs/<corrida>/<archivo-citado>
```

En el linaje se descubrió una vez que 0 artefactos habían llegado a git — toda la evidencia era local y se habría perdido con el clon.

## 4. Verifica antes de subir

- Corre `./tools/probar-gate.ps1` (el motor sano) y `./tools/verificar.ps1` (sin drift de docs).
- **No uses `--no-verify` ni manipules el estado staged para pasar un hook** (disparo `no-verify-es-teatro`): el muro real es el required check server-side; saltar el hook local solo pospone y agranda el fallo.

## 5. Release (si el sprint entrega una versión)

El ritual, en 6 pasos (`CONTRIBUTING.md`): working tree limpio → cerrar la sección del CHANGELOG → commit `chore(release)` → tag anotado → push **con OK del dueño** → GitHub release. La versión vive en **un** solo lugar; todo lo demás deriva. La pregunta del salto: ¿rompe? MAJOR · ¿agrega? MINOR · ¿arregla? PATCH — en un repo de método, una reorganización que obliga a migrar notas es MAJOR.

> Autorizaciones vigentes (revisa el HANDOFF): publicar tag+release puede estar ya autorizado; **merges de PR y cambios de config/permisos requieren orden nombrada del cliente cada vez**. No los asumas.
