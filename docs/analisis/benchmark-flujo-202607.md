---
tipo: analisis
estado: en_revision
fecha: 2026-07-21
---

# Benchmark del pilar de flujo — qué robar y de dónde

> **Anexo de [`gemba-gestion-del-flujo-202607.md`](gemba-gestion-del-flujo-202607.md).** Aquel informe midió el dolor y lanzó la hipótesis: *el método construyó el pilar Jidoka del TPS y le falta el de Just-In-Time*. Este la contrasta contra fuentes.
>
> **Recolección completa: 4 de 4 frentes.** TPS/JIT · Kanban Method + Teoría de Restricciones · Shape Up · reparto real de responsabilidades PM/SM/PO/TPM.

---

## Veredicto: la hipótesis se confirma, con tres correcciones

**Confirmada.** Los cuatro frentes, investigados por separado y sin conocerse entre sí, llegaron a la misma conclusión: los síntomas medidos tienen nombre, teoría y receta en el cuerpo de conocimiento del flujo, y **ninguna de esas recetas existe hoy en el método**.

Pero el benchmark corrige la propuesta en tres puntos, y los tres importan más que la confirmación:

### Corrección 1 — «el wey que organiza a la raza» no existe en Toyota

La respuesta más incómoda del benchmark. En TPS **no hay ningún rol humano cuya función sea gestionar el flujo caso por caso**. El ritmo (takt), la secuencia (caja heijunka) y el reabastecimiento (kanban) están codificados en sistemas físicos y visuales que operan **sin intervención gerencial momento a momento**. Los humanos existen para tres cosas: ejecutar el estándar, **responder a la excepción** (andon) y **mejorar el estándar** (kaizen).

> **No falta un PM. Faltan las reglas de flujo.** Contratar un asiento que persiga el trabajo a mano sería reproducir el problema con otro nombre.

Lo confirma el otro frente por vía independiente: en Scrum, el **Scrum Master no decide alcance ni prioridad** — el Scrum Guide 2020 sólo le asigna *«causing the removal of impediments»* y *«ensuring that all Scrum events take place… within the timebox»*. Quien decide alcance y acepta es el **Product Owner**, y *«the Product Owner is one person, not a committee»*. **El cliente ya es el Product Owner.** El asiento que falta sería un **TPM / Delivery Manager** —logística, cola, riesgo, reporte— sin autoridad sobre el QUÉ.

### Corrección 2 — el apetito se mide en horas del humano, no del agente

La restricción del sistema **no es producir código: es revisar y aceptar**. Teoría de Restricciones lo dice sin rodeos:

