# Sprint — El editor del gobierno, parte 2 (R2–R4) · Entrega

> El récord del sprint (`v1.25.0`, ADR 0044). Plan-contrato: [sprint-19-editor-gobierno-2-plan.md](sprint-19-editor-gobierno-2-plan.md) (aprobado en plan mode 2026-07-20). R1 viajó aparte en el PR #114.

## Objetivo

*El usuario declara, desde una interfaz visual, qué código sostiene qué capacidad — con qué fuerza y en qué dirección — sin editar JSON a mano.* Métrica: el aviso pasa de "las 89 capacidades" a **la exacta**.

## Decisiones

- **ADR 0044** — la extensión AUTORA, el gate EJECUTA (la línea doctrinal; ADR 0002 intacto).
- `ligas.json` **NO se siembra** (dato de instancia; `-Actualizar` pisaría las declaraciones del hijo) — matiz al contrato, declarado en el plan.
- `upsert` **reemplaza** capacidades (la selección del QuickPick es el estado final) — cambió en review: unir hacía mentir a la deselección.
- La dirección de `vigila` se **invirtió** (sale del gate): con flechas visibles, "el área vigila al gate" leía mentira.
- Ligas rotas: **aviso siempre, nunca bloqueo** (un medidor podrido no emite veredicto).
- Nomenclatura (re-Gemba): el comando se estrechó a **"ligar código a capacidad..."** (opción a del cliente); la opción b ("ligar" genérico de las 3 relaciones) quedó en ROADMAP con regla 2-3.

## Qué se entregó

- **R2:** `tools/ligas.json` + `tools/estado-ligas.ps1` (co-ocurrencia por dirección/fuerza, `-Estricto`, falla cerrado, matcher byte-fiel) + `probar-ligas.ps1` (27 casos). Cableado: pre-push, preflight, smoke, **CI desde la base** (ADR 0003). Liga dogfood inicial.
- **R2c:** la linterna pinta las ligas (nodo `liga:<id>`, aristas tipadas, rotas en rojo).
- **R3:** `extension/ligas.js` (módulo sin `vscode`, UTF-8 sin BOM) + comandos ligar/quitar (QuickPicks, menú contextual, refresco del grafo) + contrato JS↔PS probado.
- **R4:** `.vsix` empaquetado + guía (`extension/README.md`), ADR 0044 + índice, CHANGELOG/SSOT `1.25.0`, `andon/README`, AND-1 extendida.
- **Fuera de plan — rework del Gemba del cliente (7 hallazgos + addendum):** flechas con grosor por fuerza, anillo rojo del `doc_bloquea` en Foco, etiquetas legibles, fit-to-viewport, Clusters separado, sueltos anotados, la tabla del gobierno, modo **Reparto** (treemap por capa de cobertura).

## Evidencia (review)

Dos code-reviews adversariales independientes: el del sprint (**APROBADO CON REPAROS** — 3 MEDIO + 5 BAJO curados con regresión) y el del rework (**"NO mergear tal cual"** — cazó el anillo invisible A1 que la suite no vio; curado + asserts endurecidos). Suite completa `publicar -SoloVerificar` **14/14 + auditar** · `probar-ligas` 27/27 · `probar-linterna` **58/58** · `probar-extension` 16/16 · CI verde en cada push. Corrida: [`qa_runs/editor-r2r4-20260720/LOG.md`](../../qa_runs/editor-r2r4-20260720/LOG.md) (committeada).

## Hallazgos de la data real

1. **La liga dogfood mordió en su propio sprint** (dos veces): acusó `extension/*` y `estado-gobierno.ps1` sin su capacidad, **nombrándola** — la métrica del QUÉ demostrada por su propia maquinaria.
2. **El Gemba del cliente encontró lo que ningún review de código vio**: la dirección tirada al pintar, la severidad invisible en Foco, la mancha de etiquetas, los nodos fuera de pantalla, la cercanía leída como relación, Clusters sin cumplir su promesa, y "ligar" prometiendo de más. Uso real ≠ lectura de código.
3. **Un assert de presencia no caza una rotura de render**: la suite estuvo verde con el anillo rojo invisible (el CSS pisa los atributos SVG). Los asserts ahora cruzan dato con render.
4. **El cajón `raiz` (fuente `*`) hace gratis el "cero huérfanos"**: mide "nada se escapó", no "todo tiene lugar pensado". Decisión de estrecharlo: pendiente del cliente, con el treemap como instrumento.

## Verificación (el demo que corre el cliente) — `owner: cliente`

El cliente corrió el Gemba en VS Code (F5, sin código ni terminal) **dos veces**: la primera produjo los 7 hallazgos + addendum (los 3 modos, la severidad, las etiquetas, el viewport); la segunda, sobre el rework, produjo el hallazgo de nomenclatura y cerró con la orden *"pr, marge, versión y poda"* — el "está todo bien" que él mismo puso como condición. ✔ Cumplida en sus términos.

## Pendiente que dejó

- [ ] Bajar `v1.25.0` a los labs con `-Actualizar` (entisoft no puede usar el gate de ligas sin `estado-ligas.ps1`; la extensión es Jidoka-only, la mecánica sí baja).
- [ ] Decisión del cliente: ¿estrechar el área `raiz`? (el treemap del modo Reparto es el instrumento; cola del HANDOFF).
- [ ] Opción (b) de nomenclatura: "ligar" genérico de las 3 relaciones — ROADMAP, regla 2-3.
- [ ] Deuda compartida anotada: `Out-File -Encoding ascii` en los steps desde-la-base (mojibake teórico en rutas con acento) · conteo del reparto case-insensitive (B2).
- [ ] El Gemba visual de entisoft (`gobierno-entisoft.html`) sigue esperando ojos del cliente.

