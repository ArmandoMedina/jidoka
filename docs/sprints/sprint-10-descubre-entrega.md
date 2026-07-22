# Sprint Descubre — La capa de consultoría · Entrega

> El récord del sprint (`v1.13.0`, 2026-07-14). Plan-contrato: [`sprint-10-descubre-plan.md`](sprint-10-descubre-plan.md). Las lecciones viajan al siguiente `planea`.

## Objetivo

Cuando el QUÉ está borroso, el método lo descubre con una entrevista mecánica (`/jidoka:descubre`) en vez de marcarlo como pendiente — incluyendo el caso donde la autoridad del dominio es un tercero que no opera la IA.

## Decisiones

- ADR 0031 (la capa de descubrimiento: las 3 nieblas, el filtro Mom Test escrito, la autoridad tercera, `aprobacion-nombrada`, el gate anti-placeholders diferido por regla 2-3).
- Del cliente (2026-07-14): el experto tercero es *autoridad, no usuario*; la lectura se inyecta (@-include), no se encarga; casting/jerga en lenguaje llano.

## Qué se entregó

Contra el alcance del plan, completo y sin cambios de alcance:

- R1 — `.claude/commands/jidoka/descubre.md` + campos del descubrimiento en `PRODUCT_BRIEF.md` (caso citable · métrica con número · autoridad · criterio de "hecho" · apetito · no-metas · aprobación).
- R2 — `kit/.jidoka/templates/kit-entrevista.md` (kit portátil, vuelta como evidencia `docs/gemba/`).
- R3 — Disparo 14.º `aprobacion-nombrada` (ROJO→VERDE en `probar-disparos`, 13→14) + ruteo de `planea` R0 a `descubre`.
- R4 — ADR 0031 + índices, CHANGELOG `[1.13.0]`, SSOT, README, plan archivado, [release v1.13.0](https://github.com/ArmandoMedina/jidoka/releases/tag/v1.13.0).

## Evidencia (review)

PR [#65](https://github.com/ArmandoMedina/jidoka/pull/65) mergeado con check `andon` verde (36s); preflight del release 8/8. Corrida: [`qa_runs/descubre-20260714/LOG.md`](../../qa_runs/descubre-20260714/LOG.md) (ROJO→VERDE del disparo documentado).

## Hallazgos de la data real

Los 3 diagnósticos de campo (chats reales de 2 despliegues fallidos + 1 exitoso) que parieron el diseño: el QUÉ vive en ejemplos, no en docs; STOP no es comprensión; la autoridad a veces no opera la IA. Y un hallazgo sobre el propio agente, cazado por el cliente **durante este mismo sprint**: el agente dobló su propio contrato ("Lo que NO entra") a la primera re-pregunta → issue [#68](https://github.com/ArmandoMedina/jidoka/issues/68).

## Verificación (el demo que corre el cliente) — `owner: cliente`

**NO CERRADA — pendiente del cliente, a propósito.** La suite verde es condición necesaria, no suficiente: el criterio real es correr `/jidoka:descubre` en un proyecto con niebla real (tracker-financiero o el repo de rescate), ver el brief lleno sin placeholders + el kit portátil reenvíable, y comprobar que un "dale" no cierra. Los agentes no marcan esta sección como cumplida.

## Pendiente que dejó

- [ ] **Demo de campo** (owner: cliente): `/jidoka:descubre` en un proyecto con niebla real — cierra la Verificación de arriba.
- [ ] Gate anti-placeholders del brief → [#67](https://github.com/ArmandoMedina/jidoka/issues/67) (se activa con el caso real que el demo de campo produzca).
- [ ] Telemetría de lecturas del método → [#66](https://github.com/ArmandoMedina/jidoka/issues/66) (one-off primero, herramienta al 2º uso).
- [ ] Bajada de `v1.12.1`–`v1.13.0` a los labs con `-Actualizar` (ventana aparte; el lab de reconstrucción solo cuando cierre la sesión del otro agente).

## Lo aprendido (Kaizen)

1. **El QUÉ vive en ejemplos, no en documentos** — el aparato metodológico era idéntico en los 3 repos analizados; la diferencia era quién pedía (y daba) el caso concreto.
2. **STOP no es comprensión**: un checkpoint que el humano no puede juzgar (dominio, vocabulario, cansancio) es un sello de goma — por eso `aprobacion-nombrada`.
3. **El contrato del sprint también ata al agente**: doblar el "NO entra" a la primera re-pregunta es complacencia, no servicio (#68) — el cliente cazó al agente 3 veces a ojo en un día (tiers #63, contrato #68, y el patrón que parió `aprobacion-nombrada`).
4. **La lectura se inyecta, no se encarga**: la respuesta a "muchos docs que la IA no lee" son @-includes y artefactos únicos vigilados por la ley, no más docs.
5. **Los transcripts JSONL son una mina de diagnóstico**: 3 subagentes sobre ~55 MB de chats reales produjeron el fundamento empírico del sprint en ~6 minutos — patrón repetible para auditar el método por fuera (#66).
