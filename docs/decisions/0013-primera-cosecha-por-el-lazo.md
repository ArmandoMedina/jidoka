# ADR 0013 — Primera cosecha por el lazo: tres lecciones de campo absorbidas vía el canal

- **Estado:** aceptado
- **Fecha:** 2026-07-11

## Contexto

El [ADR 0012](0012-lazo-sincronizacion-labs.md) mecanizó el lazo labs↔Jidoka (*la lección sube, la
máquina baja*) y dejó a SGI como primer consumidor, con **lecciones de campo redactadas** en su
`qa_runs/`. La cosecha de SGI anterior (ADR [0011](0011-homologacion-cosecha-sgi.md)) fue **manual**
(auditoría "full join" + diff); esta es la **primera cosecha que pasa por el canal** que el lazo abrió —
la máquina en uso, no la mano. Además, la sesión que construyó el lazo destapó una **meta-lección del
cliente** sobre el propio método. Tres lecciones maduraron a mejora de método y se absorben con el ritual.

## Decisión

Se absorben tres lecciones (las demás quedan registradas como sprints propios — ver *Consecuencias*):

1. **`gemba-stop` exige evidencia rastreada por git.** El gate validaba evidencia fresca por *mtime del
   working tree*; como `qa_runs/` está gitignoreado, un archivo que nunca se commitea (el paso es
   `git add -f`) satisfacía el gate sin que git lo viera — un Goodhart. Ahora solo cuenta la evidencia que
   `git ls-files -- qa_runs` rastrea, alineando el gate con el disparo `evidencia-no-palabra` (existe en
   git, no solo en disco). Self-test nuevo: bloquea evidencia no-trackeada, pasa la forzada al índice.

2. **Excepción de dominio con nombre para el mandato sintético.** "Datos 100% sintéticos siempre" falla
   donde lo sintético *no ejercita el artefacto* (un HUD/render sobre telemetría). El mandato del
   revisor-visual (SKILL, `gemba.md`, `verificacion.md`) pasa a **"sintético por defecto, salvo excepción
   de dominio cableada con nombre"** (disparo `excepciones-cableadas` ya existente): dato real fuera del
   repo, solo capturas entran, y la excepción **nombrada** (no tolerada en silencio — eso afloja el gate
   para todos).

3. **Criterio operativo de delegación orquestador↔subagente.** Las reglas duras existían (`roles.md`) pero
   —dicho por el cliente— no era obvio *cuándo* aplican. Se añade una sección "Qué va a subagente vs qué se
   queda" con tabla al vistazo y **la propia sesión del lazo como ejemplo trabajado** (exploración y lab
   hijo → subagentes; motor+self-test acoplados por TDD → en sesión, anunciado 🎭).

## Por qué

- **La máquina que construimos debe usarse, no admirarse.** Cerrar el lazo con la primera cosecha real —y
  dogfoodeando el SSOT de versión que el propio lazo introdujo— prueba el canal con contenido, no con
  palabra.
- **Las tres pasan la regla 2–3 o corrigen un hueco confesado:** la #1 tapa un Goodhart medible; la #2
  reusa un patrón que ya existía en doctrina (`excepciones-cableadas`) en vez de inventar; la #3 vuelve
  operativa una regla que era principio disperso.

## El camino que NO se toma (y por qué tienta)

- **Que cada hijo parchee su propia maquinaria.** Tienta por inmediato, pero es exactamente la divergencia
  que el lazo evita: el arreglo vive una vez en Jidoka y baja a todos.
- **Endurecer `gemba-stop` a exigir *commiteado* (no solo indexado).** Se prefiere el índice (`git ls-files`
  ve lo staged): el cierre commitea después; exigir commit previo estorbaría el flujo `git add -f` del cierre.
- **Absorber también la lección `probar-gate`/`-Cambiados` de SGI.** No es lección para Jidoka (Jidoka ya
  expone `-Cambiados` desde `v0.10.1-beta`): es **convergencia de bajada de SGI**, su propio sprint.
- **Construir ya el hook de tope de concurrencia de subagentes en el kit.** La regla 3 ya documenta el
  principio; shippear el hook de referencia es trabajo de máquina aparte, no de esta cosecha de prosa.

## Consecuencias

- El motor mejorado (gemba-stop) baja a los hijos vía `-Actualizar`: la lección subió y la máquina bajará
  — el lazo cerrando su propio ciclo.
- Quedan **secuenciados como sprints propios**: **B** — SGI converge su gate (`-Cambiados` + `probar-gate`,
  moviendo ruff/pytest a la costura `.local`; toca sus 453 tests); **C** — homologación de TF (el último lab).
- Evidencia: `probar-hooks.ps1` 11/11 (con los casos Goodhart), suite completa verde. Versión `v0.12.0-beta`.
