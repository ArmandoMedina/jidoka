# LOG — Fix del encoding de la tubería (rama `app/curas-tuberia-20260722`)

**Fecha:** 2026-07-22
**Rebanada:** R1 — la app pinta la foto del repo sin romperse por acentos ni flechas.
**Plan-contrato:** este sprint (fix del banner rojo "la foto del repo no es JSON válido").

## Método reproducible

1. Abre la app Tauri apuntando a este repo.
2. La pestaña "La tubería" muestra un banner rojo: "la foto del repo no es JSON válido: Bad control character in string literal..."
3. Analiza el stdout de `powershell.exe` sin consola para detectar caracteres de control (0x1A) causados por CP437.
4. Porta el emit UTF-8 a `Emit-Utf8Json` en `tuberia-datos.ps1`, `parametrizar.ps1`, `override.ps1`.
5. Endurecerá `probar-app.ps1` para verificar bytes crudos + ausencia de control-chars.

## El síntoma (lo que veía el cliente)

La app Tauri abría con un banner rojo en "1 · La tubería":

> la foto del repo no es JSON válido: Bad control character in string literal in JSON at position 401 (line 11 column 54)

La vista principal quedaba ciega.

## La causa raíz (confirmada con bytes, no hipótesis)

- El puente Rust spawnea `powershell.exe` con `CREATE_NO_WINDOW`, sin consola, y lee su stdout
  como UTF-8 (`String::from_utf8_lossy`, `app/src-tauri/src/lib.rs:80`).
- PowerShell 5.1 sin consola emite su stdout con `[Console]::OutputEncoding` = code page OEM
  **CP437**. En CP437 el `→` (U+2192) se codifica al byte `0x1A` — el carácter de control **SUB**.
  Los acentos caen a bytes inválidos en UTF-8.
- El byte real en la posición 401 del stdout es `26` (`0x1A`): el primer `→` de la `desc` de
  `c-arranca` (*"Abre la sesión: git → QUÉ → CÓMO → DÓNDE"*) — línea 11, col 54. Cuadra exacto
  con el error del cliente.
- `JSON.parse` de JS rechaza cualquier carácter de control literal dentro de un string.

## El fix

Emitir los bytes UTF-8 crudos directo a `[Console]::OpenStandardOutput()` (sin BOM, newline
final), sin pasar por `[Console]::OutputEncoding`. Helper `Emit-Utf8Json` en los 5 emits a stdout
que Rust consume: `tuberia-datos.ps1` (la foto), `parametrizar.ps1` (éxito + `Salir-Error`),
`override.ps1` (éxito + `Salir-Error`). Los `WriteAllText` a archivo no se tocan (ya fijan UTF-8
sin BOM). `bandeja.ps1`/`estado-ritual.ps1` no se tocan (captura interna PS→PS ya funciona).

## Evidencia (evidencia-no-palabra)

### 1. El test tenía que dejar de mentir

`tools/probar-app.ps1` estaba **verde en falso** (35/35, exit 0) mientras la app estaba roja:
forzaba `StandardOutputEncoding = UTF8` al decodificar (ocultaba el emit CP437) y validaba con
`ConvertFrom-Json` de PS, que **tolera** los caracteres de control que `JSON.parse` de JS rechaza.

Se endureció para replicar al consumidor real (Rust bytes crudos + JS): captura bytes crudos,
decodifica UTF-8 lossy, y afirma **no hay caracteres de control** y **no hay `U+FFFD`**.

**ANTES del fix (test endurecido, motor sin arreglar) → ROJO:**
```
[FALLA] tuberia-datos stdout trae un caracter de control (0x1A): JSON.parse de JS lo rechaza (Bad control character)
[FALLA] tuberia-datos stdout trae U+FFFD: un acento/flecha se corrompio en el encoding
== App INCOMPLETA: 2 fallo(s), 35 ok. ==  (EXIT 1)
```

