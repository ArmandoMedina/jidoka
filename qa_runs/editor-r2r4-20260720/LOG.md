# Corrida — El editor del gobierno, parte 2 (R2–R4) · 2026-07-20

> Evidencia de la construcción de las ligas código↔capacidad (`v1.25.0`, ADR 0044).
> Plan-contrato: `docs/sprints/sprint-editor-gobierno-2-plan.md` (aprobado en plan mode 2026-07-20).

## Método reproducible

1. Corre `tools/probar-ligas.ps1` (26/26 casos de co-ocurrencia, fuerza, rotura).
2. Corre `node --test extension/ligas.test.js` (9/9 tests de upsert, merge, UTF-8).
3. Corre `tools/probar-linterna.ps1` (58/58 casos de nodo, arista, dogfood).
4. En Gemba: abre VS Code, pulsa F5, clic derecho sobre archivo, "Jidoka: ligar a capacidad..." → elige acción/fuerza → ve la liga en el grafo.

## Resultados (esta máquina, 2026-07-20)

| Suite | Resultado |
|---|---|
| `tools/probar-ligas.ps1` (nuevo) | **26/26** — co-ocurrencia por dirección, `avisa` jamás bloquea, `bloquea`+`-Estricto` exit 1 **nombrando la capacidad**, rotas sin falso bloqueo, falla-cerrado (ledger malformado/enum → exit 2), rango git real con `-Base`, **contrato entre stacks** (JS escribe → PS lee) |
| `extension/ligas.test.js` (nuevo, `node --test`) | **9/9** — upsert funde/deriva ids, quitar elimina la liga vacía, UTF-8 sin BOM |
| `tools/probar-extension.ps1` | **16/16** — 3 comandos contrato manifiesto↔código, `node --check`, `node --test`, extension/ sigue Jidoka-only |
| `tools/probar-linterna.ps1` | **49/49** — 7 casos nuevos de ligas (nodo propio, arista tipada, rota en rojo, ancla al área, cero aristas colgadas, dogfood real) |
| `tools/probar-publicar.ps1` | 7/7 — el poka-yoke confirmó `probar-ligas` en el preflight |
| `tools/probar-version.ps1` | 4/4 — SSOT `1.25.0` consistente (version.txt = CHANGELOG = package.json) |
| Suite completa (`publicar -SoloVerificar`) | **14/14 + auditar, exit 0** (probar-version/gate/hooks/auditor/disparos/preflight/docs/**ligas**/linterna/anti-pii/instalador/sembrar/agentes/extension) |

## La mordida dogfood (la métrica del QUÉ, en vivo)

La liga `linterna-extension` (`tools/estado-gobierno.ps1` + `extension/*` → `AND-1-muro-andon.md`,
`codigo-a-capacidad`, `avisa`) se declaró en C2. En C6, sobre el rango real del sprint
(`-Base main`), el gate mordió **antes** de que tocáramos la capacidad:

```
[AVISO] liga 'linterna-extension': cambiaste [extension/extension.js, extension/ligas.js,
        extension/ligas.test.js] sin tocar su capacidad: product/capacidades/AND-1-muro-andon.md
Resumen: 1 liga(s) | 1 evaluada(s) | 1 aviso(s) | 0 bloqueo(s) | 0 rota(s).
```

**Nombra la capacidad exacta — no "revisa las 89".** La cura fue actualizar `AND-1` (la capacidad
de verdad creció: ganó el criterio del gate de ligas). Ese era el QUÉ del sprint, demostrado por
su propia maquinaria sobre sí misma.

## Empaquetado (R4)

`npx --yes @vscode/vsce package` → `extension/jidoka-gobierno-0.1.0.vsix` (**8 archivos,
10.77 KB**, exit 0; el `.vsix` es artefacto de build, gitignoreado). Guía de uso e instalación:
`extension/README.md`.

## Code-review independiente (2026-07-20)

**Veredicto: APROBADO CON REPAROS** — ningún hallazgo compromete el muro. Atendidos con regresión:

