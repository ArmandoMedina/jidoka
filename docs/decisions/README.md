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
