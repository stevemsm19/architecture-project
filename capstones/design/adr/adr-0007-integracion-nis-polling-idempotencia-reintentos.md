# ADR-0007: Contrato de integración con el NIS — modelo de entrega (polling), idempotencia de resultados entrantes y tope de reintentos

## Estado
Aceptado

> Extiende y complementa a `design/adr/adr-0002-saga-orquestada-nis.md`
> (que sigue **Aceptado** y no se modifica: la decisión de modelar el flujo
> como Saga orquestada no cambia). Este ADR resuelve tres detalles que
> ADR-0002 dejaba sin especificar y que `architecture-reviewer` marcó como
> hallazgos de Severidad Alta en la Iteración 1.

## Contexto
Tres hallazgos relacionados de `design/milestone-2/review-log.md`
(Iteración 1) apuntan al mismo punto del diseño — el contrato real entre la
Capa Anti-Corrupción (ACL) y el NIS:

1. **Modelo de entrega no declarado**: `sequence-registro-nis.mmd` dibuja
   `NIS->>ACL: Resultado de verificación (evento/callback)`, asumiendo que
   el NIS empuja (push/webhook) el resultado, sin que eso se declare en
   ningún lado como supuesto — a diferencia de AMB-05, que sí está
   declarada explícitamente. **ASM-01** solo dice que el NIS es "fuera de
   control operativo", sin definir su modelo de integración. Un servicio
   gubernamental de identificación es, en la práctica, más plausible que
   exponga solo una API de consulta de estado (polling) que un webhook
   configurable por un tercero como UPCA.
2. **Sin idempotencia de resultados entrantes**: ADR-0002 solo define
   idempotencia para las solicitudes **salientes**. No hay manejo definido
   si el resultado **entrante** llega duplicado o fuera de orden (**ASM-01**
   confirma que el NIS es un sistema externo cuyo comportamiento de entrega
   no se controla).
3. **Sin tope de reintentos**: ante timeout repetido (**ASM-15**), ADR-0002
   define reintento con backoff exponencial + jitter, pero sin límite — un
   candidato podría quedar en un ciclo `pendiente_nis → timeout → reintento`
   de duración no acotada.

`knowledge/we2.md` (Semana 2) define Webhook como mecanismo que "evita el
sondeo constante" — lo que implica que, sin esa capacidad confirmada del
lado del NIS, el mecanismo base por defecto es polling. `knowledge/we7.md`
desarrolla Retry con backoff exponencial + jitter e Idempotent Consumer;
`knowledge/we3.md`/`we4.md` desarrollan Dead Letter Queue para resultados
que no pueden procesarse automáticamente con seguridad.

## Decisión

### 1. Modelo de entrega: polling con backoff como mecanismo primario
La ACL, tras enviar la solicitud de verificación (REQ-03), **consulta
periódicamente** el estado de la solicitud contra el NIS (`GET` sobre un
endpoint de estado, asumido expuesto por el NIS conforme a REQ-03) en vez
de esperar pasivamente un callback entrante. Intervalo de ejemplo: cada 5
minutos al inicio, con backoff hasta un máximo de 30 minutos por consulta,
durante la ventana de hasta 2h (RST-02). Si el NIS expone adicionalmente un
callback/webhook de entrada, la ACL puede aceptarlo como **acelerador
opcional** que dispara una consulta de confirmación inmediata — nunca se
confía en el payload de un callback sin confirmarlo por consulta directa,
dado que no se controla la autenticidad/formato de un tercero (ASM-01).
Esto reemplaza el supuesto implícito del diagrama por una decisión
declarada explícitamente, resolviendo el hallazgo.

### 2. Idempotencia de resultados entrantes
La primera vez que se recibe un resultado, se almacena un
`nisVerificationId` (identificador de verificación devuelto por el NIS) en
`SolicitudDeRegistro`. Cada resultado posterior se procesa según el estado
actual de la Saga (Idempotent Consumer, `we7.md`):
- Si la Saga está en un estado **no terminal compatible**
  (`pendiente_nis`, o `nis_timeout` en fase de reintento) → se procesa
  normalmente.
- Si la Saga ya transicionó con el **mismo** `nisVerificationId` (reenvío/
  duplicado de red) → se descarta silenciosamente, mas se registra en un
  log de auditoría (no se reprocesa).
- Si llega un resultado **contradictorio** con un `nisVerificationId`
  distinto después de que la Saga alcanzó un estado terminal (`aprobado` o
  `rechazado`) → **no se reprocesa automáticamente**. Se enruta a una cola
  de revisión manual (Dead Letter Queue, `we3.md`) para que el personal
  administrativo decida, incluyendo la posibilidad de revocar la
  credencial ya emitida vía ADR-0009 si corresponde.