## Lo aprendido (Kaizen)

1. **El Gemba del cliente es un detector distinto al code-review** — encontró 8 hallazgos reales que dos reviews adversariales no tocaron; ninguno era de lógica, todos de *uso*.
2. **Gemba de rama en vuelo → rework, no issues**: abrir #116–#118 a mitad del Gemba fue tratar masa en el horno como cosecha; el cliente lo corrigió y se absorbieron.
3. **Los asserts deben cruzar dato con render** — presencia de texto dio verde sobre una feature rota en el navegador.
4. **El nombre de un comando es contrato**: "ligar" prometía tres relaciones y entrega una; estrechar el nombre costó 1 línea, la honestidad no espera al sprint que ensanche la mecánica.
5. **El gate granular se pagó solo en su primer sprint**: cada push del rework recibió el aviso nombrando la capacidad exacta — la fatiga de "revisa las 89" murió donde nació.

## Cuadro de cierre

| Hecho | Valor |
|---|---|
| Sprint · ¿terminó? | "El editor del gobierno, parte 2" (R2–R4) — **TERMINADO** (con R1 del PR #114, el sprint del editor queda completo) |
| Rebanadas: planeadas / entregadas / desviadas | 3 del plan (R2, R3, R4 como 6 commits C1–C6) / **3 entregadas** / 0 desviadas + **2 rondas de rework del Gemba fuera de plan** (7 hallazgos + nomenclatura) |
| Rama · commits | `sprint/editor-gobierno-2-20260720` · 10 commits al cierre (C1–C6 + Gemba-docs + rework + curas-review + nomenclatura/cierre) |
| Working tree al cerrar · duración | Limpio tras el commit de cierre · un solo día (2026-07-20, sesión continua) |
| PR · ¿rama eliminada? | **#115 mergeado** con orden nombrada *"pr, marge, versión y poda"* · rama podada |
| Ritual corrido | `planea` (plan mode formal, STOP 2 aprobado) → construcción por rebanadas → 2× Gemba del cliente → rework → `cierra`. `arranca` no corrió (la sesión venía del cierre anterior; hueco declarado). |
| Delegaciones | Explore (cableado) · Plan (diseño fino) · 2× general-purpose (code-reviews adversariales) · el hilo construyó 🎭 (asientos mecanico/auditor no ameritaban el tamaño del diff — excepción acusada) |
| Aprobaciones nombradas | Plan aprobado en plan mode (2026-07-20) · *"resuelvas todo de una vez y ya mergeamos cuando ya vea que está todo bien"* (rework) · *"agrega esto y ya corres /jidoka:cierra autorizado pr, marge, versión y poda"* (cierre) |
| Pruebas: altas / cambios / bajas · suites | **Altas:** `probar-ligas.ps1` (27), `ligas.test.js` (9) · **cambios:** `probar-linterna` +14 (58), `probar-extension` +7 (16) · **bajas:** 0 · suite completa **14/14 + auditar** |
| E2E | El Gemba humano 2× (F5 → comando → grafo → clic derecho); harness automatizado de webview no existe (límite declarado desde R1) |
| Evidencia en `qa_runs/` | `qa_runs/editor-r2r4-20260720/LOG.md` — citada y **committeada con `git add -f`** |
| Archivos | ~12 creados (evaluador, test, módulo JS, test JS, ADR, entrega, guía…) · ~15 editados · 0 eliminados |
| Gates | `verificar` exit 0 (avisos no-aplicables acusados: render sin cambio de proceso) · `probar-gate` 14/14 · anti-PII limpio · **la liga dogfood avisó 2× nombrando AND-1** (1× cura real, 1× caso no-aplica) · CI verde en 4 corridas |
| ¿Compactación? | Sí (sesión larga); se re-verificó contra artefactos al retomar (transcript → tests → corridas) |
| ADRs | **0044** creado + listado en índice (mismo commit) — saldó además la deuda de 3 archivos que ya lo citaban sin que existiera |
| CHANGELOG · versión | `1.25.0` cerrado · **MINOR** (agrega gate + autoría; nada rompe) · `v1.24.0` queda **sin tag propio a propósito** (subsumida — decisión del cliente al autorizar "versión" tras la alternativa registrada) |
| Motor | Nave nodriza — SSOT `1.25.0` |
| Issues | #116–#118 abiertos y **cerrados en la misma sesión** (error de proceso del agente, corregido por el cliente: Gemba de rama en vuelo no va al tracker) |
| Fricción y errores (Kaizen crudo) | **Correcciones del cliente al agente: 2** (issues prematuros; "ligar" promete de más) · **errores del agente: 2 reparados** (anillo invisible con suite verde — cazado por el 2º review; asserts de presencia) · el commit con comillas dobles en PS falló 1× (rehecho vía bash) |
| Pendientes al HANDOFF | Bajada a labs · decisión `raiz` · opción (b) nomenclatura · deuda ascii/case · Gemba visual entisoft · release de esta versión (ejecutado en este cierre) |
| Resumen de cambios | El gate granular código↔capacidad completo (ledger + evaluador + CI desde la base), la extensión que lo autora con clic derecho, la linterna con 4 modos legibles (flechas, severidad, tabla, treemap), `.vsix`, ADR 0044, `v1.25.0`. |
| Resumen de la conversación | El cliente validó R1 (F5), aprobó el plan de R2–R4 en plan mode, corrió 2 Gembas que produjeron 8 hallazgos de uso real + 1 de nomenclatura, corrigió el proceso del agente (issues → rework), y cerró con orden nombrada de pr/merge/versión/poda. |
