---
tipo: decision
---
# ADR 0023 — La estructura canónica: comandos namespaced, rol neutral el mecanismo, nombre del skill de instancia

- **Estado:** aceptado
- **Fecha:** 2026-07-11

## Contexto

El drift estructural (ADR 0015 #3) tenía una mitad sin resolver: la **forma** difiere entre Jidoka y los labs,
y nadie había declarado cuál es la canónica. El cuadro real (verificado):

| | Comandos `/jidoka:*` | Skills |
|---|---|---|
| **Jidoka** | 6 **namespaced** (`.claude/commands/jidoka/*`) | nombres **neutrales** (arquitecto-doc, revisor-visual, validador, escribano) |
| **SGI** | 6 **planos** *y* 6 namespaced (los mismos duplicados) | persona *y* neutrales (8, duplicados) |
| **TF** | 6 **planos** | persona (ahiram/armando/charbel/mariana/escribano) |

Hay cruft: SGI tiene los mismos comandos y skills dos veces; los tres divergen en forma. La mecánica de
exclusión (ADR 0022) ya quita la fricción de re-agregado, pero faltaba **decidir la forma canónica** para
converger y limpiar.

## Decisión

1. **Comandos: namespaced (`.claude/commands/jidoka/*`, invocados `/jidoka:*`) es lo canónico.** Un método
   instalado en cualquier repo no debe **colisionar** con los comandos propios del proyecto: si el proyecto ya
   tiene un `/planea`, el `/jidoka:planea` no choca. El plano es cómodo pero colisiona; el namespace es la forma
   segura por defecto.

2. **El mecanismo canónico es el ROL NEUTRAL, no el nombre del skill.** La ley (`blast-radius.json`) y los hooks
   referencian **roles** (`revisor-visual`, `arquitecto-doc`, `validador`, `escribano`). El **nombre de la
   carpeta del skill es sabor de instancia**: neutral (como Jidoka) o **persona** (como los labs), siempre que
   la persona **declare su asiento neutral** (mariana→revisor-visual, etc. — ya lo bendijo el
   [ADR 0035 de SGI](../casos-de-exito.md)). La autoridad la da la ley, no el nombre.

3. **Los labs convergen la FORMA, conservan el SABOR:**
   - **Comandos → namespaced** en ambos labs (dejan de tener la versión plana). SGI ya tiene la namespaced:
     borra las 6 planas duplicadas. TF mueve sus 6 planas a `jidoka/`.
   - **Skills → una sola familia por lab.** El lab elige su sabor (Jidoka: neutral; labs: persona) y **excluye**
     (ADR 0022) la familia que no usa para que el lazo no la re-siembre. SGI: conserva personas, excluye/quita
     los skills neutrales duplicados. TF: ya está limpio (solo persona).

## Por qué

- **Namespaced = seguro para instalar en cualquier lado.** Es la única forma que garantiza que sembrar el
  método no pise los comandos del proyecto anfitrión. Para un método que se instala, la colisión no es
  hipotética.
- **Separar mecanismo (rol) de nombre (skill) ya estaba resuelto a medias** (ADR 0035); este ADR lo eleva a
  regla canónica del método, no solo de SGI: **la ley manda por rol; el nombre es cosmético/de instancia.**
- **La exclusión (ADR 0022) hace barata la convergencia de skills:** el lab no tiene que pelear con el lazo cada
  bajada; declara su familia y listo.

## El camino que NO se toma (y por qué tienta)

- **Comandos planos como canónico** (más cortos de teclear: `/planea` vs `/jidoka:planea`). Tienta por
  ergonomía, pero regala la seguridad de colisión — justo lo que un método instalable no puede ceder. La
  comodidad no vale el choque con el repo anfitrión.
- **Forzar nombres neutrales en los labs** (matar las personas). Tienta por uniformidad total, pero el ADR 0035
  ya decidió —con buena razón— que las personas son sabor de instancia legítimo mientras declaren su asiento.
  Uniformar el nombre no compra nada que el rol neutral en la ley no dé ya.

## Consecuencias

- **Reconciliación de los labs** (con la exclusión de ADR 0022): SGI borra los 6 comandos planos duplicados +
  los skills neutrales duplicados (y los excluye); TF converge sus comandos a `jidoka/*`. Ambos quedan con la
  **forma canónica** (namespaced) y su **sabor** (SGI/TF personas; Jidoka neutral) — la mecánica igual, la
  estética libre, como se pidió desde el inicio del lazo.
- Cierra la segunda mitad del drift estructural (ADR 0015 #3): la primera fue la clasificación (ADR 0021) + la
  exclusión (ADR 0022); esta es la forma canónica declarada.
- No cambia nada en Jidoka mismo (ya es namespaced + neutral); el trabajo es de reconciliación en los labs.
  Versión `v1.7.0`.
