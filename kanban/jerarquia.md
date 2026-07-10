# La jerarquía QUÉ / CÓMO — dos sombreros y un puente

> El QUÉ (producto) y el CÓMO (ingeniería) se separan a propósito: **quien define qué hace el sistema no tiene que saber cómo se construye, y viceversa.** Heredado del andamio del linaje (ADR [0004](../docs/decisions/0004-centralizacion-del-conocimiento.md)); mapea a marcos profesionales (DDD, C4, arc42, Diátaxis, MADR) — no es invento.

## Los dos sombreros

- **QUÉ y PORQUÉ** — sombrero de Producto. Vive en `product/`: qué debe hacer el sistema, descrito por comportamiento, nunca por implementación.
- **CÓMO** — sombrero de Ingeniería. Vive en `engineering/` + el código: qué pieza real lo soporta y cómo se implementa.
- **El puente entre ambos son los ADR** (`docs/decisions/`): cada decisión que cruza de un lado al otro queda registrada con su porqué.

## La jerarquía del QUÉ — 5 niveles

De lo amplio a lo atómico, cada nivel responde una pregunta:

| Nivel | Pregunta que responde |
|---|---|
| **Ecosistema** | ¿En qué universo vive esto? (telón de fondo, rara vez una nota) |
| **Producto / Solución** | ¿Qué cosa entrega valor y se puede nombrar? (normalmente un repo = un producto) |
| **Dominio** | ¿Qué área de responsabilidad coherente? — define alcance y **fuera de alcance** |
| **Módulo** | ¿Qué pieza funcional dentro del dominio? (agrupa capacidades) |
| **Capacidad** | ¿Qué puede hacer el sistema, **exactamente**? |

La **capacidad es la unidad atómica**: se describe por comportamiento + criterios de aceptación en Gherkin (`Dado que… cuando… entonces…`), nunca por implementación. Una capacidad no se revisa aislada — siempre contra su módulo, su dominio y su alcance.

Del lado del CÓMO, dos tipos de nota se conectan a las capacidades: el **componente del sistema** (¿qué pieza real lo soporta? — BD, API, plataforma) y la **especificación técnica** (¿cómo se implementa una capacidad concreta?).

## Claves estables de trazabilidad

Módulos, capacidades y specs llevan una `clave:` en su frontmatter que **no cambia al renombrar**: `FAM-MOD` (módulo), `FAM-MOD-NN` (capacidad, hereda el prefijo de su módulo), `TEC-<ORIGEN>-NN` (spec). Los cambios se propagan por el grafo usando la clave, no el título.

## Las reglas de oro

- **Define el comportamiento para que cualquiera implemente sin inventar reglas de negocio.** Lo ambiguo se **marca**, no se inventa.
- **Regla de negocio ≠ criterio de aceptación.** La regla dice *qué es verdad*; el criterio dice *cómo lo pruebas*.
- **¿Dónde va cada cosa?** Ante la duda de nivel, **sube uno**.

## Dónde está el ejemplo vivo

Esta jerarquía corre en producción en el repo más maduro del linaje (caso interno: 22 capacidades, 14 módulos, 9 dominios, con un auditor determinista del grafo que valida frontmatter, wikilinks y Gherkin de las capacidades vigentes). Las plantillas y el auditor llegan al kit en los Sprints 2-3 ([ROADMAP](../ROADMAP.md)); el conocimiento no espera a la máquina.
