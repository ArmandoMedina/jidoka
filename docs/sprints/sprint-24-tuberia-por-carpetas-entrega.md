# Entrega — Sprint "La tubería = mapa completo del repo (nada invisible)"

> Récord de cierre. Plan-contrato: [`sprint-24-tuberia-por-carpetas-plan.md`](sprint-24-tuberia-por-carpetas-plan.md).
> Evidencia: [`qa_runs/tuberia-carpetas-20260722/LOG.md`](../../qa_runs/tuberia-carpetas-20260722/LOG.md).

## Qué se entregó

La tubería (tab 1 de la app) dejó de leer una lista curada a mano (49 piezas) y ahora **deriva el
censo de las carpetas**: **360 piezas = `git ls-files` exacto, nada invisible** (ADR 0051). Aparecen
los sprints, los ADRs, los análisis, las guías, los dominios, los módulos y la 5ª capacidad (CFG-1);
la Extensión VS Code retirada desaparece sola. Los nombres se derivan del propio archivo; las
secciones grandes colapsan; las aristas quedan vacías a propósito (para cablearlas desde la app).

**Antes, aparte:** se cerró el **fix de encoding** (la app abría con banner rojo porque PS 5.1 sin
consola emitía CP437 y `→` caía a un carácter de control) — su propio commit, apilado abajo.

## Cuadro de cierre

| Hecho | Valor |
|---|---|
| Sprint · ¿terminó? | "La tubería = mapa completo del repo" · **TERMINÓ** (R1/R2/R3 verdes, Gembas aprobados) |
| Rebanadas: planeadas / entregadas / desviadas | 3 / 3 / R2 **cumplido de paso en R1** (sus filas ya estaban en `$TIPOS`) |
| Rama · commits | `sprint/tuberia-por-carpetas-20260722` · 2 commits: `3e99a0d` (fix encoding) + el commit de este cierre (sprint) |
| Working tree al cerrar · duración | Limpio tras el commit del cierre · ~1 sesión (2026-07-22) |
| PR · ¿rama eliminada? | Sin PR aún — **merge/release esperan orden nombrada** del cliente + coordinación de versión con FLU-1 |
| Ritual corrido | arranca · planea · gemba (R1 y R3) · cierra |
| Delegaciones | `explorador`×2 (mapa de la UI + mapa del motor), `auditor`×2 (review del fix + review de R1), `arquitecto`/`explorador` (localizar el bug). Hilo en sesión: 🎭 desarrollador (bucle TDD acoplado del lector, contexto en el hilo) |
| Aprobaciones nombradas | "El error del JSON" (foco del fix) · plan del fix y del sprint aprobados en plan mode · Gemba R1 "se ve bien adelante" · cierre "se ve bien cierra el sprint" |
| Pruebas automáticas: altas/cambios/bajas · suites | +4 aserciones nuevas en `probar-app.ps1` (completitud + convención) + endurecimiento del bloque de encoding · `probar-app.ps1` **41/41** |
| Pruebas E2E | No aplica — app Tauri sin harness headless en CI (el `.exe` local es la evidencia; el Gemba lo corre el cliente) |
| Evidencia en `qa_runs/` | 2 corridas con `LOG.md` (fix + sprint), citadas y commiteadas con `git add -f` |
| Archivos: creados / editados | Creados: ADR 0051, plan y entrega del sprint, 2 `qa_runs/LOG.md`. Editados: `tuberia-datos.ps1`, `app/ui/index.html`, `probar-app.ps1`, `override.ps1`+`parametrizar.ps1` (fix), CHANGELOG, índice ADR, `sprints/README.md`, HANDOFF |
| Gates: verificar / probar-gate / self-tests | (se corren en el paso 4 del cierre, ver LOG) · avisos de doc-drift atendidos por el escribano (este cierre toca los docs dueño) |
| ¿Compactación? | No |
| ADRs | **0051** creado (tubería = mapa completo por convención). Renumerado 0050→0051 al consolidar en el PR único (el sprint de ADRs se quedó con 0050; FLU-1 tomó 0049) |
| CHANGELOG · versión | Consolidado en el PR único bajo `[1.29.0]` junto al sprint de ADRs: fix=PATCH, sprint=MINOR → `v1.29.0` |
| Issues/hallazgos | Review: encoding verde-en-falso (curado), CP437 latente en bandeja (anotado), globs que cruzan `/` (anotado), nombres en `innerHTML` (anotado) |
| Fricción (Kaizen crudo) | Colisión de working tree con el agente en paralelo (resuelto: el otro agente a su worktree) · 1 error mío de sintaxis PS (`$delta:`) cazado y corregido · cambio de detalle del plan (aristas) flagueado al cliente, no mudo |
| Pendientes al HANDOFF | merge/release + versión (con FLU-1) · derivar aristas reales (sprint) · optimizar ~2s de latencia · escapar nombres en la UI · glob recursivo-vs-directo |
| Resumen (3-5 líneas) | La app de gobierno dejó de mentir por omisión: su censo se deriva del repo real, no de una lista a mano. Se arregló antes el bug de encoding que la dejaba ciega. Todo aparece "sin cablear" — el trabajo por hacer, visible, para autorarlo desde la app. |

## Lo aprendido (Kaizen) — lo que el próximo `planea` debe leer

1. **La lista curada es el drift que Jidoka combate — no la repitas dentro de la app.** El censo a
   mano se desincronizó (faltaban dominios/módulos/CFG-1, sobraba la extensión retirada). Derivar de
   la estructura real (convención + catch-all) elimina la clase entera de bug. Regla que sube a ADR 0051.
2. **El vacío puede ser una feature, si lo dices.** Las aristas vacías no son una carencia: muestran
   lo "sin cablear" para autorarlo desde la app (reframe del cliente). Igual que la bandeja muestra
   lo "pendiente de parametrizar". Un estado incompleto **visible y honesto** > uno oculto.
3. **Un test verde puede estar muerto.** `probar-app.ps1` estaba verde-en-falso (forzaba UTF-8 al
   decodificar y usaba `ConvertFrom-Json`, más laxo que `JSON.parse`). Endurecerlo a *replicar al
   consumidor real* (bytes crudos + Node) fue lo que le dio dientes. Prueba de vida, no solo mecánica.
4. **Trabajo en paralelo = worktree, no solo rama.** Dos sesiones escritoras en el mismo working tree
   colisionan (los gates ven el diff revuelto). La regla dura "una sesión escritora por working tree"
   se hace cumplir con `git worktree`, no con confiar en ramas distintas.

## Verificación (el demo que corre el cliente) — CERRADA

- **R1 (Gemba aprobado, "se ve bien"):** el cliente abrió el `.exe` recompilado y vio todos los
  árboles del repo (incl. Sprints), las secciones grandes colapsadas, y la app sin banner rojo.
- **R3 (Gemba aprobado, "se ve bien cierra el sprint"):** el cliente refrescó (sin recompilar) y
  vio los nombres como títulos reales (`/jidoka:arranca`, `Capacidad — …`).
- Sin código ni terminal en ambos: doble clic al `.exe` + botón Refrescar. Rebanadas verticales de verdad.

## Pendiente que dejó (al HANDOFF)
- Merge y release con **orden nombrada** + reconciliar la versión con FLU-1 (`v1.28.0` contendido).
- Derivar las **aristas** reales (otro sprint): `@` del ritual, `ligas.json`, wikilinks.
- Optimizar la latencia (~2s por leer 250 H1) si molesta · escapar nombres derivados en la UI
  (`textContent`) · matcher de globs recursivo-vs-directo (el cruce de `/` latente).
