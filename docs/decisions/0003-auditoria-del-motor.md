# ADR 0003 — La auditoría del motor: falla cerrado, el juez viaja en la base, y el nombre real

- **Estado:** aceptado
- **Fecha:** 2026-07-10
- **Sprint:** 1 (cierre)

## Contexto

Una auditoría independiente del Sprint 1 (motor + procedimiento + superficies públicas) encontró defectos en la **copia maestra** del motor — la que el Sprint 3 heredará al kit — y contradicciones entre lo que el repo predica (*evidencia-no-palabra*) y lo que publicaba. Hallazgos clave: el verificador **fallaba abierto** (un error de git = luz verde, verificado empíricamente); el CI ejecutaba la ley y el verificador **desde la rama del PR** (un PR podía vaciar la ley que lo juzga); `npx jidoka init` anunciaba un paquete npm **que pertenece a otra persona desde 2017**; el README afirmaba en presente comandos y roles que no existen; y "los 13 disparos" son 12 (nunca se contaron contra el artefacto).

## Decisión

1. **El gate falla cerrado.** Si `verificar.ps1` no puede calcular el rango de cambios (base inexistente, historia incompleta, ley ilegible), **no aprueba**: exit 2 con `[ERROR]`. Un muro que ante fallo interno se abre no es muro. El self-test lo guarda con un caso propio.
2. **El juez no viaja en el PR.** El check `andon` en CI ejecuta el verificador y la ley **de la rama base** (`git show origin/base:...`); los cambios legítimos a la ley rigen a partir del siguiente PR. Fallback al motor del PR solo si la base aún no lo trae (caso fundacional), con warning visible. La prueba de humo sí corre sobre el motor del PR (valida el motor nuevo propuesto).
3. **El paquete se llama `jidoka-method`** (`npx jidoka-method init`). El nombre `jidoka` en npm está ocupado desde 2017 por un tercero; anunciarlo era regalar el one-liner a un paquete ajeno. Espejo del patrón `bmad-method`. La marca sigue siendo *Jidoka*.
4. **La rama default es `main`.** Los docs ya la nombraban; la rama se renombra para que la instrucción de branch protection proteja una rama que existe.
5. **Los commits públicos no llevan trailer de sesión** (`Claude-Session: ...`): es un identificador privado del operador en un repo público. Regla de método.
6. **Line endings gobernados por `.gitattributes`**, no por convención: `.githooks/*` siempre LF (los ejecuta `sh`), `*.ps1` CRLF. El `.editorconfig` guía al editor; git no lo lee en checkout.

## Decisión abierta (para Sprint 3)

Hoy `tools/` es la **copia maestra provisional** del motor y `kit/` solo trae los disparos. Dos copias de una ley driftean: en Sprint 3 el motor debe vivir **solo en `kit/`** y este repo **instalarse su propio kit** (`npx jidoka-method init` corrido sobre Jidoka mismo). El dogfood completo: el repo de la metodología como primera instalación de su propio instalador.

## Consecuencias

- El README deja de anunciar capacidades inexistentes: tabla "Dónde va la beta" + `ROADMAP.md` con los sprints 2–4.
- `andon/README.md` gana la sección **"Fronteras del muro"**: los límites conocidos, dichos de frente (`doctrina/06`).
- Las lecciones de procedimiento van al Kaizen del sprint (`docs/sprints/sprint-1-plan.md`), no a la memoria de nadie.
