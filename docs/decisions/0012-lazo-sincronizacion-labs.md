# ADR 0012 — El lazo de sincronización labs↔Jidoka: la lección sube, la máquina baja

- **Estado:** aceptado
- **Fecha:** 2026-07-11

## Contexto

Jidoka siembra su maquinaria en repos hijos (el instalador, ADR [0008](0008-el-instalador.md)/[0009](0009-arquetipos-ejecutables.md)).
Sin un canal de sincronización, las versiones **divergen**: el hijo acumula parches locales, Jidoka
avanza, y nadie sabe quién está atrás de quién. La cosecha de SGI (ADR [0011](0011-homologacion-cosecha-sgi.md))
demostró que la homologación es bidireccional —la lección sube aunque nazca abajo— pero se hizo **a mano**
(auditoría "full join" de dos agentes + diff). Faltaba volverlo máquina.

El hallazgo que reencuadró el diseño: **un hijo real no es un hijo limpio.** SGI vino del ancestro
`project-starter` y convergió a mano; su `verificar.ps1` corre ruff+pytest (mecánica personalizada por
dominio), sus comandos no están namespaced y sus skills tienen nombre de persona (estética). Un
`-Actualizar` que sobrescriba el motor a ciegas lo rompería. La regla del cliente fijó el norte:
*la mecánica converge idéntica; la estética/instancia nunca se sobrescribe; la divergencia se detecta
y se preserva, no se pisa.*

## Decisión

Se construye el lazo en cuatro piezas (*la lección sube, la máquina baja*):

1. **Sello de versión sembrado.** El instalador escribe en cada hijo `tools/jidoka-motor.json`
   = `{ version, sembrado_hashes: { <ruta>: <SHA256> } }`: de qué versión de Jidoka viene su motor y el
   hash de cada pieza. La fuente única de la versión es `tools/version.txt` (SSOT), atada al tope del
   `CHANGELOG` por el self-test `tools/probar-version.ps1` para que **el sello no mienta**.

2. **Modo `-Actualizar` con conciencia de TRES VÍAS** (estilo `dpkg conffiles`). Re-siembra SOLO las
   piezas `clase: mecanica` del manifiesto. Por archivo: ausente→agrega; `hijo == Jidoka`→al día;
   `hijo == hash sembrado` (no lo tocó) → **actualiza**; `hijo != hash sembrado` (lo customizó) →
   **DIVERGENCIA**: no pisa, deja `<archivo>.jidoka-nuevo` y lo reporta. La **instancia** (ley, `product/`,
   HANDOFF, ADRs) nunca se toca: solo se itera `motor`. Corre en rama → PR → el humano ve el diff. El
   sello se re-sella al hash que Jidoka **envía**, así la divergencia persiste hasta reconciliar.

3. **Aviso de divergencia** (`tools/estado-motor.ps1`, sembrado). Compara el sello del hijo contra el
   `version.txt` de un Jidoka alcanzable (`-Jidoka` o `$env:JIDOKA_HOME`) y avisa "al día / atrás".
   **Aviso, no muro** (exit 0 siempre; regla 2–3 antes de endurecer).

4. **Canal de subida.** El hijo **no parchea su maquinaria local**: reporta con `tools/reportar-leccion.ps1`
   (abre el issue `leccion.md` de Jidoka) + la guía `docs/guias/reportar-leccion-a-jidoka.md`. Jidoka
   arregla con su ritual y el hijo baja con `-Actualizar`.

Y la **costura `.local`**: `verificar.ps1` genérico hace dot-source opcional de `tools/verificar.local.ps1`.
Es la vía sostenible para que un hijo extienda la mecánica (ruff/pytest) **sin bifurcar** el script
genérico — la puerta por la que un motor divergente converge sin clobber.

## Por qué

- **La conciencia de tres vías es lo que hace sostenible "no pises lo mío".** Sin la línea base del hash
  sembrado, `-Actualizar` solo puede clobbear todo o nada. Con ella distingue "el hijo no lo tocó, Jidoka
  avanzó" (seguro actualizar) de "el hijo lo customizó" (preservar y reportar) — exactamente el juicio que
  el cliente pidió, mecanizado.
- **El poka-yoke es el humano, no la automatización.** `-Actualizar` solo escribe; el diff en un PR es la
  revisión. Reversible por diseño (ADR 0003: nada irreversible sin checkpoint).
- **Aviso antes que muro** (regla 2–3, doctrina del lazo local): la divergencia se avisa mientras la
  práctica madura; endurecer a bloqueo es una decisión posterior con evidencia.

## El camino que NO se toma (y por qué tienta)

- **`-Actualizar` que sobrescribe el motor a ciegas.** Tienta por simple, pero rompería a SGI (perdería
  su ruff+pytest). La divergencia por dominio es legítima; clobbearla es destruir trabajo.
- **Cablear el aviso de divergencia dentro de `verificar.ps1` (el gate de push).** El ROADMAP lo sugería,
  pero tocar el verificador sembrado de cada hijo es el clobber que se quiere evitar; un comando standalone
  (`estado-motor.ps1`) da el aviso sin arriesgar el gate. La integración al push queda diferida.
- **Refactorizar ya el `verificar.ps1` de SGI a data-driven** (mover ruff/pytest a `.local`): es la
  convergencia correcta, pero con 453 tests de por medio es riesgo que no toca a este sprint. SGI se cablea
  al lazo (sello + canal + estado) sin tocar su motor; la convergencia real es *follow-through* del lazo.
- **SSOT completo (npm `package.json`, release-CI):** `version.txt` es el primer paso del SSOT que el
  ROADMAP pide; el resto sigue en Fase 3.C.

## Consecuencias

- Un hijo limpio converge con un comando y sabe cuándo está atrás; un hijo divergente (SGI) preserva lo
  suyo y ve exactamente qué difiere. La homologación manual de la ADR 0011 ahora tiene máquina.
- El smoke `tools/probar-instalador.ps1` cubre las tres vías, el aviso, la costura `.local` y el canal
  (32/32). El motor propio de Jidoka sigue verde (dogfooding).
- SGI queda como **primer consumidor** del lazo (su ADR propio + sello + canal), con sus lecciones de campo
  redactadas para subir.
