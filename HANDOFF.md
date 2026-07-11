# HANDOFF — relevo entre sesiones

> Estado en vuelo y pendientes. **Se llena al cerrar**, **se lee y se limpia al abrir.** Nada de memorias de la IA — todo va aquí.

## En una frase

**Jidoka** — el Sistema de Producción Toyota para agentes de IA: fusión de doctrina + método + ritual de sprint. Instalador `npx jidoka-method init` en camino (Sprint 3, ver `ROADMAP.md`). Se construye por sprints, usando su propio ritual (dogfooding).

## Dónde estamos (2026-07-11, cierre de la sesión de vitrina)

- **Todo MERGEADO y PUBLICADO hasta `v0.10.1-beta`.** PRs #1–#12 en MERGED; `main` limpio. Sprints 0–2 completos; Sprint 3 Fases 3.A/3.B publicadas; Homologación Etapa 1 + cosecha de SGI publicadas (`v0.9.0`/`v0.10.0-beta`, ADRs 0010/0011).
- **Sesión de hoy (vitrina, PR #12 → `v0.10.1-beta`):** README reescrito con **7 lectores en frío** como evidencia (Gemba de prosa en `qa_runs/lector-en-frio-readme-20260711/`); **GIF del gate mordiendo** en el README — render fiel de una corrida REAL en SGI (`docs/assets/gate-bloqueando.gif`, procedencia en `docs/guias/guion-gif-del-gate.md`, evidencia en `qa_runs/gif-gate-20260711/`); **SimGhostInputs (público) nombrado y linkeado** como evidencia del linaje (grieta 4 avanzada); quickstart curado tras fact-check hostil (el snippet anterior NO bloqueaba — se reprodujo y se probó la cura en clon); doc-drift interno curado en cascada (versión, tabla de sprints, `docs/sprints/`, `kanban/README`, `empezar-de-cero`, ROADMAP).
- **Lote de hallazgos REGISTRADO en `ROADMAP.md` para una sesión dedicada** (el cliente lo resolverá con una sesión Opus corriendo el método): el instalador que pregunte el arquetipo interactivo (Fase 3.C), el quickstart como caso end-to-end de `probar-gate.ps1` (Fase 3.C), el matiz de la cita Airbus en doctrina (backlog), y las ideas de los lectores sin destino aún (el "GIF del momento del cliente" — un Gemba visto por sus ojos — cuando exista la guía de cero).
- **Panorama registrado en el backlog** (con fuentes): **OpenWiki** (LangChain — complemento, no competidor; jamás meter doc auto-generada dentro de la ley) y **GBrain** (Garry Tan — el "pregúntale al proyecto" en lenguaje llano para no-técnicos, candidato a futuro sobre las docs curadas de este y todo repo sembrado).
- **HOMOLOGACIÓN — Etapa 2, lo que falta: TF (tracker-financiero).** El único lab pendiente de adoptar el núcleo; en su rama, reversible, conservando su casting como personas y su config-instancia. Su plan propio. Sus pendientes viven en SU HANDOFF.
- **El lazo de sincronización labs↔Jidoka — DISEÑO REGISTRADO, pendiente de plan** (pedido del cliente al cierre): *la lección sube (issue `leccion.md` → Jidoka arregla con su ritual), la máquina baja* (sello de versión sembrado + modo `-Actualizar` del instalador que re-siembra solo el motor, nunca la instancia + aviso de divergencia en el hijo). Detalle completo en `ROADMAP.md` → Fase 3.C. SGI es el primer consumidor.
- **Sprint 3 · Fase 3.C — lo diferido** (ver `ROADMAP.md`): `doc-only`, CLI npm + SSOT de versión + release-CI, multiplataforma, barreras code-first, dogfood del ADR 0003, + los dos ítems nuevos del fact-check.
- **Grietas de auditoría:** 1 CERRADA (Fase 2·B) · 2 abierta (`no-memorias` no cubre Bash; confesada como frontera) · 3 aceptada como límite v0 · 4 AVANZADA (SGI público; el resto a Sprint 4) · 5 abierta (disparos sin cablear).
- **Sprint 4 — Beta estable**: guías completas (la de empezar-de-cero es esqueleto), presentación pública, `v1.0` cuando corra end-to-end en un repo ajeno.

## Autorizaciones vigentes del cliente (dichas con nombre)

- **Publicar releases de GitHub** (2026-07-10): "Eres libre y autorizado para publicar versiones" — tag + release del cierre no necesita re-autorización.
- **Merges de PR y cambios de configuración/permisos**: SIGUEN necesitando orden nombrada cada vez ("no me muevas configuración", dicho explícito).

## Checklist humana (el cordón es tuyo)

- [ ] **Social preview** (solo se puede desde la UI) — receta en `ROADMAP.md` → *Vitrina pública* ⏳2. Con el GIF del gate ya hay material visual para derivar la imagen.
- [ ] **Dos decisiones que solo tú puedes tomar**: el párrafo en inglés del README y el ADR de la licencia (MIT vs copyleft) — argumentos en `ROADMAP.md` → *Vitrina pública* ⏳4 y ⏳5.
- [ ] **La sesión Opus del lote de hallazgos** — cuando tengas límite fresco: los pendientes están en `ROADMAP.md` (Fase 3.C nuevos + backlog), cada uno con contexto para retomarse sin re-explicación.

## Qué sigue (en orden de valor — detalle en ROADMAP.md)

1. **Homologación Etapa 2 — TF adopta el núcleo** (el único lab que falta; cierra la homologación).
2. **El lote de hallazgos del ROADMAP** en sesión dedicada corriendo el método.
3. **Sprint 3 · Fase 3.C** (por valor: CLI npm/SSOT de versión, multiplataforma) y **grietas 2 y 5**.
4. **Sprint 4 — Beta estable** (incluye el resto de la grieta 4: evidencia pública del linaje).
