# Sprints — el índice-récord

> Una fila por sprint, con el **estado real** (no el deseado). El plan aprobado se archiva como `sprint-N-plan.md`; el récord de cierre como `sprint-N-<slug>.md` (plantillas en [`kit/.jidoka/templates/`](../../kit/.jidoka/templates/)).

| Sprint | Qué entregó | Estado |
|---|---|---|
| [0 — Esqueleto + identidad](../../CHANGELOG.md) | Doctrina embebida, sistema TPS, README, MIT, 12 disparos | Publicado (`v0.1.0-beta`) |
| [1 — El motor Andon](sprint-1-plan.md) | La ley, verificador fail-closed, self-test 6/6, hooks, CI con juez-desde-la-base | Mergeado (`v0.2.0-beta`) |
| [1.5 — Vitrina + centralización del conocimiento](sprint-1.5-plan.md) | Vitrina ES, lazo/jerarquía/roles/auditoría, ADRs de doctrina, templates, qa_runs, hardening ALTO-04 | Mergeado (`v0.3.0-beta`) |
| [2·A — El ritual ejecutable](sprint-2a-plan.md) | Los 5 comandos `/jidoka:*`, las 4 skills-asiento, área `ritual` en la ley, ADR 0006 (plan efímero) | Mergeado (`v0.5.0-beta`) |
| 2·B — Los muros (homologación) | `review-stop`, `gemba-stop`, auditor del grafo, `product_avisa`, avisos al PR (grieta 1); cosechados de los labs (ADR 0007) | Publicado (`v0.6.0-beta`) |
| 3·A — El instalador mínimo | `tools/instalar.ps1` (no-clobber, Windows-first, ADR 0008) + smoke | Publicado (`v0.7.0-beta`) |
| 3·B — Arquetipos ejecutables | Manifiesto ejecutable, 2 arquetipos (ADR 0009), 12 templates de producto | Publicado (`v0.8.0-beta`) |
| Homologación E1 — Jidoka superset | Asiento `devops`, modo desatendido, casting neutral+persona (ADR 0010) | Publicado (`v0.9.0-beta`) |
| Homologación E2 — Cosecha de SGI | Token neutral en la ley + 3 maduraciones a los asientos (ADR 0011) | Publicado (`v0.10.0-beta`) |
| [Brownfield II — fallback anti-AV + auditor configurable](sprint-brownfield-2-plan.md) | `sembrar-manual.ps1` (siembra sin instalador), `estado-motor` degrada con gracia, `scanDirs` del auditor configurables; cosecha #41/#44/#45/#46 (issues #40–#46) | Publicado (`v1.10.0`) |
| [Descubre — la capa de consultoría](sprint-descubre-plan.md) | `/jidoka:descubre` (entrevista de 3 nieblas, filtro Mom Test), campos del descubrimiento en el brief, kit portátil para la autoridad tercera, disparo `aprobacion-nombrada`, ruteo desde `planea` (ADR 0031) · [entrega](sprint-descubre-entrega.md) | Publicado (`v1.13.0`) · demo de campo pendiente |
| AV-seguro completo — `sembrar-manual` siembra la instancia entera | Stubs de instancia en el fallback AV-independiente, `probar-instalador`/`probar-sembrar` al CI, ADR 0027 enmendado (densidad, no nombre) — sesión 15-jul, plan efímero (su récord: PR #76 + CHANGELOG) | Publicado (`v1.14.0`) |
| [El juez falla cerrado — cosecha #6](sprint-juez-falla-cerrado-plan.md) | Preflight de `publicar.ps1` falla cerrado ante test ausente (#78), salvavidas `no-borres-el-motor` (#73, disparo 15.º, ADR 0032), receta `skip-worktree` (#79), `sembrar-manual` en el README (#74-R2), frontera Core vs familias (#71) | En construcción |

*(Hueco confesado: 2·B, 3·A y 3·B corrieron con plan efímero (ADR 0006) que no se archivó al cierre — sus récords son los PRs #7–#9 y los ADRs. Desde aquí, archivar el plan vuelve a ser paso del cierre.)*
