# Sprint Descubre — La capa de consultoría: `/jidoka:descubre`

> Plan aprobado en plan mode el 2026-07-14. **Este plan ES el sprint**: lo que no está aquí, no entra (ver "Lo que NO entra").

## Contexto (por qué)

El método funciona cuando el cliente trae el QUÉ claro (caso de éxito: SGI) y patina cuando no (dos despliegues reales). Tres diagnósticos de campo sobre los chats + investigación de metodologías (TPS, product discovery, elicitación, literatura LLM 2025) establecieron: (a) el QUÉ vive en **ejemplos concretos**, no en documentos; (b) **STOP no es comprensión** — los checkpoints se vacían cuando el humano no puede juzgar (dominio, vocabulario, cansancio); (c) a veces la autoridad del dominio es **un tercero que no usa la IA**. `planea.md` detectaba la niebla pero solo la marcaba como pendiente — no la disolvía. Detalle y porqués: ADR 0031.

## Encuadre de producto (validado con el cliente)

Cuando el QUÉ está borroso, el operador corre `/jidoka:descubre` y el método le **saca la sopa con una entrevista mecánica**: diagnóstico de una pregunta (3 nieblas + quién es el juez de verdad), rondas de preguntas fijas que exigen hechos pasados (filtro Mom Test), salida a un `PRODUCT_BRIEF.md` sin huecos con **aprobación nombrada**. Si el juez de verdad es un tercero sin IA, el ritual produce un **kit de entrevista portátil** y recibe sus respuestas como evidencia.

## Decisiones del cliente (2026-07-14)

- La capa de consultoría se construye como sprint formal (aprobación nombrada en sesión).
- **Caso del experto tercero:** es *autoridad, no usuario* — kit portátil de ida, evidencia rastreada de vuelta; no se le pide operar la IA.
- **"Ya son muchos documentos y la IA no los va a leer"** → regla de diseño: la lectura se **inyecta** (@-include en comandos), no se encarga; el descubrimiento no crea docs permanentes nuevos (extiende el brief de una página); la ley vigila el drift.

## Alcance (rebanadas verticales)

1. **R1 — El ritual núcleo:** comando `.claude/commands/jidoka/descubre.md` (diagnóstico + rondas por ruta + filtro Mom Test escrito + @-include del brief) y campos nuevos en `kit/.jidoka/templates/PRODUCT_BRIEF.md` (caso concreto · métrica con número · autoridad del dominio · criterio de "hecho" · apetito · no-metas · aprobación del QUÉ).
2. **R2 — Autoridad tercera:** plantilla `kit/.jidoka/templates/kit-entrevista.md` + Paso 3 del comando (kit portátil, vuelta como evidencia `docs/gemba/`, formato de validación del experto).
3. **R3 — Aprobación nombrada + ruteo:** disparo 14.º `aprobacion-nombrada` (cableado en `descubre`, nombrado en `planea`), caso ROJO→VERDE en `probar-disparos.ps1` (13→14), y `planea.md` R0 rutea a `/jidoka:descubre` ante QUÉ ambiguo.
4. **R4 — Registro y release:** ADR 0031 + índice, CHANGELOG `[1.13.0]` + SSOT (version.txt/package.json), README (la capa de consultoría), este plan archivado + índice de sprints, evidencia en `qa_runs/descubre-20260714/LOG.md`, release `v1.13.0`.

## Archivos

Nuevos: `.claude/commands/jidoka/descubre.md` · `kit/.jidoka/templates/kit-entrevista.md` · `docs/decisions/0031-capa-de-descubrimiento.md` · este plan. Tocados: `kit/.jidoka/templates/PRODUCT_BRIEF.md` · `.claude/commands/jidoka/planea.md` · `kit/.jidoka/disparos/README.md` · `tools/probar-disparos.ps1` · `CHANGELOG.md` · `tools/version.txt` · `package.json` · `README.md` · `docs/decisions/README.md` · `docs/sprints/README.md` · `HANDOFF.md`. Ley: áreas `ritual`, `kit`, `disparos`, `decisiones`, `raiz` (escribano; `andon-stop` + `review-stop` en kit). El manifiesto siembra `.claude/commands` y `kit/` como directorios — las piezas nuevas bajan a los hijos sin tocarlo.

## Verificación (el demo que corre el cliente) — `owner: cliente`

**Cómo lo corre (sin código ni terminal):** abre una sesión de Claude Code en un proyecto con niebla real (uno de los dos despliegues donde el método patinó), teclea `/jidoka:descubre` y responde la entrevista en su lenguaje. Al final ve con sus ojos: el `PRODUCT_BRIEF.md` lleno sin placeholders (caso concreto con sus palabras, métrica con número, apetito, no-metas) y — si declaró un experto tercero — el **kit de entrevista portátil** listo para reenviar tal cual por WhatsApp. Además intenta cerrar con un "dale": el ritual **no lo acepta** y le pide nombrar lo que aprueba — eso también es parte del demo.

> Este demo de campo es el criterio real de cierre del sprint (la suite verde es condición necesaria, no suficiente). Queda como paso post-merge del cliente.

## Lo que NO entra (siguientes)

- Gate determinista anti-placeholders sobre el brief (regla 2-3; issue al cerrar).
- "Detector de cansancio" / aparcar decisiones nocturnas (idea viva sin mecánica honesta).
- Que el experto tercero opere la IA.
- Telemetría de lecturas del método (pedido del cliente en sesión: contar qué docs lee la IA desde los transcripts JSONL / hook PreToolUse — issue al cerrar, regla 2-3).
- Bajada a los labs con `-Actualizar` (ventana aparte, gatillada por el cliente).
