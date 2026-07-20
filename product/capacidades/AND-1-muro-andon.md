---
tipo: capacidad
estado: vigente
clave: AND-1
modulo: MOD-andon
dominio: Metodo
---
# Capacidad — El muro Andon

Del módulo [[MOD-andon]], dominio [[Metodo]]. Gates deterministas que atrapan el error en la fuente, fuera del LLM: la ley única (`tools/blast-radius.json`), el verificador que falla cerrado, los hooks de cierre, el auditor del grafo y el gate granular de ligas código↔capacidad (`tools/ligas.json` + `estado-ligas.ps1` — la ley que el cliente autora desde la extensión de VS Code, ADR 0044). El muro real es el required check server-side.

## Criterios de aceptación

- Dado que agrego un ADR sin listarlo en su índice, cuando corro `tools/verificar.ps1`, entonces bloquea el push (exit 1).
- Dado que el gate no puede calcular el rango, cuando corre, entonces falla cerrado (exit 2) — no aprueba a ciegas.
- Dado que toco un área con doc dueño, cuando cierro, entonces el hook `andon-stop` frena hasta sincronizar el doc.
- Dado que dejo evidencia de QA en `qa_runs/` **sin commitearla**, cuando cierro un cambio visual, entonces `gemba-stop` bloquea: la evidencia debe estar **rastreada por git** (`git add -f`), no solo en disco (cierra un Goodhart; ADR 0013, desde `v0.12.0-beta`).
- Dado que cambio una spec/datos de un área `rol: validador` **sin** evidencia de una corrida de motor determinista en `qa_runs/validador-*`, cuando cierro, entonces `validador-stop` bloquea: un *"validado al centavo"* en prosa no vale, el motor recalcula contra golden-masters (evidencia-no-palabra variante medición; ADR 0028, desde `v1.11.0`).
- Dado que un Stop hook no está encendido por la ley (ninguna área lo declara), cuando corro `tools/rutear.ps1`, entonces lo reporta **DORMIDO con la razón** —y `/jidoka:arranca` y `estado-motor` lo muestran— para que la dormancia sea visible, no un silencio (ADR 0029, desde `v1.12.0`).
- Dado que un cambio **borra** una pieza del motor (`tools/*.ps1`, `tools/blast-radius.json`) sin un ADR nuevo en el mismo cambio, cuando corro `tools/verificar.ps1`, entonces el salvavidas `no-borres-el-motor` **bloquea** (exit 1): una decisión se documenta, un accidente no — restaurar es seguro, el archivo sigue en git (ADR 0032, desde `v1.15.0`).
- Dado que el archivo de un `probar-*` del preflight **no existe en disco** (cuarentena de AV), cuando corro `tools/publicar.ps1`, entonces el preflight **se planta** (falla cerrado) en vez de imprimir `[OK]` de un test que jamás corrió; la evidencia server-side vive en el CI (ADR 0032, desde `v1.15.0`).
- Dado que dejo un archivo suelto (un `veredicto.txt`) rastreado y fresco en `qa_runs/` que **no** es el `LOG.md` de la corrida, cuando cierro un cambio visual o de spec, entonces `gemba-stop`/`validador-stop` **bloquean**: el listón de evidencia exige el `LOG.md` de la corrida (`qa_runs/<corrida>/LOG.md`, plantilla `qa-log.md`), no cualquier archivo — miden presencia+frescura+tracking del LOG, su contenido lo juzga el humano (ADR 0030, desde `v1.12.0`).

- Dado que existe una liga `fuerza:bloquea` en `tools/ligas.json` (dirección código-a-capacidad), cuando cambio ese código **sin** tocar su capacidad y hago push, entonces `estado-ligas.ps1 -Estricto` (pre-push + CI leyendo ledger y evaluador **desde la base**) bloquea **nombrando la capacidad exacta** — no "revisa las 89"; una liga que apunta a código o capacidad inexistente **avisa que está ROTA** y queda excluida, nunca bloquea (ADR 0044, desde `v1.25.0`).

Verificado por `tools/probar-gate.ps1` (self-test con caso que DEBE bloquear, incl. el **fixture del quickstart del README** por git desde `v0.13.0-beta`), `tools/probar-hooks.ps1` y `tools/probar-ligas.ps1` (co-ocurrencia, dirección, rotas, contrato JS↔PS). Entregado desde `v0.2.0-beta`.