> *«optimizing a non-bottleneck step (code generation) does not improve system throughput when the bottleneck step (code review and human approval) remains unchanged»* — [DZone](https://dzone.com/articles/apply-theory-constraints-software-development-bottlenecks)

Por lo tanto el **apetito** (Shape Up) del brief no se llena con «cuántas horas de agente», sino con **cuántas horas de atención humana hay para revisar**. Todo lo demás se subordina a ese número. Es el paso 3 de los 5 de focalización de Goldratt, aplicado literal.

### Corrección 3 — hay que romper «start with what you do now» a propósito

Kanban confía en que la **presión social** de un equipo hace cumplir los límites acordados. Con agentes de IA **esa presión no existe**: un agente no «respeta» un límite, sólo obedece código que rechaza la acción. Shape Up refuerza la advertencia por otro lado: dos equipos **humanos** documentaron su abandono del método (Scale X, Trustpair) precisamente por aflojar el apetito y convertir el cool-down en estacionamiento.

> Si equipos humanos completos lo aflojaron hasta abandonarlo, **un humano solo con agentes necesita que estas reglas sean estructurales, no rituales de buena voluntad.** Que es, palabra por palabra, `doctrina/00-tesis.md` llegando por un camino ajeno.

---

## Frente 1 — El pilar JIT del TPS

**La Casa tiene dos pilares y sólo dos**, confirmado en fuente primaria de Toyota: *«The first pillar is jidoka… The second pillar is Just-in-Time»* ([global.toyota](https://global.toyota/en/company/vision-and-philosophy/production-system/)); corroborado por [Lean Enterprise Institute](https://www.lean.org/lexicon-terms/toyota-production-system/). Cimiento: estabilidad, trabajo estandarizado, **heijunka**, gestión visual ([Art of Lean](https://artoflean.com/reference/tps-house/)).

**El hallazgo que reordena todo: ir más rápido que el takt es SOBREPRODUCCIÓN.**

- El takt lo marca **la demanda, no la máquina**: *«Takt representa el latido del cliente… un objetivo calculado derivado de la demanda»* ([Art of Lean](https://artoflean.com/reference/takt-time)).
- Si una estación va más rápido, **se rebalancea o se frena** — no se le deja correr. Art Smalley (ex-Toyota): demanda de 10, producción de 15 → *«hemos hecho cinco de más… son sobreproducción, una forma de desperdicio»* ([LEI](https://www.lean.org/the-lean-post/articles/art-of-lean-on-work-waste-part-2-overproduction/)).
- Ohno consideraba la sobreproducción **la peor de las 7 mudas**, *«porque genera y oculta otros desperdicios»* ([LEI](https://www.lean.org/lexicon-terms/overproduction/)).

> **Que la IA vaya «miles de pasos por delante» no es una fortaleza sin explotar: es un defecto de diseño con nombre propio en TPS desde los años 50.**

**Kanban como límite físico.** Regla dura: *«nada se produce sin una señal kanban»*; el número de tarjetas en circulación **fija el WIP máximo** — sin tarjeta, no hay forma autorizada de empezar ([Art of Lean](https://artoflean.com/reference/kanban/)). De las 6 reglas oficiales del TPS Handbook (1973), la segunda es **el proceso siguiente viene a recoger**: el aguas abajo inicia, el aguas arriba nunca empuja ([AllAboutLean](https://www.allaboutlean.com/toyotas-six-rules/)).

**Heijunka.** Ataca *mura* (variabilidad); al prevenir mura evita *muri* (sobrecarga) y en cascada *muda*. Sin nivelar: el lead time se expande, *«un solo defecto se replica en todo el lote»*, y hay líneas saturadas junto a líneas ociosas, lo que *«corroe la seguridad y la moral»* ([LEI](https://www.lean.org/lexicon-terms/heijunka/)). En software, Poppendieck lo traduce como **cadencia regular** frente a la *death march* ([ACM](https://dl.acm.org/doi/10.5555/829556)).

**Trabajo estandarizado — quién lo escribe.** Ohno, en el manual original: **«Standards should not be forced down from above but rather set by the production workers themselves»**. Y: *«Something is wrong if workers do not look around each day, find things that are tedious or boring, and then rewrite the procedures. Even last month's manual should be out of date»* ([citado en supplychaintoday](https://www.supplychaintoday.com/toyota-production-system/)).

**Dato sobre el andon que vale para el diseño del gate.** El cordón **no detiene la línea al instante**: suena la alarma y la línea sigue hasta el siguiente punto fijo; el team leader tiene 5-30 s para resolver dentro del takt. Sólo si no resuelve, para. En TMMK se jalaba ~**2 000 veces/semana**, contra 2 veces/semana en una planta comparable de Ford — *la diferencia es cultura de respuesta, no tecnología* ([LeanBlog](https://www.leanblog.org/2026/06/andon-cord-stop-the-line-myth/)).

**«Jidoka sin JIT» tiene modo de falla nombrado:** *«Jidoka without JIT becomes isolated quality control»* — se detecta y detiene el defecto pieza por pieza, pero sin pull ni nivelación nada limita el WIP ni sincroniza el ritmo con la capacidad de consumo ([Symestic](https://www.symestic.com/en-us/what-is/toyota-production-system) — consultoría, ponderar). Dato curioso: el sesgo occidental típico es **el opuesto** (JIT sin Jidoka), lo que hace este caso inusual ([Art of Lean](https://artoflean.com/reference/jidoka/)).

**Honestidad metodológica:** la frase «quita un pilar y la casa colapsa» circula atribuida a Ohno pero **no se pudo verificar textualmente**. No citarla como suya. Y LEI advierte que *«no hay UNA versión de la casa de Toyota, sino varias»* ([Ballé](https://www.lean.org/the-lean-post/articles/should-we-have-our-own-tps-house/)).

---

## Frente 2 — Kanban Method + Teoría de Restricciones

**La ley de Little vuelve el desmadre aritmética, no sensación.** `Lead Time = WIP / Throughput` (Vacanti; [businessmap](https://businessmap.io/continuous-flow/littles-law)). A throughput constante la relación es **lineal**.

> Si el ROADMAP creció 70× y la capacidad de aceptación no cambió, la ley de Little **predice** que la espera de cada ítem se multiplica igual. *«Todos los temas están siempre abiertos»* es la consecuencia aritmética de dejar crecer el WIP.

**Drum-Buffer-Rope, con caso real.** El equipo XIT de Microsoft insertó un buffer de **8 slots** para que la demanda entrante fuera *«'choked' to a level the team could actually consume»*; el lead time bajó ([Fortelabs](https://fortelabs.com/blog/theory-of-constraints-106-dbr-at-microsoft/)). Nota de Goldratt: **explotar antes de elevar** — exprimir la capacidad existente del cuello de botella antes de invertir en más.

**Clases de servicio: la alternativa a rankear 490 líneas.** Anderson sostiene que ordenar el backlog **es en sí mismo desperdicio** y que *«the backlog should remain an unordered list»* ([djaa](https://djaa.com/ban-priority-and-prioritization/)). Cada clase trae su **propia regla de despacho**:

| Clase | Regla |
|---|---|
| **Expedite** | entra ya, se salta el WIP; límite propio: 1 |
| **Fixed Date** | por riesgo de incumplir la fecha |
| **Standard** | **FIFO estricto**: siempre el más viejo |
| **Intangible** | sólo con capacidad sobrante; si envejece, migra de clase |

**Otras piezas:** límites WIP por columna/persona/clase, con *«Stop Starting, Start Finishing»* y evidencia SINTEF/ACM sobre 8 000+ ítems en 4 años ([ACM](https://dl.acm.org/doi/10.1145/3239235.3239238)) · **commitment point**: Kanban reemplaza «backlog» por ***options pool*** — antes del compromiso son opciones, no trabajo ([glosario](https://kanban.university/glossary/)) · **work item aging**: la edad es indicador *líder*, el throughput es *rezagado*; Vacanti: *«if you can only measure and manage one thing, make it Work Item Age»* ([55degrees](https://www.55degrees.se/post/what-is-work-item-age)) · roles **SDM/SRM** cubiertos con personal existente, **no son puestos nuevos**.

---

## Frente 3 — Shape Up: el backlog que no crece

**La tesis, textual** ([cap. 7](https://basecamp.com/shapeup/2.1-chapter-07)):

> *«Backlogs are a big weight we don't need to carry… The growing pile gives us a feeling like we're always behind even though we're not.»*
> *«The time spent constantly reviewing, grooming and organizing old ideas prevents everyone from moving forward on the timely projects that really matter right now.»*

En su lugar: **no hay backlog central**. La betting table sólo mira lo shapeado en el ciclo reciente, más lo que alguien revivió **activamente**: *«Anything brought back is brought back with a context, by a person, with a purpose.»* El olvido es deliberado: *«Really important ideas will come back to you.»*

**Apetito vs estimación** ([cap. 3](https://basecamp.com/shapeup/1.2-chapter-03)) — la frase que cierra el asunto:

> *«Estimates start with a design and end with a number. Appetites start with a number and end with a design.»*

Principio derivado: **tiempo fijo, alcance variable**.

**El circuit breaker** ([cap. 8](https://basecamp.com/shapeup/2.2-chapter-08)) — la pieza más valiosa para este caso:

> *«Teams have to ship the work within the amount of time that we bet. If they don't finish, by default the project doesn't get an extension. We intentionally create a risk that the project—as pitched—won't happen.»*

Tres justificaciones textuales: evita proyectos desbocados que congelan a los demás; **un proyecto que no cierra prueba que el shaping estuvo mal, no que faltó tiempo**; y obliga al equipo a recortar alcance en vez de pedir prórroga. Lo que muere no se reanuda: se re-shapea desde cero y **vuelve a competir**.

**No-gos**: cada pitch declara por escrito lo que **no** entra — *«if there's anything we're not doing in this concept, it's good to mention it here»* ([cap. 6](https://basecamp.com/shapeup/1.5-chapter-06)). Ataca la expansión silenciosa de alcance.

**Hill charts** ([cap. 13](https://basecamp.com/shapeup/3.4-chapter-13)): comunicar avance **sin porcentajes**. Subida = todavía no sabemos cómo resolverlo; bajada = ya sabemos, sólo falta ejecutar. *«The status is human generated, not computer generated.»* Contra el porcentaje: *«'42% of the tasks are complete.' What does that tell you? Very little.»* **Es el formato para el socio y para la autoridad del dominio.**

**Lo que NO aplica, dicho sin adornos:** el **ciclo de 6 semanas** es la pieza menos exportable — se diseñó para dar foco largo a *humanos*; un agente no sufre esa fatiga. Lo transferible no es la duración sino la **función** (tope fijo + muerte automática); para un agente se mide en horas o iteraciones. Singer mismo dice que Shape Up *«provides the most value when companies reach 30 to 50 people»* ([Lenny's](https://www.lennysnewsletter.com/p/shape-up-ryan-singer)) — lo contrario de este caso. Y el apéndice [Adjust to Your Size](https://basecamp.com/shapeup/4.1-appendix-02) exime a equipos de 2-3 de betting table y cool-down formal. **Con equipos de 1 no hay evidencia: es hueco documentado, ni sí ni no.**

---

## Frente 4 — El reparto real de responsabilidades

**Scrum Guide 2020, textual** ([scrumguides.org](https://scrumguides.org/scrum-guide.html)):
- Scrum Master: *«Causing the removal of impediments»* — nótese **causing**, no *removing*. Y *«ensuring that all Scrum events take place and are positive, productive, and kept within the timebox»*. **Nunca decide alcance ni prioridad.**
- Product Owner: *«Ordering Product Backlog items»* · *«The Product Owner is one person, not a committee»* · *«Only the Product Owner has the authority to cancel the Sprint»* · puede delegar la ejecución **pero sigue siendo accountable**.
- **Definition of Done como gate binario**: *«If a Product Backlog item does not meet the Definition of Done, it cannot be released or even presented at the Sprint Review.»* ← munición textual para el gate del Gemba.

**Crítica documentada, para no copiar teatro:** *«Agile Liturgy»* — culto a la forma sobre el contenido ([ThoughtWorks](https://www.thoughtworks.com/insights/blog/agile-liturgy)) · 13 formas documentadas de gamear velocity, incluida **relajar la DoD para marcar «hecho»** ([Age-of-Product](https://age-of-product.com/gaming-velocity/)) · Fowler: *«Imposing a process on a team is completely opposed to the principles of agile software»* ([InfoQ](https://www.infoq.com/news/imposed-mandated-agile-fowler/)) · Jeffries, «Dark Scrum»: el ritual secuestrado para culpar al equipo ([ronjeffries.com](https://ronjeffries.com/articles/016-09ff/defense/)).

**El cuello de botella de revisión, con datos duros:**
- 33 000+ PRs generados por IA: **61,4 % sin ninguna revisión humana registrada**; donde la hay, el humano tiende a *dirigir* al agente en vez de evaluar el código ([arXiv](https://arxiv.org/html/2605.02273v1)).
- Mantenedores de ITK abandonaron un refactor tras **36 conversiones**: *«revisar se convierte en la parte dominante del trabajo»* ([discourse.itk.org](https://discourse.itk.org/t/ai-generated-pull-requests-overwhelming-hard-to-review-carefully/7728)).
- Analogía de Nyquist: la producción crece ×3 contra un techo humano de detección que no se mueve; pasado ese punto la revisión es **sello de goma** ([Finster](https://bryanfinster.substack.com/p/ai-broke-your-code-review-heres-how)).
- **El dato más incómodo:** el estudio de METR encontró desarrolladores **19 % más lentos** usando IA mientras se creían **20 % más rápidos** ([O'Reilly](https://www.oreilly.com/radar/coding-was-never-a-bottleneck/)). La *sensación* de avance y el avance real ya divergen de forma medida.
- Y el mecanismo exacto del ROADMAP de 490 líneas, nombrado: *«la capa de planeación seguirá descomponiendo, seguirá generando, seguirá abriéndose en abanico. No tiene razón para no hacerlo»* ([Backpressure in Agent Pipelines](https://tianpan.co/blog/2026-04-12-backpressure-in-agent-pipelines-when-ai-generates-work-faster-than-it-can-execute)).

**Prácticas reales contra ese cuello de botella:** delegación acotada por **clase de riesgo** (revisión ligera automática para lo de bajo riesgo, firma humana sólo para lo alto) · **recibos de PR**: cada entrega del agente trae resumen, límite de alcance, pasos de verificación, huecos conocidos y **«foco de revisión»: las 2-3 decisiones que sí exigen juicio humano** ([Developers Digest](https://www.developersdigest.tech/blog/ai-coding-agents-review-queues)) · criterios de aceptación pre-acordados (25-30 % menos ciclos) · SLAs de turnaround.

**Comunicar avance a no técnicos:** *«stakeholders don't want more information about your project. They want less ambiguity about whether the project is going to land»*; formato de 5 secciones (titular verde/amarillo/rojo · qué se entregó · bloqueado y en riesgo · qué necesitamos de ti · qué sigue), menos de 5 minutos de lectura. Y una regla contraintuitiva: *«an update with no blockers is either a project that isn't trying hard enough, or an update that isn't honest enough»* ([Quire](https://quire.io/blog/p/stakeholder-updates-without-the-status-meeting.html)). Las **release notes narrativas** se leen 3× más que un changelog técnico ([Appcues](https://www.appcues.com/blog/changelog-vs-release-notes)).

**Qué NO copiar:** story points y velocity (gameables, y aquí sin destinatario) · standups sincrónicos (no hay pares humanos coordinándose) · **RACI matricial** (overhead documentado en equipos de menos de 8) · retros rituales de «cómo nos sentimos» · certificación · reenviar el tracker al socio en vez de traducirlo.

---

## La carta del asiento que falta

Del frente 4, adaptada al molde de alcance negativo que ya usan los agentes de este repo.

**SÍ le toca:** llevar y empaquetar la cola de preguntas a la autoridad del dominio · vigilar y reportar el presupuesto de contexto · registrar qué está bloqueado, por quién y **desde cuándo** · forzar que el ritual de planeación ocurra · verificar **mecánicamente** si un incremento cumple la DoD ya escrita · clasificar lo entrante por riesgo para decidir qué va a aceptación delegada y qué exige firma personal · producir el reporte de 5 secciones · mantener el hill chart de cada frente · **escalar** impedimentos, no resolverlos.

**NO le toca:** decidir alcance · priorizar por valor de negocio · **aceptar trabajo** (sólo dentro de criterios pre-firmados) · interpretar reglas de negocio · negociar dinero o compromisos · juzgar calidad técnica o visual (eso es del `validador` y el `revisor-visual`) · mandar sobre nadie · **rediseñar el método por su cuenta**.

---

## Las piezas robables, consolidadas

Las cuatro investigaciones convergen en cinco mecanismos. Todos deterministas — gate, no ritual.

1. **Drum-Buffer-Rope / límite WIP duro.** Antes de que un agente arranque trabajo nuevo, contar los entregables pendientes de aceptación; si `pendientes >= buffer`, **bloquear**. Frenar la producción aguas arriba es el paso 3 de Goldratt y el rebalanceo al takt de Toyota, a la vez.
2. **Circuit breaker: muerte por defecto.** Cada ítem nace con expiración explícita. Al vencer, un script —no el juicio de nadie— lo mueve a un archivo de muertos con fecha y motivo, y lo saca del ROADMAP activo. Vuelve sólo si alguien lo **re-propone activamente**. Convierte podar, de una decisión que nadie toma, en un evento que ocurre solo.
3. **Apetito obligatorio, medido en horas de revisión humana.** Ningún ítem entra sin apetito numérico; la plantilla lo **rechaza** si viene vacío. Fuerza la decisión en el momento más barato. *(Y llena de paso el hueco del brief.)*
4. **Aceptación como booleano que bloquea.** El siguiente sprint no arranca sin `client_accepted: true` verificable. Munición textual: *«cannot be released or even presented at the Sprint Review»*. Ataca la cola de Gembas vencidos, donde «liberar» y «el cliente aceptó» están hoy desacoplados.
5. **Sin backlog central: clases de servicio + aging.** Nada de rankear 490 líneas; cuatro colas con regla de despacho propia, clase obligatoria al crear, y escalamiento automático por edad. El «¿qué sigue?» deja de ser criterio y pasa a ser consulta.

Y dos para la percepción de avance, que es la mitad del encargo: **hill chart** (subida/bajada, sin porcentajes) y el **reporte de 5 secciones** — ambos para el socio y la autoridad del dominio, sin código ni terminal.

### La advertencia que atraviesa los cuatro frentes

Ninguna de estas piezas funciona como acuerdo. Kanban depende de presión social que aquí no existe; Shape Up fue abandonado por dos equipos humanos que aflojaron el apetito; Scrum se gamea relajando la DoD. **Todas tienen que ser código que rechaza la acción.** El benchmark llegó, por cuatro caminos ajenos, a la tesis que este repo ya tenía escrita.
