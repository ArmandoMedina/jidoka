# qa_runs/ — evidencia del Gemba de este repo (dogfooding)

> Jidoka usa su propia convención de evidencia. La regla completa vive en [`kit/.jidoka/qa_runs/README.md`](../kit/.jidoka/qa_runs/README.md); esto es la instancia.

- Un directorio por corrida: `<rol|propósito>-<YYYYMMDD[-HHMMSS]>/`.
- Artefactos, no actas. Datos sintéticos. El veredicto va a `HANDOFF.md`/`CHANGELOG.md` citando la corrida.
- El bulto está gitignored; **lo citado se commitea con `git add -f` como paso del cierre**.
- **Cada corrida lleva su `LOG.md`** (plantilla: `kit/.jidoka/templates/qa-log.md`) — el listón de ADR 0030. Las corridas anteriores a 2026-07-14 **predatan esa convención** y se conservan tal cual: no se fabrica evidencia retroactiva (`evidencia-no-palabra`). Primer uso propio: `dogfood-20260714/`.
