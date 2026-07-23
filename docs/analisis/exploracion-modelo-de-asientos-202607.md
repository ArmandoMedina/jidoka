---
tipo: analisis
estado: vigente
---
# Exploración — el modelo de asientos está enredado (mapa para la sesión a fondo) (2026-07-23)

> **Qué es y qué NO es.** Este NO es el informe que resuelve el enredo de los agentes — el dueño
> lo marcó importantísimo y pidió *sentarse a revisarlo bien* en una sesión aparte. Esto es el
> **mapa que esa sesión debe tener sobre la mesa antes de empezar**: qué existe, dónde se nombra,
> qué dice la doctrina, qué dice la plataforma, y qué me equivoqué al explicárselo al dueño en la
> conversación que lo destapó. Tres subagentes ciegos entre sí lo levantaron (un `explorador` de
> localización, un `auditor` de coherencia, un `claude-code-guide` sobre el mecanismo real de la
> CLI). **Sobre el tamaño:** largo a propósito — es un mapa de referencia, no una vuelta de kata
> con media cuartilla; su función es que no se pierda ningún hilo antes de la sesión a fondo.

## Las cinco preguntas

1. **Condición objetivo.** Que al empezar la sesión a fondo, nadie tenga que redescubrir qué es un
   agente, qué es una skill, dónde se nombra cada uno, ni qué permite la plataforma — todo en un
   documento.
2. **Condición actual.** Medida abajo: tres ejes bajo la palabra «asiento», un renombre que toca
   120+ sitios (varios con listas hardcodeadas), y una doctrina que aún describe el «antes».
3. **Obstáculo elegido AHORA.** Levantar el mapa completo sin dejar hilos. No se decide el diseño
   —eso es la sesión a fondo—, solo se junta el terreno.
4. **Hipótesis, escrita antes de medir.** *«El renombre será mecánico y la plataforma fijará las
   reglas.»* → **Refutada por los dos lados:** el renombre NO es mecánico (rompe suites y choca
   con un ADR), y la plataforma es MÁS flexible de lo que supuse (los límites que creía de
   plataforma eran decisiones de este repo).
5. **Cita de revisión.** La sesión a fondo. Si al abrirla hay que volver a preguntar «¿los agentes
   son de Claude?», este mapa falló.

## Los tres ejes que la palabra «asiento» tapa

| Eje | Qué nombra | Vive en | Se… | Nombres hoy |
|---|---|---|---|---|
| **Rol del método** | la función | `kanban/roles.md`, token en `blast-radius.json` | ocupa | orquestador, desarrollador, escribano, validador, revisor-visual, arquitecto-doc, devops |
| **Mecánica por tier** | cuánto cerebro cuesta | `.claude/agents/*.md` | delega | explorador, mecanico, auditor, arquitecto |
| **Casting / persona** | etiqueta memorable | `product/casting.md` (+ tu archivo local, decisión 2026-07-23) | pega encima del eje 1 | nombres de pila |

La doctrina (`kanban/roles.md:7`) distingue bien *qué se delega vs qué se aplica* para el eje 1,
pero **llama «asiento» también al eje 2** (`roles.md:56`, `casting.md:35`), y ahí nace la
confusión que el dueño reportó.

## Condición actual (medida)

### El renombre no es cosmético — blast-radius real

Los 4 agentes se nombran en **120+ sitios** (`explorador` en ~24 archivos, `arquitecto` en ~30).
No todo es prosa: hay **listas hardcodeadas que un renombre rompe**:

- `tools/probar-agentes.ps1:49` — `$asientosEsperados = @('explorador','mecanico','auditor','arquitecto')`
- `tools/probar-sembrar.ps1:44` y `tools/probar-instalador.ps1:55` — el mismo cuarteto literal.
- `tools/tuberia-piezas.json:12-15` — las piezas por nombre.
- `kit/.jidoka/instalar/manifiesto.json:62-63` — `.claude/agents` y `.claude/skills` viajan como
  directorios completos, clase `mecanica`, a todos los arquetipos.

Renombrar `explorador` sin tocar esas listas **pone las suites en rojo**. El renombre es un sprint
con censo, no un `sed`.

### La doctrina está en el «antes» del diagnóstico

`kanban/roles.md` y `product/casting.md` describen el modelo enredado como si estuviera bien:

- **Personalización asimétrica (hueco real).** `roles.md:31-48` documenta cómo renombrar una
  **skill** para el casting. **No hay una sola línea** sobre renombrar un **agente**. Y peor: el
  lint (`probar-agentes.ps1:49`) + el ADR 0033 exigen que `name:` coincida con el nombre del
  archivo, así que hoy el eje de agentes ni siquiera *admite* un renombre sin tocar su propia ley.
- **Los 4 agentes no están en el «menú de asientos»** de `roles.md:19-27` — aparecen 30 líneas
  después, en otra tabla, sin decir «esto es otro eje». Es exactamente por qué el dueño creyó que
  eran de Claude: la doctrina no los sienta a la misma mesa.
- **Drift doctrina-vs-artefacto (nuevo, medido).** `roles.md:37` ilustra la ley con el token
  `rol: revisor-visual`, pero `blast-radius.json` **solo tiene `rol: escribano`** (11 veces,
  ninguna de las otras tres). El ejemplo de la doctrina no corresponde al archivo real — el mismo
  tipo de drift que el método existe para cazar, dentro de la doctrina del método.

### Colisiones de nombre confirmadas por lectura

- **`explorador`** (agente haiku, «barre y localiza», no juzga) vs **«exploración»** (la kata,
  trabajo de más juicio) vs **la punta de lanza** que el dueño quiere vs **`Explore`** (agente de
  fábrica de Claude — confirmado por el `claude-code-guide`, ver abajo). Cuatro sentidos, una raíz.
