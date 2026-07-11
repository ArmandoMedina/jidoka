---
tipo: guia
estado: en_definicion
---

# Empezar de cero con Jidoka

> 🧪 Guía en construcción — se completa en el Sprint 4 (beta). Este es el esqueleto.

Esta guía te lleva de la mano, sin asumir nada, desde la instalación (`./tools/instalar.ps1` hoy; `npx jidoka-method init` cuando exista el CLI) hasta tu primer sprint entregado con demo visual.

## Lo que cubrirá

1. **Instalar** — `./tools/instalar.ps1 -Destino <tu-repo>`, elegir tu arquetipo (`docs-as-code` · `code-first`; `doc-only` diferido — ADR 0009) y stack.
2. **Tu primer `/jidoka:planea`** — cómo se arma un sprint en plan mode y qué apruebas.
3. **El sprint** — cómo el `dev` construye en rebanadas verticales y qué avisa el Andon.
4. **El Gemba** — cómo corres el demo visual y das el visto bueno (recuerda: revisas el demo, nunca el PR).
5. **Cerrar** — `/jidoka:cierra`, la retro Kaizen y el HANDOFF.

Mientras tanto, el panorama está en el [README](../../README.md), el ritual en [`kanban/`](../../kanban/) y los gates en [`andon/`](../../andon/).
