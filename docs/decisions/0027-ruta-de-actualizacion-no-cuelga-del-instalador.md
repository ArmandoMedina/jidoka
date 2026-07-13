---
tipo: decision
---
# ADR 0027 — La ruta de actualización no cuelga de que `instalar.ps1` sea legible (el fallback `sembrar-manual.ps1`)

- **Estado:** aceptado
- **Fecha:** 2026-07-13

## Contexto

Sembrando el método en un **repo real regulado** (base de conocimiento PLD/CNBV) sobre **Windows 11 /
PowerShell 5.1 con un AV de terceros**, `instalar.ps1` resultó ser el **único** archivo del clon al que el SO
negaba lectura/ejecución, de forma **intermitente y muda**: `Get-Content instalar.ps1` → *acceso denegado*;
al ejecutarlo → *"está siendo utilizado en otro proceso"*, o quedaba callado sin sembrar y sin devolver exit.
El resto de los `.ps1` del clon se leían sin problema. Hipótesis: heurística de AV que marca por reputación un
script llamado *"instalar"* que hace `git config core.hooksPath` + copia hooks + usa `-ExecutionPolicy Bypass`
(jidoka#40, con el reporte y la evidencia; jidoka#43, la lección metodológica).

El punto de fondo: **el mecanismo de actualización del método era a la vez un único punto de falla y el
artefacto más sospechoso del kit.** El lazo "la máquina baja con `-Actualizar`" (ADR 0012) asume que
`instalar.ps1` **siempre** puede leerse y correr — y ese supuesto se rompe precisamente en los entornos
endurecidos que más valoran el método. El hijo se quedaba **sin ruta de siembra ni actualización, en silencio**.

El operador de campo encontró un workaround que funcionó: **siembra manual** — copiar las entradas `motor` del
`manifiesto.json` al destino, `git config core.hooksPath .githooks`, y escribir el sello `tools/jidoka-motor.json`.
Es, de hecho, el mismo camino que ya anticipaban `-Sellar` y `estado-motor.ps1`, solo que **no estaba guiado**.

## Decisión

**La ruta de actualización deja de colgar de un solo artefacto.** Se añade un **segundo camino, independiente
de `instalar.ps1`**:

1. **`tools/sembrar-manual.ps1`** — fallback de siembra y actualización que reproduce el workaround del reporte
   (copiar la `mecanica` del manifiesto + `core.hooksPath` + escribir el sello clasificado), con **menor
   superficie de sospecha**: no se llama "instalar" y **no usa `-ExecutionPolicy Bypass`**. Respeta no-clobber y
   las tres vías por hash igual que `instalar.ps1` (mismo hasheo agnóstico al EOL, ADR 0021). Se registra como
   pieza de `motor` en el manifiesto: **baja a los hijos por el propio lazo**. Sus tres helpers puros
   (`Get-MotorHash`, `Get-MotorPares`, clasificación del sello) están **duplicados a propósito** de `instalar.ps1`
   — el fallback debe correr *aunque `instalar.ps1` sea ilegible*, así que no puede depender de él. Esa redundancia
   **es** el objetivo, no una omisión de DRY.
2. **`estado-motor.ps1` degrada con gracia.** Cuando avisa que el hijo está atrás, **detecta si `instalar.ps1`
   es legible**. Si lo es, recomienda `instalar.ps1 -Actualizar` (el camino normal); si el AV lo bloqueó, apunta
   directo a `sembrar-manual.ps1 -Actualizar`, en vez de recomendar un script que no va a correr.
3. **La guía lo hace de primera clase.** `docs/guias/mantener-el-motor-al-dia.md` documenta el fallback como
   camino guiado (antes se infería de `estado-motor.ps1`).

## El principio

> **El mecanismo por el que el método se mantiene al día no debe ser a la vez el único punto de falla y el
> artefacto más sospechoso del kit.** Un `deny` o una cuarentena de terceros sobre una pieza no debe dejar al
> hijo sin ruta *ni aviso*. Como con los límites duros de la aviación (doctrina 03: hasta un `deny` tiene modo
> degradado; confiésalo), la ruta de actualización **degrada con gracia** a un segundo camino en vez de quedar muda.

## El camino que NO se toma (y por qué tienta)

- **Renombrar o firmar `instalar.ps1`** (quitarle el nombre-imán, firmar el script). Tienta porque atacaría la
  causa en el artefacto original. Se difiere: **alto blast-radius** (todo referencia `instalar.ps1`: guías, CI,
  wrapper npx, tests) y **la firma necesita un certificado** — recurso del cliente. Registrado en el ROADMAP
  con marca regla 2-3 junto con la ruta `npx jidoka-method` (que también acortaría este filo).
- **Un instalador que se auto-desbloquee del AV.** Fuera de alcance y frágil: la política del AV es del entorno,
  no del kit. El fallback existe precisamente para bajar el método **aunque no puedas tocar la política del AV**.

## Consecuencias

- El lazo de bajada tiene **dos caminos** al mismo estado final (motor + ley + sello + hooks); el segundo no
  depende del primero. `sembrar-manual.ps1` baja a los labs por `-Actualizar` como cualquier pieza de mecánica.
- Cobertura nueva: **`tools/probar-sembrar.ps1`** (24 casos: siembra, paridad del sello con `instalar.ps1`,
  no-clobber, tres vías, `-Actualizar` sin sello, y la degradación con gracia de `estado-motor`). Jidoka-only.
- **Regla 2-3:** primer uso real (un repo regulado, un entorno endurecido). Lo *construido* aquí (el fallback +
  la degradación) resuelve el daño activo sin esperar; lo *diferido* (renombrar/firmar/`npx`) espera el segundo
  entorno que lo pida. Los issues #40 y #43 quedan cerrados. Versión `v1.10.0`.
