# Inventario de señales — los dos tableros (Operar/andon y Configurar)

> R1 del sprint 27 (2026-07-22). **Regla dura:** ninguna señal se dibuja en una maqueta si no
> tiene fila aquí con su fuente real. Una señal sin fuente se marca `REQUIERE MECANISMO` —
> se especifica el hueco, no se inventa el dato. Verificado contra la salida real de
> `estado-flujo.ps1 -Json` y los ledgers del 2026-07-22.

## Tablero Operar (andon) — anomalías en tiempo presente

| # | Señal | Fuente real hoy | Dueño | Reloj | Estado |
|---|---|---|---|---|---|
| O1 | **La línea paró** (un Stop hook bloqueó a la IA, o `verificar` dio exit 1/2) | **Ninguna** — el paro vive en la sesión/terminal y se pierde | agente → cliente | hora del paro | `REQUIERE MECANISMO` — ledger de eventos de paro: los 4 Stop hooks y `verificar.ps1` anexan una línea (fecha, gate, motivo) a un archivo de instancia que la app lee |
| O2 | **Gemba esperando tus ojos** (entrega sin aceptar/rechazar) | `tools/flujo.json` → `estado.gembas_pendientes[aceptado:false]` (vía `estado-flujo.ps1 -Json`: `id`, `desde`, `que_ver`) | cliente | días desde `desde` | existe |
| O3 | **WIP vs techo** | `estado-flujo.ps1 -Json` → `wip_limite` + conteo de pendientes | cliente | — | existe |
| O4 | **Vence pronto / vencido** (circuit breaker) | ítems `vence:` del ROADMAP + `expirar.ps1 -Simular` (early warning ≤7 días) | cliente | días a `vence` | existe |
| O5 | **Esperas envejeciendo** (cliente/terceros) | `estado-flujo.ps1 -Json` → `esperando_terceros[]` (`quien`, `titulo`, `clase`) + `alta:` del ítem | el `quien` de cada una | días desde `alta` | existe |
| O6 | **Documento DESVIADO** (estructura rota contra su contrato) | `estado-docs.ps1` (ledger `docs-gobernados.json`) — hoy solo consola; la app invocaría el motor (ADR 0048) | agente | desde la corrida que lo detectó | existe (falta invocarlo desde la app) |
| O7 | **Pieza huérfana** (archivo que nadie gobierna) | `bandeja.ps1` / `tuberia-datos.ps1` (estado `huerfano`) | cliente (parametrizar) | días en bandeja — la fecha de alta no se guarda | existe parcial — el reloj `REQUIERE MECANISMO` (fecha de detección en la foto) |
| O8 | **Pieza sin validar / validación vieja** («última validación del dueño») | **Ninguna** — la propiedad no existe | cliente | días desde la última validación | `REQUIERE MECANISMO` — campo `validado_fecha` por pieza en `contratos.json`, escrito vía motor (`override.ps1`/`parametrizar.ps1`, firma ADR 0047) |
| O9 | **Sprint activo y su estado** | `tools/flujo.json` → `estado.sprint_activo` (texto) | agente | — | existe |
| O10 | **Motor desincronizado** (repo hijo atrás de la nave) | `estado-motor.ps1` (aviso, siempre exit 0) | cliente | versiones de atraso | existe (solo aplica en hijos) |

**El silencio es el diseño:** con O1–O8 en cero/verde, la portada de Operar se ve casi vacía.

## Tablero Configurar (la línea) — parámetros por pieza y por área

| # | Parámetro | Fuente real hoy | Quién lo escribe | Estado |
|---|---|---|---|---|
| C1 | Régimen de la pieza (libre/estatuto/candado) | `tools/contratos.json` (no existe aún en la nave — camino de escritura probado, no ejercido) | `parametrizar.ps1` desde el formulario | existe |
| C2 | Candado (la IA rebota) | `contratos.json` `candado:true` + hook `candado-pretooluse` | `override.ps1` con firma (ADR 0047) | existe |
| C3 | Secciones requeridas por doc/familia | `tools/docs-gobernados.json` | **solo a mano** — el radio del formulario escribe otro ledger (teatro confesado) | existe la fuente; la escritura desde UI `REQUIERE MECANISMO` (`-Requeridas` en `parametrizar.ps1` + no-clobber, exige ADR) |
| C4 | Áreas de la ley y sus gates (qué vigila qué) | `tools/blast-radius.json` + `rutear.ps1` (vivo/dormido) | a mano (la ley); `parametrizar.ps1` solo anexa `fuente` | existe |
| C5 | Techos y contratos de flujo (WIP, líneas, vencimientos) | `tools/flujo.json` | a mano | existe |
| C6 | `@`-includes de fábrica del ritual | `ritual-gobernado.json` + `estado-ritual.ps1` | a mano | existe |
| C7 | Ligas código↔capacidad | `tools/ligas.json` + `estado-ligas.ps1` (no-op si no existe) | manual (la autoría asistida se perdió con la extensión) | existe |
| C8 | «Última validación del dueño» (asignarla) | la misma de O8 | el cliente desde la vista por documento | `REQUIERE MECANISMO` (mismo que O8) |

## Los huecos, consolidados (lo que la ola de UI debe construir además de pantallas)

1. **Ledger de eventos de paro** (O1) — la señal más andon de todas; hoy el paro no deja huella.
2. **`validado_fecha` por pieza** (O8/C8) — la propiedad de revisión del dueño, vía motor con firma.
3. **Escritura real de secciones desde la UI** (C3) — cerrar el teatro del radio «estructura gobernada».
4. **Fecha de detección en la bandeja** (O7) — para que los huérfanos tengan reloj.

Todo lo demás que las maquetas dibujen sale de fuentes que ya existen — la ola de UI es
mayormente **superficie sobre motor existente**, no motor nuevo.
