---
tipo: analisis
estado: vigente
fecha: 2026-07-21
---

# El reparto de funciones en enti — el diseño aplicado a un dominio ajeno (solo lectura)

> **Qué es este informe.** El reparto humano/agente de `product/casting.md` **aplicado** al laboratorio de campo `entisoft-rescate`, para responder la duda concreta del cliente: *«el usuario debería ser siempre el que sabe… pero en el caso de enti no sé cómo ponerme a mí»*. Es **análisis solo-lectura**: se levantó del repo de enti (casting declarado, HANDOFF, plan-maestro) sin tocar su árbol. Corte 2026-07-21. La aplicación real la hará el propio agente de enti cuando baje `v1.26` (aquí no se sembró nada allá).
>
> Frontera de confidencialidad respetada: solo nombres de pila (ya viven en los repos); cero apellidos, correos o rutas personales.

## La respuesta a la duda: en enti NO eres «el que sabe», y no pasa nada

La premisa del cliente —«el usuario siempre es el que sabe»— **es verdadera en la nave** (Jidoka), donde él conoce el método al dedillo y lo opera. Pero enti es un rescate de un sistema de crédito ajeno: **el que sabe del negocio es Marcelo**, no el cliente. El diseño de dos roles separados vuelve eso una configuración correcta, no un hueco:

- **En enti el cliente es el dueño-operador, no la autoridad del dominio.** Prioriza, corre el método, acepta el flujo, firma alcances — pero **no** es el juez de si una regla de crédito «está bien». Ese juez es Marcelo.
- **Optimizar tus horas ahí no sube el throughput.** El cuello de botella del sistema es la ventana de la autoridad (Marcelo), no tu tiempo de operación (Goldratt, paso 3). Meterle más horas de agente o de tu propia operación no acelera nada mientras las respuestas de Marcelo sigan siendo la restricción.

## El reparto humano de enti

| Rol del diseño | Quién | Su carta | Su restricción (y unidad **real**) |
|---|---|---|---|
| **Autoridad del dominio** («el que sabe») | **Marcelo** (oficial de cumplimiento / experto de crédito) | Único juez de las reglas de crédito; responde por el kit de entrevista; **no es usuario de la IA**. Evidencia en `docs/gemba/`. | **Ventanas asíncronas de ~1 semana, canal WhatsApp** (no «6 h/semana» — esa cifra no existe en ningún doc de enti). El WIP se calcula por **rondas/ventana**, no por horas. |
| **Dueño-operador** | **El cliente** | Prioriza, presupuesta tiers por costo, corre el método, autoriza merge/versión/poda, acepta el **flujo** — no las reglas de negocio. | Su apetito de revisión por ciclo. Citas: *«autorizado pr, marge, versión y poda»*; *«yo solo autorizo formal en plan mode»*; decide tier por costo (*«si van a ser 6 mejor opus, es carito el fable»*). |

**No hay un tercer humano** en el repo del lab: la autoridad y el operador agotan el reparto humano de enti.

## Los asientos-agente de enti (idénticos a la nave, casteados con nombres)

Los mismos asientos del método; enti solo les puso nombre en su `## El casting`. La maquinaria es neutral; el nombre es cosmético.

| Nombre en enti | Rol del método | Vive como |
|---|---|---|
| **Mau** | orquestador | la sesión principal |
| **Ahiram** | desarrollador | el trabajo por defecto |
| **Escribano** | escribano | `skills/<nombre>/` |
| **Charbel** | validador | `skills/<nombre>/` |
| **Mariana** | revisor-visual | `skills/<nombre>/` |
| **Armando** | arquitecto-doc | `skills/<nombre>/` |
| **Oscar** | devops | agente de plataforma (fuera del repo) |

Los cuatro asientos-subagente por tier (**explorador/mecanico/auditor/arquitecto**) son **byte-genéricos, los mismos que la nave** (haiku/haiku/sonnet/opus en su frontmatter) — enti no los renombra porque son maquinaria neutral.

## Los números (corte 2026-07-21)

- **HANDOFF.md: 340 líneas · ROADMAP.md: 490 líneas** — el mismo síntoma de crecimiento sin freno que motivó el pilar de flujo en la nave; enti es candidato directo de los contratos de HANDOFF/ROADMAP de `v1.26`.
- **42 hallazgos confirmados** (H-01..H-42; los sub-IDs no cuentan al global) del rescate/ingeniería inversa.
- **Cola de Gembas: 13 sin correr o bloqueados** de 32 pasos totales (la pre-revisión corrió 19). Partida en Sesión A (Marcelo) y Sesión B (cliente); la acumulación es **a propósito** (*«acumulamos algunos y luego los revisamos juntos»*).
- Alcance del dominio: **~89-90 pantallas** como capacidades en **11 dominios**.

## Por qué el reporte de avance de enti va dirigido a Marcelo

La autoridad del dominio de enti trabaja async por WhatsApp y no está en la terminal. El `tools/reporte-avance.ps1` (R7) —5 secciones en lenguaje llano + hill chart, sin jerga— es exactamente su formato: el cliente se lo manda tal cual a Marcelo en su canal. Es la pieza que resuelve el *«no tengo sensación de avance ni para mí ni para Marcelo»* del diagnóstico.

## Nota de aplicación

Este informe es **solo lectura**: no se tocó el árbol de `entisoft-rescate`. La siembra del `product/casting.md` de enti la hará **su propio agente** cuando el lab actualice a `v1.26` (`instalar.ps1 -Actualizar`), casteando el molde con Marcelo como autoridad (unidad: ventanas de ~1 semana) y el cliente como dueño-operador.
