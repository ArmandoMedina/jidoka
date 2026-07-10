# El lazo — Intención → Construcción → Verificación → Registro

> Dirigir software —lo escriba un humano o una IA— es el mismo lazo de control. El sprint ([README](README.md)) es el ritmo; **este lazo es lo que gira adentro** de cada rebanada. Heredado del andamio interno del linaje (ADR [0001](../docs/decisions/0001-la-fusion-jidoka.md), ADR [0004](../docs/decisions/0004-centralizacion-del-conocimiento.md)).

```
Intención ──▶ Construcción ──▶ Verificación ──▶ Registro
(capacidad     (el código)     (tests +          (ADR ·
 + criterios)                   correr la app)    CHANGELOG ·
                                                  HANDOFF)
```

## Los cuatro tiempos

1. **Intención (el QUÉ).** Di qué debe hacer, en lenguaje llano, y cómo sabrás que se cumple: una **capacidad** con **criterios de aceptación** (`Dado que… cuando… entonces…`). Es la mitad que casi todos se saltan — y la lección más cara del linaje: *sprints construidos sin criterios aprobados terminaron entregando cosas que el cliente no pidió*. El QUÉ se escribe **antes** de construir, no después.
2. **Construcción (el CÓMO).** Tú o la IA escriben el código. En rebanadas verticales, cada paso commiteable y verde.
3. **Verificación.** Los criterios se vuelven **tests**, y corres la app. Aquí confirmas que la intención se cumplió **sin tener que leer el código** — la mitad que vuelve seguro el vibe coding. El veredicto lo da el artefacto (test verde, demo corriendo), nunca la palabra del agente.
4. **Registro.** Lo no obvio que decidiste queda escrito, para que la próxima sesión (tú en 6 meses, o una IA sin memoria) tenga continuidad.

## El Registro se reparte por caducidad

No todo lo que se registra vive lo mismo. Cada cosa tiene un doc dueño:

| Caducidad | Doc dueño | Qué guarda |
|---|---|---|
| **Permanente** | ADR (`docs/decisions/`) | El **porqué** de cada decisión — incluido el camino que NO se tomó |
| **Lo enviado** | `CHANGELOG.md` | Qué cambió, versión a versión |
| **Efímero** | `HANDOFF.md` | Dónde voy, qué falta — **se llena al cerrar, se lee y se LIMPIA al abrir.** Es estado en vuelo, no historial; lo atendido se borra |

## El kit mínimo

Para muchos proyectos, esto es *todo* lo que hace falta: un brief de producto + capacidades con criterios + código con tests + ADRs + un mapa de arquitectura para no perderte cuando crezca. Lo demás es expansión opcional.

## Las dos reglas que gobiernan el lazo

- **La disciplina escala con el riesgo.** Un experimento personal no merece la ceremonia de un sistema regulado. Es un menú, no un molde.
- **Avisa temprano, bloquea al final.** Los gates locales avisan mientras trabajas; el muro real (CI + required check) bloquea al mergear. Ver [`andon/`](../andon/).
