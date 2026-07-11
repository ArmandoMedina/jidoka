# ADR 0010 — El roster completo (`devops`), el modo desatendido general, y el casting neutral+persona

- **Estado:** aceptado
- **Fecha:** 2026-07-10
- **Sprint:** Homologación · Etapa 1

## Contexto

El cliente quiere **una sola metodología** — no versiones paralelas entre Jidoka y sus dos casos de éxito (SGI, TF). Un diagnóstico de delta (dos agentes de extracción, evidencia contra el artefacto) mostró que en el **motor** Jidoka ya es la versión más nueva de los labs (falla-cerrado, hooks data-driven, CI con la ley en la base), así que converger hacia Jidoka es un *upgrade*, no una regresión. Solo faltaban **tres piezas de método** para que Jidoka sea el superset real y los labs puedan adoptarlo sin perder nada. Esta es la Etapa 1: subirlas. La Etapa 2 (que los labs adopten) es aparte.

## Decisión

1. **El roster gana el asiento `devops`.** Es el agente de **plataforma/máquina** (VMs, SSH, sandbox, CI, deploys, secretos, `core.hooksPath`, branch protection, config de cuenta). Como el orquestador y el desarrollador, **no es una skill del repo** — su dominio es la máquina, no el código, y no vive en el repo. Con esto los asientos no-skill son tres.
2. **El modo desatendido se generaliza a cualquier actividad**, no solo auditar (`kanban/desatendido.md` + `/jidoka:desatendido`). Consolida lo que estaba disperso: las **dos lanes** `[agente]`/`[humano]`, la prioridad declarada, el click-it-down, y las reglas duras (nada irreversible sin el humano; **el agente no edita sus propios gates**).
3. **El casting es maquinaria neutral + persona opcional** (`kanban/roles.md` → *Personalizar el casting*, modelo del starter): la ley y los hooks usan el token de rol genérico siempre; el nombre propio es una capa cosmética por repo. La autoridad la da la ley (el campo `rol` de cada área), no el nombre.

## Por qué

- **`devops` como asiento-no-skill respeta la propia doctrina** (`asiento ≠ skill`): forzarlo como skill habría sido sobreingeniería y habría contradicho `roles.md`. El rol faltaba en el menú; la forma correcta de añadirlo es documentarlo, no cablear una skill.
- **El modo desatendido ya era doctrina a medias** (la corrida nocturna de `auditoria.md`); generalizarlo cuesta poco y cierra la deuda real: el cliente precisó que el trabajo autónomo no es solo auditar.
- **El casting neutral+persona resuelve la tensión sin maquinaria:** la metodología es una (la maquinaria neutral); los nombres son etiquetas. Dos repos con castings distintos corren *el mismo método*. Cero alias en runtime, cero paralelo.

## El camino que NO se toma (y por qué tienta)

- **Cablear `desarrollador` y `devops` como skills** (como hicieron los labs con `ahiram`). Tienta por paridad con los labs. Se descarta: contradice `asiento ≠ skill` y agrega maquinaria que la doctrina dice explícitamente que no debe existir. El desarrollador es el trabajo por defecto; el devops es plataforma. Un repo *puede* persona-ficarlos localmente, pero el método no los impone como skills.
- **Una capa de alias en runtime para el casting.** Tienta para "soportar nombres". Se descarta: el renombrado es cosmético en tiempo de siembra (carpeta + `name:`), no una capa que mantener. Menos es más.

## Consecuencias

- Jidoka queda como **superset del método** de los labs: los labs pueden adoptar su núcleo (motor + hooks + comandos + skills neutrales) sin perder nada, conservando su casting como personas y su config-instancia.
- La Etapa 2 (migrar cada lab, en rama, reversible) tiene el terreno listo.

## Qué NO resuelve

- **La convergencia real sigue pendiente:** ningún lab ha adoptado Jidoka aún. Esto solo prepara el superset. El valor se materializa cuando SGI o TF corran sobre el núcleo unificado (Etapa 2), no antes.
- **El instalador aún no pregunta neutral/nombres** — el casting se personaliza a mano (documentado); el prompt del instalador es un enhancement de la Etapa 2.

---

> Reglas del registro: una decisión = un archivo · al agregarlo, **listalo en el [índice](README.md) en el mismo commit** (el gate lo exige) · nunca borres una decisión: márcala *reemplazada* y enlaza la nueva.
