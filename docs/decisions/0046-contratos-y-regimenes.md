# ADR 0046 — Cada pieza tiene un régimen (motor / estatuto / libre); el régimen efectivo es fábrica + overrides firmados en `contratos.json`, que es instancia y nunca motor

- **Estado:** aceptado
- **Fecha:** 2026-07-21
- **Relacionado:** [ADR 0045](0045-identidad-sistema-gobierno-configurable.md) (la identidad) · [ADR 0042](0042-gobierno-documental-por-estructura.md) (introdujo el estatuto para docs; este lo generaliza) · [ADR 0012](0012-lazo-sincronizacion-labs.md) (el sello por hash = el régimen motor) · [[CFG-1-gobierno-configurable]] · [[KIT-2-gobierno-documental]]

## Contexto

El censo de la tubería (54 piezas en 13 categorías) mostró **tres regímenes de gobierno conviviendo** sin nombre común: motor sellado por hash, gobierno por estructura (el que ADR 0042 estrenó para tres docs), y libre. El hallazgo que obligó a decidir: **los comandos del ritual están en el cajón equivocado** — viajan como `mecanica` (gobernados por hash), así que agregar un `@` legal a tu `arranca.md` se acusa `DIVERGE` **igual** que si le quitaras el brief. La máquina no distingue extensión legítima de mutilación, y eso produce rigidez o fatiga de aviso.

Además, si el usuario va a **reclasificar** regímenes, **aceptar** desviaciones o poner **candados** desde la UI, esas excepciones necesitan un hogar que el lazo (`-Actualizar`) no pise — hoy no existe.

## Decisión

**1. Tres regímenes por pieza, con nombre.**

- **`motor`** — sellado por hash (`tools/jidoka-motor.json`). Lo actualiza solo el lazo (`-Actualizar`); editar por fuera = `DIVERGE`, borrar sin ADR = `BLOQUEA` (`no-borres-el-motor`).
- **`estatuto`** — gobernado por **estructura/secciones**: invariantes de fábrica + extensiones del cliente, registradas y legales. Romper un invariante = `DESVIADO`, *garantía nula* (aviso local, muro opt-in en CI). Es el régimen que ADR 0042 estrenó para `brief`/`infra`/`CONTRIBUTING` y que este ADR generaliza al ritual (R3).
- **`libre`** — instancia del cliente (HANDOFF, ROADMAP, capacidades…): se registra para que el verde no mienta, no se opina del contenido.

**2. El nombre `estatuto` (retiro de una marca de tercero).** El régimen del medio se llamaba por analogía con una marca ajena (un ERP). Por orden del cliente (2026-07-21) esa analogía se retira —para no depender de una marca de un tercero— y el concepto pasa a llamarse **estatuto** en todo el repo. La enmienda queda anotada en ADR 0042; no cambia la mecánica, solo el nombre.

**3. No se duplica la fuente de verdad.** Cada régimen guarda su verdad en UNA herramienta: `motor` = sello por hash; `estatuto` = ledgers por secciones/invariantes (`docs-gobernados.json` para docs, `ritual-gobernado.json` para el ritual — R3); `libre` = capa 3, sin ledger. El régimen efectivo de una pieza = **fábrica + overrides**.

**4. `tools/contratos.json` es INSTANCIA, no motor.** Registra **solo los overrides con firma** (candado IA, reclasificación, desviación aceptada) que el cliente autora. Es **no-clobber** y **jamás entra a la lista mecánica del manifiesto**: la mecánica converge en `-Actualizar`, que pisaría los datos del cliente. Nace como **lector** en R2 (la bandeja resta lo firmado) y gana **escritores** en R4/R6 (la extensión). El evaluador/hook sí se siembra; el ledger no.

**5. R3b diferida (con su porqué).** La cura completa del "cajón equivocado" incluye una **clase `contrato` en la siembra** (`instalar.ps1`/`sembrar-manual.ps1`) para que los hijos con `@` legales dejen de acusarse `DIVERGE` por el sello. Se **difiere** (R3b, ADR propio): `sembrar-manual` es AV-frágil por diseño (ADR 0027) y tocar la siembra exige una ventana con re-prueba de antivirus. En fase 1, el mensaje del detector del estatuto explica cuál gobierno manda.

## Por qué

- **El hash no sirve para lo que varía a propósito.** El motor debe ser idéntico byte a byte; el comando de instancia debe poder ganar `@` extra sin gritar. Regímenes distintos = herramientas distintas — es la misma lógica de ADR 0042, ahora nombrada y generalizada.
- **El override es del cliente, y el lazo no lo pisa.** Meter `contratos.json` al motor lo haría converger en `-Actualizar` y borraría las excepciones firmadas. Por eso es instancia no-clobber, como el HANDOFF o el brief lleno.
- **Un nombre propio antes que una marca ajena.** Depender de "como en \<marca\>" ata el vocabulario del método a un producto de un tercero; `estatuto` es autoexplicativo (la estructura es el estatuto; el contenido, libre).

## El camino que NO se toma (y por qué tienta)

- **Meter `contratos.json` a la lista mecánica del manifiesto.** Tienta por simetría con el resto del motor. Se rechaza: `-Actualizar` lo pisaría y el cliente perdería sus candados/desviaciones firmadas — exactamente el dato que no puede perderse.
- **Un solo ledger para los tres regímenes.** Tienta por DRY. Se rechaza: mezcla hash con secciones con nada; fuerza dos herramientas distintas (byte vs sección) en una y reintroduce el "cajón equivocado" que este ADR cura.
- **Sembrar YA la clase `contrato` (no diferir R3b).** Tienta porque cierra el `DIVERGE` de los hijos de una vez. Se rechaza en fase 1: tocar `sembrar-manual` es frágil ante AV (ADR 0027) y merece su ventana y su ADR — no se cuela en una rebanada de ledger.

## Consecuencias

- El **estatuto se generaliza al ritual** (R3: `ritual-gobernado.json` + `estado-ritual.ps1`) — agregar un `@` legal deja de acusarse como mutilación.
- Nace **`tools/contratos.json`** como instancia: lector en la bandeja (R2), escritores en el formulario (R4) y el modo avanzado (R6); lo lee el candado (R5).
- **Trampa confesada:** hasta R3b, el sello por hash seguirá marcando `DIVERGE` en hijos que agreguen `@` legales; el detector del estatuto explica cuál gobierno manda. No es regresión — es el estado conocido que R3b cierra.
- El vocabulario del repo queda libre de la marca de tercero (barrido `estatuto`, 2026-07-21).
