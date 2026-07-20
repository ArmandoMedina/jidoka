# Sprint — El editor del gobierno: la extension de VS Code (plan-contrato)

> Contrato R0 aprobado por el cliente el **2026-07-19** en plan mode (STOP 2 del ritual).
> Sucede al sprint de la linterna (`v1.24.0`, ADR 0043): aquella **muestra**, este **deja configurar**.

## R0 — El QUE (aprobado)

**La capacidad:** *el usuario declara, desde una interfaz visual, que codigo sostiene que capacidad
— y con que fuerza y en que direccion se vigila esa relacion — sin editar JSON a mano.*

### De donde nace (hechos de la sesion anterior)
Al usar la linterna sobre `entisoft-rescate`, el cliente vio dos cosas:
1. **El grafo se satura** — 132 objetos en un force-graph es una marana. Faltan modos de vista.
2. **El gobierno es demasiado grueso** — el area `codigo` de entisoft (`fuente: servidor/*`) avisa
   sobre `product/capacidades/*`: **las 89 capacidades**, sin decir cual.

Palabras del cliente: *"el objetivo es hacer la herramienta que me va a permitir a mi hacerlo. La
herramienta no te va a decir con que ligar — eso lo sabes tu. Pero yo poder decir: **este archivo son
estas 5 capacidades**, y poder decir que **el trigger es el cambio de codigo**... o al reves, o en
ambas direcciones"*. Y: *"la UI donde vea el arbol de archivos y los pueda relacionar ahi, y que se
edite el blast-radius al mismo tiempo"*. Sobre los 3 modos de grafo: *"vale la pena conservar las 3"*.

### Criterios de aceptacion (demostrables sin codigo ni terminal)
- Dado que abro VS Code en un repo con Jidoka, cuando ejecuto **"Jidoka: ver el gobierno"**, entonces
  se abre un panel con el grafo dentro del editor y puedo cambiar entre **Foco / Agrupado / Clusters**.
- Dado que hago **clic derecho en un archivo** en el explorador, cuando elijo **"Jidoka: ligar a
  capacidad..."**, entonces selecciono **una o varias** capacidades y elijo **direccion**
  (codigo-a-capacidad · capacidad-a-codigo · ambas) y **fuerza** (avisa · bloquea).
- Dado que confirmo la liga, entonces **el ledger queda escrito en disco** — lo veo en *Source
  Control* de VS Code — y el grafo se actualiza mostrando la relacion nueva.
- Dado que existe una liga **bloquea** en direccion codigo-a-capacidad, cuando cambio ese codigo
  **sin** tocar su capacidad y trato de hacer push, entonces el gate **me detiene nombrando la
  capacidad exacta** (no "revisa las 89").
- Dado que una liga apunta a un archivo o capacidad que ya no existe, cuando corre el verificador,
  entonces **avisa que la liga esta rota** (el link no se pudre en silencio).

**Metrica:** el aviso de "cambie codigo" pasa de **89 capacidades** a **las declaradas** (1-5).
**Apetito:** varios sprints; este es el primero. **Autoridad:** el cliente, viendolo correr en VS Code.

## La linea doctrinal que no se cruza

**La extension AUTORA; el gate EJECUTA.** El usuario configura la regla en la UI -> se escribe a un
ledger en disco -> los gates deterministas (pre-push + required check en CI, **fuera del LLM**) la
hacen cumplir. La UI **nunca** es el muro: ADR 0002 prohibe API/MCP *como capa de gobierno*, y un
editor que solo escribe declaraciones no lo es.

## Decisiones de diseno

- **Extension en JavaScript plano, sin build step.** VS Code no exige TypeScript. El repo nunca ha
  corrido `npm install`, no tiene un solo `.ts`, y su unico precedente Node (`docs/atlas/tools/*.mjs`)
  es JS plano con cero dependencias + `npx` on-demand. Se sigue ese molde.
- **`extension/` es Jidoka-only** (como el atlas): fuera del manifiesto de siembra y del `files` de
  npm. La **mecanica** que consume (ledger + evaluador en PowerShell) **si** se siembra — un hijo gana
  el gobierno granular aunque no instale la extension.
