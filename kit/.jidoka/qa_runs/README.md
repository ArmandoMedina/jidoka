# qa_runs/ — la evidencia del Gemba

> Aquí vive lo que la revisión visual **produjo**, no lo que alguien **dijo**. Regla madre: **un archivo que diga "validé y todo bien" no es evidencia** — eso es un acta, y las actas se auto-firman. La evidencia son los artefactos de la corrida.

## La convención

- **Un directorio por corrida:** `<rol|propósito>-<YYYYMMDD[-HHMMSS]>/` (ej. `revisor-visual-20260710-170512/`).
- **Adentro van artefactos reales:** capturas, snapshots renderizados, logs, tablas entrada→salida-obtenida→esperada. Con un `LOG.md` que declare: fecha, rama, **método reproducible**, y los resultados como tabla `# | Caso | Check | Resultado (N/N)`.
- **Datos 100 % sintéticos, siempre** — incluso en repos privados. Ninguna captura carga datos reales (perfil ficticio, montos inventados).
- **El veredicto NO vive aquí.** Va a `HANDOFF.md` o `CHANGELOG.md` **citando** el directorio de la corrida. Artefacto y veredicto se separan a propósito.

## La política de git (lección pagada)

El bulto se ignora (`qa_runs/*/` en `.gitignore`); **solo la evidencia citada desde HANDOFF/CHANGELOG se commitea**, selectivamente:

```
git add -f qa_runs/<corrida>/<archivo-citado>
```

Y es **paso obligatorio del cierre**, no cortesía: en el linaje se descubrió una vez que 0 artefactos habían llegado a git — toda la evidencia era local y se habría perdido con el clon.

## El checkpoint final es humano

La evidencia es el insumo para la revisión del cliente, no la revisión misma. El revisor-visual surte capturas y deja la corrida; **"¿se ve bien?" la responde el cliente con sus propios ojos** (Gemba).
