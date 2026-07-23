# Muertos del Roadmap — Jidoka

> **El archivo de muertos del roadmap.** Aquí cae lo vencido, movido por [`tools/expirar.ps1`](../tools/expirar.ps1) con **fecha** y **motivo** (la clase de servicio, su alta y la fecha en que venció). El vencimiento es por clase de servicio (`vencimiento_dias` en [`tools/flujo.json`](../tools/flujo.json)): «Con fecha» muere si su `vence:` ya pasó; Urgente/Normal/«Algún día» mueren si `alta + su ventana < hoy`; Referencia nunca muere.
>
> **Revivir = re-proponer.** Nada vuelve solo: para resucitar un ítem, agrégalo de nuevo al `ROADMAP.md` con **alta nueva** — no se recupera desde aquí. Esto convierte podar de *decisión-que-nadie-toma* en *evento-que-ocurre-solo* (el circuit breaker de Shape Up: la muerte por defecto).

<!-- Las entradas las appendea tools/expirar.ps1 bajo un encabezado ## AAAA-MM-DD (la fecha en que corrió la poda). Aún sin entradas. -->

## 2026-07-23
- **El plan declara sus pruebas** `[alta:2026-07-17 · apetito:2h]` — `planea.md` exige sección explícita de pruebas/evidencia por rebanada (pedido del cliente 2026-07-17). El plan FLU-1 ya la estrena a mano; falta el molde en el comando y la plantilla.
  - podado: Urgente, alta 2026-07-17; sin puntero a informe/ADR/issue (regla de procedencia, decision del dueno 2026-07-23); revive re-proponiendolo con alta nueva
- **La app como amortiguador de la sobreproducción (cola e indicadores)** `[alta:2026-07-22 · apetito:6h]` — dirección del cliente (2026-07-22): la app es el punto medio repo↔humano — la cola del ROADMAP visible por clase de servicio con vencimientos, e indicadores de flujo (WIP, Gembas pendientes, piezas sin validar); los controles y límites de la línea, visibles sin terminal. Respeta ADR 0049: clasifica, no rankea.
  - podado: Normal, alta 2026-07-22; sin puntero a informe/ADR/issue (regla de procedencia, decision del dueno 2026-07-23); revive re-proponiendolo con alta nueva
- **Ritual de Gemba efectivo: guion del dueño + conejo rojo** `[alta:2026-07-22 · apetito:3h]` — el LOG técnico pasa a anexo del auditor; el dueño recibe un guion de una página derivado 1:1 de los criterios del R0 (hechos y rojo honesto arriba, ≤7 pasos «haz esto / debe pasar esto / recházalo si»), un defecto provocado que el sistema debe atrapar ante sus ojos (práctica red-rabbit, IATF 16949: probar el poka-yoke con fallo simulado y registrar), y evidencia grabada por criterio con veredicto. Benchmark 2026-07-22: ningún jugador lo ofrece para dueño no-técnico — es producto, va al kit.
  - podado: Normal, alta 2026-07-22; sin puntero a informe/ADR/issue (regla de procedencia, decision del dueno 2026-07-23); revive re-proponiendolo con alta nueva
- **Rework del `reporte-avance.html` para terceros** `[alta:2026-07-22 · apetito:2h]` — el reporte generado no convenció al cliente en el Gemba de FLU-1 (2026-07-22): revisar diseño y lenguaje para el lector externo. No bloquea; el pilar quedó aceptado con esta reserva.
  - podado: Normal, alta 2026-07-22; sin puntero a informe/ADR/issue (regla de procedencia, decision del dueno 2026-07-23); revive re-proponiendolo con alta nueva
- **Validar el casting en la práctica** `[alta:2026-07-22 · apetito:1h]` — el cliente confirmó que `product/casting.md` existe pero no lo ha visto operar en una sesión real; falta un demo donde se vea la delegación a los 4 asientos en vivo. Reserva del Gemba de FLU-1 (2026-07-22).
  - podado: Normal, alta 2026-07-22; sin puntero a informe/ADR/issue (regla de procedencia, decision del dueno 2026-07-23); revive re-proponiendolo con alta nueva
- **Autoría de ligas en la app** `[alta:2026-07-21 · apetito:4h]` — al retirar la extensión se perdió `ligas.js`; el gate `estado-ligas.ps1` sigue vivo pero la autoría asistida quedó manual (capacidad futura de la app).
  - podado: Normal, alta 2026-07-21; sin puntero a informe/ADR/issue (regla de procedencia, decision del dueno 2026-07-23); revive re-proponiendolo con alta nueva
- **Completar los cartones de la app** `[alta:2026-07-21 · apetito:4h]` — «reconciliar» y «alta de agente» siguen siendo teatro confesado; cablearlos de verdad.
  - podado: Normal, alta 2026-07-21; sin puntero a informe/ADR/issue (regla de procedencia, decision del dueno 2026-07-23); revive re-proponiendolo con alta nueva
