---
tipo: decision
---
# ADR 0028 — El gate de validación por medición (`validador-stop`): evidencia-no-palabra para datos/especificación

- **Estado:** aceptado
- **Fecha:** 2026-07-14

## Contexto

El método tenía **dos** gates de evidencia con rol propio, y ambos atados a un tipo de entregable:

- `review-stop` → **código** (áreas `revisa: true`).
- `gemba-stop` → **visual/UI** (áreas `rol: revisor-visual`).

Bajando el método a un repo de **reconstrucción / ingeniería inversa**, el entregable central no era ninguno de los dos: era una **especificación numérica** recuperada (una fórmula) que debía verificarse **recalculándola contra golden-masters** (créditos reales, celda por celda). Un sprint la cerró declarando en prosa *"validado al centavo"* — un acta auto-firmada (disparo `evidencia-no-palabra`). **Ningún gate lo atrapó:**

1. `gemba-stop` **dormido** (no había área `revisor-visual`).
2. `review-stop` **no aplicaba** (el cambio era doc/spec, no `src/*`).
3. Los Stop hooks leen el working tree sin commitear → al mergear, árbol limpio → nada que ver.

Cuando por fin se corrió un motor determinista, **desmintió el acta**. El acta se coló porque el **tipo de deliverable caía fuera de lo que la ley vigilaba** (issues #51 y #52). Y el fallo-abierto de `git status --porcelain` sobre directorios recién-nacidos (#50) hacía que ni el deliverable nuevo casara. Los proyectos de reconstrucción, migración de datos e ingeniería inversa **viven** de este tipo de entregable.

## Decisión

**Se añade un tercer gate de evidencia, simétrico a los otros dos pero para NÚMEROS: `validador-stop`.** Reusa toda la maquinaria existente (nada nuevo en la arquitectura):

1. **Token en la ley.** Un área con `rol: "validador"` en `blast-radius.json` (el rol ya existía en `kanban/roles.md`; solo faltaba el hook que lo leyera). Enciende el gate; si ninguna área lo declara, el hook nace **dormido** — como `gemba-stop` en el propio Jidoka.
2. **`validador-stop.ps1`.** Stop hook calcado de `gemba-stop`: si cambia una `fuente` de un área `validador` **sin** evidencia **fresca y rastreada por git** de una corrida, **bloquea el cierre**. Válvula humana por marcador (`.claude/.validador-marker`, SHA del diff aprobado), nunca auto-firma.
3. **Motor determinista.** El repo aporta `tools/validar-<dominio>.ps1` que recalcula el artefacto contra los golden-masters y emite la tabla `entrada → obtenido → esperado` + `exit 0/1`. **El cálculo lo hace el motor, nunca el LLM** (coherente con "el determinismo bloquea; el juicio orquesta"). El método define el **contrato** (exit code, ruta de evidencia); el repo implementa la fórmula — como `verificar.ps1` se customiza por arquetipo.
4. **Evidencia.** `qa_runs/validador-*/` forzado al índice con `git add -f` (cierra el mismo Goodhart que `gemba-stop`: fresco por mtime pero nunca commiteado no vale).

### Variante local para fixtures confidenciales

Cuando los golden-masters son **PII** (gitignored, fuera del remoto), el motor **no puede correr en CI** (el runner no los tiene). Por eso el gate es **local, tipo Gemba** (corre en `Stop`, no en el push) y exige la **evidencia commiteada saneada** (la tabla sin los datos sensibles), no la corrida en el servidor. Es el caso natural de cualquier repo con datos reales de por medio.

## Consecuencias

- El hueco por el que un *"validado al centavo"* en prosa se colaba **queda cerrado**: un deliverable de datos/spec ya tiene maquinaria equivalente a la que ya tenían código y UI.
- Con `rol: validador` disponible, el **lint de arquetipo de #51** ("¿ninguna área dispara gate de evidencia?") deja de ser un hueco silencioso: un repo de data/spec ya tiene *un gate que declarar*.
- **Prueba de vida:** cinco casos en `tools/probar-hooks.ps1` (bloquea spec sin corrida; bloquea evidencia fresca-pero-no-rastreada; deja cerrar con `git add -f`; dormido sin área; respeta `stop_hook_active`), incluido el que **DEBE bloquear** — un gate no se estrena sin eso (`prueba-de-vida-del-gate`).
- En **Jidoka** el gate nace **dormido** (el método no tiene deliverable de datos/spec propio); su comportamiento vive en el self-test, no en el repo — mismo patrón que `gemba-stop`.
- Cierra #52; complementa #50 (fallo-abierto) y #51 (gates dormidos). El complemento de **conciencia** (que el orquestador se ponga el asiento) es #53, aparte.
