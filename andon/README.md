# Andon — los gates deterministas

> El cordón que para la línea. En Toyota, cualquier operario que ve un defecto jala el Andon y detiene la producción. Aquí, el Andon es el conjunto de gates que **atrapan el error en la fuente, fuera del LLM** — no le piden al agente que se porte bien; hacen el error imposible o lo bloquean.

## La ley: una sola fuente

Toda regla de gate vive en **un solo lugar** — `.jidoka/blast-radius.json` (el "radio de explosión": qué área, al tocarse, obliga a tocar qué doc dueño). El hook, el verificador local y el auditor de CI **leen esa ley**; la prosa solo la explica. Cambiar la regla en un lugar la cambia en todos.

## Autoridad creciente (el modelo de amenaza)

No todos los gates son muros. Se ordenan por autoridad, y solo el último es infranqueable:

```
Stop hooks (avisan / frenan el cierre)   →  saltables
  pre-push  (UX local)                   →  saltable con --no-verify
    Auditor en CI + branch protection    →  EL MURO REAL (server-side)
```

Se asume que **todo aviso local será bypaseado**. Por eso el muro real es el auditor corriendo en CI con *required checks* activados — lo único que `--no-verify` no salta.

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

*(El motor ejecutable —`blast-radius.json`, `verificar`, `auditar`, `probar-gate`— se monta en Sprint 1.)*
