# Sprint — La app de la tubería: la maqueta se vuelve el producto (Tauri) · Entrega

> El récord del sprint (`v1.27.0`, ADR 0048). Plan-contrato: [sprint-app-tuberia-plan.md](sprint-app-tuberia-plan.md) (aprobado en plan mode 2026-07-21, STOP 2). Evidencia: [`qa_runs/app-tuberia-20260721/LOG.md`](../../qa_runs/app-tuberia-20260721/LOG.md).

## Objetivo

*El usuario abre UNA app de escritorio (doble clic) idéntica a la maqueta validada — tubería, bandeja, formulario, modo avanzado en la misma ventana — leyendo y escribiendo los datos reales del repo vía el motor PowerShell.* La superficie del gobierno deja de ser comandos dispersos de VS Code y pasa a ser la maqueta navegable que el cliente aprobó en 6 Gembas.

## Decisiones

- **ADR 0048** — la superficie del gobierno es la **app de la tubería (Tauri v2)**; supersede al **ADR 0044 en la superficie** (cambia el QUIÉN autora: la app, ya no la extensión; el principio "la UI autora, el gate ejecuta" sigue vivo). Alternativas descartadas con porqués (extensión VS Code, web local, File System Access API, Electron).
- **La firma se DERIVA de `git config` DENTRO de `override.ps1`**, nunca por parámetro (refuerza el ADR 0047 con dientes: si la app pudiera pasar el firmante, podría inventarlo). El escritor único es dueño de la regla.
- **El motor PS es el único escritor** de los ledgers: `parametrizar.ps1` (port de `contratos.js` + `ritual.js`) y `override.ps1` (port de `registrarOverride` + `firmaDeterminista`); la app invoca, no escribe.
- **`app/` es Jidoka-only** (no se siembra a los hijos; invariante en `probar-app.ps1`, migrado del de `probar-extension.ps1`).
- **Gemba de fidelidad ANTES de cablear datos** (el 6º criterio del R0, mandatorio): la cara se aprueba en R2, con la app aún de teatro, antes de tocar un solo dato real.

## Qué se entregó

Contra el alcance del plan (7 rebanadas), todas entregadas:

- **R1** — Cierre del legado: ADR 0048 + índice, CHANGELOG `v1.26.0` del sprint anterior, SSOT `1.26.0`, HANDOFF reconciliado, plan archivado, LOG iniciado. PR del sprint legado abierto (⏸ orden nombrada).
- **R2** — El cascarón Tauri v2 en `app/`: `ui/index.html` copia **byte-fiel** de la maqueta congelada (SHA256 idéntico), `src-tauri/` completo, `probar-app.ps1`, área `app` en la ley, cableado en las DOS listas (`publicar.ps1` + `andon.yml`). **GEMBA temprano APROBADO por el cliente.**
- **R3 (motor)** — `tuberia-datos.ps1` (el consolidador) + `tuberia-piezas.json` (semilla curada: **49 piezas / 57 aristas**, no las 37+42 estimadas — la semilla es fiel al artefacto) + switch `-Json` aditivo en `bandeja.ps1`/`estado-ritual.ps1`.
- **R4 (motor)** — `parametrizar.ps1`, el escritor único (upsert de contrato + agregar a fuente + insertar `@`; acumula avisos, jamás éxito falso).
- **R5 (motor)** — `override.ps1`, la acción firmada (candado/reclasificar/aceptar desviación con firma derivada de git, aborta sin `user.name`).
- **R3 (UI)** — `app/ui/index.html` deja el teatro en las **lecturas**: al abrir corre el motor real vía el puente Rust (`std::process::Command`, no el plugin shell — menos superficie) y pinta la tubería/bandeja con SUS piezas/regímenes/candados/cola reales. `<style>` intacto (byte-idéntico a la spec).
- **R4 (UI)** — el formulario de alta **escribe de verdad**: `invoke('parametrizar')`, preview + éxito + lista de avisos reales + refresco automático. (Wizard `'doc'` confesado como teatro: distinta forma de datos; su botón final lleva al formulario real que sí escribe.)
- **R5 (UI)** — el modo avanzado reclasifica/firma/pone candado de verdad: contraseña = **nombre del repo** (retira `GARANTIA-NULA`), firma real derivada de git visible, éxito parcial honesto, candado-off desde la UI.
- **R6** — VS Code queda limpio: `extension/` retirado completo (`git rm`), `probar-extension` retirado (su invariante migró a `probar-app`), área `extension` retirada de la ley; el gate `no-borres-el-motor` aceptó el borrado con el ADR 0048 en el mismo rango.
- **R7** — Empaquetado + `v1.27.0`: SSOT en los 4 sitios, bundle NSIS (`jidoka-tuberia_1.27.0_x64-setup.exe`, 1.86 MB, no versionado). **PR + merge + release = orden nombrada (⏸).**

