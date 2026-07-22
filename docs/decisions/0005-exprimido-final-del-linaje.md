# ADR 0005 — El exprimido final del linaje: última cosecha y archivado de los repos de método

- **Estado:** aceptado
- **Fecha:** 2026-07-10

## Contexto

El ADR 0004 centralizó el grueso del conocimiento del linaje, pero dejó saldo: piezas que jidoka **cita por nombre sin contenerlas** (el protocolo de homologación), vocabulario que el Sprint 2 necesita y no existía (los estados de una nota), y todo lo que los repos produjeron *después* de aquella pasada (una auditoría nocturna desatendida, 4 ADRs nuevos del laboratorio, un sprint entero del tracker del ritual). Decisión del cliente: exprimir los cuatro repos **letra por letra**, subir todo lo que enriquezca a Jidoka, y que Jidoka quede como **la fuente de verdad definitiva del método** — el conocimiento no puede seguir regado.

Precisión del cliente, con nombre: **esto no es una migración; se construye una metodología.** Los dos repos de **método** (la doctrina y el andamio) se archivan — su razón de existir era ser absorbidos. Los dos **casos de éxito** (el laboratorio de campo y el tracker del ritual) **siguen vivos como proyectos**: alimentan el método, no se jubilan.

Cuatro agentes de extracción exprimieron los cuatro repos (129 archivos el andamio; 38+34+5 ADRs leídos completos; historial de git incluido, con dos bitácoras borradas recuperadas vía `git show`), comparando cada pieza contra jidoka antes de declararla faltante.

## Decisión

### Asciende YA (conocimiento)

| Qué | Dónde quedó |
|---|---|
| El protocolo de homologación (5 pasos, criterio-no-copia, frontera NDA, regla 2–3 de maduración, method-fiction) | `kanban/homologacion.md` |
| La doctrina de pruebas (dos capas a prueba de migración, entrada hostil con presupuesto anti-ReDoS, e2e por clave, cerrar por medición, terceros contra su fuente) | `kanban/verificacion.md` |
| Estados y prioridades (`vigente` ≠ construido, gate modulado por estado, gobernanza documental del arquetipo regulado) | `kanban/estados.md` |
| Los dos casos de éxito, con números y lecciones (anonimizados) | `docs/casos-de-exito.md` |
| El recetario de entorno Windows/PS 5.1 + "los subagentes no leen la config global" | `docs/guias/entorno-windows-powershell51.md` |
| Paso 0 (¿exploras o consolidas?), la poda, la cola de juicio del cliente, el protocolo de invariante rota, menú-no-molde operativo | `kanban/lazo.md` |
| Cómo vive el grafo en disco (híbrido links+wikilinks, carpetas planas, Mermaid, glosario SSOT), TBL/TEC, mapa a marcos | `kanban/jerarquia.md` |
| Reglas duras nuevas: una sola escritora por working tree; el diseño del tope de concurrencia ("esperanza no es barrera") | `kanban/roles.md` |
| Familia de drift / matar la fuente / GO condicionado; la corrida nocturna desatendida ([humano]/[agente], el agente no edita sus gates) | `kanban/auditoria.md` |
| Cuatro reglas de campo: baseline hacia adelante; segunda familia de barreras (proceso); principio sin mecanismo es promesa; sin descartes silenciosos; + teatro de gates (4 modos) | `andon/README.md`, `kanban/auditoria.md` |
| Estados de ADR ampliados (delegación · revisable; enmienda bidireccional; "Qué NO resuelve") | `kit/.jidoka/templates/adr.md` |
| QA desde el producto, harness headless, test de fuga por términos, before/after | `kit/.jidoka/qa_runs/README.md` |
| Ritual de release en 6 pasos + la pregunta del salto SemVer + receta de commits con acentos | `CONTRIBUTING.md` |
| El índice del corpus de fuentes (7 frentes) — el corpus mismo sigue sin ascender | `doctrina/decisiones/README.md` |
| Limpieza: referencias colgantes a `../fuentes/` en 3 docs de doctrina | `doctrina/01`, `02`, `citas-verificadas.md` |

### Amplía el registro para los Sprints 2–3 (maquinaria que espera su ritual)

**Sprint 2:** los dos SKILL.md de referencia del arquetipo doc-only quedaron en el repo archivado de doctrina (al portarlos: asiento genérico, no nombre propio) y cinco más en el laboratorio; anatomía probada de skill (gatillos naturales, "Entorno" de 5 líneas embebido, "los skills no son subagent_type", el arquitecto-doc **copia su template, nunca redacta de cero**); mecánica fina del `gemba-stop` (se auto-configura desde las áreas con `rol: revisor-visual` de la ley; "evidencia fresca" = mtime posterior al último cambio visual; marcador SHA solo como válvula del cliente; mensaje = guion de 4 pasos); `recursos-del-proyecto.md` ("lo que la sesión no debe preguntarte": material, identidades por servicio, máquinas — nunca secretos, solo punteros; `/jidoka:arranca` lo lee al abrir); la rebanada **R0 con STOP** (el QUÉ aprobado por el cliente leyendo `product/`, antes de la primera línea de código); regla del arquetipo doc-only: **no se siembra `/arranca` ni "lee el método"** — sería el camino que el ADR 0003 de la doctrina rechaza.

