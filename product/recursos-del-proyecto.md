# Recursos del proyecto — Jidoka

> **Lo que la sesión no debe preguntar al abrir.** Punteros, nunca secretos (ver la plantilla en `kit/.jidoka/templates/recursos-del-proyecto.md`). `/jidoka:arranca` lo lee.

## Material de referencia

- **El estado en vuelo** vive en `HANDOFF.md` (se lee y se limpia al abrir).
- **Hacia dónde va la beta**: `ROADMAP.md` (sprints, grietas registradas, backlog).
- **El porqué de cada decisión**: `docs/decisions/` (ADRs; índice en su `README.md`).
- **El método escrito**: `kanban/` (ritual, roles, lazo, estados, verificación, homologación, auditoría, jerarquía) y `andon/` (los gates). La doctrina citable, en `doctrina/`.
- **El plan de trabajo del día** (efímero, si existe): `/.jidoka/plan-actual.md` — fuera de git (ADR 0006).

## Identidades por servicio

- **GitHub**: se pushea al remoto `origin` (repo `ArmandoMedina/…`). `main` está protegido (require PR + check `andon` required, sin bypass). Merges de PR **requieren orden nombrada del cliente cada vez**; publicar tag+release ya está autorizado (ver HANDOFF).

## Máquinas y ambientes

- **Desarrollo**: Windows 11 / PowerShell 5.1. El recetario de entorno (BOM, acentos, `$LASTEXITCODE`, "los subagentes no leen la config global") vive en `docs/guias/entorno-windows-powershell51.md`. El motor (`*.ps1`) es ASCII a propósito y el CI corre en `windows-latest` con el mismo intérprete.
- **Ambientes de prueba disponibles** (dos, en la máquina del autor):
  - Uno **"que jala bien"** — el ambiente de pruebas preferido para correr el ritual, el motor y ensayar el instalador (Sprint 3).
  - El **sandbox de Windows** ("el feo") — entorno desechable/aislado; útil para probar el motor en un repo limpio desde cero, aunque incómodo. Preferir el bueno salvo que se necesite aislamiento real.
  - *(Cuando cada uno tenga nombre/forma de levantarse concretos, se anotan aquí para que la sesión sepa cuál usar para qué.)*

## Convenciones que no se re-preguntan

- **Los commits públicos no llevan trailer de sesión** (`Claude-Session:` ni `Co-Authored-By` de IA) — ADR 0003 #5: identificadores privados del operador fuera de un repo público.
- **Se trabaja en rama sacada de `main`**, nunca commit directo a `main`.
- **Evidencia-no-palabra**: nada se anuncia como hecho hasta que corre; la evidencia va al artefacto (test, `qa_runs/`, log), no a la palabra del agente.
