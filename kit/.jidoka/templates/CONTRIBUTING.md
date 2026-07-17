# Contribuir a [nombre del proyecto]

> Corto a propósito. Este repo se gobierna con el método Jidoka; los gates te dirán lo que falte — no necesitas memorizar esto. Copia esta estructura al `CONTRIBUTING.md` de la raíz y llénala con lo tuyo. **La sección `## El flujo` es requerida** (el ritual `/jidoka:arranca` la inyecta con `@`; el gobierno documental por estructura la vigila — si la quitas o la reestructuras, *garantía nula*, ver ADR 0042). Las demás secciones son recomendadas: el contenido varía por proyecto, las **secciones** no.

## El flujo

1. **Rama + PR contra la rama default.** Nadie pushea directo (branch protection).
2. **Enciende los hooks locales** (una vez por clon): `git config core.hooksPath .githooks`. El `pre-push` corre el verificador antes que el CI; saltarlo con `--no-verify` solo pospone el rojo.
3. **Una decisión = un ADR** en `docs/decisions/`, listado en su índice en el mismo commit.
4. **Evidencia-no-palabra**: nada se declara hecho hasta que corre; la evidencia va al artefacto (`qa_runs/`, test, log), no a tu palabra.

## Quién es dueño de qué (SSOT)

> Cada hecho vive en UN doc dueño; los demás lo enlazan, no lo repiten. Ajusta la tabla a los docs dueños de tu proyecto.

| Qué | Doc dueño |
|---|---|
| El porqué de una decisión | `docs/decisions/` (ADR) — permanente |
| Estado en vuelo, pendientes | `HANDOFF.md` — efímero: se llena al cerrar, se limpia al abrir |
| Hacia dónde va | `ROADMAP.md` |
| Qué cambió, versión a versión | `CHANGELOG.md` |

## Versionar y publicar

> La pregunta que decide el salto: **¿rompe?** MAJOR · **¿agrega?** MINOR · **¿arregla?** PATCH. Ajusta este apartado a tu ritual de release (o bórralo si tu proyecto no versiona).

## Frontera de confidencialidad

Nada de nombres de clientes, personas o datos de entorno personal en commits ni docs: los casos internos se citan anónimos (patrón heredado del método). Ajusta a la política de tu equipo.
