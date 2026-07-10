# La auditoría en rama — el ritual de revisión grande

> Para lo que un `/code-review` no alcanza: antes de un release, tras varios sprints, o cuando el repo huele a deuda. Probado en el linaje (una auditoría integral de 21 auditores) y en el propio Jidoka (el cierre del Sprint 1 fue exactamente esto). Es la versión "grande" de la revisión por robots — el humano sigue revisando el demo, no el diff.

## El ritual, por tiempos

1. **Rama propia** (`audit/<fecha>` o el cierre del sprint): la auditoría produce cambios y récord, no opiniones sueltas.
2. **Fan-out de auditores por área.** Subagentes independientes, cada uno con un área acotada (código por dominio, gates, docs/SSOT, seguridad, CI). Cada auditor entrega hallazgos con evidencia (ruta + línea + por qué), no impresiones.
3. **Síntesis con dedupe y reconciliación.** Un sintetizador consolida los reportes: deduplica (en el caso real: ~190 hallazgos brutos → ~65), **reconcilia contradicciones con la regla "gana la evidencia más directa"**, y recalibra todo a una escala única de severidad.
4. **Paquetes de remediación** ordenados (R1, R2, …): trabajo agrupado por tema y prioridad, no una lista plana.
5. **Veredictos GO/NO-GO separados por acción.** Mergear no es lo mismo que taggear un release: cada acción irreversible recibe su propio veredicto.
6. **"Descartado a propósito."** Lo que NO se va a arreglar se lista con su porqué — evita inflar el backlog y deja el juicio registrado.
7. **"Decisiones que necesitan al humano"** se separan del trabajo autónomo. La IA ejecuta lo suyo; lo que exige juicio del cliente sale como checklist, nunca enterrado en prosa (lección pagada: un pendiente en prosa se cayó una sesión entera).

## Las reglas

- **Hallazgo sin evidencia no cuenta.** Igual que el Gemba: el artefacto, no la palabra.
- **La severidad la asigna la síntesis, no cada auditor** — 21 escalas distintas no son una escala.
- **La auditoría también se audita**: sus arreglos pasan por los mismos gates que cualquier cambio (el check `andon` no distingue quién empuja).
