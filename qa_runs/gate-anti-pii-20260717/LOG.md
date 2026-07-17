# LOG — Gate anti-PII de entorno (rama gate-anti-pii-20260717)

- **Fecha:** 2026-07-17
- **Máquina:** Windows 11 / PowerShell 5.1 (el mismo intérprete del CI)
- **Qué se verifica:** el gate `tools/anti-pii.ps1` muerde (ROJO→VERDE), no da falsos positivos en el repo real, y la suite completa sigue verde con las piezas nuevas.

## Self-test del gate — `probar-anti-pii.ps1` (11/11)

```
[PASA]  email con dominio real -> BLOQUEA
[PASA]  ruta C:\Users\<nombre real> -> BLOQUEA
[PASA]  ruta /home/<nombre real> -> BLOQUEA
[PASA]  handle GitHub (@usuario sin dominio) -> PASA
[PASA]  ruta C:\Users\x (placeholder) -> PASA
[PASA]  ruta C:\ruta\a\tu-repo (placeholder de guia) -> PASA
[PASA]  email de dominio sintetico (.local) -> PASA
[PASA]  email noreply de GitHub -> PASA
[PASA]  denylist local: cadena reservada -> BLOQUEA
[PASA]  sin denylist presente: estructural corre y PASA si limpio
[PASA]  sin poder listar el arbol (no-git) -> FALLA CERRADO (exit 2)
== Gate anti-PII sano: los 11 casos se comportan como se espera. ==
```

## Scan del repo real — `anti-pii.ps1` (cero falsos positivos)

```
[OK] sin fugas de dato de entorno en 206 archivo(s) rastreado(s).  (exit 0)
```

Bug de detector cazado y curado en esta corrida: el regex de rutas Windows tragaba
la puntuación de cierre (backtick) del segmento — el propio CHANGELOG que cita
`C:\Users\x` como ejemplo se auto-bloqueaba. Se acotó la captura a caracteres de
palabra (`[A-Za-z0-9._-]+`). Re-corrido: limpio.

## Suite completa (preflight) — 8/8 verde

```
probar-agentes     exit 0
probar-anti-pii    exit 0
probar-auditor     exit 0
probar-disparos    exit 0   (16 disparos: el nuevo sin-pii-en-el-repo cableado)
probar-gate        exit 0
probar-hooks       exit 0
probar-preflight   exit 0
probar-version     exit 0   (SSOT 1.22.0: version.txt = CHANGELOG = package.json)
verificar          exit 0   (3 avisos no-bloqueantes, revisados)
auditar            exit 0
```

## Avisos de `verificar` revisados (no bloquean)

- `[disparos] -> doctrina`: **atendido** — respaldo del disparo agregado en `doctrina/00-tesis.md`.
- `[atlas] -> docs/atlas/*`: no aplica — no cambió el flujo de ningún comando (solo bump de conteo en `probar-disparos`).
- `[barreras] -> product grafo`: no aplica — refuerza la capacidad existente [[AND-1-muro-andon]] (el muro), no estrena capacidad.

## Pendiente de verificación server-side

El muro real es el check `andon` en el PR. Este LOG es la corrida local; el CI vuelve a
correr la suite + el scan anti-PII sobre el árbol del PR antes del merge.
