# ADR 0041 — El gate anti-PII se parte en detector-de-formas público y denylist-de-cadenas privada

- **Estado:** aceptado
- **Fecha:** 2026-07-17

## Contexto

Jidoka es un repo **público**. Una sesión encontró que `product/infra.md` y `HANDOFF.md` nombraban una cuenta GitHub secundaria del autor — vinculaba dos identidades y violaba la "Frontera de confidencialidad" del `CONTRIBUTING.md` ("nada de datos de entorno personal en docs"). Se limpió del HEAD, pero nada impedía que volviera a colarse: la frontera era prosa, no muro. El cliente pidió "blindar con un gate".

La trampa que condiciona todo el diseño: **un gate anti-PII no puede contener la PII que busca.** Hardcodear el nombre de la cuenta o el correo personal dentro del checker los RE-publica en el mismo repo público que se quiere proteger. Cualquier diseño ingenuo (una denylist committeada) se derrota a sí mismo.

## Decisión

El gate (`tools/anti-pii.ps1`, self-test `tools/probar-anti-pii.ps1`) se parte en dos mecanismos de naturaleza distinta:

1. **Detector estructural — el muro (público, server-side).** Busca *formas* de PII, no instancias: email con dominio real (tolera `.local`/`.test`/`example`/`noreply.github.com`) y rutas de perfil de usuario nombradas (`C:\Users\<x>`, `/home/<x>`, `/Users/<x>`) que no sean placeholders. El patrón es una *clase*, no una instancia, así que vivir en git público no revela nada. Corre en el check `andon` required (con el patrón "detector de la BASE", como `verificar`) → muro real. **BLOQUEA** (exit 1); **FALLA CERRADO** (exit 2) si no puede listar el árbol.

2. **Denylist local — el cinturón (privado, pre-push).** `tools/anti-pii.denylist.txt`, **gitignoreado, nunca committeado**, con las cadenas literales del entorno del operador (cuenta secundaria, correo). El detector la lee si existe. Su formato se siembra como `tools/anti-pii.denylist.example.txt`.

Modelo de amenaza declarado: el **accidente** (dato que se cuela sin querer), no un adversario con push. Por eso las allowlists son evadibles a propósito.

## Por qué

- **La tesis manda:** "un mecanismo es muro real solo si el punto de control vive FUERA del LLM y es required check server-side" (`doctrina/00-tesis.md`). El detector estructural cumple; la denylist no puede sin filtrar su contenido — de ahí la partición honesta, en vez de fingir que la denylist es muro.
- **Cero falsos positivos medidos:** contra los 206 archivos rastreados del repo, el detector no marca nada (el handle `@ArmandoMedina` del CoC, los `@jidoka.local` de fixtures, los `C:\Users\x` y `C:\ruta\a\` de guías, todos pasan por allowlist). Un gate ruidoso se desactiva; este no lo es.
- **Es gate de contenido, no de topología:** por eso es script propio (como `auditar.ps1`), no una entrada-regla de `blast-radius.json` (que gobierna "tocaste un área sin su doc").

## El camino que NO se toma (y por qué tienta)

- **Denylist committeada / como secret de CI.** Tienta porque haría de las cadenas-conocidas un muro server-side. Descartado: committearla publica la PII; el secret de CI acopla el gate a infra configurada a mano que no viaja al kit, y es sobreingeniería para un modelo de amenaza que es accidente, no adversario. Si algún día la PII amerita ese nivel, se re-abre aquí.
- **Reescribir la historia de git** para borrar la fuga del pasado. Descartado (decisión del dueño): pesado, rompe hashes y forks, y GitHub cachea igual. El gate defiende el *futuro*; el pasado fue una limpieza puntual.
- **Un secret-scanner externo (gitleaks/trufflehog).** Rompe "el gate corre idéntico local y en CI" (PS 5.1 homogéneo) y complica la siembra al kit. Un detector de ~90 líneas cubre el caso real sin dependencias nuevas.
- **Hardcodear la cuenta/correo conocidos en el checker.** La trampa central: re-publica lo que busca frenar. El detector solo conoce *formas*.

## Consecuencias

- Más fácil: una fuga de correo real o ruta de usuario en un doc queda frenada antes del merge, server-side.
- Más difícil / deuda abierta: la denylist local no protege a un colaborador externo que no la tenga (solo el detector de formas lo cubre) — límite honesto e inevitable en un repo público. La detección de hostnames/dominios corporativos internos quedó fuera de v1 por ruido; se re-abre si un caso real lo pide.
- El gate baja a los hijos por el manifiesto (`-Actualizar`): cada repo sembrado hereda el mismo muro.

---

> Reglas del registro: una decisión = un archivo · al agregarlo, **listalo en el [índice](README.md) en el mismo commit** (el gate lo exige) · nunca borres una decisión: márcala *reemplazada* y enlaza la nueva.
