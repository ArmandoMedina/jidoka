---
tipo: analisis
estado: en_revision
---
# Costo neto del método en SimGhostInputs — primer pase manual (issue #72)

> **Qué es esto:** el análisis puntual que pidió el issue [#72](https://github.com/ArmandoMedina/jidoka/issues/72) — sobre evidencia existente, sin maquinaria nueva. Reconstruye 1-2 sprints cerrados del lab real (SGI, junio-julio 2026) y responde las 6 preguntas del issue. **Es un primer pase con limitaciones explícitas** (al final); sus números son reconstruibles por cualquiera desde los artefactos citados.

## La evidencia, en una tabla

| Señal | Número | Fuente |
|---|---|---|
| Corridas del muro server-side (`tests.yml`, historial completo) | **206** (185 verdes · 21 rojas ≈ 10 %) | GitHub Actions, repo SGI |
| Bloqueos REALES del gate de doc-drift (`audit`) antes del merge | **3** (PRs #59, #22, #19 — dos veces el mismo patrón `ui` sin `guia-usuario.md`) | check-runs de los PRs |
| Tiempo de vuelta al verde tras un rojo | **2–8 min** en 7 de 9 ramas con rojos | timestamps de los runs |
| Ramas que nunca pasaron el muro | 2 (abandonadas; su contenido llegó a `master` por otra vía **ya en verde**) | PRs #13→#15, #42→#45 |
| Muro infranqueable | ruleset "Protect master": 7 checks required, `bypass: never`, ni admin | API rulesets |
| ADRs acumulados en SGI | **38** (7 de los últimos 30 commits citan ADR) | `docs/decisions/`, git log |
| Falsos positivos del gate documentados | **1** (DIVERGE por CRLF → subió como lección → ADR 0021 en Jidoka lo curó de raíz) | `qa_runs/actualizar-jidoka-1.4-20260711/RESUMEN.md` |
| Avisos (`AVISA`) ignorados y mergeados | **1 confirmado** (PR #58, área `orquestacion`) | diff del PR vs aviso |
| Costo doc por commit de código sustancial | commit `aa63e41`: 3 archivos de código → **9 ADRs + 6 docs dueños** | git log --name-only |
| Actualizaciones del motor en un solo día | **3** (0.13.0-beta→1.4.0→1.7.1→1.9.0), cada una con ~8-10 archivos de verificación | `qa_runs/actualizar-*`, sello |
| Issues del lazo abiertos DESDE SGI | **0** (3 lecciones draft locales sin presentar; el canal `reportar-leccion` sin un solo uso) | gh issue list, `qa_runs/lazo-sync-20260711/` |

## Las 6 preguntas del issue

1. **¿Qué bloqueó o avisó?** 21 corridas rojas server-side: 3 fueron el gate de doc-drift (`audit` — el diferenciador de Jidoka; el resto lint/pytest, que existirían sin el método). Local: los bloqueos del pre-push/hooks **no dejan rastro** (hueco de medición, ver limitaciones). 1 `AVISA` ignorado que mergeó igual.
2. **¿Cuáles hallazgos eran accionables?** Los 3 `BLOQUEA` de doc-drift: los tres se corrigieron y el PR mergeó con la doc sincronizada. El `AVISA` ignorado sugiere que **el aviso sin dientes se ignora** (consistente con la doctrina: solo el bloqueo es muro).
3. **¿Cuánto trabajo evitó?** Reconstruible con confianza: 3 merges con docs desincronizadas evitados; un `-Actualizar` entero que habría marcado DIVERGE falso en cadena, evitado al cazar el bug CRLF (se descartó un intento y la cura subió a Jidoka — el lazo completo funcionó una vez, de punta a punta). El HANDOFF de SGI retomó sesiones sin re-explicación a lo largo de 40+ PRs.
4. **¿Cuánto tiempo agregó?** **No cuantificable en horas** (ningún artefacto mide duración — la limitación más gorda). Proxies honestos: 2–8 min por vuelta al verde tras un rojo; 9–15 archivos de doc por commit de código sustancial; ~10 artefactos de verificación por bajada de motor, ×3 en un día. El costo dominante visible NO son los gates: es la **ceremonia del lazo** (actualizar el motor, reclasificar piezas code-first a mano cada vez) y la doc obligada por commit.
5. **¿Qué habría pasado sin Jidoka?** Contrafactual — se declara como inferencia, no como dato: los 3 doc-drifts habrían mergeado (la guía de usuario mintiendo sobre la UI dos veces); el DIVERGE falso habría ensuciado cada actualización futura; y los 38 ADRs no existirían como memoria consultable (7/30 commits los citan: se usan, no son adorno).
6. **¿Qué controles no aportaron en el periodo?** Cuatro con señal de cero uso — candidatos a poda, simplificación o prueba de vida (#46), no a fe:
   - **`docs-graph`** (auditor del grafo): 0 fallos en todo el historial muestreado — o el grafo siempre estuvo sano, o el gate nunca tuvo oportunidad de morder. Indistinguible sin prueba de vida.
   - **La plantilla `sprint-entrega.md`**: 0 usos en SGI (la entrega se reconstruye de HANDOFF+CHANGELOG+qa_runs). El kit prescribe un artefacto que su lab estrella no ocupa.
   - **El canal `reportar-leccion.ps1`**: 0 issues generados desde SGI (las lecciones subieron, pero por las sesiones del autor — el canal formal no se usa; 3 drafts locales llevan días sin presentar).
   - **El summary de avisos en el PR ("grieta 1 cerrada")**: el `andon/README.md` de SGI lo afirma, pero **no está implementado ahí** (el back-out de `andon.yml` se llevó la pieza y nadie ajustó la prosa; `output.summary = null` en los check-runs, cero `GITHUB_STEP_SUMMARY` en el repo). Doc que promete lo que la config no hace.

## Veredicto (primer pase)

**El muro server-side paga su costo con margen**: es barato (minutos por rojo), infranqueable de verdad, y sus 3 mordidas de doc-drift son exactamente el defecto que el método existe para frenar. **El costo dominante está en el lazo y la ceremonia**, no en los gates: bajadas de motor repetidas con verificación manual, reclasificación de piezas code-first, y doc obligada cuyo volumen supera al código en los commits sustanciales. Y hay **cuatro piezas sin señal de vida** que este análisis pone sobre la mesa para la decisión que el issue #72 anticipó: *"un gate correcto pero demasiado caro puede ser un mal producto"* — medir también puede justificar podar.

## Limitaciones explícitas

- **Sin horas-persona/agente**: ningún artefacto registra duración; todos los "cuánto costó" son proxies de conteo, no de tiempo.
- **Los bloqueos locales son invisibles**: pre-push y Stop hooks no dejan log persistente — el numerador del valor local está subcontado (conecta con #66, telemetría).
- **Un solo lab, operado por el autor del método**: nada aquí mide transferibilidad (eso es #70, el piloto independiente).
- **Los contrafactuales (pregunta 5) son inferencia**, marcados como tal.
- **Cobertura parcial de las 21 rojas**: 11 de 21 desglosadas por job; la caracterización de la rama `worktree-agent-*` es muestra, no censo.
- Corte de la evidencia: **2026-07-16**, SGI en motor `1.9.0` (commit `158097e`); lo posterior no existe para este análisis.

## Qué seguiría (si el segundo caso lo amerita — regla 2-3)

Una segunda medición real (otro lab u otro periodo) decidiría qué señales vale la pena instrumentar de forma permanente (#66) y qué piezas de las cuatro sin uso se podan, se simplifican o ganan prueba de vida (#46). Este documento NO propone construir nada todavía.

## Qué debe revisar el dueño (guion)

Guion para la épica «converger el `verificar` de SGI a motor genérico sin romper sus 453 tests»:

1. **Verifica el costo que motiva la convergencia.** Abre la pregunta «¿Cuánto tiempo agregó?» y el Veredicto: el costo dominante **no son los gates**, es «la ceremonia del lazo — reclasificar piezas code-first a mano cada vez». Confirma que ese trabajo manual repetido es lo que la convergencia busca borrar.
2. **Decide el criterio de éxito.** La convergencia debe pasar el `verificar` de SGI a motor genérico **sin romper sus 453 tests**. Decide: ¿se acepta solo si los 453 siguen en verde en la suite de SGI, o toleras un delta declarado y firmado? Sin ese número como gate, la convergencia se auto-firma.
3. **Ojo con el muro que sí paga.** Verifica que el muro server-side de SGI («Protect master»: 7 checks required, `bypass: never`) sigue infranqueable tras converger. Recházalo si el motor genérico afloja un check required: es el único muro que de verdad muerde al ajeno.
4. **Decide la poda de las piezas sin vida.** La pregunta de uso lista piezas con **0 uso** en SGI. Por cada una decide: poda, simplifica o dale prueba de vida (#46). No conviertas en genérico un control que su lab estrella no ocupa.
5. **El criterio de decisión.** Si pesa más «bajar el costo de ceremonia» → converge y poda agresivo. Si pesa más «no perder el muro que sí paga» → converge solo lo que preserve los 453 tests y el ruleset intactos. Ten presente la limitación del informe: primer pase, sin horas medidas — todo «cuánto costó» son proxies de conteo.
