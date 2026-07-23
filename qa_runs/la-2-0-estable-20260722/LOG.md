# LOG — Sprint 26 «La 2.0 estable» (evidencia rojo→verde por escenario)

Corrida del 2026-07-22 sobre la rama `sprint/la-2-0-estable-20260722` (base `v1.30.0`).
Protocolo pedido por el cliente en vivo: **cada escenario de los escaneos se reproduce en
rojo (el defecto corriendo) y se cierra en verde (la cura corriendo)**; lo diferido queda en
rojo honesto (ver `docs/analisis/matriz-carriles-202607.md`).

## Metodo reproducible

Cada par se corrió en PowerShell 5.1 desde la raíz del repo; los comandos exactos van en cada
escenario. Los rojos de R1/R2 se reprodujeron **antes** de la cura (sobre el estado de
`v1.30.0`); el rojo del gate del badge se reprodujo con `git stash` del README curado. Nada de
lo aquí afirmado depende de la palabra del agente: todo comando es re-ejecutable.

## Resultados

### R1 — Corte honesto

**E1 · `package.json` prometía Mac/Linux sin evidencia**
- 🔴 ROJO (v1.30.0): `Select-String -Path package.json -Pattern '"os"' -Context 0,4` →
  `"os": [ "win32", "darwin", "linux" ]` — mientras `bin/jidoka-method.js:9-11` confiesa
  «PROBADO: Windows… AUN NO está probada» y la ley del repo dice «no se declara
  cross-platform sin evidencia». El fail-open: npm instalaría en Mac/Linux y los hooks
  jamás correrían, en silencio.
- 🟢 VERDE: `package.json` declara `"os": ["win32"]`; `probar-version.ps1` 5/5;
  `probar-instalador.ps1` 67/67.

**E2 · La promesa `npx` del README**
- 🔎 MATIZ (hallazgo del rojo): el README ya calificaba la promesa — línea 8: «`npx
  jidoka-method init` **en camino** (roadmap)»; línea 140: «falta CLI `npx` +
  multiplataforma». El escaneo la pintó peor de lo que estaba. Se deja como está
  (decisión aprobada: recortar/no publicar hasta cuenta npm); no hay promesa incumplida
  sin calificar. `Select-String -Path README.md -Pattern 'npx jidoka-method'` → 1 hit,
  calificado.

**E3 · Nada gritaba que el muro server-side no muerde tras instalar**
- 🔴 ROJO (v1.30.0): el final de `instalar.ps1` listaba branch protection como el paso 3
  entre 4 «siguientes pasos» — un ítem más de checklist, no un aviso.
- 🟢 VERDE: instalación real en repo temporal (`instalar.ps1 -Destino <tmp> -Arquetipo
  docs-as-code -Yes`) cierra con el bloque `!!!` amarillo: «OJO: el muro server-side AUN NO
  muerde… hooks locales (saltables con --no-verify)… branch protection… paso humano». Dato
  de instancia en `manifiesto.json` (`post.aviso`), impreso por `instalar.ps1`.

**E4 · El badge «1.0 estable» sobrevivió 30 releases mintiendo**
- 🔴 ROJO (v1.30.0): `README.md:12` = badge `estado-1.0%20estable` y `README.md:17` fijaba
  `v1.0.0`, con el repo en `v1.30.0`. Ningún gate lo cobraba.
- 🔴 ROJO del gate nuevo (vía `git stash` del README curado): `probar-version.ps1` →
  `[FALLA] el badge de estado del README dice v1.30.0 … exit 1`.
- 🟢 VERDE: badge `estado-v1.30.0` + check nuevo en `probar-version.ps1` (SSOT extendido 2)
  → `[PASA] el badge de estado del README dice v1.30.0 … exit 0`. La etiqueta ya no puede
  envejecer en silencio.

### R2 — Fiabilidad del motor

**E5 · Las copias gemelas divergen sin que nada lo grite**
- 🔴 ROJO (primera corrida de `probar-gemelas.ps1` sobre el código de v1.30.0): **3 drifts
  reales**, exit 1 —
  1. `Match-Any` de `andon-stop.ps1` usaba `$paths/$p` vs `$list/$item` de la canónica.
  2. `Test-NoVacio` de `bandeja.ps1` divergía semánticamente (`$null -ne $x` — un string
     vacío contaba como no-vacío, distinto del gate).
  3. `Clase-Display` de `expirar.ps1` con claves `confecha/algundia` vs
     `con_fecha/algun_dia` de `estado-flujo.ps1` — la divergencia viva que el escaneo
     predijo.
- 🟢 VERDE: las 3 curas alineadas a la canónica; `probar-gemelas.ps1` exit 0 (11 grupos, 21
  comparaciones); cableado al smoke del CI. Regresión de los curados: `probar-flujo` 94
  verdes, `probar-bandeja` 21, `probar-hooks` 47/47, `expirar -Simular` salida idéntica.

