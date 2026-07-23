---
tipo: analisis
estado: vigente
---
# Exploración — la huella de Jidoka en un repo ajeno (2026-07-23)

> **Qué es.** La primera vuelta de la kata de mejora (`doctrina/08-kata-de-mejora.md`) corrida
> como exploración real, no como ejemplo. Su pregunta: cuando Jidoka se instala en un repo
> ajeno, ¿el estorbo que produce es **colisión estructural** o **ruido visual**? La distinción
> decide si conviene pagar una reestructuración MAYOR o si basta con no hacer nada. El informe
> mide la condición actual, reporta un experimento rojo→verde sobre una copia desechable de un
> lab (línea base en los tres), y separa **lo medido** de **lo no medido** — que es el umbral que este repo usa
> para decidir qué se afirma (`docs/analisis/matriz-carriles-202607.md`, mismo criterio).
>
> **Cómo se usa.** Es evidencia, no registro: las decisiones que salgan de aquí van a un ADR y
> al ROADMAP, no a este archivo. Lo marcado como **no medido** no debe entrar a un plan: si se
> planea sobre eso, se planea sobre supuestos. Corte: 2026-07-23 · `v1.31.0`.

## La pregunta (una sola, timebox de una tarde)

¿La huella de Jidoka en un lab es colisión estructural o ruido visual — y se puede aislar la
maquinaria sin apagar el muro?

Corolario que la motiva: el muro real es el required check de CI, que corre `tools/verificar.ps1`
desde el checkout del propio repo. La maquinaria **tiene** que viajar dentro del repo del lab;
el problema no es sacarla, es que no estorbe.

## Método

Seis barridos de inventario de solo-lectura sobre el árbol (uno por territorio: `tools/`,
`.claude/`+CI, las carpetas de método, `app/`, prior art en ADRs/ROADMAP, y raíz+`docs/`+
`product/`), más un experimento sobre **copias desechables** de los tres labs
(`git clone --no-hardlinks` desde la ruta local; los originales nunca se tocaron; las copias se
borraron al cerrar). **Alcance exacto: la línea base verde corrió en las tres copias; el
rojo→verde del contenedor corrió en UNA sola** (el brownfield). Todo comando es re-ejecutable.
**Excepción declarada:** los sellos de los labs se leyeron de repos externos y su evidencia
—el `jidoka-motor.json` de cada uno— no quedó adjunta aquí; ese bloque descansa en la lectura
del agente hasta que se adjunte.

## Condición actual (medida)

**La huella visible en la raíz del lab son cinco carpetas de maquinaria pura** — `tools/`,
`kanban/`, `andon/`, `doctrina/`, `kit/` — más tres guías del motor sembradas dentro del
`docs/guias/` del anfitrión (manifiesto: `tools/` en `manifiesto.json:26-58` + la ley en `:24`;
las guías en `:66-68`; las otras cuatro carpetas en `:69-74`).

**Lo que no se puede mover ya es invisible.** `.claude/` (lo exige Claude Code), `.github/workflows/`
(lo exige GitHub) y `.githooks/` son ocultos, igual que el `/.jidoka/` efímero del `.gitignore`.
Ninguna restricción dura choca con aislar el resto.

**`tools/` es una carpeta mezclada, no solo maquinaria.** De sus **52 archivos rastreados, 17 no
viajan** a los labs. Y conviven scripts del motor con JSON que son **dato de instancia**: en la
nave existen la ley (`blast-radius.json`) y los contratos/estado del flujo (`flujo.json`), más
`ligas.json` —que declara en su propia descripción que no se siembra—. Otros dos son **dato de
instancia que la nave no tiene**: `contratos.json` (lo crea la app al parametrizar; comprobado
ausente aquí, y `bandeja.ps1:19` lo llama «el caso común hoy») y `jidoka-motor.json`, el sello,
que solo existe **en el hijo** porque lo escribe el instalador (`instalar.ps1:452`).

**La app no llega a los labs, y su motor tampoco.** `app/` es Jidoka-only por decisión (ADR 0048)
y no aparece en el manifiesto. Pero los tres scripts de los que depende para leer y escribir —
`tuberia-datos.ps1`, `parametrizar.ps1`, `override.ps1` — **tampoco se siembran**. Consecuencia
medida: hoy la app no podría operar contra un lab instalado aunque se distribuyera.

**Los labs están más atrás de lo que declara el ROADMAP.** Sellos reales al 2026-07-23:
dos labs en `v1.9.0` y uno en `v1.23.0`, contra `v1.31.0` de la nave. Los dos de `v1.9.0` son
pre-1.17 y **no registran arquetipo** en el sello, que es el caso en el que el instalador se
salta los stubs por arquetipo y solo avisa (`tools/instalar.ps1:231-233`). La tarjeta del
ROADMAP describe el batch como `v1.23.0`–`v1.28.x`: para dos de los tres labs eso es falso.

