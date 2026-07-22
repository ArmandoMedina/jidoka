# Sprint — El molde único de sprints y `qa_runs` (patrón ADRs, sin monolito)

> Plan aprobado en plan mode el 2026-07-22. **Este plan ES el sprint**: lo que no está aquí, no entra (se anota abajo en "Lo que NO entra"). El número canónico del sprint se asigna en R2 (esta capacidad introduce la numeración).

## Contexto (por qué)

Los ADRs ya viven bajo molde con guardián que bloquea el drift (ADR 0050). **Sprints, `qa_runs`, módulos y dominios no**: los sprints no tienen número canónico y sus `-plan.md`/`-entrega.md` divergen; cada `LOG.md` de `qa_runs/` es formato libre; módulos y dominios también divergieron. Es la clase de deriva que Jidoka combate — hoy sin muro.

**Hallazgo de arquitectura (arquitecto/opus, 2026-07-22) que reencuadra el pedido:** no se crea un `probar-<familia>.ps1` por familia (clona la mecánica de `Fold`/`Get-Secciones` en zona minada de PS 5.1) ni un `.ps1` monolítico (punto único de falla: entraría en la lista secuencial de `andon.yml` y un bug en "sprints" tumbaría el muro de ADRs). **La tercera vía ya existe en el repo:** `tools/estado-docs.ps1` es un motor genérico ledger-driven (`tools/docs-gobernados.json`, ADR 0042) que valida secciones **por datos, no por código**. Se extiende agregando filas.

## Encuadre de producto (validado con el cliente)

Ata a **[[AND-1-muro-andon]]** (cuando algo diverge, un muro lo para, fuera del LLM) y a la tesis anti-drift. El formato que se desvía en silencio es exactamente el fallo que el método existe para cerrar. La capacidad que gana el usuario: que un sprint y un `LOG.md` **nazcan conformes y no puedan desviarse**.

## Decisiones del cliente

- **2026-07-22 — Alcance:** un solo sprint, rebanadas verticales.
- **2026-07-22 — Rama:** sale de `consolida-tuberia-adrs-20260722` ya; rebase a `main` cuando #125 mergee.
- **2026-07-22 — Arquitectura:** extender el motor genérico `estado-docs.ps1` por ledger; NO un `.ps1` monolítico. `probar-adrs.ps1` se queda aparte (hace más que secciones).
- **2026-07-22 — Módulo/dominio/capacidad (restricción dura, ADR 0042 §dec.5 y §camino-d):** su homologación de formato se refuerza dentro de `auditar.ps1` (su dueño), NO en el ledger. Capacidades ya se auditan (Gherkin) → sin trabajo.
- **2026-07-22 — Severidad:** sprints/`qa_runs` nacen `estricto:false` (aviso; muro opt-in en CI). Palanca `estricto:true` disponible si se quiere dureza tipo ADR.

## Criterios de aceptación (Gherkin — demostrables sin código ni terminal)

- **CA-1 (numeración):** *Dado* que abro `docs/sprints/README.md`, *entonces* veo los sprints numerados en orden con nombre canónico.
- **CA-2 (molde sprints):** *Dado* que abro dos `-entrega.md`, *entonces* comparten las mismas secciones canónicas.
- **CA-3 (skill generadora):** *Dado* que corro la skill, *entonces* nace un sprint ya conforme (veo el archivo).
- **CA-4 (guardián sprints):** *Dado* un sprint sin una sección requerida, *cuando* corre el verificador, *entonces* lo marca DESVIADO en el reporte de conformidad que abro con doble clic.
- **CA-5 (molde qa_runs):** *Dado* que abro dos `LOG.md`, *entonces* comparten estructura (fecha · rama · método · tabla de evidencia).
- **CA-6 (guardián qa_runs):** *Dado* un `LOG.md` sin secciones mínimas, *entonces* sale DESVIADO en el reporte.
- **CA-7 (módulos/dominios):** *Dado* que abro dos módulos (o dos dominios), *entonces* comparten molde de secciones — verificado por `auditar.ps1`, no por un gate nuevo.

## Alcance (rebanadas verticales)

