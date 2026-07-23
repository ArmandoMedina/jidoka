# Bocetos del tablero Operar (andon) — R2 del sprint 27

> Tres variantes de portada, doble clic cada una. **Ninguna es la spec** — el cliente elige
> una (o pide mezcla) y esa pasa a la maqueta congelada de R3. Todas dibujan solo señales
> del inventario (`senales-tableros-202607.md`) y todas cumplen el principio: **sano = silencio**.

## Las variantes

| Boceto | Idea | Fortaleza | Riesgo | Veredicto del cliente |
|---|---|---|---|---|
| [A — Semáforo por columnas](boceto-andon-a-202607.html) | 3 carriles fijos: Paros / Esperándote / Relojes | Se aprende en 10 segundos; cada tipo tiene su casa | Con pocas señales, 3 columnas casi vacías desperdician pantalla | (pendiente) |
| [B — Bandeja única](boceto-andon-b-202607.html) | Una sola cola por gravedad, cada fila con su acción siguiente | Nunca hay que decidir «por dónde empiezo»; ideal contra la sobreproducción | Mezcla tipos distintos en una lista; con muchas señales se hace larga | (pendiente) |
| C — [Tablero de planta](boceto-andon-c-202607.html) | 4 contadores grandes estilo andon fabril + detalle de lo encendido | El estado entero en 4 números, legible de reojo; el más «andon» visualmente | Los contadores agregan — para actuar siempre hay que bajar al detalle | (pendiente) |

## Referencias (media página, de la investigación 2026-07-22)

- **Andon fabril (Toyota UK / Vorne):** el tablero muestra estado y ubicación de la anomalía, no actividad; lo normal no se enseña. La luz llama al responsable y el paro escala con reloj (fixed-position stop). → De ahí: sano = vacío, cada señal con dueño y reloj (variante C es la traducción más literal).
- **A3 (Shook, MIT Sloan):** una página, hechos separados de juicio por estructura; se interroga, no se archiva. → De ahí: la portada enseña hechos con fuente citada, nunca juicio del agente.
- **Devin/Cursor (2026):** el reporte útil lleva aserciones con veredicto y capítulos para saltar a lo que importa. → De ahí: cada fila lleva su «acción siguiente» (variante B).
- **Approval fatigue (literatura 2025-2026):** si llega más de lo que el humano puede leer, la supervisión colapsa. → De ahí: el techo visual — la portada jamás pagina; si no cabe, la señal se agrega, no se lista.

## Qué mirar al elegir (2 minutos por boceto)

1. Ábrelo doble clic, déjalo en «Estado sano» — ¿te transmite calma o te parece roto?
2. Cambia a «Con anomalías» — ¿sabes en 5 segundos qué harías primero?
3. Pregunta de cualquier elemento «¿de dónde sale?» — la etiqueta gris (O1–O8) responde.
