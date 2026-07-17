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
| [El juez falla cerrado — cosecha #6](sprint-juez-falla-cerrado-plan.md) | Preflight de `publicar.ps1` falla cerrado ante test ausente (#78), salvavidas `no-borres-el-motor` (#73, disparo 15.º, ADR 0032), receta `skip-worktree` (#79), `sembrar-manual` en el README (#74-R2), frontera Core vs familias (#71) | Publicado (`v1.15.0`) |
| [Conciencia del agente — reconstrucción limpia](sprint-conciencia-del-agente-plan.md) | Agentes-asiento tiereados (#63, ADR 0033), reframe rol-teatro + payload inyecta-directo en `arranca` (ADR 0034), split `PRODUCT_BRIEF.md`/`infra.md` (#75) | Publicado (`v1.16.0`) · demo del cliente pendiente |
| [La bajada que dolió — cosecha #7](sprint-cosecha-7-plan.md) | La conciencia viaja al kit (agentes + stubs de instancia + `-Actualizar` migra, #86/#87/#82), el juez sin hueco (#88), guard de stubs (#89), costura `ci.local` (#90), nits del sello (#91) — cosecha de la bajada real 1.13→1.16 en el caso 1 | Publicado (`v1.18.0`) · demo del hijo de práctica pendiente |
| [El atlas dice la verdad](sprint-atlas-fiel-plan.md) | Auditoría de fidelidad de los 24 diagramas AS-IS contra su fuente real (14 fieles, 10 desviados); cura del insignia 10-arranca, la ruta AV-segura dibujada, las omisiones de lógica del método, informe durable en `docs/analisis/` | Publicado (`v1.20.0`, PR #101) |
| [Cierre 2026-07-17 — El ritual determinista](cierre-20260717.md) | Sin sprint formal: ADR 0039/0040, `asientos.ps1` (casting del artefacto), atlas Method & Style (end states de 10/12/15/17 leídos por el 01), planea con 2 STOPs + póliza `@`, el cuadro de cierre versionado (estrena con este) | PR #103 abierto · merge y release (v1.21.0) pendientes de orden |
| [Documentos gobernados — gobierno por estructura (SAP)](sprint-documentos-gobernados-plan.md) | Ledger capa-1/2/3 (`docs-gobernados.json`), detector de conformidad de secciones `estado-docs.ps1` (hermano de `estado-motor`; aviso + muro CI opt-in), template real de CONTRIBUTING; el grafo se queda con `auditar` (ADR 0042) | En curso |

*(Hueco confesado: 2·B, 3·A y 3·B corrieron con plan efímero (ADR 0006) que no se archivó al cierre — sus récords son los PRs #7–#9 y los ADRs. Desde aquí, archivar el plan vuelve a ser paso del cierre.)*
