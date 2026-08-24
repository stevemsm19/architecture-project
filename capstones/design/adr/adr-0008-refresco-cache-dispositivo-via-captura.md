# ADR-0008: Refresco de caché de credencial del Dispositivo DAS vía Captura de Asistencia (no directo a Identidad)

## Estado
Aceptado (mecanismo corregido en iteración extra puntual, ver "Nota de
iteración extra" al final del Contexto)

## Contexto
`architecture-reviewer` (Iteración 1) confirmó una ambigüedad ya señalada
por `architecture-modeler` en `design/diagrams/NOTES.md` (punto 3):
ADR-0005 dice que la caché del Dispositivo DAS "se refresca periódicamente
desde Identidad y Credenciales", pero `bounded-contexts.md` solo nombra a
**Captura de Asistencia** como consumidor de
`GET /identity/{dasId}/credential/validate`. No es un detalle de dibujo:
cambia el perímetro de seguridad (**DRV-03**) y el perfil de carga de
Captura de Asistencia (**REQ-06**, **DRV-05**). Si el Dispositivo DAS
llamara directamente a Identidad, se expondría esa API a dispositivos
físicos en 20 campus; si el refresco pasa por Captura, ésta absorbe tráfico
adicional no contemplado en su perfil de carga original.
`knowledge/we7.md` define el Context Mapping **Conformista/Servicio Host
Abierto**, ya usado en `bounded-contexts.md` para la relación Identidad →
Captura; `knowledge/we6.md` señala el acoplamiento débil vía "bounded
contexts + ACL" y advierte contra ampliar innecesariamente la superficie
expuesta de un contexto con datos sensibles.

### Nota de iteración extra (post-revisión `architecture-reviewer`, Iteración 2)

`review-log.md` (Iteración 2) confirmó que la ambigüedad de *dibujo* (quién
llama a quién: Dispositivo → Captura, nunca Dispositivo → Identidad) había
quedado resuelta, pero encontró un hallazgo nuevo de severidad **Alta**
sobre el *mecanismo interno* declarado en este mismo ADR: la versión
anterior decía que "internamente Captura obtiene el delta de Identidad
mediante una llamada backend-a-backend... protegida por el mismo Circuit
Breaker de ADR-0006", **reutilizando por nombre**
`GET /identity/{dasId}/credential/validate` — que en todo el resto del
diseño (`bounded-contexts.md`) está descrita como una consulta **por
`dasId` individual**, sin parámetro `since=<timestamp>` ni respuesta en
lote. Implementado tal cual, Captura tendría que iterar sobre miles de
`dasId` conocidos cada ~15 minutos para reconstruir algo parecido a un
delta, saturando exactamente el mismo Circuit Breaker que ADR-0006 diseñó
para proteger el camino síncrono crítico de escaneo en vivo — generando el
propio incidente de "backend degradado" que ADR-0006 busca mitigar. Esta
sección "Decisión" se corrige a continuación para cerrar esa contradicción
con un mecanismo concreto y verificable, sin reabrir la parte ya resuelta
(quién llama a quién).

## Decisión

### 1. Dispositivo DAS → Captura de Asistencia (sin cambios respecto a la versión anterior de este ADR)

El Dispositivo DAS **no** llama directamente a Identidad y Credenciales. El
refresco de su caché local pasa por **Captura de Asistencia**, vía:

`GET /attendance-devices/{dispositivoId}/credential-cache?since=<timestamp>`

Devuelve un **delta** (altas, revocaciones — ADR-0009 —, cambios) de
credenciales válidas para el campus del dispositivo, cifra de diseño: el
dispositivo consulta cada 15 minutos (alineado con el TTL de ADR-0009),
usando el mismo canal de red que ya usa para `POST /attendance-events` — no
se abre un canal nuevo hacia Identidad.

### 2. Captura de Asistencia → Identidad y Credenciales (mecanismo corregido)

Este es el punto que se corrige. El delta que expone el endpoint anterior
**ya no se construye reutilizando la API de validación individual**. Se
construye con dos mecanismos separados, de frecuencia y propósito
distintos:

**(a) Mecanismo primario — proyección local por eventos (estado estable, alta frecuencia)**

Captura de Asistencia mantiene una **proyección local materializada**,
`CredencialesVigentesPorCampus` (dasId, campusId, estado, actualizadaEn),
construida **de forma asíncrona** consumiendo los eventos que Identidad ya
publica en el broker: `CredentialIssued` y `CredentialRevoked`
(`bounded-contexts.md` ya listaba `CredentialIssued` como "consumido...
por la caché de Captura de Asistencia" — esta decisión formaliza y
completa ese consumo, que antes no estaba conectado al endpoint del
dispositivo). Este es el mismo patrón de **Event Broker** (push,
múltiples suscriptores por evento, `knowledge/we3.md`) y de **proyección
CQRS de lado de lectura** (`knowledge/we3.md`/`we4.md`/`we6.md`) que el
propio diseño ya usa para el contexto Reportes y Analítica (proyecta
`AttendanceRecorded` en vistas de lectura) — se aplica aquí el mismo
principio en sentido inverso (Captura como consumidor/proyector de eventos
de Identidad, en vez de productor). El consumo es idempotente
(**Idempotent Consumer**, `we3.md`) frente a reentregas del broker.

`GET /attendance-devices/{dispositivoId}/credential-cache?since=<ts>` se
sirve **enteramente desde esta proyección local** (una consulta filtrada
por `campusId` y `actualizadaEn > since`) — **sin ninguna llamada
síncrona a Identidad en esta ruta**. Esto elimina estructuralmente la
saturación del Circuit Breaker de ADR-0006: ese Circuit Breaker sigue
protegiendo únicamente la llamada síncrona individual
`GET /identity/{dasId}/credential/validate` del camino crítico de escaneo
en vivo (ADR-0006), que nunca se ve tocada por el refresco de caché del
dispositivo.

**(b) Mecanismo secundario — snapshot en lote (arranque en frío / reconciliación, baja frecuencia)**

Se agrega una API nueva en Identidad y Credenciales, explícitamente
separada de la de validación individual:

`GET /identity/credentials/snapshot?campusId=<id>&cursor=<token>`

Exporta en lotes paginados el conjunto de credenciales vigentes de un
campus en un momento dado. Se usa **solo** en dos casos, ambos de baja
frecuencia (no cada 15 minutos por dispositivo):
- **Arranque en frío**: cuando una instancia de la proyección de Captura
  para un campus se crea o se reconstruye sin historial local (ej. nuevo
  despliegue, nuevo campus, pérdida del almacén local).
- **Reconciliación periódica** (cifra de diseño: una vez por día, no por
  dispositivo): corrige cualquier desvío ante una posible pérdida de
  entrega de eventos que el broker no pudo garantizar (mismo riesgo
  residual que ya asume el proyector de Reportes en ADR-0003, no uno
  nuevo).

Por su baja frecuencia (arranque + una vez al día, no miles de veces cada
15 minutos), esta llamada backend-a-backend sí puede compartir el mismo
Circuit Breaker de ADR-0006 sin riesgo real de saturarlo — la diferencia
con el mecanismo original rechazado no es solo "quién llama", sino
**cuántas veces se llama**.

## Alternativas consideradas

### Alternativa A: Dispositivo DAS llama directamente a Identidad y Credenciales
- **Pros**: un salto de red menos; Captura no absorbe tráfico adicional.
- **Contras**: extiende la superficie de exposición de la API de
  validación de identidad a dispositivos físicos en 20 campus (contradice
  el argumento de DRV-03 de "confinar" el dato sensible dentro de su
  contexto); rompe el patrón de Context Mapping ya declarado (Servicio Host
  Abierto limitado a Captura, no a dispositivos externos); un dispositivo
  físico comprometido alcanzaría directamente la API interna de Identidad.
- **Por qué no se eligió**: es precisamente el riesgo de seguridad de red
  que el reviewer señaló como consecuencia de dejar esto ambiguo.

### Alternativa B (versión original de este ADR, descartada en esta corrección): Captura reconstruye el delta iterando `GET /identity/{dasId}/credential/validate` por cada `dasId` conocido
- **Pros**: no requiere ningún endpoint nuevo en Identidad; reutiliza un
  contrato ya existente.
- **Contras**: esa API es de consulta **individual** por `dasId`, no
  soporta `since=<timestamp>` ni lote — para miles de `dasId` por campus,
  cada ciclo de 15 minutos implicaría potencialmente miles de llamadas
  síncronas, saturando el mismo Circuit Breaker (ADR-0006) que protege el
  camino crítico de escaneo en vivo, generando el propio incidente de
  "backend degradado" que ADR-0006 fue diseñado para mitigar.
- **Por qué no se eligió**: es exactamente el hallazgo de severidad Alta de
  `review-log.md` (Iteración 2) que motiva esta corrección — una
  contradicción funcional, no solo una cifra de diseño pendiente de
  ajustar.

### Alternativa C: nuevo endpoint HTTP síncrono de delta en lote, consultado directamente cada 15 minutos (`GET /identity/credentials/changes?since=<ts>`), sin proyección local en Captura
- **Pros**: resuelve el problema de contrato (delta real, no individual);
  más simple de razonar que mantener una proyección local duplicada.
- **Contras**: sigue siendo una llamada síncrona repetida con alta
  frecuencia (cada 15 min × N campus) contra Identidad — perpetúa el
  acoplamiento de disponibilidad entre ambos contextos para esta ruta
  (si Identidad está degradada, el refresco de caché falla igual que con
  la Alternativa B, solo que con menos llamadas); no aprovecha que el
  sistema ya tiene un Event Broker como columna vertebral de comunicación
  entre contextos (`we3.md`) ni el precedente de proyección CQRS ya
  aplicado en Reportes y Analítica.
- **Por qué no se eligió como mecanismo primario**: el mecanismo por
  eventos (elegido) logra lo mismo con menor acoplamiento de
  disponibilidad y reutiliza infraestructura y patrones ya presentes en el
  diseño. Se conserva una versión de esta alternativa, pero acotada a
  arranque en frío/reconciliación de baja frecuencia (mecanismo secundario
  (b) de la Decisión), donde sus contras dejan de aplicar por la baja
  frecuencia de uso.

## Consecuencias

**Positivas**
- Cierra la ambigüedad de forma consistente con el Context Mapping ya
  trazado (Captura sigue siendo el único llamador de confianza hacia
  Identidad; el Dispositivo DAS solo conoce a Captura).
- Resuelve el hallazgo de severidad Alta de `review-log.md` (Iteración 2)
  sin reabrir la parte ya cerrada del diseño (quién llama a quién):
  el delta servido al dispositivo ya no depende de reutilizar
  incorrectamente una API de consulta individual.
- Elimina estructuralmente la saturación del Circuit Breaker de ADR-0006
  en la ruta de refresco de caché: el mecanismo primario no realiza
  ninguna llamada síncrona a Identidad; el mecanismo secundario la usa con
  una frecuencia órdenes de magnitud menor (arranque + 1 vez/día, no cada
  15 min por dispositivo).
- Reduce el radio de ataque: un dispositivo comprometido solo alcanza la
  API de Captura (ya diseñada para tráfico masivo de dispositivos), nunca
  la API interna de Identidad.
- Se integra con ADR-0009: la proyección local incluye revocaciones desde
  `CredentialRevoked`, acotando la ventana de exposición de una credencial
  revocada al mismo TTL de 15 minutos ya declarado.
- Reutiliza patrones y componentes ya presentes en el diseño (Event
  Broker, proyección CQRS de lectura, Idempotent Consumer) en vez de
  introducir un mecanismo nuevo no relacionado con el resto de la
  arquitectura.

**Negativas / deuda que se acepta**
- Captura de Asistencia debe mantener un componente de estado adicional
  (la proyección `CredencialesVigentesPorCampus`), distinto de la caché de
  "recientemente validadas" de ADR-0006 — dos estructuras de caché
  distintas en el mismo contexto, con propósitos y ciclos de vida
  distintos, que deben documentarse con claridad para no confundirse
  (ver `data-model-conceptual.md`).
- Introduce una nueva API en Identidad y Credenciales
  (`GET /identity/credentials/snapshot`), aunque de uso infrecuente,
  amplía en algo la superficie de esa API — mitigado porque solo Captura
  la consume (mismo llamador de confianza ya establecido), nunca el
  Dispositivo DAS.
- La consistencia de la proyección local depende de la entrega confiable
  del broker de eventos; un evento perdido o muy retrasado deja la
  proyección desactualizada hasta la siguiente reconciliación diaria —
  riesgo residual ya aceptado en el diseño para el proyector de Reportes
  (ADR-0003) y ahora extendido explícitamente a este segundo proyector.
- Introduce una dependencia adicional: si Captura está indisponible, el
  dispositivo no puede refrescar su caché — mitigado porque el dispositivo
  sigue operando con su última caché conocida (comportamiento ya cubierto
  por ADR-0005).

**Riesgos que quedan abiertos**
- El intervalo de 15 minutos (dispositivo→Captura) y de 1 día
  (reconciliación Captura→Identidad) son cifras de diseño no validadas
  contra el volumen real de revocaciones ni contra el ancho de banda
  disponible en los 20 campus.
- El tamaño de página/paginación exacta de
  `GET /identity/credentials/snapshot` para campus grandes no se
  especifica en este ADR — queda como detalle de implementación.

## Referencias
- `knowledge/we6.md`, `knowledge/we7.md` — Context Mapping (Conformista,
  Servicio Host Abierto), acoplamiento débil.
- `knowledge/we3.md` — Event Broker (push, múltiples suscriptores),
  patrones de confiabilidad (Idempotent Consumer), CQRS.
- `knowledge/we4.md`, `knowledge/we6.md` — CQRS como mecanismo de
  contrapresión y como patrón de gestión de datos en MSA (proyección de
  lado de lectura), ya aplicado en Reportes y Analítica (ADR-0003) y
  extendido aquí por analogía a Captura de Asistencia.
- `design/traceability.md` — DRV-03, DRV-05, REQ-06.
- `design/adr/adr-0005-captura-offline-tolerante.md` — caché local del
  Dispositivo DAS, ahora con mecanismo de refresco explícito.
- `design/adr/adr-0006-circuit-breaker-captura-identidad.md` — Circuit
  Breaker que protege exclusivamente la validación síncrona individual del
  camino crítico de escaneo en vivo; ya no compartido por el mecanismo
  primario de refresco de caché tras esta corrección.
- `design/adr/adr-0009-revocacion-credencial.md` — contenido del delta de
  revocaciones, TTL de 15 minutos.
- `design/milestone-2/bounded-contexts.md` — contexto Captura de
  Asistencia e Identidad y Credenciales, APIs y eventos actualizados.
- `design/milestone-2/data-model-conceptual.md` — nueva proyección local
  `CredencialesVigentesPorCampus`.
- `design/diagrams/NOTES.md` — ambigüedad de dibujo, punto 3, origen del
  hallazgo original.
- `design/milestone-2/review-log.md` — Iteración 1 (hallazgo de
  "refresco de caché ambiguo") e Iteración 2 (hallazgo de severidad Alta,
  "mecanismo real de delta sigue sin contrato de API concreto", que motiva
  esta corrección puntual).

## Nota de revisión — Milestone 3 (DEC-0013)

`design/adr/adr-0013-monolito-modular-fase1-extraccion-selectiva.md`
(`DEC-0013`) deja este mecanismo **en pausa** durante la Fase 1: el
problema que este ADR resuelve — evitar que el Dispositivo DAS o el
refresco de su caché saturen una llamada síncrona de red hacia Identidad y
Credenciales, mediante una proyección local (`CredencialesVigentesPorCampus`)
alimentada por eventos del broker — presupone una **fuente única de verdad
accedida por proyección distribuida entre dos servicios independientes**.
En el Monolito Modular de Fase 1, Captura de Asistencia e Identidad y
Credenciales comparten el mismo esquema/namespace lógico dentro del mismo
almacén (ver nota de revisión de `data-model-conceptual.md`): el endpoint
`GET /attendance-devices/{dispositivoId}/credential-cache?since=<ts>` puede
leer el estado de credenciales vigentes con una **consulta directa de
lectura** dentro del mismo proceso, sin necesitar una proyección asíncrona
propia ni el mecanismo de snapshot en lote descrito arriba.

El mecanismo especificado en este ADR queda **en pausa**, no descartado: al
activarse el trigger de extracción de Captura de Asistencia (ADR-0013, Fase
2) y separarse en un servicio con su propio almacén, la fuente única de
verdad deja de ser accesible por lectura directa y este mecanismo —
proyección local por eventos + snapshot en lote de baja frecuencia — vuelve
a ser exactamente necesario tal como está descrito arriba, sin requerir
rediseño.
