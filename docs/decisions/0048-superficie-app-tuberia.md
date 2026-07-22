# ADR 0048 — La superficie del gobierno es la app de la tubería (Tauri) — supersede el ADR 0044

- **Estado:** aceptado
- **Fecha:** 2026-07-21
- **Relacionado:** [ADR 0044](0044-editor-del-gobierno-autora-gate-ejecuta.md) (superseded **en la superficie**; su principio "la UI autora, el gate ejecuta" sigue vivo) · [ADR 0002](0002-motor-andon.md) (el muro determinista fuera del LLM, intacto) · [ADR 0045](0045-identidad-sistema-gobierno-configurable.md) (la identidad configurable) · [ADR 0047](0047-meta-gobierno-contrasena-firma-candado.md) (firma derivada de `git config`) · [[CFG-1-gobierno-configurable]]

## Contexto

El sprint "sistema configurable, fase 1" entregó el **motor verde** —la bandeja (`bandeja.ps1`), el estatuto del ritual (`estado-ritual.ps1`) y el candado IA (hook `PreToolUse`)— pero la **superficie** quedó fragmentada en comandos de VS Code: paleta + clic derecho + webviews sueltos. El cliente validó en **6 Gembas** la maqueta `docs/analisis/maqueta-tuberia-202607.html` como **UNA app navegable**; al ver el producto fragmentado lo rechazó explícitamente: *"si la interface ni es navegable literal como una web no la quiero... me veo venir pantallas separadas y más opciones en el clic derecho."*

La retro del transcript encontró la causa: el plan del sprint decía a la vez que *"la maqueta ES la spec visual"* y que *"no se porta"* — la exclusión de la cara visible que el cliente ya había validado **nunca se le resaltó**. Aprobó el plan sin ver que lo único que quería (la app navegable) quedaba fuera.

## Decisión

La superficie de autoría del gobierno es una **app de escritorio (Tauri v2)** cuya interfaz **es la maqueta, literal**: una sola ventana navegable —tubería, bandeja, formulario, modo avanzado— en lugar de comandos dispersos en el IDE.

El principio del ADR 0002/0044 queda **intacto en su mitad viva**: **la UI autora, el gate ejecuta**. Lo que cambia es el **QUIÉN autora** — la app de escritorio, ya no la extensión de VS Code. El motor PowerShell sigue siendo el **único lector/escritor de los ledgers** (`contratos.json`, `blast-radius.json`, los `@` del ritual); la app lo **invoca**, no reimplementa su lógica. La extensión de VS Code se **retira** de la superficie. **Fase 1 = Windows.**

## Por qué

- **El cliente rechazó lo fragmentado con sus ojos.** Los 6 Gembas validaron una sola ventana navegable; entregar comandos sueltos era entregar lo que ya había dicho que no quería. El artefacto concreto (la maqueta) es el contrato visual, no la prosa del plan.
- **El motor ya existe y es la verdad.** La bandeja, el estatuto y el candado leen/escriben los ledgers en PowerShell. La app **no duplica** esa verdad: la invoca. Superficie nueva, motor intacto.
- **La app instalable era la forma que el cliente pidió**, no una web que exige arrancar un proceso ni una extensión que vive dentro del IDE.

## El camino que NO se toma (y por qué tienta)

- **(a) Seguir con la extensión de VS Code.** Tienta porque ya está construida (R4/R6 del sprint pasado). Se rechaza: fragmenta la experiencia en comandos y menús contextuales — exactamente lo que el cliente rechazó al verlo. Vivir dentro del IDE nunca fue "una app navegable como una web".
- **(b) Web app local (HTML + servidor local).** Funcional y reutilizaría la maqueta casi tal cual. Se rechaza: exige **arrancar un proceso** (servidor) antes de abrir la interfaz; el cliente prefirió una app instalable de doble clic.
- **(c) File System Access API en el navegador.** Tienta por "cero instalación". Se rechaza: es **Chromium-only** y **no puede ejecutar procesos** — obligaría a **duplicar el motor en JS** (contra "sin duplicar la verdad", ADR 0046) y la **firma derivada de `git config` global** (ADR 0047) queda inaccesible desde el sandbox del navegador.
- **(d) Electron.** Mismo modelo de "web empaquetada como app de escritorio" que Tauri, pero el binario resultante es **~10x más pesado** (arrastra Chromium). Tauri usa el WebView del sistema (WebView2 en Windows).

## Consecuencias

- **`app/` es Jidoka-only:** no se siembra a los hijos; el invariante viaja en un test, como lo fue `extension/` (ADR 0044, vigilado por `probar-extension.ps1`).
- **Área nueva `app` en la ley** (`blast-radius.json`) con `revisa:true`.
- **La extensión se retira en una rebanada propia** (R6 del sprint nuevo): los `.js` ya portados a PowerShell primero, para no perder los ports sutiles (idempotencia del `@`, firma que aborta sin `quien`/`motivo`).
- **El `.exe` sin firma Authenticode puede disparar AV/SmartScreen** (riesgo confesado; historial real de Bitdefender en esta máquina). El **certificado es fase 2** — cura de fondo, no bloqueante de fase 1.
- **Multiplataforma del motor (pwsh en macOS/Linux) es fase 2:** el cascarón Tauri queda listo, pero el motor sigue siendo `powershell.exe` (Windows).

## Lección de proceso

Un plan que **excluye algo visible que el cliente ya validó** debe **resaltarlo en una línea explícita** ("NO verás X"), no dejarlo enterrado entre "es la spec" y "no se porta". La aprobación visual va **ANTES** de construir: este sprint pone el **Gemba de fidelidad** en su primera rebanada visual (R2), para que el cliente apruebe la cara con sus ojos antes de que se cable un solo dato.

---

> Reglas del registro: una decisión = un archivo · al agregarlo, **listalo en el [índice](README.md) en el mismo commit** (el gate lo exige) · nunca borres una decisión: márcala *reemplazada* y enlaza la nueva.
