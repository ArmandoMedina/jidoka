# ADR 0032 — El atlas de procesos vive en BPMN: el método se documenta como diagrama navegable

- **Estado:** aceptado
- **Fecha:** 2026-07-16

## Contexto

El método Jidoka vivía solo como prosa (comandos, doctrina, ADRs). Se generó un primer "atlas
navegable" que traduce el ritual a diagramas de proceso (25 BPMN + 1 DMN, jerarquía por Call
Activities con índice `RELACIONES.csv`), pero llegó fuera del repo, con una copia duplicada
anidada, y sin forma acordada de que el método (la IA) y el dueño (Armando) lo editaran juntos.

Antes de comprometer un formato al repo se hizo un **bake-off con evidencia**: el mismo fragmento
de `/cierra` —carriles agente/humano, gateway del gate Andon, STOP— modelado en **BPMN, Mermaid y
D2**, los tres renderizados y comparados a la vista. BPMN dio **carriles (swimlanes) reales de banda
completa** e iconografía estándar que mapea directo al método (tarea de servicio = lo del agente,
tarea de usuario = el checkpoint humano, rombo con X = gateway). Mermaid rompió los carriles (el
lane "Humano" quedó flotando, el fin fuera de todo carril). D2 se veía pulido pero sus "carriles"
eran cajas, no bandas, y el diagrama se estiraba en horizontal.

## Decisión

El atlas de procesos vive versionado en `docs/atlas/` y su formato canónico es **BPMN 2.0**.

1. Se importa limpio (sin la copia duplicada) a `docs/atlas/`; **no** entra a `docs/guias/`, así
   queda interno y no infla el paquete npm (`files` en `package.json` solo publica `docs/guias/`).
2. **Toolchain Node on-demand** en `docs/atlas/tools/`: `validar.mjs` (sin dependencias, verifica
   que todo `calledElement` resuelva y toda Call Activity esté en el CSV), `render.mjs` (SVG por
   `npx bpmn-to-image`, versionados en `docs/atlas/render/` para verse en los PRs), `layout.mjs`
   (`bpmn-auto-layout` genera la geometría). Scripts `atlas:validate|render|layout` en package.json.
3. **Ciclo de trabajo:** la IA edita la semántica del XML; Armando lo ve/afina con la extensión de
   VS Code Miragon BPMN Modeler (recomendada vía `.vscode/extensions.json`) o demo.bpmn.io.
4. **Convención BPMN-formal / Mermaid-borrador:** para acordar la *lógica* de un flujo se boceta en
   Mermaid (barato, GitHub lo pinta); una vez acordado se formaliza en BPMN. Los borradores Mermaid
   no se versionan como atlas.
5. El atlas es **AS-IS**: documenta el método como es, no afirma que sea óptimo.

## Por qué

- **La fidelidad del artefacto pesa más que la comodidad de quien lo escribe.** El atlas es para que
  *otros lo lean* (auditar el método como proceso). BPMN fue el único de los tres que dibujó los
  carriles agente/humano como bandas reales — y ese reparto es el corazón de Jidoka. Optimizar por
  la comodidad de autoría de la IA habría degradado lo que ve el lector.
- **El costo real de BPMN (coordenadas a mano) es mitigable, la pérdida de fidelidad no.**
  `bpmn-auto-layout` genera la geometría y el editor visual permite empujar cajas; el estándar, en
  cambio, no se recupera si se elige un formato que no modela swimlanes.
- **On-demand por `npx`, no dependencia dura.** `bpmn-to-image` arrastra Puppeteer/Chromium; meterlo
  a `devDependencies` haría que cada `npm install` baje Chromium — costoso y frágil en los repos con
  antivirus del entorno. Renderizar es ocasional, así que `npx` lo baja solo cuando se usa.

## El camino que NO se toma (y por qué tienta)

- **D2 o Mermaid como formato canónico.** Tienta fuerte porque son *texto plano* — nativos para la
  IA, sin coordenadas, y Mermaid además se pinta solo en GitHub sin instalar nada. Se descarta porque
  la evidencia visual mostró que ninguno hace swimlanes de banda: Mermaid dejó el carril humano
  flotando y D2 los volvió cajas. Para un mapa cuyo mensaje central es "quién hace qué: agente vs
  humano", eso no es cosmético, es perder el mensaje. Mermaid se conserva, pero como **borrador de
  lógica**, no como el atlas.
- **draw.io / imágenes sueltas.** Tienta por lo fácil de arrastrar cajas. Se descarta: no es
  diagrama-como-código (no hay diff legible ni validación estructural), y un PNG suelto miente en
  cuanto el método cambia y nadie regenera la imagen.
- **Dejar el atlas fuera del repo (o duplicado).** Tienta por inercia (así llegó). Se descarta: un
  mapa del método que no viaja con el método se pudre; y la copia anidada duplicaba 26 archivos.

## Consecuencias

- **Más fácil:** el método se puede leer y auditar como proceso; la IA edita XML y el dueño lo ve en
  vivo; los diagramas se renderizan a SVG que sí se ven en GitHub/PRs; `atlas:validate` caza enlaces
  padre→hijo rotos.
- **Más difícil / deuda:** editar BPMN a mano es verboso (mitigado, no eliminado); el render depende
  de bajar Chromium la primera vez. Al decidir esto solo `16-cierra` se re-modeló como patrón y los
  otros 24 quedaban *happy-path* — **esa deuda ya se cerró (ver Enmienda 2026-07-16).** `atlas:validate`
  **no** se cableó a Andon/CI todavía (regla 2-3: que pruebe valor antes de ganarse un gate).
- **Aviso de ley:** editar `package.json` dispara el aviso `raiz` del blast-radius (se anota en
  HANDOFF); el ADR se lista en el índice en el mismo commit (bloqueo duro del área `decisiones`).

## Enmienda (2026-07-16) — el atlas completo, sin happy-path

La deuda de "solo `16-cierra` re-modelado" se cerró en el mismo arco: **los 25 diagramas de proceso
del atlas están re-modelados** con carriles (donde hay actor humano) y gateways (donde hay decisión);
los procesos de puro motor van en un carril único. También se cableó el acoplamiento del atlas al flujo
como **aviso comando→diagrama** (ADR [0033](0033-acoplamiento-proceso-docs-diagrama.md)). Sigue abierto
solo lo dicho arriba: `atlas:validate` no se cableó a un gate todavía (regla 2-3).

---

> Reglas del registro: una decisión = un archivo · al agregarlo, **listalo en el [índice](README.md) en el mismo commit** (el gate lo exige) · nunca borres una decisión: márcala *reemplazada* y enlaza la nueva.
