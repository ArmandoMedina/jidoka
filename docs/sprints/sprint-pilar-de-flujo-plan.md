# Sprint «El pilar de flujo» — FLU-1 · plan aprobado

> **Plan aprobado en plan mode el 2026-07-21.** **Este plan ES el sprint**: lo que no está aquí, no entra (frontera en «Lo que NO entra»). El QUÉ se recuperó de la sesión anterior del mismo día (alcance aprobado con «quiero todo»), más dos adiciones aprobadas en esta: el reparto de roles humanos/agentes (R8a) y el contrato del CHANGELOG (R4). Versión objetivo: `v1.28.0` (MINOR) + ADR 0049 (renumerado desde 0045 al reconciliar con `main` v1.27.0, que ya tomó 0045-0048).

## Contexto (por qué)

La Casa del TPS tiene dos pilares; el método construyó Jidoka (parar ante el defecto) con dientes y **el pilar de flujo (JIT) no existe**. Medido, no opinado (`docs/analisis/gemba-gestion-del-flujo-202607.md` + `benchmark-flujo-202607.md`): HANDOFF de 419 líneas que nunca se limpia, ROADMAP que solo crece (70× en el lab), cola de Gembas vencidos, cero issues como flujo, y toda la capa de gestión es prosa que depende de que alguien se acuerde — «si depende de que el modelo coopere, no es muro». La advertencia de los 4 frentes del benchmark: **todo tiene que ser código que rechaza la acción**.

## La capacidad

**`FLU-1-pilar-de-flujo`** — los documentos que cargan el estado dejan de crecer solos, el trabajo entra con límite, y el avance y el reparto de roles se ven sin terminal.

## Decisiones del cliente (con fecha)

- **2026-07-21 · Alcance:** «quiero todo» — las 8 rebanadas, nada se poda; se entrega en secuencia M1→M2→M3 (el orden lo dicta la dependencia).
- **2026-07-21 · Apetito: 6 horas de revisión del cliente, tope duro con muerte por defecto** — si se consumen sin entregar, el sprint muere y se re-shapea (no se extiende). Primer uso del circuit breaker sobre nosotros mismos.
- **2026-07-21 · Takt declarado:** ~4 h/día del cliente para jidoka, ~1 h/día para enti; WIP inicial por ley de Little: ~8 (jidoka) / ~3 (enti), a calibrar.
- **2026-07-21 · Tauri:** el otro agente se queda en la tubería de configuración; este sprint entrega **motor + contrato JSON**, cero UI nueva.
- **2026-07-21 · CHANGELOG:** no está roto pero «cambia mucho de estructura; parece un entregable de correo, no algo operativo» → R4 le da estructura fija gobernada.
- **2026-07-21 · Roles:** los asientos-agente son los mismos en casi todos los proyectos; lo que varía es el lado humano. Diseño resultante en R8a: separar **autoridad del dominio** («el que sabe») de **dueño-operador del método**. En jidoka ambos son el cliente; en enti la autoridad es Marcelo y el cliente es dueño-operador.
- **2026-07-21 · Enti no se toca** este sprint; su reparto se entrega como análisis solo-lectura + molde sembrable (patrón linterna); baja después con `-Actualizar`.

## Alcance — 9 rebanadas en 3 movimientos (cada una commiteable y verde sola)

### M1 — Los documentos dejan de crecer (*pull, no push: lo que no se lee, no se inyecta*)

**R1 — El contrato del HANDOFF.** `HANDOFF.md` queda con **1 sección «Dónde estamos» + máximo 2 «Dónde estuvimos»**; todo lo anterior se muda a `docs/handoff-historico.md` (nuevo, **nunca inyectado por `/arranca`**). El gate: nuevo check determinista en `tools/verificar.ps1` (patrón de los checks de área, `tools/verificar.ps1:123-178`) que cuenta secciones `## Dónde` y techo de líneas (~120) del HANDOFF → **BLOQUEA** al pasarse. Incluye la migración inicial (las ~10 secciones viejas al histórico). *Toca la ley/motor: sí (verificar.ps1).* — Lo ves: `/arranca` te inyecta ~40 líneas, no 419.

**R2 — El contrato del ROADMAP.** `ROADMAP.md` se reestructura en **4 clases de servicio** (urgente / con-fecha / normal / algún-día), y cada ítem vivo declara `[clase · fecha-alta · apetito]`. No se rankea: se clasifica (Anderson: ordenar el backlog es desperdicio). Gate en `verificar.ps1`: ítem sin clase/fecha/apetito → BLOQUEA; techo de líneas del ROADMAP vivo. Migración inicial del ROADMAP actual (141 líneas: lo cumplido se va al CHANGELOG/histórico, lo vivo se clasifica). *Toca motor: sí.* — Lo ves: el ROADMAP cabe en una pantalla.

