# HANDOFF — relevo entre sesiones

> Estado en vuelo y pendientes. **Se llena al cerrar**, **se lee y se limpia al abrir.** Nada de memorias de la IA — todo va aquí.

## En una frase

**Jidoka** — el Sistema de Producción Toyota para agentes de IA: fusión de doctrina + método + ritual de sprint. Instalador `npx jidoka-method init` en camino (Sprint 3, ver `ROADMAP.md`). Se construye por sprints, usando su propio ritual (dogfooding).

## Dónde estamos (2026-07-11, apertura de sesión — HANDOFF saneado contra git/GitHub)

- **Todo lo construido está MERGEADO y PUBLICADO.** PRs #1–#11 en MERGED; último tag `v0.9.0-beta`; `main` limpio en `7f99ae3`. Sprints 0–2 completos, Sprint 3 Fases 3.A y 3.B en `main` (`v0.7.0`/`v0.8.0-beta`), Homologación Etapa 1 en `main` (`v0.9.0-beta`, ADR 0010).
- **Homologación (una sola metodología entre Jidoka, SGI y TF) — Etapa 2 EN CURSO.**
  - **SGI: auditoría full-join hecha y cosecha mergeada** (PR #11, ADR 0011): la maquinaria descendió byte-idéntica; token neutral corregido en la ley (`"Escribano"` → `"escribano"`) y 3 maduraciones ascendidas a los asientos (`arquitecto-doc`, `escribano`, `revisor-visual`). Confirmado: no queda lección de método de SGI que Jidoka desconozca; los huecos restantes son maquinaria diferida (Fase 3.C).
  - **TF (tracker-financiero): PENDIENTE** — su adopción/auditoría full-join, en su rama, reversible, conservando su casting como personas y su config-instancia. Un lab a la vez, su propio plan. Sus pendientes viven en SU HANDOFF, no aquí.
- **Sprint 3 · Fase 3.C — lo diferido (ver `ROADMAP.md`):** arquetipo `doc-only`/regulado, matriz de piezas fina, CLI npm + SSOT de versión + release-CI, multiplataforma (`.sh`/`pwsh`), barreras code-first de stack, dogfood completo del ADR 0003 (auto-instalación desde `kit/`), enlaces de método que el instalador no siembra (deuda ADR 0008).
- **Grietas de auditoría abiertas:** **grieta 2** (`no-memorias` solo `Write|Edit`, no Bash — documentada como frontera en `andon/README.md`) y **grieta 5** (disparos sin cablear — cada hook nuevo ya consume los suyos; queda catálogo sin punto de inyección). Grietas 1 y 3 cerradas/aceptadas; grieta 4 → Sprint 4.
- **Sprint 4 — Beta estable**: guías completas, presentación pública, candidato a `v1.0` cuando el método corra end-to-end en un repo ajeno.

## Autorizaciones vigentes del cliente (dichas con nombre, 2026-07-10)

- **Publicar releases de GitHub**: "Eres libre y autorizado para publicar versiones" — el ritual tag + release del cierre de sprint no necesita re-autorización.
- **Merges de PR y cambios de configuración/permisos**: SIGUEN necesitando orden nombrada cada vez ("no me muevas configuración", dicho explícito).

## Checklist humana (el cordón es tuyo)

- [x] **El GIF del gate** — hecho en sesión (2026-07-11): generado de una corrida real en SGI, incrustado en el README (`docs/assets/gate-bloqueando.gif`; procedencia en `docs/guias/guion-gif-del-gate.md`).
- [ ] **Social preview** (solo se puede desde la UI) — receta en `ROADMAP.md` → *Vitrina pública* ⏳2.
- [ ] **Dos decisiones que solo tú puedes tomar**: el párrafo en inglés del README y el ADR de la licencia (MIT vs copyleft) — argumentos completos en `ROADMAP.md` → *Vitrina pública* ⏳4 y ⏳5.

## Qué sigue (en orden de valor — detalle en ROADMAP.md)

1. **Homologación Etapa 2 — TF adopta el núcleo** (el único lab que falta; cierra la homologación).
2. **Vitrina pública ⏳3** que no requiere humano: `CODE_OF_CONDUCT.md` (+ preparar los archivos del GIF para la grabación humana).
3. **Sprint 3 · Fase 3.C** (por valor: CLI npm/SSOT de versión, multiplataforma) y **grietas 2 y 5**.
4. **Sprint 4 — Beta estable** (incluye la grieta 4: evidencia pública del linaje).
