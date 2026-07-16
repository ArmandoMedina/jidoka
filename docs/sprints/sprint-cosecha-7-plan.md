# Cosecha #7 — «La bajada que dolió» (issues #86–#91 + #82)

> Plan-contrato del sprint. R0 aprobado con nombre por el cliente (2026-07-16): alcance R1+R2+R3, **cura B completa** para R1. Al aprobarse este plan se archiva como `docs/sprints/sprint-cosecha-7-plan.md` y se registra en `docs/sprints/README.md`. Versión objetivo: **v1.17.0** (MINOR — agrega sin romper).

## Contexto (por qué)

Una bajada real 1.13.0 → 1.16.1 en un hijo instalado («caso 1», hoy 15:27) devolvió 6 issues en batch: la conciencia de v1.16 no viaja (`@` rotos, agentes inexistentes en el hijo — exactamente lo que #82 predijo ayer), el salvavidas `no-borres-el-motor` tiene un hueco (un ADR editado/borrado destraba borrar el motor), el fallback AV-seguro revienta a medias con manifiesto sin `stubs`, el CI del hijo re-diverge en cada actualización, y dos nits del instalador. El próximo consumidor es inmediato: la bajada pendiente a los labs y el piloto fresco (#70).

## Decisiones del cliente

- 2026-07-16 — Cura **B completa** del #82: el kit siembra `.claude/agents/` + `probar-agentes` + stubs de instancia; las leyes-plantilla ganan el área. («La regla 2-3 ya está pagada por el caso 1».)
- 2026-07-16 — R0 aprobado tal cual: R1 (#86+#87+#82), R2 (#88), R3 (#89+#90+#91). Fuera: validación de `tools:` del lint, bajada a labs, Authenticode/npm.
- Va **ADR 0035** (decisión gorda: los agentes viajan en el kit + `-Actualizar` consciente de migraciones + la casa única del roster).

## Decisiones de diseño (arquitecto, dentro del R0 aprobado)

1. **Brief e infra se vuelven stubs COMUNES en `product/`** (hoy `brief` siembra `PRODUCT_BRIEF.md` en la raíz solo para ese arquetipo; `grafo` no lo siembra). Razón: el `arranca` canónico inyecta `@product/PRODUCT_BRIEF.md` y `@product/infra.md` para TODOS — si son comunes, la migración de `-Actualizar` es 100 % decidible sin saber el arquetipo (el sello no lo registra). `grafo` conserva además su `product/README.md`.
2. **La casa única del roster es `product/infra.md`** («se inyecta donde vive»): la plantilla `infra.md` gana la sección `## El casting` (la tabla que hoy vive en `recursos-del-proyecto.md`); la plantilla `recursos-del-proyecto.md` se retira del kit (ADR 0035 lo documenta — el salvavidas exigirá el ADR en el mismo cambio si aplicara, pero es template, no motor); el `arranca` §2 apunta a `## El casting` de `product/infra.md`. Hijos viejos: aviso `[MIGRA]` (no se borra nada en el hijo).
3. **`@CONTRIBUTING.md` del arranca**: se agrega `CONTRIBUTING.md` a los stubs comunes con contenido mínimo genérico (flujo rama+PR, hooks locales, una-decisión-un-ADR) — no-clobber: si el hijo ya tiene uno, no se toca.
4. **El sello gana campos `producto` y `gobernanza`** en siembras/sellados nuevos (para futuras migraciones arquetipo-dependientes). Los sellos viejos sin el campo siguen válidos.
5. **#91 doble resumen**: el código de `Invoke-Actualizar` imprime el resumen UNA vez (verificado: `instalar.ps1:153` y `:219`) — se reproduce una corrida real; si no reproduce, se acusa en #91 como artefacto de captura y NO se toca (evidencia-no-palabra).

## Alcance (rebanadas verticales, cada una commiteable y verde)

### R1a — Los agentes viajan en el kit (#87, #82.2, #82.3)
- `kit/.jidoka/instalar/manifiesto.json`: entradas de motor `{ "origen": ".claude/agents", "destino": ".claude/agents", "dir": true, "clase": "mecanica" }` y `tools/probar-agentes.ps1`.
- `kit/.jidoka/leyes/blast-radius.code-first.json` y `.docs-as-code.json`: área `ritual.fuente` gana `".claude/agents/*"` (espejo de la ley de la nave, `tools/blast-radius.json:40-48`).
- `arranca` §3 (`.claude/commands/jidoka/arranca.md`): una línea de degradación honesta — «si `.claude/agents/` no está sembrado, delega con el agente general y anuncia el asiento» (seguro barato aun con cura B).
- Tests: `probar-instalador` y `probar-sembrar` ganan checks «`.claude/agents/` sembrado con los 4 asientos» (el niño ya puede correr `probar-agentes` — su `andon.yml` lo invoca condicional, `andon.yml:47-49`, sin cambio).

### R1b — La instancia que el arranca asume (#86 detalle, #82.1)
- Manifiesto: `stubs` comunes ganan `product/PRODUCT_BRIEF.md` (contenido = plantilla actual), `product/infra.md` (plantilla + `## El casting`) y `CONTRIBUTING.md` mínimo; `stubs_arquetipo.brief` deja de sembrar `PRODUCT_BRIEF.md` en la raíz (queda vacío o se elimina la clave); `grafo` conserva `product/README.md`.
- `kit/.jidoka/templates/infra.md`: gana `## El casting` (tabla de asientos migrada); nota de casting apuntando aquí.
- `kit/.jidoka/templates/recursos-del-proyecto.md`: se retira (git rm); referencias (`arranca` §2, docs que lo citen — barrer con grep) actualizadas a `product/infra.md`.
- `arranca` §2: el casting vive en `## El casting` de `product/infra.md`.
- Tests: `probar-instalador`/`probar-sembrar` verifican los stubs nuevos en siembra fresca (ambos arquetipos) y que la raíz NO gana `PRODUCT_BRIEF.md`.

### R1c — `-Actualizar` migra la instancia (#86 núcleo)
- `tools/instalar.ps1` (`Invoke-Actualizar`, líneas 134-229): tras actualizar la mecánica, recorre `manifiesto.stubs` y siembra los faltantes **no-clobber** con aviso `[MIGRA] sembrado X — el arranca nuevo lo inyecta`; lo arquetipo-dependiente (`stubs_arquetipo`) solo si el sello registra `producto` (sellos nuevos), si no: aviso `[MIGRA] revisa a mano`.
- Mismo comportamiento en `sembrar-manual.ps1 -Actualizar` (si su modo actualizar existe; si no, solo fresco — verificar en construcción).
- Sello: `instalar.ps1` (3 sitios: ~216, ~437, ~265) y `sembrar-manual.ps1` (~213) ganan `producto`/`gobernanza` cuando se conocen.
- Tests: caso en `probar-instalador` — hijo 1.13 simulado (sin `product/`), `-Actualizar` → stubs sembrados, instancia existente intacta (no-clobber probado con un `HANDOFF.md` pre-existente).

### R2 — El juez sin hueco (#88)
- `tools/verificar.ps1`: `$decisionesNuevas` se calcula desde **agregados** (`git diff --name-only --diff-filter=A` en los 3 caminos con git, espejo de las líneas 69/78/86 de borrados) + parámetro `[string[]]$AgregadosInyectados = @()` para el camino de prueba (espejo de `-BorradosInyectados`; misma nota PS 5.1 case-insensitive).
- `tools/probar-gate.ps1`: el caso verde existente (línea ~111) pasa a usar `-AgregadosInyectados`; +2 casos negativos ROJO: ADR **editado** no destraba, ADR **borrado** no destraba.

### R3 — Mecánica menor (#89 + #90 + #91)
- `tools/sembrar-manual.ps1:192-194`: guard `$stubs = @($manif.stubs | Where-Object { $_ })` (y mismas líneas para `stubs_arquetipo`); + caso en `probar-sembrar` con manifiesto sin `stubs` (hoy `@($null)` revienta el Join-Path).
- `.github/workflows/andon.yml`: step nuevo «extensión local del CI» que invoca `tools/ci.local.ps1` **si existe** (espejo del patrón `verificar.local.ps1`, `verificar.ps1:161-164`); documentado en `docs/guias/mantener-el-motor-al-dia.md`.
- Sello con newline final: los 4 `WriteAllText` del sello agregan `"`n"` (instalar ×3, sembrar-manual ×1).
- Doble resumen: reproducir `-Actualizar` en fixture → cura o acuse en #91 (decisión de diseño 5).

### Cierre
- **ADR 0035** (+ índice en el mismo commit — bloqueo duro de la ley).
- `CHANGELOG.md` (v1.17.0), `docs/sprints/sprint-cosecha-7-plan.md` (este contrato) + fila en `docs/sprints/README.md`.
- Acusar los 7 issues uno por uno (3er paso del lazo): cerrar #86/#87/#88/#89/#90/#91 con el release; #82 comentar qué quedó (validación `tools:` del lint).
- Evidencia: `qa_runs/cosecha-7-20260716/LOG.md` (plantilla `qa-log.md`).

## Archivos (blast radius)

| Área de la ley | Archivos | Gate |
|---|---|---|
| `kit` | `manifiesto.json`, `leyes/*.json`, `templates/infra.md`, `templates/recursos-del-proyecto.md` (retiro), stubs inline | review-stop + andon-stop |
| motor (`kit`/raíz) | `tools/instalar.ps1`, `tools/sembrar-manual.ps1`, `tools/verificar.ps1`, `.github/workflows/andon.yml` | andon-stop |
| `ritual` | `.claude/commands/jidoka/arranca.md` | andon-stop |
| tests | `tools/probar-gate.ps1`, `probar-instalador.ps1`, `probar-sembrar.ps1` | — |
| `decisiones` | `docs/decisions/0035-*.md` + índice | andon-stop |
| docs | `CHANGELOG.md`, `docs/guias/mantener-el-motor-al-dia.md`, `docs/sprints/*` | andon-stop |

Rama: `cosecha-7-la-bajada-que-dolio` desde `main`. PR contra `main`; merge solo con orden nombrada del cliente.

## Asientos (quién construye)

Orquestador teje; `mecanico` para edits ya especificados (stubs, newline, guard); `auditor` para correr los tests y leer salidas; excepciones en sesión se acusan con 🎭.

## Verificación (el demo que corre el cliente) — `owner: cliente`

**Sin código ni terminal:**
1. Abres una sesión de Claude Code en el **hijo de práctica** que te dejaré actualizado (fixture de la corrida, ruta en el LOG) y corres `/jidoka:arranca`: lo ves abrir **completo** — brief, infra y CONTRIBUTING inyectados sin `@` rotos, el casting visible en `## El casting`, y el §3 delegando a asientos que existen.
2. Lees `qa_runs/cosecha-7-20260716/LOG.md`: la corrida `-Actualizar` con los avisos `[MIGRA]`, y el guard #88 mordiendo ROJO→VERDE (ADR editado NO destraba; ADR agregado sí).

## Lo que NO entra (siguientes)

- Validación de nombres de `tools:` en `probar-agentes` (typo `Gerp` pasa) — queda en #82.
- La **bajada a los labs** con v1.17.0 — ventana aparte ya pendiente.
- Certificado Authenticode, npm publish, #70 (piloto), #72 (Gemba del análisis).
- Arquetipo `doc-only` y `stubs_arquetipo.gobernanza` (hoy inexistente — se acusa, no se construye: regla 2-3).

## Verificación técnica (antes del PR)

Suite completa: `probar-gate`, `probar-hooks`, `probar-auditor`, `probar-disparos`, `probar-instalador`, `probar-sembrar`, `probar-version`, `probar-publicar`, `probar-agentes` — todo verde local + `verificar.ps1`/`auditar.ps1` exit 0; CI verde en el PR.
