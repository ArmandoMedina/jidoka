# Sprint — Especificacion de los dos tableros

> Plan aprobado en plan mode el 2026-07-22. **Este plan ES el sprint**: lo que no está aquí, no entra (se anota abajo en "Lo que NO entra").

## Contexto (por qué)

La app de la tubería va a tener **dos modos**: **Operar** (el tablero andon — anomalías en tiempo presente, paros, relojes; silencioso cuando todo está bien) y **Configurar** (diseñar la línea — áreas, gates, contratos, parámetros por documento). El material crudo para especificarlos existe (los 4 escaneos de `docs/analisis/escaneo-camino-2.0-202607.md`, los benchmarks, la investigación de prácticas andon/red-rabbit/A3 del 2026-07-22) pero está disperso; construir la ola de UI sin la spec consolidada repetiría el patrón de superficies que el Gemba luego reprueba. Además el cliente está en sobreproducción: este sprint entrega **papel en lotes chicos** — cada rebanada deja un artefacto juzgable en ≤10 minutos.

## Encuadre de producto (validado con el cliente)

El dueño gana el plano aprobado de su superficie de gobierno: sabrá exactamente qué verá al operar la línea (qué se enciende, qué calla, qué reloj corre) y qué podrá configurar (qué parámetros tiene cada documento y cómo se asignan), antes de pagar una sola hora de construcción. Hipótesis marcada: que el modo Operar drena la sobreproducción del dueño — se valida cuando la pantalla exista, no en este sprint.

## Decisiones del cliente

- 2026-07-22 — La superficie del gobierno es la app; dos modos: Operar (andon, default al abrir) y Configurar (la línea). No se mezclan.
- 2026-07-22 — Este sprint es solo de especificación y backlog: nada de ejecución de producto.
- 2026-07-22 — La maqueta ES la spec (precedente del sprint 20, ADR 0048): las especificaciones se entregan como maquetas HTML de doble clic + una página de doc.
- 2026-07-22 — El R0 se aprobó con 5 rebanadas (inventario de señales, exploración de variantes, spec Operar, spec Configurar, backlog reorganizado), apetito 5h.

## Alcance (rebanadas verticales)

1. **R1 — Inventario de señales** (`docs/analisis/senales-tableros-202607.md`): tabla señal → fuente real (archivo/gate que la produce hoy) → dueño → reloj → tablero. Señal sin fuente real se marca `requiere mecanismo nuevo` (caso conocido: los paros de los Stop hooks no persisten en ningún ledger — se especifica el hueco, no se construye). Checkpoint del cliente: leer la tabla.
2. **R2 — Exploración visual**: 2–3 variantes de portada del modo Operar como bocetos HTML de doble clic (marcados BOCETO, no spec) + media página de referencias de tableros andon reales. Checkpoint del cliente: elegir la variante; las descartadas quedan marcadas.
3. **R3 — Especificación del tablero Operar** (`docs/analisis/maqueta-andon-202607.html` + 1 página): sobre la variante elegida; cada señal dibujada cita su fila del inventario R1; toggle de estado simulado (sano = portada casi vacía; con anomalías = señales con dueño y reloj).
4. **R4 — Especificación del tablero Configurar** (`docs/analisis/maqueta-configurar-202607.html` + 1 página): las pantallas existentes (tubería, bandeja, formulario, avanzado) mapeadas al modo + los 4 ledgers consolidados por documento + parametrizar secciones de verdad + la propiedad «última validación del dueño» + el puente Operar→Configurar.
5. **R5 — Backlog reorganizado** (`ROADMAP.md`): cada ítem de la ola de UI declara tablero, apetito y dependencia; los que las specs absorben se funden. Gate `[contrato-roadmap]` verde.

## Archivos

- Nuevos: `docs/analisis/senales-tableros-202607.md`, `docs/analisis/boceto-andon-{a,b,c}-202607.html` (R2), `docs/analisis/maqueta-andon-202607.html`, `docs/analisis/maqueta-configurar-202607.html`, este plan y su fila en `docs/sprints/README.md`.
- Editados: `ROADMAP.md` (R5).
- NO se tocan: `app/`, `tools/*.ps1`, hooks, la ley. Solo áreas de documentación (`analisis`, `raiz`, `sprints`).

## Verificación (el demo que corre el cliente) — `owner: cliente`

**Cómo lo corre (sin código ni terminal):**

1. Doble clic a `docs/analisis/maqueta-andon-202607.html` → con el estado sano la portada se ve casi vacía; activando el toggle de anomalías se encienden las señales, cada una con su dueño y su reloj.
2. Señalar cualquier elemento de las dos maquetas y preguntar «¿de dónde sale este dato?» → la spec o el inventario nombran el archivo o gate real que lo produce; si no lo nombran, se rechaza.
3. Abrir `ROADMAP.md` → cada ítem de la ola de UI dice su tablero, su apetito y qué va antes de qué.
4. Cada rebanada dejó un artefacto juzgable en ≤10 minutos.

> **Regla del demo tangible:** si el cliente no puede correr el demo **sin código ni terminal**, la rebanada **no es vertical** — re-rebánala hasta que entregue algo que él pueda tocar, o márcala como decisión pendiente del cliente (no la cierres con una demo de terminal que solo tú puedes correr). Nace aquí y se cierra idéntico en la entrega: es el criterio de aceptación del sprint.

## Lo que NO entra (siguientes)

- Ninguna pantalla real de la app ni script nuevo: el ledger de eventos de paro **se especifica** (R1/R3), no se construye.
- Investigación adicional de internet — el material ya existe; más sería sobreproducción.
- El ritual de Gemba nuevo (guion del dueño + conejo rojo): ítem propio del backlog, fuera de este sprint.
- La etiqueta «2.0» y cualquier release: este sprint entrega papel.