**DESPUÉS del fix → VERDE:**
```
[PASA] tuberia-datos stdout sin BOM (el JS que lo parsea no tolera BOM)
[PASA] tuberia-datos stdout SIN caracteres de control (JSON.parse de JS lo aceptaria)
[PASA] tuberia-datos stdout sin replacement chars (acentos y flechas intactos)
[PASA] la foto consolidada parsea como JSON
== App sana: 37 verificaciones verdes. ==  (EXIT 0)
```

### 2. Prueba dura del pipe con el parser real (Node JSON.parse)

Capturado el stdout como lo hace Rust (Process sin consola, bytes crudos) y pasado por el
`JSON.parse` de Node — el mismo motor que la app:
```
JSON.parse OK -- piezas:49 repo:C:/Repositorio personal/jidoka
desc[0]:"Abre la sesión: git → QUÉ → CÓMO → DÓNDE. Inyecta 4 docs con @, corre 3 scripts del motor (preflight, router, casting) y fija las reglas duras."
NODE EXIT: 0
```
La `desc` que rompía ahora se lee perfecta, con acentos y flechas.

## Resultados

### 3. Gates de contrato y sintaxis

- `tools/verificar.ps1` → **EXIT 0** (3 avisos no bloqueantes de doc-drift: atlas/barreras/producto).
- Syntax-check (tokenize) de los 3 scripts editados → OK.

## Revisión (`/code-review`, high effort) — 2026-07-22

Diff revisado: `tools/{tuberia-datos,parametrizar,override,probar-app}.ps1`.

**Hallazgo primario — RESUELTO.** El bug reportado (banner rojo) se resuelve: verificado por
tres vías — test endurecido rojo→verde, `JSON.parse` de Node sobre la foto capturada como Rust,
y `JSON.parse` de Node sobre los emits de `parametrizar`/`override` (rama `Salir-Error`, con un
acento "Excepción" que cruzó intacto). Sin fuga al success-stream; orden de definición del helper
correcto; `CopyTo`/`WaitForExit` sin deadlock.

**Hallazgo latente — ANOTADO, no manifiesta hoy (fuera del alcance aprobado, regla 2-3).**
`tuberia-datos.ps1:134` captura `bandeja.ps1`/`estado-ritual.ps1` internamente vía
`(& powershell ...) | Out-String`, que **no** se portaron a `Emit-Utf8Json`. Esa captura depende
de un round-trip CP437 simétrico: los chars **en** CP437 (acentos, `→`) round-trippean bien, pero
un char **fuera** de CP437 (em-dash `—`, comillas tipográficas, `≠`…) en un `detalle`/`motivo` de
bandeja o un `faltan` de ritual se volvería `?` en silencio bajo modo sin-consola (Rust).
- **No es crash ni reabre el banner** (`?` no es carácter de control; los datos que importan
  round-trippean). Es mojibake cosmético en subsecciones.
- **Verificado que NO ocurre hoy:** las secciones `bandeja`/`ritual` del repo son ASCII puro
  (rutas, "existe", nombres de comando) — cero `U+FFFD`, cero `?`. Empíricamente limpio.
- **El test no lo cazaría** (sus aserciones ven control-chars y `U+FFFD`, no la sustitución `?`).
- **Cura completa (si un dato futuro lo pide):** portar `bandeja.ps1`/`estado-ritual.ps1` a
  `Emit-Utf8Json` **y** cambiar `Invoke-JsonScript` a captura de bytes crudos + decode UTF-8.
  Toca el motor sembrado (blast radius mayor) — por eso el plan lo dejó fuera. Follow-up al ROADMAP.

## Pendiente

- **Gemba del cliente** (owner: cliente): abrir la app apuntando a este repo y ver "1 · La tubería"
  renderizada sin banner rojo. Es la aceptación final (sin código ni terminal).
- **Cierre:** CHANGELOG, doc-drift (escribano: atlas/barreras/producto si aplica), y la decisión
  de versión/merge coordinada con el frente FLU-1 en paralelo (PATCH `v1.27.1` vs. plegar a `v1.28.0`).

## Veredicto

El banner rojo desaparece. El encoding UTF-8 se emite sin control-chars. La app pinta "1 · La tubería" sin errores de parseo JSON.
