# ADR 0002 — El motor Andon: gates deterministas sobre el propio Jidoka

- **Estado:** aceptado
- **Fecha:** 2026-07-10
- **Sprint:** 1

## Contexto

Jidoka ya predicaba en `andon/README.md` que un gate solo es muro si vive **fuera del LLM**, pero no corría ni un gate. La tesis sin motor es prosa. Este sprint construye el motor y lo pone a correr **sobre el propio repo** (dogfooding): el repo de la metodología cumple su propia metodología.

El motor no se reescribe: se **adapta** el ya probado en `poka-yoke-ia` (`verificar.ps1`, `probar-gate.ps1`, los hooks, el CI, el pre-push). Reusar el punto de control que ya funciona es, literalmente, lo que Jidoka predica.

## Decisión

Sembrar el arquetipo **doc-first** completo: una ley única + verificador + self-test + hooks + pre-push + CI.

- **La ley única — `tools/blast-radius.json`.** Una sola fuente que declara, por área, qué doc dueño debe tocarse cuando tocas esa área. El verificador, el hook de cierre y el CI la leen; la prosa solo la explica.
- **Casi todo `avisa`, un solo `doc_bloquea` real.** Fiel a la doctrina anti-fatiga (excepciones cableadas): el manifiesto arranca en `avisa` salvo **una** regla que bloquea de verdad — *un ADR nuevo debe listarse en `docs/decisions/README.md`*. Es alto valor (un ADR fuera del índice es una decisión perdida) y baja fatiga (los ADR son append-only). El camino de bloqueo se guarda además con un manifiesto sintético en `probar-gate.ps1`, para que la rama que bloquea no se pudra si la ley real cambia (disparo *prueba-de-vida-del-gate*).
- **PS 5.1 solo en este sprint.** Los scripts son PowerShell 5.1 y el CI corre en `windows-latest` (mismo intérprete que el hook local). Los **gemelos `.sh`** llegan con el instalador (Sprint 3), donde el multiplataforma sí importa. No se adelanta complejidad que hoy nadie usa.
- **Autoridad creciente.** `andon-stop` (Stop hook, frena el cierre si falta un doc dueño) → `pre-push` (UX local, saltable con `--no-verify`) → **check `andon` en CI + branch protection** (el único muro infranqueable). El required check en la protección de `main` es un **paso humano** documentado en `andon/README.md`.

## Por qué

- La tesis sin motor es prosa: Jidoka predicaba que un gate solo es muro si vive fuera del LLM, pero no corría ningún gate.
- Reusar el motor ya probado en el linaje (verificar.ps1, probar-gate.ps1) es literalmente lo que el método predica (dogfooding).
- Arrancar con "casi todo avisa, un solo doc_bloquea real" sigue la doctrina anti-fatiga: endurecer con evidencia, no con supuesto.

## El camino que NO se toma (y por qué tienta)

- Adelantar los gemelos `.sh` y el multiplataforma tienta por completitud, pero se posterga al Sprint 3 (el instalador): no se adelanta complejidad que hoy nadie usa.
- Sumar el auditor del grafo (`auditar.ps1`) desde ya tienta por cobertura, pero no entra: Jidoka aún no tiene grafo de producto que auditar (`product/` es solo ejemplos).

## Consecuencias

- Jidoka corre sus propios gates en cada push y cada PR. Cambiar un artefacto sin tocar su doc dueño **avisa**; agregar un ADR sin índice **bloquea**.
- El `auditar.ps1`/auditor de grafo **no** entra: Jidoka aún no tiene grafo de producto que auditar (`product/` es solo ejemplos). El par `verificar` + `probar-gate` + CI + pre-push es el set completo del arquetipo doc-first.
- Queda para Sprint 2 el ritual Kanban ejecutable (comandos `/jidoka:*`, `gemba-stop`, roles) que se apoya en este motor.
- **Kaizen:** si el bloqueo del índice resulta molesto en la práctica, se degrada a `avisa`. Empezar suave y endurecer con evidencia es la doctrina.
