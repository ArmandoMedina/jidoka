---
tipo: decision
---
# ADR 0025 — El substrato es git porque es el idioma nativo del agente: una API se degrada con el agente, git no

- **Estado:** aceptado
- **Fecha:** 2026-07-12

## Contexto

Surgio una pregunta hipotetica de fondo: *"¿y si dejamos git y hacemos una API mas potente y mas flexible?"*
Vale la pena responderla con su porque, porque el [ADR 0008](0008-el-instalador.md) eligio git como substrato
("PowerShell-first, lee del arbol") pero **nunca escribio por que git** y no otra cosa. Este ADR cierra ese hueco.

Git hace **dos trabajos** en Jidoka, y conviene separarlos:
- **Gobernar** — los gates (Andon), el blast-radius, el required check server-side. Aqui git aporta el diff como
  unidad de inspeccion y una pared que el agente no puede ablandar.
- **Sincronizar** — el lazo lab↔Jidoka: el sello, `-Actualizar`, el merge de tres vias. Aqui git es **incidental**:
  la logica es de gestor de paquetes (estilo dpkg conffiles), no de control de versiones.

La duda fina (el "seam"): git **crudo** (`git diff`, `commit`, `gh`) es nativo para el agente, pero la **logica
custom del lazo** (sello, `.jidoka-nuevo`, tres vias) NO lo es — es logica Jidoka-especifica que solo *viste ropa
git*. ¿Git-shapear la interfaz le compra fluidez nativa a esa logica custom, o solo a git crudo? Eso no se decide
por opinion; se mide.

## La evidencia (el experimento)

Se corrieron **3 agentes frescos, sin contexto, ciegos a la tesis**, con framing variado (2 arrancando *dentro*
del hijo —sin `instalar.ps1` a la vista—, 1 del lado Jidoka). Cada uno debia reconciliar un lab real (SGI, sello
1.7.1) contra el upstream (Jidoka 1.8.1), en copias desechables aisladas.

**Resultado: 3 de 3.** Los tres **descubrieron y operaron el lazo** (`instalar.ps1 -Actualizar`) desde los
artefactos solos (uno leyendo la guia `mantener-el-motor-al-dia.md`, otros por inferencia de "esto es un lab
Jidoka"). Los tres preservaron las 8 customizaciones byte-identicas, honraron las 5 exclusiones, y su resultado
**calzo exacto** con la referencia (61 al dia / 1 nuevo / 8 divergen / 5 excluidas). Ninguno hizo un `git merge`
a mano ni un `cp -r` que aplastara la instancia; uno cito los comentarios internos del instalador (ADR 0021/0022)
para justificar NO reimplementar el merge. Honestidad: n=3, todos Opus 4.8 — la confirmacion es *"para un agente
capaz"*; un modelo mas debil podria no inferir "corre el tool desde el upstream".

## Decisión

**El substrato se queda en git.** No solo por la pared (el argumento de gobernanza), sino por una razon mas fuerte
que el experimento confirma: **git es el idioma nativo del agente.** El modelo esta preentrenado con git/gh/diffs
y los opera en frio, sin instruccion, incluso degradado o post-compactacion. Cualquier API que se construya es
**fuera de distribucion**: hay que descubrirla, aprenderla y re-aprenderla cada sesion.

- **Gobernar → git, no negociable.** Necesita un diff que inspeccionar y una pared inanulable server-side.
- **Sincronizar → logica de registry, pero interfaz de git.** La logica es de gestor de paquetes; la interfaz con
  el agente se queda git-shaped (archivos, hashes, `.jidoka-nuevo`, `git diff`) **porque el consumidor es un modelo
  nativo a git**. Git-shapear la interfaz SI le compra fluidez a la logica custom — el experimento lo demostro.
- **Una API bespoke solo gana donde el consumidor NO es el agente degradable:** un humano (dashboard, instalador
  cross-platform) u otro sistema (CI, un registry que hospede versiones del motor por detras). El touchpoint del
  *agente* siempre se queda en git.

## Por qué

- **Fluidez nativa que no se degrada.** La tesis del metodo es que el substrato aguante *cuando el agente se
  degrada*. Una API se degrada JUNTO con el agente: en el momento click-it-down el modelo tira de `git status` por
  instinto, no de una tool custom, y la rodea bajo presion. Git no se degrada. Ni MCP lo salva: el tool list da que
  la tool *existe*, no la fluidez de *como* usarla — y esa fluidez se pierde al compactar.
- **Generaliza el [ADR 0003](0003-auditoria-del-motor.md).** "La IA no lee docs de metodologia → cablea la regla
  en el gate" es el mismo hallazgo en otra forma: un canal que el agente debe *recordar* (los docs, "la API")
  falla; un canal cableado al substrato (el hook, git) aguanta. Esta tesis lo nombra: el porque es la fluidez
  nativa, y lo extiende de "docs vs hooks" a "API vs git".
- **Complementa el [ADR 0008](0008-el-instalador.md)** con el *por que git* que ahi faltaba.

## El camino que NO se toma (y por qué tienta)

**Reemplazar git por "una API mas potente y flexible" para gobernar/sincronizar.** Tienta por flexibilidad,
cross-platform y elegancia. Se descarta porque, para este proposito, la flexibilidad es *el enemigo*: una API
cooperativa con el agente es una superficie que el agente **moldea** → vuelve a palabra-no-evidencia; y una que
debe recordar, la **olvida y rodea** bajo estres. La mejora genuina que si vale —matar PowerShell-como-glue y darle
al motor una API por encima *de* git— no exige dejar git; git se encoge a **ser la pared + la interfaz nativa**, y
todo lo demas (frontends para humanos/sistemas) se gradua a API.

## Consecuencias

- Git pasa de "substrato provisional heredado" a **decision deliberada con su porque**.
- **Prediccion falsable (prueba de vida):** si algun dia alguien expone una operacion de sincronizacion como API
  bespoke (MCP/SDK) y **pega** —los agentes la usan bien a traves de sesiones sin re-explicarsela— la tesis esta
  mal y este ADR se revisa. Hasta entonces: la interfaz del agente se queda git.
- Deja abierta, sin contradecirla, la evolucion de la *logica* del lazo hacia un registry (versionado del motor)
  mientras el touchpoint del agente siga siendo git.
- Evidencia archivada: el experimento de los 3 agentes frescos (este sprint). Versión `v1.9.0`.