**R3 — La expiración automática.** `tools/expirar.ps1` (nuevo, mecánica): calcula la edad de cada ítem contra su apetito/fecha; lo vencido se mueve **por script, no por juicio** a `docs/MUERTOS.md` con fecha y motivo; vuelve solo si alguien lo re-propone. Corre como paso obligatorio de `/jidoka:cierra` y como aviso en `/arranca` («N ítems por vencer»). — Lo ves: el ROADMAP es más corto que ayer, y ves qué murió y por qué.

### M2 — El trabajo entra con límite (*la restricción es tu revisión; frenar aguas arriba*)

**R4 — El cierre estandarizado + el contrato del CHANGELOG.** `cierra.md` gana el procedimiento fijo: qué escribe en cada doc (HANDOFF→ROADMAP→CHANGELOG→índices), en qué orden, y **qué verifica antes de declarar cerrado** (corre `verificar` + `expirar` + el check de flujo). El CHANGELOG entra al ledger `tools/docs-gobernados.json` (patrón KIT-2, `tools/estado-docs.ps1`) con estructura fija por versión (Agregado/Cambiado/Arreglado — deja de ser «carta») — aviso primero, muro cuando madure (regla 2-3). *Toca motor: sí (cierra.md, ledger).* — Lo ves: el cierre deja de depender de que te acuerdes, y el CHANGELOG se lee igual en toda versión.

**R5 — El límite WIP / Gemba vencido.** Ledger nuevo `tools/flujo.json` (instancia): sprint activo, gembas pendientes de aceptación (`aceptado: true/false` con fecha), cola bloqueada por terceros. `tools/estado-flujo.ps1` (nuevo, mecánica) lo lee y **`/jidoka:planea` gana un preflight `!` que se planta** si hay Gemba pendiente — imprime `[BLOQUEA] Gemba vencido: <cuál>` y el comando no avanza a R0 (mismo estilo determinista del preflight de arranca; regla del clasificador: sin `for`/variables de shell). El WIP configurado (8/3) vive en `flujo.json`. *Toca motor: sí.* — Lo ves: intentas abrir sprint y el comando se planta nombrándote cuál Gemba lo bloquea.

### M3 — El avance y los roles se ven (*gestión visual: el estado se ve sin preguntar*)

**R6 — La vista de «qué sigue».** `estado-flujo.ps1 -Json` emite el contrato (sprint activo, siguientes 3 por clase de servicio, bloqueados-por-tercero, gembas pendientes) — la cara la pinta el Tauri después. Cableado del **primer hook `SessionStart`** del repo (`.claude/settings.json`, hoy sin ninguno): al abrir sesión se inyecta el resumen determinista — ya no depende de que un comando se acuerde. *Toca motor: sí (settings.json sembrado, hooks).* — Lo ves: abres sesión y lo primero es qué sigue y qué espera a Marcelo.

**R7 — El reporte de avance.** `tools/reporte-avance.ps1` (nuevo, mecánica): emite un `.html` autocontenido (patrón linterna, cero deps) con **hill chart** (subiendo/bajando la loma, sin porcentajes — Basecamp) + 5 secciones sin jerga: qué cerró, qué está en curso, qué espera a la autoridad, qué murió, qué sigue. — Lo ves: lo abres, lo entiendes en <5 min y se lo mandarías a Marcelo o a tu socio tal cual.

**R8a — El reparto de funciones (NUEVO — pedido 2026-07-21).** El análisis: qué funciones existen en cada proyecto y quién las toma. Diseño: **dos roles humanos separados** — la **autoridad del dominio** (el que sabe: acepta reglas de negocio, sus horas son la restricción) y el **dueño-operador** (prioriza, presupuesta, corre el método) — + los asientos-agente fijos con su **carta SÍ-le-toca / NO-le-toca** (del benchmark, frente 4). Entregables: `product/casting.md` (la casa propia del casting — sale de `infra.md`; `arranca.md` y el ledger de docs-gobernados se actualizan) con el mapa de **jidoka** lleno; el mapa de **enti** como análisis solo-lectura en `docs/analisis/` (Marcelo = autoridad, cliente = dueño-operador, sus agentes por asiento); template sembrable `kit/.jidoka/templates/casting.md`. *Toca motor: sí (arranca.md, ledger, kit).* — Lo ves: abres un doc y sabes qué hace cada quien — tú, Marcelo, y cada agente — y qué NO le toca.

**R8b — El casting con enfoque real.** Los 4 agentes (`.claude/agents/*.md`) ganan **personalidad y enfoque conductual** conforme al reparto de R8a: cómo piensa cada uno, qué reporta por su cuenta («lo que notó sin que se lo pidieran»), y su alcance negativo ampliado. `probar-agentes.ps1` se amplía para exigir las secciones nuevas. Bajan a todos los proyectos vía kit (los asientos son los mismos en todos — decisión del cliente). — Lo ves: delegas y se nota que piensan distinto; el criterio honesto del R0: *si al verlo no sientes la diferencia, no cuenta como hecho*.

## Archivos (blast radius)

