---
tipo: capacidad
estado: vigente
clave: AND-1
modulo: MOD-andon
dominio: Metodo
---
# Capacidad — El muro Andon

Del módulo [[MOD-andon]], dominio [[Metodo]]. Gates deterministas que atrapan el error en la fuente, fuera del LLM: la ley única (`tools/blast-radius.json`), el verificador que falla cerrado, los hooks de cierre y el auditor del grafo. El muro real es el required check server-side.

## Criterios de aceptación

- Dado que agrego un ADR sin listarlo en su índice, cuando corro `tools/verificar.ps1`, entonces bloquea el push (exit 1).
- Dado que el gate no puede calcular el rango, cuando corre, entonces falla cerrado (exit 2) — no aprueba a ciegas.
- Dado que toco un área con doc dueño, cuando cierro, entonces el hook `andon-stop` frena hasta sincronizar el doc.
- Dado que dejo evidencia de QA en `qa_runs/` **sin commitearla**, cuando cierro un cambio visual, entonces `gemba-stop` bloquea: la evidencia debe estar **rastreada por git** (`git add -f`), no solo en disco (cierra un Goodhart; ADR 0013, desde `v0.12.0-beta`).
- Dado que cambio una spec/datos de un área `rol: validador` **sin** evidencia de una corrida de motor determinista en `qa_runs/validador-*`, cuando cierro, entonces `validador-stop` bloquea: un *"validado al centavo"* en prosa no vale, el motor recalcula contra golden-masters (evidencia-no-palabra variante medición; ADR 0028, desde `v1.11.0`).
- Dado que un Stop hook no está encendido por la ley (ninguna área lo declara), cuando corro `tools/rutear.ps1`, entonces lo reporta **DORMIDO con la razón** —y `/jidoka:arranca` y `estado-motor` lo muestran— para que la dormancia sea visible, no un silencio (ADR 0029, desde `v1.12.0`).
- Dado que dejo un archivo suelto (un `veredicto.txt`) rastreado y fresco en `qa_runs/` que **no** es el `LOG.md` de la corrida, cuando cierro un cambio visual o de spec, entonces `gemba-stop`/`validador-stop` **bloquean**: el listón de evidencia exige el `LOG.md` de la corrida (`qa_runs/<corrida>/LOG.md`, plantilla `qa-log.md`), no cualquier archivo — miden presencia+frescura+tracking del LOG, su contenido lo juzga el humano (ADR 0030, desde `v1.12.0`).

Verificado por `tools/probar-gate.ps1` (self-test con caso que DEBE bloquear, incl. el **fixture del quickstart del README** por git desde `v0.13.0-beta`) y `tools/probar-hooks.ps1`. Entregado desde `v0.2.0-beta`.
