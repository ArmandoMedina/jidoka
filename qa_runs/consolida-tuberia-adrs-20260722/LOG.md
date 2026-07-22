# LOG — Consolidación de los dos sprints en un PR único (2026-07-22)

> Por orden del cliente: *"todos los cambios deben ir a un solo PR"* — las dos ramas
> (tubería + ADRs) fusionadas sobre `main` (v1.28.0) en `consolida-tuberia-adrs-20260722`.
> Evidencia de que la reconciliación quedó **verde de verdad**, no de palabra.

## Método reproducible

1. Fusionar 5 commits del sprint de ADRs + 2 commits de tubería sobre `main` v1.28.0 (FLU-1).
2. Resolver colisión de ADRs: renumerar 0050 → 0051 (tubería); ADRs 0045-0047 (nuevo, sistema configurable).
3. Unificar versión a `v1.29.0` en los 3 sitios SSOT (version.txt, package.json, tope del CHANGELOG).
4. Correr la suite completa de tests en `andon` (verificar, probar-adrs, probar-app, probar-flujo, gates, etc.).

## Qué se consolidó

Rama nueva desde `origin/main` (v1.28.0, ya con FLU-1 / PR #122). Encima:

- **5 commits del sprint de ADRs** (`f6dee34`→`524a33a`), sin los 2 de FLU-1 (ya en main).
- **2 commits de tubería** (`3e99a0d` fix + `ec5202d` sprint).

## Reconciliación aplicada

- **Colisión ADR 0050:** el sprint de ADRs conserva `0050-molde-unico-de-los-adrs.md`; la
  tubería se **renumeró 0050 → 0051** (`0051-tuberia-mapa-completo-por-convencion.md`),
  título, índice, CHANGELOG y récord de entrega actualizados.
- **Versión unificada `v1.29.0`** (`tools/version.txt`, `package.json`, tope del CHANGELOG).
- **CHANGELOG:** una sola sección `[1.29.0]` fusiona ADRs + tubería + el fix (7 bullets
  tipados, prosa 1/8 — dentro del contrato `[contrato-changelog]`).
- **HANDOFF:** reescrito a **1 «Dónde estamos»** (el PR consolidado) + 2 históricas
  (FLU-1 v1.28.0, app v1.27.0) = 37/120 líneas — dentro del contrato `[contrato-handoff]`.
- **Índices** de ADRs y de sprints reconciliados con el estado real (git gana).

## Resultados (esta máquina, 2026-07-22) — todo lo que corre el check `andon`

| Gate / suite | Resultado |
|---|---|
| `verificar.ps1` (contratos handoff/roadmap/changelog) | exit 0 (2 avisos no bloqueantes: atlas, barreras) |
| `probar-adrs` (guardián del molde, incluye la 0051) | 9/9 · corpus real: **51 ADRs conforman** |
| `probar-app` (censo tubería + fix de encoding) | 41/41 · **387 piezas = `git ls-files` exacto**, stdout sin BOM/sin ctrl chars |
| `probar-flujo` (contratos FLU-1) | 94/94 |
| `probar-version` | 1.29.0 consistente (version.txt = CHANGELOG = package.json) |
| `estado-docs` | 4 conforme / 0 desviado |
| `probar-gate` | 14/14 |
| `probar-hooks` | 47/47 |
| `probar-auditor` | 7/7 |
| `probar-disparos` | 4/4 |
| `probar-preflight` | 8/8 |
| `probar-docs` | 27/27 |
| `probar-ligas` | 25/25 |
| `probar-linterna` | 57/57 |
| `probar-bandeja` | 21/21 |
| `probar-ritual` | 19/19 |
| `probar-anti-pii` | 11/11 |
| `probar-sembrar` | 39/39 |
| `probar-publicar` | 7/7 (deriva el tag v1.29.0 del SSOT) |
| `probar-parametrizar` | 27/27 |
| `probar-override` | verde |
| `probar-agentes` | 44/44 |

**No corridos localmente:** `instalar.ps1` / `probar-instalador.ps1` — en cuarentena por el
AV (Bitdefender); el CI los corre limpio en `windows-latest`. No los tocó esta consolidación.

## Veredicto

Consolidación verde: 51 ADRs conformes, 387 piezas de la tubería censuadas, flujo reconciliado con v1.29.0. Listo para merge y release.

## Pendiente (del cliente)

- **Gemba** de ambos sprints sin terminal (ya aprobó la fidelidad de la tubería en 2 Gembas).
- **Merge del PR + release `v1.29.0`** — requiere **orden nombrada**.
- **Cerrar la PR #124** (ADRs) apuntando a este PR consolidado.
