---
tipo: decision
---
# ADR 0026 — Cosecha brownfield: el instalador no era consciente de la instancia ni del arquetipo del hijo (cinco arreglos)

- **Estado:** aceptado
- **Fecha:** 2026-07-12

## Contexto

Al bajar el metodo a **repos reales** —SGI (por el experimento del [ADR 0025](0025-git-idioma-nativo.md)) y
**TequiOBD** (adopcion brownfield: un repo TS que ya traia un slice viejo y hecho a mano del linaje
`poka-yoke-ia`)— el propio metodo, corriendo sus gates y su instalador contra artefactos reales, hizo **aparecer
cinco defectos** que en prosa no se veian. Dogfooding: el defecto no se declara, se hace aparecer. Los cinco
comparten una **raiz comun**: el instalador (`instalar.ps1` fresco + el wrapper npx) **no era consciente de lo que
el hijo ya traia** —su instancia customizada y su arquetipo— y trataba todo como si el destino estuviera vacio.

## Decisión

Se agrupan **cinco arreglos** (precedente de cosecha agrupada: ADR 0013, 0015), todos hacia la misma raiz —
volver el instalador consciente de instancia y de arquetipo:

1. **[#36] El sello del install fresco clasifica pristina-vs-customizada** (como `-Sellar`, ADR 0019). Antes
   hasheaba lo que quedara en el destino; en un hijo brownfield con piezas de motor customizadas (saltadas por
   no-clobber) registraba la version **customizada** como semilla → el proximo `-Actualizar` la **pisaba**
   (perdida de datos). Ahora compara destino vs origen de Jidoka: pristina → registra; customizada → **omite**
   (se preserva como DIVERGE). Se extrajo un helper compartido (`Get-SelloClasificado`) usado por el install y por
   `-Sellar` — una sola logica de clasificacion.
2. **[#38] El arquetipo declara `excluir_motor`.** `code-first` excluye `tools/probar-gate.ps1` y
   `.github/workflows/andon.yml` (que prueban el contrato canonico de `verificar`, el cual code-first customiza).
   El install ya no los siembra y los escribe en el `excluir` del sello. Mata la friccion recurrente que **SGI y
   TequiOBD** resolvieron a mano por separado.
3. **[#37] Aviso de cableado inerte.** Cuando `.claude/settings.json` ya existe (preservado por no-clobber) y no
   cablea los hooks del motor actual (`review/andon/gemba-stop`) o su `PreToolUse` no cubre `Bash`, el install
   ahora **avisa** en vez de callar. Antes: los hooks recien sembrados quedaban inertes sin que nadie lo dijera.
4. **[#35] La guia aclara el `.jidoka-nuevo`.** Al **conservar** la version local, el sidecar es andamiaje: se
   **borra** antes de commitear; el diff del PR lleva la decision aplicada, no el sidecar. (Tres agentes frescos
   se habian partido 2-1 por la ambiguedad.)
5. **[#34] El wrapper npx no fuerza `-ExecutionPolicy Bypass`.** Los clasificadores de seguridad de agentes IA
   —operario primario del metodo— lo bloquean. Ahora pre-chequea la politica y solo agrega `Bypass` si de verdad
   bloquearia (`Restricted`/`AllSigned`); en la mayoria de las maquinas de dev corre sin el flag.

## Por qué agrupados

Comparten raiz (**instance/archetype-awareness**) y salieron de la **misma ventana** de bajar-a-repos-reales.
Los mas graves (#36, #37, #38) los cazo **TequiOBD**: el brownfield es el que mas caza porque el hijo trae
instancia real que **colisiona** con la siembra — justo lo que un repo vacio nunca revela.

## El camino que NO se toma (y por qué tienta)

**Un install "inteligente" que auto-reconcilie todo** (merge automatico de `settings.json`, adopcion automatica de
customizaciones, etc.). Tienta porque dejaria el hijo verde sin intervencion. Se descarta: **no-clobber + avisar +
clasificar** es mas seguro que auto-merge, que arriesga pisar la instancia genuina del hijo. La reconciliacion fina
(que customizacion se conserva vs se adopta) es **juicio humano** (decision-queda-en-humano), no algo que el
instalador deba adivinar. El instalador se vuelve consciente para **avisar y preservar**, no para decidir.

## Consecuencias

- El instalador es ahora consciente de **instancia** (clasifica pristina-vs-customizada en el install fresco) y de
  **arquetipo** (`excluir_motor`). Futuras adopciones brownfield no pierden customizaciones ni dejan maquinaria
  inerte en silencio.
- Cobertura de self-test nueva en `probar-instalador.ps1` (caso brownfield: la customizada NO entra a la semilla;
  caso code-first: `probar-gate`/`andon.yml` no se siembran y quedan en `excluir`).
- Los issues #34–#38 quedan cerrados. Los arreglos son **mecanica**: bajaran a los labs (SGI, TF, TequiOBD) por
  `-Actualizar`. Version `v1.9.0`.