- **`arquitecto`** (agente opus, trade-offs) vs **`arquitecto-doc`** (skill, formato del grafo de
  docs). Dominios opuestos, raíz compartida, ninguna fuente señala el choque.

## La verdad del mecanismo (CLI 2.1.218) — corrige supuestos míos

Del `claude-code-guide`. **Marcado lo que corrige lo que le dije al dueño en la conversación:**

- **El filename NO tiene que coincidir con `name:` — en la plataforma.** Se lo presenté como si
  renombrar un agente fuera solo cambiar `name:`. **Cierto en Claude, falso en ESTE repo:** aquí
  el lint y el ADR 0033 lo obligan. El límite es nuestro, no de la plataforma.
- **Una skill SÍ puede declarar `model` y `allowed-tools` — en la plataforma.** Le dije que una
  skill «no tiene cerebro propio, usa el tuyo». Eso es una **decisión de este repo** (las 4 skills
  declaran a propósito «no soy `subagent_type`»), **no una ley de la plataforma**. Lo di como ley;
  era elección. Corregido aquí.
- **`agent_type`/`agent_id` en los hooks son CONTRATO FORMAL documentado**, no detalle de
  implementación. Esto **cierra el "Lo NO medido"** de
  [`exploracion-allowlist-por-asiento-202607.md`](exploracion-allowlist-por-asiento-202607.md):
  el muro por asiento no se cae en la próxima versión sin aviso.
- **Restricción por RUTAS:** la CLI **no** la soporta para agentes; el `claude-code-guide` afirma
  que **las skills tienen un campo `paths`** nativo. **Sin verificar** — si es cierto, el asiento
  de exploración podría no necesitar el hook `PreToolUse` que ya probamos. **Verificar antes de
  construir**; el hook, en cambio, ya está probado y funciona.
- **`Explore` de fábrica se puede sobrescribir** definiendo un agente propio con `name: Explore`,
  o desactivar con `CLAUDE_CODE_DISABLE_EXPLORE_PLAN_AGENTS=1`. Relevante para la colisión.
- **Precedencias inversas:** agentes = proyecto gana sobre usuario; skills = usuario gana sobre
  proyecto. Importa cuando el kit siembre a los labs — una skill de usuario en la máquina del lab
  le gana a la sembrada por el repo.

> **Cautela de origen:** los puntos de este bloque vienen de un subagente que consulta la
> plataforma; el único verificado con experimento propio es `agent_type`/`agent_id` (nuestro lab
> del hook). El resto **se verifica contra la doc oficial antes de construir sobre él** — sobre
> todo el campo `paths` de skills, que si existe cambia el diseño.

## Lo NO medido

- **El campo `paths` de skills**: existe o no, y si restringe escritura de verdad. Decide si el
  asiento de exploración es hook o skill nativa.
- **Qué es la punta de lanza: ¿agente o skill?** Sin resolver. Agente = piensa aparte, devuelve
  informe. Skill = un modo que el dueño activa. Cambia todo el diseño y nadie lo decidió.
- **El renombre completo con su censo**: no se listaron los ~120 sitios uno por uno con su tipo
  (prosa / lista dura / ley). La sesión a fondo lo necesita antes de tocar nada.
- **Si conviene un solo eje de nombres o de verdad hacen falta tres.** La pregunta de fondo que la
  sesión debe responder, no este mapa.

## Qué debe revisar el dueño (guion) — 10 min

1. **Haz esto:** lee la tabla «Los tres ejes». **Debe pasar:** reconoces que función, mecánica y
   persona son tres cosas y que la palabra «asiento» las tapa. **Recházalo si** sigues sin poder
   decir en qué eje vive tu punta de lanza.
2. **Haz esto:** abre `.claude/agents/` y cuenta los archivos. **Debe pasar:** ves cuatro `.md` y
   entiendes que son tuyos, editables, no de Claude. **Recházalo si** te parece que borrar uno no
   debería quitar el asiento — eso significaría que aún los crees fijos.
3. **El paso de decisión (para la sesión a fondo, no ahora):** decidir si la punta de lanza es
   agente o skill, y si el sistema se queda con tres ejes de nombres o se colapsa a menos.
   **Recházalo si** alguien intenta construir el renombre antes de responder esto.

## Qué se descarta (y por qué)

- **Renombrar ya, en esta rama.** Descartado: es exploración, y el blast-radius (120+ sitios,
  listas duras, un ADR de por medio) lo vuelve un sprint con censo, no un ajuste.
- **Tratar los límites de la plataforma como fijos.** Descartado tras medir: varios «no se puede»
  que asumí eran decisiones de este repo, reversibles.

## Qué mata este informe si se adopta

- Mata la lectura de que `kanban/roles.md` y `product/casting.md` describen un modelo sano: quedan
  marcados como «el antes» hasta que la sesión a fondo los reescriba.
- Mata mi afirmación en la conversación de que una skill no puede tener modelo propio y de que
  renombrar un agente es solo cambiar `name:` — ambas corregidas arriba.
- No supersede ningún ADR. La sesión a fondo probablemente **pida** uno nuevo (o enmiende el 0033).

## Qué gradúa

Nada de código. Al ROADMAP, la tarjeta «Exploración profunda…» ya existe (importantísimo); este
informe es su insumo. Sub-hilos que esa sesión no debe soltar, ya listados arriba: el campo
`paths`, la decisión agente-vs-skill de la punta de lanza, el censo del renombre, el drift de
`roles.md:37`, y la pregunta de fondo (¿tres ejes o menos?).
