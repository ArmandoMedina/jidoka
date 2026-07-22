# LOG — Gemba FLU-1 (el pilar de flujo)

- **Fecha:** 2026-07-22
- **Rama:** `consolida-tuberia-adrs-20260722`
- **Incremento:** `flu-1-pilar-de-flujo` (entregado en `v1.28.0`, PR #122; su Gemba quedó pendiente de aceptación desde 2026-07-21).
- **Método reproducible (sin código para el cliente — doble clic / abrir archivo):**
  1. Abre `HANDOFF.md` y `ROADMAP.md` — cada uno cabe en una pantalla.
  2. Abre `docs/MUERTOS.md` — el cementerio del roadmap existe.
  3. Abre `.jidoka/reporte-avance.html` con doble clic — se entiende en 5 min, sin jerga.
  4. Abre `product/casting.md` — responde quién hace qué.
  5. (Ya visto en vivo) `/jidoka:planea` se plantó por este mismo Gemba.

## Evidencia (artefactos de la corrida, no palabra)

| # | Caso | Check | Resultado |
|---|---|---|---|
| 1 | HANDOFF y ROADMAP caben en pantalla | `verificar.ps1` mide contra techo de `flujo.json` | **HANDOFF 37/120 · ROADMAP 65/90** ✓ |
| 2 | `docs/MUERTOS.md` existe (lo vencido muere solo) | Archivo presente, cabecera cita `expirar.ps1` + `vencimiento_dias` | **existe, 0 entradas** (estéril, previsto) ✓ |
| 3 | La expiración es máquina, no prosa | `tools/expirar.ps1` presente: "el circuit breaker del ROADMAP… muere por script" | **existe** ✓ |
| 4 | `reporte-avance.html` se entiende en 5 min | Generado desde `tools/reporte-avance.ps1` (pipeline real); 5 secciones en lenguaje llano | **generado, 83 líneas** ✓ |
| 5 | `casting.md` responde quién hace qué | `product/casting.md`, tabla "Los asientos-agente" (4 filas) | **4 asientos declarados** ✓ |
| 6 | Los 4 asientos piensan distinto | `.claude/agents/`: tiers y propósitos distintos | **haiku·haiku·sonnet·opus, 4 cartas distintas** ✓ |
| 7 | `planea` se planta por este Gemba (límite WIP) | Corrido en vivo 2026-07-22: `[BLOQUEA] Gemba pendiente… flu-1-pilar-de-flujo` | **se plantó** ✓ |

**Suite automática (7/7 de los criterios objetivos verificados).** Lo subjetivo — "¿se ve bien el reporte?, ¿el HANDOFF se lee de un vistazo?" — lo pone el cliente con sus propios ojos.

## Las 5 secciones del reporte de avance (lenguaje llano, cero jerga)

`Qué se terminó` · `En qué vamos` · `Qué espera una respuesta` · `Qué se descartó` · `Qué sigue`
(traduce "gate"→"control automático", "WIP"→"límite de trabajo abierto", etc. — `reporte-avance.ps1`)

## Veredicto

**ACEPTADO para continuar (2026-07-22)** — veredicto nombrado del cliente: *"yo lo veo bien para continuar"*, con dos reservas diferidas (no se arreglan ahora, encoladas al backlog):

1. El `reporte-avance.html` (reporte para terceros) **no le gustó** → rework en ROADMAP (`[alta:2026-07-22 · apetito:2h]`).
2. El casting nuevo **no lo ha visto operar en la práctica** (sabe que el MD existe) → validación en ROADMAP (`[alta:2026-07-22 · apetito:1h]`).

Booleano movido: `estado.gembas_pendientes[flu-1-pilar-de-flujo].aceptado = true` + `aceptado_fecha: 2026-07-22` en `tools/flujo.json` → **desbloquea `/jidoka:planea`**. Las reservas son follow-ups, no rechazos: el pilar queda aceptado.