**E6 · `auditar.ps1` aprobaba en silencio si git fallaba (el único gate fail-open)**
- 🔴 ROJO (v1.30.0): `tools/auditar.ps1 -Range "rama-fantasma..otra-fantasma"` →
  `fatal: bad revision` + «(nada que auditar…)» + `== Grafo de docs integro ==` + **exit 0**.
- 🟢 VERDE: mismo comando → `[ERROR] git diff no pudo calcular el rango… FALLA CERRADO
  (exit 2)`. Regresión: `auditar.ps1` normal exit 0; `probar-auditor.ps1` 13/13.

**E7 · Borrar un Stop hook no disparaba el salvavidas**
- 🔴 ROJO (v1.30.0): `Remove-Item .claude\hooks\gemba-stop.ps1` + `verificar.ps1` →
  **exit 0** (el salvavidas solo cubría `tools/*.ps1` y la ley).
- 🟢 VERDE: mismo borrado → `[BLOQUEA] [no-borres-el-motor] el cambio BORRA
  .claude/hooks/gemba-stop.ps1 (pieza del motor) sin un ADR nuevo…` **exit 1**. Cobertura
  nueva: `.claude/hooks/*.ps1`, `.claude/settings.json`, `.githooks/*`. Regresión:
  `verificar` limpio exit 0; `probar-gate.ps1` 14/14.

### R3 — Superficies de absorción

**E8 · La conformidad por documento solo salía por terminal**
- 🔴 ROJO (v1.30.0): el CONFORME/DESVIADO por familia solo existía como salida de consola
  de `estado-docs.ps1`; el ROADMAP lo cargaba como pendiente (`conformidad-docs.html`).
- 🟢 VERDE: `estado-docs.ps1 -Reporte` emite el tablero doble-clic (espejo del
  `conformidad-adrs.html`): **`conformidad-docs.html`** en esta carpeta, 52 documentos
  con su familia, estado y faltantes. `probar-docs.ps1` 43 verdes (regresión).

**E9 · El mapa de enforcement solo se veía corriendo scripts**
- 🔴 ROJO (v1.30.0): la linterna (`estado-gobierno.ps1`) existía pero nadie la llamaba en
  el flujo; el mapa vivo/dormido solo salía por `rutear.ps1` en consola.
- ⛔ **DESCARTADO por decisión del cliente (2026-07-22): toda superficie del gobierno debe
  ser la app.** La linterna se recableó inicialmente (HTML en CI + evidencia) y el cliente la
  descartó como superficie: un HTML suelto no es la app (ADR 0048). El mapa
  de enforcement (qué bloquea/avisa/duerme) pasa al sprint de UI como pantalla de la app;
  el retiro formal de `estado-gobierno.ps1` del motor se decidirá ahí con su ADR (hoy
  sigue en el árbol: el salvavidas exige ADR para borrar motor, y los hijos sembrados aún
  la reciben). Lo que sí queda de este escenario: el drift vista-vs-gate vigilado por
  `probar-gemelas.ps1` mientras la pieza exista.

**E10 · «La IA siempre viaja por los caminos planeados» era inafirmable**
- 🔴 ROJO HONESTO (se documenta, no se cura en este sprint): 11 escenarios mapeados en
  `docs/analisis/matriz-carriles-202607.md` — 1 muro (con límite confesado) + 2
  parciales + 6 prosa + 2 nada (sin bloque `permissions`, sin gate de plan). Los ítems para
  cablear ya existen en el ROADMAP; prenderlos es decisión del cliente con la métrica de
  correcciones en la mano (regla 2: no sobre-cablear).

## Veredicto

**R1–R3 construidas y verdes; 7 pares rojo→verde corridos de verdad, 1 matiz confesado (E2),
1 rojo honesto diferido (E10).** Suites completas tras el último cambio: gate 18/18 (4 casos nuevos
del salvavidas), hooks 47/47, auditor 13/13, docs 43, flujo 94, bandeja 21, linterna 57,
gemelas 21/21, instalador 68/68 (caso nuevo del aviso), versión 5/5. Review adversarial del asiento `auditor` (2026-07-22): 2 MEDIOS + 2 BAJOS,
los 4 curados en el mismo sprint (huella de gemelas respeta literales de string; el tablero ya
no duplica cabecera en singletons; este conteo; resumen de la matriz trazable) + 2 regresiones
que faltaban, agregadas (caso del salvavidas de hooks en `probar-gate`, caso del aviso en
`probar-instalador`). Pendiente del cliente: el Gemba sin terminal (pasos en el plan) y la
decisión de release `v2.0.0` + ADR «qué significa 2.0» al cierre.