### 3. Tope de reintentos y escalamiento
Máximo **3 ciclos de timeout** (hasta 2h cada uno, RST-02 → hasta 6h de
espera acumulada total). Tras el tercer timeout, la Saga transiciona a un
nuevo estado terminal explícito **`escalado_manual`** (distinto de
`rechazado`: no es un rechazo, es una falla operativa del proceso de
verificación), publicando `NISVerificationEscalated`, que dispara
notificación al personal administrativo para intervención manual (ej.
contacto directo con el NIS o decisión manual basada en otros medios).

**Máquina de estados actualizada**: `pendiente_nis → (timeout, hasta 3
veces con backoff) → nis_timeout → pendiente_nis → ... → tras el 3er
timeout → escalado_manual` (terminal).

## Alternativas consideradas

### Alternativa A: Mantener el supuesto de push/webhook sin declararlo
- **Por qué no se eligió**: es exactamente el hallazgo del reviewer — una
  decisión técnica de alto impacto tratada como hecho dado. Si el NIS real
  no soporta webhooks entrantes configurables por UPCA, el diseño completo
  de la Saga quedaría roto en producción.

### Alternativa B: Reintentos ilimitados con backoff (sin tope)
- **Por qué no se eligió**: no acota la espera total del usuario,
  contradice la expectativa de un proceso con fin definido y dificulta que
  el personal administrativo sepa cuándo intervenir.

### Alternativa C: Reprocesar automáticamente cualquier resultado tardío, incluso tras estado terminal
- **Por qué no se eligió**: riesgo de revocar o rechazar automáticamente a
  un usuario que ya tiene una credencial válida emitida, sin revisión
  humana — impacto directo en DRV-03/confianza del sistema.

## Consecuencias

**Positivas**
- El modelo de integración con el NIS queda declarado y auditable, no
  implícito en un diagrama.
- Elimina transiciones contradictorias silenciosas ante duplicados o
  resultados tardíos.
- Acota la espera total del usuario a un máximo determinado (6h) con una
  salida operativa clara (`escalado_manual`), en vez de un ciclo indefinido.

**Negativas / deuda que se acepta**
- Mayor complejidad en la ACL: debe implementar polling con backoff, no
  solo escuchar eventos entrantes.
- Carga adicional de consultas repetidas contra el NIS durante la ventana
  de espera — aceptada explícitamente porque no hay alternativa sin
  control sobre el contrato real del NIS (ASM-01).
- Nuevo estado terminal `escalado_manual` y nuevo evento
  `NISVerificationEscalated` — cambia la máquina de estados de ADR-0002 sin
  invalidar su decisión central (Saga orquestada).

**Riesgos que quedan abiertos**
- El intervalo de polling (5-30 min) y el tope de 3 ciclos son cifras de
  diseño de este equipo, no validadas contra el comportamiento real del
  NIS — `architecture-risk` (Milestone 3) debería evaluarlas si aparece
  evidencia de que son insuficientes o generan carga excesiva sobre un
  tercero no negociable.

## Referencias
- `knowledge/we2.md` — Webhook ("evita el sondeo constante").
- `knowledge/we3.md` — Dead Letter Queue.
- `knowledge/we7.md` — Retry con backoff exponencial y jitter, Idempotent
  Consumer.
- `design/traceability.md` — DRV-02, REQ-03, REQ-04, ASM-01, ASM-15,
  AMB-05.
- `design/adr/adr-0002-saga-orquestada-nis.md` — decisión de Saga
  orquestada, no modificada por este ADR.
- `design/milestone-2/bounded-contexts.md` — contexto Registro y
  Verificación.
- `design/milestone-2/review-log.md` — Iteración 1, hallazgos "Sin manejo
  definido de respuesta duplicada", "Sin tope máximo de reintentos" y
  "Modelo de entrega... asumido sin declararlo".

## Nota de revisión — Milestone 3 (DEC-0013)

`design/adr/adr-0013-monolito-modular-fase1-extraccion-selectiva.md`
(`DEC-0013`) no afecta el contrato de integración con el NIS descrito en
este ADR: el NIS es un sistema externo (**ASM-01**) fuera del control
operativo del equipo independientemente de la topología interna del
backend de UPCA — el modelo de entrega (polling con backoff), la
idempotencia de resultados entrantes (`nisVerificationId`), el tope de 3
ciclos de reintento y el estado `escalado_manual` se mantienen exactamente
como están especificados arriba.

Lo único que cambia es **quién ejecuta el polling**: en Fase 1 (Monolito
Modular), un **worker de la cola de trabajos interna** dentro del módulo
Registro y Verificación (ver nota de revisión de ADR-0002) ejecuta los
ciclos de consulta contra el NIS, en vez de un servicio Registro y
Verificación desplegado de forma independiente. El comportamiento
observable (frecuencia de polling, idempotencia, tope de reintentos,
escalamiento) es idéntico desde la perspectiva del NIS y del usuario.
