# Gemba — Brownfield II: fallback anti-AV + auditor configurable (v1.10.0, ADR 0027)

Evidencia de aceptación del sprint (issues #40–#46). Fecha: 2026-07-13.

## Lo que se demuestra

- **[demo-fallback.txt](demo-fallback.txt)** — corrida REAL de los pasos de Verificación del cliente:
  1. `tools/sembrar-manual.ps1` siembra el motor completo (76 piezas) + la ley + el sello + `core.hooksPath`,
     **sin usar `instalar.ps1`** (el camino que el AV bloquea).
  2. `tools/estado-motor.ps1 -Jidoka <jidoka>` reporta **`[OK]` al día** — el fallback deja el mismo estado
     que el instalador.

## Suites verdes (prueba de vida)

Corridas en esta máquina (Windows 11 / PS 5.1) el 2026-07-13:

| Suite | Resultado | Cubre |
|---|---|---|
| `tools/probar-sembrar.ps1` | **24/24** | fallback: siembra, paridad del sello con `instalar.ps1`, no-clobber, tres vías, `-Actualizar` sin sello, degradación con gracia de `estado-motor` (con/sin `instalar.ps1` legible) |
| `tools/probar-auditor.ps1` | **7/7** | #42: sin `scanDirsExtra` un wikilink a `engineering/` bloquea (regresión); con el campo, resuelve |
| `tools/probar-instalador.ps1` | **51/51** | regresión: el instalador sigue sano con `sembrar-manual` como pieza de motor y la ley con el meta-entry |
| `tools/probar-gate` · `probar-hooks` · `probar-disparos` · `probar-version` | 10/10 · 17/17 · 4/4 · ok | muro + versión consistente (1.10.0) |

## Cosecha (regla 2-3, NO construida)

#41 (`doc-only`), #44 (`operacion`), #45 (gobernanza compuesta), #46 (prueba de vida) → registrados en
`ROADMAP.md` → *Tercera cosecha por el lazo*, esperando su 2º/3er uso real. Issues etiquetados `leccion` + `regla-2-3`.
