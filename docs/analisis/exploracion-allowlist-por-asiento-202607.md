---
tipo: analisis
estado: vigente
---
# Exploración — ¿el hook sabe qué asiento lo invocó? (2026-07-23)

> **Sobre el tamaño, sin coartada:** ~95 líneas contra las ~15 que pide la regla 5 de
> `doctrina/08-kata-de-mejora.md`. **No cumple.** Sale largo por la tabla de campos y el guion de
> revisión; la tensión molde-vs-informe-durable sigue abierta
> (`kit/.jidoka/templates/exploracion.md:11-14`). Cierra el hueco que
> [`exploracion-procedencia-del-backlog-202607.md`](exploracion-procedencia-del-backlog-202607.md)
> dejó declarado en «Lo NO medido».

## Las cinco preguntas

1. **Condición objetivo.** Que cada asiento declare sus rutas y un muro determinista se las haga
   cumplir — que «el asiento de exploración solo escribe ROADMAP y análisis» sea un hecho verificable, no
   promesa del modelo.
2. **Condición actual.** El `tools:` de `.claude/agents/*.md` limita herramientas, no rutas. El
   único precedente de muro por ruta (`candado-pretooluse.ps1`) es global: no mira quién escribe.
3. **Obstáculo elegido AHORA.** Si el payload del `PreToolUse` identifica al invocador. De eso
   depende que exista *asiento* con alcance propio o solo *modo de sesión*.
4. **Hipótesis, escrita antes de medir.** *«El stdin NO trae identidad del asiento; el subagente
   será indistinguible del hilo principal.»* → **REFUTADA.**
5. **Cita de revisión.** El guion de abajo, en esta misma sesión.

## Método

Repo desechable fuera de este árbol (`scratchpad/lab-hook/`), con su propio
`.claude/settings.json`, un hook `PreToolUse` que vuelca el stdin, y un asiento de prueba
`sabueso` (`tools: Write`). Se corrió `claude -p` en headless con `--allowed-tools`, primero para
capturar payloads y luego para probar el bloqueo. **La configuración de este repo no se tocó.**
El lab se borró al terminar (regla 4: todo nace muerto).

## Condición actual (medida) — hipótesis refutada

El payload **sí identifica al invocador**, y solo cuando hay uno:

| Campo | Hilo principal | Subagente `sabueso` |
|---|---|---|
| `agent_type` | *(ausente)* | `"sabueso"` |
| `agent_id` | *(ausente)* | `"ae85f03d7e9bcb4f9"` |
| `session_id`, `transcript_path`, `prompt_id`, `cwd` | idénticos en ambos | idénticos en ambos |

Consecuencias directas: **el asiento se distingue por nombre**, y **«es el hilo principal» se
detecta por la ausencia del campo** — no hace falta un marcador de sesión.

## Resultado — rojo → verde

Allowlist por asiento (`agent_type === 'sabueso'` ⇒ solo `ROADMAP.md` o `**/analisis/**`), con el
hilo principal sin candado:

- **Rojo (con el hook roto):** un `SyntaxError` en el hook dejó pasar `motor.ps1`. **Hallazgo
  colateral no buscado: un hook que truena falla ABIERTO** — el mismo modo de falla que la tarjeta
  de los 4 Stop hooks, por otra causa (crash, no ley ausente).
- **Verde (hook sano):** el subagente intentó los dos `Write`. `analisis/hallazgo.md` se creó;
  `motor.ps1` **no existe en disco** y el subagente reportó el bloqueo con la razón del hook.

## Lo NO medido

- Si `agent_type` aparece también en los asientos **de fábrica** (`general-purpose`, `Explore`) y
  en subagentes **anidados**. Solo se probó un asiento custom, un nivel.
- El campo en `Bash` y `Edit` (aquí solo `Write`), y si el matcher heurístico de rutas dentro de
  comandos de `Bash` hereda las evasiones ya confesadas en `andon/README.md`.
- ~~**Si el campo es contrato estable de la herramienta o detalle de implementación.**~~
  **CERRADO el 2026-07-23** por el barrido de la CLI (`exploracion-modelo-de-asientos-202607.md`):
  `agent_type`/`agent_id` son **contrato formal documentado** de los hooks, no detalle de
  implementación — el muro no se cae sin aviso entre versiones. Además apareció una alternativa a
  medir: la CLI podría soportar un campo `paths` nativo en skills, que evitaría el hook.

## Qué debe revisar el dueño (guion) — 6 min

1. **Haz esto:** lee la tabla de arriba. **Debe pasar:** entiendes que el asiento se reconoce por
   `agent_type` y el hilo principal por la ausencia de ese campo. **Recházalo si** no queda claro
   cuál de los dos casos deja pasar todo.
2. **Haz esto:** pregúntame por el bloqueo en vivo y pídeme repetirlo delante de ti sobre un lab
   desechable. **Debe pasar:** el archivo prohibido **no aparece en disco** y el subagente reporta
   la razón. **Recházalo si** el archivo existe aunque el agente diga que fue bloqueado — la
   palabra del agente no es la evidencia, el `find` sí.
3. **El conejo rojo — provoca el fallo a propósito:** pídeme romper el hook (un error de sintaxis)
   y repetir. **Debe pasar:** la escritura prohibida **entra**, demostrando que el muro falla
   abierto. **Recházalo si** crees que un hook roto protege algo. Este paso ya ocurrió por
   accidente en esta vuelta y es la razón de que exista la tarjeta del fail-open.

## Qué se descarta (y por qué)

- **El modo-de-sesión con archivo marcador** (`.jidoka/modo-exploracion`): era el plan B si el
  payload no identificaba al invocador. Ya no hace falta y cuesta más (hay que encenderlo y
  apagarlo a mano, y restringe también al hilo principal). Descartado.
- **Confiar en el `tools:` del agente como límite de alcance.** No limita rutas; es sugerencia.

## Qué mata este informe si se adopta

Deja falsa la nota de `exploracion-procedencia-del-backlog-202607.md` que declara este punto
«no medido», y quita del ROADMAP la condicional «asiento **o** modo»: es asiento. Ningún ADR
queda superseded — cablearlo sí pedirá uno (es un muro nuevo, hermano del ADR 0047).

## Qué gradúa

- La tarjeta del asiento de exploración pasa de *«medir primero»* a *«cablear»*, con mecanismo
  conocido.
- Tarjeta nueva: **el fail-open del hook cuando el propio hook truena**.
