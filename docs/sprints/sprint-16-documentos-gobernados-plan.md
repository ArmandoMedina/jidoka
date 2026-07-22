# Plan de sprint — Documentos gobernados (gobierno por estructura, el régimen estatuto)

> Contrato del sprint (aprobado 2026-07-17, R0 nombrado + STOP 2 en plan mode). El QUÉ + el CÓMO.

## Contexto — por qué ahora

El cliente hace análisis de flujos en el hijo **enti** (`entisoft-rescate`, motor 1.21.1) y percibe que "los documentos de los hijos están super diferentes". La medición (solo-lectura) desmintió la premisa inicial pero encontró la real:

- **Los `.md` del ritual (arranca/planea/cierra) NO divergen** — son motor, `-Actualizar` los gobierna bien por hash. enti solo va 1 fix atrás (el preflight `!` de la rama sin liberar). La gobernanza capa-1 funciona.
- **Donde HAY template, el hijo conformó**: `PRODUCT_BRIEF` 14/14 secciones idénticas en orden; `infra` = molde + 1 sección aditiva.
- **Donde NO hay template (`CONTRIBUTING`)**: tres estructuras sin relación (stub kit de 4 líneas / enti 4 secciones propias / jidoka canónico 5 secciones). **Ese es el hueco.**

**Causa raíz:** el motor se gobierna por **hash** (sello + `estado-motor -Detallado`), pero los documentos **instancia-de-template** tienen contenido que varía a propósito — el hash es la herramienta equivocada. Falta el **hermano estructural**: gobernar las **secciones**. El ritual inyecta esos docs con `@`; si el hijo vació o reestructuró CONTRIBUTING, la lógica del `arranca`/`planea` opera sobre basura y el preflight actual (que solo checa **existencia**) no lo caza.

**Modelo mental (cliente):** el estatuto. El hijo puede llenar/configurar, pero si **altera la estructura gobernada**, "garantía nula" — el método declara que ya no garantiza que su lógica inyectada funcione. *"No se pueda (bloquea) o no se recomiende (avisa) desviar."*

## Encuadre de producto

