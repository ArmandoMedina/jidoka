# HANDOFF — relevo entre sesiones

> Estado en vuelo y pendientes. **Se llena al cerrar**, **se lee y se limpia al abrir.** Nada de memorias de la IA — todo va aquí.

## En una frase

**Jidoka** — el Sistema de Producción Toyota para agentes de IA: fusión de doctrina + método + ritual de sprint. Estable en `v1.x` (salió de beta en `v1.0.0`). Instalador PowerShell + CLI `npx jidoka-method` construido (pendiente `npm publish`). Se construye por sprints, usando su propio ritual (dogfooding).

## Dónde estamos (2026-07-13 — CERRADO Y LIBERADO · Jidoka `v1.10.0`)

**Sesión que atendió la cosecha de issues del lazo (#40–#46). Todo mergeado y liberado; `main` limpio.** PR #48 mergeado (836b14d), [release `v1.10.0`](https://github.com/ArmandoMedina/jidoka/releases/tag/v1.10.0) publicado (suite verde en el preflight). Plan-contrato: `docs/sprints/sprint-brownfield-2-plan.md`. Los 7 issues **acusados uno por uno** (el 3er paso del lazo); #40/#42/#43 cerrados con el release, #41/#44/#45/#46 abiertos con `regla-2-3`.

**Construido (`v1.9.0`→`v1.10.0`, ADR 0027 — tercera cosecha por el lazo):**
- **R1 (#40/#43) — la ruta de actualización deja de colgar del instalador.** `tools/sembrar-manual.ps1`: fallback de siembra/actualización **independiente de `instalar.ps1`** (sin `-ExecutionPolicy Bypass`, sin el nombre "instalar"), para Windows endurecido donde el AV pone `instalar.ps1` en cuarentena. Copia la mecánica del manifiesto + `core.hooksPath` + sello; no-clobber + tres vías. Registrado como pieza de motor (baja por el lazo). `estado-motor.ps1` **degrada con gracia** (apunta al fallback si `instalar.ps1` no es legible). Guía: `mantener-el-motor-al-dia.md`.
- **R2 (#42) — auditor configurable.** `auditar.ps1` lee `scanDirsExtra` de la ley (`tools/blast-radius.json`): amplía el índice de wikilinks a capas propias (`engineering/`) sin tocar el motor. Sin el campo, idéntico. Campo documentado en ambas plantillas de ley.
- **R3 — cosecha (regla 2-3, NO construida):** #41 (`doc-only`, 1er uso real), #44 (arquetipo `operacion`), #45 (gobernanza compuesta), #46 (prueba de vida ≠ tests verdes), y reducir superficie AV del instalador (renombrar/firmar/`npx`) → en `ROADMAP.md` → *Tercera cosecha por el lazo*. Los 7 issues etiquetados (`bug`/`leccion`/`regla-2-3`).

**Evidencia (verde, esta máquina 2026-07-13):** `probar-sembrar` 24/24 · `probar-auditor` 7/7 (con casos #42) · `probar-instalador` 51/51 (regresión) · `probar-gate` 10/10 · `probar-hooks` 17/17 · `probar-disparos` 4/4 · `probar-version` 1.10.0 · verificar sin bloqueo. Demo Gemba en `qa_runs/brownfield-2-20260713/`.

### Modo actual: dejar que se acumulen más issues (batch, no goteo)
Decisión del cliente (2026-07-13): **cerrar aquí y esperar a que se junten más lecciones** antes de la próxima cosecha. Los follow-ups están **en el backlog del ROADMAP** (*Follow-ups sueltos*), no requieren acción ya:
1. `publicar.ps1` no incluye `probar-sembrar` en su preflight (arreglo de una línea).
2. **[#47](https://github.com/ArmandoMedina/jidoka/issues/47)** sin triar (etiquetado `leccion`) + los abiertos `regla-2-3` (#41/#44/#45/#46) → material de la próxima cosecha.
3. **Bajar el batch a los labs** con `-Actualizar` (próxima ventana; `sembrar-manual` + auditor configurable + acuse son mecánica).
4. **Épica `.local` code-first + drift estructural** (ADR 0015): abierta de arcos anteriores.

## Antes (2026-07-11 — SESIÓN CERRADA · Jidoka `v1.8.1`)

**Sesión enorme, toda cerrada y liberada; los tres repos limpios.** Jidoka `v1.0.0`→`v1.8.1`; labs **SGI `v2.6.0`→`v2.8.0`**, **TF `v0.2.0`→`v0.4.0`**.

**Post-1.0 (`v1.1.0`→`v1.8.1`):** muro endurecido (grietas 2/5, ADR 0018) · hotfix hook Bash (`v1.1.1`) · el lazo ve la divergencia (`-Sellar`/`estado-motor -Detallado`, ADR 0019) · release desde el SSOT (`publicar.ps1`, ADR 0020) · lazo **EOL-agnóstico** (ADR 0021) · **lista de exclusión** del hijo (ADR 0022) · guía "mantener el motor al día" · `CODE_OF_CONDUCT.md` · párrafo en inglés · **CLI `npx jidoka-method` construido** (`package.json`+`bin/`) · **estructura canónica** (comandos namespaced, ADR 0023) · **el motor se lee del árbol** (ADR 0024, cierra el dogfood del ADR 0003 como *"no se migra"*).

**Bajado a ambos labs** (ventana de bajada + estructura canónica): SGI/TF corren el núcleo actual, comandos namespaced re-personalizados con su sabor, `excluir` declarado. **Drift estructural cerrado de raíz** (ADR 0021/0022/0023).

### Lo único pendiente — todo gatillado por el cliente (nada que la IA pueda hacer sola)
1. **`npm publish`** del CLI `jidoka-method` — necesita tu cuenta npm. Mientras tanto se usa con `node bin/jidoka-method.js init <ruta>`.
2. **Verificar el CLI/motor en Mac/Linux** (pwsh Core) — necesita un entorno no-Windows; no se declara cross-platform sin evidencia (`evidencia-no-palabra`).
3. **Social preview** del repo — imagen 1280×640 desde la UI de GitHub.

**Cuatro bugs de herramienta cazados por uso real** este arco (hook Bash, hash EOL, `publicar` ×2), más `probar-disparos` cazando su propio slug — todos ahora invariantes con test. El método sobre sí mismo.

### Antes (2026-07-11, `v1.4.0` — batch post-1.0 BAJADO a ambos labs)

**Modo de operación (decisión del cliente):** *avanzar Jidoka lo máximo posible acumulando releases y hacer UNA sola bajada a los labs al final* — la bajada (2 repos × PR/tests/merge) es la parte cara, no el release de Jidoka. Además, **el cliente elige el tamaño y la dirección del sprint; no preguntar** (yo decido por capacidad/esfuerzo, él frena si algo no cuadra).

**Releases post-1.0 (todos BAJADOS a los labs en la ventana de bajada):**
- **`v1.1.0` — "El muro cumple lo que promete"** (ADR 0018): grietas 2 y 5 cerradas con invariantes. `no-memorias` cubre Bash; registro de disparos cableados (`probar-disparos.ps1`).
- **`v1.1.1` — hotfix** (dogfood): el matcher Bash de `no-memorias` bloqueaba en falso lecturas con `2>&1`/`2>/dev/null` (el `>` casaba con la redirección de stderr). Cazado en vivo minutos después de publicar `v1.1.0`. `probar-hooks` 17/17.
- **`v1.2.0` — "El lazo ve la divergencia"** (ADR 0019): `instalar.ps1 -Sellar` (sello bootstrap clasificador pristina-vs-customizada) + `estado-motor -Detallado` (divergencia por-hash). `probar-instalador` 41/41.
- **`v1.3.0` — "El release se deriva del SSOT"** (ADR 0020): `tools/publicar.ps1` corta el tag+notas desde `version.txt`+CHANGELOG y corre la suite antes de publicar (Jidoka-only, dogfoodeado en su propio corte). `probar-publicar` 4/4.
- **`v1.4.0` — "El lazo es agnóstico al EOL"** (ADR 0021): `Get-MotorHash` normaliza a LF. Bug estructural cazado al bajar a TF (un hijo `eol=lf` divergía en todo). `probar-instalador` 42/42 (caso LF nuevo).

**✅ BAJADA CERRADA (2026-07-11).** El batch `v1.1.0→v1.4.0` bajó a ambos labs, verde server-side: **SGI `v2.7.0`** (PR #59, 7/7) y **TF `v0.3.0`** (PR #8, 5/5). Ambos corren el núcleo `1.4.0` con la mecánica genérica idéntica; code-first preservado (verificar/auditar/probar-gate/pre-push/escribano). Lecciones de la ventana (el uso real cazó lo que la revisión no):
- **Dos defectos estructurales del lazo** cazados y arreglados: `v1.1.1` (falso-positivo del matcher Bash con `2>&1`) y `v1.4.0` (hash sensible al EOL → un lab `eol=lf` divergía en todo).
- **La línea code-first-vs-genérico no estaba bien trazada:** hooks/tests genéricos (`gemba-stop`, `probar-hooks`) se estaban preservando como si fueran del lab. El operador la adivinó cada bajada. → **el drift estructural (ADR 0015 #3) necesita una LISTA DECLARADA de piezas code-first** por lab (o por convención de nombres), para que `-Actualizar` distinga "genérico atrasado" (adopta) de "customizado" (preserva) sin adivinar.
- Los gates de doc-sync de los propios labs (`barreras` → `docs/flujo-de-trabajo.md`) mordieron server-side y se sincronizaron.

**Pendiente en la ventana de bajada (NO se hizo, sigue abierto):** la **épica `.local` code-first** (converger verificar/auditar al motor genérico + costura `.local`, sin romper los 453 tests de SGI) y el **drift estructural** (lista declarada de code-first). Ambos siguen registrados (ADR 0015).

### Antes — PROGRAMA HACIA 1.0 (COMPLETO · `v1.0.0`)

**Jidoka salió de beta.** El programa de 3 sprints hacia 1.0 cerró completo. La vara del ROADMAP (*el método corre end-to-end en un repo ajeno*) quedó cumplida **con evidencia**: el núcleo bajó a dos labs ajenos reales con CI verde server-side.

- **✅ Sprint A** (`v0.13.0-beta`, ADR 0014): los 4 bloqueantes de "corre en un repo ajeno" cerrados (instalador pregunta arquetipo, método sembrado completo, fixture del quickstart, guía empezar-de-cero). PR #16 mergeado, release publicado.
- **✅ Sprint B** (labs): el núcleo bajó por el lazo. **SGI `v2.6.0`** (PR #58, 7/7 checks) — actualizar núcleo + **curar un bug del sello** (grababa piezas code-first como semilla pristina → auto-sanante). **TF `v0.2.0`** (PR #7, 5/5 checks) — cablear al lazo (sello + canal de subida + `core.hooksPath`) + convergencia ADR 0006. Ambos liberados, lo code-first preservado sin pisar nada. Evidencia en el `qa_runs/` de cada lab.
- **✅ Sprint C** (`v1.0.0`, ADRs 0015/0016/0017): segunda cosecha por el lazo (4 lecciones al backlog), licencia **MIT consciente**, y la **declaración 1.0**. `tools/version.txt` → `1.0.0`.
- **Alcance 1.0 funcional.** Diferido explícito a post-1.0 (ROADMAP): lo público (social preview, párrafo en inglés, `CODE_OF_CONDUCT`), CLI npm/SSOT, multiplataforma, reconciliación code-first vía `.local`, grietas 2 y 5, y las 4 lecciones de ADR 0015.
- **Estado de los labs:** SGI (`master`) y TF (`main`) corren el núcleo `0.13.0-beta`, cableados al lazo. La próxima mejora de Jidoka baja a ambos con `-Actualizar`.

### Qué sigue (post-1.0, modo batch — avanzar Jidoka, bajar una vez)

**Jidoka-interno (avanza sin tocar labs, acumulando releases):**
1. **CLI npm `npx jidoka-method init` + multiplataforma** — el mayor desbloqueo de adopción, pero **BLOQUEADO por verificación**: son cross-platform y esta máquina es Windows-only; declararlos aquí afirmaría que corren en Mac/Linux sin evidencia (`evidencia-no-palabra`). Necesitan un entorno no-Windows para probarse, o el cliente diciendo "shippéalo sin probar cross-platform". `npm publish` además necesita la cuenta del cliente. *(La parte SSOT/release-derivation ya se hizo en `v1.3.0`, ADR 0020.)*
2. **Dogfood ADR 0003** (motor solo en `kit/`, auto-instalación) — Windows-verificable pero **big-bet** (reubica el motor del que dependen todos los gates; alto blast-radius). Arquetipo `doc-only` sigue diferido (regla 2-3: sin consumidor real).
3. **Presentación pública** (Sprint 4): social preview, párrafo en inglés, `CODE_OF_CONDUCT`, badges — tiene piezas gatilladas por el cliente.

**En la ventana de bajada (necesitan labs, se hace UNA vez):**
4. **Re-sellar SGI/TF con `-Sellar` + `-Actualizar`** el batch acumulado (hook mejorado, `probar-disparos`, refinamientos del lazo).
5. **Épica `.local` code-first + drift estructural núcleo↔labs** (ADR 0015): la "mecánica igual" completa, sin romper los 453 tests de SGI.

Refinamientos del lazo #1 y #2 (sello bootstrap, `estado-motor -Detallado`): ✅ hechos en `v1.2.0` (ADR 0019).

## Antes (2026-07-11, la cosecha del lazo — CERRADA)

- **✅ Primera cosecha por el lazo MERGEADA y LIBERADA (`v0.12.0-beta`, ADR 0013).** PR #15 mergeado; [release](https://github.com/ArmandoMedina/jidoka/releases/tag/v0.12.0-beta). Tres lecciones absorbidas: gemba-stop exige evidencia rastreada por git, excepción de dominio con nombre, criterio operativo de delegación.

## Antes (2026-07-11, el lazo labs↔Jidoka — CERRADO)

- **✅ Lazo de sincronización labs↔Jidoka MERGEADO y LIBERADO (`v0.11.0-beta`, ADR 0012).** PR #14 mergeado; [release publicado](https://github.com/ArmandoMedina/jidoka/releases/tag/v0.11.0-beta). *La lección sube, la máquina baja*: sello de versión (`tools/jidoka-motor.json`) + SSOT (`tools/version.txt`); `-Actualizar` de tres vías por hash; aviso de divergencia (`estado-motor.ps1`); canal de subida (`reportar-leccion.ps1`); costura `.local`. Smoke 32/32.
- **✅ SGI = primer consumidor, MERGEADO** (SGI PR #57 squash a `master`, ADR 0036): sello retroactivo + canal + reporte de divergencia + 3 lecciones draft en `SGI/qa_runs/lazo-sync-20260711/` (pendientes de presentar con `reportar-leccion.ps1`). El aviso de divergencia se probó a sí mismo (SGI 0.10.1-beta detectado atrás de 0.11.0-beta).

## Antes (2026-07-11, cierre de la sesión de vitrina)

- **Todo MERGEADO y PUBLICADO hasta `v0.10.1-beta`.** PRs #1–#12 en MERGED; `main` limpio. Sprints 0–2 completos; Sprint 3 Fases 3.A/3.B publicadas; Homologación Etapa 1 + cosecha de SGI publicadas (`v0.9.0`/`v0.10.0-beta`, ADRs 0010/0011).
- **Sesión de hoy (vitrina, PR #12 → `v0.10.1-beta`):** README reescrito con **7 lectores en frío** como evidencia (Gemba de prosa en `qa_runs/lector-en-frio-readme-20260711/`); **GIF del gate mordiendo** en el README — render fiel de una corrida REAL en SGI (`docs/assets/gate-bloqueando.gif`, procedencia en `docs/guias/guion-gif-del-gate.md`, evidencia en `qa_runs/gif-gate-20260711/`); **SimGhostInputs (público) nombrado y linkeado** como evidencia del linaje (grieta 4 avanzada); quickstart curado tras fact-check hostil (el snippet anterior NO bloqueaba — se reprodujo y se probó la cura en clon); doc-drift interno curado en cascada (versión, tabla de sprints, `docs/sprints/`, `kanban/README`, `empezar-de-cero`, ROADMAP).
- **Lote de hallazgos REGISTRADO en `ROADMAP.md` para una sesión dedicada** (el cliente lo resolverá con una sesión Opus corriendo el método): el instalador que pregunte el arquetipo interactivo (Fase 3.C), el quickstart como caso end-to-end de `probar-gate.ps1` (Fase 3.C), el matiz de la cita Airbus en doctrina (backlog), y las ideas de los lectores sin destino aún (el "GIF del momento del cliente" — un Gemba visto por sus ojos — cuando exista la guía de cero).
- **Panorama registrado en el backlog** (con fuentes): **OpenWiki** (LangChain — complemento, no competidor; jamás meter doc auto-generada dentro de la ley) y **GBrain** (Garry Tan — el "pregúntale al proyecto" en lenguaje llano para no-técnicos, candidato a futuro sobre las docs curadas de este y todo repo sembrado).
- **HOMOLOGACIÓN — Etapa 2, lo que falta: TF (tracker-financiero).** El único lab pendiente de adoptar el núcleo; en su rama, reversible, conservando su casting como personas y su config-instancia. Su plan propio. Sus pendientes viven en SU HANDOFF.
- **El lazo de sincronización labs↔Jidoka — DISEÑO REGISTRADO, pendiente de plan** (pedido del cliente al cierre): *la lección sube (issue `leccion.md` → Jidoka arregla con su ritual), la máquina baja* (sello de versión sembrado + modo `-Actualizar` del instalador que re-siembra solo el motor, nunca la instancia + aviso de divergencia en el hijo). Detalle completo en `ROADMAP.md` → Fase 3.C. SGI es el primer consumidor.
- **Sprint 3 · Fase 3.C — lo diferido** (ver `ROADMAP.md`): `doc-only`, CLI npm + SSOT de versión + release-CI, multiplataforma, barreras code-first, dogfood del ADR 0003, + los dos ítems nuevos del fact-check.
- **Grietas de auditoría:** 1 CERRADA (Fase 2·B) · 2 abierta (`no-memorias` no cubre Bash; confesada como frontera) · 3 aceptada como límite v0 · 4 AVANZADA (SGI público; el resto a Sprint 4) · 5 abierta (disparos sin cablear).
- **Sprint 4 — Beta estable**: guías completas (la de empezar-de-cero es esqueleto), presentación pública, `v1.0` cuando corra end-to-end en un repo ajeno.

## Autorizaciones vigentes del cliente (dichas con nombre)

- **Publicar releases de GitHub** (2026-07-10): "Eres libre y autorizado para publicar versiones" — tag + release del cierre no necesita re-autorización.
- **Merges de PR y cambios de configuración/permisos**: SIGUEN necesitando orden nombrada cada vez ("no me muevas configuración", dicho explícito).

## Checklist humana (el cordón es tuyo)

- [ ] **Social preview** (solo se puede desde la UI) — receta en `ROADMAP.md` → *Vitrina pública* ⏳2. Con el GIF del gate ya hay material visual para derivar la imagen.
- [ ] **Dos decisiones que solo tú puedes tomar**: el párrafo en inglés del README y el ADR de la licencia (MIT vs copyleft) — argumentos en `ROADMAP.md` → *Vitrina pública* ⏳4 y ⏳5.
- [ ] **La sesión Opus del lote de hallazgos** — cuando tengas límite fresco: los pendientes están en `ROADMAP.md` (Fase 3.C nuevos + backlog), cada uno con contexto para retomarse sin re-explicación.

## Qué sigue (en orden de valor — detalle en ROADMAP.md)

1. **Homologación Etapa 2 — TF adopta el núcleo** (el único lab que falta; cierra la homologación).
2. **El lote de hallazgos del ROADMAP** en sesión dedicada corriendo el método.
3. **Sprint 3 · Fase 3.C** (por valor: CLI npm/SSOT de versión, multiplataforma) y **grietas 2 y 5**.
4. **Sprint 4 — Beta estable** (incluye el resto de la grieta 4: evidencia pública del linaje).
