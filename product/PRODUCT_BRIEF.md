---
tipo: brief
estado: vigente
---

# Jidoka — Brief

> El QUÉ y el PORQUÉ, en una página. Este brief **no estrena un QUÉ nuevo**: consolida el vigente, ya escrito y entregándose en el repo (README, ROADMAP, `doctrina/`, `product/capacidades/`). Nada de lo que dice se inventó aquí — cada sección apunta a dónde vive lo dicho. Donde el repo NO ha definido algo, se marca **Pendiente del cliente**: es un hallazgo, no un hueco a rellenar. El CÓMO-operativo (identidades, máquinas, convenciones) vive aparte, en [[infra]].

## En una frase

Jidoka es el Sistema de Producción Toyota aplicado al trabajo con agentes de IA — doctrina + método + ritual de sprint — para **dirigir agentes sin depender de su palabra**: la disciplina vive en gates deterministas *fuera* del modelo (hooks, CI, branch protection) y el juicio se queda en el humano (README).

## El problema

Programar con agentes de IA falla por dos vías (README, «¿Te suena?»): **pierden el contexto entre sesiones** — cada sesión arranca de cero y re-decide lo ya decidido; las memorias escritas ni las leen — y **cooperan con su propia mentira** — dicen «listo» cuando no, porque son un actor que no recuerda y no tiene nada que perder; arreglan una cosa y rompen tres; la documentación dice una cosa y el código otra. La ley incómoda de la que parte el método (`doctrina/00-tesis.md`):

> Un mecanismo de gobierno es **muro real solo si el punto de control vive FUERA del LLM.**
> Si depende de que el modelo coopere, no es muro — es una sugerencia.

## El caso concreto (citable)

El dolor no es hipótesis; es el linaje documentado (`docs/casos-de-exito.md`):

