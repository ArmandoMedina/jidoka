# Análisis — informes durables de auditoría y medición

> **Qué es esta carpeta:** los **informes** que una auditoría o medición produjo — evidencia
> razonada con **fecha de corte**, no doctrina viva. Se leen al retomar el tema que auditaron;
> **no se actualizan**: un informe nuevo reemplaza, el viejo queda como historial (su `estado`
> del frontmatter lo dice). Una decisión que salga de un informe **va a un ADR** — el informe
> es su evidencia, no su registro.

| Informe | Qué midió | Corte |
|---|---|---|
| [auditoria-documentos-y-ley-202607](auditoria-documentos-y-ley-202607.md) | Inventario de todos los docs (función, lector, cuándo se editan) + coherencia de la ley contra el árbol real. Sus huecos de ley se cerraron en ADR 0038 | 2026-07-16 · v1.18.0 |
| [auditoria-atlas-202607](auditoria-atlas-202607.md) | Auditoría hostil de los 24 BPMN + 1 DMN contra sus fuentes reales (primera verificación elemento por elemento) | 2026-07-16 · v1.18.0 |
| [fidelidad-atlas-202607](fidelidad-atlas-202607.md) | El careo diagrama-por-diagrama contra su Fuente declarada, con cita de cada desvío (base del sprint "el atlas dice la verdad", v1.20.0) | 2026-07-16 · v1.18.0 |
| [auditoria-kit-202607](auditoria-kit-202607.md) | La bajada a los hijos: ¿instalación y actualización quedan correctas y completas? (verificación independiente post-cosecha #7) | 2026-07-16 · v1.18.0 |
| [prueba-de-vida-nodriza-202607](prueba-de-vida-nodriza-202607.md) | Qué piezas del método tienen uso real documentado y cuáles cero señal de vida (un test verde NO es señal de vida) | 2026-07-16 · v1.18.0 |
| [costo-neto-sgi-202607](costo-neto-sgi-202607.md) | Costo neto del método en el lab real SGI (issue #72) — primer pase manual, reconstruible desde los artefactos citados | 2026-07 · SGI |
| [veredicto-teatro-vs-real-202607](veredicto-teatro-vs-real-202607.md) | La síntesis de las 5 auditorías: "¿Toyota y Scrum de verdad, o puro teatro?" — respondida con la evidencia cruzada | 2026-07-16 · v1.18.0 |
| [gemba-gestion-del-flujo-202607](gemba-gestion-del-flujo-202607.md) | Por qué nada cierra: 684 mensajes del cliente + forense con números de los dos repos. El método construyó el pilar Jidoka del TPS y **le falta el de Just-In-Time** — hipótesis confirmada por el benchmark (abajo) y atendida por el sprint FLU-1 | 2026-07-21 · v1.25.0 |
| [benchmark-flujo-202607](benchmark-flujo-202607.md) | El benchmark de 4 frentes (TPS/JIT, Kanban+ToC, Shape Up, reparto de responsabilidades) con fuentes: la hipótesis se confirma con 3 correcciones — no falta un PM, faltan las reglas; el apetito se mide en revisión humana; la sobreproducción es la peor muda | 2026-07-21 · v1.25.0 |
| [descubrimiento-sistema-configurable-202607](descubrimiento-sistema-configurable-202607.md) | El descubrimiento de la visión "sistema configurable": las 5 relaciones de "ligar", los 3 regímenes de gobierno, la bandeja y el formulario. Su artefacto validado: [la maqueta clickeable](maqueta-tuberia-202607.html) | 2026-07-20 · v1.25.0 |
| [reparto-enti-202607](reparto-enti-202607.md) | El reparto de funciones (`product/casting.md`) aplicado, solo-lectura, al lab `entisoft-rescate`: Marcelo = autoridad del dominio (ventanas async ~1 semana); el cliente = dueño-operador. Responde la duda «cómo ponerme a mí en enti» | 2026-07-21 · v1.26.0 |
| [exploracion-huella-en-labs-202607](exploracion-huella-en-labs-202607.md) | Primera vuelta de la kata (cap. 08) corrida de verdad: ¿la huella de Jidoka en un lab es colisión estructural o ruido visual? Rojo→verde sobre copias desechables de los 3 labs — el contenedor anidado da falso-verde, el aplanado pasa sin tocar código, el instalador falla cerrado. Rojo honesto sin cura: los 4 Stop hooks dejan cerrar si falta la ley | 2026-07-23 · v1.31.0 |
