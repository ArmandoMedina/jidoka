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

Verificado por `tools/probar-gate.ps1` (self-test con caso que DEBE bloquear) y `tools/probar-hooks.ps1`. Entregado desde `v0.2.0-beta`.