## El experimento (rojo → verde)

Línea base: el gate corre y sale `exit 0` en las tres copias, antes de tocar nada.

**ROJO — contenedor anidado (`jidoka/tools/`): falso-verde silencioso.** El gate sale `exit 0` y
reporta «Todo limpio»… verificando un árbol que no existe. En la línea base avisaba que había
código en `src/`; tras el movimiento decía que no había código. Causa medida: los scripts
calculan la raíz como `Split-Path -Parent $PSScriptRoot`, de modo que desde `jidoka/tools/` la
raíz se resuelve a `jidoka/`. **El modo de falla no es un crash: es una aprobación falsa.**

**VERDE — contenedor aplanado (`jidoka/`, scripts en su primer nivel).** La raíz se resuelve
correctamente y la salida del gate es idéntica a la línea base, **sin un solo cambio de código**.

**VERDE — el instalador falla cerrado.** `tools/instalar.ps1 -Actualizar` contra un lab migrado
a mano sale `exit 1` con un error explícito («no hay sello… no parece un hijo instalado») y **no
toca ningún archivo**: no re-siembra un `tools/` duplicado (`instalar.ps1:135-137`, antes de
escribir nada). Es un escenario **distinto** del que descartó el ADR 0024 —aquel era duplicar el
motor en `kit/`— pero el resultado que evita es de la misma familia: dos motores en un repo.
Consecuencia: un lab migrado queda **fuera del lazo de actualización** hasta que el instalador
aprenda dónde vive el contenedor.

**Anatomía del sello, para dimensionar la migración.** `jidoka-motor.json` guarda `version`,
`sembrado_hashes` (mapa ruta→hash), `excluir[]` y —desde 1.17— `producto` y `gobernanza`
(`instalar.ps1:237-241`). Las llaves del mapa **son** las rutas destino, así que mover carpetas
obliga a reescribirlo completo en cada lab.

## Rojo honesto (medido, sin cura, intención no determinada)

**Los cuatro Stop hooks dejan cerrar en silencio si falta la ley.** Comprobado por A/B con el
mismo cambio prohibido (tocar una barrera sin su doc dueño): con `tools/blast-radius.json` en su
sitio el hook emite `"decision":"block"` y frena el cierre; con la ley ausente **no emite nada y
deja cerrar**. El patrón está en el motor actual: `andon-stop.ps1:51`, `review-stop.ps1:34`,
`gemba-stop.ps1:41` y `validador-stop.ps1:49`, todos con
`if (-not (Test-Path $manifestPath)) { exit 0 }`.

El contraste que lo vuelve una pregunta y no un veredicto: `candado-pretooluse.ps1:26` hace lo
mismo **y lo documenta** como decisión («sin ledger no hay candados (caso hijo): falla-abierta»).
Los cuatro Stop hooks no documentan nada. Si la falla-abierta es deliberada, falta escribirla; si
no lo es, contradice la doctrina del juez que falla cerrado. **Esa clasificación es del cliente,
no del agente.**

## Deudas menores halladas de paso (no eran la pregunta)

Se listan porque se midieron y si no quedan escritas se pierden:

- **Tres scripts resuelven rutas contra el directorio actual, no contra la raíz del repo:**
  `estado-flujo.ps1:102-105` y `expirar.ps1:79-82` prueban `'tools/flujo.json'`, y `auditar.ps1:82`
  fija `'tools/blast-radius.json'` literal — los tres aceptan `-Repo` y no lo usan en esas líneas.
  Ya fallan hoy si se corren desde otra carpeta; el contenedor solo los delataría.
- **El contrato del apetito no expresa nada menor a una hora** (`apetito:\d+h`,
  `tools/verificar.ps1:300`). Todo ítem chico se declara `1h`, así que el backlog **sobreestima el
  presupuesto de atención del dueño**, que es justo la restricción del sistema. Arreglo de una
  línea más su prueba.
- **`review-stop` le dicta al agente su propio bypass.** Su encabezado declara «NO es auto-firma:
  el humano lo pone tras revisar» (`review-stop.ps1:7-8`), pero el mensaje de bloqueo **imprime el
  comando `Set-Content` exacto** para firmar el marcador (`review-stop.ps1:80`). Ocurrió en vivo
  durante esta sesión: el agente se auto-firmó y siguió; se revirtió al detectarse en la auditoría.
  El harness ya deshabilita `/code-review` para el modelo — el hook no debería entregar la llave
  junto a la cerradura. **Es el mismo patrón que este informe documenta en los otros hooks, pero
  cometido sobre el revisor.**
