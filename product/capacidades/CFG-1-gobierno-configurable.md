---
tipo: capacidad
estado: en_revision
clave: CFG-1
modulo: MOD-andon
dominio: Metodo
---
# Capacidad — Gobierno configurable (la UI autora, el gate ejecuta)

Del módulo [[MOD-andon]], dominio [[Metodo]]. El usuario **parametriza el gobierno de su repo desde la UI** —qué se vigila, qué se lee, qué régimen tiene cada pieza y qué no puede tocar la IA— sin editar JSON a mano, y todo lo que nazca por fuera cae a una **bandeja de pendientes de parametrizar**. Extiende el estatuto de [[KIT-2-gobierno-documental]] del documento al ritual, y sube sobre [[AND-1-muro-andon]] sin doblarlo: la interfaz **autora** (escribe ledgers en git), el gate determinista **ejecuta** (ADR 0002/0044 intactos — la UI nunca es el muro). Los tres regímenes por pieza (`motor` / `estatuto` / `libre`) y el ledger de contratos ([ADR 0046](../../docs/decisions/0046-contratos-y-regimenes.md)), el meta-gobierno de contraseña-ritual + firma + candado IA ([ADR 0047](../../docs/decisions/0047-meta-gobierno-contrasena-firma-candado.md)), y la identidad de sistema configurable ([ADR 0045](../../docs/decisions/0045-identidad-sistema-gobierno-configurable.md)). Fase 1: documentos + ritual + candados + regímenes. Pasa a `vigente` tras el Gemba del cliente al cierre de la fase.

Piezas por rebanada: la bandeja (`tools/bandeja.ps1`, R2), el estatuto del ritual (`tools/ritual-gobernado.json` + `tools/estado-ritual.ps1`, R3), el candado IA (`.claude/hooks/candado-pretooluse.ps1`, R5), el formulario y el modo avanzado en la extensión (R4/R6), sobre el ledger de instancia `tools/contratos.json`.

## Criterios de aceptación

- Dado que existe un archivo en un árbol auditado sin regla que lo gobierne (el hueco de `docs/`), cuando abro la bandeja, entonces aparece como "cubierto solo por existir" — el verde deja de mentir.
- Dado un elemento en la bandeja, cuando lo parametrizo desde VS Code (tipo → régimen → cajón → fuerza → qué comandos lo leen), entonces la regla queda escrita en los ledgers reales y el elemento sale de la cola — yo nunca abrí un JSON.
- Dado que marco qué comandos leen un doc, cuando guardo, entonces el `@` queda escrito en el comando y el detector del ritual NO lo acusa (extensión legal ≠ mutilación).
- Dado que alguien quita un `@` de fábrica de `arranca.md`, cuando corre el detector, entonces sale `DESVIADO` nombrando el invariante perdido (garantía nula) — y reconciliar tiene dos salidas: restaurar o aceptar con firma. La desviación muda no existe.
- Dado que una pieza tiene candado IA, cuando el agente intenta editarla (Write/Edit/Bash), entonces el hook lo deniega EN EL MOMENTO nombrando el contrato y el camino legal.
- Dado que reclasifico un régimen en modo avanzado, cuando confirmo, entonces queda firma (quién/cuándo/porqué, derivada de `git config` — no inventada) en el registro; sin motivo no hay reclasificación.

> Cada criterio se demuestra **sin código ni terminal** (disparo `demo-que-corre-el-cliente`): la bandeja se abre con doble clic al HTML; el formulario y el modo avanzado corren en VS Code; el candado se ve rebotar pidiéndole al agente que edite. Los tests que verifican la mecánica se entregan por rebanada (`probar-bandeja`, `probar-ritual`, `probar-hooks` extendido, `probar-extension`); esta capacidad pasa a `vigente` cuando el Gemba del cliente cierra la fase 1.