Extiende **[[KIT-1-lazo-sincronizacion]]** (*la lección sube, la máquina baja*). Alta como capacidad nueva **[[KIT-2-gobierno-documental]]** (el área `barreras` ya avisa sobre `product/capacidades/KIT-*`). Respeta la regla dura de KIT-1: **la instancia nunca se sobrescribe** — el detector **declara**, no muta. Límite v0 aceptado (grieta #3): no juzga el *contenido* de las secciones, solo su **presencia** (co-ocurrencia, no semántica).

## Decisiones del cliente (validadas con el asiento arquitecto, 2026-07-17)

| # | Decisión | Resolución |
|---|---|---|
| 1 | QUÉ del sprint (3 rebanadas) | aprobado en R0 (nombrado), 2026-07-17 |
| 2 | Dónde vive el ledger | **archivo nuevo `tools/docs-gobernados.json`**, sembrado como motor + hasheado. (El sello es *generado* por el instalador — no editable a mano; el manifiesto no se siembra al hijo.) |
| 3 | Altura de la ejecución | **aviso** por defecto para toda la clase (surtido en `/jidoka:arranca`); lo **estricto** es **opt-in y apagado**, y al encenderse va al **required-check de CI** (`andon.yml`), nunca a `verificar.ps1`. El "no se pueda" llega como palanca del cliente. |
| 4 | Qué docs nacen estrictos | **ninguno** (todo nace aviso). `estricto:true` es una palanca por-doc que el cliente enciende cuando quiera el muro. |
| 5 | Alcance del detector | **solo los 3 singletons inyectados** (brief, infra, CONTRIBUTING). El grafo de producto se queda con `auditar.ps1` (ya lo gobierna, con regla risk-scaled). |

Las decisiones 2/3/5 son de arquitectura → van además a un **ADR** (una decisión = un ADR).

## Alcance en rebanadas verticales

### R1 — El ledger capa-1/2/3 *(toca `tools/*` → área `barreras`)*
`tools/docs-gobernados.json`: para cada capa-2 singleton, su `molde` (template) y su lista **congelada** de secciones `requeridas`; más la lista capa-3 (libre). Criterios:
- Dado que abro el ledger, cuando lo leo, entonces cada documento gobernado está en capa-1 (hash), capa-2 (secciones) o capa-3 (libre), sin ambigüedad.
- Dado que un doc es capa-3 (`CODE_OF_CONDUCT`, `LICENSE`), cuando reviso la ley, entonces NO es fuente gobernada (fuera del blast-radius), explícito.

### R2 — El detector de conformidad de secciones *(el corazón; `tools/*` → `barreras`)*
`tools/estado-docs.ps1`, hermano estructural de `estado-motor.ps1`. Criterios:
- Dado que un doc capa-2 conserva las secciones **requeridas** del ledger, cuando corre el detector, entonces **CONFORME**.
- Dado que el contenido difiere pero las secciones requeridas están (lo normal), cuando corre, entonces **CONFORME** — no confunde contenido con estructura (donde el hash gritaría en falso).
- Dado que el doc tiene secciones **aditivas** (extra), cuando corre, entonces **CONFORME** (aditivas OK — como `infra` + "Relacionado con" en enti).
- Dado que **falta** una sección requerida, cuando corre, entonces **DESVIADO**, la nombra, y declara "garantía nula".
- Dado que las secciones están pero **reordenadas**, cuando corre, entonces **nota suave**, no DESVIADO (el `@` inyecta el archivo entero; el consumidor LLM es orden-insensible).
- Dado que un doc estricto (`estricto:true`) pierde una requerida y corro `-Estricto`, entonces exit≠0 (el muro opt-in); sin `-Estricto`, exit 0 (aviso).
- Self-test `tools/probar-docs.ps1` con casos ROJO→VERDE (incluye integridad del ledger).

### R3 — CONTRIBUTING gana template + capa-3 confirmada *(toca `kit`)*
- Dado que siembro un hijo nuevo, cuando termina, entonces su `CONTRIBUTING.md` trae las secciones **requeridas mínimas** del molde y el detector lo reporta CONFORME recién sembrado.
- Dado que reviso el ledger, cuando busco `CODE_OF_CONDUCT`, entonces está en capa-3, confirmado explícito.

## CÓMO (diseño)

**1. El ledger `tools/docs-gobernados.json`** (autoral, versionado en el padre, sembrado como `clase: mecanica` → hasheado en el sello). Forma:
```
{ "capa2": [
    { "doc": "CONTRIBUTING.md",          "molde": "kit/.jidoka/templates/CONTRIBUTING.md",  "requeridas": ["El flujo", "..."], "estricto": false },
    { "doc": "product/PRODUCT_BRIEF.md", "molde": "kit/.jidoka/templates/PRODUCT_BRIEF.md", "requeridas": ["En una frase", "..."], "estricto": false },
    { "doc": "product/infra.md",         "molde": "kit/.jidoka/templates/infra.md",         "requeridas": ["El casting", "..."], "estricto": false } ],
  "capa3": ["CODE_OF_CONDUCT.md", "LICENSE"] }
```
- Match por **ruta exacta** (son singletons). `requeridas` = contrato **congelado y mínimo** (no todo el molde) — el template puede mostrar más como opcional; las secciones requeridas son las que arranca/planea de verdad consumen.
- **Capa-1 no se re-lista**: es "lo que el sello ya gobierna por hash". El ledger lo referencia en prosa, no duplica.

**2. El detector `tools/estado-docs.ps1`** (ASCII/PS 5.1, espeja `estado-motor.ps1`):
- Lee el ledger **desde la raíz del hijo** (sembrado — corre sin `-Jidoka`). Para cada `capa2.doc` presente: extrae encabezados **nivel `##`**, normaliza (trim, lowercase, fold de acentos — coherente con el pipeline LF/ASCII), y checa que cada `requerida` esté. Faltante → DESVIADO(nombra); reordenada → nota suave; extra → ignora. Frontmatter **no** cuenta como sección (solo selector de molde).
- Imprime tabla humana (CONFORME / DESVIADO: falta X). exit 0 por defecto; `-Estricto` → exit 1 si algún `estricto:true` pierde requerida. Degrada con gracia si falta el ledger.

**3. Surtido en `/jidoka:arranca` §1b** — línea `!` nueva, **classifier-safe** y **guardada** para no tronar en motor viejo:
`!test -f tools/estado-docs.ps1 && powershell -File tools/estado-docs.ps1 || echo "[docs] sin detector (motor viejo); corre -Actualizar para gobernar brief/infra/CONTRIBUTING"`
- **Checkpoint de implementación:** validar ese idioma contra el clasificador de permisos y ampliar `tools/probar-preflight.ps1` para aceptarlo (misma disciplina que la lección del preflight `!`). Latencia: 3 docs, debe ser barato.

**4. El muro estricto (opt-in, OFF)** — el mecanismo se construye pero nace apagado: `estado-docs.ps1 -Estricto` en un step de `andon.yml` (pieza de motor separada, converge por `-Actualizar` sin tocar la costura `.local` del `verificar` del hijo). El cliente lo enciende marcando `estricto:true` en su ledger. Doctrina del único-muro respetada (required check server-side).

**5. R3 — template + stub:** crear `kit/.jidoka/templates/CONTRIBUTING.md` (muestra la estructura completa; las **requeridas** del ledger son el subconjunto mínimo — el flujo + hooks — para que un hijo con stub viejo NO quede DESVIADO de golpe). Cambiar el stub del manifiesto (línea 64) para que su `contenido` ya traiga las secciones requeridas y referencie el template (como brief/infra líneas 62-63). Confirmar `CODE_OF_CONDUCT` en capa-3.

**6. Integridad (en `probar-docs.ps1`, corre en el padre):** `requeridas(ledger) ⊆ headings(molde)`; cada stub sembrado tiene entrada en el ledger; cada molde referenciado existe en disco. Ata ledger↔manifiesto↔templates sin fundirlos.

## Archivos (blast radius)
- **Nuevos:** `tools/docs-gobernados.json`, `tools/estado-docs.ps1`, `tools/probar-docs.ps1`, `kit/.jidoka/templates/CONTRIBUTING.md`, un ADR en `docs/decisions/`, `product/capacidades/KIT-2-gobierno-documental.md`.
- **Editados:** `.claude/commands/jidoka/arranca.md` (surtir el detector §1b), `kit/.jidoka/instalar/manifiesto.json` (stub CONTRIBUTING → estructurado + sembrar ledger/detector/test como motor), `tools/probar-preflight.ps1` (aceptar la nueva línea), `.github/workflows/andon.yml` (step `-Estricto` opt-in, OFF), `andon/README.md` (mapa del gate nuevo), `CHANGELOG.md`, `docs/decisions/README.md` (índice), `docs/sprints/README.md` (registrar sprint).

## Verificación (el demo que corre el cliente) — owner: cliente
- **Demo sin código ni terminal:** en un **hijo-fixture desechable** (no enti — lo trabaja otro agente), correr `/jidoka:arranca` con un `CONTRIBUTING.md` deliberadamente vaciado → el cliente **ve el aviso** nombrando la sección faltante ("garantía nula"). En un doc conforme → "CONFORME". El cliente lo ve corriendo el **ritual**, no un script.
- Evidencia técnica (respaldo, no el demo): `qa_runs/documentos-gobernados-<fecha>/LOG.md` con la suite verde (`probar-docs` ROJO→VERDE, `probar-preflight`, `probar-instalador` regresión).

## Lo que NO entra
- No se toca el gobierno por-hash del motor (capa-1 ya funciona).
- **El grafo de producto NO entra** — lo gobierna `auditar.ps1` con su regla risk-scaled (C1).
- No se juzga contenido de secciones (solo presencia).
- No se fuerza ni sobrescribe la instancia del hijo (KIT-1 manda).
- El muro estricto **nace apagado** — este sprint entrega la palanca, no la enciende.
- No se baja nada a enti (lo trabaja otro agente; el demo usa fixture).

## Coordinación / cabos sueltos
- **enti**: solo-lectura o rama propia; nunca pisar su working tree.
- **Rama `fix/preflight-classificador-20260717` (45aa926)**: sin mergear, espera orden nombrada — independiente de este sprint (la rama del sprint se sacó sobre su HEAD para extender el preflight bueno).
