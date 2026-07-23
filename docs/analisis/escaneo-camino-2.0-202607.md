# Escaneo — el camino a una «2.0 estable» (4 ángulos, 2026-07-22)

> Cuatro asientos `arquitecto` en paralelo, solo-lectura, sobre `main` en `v1.30.0` (PR #126).
> Pregunta del cliente: fijar una versión de salida estable (candidata: 2.0), mapear todo lo
> que falta, y servir tres objetivos: revisar documento por documento con la UI asignando
> parámetros, ver exactamente cómo funciona la lógica de bloqueos/avisos (código repetido
> incluido), y asegurar que la IA viaje solo por los caminos planeados.
> La restricción vigente es la capacidad de absorción del dueño (diagnóstico de flujo 2026-07).

## Veredicto en una frase

**Entre v1.30.0 y una 2.0 instalable sin miedo no hay un cerro de features: hay un corte de
honestidad (~5h), tres curas de fiabilidad, y las superficies para que el cliente absorba sin
terminal — lo demás que se encontró ya estaba en el ROADMAP o es doctrina deliberada.**

## Ángulo 1 — Gobierno documental y parametrización

- **Los «parámetros» de un documento viven en 4 ledgers con 4 guardianes y 4 caminos de
  escritura**: `docs-gobernados.json` (secciones, guardián `estado-docs.ps1`), `flujo.json`
  (techos/contratos, guardián `verificar.ps1`), `product/*` (frontmatter/Gherkin, guardián
  `auditar.ps1`) y `blast-radius.json` (co-ocurrencia, guardián `verificar.ps1` + Stop hooks).
- **Hallazgo crítico (teatro no confesado):** el radio «Estructura gobernada» del formulario de
  la app (`app/ui/index.html:693`) escribe `contratos.json` vía `parametrizar.ps1`, pero el
  guardián de secciones lee `docs-gobernados.json` — que `parametrizar.ps1` **no toca en ningún
  punto** (`parametrizar.ps1:234-281`). Marcarlo en la UI no vigila ninguna sección.
- **La vista miente por omisión:** `tuberia-datos.ps1:194-195` emite `confHoy`/`confVision`
  vacíos (no lee `docs-gobernados.json`), y ROADMAP/HANDOFF/CHANGELOG salen como régimen
  «libre» (`tuberia-piezas.json:103-109`) teniendo muro real de formato en `flujo.json`.
- **Deuda de siembra:** `docs-gobernados.json` se siembra clase `mecanica` (clobber,
  `manifiesto.json:40`); dar UI de alta de secciones presupone que sea de instancia
  (no-clobber) — re-clasificarlo exige ADR antes de diseñar la UI.
- **`contratos.json` no existe aún en la nave**: el camino bandeja→parametrizar→candado está
  codificado y con self-test, pero nunca ejercido de punta a punta (Gemba end-to-end pendiente).

## Ángulo 2 — Lógica de bloqueos/avisos y código repetido

- **Inventario completo**: 7 hooks (2 PreToolUse deny, 4 Stop block, 1 SessionStart vista),
  verificar (blast-radius + no-borres-el-motor + 3 contratos FLU-1), estado-ligas, anti-pii,
  auditar, estado-docs/-ritual (`-Estricto`, nacen apagados), estado-flujo `-Gate`, expirar,
  pre-push local (saltable), CI `andon.yml` (el único muro server-side, y solo si branch
  protection lo marca required — confesado en `andon.yml:5-9`).
- **Un solo `doc_bloquea` real en toda la ley** (`decisiones`, `blast-radius.json:7`); las otras
  10 áreas avisan. Deliberado (baja fatiga), pero el cliente debe saberlo.
- **14 duplicaciones localizadas.** Las graves: `Test-Pattern` ×8 byte-idénticas (verificar,
  estado-ligas, estado-gobierno, bandeja + 4 Stop hooks) — el corazón semántico del enforcement;
  parser del ROADMAP ×3 (verificar/estado-flujo/expirar — si divergen, `expirar` **borra** mal);
  `Clase-Display` ×2 **ya divergió** en claves internas (`con_fecha` vs `confecha`);
  `Normaliza` ×3, `Get-Secciones` ×4, `Get-Frontmatter` ×3 con 2 firmas, triple-fallback git ×2.
- **La duplicación es doctrina, no descuido** (standalone sin dot-source, declarado en
  `probar-agentes.ps1:33`, `estado-ligas.ps1:55-56`). La cura no es DRY: es un self-test que
  falle si las copias divergen (convertir la copia en contrato verificado).
- **Huecos de fiabilidad:** (H1) `auditar.ps1:110` no checa `$LASTEXITCODE` en `-Range` — si git
  falla, aprueba en silencio con exit 0 (el único gate fail-open del sistema); (H7) el
  salvavidas `no-borres-el-motor` (`verificar.ps1:160`) no cubre `.claude/hooks/*`,
  `settings.json` ni `.githooks/*`; (H5) el orden de Stop hooks en `settings.json` no coincide
  con la autoridad narrada por `rutear.ps1`.
- **Legibilidad:** el mapa solo existe corriendo scripts. `estado-gobierno.ps1` ya genera un
  HTML autocontenido del grafo — nadie lo llama en el flujo.

## Ángulo 3 — Los caminos planeados de la IA

- **Asimetría estructural:** los muros duros viven al editar piezas candadas (PreToolUse) y al
  cerrar (Stop). Arrancar bien, planear antes de picar y no saltarse plan mode son **prosa**.
- **11 casos de uso mapeados** (muro/prosa/nada). Los descubiertos: sesión sin `arranca`
  (prosa), edición sin plan aprobado (nada), push directo a main (opt-in local, sin branch
  protection server declarada — ROADMAP #47), saltarse plan mode (prosa; el cliente lo reclamó
  4× medido; **cero matchers `ExitPlanMode` cableados**), compactación (PreCompact sin cablear),
  dos sesiones escritoras (prosa con daño demostrado), `permissions` allow/ask/deny
  (**el bloque no existe en `.claude/settings.json`**), «listo» sin evidencia en lógica pura
  (solo review-marker humano).
- **Ley vigente que un plan no debe contradecir:** regla 2 de `kanban/roles.md:70` — no todo
  merece hook; se cablea lo que ya se salió del carril **en campo, medido**. Y el muro de main
  es server-side (disparo `no-verify-es-teatro`), dominio del devops fuera del repo.
- **Para poder AFIRMAR «la IA viaja por los caminos»**: (A) suite de simulacros off-path
  (`probar-caminos.ps1`, ~8h, extiende `probar-hooks.ps1` de hook-aislado a escenario) +
  (B) matriz de carriles publicada como doc vivo (~2h) con la métrica de correcciones del cuadro
  de cierre. Sin A ni B la afirmación es el acta que se auto-firma.

## Ángulo 4 — Qué hay entre v1.30.0 y la 2.0 instalable sin miedo

- **La cadena de instalación está probada por suite, no por palabra**: `instalar.ps1` y
  `probar-instalador.ps1` presentes en el árbol (sin cuarentena activa); no-clobber verificado
  en vivo; actualización de tres vías (`.jidoka-nuevo`) probada; brownfield/EOL/exclusión/sello
  cubiertos; `sembrar-manual.ps1` como ruta AV-independiente probada; SSOT de versión gateado.
- **Promesas vs realidad:** `package.json:32-36` declara `darwin/linux` sin evidencia —
  **contradice la propia ley del repo** («no se declara cross-platform sin evidencia»,
  ROADMAP) y es el único fail-open que muerde al ajeno de verdad (hooks mudos en no-Windows);
  `npx jidoka-method` prometido 3 veces y no publicado; badges del README dicen «1.0 estable»
  con el repo en 1.30 (no gateados); tras instalar, nada grita que branch protection es manual.
- **Lo que NO se hereda:** el teatro de la app (reconciliar/alta-agente) es Jidoka-only, no se
  siembra (`app/README.md:8`).

## La lista cerrada del corte «estable 2.0» (propuesta al cliente)

**BLOQUEA-2.0** (~5h): B1 `package.json` os honesto a `["win32"]` (1h) · B2 reconciliar la
promesa `npx` — publicar o recortar del README (0.5-2h) · B3 aviso ruidoso post-instalar
«el muro server-side aún NO muerde: branch protection es manual» (2h).

**FIABILIDAD** (mismo corte, ~6h): F1 self-test anti-drift de las copias gemelas (4h) ·
F2 cerrar el fail-open de `auditar.ps1` (1h) · F3 salvavidas cubre hooks/settings/.githooks (1h).

**SUPERFICIES DE ABSORCIÓN** (sirven la restricción del cliente, ~6h): S1
`conformidad-docs.html` (ya en ROADMAP, 2h) · S2 mapa de enforcement HTML cableado + self-test
vista==rutear (2h) · S3 matriz de carriles de la IA como doc vivo (2h).

**SIGUIENTE OLA (no bloquea 2.0, habilita el objetivo doc-por-doc):** V1 la UI dice la verdad
por documento — `tuberia-datos` consolida los 4 ledgers (6h) · V2 parametrizar secciones desde
la UI — `-Requeridas` + ADR de re-clasificación no-clobber de `docs-gobernados.json` (6h) ·
V3 suite `probar-caminos.ps1` de simulacros off-path (8h) · V4 permisos allow/ask/deny + plan
mode inescapable (ya en ROADMAP, 4h).

**FUERA DE 2.0** (regla 2-3, difierelo el propio repo): multiplataforma real, firma
Authenticode (mitigada por `sembrar-manual`), cartones de la app, comunidad.

> Los cuatro informes completos con toda la evidencia archivo:línea viven en la conversación de
> la sesión 2026-07-22; este doc es la síntesis citable. Los ítems accionables quedaron en
> `ROADMAP.md` con contrato de ítem.
