# Gemba de R1 — la extensión de VS Code corre (2026-07-20)

> Corrida del cierre de sesión 2026-07-20. El pendiente crítico del HANDOFF era: *"nadie ha visto correr la extensión"*. Este LOG registra que **el cliente la vio correr con sus ojos** — el go/no-go del stack VS Code salió **GO**.

## Lo que corrió la máquina (esta sesión, esta máquina)

| Verificación | Resultado |
|---|---|
| `tools/probar-extension.ps1` (contrato manifiesto↔código) | **9/9 verde** |
| `node --check extension/extension.js` | exit 0, sin errores de sintaxis |
| `tools/estado-gobierno.ps1 -Repo . -Salida .jidoka\gobierno.html` (la cadena que la extensión ejecuta por dentro) | exit 0 · HTML de 26 928 bytes · **0 huérfanos** · 11 áreas · 2 gates vivos · 296 archivos |
| `tools/probar-gate.ps1` | 14/14 |
| `tools/verificar.ps1` | exit 0, sin drift |

## Lo que corrió el cliente (el Gemba real, sin código ni terminal)

1. Abrió `jidoka.code-workspace` en VS Code y pulsó **F5**.
2. La ventana **[Extension Development Host] jidoka** abrió **con el repo ya cargado** (captura compartida en sesión: barra de título con el nombre correcto, explorador con el árbol del repo, rama `sprint/linterna-gobierno-20260719` visible en la barra de estado).
3. Corrió `Ctrl+Shift+P` → **"Jidoka: ver el gobierno"** y continuó la sesión preguntando cómo **ligar un archivo huérfano** — la pregunta que solo tiene sentido con el grafo enfrente. Confirmó el flujo con "va".

**Ajuste de sesión:** `.vscode/launch.json` ganó `${workspaceFolder}` como argumento del Extension Development Host — la ventana de prueba abre sola la carpeta del repo (antes arrancaba vacía y pedía File → Open Folder a mano).

## Hueco declarado (no se rellena bonito)

- La captura archivada en sesión muestra el **dev host abierto**, no el webview con el grafo pintado. La confirmación del render es la conducta del cliente en sesión (pasó directo a preguntar por la autoría de huérfanos), no un artefacto de imagen. Si se quiere evidencia visual del webview, se toma en la próxima corrida.
- El caso real (entisoft) **no** se probó desde la extensión: entisoft aún no tiene el motor `v1.24.0` (`tools/estado-gobierno.ps1` no existe allá). Espera la bajada a los labs.

## Veredicto

**GO.** El stack VS Code (extensión JS plano → PowerShell → webview) quedó demostrado de punta a punta. R2 (ledger `tools/ligas.json` + gate) queda desbloqueado; su plan vive en `docs/sprints/sprint-editor-gobierno-plan.md`.
