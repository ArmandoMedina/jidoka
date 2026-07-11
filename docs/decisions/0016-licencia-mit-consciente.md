# ADR 0016 — Licencia: MIT para máxima adopción (decisión consciente, no heredada)

- **Estado:** aceptado
- **Fecha:** 2026-07-11

## Contexto

Jidoka nació con licencia **MIT** (Sprint 0, `v0.1.0-beta`) — una elección de arranque, no una decisión
razonada. Antes de taggear la `v1.0.0` el cliente pidió que la licencia dejara de ser herencia y pasara a ser
decisión con registro. La tensión es real: **MIT corre en ambas direcciones** — cualquier empresa puede tomar
Jidoka, cerrarlo y venderlo sin devolver nada. La alternativa alineada con *"el que tome, comparte de vuelta"*
es **copyleft** (GPL/AGPL), que el propio autor ya usa en SimGhostInputs. La decisión es del cliente; este ADR
la fija con su camino no tomado para que no se re-litigue por olvido.

## Decisión

**Jidoka se mantiene bajo licencia MIT.** El archivo `LICENSE` no cambia. La decisión es ahora **consciente y
registrada**: se eligió MIT sobre copyleft, con los ojos abiertos al trade-off.

## Por qué

- **Una metodología es conocimiento más que código.** El valor de Jidoka es la doctrina + el método + el
  ritual; el motor PowerShell es el vehículo, no el activo. Para que un método se adopte, la barrera de
  entrada debe ser cero — MIT no obliga a nada al que lo instala.
- **Adopción máxima > reciprocidad forzada, para este activo.** El objetivo declarado (ROADMAP norte:
  *"empaquetado para que cualquiera lo instale"*) es que el método se use ampliamente. El copyleft protege
  contra el enclosure pero **fricciona la adopción corporativa** — justo el público que más se beneficiaría
  de gates deterministas sobre agentes de IA.
- **El riesgo del enclosure es bajo para conocimiento abierto.** Aunque una empresa cierre un *fork*, la
  doctrina y el método siguen públicos y evolucionando aquí; no hay un secreto que el permisivo regale.

## El camino que NO se toma (y por qué tienta)

**Copyleft (GPL/AGPL).** Tienta por principio y por coherencia: es la postura *"el que tome, comparte de
vuelta"*, y es lo que el autor ya usa en SimGhostInputs, así que unificar licencias tiene atractivo estético.
Se descarta porque para una **metodología** el copyleft compra protección contra un riesgo bajo (enclosure de
conocimiento ya público) al precio de un costo alto (fricción de adopción, que es el objetivo central). Si el
activo fuera un producto de software con ventaja competitiva encerrable, la balanza cambiaría — pero no es el
caso de Jidoka. Queda como decisión **revisable** (regla 2–3): si aparece evidencia de enclosure dañino, se
reabre.

## Consecuencias

- **Cierra el punto abierto del ROADMAP** (*Vitrina pública* ⏳5) y una de las dos decisiones que solo el
  cliente podía tomar. El párrafo en inglés del README sigue abierto (Sprint 4, público).
- **Toca el pendiente del [ADR 0001](0001-la-fusion-jidoka.md)**: si algún día la doctrina se publica suelta
  rebrandeada ("Poka-yoke"), heredará esta misma postura MIT consciente, no una nueva por defecto.
- No hay cambio de archivo ni de badge — la coherencia era ya MIT; lo que cambió es que **ahora está
  decidido**. Versión `v1.0.0`.
