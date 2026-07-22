# ADR 0056 — El molde de sprints y qa_runs se gobierna extendiendo el motor genérico, no clonando guardianes

- **Estado:** aceptado
- **Fecha:** 2026-07-22
- **Relacionado:** [ADR 0042](0042-gobierno-documental-por-estructura.md) (gobierno documental por estructura; el grafo se queda con `auditar`) · [ADR 0050](0050-molde-unico-de-los-adrs.md) (el molde único de los ADRs, guardián que bloquea) · [ADR 0049](0049-pilar-de-flujo.md) (contratos con gate)

## Contexto

Los ADRs ya viven bajo un molde con guardián residente que bloquea (ADR 0050), pero **los sprints (`docs/sprints/*-plan.md` / `*-entrega.md`), los `LOG.md` de `qa_runs/` y el grafo de producto (módulos/dominios) divergieron en su formato** — sin número canónico, con estructuras distintas, sin muro. Para cerrar ese drift había dos caminos evidentes: (a) clonar un `probar-<familia>.ps1` por cada familia (como `probar-adrs.ps1`), o (b) un `.ps1` monolítico que valide todo. Ambos tienen costo: clonar reproduce la mecánica de fold-de-acentos/fences/`Get-Secciones` —zona minada de PS 5.1— en 5-6 copias que divergen solas; el monolito se vuelve un punto único de falla (entraría en la lista secuencial de `andon.yml` y un bug en "sprints" tumbaría el muro de ADRs).

## Decisión

Se **extiende el motor genérico que ya existía** — `tools/estado-docs.ps1`, que lee el ledger `tools/docs-gobernados.json` (ADR 0042) — para gobernar por **datos, no por código**:

1. El campo `doc` del ledger acepta ahora un **glob de familia** (`docs/sprints/*-plan.md`, `qa_runs/*/LOG.md`), no solo una ruta singleton: el motor lo expande y valida cada miembro; 0 miembros emite `[FAMILIA VACIA]` (nunca un CONFORME en falso).
2. Sprints y `qa_runs` se gobiernan como **filas del ledger** (secciones requeridas mínimas del molde canónico), no como scripts nuevos. `probar-adrs.ps1` se queda **aparte** porque hace más que verificar secciones (coherencia de estado, huérfanos, self-test).
3. El molde de secciones de **módulos y dominios** se refuerza dentro de su dueño **`auditar.ps1`** (ADR 0042 §dec.5), NO en el ledger — evita el doble-gobierno que entrena el click-para-ignorar. Las capacidades ya las audita `auditar` (Gherkin).
4. La generación de un sprint conforme es **`/jidoka:planea` + la plantilla + el scaffolder `tools/nuevo-sprint.ps1`**, no un comando aparte.

## Por qué

- **No clonar mecánica frágil.** El fold de acentos y el salto de fences son código delicado en PS 5.1; una sola copia con self-test (`probar-docs.ps1`) vale más que seis que divergen con el lazo `-Actualizar`.
- **No un punto único de falla.** Fundir el muro-duro de ADRs con el aviso opt-in de las demás familias en un solo script obligaría a dos regímenes de severidad y arriesgaría el único muro que llega a `main`.
- **El motor genérico ya existía dos veces** (`estado-docs.ps1` y su hermano `estado-ritual.ps1`): la respuesta correcta a "¿un solo `.ps1`?" no es un monolito con `switch`, sino un motor alimentado por un registro de moldes.
- **Un comando nuevo duplica `planea`**, que ya pare el plan desde la plantilla.

## El camino que NO se toma

- **Un `probar-<familia>.ps1` por familia** — clona la mecánica de secciones sin beneficio (sprints/qa_runs no tienen reglas que excedan "están las secciones").
- **Un `.ps1` monolítico** que fusione ADR + qa + sprints — punto único de falla en `andon.yml`.
- **Meter capacidades/módulos/dominios al ledger** — contradice ADR 0042 (doble-gobierno del grafo de `product/`); van por `auditar.ps1`.
- **Un comando `/jidoka:nuevo-sprint`** — se retira; el scaffolder determinista se pliega en el paso de `planea`.

## Consecuencias

- Un **solo motor genérico** gobierna tres familias de documentos por datos; agregar una familia futura es una fila del ledger, no un script. Nacen `estricto:false` (aviso; muro opt-in en CI), coherente con ADR 0042 §dec.3.
- `probar-docs.ps1` gana el self-test de familias, incluida la guarda del **verde mentiroso** (glob sin miembros); `auditar.ps1` gana el molde de secciones de módulo/dominio con su self-test en `probar-auditor.ps1`.
- Como parte del mismo sprint (decisiones del cliente 2026-07-22): los **archivos de sprint se numeran** `sprint-NN-<slug>`; las decisiones de doctrina se **consolidan** en `docs/decisions/` (0052-0055, una sola carpeta de ADRs); y el comando redundante `/jidoka:nuevo-sprint` se **elimina** (el scaffolder `tools/nuevo-sprint.ps1` se queda, plegado en `planea`) — este ADR documenta ese borrado (lo exige el gate `no-borres-el-motor`).
