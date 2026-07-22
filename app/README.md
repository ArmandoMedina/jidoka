# app/ — La app de la tubería (Tauri v2)

> La superficie del gobierno es una app de escritorio cuya interfaz **ES la maqueta**
> (`docs/analisis/maqueta-tuberia-202607.html`). El cliente le da doble clic al `.exe`
> y ve su tubería, bandeja, formulario y modo avanzado en una ventana propia. Decisión
> del cliente 2026-07-21 (ADR 0048, supersede 0044 en la superficie).

**Jidoka-only:** `app/` NO se siembra a los repos hijos (invariante afirmado en
`tools/probar-app.ps1`). Es la cara de Jidoka, no motor genérico que se propaga.

## Estructura

- `ui/index.html` — la interfaz. En R2 es **copia byte-fiel** de la maqueta congelada
  (`docs/analisis/maqueta-tuberia-202607.html`); datos aún hardcodeados (teatro). En R3+
  solo se sustituye el bloque de datos por `invoke()` al motor PS.
- `src-tauri/` — el cascarón Rust/Tauri v2. `frontendDist` apunta a `../ui` (estático,
  sin dev server ni bundler). Plugins `shell` y `dialog` registrados ya (R3+ los usa).

## Compilar (solo en el repo Jidoka; requiere el toolchain de escritorio)

Prerrequisitos (Windows): Rust (rustup + toolchain MSVC), VS2022 C++ build tools,
WebView2. Node para el CLI de Tauri.

```
cd app
npm install
npx tauri build --debug --no-bundle   # binario de verificación (rápido, sin instalador)
```

Resultado: `app/src-tauri/target/debug/jidoka-tuberia.exe`. El instalador NSIS
firmable es de R7 (`npx tauri build`).

Para iterar la UI en vivo:

```
npx tauri dev
```

## Nota de fidelidad

La maqueta original `docs/analisis/maqueta-tuberia-202607.html` es **spec congelada**:
no se toca. `ui/index.html` nace idéntica (hash SHA256 igual, verificado por
`tools/probar-app.ps1`). Ese assert se relaja a paridad estructural en R3, cuando el
bloque de datos se sustituya por llamadas al motor.