- **Nuevos (mecánica):** `tools/estado-flujo.ps1` · `tools/expirar.ps1` · `tools/reporte-avance.ps1` · `tools/flujo.json` (instancia) · `tools/probar-flujo.ps1` (tests de los 3).
- **Nuevos (docs):** `docs/handoff-historico.md` · `docs/MUERTOS.md` · `product/casting.md` · `docs/analisis/reparto-enti-202607.md` · `kit/.jidoka/templates/casting.md`.
- **Se tocan:** `HANDOFF.md`, `ROADMAP.md` (migraciones R1/R2) · `tools/verificar.ps1` (checks R1/R2) · `tools/docs-gobernados.json` + `tools/estado-docs.ps1` si hace falta (R4/R8a) · `.claude/commands/jidoka/{arranca,planea,cierra}.md` · `.claude/settings.json` + hook nuevo `SessionStart` (R6) · `.claude/agents/*.md` (R8b) · `tools/probar-agentes.ps1`, `tools/probar-hooks.ps1`, `tools/probar-preflight.ps1` · manifiesto del kit (siembra de piezas nuevas) · `product/capacidades/FLU-1-pilar-de-flujo.md` (nueva, con Gherkin — el auditor la exige) · `CHANGELOG.md`, ADR 0049 + índice.
- **Ley (`tools/blast-radius.json`):** las piezas nuevas caen en áreas ya vigiladas (`barreras`/`ritual`/`raiz`); si `verificar` acusa hueco, se declara área `flujo` en el mismo commit (dogfooding — como hizo la linterna con `extension`).

## Pruebas por rebanada (evidencia-no-palabra, declarada de antemano)

- R1/R2: casos ROJO→VERDE en `probar-gate.ps1`/nuevo `probar-flujo.ps1` (HANDOFF con 3 históricas → BLOQUEA; ítem sin clase → BLOQUEA).
- R3: fixture con ítem vencido → corre `expirar` → aparece en MUERTOS con fecha/motivo; ROADMAP más corto.
- R4: `estado-docs` acusa CHANGELOG desviado en fixture; cierre sin pasos → gate lo acusa.
- R5: `flujo.json` con Gemba pendiente → preflight de `planea` imprime `[BLOQUEA]` (caso en `probar-preflight.ps1`).
- R6: `estado-flujo -Json` validado contra esquema; hook SessionStart con prueba de vida en `probar-hooks.ps1`.
- R7: HTML generado en `.jidoka/` y capturado a `qa_runs/`.
- R8: `probar-agentes.ps1` exige secciones nuevas; suite completa `publicar -SoloVerificar` verde al final de cada movimiento.

## Verificación (el demo que corre el cliente) — `owner: cliente`, sin código ni terminal

1. **M1:** abres `HANDOFF.md` y `ROADMAP.md` en GitHub/VS Code — el HANDOFF tiene 1 «Dónde estamos» y cabe en una pantalla; el ROADMAP muestra las 4 clases; `docs/MUERTOS.md` lista qué murió, cuándo y por qué.
2. **M2:** me pides abrir un sprint nuevo con un Gemba pendiente anotado — ves el comando plantarse nombrando cuál. El CHANGELOG se lee con la misma estructura en sus últimas versiones.
3. **M3:** abres una sesión nueva — lo primero que ves es qué sigue y qué espera a Marcelo, sin pedirlo. Abres `reporte-avance.html` y decides si se lo mandarías a Marcelo tal cual. Abres `product/casting.md` y me dices si el reparto (tú, Marcelo, los asientos) responde tu «no sé cómo ponerme en enti». Delegas una tarea y juzgas si los asientos piensan distinto.
4. Todo queda con `LOG.md` en `qa_runs/flujo-<fecha>/` (el listón).

## Lo que NO entra (frontera explícita)

- **Ninguna UI nueva** — el JSON es el contrato; la cara es del agente del Tauri.
- **Enti no se escribe** — solo lectura para el análisis de R8a; la bajada es post-sprint con `-Actualizar`.
- **Nada de Scrum importado**: ni story points, ni velocity, ni standups, ni RACI formal.
- **Ningún asiento-capataz**: reglas que rechazan, no un rol que persigue.
- **La coordinación multi-máquina de escritores** (3 frentes + rama del socio): registrada como decisión abierta del diagnóstico; NO se resuelve aquí — este sprint escribe solo en jidoka, en rama. Va al ROADMAP con clase.
- **PreCompact hook y permisos allow/ask/deny** (hallazgos del censo): registrados al ROADMAP clasificado, no se construyen aquí.

## Orden y regla de vida

M1 → M2 → M3 (la dependencia: R6 lee clases de R2; R7 necesita MUERTOS de R3; R5 necesita la definición de aceptación de R4). Cada rebanada cierra verde antes de abrir la siguiente. **Si las 6 horas de revisión del cliente se consumen: el sprint muere donde va y se re-shapea** — M1 solo ya alivia la sesión.
