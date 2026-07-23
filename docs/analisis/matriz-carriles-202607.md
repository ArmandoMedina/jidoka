# Matriz de carriles de la IA — muro / prosa / nada (2026-07-22)

> **Qué es.** El mapa honesto de por dónde puede viajar una sesión de IA en un repo gobernado
> por Jidoka: qué escenarios tienen **muro** (un mecanismo determinista fuera del LLM que
> deniega o bloquea), cuáles solo **prosa** (una instrucción inyectada que el agente puede
> honrar u olvidar), y cuáles **nada**. Nace del escaneo del sprint 26
> (`escaneo-camino-2.0-202607.md`, ángulo «caminos de la IA») y del objetivo del proyecto de
> asegurar que la IA viaje solo por los caminos planeados — una afirmación que sin este
> mapa sería el acta que se auto-firma.
>
> **Cómo se usa.** La regla 2 del repo (`kanban/roles.md`) manda: se cablea un muro para lo que
> **ya se salió del carril en campo, medido** — no para todo. Esta matriz es el insumo de esa
> decisión: cada fila «prosa» o «nada» es un candidato, y la métrica de «correcciones del
> cliente al agente» del cuadro de cierre dice cuál merece pasar a muro. Un rojo aquí es
> **rojo honesto**: se documenta, no se finge verde.

## La asimetría estructural

Los muros duros viven en dos momentos: **al editar** una pieza candada (PreToolUse: `no-memorias`,
`candado`) y **al cerrar** (Stop: `andon`, `review`, `gemba`, `validador`). El arranque y el
proceso de sprint (arrancar bien, planear antes de picar, no saltarse plan mode) se gobiernan
por **prosa** inyectada en los comandos `/jidoka:*`. Es coherente con el norte («la disciplina
en el robot, el juicio en el humano») — pero hay filas donde el juicio queda en el *agente*,
no en el humano, y esas son las que esta matriz vigila.

## La matriz

| # | Escenario | Carril hoy | Mecanismo / evidencia | Qué faltaría (si el campo lo pide) |
|---|---|---|---|---|
| 1 | Sesión arranca sin `/jidoka:arranca` | 🟡 **Prosa** | `flujo-sessionstart.ps1` solo empuja la vista (exit 0 siempre) | Hook `UserPromptSubmit` que inyecte reglas duras por turno |
| 2 | Editar código sin plan aprobado | 🔴 **Nada** | Ningún PreToolUse exige plan activo; `planea.md` es prosa | Gate PreToolUse «hay plan/rama de sprint» para áreas `fuente` |
| 3 | Push directo a `main` | 🟡 **Muro parcial opt-in** | `.githooks/pre-push` (saltable con `--no-verify`); branch protection es paso humano (#47) | El muro real es server-side: branch protection con check requerido — dominio del `devops`, fuera del repo (disparo `no-verify-es-teatro`) |
| 4 | Saltarse plan mode (reclamado 4× en 7 sesiones, medido) | 🟡 **Prosa** | «STOP 2 siempre en plan mode» es texto (`planea.md`); cero matchers `ExitPlanMode` | El ítem del ROADMAP «plan mode inescapable» (con permisos `ask`) |
| 5 | Compactación que miente | 🟡 **Prosa** | Disparo `desconfia-de-la-compactacion` solo se inyecta en `arranca` | `PreCompact` hook (ROADMAP «Algún día») |
| 6 | Sesión desatendida | 🟡 **Prosa** | Protocolo `desatendido.md` (lanes, «nada irreversible sin humano») es honor-system | Los mismos PreToolUse/Stop la cubren; distinguir el modo no tiene muro |
| 7 | Dos sesiones escritoras (multi-PC) | 🟡 **Prosa con daño demostrado** | Regla 5 de `roles.md`; un commit ajeno dejó ciegos los Stop hooks de otra sesión | Ítem del ROADMAP «coordinación de escritores multi-máquina» (lock/lease) |
| 8 | Repo hijo con motor desincronizado | 🟡 **Prosa + vista** | `estado-motor.ps1` informa (exit 0 siempre, por diseño); los PreToolUse fallan-abierto en hijos sin ledger (deliberado, portabilidad) | Gate de cierre «hijo atrás de la nave» si el campo lo pide |
| 9 | «Listo» sin evidencia | 🟢 **Muro parcial** | `gemba-stop`/`validador-stop` (por rol de área) + `review-stop` (marcador humano); en lógica pura sin área declarada, solo el review-marker | Declarar el rol del área en la ley cuando aplique — no inventar muro genérico |
| 10 | Editar una pieza candada | 🟢 **Muro** | `candado-pretooluse.ps1` (deny; límite confesado: aliases/rutas ofuscadas en Bash evaden el matcher heurístico) | Frontera confesada; cerrarla es trabajo real, no descuido |
| 11 | Bloque `permissions` allow/ask/deny | 🔴 **Nada** | `.claude/settings.json` no tiene bloque `permissions`; el lado *ask* del disparo `deny-vs-ask` sigue sin cablear | El ítem del ROADMAP «permisos allow/ask/deny + plan mode inescapable» |

**Resumen honesto (trazable a las etiquetas de la tabla): 1 muro — #10, con límite confesado ·
2 muros parciales — #3 (opt-in local) y #9 (por rol de área) · 6 prosa — #1, #4, #5, #6, #7,
#8 · 2 nada — #2 y #11.**
La frase «la IA siempre viaja por los caminos planeados» **no se puede afirmar hoy** — lo que
sí se afirma con evidencia: estos 2+1 caminos tienen muro probado por suite
(`probar-hooks.ps1` 47 casos, `probar-gate.ps1` 14, `probar-gemelas.ps1`), y estos 8 son prosa
o nada, **a sabiendas y por decisión** (regla 2: no sobre-cablear).

## Lo que este doc NO decide

- **No prende muros.** Prenderlos es decisión del cliente, fila por fila, con la métrica de
  correcciones en la mano (los ítems ya existen en el ROADMAP: permisos+plan-mode 4h,
  coordinación multi-máquina 8h, PreCompact).
- **No inventa la suite de simulacros.** `probar-caminos.ps1` (escenarios off-path end-to-end)
  se decide DESPUÉS de medir — está confesado como frontera en `probar-gemelas.ps1` y en el
  plan del sprint 26 («Lo que NO entra»).

> **Mantenimiento.** Esta matriz se revisa en cada cierre de sprint que toque `.claude/hooks/`,
> `settings.json` o la ley — si una fila cambia de carril, el cambio se anota aquí con fecha.
> Procedencia: escaneo 4-ángulos del 2026-07-22, sprint 26 «La 2.0 estable».
