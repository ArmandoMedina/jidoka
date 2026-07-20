# Jidoka — el editor del gobierno (extensión de VS Code)

> **La extensión AUTORA; el gate EJECUTA** (ADR 0044). Aquí ves el grafo del gobierno y
> declaras ligas código↔capacidad con clics; quien muerde es el gate determinista
> (`tools/estado-ligas.ps1` en pre-push + CI), fuera del editor y fuera del LLM.

## Qué hace

| Comando (Ctrl+Shift+P o clic derecho) | Qué hace |
|---|---|
| **Jidoka: ver el gobierno** | Corre `tools/estado-gobierno.ps1` y pinta el grafo (áreas, gates, docs-dueño, capacidades, ligas, huérfanos en rojo) en un panel. Modos Foco / Agrupado / Clusters. |
| **Jidoka: ligar código a capacidad...** | Clic derecho sobre archivo(s) o carpeta del explorador → eliges capacidades (multi), dirección (`codigo-a-capacidad` / `capacidad-a-codigo` / `ambas`) y fuerza (`avisa` / `bloquea`) → escribe `tools/ligas.json`. El diff aparece en *Source Control*; el grafo se repinta. El nombre promete exactamente lo que hace: la relación código↔capacidad (el blast-radius área↔doc y los wikilinks capacidad↔capacidad son otras relaciones, con su propia mecánica). |
| **Jidoka: quitar liga código-capacidad...** | Saca la ruta seleccionada del ledger; una liga que queda sin código se elimina entera. |

Requiere que el repo abierto tenga el motor de Jidoka (`tools/estado-gobierno.ps1`, `v1.24.0+`).

## Probarla sin instalar (modo desarrollo)

Abre `C:\Repositorios\jidoka` (o `jidoka.code-workspace`) en VS Code → **F5** → en la ventana
*Extension Development Host* (abre el repo sola), corre los comandos desde la paleta.

## Empaquetar e instalar el `.vsix`

```
cd extension
npx --yes @vscode/vsce package
```

Sale `jidoka-gobierno-<version>.vsix` (gitignoreado — artefacto de build, no fuente). Instalar:

```
code --install-extension jidoka-gobierno-<version>.vsix
```

o en VS Code: *Extensions → ⋯ → Install from VSIX…*

## Fronteras declaradas (regla 2-3)

- **No está en el marketplace** ni se siembra a los repos hijos (`probar-extension.ps1` lo vuelve
  invariante). La **mecánica** que consume (`estado-ligas.ps1` + `probar-ligas.ps1`) sí baja a los
  hijos por el manifiesto — un hijo gana el gate granular aunque no instale la extensión.
- **No sugiere qué ligar** — el juicio es del humano; la extensión solo lista y escribe.
- JS plano sin build step ni dependencias (`extension.js` + `ligas.js`); self-tests en
  `ligas.test.js` (`node --test`) y contrato JS↔PS en `tools/probar-ligas.ps1`.