**Sprint 3:** el inventario exacto de los 12 templates faltantes del andamio (capacidad rica, módulo, dominio, ecosistema, solución, componente, spec, modelo-de-datos, requerimiento+backlog, proceso, glosario, propuesta-gate-proceso) + PRODUCT_BRIEF (con Landscape verificado) + HANDOFF (con columna Validación) + benchmark (licencias "verificadas en vivo, no de memoria" y nota de reconciliación); SSOT de versión (un literal, todo deriva); detalle del release podrido (el evento `release` lee el workflow **desde el commit del tag**; un builder falla con ≠0 en el punto del error; smoke por filtro de paths que publica el artefacto ANTES del tag); el **ensayo del empaquetado** (el build se autoverifica contra el manifiesto que el runtime realmente usa, no contra una lista paralela — la herramienta de copiado falla callada); gate de UX en 3 capas (lo medible bloquea, lo subjetivo es checkpoint) + rúbrica de heurísticas del revisor-visual; lint de alta señal (set corto, no muro de reglas); la matriz pieza×arquetipo del andamio como especificación funcional del instalador.

### NO asciende (sin cambio, y ahora con constancia)

- El corpus de fuentes (~1.2 MB): misma razón del ADR 0004, ahora con el detalle honesto — la PII vive también en los **metadatos de commit** (author, trailers de sesión), así que publicarlo exige historia nueva o filter-repo: decisión humana irreversible, pendiente.
- El casting con nombres propios, el código de dominio de los casos, y lo que jidoka ya evolucionó mejor (no se retrocede).
- La licencia pendiente del repo de doctrina muere con su archivado: la doctrina ya quedó licenciada MIT **vía jidoka**.

### El archivado

- **Se archivan** (GitHub archive, read-only, reversible) los dos repos de **método**: el de doctrina y el andamio. Antes del archivado, cada uno recibe una lápida en su README apuntando a Jidoka como sucesor, y el andamio corrige sus enlaces públicos a la antigua URL de la doctrina (hoy 404) para que apunten a `jidoka/doctrina/`.
- **NO se archivan** los dos casos de éxito: siguen siendo proyectos vivos. Sus lecciones futuras llegarán a Jidoka por el canal normal: la [homologación](../../kanban/homologacion.md).

## Por qué

- El ADR 0004 dejó saldo: piezas que Jidoka cita por nombre sin contenerlas y producción posterior a la primera pasada — la fuente de verdad seguía fragmentada.
- Los repos de método cumplieron su propósito al ser absorbidos; mantenerlos vivos confundiría migración con metodología.
- Los casos de éxito siguen produciendo lecciones que la homologación cosecha: archivarlos cortaría el canal de retroalimentación del método vivo.

## Lecciones de campo nuevas que este ADR deja citables (anonimizadas — continúan la lista del ADR 0004)

9. Una regla enterrada en un ítem tachado del backlog no la lee nadie: **se asciende a donde se decide.**
10. **El agente desatendido no edita sus propios gates** — y rodear la negativa del harness por shell sería el anti-patrón que la doctrina condena.
11. La remediación de una fuga **termina en la plataforma, no en el repo**: los previews por rama siguieron sirviendo la versión filtrada después del fix.
12. Un principio sin mecanismo es una promesa: el ADR se hace cumplir **por plataforma** (CSP), con el costo de salida como diseño.
13. Lo mecánico que depende de memoria humana es un proceso roto: **elimina la redundancia, no automatices la sincronización.**
14. El contrato con un tercero se verifica **contra su código fuente**, no contra su documentación.
15. Un descarte silencioso es un reporte que miente por omisión: **el silencio también se audita.**
16. Dos sesiones escritoras sobre el mismo working tree se dejan ciegos los gates mutuamente: **una sola escritora**; la segunda, worktree propio o solo-lectura.

## Deuda heredada del linaje (registrada, no resuelta)

- **La contradicción del plan efímero sigue abierta** en el laboratorio (template dice "NO se versiona"; el comando de arranque dice "escríbelo en el repo"; la práctica real lo violó dos veces citando riesgo de corte de contexto en tareas largas multi-asiento). Jidoka heredó la política "efímero"; al construir `/jidoka:arranca` (Sprint 2) hay que **zanjarla**: o una válvula de excepción definida para tareas largas, o la realidad la seguirá violando.
- Candidatos "esperan maduración" con un solo uso, detectados en la homologación del linaje: carpeta de infraestructura + CONTRIBUTING partido en 3; postmortems fechados + sección `### Security` en el changelog. Re-evaluar en la próxima pasada (regla 2–3).

## El camino que NO se toma (y por qué tienta)

**Archivar también los casos de éxito.** Tienta por simetría ("fuente de verdad única = todo lo demás se congela"). Se descarta porque confunde migración con metodología: un método vivo necesita laboratorios vivos — el laboratorio y el tracker siguen produciendo las lecciones que la homologación cosecha. Lo que se congela es lo que ya cumplió su propósito: los repos cuyo único producto era el método mismo.

**Portar la maquinaria ya** (skills, gemba-stop, auditor del grafo, templates de producto). Misma razón del ADR 0004: ejecutaría los Sprints 2–3 sin su plan ni su Gemba. El inventario quedó más fino que nunca; la máquina asciende con su sprint.

## Consecuencias

- Jidoka contiene ahora **todo el conocimiento del método** — ningún concepto vive ya solo en un repo privado. `kanban/` pasa de 4 a 7 documentos; el kit y las guías crecen.
- Los Sprints 2–3 tienen especificación casi ejecutable (mecánica del gemba-stop, matriz del instalador, inventario de templates con contenido).
- Los dos repos de método quedan read-only con lápida; los dos casos de éxito siguen vivos y la homologación queda documentada como el canal por el que sus futuras lecciones ascienden.
