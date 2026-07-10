<!-- Plantilla de PR de Jidoka: punto de inyección de disparos (andon/README.md).
     Corta a propósito — un checklist largo entrena el click-para-pasar (doctrina/04). -->

## Qué entrega este PR

<!-- En lenguaje llano: qué puede hacer ahora el repo que antes no. -->

## Evidencia, no palabra

- [ ] **El artefacto existe**: lo que este PR afirma se puede ver correr (test, demo, corrida en `qa_runs/`, o el diff mismo si es doc).
- [ ] Si agrega o cambia un **ADR**, está listado en `docs/decisions/README.md` (el check `andon` lo bloquea si no).
- [ ] Si cambia una **regla accionable**, su disparo en `kit/.jidoka/disparos/` va en este mismo PR.

> **Para el revisor humano**: revisa el *demo*, no el código. Si no hay nada que ver corriendo, pregunta por qué.
> **Disparo `no-verify-es-teatro`**: si este PR llegó saltándose el hook local, dilo aquí — el muro real es este check, no el hook.
