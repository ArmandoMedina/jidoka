# Sprint — La tubería = mapa completo del repo (nada invisible)

> Plan-contrato aprobado por el cliente el **2026-07-22** (plan mode). Extiende [[CFG-1-gobierno-configurable]].
> Rama: `sprint/tuberia-por-carpetas-20260722`, apilada sobre el commit del fix de encoding `3e99a0d`.

## Contexto (por qué ahora)

La tubería (tab 1 de la app) muestra hoy **49 piezas de una lista a mano** (`tools/tuberia-piezas.json`)
y por eso **miente por omisión**: faltan dominios, módulos, la 5ª capacidad (CFG-1), los **sprints**,
los análisis, las guías… y sigue mostrando la **Extensión VS Code** ya retirada. Es el propio drift
que Jidoka combate, dentro de la app.

## Encuadre de producto

Extiende **CFG-1** ("la UI autora, el gate ejecuta, sin editar JSON a mano") llevándolo del contrato
al **censo completo**: el censo deja de mantenerse a mano; la estructura del repo es la fuente.

## Decisiones del cliente (2026-07-22)
1. **La tubería se deriva de las carpetas** — cada pieza aparece por existir su archivo. Las reglas
   (carpeta→tipo→régimen→filtro) viven **en el lector** (`tuberia-datos.ps1`) como convención
   (*Opción 1*; caminos no tomados: frontmatter por archivo, y la lista curada que se desincronizó).
2. **Alcance = absolutamente todo:** cada archivo trackeado aparece. Árboles conocidos con su **tipo
   bonito**; **todo lo demás en un cajón por carpeta**; binarios/assets en "Otros". **Nada invisible.**

Decisión a **ADR** (nuevo, en la construcción): la tubería como mapa completo derivado por convención
+ catch-all en el lector.

## Alcance en rebanadas verticales

### R1 — El escáner completo: todo aparece, agrupado y colapsable (el corazón) · toca ley + app
- Enumerar **TODO** reusando `bandeja.ps1:176-186` (git ls-files tracked+untracked) + `Test-Pattern`.
- **Tabla de convención `$TIPOS`** (~14 tipos bonitos) en `tuberia-datos.ps1`; **catch-all por carpeta**
  para el resto; cajón "Otros/assets" para binarios.
- `tuberia-piezas.json` se adelgaza a `{ aristas, overrides }`; **57 aristas re-mapeadas** a IDs por-path.
- UI: secciones de alta cardinalidad **colapsan por defecto** (`pintarTuberia`).
- **Prueba:** `probar-app.ps1` — conteo de piezas ≈ `git ls-files`; una pieza conocida con su tipo bonito;
  un sprint en su cajón; `probar-*` fuera de "El motor".
- **Gemba (cliente):** ve todos los árboles incl. Sprints; suelta un archivo + Refrescar → aparece.

### R2 — Tipos bonitos que faltan + auto-cura de lo stale · toca app
- `$TIPOS`: Dominio (`product/dominios`), Módulo (`product/modulos`), Capacidades = 5 (CFG-1). `ORDER` en UI.
- Auto-cura: `extension/` retirada no casa nada → "Extensión VS Code" desaparece sola.
- **Prueba:** `probar-app.ps1` — tipos nuevos presentes, extensión ausente.
- **Gemba:** Dominios y Módulos visibles; Capacidades = 5; Extensión VS Code ausente.

### R3 — La prosa y el régimen finos (que no se vea pelón) · toca ley + app
- Nombre derivado: frontmatter/`# H1` del `.md`, cabecera del `.ps1`, fallback filename. `confHoy/confVision`
  de overrides o vacío. Régimen/leyenda correcta para catch-all (libre) + cajón "Otros".
- **Prueba:** `probar-app.ps1` — una pieza `.md` toma su H1 como nombre.
- **Gemba:** las piezas muestran su título real y su color de régimen correcto.

## Archivos (blast radius)
- `tools/tuberia-datos.ps1` — motor de escaneo (tabla `$TIPOS` + catch-all), reemplaza el loop `:103-125`.
- `tools/tuberia-piezas.json` — adelgazar a `{ aristas, overrides }`; re-mapear aristas.
- `app/ui/index.html` — colapso de secciones grandes; `ORDER`.
- `tools/probar-app.ps1` — aserciones nuevas.
- `docs/decisions/` — ADR de la decisión + índice. `CHANGELOG.md` al cerrar.
- Área **app** (review-stop + andon-stop) + toca la ley del censo → `/code-review` + escribano al cerrar.

## Verificación (el demo que corre el cliente) — owner: cliente
En "1 · La tubería", sin código ni terminal:
1. Veo **todos** los árboles del repo, incluidos **Sprints**, Análisis, Guías, Kanban, Doctrina, ADRs.
2. Suelto un archivo nuevo en cualquier carpeta + **Refrescar** → aparece en su cajón (nadie editó un JSON).
3. Las secciones grandes (Sprints, ADRs) se ven **colapsadas/contadas**, no cientos de tiles.
4. Aparecen **Dominios** y **Módulos**; **Capacidades = 5**; la **Extensión VS Code** ya no está.
5. Las piezas muestran su **título real** y su color de régimen correcto.

Evidencia interna por rebanada: `probar-app.ps1` verde + conteo por tipo (antes/después) al `qa_runs/.../LOG.md`.

## Lo que NO entra (frontera)
- Derivar **aristas nuevas** (ligas, wikilinks) — se conservan las curadas re-mapeadas; derivarlas es otro sprint.
- Re-curar `confHoy/confVision` a mano por pieza — se derivan o quedan vacías.
- Candado/firma/parametrizar (CFG-1 fase 1) ya existen — no se rehacen.
- Régimen "inteligente" para el catch-all — todo lo no-mapeado es **libre**; afinar = una fila en `$TIPOS`.
