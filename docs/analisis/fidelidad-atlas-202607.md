# Auditoría de fidelidad del atlas — 2026-07-16

> **Qué es esto:** el careo de cada diagrama AS-IS del atlas (`docs/atlas/`) contra su **fuente real** (el comando `.md`, el script `.ps1` o el doc de método que declara en su `<bpmn:documentation>`). El atlas es AS-IS: debe reflejar lo que el método hace, no lo que sería bonito. Cada desvío lleva su cita de la fuente.
>
> **Por qué existe este archivo:** el hallazgo se re-descubrió a golpes en 3 sesiones porque vivía enterrado en transcripts. Aquí queda durable. Es la base del sprint «El atlas dice la verdad» (`docs/sprints/sprint-atlas-fiel-plan.md`).

## Método

- 24 diagramas careados (el 25.º, `referencia/arranca-propuesta-usuario.bpmn`, es una propuesta, sin fuente AS-IS).
- Cada diagrama: extraer su lógica (tareas, gateways con salidas, orden, eventos de fin, carril) y compararla contra los pasos/decisiones reales de la fuente.
- **Regla de lectura (aprendida en esta auditoría):** los scripts en cuarentena de AV (`skip-worktree`, p. ej. `tools/instalar.ps1`) **se leen de git** (`git show HEAD:tools/instalar.ps1`), nunca del disco. Auditar contra el disco dio un falso "fuente muerta".

## Veredicto

**FIEL (14):**

| Diagrama | Fuente | Nota |
|---|---|---|
| 00-arquitectura-procesos | mapa de navegación | referencias a hijos, todas vivas |
| 01-operar-sesion-entregar-incremento | mapa de navegación | 9 subprocesos, referencias vivas + salida de abandono |
| 02-instalar-mantener-metodo | mapa | 5 ramas, referencias vivas |
| 03-auditar-aprender-homologar | mapa | 3 ramas, referencias vivas |
| 04-publicar-jidoka | mapa | preflight→publicar coherente |
| 14-revision | `review-stop.ps1`, `verificar.ps1`, `andon.yml` | los 3 mecanismos correctos |
| 15-gemba | `gemba.md` | checkpoint del cliente + loop de corrección |
| 16-cierra | `cierra.md` | las 5 secciones en orden |
| 17-que-sigue | `que-sigue.md` | 3 pasos + STOP humano |
| 18-desatendido | `desatendido.md` | las dos lanes + click-it-down |
| 40-estado-motor | `estado-motor.ps1` | 3 salidas tempranas + comparación por hash |
| 41-actualizar | `instalar.ps1 -Actualizar` (Invoke-Actualizar) | gateway de 5 salidas exacto |
| 80-publicar-release | `publicar.ps1` | secciones 1–5 + Test-Path guard |
| 81-preflight-release | `publicar.ps1 -SoloVerificar` | orden de la suite correcto |

**DESVIADO (10):**

| Diagrama | Fuente | Desvío (con cita) |
|---|---|---|
| **10-arranca** | `arranca.md` | **INVENTADO:** bucle "¿Falta contexto crítico?→Solicitar aclaración→Respuesta" y tarea "Leer solo documentación activada" — no existen en la fuente. **FALTANTE:** §3 "El asiento lo ocupa el subagente" (arranca.md L41-54) y §5 "Fija las reglas duras" (L60-68) sin nodo; lecturas de `@product/PRODUCT_BRIEF.md` (L17) y `@CONTRIBUTING.md` (L22-23) ausentes. **ACTOR:** router (`rutear.ps1`, §2) en carril Motor cuando la fuente lo instruye como acción del agente. *(Verificado a mano contra `arranca.md`.)* |
| **11-descubre** | `descubre.md` | **FALTANTE:** Paso 0 (leer `product/PRODUCT_BRIEF.md` si existe, no re-preguntar — L19-24) sin nodo. **ORDEN:** el gateway del "juez de verdad" ocurre post-entrevista; la fuente lo ubica dentro del Paso 1/diagnóstico, concurrente con la ruta A/B/C (L35-39), y el kit portátil se aplica *además* de la ruta, no en su lugar. |
| **13-construye-rebanada** | `kanban/lazo.md` | **FALTANTE:** el Paso 0 "mientras exploras, nada de la maquinaria corre" (lazo.md L14) — el diagrama aplica la maquinaria de gates desde el inicio, sin la fase de exploración libre. |
| **70-auditoria-en-rama** | `kanban/auditoria.md` | **FALTANTE:** paso 6 "descartado a propósito" (lo que NO se arregla, con su porqué) sin nodo propio. **ORDEN:** el paso 7 (decisiones que necesitan al humano) se modela post-veredicto (`T_Registrar`) cuando la fuente lo prepara antes del veredicto. |
| **71-auditoria-nocturna** | `auditoria.md` + `desatendido.md` | **FALTANTE:** el "click-it-down" (si algo se complica, el agente baja de ejecutar a dejar-preparado — desatendido.md regla 1, la más importante del modo) no tiene camino de re-clasificación de `T_Ejecutar`→`T_Humano`. |
| **72-homologacion** | `kanban/homologacion.md` | **FALTANTE:** la frontera NDA (paso 4) no tiene gateway de resultado — "lo pusheado se reescribe, no se parcha" no tiene camino de remediación cuando `T_NDA` detecta violación. |
| **30-instalar** | `instalar.ps1` (git) | **ORDEN/FALTANTE:** funde copiar-motor + ley + stubs-comunes + stubs-arquetipo (L379-434) en una tarea; invierte destino↔arquetipo; no muestra el no-clobber del sello (L454); ubica el aviso brownfield al final cuando es el paso 7 de 13. |
| **42-sellar** | `instalar.ps1 -Sellar` (Invoke-Sellar, git) | **FALTANTE:** la guarda de sello preexistente (lee y preserva `excluir` previo, L270-276) y la clasificación pristina-vs-customizada-vs-ausente (el núcleo del modo: lo customizado queda fuera del sello a propósito) no se modelan. |
| **12-planea** | `planea.md` | **Menor:** el residuo que "ni el descubrimiento resuelva" no tiene rama que lo marque pendiente (planea.md L15). |
| **44-reportar-leccion** | `reportar-leccion.ps1` | **Alcance:** el script solo abre la URL del template; el diagrama modela el ritual humano completo post-script sin que la `Fuente:` lo cite. Arreglo = ampliar la fuente citada, no el diagrama. |

**Hueco (ausencia, no desvío):** no existe diagrama de `tools/sembrar-manual.ps1` (el instalador AV-seguro, ADR 0027) — la ruta de instalación en Windows endurecido no está en el mapa.

## Corrección importante registrada

El primer pase de esta auditoría marcó 30/41/42 como "fuente muerta" porque `tools/instalar.ps1` no está en disco. **Error:** el archivo está en git, `skip-worktree` + cuarentena AV (#79). Leído de git, tiene sus 3 modos (`Invoke-Actualizar` L134, `Invoke-Sellar` L269). El cliente cazó el error. De ahí la regla de lectura de arriba y el issue de tooling pendiente (auditar el atlas contra disco no ve piezas `skip-worktree`).
