# Entrega — Sprint "Documentos gobernados" (KIT-2, ADR 0042)

> Récord de cierre. El contrato está en [`sprint-documentos-gobernados-plan.md`](sprint-documentos-gobernados-plan.md). Cerrado 2026-07-17, `v1.23.0`.

## Qué se entregó

El **hermano estructural del sello**: el motor se gobierna por hash; los documentos instancia-de-template que el ritual inyecta con `@` (`brief`/`infra`/`CONTRIBUTING`) por **secciones** (modelo SAP: alterar la estructura gobernada = *garantía nula*). Las 3 rebanadas del plan, entregadas completas:

- **R1 — Ledger** `tools/docs-gobernados.json`: taxonomía capa-1/2/3 + secciones requeridas congeladas por doc.
- **R2 — Detector** `tools/estado-docs.ps1` (hermano de `estado-motor`): aviso en `/jidoka:arranca`; muro opt-in (`-Estricto` en CI, apagado por defecto). `tools/probar-docs.ps1` (24/24).
- **R3 — CONTRIBUTING** gana template real + stub estructurado; `CODE_OF_CONDUCT` confirmado capa-3.

## Kaizen (las lecciones — lo único que el próximo `planea` lee completo)

1. **La premisa del cliente puede estar medio equivocada — mide antes de construir.** El cliente sintió "los docs del ritual divergen"; la medición (solo-lectura) mostró que **NO** (son motor, gobernados por hash) y encontró el hueco real: los docs de **instancia** sin gobierno de estructura. Medir el drift antes de planear evitó construir el mecanismo equivocado (endurecer el ritual) en vez del correcto (gobernar la estructura de la instancia).
2. **Dos regímenes de gobierno, dos herramientas.** El hash es correcto para lo que debe ser idéntico (motor); es la herramienta **equivocada** para un doc cuyo contenido debe variar a propósito. Las secciones son el eje correcto para la instancia. No forzar una sola herramienta sobre ambos.
3. **Congela el contrato en el ledger, no en el template vivo** (corrección del asiento arquitecto). Derivar las requeridas de los `##` del molde acoplaría cada edición de template al pass/fail de todos los hijos — una sección nueva los marcaría DESVIADO de golpe. El ledger congela; el template crece libre.
4. **El "no se pueda" se honra como palanca del cliente, no como muro impuesto.** El muro estricto nace opt-in y **apagado**: encenderlo por defecto podía brickear el CI de todos los hijos con una sola edición de molde. La autoridad del cliente = el flag en su ledger.
5. **El método sobre sí mismo, otra vez.** El `/code-review` cazó un falso-CONFORME real (un `##` dentro de un code-fence contaba como sección) — curado en el diff con caso ROJO→VERDE antes de cerrar.

## Cuadro de cierre

