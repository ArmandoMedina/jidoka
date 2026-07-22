---
tipo: capacidad
estado: vigente
clave: KIT-2
modulo: MOD-instalador
dominio: Metodo
---
# Capacidad — Gobierno documental por estructura (el régimen estatuto)

Del módulo [[MOD-instalador]], dominio [[Metodo]]. El hermano estructural de [[KIT-1-lazo-sincronizacion]]: aquel gobierna el **motor** por **hash** (byte a byte); este gobierna los documentos **instancia-de-template** por **secciones**. Gobierno por estatuto: el hijo llena el contenido libre, pero si **altera la estructura gobernada** de un doc que el ritual inyecta con `@`, el método declara *garantía nula* — no puede asegurar que su lógica inyectada funcione. Respeta la regla dura de KIT-1: la instancia nunca se sobrescribe; el detector **declara**, no muta. Piezas: el ledger sembrado (`tools/docs-gobernados.json`: capa-1/2/3 + secciones requeridas congeladas), el detector (`tools/estado-docs.ps1`, aviso en `/jidoka:arranca`; `-Estricto` = muro opt-in en CI), y el template real de `CONTRIBUTING`. Ver [ADR 0042](../../docs/decisions/0042-gobierno-documental-por-estructura.md).

## Criterios de aceptación

- Dado que un documento capa-2 conserva las secciones requeridas de su molde, cuando corro `tools/estado-docs.ps1`, entonces lo reporta CONFORME.
- Dado que el contenido del documento difiere del molde pero las secciones requeridas están, cuando corro el detector, entonces lo reporta CONFORME (no confunde contenido con estructura — donde el hash gritaría en falso).
- Dado que el documento tiene secciones aditivas (extra), cuando corro el detector, entonces lo reporta CONFORME (aditivas permitidas).
- Dado que a un documento capa-2 le falta una sección requerida, cuando corro el detector, entonces lo reporta DESVIADO, nombra la sección faltante, y declara "garantía nula".
- Dado que un documento marcado `estricto:true` en el ledger pierde una sección requerida, cuando corro `tools/estado-docs.ps1 -Estricto`, entonces sale con exit 1 (el muro opt-in); sin `-Estricto`, sale exit 0 (aviso).
- Dado que ningún documento está marcado `estricto:true`, cuando corro `-Estricto`, entonces sale exit 0 — el muro nace apagado y no bloquea de más.
- Dado que abro una sesión con `/jidoka:arranca` y un documento inyectado se desvió de su estructura, cuando corre el preflight, entonces veo el aviso de conformidad nombrando la sección faltante, sin código ni terminal.
- Dado que un documento es capa-3 (`CODE_OF_CONDUCT`, `LICENSE`), cuando reviso el ledger y la ley, entonces está declarado libre y fuera del blast-radius (no es fuente gobernada).
- Dado que siembro un hijo nuevo, cuando termina, entonces su `CONTRIBUTING.md` trae las secciones requeridas del molde y el detector lo reporta CONFORME recién sembrado.

Verificado por `tools/probar-docs.ps1` (comportamiento del detector con fixtures ROJO→VERDE: conforme, faltante, aditiva, fold de acentos, muro opt-in; e integridad del ledger real: cada molde existe, cada requerida es prefijo de una sección del molde, los 3 docs inyectados están gobernados). El detector corre en el smoke local y en el required-check de CI (`andon.yml`). Entregado en el sprint "Documentos gobernados" (ADR 0042).
