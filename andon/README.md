# Andon — los gates deterministas

> El cordón que para la línea. En Toyota, cualquier operario que ve un defecto jala el Andon y detiene la producción. Aquí, el Andon es el conjunto de gates que **atrapan el error en la fuente, fuera del LLM** — no le piden al agente que se porte bien; hacen el error imposible o lo bloquean.

## La ley: una sola fuente

Toda regla de gate vive en **un solo lugar** — el `blast-radius.json` (el "radio de explosión": qué área, al tocarse, obliga a tocar qué doc dueño). El hook, el verificador local y el CI **leen esa ley**; la prosa solo la explica. Cambiar la regla en un lugar la cambia en todos.

> **Dónde vive:** en un proyecto instalado, la ley es `.jidoka/blast-radius.json`. Jidoka corre su propio Andon (dogfooding), así que en **este** repo el motor vive en [`../tools/`](../tools/) y la ley es [`../tools/blast-radius.json`](../tools/blast-radius.json).

## Autoridad creciente (el modelo de amenaza)

No todos los gates son muros. Se ordenan por autoridad, y solo el último es infranqueable:

```
Stop hooks (avisan / frenan el cierre)   →  saltables
  pre-push  (UX local)                   →  saltable con --no-verify
    check `andon` en CI + branch protection  →  EL MURO REAL (server-side)
```

Se asume que **todo aviso local será bypaseado**. Por eso el muro real es el check `andon` corriendo en CI con *required checks* activados — lo único que `--no-verify` no salta.

## deny vs ask — heredado de la aviación

Este eje no lo inventamos: sale de cómo la aviación resolvió la automatización peligrosa (ver [`../doctrina/03-aviacion.md`](../doctrina/03-aviacion.md)).

- **`deny`** (bloqueo duro, **estilo Airbus**: límites que no puedes cruzar) para lo **irreversible y peligroso**.
- **`ask`** con override (**estilo Boeing**: avisa y frena, pero puedes anular) para lo que requiere **juicio humano**.

Se mezclan por tipo de acción; no se elige una sola filosofía. Y cuando la situación se degrada, la regla es **`click-it-down`** ("Children of the Magenta"): baja el nivel de automatización, no pelees dentro del modo automático.

## Los disparos: doctrina en el momento del gate

La IA no lee la doctrina. La doctrina le llega **compilada a disparos** — mensajes cortos (regla + porqué, autocontenidos) que se inyectan en el `permissionDecisionReason` de un hook, en un mensaje de CI o en la plantilla de un PR. Los 12 disparos viven en [`../kit/.jidoka/disparos/`](../kit/.jidoka/disparos/). Algunos clave:

- **`no-verify-es-teatro`** — saltarte el hook local solo pospone y agranda el fallo; el muro real es el required check.
- **`evidencia-no-palabra`** — el gate lee el artefacto (archivo, timestamp, diff, log), no la palabra del agente.
- **`prueba-de-vida-del-gate`** — ¿cuándo rechazó este gate algo real por última vez? Silencio = podrido.

## Prueba de vida

Un gate que nunca rechaza nada está podrido aunque el tablero esté verde. Por eso el motor Andon incluye un **self-test** (`probar-gate`): corre casos de resultado conocido —incluido uno que DEBE bloquear— para que la rama que bloquea no se pudra sin que nadie lo note. Quien valida, también se valida.

## Cuatro reglas de campo (pagadas en el linaje)