- **Ledger separado** (precedente `docs-gobernados.json`, ADR 0042): `tools/ligas.json` + evaluador
  `estado-ligas.ps1` + self-test + step de CI. **No se toca `verificar.ps1`** (los hijos lo customizan).
- **Se lee desde la BASE en CI** (ADR 0003): como las ligas **bloquean**, el ledger y el evaluador se
  extraen con `git show "$ref:..."` igual que el step de andon — si no, un PR podria desactivar la liga
  que lo juzga. (De paso queda registrado que el step de `estado-docs` aun no lo hace.)

Forma del ledger:
```json
{ "ligas": [
  { "id": "pagos-motor",
    "codigo": ["servidor/pagos/motor.js"],
    "capacidades": ["product/capacidades/PAGO-1.md"],
    "direccion": "ambas",
    "fuerza": "avisa" } ] }
```

## Rebanadas (cada una commiteable, verde y demostrable)

### R1 — Los 3 modos + la extension que muestra el grafo
Portar **Foco / Agrupado / Clusters** a `tools/estado-gobierno.ps1` (Foco por defecto) + `extension/`
minima en JS plano con el comando **"Jidoka: ver el gobierno"** (corre el `.ps1`, muestra su HTML en
un webview). *Prueba el stack antes de la inversion grande.*
- **Pruebas/evidencia:** casos nuevos en `probar-linterna.ps1` (el HTML trae los 3 modos, arranca en
  Foco). **Demo:** abrir VS Code, correr el comando, ver el grafo y cambiar de modo — sin terminal.

### R2 — El modelo de ligas + el gate que las hace cumplir
`tools/ligas.json` + `tools/estado-ligas.ps1` (`-Estricto` sale 1 en las `bloquea`) +
`tools/probar-ligas.ps1`. Cableado: step en `andon.yml` **desde la base**, `.githooks/pre-push`,
preflight de `publicar.ps1`. Ligas escritas **a mano** aqui (prueba el modelo antes de la autoria).
- **Pruebas/evidencia:** ROJO->VERDE (liga rota avisa; `bloquea` con capacidad sin tocar -> exit 1;
  tocando ambas -> verde). **Demo:** push detenido **nombrando la capacidad**, desde el panel de git.

### R3 — La extension autora las ligas (el corazon)
Clic derecho -> **"Jidoka: ligar a capacidad..."** -> quick pick multi-seleccion -> direccion + fuerza
-> escribe `ligas.json`. Comando gemelo desde una capacidad y **"quitar liga"**. El grafo se refresca.
- **Pruebas/evidencia:** self-test JS del modulo del ledger (`node --test`) + `probar-ligas.ps1`
  validando que lo escrito es legible por el evaluador (el contrato entre los dos stacks).
  **Demo:** ligar un archivo a 2 capacidades sin tocar JSON y ver el diff en *Source Control*.

### R4 — Empaquetar y gobernar
`npx --yes @vscode/vsce package` -> `.vsix` + guia de instalacion. Area `extension` en la ley, ADR 0044
"el editor autora, el gate ejecuta" + indice, CHANGELOG, `andon/README.md`, HANDOFF, SSOT a `1.25.0`.
**Declarado:** NO se siembra ni se publica al marketplace todavia (regla 2-3, como el atlas).

## Lo que NO entra
Marketplace · sembrar la extension · otros editores · que la herramienta **sugiera** que ligar con que
(el juicio es del humano) · migrar la ley de entisoft (ese repo lo lleva **otro agente**: se coordina,
no se impone) · que el gate juzgue **contenido** (sigue midiendo co-ocurrencia).

## Riesgos declarados
- **Stack nuevo:** aun en JS plano, es el primer artefacto de su tipo aqui; su verificacion se apoya
  mas en el demo (Gemba) que en la suite PowerShell. Se mitiga con el self-test JS y con
  `probar-ligas.ps1` validando el contrato entre stacks.
- **Es el build mas grande hasta ahora.** R1 esta disenado para probar el stack **antes** de la
  inversion: si el camino VS Code no convence, se corta ahi con la linterna ya mejorada.
