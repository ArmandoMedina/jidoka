# ADR 0021 — El lazo es agnóstico al fin de línea: el hash del motor normaliza a LF

- **Estado:** aceptado
- **Fecha:** 2026-07-11

## Contexto

Al bajar el batch `v1.3.0` a los labs (una ventana de bajada), **TF (tracker-financiero) no aplicó ninguna
mejora**: `-Actualizar` reportó `0 al día | 62 divergen`. SGI, en cambio, funcionó (`59 al día`). La causa,
verificada byte a byte: **conflicto de política de fin de línea entre repos**.

- **Jidoka** (`.gitattributes`: `*.ps1 text eol=crlf`, `* text=auto`) tiene el working tree en **CRLF**. El
  instalador siembra el sello hasheando esos bytes CRLF.
- **TF** (`.gitattributes`: `* text=auto eol=lf`) tiene el working tree en **LF**. **SGI** no fuerza EOL, así
  que en Windows queda en CRLF (por eso casó con Jidoka).

El three-way del lazo comparaba `hash(archivo LF del hijo)` contra `seed(hash CRLF de Jidoka)`. **Nunca casan**
—difieren en un byte CR por línea— aunque el contenido sea idéntico. Un hijo con `eol=lf` divergía en TODAS las
piezas, para siempre: ninguna corrección del lazo podía bajarle. El subagente que hizo la bajada de TF paró y
reportó en vez de adoptar a mano (habría shippeado un sello que miente "todo diverge").

## Decisión

**`Get-MotorHash` hashea el CONTENIDO NORMALIZADO A LF** (quita los bytes `0x0D` antes de `SHA256`). El hash
del motor queda **agnóstico al fin de línea**: un archivo con el mismo contenido produce el mismo hash sea CRLF
o LF. Se aplica en las tres piezas que hashean el motor: `instalar.ps1` (sembrado + three-way de `-Actualizar`
y `-Sellar`), `estado-motor.ps1` (`-Detallado`) y `probar-instalador.ps1` (el self-test). El motor es 100%
texto, así que quitar `0x0D` es seguro.

## Por qué

- **La política de EOL es del hijo, no de Jidoka.** Un lab puede elegir `eol=lf` por buenas razones (TF corre
  su `sh`/node en LF). El lazo no debe imponer la convención Windows de Jidoka como precio de recibir
  correcciones. Comparar por *contenido* (no por bytes) es lo correcto.
- **Sin el fix, el lazo estaba roto para toda una clase de repos** (cualquiera con `eol=lf`) — y en silencio: se
  veía como "todo customizado" en vez de "todo idéntico". Otro Goodhart del sello, cazado por el uso real.
- **Es un fix en la fuente** (la lección subió): vive una vez en Jidoka y baja a todos, en vez de que cada lab
  LF lo sufra.

## El camino que NO se toma (y por qué tienta)

- **Forzar a todos los hijos a CRLF** (documentar "tu repo debe ser CRLF"). Tienta por simple, pero impone la
  convención de Jidoka a repos que legítimamente usan LF (y rompería sus toolchains). El lazo debe adaptarse al
  hijo, no al revés.
- **Delegar la comparación a git** (`git hash-object` con normalización). Tienta porque git ya sabe de EOL,
  pero ataría el sello a git y a la config de `.gitattributes` de cada lado; un hash SHA256 del contenido
  normalizado es autónomo y determinista, sin depender de la config de git de nadie.

## Consecuencias

- **El lazo funciona para hijos con cualquier política de EOL.** TF (LF) ahora reconcilia por contenido.
- **Los sellos existentes (con hashes CRLF) se re-clasifican una vez.** SGI y TF traen sellos de la bajada
  previa con hashes no-normalizados; el próximo `-Actualizar` con el instalador arreglado los re-sella con
  hashes LF-normalizados (una reconciliación única, esperada). Por eso la bajada de este batch se **rehace**
  con el instalador arreglado en ambos labs.
- Evidencia: `probar-instalador.ps1` 42/42, con un caso nuevo que convierte un hijo entero a LF y verifica que
  `-Actualizar` reporta **0 divergencias** (antes del fix: todo divergía). Versión `v1.4.0`.
