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

Verificado por `tools/probar-instalador.ps1` (32/32: siembra + sello + tres vías + aviso + `.local` + canal) y `tools/probar-version.ps1` (SSOT). Entregado desde `v0.11.0-beta`.
