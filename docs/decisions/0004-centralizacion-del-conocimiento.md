# ADR 0004 — Centralización del conocimiento del linaje (la homologación de los 4 repos)

- **Estado:** aceptado
- **Fecha:** 2026-07-10

## Contexto

Jidoka nació como fusión de tres activos internos (ADR 0001), pero la fusión copió la doctrina y el motor — **no el conocimiento alrededor**: el lazo, la jerarquía QUÉ/CÓMO y los roles eran una línea del ADR 0001; los porqués de la doctrina (sus 4 ADRs) no viajaron; y los patrones probados en producción quedaron en los repos privados. Se inventariaron los cuatro repos del linaje con agentes de exploración: la plantilla interna (el andamio), el repo de doctrina, el tracker del ritual (5 sprints reales) y **el laboratorio de campo** — el repo más maduro (34 ADRs, auditoría integral de 21 auditores, evidencia de QA con enforcement).

Decisión del cliente: centralizar **todo lo aprovechable**, de forma inteligente. Además: **todo en español, a propósito** — la identidad se defiende, la barrera se acepta.

## Decisión

Se homologa con tres destinos, según la regla del protocolo de homologación del linaje ("sube como máquina antes que como prosa… **pero el conocimiento no espera a la máquina**"):

### Asciende YA (conocimiento, templates, hardening puntual)

| Qué | Dónde quedó |
|---|---|
| El lazo Intención→Construcción→Verificación→Registro | `kanban/lazo.md` |
| La jerarquía QUÉ/CÓMO (5 niveles, capacidad con Gherkin, claves estables) | `kanban/jerarquia.md` |
| Los asientos (asiento ≠ skill, menú con "lo que NO hace", model-routing, reglas duras) | `kanban/roles.md` |
| El ritual de auditoría en rama (fan-out → síntesis → GO/NO-GO separados) | `kanban/auditoria.md` |
| Los 4 ADRs de la doctrina (repo propio; **no API como gobierno**; **disparos, no lectura**; anonimización mecánica) | `doctrina/decisiones/` (números originales) |
| Templates de sprint probados en 5 sprints reales + plan-de-trabajo efímero + plantilla de ADR | `kit/.jidoka/templates/` |
| La convención `qa_runs/` (artefactos no actas; `git add -f` de lo citado como paso del cierre) | `kit/.jidoka/qa_runs/` + `qa_runs/` (dogfood) |
| **ALTO-04** (hooks revisan `$LASTEXITCODE`; git roto → AVISO, no silencio) — regresión: jidoka estaba pre-ALTO-04 | `.claude/hooks/andon-stop.ps1` |
| Área `raiz` (tierra de nadie) + mensajes que enseñan cuándo NO aplican (anti-fatiga, lección ADR 0020 del laboratorio) | `tools/blast-radius.json` |
| CONTRIBUTING con la tabla SSOT de dueños | `CONTRIBUTING.md` |

### Espera CON REGISTRO (maquinaria que exige el ritual ejecutable)

- **Sprint 2:** skills-asiento escritas; hooks `gemba-stop` (= el gate de evidencia visual probado), `review-stop` (marcador SHA de code-review — con sus grietas documentadas: el marcador se puede setear sin hacer el trabajo), `/jidoka:arranca` (reglas duras de sesión, incl. "desconfía del resumen de compactación" — caso real de resumen que mintió); auditor determinista del grafo de docs (frontmatter + wikilinks + Gherkin + huérfanas, modulado por estado); dimensión `product_avisa` en la ley.
- **Sprint 3:** jerarquía completa de templates de producto al kit; `setup` desatendido (`-Yes`); barreras extra del verificador (lint/formato/tests/cobertura/CHANGELOG-gate); CI de release + smoke del instalador (lección: *un workflow que solo corre al cortar release se pudre en silencio* — `workflow_dispatch` como rescate).

### NO asciende

- El corpus de fuentes de la doctrina (~1.2 MB): su historial de origen arrastra datos de entorno personal (ver `doctrina/decisiones/0004`). Queda como fuente interna hasta que un humano decida la estrategia de limpieza del historial.
- Todo lo específico de dominio de los repos (código de apps, datos, casting con nombres propios — los roles de Jidoka son genéricos a propósito).
- Lo que jidoka ya evolucionó mejor río abajo (no se retrocede): fail-closed, parametrización del verificador, self-test, juez-desde-la-base, mensaje del Stop hook en `reason`.

## Por qué

- Los tres activos del linaje centralizaron doctrina y motor, pero no el conocimiento alrededor (el lazo, la jerarquía QUÉ/CÓMO, los roles, los porqués de la doctrina): esa dispersión bloquea el uso real en repos ajenos.
- El protocolo de homologación lo exige: "el conocimiento no espera a la máquina".
- Jidoka debe ser self-contained en lo conceptual para que ningún pilar del método viva solo en un repo privado.

## Lecciones de campo que este ADR deja citables (anonimizadas)

1. **La mayor:** varios sprints del linaje se construyeron sin criterios de aceptación aprobados por el cliente — la IA decidió nombres y defaults sola y el cliente no pudo alinear lo entregado con lo pedido. Correctivo permanente: **el QUÉ se escribe y aprueba ANTES de construir** (por eso el lazo empieza en Intención).
2. La clasificación automática **sugiere, no auto-confirma** — no decidir por el usuario.
3. La data real rompe el parser/supuesto varias veces antes de estabilizar: validar contra **toda** la data, no una muestra bonita.
4. La matemática crítica se valida en motor puro con tests **antes** de tocar pantalla.
5. Un número sin sus supuestos es un número que el usuario no cree — la vista muestra "de qué está hecho".
6. La urgencia puede saltarse el ritual (caso: fuga de privacidad forzó merge sin demo) — pero la deuda se anota, no se disimula.
7. Los Stop hooks son **ciegos al código ya commiteado** — se mitiga por proceso (commitear código y docs juntos), no por código.
8. Un gate que no sabe decir cuándo NO aplica fatiga y se ignora (falsos positivos = pudrición).

## El camino que NO se toma (y por qué tienta)

**Portar toda la maquinaria ya** (auditor de grafo, hooks de evidencia, skills). Tienta porque está escrita y probada — sería copiar y pegar. Se descarta porque ejecutaría los Sprints 2-3 sin su plan ni su Gemba, rompiendo el ritual que el propio método predica; y porque la maquinaria sin su ritual alrededor (comandos, roles activos) sería andamiaje muerto que se pudre. El conocimiento asciende hoy; la máquina asciende con su sprint.

## Consecuencias

- Jidoka queda **self-contained en lo conceptual**: ningún pilar del método vive ya solo en un repo privado.
- Los Sprints 2-3 tienen inventario con nombres y rutas: menos exploración, más construcción.
- La ley creció a 6 áreas y el hook es más honesto ante fallas — el kit hereda ambos.
