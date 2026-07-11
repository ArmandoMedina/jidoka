---
tipo: guia
estado: vigente
---

# Empezar de cero con Jidoka

Esta guía te lleva de la mano, sin asumir nada, desde una instalación limpia hasta tu primera sesión de trabajo con el método corriendo. Es para alguien que **no conoce Jidoka** y quiere instalarlo y probarlo **en su propio repo**.

**Jidoka en dos líneas:** es un método para dirigir agentes de IA con disciplina de manufactura — el error se atrapa en la fuente, fuera del LLM, con gates deterministas (el "Andon") en vez de pedirle al agente que se porte bien. La documentación y el código no pueden mentirse el uno al otro: si divergen, el push se detiene.

> **Hoy Jidoka es Windows-first.** El motor, los hooks locales y el instalador corren en **Windows + PowerShell 5.1**. El muro real (el check de Andon) corre server-side en GitHub Actions, así que tu equipo puede ser mixto — pero esta guía asume que instalas desde una máquina Windows. Multiplataforma y el CLI `npx` vienen en el [roadmap](../../ROADMAP.md).

---

## 1. Antes de empezar

Necesitas, ya instalado y funcionando:

- **Windows** con **PowerShell 5.1** (el que trae Windows de fábrica: `Windows PowerShell`, no hace falta 7). Verifícalo con `$PSVersionTable.PSVersion`.
- **git** en el `PATH` (`git --version` responde).
- Una **cuenta de GitHub** — la vas a necesitar para encender el muro real (branch protection).
- **[Claude Code](https://claude.com/claude-code)** — el ritual (`/jidoka:arranca`, `/jidoka:planea`, …) corre ahí. Todo, incluido el modo desatendido, se cubre con tu suscripción Pro/Max, sin API key.

> PowerShell 5.1 tiene trampas propias (encoding UTF-16 por defecto, `2>&1` que envuelve stderr, sin operadores `&&`/`??`). No las necesitas para instalar, pero cuando escribas scripts del método consulta [las trampas de PS 5.1](entorno-windows-powershell51.md).

Ten a mano **la ruta del repo donde quieres el método**. Puede ser un repo con trabajo ya empezado (el instalador **nunca sobrescribe nada tuyo**) o una carpeta nueva vacía (el instalador corre `git init` por ti).

---

## 2. Instalar

### 2.1 Clona Jidoka

Clona el repo de Jidoka **en cualquier lado** — es la fuente del motor, no tu proyecto:

```powershell
git clone https://github.com/ArmandoMedina/jidoka
cd jidoka
```

### 2.2 Corre el instalador apuntando a tu repo

El único parámetro obligatorio es `-Destino`: la ruta de **tu** repo (el que recibe el método).

```powershell
./tools/instalar.ps1 -Destino C:\ruta\a\tu-repo
```

Si no pasas `-Arquetipo`, el instalador **te pregunta** con un menú interactivo:

```
== Elige el arquetipo (que siembra Jidoka) ==
  [1] docs-as-code - documentacion y codigo viajan juntos (herramienta operativa de equipo)
  [2] code-first - el metodo vive implicito en el codigo + un brief (herramienta o libreria personal)
Numero o nombre (Enter = docs-as-code)
```

Elige por el **criterio real** de cada arquetipo:

| Arquetipo | Cuándo | Qué siembra de producto |
|---|---|---|
| **`docs-as-code`** | Documentación y código viajan juntos: una herramienta operativa de equipo donde el "qué" se documenta como grafo vivo. | `product/` — el grafo del QUÉ (dominios → módulos → capacidades), auditado por `tools/auditar.ps1`. |
| **`code-first`** | El método vive implícito en el código + un brief de una página: una herramienta o librería personal. | `PRODUCT_BRIEF.md` — el QUÉ y el PORQUÉ en una página. |

*(Hay un tercer arquetipo, `doc-only`, diseñado pero **diferido** — el instalador lo rechaza hasta que un repo regulado real lo estrene.)*

Si sabes cuál quieres, pásalo directo y evita la pregunta:

```powershell
./tools/instalar.ps1 -Destino C:\ruta\a\tu-repo -Arquetipo code-first
```

Para correr **desatendido** (sin que nadie conteste el menú), usa `-Yes`; sin `-Arquetipo` cae a `docs-as-code`:

```powershell
./tools/instalar.ps1 -Destino C:\ruta\a\tu-repo -Yes
```

### 2.3 Qué siembra

El instalador copia, respetando **no-clobber** (solo lo que falte):

- **El motor genérico** — `tools/verificar.ps1`, `auditar.ps1`, los self-tests `probar-gate/-hooks/-auditor.ps1`, `estado-motor.ps1`, `reportar-leccion.ps1`; los hooks de Claude (`.claude/`), el `pre-push` (`.githooks/`) y el workflow de CI (`.github/workflows/andon.yml`).
- **El método completo** — `kanban/` (el ritual), `andon/` (los gates) y `doctrina/` (el porqué) se siembran también, para que el repo hijo lleve la explicación consigo.
- **La ley de tu arquetipo** — la plantilla `blast-radius` correspondiente, como `tools/blast-radius.json`.
- **Los stubs** — `HANDOFF.md`, `ROADMAP.md`, `CHANGELOG.md`, `docs/decisions/README.md` (el índice de ADRs), `.gitignore`, y la semilla de producto de tu arquetipo (`product/README.md` o `PRODUCT_BRIEF.md`).
- **El sello de versión** — `tools/jidoka-motor.json` (versión de Jidoka + hash de cada pieza de motor). Es la línea base para bajar mejoras después (§6).

Al terminar enciende `core.hooksPath = .githooks` y te imprime los **Siguientes pasos**:

```
Siguientes pasos:
  1. Corre ./tools/probar-gate.ps1 para confirmar que el motor quedo sano.
  2. Corre /jidoka:arranca en una sesion de Claude Code para activar el ritual.
  3. Enciende el muro server-side (paso humano): branch protection en main con el check 'andon' requerido y sin bypass.
  4. Copia una plantilla de kit/.jidoka/templates/ (ritual) o kit/.jidoka/templates/producto/ para tu primer plan, ADR o capacidad.
```

### 2.4 La regla no-clobber

El instalador **nunca sobrescribe** un archivo que ya exista en el destino: lo salta y lo reporta (`[SALTA] ... (ya existe; no se sobrescribe)`). Puedes correrlo sobre un repo con trabajo empezado sin miedo — no borra nada tuyo. Si ya tenías un `HANDOFF.md` o un `.gitignore`, se conservan tal cual.

---

## 3. Encender el muro

Hay **dos** capas, y hacen cosas distintas. No confundas la primera con la segunda:

- **Hooks locales** (`core.hooksPath = .githooks`) — **avisan mientras trabajas**. El `pre-push` corre el verificador antes de cada push. Son UX: se saltan a propósito con `--no-verify`.
- **El required check server-side** (branch protection en GitHub) — **bloquea al mergear**. Es lo único que `--no-verify` no salta. **Este es el muro real.**

### 3.1 Los hooks locales (ya hecho)

El instalador ya corrió `git config core.hooksPath .githooks` en tu repo. Los hooks de Claude (`no-memorias`, `andon-stop`, …) se cablean solos vía `.claude/settings.json`. No tienes que hacer nada aquí — solo saber que están.

### 3.2 La branch protection en GitHub (paso humano, una vez)

Sube tu repo a GitHub si aún no está, abre el primer PR (para que el workflow Andon corra al menos una vez y aparezca en el selector), y luego en **GitHub → Settings → Branches → Add branch protection rule** para `main`, marca **las tres** cosas — sin las tres no hay muro:

1. **Require a pull request before merging** — si se puede pushear directo a `main`, el check nunca corre.
2. El check del workflow Andon como **required status check** — en el selector de GitHub aparece con su nombre de job: **`andon blast-radius (la ley)`**.
3. **Do not allow bypassing the above settings** — si el admin puede saltárselo, para el admin (y para el agente usando sus credenciales) sigue siendo una sugerencia, no un muro.

El detalle completo, con las fronteras conocidas del muro, está en [`andon/README.md`](../../andon/README.md).

---

## 4. Confirmar que quedó sano

### 4.1 Corre los self-tests sembrados

El instalador sembró los self-tests del motor. Correrlos confirma que la maquinaria quedó viva — cada uno incluye al menos un caso que **debe bloquear** (un gate que nunca rechaza nada está podrido aunque el tablero esté verde). Desde tu repo:

```powershell
cd C:\ruta\a\tu-repo
./tools/probar-gate.ps1      # el verificador (la rama que bloquea)
./tools/probar-hooks.ps1     # los Stop hooks de Claude
./tools/probar-auditor.ps1   # el auditor del grafo de docs
```

Los tres deben salir verdes.

> `tools/probar-instalador.ps1` **no** se siembra: es el smoke del propio repo Jidoka. En tu repo hijo no existe, y está bien.

### 4.2 Provoca un `[BLOQUEA]` real y míralo morder

Para verlo detener algo de verdad, agrega un ADR **sin listarlo en su índice** (el único bloqueo duro de la ley) y corre el verificador:

```powershell
Set-Content docs\decisions\9999-demo.md '# ADR 9999 - demo'   # decisión SIN listar en su índice
git add .; git commit -m "demo: ADR sin listar"
./tools/verificar.ps1        # → [BLOQUEA] ... PUSH DETENIDO. (exit 1)
git reset --hard HEAD~1      # limpieza: borra el commit del demo
```

Si viste el `[BLOQUEA]` rojo y `exit 1`, el muro muerde. El `git reset` deja tu repo como estaba.

---

## 5. Tu primera sesión

Abre Claude Code en tu repo y corre:

```
/jidoka:arranca
```

`arranca` **lee el estado real** (tu `HANDOFF.md`, los recursos del proyecto, dónde está git) en vez de fiarse de la memoria, y **fija las reglas duras** de la sesión: una sola sesión escritora, evidencia-no-palabra, la disciplina escala con el riesgo, nada de memorias de la IA. Es lo primero, siempre.

De ahí, el ciclo — cada paso es un comando `/jidoka:*`:

1. **`/jidoka:planea`** — diseña el sprint con el QUÉ **aprobado por el cliente antes de escribir código** (la rebanada R0 con STOP). El entregable es un plan, no código.
2. **Construir en rebanadas** — el agente construye por rebanadas verticales, cada una commiteable y verde por sí sola; el Andon avisa o bloquea si algo diverge.
3. **`/jidoka:gemba`** — corre el demo desde el producto real y deja la evidencia en `qa_runs/` para que el cliente lo verifique **con sus propios ojos** (revisa el demo, no el PR).
4. **`/jidoka:cierra`** — registra el estado en su doc dueño, poda lo muerto, commitea la evidencia citada y prepara el release.

¿No sabes por dónde seguir? **`/jidoka:que-sigue`** lee el estado y propone el siguiente paso en orden de valor. ¿Trabajas sin humano presente? **`/jidoka:desatendido`** reparte lo ejecutable de lo que exige tu juicio.

> **Menú, no molde.** La disciplina escala con el riesgo: enciende solo la ceremonia que el cambio merece. Un typo no necesita un sprint; un cambio irreversible sí necesita R0 con STOP.

---

## 6. Bajar mejoras del método

Jidoka evoluciona. El lazo entre tu repo y Jidoka (ADR 0012) tiene dos direcciones — *la lección sube, la máquina baja*:

**Bajar la máquina.** Cuando Jidoka publique una versión nueva, actualiza tu clon de Jidoka (`git pull`) y desde **dentro de Jidoka** apunta el instalador a tu repo con `-Actualizar`:

```powershell
cd C:\ruta\a\jidoka
git pull
./tools/instalar.ps1 -Destino C:\ruta\a\tu-repo -Actualizar
```

`-Actualizar` re-siembra **solo la mecánica** (el motor) con conciencia de tres vías por hash: agrega lo nuevo, actualiza lo que no tocaste, y **si customizaste una pieza no la pisa** — deja la versión nueva al lado como `<archivo>.jidoka-nuevo` para que reconcilies a mano. Tu **instancia** (tu ley `blast-radius.json`, tu `product/`, tus ADRs, tu HANDOFF) **nunca se toca**.

**Subir la lección.** Cuando uses el método y descubras algo — una regla que faltó, un gate que se pudrió — **no parchees tu maquinaria local** (divergiría). Repórtalo hacia arriba:

```powershell
./tools/reportar-leccion.ps1
```

Abre el issue de lección de Jidoka, prellenado, en tu navegador. Jidoka lo arregla con su propio ritual y tú bajas la corrección con `-Actualizar`. El detalle, en [reportar una lección a Jidoka](reportar-leccion-a-jidoka.md).

---

## 7. A dónde seguir

- **El ritual** — cómo gira el lazo Intención → Construcción → Verificación → Registro: [`kanban/`](../../kanban/README.md) (empieza por [`kanban/lazo.md`](../../kanban/lazo.md)).
- **Los gates** — cómo el Andon atrapa el error en la fuente y cuáles son sus fronteras: [`andon/README.md`](../../andon/README.md).
- **La doctrina** — el porqué de todo (manufactura, software, aviación): [`doctrina/`](../../doctrina/README.md).
- **El panorama** — qué es Jidoka y por qué se llama así: el [README](../../README.md).

Bienvenido. Ya tienes el muro encendido y el ritual listo — de aquí en adelante, el método trabaja contigo.
