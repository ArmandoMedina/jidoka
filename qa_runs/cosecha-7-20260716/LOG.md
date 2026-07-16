# LOG de la corrida — cosecha-7-20260716

> El artefacto que los gates de evidencia exigen. Datos 100 % sintéticos (fixtures temporales + hijo de práctica desechable).

- **Corrida:** cosecha-7-20260716
- **Fecha:** 2026-07-16
- **Rama:** `cosecha-7-la-bajada-que-dolio`
- **Asiento:** validador (subagente `auditor` corrió la suite; orquestador corrió el demo de migración y el ROJO→VERDE, acusado en sesión)

## Método reproducible

1. **Suite completa del motor** (9 tests): `powershell -NoProfile -ExecutionPolicy Bypass -File ./tools/probar-<X>.ps1` para version, gate, hooks, auditor, disparos, instalador, sembrar, publicar, agentes; más `verificar.ps1` y `auditar.ps1`. Windows 11 / PS 5.1, esta máquina.
2. **Demo de migración end-to-end**: worktree de `main` (motor v1.16.1) → `instalar.ps1 -Destino C:\Repositorios\jidoka-hijo-practica -Arquetipo docs-as-code -Yes` (hijo "pre-1.17" real: sin brief/infra/CONTRIBUTING/agentes, sello sin `producto`) → desde la rama de la cosecha, `instalar.ps1 -Destino <hijo> -Actualizar`.
3. **ROJO→VERDE del #88**: mismo escenario (`-Cambiados 'docs/decisions/0001-viejo.md' -BorradosInyectados 'tools/verificar.ps1'`, ley mínima sintética) contra el `verificar.ps1` de `main` (juez viejo) y el de la rama (juez curado).
4. **Repro del #91 (doble resumen)**: siembra fresca + `-Actualizar` con salida completa capturada; conteo de apariciones del encabezado y del resumen.

## Resultados

### Suite del motor (todo verde tras el bump del SSOT)

| # | Test | Casos | Exit |
|---|---|---|---|
| 1 | probar-version | 4/4 (`1.18.0` consistente en version.txt / CHANGELOG / package.json) | 0 |
| 2 | probar-gate | 14/14 (2 negativos nuevos del #88) | 0 |
| 3 | probar-hooks | 29/29 | 0 |
| 4 | probar-auditor | 7/7 | 0 |
| 5 | probar-disparos | 4/4 | 0 |
| 6 | probar-instalador | 67/67 (5 de migración + 6 de stubs/agentes + newline del sello) | 0 |
| 7 | probar-sembrar | 36/36 (agentes+lint, stubs comunes, guard #89) | 0 |
| 8 | probar-publicar | 7/7 | 0 |
| 9 | probar-agentes | 28/28 | 0 |
| — | verificar.ps1 | `[OK] blast-radius al dia` → `Todo limpio` | 0 |
| — | auditar.ps1 | `Grafo de docs integro` | 0 |

> Nota honesta: la primera corrida de `probar-version` dio ROJO (3/4) porque la sección nueva del CHANGELOG decía `[Sin publicar]` con el SSOT en `1.16.1` — la invariante del test es correcta y mordió como debe; se curó titulando la sección y subiendo el SSOT + `package.json` en el mismo PR (el release deriva del SSOT, ADR 0020).
>
> Reconciliación con el atlas: `v1.17.0` (atlas BPMN, ADRs 0035/0036) se liberó en `main` mientras esta cosecha se construía — la cosecha se renumeró a **`v1.18.0` / ADR 0037** y la suite completa se re-corrió sobre el árbol mergeado (esta tabla refleja la corrida final).

### Demo de migración (#86) — hijo real pre-1.17 → cosecha #7

Estado PRE (sembrado con `main` v1.16.1): `product/PRODUCT_BRIEF.md` **False** · `product/infra.md` **False** · `CONTRIBUTING.md` **False** · `.claude/agents` **False** · sello sin `producto` — exactamente el estado que rompió al caso 1.

Salida real de `-Actualizar` (extracto, íntegra en `demo-actualizar.txt` junto a este LOG):

```
  [NUEVO]  tools/probar-agentes.ps1
  [NUEVO]  .claude/agents/arquitecto.md
  [NUEVO]  .claude/agents/auditor.md
  [NUEVO]  .claude/agents/explorador.md
  [NUEVO]  .claude/agents/mecanico.md
  [MIGRA] product/PRODUCT_BRIEF.md sembrado: el motor nuevo lo asume y el hijo no lo tenia
  [MIGRA] product/infra.md sembrado: el motor nuevo lo asume y el hijo no lo tenia
  [MIGRA] CONTRIBUTING.md sembrado: el motor nuevo lo asume y el hijo no lo tenia
  [MIGRA] el sello no registra el arquetipo (pre-1.17): los stubs por-arquetipo no se auto-siembran; ...

== Motor: 74 al dia | 8 actualizado(s) | 5 nuevo(s) | 0 divergen | 3 stub(s) migrado(s) ==
```

Estado POST: los 3 stubs existen, los 4 agentes existen, instancia previa (HANDOFF, ley) intacta. El hijo queda en `C:\Repositorios\jidoka-hijo-practica` (desechable, commiteado) para el demo del cliente.

### ROJO→VERDE del #88 (el hueco del salvavidas)

| Juez | Escenario: borra `tools/verificar.ps1` + ADR viejo solo EDITADO | Exit |
|---|---|---|
| `main` v1.16.1 (viejo) | `[OK] ... con un ADR nuevo en el mismo cambio: decision documentada` ← **el hueco: aprueba** | 0 |
| cosecha #7 (curado) | `[BLOQUEA] [no-borres-el-motor] ... sin un ADR nuevo en el mismo cambio` | 1 |

### Repro del #91 (doble resumen)

Corrida real `-Actualizar` con todos los streams capturados: `== Actualizar motor:` ×**1**, `== Motor:` (resumen) ×**1**. **No reproduce** — consistente con la hipótesis del propio issue (artefacto de captura del stream); el código no se tocó (evidencia-no-palabra). El newline del sello sí era real y se curó (check nuevo en probar-instalador).

## Artefactos

- `demo-actualizar.txt` — salida íntegra de la corrida de migración sobre el hijo de práctica.

## Veredicto

Suite 9/9 verde (196 casos) + gate y auditor limpios; migración end-to-end demostrada sobre un hijo pre-1.17 real; el hueco del #88 cerrado con ROJO→VERDE contra el juez viejo. El "¿se ve bien?" final lo responde el cliente: `/jidoka:arranca` en el hijo de práctica + este LOG.
