# product/ — el grafo del QUÉ

El QUÉ de Jidoka en lenguaje llano: **dominios → módulos → capacidades**, cada nota con frontmatter (`tipo`, `estado`) y enlazada por wikilinks `[[...]]`. Es el grafo que `tools/auditar.ps1` mantiene íntegro (frontmatter, links, criterios de las capacidades `vigente`, huérfanas), modulado por estado (`kanban/estados.md`).

> Seed mínimo (Sprint 2 · Fase B): las dos capacidades ancla del método. El PRODUCT_BRIEF completo y las plantillas de producto llegan en el Sprint 3.

- **Dominio:** [[Metodo]]
- **Módulos:** [[MOD-ritual]] · [[MOD-andon]]
- **Capacidades:** [[RIT-1-ritual-ejecutable]] · [[AND-1-muro-andon]]

Aquí viven también dos notas hermanas con dueño claro: [[PRODUCT_BRIEF]] — el **QUÉ** de Jidoka consolidado en una página (`tipo: brief`) — e [[infra]] — el **CÓMO-operativo**: identidades, máquinas y convenciones que la sesión no debe preguntar (`tipo: recursos`).
