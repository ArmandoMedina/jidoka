---
tipo: capacidad
estado: vigente
clave: KIT-1
modulo: MOD-instalador
dominio: Metodo
---
# Capacidad — El lazo de sincronización labs↔Jidoka

Del módulo [[MOD-instalador]], dominio [[Metodo]]. *La lección sube, la máquina baja.* Un repo hijo baja correcciones del motor sin que las versiones diverjan: la **mecánica** converge idéntica, la **estética/instancia** nunca se sobrescribe, y la **divergencia** se detecta y se preserva. Piezas: el sello de versión sembrado (`tools/jidoka-motor.json` + SSOT `tools/version.txt`), el modo `-Actualizar` de tres vías, el aviso de divergencia (`tools/estado-motor.ps1`) y el canal de subida (`tools/reportar-leccion.ps1`). Ver ADR 0012.

## Criterios de aceptación

- Dado que instalo el método en un hijo, cuando termina, entonces queda sembrado `tools/jidoka-motor.json` con la versión de Jidoka y el hash de cada pieza de motor.
- Dado que el hijo NO tocó una pieza de mecánica y Jidoka avanzó, cuando corro `instalar.ps1 -Actualizar`, entonces esa pieza se actualiza a la versión de Jidoka.
- Dado que el hijo customizó una pieza de mecánica, cuando corro `-Actualizar`, entonces NO se pisa: se deja `<archivo>.jidoka-nuevo` y se reporta la divergencia.
- Dado que toco un archivo de instancia (ley, HANDOFF, `product/`), cuando corro `-Actualizar`, entonces queda intacto.
- Dado que el sello del hijo difiere de la versión de Jidoka, cuando corro `estado-motor.ps1 -Jidoka <ruta>`, entonces avisa que está atrás (exit 0 — aviso, no muro).
- Dado que `instalar.ps1` no es legible/ejecutable (p.ej. cuarentena de AV en Windows endurecido), cuando corro `tools/sembrar-manual.ps1 -Destino <hijo> -Jidoka <ruta>`, entonces la **instancia completa** queda sembrada **igual que con `instalar.ps1`** (mecánica + ley del arquetipo + stubs de instancia + sello) — un hijo en máquina endurecida no queda a medias, y la ruta de actualización no cuelga de un solo artefacto (ADR 0027 + enmienda 2026-07-15: el trigger es densidad de comportamiento, no el nombre).
- Dado que `instalar.ps1` no es legible y el hijo está atrás, cuando corro `estado-motor.ps1`, entonces **apunta al fallback `sembrar-manual.ps1`** en vez de recomendar un script que no va a correr.

Verificado por `tools/probar-instalador.ps1` (siembra + sello + tres vías + aviso + `.local` + canal + brownfield + exclusión), `tools/probar-sembrar.ps1` (26: el fallback deja el mismo estado que el instalador —ahora incluida la instancia completa— + degradación con gracia) y `tools/probar-version.ps1` (SSOT). Entregado desde `v0.11.0-beta`; camino anti-AV desde `v1.10.0`, completo (instancia entera) desde la enmienda del ADR 0027 (2026-07-15).
