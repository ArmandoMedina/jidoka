---
tipo: analisis
estado: en_revision
---
# Auditoría 1+5 — Los documentos y la ley que los vigila (2026-07-16)

> **Qué es esto:** dos de las cinco auditorías de la sesión del 2026-07-16 pedidas por el cliente: (1) inventario de todos los documentos — qué función tienen, cuándo se leen, cuándo se editan — y (5) coherencia de la ley (`tools/blast-radius.json`) contra el árbol real. Se auditó sobre `v1.18.0` (`affb44e`). Barrido por subagente `explorador` + verificación en sesión contra la ley y `tools/verificar.ps1`. Los hallazgos del barrido que NO sobrevivieron la verificación están acusados al final — no se publican hallazgos sin verificar.

## El panorama en números

~95 documentos `.md` rastreados (sin contar `qa_runs/` ni renders del atlas). El núcleo del método está bien traqueado: HANDOFF, CHANGELOG, brief, infra, ADRs + índice (el único bloqueo duro, a propósito), comandos, skills, disparos y plantillas del ritual tienen **lectura declarada** (inyección `@` o invocación) y **edición vigilada** (la ley o el propio ritual los escribe). La cola larga son ~25-30 docs de referencia (doctrina de contexto, guías, docs del kanban, índices) que **se editan vigilados pero nada los lee en runtime**.

## Hallazgos verificados

### A. La ley tiene huecos de cobertura reales (auditoría 5)

1. **`bin/jidoka-method.js` — el CLI npx — no lo vigila ninguna área.** El área `barreras` cubre `tools/*` pero no `bin/`. Es pieza de motor publicable (pendiente `npm publish`) con cero vigilancia y sin `revisa: true`. Se puede editar el CLI sin que ningún gate avise nada.
2. **4 archivos legítimos de raíz fuera de la lista `excluye` del área `raiz`:** `CODE_OF_CONDUCT.md`, `package.json`, `package-lock.json`, `jidoka.code-workspace`. La `fuente: ["*"]` del área los casa al modificarlos → aviso falso "apareció un archivo suelto en la raíz" en cada cambio legítimo (p. ej. cualquier release que toque `package.json`).
3. **El acoplamiento del atlas es unidireccional a propósito (ADR 0036) — y el otro sentido quedó sin nada.** Cambiar un comando avisa "actualiza el diagrama"; editar un `.bpmn` o el toolchain (`docs/atlas/tools/*.mjs`) no dispara ni un aviso de CHANGELOG. El atlas puede driftear en silencio en la dirección opuesta (y ya pasó: ver el informe del atlas de esta misma sesión).
4. **`product/**` no es `fuente` de ninguna área.** Editar el brief, la infra o una capacidad no dispara nada. La integridad *estructural* la cubre `auditar.ps1` (frontmatter, wikilinks, Gherkin), pero la co-ocurrencia con el motor no la mide nadie. Los `product_avisa` apuntan HACIA product, nunca DESDE product.
5. **`docs/guias/`, `docs/analisis/`, `docs/sprints/` tampoco son fuente de ninguna área.** Tres guías viajan como motor en el manifiesto del kit; editarlas no avisa nada (ni CHANGELOG). Los planes de sprint son contratos que no deberían cambiar tras aprobarse — y nada lo detecta si cambian.

Lo positivo: **todos los destinos que la ley promete existen** (índice de ADRs, `kit/.jidoka/disparos/README.md`, `doctrina/citas-verificadas.md`, `andon/README.md`, las 3 capacidades), el matching falla cerrado (exit 2), y el único bloqueo duro es el declarado en CONTRIBUTING.

### B. Docs con edición vigilada pero sin lector (auditoría 1)

Estos NO son huérfanos de la ley (el área `metodo` avisa CHANGELOG al tocarlos), pero **ningún comando, skill, tool ni hook los lee**; su única función es que un humano los abra por iniciativa propia:

- `kanban/jerarquia.md`, `kanban/verificacion.md` — cero referencias en runtime (verificación cruzada con la prueba de vida: cero señal de consulta en 13 corridas de `qa_runs/`).
- `kanban/auditoria.md`, `kanban/homologacion.md` — su único lector real es el atlas (los diagramas 70-72 los declaran como Fuente).
- `docs/atlas/RUTA-SUGERIDA.md`, `docs/atlas/VALIDACION.md`, `kit/.jidoka/templates/README.md`, `doctrina/01/02/05/07` — referencia humana pura.
- Las guías (`empezar-de-cero`, `entorno-windows-powershell51`, `mantener-el-motor-al-dia`) se **linkean pero nunca se inyectan**: están "ahí" sin llegar al contexto de una sesión. Para la guía de entorno esto es una decisión defendible (el recetario es largo); para las otras es simplemente su naturaleza de guía.

**La pregunta que esto abre no es "¿bórralos?" sino "¿quién es su consumidor?"**: si el consumidor es el lector humano del método (plausible para doctrina y kanban), son vitrina y está bien; si nadie los abre nunca (medible con #66), son ceremonia. La prueba de vida de esta misma sesión da datos por pieza.

### C. Menores

- Los disparos se inyectan pieza a pieza pero **ningún mecanismo enseña el listado completo en sesión** (el `arranca` no los enumera; `andon/README.md` sí). Cosmético.
- `docs/decisions/0000-plantilla.md` duplica función con `kit/.jidoka/templates/adr.md`.

## Hallazgos del barrido DESCARTADOS al verificar (se acusan por honestidad)

El subagente reportó tres hallazgos "graves" que la verificación contra la ley tumbó — el patrón de error fue confundir "no tiene un `doc_avisa` dedicado" con "no está vigilado":

1. ~~"`doctrina/00-tesis.md` se edita sin aviso"~~ — FALSO: el área `doctrina` (`fuente: ["doctrina/*"]`) lo cubre y avisa disparos + ledger de citas.
2. ~~"`andon/README.md` puede divergir de la ley sin detección"~~ — FALSO: `tools/blast-radius.json` está en la fuente del área `barreras`, cuyo `doc_avisa` es exactamente `andon/README.md`.
3. ~~"cambiar un comando no avisa a las capacidades de product"~~ — FALSO: el área `ritual` tiene `product_avisa: ["product/capacidades/RIT-*"]`.

## Veredicto

El traqueo del núcleo es real y mejor de lo que el barrido inicial sugería. Los huecos verificados son **de cobertura de la ley** (bin/, product/, docs/ no-decisiones, 4 exclusiones de raíz) y **de lectores** (una cola de docs de referencia que nada consume en runtime). Nada de esto es un muro roto; es superficie sin vigilar y prosa sin consumidor declarado.

## Limitaciones

- "Nadie lo lee" = ninguna pieza de maquinaria lo lee; la lectura humana espontánea no deja rastro (conecta con #66, telemetría de lecturas).
- Corte de evidencia: 2026-07-16, `v1.18.0` (`affb44e`).
