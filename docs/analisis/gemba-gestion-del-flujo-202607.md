---
tipo: analisis
estado: en_revision
fecha: 2026-07-21
---

# El Gemba de la gestión del flujo — por qué nada cierra

> **Qué es esto.** El cliente reportó un dolor: *«el roadmap y el handoff son un desmadre; todos los temas están siempre abiertos; no tengo sensación de avance; no tengo a la vista lo que hay que hacer»*. Esto es la medición de ese dolor contra evidencia real, no contra impresiones. **Estado `en_revision`: el veredicto lo pone el cliente.**
>
> **Frontera de confidencialidad:** el laboratorio de campo se cita como «el lab»; las personas, por su función (la autoridad del dominio, el socio). Ver `CONTRIBUTING.md`.

## Cómo se midió (reproducible)

1. **Corpus:** 274 MB de transcripciones de 37 sesiones reales del lab (2026-07-14 → 07-21), destiladas a **684 mensajes del cliente** — solo la voz humana, sin salidas de herramienta. Script: `destilar.js` (extrae `type:user`, descarta meta/sidechain/system-reminder).
2. **Análisis:** 5 agentes en paralelo sobre tramos cronológicos, con la consigna de extraer **cita literal**, no interpretación.
3. **Forense de artefactos:** 1 agente midiendo con números el ROADMAP, el HANDOFF, los issues, los sprints y el casting de los dos repos (la nodriza y el lab).

## Lo que dicen los números

| | el lab | la nodriza |
|---|---|---|
| ROADMAP.md | **7 → 490 líneas en 7 días (70×)** | 33 → 140 (4×) |
| HANDOFF.md | 51 → 340; **una sola poda** | 20 → 391; **cero podas**, 12 secciones «Dónde estuvimos» |
| Issues de GitHub | **0. Cero. Nunca.** 42 hallazgos viven como filas de tabla | 21/50 abiertos; 67 % con más de 5 días |
| Milestones / tablero / Projects | `[]` / 404 | `[]` / 404 |
| Etiquetas de prioridad | ninguna | ninguna |
| Sprints con doc de entrega | 26/31 | **3 de 13 (23 %)** |

Los dos `HANDOFF.md` declaran en su primera línea *«se lee y se limpia al abrir»*. **Ninguno se limpia, y nada lo detecta.** El ROADMAP del lab declara textualmente de sí mismo *«el ROADMAP permanece»*: está diseñado para no cerrarse nunca.

## El hallazgo que ordena a los demás

El método define «hecho» así: ***«Hecho» = lo viste funcionar*** (README, disparo `demo-que-corre-el-cliente`). Es el único gate de correctitud en trabajo no-código.

**Los últimos 3 sprints del lab salieron a `main` sin que el cliente los viera.** Lo confiesa su propio HANDOFF, con título literal: `🚨 COLA DE GEMBAS VENCIDOS — imposible de perder`. Seis sprints en cola, 32 pasos de aceptación planeados, **13 sin correr**.

No es que falte sensación de avance. Es que **por la propia definición del método, nada está hecho.** La intuición del cliente estaba midiendo bien.

> Ponerle a la cola el nombre «imposible de perder» es una **confesión**, no una solución. El patrón está descrito en la tesis: si depende de que alguien se acuerde, no es muro.

## Las 5 causas raíz (con la evidencia que las prueba)

**1. El método gobierna la correctitud, no el flujo.**
Hay gates deterministas de primera para *«¿está bien?»* — andon, review-stop, ligas, anti-PII, docs gobernados. Hay **cero** para *«¿se está cerrando?»*. Toda la capa de gestión es prosa que depende de que alguien se acuerde — exactamente lo que `doctrina/00-tesis.md` llama *sugerencia, no muro*.

**2. El Gemba es advisory, no gate.** Nada bloquea abrir el sprint N+1 con la cola vencida. Por eso hay 6 acumulados y 3 releases seguidas sin aceptación.

**3. No existe el estado CERRADO.** Ningún artefacto declara un tema terminado **y lo saca de lo que `/jidoka:arranca` inyecta**. Todo doc vive para siempre → cada sesión carga 490 + 340 líneas → context rot. El cliente lo nombró solo el 15-jul: *«apartir de aqui subagenta todo para evitar el contex rot»*.

**4. El cliente ES el PM.** Los 684 mensajes lo prueban:
- Lleva el presupuesto de contexto: *«estas llenando demaciado rápido el contexto, necesito que uses más subagentes o me vas a obligar a compactar»*.
- Lleva la cola de bloqueos: la pregunta *«¿qué avanzamos sin [la autoridad del dominio]?»* aparece **casi textual en 3 sesiones distintas** — nadie la registró nunca, así que la volvió a hacer cada vez.
- No decide el alcance, lo descubre: *«la IA se ha estado echando los sprints en 1 hora con lo que ha decidio por su cuenta agregar a cada uno»*.
- Persigue el ritual: reclamó el plan mode **4 veces en 7 sesiones** (*«COmo lo acepto si no me mandaste plan mode»* · *«falto el plan mode»* · *«no entraste en plan mode, quiero el plan formal»* · *«y el plan mode?»*).

