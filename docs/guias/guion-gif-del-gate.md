# Guion — el GIF del gate mordiendo

> La pieza más valiosa de la vitrina (`ROADMAP.md` → *Vitrina pública* ⏳1). Todo lo de abajo está listo para copy-paste: solo abre la terminal, enciende [ScreenToGif](https://www.screentogif.com/) (Windows, gratis) y graba una toma de ~20 segundos. El GIF se incrusta en el README, en la sección *Míralo morder* (ya hay un comentario HTML marcando el lugar).

## Preparación (fuera de cámara)

```powershell
cd C:\Repositorios\jidoka
git status          # working tree limpio, para que el revert final sea trivial
```

## La toma (~20 s, 4 movimientos)

**1. Crea un ADR sin listarlo en el índice** (el defecto):

```powershell
Set-Content -Path docs\decisions\9999-demo-gate.md -Value '# ADR 9999 - demo del gate' -Encoding utf8
```

**2. Corre el verificador → el bloqueo rojo** (el momento estelar — deja el `[BLOQUEA]` en pantalla un par de segundos):

```powershell
./tools/verificar.ps1
```

**3. Lístalo en el índice → verde** (la línea es lo único que cambia):

```powershell
Add-Content -Path docs\decisions\README.md -Value '- [9999 - demo del gate](9999-demo-gate.md)' -Encoding utf8
./tools/verificar.ps1
```

**4. Corte.**

## Limpieza (fuera de cámara)

```powershell
git checkout -- docs\decisions\README.md
Remove-Item docs\decisions\9999-demo-gate.md
git status          # limpio otra vez
```

## Al terminar

- Guarda el GIF como `docs/assets/gate-mordiendo.gif` (crea la carpeta si no existe).
- En `README.md`, reemplaza el comentario `<!-- GIF del gate mordiendo... -->` por:
  `![El gate Andon bloqueando un ADR sin listar, y pasando a verde al listarlo](docs/assets/gate-mordiendo.gif)`
- Marca el ⏳1 de *Vitrina pública* en `ROADMAP.md` como hecho.
