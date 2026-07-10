# qa_runs/ — evidencia del Gemba de este repo (dogfooding)

> Jidoka usa su propia convención de evidencia. La regla completa vive en [`kit/.jidoka/qa_runs/README.md`](../kit/.jidoka/qa_runs/README.md); esto es la instancia.

- Un directorio por corrida: `<rol|propósito>-<YYYYMMDD[-HHMMSS]>/`.
- Artefactos, no actas. Datos sintéticos. El veredicto va a `HANDOFF.md`/`CHANGELOG.md` citando la corrida.
- El bulto está gitignored; **lo citado se commitea con `git add -f` como paso del cierre**.
