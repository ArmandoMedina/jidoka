# LOG de la corrida — [rol]-[YYYYMMDD-HHMMSS]

> El artefacto que los gates de evidencia exigen (`gemba-stop`, `validador-stop`): **este `LOG.md`**, no un veredicto suelto. El gate mide que exista, esté fresco y rastreado por git; su **contenido** lo juzga el humano en el Gemba. Datos 100 % sintéticos, siempre — incluso en repos privados.

- **Corrida:** [rol]-[YYYYMMDD-HHMMSS]
- **Fecha:** AAAA-MM-DD
- **Rama:** [rama]
- **Asiento:** [quién corrió esto — revisor-visual / validador, por nombre si hay casting]

## Método reproducible

[Los pasos EXACTOS para reproducir esta corrida desde cero: qué se corrió, con qué datos sintéticos, en qué ambiente. Otra sesión debe poder repetirlo sin adivinar. Sale del pipeline real del producto (E2E), no de un script ad-hoc por fuera.]

## Resultados

| # | Caso | Check | Resultado (N/N) |
|---|---|---|---|
| 1 | [caso] | [qué se verificó] | [obtenido / esperado] |
| 2 | ... | ... | ... |

> Para validación por medición (`validador`): la tabla es `entrada → obtenido → esperado`, y **el cálculo lo hace el motor determinista, nunca el LLM**. Si los fixtures son confidenciales (PII), commitea la salida **saneada**, no los datos.

## Artefactos

[Capturas, snapshots renderizados, logs, pares before/after — lo que la corrida produjo. Van junto a este LOG.md en el mismo directorio de la corrida.]

## Veredicto

[Una línea. **El veredicto NO se queda aquí:** viaja a `HANDOFF.md` / `CHANGELOG.md` / la entrega del sprint **citando** esta corrida. El checkpoint final "¿se ve bien?" lo responde el cliente con sus propios ojos, no el agente.]

---

> **Cerrar (paso obligatorio, no cortesía):** `qa_runs/` está gitignoreado; fuerza este LOG al índice o el gate no lo verá y el clon lo pierde:
>
> ```
> git add -f qa_runs/[rol]-[YYYYMMDD-HHMMSS]/LOG.md
> ```
