# Recursos del proyecto — [nombre del proyecto]

> **Lo que la sesión no debe preguntarte al abrir.** Punteros a lo que el trabajo necesita: material de referencia, identidades por servicio, máquinas y ambientes. `/jidoka:arranca` lo lee al abrir para no re-preguntar sesión tras sesión.
>
> **Regla dura: punteros, nunca secretos.** Aquí van *dónde* está algo y *cómo se llama*, jamás el contenido sensible. Nada de tokens, contraseñas, llaves ni claves de API — esos viven en el gestor de secretos / variables de entorno, y aquí solo se nombra cuál. Este archivo puede o no versionarse según el arquetipo; si versiona, un secreto filtrado aquí es un secreto en el historial de git para siempre (afín al disparo `frontera-nda`).

## El casting

> **Quién ocupa cada asiento del método, por nombre.** `/jidoka:arranca` lee esta sección para **sentar la sesión** en su rol y anunciarlo. El *rol* es el mecanismo (lo neutral que la ley y los hooks entienden; ver `kanban/roles.md`); el *nombre* es sabor de instancia — mapearlo a una persona lo vuelve memorable y deja claro quién responde por qué (ADR 0023). Sin esta sección, la sesión cae a los roles neutrales.

| Asiento (rol del método) | Nombre | Quién lo ocupa / cuándo |
|---|---|---|
| orquestador | [nombre] | El hilo principal: decide y teje, delega lo pesado. |
| escribano | [nombre] | Sincroniza los docs dueños según la ley; cierra el drift. |
| revisor-visual | [nombre] | Gemba: corre el demo con datos reales y deja evidencia en `qa_runs/`. |
| validador | [nombre] | Validación por medición: corre el motor determinista contra golden-masters. |

> Enciende solo los asientos que este repo merece (menú, no molde). Para personalizar el casting —incluido volver un asiento un skill con nombre propio— ve `kanban/roles.md` → **"Personalizar el casting"**.

## Material de referencia

[Docs, specs, diseños, tickets que la sesión debe conocer. Puntero + una línea de qué es. Ej: "El brief de producto vive en `product/PRODUCT_BRIEF.md`". "El diseño de la API está en Figma, proyecto X (link en el ticket JIRA-123)."]

## Identidades por servicio

[Con qué cuenta/usuario se opera cada servicio — el *nombre*, no la credencial. Ej: "GitHub: se pushea como `usuario`; el remoto es `origin`." "Deploy: cuenta `proj-prod` en el servicio Y; el secreto se llama `DEPLOY_TOKEN` y vive en las Actions secrets del repo."]

## Máquinas y ambientes

[Dónde corre y se prueba esto. Ej: "Dev en Windows 11 / PowerShell 5.1 (ver `docs/guias/entorno-windows-powershell51.md`)." "Ambiente de prueba limpio: <cuál, cómo se levanta, qué NO tiene>." Nombra el ambiente bueno y el feo si hay varios, para que la sesión sepa cuál usar para qué.]

## Convenciones que no se re-preguntan

[Decisiones operativas ya tomadas que la sesión debe respetar sin volver a consultarlas. Ej: "Los commits no llevan trailer de sesión (ADR 000X)." "La rama de trabajo se saca de `main`, nunca se commitea directo."]
