# Roadmap — Jidoka

> **Contrato del ROADMAP (FLU-1, ADR 0049): esto es una cola de trabajo clasificada, no un diario.** Cada ítem vivo declara `[alta:AAAA-MM-DD · apetito:Nh]` (los «Con fecha» además `vence:`; el icebox «Algún día» solo `alta:`). Se **clasifica, no se rankea** (Anderson: ordenar el backlog es desperdicio). Lo cumplido vive en `CHANGELOG.md`; lo vencido **muere solo** a `docs/MUERTOS.md` (`tools/expirar.ps1`) y solo vuelve si alguien lo re-propone. El check `[contrato-roadmap]` de `tools/verificar.ps1` hace cumplir el formato y el techo (límites en `tools/flujo.json`). El roadmap-diario anterior, íntegro: [`docs/roadmap-historico.md`](docs/roadmap-historico.md). Norte sin cambio: **la disciplina en el robot, el juicio en el humano**.

## Urgente

- **El plan declara sus pruebas** `[alta:2026-07-17 · apetito:2h]` — `planea.md` exige sección explícita de pruebas/evidencia por rebanada (pedido del cliente 2026-07-17). El plan FLU-1 ya la estrena a mano; falta el molde en el comando y la plantilla.

## Con fecha

- **Bajar el batch `v1.23.0`–`v1.28.x` a los labs** `[alta:2026-07-20 · vence:2026-08-04 · apetito:4h · espera:ventana-labs]` — entisoft gana `estado-ligas`, linterna nueva, la mecánica del sistema configurable (bandeja/estatuto del ritual/candado IA) y el pilar de flujo; SGI/TF re-sellar + converger a namespaced (SGI: quitar duplicados; TF: comandos a `jidoka/*`). La ventana la abre el cliente (el lab lo trabaja otro agente — no pisar).

## Normal

