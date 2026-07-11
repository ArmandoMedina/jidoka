# ADR 0011 — Cosecha de SGI: token neutral en la ley y tres maduraciones al casting (Homologación Etapa 2)

- **Estado:** aceptado
- **Fecha:** 2026-07-11

## Contexto

El [ADR 0010](0010-roster-y-modo-desatendido.md) dejó el casting **neutral + persona** y declaró la
regla: *la maquinaria es neutral; el nombre es cosmético* (`kanban/roles.md`). Una auditoría de
homologación "full join" contra un repo hijo real (SGI, instancia code-first de sim-racing, 2026-07-11)
confirmó que la maquinaria descendió byte-idéntica —hooks, `settings.json`, comandos, esquema de la
ley— pero encontró dos cosas que **el propio método debe corregir o cosechar**:

1. **La ley de Jidoka viola su propia regla de token.** `kanban/roles.md` dice que la ley usa el
   *token de rol genérico* (`rol: revisor-visual`, en minúscula), pero `tools/blast-radius.json`
   hardcodeaba `"rol": "Escribano"` (capitalizado, con aire de persona) en las 8 áreas. El hijo
   implementó la neutralidad en minúscula que Jidoka solo describía — el superset quedó como plantilla
   sucia.
2. **Tres prácticas del hijo maduraron (regla 2–3) y deben ascender** a los asientos neutrales.

## Decisión

1. **Token neutral en la ley.** `tools/blast-radius.json` baja `"rol": "Escribano"` → `"escribano"`
   en las 8 áreas. Cambio cosmético-seguro: ningún hook ni verificador **ramifica** sobre ese literal
   (el único que ramifica es `gemba-stop`, que busca `revisor-visual`); `andon-stop`/`verificar.ps1`
   solo lo **interpolan** en el mensaje. Ahora la ley concuerda con `kanban/roles.md`.
2. **Ascienden al casting neutral tres maduraciones cosechadas del hijo:**
   - `arquitecto-doc` — criterios Gherkin **derivados de tests reales**; si no hay test, se declara en
     la nota (la versión concreta, atada a evidencia, de "las ambigüedades se marcan, no se rellenan").
   - `escribano` — **propone el texto, no commitea**; el humano aprueba antes de cerrar (alinea el
     asiento con la ley "nada irreversible se automatiza sin checkpoint").
   - `revisor-visual` — nota de que lo **medible** de lo visual puede automatizarse como **regresión de
     snapshot en CI** (verdad en CI, tolerancia generosa, opt-in), mientras lo subjetivo sigue siendo
     checkpoint humano.

## Por qué

- **La regla de token existía en prosa pero no en la ley.** Un superset que no cumple su propia norma
  siembra hijos que la heredan mal; el hijo ya demostró la forma correcta. Homologar es bidireccional:
  la lección sube aunque nazca abajo.
- **Las tres maduraciones pasan la regla 2–3** (usadas en producción en el hijo) y son **método
  neutral**, no dominio: aplican a cualquier repo con docs/UI, no solo a sim-racing.

## El camino que NO se toma (y por qué tienta)

- **Persona-ficar la ley** (dejar `"Escribano"` porque "se lee como quién valida"): tienta porque es
  legible, pero es exactamente el acoplamiento nombre↔máquina que el ADR 0010 prohibió. La autoridad la
  da el token, no la etiqueta.
- **Ascender también el instalador/las barreras de stack del hijo**: son de arquetipo *code-first*, ya
  rastreados en el `ROADMAP` (Fase 3.C); requieren diseño de máquina nueva, no cosecha de prosa. No
  entran aquí.
- **Reescribir `probar-hooks.ps1`** (su fixture interno aún dice `"Escribano"`): es data de test
  autocontenida, no la ley; cambiarla no aporta y arriesga el self-test. Se deja.

## Consecuencias

- La ley de Jidoka concuerda con `kanban/roles.md`: **plantilla limpia** para el próximo hijo.
- Tres asientos neutrales quedan enriquecidos con práctica probada en campo, sin tocar la maquinaria
  que juzga (cero riesgo de regresión: hooks/`settings.json`/comandos intactos).
- Confirmado que **no hay lección de método del hijo que Jidoka desconozca por completo**; los huecos
  restantes son de *maquinaria diferida* (arquetipo code-first), ya en el ROADMAP.
