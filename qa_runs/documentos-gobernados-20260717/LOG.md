# LOG — Sprint "Documentos gobernados" (KIT-2, ADR 0042)

- **Fecha:** 2026-07-17
- **Rama:** `sprint/documentos-gobernados-20260717` (sobre `main` = 904c05e + el preflight 45aa926)
- **Qué se verifica:** el gobierno documental por estructura (capa-2) — detector, ledger, template, muro opt-in.

## Método reproducible

1. Corre `probar-docs.ps1` sobre la nave nodriza (jidoka) verificando conformidad de 3 docs estructurales.
2. Crea fixtures hijo-1 (conforme) e hijo-2 (desviado, modo estricto) para probar el detector.
3. Corre la copia SOLO-LECTURA del caso enti para diagnóstico real sin modificar.
4. En Gemba: corre `/jidoka:arranca` sobre un hijo-fixture con CONTRIBUTING destripado y ve el aviso `[DESVIADO]`.

## Resultados (evidencia-no-palabra)

| Test | Resultado |
|---|---|
| `probar-docs` (nuevo) | **23/23** — comportamiento del detector + integridad del ledger |
| `probar-version` | **1.22.0** (version.txt == CHANGELOG == package.json) |
| `probar-preflight` | 7/7 (los @ de instancia siguen guardados; la línea nueva no rompe el invariante) |
| `probar-instalador` | **67/67** (el manifiesto nuevo siembra bien: stub estructurado + 3 piezas motor) |
| `probar-sembrar` | **38/38** (el fallback AV-seguro siembra el ledger/detector/test) |
| `probar-publicar` | 7/7 (probar-docs entró al preflight — invariante) |
| `probar-agentes` / `probar-disparos` / `probar-gate` / `probar-hooks` / `probar-auditor` | 32 / 4 / 14 / 32 / 7 |
| `auditar` (grafo product/) | íntegro (KIT-2 pasa frontmatter + wikilinks + Gherkin) |
| `verificar -Base main` | **exit 0** — 2 avisos no bloqueantes (ritual/atlas), aceptados con razón (ver cierre) |

## El detector en la nave nodriza (jidoka) — CONFORME

```
== Conformidad estructural de documentos (capa-2) ==
  [CONFORME]  CONTRIBUTING.md
  [CONFORME]  product/PRODUCT_BRIEF.md
  [CONFORME]  product/infra.md
  Resumen: 3 conforme(s) | 0 desviado(s).
```
(Nota de diseño cazada en vivo: el primer ledger requería "El casting" en infra; la nave nodriza lo omite a propósito —roles neutrales, decisión del cliente 2026-07-14— y el arranca tiene fallback. Se quitó de las requeridas: su ausencia degrada con gracia, no es garantía nula.)

## DEMO A — el money shot: un `CONTRIBUTING` destripado (aviso, exit 0)

Hijo-fixture con brief/infra conformes y un `CONTRIBUTING.md` reducido a "# Contribuir\n\nEste repo usa PRs. Ya.":
```
  [DESVIADO]  CONTRIBUTING.md -- falta(n): El flujo
               garantia nula: la logica que el ritual inyecta con @ no se garantiza sobre este doc.
  [CONFORME]  product/PRODUCT_BRIEF.md
  [CONFORME]  product/infra.md
```
Aviso (exit 0): el ritual sigue, pero grita que el `@CONTRIBUTING` inyectará basura. **Esto es lo que el cliente ve al correr `/jidoka:arranca`.**

## DEMO B — el cliente enciende el muro (opt-in, exit 1)

Mismo fixture, `estricto:true` en el CONTRIBUTING del ledger, corriendo `estado-docs -Estricto` (lo que hace `andon.yml`):
```
  [DESVIADO*] CONTRIBUTING.md -- falta(n): El flujo
  Resumen: 2 conforme(s) | 1 desviado(s) (1 estricto).
exit=1   <- el muro opt-in bloquea el push en CI
```
El "no se pueda" del cliente: **palanca suya** (un flag en su ledger), no muro impuesto.

## Caso real — enti (`entisoft-rescate`, motor 1.21.1, SOLO-LECTURA)

Copia read-only de los 3 docs de enti a un fixture (enti no se tocó — lo trabaja otro agente):
```
  [DESVIADO]  CONTRIBUTING.md -- falta(n): El flujo
  [CONFORME]  product/PRODUCT_BRIEF.md
  [CONFORME]  product/infra.md
```
Confirma el diagnóstico con máquina: enti renumeró CONTRIBUTING ("## 2. El flujo (el lazo)" ≠ "El flujo") → alteró la estructura → garantía nula. Su brief/infra conformaron al molde. El modelo SAP, exacto.

## El Gemba que corre el cliente (owner: cliente)

Sin código ni terminal: sembrar un hijo-fixture desechable, destripar su `CONTRIBUTING.md`, y correr **`/jidoka:arranca`** → ver el aviso `[DESVIADO] CONTRIBUTING.md -- falta(n): El flujo` en la apertura de la sesión. En un doc conforme → `[CONFORME]`. (enti NO se usa para el Gemba: lo trabaja otro agente.)

## Veredicto

El detector de conformidad documental funciona: detecta desviaciones por secciones faltantes y es configurable opt-in (muro estricto). La nave nodriza y enti casan con su diagnóstico automático.