**5. El casting es un alias, no una personalidad.**
Los `.claude/agents/*.md` del lab son **byte-idénticos** a los de la nodriza (verificado con `diff`). Los nombres del casting son una tabla de traducción en `product/infra.md` que **no toca el prompt que el harness carga**. El cliente ya había reclamado la ubicación el 17-jul (*«nada que ver el casting con infa»*) y terminó cediendo. Lo que echa de menos, en sus palabras, no es un tono simpático:

> *«es algo que si echo de menos del chat anterior como que el de alguna forma tenía visibilidad y el mismo iba tomando nota de cosas que notaba»*

Es **iniciativa propia de registro**. Un asiento que note y anote sin que se lo pidan.

## La cita que ya lo había dicho todo

El dolor no es nuevo. El 14-jul, sesión 2:

> *«se supone que trabajamos con scrum... [la autoridad del dominio] valida algo tangible y funcional necesito los incrementos de cada sprint cierra los pendientes merchea las ramas y arreglemos esto»*

Y el 16-jul, la raíz, mejor formulada de lo que la formuló este análisis:

> *«me he dado cuenta que ningun proyecto se termina nunca, siempre están en movimiento/crecimiento, que hacemos para prepararnos para eso de una vez?»*

Y sobre por qué el avance no se siente aunque exista (20-jul):

> *«del punto 1 no entendí nada tu vas miles de pasos por enfrente de mi»*
> *«el tema no es que escribas mucho es que no me das tiempo de leer»*

**Avance que el cliente no puede seguir no cuenta como avance.**

## La hipótesis (a verificar — benchmark lanzado, sin resultado aún)

La Casa del TPS tiene **dos pilares**: **Jidoka** (parar ante el defecto) y **Just-In-Time** (el flujo), sobre un cimiento de *heijunka*, trabajo estandarizado y kaizen.

**El método construyó el pilar derecho, entero y con dientes. El izquierdo no existe.** Y cada síntoma corresponde a una pieza ausente de JIT:

| Síntoma | Pieza de JIT ausente |
|---|---|
| «todos los temas están siempre abiertos» | **kanban / límite WIP** |
| «vas miles de pasos por enfrente de mi» | **takt time** — el ritmo lo marca quien absorbe, no quien produce |
| ROADMAP 70× | **heijunka** — nivelar en vez de volcar |
| «un solo camino fijo, no varias rutas en paralelo» | **flujo de una pieza** |
| «no tengo sensación de avance» | **pull system** — se mide lead time, no actividad |
| el asiento del PM que no existe | **trabajo estandarizado** |

**Señal de que el método ya lo sospechaba:** el `PRODUCT_BRIEF.md` tiene un campo **`Apetito`** —concepto de Shape Up, la metodología cuya tesis central es *el backlog que crece para siempre es el enemigo*— marcado **«Pendiente del cliente»** desde que se escribió. Nunca se llenó.

**Hipótesis a confirmar o tumbar:** no hay que importar Scrum; hay que **terminar la casa**, construyendo JIT con la misma doctrina (gates deterministas fuera del LLM) y robando de Kanban Method y Shape Up las piezas que Toyota no tenía porque no hacía software.

> **Benchmark lanzado el 2026-07-21, resultado NO incorporado:** 4 investigaciones con fuentes (pilar JIT y los roles de flujo en Toyota · Kanban Method + Teoría de Restricciones · Shape Up y el backlog que no crece · reparto real de responsabilidades PM/SM/PO/TPM). **Si no aparecen anexadas abajo, no se recogieron — hay que relanzarlas.** Sin ellas, todo lo anterior es hipótesis.

## Las 5 piezas propuestas (alcance completo, orden sugerido)

Ninguna se poda del alcance. El orden es la propuesta; decide el cliente.

1. **Límite WIP como muro duro.** No se abre sprint nuevo con Gemba vencido: un gate cuenta la cola y **bloquea `/jidoka:planea`**. Es el andon aplicado al flujo.
2. **El estado CERRADO con efecto físico.** Cerrar congela, saca del ROADMAP vivo y **deja de inyectarse en el contexto**. Techo de líneas: si se pasa, el gate exige podar. Cerrar deja de ser adjetivo y se vuelve operación.
3. **Una sola vista de «qué sigue».** El único sprint activo, los siguientes 3 ítems, la cola bloqueada por terceros. Emitida en **JSON** por el motor; la cara la pinta quien sea.
4. **El reporte de avance sin terminal.** Qué cerró, qué se puede tocar, qué espera respuesta de un tercero. Es lo que convierte trabajo hecho en avance percibido — para el cliente y para los suyos.
5. **El casting con dientes.** Personalidad y enfoque **dentro** de cada `.claude/agents/*.md`, y el casting fuera de `infra.md`, en su propia casa.

