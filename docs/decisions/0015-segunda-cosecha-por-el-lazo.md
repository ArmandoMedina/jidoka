# ADR 0015 — Segunda cosecha por el lazo: el mecanismo probado en producción y las cuatro lecciones que suben

- **Estado:** aceptado
- **Fecha:** 2026-07-11

## Contexto

El [ADR 0012](0012-lazo-sincronizacion-labs.md) mecanizó el lazo labs↔Jidoka (*la lección sube, la máquina
baja*); el [ADR 0013](0013-primera-cosecha-por-el-lazo.md) fue la primera cosecha por el canal. En el
**Sprint B del programa hacia 1.0** el lazo dejó de ser diseño y **corrió en producción**: el núcleo
`0.13.0-beta` **bajó a los dos labs** por el mecanismo `-Actualizar` — **SGI** (`v2.6.0`) y **TF** (`v0.2.0`),
ambos mergeados, liberados y con **CI verde server-side** (el `audit` de blast-radius y el `gate-smoke`
pasaron en los PRs = el gate bloqueando de verdad en dos repos ajenos). La bajada preservó lo code-first sin
pisar una sola pieza. En el camino, el mecanismo **destapó cuatro refinamientos de sí mismo**. Esta cosecha
los registra; ninguno bloquea la 1.0 (son mejoras del lazo, no del criterio de *"corre en un repo ajeno"*).

## Decisión

Se registran cuatro lecciones que suben de Sprint B, **todas dispuestas como trabajo post-1.0** (backlog del
ROADMAP), con una parcheada reactivamente en los labs pero pendiente de generalizar en el núcleo:

1. **El sello inicial de un lab ya-divergido debe distinguir pristina-vs-customizada.** Defecto real y
   verificado: el sello de SGI (`tools/jidoka-motor.json`) había grabado sus piezas **code-first**
   (`verificar.ps1`, `auditar.ps1`, `probar-hooks.ps1`, `pre-push`…) como **semilla pristina** — como
   `childHash == seedHash`, un `-Actualizar` las habría clasificado "el hijo no lo tocó → actualiza" y las
   **habría pisado** con la versión genérica. Se **parcheó reactivamente** (SGI: quitar esas entradas del
   sello → quedan `child ≠ seed` ⇒ DIVERGE auto-sanante; TF: bootstrap de **semilla vacía**, máximamente
   conservador). Pendiente de **generalizar en `instalar.ps1`**: que crear el sello de un lab que ya divergió
   clasifique cada pieza (¿es la genérica de alguna versión de Jidoka, o customizada?) en vez de asumir pristina.

2. **`estado-motor.ps1` compara por versión declarada, no por hash.** Reporta "al día" mirando solo
   `version.txt` vs el sello; no *ve* la divergencia fina por-archivo. Falta una bandera `-Detallado` que
   liste, por-hash, qué piezas divergen — el aviso hoy es de grano grueso.

3. **Drift estructural núcleo↔labs.** El motor 0.13 **namespacea** los comandos (`.claude/commands/jidoka/*`)
   y trae skills genéricos; los labs convergieron (ADR 0006 de TF) a **comandos planos** + **skills-persona**
   (mariana/charbel/ahiram/armando/escribano — la autoridad la da la ley, no el nombre). El `-Actualizar` los
   marcó como piezas nuevas/divergentes y hubo que hacer back-out. No es error del lab: es que el núcleo
   drifteó de lo que los labs adoptaron. Reconciliar en el **diseño del lazo** (¿qué estructura es canónica?).

4. **Reconciliación del motor code-first vía costura `.local`.** verificar/auditar/probar-gate divergen por
   lenguaje (ruff/pytest en SGI, `-SoloDocGate`/node en TF). Hoy se **preservan** como divergencia honesta.
   La "mecánica igual" completa —motor genérico + `verificar.local.ps1` para lo del lenguaje— es una **épica
   post-1.0** (toca los 453 tests de SGI); la costura `.local` ya existe (ADR 0012), falta ejecutar la mudanza.

## Por qué

- **El lazo se probó con contenido, no con palabra.** Dos labs bajaron el núcleo por el mecanismo, con
  evidencia en CI y en sus `qa_runs/`. Un mecanismo que corre en producción y sobrevive es la única prueba
  que vale (*evidencia-no-palabra*).
- **La lección #1 es un defecto real que el uso destapó** — exactamente el valor del lazo: la fricción de
  campo sube y se arregla en la fuente, no se parchea en silencio en cada hijo.
- **Ninguna de las cuatro bloquea la 1.0.** El criterio (*el método corre e2e en un repo ajeno*) ya se
  cumplió; estos son refinamientos del propio lazo. Registrarlos con destino honra la regla 2–3 (madurar con
  evidencia) sin inflar el alcance del release.

## El camino que NO se toma (y por qué tienta)

- **Arreglar ya la generalización del sello (#1) en `instalar.ps1` dentro de este sprint.** Tienta porque el
  defecto es fresco, pero es **código de mecanismo nuevo con casos borde** (¿contra qué versiones históricas
  compara la clasificación?) y tests — riesgo que no pertenece a un release de declaración. El parche
  reactivo ya dejó a los dos labs seguros; la generalización espera su sprint.
- **Absorber la #3/#4 forzando a los labs al molde del núcleo (o al revés).** Cualquiera de las dos
  direcciones es una decisión de diseño del lazo con consecuencias en ambos lados; tomarla al vuelo, en un
  sprint de release, es cómo se rompe la "mecánica igual". Se registra para decidir con cabeza fría.
- **Dejar las cuatro solo en el HANDOFF.** El HANDOFF se limpia al abrir; una lección de mecanismo con
  destino a varios sprints necesita hogar permanente. Por eso es ADR + backlog del ROADMAP, no relevo.

## Consecuencias

- **El lazo queda validado como mecanismo de producción**, no solo de diseño: es el hallazgo que habilita
  declarar la 1.0 (ver [ADR 0017](0017-jidoka-1.0.md)).
- Quedan **cuatro entradas en el backlog del ROADMAP** con contexto para retomarse sin re-explicación: la
  generalización del sello, `estado-motor -Detallado`, la reconciliación del drift estructural, y la épica
  `.local` code-first (que subsume la vieja "convergencia profunda del gate de SGI").
- Evidencia de la cosecha: SGI PR #58 (7/7 checks) + TF PR #7 (5/5 checks) verdes; sellos de ambos labs a
  `0.13.0-beta`; `qa_runs/2026-07-11-*` en cada lab. Versión `v1.0.0`.
