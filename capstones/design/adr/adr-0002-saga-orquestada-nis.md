# ADR-0002: Modelar el registro/verificación NIS como Saga orquestada (Proceso de Larga Duración)

## Estado
Aceptado

## Contexto
El registro de un usuario requiere dos aprobaciones encadenadas de origen
distinto — verificación del NIS (hasta 2 horas, no negociable) y aprobación
del personal administrativo (**RST-04**, **REQ-04**, **DRV-02**). Los
stakeholders simulados exigen visibilidad explícita de estado durante toda
la espera (**ASM-08**: pendiente de verificación → verificado/pendiente de
aprobación → aprobado, o rechazado) y un manejo operativo concreto si el
NIS no responde a tiempo (**ASM-15**: alerta al personal, notificación de
demora al usuario, la solicitud permanece pendiente, debe existir mecanismo
de reintento) o si el registro es rechazado (**ASM-11**: notificación con
motivo). `knowledge/we4.md` (Semana 4) define este tipo de proceso como
Proceso de Larga Duración (PLD) y ofrece dos patrones principales: motores
de flujo de trabajo (orquestación) y Saga por coreografía; `knowledge/we7.md`
(Semana 7) desarrolla ambos enfoques de Saga (coreografía y orquestación)
con sus trade-offs explícitos.

## Decisión
El flujo de Registro y Verificación se modela como una Saga **orquestada**
(`UserRegistrationSaga`), con un motor de flujo de trabajo central que
mantiene la máquina de estados explícita del proceso, controla los
reintentos ante fallos transitorios del NIS con backoff exponencial y
jitter, detecta el timeout de 2 horas, y coordina la transición hacia la
aprobación administrativa y la emisión final del evento
`RegistrationApproved`/`RegistrationRejected`.

## Alternativas consideradas

### Alternativa A: Saga por coreografía
- **Pros**: mayor desacoplamiento entre Registro/Verificación, el NIS
  (vía ACL) y la aprobación administrativa — cada paso reacciona a eventos
  sin un coordinador central (`we4.md`, `we7.md`).
- **Contras**: `we7.md` señala explícitamente como desventaja de la
  coreografía que es "más difícil de depurar (no hay un punto central que
  muestre el flujo completo)". Este proceso tiene exactamente dos
  aprobaciones secuenciales obligatorias con estados intermedios que el
  usuario debe poder consultar en cualquier momento (ASM-08) y un requisito
  operativo explícito de alerta + reintento ante timeout (ASM-15) — ambas
  necesidades exigen un lugar único y consultable donde el estado del
  proceso completo sea explícito, no reconstruible únicamente a partir de
  eventos dispersos entre varios servicios.
- **Por qué no se eligió**: el propio material del curso (`we4.md`,
  "Impacto arquitectural" de Motores de flujo de trabajo) señala que la
  orquestación "hace que los procesos complejos sean explícitos, comprobables
  y, crucialmente, recuperables" — es la propiedad que ASM-08 y ASM-15
  exigen funcionalmente. La coreografía sacrifica exactamente esa propiedad
  a cambio de un desacoplamiento que este proceso, al ser inherentemente
  secuencial (RST-04: dos aprobaciones encadenadas, no paralelas ni
  independientes), no necesita en la misma medida que otros flujos del
  sistema.

## Consecuencias

**Positivas**
- El estado de la solicitud es una fuente única y consultable, satisfaciendo
  directamente ASM-08 (`GET /registrations/{id}/status`).
- El timeout de 2 horas y el mecanismo de reintento exigidos por ASM-15 se
  implementan como lógica explícita del orquestador, no como comportamiento
  emergente de eventos coreografiados.
- Los reintentos ante fallos transitorios del NIS usan backoff exponencial +
  jitter (`we7.md`, Patrón Retry) e idempotencia (clave de idempotencia por
  solicitud), evitando tormentas de reintentos contra un tercero cuyo
  comportamiento real se desconoce (ASM-01).

**Negativas / deuda que se acepta**
- El orquestador introduce un punto de acoplamiento central dentro del
  contexto Registro y Verificación (`we7.md`: "introduce acoplamiento hacia
  el orquestador") — aceptable porque ese acoplamiento queda confinado
  dentro de un único bounded context, no distribuido entre varios servicios.
- Requiere infraestructura de motor de flujo de trabajo (ej. equivalente
  conceptual a Temporal/Step Functions, `we4.md`) — complejidad operacional
  adicional que se suma a la ya aceptada en ADR-0001.

**Riesgos que quedan abiertos**
- La orden/dependencia estricta entre verificación NIS y aprobación
  administrativa sigue sin confirmarse por el enunciado ni por los
  stakeholders simulados (**AMB-05**, parcialmente resuelta). Este ADR
  asume, siguiendo la señal cualitativa del Personal Administrativo
  simulado ("un registro que ya fue verificado por el NIS"), un orden
  secuencial NIS → aprobación administrativa. Si esa ambigüedad se
  resolviera en sentido contrario (aprobación en paralelo o independiente
  del resultado del NIS), la máquina de estados de la Saga debe revisarse
  — se deja constancia explícita de este supuesto.

## Referencias
- `knowledge/we4.md` — Procesos de Larga Duración, patrones (motores de
  flujo de trabajo vs. Saga por coreografía).
- `knowledge/we7.md` — Patrón Saga (coreografía vs. orquestación), Retry
  con backoff exponencial y jitter, idempotencia.
- `design/traceability.md` — DRV-02, RST-02, RST-04, REQ-04, ASM-08,
  ASM-11, ASM-15, AMB-05.
- `design/milestone-2/bounded-contexts.md` — contexto Registro y
  Verificación.

## Nota de revisión — Milestone 3 (DEC-0013)

`design/adr/adr-0013-monolito-modular-fase1-extraccion-selectiva.md`
(`DEC-0013`) reemplaza, únicamente para la Fase 1, el mecanismo de
infraestructura de este ADR: el "motor de flujo de trabajo central"
descrito en la Decisión se reemplaza por una **máquina de estados/cola de
trabajos interna** (in-process, dentro del monolito modular), sin requerir
un motor de workflow desplegado como infraestructura separada.

El patrón conceptual que motivó esta decisión — Proceso de Larga Duración
explícito, comprobable y recuperable (`knowledge/we4.md`), con la máquina de
estados de `UserRegistrationSaga`, los reintentos con backoff exponencial y
jitter, y la orquestación (frente a coreografía) por las razones ya
argumentadas arriba — **se mantiene sin cambios**. No se reabre la elección
orquestación vs. coreografía ni ninguna otra sección de este ADR: cambia
únicamente el "cómo" de implementación (motor de workflow dedicado → cola de
trabajos interna con persistencia del estado en el mismo almacén del
monolito), no el "qué" (Saga orquestada como abstracción).

En Fase 2, si Registro y Verificación se extrae por el trigger condicional
de ADR-0013, la máquina de estados puede migrar a un motor de flujo de
trabajo dedicado tal como estaba previsto originalmente en este ADR, sin
cambio conceptual adicional.
