---
tipo: guia
estado: vigente
---
# Mantener el motor al día (el canal de bajada del lazo)

Esta guía es para quien **mantiene un repo con el método instalado** (un "lab"/hijo). El lazo de
sincronización tiene dos sentidos: *la lección sube* (reportas a Jidoka — ver
[`reportar-leccion-a-jidoka.md`](reportar-leccion-a-jidoka.md)) y *la máquina baja* (traes las mejoras del
motor a tu repo). Esto último es lo que aquí se explica.

> **El principio:** la **mecánica** del motor converge a la de Jidoka; tu **instancia** (tu ley
> `blast-radius.json`, tu `product/`, tu `HANDOFF`, tus ADRs) y tus **customizaciones code-first** (tu
> `verificar.ps1` con las herramientas de tu lenguaje, etc.) **nunca se pisan**. El lazo distingue una de otra
> por el **sello** `tools/jidoka-motor.json`.

## El sello: qué recuerda tu repo

`tools/jidoka-motor.json` registra de qué versión de Jidoka viene tu maquinaria y, por pieza, el hash que
Jidoka envió. Campos:

- `version` — la versión de Jidoka a la que sincronizaste por última vez.
- `sembrado_hashes` — hash (normalizado a LF, agnóstico al fin de línea — ADR 0021) por pieza de mecánica.
- `excluir` — *(opcional)* lista de piezas que tu repo **no quiere** (ver más abajo).

## Traer las mejoras: `-Actualizar`

Se corre **desde el repo de Jidoka**, apuntando al tuyo:

```powershell
# (desde el checkout de Jidoka)
./tools/instalar.ps1 -Destino C:\ruta\a\tu-repo -Actualizar
```

Por cada pieza de mecánica, decide con conciencia de tres vías (estilo `dpkg conffiles`) y te lo dice:

| Marca | Qué pasó |
|---|---|
| *(silencio)* / `al dia` | tu pieza es idéntica a la de Jidoka — nada que hacer. |
| `[ACTUALIZA]` | no la habías tocado desde la siembra y Jidoka avanzó → se actualiza. |
| `[NUEVO]` | pieza nueva de esta versión → se agrega. |
| `[DIVERGE]` | **la customizaste** → **no se pisa**; se deja `<pieza>.jidoka-nuevo` al lado para que compares. |
| `[EXCLUIDA]` | está en tu lista `excluir` → no se toca ni se re-agrega. |

Tu **instancia** (ley, `product/`, `HANDOFF`, ADRs) no se itera nunca: `-Actualizar` solo toca `mecanica`.

### Manejar las divergencias

Cada `[DIVERGE]` deja un sidecar `<pieza>.jidoka-nuevo` con la versión de Jidoka. Revisa el diff y decide:

- **Adoptar** la de Jidoka (si tu "customización" era en realidad una versión atrasada):
  `Move-Item <pieza>.jidoka-nuevo <pieza> -Force`.
- **Conservar** la tuya (si es una customización genuina de tu lenguaje): borra el sidecar
  (`Remove-Item <pieza>.jidoka-nuevo`).
- Reconciliar a mano, o mover tu ajuste a la costura `.local` (p.ej. `tools/verificar.local.ps1`), para que la
  mecánica converja sin bifurcarse.

### Las costuras `.local`: customiza sin divergir

Las piezas del motor traen puntos de extensión para que tu customización viva en la **instancia** (archivos
tuyos que el lazo jamás toca) en vez de editada dentro de la mecánica — editar la mecánica te condena a
reconciliar el mismo `[DIVERGE]` en **cada** bajada, para siempre:

