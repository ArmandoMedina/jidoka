# ADR 0019 — El lazo ve la divergencia: sello bootstrap clasificador + `estado-motor -Detallado`

- **Estado:** aceptado
- **Fecha:** 2026-07-11

## Contexto

La [segunda cosecha por el lazo](0015-segunda-cosecha-por-el-lazo.md) (ADR 0015) registró dos huecos del
mecanismo, destapados al bajar el núcleo a los dos labs en Sprint B:

1. **El sello inicial de un lab ya-divergido no distinguía pristina de customizada.** El sello de SGI había
   grabado sus piezas code-first como semilla pristina → un `-Actualizar` las habría **pisado**. Se parcheó a
   mano (SGI: quitar esas entradas; TF: semilla vacía), pero `instalar.ps1` seguía sin saber sellar bien un
   hijo que convergió a mano.
2. **`estado-motor.ps1` comparaba solo la *versión* declarada del sello**, no las piezas. Reportaba "al día"
   aunque una pieza divergiera — la divergencia fina era invisible.

Este ADR implementa las dos curas (mecánica de Jidoka; no tocó los labs).

## Decisión

1. **`instalar.ps1 -Sellar`**: escribe el sello inicial de un hijo que ya tiene el motor pero convergió a mano,
   **clasificando cada pieza de mecánica** contra el Jidoka actual:
   - hijo **== Jidoka** → *pristina*: la registra en la semilla con el hash de Jidoka (así el próximo
     `-Actualizar` la actualiza).
   - hijo **!= Jidoka** → *customizada*: **NO la registra** (semilla sin ella) → el próximo `-Actualizar` la
     ve `child != seed=null` ⇒ **DIVERGE** y la **preserva**.
   - hijo ausente → se omite (el `-Actualizar` la agregará).

2. **`estado-motor.ps1 -Detallado`**: además de la versión, compara **pieza por pieza (por hash)** el motor del
   hijo contra el de Jidoka (leyendo el manifiesto de Jidoka), y lista las que **DIVERGEN** o faltan (las al
   día solo se cuentan, para bajar el ruido). El mensaje de versión pasa de *"estás al día"* a *"declara la
   versión X"* — más honesto: la versión es de grano grueso; el detalle por-hash es la verdad fina.

## Por qué

- **Generaliza el arreglo manual de los labs en la máquina** (la lección subió, la máquina mejora): en vez de
  repetir a mano "quita las entradas code-first" en cada lab, `-Sellar` lo hace clasificando.
- **`-Sellar` es más correcto que las dos aproximaciones manuales**: mejor que *asumir-pristina* (el bug que
  casi pisa SGI) y mejor que *semilla-vacía* (TF: preserva todo, pero entonces `-Actualizar` tampoco actualiza
  lo pristino). Clasificar pieza por pieza baja lo pristino y preserva lo customizado.
- **Estas mejoras son la herramienta de la propia bajada.** Hacerlas *antes* de la próxima bajada a los labs
  la vuelve más limpia: se re-sella cada lab con `-Sellar` y `estado-motor -Detallado` muestra exactamente qué
  diverge.

## El camino que NO se toma (y por qué tienta)

- **Que `-Sellar` intente adivinar la versión histórica de la que vino cada pieza** (comparando contra el
  árbol de Jidoka en cada tag). Tienta por precisión, pero es frágil y caro (requiere la historia completa de
  Jidoka a la vista) y no aporta: para el objetivo —¿pristina o customizada *hoy*?— basta comparar contra el
  Jidoka actual. Una pieza que es idéntica a la actual es segura de registrar; cualquier otra se preserva.
- **Dejar `estado-motor` en "al día" por versión y no listar piezas.** Tienta por simple, pero es la
  sobre-afirmación que la cosecha señaló: un tablero verde que oculta divergencia es un gate podrido
  (`prueba-de-vida-del-gate` aplicado al aviso).

## Consecuencias

- `instalar.ps1` gana el modo `-Sellar`; `estado-motor.ps1` gana `-Detallado`. Ambas son mecánica → bajarán a
  SGI y TF en la próxima ventana de bajada, y el re-sellado de los labs usará `-Sellar` (corrige de raíz el
  sello que se parcheó a mano en Sprint B).
- Quedan **dos** de las cuatro lecciones de ADR 0015 hechas; siguen abiertas el drift estructural núcleo↔labs
  y la épica `.local` code-first (esta última se hace *en* la ventana de bajada, porque toca los tests de SGI).
- Evidencia: `probar-instalador.ps1` 41/41 (6 casos nuevos: `-Sellar` clasifica y preserva, `-Detallado` ve la
  divergencia por-hash). Versión `v1.2.0`.
