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

La IA no lee la doctrina. La doctrina le llega **compilada a disparos** — mensajes cortos (regla + porqué, autocontenidos) que se inyectan en el `permissionDecisionReason` de un hook, en un mensaje de CI o en la plantilla de un PR. Los 13 disparos viven en [`../kit/.jidoka/disparos/`](../kit/.jidoka/disparos/). Algunos clave:

- **`no-verify-es-teatro`** — saltarte el hook local solo pospone y agranda el fallo; el muro real es el required check.
- **`evidencia-no-palabra`** — el gate lee el artefacto (archivo, timestamp, diff, log), no la palabra del agente.
- **`prueba-de-vida-del-gate`** — ¿cuándo rechazó este gate algo real por última vez? Silencio = podrido.

## Prueba de vida

Un gate que nunca rechaza nada está podrido aunque el tablero esté verde. Por eso el motor Andon incluye un **self-test** (`probar-gate`): corre casos de resultado conocido —incluido uno que DEBE bloquear— para que la rama que bloquea no se pudra sin que nadie lo note. Quien valida, también se valida.

## El motor, en concreto (Sprint 1)

En este repo el motor son cuatro piezas en [`../tools/`](../tools/) más los hooks y el CI:

| Pieza | Qué hace |
|---|---|
| [`tools/blast-radius.json`](../tools/blast-radius.json) | La ley. 5 áreas; casi todo `avisa`, **un** `doc_bloquea` real (un ADR nuevo debe listarse en su índice). |
| [`tools/verificar.ps1`](../tools/verificar.ps1) | El verificador. Corre local (pre-push) y en CI. **Avisa** los `doc_avisa`, **bloquea** los `doc_bloquea`. |
| [`tools/probar-gate.ps1`](../tools/probar-gate.ps1) | El self-test. Casos de resultado conocido, incluido uno que DEBE bloquear. |
| `.claude/hooks/` + `.github/workflows/andon.yml` | `no-memorias` y `andon-stop` (Stop) locales; el check `andon` en cada PR. |

### Encenderlo

1. **Hooks locales** (una vez por clon): `git config core.hooksPath .githooks` — así el `pre-push` corre el verificador antes de cada push. Los hooks de Claude (`no-memorias`, `andon-stop`) se cablean solos vía `.claude/settings.json`.
2. **El muro real** (paso humano, una vez): en GitHub → *Settings → Branches → Branch protection rule* de `main` → marca el check **`andon`** como *required*. Sin esto, el CI corre pero no **bloquea** el merge; con esto, `--no-verify` ya no salva a nadie.
3. **Probarlo**: corre `./tools/probar-gate.ps1` (debe salir verde). Para verlo bloquear de verdad: agrega un ADR en `docs/decisions/` sin listarlo en el índice y corre `./tools/verificar.ps1`.
