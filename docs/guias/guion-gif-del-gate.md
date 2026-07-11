# El GIF del gate — cómo se hizo y cómo regenerarlo

> El GIF vive en `docs/assets/gate-bloqueando.gif` y se incrusta en el README (sección *Velo bloquear un cambio malo*). **No es una animación inventada:** cada línea de su terminal proviene de una corrida real de `tools/verificar.ps1` en un clon de [SimGhostInputs](https://github.com/ArmandoMedina/SimGhostInputs) (2026-07-11). Evidencia de la corrida: `qa_runs/gif-gate-20260711/` (las salidas capturadas + el generador).

## La historia que cuenta (4 tiempos, ~21 s)

1. Un agente cambia la UI (`fantasma/ui/ng_helpers.py`) y commitea.
2. `verificar.ps1` corre: lint OK, formato OK, **453 tests verdes** — y el doc-gate encuentra que `docs/guia-usuario.md` quedó atrás → `[BLOQUEA]` → **PUSH DETENIDO** (exit 1).
3. Se actualiza la guía de usuario y se commitea.
4. El mismo verificador pasa (exit 0). Subtítulo final: el mismo check corre en CI como requerido — el muro real.

## Cómo se generó

En lugar de grabar pantalla: se corrió el flujo de verdad en un clon temporal de SGI, se capturó la salida auténtica (`salida-bloqueo.txt` / `salida-verde.txt`) y un script Python+Pillow (`gen_gif.py`, en la corrida de `qa_runs/`) renderizó esa salida real cuadro a cuadro con estética de terminal (Consolas, colores del verificador, subtítulos por fase). Duraciones variables por cuadro; el GIF final pesa ~1.3 MB.

## Para regenerarlo (si el verificador o la historia cambian)

1. Clon temporal de SGI: `git clone --local C:\Repositorios\SimGhostInputs <tmp>`.
2. Reproduce los 4 tiempos commiteando (el gate de SGI mide `@{u}..HEAD`) y captura ambas salidas de `./tools/verificar.ps1`.
3. Ajusta los textos de `gen_gif.py` a las salidas capturadas (nunca al revés: el GIF sigue a la realidad) y córrelo con Python 3 + Pillow.
4. Reemplaza `docs/assets/gate-bloqueando.gif` y actualiza la evidencia en `qa_runs/`.

## Si algún día se prefiere una grabación de pantalla humana

ScreenToGif (Windows, gratis) sobre la misma secuencia de comandos; el guion copy-paste original quedó en el historial de este archivo (git log).