**Desviaciones deliberadas y confesadas:**
- **R3–R5 partidas en mitad-motor / mitad-UI.** La mitad motor (los comandos PS) avanzó autónoma; la mitad UI esperó el STOP de fidelidad de R2. Confesado por rebanada en el LOG.
- **La firma por derivación (no por parámetro)** en `override.ps1` — diverge del texto del plan R5 (que listaba `-Quien -Email`) a propósito, para reforzar el ADR 0047.
- **La rama de la app se sacó desde la rama del legado**, no desde `main` post-merge, porque el merge del legado espera orden nombrada del cliente.

## Evidencia (review)

5 reviews de auditor `sonnet` (uno por rebanada con código: R2, R3-motor, R4-motor, R5-motor, R3-UI, R4/R5-UI); mecánicos `haiku`/`sonnet` para los fixes. Suites al cierre: `probar-app` 35/35, `probar-parametrizar` 27/27, `probar-override` 26/26, `probar-bandeja` 21/21, `probar-ritual` 19/19, `probar-publicar` 7/7, `probar-version` 0, `anti-pii` 0, `verificar` 0 (incl. `-Base main` con `no-borres-el-motor` OK), `auditar` 0. Corrida: [`qa_runs/app-tuberia-20260721/LOG.md`](../../qa_runs/app-tuberia-20260721/LOG.md), committeada con `git add -f` en cada rebanada.

**Hallazgo del cierre (los artefactos ganan — y el gate mordió de verdad):** el CI de **PR #121 estaba ROJO** al cerrar el código — `probar-ligas.ps1` fallaba (`[FALLA] ledger real: hay ligas rotas`, 1 fallo / 24 ok, reproducido local). Causa: R6 borró `extension/` pero `tools/ligas.json` conservaba la liga `linterna-extension` apuntando a `extension/*` → el ledger de ligas mentía con un puntero colgante. `probar-ligas` no estaba en el alcance de ninguna rebanada y el hueco se coló. **Hallazgo cazado por el gate en el cierre y CURADO en el mismo cierre:** la entrada `linterna-extension` se retiró de `tools/ligas.json` (array `ligas` queda vacío); `probar-ligas` pasa 25/25, `verificar` exit 0. El CI de #121 quedará **verde** tras el push de esta cura. PR #120 (legado) tiene CI **verde**.

## Hallazgos de la data real

1. **La maqueta congelada tiene 49 piezas / 57 aristas**, no las "37+42" que estimó el plan — la semilla es fiel al artefacto, no a la estimación.
2. **El colapso de arrays de 1 elemento de PS 5.1 muerde en dos sitios**: `ConvertTo-Json` Y el retorno de funciones (`@($x)` se re-desenvuelve a escalar al salir). Los self-tests con el caso de 1 elemento cazaron un bug real (área existente reportada como inexistente) antes de cablear.
3. **La primera cura del CI rojo era doblar el gate, no curarlo**: excluir `probar-ritual.ps1` del detector anti-PII del PR maquillaba el síntoma. La cura real fue arreglar los fixtures (que no parezcan emails) y **revertir la exclusión**.
4. **Los assets del frontend van embebidos en el exe de Tauri**: todo cambio de UI exige recompilar (`npx tauri build`) o el Gemba ve la versión vieja.
5. **Retirar la extensión rompió una liga viva**: `ligas.json` seguía apuntando a `extension/*` (ver "Evidencia") — la superficie retirada dejó un puntero colgante que el gate de ligas cazó en el CI. **El gate mordió de verdad en el cierre, y la cura ocurrió en el mismo cierre** (la entrada `linterna-extension` se retiró de `tools/ligas.json`; 25/25 verdes).

