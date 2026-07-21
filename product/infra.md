---
tipo: recursos
estado: vigente
---
# Infra — Jidoka

> **El CÓMO-operativo: lo que la sesión no debe preguntar al abrir.** Punteros, nunca secretos (ver la plantilla en `kit/.jidoka/templates/infra.md`). `/jidoka:arranca` lo lee. El QUÉ vive aparte, en [[PRODUCT_BRIEF]].

> **Nota sobre el casting:** el reparto de funciones vive en su casa propia, `product/casting.md` (molde en `kit/.jidoka/templates/casting.md`) — humanos y agentes, con la carta SÍ/NO de cada asiento. En esta nave, el cliente ocupa los dos roles humanos (autoridad del dominio + dueño-operador). `infra.md` se queda con identidades y máquinas.

## Material de referencia

- **El estado en vuelo** vive en `HANDOFF.md` (se lee y se limpia al abrir).
- **Hacia dónde va la beta**: `ROADMAP.md` (sprints, grietas registradas, backlog).
- **El porqué de cada decisión**: `docs/decisions/` (ADRs; índice en su `README.md`).
- **El método escrito**: `kanban/` (ritual, roles, lazo, estados, verificación, homologación, auditoría, jerarquía) y `andon/` (los gates). La doctrina citable, en `doctrina/`.
- **El plan de trabajo del día** (efímero, si existe): `/.jidoka/plan-actual.md` — fuera de git (ADR 0006).

## Identidades por servicio

- **GitHub**: se pushea al remoto `origin` (repo `ArmandoMedina/…`). `main` está protegido (require PR + check `andon` required, sin bypass). Merges de PR **requieren orden nombrada del cliente cada vez**; publicar tag+release ya está autorizado (ver HANDOFF).
- **Cuentas gh en esta máquina:** hay dos (`gh auth status`): la **dueña del repo** (`ArmandoMedina` — la única con permiso de merge y release) y una **cuenta secundaria de solo-lectura** (suele ser la activa). Para mergear o liberar: `gh auth switch --user ArmandoMedina` y restaurar la secundaria al terminar (`gh auth status` muestra cuál es).

## Máquinas y ambientes

- **Desarrollo**: Windows 11 / PowerShell 5.1. El recetario de entorno (BOM, acentos, `$LASTEXITCODE`, "los subagentes no leen la config global") vive en `docs/guias/entorno-windows-powershell51.md`. El motor (`*.ps1`) es ASCII a propósito y el CI corre en `windows-latest` con el mismo intérprete.
- **Ambientes de prueba disponibles** (en la máquina del autor):
  - **Máquinas virtuales** en este equipo — el ambiente ideal para el **smoke del instalador del Sprint 3** (`npx jidoka-method init` sobre un repo/entorno limpio, aislado del dev): permiten verificar la instalación desde cero sin ensuciar el equipo real. Es la pieza que vuelve verificable "corre en un repo ajeno" (el criterio de la 1.0).

## Convenciones que no se re-preguntan

- **Los commits públicos no llevan trailer de sesión** (`Claude-Session:` ni `Co-Authored-By` de IA) — ADR 0003 #5: identificadores privados del operador fuera de un repo público.
- **Se trabaja en rama sacada de `main`**, nunca commit directo a `main`.
- **Evidencia-no-palabra**: nada se anuncia como hecho hasta que corre; la evidencia va al artefacto (test, `qa_runs/`, log), no a la palabra del agente.
