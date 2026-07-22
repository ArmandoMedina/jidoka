---
tipo: analisis
estado: en_revision
---
# El descubrimiento del sistema configurable — Jidoka más allá de la metodología

> **Qué es esto:** el récord del descubrimiento de dos sesiones (2026-07-20) en las que el cliente
> aterrizó una visión que venía persiguiendo desde el re-Gemba de `v1.25.0` ("ligar no es solo para
> capacidades"). Es un **informe de descubrimiento con fecha de corte**, no un plan ni una decisión:
> la decisión de identidad que sale de aquí **va a un ADR cuando el cliente la nombre** (regla de esta
> carpeta). Su artefacto de validación es la maqueta clickeable
> [`maqueta-tuberia-202607.html`](maqueta-tuberia-202607.html) — el cliente la vio y reaccionó
> ("me gustó") el 2026-07-20.

## La tesis del cliente (textual, 2026-07-20)

> *"La IA puede hacer todo, pero alguien que hace todo no hace nada. La idea es conectar tubería que
> no sea una caja negra, que se pueda guiar al usuario y a la IA por los caminos que nosotros
> determinamos como correctos. Toda la maquinaria es configurable."*

Y el marco que la acompaña: **"estamos haciendo un sistema configurable — ya no lo veas solo como una
metodología."** Jidoka evoluciona de *metodología con comandos fijos* a *sistema de gobierno
configurable con UI guiada*, donde el muro sigue siendo el gate determinista (ADR 0002 intacto) y la
UI **autora, nunca ejecuta** (ADR 0044 intacto).

## Cómo se llegó aquí (el camino importa: enseña qué NO es)

1. **El punto de partida:** "ligar" debía ser genérico — *"se pueden ligar capacidades, módulos,
   dominios, documentos… yo decido la lógica"*. La sesión anterior había hecho lo contrario
   (estrechó el comando a "ligar código a capacidad").
2. **El desvío que enseñó:** se intentó resolver con **visualización** (workflow de 21 variantes;
   spike del modo "Capas" — las 3 capas de enforcement, rama `spike/linterna-capas-enforcement-20260720`).
   El cliente lo rechazó con sus ojos: *"la verdad es que no"*. **Lección: el problema nunca fue de
   mapas.** Un mapa responde "¿cómo se ve todo?"; la pregunta del cliente es "¿qué hago con ESTO,
   ahora?".
3. **El destrape:** *"llega un aviso → abro la UI → me guía con preguntas y flujos → quiero ver cómo
   está cableado todo → reglas de negocio ('esto NO se puede conectar con esto') → más determinista,
   menos caminos."*
4. **La validación:** la maqueta de cartón (censo real de la tubería + formulario de alta + bandeja
   de pendientes + regímenes de gobierno). Reacción del cliente: **"me gustó — hay que aterrizarlo."**

## Las cinco ideas fuerza

### 1 · "Ligar" es genérico: hoy existen 4 relaciones, y la visión agrega una 5.ª

| Relación | Extremos | Dónde vive hoy | ¿Se autora con UI? |
|---|---|---|---|
| Vigilancia (blast-radius) | código ↔ doc/área | `tools/blast-radius.json` | No — JSON a mano |
| Wikilinks | capacidad ↔ capacidad | `product/**` | No |
| Ligas | código ↔ capacidad | `tools/ligas.json` | **Sí** (la extensión, ADR 0044) |
| **Lectura (`@`)** | doc ↔ comando del ritual | dentro de cada `.md` de comando | No — y nadie la ve junta |
| **Prohibición** *(nueva)* | cualquiera ↔ cualquiera | **no existe** | — |

La relación de **lectura** la descubrió el cliente ("el brief lo leen arranca Y planea — que dar de
alta un doc cambie los `@` de arranca.md"). La de **prohibición** ("esto no se puede conectar con
esto, no tiene sentido") es la única mecánica genuinamente nueva: hoy la ley solo sabe decir "si
tocas X, mantén Y fresco" — nunca "X↔Y está prohibido". Merece diseño y ADR propios.

### 2 · Cada pieza de la tubería tiene un régimen de gobierno (el contrato)

El censo de la tubería (54 piezas en 13 categorías) mostró **tres regímenes conviviendo**:

- **Motor sellado** (por hash): los `tools/*.ps1`, hooks, pre-push, CI. Editar por fuera = `DIVERGE`;
  borrar sin ADR = `BLOQUEA`. Solo Jidoka lo actualiza (el lazo).
- **Estatuto** (por estructura, KIT-2): invariantes de fábrica + extensiones del cliente,
  registradas y legales. Romper un invariante = `DESVIADO`, *garantía nula* — aviso local, muro
  opt-in en CI. Hoy solo cubre 3 docs (brief, infra, CONTRIBUTING).
- **Libre**: instancia del cliente (HANDOFF, ROADMAP, capacidades…). Se registra, no se opina.

**El hallazgo:** los comandos del ritual están en el cajón equivocado. Viajan como `mecanica`
(gobernados por hash), así que **agregar un `@` legal a tu arranca se acusa IGUAL que quitarle el
brief** — la máquina no distingue extensión legítima de mutilación. Eso produce rigidez o fatiga de
aviso. La cura: estatuto para los comandos — los `@` de fábrica y los pasos del ritual son
invariantes; los `@` que el cliente agrega son extensiones registradas.

**El estira y afloja, resuelto con la escalera de dureza que ya es doctrina:** (1) la UI no ofrece el
camino absurdo (quitar el brief no es botón; agregar un `@` sí); (2) si lo quitan a mano: `DESVIADO`,
garantía nula — la desviación se **acepta con firma** o se **restaura**, nunca queda muda; (3) muro
opt-in en CI; (4) `BLOQUEA` solo destruir motor sin ADR.

### 3 · La bandeja: "pendiente de parametrizar"

Regla del cliente: *"si se da de alta por fuera, que salga en alguna parte como pendiente de
parametrizar."* Nada nace en silencio, nada finge estar verde. Los **detectores ya existen**
(huérfanos de la linterna, el sello por hash, `estado-docs`, y el hueco de `docs/` descrito abajo);
lo que falta es **la cola que los une** y **el formulario que la vacía**. Parametrizar un elemento lo
saca de la cola; aceptar una desviación con firma también (pero la pieza carga el badge).

### 4 · El formulario de alta (burocracia una vez, determinismo para siempre)

Dar de alta una pieza = llenar su contrato: tipo (del catálogo de templates), régimen, cajón de
vigilancia + fuerza (avisa/bloquea), **qué comandos la leen** (checkboxes que escriben los `@`),
responsable, y el opt-in de muro en CI. Principios validados en la maqueta:

- **La UI recorta caminos absurdos**: no ofrece `verificar.ps1` como destino del glosario; no ofrece
  el régimen "motor sellado" (solo lo trae Jidoka de fábrica); el cajón lo sugiere el tipo.
- **Para el código no hay preguntas**: la ruta ya decide el área (determinismo existente). El juicio
  humano solo entra con docs nuevos y huérfanos — 2-3 preguntas, iguales para todas las áreas.
- Al guardar, escribe en los ledgers reales (ley, docs-gobernados, `@` de comandos) **con OK del
  cliente** — la UI autora, el gate ejecuta.

### 5 · Los hallazgos del censo (lo que el cliente no estaba viendo)

| Hallazgo | Estado | Nota |
|---|---|---|
| `permissions` de `settings.json` **vacío** | sin cablear | El harness trae allow/ask/deny determinista por herramienta y patrón — muro que no le pide permiso al modelo. El disparo `deny-vs-ask` lleva meses "catálogo-solo": la doctrina lo pedía, nadie lo cableó. |
| `PreToolUse` subutilizado | sin cablear | Puede frenar CADA edición en el momento (poka-yoke en la estación); hoy solo lo usa `no-memorias`. Los 4 gates gordos son inspectores al final de la línea (Stop). |
| Eventos `PostToolUse`, `SubagentStop`, `SessionStart`, `PreCompact` | sin usar | `SubagentStop` podría verificar al subagente antes de que el orquestador acepte su palabra; `PreCompact` volvería maquinaria el disparo `desconfia-de-la-compactacion`. |
| El hueco de `docs/` | **el verde miente** | `estado-gobierno.ps1:132`: los "árboles auditados" (`docs/`, `product/`, `kanban/`, `doctrina/`…) cuentan como "cubiertos" solo por existir — cero reglas, cero lectores, cero huérfano. Versión grande de la decisión pendiente del área `raiz` (HANDOFF). Caso real: `docs/analisis/costo-neto-sgi-202607.md` — nada lo vigila, nadie lo lee. |
| `gemba.md` no inyecta nada | sin declarar | Único comando sin `@` ni `!`. ¿Diseño o accidente? Nada lo dice. |
| Branch protection invisible | límite conocido | El único muro real es un estado server-side que ni la ley ni la linterna ven. Un check "el muro sigue en pie" (vía `gh api`) lo cubriría. |
| Los agentes ya son tubería configurada | invisible | Modelo fijo + herramientas recortadas por oficio (el arquitecto no edita, el mecánico no ejecuta, el auditor no toca lo que juzga) — "bajar caminos" ya funciona ahí, en frontmatter que nadie ve. |

## Lo que NO cambia (la frontera doctrinal)

- **La UI jamás es el muro** (ADR 0002): los gates deterministas siguen siendo el único enforcement.
- **La extensión autora, el gate ejecuta** (ADR 0044): este descubrimiento la ensancha, no la dobla.
- **Regla 2-3**: nada de esto se construye completo de golpe; cada rebanada espera su caso real.
- **El juicio queda en el humano**: la UI guía, el cliente decide; la primera vez su juicio clasifica,
  de ahí en adelante la máquina lo obedece.

## Candidatas de rebanada (orden tentativo de valor; el orden lo decide el cliente)

1. **La bandeja mínima real** — unir los detectores existentes en una cola visible ("pendiente de
   parametrizar"). Sin mecánica nueva: es presentación de señales que ya existen. De paso cura el
   hueco de `docs/` (lo no-parametrizado deja de contar como cubierto).
2. **Estatuto para los comandos del ritual** — ledger de invariantes por comando (los `@` de
   fábrica, los pasos) + registro de extensiones del cliente; el sello deja de acusar la extensión
   legal. Cura el "cajón equivocado".
3. **El formulario de alta en la extensión** — el flujo del glosario de verdad: escribe la regla en
   la ley + los `@` en los comandos, con OK del cliente.
4. **Cablear `deny-vs-ask`** — estrenar `permissions` de `settings.json` con las primeras reglas
   deny (p. ej. proteger la ley de edición directa) — el disparo deja de ser catálogo-solo.
5. **Prohibiciones** — diseño + ADR de la mecánica nueva ("esto no se conecta con esto").

## Decisiones pendientes del cliente (no se rellenan solas)

- **El ADR del cambio de identidad** (metodología → sistema configurable): se escribe cuando el
  cliente lo apruebe con nombre (disparo `aprobacion-nombrada`).
- **El orden de las rebanadas** (o correr `/jidoka:planea` sobre la primera).
- **El destino de la rama del spike** `spike/linterna-capas-enforcement-20260720` (el modo "Capas"
  rechazado en Gemba: ¿se poda o se conserva aparcada?).
- **¿Los hallazgos mecánicos van al lazo como issues?** (permissions vacías, hueco de docs/,
  gemba.md sin `@`, branch protection invisible) — batch, no goteo, como manda la casa.