## Verificación (el demo que corre el cliente) — `owner: cliente`

**Media cerrada (SÍ):** el cliente corrió el **Gemba de FIDELIDAD de R2** (doble clic al `.exe`, sin código ni terminal, 2026-07-21) y aprobó con sus ojos: *"Sí es fiel... abre y se ve como me gustó"*. La cara de la app ES la maqueta — ese criterio (el 6º del R0, el que manda) queda **cumplido**.

**Media abierta (NO — va en "Pendiente que dejó"):** el demo **completo end-to-end** (crear un glosario por fuera → verlo en la bandeja → parametrizarlo desde el formulario → poner candado desde el modo avanzado → ver a la IA rebotar) **el cliente NO lo ha corrido todavía**. Está verificado por partes (los motores producen escrituras reales con los args exactos del puente; el JS parsea; el `.exe` arranca) pero **el clic real, end-to-end, no lo hizo un humano**. No se da por cumplido: la verticalidad completa la cierra el Gemba del cliente.

Los pasos del flujo completo, para cuando el cliente lo corra (sin código, sin terminal, sin VS Code):

1. Instalar desde `jidoka-tuberia_1.27.0_x64-setup.exe` → abrir → selector de carpeta → apuntar al repo Jidoka.
2. Ver las 49 piezas con su régimen/candado real; la bandeja con la cola real.
3. Crear `docs/glosario-del-dominio.md` por fuera → `↻ Refrescar` → verlo aparecer en la bandeja.
4. "Parametrizar →" el glosario → llenar el formulario (tipo, régimen, fuerza, comandos) → "✍️ Escribir el contrato" → éxito + `@` insertado + la pieza sale de la bandeja.
5. Modo avanzado → teclear el nombre del repo (`jidoka`) → reclasificar + candado → "✍️ Firmar y aplicar" → ver la firma real (derivada de git).
6. En una sesión de Claude Code, pedir a la IA editar la pieza con candado → verla **rebotar**.

## Pendiente que dejó

- [ ] Correr el **Gemba completo end-to-end** (flujo del glosario, pasos arriba; sin código ni terminal) — la mitad de la Verificación que falta.
- [x] **Liga rota curada** en `tools/ligas.json`: la entrada `linterna-extension` (apuntaba a `extension/*`, borrado en R6) se retiró — hallazgo cazado por el gate en el cierre y curado en el mismo cierre. `probar-ligas` 25/25, CI de #121 verde esperado tras el push.
- [ ] Orden nombrada: **merge #120** (legado `v1.26.0`, CI verde).
- [ ] Orden nombrada: **merge #121** (app `v1.27.0`) + tag/release `v1.27.0` + subir `jidoka-tuberia_1.27.0_x64-setup.exe` como asset del release.
- [ ] Decisión del cliente: **¿el retiro de la extensión amerita MAJOR (`v2.0.0`)** en vez de `v1.27.0`? (breaking confesado; en régimen 1.x de este repo lo decide el cliente).
- [ ] Destino de la copia scratch `.jidoka/maqueta-tuberia.html` (dice "SAP", quedó vieja; la spec real vive en `docs/analisis/`).
- [ ] Atlas de los tools nuevos (`tuberia-datos`, `parametrizar`, `override`) — pulido del cliente; va al HANDOFF.

## Lo aprendido (Kaizen)

