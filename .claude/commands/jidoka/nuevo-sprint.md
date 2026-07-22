---
description: Genera un sprint que nace conforme al molde (plan y, opcional, entrega) desde la plantilla gobernada
allowed-tools: Bash(pwsh:*), Bash(powershell:*), Read
---

El cliente quiere **arrancar un sprint nuevo con el formato correcto de fábrica** — sin copiar-pegar a mano ni desviarse del molde que el guardián `estado-docs.ps1` hace cumplir (familia `docs/sprints/*-plan.md` en `tools/docs-gobernados.json`).

## Qué hace

1. **Genera el plan** desde `kit/.jidoka/templates/sprint-plan.md` a `docs/sprints/sprint-<slug>-plan.md`, con el título ya puesto. El slug se deriva del nombre (minúsculas, sin acentos, guiones) o se pasa explícito.

   Córrelo (Windows PowerShell 5.1):
   !`powershell -NoProfile -File tools/nuevo-sprint.ps1 -Nombre "<nombre corto del incremento>"`

   Con `-Entrega` genera además el récord de cierre `sprint-<slug>-entrega.md`. Con `-Slug <slug>` fija el slug.

2. **No sobrescribe:** si el archivo ya existe, se detiene (no pisa trabajo).

3. **Nace conforme:** el documento sale del molde canónico, así que `tools/estado-docs.ps1` lo marca `CONFORME` sin tocar nada. Verifícalo:
   !`powershell -NoProfile -File tools/estado-docs.ps1`

## Después de generar

- **Regístralo en el índice** `docs/sprints/README.md` (una fila, con su `#` de orden canónico y el estado real).
- **Llena el plan** — no dejes los placeholders `[...]` del molde: el contenido varía libre, las **secciones** no.
- Recuerda que el plan-contrato se aprueba en plan mode (STOP 2 de `/jidoka:planea`) antes de construir.