- **La confesión fundacional** del hook anti-memoria del laboratorio de campo, textual: *«se hizo cumplir con hook porque repetirla no funcionó (4 veces en las sesiones reales de ESTE repo)»* (`doctrina/00-tesis.md`). Los mecanismos voluntarios — comandos de arranque, memorias, repetir reglas en prosa — fallaron todos; los hooks ganaron porque no le piden permiso a la IA.
- **SimGhostInputs** (repo público: github.com/ArmandoMedina/SimGhostInputs): el «probé clic por clic» sin artefacto convivió con la UI rota a ojo (de ahí nació el gate de evidencia fresca en `qa_runs/`); la versión vivía en 3 lugares y falló 3 releases seguidos; el primer release que ejercitó su workflow falló 3 veces con 3 bugs dormidos hacía meses. El GIF del README es una corrida real ahí (2026-07-11): el agente cambió la UI sin actualizar la guía → `PUSH DETENIDO` (evidencia cruda en `qa_runs/gif-gate-20260711/`).
- **Los despliegues de campo** (2026-07-13, ADR 0027): un repo de conocimiento regulado (PLD/CNBV) y un proceso de operación («Caso F») instalaron el método a mano y devolvieron siete issues reales (#40–#46).
- **Las cosechas del lazo #1–#6** (*la lección sube, la máquina baja*): seis rondas documentadas en las que los repos hijos y el propio uso devolvieron lecciones que maduraron a mecanismo — ADRs 0013, 0015, 0027, 0028, 0029/0030 y 0032 (`CHANGELOG.md`).

## Métrica objetivo (con número)

**Pendiente del cliente.** El repo no declara una métrica objetivo con número para Jidoka mismo. Existen resultados medidos del linaje — 32 versiones en las primeras 4 semanas en SimGhostInputs; 6 sprints del ritual en 3 semanas en el caso 2; el `[BLOQUEA]` visible en ~3 minutos del quickstart — y el criterio de la 1.0 («el método corre end-to-end en un repo ajeno») se cumplió en 2 labs (ADR 0017), pero ninguno está declarado como *la* métrica del producto.

## La autoridad del dominio

**El cliente/autor (Armando Medina).** Está dicho en el método: aprueba el QUÉ antes de que se construya (rebanada R0 con STOP de `/jidoka:planea`) y valida **viendo el demo corriendo** (Gemba) — nunca el PR, sin código ni terminal (README; `doctrina/00-tesis.md`: *el único gate de correctitud en trabajo no-código es el humano*). Los merges a `main` requieren su orden nombrada cada vez (ver [[infra]]). Formato de validación: el demo que corre el cliente + el `LOG.md` de la corrida en `qa_runs/`.

## Criterio de "hecho"

*«Hecho» = lo viste funcionar* (README). Una rebanada está terminada solo si **el cliente puede correr el demo sin código ni terminal**; si la única forma de verlo es corriendo un script, no está terminada (disparo `demo-que-corre-el-cliente`, ADR 0030). La evidencia que el gate exige es el **`LOG.md` de la corrida**, rastreado por git — no la palabra del agente (*evidencia-no-palabra*).

## Qué hace (capacidades ancla)

Las capacidades vigentes viven en el grafo (`product/capacidades/`, auditado por `tools/auditar.ps1`):

- [[AND-1-muro-andon]] — cuando el agente dice «listo» y no es cierto, algo lo para: la ley única (`tools/blast-radius.json`), el verificador que falla cerrado, los hooks de cierre y el auditor del grafo; el muro real es el required check server-side.
- [[RIT-1-ritual-ejecutable]] — el método deja de ser prosa que hay que recordar: comandos `/jidoka:arranca|planea|gemba|cierra|que-sigue|desatendido` y los asientos como skills que se autoinvocan.
- [[KIT-1-lazo-sincronizacion]] — el método se instala en repos ajenos (instalador + sello + actualización de tres vías) y las lecciones de los hijos suben por canal: *la lección sube, la máquina baja*.
- **La memoria vive en artefactos, no en el modelo**: el `HANDOFF.md` como relevo entre sesiones, los ADRs con el camino que NO se tomó, el plan aprobado como contrato archivado (README; Jidoka Core, issue #71).
- **Y si el QUÉ está borroso, el método te saca la sopa**: `/jidoka:descubre` — entrevista con hechos pasados, nunca hipotéticos, más el kit de entrevista portátil para el experto que no usa la IA (familia Discovery: 1 caso real; demo de campo pendiente).

## Apetito

**Pendiente del cliente.** No hay una apuesta máxima de tiempo/dinero escrita en el repo. Lo único declarado es el techo del gasto operativo: Jidoka corre íntegramente dentro de Claude Code y se cubre con la suscripción (Pro/Max), sin API key ni cobro por token (README).

## Criterios de aceptación (Gherkin)

Viven — y se auditan — en cada capacidad vigente del grafo (`tools/auditar.ps1` bloquea una capacidad `vigente` sin Gherkin). Ejemplos ancla, textuales:

- Dado que agrego un ADR sin listarlo en su índice, cuando corro `tools/verificar.ps1`, entonces bloquea el push (exit 1) — [[AND-1-muro-andon]].
- Dado que el gate no puede calcular el rango, cuando corre, entonces falla cerrado (exit 2) — no aprueba a ciegas — [[AND-1-muro-andon]].
- Dado que voy a construir un sprint, cuando corro `/jidoka:planea`, entonces exige el QUÉ aprobado por el cliente (R0 con STOP) antes de la primera línea de código — [[RIT-1-ritual-ejecutable]].
- Dado que el hijo customizó una pieza de mecánica, cuando corro `-Actualizar`, entonces NO se pisa: se deja `<archivo>.jidoka-nuevo` y se reporta la divergencia — [[KIT-1-lazo-sincronizacion]].

## Landscape — qué más existe y por qué esto

Las dos alternativas externas están verificadas y registradas con fuentes en `ROADMAP.md` (entradas *Panorama*); la primera fila es el status quo que la doctrina descarta con tabla (`doctrina/00-tesis.md`):

| Opción | Qué hace | Por qué no basta |
|---|---|---|
| Memorias / CLAUDE.md / prosa que «debería leer» | Reglas repetidas al modelo esperando que coopere | Depende del LLM → no es muro (la confesión de las 4 veces; `doctrina/00-tesis.md`) |
| OpenWiki (LangChain, 2026-06, MIT, ~10.5k stars) | Wiki del repo *para agentes*, con Action diaria anti-drift (flecha código→doc) | Generativa, palabra de LLM; la de Jidoka es normativa doc→código con gate determinista. Complemento, no competidor |
| GBrain (Garry Tan, 2026-04, MIT, ~26k stars) | Grafo de conocimiento sobre Markdown git-nativo, consulta con citas vía MCP | Interfaz de consulta, no gobierno: no gatea nada. Interés registrado como capa «pregúntale al proyecto» sobre las docs del método |

## Fuera de alcance (no-metas)

- **No pretende hacer infalible al modelo** — cambia las condiciones (los gates) bajo las que opera (README, cierre).
- **Sin API/MCP propia como capa de gobierno**: reintroduce la amnesia que se resolvió (decisión congelada, ADR 0002; `doctrina/00-tesis.md`).
- **El gate no juzga contenido**: mide co-ocurrencia (presencia + frescura + tracking); la verdad la pone el humano en el Gemba — límite conocido aceptado, confesado en `andon/README.md` (grieta #3 de la auditoría externa).
- **Traducción al inglés no planeada**: en español, a propósito — la prosa es parte de su identidad; la maquinaria es language-agnostic (README).
- **Nada se construye por método-ficción**: las familias opcionales (Docs/`doc-only`, Operations, Observability) esperan consumidores reales (regla 2-3; frontera Core declarada en README/ROADMAP, issue #71).

## Decisiones abiertas

Registradas en `ROADMAP.md`; decide el cliente:

- **Multiplataforma del motor** (gemelos `.sh` o unificar en pwsh Core) — pendiente de un entorno no-Windows para probarse.
- **`npm publish` del CLI `npx jidoka-method`** — necesita la cuenta npm del cliente.
- **Comunidad** (Discussions / Discord) — Sprint 4.
- **El párrafo en inglés del README** — identidad en español vs. el bounce del visitante anglófono; solo el autor decide.
- **Qué más del linaje puede hacerse público** — el ancestro y el caso 2 siguen privados.

## Aprobación del QUÉ

Este brief **no estrena un QUÉ nuevo — consolida el vigente**, ya aprobado y entregándose (la `v1.0.0` cumplida en 2 labs ajenos, ADR 0017; la frontera Core declarada el 2026-07-15, issue #71). Consolidado el **2026-07-16** como rebanada R2 del sprint «Conciencia del agente» (`docs/sprints/sprint-conciencia-del-agente-plan.md`), bajo la decisión del cliente del 2026-07-16 («adelante con el siguiente sprint», #75).