1. **Un plan que excluye algo visible que el cliente ya validó debe resaltarlo en una línea** ("NO verás X"). La cura estructural fue el **Gemba temprano**: la fidelidad visual se aprobó en R2, antes de cablear un solo dato — y funcionó (cero retrabajo visual).
2. **Los gates corren desde la base en el CI a propósito.** La primera cura del CI rojo (excluir el archivo en el detector del PR) era doblar el gate y no curaba nada; la cura real fue arreglar los fixtures (que no parezcan emails) y revertir la exclusión. Corolario: fixtures de tests jamás con forma `letra@dominio.punto`.
3. **El escritor único es dueño de las reglas.** La firma se deriva de `git config` DENTRO de `override.ps1`, no por parámetros — si la UI pudiera pasar el firmante, podría inventarlo (ADR 0047 con dientes).
4. **PS 5.1 muerde en los bordes de JSON**: colapso de arrays de 1 elemento (`ConvertTo-Json` y también el retorno de funciones que desenvuelve `@($x)`), BOM, `-Depth`. Los self-tests con el caso de 1 elemento cazaron un bug real antes de cablear.
5. **Los assets del frontend van embebidos en el exe de Tauri**: todo cambio de UI exige recompilar o el Gemba ve la versión vieja.

## Cuadro de cierre

