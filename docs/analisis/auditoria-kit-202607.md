---
tipo: analisis
estado: en_revision
---
# Auditoría 3 — La bajada a los hijos: ¿el mapeo queda garantizado? (2026-07-16)

> **Qué es esto:** verificación independiente de que la instalación y la actualización hacia repos hijos quedan correctas y completas en `v1.18.0` — pedida por el cliente un día después de que la cosecha #7 (ADR 0037) atacara exactamente este frente. Subagente `auditor` con acceso a git (las 2 piezas en cuarentena AV se leyeron con `git show`). Sobre `affb44e`.

## Veredicto directo

- **Hijo fresco sembrado con `v1.18.0`: APTO.** Los 5 archivos que el `arranca` inyecta con `@` quedan sembrados (stubs comunes) o son bajo demanda (`plan-actual.md`); los agentes-asiento viajan (`.claude/agents/` en el manifiesto); el casting tiene casa (`product/infra.md` → `## El casting`); `kanban/lazo.md` y `roles.md` viajan completos. **Cero `@` rotos.**
- **Hijo `1.16.1` migrado con `-Actualizar`: APTO con advertencia honesta.** Stubs faltantes se siembran con `[MIGRA]` (no-clobber estricto); con sello pre-1.17 (sin campo `producto`) el stub condicionado al arquetipo NO se siembra pero **se avisa explícitamente** en vez de adivinar — comportamiento correcto.
- **Paridad `instalar.ps1` ↔ `sembrar-manual.ps1`: confirmada pieza por pieza** (mismo manifiesto completo, no-clobber, tres vías, sello con version + hashes + producto/gobernanza + excluir, `core.hooksPath`). El fallback AV es un instalador de primera clase, no un recorte.
- Los **26 orígenes del manifiesto existen** en el árbol; el atlas NO se referencia desde nada que viaje al hijo (no le miente); ambas leyes-plantilla tienen el área `ritual` con `.claude/agents/*`.

**La cosecha #7 quedó completa.** Lo que resta son huecos de *cobertura de prueba*, no de mecanismo.

## Hallazgos (todos BAJA)

1. **`probar-instalador.ps1` no verifica que `sello.producto` quede escrito en siembra fresca.** El código lo escribe (sección 6c); el smoke solo lo verifica en migración (líneas ~179-184). Si la lógica de sellado se rompiera, el smoke pasaría verde y el primer `-Actualizar` posterior no podría decidir los stubs de arquetipo.
2. **`probar-sembrar.ps1` tiene la misma brecha** en el fallback AV — y es el instalador que corre en las máquinas endurecidas, donde más duele.
3. **El bloque `gobernanza` es código sin manifiesto ni test:** `instalar.ps1` y `sembrar-manual.ps1` evalúan `$manif.stubs_arquetipo.gobernanza`, que no existe (los 2 arquetipos declaran `gobernanza: false`). Hoy es inerte; si alguien activa `gobernanza: true` sin añadir el stub, el bloque falla EN SILENCIO (ni siembra ni error). Deuda reconocida en ADR 0037 (regla 2-3), pero el modo de fallo silencioso no está anotado.
4. **Lo vivo de #82 sigue vivo, tal como se re-alcanzó:** `probar-agentes.ps1` valida `model:` contra lista cerrada pero no valida los nombres de `tools:` (un typo `Gerp` pasa).

## Recomendación

Los 4 caben en una sola rebanada de tests (~4 `Check` nuevos + validación de `tools:` contra lista cerrada) para la próxima cosecha. Ninguno bloquea la bajada `v1.12.1`–`v1.18.0` a los labs pendiente en el HANDOFF — esta auditoría más bien la desbloquea con evidencia independiente.

## Limitaciones

- Verificación estática (lectura de scripts y manifiesto); no se sembró un hijo real en esta corrida — el demo vivo sigue siendo el pendiente del cliente (`jidoka-hijo-practica`, HANDOFF).
- Corte: 2026-07-16, `v1.18.0` (`affb44e`).
