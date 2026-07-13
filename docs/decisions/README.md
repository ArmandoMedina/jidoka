# Decisiones (ADRs) — Jidoka

Registro de las decisiones de arquitectura del proyecto. Cada ADR captura **una** decisión y su porqué, para que el contexto viaje entre sprints sin depender de la memoria de nadie.

> **Este índice es un doc dueño con bloqueo real.** La ley (`tools/blast-radius.json`, área `decisiones`) hace que agregar un ADR sin listarlo aquí **detenga el push**: un ADR fuera del índice es una decisión invisible. Es el único `doc_bloquea` del manifiesto (alto valor, baja fatiga).

| # | Título | Estado |
|---|---|---|
| [0000](0000-plantilla.md) | Plantilla — con la sección "El camino que NO se toma" | plantilla |
| [0001](0001-la-fusion-jidoka.md) | Jidoka: fusión de la doctrina, el método y el ritual de sprint | aceptado |
| [0002](0002-motor-andon.md) | El motor Andon: gates deterministas sobre el propio Jidoka | aceptado |
| [0003](0003-auditoria-del-motor.md) | La auditoría del motor: falla cerrado, el juez viaja en la base, y el nombre real | aceptado |
| [0004](0004-centralizacion-del-conocimiento.md) | Centralización del conocimiento del linaje: qué asciende ya, qué espera con registro, qué no asciende | aceptado |
| [0005](0005-exprimido-final-del-linaje.md) | El exprimido final del linaje: última cosecha, archivado de los repos de método, los casos de éxito siguen vivos | aceptado |
| [0006](0006-plan-efimero.md) | El plan de trabajo: efímero, con hogar persistente fuera de git (`/.jidoka/plan-actual.md`) | aceptado |
| [0007](0007-homologacion-de-los-muros.md) | La homologación de los muros: `review-stop`, `gemba-stop` y el auditor del grafo, cosechados de los casos de éxito | aceptado |
| [0008](0008-el-instalador.md) | El instalador mínimo: PowerShell-first, siembra leyendo del árbol sin duplicar, un arquetipo (docs-as-code) | aceptado |
| [0009](0009-arquetipos-ejecutables.md) | Los arquetipos ejecutables (matriz-como-manifiesto) y la poda a dos (docs-as-code + code-first; doc-only diferido) | aceptado (delegado · revisable) |
| [0010](0010-roster-y-modo-desatendido.md) | El roster completo (`devops`), el modo desatendido general, y el casting neutral+persona (Homologación Etapa 1) | aceptado |
| [0011](0011-homologacion-cosecha-sgi.md) | Cosecha de SGI: token neutral en la ley (`escribano` en minúscula) y tres maduraciones al casting (Homologación Etapa 2) | aceptado |
| [0012](0012-lazo-sincronizacion-labs.md) | El lazo de sincronización labs↔Jidoka: sello de versión + `-Actualizar` (tres vías por hash) + aviso de divergencia + canal de subida | aceptado |
| [0013](0013-primera-cosecha-por-el-lazo.md) | Primera cosecha por el lazo: tres lecciones de campo absorbidas (gemba-stop rastreado, excepción de dominio con nombre, criterio de delegación) | aceptado |
| [0014](0014-listo-para-1.0.md) | Jidoka listo para 1.0: cerrar los bloqueantes de "corre en un repo ajeno" (instalador pregunta arquetipo, sembrar el método, fixture del quickstart, guía empezar-de-cero) | aceptado |
| [0015](0015-segunda-cosecha-por-el-lazo.md) | Segunda cosecha por el lazo: el mecanismo probado en producción (2 labs bajados) y las cuatro lecciones que suben (sello pristina-vs-customizada, estado-motor por-hash, drift estructural, épica `.local` code-first) | aceptado |
| [0016](0016-licencia-mit-consciente.md) | Licencia: MIT para máxima adopción (decisión consciente, no heredada; el camino copyleft no tomado) | aceptado |
| [0017](0017-jidoka-1.0.md) | Jidoka 1.0.0: el criterio de "corre en un repo ajeno", cumplido con evidencia (2 labs, 2 lenguajes, CI verde server-side) | aceptado |
| [0018](0018-muro-grietas-2-5.md) | El muro cumple lo que promete: grietas 2 (`no-memorias` cubre Bash) y 5 (registro de disparos cableados, testeable) cerradas con invariantes | aceptado |
| [0019](0019-lazo-ve-la-divergencia.md) | El lazo ve la divergencia: `instalar.ps1 -Sellar` (sello bootstrap clasificador pristina-vs-customizada) + `estado-motor -Detallado` (divergencia por-hash) | aceptado |
| [0020](0020-release-derivado-del-ssot.md) | El release se deriva del SSOT: `publicar.ps1` corta el tag+notas desde `version.txt`+CHANGELOG y corre la suite antes de publicar (Jidoka-only) | aceptado |
| [0021](0021-lazo-agnostico-al-eol.md) | El lazo es agnóstico al fin de línea: `Get-MotorHash` normaliza a LF (un hijo `eol=lf` reconcilia por contenido, no por bytes) — defecto cazado al bajar a TF | aceptado |
| [0022](0022-lista-de-exclusion-del-hijo.md) | La lista de exclusión del hijo: el sello declara `excluir: [rutas]` y el lazo no las re-agrega — mata el back-out recurrente (drift estructural, ADR 0015 #3) | aceptado |
| [0023](0023-estructura-canonica.md) | La estructura canónica: comandos namespaced (`/jidoka:*`, seguro de colisión), el rol neutral es el mecanismo, el nombre del skill es sabor de instancia (persona OK) — cierra el drift estructural | aceptado |
| [0024](0024-el-motor-se-lee-del-arbol.md) | El motor se lee del árbol (no "solo en kit/"): cierra la decisión abierta del ADR 0003 — no hay duplicación que eliminar, migrar la crearía, el dogfood ya lo cubre `probar-instalador` | aceptado |
| [0025](0025-git-idioma-nativo.md) | El substrato es git porque es el idioma nativo del agente: una API se degrada con el agente, git no (sincronizar = lógica de registry, interfaz de git) — cierra el porqué-git del ADR 0008, con el experimento de 3 agentes frescos como evidencia | aceptado |
| [0026](0026-cosecha-brownfield.md) | Cosecha brownfield: el instalador no era consciente de la instancia ni del arquetipo del hijo — cinco arreglos (#34–#38) cazados al bajar el método a repos reales (SGI, TequiOBD) | aceptado |
| [0027](0027-ruta-de-actualizacion-no-cuelga-del-instalador.md) | La ruta de actualización no cuelga de que `instalar.ps1` sea legible: el fallback `sembrar-manual.ps1` (independiente, menor superficie de AV) + `estado-motor` degrada con gracia — cazado en un repo regulado Windows con AV (#40/#43) | aceptado |