| Quieres agregar | NO edites | Pon tu código en |
|---|---|---|
| Checks propios al gate local | `tools/verificar.ps1` | `tools/verificar.local.ps1` (se dot-sourcea si existe) |
| Checks propios al CI (p.ej. lint de fronteras, npm test) | `.github/workflows/andon.yml` | `tools/ci.local.ps1` (el workflow lo invoca si existe — cosecha #7, issue #90) |

`tools/ci.local.ps1` corre en el mismo job del check `andon` (PowerShell, exit ≠ 0 = rojo). Si tus checks
necesitan setup pesado (Node, contenedores), la alternativa sigue siendo un **workflow propio aparte**
(`fronteras.yml` tuyo) — también instancia, también libre de DIVERGE.

> **Los `.jidoka-nuevo` son andamio de reconciliación, no herramienta terminada: bórralos antes de commitear.** En
> cualquiera de los tres caminos, el sidecar desaparece del árbol una vez que decidiste — lo que entra al diff del PR
> es tu decisión *aplicada* (adoptaste, conservaste o reconciliaste), nunca el `.jidoka-nuevo` en sí.

**Corre siempre en una rama, revisa el diff, ábrelo como PR** — el diff ES la revisión. Y **corre tu suite de
tests antes de mergear** (el motor bajado no vale hasta que corre verde en tu repo).

## En Windows endurecido (antivirus): usa `sembrar-manual.ps1`

En Windows endurecido con un AV de terceros, `instalar.ps1` (y su test `probar-instalador.ps1`) puede caer
en **cuarentena heurística** —p. ej. Bitdefender `CMD:Heur.…Boxter`, familia ransomware— y el SO **niega
leerlo o ejecutarlo**, a veces de forma intermitente y **muda** (no siembra, no da error). Es el filo de los
repos regulados, justo los que más valoran el método (jidoka#40/#43; ADR 0027 + su enmienda 2026-07-15).

> **Ojo — el disparador NO es el nombre ni una línea suelta** (verificado en campo, ADR 0027 enmienda):
> es la **densidad acumulada** de comportamiento tipo *dropper* que tiene cualquier instalador (spawn de
> powershell + `core.hooksPath` + copia masiva + leer/escribir bytes). Por eso **renombrar no ayuda** y
> **re-clonar tampoco** (el scan re-detecta el mismo contenido). La cura robusta de fondo es **firmar** los
> scripts (Authenticode) — la controla el desarrollador, no el AV; pendiente de un certificado.

Para eso existe **`tools/sembrar-manual.ps1`**: un **camino AV-seguro completo, independiente de que
`instalar.ps1` sea legible**. Es un script **magro** (subconjunto bajo el umbral heurístico) que hace lo
mismo que `instalar.ps1` sin su densidad: copia la `mecanica` del manifiesto, siembra la **ley** del
arquetipo y los **stubs de instancia**, fija `core.hooksPath` y escribe el sello. La magrez es una
**restricción**: si lo editas, vuelve a probarlo contra el AV.

```powershell
# Siembra fresca (cuando instalar.ps1 nunca llegó a sembrar):
./tools/sembrar-manual.ps1 -Destino C:\ruta\a\tu-repo -Jidoka C:\ruta\a\jidoka

# Actualizar un hijo ya sembrado (mismo -Actualizar de tres vías, sin instalar.ps1):
./tools/sembrar-manual.ps1 -Destino C:\ruta\a\tu-repo -Jidoka C:\ruta\a\jidoka -Actualizar
```

- Corrido **desde el checkout de Jidoka** (`./tools/sembrar-manual.ps1`), toma el motor de ahí solo; desde
  un hijo, apunta a Jidoka con `-Jidoka <ruta>` o `$env:JIDOKA_HOME`.
- Respeta **no-clobber** y las **tres vías** igual que `instalar.ps1`: tu instancia y tus customizaciones
  no se pisan; deja `<pieza>.jidoka-nuevo` para lo divergente.
- Siembra la **instancia completa** (no-clobber): mecánica + la ley del arquetipo + los **stubs de instancia**
  (HANDOFF, ROADMAP, CHANGELOG, índice de ADRs, `.gitignore` + la semilla del QUÉ del arquetipo) + el sello.
  Ya no hace falta `instalar.ps1` para dejar el repo entero en una máquina donde el AV lo bloquea.
- Verifica al final: `./tools/estado-motor.ps1 -Jidoka <ruta>` debe decir **`[OK]` al día**.

> **`estado-motor.ps1` te lleva de la mano:** cuando avisa que estás atrás, detecta si `instalar.ps1` es
> legible. Si lo es, recomienda `instalar.ps1 -Actualizar`; si el AV lo bloqueó, apunta directo a
> `sembrar-manual.ps1 -Actualizar` en vez de recomendarte un script que no va a correr.

Y si prefieres AGREGAR `instalar.ps1` a la lista blanca de tu AV, esa es la otra salida — pero el fallback
existe para que el método baje **aunque no puedas tocar la política del AV**.

### El parche `skip-worktree`: cuando el AV se come una pieza ya sembrada

Un caso distinto al de arriba: no es que `instalar.ps1` esté en cuarentena, es que el AV puso en
cuarentena **una pieza ya sembrada** en tu repo (p.ej. `tools/instalar.ps1` mismo, una vez sembrado). El
archivo desaparece del disco y `git status` la reporta como **borrada** — te ensucia el árbol con algo que tú
no tocaste.

**El parche local:**

```powershell
git update-index --skip-worktree tools/instalar.ps1
```

Con eso, el árbol vuelve a reportarse limpio.

> **La trampa — por qué esta receta existe:** el parche es **invisible**. `git status` dice "limpio" con
> piezas del motor fuera del disco, y **no viaja con el clon** (es estado del índice local, no algo que
> commiteas). Un release se cortó con "árbol limpio: `True`" y dos piezas del motor ausentes en el disco —
> nadie lo vio porque nada lo dijo. **No te creas el "limpio"** sin auditar: si sospechas piezas con el
> parche puesto, revisa con
>
> ```powershell
> git ls-files -v tools/ | findstr /R "^S"
> ```
>
> — las líneas que empiezan con `S` son las que tienen `skip-worktree` activo.

**Cómo revertirlo** (cuando el AV deje de comerse la pieza — p.ej. con el motor firmado, ver arriba):

```powershell
git update-index --no-skip-worktree tools/instalar.ps1
git checkout -- tools/instalar.ps1
```

> Nota: que `estado-motor.ps1` **acuse este estado solo** (sin que tengas que saber correr el `findstr` de
> arriba) es una cura mecánica pendiente, registrada como candidata en el issue #79 (regla 2-3: esperando el
> 2º caso antes de construirla).

## Rechazar piezas que no quieres: `excluir`

Si una pieza del núcleo no encaja en tu repo (p.ej. un `probar-gate.ps1` genérico incompatible con tu
`verificar` code-first, o un `andon.yml` que duplica tu CI), **declárala** en tu sello para que el lazo deje de
re-agregarla en cada bajada (ADR 0022). En `tools/jidoka-motor.json`:

```json
{
  "version": "1.5.1",
  "sembrado_hashes": { "...": "..." },
  "excluir": [
    "tools/probar-gate.ps1",
    ".github/workflows/andon.yml"
  ]
}
```

A partir de ahí, `-Actualizar` reporta esas piezas como `[EXCLUIDA]` y no las toca. La lista se **preserva**
entre bajadas (no la pierdes al re-sincronizar). Sin `excluir`: comportamiento normal (nada cambia).

## Ver la divergencia fina: `estado-motor -Detallado`

La versión del sello es de grano grueso. Para ver **qué piezas divergen** de Jidoka, por hash:

```powershell
# (desde tu repo)
./tools/estado-motor.ps1 -Jidoka C:\ruta\a\jidoka -Detallado
```

Lista las `[DIVERGE]` y `[AUSENTE]`, y cuenta las al día. Es **aviso, no muro** (nunca bloquea; exit 0). Sin
`-Jidoka`, o con `$env:JIDOKA_HOME` exportado, solo compara la versión.

## Sellar un repo que convergió a mano: `-Sellar`

Si adoptaste el método a mano y **no tienes sello** (o quieres re-crearlo bien), `-Sellar` lo escribe
clasificando cada pieza contra el Jidoka actual (ADR 0019):

```powershell
# (desde Jidoka)
./tools/instalar.ps1 -Destino C:\ruta\a\tu-repo -Sellar
```

- pieza **idéntica** a Jidoka → **pristina**: se registra (el próximo `-Actualizar` la mantiene al día).
- pieza **distinta** → **customizada**: se omite de la semilla (el próximo `-Actualizar` la ve `[DIVERGE]` y la
  preserva).

> **Ojo:** `-Sellar` compara contra el Jidoka **actual**. Úsalo cuando tu repo está **al nivel** de ese Jidoka
> (convergido a mano). Si tu repo está **atrasado**, no uses `-Sellar` (marcaría como "customizada" cualquier
> pieza pristina-pero-vieja): usa `-Actualizar`, que se apoya en el sello existente.

## Para el mantenedor de Jidoka: cortar un release con `publicar.ps1`

*(Solo el repo Jidoka; no se siembra.)* El release se **deriva del SSOT** `tools/version.txt` (ADR 0020):

```powershell
./tools/publicar.ps1              # corre la suite, crea el tag + release con las notas del CHANGELOG
./tools/publicar.ps1 -DryRun      # muestra qué haría sin crear nada
./tools/publicar.ps1 -SoloVerificar   # corre el preflight (suite) sin publicar
```

Escribe la versión **una vez** en `version.txt` (y su sección en el CHANGELOG); el tag, el título y las notas
derivan de ahí. No publica si un self-test falla.

---

> **Fin de línea:** el hash del motor es agnóstico al EOL (normaliza a LF antes de comparar), así que tu repo
> puede tener la política que quiera (`eol=lf` o `crlf`) y el lazo reconcilia por **contenido**, no por bytes
> (ADR 0021).
