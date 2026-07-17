---
tipo: capacidad
estado: vigente
clave: RIT-1
modulo: MOD-ritual
dominio: Metodo
---
# Capacidad — El ritual Kanban ejecutable

Del módulo [[MOD-ritual]], dominio [[Metodo]]. La sesión gana el ritual como comandos que se invocan (`/jidoka:arranca|planea|gemba|cierra|que-sigue`) y los asientos como skills que se autoinvocan por contexto. El método deja de ser prosa que hay que recordar.

## Criterios de aceptación

- Dado que abro una sesión, cuando corro `/jidoka:arranca`, entonces lee el estado real en orden de onboarding `git → qué → cómo → dónde` (git primero como filtro de frescura), **sienta la sesión en su asiento** (adopta el casting) y **lee el router** (`tools/rutear.ps1`: qué área se rutea a qué gate, cuáles vivos/dormidos), y enuncia las reglas duras antes de tocar nada (ADR 0029).
- Dado que voy a construir un sprint, cuando corro `/jidoka:planea`, entonces exige el QUÉ aprobado por el cliente (R0 con STOP) antes de la primera línea de código y la **aprobación formal del plan antes de archivarlo** (STOP 2, **siempre en plan mode** — si el agente no está, entra; un plan rechazado se ajusta y se re-presenta), y su Verificación debe poder demostrarse **sin código ni terminal** (disparo `demo-que-corre-el-cliente`); `/jidoka:cierra` no la da por cumplida si solo corre por terminal (ADR 0030).
- Dado que digo una frase natural del rol, cuando aplica, entonces se autoinvoca la skill-asiento con sus límites ("lo que NO hace") visibles.
- Dado que trabajo sin humano presente, cuando corro `/jidoka:desatendido`, entonces el trabajo se reparte en las dos lanes `[agente]`/`[humano]` y nada irreversible se decide solo (ver `kanban/desatendido.md`).
- Dado que cierro con `/jidoka:cierra`, cuando la sesión o el sprint termina, entonces entrega el **cuadro de cierre** — los hechos medibles (sprint y rebanadas, rama/commits/PR, ritual corrido, delegaciones y excepciones 🎭, aprobaciones nombradas, pruebas altas/cambios/bajas, E2E, evidencia en `qa_runs/`, gates y avisos, compactación, motor al día, fricción y errores como Kaizen crudo) — llenado con verdad (un hueco se declara) y **versionado con los planes** (en la entrega del sprint o `docs/sprints/cierre-AAAAMMDD.md`).
- Dado que abro sesión con `/jidoka:arranca`, cuando el comando corre, entonces el estado queda **inyectado** en el contexto —no encargado como lectura a criterio del agente— en orden `git → qué (brief) → cómo (CONTRIBUTING, infra) → dónde (HANDOFF, plan)`, con git como filtro de frescura (si el HANDOFF contradice a git, git gana), el roster muestra los asientos-subagente con su tier fijo **impreso del artefacto** (`tools/asientos.ps1` lee `.claude/agents/`, no una copia en prosa), y el router presenta los gates como **preview** ("estos te van a vigilar al cerrar"), no como un rol que el hilo principal adopta (ADR 0034, desde `v1.16.0`; orden refinado en la enmienda 2026-07-17).

No existe test automatizado: se verifica por demo Gemba (una sesión que corre el lazo completo). Entregado en `v0.5.0-beta`; el modo desatendido se sumó en la Homologación Etapa 1.
