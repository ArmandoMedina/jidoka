# Contribuir a Jidoka

> Corto a propósito. Jidoka se gobierna con su propio método: los gates te dirán lo que falte — no necesitas memorizarte esto.

## El flujo

1. **Rama + PR contra `main`.** Nadie pushea directo (branch protection); el check `andon` es required y corre la ley **desde la rama base** — un PR no puede editar la ley que lo juzga.
2. **Enciende los hooks locales** (una vez por clon): `git config core.hooksPath .githooks`. El `pre-push` corre el verificador y te avisa antes que el CI. Saltarlo con `--no-verify` solo pospone el rojo (disparo `no-verify-es-teatro`).
3. **Commits**: en español, imperativo, con el porqué en el cuerpo si no es obvio. Sin trailers de sesión de IA (ADR 0003).
4. **Una decisión = un ADR.** Si tu cambio implica una decisión (no solo código), agrégala en `docs/decisions/` **y listala en su índice en el mismo commit** — es el único bloqueo duro de la ley, y es a propósito.

## Quién es dueño de qué (SSOT)

Cada hecho vive en UN doc dueño; los demás lo enlazan, no lo repiten:

| Qué | Doc dueño |
|---|---|
| El porqué de una decisión | `docs/decisions/` (ADR) — permanente |
| El porqué del método (doctrina) | `doctrina/` — y su forma ejecutable, los disparos en `kit/.jidoka/disparos/` (se actualizan juntos) |
| Qué cambió, versión a versión | `CHANGELOG.md` |
| Estado en vuelo, pendientes | `HANDOFF.md` — efímero: se llena al cerrar, se limpia al abrir |
| Hacia dónde va la beta | `ROADMAP.md` |
| El ritual y el lazo | `kanban/` |
| Los gates y su ley | `andon/` (doctrina) + `tools/blast-radius.json` (la ley única) |

La ley completa de qué-obliga-a-tocar-qué vive en `tools/blast-radius.json` — cambiarla ahí la cambia en el hook, el pre-push y el CI a la vez.

## El modelo de amenaza, en una línea

Todo aviso local se asume bypaseable; **el único muro real es el required check en CI con branch protection sin bypass** — por eso está encendido.

## Frontera de confidencialidad

Nada de nombres de clientes, personas o datos de entorno personal en commits ni docs: los casos internos se citan como "caso N" / "laboratorio de campo" (ver `doctrina/decisiones/0004`).