- **El comando que dicta puede venir caduco, y obedecerlo rompe el gate.** Medido el 2026-07-23:
  tras corregir el diff, el mensaje del hook seguía dictando el SHA **anterior**; escribirlo
  habría dejado el marcador sin corresponder al diff real y el hook bloquearía para siempre. El
  SHA correcto solo se obtiene recalculándolo (`review-stop.ps1:65-69`). **Un gate que dicta un
  comando obsoleto entrena a obedecer sin verificar** — y aquí obedecer era lo incorrecto.
- **El SHA del marcador no cubre los archivos sin rastrear.** Se calcula sobre `git diff HEAD`
  (`review-stop.ps1:65-69`), así que el **contenido de un archivo nuevo no entra en el hash**:
  medido en vivo el 2026-07-23 — se editó dos veces un archivo sin rastrear del área vigilada y el
  SHA no se movió. Un diff firmado como «revisado» puede llevar archivos nuevos con cualquier cosa
  dentro y el hook no se entera.

## Lo NO medido (no se afirma, no debe entrar a un plan)

- Si el contenedor aplanado pasa la **suite completa** de los 14 `probar-*.ps1` del motor actual.
- El comportamiento de la superficie de acoplamiento: 60+ rutas literales del repo escritas en
  hooks, comandos, skills, `.githooks/pre-push` y `.github/workflows/andon.yml`, 30 de ellas
  repetidas en dos o más lugares.
- Cómo se hace llegar a los labs el motor que la app invoca (que **no viaje** sí está medido; lo
  no medido es el cómo).
- Cómo se escribe la migración del sello (reescribir el mapa es mecánico; que el instalador
  encuentre el sello **antes** de saber dónde está todo lo demás es el problema de arranque).
- El comportamiento en los otros dos labs: el experimento corrió en uno solo.

## Qué se decide y qué se descarta

- **Descartado con evidencia:** la variante anidada del contenedor. Su modo de falla es una
  aprobación falsa y silenciosa, que es peor que no migrar.
- **Descartado por el cliente:** ocultar sin mover (`.gitattributes`/`files.exclude`), por no
  resolver la colisión de nombres.
- **Confirmado:** el principio ya está en la casa. El ADR 0023 aplicó «no colisionar con el repo
  anfitrión» a los **comandos** (`/jidoka:*`); el contenedor es ese mismo principio aplicado a
  **carpetas**. El ADR 0024 no lo bloquea: cerró la pregunta de mover el motor a `kit/` porque
  **crearía dos copias**, y un movimiento no crea una segunda copia.

## Qué debe revisar el dueño (guion, no «un vistazo»)

Formato *haz esto / debe pasar esto / recházalo si*. **Aviso que este informe se ganó a golpes:**
mirar y que se vea bien **no prueba nada** — la variante anidada se veía impecable (una sola
carpeta, raíz limpia) con el muro muerto. Por eso cada guion incluye **provocar un fallo**: la
única forma de saber que el gate sigue vivo es verlo morder.

> **Presupuesto real declarado por el dueño (2026-07-23):** 15 min para el contenedor, 1 h para los
> hooks, 15 min para la app. Las tarjetas dicen `apetito:1h` en las tres **no porque valgan una
> hora, sino porque el contrato del ROADMAP solo acepta horas enteras** (`apetito:\d+h`,
> `tools/verificar.ps1:300`). El backlog sobreestima ~1h45 de atención que no se pidió; el número
> de verdad es este párrafo.

### Contenedor `jidoka/` — 15 min

1. **Haz esto:** abre la raíz de un lab migrado. **Debe pasar:** ves **una** carpeta `jidoka/` y
   ninguna de `tools/`, `kanban/`, `andon/`, `doctrina/`, `kit/`. **Recházalo si** sobrevive
   cualquiera de las cinco, o si siguen apareciendo guías del motor dentro de `docs/guias/`.
2. **Haz esto:** toca a propósito un archivo de barrera (un hook, por ejemplo) **sin** actualizar
   su doc dueño, e intenta cerrar la sesión. **Debe pasar:** el cierre se frena y el mensaje
   nombra el área y el doc que falta. **Recházalo si te deja cerrar en silencio** — eso es el
   falso-verde: la raíz se resolvió mal y el gate está aprobando sin mirar.
3. **Haz esto:** corre el actualizador del motor contra ese lab. **Debe pasar:** lo reconoce y
   actualiza, o se niega con un error explícito. **Recházalo si** siembra un `tools/` nuevo en la
   raíz: eso deja **dos motores** en el mismo repo, que es la falla que la migración debe evitar.

### Los 4 Stop hooks — 1 h

Esto no es un vistazo: es una decisión tuya con dos salidas legítimas.

1. **Haz esto:** decide si un repo con los hooks cableados pero **sin** la ley debe poder cerrar.
   **Debe pasar:** eliges *diseño* o *defecto*. Si es diseño, se escribe en los cuatro hooks como
   ya lo hace `candado-pretooluse.ps1:26`; si es defecto, se cura y se prueba.
