# ADR 0033 — El acoplamiento proceso↔docs↔diagrama es asimétrico: el proceso manda, el diagrama y la prosa son vistas, y el puente vive en el comando

- **Estado:** aceptado
- **Fecha:** 2026-07-16

## Contexto

Con el atlas BPMN en el repo (ADR 0032) surge la pregunta natural: ¿se acopla al flujo Jidoka como el
`blast-radius` acopla código↔docs, para que un diagrama no se pudra cuando el método cambia? La tentación
es un acoplamiento **simétrico de tres vías** — "si mueves dev mueves docs, si mueves docs mueves diagrama"
en cualquier dirección. Eso choca de frente con la doctrina anti-fatiga del propio motor: el manifiesto
tiene **un solo** `doc_bloquea` real y todo lo demás avisa (regla 2-3, "un gate que grita en falso entrena
el reflejo de click-para-pasar"). La mayoría de los commits son implementación (un bugfix, un refactor) que
**no** cambian el proceso; un gate que exigiera tocar el diagrama en cada uno sería ruido puro.

## Decisión

El acoplamiento es **asimétrico**, y se cablea como **aviso, no bloqueo**:

- **Proceso = fuente de verdad (el QUÉ).** Los comandos `.claude/commands/jidoka/*.md` **son** la
  especificación del proceso.
- **Prosa (docs) y diagrama (BPMN) = dos vistas del mismo proceso.** Deben ir sincronizadas entre sí y con
  el comando.
- **Código (dev) = la implementación.** Cambia por razones que casi nunca tocan el proceso.
- **El puente concreto es el `.md` del comando:** cada diagrama declara su `Fuente:` (el comando que dibuja),
  en su `<bpmn:documentation>`. Se cablea **un aviso**: tocar un comando `/jidoka:*` avisa revisar su
  diagrama (área nueva `atlas` en `tools/blast-radius.json`, `doc_avisa: ["docs/atlas/**"]`). Nunca bloquea.
- **El bloqueo NO se cablea todavía** (regla 2-3): se gana si el drift real reaparece con costo.

## Por qué

- Un diagrama que no refleja su comando es **doc-drift visual** — el mismo mal que el escribano ya combate
  en prosa. No cablearlo dejaría al atlas pudrirse en silencio, que es justo lo que el motor existe para
  evitar.
- **Simétrico = fatiga.** Acoplar cada cambio de código al diagrama dispararía en casi todos los commits
  (implementación que no toca el proceso), y un aviso que casi siempre sobra se ignora — matando su propia
  autoridad. La asimetría mete la señal donde de verdad indica algo: en el `.md` del comando, que es el
  proceso.
- **Aviso, no muro, porque el diagrama es documentación aguas abajo.** No gobierna el código; recordar
  revisarlo basta. El render a SVG (`npm run atlas:render`) mantiene la imagen fresca de forma mecánica.

## El camino que NO se toma (y por qué tienta)

- **Acoplamiento simétrico de tres vías con bloqueo duro** (diagrama ⇄ docs ⇄ código). Tienta porque "todo
  conectado" suena riguroso y a prueba de olvidos. Se descarta: alta fatiga, señal baja, y contradice el
  diseño de un-solo-bloqueo del manifiesto. Un muro que se dispara en cada refactor se vuelve teatro que se
  saltea.
- **Mapear cada archivo de dev a su diagrama.** Tienta por completitud. Se descarta: el código no es el
  proceso; el puente correcto y estable es el `.md` del comando (el código puede reescribirse entero sin
  que el proceso cambie).

## Consecuencias

- **Más fácil:** el atlas deja de pudrirse en silencio; al tocar un comando, el aviso recuerda revisar su
  diagrama; la imagen se regenera sola con `atlas:render`.
- **Más difícil / deuda:** el aviso es **grueso** (cualquier archivo bajo `docs/atlas/` en el mismo cambio
  lo satisface); la resolución fina comando→diagrama exacto la hace el humano leyendo la línea `Fuente:` del
  diagrama. El bloqueo queda pendiente de ganárselo (regla 2-3). El área `atlas` sólo cubre los comandos
  `/jidoka:*`; las familias que nacen de `tools/` (instalar, motor, release) no tienen diagrama-espejo aún.
- **Aviso de ley:** editar `tools/blast-radius.json` toca el área `barreras` → se actualiza `andon/README.md`
  y se corre `tools/probar-gate.ps1` en el mismo cambio (dogfooding).

---

> Reglas del registro: una decisión = un archivo · al agregarlo, **listalo en el [índice](README.md) en el mismo commit** (el gate lo exige) · nunca borres una decisión: márcala *reemplazada* y enlaza la nueva.
