# ADR-0009: Revocación de credencial — evento `CredentialRevoked`, API y propagación de caché con TTL

## Estado
Aceptado

## Contexto
`data-model-conceptual.md` define `DASID.estado (activo | revocado)`, pero
`architecture-reviewer` (Iteración 1) encontró que ningún ADR, API o evento
define qué dispara esa transición ni cómo se propaga a las cachés
identificadas (la del backend de Identidad, la caché local de "recientemente
validadas" de Captura introducida en ADR-0006, y la caché del Dispositivo
DAS de ADR-0005). El único evento publicado por Identidad era
`CredentialIssued` — ninguno de revocación (**DRV-03**, **REQ-09**).
Escenario real: un estudiante es expulsado o reporta su insignia como
perdida/robada; sin este mecanismo, el usuario revocado podría seguir
registrando asistencia válida hasta que expire un TTL no especificado.
`knowledge/we7.md` desarrolla Agregados con consistencia inmediata dentro
del límite transaccional (aplicable a `DASID` como entidad raíz);
`knowledge/we3.md`/`we4.md` desarrollan mensajería asíncrona como mecanismo
de propagación de cambios de estado entre contextos.

## Decisión
Se agrega una nueva API en Identidad y Credenciales:

`POST /identity/{dasId}/revoke` (uso exclusivo del personal administrativo,
vía BFF Web), con `motivo` (ej. baja, insignia reportada perdida/robada,
expulsión).

Al invocarse, Identidad transiciona `DASID.estado = revocado` de forma
**inmediata** en su propio almacén (consistencia inmediata dentro del
agregado, ya declarado como criterio de este contexto en
`bounded-contexts.md`) y publica el evento
**`CredentialRevoked (dasId, motivo, revocadoEn)`**.

Consumidores de `CredentialRevoked`:
- **Captura de Asistencia**: invalida inmediatamente la entrada de ese
  `dasId` en su caché local de "recientemente validadas" (ADR-0006). Si el
  Circuit Breaker está Abierto (modo degradado), la entrada se elimina
  explícitamente, forzando fail-closed para ese `dasId` específico incluso
  en modo degradado — prioriza DRV-03 sobre DRV-05 exactamente en el caso
  que el reviewer señaló.
- **Endpoint de sincronización de caché de dispositivo** (ADR-0008):
  incluye la revocación en el próximo delta que devuelve, para que el
  dispositivo purgue la credencial en su siguiente ciclo de refresco.
- **Notificaciones**: notifica al usuario afectado (transparencia,
  consistente con el patrón ya usado para otros cambios de estado).

**TTL explícito**: se fija como cifra de diseño un TTL máximo de caché de
credencial de **15 minutos**, tanto en la caché de "recientemente
validadas" de Captura (ADR-0006) como en la caché del Dispositivo DAS
(alineado con el intervalo de refresco de ADR-0008). En el peor caso (ej.
circuito Abierto simultáneamente con la revocación, o dispositivo offline),
una credencial revocada puede seguir siendo aceptada hasta un máximo de 15
minutos después de la revocación. Se declara explícitamente como el
trade-off aceptado entre disponibilidad de captura (DRV-05) y exactitud
inmediata de revocación (DRV-03), resolviendo la ambigüedad de TTL que
ADR-0005 había dejado abierta.

## Alternativas consideradas

### Alternativa A: Revocación solo por expiración pasiva de TTL, sin evento activo
- **Pros**: no requiere nuevo evento ni nuevos consumidores.
- **Contras**: desperdicia la oportunidad de cerrar la ventana de exposición
  de inmediato en el caso común (Captura online, circuito Cerrado, donde sí
  es posible invalidar activamente).
- **Por qué no se eligió**: el TTL pasivo de 15 min queda como **peor caso
  ya aceptado** (fallback), pero no como único mecanismo — se prefiere
  invalidación activa cuando es posible.

### Alternativa B: Consistencia fuerte (sin caché, validar siempre contra Identidad en cada escaneo)
- **Contras**: reintroduce el punto único de fallo síncrono que ADR-0005 y
  ADR-0006 ya evitaron deliberadamente.
- **Por qué no se eligió**: contradice directamente ambos ADRs y DRV-05.

## Consecuencias

**Positivas**
- Cierra el hallazgo de revocación no modelada con un mecanismo activo
  (evento) y una cota explícita (TTL 15 min) para el caso pasivo.
- Consistente con el resto del diseño de caché en capas (ADR-0005,
  ADR-0006, ADR-0008).

**Negativas / deuda que se acepta**
- Nuevo evento y nuevos consumidores en Captura de Asistencia,
  Notificaciones y en el canal de sincronización del Dispositivo DAS.
- El TTL de 15 minutos es una ventana de exposición **aceptada**, no
  eliminada — DRV-03 no queda en riesgo cero.

**Riesgos que quedan abiertos**
- El valor de 15 minutos no está validado contra el apetito de riesgo real
  de UPCA para credenciales robadas/perdidas — `architecture-risk`
  (Milestone 3) podría necesitar ajustarlo si el escenario de robo físico
  de insignia resulta más frecuente/crítico de lo asumido aquí.

## Referencias
- `knowledge/we7.md` — Agregados, consistencia inmediata dentro del límite
  transaccional.
- `knowledge/we3.md`, `knowledge/we4.md` — mensajería asíncrona como
  mecanismo de propagación de estado.
- `design/traceability.md` — DRV-03, REQ-09.
- `design/adr/adr-0006-circuit-breaker-captura-identidad.md` — caché
  invalidada por este evento.
- `design/adr/adr-0008-refresco-cache-dispositivo-via-captura.md` — canal
  de propagación hacia el Dispositivo DAS.
- `design/milestone-2/data-model-conceptual.md` — `DASID.estado`.
- `design/milestone-2/bounded-contexts.md` — contexto Identidad y
  Credenciales, nueva API y evento.

## Nota de revisión — Milestone 3 (DEC-0013)

`design/adr/adr-0013-monolito-modular-fase1-extraccion-selectiva.md`
(`DEC-0013`) simplifica drásticamente la propagación de revocación descrita
en este ADR durante la Fase 1: con una única fuente de verdad
(`DASID.estado`) dentro de un esquema/namespace lógico compartido en el
mismo almacén del monolito, ya no existen las tres cachés distribuidas
físicamente independientes que este ADR sincroniza (caché de Identidad,
caché de "recientemente validadas" de Captura vía ADR-0006 — en pausa en
Fase 1, ver su propia nota de revisión — y caché del Dispositivo DAS vía
ADR-0008 — también en pausa). En Fase 1, una consulta de credencial puede
leer `DASID.estado` con consistencia inmediata dentro del mismo proceso, o
vía la caché local que sí sigue vigente (Dispositivo DAS, ADR-0005, que no
depende de la topología de despliegue del backend), reduciendo la ventana
de exposición del TTL de 15 minutos al escenario ya cubierto por ADR-0005
(dispositivo desconectado), no a una cadena de sincronización entre
servicios.

Lo que **se mantiene íntegramente vigente, sin cambios conceptuales**: la
API `POST /identity/{dasId}/revoke`, el campo `DASID.estado = revocado` con
consistencia inmediata, y el evento `CredentialRevoked` como el mecanismo
de propagación — publicarlo sigue siendo válido y necesario en Fase 1
(Notificaciones sigue siendo un módulo separado que lo consume de forma
asíncrona), y su contrato queda listo sin cambios para el momento en que,
en Fase 2, vuelvan a existir cachés distribuidas físicamente independientes
que sincronizar.