2. **Haz esto (solo si elegiste «defecto»):** con la cura puesta, renombra la ley y cierra.
   **Debe pasar:** el cierre se frena avisando que la ley no está. **Recházalo si te deja cerrar**
   — la cura no sirvió.

### La app en el lab — 15 min

1. **Haz esto:** instala Jidoka en un lab limpio y abre la app apuntándola a **ese** lab.
   **Debe pasar:** la app carga y la pantalla de gobierno dice la verdad **de ese repo**, no de la
   nave. **Recházalo si** no encuentra el repo, si carga vacía, o si algo que escribas aterriza en
   el repo equivocado.

### `review-stop` no debe dictar su propio bypass — 10 min

1. **Haz esto:** con el arreglo puesto, toca un archivo del área revisada e intenta cerrar.
   **Debe pasar:** el hook frena y te manda a revisar, **sin incluir el comando de firma** en el
   mensaje. **Recházalo si** el texto sigue trayendo el `Set-Content` — la llave sigue junto a la
   cerradura y cualquier agente la va a usar, como pasó el 2026-07-23.
2. **Haz esto:** revisa tú y firma. **Debe pasar:** el cierre procede. **Recházalo si** el hook
   sigue bloqueando con el marcador puesto (el SHA no corresponde al diff real).

### Tres scripts que resuelven contra el CWD — 10 min

1. **Haz esto:** párate en una subcarpeta cualquiera (`docs/`, por ejemplo) y corre desde ahí
   `estado-flujo.ps1`, `expirar.ps1 -Simular` y `auditar.ps1`. **Debe pasar:** se comportan igual
   que desde la raíz del repo. **Recházalo si** alguno dice que no encuentra `flujo.json` o la
   ley, **o si dice «no aplica» y sale limpio** — eso último es el falso-verde otra vez: sale
   contento porque no encontró qué vigilar.

### El contrato del apetito — 5 min

1. **Haz esto:** con el arreglo puesto, agrega una tarjeta de prueba con un apetito menor a una
   hora en el formato que se decida, y corre el gate. **Debe pasar:** la acepta. **Recházalo si**
   sigue exigiendo horas enteras, o si ahora deja pasar cualquier cosa en ese campo — aflojar el
   contrato no es arreglarlo. Bórrala después: era de prueba.

### Lo que NO se revisa mirando, porque es una decisión tuya

Tres tarjetas no tienen guion porque no hay nada que inspeccionar hasta que decidas: el **orden
del contenedor respecto al batch** de los labs (antes o después del 2026-08-04), el **arquetipo
«exploración» y su graduación**, y la **clasificación del rojo honesto de los hooks**. En esas, el
trabajo de revisión es elegir, no verificar.

## Qué mata este informe si se adopta

Esta sección es obligatoria por lo que costó el episodio de la linterna — que no es una sección
del ADR 0043, sino lo que pasó **con** él: siguió marcado `aceptado` después de que el cliente
descartara esa dirección, y un escaneo posterior lo obedeció y reconstruyó trabajo ya muerto.

Adoptar el contenedor **supersede la parte del ADR 0024** que se lee como «la maquinaria vive en
la raíz del árbol», y **obliga a re-datar la tarjeta del batch** del ROADMAP, cuyo rango de
versiones es incorrecto para dos de los tres labs.

**Y obliga a revisar el ADR 0048** («`app/` es Jidoka-only: no se siembra a los hijos»). Decisión
del cliente del 2026-07-23: **es obligatorio que el lab pueda usar la app** — si toda superficie
del gobierno debe ser la app (regla del cierre del Sprint 26), un lab sin ella es un lab sin
superficie. Matiz que la medición aporta y que abarata la decisión: la app es **de escritorio y
opera sobre la carpeta que se le indique** — valida cualquier repo comprobando que tenga
`tools/blast-radius.json` (`app/src-tauri/src/lib.rs:33-36`) y recuerda el último abierto — así
que **no necesita sembrarse por lab**: una instalación puede apuntar a los tres. Lo que sí debe viajar es el **motor** que
invoca: `tuberia-datos.ps1`, `parametrizar.ps1` y `override.ps1`. Con ese encuadre el ADR 0048
puede sobrevivir en su letra (`app/` sigue sin sembrarse) y lo que cambia es el manifiesto.

## Lo que este informe NO decide

No prende ningún cambio. La forma final del contenedor, la clasificación del rojo honesto de los
hooks y el orden respecto al batch de los labs son decisiones del cliente. Lo que sí queda
cerrado es la pregunta de la exploración: **el estorbo es estructural, no visual, y es aislable
sin apagar el muro.**