| Hecho | Valor |
|---|---|
| Sprint · ¿terminó? | "Documentos gobernados" (KIT-2) · **terminó** (3/3 rebanadas) |
| Rebanadas: planeadas / entregadas / desviadas | 3 / 3 / 0 (ajustes de diseño dentro del plan: "El casting" fuera de infra-requeridas por su fallback; el grafo fuera de alcance por validación del arquitecto — ambos en el plan) |
| Rama · commits | `sprint/documentos-gobernados-20260717` · 5 (subsume el preflight `45aa926`): `1c4a031` feat · `029fcb7` docs · `0290b19` test · `e730b5a` fix(code-review) |
| Working tree · duración | limpio al cerrar · ~1 h (15:39→16:44, 2026-07-17) |
| PR · ¿rama eliminada? | (se abre y mergea en este cierre — autorización nombrada) · rama a eliminar tras merge |
| Ritual corrido | arranca · planea (R0 + STOP 2 en plan mode) · cierra |
| Delegaciones | `arquitecto` (opus, read-only): validó las 3 decisiones de arquitectura + cazó C1/C2/C3. 🎭 Hilo principal en sesión: la codificación de los `.ps1` (edición acoplada con bucle TDD sobre los mismos scripts — excepción del §5, no rito) |
| Aprobaciones nombradas | R0 del QUÉ ("dale a /jidoka:planea con esas 3 rebanadas") + STOP 2 (plan aprobado en plan mode) + cierre ("ciérralo... autorizado, marge, con versión y borrar rama") |
| Pruebas: altas / cambios / bajas | altas: `probar-docs.ps1` (nuevo, 24 casos) · cambios: `publicar.ps1` (probar-docs al preflight) · bajas: 0 |
| Suites corridas | `probar-docs` 24/24 · `probar-instalador` 67/67 · `probar-sembrar` 38/38 · `probar-publicar` 7/7 · `probar-preflight` 7/7 · `probar-version` 1.23.0 · `probar-agentes` 32 · `probar-gate` 14 · `probar-hooks` 32 · `probar-disparos` 4 · `probar-auditor` 7 |
| E2E (Playwright u otro) | N/A (repo de método; sin harness E2E) |
| Evidencia en `qa_runs/` | `qa_runs/documentos-gobernados-20260717/LOG.md` — suite verde + demos A/B + caso enti · citada y commiteada (`git add -f`) |
| Archivos: creados / editados | 8 nuevos / 14 editados (clave nuevos: `estado-docs.ps1`, `docs-gobernados.json`, `probar-docs.ps1`, `templates/CONTRIBUTING.md`, ADR 0042, KIT-2, plan+entrega) |
| Gates | `verificar -Base main` exit 0 (2 avisos: `ritual`→es KIT-2 no RIT-1; `atlas`→diagrama, follow-up registrado) · `auditar` íntegro · self-tests verdes |
| Compactación | no hubo · N/A |
| ADRs | **0042** creado (gobierno documental por estructura) · listado en su índice en el mismo commit |
| CHANGELOG · versión | al día · **1.23.0** (MINOR — capacidad nueva; rebumpó de 1.22.0 al rebasar sobre main que ya liberó 1.22.0 con #108) |
| Motor Jidoka | al día (es la nave nodriza) |
| Issues/hallazgos | code-review: 1 fix aplicado (fence), 2 límites aceptados (prefijo — ADR), 1 follow-up (muro lee ledger del PR no de base). Sin issues de GitHub abiertos (al HANDOFF) |
| Fricción / Kaizen crudo | Correcciones del cliente (colaborativas, no errores): "y el plan mode?" (aclaré los 2 STOP) · "no autorizo el QUÉ sin el CÓMO" (fusioné R0+plan en plan mode) · "capacidades es mal ejemplo" (refiné la taxonomía) · reframe SAP · "une la rama del preflight". Errores del agente reparados en sesión: 2 — el ledger requería "El casting" (falso-DESVIADO en la nave nodriza) y el falso-CONFORME por code-fence (cazado por el review) |
| Pendientes al HANDOFF | colisión de versión #108 · Gemba del cliente · atlas 10-arranca sin el sub-paso nuevo · muro lee ledger del PR no de base · bajar KIT-2 a los labs |
| Resumen de cambios | Gobierno documental por estructura: ledger + detector (aviso + muro opt-in) + template de CONTRIBUTING. El motor gana la capacidad de detectar cuando un doc de instancia altera su estructura gobernada, sin sobrescribirlo (KIT-1 manda). |
| Resumen de la conversación | El cliente pidió "documentos gobernados que no se puedan/recomienden desviar de la original" (modelo SAP). Se midió el drift real (el ritual NO diverge; el hueco es el `CONTRIBUTING` sin template), se planeó con R0+arquitecto, se construyó, revisó y cerró con merge+release autorizados. |

## Verificación (el demo que corre el cliente) — owner: cliente · **PENDIENTE**

El Gemba lo corre el cliente sin código ni terminal: sembrar un hijo-fixture desechable, destripar su `CONTRIBUTING.md`, correr `/jidoka:arranca` → ver `[DESVIADO] CONTRIBUTING.md -- falta(n): El flujo` en la apertura. La evidencia técnica (el detector corriendo, demos A/B, caso enti) está en `qa_runs/documentos-gobernados-20260717/LOG.md`, pero el demo **sin terminal** lo cierra el cliente — queda como pendiente honesto, no cumplido.
