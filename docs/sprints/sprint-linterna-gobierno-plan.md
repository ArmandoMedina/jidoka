# Sprint — La linterna del gobierno (plan-contrato)

> Contrato R0 aprobado por el cliente el **2026-07-19** (sesion de `/jidoka:descubre` + plan mode formal).
> El QUE se descubrio con hechos, no hipoteticos. Este documento es el contrato archivado; la
> evidencia de cada rebanada vive en `qa_runs/` y en los self-tests.

## R0 — El QUE (aprobado, con nombre)

**Aprobacion nombrada del cliente:** *"la linterna del gobierno: ver toda la infraestructura
determinista (gates, hooks, CI, blast-radius, docs) y los caminitos de validacion en un grafo de
solo-lectura, leido de la ley real; metrica cero huerfanos; primer sprint = la vista de un repo real
generada de lo que ya existe."* + apetito **varios sprints** (este plan cubre el primero).

### El problema (hecho real)
En `entisoft-rescate`, Claude genero archivos ("candy" + auditoria) que quedaron **huerfanos** del
gobierno; la maquina se puso necia ("documentos sin trackear / blast-radius"). Parche de hoy: *"le digo
que lo arregle, lo hace, pero no se que hace -- miles de cambios, decenas de commits, horas revisando, y
sigue siendo **juez y parte** porque el me explica."*

### El porque profundo (el cliente, textual)
*"El proyecto ya trae una barrera de entrada bien grande porque ya no es solo instalo y ya, ya tienes
que conocer el proceso para asegurar que funcione bien, y como el mismo Jidoka predica no puedes
confiarle todo a la IA."* La linterna **baja la barrera de entrada** sin traicionar "no confies todo a
la IA": el humano ve y duena el gobierno con sus ojos, no siendo mecanico de JSON.

### Metrica objetivo (contable)
**Documentos huerfanos = 0** en un repo brownfield (o declarados libres a proposito). La linterna la cuenta.

### Autoridad y criterio de "hecho"
El cliente, viendolo: abre el `.html` en un repo real y **ve** la maquina (huerfanos en rojo, gates
vivo/dormido) **sin codigo ni terminal**. Evidencia = `qa_runs/linterna-<fecha>/LOG.md`.

### Restriccion dura (ADR 0002, congelado)
Prohibido API/MCP/servidor **como capa de gobierno**. La linterna es un **reporte estatico** (un `.html`
que se abre con doble clic), como `estado-docs.ps1` o los SVG del atlas -- no gatea nada, nadie la llama.
Nace **vista, no muro** (regla 2-3), como el atlas (ADR 0035).

## Decisiones de diseno (del cliente)
- **Render:** HTML autocontenido interactivo (force-directed, JS vanilla inline; cero deps, cero servidor).
- **Linaje:** familia `estado-*.ps1` (PS 5.1 ASCII), no Node -- para que **se siembre** a los hijos.
- **Primer corte:** toda la topologia del gobierno (no solo docs).
- **La linterna NO inventa verdad:** deriva el grafo de las fuentes que ya existen (misma fuente que gatea).

## Las rebanadas (verticales; cada una se ve corriendo)

### R1 — La linterna: esqueleto + huerfanos
`tools/estado-gobierno.ps1` lee `blast-radius.json` + `docs-gobernados.json`, deriva areas/gates/docs,
detecta **huerfanos** con el matcher de `verificar.ps1` (patron sin `/` = solo raiz), y emite `.html`
con grafo force-directed: areas, gates (VIVO/DORMIDO), docs (conforme/desviado), **huerfanos en rojo** +
**contador de huerfanos** (la metrica visible).
- **Pruebas/evidencia:** `tools/probar-linterna.ps1` (patron `probar-docs.ps1`: fixture git temporal con
  un archivo huerfano -> el HTML lo marca rojo y cuenta 1; repo sin huerfanos -> 0; ROJO->VERDE). Demo
  Gemba: abrir el `.html` sobre `entisoft-rescate`, ver "candy"/auditoria en rojo, sin terminal.

### R2 — La topologia completa + interactividad
Suma **hooks** (`.claude/settings.json`), **checks de CI** (`andon.yml`), **capacidades** (grafo de
`auditar.ps1` via un modo `-Grafo`/`-Json` nuevo), y **aristas tipadas** (dura vs blanda vs product).
Consolida el vivo/dormido en `rutear.ps1 -Json` (fuente unica, sin 6.a copia de la regla). Interactividad:
filtrar por tipo, hover con el "por que" (campo `desc`/`mensaje`), clic que resalta vecinos.
- **Pruebas/evidencia:** casos nuevos en `probar-linterna.ps1` (cada tipo de nodo; gate DORMIDO se pinta
  inactivo, no ausente); `probar-auditor.ps1` cubre `-Grafo`. Demo: abrir sobre el propio repo Jidoka.

### R3 — Siembra + cablear a la maquina
- Manifiesto: 2 entradas `clase: mecanica` en `kit/.jidoka/instalar/manifiesto.json` (-Actualizar converge).
- Preflight/CI: `'probar-linterna'` en `tools/publicar.ps1` y `.github/workflows/andon.yml` (poka-yoke:
  `probar-publicar.ps1` bloquea si falta).
- ADR "la linterna es vista, no gate" + indice `docs/decisions/README.md`; `andon/README.md`, `CHANGELOG.md`, `HANDOFF.md`.
- **NO cablear a Andon** todavia (regla 2-3): que pruebe valor como vista antes de ganarse un gate.
- **Pruebas/evidencia:** suite completa verde en preflight; `-Actualizar` sobre un hijo-fixture baja la linterna.

## Fuera de este sprint (horizonte, registrado)
Caminitos animados (trazar un cambio por los gates) · atlas vivo que jubile al BPMN dibujado a mano ·
edicion desde la UI (solo si la vista prueba valor; toca ADR 0002 de frente y sube la barrera que se busca bajar).
