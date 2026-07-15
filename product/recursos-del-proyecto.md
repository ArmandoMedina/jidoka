---
tipo: recursos
estado: vigente
---
# Recursos del proyecto — Jidoka

> **Lo que la sesión no debe preguntar al abrir.** Punteros, nunca secretos (ver la plantilla en `kit/.jidoka/templates/recursos-del-proyecto.md`). `/jidoka:arranca` lo lee.

## El casting

> **Quién ocupa cada asiento del método, por nombre.** `/jidoka:arranca` lee esta sección para **sentar la sesión** en su rol y anunciarlo. En este repo el casting usa los **nombres neutrales** del método a propósito (decisión del cliente, 2026-07-14): la nave nodriza sigue la misma ruta que un usuario recién sembrado, para no sesgarse. La autoridad la da la ley (`tools/blast-radius.json`), no el nombre (`kanban/roles.md`).

| Asiento (rol del método) | Nombre | Quién lo ocupa / cuándo |
|---|---|---|
| orquestador | orquestador | El hilo principal: decide y teje, delega lo pesado. |
| escribano | escribano | Sincroniza los docs dueños según la ley; cierra el drift. Las 8 áreas de la ley rutean aquí. |
| revisor-visual | *(dormido)* | Sin área `rol: revisor-visual` en la ley — este repo no tiene deliverable visual. Se sienta al declararla. |
| validador | *(dormido)* | Sin área `rol: validador` en la ley — sin spec numérica propia. Se sienta al declararla. |

> Menú, no molde: solo se sientan los asientos que este repo merece. Un asiento *(dormido)* no es permiso — es un área que la ley aún no declara.

## Material de referencia

- **El estado en vuelo** vive en `HANDOFF.md` (se lee y se limpia al abrir).
- **Hacia dónde va la beta**: `ROADMAP.md` (sprints, grietas registradas, backlog).
- **El porqué de cada decisión**: `docs/decisions/` (ADRs; índice en su `README.md`).
- **El método escrito**: `kanban/` (ritual, roles, lazo, estados, verificación, homologación, auditoría, jerarquía) y `andon/` (los gates). La doctrina citable, en `doctrina/`.
- **El plan de trabajo del día** (efímero, si existe): `/.jidoka/plan-actual.md` — fuera de git (ADR 0006).

## Identidades por servicio

- **GitHub**: se pushea al remoto `origin` (repo `ArmandoMedina/…`). `main` está protegido (require PR + check `andon` required, sin bypass). Merges de PR **requieren orden nombrada del cliente cada vez**; publicar tag+release ya está autorizado (ver HANDOFF).
- **Cuentas gh en esta máquina (2026-07-15):** hay dos (`gh auth status`): **`ArmandoMedina`** (dueño del repo — la única con permiso de merge y release) y `Armandomedina9705` (solo lectura aquí; suele ser la activa). Para mergear o liberar: `gh auth switch --user ArmandoMedina` y restaurar la otra al terminar.

## Máquinas y ambientes

- **Desarrollo**: Windows 11 / PowerShell 5.1. El recetario de entorno (BOM, acentos, `$LASTEXITCODE`, "los subagentes no leen la config global") vive en `docs/guias/entorno-windows-powershell51.md`. El motor (`*.ps1`) es ASCII a propósito y el CI corre en `windows-latest` con el mismo intérprete.
- **Ambientes de prueba disponibles** (en la máquina del autor):
  - **Máquinas virtuales** en este equipo — el ambiente ideal para el **smoke del instalador del Sprint 3** (`npx jidoka-method init` sobre un repo/entorno limpio, aislado del dev): permiten verificar la instalación desde cero sin ensuciar el equipo real. Es la pieza que vuelve verificable "corre en un repo ajeno" (el criterio de la 1.0).
  - Uno **"que jala bien"** — el ambiente preferido para correr el ritual y el motor en el día a día.
  - El **sandbox de Windows** ("el feo") — entorno desechable/aislado; útil para pruebas rápidas de un repo limpio, aunque incómodo. Preferir el bueno o una VM salvo que se necesite aislamiento efímero.
  - *(Cuando cada VM/ambiente tenga nombre y forma concreta de levantarse, se anota aquí para que la sesión sepa cuál usar para qué.)*

## Convenciones que no se re-preguntan

- **Los commits públicos no llevan trailer de sesión** (`Claude-Session:` ni `Co-Authored-By` de IA) — ADR 0003 #5: identificadores privados del operador fuera de un repo público.
- **Se trabaja en rama sacada de `main`**, nunca commit directo a `main`.
- **Evidencia-no-palabra**: nada se anuncia como hecho hasta que corre; la evidencia va al artefacto (test, `qa_runs/`, log), no a la palabra del agente.
