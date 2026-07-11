# ADR 0018 — El muro cumple lo que promete: grietas 2 y 5 cerradas con invariantes testeables

- **Estado:** aceptado
- **Fecha:** 2026-07-11

## Contexto

La auditoría externa (`ROADMAP.md` → grietas) dejó dos huecos *confesados* en la promesa central de Jidoka
—*los gates son deterministas, no teatro*— que ahora que el repo es `v1.0.0` son deuda de credibilidad
(un tercero los encontrará):

- **Grieta 2:** el hook `no-memorias` solo interceptaba `Write|Edit`; una escritura vía Bash (`Set-Content`,
  redirección `>`) rodeaba el deny. *"Un aviso disfrazado de deny."*
- **Grieta 5:** 11 de los 12 disparos eran "catálogo, no máquina". El diagnóstico fino: la mayoría **ya se
  referenciaban** en hooks/comandos/templates — el problema real era que **nada lo verificaba**, así que el
  cableado se pudría en silencio (drift). No faltaba cablear; faltaba un guardián que lo comprobara.

Ambas se cierran con el estándar que Jidoka le exige a los demás: **invariantes testeables, no prosa.**

## Decisión

1. **`no-memorias` cubre Bash.** El hook inspecciona además `tool_input.command` y **deniega la escritura** a
   una ruta de memoria (`.claude/projects/<slug>/memory/`) cuando el comando trae un token de escritura
   (`Set-Content`/`Out-File`/`New-Item`/`Copy-Item`/`Move-Item`/`tee`/`cp`/`mv`/redirección `>`). La
   **lectura/recall no se bloquea**. El matcher de `.claude/settings.json` pasa a `Write|Edit|Bash`. Prueba de
   vida: cuatro casos nuevos en `probar-hooks.ps1` (deny en escritura Set-Content/redirección, allow en
   lectura y en escritura normal del repo).

2. **El registro de disparos cableados.** Cada disparo del catálogo (`kit/.jidoka/disparos/README.md`) declara
   su estado: **`Cableado en:`** su punto de inyección real (que **nombra el slug** como marcador estable) o
   **`Catalogo-solo:`** con su razón (principio de diseño sin gate en runtime — `deny-vs-ask`,
   `capacita-desde-el-artefacto`). Un self-test nuevo, **`probar-disparos.ps1`**, verifica que cada
   `Cableado en` siga presente en su punto (detección de **rot**), con un caso sintético que DEBE detectar un
   cableado podrido. Se registra en `andon.yml` (CI) y en el manifiesto (`clase: mecanica`). Es **tolerante a
   puntos ausentes** (un hijo que no sembró el PR template los **omite con aviso visible** — sin descartes
   silenciosos— en vez de fallar); en Jidoka están los 10, rigor total.

## Por qué

- **Un muro con hueco confesado en su vitrina 1.0 es deuda de credibilidad.** Cerrar las grietas con tests
  —no con más prosa— es dogfoodear la propia tesis: *poka-yoke, evidencia-no-palabra* aplicados a Jidoka mismo.
- **La grieta 5 era de verificación, no de cableado.** Por eso la cura es un registro machine-checkable: cablear
  a mano una vez es exactamente lo que ya se hizo y se pudrió. El guardián evita que vuelva a pasar.
- **Ambas curas son mecánica** → bajarán a los labs por `-Actualizar` (el lazo cerrando su ciclo otra vez).

## El camino que NO se toma (y por qué tienta)

- **Cablear los disparos a mano y darlo por hecho (sin self-test).** Tienta por rápido, pero es la causa raíz de
  la grieta 5: sin un check, el cableado se cae en el siguiente refactor y nadie lo nota. Un invariante sin
  prueba de vida no es invariante.
- **Bloquear TODO comando Bash que mencione la ruta de memoria (incluida la lectura).** Tienta por "máxima
  seguridad", pero rompería el recall legítimo (leer una memoria recuperada es válido); un gate que grita en
  falso entrena el reflejo de saltárselo (`excepciones-cableadas`). Solo se deniega la escritura.
- **Prometer cobertura server-side de `no-memorias`.** Imposible honestamente: la memoria es **conducta del
  agente, no estado del repo** — un check de CI no puede verla. Se confiesa como frontera en vez de fingirla.

## Consecuencias

- **Grieta 2: cerrada en parte.** Los caminos Bash obvios ya no rodean el deny. **Residual honesto**
  (confesado en `andon/README.md`): aliases (`sc`/`ac`/`ni`) y rutas ofuscadas (base64, armadas por variable)
  evaden el matcher heurístico; server-side sigue sin cobertura por la naturaleza del problema.
- **Grieta 5: cerrada** con un registro que no se puede pudrir en silencio (el CI falla si un cableado se cae).
  Quedan **dos disparos catálogo-solo** por diseño (principios, no mensajes de gate), declarados con su razón.
- **Suite**: `probar-hooks.ps1` 15/15 (con los casos Bash), `probar-disparos.ps1` nuevo 4/4 (con el caso de
  rot), `probar-instalador.ps1` 35/35 (el hijo corre `probar-disparos`). Versión `v1.1.0`.
- **Follow-through**: el hook y el nuevo self-test son mecánica → bajarán a SGI y TF por `-Actualizar` en un
  paso aparte (como Sprint B).
