---
tipo: capacidad
estado: vigente
clave: FLU-1
modulo: MOD-andon
dominio: Metodo
---
# Capacidad — El pilar de flujo

Del módulo [[MOD-andon]], dominio [[Metodo]]. La Casa del TPS tiene dos pilares; el método ya tenía Jidoka (parar ante el defecto) pero el pilar de flujo (JIT) no existía. Esta capacidad lo estrena: **los documentos que cargan el estado dejan de crecer solos, el trabajo entra con límite, y el avance y el reparto se ven sin terminal** — y todo es código que rechaza la acción, no prosa que dependa de que alguien se acuerde (plan-contrato: [`docs/sprints/sprint-pilar-de-flujo-plan.md`](../../docs/sprints/sprint-pilar-de-flujo-plan.md), aprobado 2026-07-21; ADR 0049).

Las piezas:

- **Los 3 contratos de documentos** — checks deterministas en `tools/verificar.ps1` (`[contrato-handoff]`, `[contrato-roadmap]`, `[contrato-changelog]`), los **mismos checks del muro** de [[AND-1-muro-andon]]: los límites son dato de instancia en `tools/flujo.json` (sin el archivo el check no aplica; corrupto → falla cerrado, exit 2).
- **La muerte por defecto** — `tools/expirar.ps1` mueve lo vencido del `ROADMAP.md` a `docs/MUERTOS.md` con fecha y motivo, por clase de servicio (`vencimiento_dias` en `tools/flujo.json`). Lo caduco muere por script, no por juicio.
- **La vista de «qué sigue»** — `tools/estado-flujo.ps1`: `-Gate` planta a `/jidoka:planea` si hay un Gemba pendiente; `-Json` emite el contrato que la cara Tauri pintará después; el modo default es el resumen humano que el **primer hook `SessionStart` del repo** (`.claude/hooks/flujo-sessionstart.ps1`, cableado en `.claude/settings.json`) inyecta al abrir sesión.
- **El reporte para terceros** — `tools/reporte-avance.ps1` arma un `.html` autocontenido sin jerga (hill chart, 5 secciones en lenguaje llano) que el cliente reenvía tal cual a un no-técnico. Es vista, no gate.
- **El reparto de funciones** — el [[casting]] (`product/casting.md`, con molde sembrable `kit/.jidoka/templates/casting.md`) separa la autoridad del dominio del dueño-operador, y los 4 agentes-asiento (`.claude/agents/*.md`) ganan enfoque conductual propio (cómo piensa cada uno, qué reporta por su cuenta).

El ritual [[RIT-1-ritual-ejecutable]] ganó pasos por esto: `/jidoka:planea` se planta ante un Gemba pendiente, `/jidoka:cierra` fija el orden del registro y corre `expirar` como paso duro, `/jidoka:gemba` registra la aceptación, y `/jidoka:arranca` recibe el resumen inyectado y el early-warning de lo que vence.

## Criterios de aceptación

- Dado que el `HANDOFF.md` se pasa del techo de líneas (o trae más de una sección «Dónde estamos», o más históricas de las permitidas) definido en `tools/flujo.json`, cuando corro `tools/verificar.ps1`, entonces el check `[contrato-handoff]` **BLOQUEA** el push (exit 1) y manda a archivar lo viejo ÍNTEGRO en `docs/handoff-historico.md` — que `/jidoka:arranca` nunca inyecta.
- Dado que un ítem del `ROADMAP.md` no declara su clase (sección fuera de las 4 de servicio + Referencia) o le falta `[alta:AAAA-MM-DD]` (los Urgente/Con fecha/Normal además `apetito:Nh`; los Con fecha además `vence:`), cuando corro `tools/verificar.ps1`, entonces el check `[contrato-roadmap]` **BLOQUEA** el push (exit 1) nombrando qué falta — la cola se clasifica, no se rankea.
- Dado que `tools/flujo.json` trae un Gemba en `estado.gembas_pendientes` con `aceptado != true`, cuando corro `/jidoka:planea`, entonces `tools/estado-flujo.ps1 -Gate` se planta **antes de R0** nombrándolo (`[BLOQUEA] Gemba pendiente de aceptacion: <id>` + `ABRIR SPRINT NUEVO BLOQUEADO`, exit 1) — el límite lo pone la aceptación del cliente, no la producción.
- Dado que un ítem del `ROADMAP.md` venció (su `vence:` ya pasó, o `alta` + la ventana de su clase en `vencimiento_dias` es anterior a hoy), cuando corro `tools/expirar.ps1` (paso duro de `/jidoka:cierra`), entonces se mueve a `docs/MUERTOS.md` con **fecha y motivo** (clase, alta y fecha en que vencía), preservando el resto del ROADMAP byte-igual; revive solo si se re-propone con alta nueva.
- Dado que abro una sesión nueva, cuando corre el hook `SessionStart` (`.claude/hooks/flujo-sessionstart.ps1`, cableado en `.claude/settings.json`), entonces se inyecta el resumen de `tools/estado-flujo.ps1` —qué sigue (los 3 siguientes por clase de servicio), qué espera a terceros, los gembas pendientes— **sin que nadie lo pida**: el estado se empuja a la vista, ya no depende de que un comando se acuerde.

Verificado por `tools/probar-flujo.ps1` (fixtures ROJO→VERDE de los 3 contratos + expiración por clase, `-Gate`, `-Json` y la degradación con gracia) y la prueba de vida del hook en `tools/probar-hooks.ps1`. Entregado en `v1.28.0`.
