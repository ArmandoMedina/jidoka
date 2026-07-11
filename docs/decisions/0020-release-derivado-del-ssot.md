# ADR 0020 — El release se deriva del SSOT: `publicar.ps1` en vez del tipeo manual

- **Estado:** aceptado
- **Fecha:** 2026-07-11

## Contexto

`tools/version.txt` ya era el SSOT de versión (atado al CHANGELOG por `probar-version.ps1`; ADR 0012). Pero el
**ritual de release** seguía siendo manual: en cada corte se tecleaba a mano el tag (`v1.x.y`), el título y las
notas en el `gh release create`. Eso es exactamente el drift que el SSOT existe para evitar — el mismo número
escrito en varios lugares a mano se desincroniza. El ROADMAP lo tenía pendiente ("SSOT de versión: un literal,
todo deriva"). Con varios releases seguidos en el batch post-1.0, el tipeo manual ya era una fuente real de
error.

## Decisión

**`tools/publicar.ps1`** corta el release **derivando todo del SSOT**:

1. Lee la versión de `tools/version.txt` → `$tag = "v$version"`.
2. Extrae del `CHANGELOG.md` la sección de esa versión (título descriptivo del primer `### ` + cuerpo), leída
   como **UTF-8** (los acentos/flechas del CHANGELOG saldrían corruptos en PS 5.1 sin esto).
3. **Guardas**: en `main`, árbol limpio, el tag no existe aún.
4. **Corre la suite completa de self-tests** (evidencia-no-palabra: no se publica un motor roto).
5. Crea el tag + release con esas notas. `-DryRun` muestra todo sin crear nada (testable).

`publicar.ps1` y su self-test `probar-publicar.ps1` son **Jidoka-only** (no se siembran): un hijo versiona su
app con su propio esquema (SGI usa `fantasma.__version__`, TF su CHANGELOG). Se CI-gatean con una guarda
`Test-Path` en `andon.yml`, que corre los tests Jidoka-only solo donde existen.

## Por qué

- **Mata el drift del tipeo manual en la fuente.** La versión se escribe UNA vez (en `version.txt`) y el tag,
  el título y las notas del release derivan de ahí + del CHANGELOG. No hay segundo lugar que teclear.
- **El release queda gateado por la suite** (`evidencia-no-palabra`): `publicar.ps1` no crea el tag si un
  self-test falla — el motor se prueba antes de estrenarse, no después.
- **Se dogfoodea de inmediato**: este mismo `v1.3.0` se cortó con `publicar.ps1` (su primera corrida real es su
  prueba de vida — `prueba-de-humo-del-gate`).

## El camino que NO se toma (y por qué tienta)

- **`package.json` como SSOT ahora** (lo que sugería el ROADMAP). Tienta porque es el destino natural cuando
  exista el CLI npm. Se descarta hoy: no hay paquete npm todavía (el CLI es su propia épica, bloqueada además
  por la verificación cross-platform), así que introducir `package.json` solo por la versión sería andamiaje
  sin consumidor. Cuando el CLI llegue, `package.json` derivará de `version.txt`, no al revés.
- **Un `publicar.ps1` genérico y sembrado.** Tienta por simetría con el resto de la mecánica, pero los hijos
  tienen esquemas de versión distintos; un release-tool genérico les serviría mal. Se mantiene Jidoka-only.

## Consecuencias

- El ritual de release de Jidoka es un comando (`./tools/publicar.ps1`) que deriva del SSOT y se auto-verifica.
- `probar-publicar.ps1` (4 casos, dry-run sin efectos) + `probar-version.ps1` quedan CI-gateados en Jidoka vía
  la guarda `Test-Path` de `andon.yml`.
- Primer peldaño concreto del CLI npm (cuando se retome): la versión ya está centralizada y derivable.
- Evidencia: `probar-publicar.ps1` 4/4; `v1.3.0` cortado con la propia herramienta. Versión `v1.3.0`.