- **Gemba visual de entisoft** `[alta:2026-07-20 · apetito:1h · espera:cliente]` — `gobierno-entisoft.html` (15 huérfanos) espera ojos del cliente.
  - podado: Normal, alta 2026-07-20; sin puntero a informe/ADR/issue (regla de procedencia, decision del dueno 2026-07-23); revive re-proponiendolo con alta nueva
- **Issues del lazo con los hallazgos del censo** `[alta:2026-07-21 · apetito:1h]` — PreToolUse subutilizado · hueco de `docs/` · `gemba.md` sin `@` (batch, no goteo; el de permisos ya está listado aparte).
  - podado: Normal, alta 2026-07-21; sin puntero a informe/ADR/issue (regla de procedencia, decision del dueno 2026-07-23); revive re-proponiendolo con alta nueva
- **Permisos `allow/ask/deny` + plan mode inescapable** `[alta:2026-07-21 · apetito:4h]` — cablear el disparo `deny-vs-ask` (meses en catálogo); el muro que evita saltarse plan mode (el cliente lo reclamó 4 veces en 7 sesiones — medido).
  - podado: Normal, alta 2026-07-21; sin puntero a informe/ADR/issue (regla de procedencia, decision del dueno 2026-07-23); revive re-proponiendolo con alta nueva
- **Barreras code-first** `[alta:2026-07-09 · apetito:8h]` — lint/formato/tests/cobertura/CHANGELOG-gate; gate de UX en 3 capas; lint de alta señal.
  - podado: Normal, alta 2026-07-09; sin puntero a informe/ADR/issue (regla de procedencia, decision del dueno 2026-07-23); revive re-proponiendolo con alta nueva
- **`npm publish` del CLI `jidoka-method`** `[alta:2026-07-11 · apetito:2h · espera:cliente-cuenta-npm]` — construido y probado en Windows; mientras: `node bin/jidoka-method.js init <ruta>`.
  - podado: Normal, alta 2026-07-11; sin puntero a informe/ADR/issue (regla de procedencia, decision del dueno 2026-07-23); revive re-proponiendolo con alta nueva
- **Multiplataforma del motor + CLI** `[alta:2026-07-09 · apetito:8h · espera:entorno-no-windows]` — gemelos `.sh` o unificar en pwsh Core (decisión abierta); no se declara cross-platform sin evidencia.
  - podado: Normal, alta 2026-07-09; sin puntero a informe/ADR/issue (regla de procedencia, decision del dueno 2026-07-23); revive re-proponiendolo con alta nueva
- **Deudas de reviews de `v1.25.0`** `[alta:2026-07-20 · apetito:2h]` — conteo del reparto case-insensitive (B2) · `Out-File -Encoding ascii` en steps desde-la-base.
  - podado: Normal, alta 2026-07-20; sin puntero a informe/ADR/issue (regla de procedencia, decision del dueno 2026-07-23); revive re-proponiendolo con alta nueva
- **`SECURITY.md`** `[alta:2026-07-09 · apetito:1h]` — colaboración externa.
  - podado: Normal, alta 2026-07-09; sin puntero a informe/ADR/issue (regla de procedencia, decision del dueno 2026-07-23); revive re-proponiendolo con alta nueva
- **Social preview del repo** `[alta:2026-07-10 · apetito:1h · espera:cliente]` — Settings → General, imagen 1280×640 (solo desde la UI de GitHub).
  - podado: Normal, alta 2026-07-10; sin puntero a informe/ADR/issue (regla de procedencia, decision del dueno 2026-07-23); revive re-proponiendolo con alta nueva
- **Párrafo en inglés del README** `[alta:2026-07-10 · apetito:1h · espera:cliente]` — identidad en español vs bounce anglófono; solo el autor decide.
  - podado: Normal, alta 2026-07-10; sin puntero a informe/ADR/issue (regla de procedencia, decision del dueno 2026-07-23); revive re-proponiendolo con alta nueva
- **Qué más del linaje se hace público** `[alta:2026-07-10 · apetito:1h · espera:cliente]` — el ancestro y el caso 2 siguen privados.
  - podado: Normal, alta 2026-07-10; sin puntero a informe/ADR/issue (regla de procedencia, decision del dueno 2026-07-23); revive re-proponiendolo con alta nueva
- **«Ligar» como verbo genérico (opción b)** `[alta:2026-07-20]` — la extensión autora las 3 relaciones; espera el uso real que lo pida.
  - podado: Algún día, alta 2026-07-20; sin puntero a informe/ADR/issue (regla de procedencia, decision del dueno 2026-07-23); revive re-proponiendolo con alta nueva
