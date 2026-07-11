# De dónde viene: el linaje

> Jidoka no nació en un pizarrón: se cosechó de repos reales ([homologación](../kanban/homologacion.md), ADRs [0004](decisions/0004-centralizacion-del-conocimiento.md) y [0005](decisions/0005-exprimido-final-del-linaje.md)). Estos son los dos casos de campo. Ambos proyectos **siguen vivos** — casos en curso, no piezas de museo. Uno es **público y puedes auditarlo tú mismo**; el otro se cita anónimo por la frontera de confidencialidad del método (sin datos ni entornos personales).

## Caso 1 — SimGhostInputs: 32 versiones, el método a la vista

**Repo público: [github.com/ArmandoMedina/SimGhostInputs](https://github.com/ArmandoMedina/SimGhostInputs)** — una herramienta open-source de análisis de telemetría para simulación de carreras (Python, Windows): un solo humano dirigiendo agentes de IA con el ritual completo. La evidencia no es este párrafo; es su récord, clickeable:

- **[Sus versiones publicadas](https://github.com/ArmandoMedina/SimGhostInputs/releases)** con instalador Windows generado por CI — 32 versiones en las primeras 4 semanas de calendario (0.1.0 → 2.4.0); hoy va en `v2.5.0` y sigue.
- **[Sus decisiones documentadas](https://github.com/ArmandoMedina/SimGhostInputs/tree/master/docs/decisions)** — más de 35 ADRs con "el camino que NO se toma".
- **[La evidencia de demos en `qa_runs/`](https://github.com/ArmandoMedina/SimGhostInputs/tree/master/qa_runs)** y una suite que creció de 0 a más de 450 tests, corriendo en su CI.
- **La misma maquinaria de gates que este repo** (`.githooks/`, `tools/`, `HANDOFF.md`, `product/`) — es el repo hijo donde el método corre en producción, y del que Jidoka cosecha de vuelta (ADR [0011](decisions/0011-homologacion-cosecha-sgi.md)).

Antes de la 2.0 se corrió el [ritual de auditoría en rama](../kanban/auditoria.md): **21 auditores en fan-out** produjeron ~190 hallazgos brutos que la síntesis deduplicó a ~65 (7 críticos), con veredictos separados — **GO condicionado** al merge, **NO-GO** al tag hasta cerrar la remediación. El release salió con los críticos cerrados y con una UI entera retirada de un golpe para eliminar la *fuente* de la familia de drift #1.

Lo que este caso le dejó al método:

1. **Evidencia-no-palabra, con diente.** El "probé clic por clic" sin artefacto convivió con la UI rota a ojo; nació el gate que exige evidencia fresca en `qa_runs/` — y commitear lo citado se volvió paso obligatorio del cierre.
2. **Un workflow que solo corre al cortar release se pudre en silencio.** El primer release que lo ejercitó falló 3 veces con 3 bugs distintos que llevaban meses dormidos.
3. **Un gate que llora en falso se ignora.** El gate aprende a decir cuándo NO aplica; el muro duro se muda al CI requerido.
4. **Lo mecánico que depende de memoria humana es un proceso roto.** La versión vivía en 3 lugares y falló 3 releases seguidos; la cura fue **eliminar la redundancia** (un solo literal, todo deriva), no automatizar la sincronización.
5. **El contrato con terceros se verifica contra su código fuente, no contra su documentación** — trazar el fuente real corrigió 3 supuestos falsos y confirmó un crash alcanzable antes de que llegara a producción.

## Caso 2 — Una PWA de finanzas personales: 6 sprints del ritual, cliente que no lee código

*(Este repo es privado — maneja documentos financieros reales de su autor — así que se cita sin nombre ni datos: es la parte del linaje que se cuenta, no se enseña.)*

Una app local-first que lee documentos financieros en el navegador —nada sale del dispositivo— y responde dos preguntas en lenguaje llano: *"¿me alcanza?"* y *"¿cuánto aguanto?"*. El cliente no lee código: **todo lo que aceptó, lo aceptó corriendo un demo** (Gemba).

En **3 semanas de calendario**: **6 sprints del ritual Kanban** (5 fusionados a producción), 5 ADRs con "el camino que NO se toma", 5 suites que bloquean el push, un CI de 5 jobs donde hasta el gate y el empaquetado se prueban a sí mismos, y **una auditoría nocturna desatendida** que en dos corridas cerró un CVE del vendor y un XSS, activó una CSP verificada de punta a punta, y dejó cada decisión que no le tocaba en una lista [humano]/[agente].

El método pagó donde duele: el parser se validó contra **28 documentos reales (0 falsos positivos)** — y la data real lo rompió varias veces antes de estabilizar; la matemática de dinero vivió en motores puros con tests **antes** de tocar pantalla; y cuando una urgencia de privacidad forzó un merge sin demo, **la deuda se anotó en vez de disimularse**.

Lo que este caso le dejó al método:

1. **El QUÉ se escribe y aprueba antes de construir.** Los sprints que no lo hicieron entregaron cosas que el cliente no pudo alinear con lo pedido — hoy es regla permanente, operacionalizada como rebanada R0 con STOP de aprobación.
2. **La clasificación automática sugiere; el usuario confirma.**
3. **Un gate puede existir y no morder** — se audita que muerda, no que exista (cuatro modos de teatro observados, ver [`andon/`](../andon/README.md)).
4. **Todo paso manual de actualización se olvida justo cuando importa** — producción se quedó atorada en una versión vieja *precisamente* mientras se acumulaban fixes de seguridad.
5. **La remediación de una fuga termina en la plataforma, no en el repo:** los previews por rama del hosting seguían sirviendo la versión filtrada después del fix.