## Herramientas ya disponibles y sin usar (del censo de la maqueta)

- **`SessionStart` hook — cero cableados.** Ahí va la vista de «qué sigue»: inyectada de forma determinista al abrir, sin depender de que un comando se acuerde.
- **`PreCompact` hook — cero cableados.** El disparo `desconfia-de-la-compactacion` puede dejar de ser prosa y volverse máquina.
- **Permisos `allow`/`ask`/`deny` — la sección está VACÍA**, y el disparo `deny-vs-ask` lleva meses en catálogo sin cablearse. Ese es el muro que haría que el plan mode **no se pueda saltar**.

## Decisiones abiertas — sólo del cliente

1. **~~El apetito~~ ✅ DECLARADO por el cliente el 2026-07-21** — y resulta ser el hallazgo más importante del análisis:

   | Proyecto | Capacidad de revisión **humana** disponible | Quién es la autoridad del dominio |
   |---|---|---|
   | La nodriza | **~20 h/semana** (4 h/día) del cliente | **el cliente mismo** |
   | El lab | ~5-7 h/semana del cliente, pero **techo real: 6 h/semana** de la autoridad del dominio | **un tercero** (6 h/semana, no sustituible) |

   **Las dos restricciones son distintas en naturaleza, no sólo en tamaño.** En la nodriza el cuello de botella es el propio cliente y es elástico. En el lab el cuello de botella es **un tercero cuyas horas no se pueden comprar ni delegar** — nadie más puede responder una regla de negocio.

   **Esto explica la asimetría medida al inicio de este informe sin necesidad de ninguna otra causa:** el ROADMAP del lab creció **70×** y el de la nodriza **4×**, con agentes corriendo a la misma velocidad en ambos. La diferencia es la restricción: **~3× más apretada en el lab**. La cola de Gembas vencidos existe en el lab y no en la nodriza por la misma razón.

   **El diagnóstico en una línea: el lab se está corriendo al takt de la nodriza.** Misma cadencia de sprint, misma velocidad de agentes, contra un tercio de capacidad de aceptación.

   **Corolario incómodo (paso 3 de Goldratt):** aumentar las horas que el cliente le dedica al lab **no sube el throughput**, porque él no es la restricción ahí. La restricción es el tercero. Optimizar un no-cuello-de-botella no mejora nada.

   **Primer cálculo de límite WIP por la ley de Little** (`WIP = Throughput × Lead Time`, con lead time objetivo de 1 semana) — **a calibrar con datos reales, no tomar como exacto**:
   - **Lab: WIP ≈ 3 ítems abiertos.** Si de las 6 h/semana del tercero se reservan ~4 h para conocimiento irremplazable y ~2 h para aceptación, a ~30 min por aceptación real → ~4 aceptaciones/semana.
   - **Nodriza: WIP ≈ 8 ítems abiertos.** ~10 h/semana efectivas de revisión, a ~1 h por aceptación con juicio real.

   Hoy el lab tiene **42 hallazgos abiertos** contra un WIP sostenible de ~3. La cola no es desorden: es **14× la capacidad del sistema**.

   **«Explotar antes de elevar»** (paso 2 de Goldratt): antes de pedirle más horas al tercero, hay que dejar de desperdiciar las que ya da. El forense encontró el desperdicio exacto: el archivo de preguntas **internamente inconsistente** (el índice declaraba 24, el cuerpo llegaba a 19, una retirada seguía presente) y el propio cliente pidiendo *«asegurate que no se dupliquen las preguntas y que realmente no hayan sido contestadas ya»*. **Cada pregunta duplicada quema minutos del recurso más escaso de toda la operación.** Ese es el primer kaizen, y no cuesta nada.
2. **¿Orden o paralelo?** El cliente pidió «todo» por miedo a que se traspapele. La objeción registrada: *«todo a la vez» es el mecanismo que produjo las 490 líneas*. **Registrar todo ≠ construir todo**; y la pieza que garantiza que nada se pierda es justamente la #1. Queda a su decisión.
3. **Coordinación de escritores.** Hay tres frentes de escritura en paralelo sobre el mismo método (esta sesión, el agente del lab, un agente en otra rama en otra máquina) más una rama del socio sin subir. La regla dura *«una sola sesión escritora por working tree»* ya no alcanza con varias máquinas. **Es el mismo desmadre una capa arriba**, y sin resolverlo la capa PM producirá tres versiones de la verdad sobre qué está cerrado.

## Hueco declarado de este análisis

- El benchmark se lanzó pero **su resultado no está incorporado** (ver arriba). La hipótesis de los dos pilares está **sin verificar contra fuentes**.
- El corpus destilado vivía en un directorio temporal de sesión: **si se necesita re-analizar, hay que re-destilarlo** desde las transcripciones.
- Este análisis mide el dolor y propone; **no construyó nada**. Ninguna de las 5 piezas existe.