1. **R1 — El motor: de singleton a glob-familia (la de riesgo, va SOLA; toca la ley, área `barreras`).** Generalizar `docs-gobernados.json` + `estado-docs.ps1` para soportar `doc` como glob de familia (`docs/sprints/*-plan.md`, `qa_runs/*/LOG.md`), expandiendo con `Get-ChildItem`. Riesgo: glob que no matchea = CONFORME en falso (verde mentiroso). Self-test en `probar-docs.ps1` con caso sintético de familia (2 archivos, uno conforme, uno DESVIADO). Verde sin agregar familias reales.
2. **R2 — Sprints: numeración + molde + skill.** Numerar los sprints en orden cronológico (`git mv`) y reflejarlo en `docs/sprints/README.md`. Fila(s) al ledger con las `requeridas` de `sprint-plan.md`/`sprint-entrega.md`. Homologar los existentes (solo estructura). Skill generadora `/jidoka:nuevo-sprint` que copia el template conforme.
3. **R3 — `qa_runs`: molde del `LOG.md`.** Fila al ledger con las `requeridas` de `qa-log.md`. Homologar los `LOG.md` existentes.
4. **R4 — Módulos y dominios: reforzar molde en su dueño (`auditar.ps1`).** Descubrimiento primero: leer `kit/.jidoka/templates/validar-dominio.ps1` (ya existe). Reforzar el molde de secciones dentro de `auditar.ps1`, NO en el ledger. Homologar `product/modulos/*` y `product/dominios/*`. Capacidades: cero trabajo.
5. **Cierre — Cableado y siembra.** Cablear a `andon.yml`, `publicar.ps1`, `manifiesto.json`; documentar en `andon/README.md`; ADR nuevo ("extender el motor, no clonar guardianes"); índice de ADRs, CHANGELOG, quitar el ítem del ROADMAP, HANDOFF; Gemba.

## Archivos

- **R1:** `tools/estado-docs.ps1`, `tools/docs-gobernados.json`, `tools/probar-docs.ps1`.
- **R2:** `docs/sprints/*.md` (+ `git mv` para numeración), `docs/sprints/README.md`, `kit/.jidoka/templates/sprint-plan.md`/`sprint-entrega.md`, skill en `.claude/commands/jidoka/`.
- **R3:** `qa_runs/*/LOG.md`, `kit/.jidoka/templates/qa-log.md`.
- **R4:** `tools/auditar.ps1`, `product/modulos/*`, `product/dominios/*`, `kit/.jidoka/templates/validar-dominio.ps1` (leer antes de tocar), self-test del auditor.
- **Cierre/ley:** `.github/workflows/andon.yml`, `tools/publicar.ps1`, `kit/.jidoka/instalar/manifiesto.json`, `andon/README.md`, `docs/decisions/` (+ índice), `CHANGELOG.md`, `ROADMAP.md`, `HANDOFF.md`.

## Verificación (el demo que corre el cliente) — `owner: cliente`

**Cómo lo corre (sin código ni terminal):**
1. Abre `docs/sprints/README.md` → los sprints están numerados en orden (CA-1).
2. Abre dos `-entrega.md` distintos → mismas secciones (CA-2). Ídem dos `LOG.md` (CA-5). Ídem dos módulos/dominios (CA-7).
3. Corre la skill nueva desde la app/comando → nace un sprint ya conforme (CA-3).
4. Abre el reporte de conformidad (`conformidad-docs.html` o equivalente) con doble clic → tabla CONFORME / DESVIADO por familia; un doc al que le quito una sección aparece DESVIADO (CA-4, CA-6).

## Lo que NO entra (siguientes)

- **No reescribir el contenido** de sprints, logs, módulos ni dominios — solo homologar estructura.
- **No tocar el molde de ADRs** (ya gobernado).
- **No meter capacidades/módulos/dominios al ledger** (contradice ADR 0042; van por `auditar.ps1`).
- **No un `.ps1` monolítico** que fusione ADR + qa + sprints (punto único de falla en `andon.yml`).

## Riesgos / banderas

1. **R1 es el punto de riesgo:** motor sembrado a los hijos; un glob mal expandido = verde mentiroso. Self-test obligatorio antes de agregar familias reales.
2. **`validar-dominio.ps1` ya existe** como template → descubrir antes de crear en R4.
3. **Severidad opt-in:** sprints/`qa_runs` nacen como aviso, no muro duro como ADR — palanca `estricto:true` (decisión de negocio).
4. **Módulo/dominio/capacidad** se desvían del pedido literal ("meterlos también"): van a `auditar.ps1`, no al ledger, por ADR 0042.