- **El gate gobierna hacia adelante; la historia tiene baseline.** Al estrenar un gate en un repo existente, el modo forense surfacea commits previos a la regla — eso no es deuda accionable: se limpia en un PR dedicado o se acepta como baseline. La autoridad del gate empieza el día que se enciende.
- **Hay una segunda familia de barreras: las que protegen el proceso, no el repo.** Corren donde el artefacto vive (el envío, el despliegue), no en CI. Mismas leyes: choke point, deny/ask, ledger de lo realmente enviado ("el registro se hace SOLO tras enviar de verdad"), y sin historial el check **se degrada a lo verificable hoy y lo dice** — no truena. Un `ask` que grita en falso seguido se recalibra o se poda: un gate ruidoso entrena el reflejo de click-para-pasar.
- **Un principio sin mecanismo es una promesa.** En el linaje, "nada sale del dispositivo" fue disciplina de código hasta que se volvió regla de plataforma (una CSP que lo hace imposible) — con la consecuencia deliberada de que violar el principio en el futuro exija revisitar el ADR a propósito. El costo de salida como diseño: poka-yoke aplicado a los propios ADRs.
- **Sin descartes silenciosos.** Cuando un motor decide omitir o callar algo, el descarte queda en el artefacto de auditoría con su razón. Caso real: unos `continue` tiraban datos sin registrarlos y el reporte *mentía por omisión*. El silencio también es auditable.

## El motor, en concreto (Sprint 1)

En este repo el motor son cuatro piezas en [`../tools/`](../tools/) más los hooks y el CI:

| Pieza | Qué hace |
|---|---|
| [`tools/blast-radius.json`](../tools/blast-radius.json) | La ley. 6 áreas (incluida `raiz`, la tierra de nadie: un archivo suelto en la raíz avisa); casi todo `avisa`, **un** `doc_bloquea` real (un ADR nuevo debe listarse en su índice). Los mensajes enseñan también cuándo **no** aplican (anti-fatiga de falsos positivos). |
| [`tools/verificar.ps1`](../tools/verificar.ps1) | El verificador. Corre local (pre-push) y en CI. **Avisa** los `doc_avisa`, **bloquea** los `doc_bloquea`, y **falla cerrado** (exit 2) si no puede medir. |
| [`tools/probar-gate.ps1`](../tools/probar-gate.ps1) | El self-test. Casos de resultado conocido, incluido uno que DEBE bloquear. |
| `.claude/hooks/` + `.github/workflows/andon.yml` | `no-memorias` y `andon-stop` (Stop) locales — si git falla de verdad, el hook **avisa** en vez de callar (lección ALTO-04 del laboratorio de campo); el check `andon` en cada PR — **con la ley y el verificador leídos desde la rama base** (un PR no puede editar la ley que lo juzga; ADR 0003). |

### Encenderlo

1. **Hooks locales** (una vez por clon): `git config core.hooksPath .githooks` — así el `pre-push` corre el verificador antes de cada push. Los hooks de Claude (`no-memorias`, `andon-stop`) se cablean solos vía `.claude/settings.json`.
2. **El muro real** (paso humano, una vez): en GitHub → *Settings → Branches → Branch protection rule* de `main`, con **tres** cosas — sin las tres no hay muro:
   - **Require a pull request before merging** (si se puede pushear directo, el check nunca corre);
   - el check **`andon`** como *required status check*;
   - **Do not allow bypassing the above settings** (si el admin puede saltárselo, para el admin —y para el agente usando sus credenciales— sigue siendo una sugerencia).
3. **Probarlo**: corre `./tools/probar-gate.ps1` (debe salir verde). Para verlo bloquear de verdad: agrega un ADR en `docs/decisions/` sin listarlo en el índice y corre `./tools/verificar.ps1`.

## Fronteras del muro (honestidad)

Ningún muro es infinito; estos son los límites conocidos de este motor, dichos de frente (la doctrina exige fronteras explícitas, `doctrina/06`):

- **La ley que juzga un PR es la de la base, no la del PR** — eso cierra el hueco auto-referencial (un PR ya no puede vaciar la ley que lo juzga). El costo: un cambio legítimo a la ley rige a partir del *siguiente* PR.
- **El primer push de una rama nueva no se verifica localmente** (sin upstream, el pre-push solo ve el working tree). Lo cubre el CI en cuanto abres el PR.
- **"Tocar" el doc dueño incluye borrarlo** — el matching mide presencia en el diff, no que el doc siga existiendo. Borrar el índice de ADRs junto con un ADR nuevo pasaría el gate (y lo cazaría el humano en el PR).
- **Sin branch protection completa (paso 2), todo lo anterior es teatro.** El gate local se salta con `--no-verify` a propósito y por diseño; el muro es el check requerido server-side, y solo si el admin tampoco puede saltárselo.
