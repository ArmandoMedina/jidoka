# ADR 0014 — Jidoka listo para 1.0: cerrar los bloqueantes de "corre en un repo ajeno"

- **Estado:** aceptado
- **Fecha:** 2026-07-11

## Contexto

El criterio de `v1.0` (`ROADMAP.md`) es *"el método completo corra end-to-end en un repo ajeno"*. Un
gap-análisis contra esa vara separó los pendientes en **bloqueantes duros** (chocan con correr en un repo
ajeno) y **diferibles** (presentación pública, CLI npm, multiplataforma, doc-only). Este ADR cierra los
cuatro bloqueantes duros para dejar a Jidoka listo para bajar a los labs (SGI, TF) y taggear 1.0. El
alcance es **1.0 funcional** (decisión del cliente): lo público y el CLI quedan post-1.0.

## Decisión

Se cierran los cuatro bloqueantes duros:

1. **El instalador pregunta el arquetipo.** `tools/instalar.ps1`: si no se pasa `-Arquetipo` ni `-Yes`,
   `Read-Host` interactivo con los arquetipos `disponible:true` del manifiesto; con `-Yes` cae a
   `docs-as-code` (desatendido). Antes el default silencioso `docs-as-code` sembraba el arquetipo
   equivocado a un repo code-first sin avisar.

2. **El método se siembra (fin de los enlaces muertos).** Los comandos/skills sembrados citaban `kanban/`,
   `andon/`, `doctrina/`, `docs/guias/` que no viajaban → 404 locales en un repo ajeno. Ahora el manifiesto
   siembra el **método completo** (`kanban/` + `andon/` + `doctrina/` + la guía de entorno) como `mecanica`
   → el hijo es autocontenido y converge por `-Actualizar`. Un **verificador de enlaces** en
   `probar-instalador.ps1` lo vuelve invariante testeado (ningún doc sembrado cita un doc de método ausente).

3. **Fixture del quickstart.** `probar-gate.ps1` gana un caso que ejercita el flujo **real commit→verificar
   por git** en un repo fixture (no solo inyección de `-Cambiados`), replicando el paso 3 del README (ADR
   sin listar → `[BLOQUEA]`; listarlo → pasa). La demo copy-paste no se rompe en silencio.

4. **La guía `empezar-de-cero.md` completa.** Deja de ser esqueleto (`estado: vigente`): walkthrough de
   instalación desde cero verificado contra el flujo real.

## Por qué

- **La vara de 1.0 es empírica**, no una lista de features: "corre en un repo ajeno". Cada bloqueante se
  eligió porque un tercero real tropieza con él (arquetipo equivocado, enlaces muertos, demo rota, sin guía).
- **Sembrar el método** (en vez de apuntar a URLs públicas) hace al hijo autocontenido y offline, y encaja
  con el lazo: el método es `mecanica` que converge por `-Actualizar` sin pisar la instancia.

## El camino que NO se toma (y por qué tienta)

- **Apuntar los enlaces a los docs públicos de Jidoka por URL** en vez de sembrar el método: más liviano,
  pero enlaces externos que se pudren y no sirven offline. El hijo autocontenido es más honesto.
- **Cerrar también lo diferible antes de 1.0** (social preview, inglés, CLI npm, multiplataforma): son
  adopción/distribución, no "corre en un repo ajeno". Los labs son Windows → multiplataforma no bloquea.
- **Sembrar los ADR de Jidoka** para que las citas de procedencia resuelvan: los ADR son la *historia de
  Jidoka*, no del hijo (el hijo tiene los suyos). **Límite conocido:** los docs de método sembrados citan
  ADR de Jidoka (`docs/decisions/000X`) como procedencia — apuntan a la fuente, no viven en el hijo. El
  verificador de enlaces excluye `docs/decisions/` a propósito.

## Consecuencias

- Jidoka queda listo para **bajar a los dos labs** (SGI vía `-Actualizar`; TF cablearlo al lazo) y probar
  e2e — la vara de 1.0. Versión `v0.13.0-beta`.
- Evidencia: `probar-instalador.ps1` 34/34 (con el verificador de enlaces), `probar-gate.ps1` 10/10 (con el
  fixture), suite completa verde.
- Diferido a post-1.0, registrado en el ROADMAP: presentación pública, CLI npm/SSOT, multiplataforma,
  doc-only, barreras code-first del instalador, grietas 2 y 5, y el ADR de licencia (decisión del cliente).
