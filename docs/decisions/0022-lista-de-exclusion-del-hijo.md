# ADR 0022 — La lista de exclusión del hijo: el lazo respeta lo que el hijo no quiere

- **Estado:** aceptado
- **Fecha:** 2026-07-11

## Contexto

La ventana de bajada del batch `v1.1.0→v1.4.0` a los labs destapó una fricción **recurrente** del drift
estructural (ADR 0015 #3): en **cada** `-Actualizar`, los labs tienen que rehacer los **mismos back-outs**
—`probar-gate.ps1` (incompatible con su `verificar` code-first), `andon.yml` (duplica su CI), los comandos
`jidoka/*` namespaced (los labs los tienen planos), los skills genéricos (contradicen su casting-personas)—
porque `-Actualizar` los ve **ausentes** en el hijo (fueron borrados en el back-out) y los **re-agrega** como
piezas nuevas. El operador (o un subagente) los vuelve a borrar. Es trabajo repetido, propenso a error, y una
señal de que al lazo le faltaba una forma de que el hijo dijera *"esta pieza no la quiero"*.

(La otra mitad del drift —distinguir "genérico atrasado" de "customizado"— ya la resolvieron el fix EOL
[ADR 0021] + el re-sellado limpio: el seed normalizado clasifica bien pristina-vs-customizada. Lo que
quedaba era el re-agregado.)

## Decisión

El sello del hijo (`tools/jidoka-motor.json`) gana un campo opcional **`excluir: [rutas]`**: las piezas de
mecánica que el hijo **declara que no quiere**. `instalar.ps1` lo respeta:

- **`-Actualizar`**: una pieza en `excluir` **no se re-agrega, no se actualiza, no se toca** — se reporta
  `[EXCLUIDA]` y se cuenta aparte. La lista se **preserva** en el sello re-escrito (no se pierde entre bajadas).
- **`-Sellar`**: las piezas en `excluir` se saltan (no se sellan), y la lista existente se preserva.
- Sin `excluir` (sellos viejos): comportamiento idéntico al anterior (retro-compatible).

Así el hijo **declara una vez** sus exclusiones y el lazo las honra en cada bajada — el back-out deja de ser
manual y recurrente.

## Por qué

- **Mata la fricción recurrente en la fuente.** En vez de que cada bajada repita el mismo back-out, el hijo lo
  declara y el lazo lo respeta. Es la lección de la ventana de bajada, cableada.
- **El hijo es dueño de sus exclusiones.** Qué piezas del núcleo no encajan es decisión de instancia (depende
  del lenguaje/estructura del lab), no del manifiesto genérico. El campo vive en el sello del hijo, no en
  Jidoka.
- **Es seguro**: `excluir` solo hace que el lazo **omita** (nunca borra lo que el hijo tenga, nunca pisa).
  Peor caso de una exclusión de más: el hijo no recibe una mejora genérica — un aviso, no un daño.

## El camino que NO se toma (y por qué tienta)

- **Excluir en el manifiesto de Jidoka** (marcar piezas como "opcionales"). Tienta por centralizar, pero qué
  pieza sobra es **por-instancia**: `probar-gate` es basura para un lab code-first pero núcleo para uno
  docs-as-code. La exclusión es del hijo, no del manifiesto.
- **Que Jidoka deje de sembrar esas piezas del todo.** Tienta, pero son valiosas para otros hijos; retirarlas
  del núcleo por el gusto de dos labs sería podar de más.
- **Borrar del hijo lo que Jidoka retiró (simétrico).** Distinto problema (piezas que Jidoka ya no manda);
  sigue siendo "no borrar por defecto" (el límite dpkg documentado en `-Actualizar`). `excluir` es lo inverso:
  el hijo rechaza lo que Jidoka SÍ manda.

## Consecuencias

- Cierra la mitad "re-agregado" del drift estructural (ADR 0015 #3). **Siguiente paso (no en este ADR):** los
  labs añaden su `excluir` a su sello (una vez) — SGI: `tools/probar-gate.ps1`, `.github/workflows/andon.yml`;
  TF: `tools/probar-auditor.ps1`, `.github/workflows/andon.yml`, `.claude/commands/jidoka/*`, skills genéricos.
  Entonces su próxima bajada no pedirá ningún back-out.
- Evidencia: `probar-instalador.ps1` 45/45 (3 casos nuevos: la excluida no se re-agrega, se reporta
  `[EXCLUIDA]`, el sello preserva la lista). Versión `v1.5.0`.