| Hecho | Valor |
|---|---|
| Sprint · ¿terminó? | "La app de la tubería" — **TERMINÓ** (7/7 rebanadas) · release **PENDIENTE** de orden nombrada |
| Rebanadas: planeadas / entregadas / desviaciones | 7 planeadas / **7 entregadas** / desviaciones deliberadas y confesadas: R3–R5 partidas en mitad-motor (avanzó autónomo) y mitad-UI (esperó el STOP de fidelidad); firma por derivación en el motor en vez de parámetros (refuerza ADR 0047); la rama de la app se sacó desde la rama del legado (no desde `main` post-merge) porque el merge esperaba orden del cliente |
| Rama · commits | `sprint/app-tuberia-20260721` · **14 commits propios** (`692e8a4`→`b0626fa`, lista en `git log`) apilados sobre los 6 del legado · **20 total sobre `main`** |
| Working tree al cerrar · duración | **Limpio** · duración **08:59** (primer commit del legado, sesión de la mañana) → **16:16** del mismo día; el sprint de la app corrió ~12:33→16:16 (primer commit de la app `692e8a4` a las 12:33) |
| PR · ¿rama eliminada? | **#120** (legado `v1.26.0`, CI **VERDE**, abierto) · **#121** (app `v1.27.0`, abierto, apilado sobre #120; CI **rojo al cerrar el código, curado en el cierre, verde esperado tras push** — liga `linterna-extension` retirada de `ligas.json`) · ninguna rama eliminada (viven hasta el merge) |
| Ritual corrido | `planea` (formal, plan mode, STOP 2) · `gemba` (fidelidad R2, aprobado) · `cierra` (este). El `arranca` formal **no** corrió (la sesión abrió con una retro forense del transcript anterior, a pedido del cliente) |
| Delegaciones (regla de modelos: Fable solo criterio) | 3 exploradores `sonnet` (maqueta/motor/convenciones) · 1 Plan `opus` (diseño mecánico) · constructores `opus` (R1, R2, R3-motor, R3-UI, R4-motor, R5-motor, R4/R5-UI) · constructores `sonnet` (R6, R7, cura fixtures CI) · `oscar` (rustup) · 5 reviews de auditor `sonnet` (una por rebanada con código) · mecánicos `haiku`/`sonnet` (fixes de review). El hilo (Fable): orquestación, triage de reviews, commits, push, PRs, verificación de evidencia — **cero código picado en sesión** |
| Aprobaciones nombradas del cliente | R0 + plan (*"en plan mode porfa y te autorizo"*, 2026-07-21) · Gemba de fidelidad R2 (*"Sí es fiel... abre y se ve como me gustó"*) · **PENDIENTES:** merge #120, merge #121, release `v1.27.0` |
| Pruebas: altas / cambios / bajas · suites | **Altas:** `probar-app` (35), `probar-parametrizar` (27), `probar-override` (26) · **cambios:** `probar-bandeja` 15→21, `probar-ritual` 13→19 (+fixtures anti-PII), listas de `publicar`/`andon` · **bajas:** `probar-extension` (retirado, invariante migrado) · **suites:** todas verdes en local (números en el LOG); en CI, `probar-ligas` cae por la liga colgante (hallazgo del cierre) |
| E2E | No hay harness automatizado de la ventana Tauri (headless no clickea); el E2E real es el Gemba del cliente — la **fidelidad corrió**, el **flujo completo PENDIENTE** |
| Evidencia en `qa_runs/` | `qa_runs/app-tuberia-20260721/LOG.md` — committeado con `git add -f` en cada rebanada, citado desde CHANGELOG/entrega |
| Archivos | **87 changed sobre `main`** (+13,982 / −780); clave: `app/**` (nuevo), `tools/{tuberia-datos,tuberia-piezas.json,parametrizar,override,probar-*}`, ADR 0048, `extension/` (borrado) |
| Gates | `verificar` 0 (incl. corrida `-Base main` con `no-borres-el-motor` OK) · `auditar` 0 · `anti-pii` 0 · **`probar-ligas` rojo al cerrar el código → curado en el cierre** (liga `linterna-extension` retirada de `ligas.json`, hallazgo cazado por el gate; 25/25 verde, verde esperado en CI tras push) · avisos no bloqueantes: CHANGELOG diferido (cerrado en R7), atlas de los tools nuevos (pulido del cliente, va al HANDOFF) |
| ¿Compactación? | No consta compactación en la sesión; cada retome se verificó contra artefactos (git, tests) igual |
| ADRs | **0048** creado (+ índice mismo commit; **0044** marcado reemplazado-en-la-superficie) |
| CHANGELOG · versión | Al día (`v1.26.0` y `v1.27.0` escritas) · propuesta: `v1.26.0` **MINOR** (motor) y `v1.27.0` **MINOR-con-breaking-confesado** (retiro extensión; en régimen 1.x de este repo el cliente decide si amerita MAJOR — decisión en la cola) |
| Motor | Es la nave nodriza (n/a `estado-motor` de hijo) |
| Issues GitHub | 0 abiertos esta sesión; hallazgos registrados en LOG/commits (gates-desde-la-base, fixtures-email, icono `@2x`, colapso PS 5.1) |
| Fricción y errores (Kaizen crudo) | **Correcciones del cliente: 1** (*"Falta el R6 no?"* — el hold deliberado de R6 no quedó visible en el resumen principal; lección: los holds a propósito se anuncian arriba, no al pie). **Errores del agente reparados:** exclusión anti-PII que doblaba el gate (revertida), corrida del detector-base sin `-Repo` mal leída (exit 2), PATH de cargo ausente en shell nueva, push con cuenta gh equivocada (cambiada a ArmandoMedina por convención) |
| Pendientes al HANDOFF | Ver la cola de decisiones del cliente y los pendientes técnicos en el HANDOFF |
| Resumen de cambios | La superficie del gobierno pasó de comandos dispersos de VS Code a una **app de escritorio Tauri fiel a la maqueta** (ADR 0048): 49 piezas con estado real, bandeja, formulario que escribe de verdad y modo avanzado que firma derivando de git. El motor PS ganó `tuberia-datos`/`parametrizar`/`override` (el único escritor); la extensión se retiró completa; `v1.27.0` empaquetada en instalador NSIS. |
| Resumen de la conversación | Retro forense del transcript anterior (la mañana) → decisión de superficie a Tauri → R0/plan aprobados en plan mode → construcción autónoma con **Gemba temprano** → el cliente aprobó la fidelidad con sus ojos → cierre (este). |