- **Cablear aviso de divergencia dentro de `verificar.ps1`** `[alta:2026-07-11]` — diferido para no clobbear el verificador del hijo.
  - podado: Algún día, alta 2026-07-11; sin puntero a informe/ADR/issue (regla de procedencia, decision del dueno 2026-07-23); revive re-proponiendolo con alta nueva
- **Matriz de piezas más fina por arquetipo** `[alta:2026-07-09]` — qué skills/tests/UI por arquetipo.
  - podado: Algún día, alta 2026-07-09; sin puntero a informe/ADR/issue (regla de procedencia, decision del dueno 2026-07-23); revive re-proponiendolo con alta nueva
- **Reducir superficie AV / firmar Authenticode** `[alta:2026-07-13]` — firma del instalador PS y del `.exe` NSIS de la app (SmartScreen; historial Bitdefender); regla 2-3, espera 2º entorno endurecido.
  - podado: Algún día, alta 2026-07-13; sin puntero a informe/ADR/issue (regla de procedencia, decision del dueno 2026-07-23); revive re-proponiendolo con alta nueva
- **Endurecer muro de docs-gobernados a lectura-desde-base** `[alta:2026-07-17]` — hoy lee el ledger del PR (mitigado: opt-in de instancia); regla 2-3.
  - podado: Algún día, alta 2026-07-17; sin puntero a informe/ADR/issue (regla de procedencia, decision del dueno 2026-07-23); revive re-proponiendolo con alta nueva
- **Re-evaluar qué avisos maduran a bloqueo** `[alta:2026-07-10]` — práctica continua (regla 2-3).
  - podado: Algún día, alta 2026-07-10; sin puntero a informe/ADR/issue (regla de procedencia, decision del dueno 2026-07-23); revive re-proponiendolo con alta nueva
- **Verificación de contenido del gate** `[alta:2026-07-10]` — más allá de co-ocurrencia; riesgo de over-governance, decisión aparte.
  - podado: Algún día, alta 2026-07-10; sin puntero a informe/ADR/issue (regla de procedencia, decision del dueno 2026-07-23); revive re-proponiendolo con alta nueva
- **PreCompact hook** `[alta:2026-07-21]` — el disparo `desconfia-de-la-compactacion` como máquina (censo de la maqueta: cero cableados).
  - podado: Algún día, alta 2026-07-21; sin puntero a informe/ADR/issue (regla de procedencia, decision del dueno 2026-07-23); revive re-proponiendolo con alta nueva
- **Destino del spike `linterna-capas-enforcement`** `[alta:2026-07-21 · espera:cliente]` — rechazado en Gemba («la verdad es que no»); podar la rama o conservarla aparcada.
  - podado: Algún día, alta 2026-07-21; sin puntero a informe/ADR/issue (regla de procedencia, decision del dueno 2026-07-23); revive re-proponiendolo con alta nueva
- **Destino de la copia scratch `.jidoka/maqueta-tuberia.html`** `[alta:2026-07-21 · espera:cliente]` — dice «SAP» y quedó vieja; la spec real vive en `docs/analisis/`.
  - podado: Algún día, alta 2026-07-21; sin puntero a informe/ADR/issue (regla de procedencia, decision del dueno 2026-07-23); revive re-proponiendolo con alta nueva
- **¿Estrechar el área `raiz`?** `[alta:2026-07-20 · espera:cliente]` — el modo Reparto de la linterna es el instrumento para decidir.
  - podado: Algún día, alta 2026-07-20; sin puntero a informe/ADR/issue (regla de procedencia, decision del dueno 2026-07-23); revive re-proponiendolo con alta nueva
- **¿Diagrama del atlas y nota de capacidad para la linterna?** `[alta:2026-07-19 · espera:cliente]` — los 2 avisos de `verificar` anotados al cerrar `v1.24.0`.
  - podado: Algún día, alta 2026-07-19; sin puntero a informe/ADR/issue (regla de procedencia, decision del dueno 2026-07-23); revive re-proponiendolo con alta nueva
- **Presentación pública (Sprint 4)** `[alta:2026-07-09]` — badges, banner, social preview definitivo; y **comunidad** (Discussions/Discord — decisión del cliente).
  - podado: Algún día, alta 2026-07-09; sin puntero a informe/ADR/issue (regla de procedencia, decision del dueno 2026-07-23); revive re-proponiendolo con alta nueva
- **Tablero de instrumentación (leading vs lagging)** `[alta:2026-07-09]` — las 5 series de `doctrina/05`; frontera sin precedente en el linaje.
  - podado: Algún día, alta 2026-07-09; sin puntero a informe/ADR/issue (regla de procedencia, decision del dueno 2026-07-23); revive re-proponiendolo con alta nueva