- **Homologar `docs/sprints/` y `qa_runs/` a molde único (patrón ADRs)** `[alta:2026-07-22 · apetito:8h]` — enumerar los sprints en orden (hoy sin número canónico), auditar en varias direcciones con agentes, definir molde y plantilla homologados, homologar los existentes sin reescribir contenido, skill generadora más guardián residente que BLOQUEA el drift (el equivalente a `probar-adrs.ps1`); mismo tratamiento a los `LOG.md` de `qa_runs/`. Cableado a `andon`, `publicar` y sembrado. Pedido del cliente 2026-07-22.
- **Gemba end-to-end de la app de la tubería** `[alta:2026-07-21 · apetito:1h · espera:cliente]` — el flujo del glosario completo (crear por fuera → bandeja → parametrizar desde el formulario → candado → ver a la IA rebotar), sin código ni terminal; pasos en `docs/sprints/sprint-app-tuberia-entrega.md`. La fidelidad de R2 ya se aprobó; el flujo completo no se ha corrido.
- **Autoría de ligas en la app** `[alta:2026-07-21 · apetito:4h]` — al retirar la extensión se perdió `ligas.js`; el gate `estado-ligas.ps1` sigue vivo pero la autoría asistida quedó manual (capacidad futura de la app).
- **Completar los cartones de la app** `[alta:2026-07-21 · apetito:4h]` — «reconciliar» y «alta de agente» siguen siendo teatro confesado; cablearlos de verdad.
- **Atlas de los tools nuevos de la app** `[alta:2026-07-21 · apetito:1h]` — `tuberia-datos`, `parametrizar`, `override` sin diagrama en el atlas.
- **Gemba visual de entisoft** `[alta:2026-07-20 · apetito:1h · espera:cliente]` — `gobierno-entisoft.html` (15 huérfanos) espera ojos del cliente.
- **Issues del lazo con los hallazgos del censo** `[alta:2026-07-21 · apetito:1h]` — PreToolUse subutilizado · hueco de `docs/` · `gemba.md` sin `@` (batch, no goteo; el de permisos ya está listado aparte).
- **Coordinación de escritores multi-máquina** `[alta:2026-07-21 · apetito:8h]` — 3 frentes de escritura sobre el método + la rama del socio sin subir; «una sola sesión escritora por working tree» no alcanza con varias PCs (decisión abierta #3 del diagnóstico del flujo).
- **Permisos `allow/ask/deny` + plan mode inescapable** `[alta:2026-07-21 · apetito:4h]` — cablear el disparo `deny-vs-ask` (meses en catálogo); el muro que evita saltarse plan mode (el cliente lo reclamó 4 veces en 7 sesiones — medido).
- **Cuadro de cierre como plantilla sembrable** `[alta:2026-07-17 · apetito:2h]` — mover el detalle a `kit/.jidoka/templates/cierre-cuadro.md` inyectada con `@` (ADR 0040).
- **Épica `.local` code-first (SGI)** `[alta:2026-07-11 · apetito:8h · espera:ventana-labs]` — converger el `verificar` de SGI a motor genérico + costura `.local` sin romper sus 453 tests (ADR 0015).
- **Barreras code-first** `[alta:2026-07-09 · apetito:8h]` — lint/formato/tests/cobertura/CHANGELOG-gate; gate de UX en 3 capas; lint de alta señal.
- **`npm publish` del CLI `jidoka-method`** `[alta:2026-07-11 · apetito:2h · espera:cliente-cuenta-npm]` — construido y probado en Windows; mientras: `node bin/jidoka-method.js init <ruta>`.
- **Multiplataforma del motor + CLI** `[alta:2026-07-09 · apetito:8h · espera:entorno-no-windows]` — gemelos `.sh` o unificar en pwsh Core (decisión abierta); no se declara cross-platform sin evidencia.
- **Demo de campo de Discovery** `[alta:2026-07-14 · apetito:2h · espera:cliente]` — correr `/jidoka:descubre` en un proyecto con niebla real; alimenta #67.
- **Deudas de reviews de `v1.25.0`** `[alta:2026-07-20 · apetito:2h]` — conteo del reparto case-insensitive (B2) · `Out-File -Encoding ascii` en steps desde-la-base.
- **`SECURITY.md`** `[alta:2026-07-09 · apetito:1h]` — colaboración externa.
- **Social preview del repo** `[alta:2026-07-10 · apetito:1h · espera:cliente]` — Settings → General, imagen 1280×640 (solo desde la UI de GitHub).
- **Párrafo en inglés del README** `[alta:2026-07-10 · apetito:1h · espera:cliente]` — identidad en español vs bounce anglófono; solo el autor decide.
- **Qué más del linaje se hace público** `[alta:2026-07-10 · apetito:1h · espera:cliente]` — el ancestro y el caso 2 siguen privados.

## Algún día

- **Arquetipo `doc-only`/regulado** `[alta:2026-07-13]` — regla 2-3: 1er uso real llegó (PLD/CNBV); espera el 2º repo regulado (#41).
- **Arquetipo `operacion`** `[alta:2026-07-13]` — doctrina sin motor; 1er caso real (Caso F); espera el 2º (#44).
- **Gobernanza compuesta** `[alta:2026-07-13]` — 2º apunte del patrón; espera el 3º (#45).
- **Prueba de vida ≠ tests verdes** `[alta:2026-07-13]` — leading indicators de gates de operación; espera el 2º caso (#46).
- **«Ligar» como verbo genérico (opción b)** `[alta:2026-07-20]` — la extensión autora las 3 relaciones; espera el uso real que lo pida.
- **Cablear aviso de divergencia dentro de `verificar.ps1`** `[alta:2026-07-11]` — diferido para no clobbear el verificador del hijo.
- **Matriz de piezas más fina por arquetipo** `[alta:2026-07-09]` — qué skills/tests/UI por arquetipo.
- **Reducir superficie AV / firmar Authenticode** `[alta:2026-07-13]` — firma del instalador PS y del `.exe` NSIS de la app (SmartScreen; historial Bitdefender); regla 2-3, espera 2º entorno endurecido.
- **Endurecer muro de docs-gobernados a lectura-desde-base** `[alta:2026-07-17]` — hoy lee el ledger del PR (mitigado: opt-in de instancia); regla 2-3.
- **Re-evaluar qué avisos maduran a bloqueo** `[alta:2026-07-10]` — práctica continua (regla 2-3).
- **Verificación de contenido del gate** `[alta:2026-07-10]` — más allá de co-ocurrencia; riesgo de over-governance, decisión aparte.
- **#47 pre-push no protege la rama default** `[alta:2026-07-13]` — sin triar; se decide en la próxima cosecha.
- **PreCompact hook** `[alta:2026-07-21]` — el disparo `desconfia-de-la-compactacion` como máquina (censo de la maqueta: cero cableados).
- **Destino del spike `linterna-capas-enforcement`** `[alta:2026-07-21 · espera:cliente]` — rechazado en Gemba («la verdad es que no»); podar la rama o conservarla aparcada.
- **Destino de la copia scratch `.jidoka/maqueta-tuberia.html`** `[alta:2026-07-21 · espera:cliente]` — dice «SAP» y quedó vieja; la spec real vive en `docs/analisis/`.
- **¿Estrechar el área `raiz`?** `[alta:2026-07-20 · espera:cliente]` — el modo Reparto de la linterna es el instrumento para decidir.
- **¿Diagrama del atlas y nota de capacidad para la linterna?** `[alta:2026-07-19 · espera:cliente]` — los 2 avisos de `verificar` anotados al cerrar `v1.24.0`.
- **Presentación pública (Sprint 4)** `[alta:2026-07-09]` — badges, banner, social preview definitivo; y **comunidad** (Discussions/Discord — decisión del cliente).
- **Publicar la doctrina suelta «Poka-yoke»** `[alta:2026-07-09]` — ADR 0001 lo deja abierto; decide el autor.
- **Tablero de instrumentación (leading vs lagging)** `[alta:2026-07-09]` — las 5 series de `doctrina/05`; frontera sin precedente en el linaje.

## Referencia

> Landscape y declaraciones — no son cola de trabajo; no llevan contrato de ítem.

- **Frontera Core vs familias opcionales (issue #71):** Core estable (memoria por artefactos, gates fuera del LLM, ritual, instalador+lazo) · Discovery (1 caso real) · Docs/`doc-only`, Operations, Observability: esperan consumidores reales (regla 2-3). Detalle histórico en `docs/roadmap-historico.md`.
- **Panorama — OpenWiki** (LangChain, MIT): wiki para agentes, flecha código→doc generativa; complemento, no competidor (la nuestra es normativa doc→código con gate).
- **Panorama — GBrain** (Garry Tan, MIT): grafo de conocimiento git-nativo con consulta citada vía MCP; interés como capa «pregúntale al proyecto», no gobierna nada.