- **MEDIO — deselección mentirosa en el QuickPick:** `upsert` unía capacidades; desmarcar no quitaba. Cura: `upsert` ahora **reemplaza** (la selección es el estado final) + test actualizado.
- **MEDIO — archivo fuera del workspace → liga ROTA silenciosa:** `rutaRelativa` ahora rechaza `..`/absolutas (multi-root) con mensaje que lo explica.
- **MEDIO — evidencia "committeada" que no lo estaba:** este LOG entra con `git add -f` en el commit de C6 (verificable en el diff del PR).
- **BAJO (5 curados):** `quitar` ya no crea/reescribe ledger sin tocar nada · tolera ligas malformadas sin tronar · caso faltante `'ambas'` ambos-tocados → 0 agregado (27/27) · comentario del split de `-Cambiados` corregido (contrato propio, no de verificar) · BOM del `package.json` raíz eliminado · liga sin `id` se pinta con id sintético (antes se omitía del grafo).
- **BAJO (2 anotados, no curados a propósito):** el step de CI re-codifica el ledger de la base a ASCII (deuda **compartida** con el step del blast-radius/anti-pii — mismo molde; cura eventual: extraer bytes, no texto) · el ancla `area→liga` resuelve el string del glob, no sus archivos (bendecido por el plan: "sin área, nodo suelto — honesto").

Regresión post-curas: `probar-ligas` **27/27** · `probar-extension` **16/16** (12 tests JS) · `probar-linterna` **49/49** · `probar-version` 4/4.

## Rework del Gemba del cliente + segundo code-review (2026-07-20)

Los 7 hallazgos del Gemba del cliente (dirección tirada, severidad invisible en Foco, etiquetas
encimadas, nodos fuera de pantalla, sueltos ambiguos, Clusters enredado, lectura por cercanía)
se curaron como **rework en esta rama** (issues #116–#118 cerrados como absorbidos — eran Gemba
de rama sin mergear, no cosecha). Un segundo review adversarial sobre el rework dictaminó
**"NO mergear tal cual"** y cazó lo que la suite no vio:

- **ALTO A1 (curado):** el anillo rojo de `dura` era **invisible en el navegador** — el CSS
  `.node circle` pisa los atributos de presentación SVG. La suite estaba verde encima (los
  asserts medían presencia de texto, no render). Cura: estilo inline + assert que exige el
  estilo inline exacto. La lección: **un assert de presencia no caza una rotura de render.**
- **MEDIO (curados):** guard de orden en `tmSplit` (recursión infinita si el sort de PS cambia) ·
  el bbox del fit ignora las etiquetas de hover (lazo hover→zoom que "bombeaba") · asserts
  endurecidos (flecha INVOCADA, anillo inline, vigila gate→área).
- **BAJO (6 curados):** halo gris en las puntas de flecha · desempate determinista del sort del
  reparto · etiqueta vacía de checks que empiezan con `(` · resize a dimensión 0 · tooltip de
  sueltos condicionado por tipo · **dirección de `vigila` invertida** (ahora sale del gate — con
  flechas visibles, "el área vigila al gate" leía mentira). **1 anotado:** `$cobConteo` es
  hashtable case-insensitive (dos áreas `Docs`/`docs` se fundirían en el treemap — ultra-borde).

Regresión post-curas: `probar-linterna` **58/58**.

## Veredicto

Las ligas código↔capacidad están cableadas: el gate muerde nombrando la capacidad exacta. R2–R4 todos verdes. Listo para merge a v1.25.0.

## Pendiente que deja esta corrida (Gemba del cliente, sin código ni terminal)

1. F5 → clic derecho sobre un archivo → *"Jidoka: ligar a capacidad..."* → 2 capacidades +
   dirección + fuerza → ver el diff de `tools/ligas.json` en *Source Control* y la liga en el grafo.
2. Cambiar un archivo ligado `bloquea` sin tocar su capacidad → push desde el panel de git →
   verlo detenido nombrando la capacidad.
3. *"Jidoka: quitar liga..."* → el grafo la deja de pintar.

**El webview de los comandos nuevos no lo ha visto correr nadie** (mismo estado que R1 antes de
tu F5): el contrato está linteado y el módulo probado, pero los QuickPicks en pantalla son tu parte.
