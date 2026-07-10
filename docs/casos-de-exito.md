# Casos de éxito del linaje

> Jidoka no nació en un pizarrón: se cosechó de repos reales ([homologación](../kanban/homologacion.md), ADRs [0004](decisions/0004-centralizacion-del-conocimiento.md) y [0005](decisions/0005-exprimido-final-del-linaje.md)). Estos son los dos casos de campo, citados con la frontera de confidencialidad del método (sin nombres, datos ni entornos personales — `doctrina/decisiones/0004`). Ambos proyectos **siguen vivos** — son casos de éxito en curso, no piezas de museo. Evidencia-no-palabra: cada número de aquí existe en el récord del repo de origen.

## Caso 1 — El laboratorio de campo: 4 semanas, 32 versiones, 34 decisiones

Una herramienta open-source de análisis de telemetría para simulación de carreras (Python, Windows): un solo humano dirigiendo agentes de IA con el ritual completo. En **4 semanas de calendario**: 239 commits, **32 versiones publicadas** (0.1.0 → 2.4.0) con instalador Windows generado por CI, **34 ADRs**, y una suite que creció de 0 a **453 tests**. El QUÉ vive en una jerarquía navegable (22 capacidades, 14 módulos, 9 dominios) gateada por un auditor determinista.

Antes de la 2.0 se corrió el [ritual de auditoría en rama](../kanban/auditoria.md): **21 auditores en fan-out** produjeron ~190 hallazgos brutos que la síntesis deduplicó a ~65 (7 críticos), con veredictos separados — **GO condicionado** al merge, **NO-GO** al tag hasta cerrar la remediación. El release salió con los críticos cerrados y con una UI entera retirada de un golpe para eliminar la *fuente* de la familia de drift #1.

Lo que este caso le dejó al método:

1. **Evidencia-no-palabra, con diente.** El "probé clic por clic" sin artefacto convivió con la UI rota a ojo; nació el gate que exige evidencia fresca en `qa_runs/` — y commitear lo citado se volvió paso obligatorio del cierre.
2. **Un workflow que solo corre al cortar release se pudre en silencio.** El primer release que lo ejercitó falló 3 veces con 3 bugs distintos que llevaban meses dormidos.
3. **Un gate que llora en falso se ignora.** El gate aprende a decir cuándo NO aplica; el muro duro se muda al CI requerido.
4. **Lo mecánico que depende de memoria humana es un proceso roto.** La versión vivía en 3 lugares y falló 3 releases seguidos; la cura fue **eliminar la redundancia** (un solo literal, todo deriva), no automatizar la sincronización.
5. **El contrato con terceros se verifica contra su código fuente, no contra su documentación** — trazar el fuente real corrigió 3 supuestos falsos y confirmó un crash alcanzable antes de que llegara a producción.

## Caso 2 — Una PWA de finanzas personales: 6 sprints del ritual, cliente que no lee código

Una app local-first que lee documentos financieros en el navegador —nada sale del dispositivo— y responde dos preguntas en lenguaje llano: *"¿me alcanza?"* y *"¿cuánto aguanto?"*. El cliente no lee código: **todo lo que aceptó, lo aceptó corriendo un demo** (Gemba).

En **3 semanas de calendario**: **6 sprints del ritual Kanban** (5 fusionados a producción), 5 ADRs con "el camino que NO se toma", 5 suites que bloquean el push, un CI de 5 jobs donde hasta el gate y el empaquetado se prueban a sí mismos, y **una auditoría nocturna desatendida** que en dos corridas cerró un CVE del vendor y un XSS, activó una CSP verificada de punta a punta, y dejó cada decisión que no le tocaba en una lista [humano]/[agente].

El método pagó donde duele: el parser se validó contra **28 documentos reales (0 falsos positivos)** — y la data real lo rompió varias veces antes de estabilizar; la matemática de dinero vivió en motores puros con tests **antes** de tocar pantalla; y cuando una urgencia de privacidad forzó un merge sin demo, **la deuda se anotó en vez de disimularse**.

Lo que este caso le dejó al método:

1. **El QUÉ se escribe y aprueba antes de construir.** Los sprints que no lo hicieron entregaron cosas que el cliente no pudo alinear con lo pedido — hoy es regla permanente, operacionalizada como rebanada R0 con STOP de aprobación.
2. **La clasificación automática sugiere; el usuario confirma.**
3. **Un gate puede existir y no morder** — se audita que muerda, no que exista (cuatro modos de teatro observados, ver [`andon/`](../andon/README.md)).
4. **Todo paso manual de actualización se olvida justo cuando importa** — producción se quedó atorada en una versión vieja *precisamente* mientras se acumulaban fixes de seguridad.
5. **La remediación de una fuga termina en la plataforma, no en el repo:** los previews por rama del hosting seguían sirviendo la versión filtrada después del fix.
