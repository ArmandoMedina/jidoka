# Sprint «El atlas dice la verdad» — plan

> Plan-contrato aprobado por el cliente el 2026-07-16 (aprobación nombrada vía plan mode). El QUÉ se descubrió a lo largo de la sesión de auditoría de fidelidad del atlas.

## Contexto (por qué ahora)

Esta sesión auditó los 24 diagramas AS-IS del atlas **contra su fuente real** (comando `.md` o script `.ps1`), con cada hallazgo verificado y con cita de la fuente. Resultado: **14 fieles, 10 desviados.** La nave predica *"doc↔código sincronizado con gate determinista"* y su propio atlas se desincronizó: un diagrama inventa pasos, varios omiten lógica real del método, y falta dibujar la ruta de instalación AV-segura que el autor sí usa.

Aprendizaje de tooling que salió a la luz: **auditar el atlas contra el disco miente cuando hay piezas `skip-worktree`** (`instalar.ps1` está en git pero en cuarentena AV → una auditoría de disco lo dio por inexistente). Se registra como issue aparte, no entra a este sprint.

## Veredicto de fidelidad (la base del trabajo)

**FIEL (14):** 00, 01, 02, 03, 04, 14-revisión, 15-gemba, 16-cierra, 17-que-sigue, 18-desatendido, 40-estado-motor, 41-actualizar, 80-publicar, 81-preflight. — No se tocan.

**DESVIADO (10):**
- **10-arranca** — INVENTA (bucle "¿falta contexto?→aclaración", tarea "leer doc activada"); OMITE (§3 el asiento, §5 reglas duras, lecturas de PRODUCT_BRIEF y CONTRIBUTING); router en carril Motor en vez de Agente.
- **11-descubre** — falta el Paso 0 (leer brief existente); el gateway del juez de verdad mal ubicado.
- **13-construye-rebanada** — falta el Paso 0 "mientras exploras, nada de la maquinaria corre" (`kanban/lazo.md`).
- **70-auditoria-en-rama** — falta el paso 6 "descartado a propósito"; orden invertido del paso 7.
- **71-auditoria-nocturna** — no modela el "click-it-down" (la regla más importante del modo desatendido).
- **72-homologacion** — la frontera NDA no tiene salida de "violación → se reescribe".
- **30-instalar** — funde 4 pasos en uno, invierte orden destino↔arquetipo, no muestra el no-clobber del sello.
- **42-sellar** — omite la guarda de sello preexistente y la clasificación pristina-vs-customizada.
- **12-planea** — borde menor (residuo de descubre no marcado pendiente).
- **44-reportar-leccion** — el diagrama pinta el ritual humano completo pero su `Fuente:` solo cita el script.

**Hueco (ausencia, no desvío):** no hay diagrama de `sembrar-manual.ps1` (el instalador AV-seguro, ADR 0027).

## Decisiones del cliente (2026-07-16)

1. **Reparto:** el agente arregla el **contenido/fidelidad** (qué nodos existen y su lógica) y lo acomoda funcional; **el cliente da el pulido visual final** en su editor.
2. **Profundidad:** R1–R4 completas; en R4 los menores (12, 44) se arreglan si es barato o se anotan como compresión deliberada.

## Alcance en rebanadas verticales

Cada rebanada = diagramas fieles + `atlas:validate` verde + render inspeccionado a la vista. Ninguna toca la ley; el área `atlas` solo avisa.

- **R1 — insignia + informe durable:** `docs/analisis/fidelidad-atlas-202607.md` (tabla verificada con citas) + `10-arranca-con-subprocesos.bpmn` fiel a `arranca.md`.
- **R2 — ruta AV-segura:** `31-sembrar-manual-as-is.bpmn` (nuevo, de `sembrar-manual.ps1`) + enlace desde `02-instalar-mantener-metodo.bpmn`.
- **R3 — omisiones de lógica:** 11, 13, 70, 71, 72 — agregar el paso/rama real omitido en cada uno.
- **R4 — motor y menores:** 30, 42 (vs `instalar.ps1` real de git); 12, 44 (arreglar o anotar deliberado).

## Método de trabajo (la receta que costó 2 chats redescubrir)

- **Layout a mano (DI manual), no auto-layout.** Rejilla de la sesión de la mañana: pool/carriles como bandas completas; tareas 150×80 (o ×60 según densidad); gateways 50×50; eventos 36×36; espaciado horizontal ~190px; rótulos de gateway encima del rombo. Patrón de referencia: `16-cierra-as-is.bpmn`.
- **Ver, no adivinar.** Tras cada edición: `npx --yes bpmn-to-image "ruta/x.bpmn;docs/atlas/render/x.png"` (rutas relativas, separador `;`) → abrir el PNG → confirmar a la vista antes de seguir.
- **Scripts `.ps1` `skip-worktree` se leen de git** (`git show HEAD:tools/instalar.ps1`), nunca del disco.

## Verificación (el demo que corre el cliente — sin código ni terminal)

`owner: cliente`. Verifica **abriendo los diagramas renderizados**:
- 10-arranca muestra las 6 secciones reales de `arranca.md` (con §3, §5, brief/CONTRIBUTING) y ya no el bucle inventado.
- Existe el diagrama de `sembrar-manual.ps1`.
- Cada diagrama de R3 muestra el paso real que faltaba.
- El informe de fidelidad existe como archivo del repo.
- Cierre técnico: `npm run atlas:validate` sin huecos; cada diagrama tocado re-renderizado y mostrado para OK visual.

## Lo que NO entra (no-metas)

- No se re-maquillan los 14 fieles. No se tocan las fuentes reales.
- No se arregla la lección de tooling (`auditar`/atlas leen disco, no ven `skip-worktree`) — issue `leccion` aparte.
- El pulido visual fino lo hace el cliente; el agente entrega fidelidad + layout funcional legible.
