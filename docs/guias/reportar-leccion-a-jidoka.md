# Reportar una lección a Jidoka — la subida del lazo

> *La lección sube, la máquina baja.* Este repo trae maquinaria (hooks, gates, ritual)
> sembrada por [Jidoka](https://github.com/ArmandoMedina/jidoka). Cuando la usas y
> descubres algo —una regla que faltó, un gate que se pudrió, una idea que el método
> debería absorber— **no parchees tu maquinaria local**: repórtalo hacia arriba. Jidoka
> lo arregla con su propio ritual y tú bajas la corrección. Así las versiones no divergen.

## Por qué no lo arreglas aquí

Tu maquinaria del método (la sección `motor`: `verificar/auditar/probar-*`, hooks,
comandos y skills genéricos) es **común a todos los repos que siembran Jidoka**. Si la
parcheas solo aquí, tu copia diverge y el próximo `-Actualizar` te lo marca como conflicto.
El arreglo vive **una vez**, en Jidoka, y baja a todos. Tu **instancia** (tu ley
`blast-radius.json`, tu `product/`, tus ADRs, tu casting) sí es tuya y nunca se toca.

## Cómo subir una lección

1. **Ábrela con el helper** (abre el issue prellenado en el navegador):

   ```powershell
   ./tools/reportar-leccion.ps1
   ```

   O a mano: `https://github.com/ArmandoMedina/jidoka/issues/new?template=leccion.md`.

2. **Escribe la lección en una frase**, dónde la pagaste (anonimiza — disparo
   `frontera-nda`: nunca nombres de clientes, montos ni repos de trabajo; "caso N" basta)
   y qué haría Jidoka distinto.

3. **Regla 2-3**: 2-3 usos reales antes de que una lección se vuelva regla. Un solo uso
   también vale registrarlo: queda esperando su segundo.

## Cómo bajar la corrección

Cuando Jidoka publique el arreglo, corre desde el repo Jidoka apuntando a este repo:

```powershell
./tools/instalar.ps1 -Destino <ruta-de-este-repo> -Actualizar
```

Re-siembra **solo** la mecánica que no tocaste; lo que customizaste se preserva y se te
deja al lado como `<archivo>.jidoka-nuevo` para que reconcilies a mano (o muevas tu ajuste
a la costura `tools/verificar.local.ps1`). Corre en una rama → revisa el diff → PR.
Para saber si estás atrás: `./tools/estado-motor.ps1 -Jidoka <ruta-de-Jidoka>`.

## Cómo se acusa una lección (el lado del mantenedor)

*La lección sube y la máquina baja — pero entre las dos hay un tercer paso que sostiene el
canal: **el acuse**.* Quien reporta desde un repo real se tomó el trabajo; el silencio (o un
"no" seco) mata la confianza en el canal. Todo reporte recibe respuesta, y esa respuesta hace
**tres cosas**:

1. **Acusa que llegó y se entendió** — repetir la lección en tus palabras prueba que la leíste.
2. **Dice qué se decidió y por qué**, con el mecanismo del método por delante (regla 2-3), no
   como capricho del mantenedor.
3. **Deja rastro y disparador** — dónde quedó registrado (ROADMAP/ADR/versión) y **qué la haría
   avanzar** — para que no sea un agujero negro.

Hay dos formas según el destino de la lección:

**A — la lección que SÍ se construyó.** Acusa, di **en qué versión** quedó y con qué artefacto,
cómo bajarla (`-Actualizar`), y **cierra** el issue al mergear.

> Gracias — reproducido y entendido: *\<la lección en tus palabras\>*. Arreglado en `vX.Y.Z`
> (ADR NNNN): *\<qué se construyó\>*. Bájalo con `-Actualizar`. Cierro al mergear.

**B — la lección diferida por regla 2-3.** No es un rechazo: es "1er/2º uso real registrado,
esperando el siguiente". Nombra dónde quedó, **deja el issue abierto** e **invita al siguiente
caso** como el disparador explícito.

> Gracias — la lección quedó clara: *\<en tus palabras\>*. La registramos, no la estrenamos
> todavía — por la misma **regla 2-3** que tu reporte invoca (Nº uso real; se construye cuando
> aparezca el siguiente), para no cristalizar la abstracción alrededor de un solo caso. Queda en
> `ROADMAP.md` con contexto completo y el issue sigue **abierto** con la etiqueta `regla-2-3`.
> **Si te vuelve a morder en otro caso, coméntalo aquí: ese es el que lo asciende.**

Etiqueta cada issue del canal: `leccion` (toda lección), `bug` (si además es un defecto
reproducible), `regla-2-3` (si queda esperando su siguiente uso). Cerrar es para lo resuelto;
lo diferido **se deja abierto a propósito** — el issue abierto *es* el marcador del contador 2-3.
