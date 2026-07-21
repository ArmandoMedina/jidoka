# Muertos del Roadmap — Jidoka

> **El archivo de muertos del roadmap.** Aquí cae lo vencido, movido por [`tools/expirar.ps1`](../tools/expirar.ps1) con **fecha** y **motivo** (la clase de servicio, su alta y la fecha en que venció). El vencimiento es por clase de servicio (`vencimiento_dias` en [`tools/flujo.json`](../tools/flujo.json)): «Con fecha» muere si su `vence:` ya pasó; Urgente/Normal/«Algún día» mueren si `alta + su ventana < hoy`; Referencia nunca muere.
>
> **Revivir = re-proponer.** Nada vuelve solo: para resucitar un ítem, agrégalo de nuevo al `ROADMAP.md` con **alta nueva** — no se recupera desde aquí. Esto convierte podar de *decisión-que-nadie-toma* en *evento-que-ocurre-solo* (el circuit breaker de Shape Up: la muerte por defecto).

<!-- Las entradas las appendea tools/expirar.ps1 bajo un encabezado ## AAAA-MM-DD (la fecha en que corrió la poda). Aún sin entradas. -->
