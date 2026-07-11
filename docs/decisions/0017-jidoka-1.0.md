# ADR 0017 — Jidoka 1.0.0: el criterio de "corre en un repo ajeno", cumplido con evidencia

- **Estado:** aceptado
- **Fecha:** 2026-07-11

## Contexto

El ROADMAP fijó desde temprano una vara única y verificable para la 1.0 (línea 58):
*"Candidato a `v1.0` cuando el método completo corra end-to-end en un repo ajeno."* Toda la beta (0.1→0.13)
construyó hacia eso. El **programa hacia 1.0** (tres sprints) lo remató:

- **Sprint A** (`v0.13.0-beta`, [ADR 0014](0014-listo-para-1.0.md)): cerró los cuatro bloqueantes duros —el
  instalador pregunta el arquetipo, el método se siembra completo (fin de los enlaces muertos), el fixture
  del quickstart, y la guía `empezar-de-cero.md`.
- **Sprint B**: el núcleo bajó a **dos repos ajenos reales** por el lazo — **SGI** (`v2.6.0`, Python/450+
  tests) y **TF** (`v0.2.0`, JS/PWA vanilla). No fue teatro: los PRs pasaron **CI verde server-side** — el
  `audit` de blast-radius y el `gate-smoke` bloqueando de verdad, los self-tests sembrados verdes, evidencia
  en el `qa_runs/` de cada lab. La bajada preservó lo code-first sin pisar una pieza ([ADR 0015](0015-segunda-cosecha-por-el-lazo.md)).

La vara está satisfecha, **con evidencia, no con palabra.**

## Decisión

**Se declara Jidoka `v1.0.0`.** El alcance es **1.0 funcional**: el método —doctrina + ritual + motor Andon +
instalador + lazo de sincronización— corre end-to-end en repos ajenos, en dos lenguajes y dos arquetipos
(code-first Python y JS), con el gate bloqueando server-side. `tools/version.txt` pasa a `1.0.0` (sin sufijo
`-beta`); el CHANGELOG corta `[1.0.0]`.

## Por qué

- **El criterio era explícito y se cumplió con evidencia reproducible.** No es un "se siente listo": son dos
  PRs verdes en repos públicos distintos, con CI que bloquea, self-tests que pasan, y `qa_runs/` commiteados.
  La 1.0 se **gana**, no se declara por calendario.
- **Dos labs, dos lenguajes, dos arquetipos.** SGI (code-first Python) y TF (code-first JS/PWA) ejercitan el
  método en condiciones genuinamente distintas; que ambos corran el mismo núcleo prueba que la mecánica es
  portable y la divergencia (estética/lenguaje) está contenida y es honesta.
- **Salir de `-beta` es un contrato.** Declarar 1.0 compromete estabilidad de la mecánica y del instalador
  para quien lo adopte; el programa produjo la base para sostener ese contrato (self-tests, lazo, guía).

## El camino que NO se toma (y por qué tienta)

- **Esperar a "1.0 completa" (pública + CLI npm) antes de taggear.** Tienta porque un `v1.0.0` con README aún
  en español-solo y sin `npx jidoka-method init` se siente incompleto de cara al mundo. Se descarta porque la
  vara de 1.0 **nunca fue la presentación pública** — fue *que el método corra en un repo ajeno*. Atar la 1.0
  a lo público mezclaría dos criterios y retrasaría el contrato de estabilidad que ya está ganado. Lo público
  es Sprint 4; el CLI, un frente propio. Se difieren **explícitos**, no por olvido.
- **Bautizarla `v1.0.0-rc` y esperar adopción externa.** El linaje ya es la evidencia de adopción (SGI
  público); un RC eterno es cómo un proyecto nunca cumple su propio criterio.

## Consecuencias

- **Jidoka sale de beta.** El norte del ROADMAP (*la disciplina en el robot, el juicio en el humano,
  empaquetado para que cualquiera lo instale*) tiene su primer release estable.
- **Se difiere explícito a post-1.0** (registrado en ROADMAP): presentación pública (social preview, párrafo
  en inglés, `CODE_OF_CONDUCT`), CLI npm + SSOT de versión, multiplataforma, la reconciliación code-first vía
  `.local`, las grietas 2 y 5 de la auditoría, y las cuatro lecciones de la segunda cosecha (ADR 0015).
- **La licencia queda MIT consciente** ([ADR 0016](0016-licencia-mit-consciente.md)) — decidida antes del tag,
  no heredada.
- Evidencia de la declaración: suite completa verde en Jidoka (`probar-version`/`gate`/`hooks`/`instalador`/
  `auditor` + `auditar` + `verificar -Base main`); el required check `andon` verde en el PR de release; los
  dos labs en `0.13.0-beta` con CI verde.
