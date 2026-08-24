# ADR-0001: Adoptar Microservicios por Bounded Context con Arquitectura Dirigida por Eventos (MSA + EDA)

## Estado
Aceptado

## Contexto
El DAS de UPCA debe crecer de ~5.000 a ~15.000 usuarios en 2 años manteniendo
rendimiento eficiente en 20 campus/10 ciudades (**DRV-01**, **REQ-10**),
integrarse de forma asíncrona con un servicio externo (NIS) cuya latencia
puede llegar a 2 horas (**DRV-02**, **RST-02**), garantizar confidencialidad
y seguridad de datos personales sensibles (**DRV-03**, **REQ-09**), retener
registros de asistencia un mínimo de 5 años (**DRV-04**, **RST-03**), y
registrar entrada/salida "lo más cercano posible al tiempo real" (**DRV-05**,
**REQ-11**), driver que el propio enunciado contrapone explícitamente al de
retención. `priorizacion.md` identifica **REQ-06** (captura de asistencia) y
**REQ-07** (portal/reportes) como el punto de mayor riesgo técnico por
competir por los mismos recursos si no se diferencian sus patrones de
acceso.

`knowledge/we6.md` y `knowledge/we7.md` (Semanas 6-7, MSA II/III) establecen
que los límites de servicio deben trazarse por capacidad de negocio y
Bounded Context (DDD), no por capa técnica, cuando distintos subdominios
tienen velocidades de cambio, perfiles de carga y límites transaccionales
distintos — exactamente la situación de este sistema (ver
`design/milestone-2/bounded-contexts.md`, tabla de criterio de separación).

## Decisión
Se adopta una arquitectura de microservicios, uno por bounded context
(Identidad y Credenciales, Registro y Verificación, Captura de Asistencia,
Reportes y Analítica, Notificaciones), comunicados de forma predominantemente
asíncrona mediante un broker de eventos (Arquitectura Dirigida por Eventos),
con Base de Datos por Servicio, API Gateway + Backend-for-Frontend para los
dos clientes (portal web, app móvil), y CQRS para separar la ruta de
escritura de asistencia de la ruta de lectura de reportes.

## Alternativas consideradas

### Alternativa A: Monolito Modular con procesamiento asíncrono interno
- **Pros**: menor complejidad operacional (un solo pipeline de CI/CD, un
  solo entorno de despliegue); compatible con el hecho de que el proyecto es
  individual (**RST-01**); resuelve DRV-02 con un job queue interno sin
  necesitar un broker distribuido.
- **Contras**: la captura de asistencia (alto volumen de escritura, DRV-01/
  DRV-05) y las consultas del portal (lectura agregada, REQ-07) comparten
  runtime y, típicamente, almacén de datos — exactamente el riesgo que
  `priorizacion.md` señala para REQ-07 ("riesgo de que las consultas
  analíticas compitan por recursos con la captura de asistencia"); sin
  persistencia políglota, la estrategia de retención por capas (DRV-04) es
  más difícil de aislar del resto del sistema; un cambio en la lógica de
  Registro (volátil, por depender del NIS) obliga a redesplegar todo el
  sistema, incluida la ruta crítica de Captura de Asistencia.
- **Por qué no se eligió**: los cinco drivers de Milestone 1 tienen, cada
  uno, una necesidad de escalado, consistencia o ciclo de cambio distinta —
  eso es precisamente lo que las heurísticas de límites de servicio de
  `we7.md` identifican como la señal para separar en servicios
  independientes, no para mantener un único despliegue. El ahorro
  operacional de esta alternativa no compensa el riesgo explícito ya
  identificado en `priorizacion.md` para REQ-06/REQ-07.

## Consecuencias

**Positivas**
- Captura de Asistencia puede escalar horizontalmente de forma
  independiente para soportar el crecimiento a 15.000 usuarios en 20 campus
  (DRV-01) sin degradar ni ser degradada por Reportes o Registro.
- El aislamiento del NIS detrás de una Capa Anti-Corrupción en el contexto
  Registro y Verificación confina la volatilidad de ese tercero (DRV-02).
- CQRS resuelve la tensión explícita del enunciado entre near real-time
  (DRV-05) y retención de 5 años (DRV-04): la ruta de escritura no compite
  con la ruta de lectura ni con las consultas históricas más lentas
  (ASM-13).
- Base de Datos por Servicio confina el radio de exposición de datos
  sensibles (DRV-03) a su propio contexto.

**Negativas / deuda que se acepta**
- Complejidad operacional significativamente mayor: observabilidad
  distribuida, gestión de consistencia eventual, orquestación de despliegue
  de múltiples servicios — un solo desarrollador (RST-01) debe operar todo
  esto, no solo diseñarlo.
- Más superficie de red interna que asegurar que en un monolito (tensión
  parcial con DRV-03 en su dimensión operativa, aunque el aislamiento de
  datos por contexto mitiga el radio de daño).

**Riesgos que quedan abiertos**
- La complejidad de operar múltiples servicios con un equipo de una sola
  persona es un riesgo real que `architecture-risk` (Milestone 3) debe
  evaluar con detalle — este ADR no lo resuelve, solo lo acepta como
  trade-off consciente a favor de los drivers técnicos priorizados.

## Referencias
- `knowledge/index.md`, `knowledge/we6.md`, `knowledge/we7.md` — Bounded
  Context, heurísticas de límites de servicio, CQRS, Base de Datos por
  Servicio.
- `design/traceability.md` — DRV-01 a DRV-05, REQ-06, REQ-07, REQ-09,
  REQ-10, REQ-11, RST-01, RST-02, RST-03.
- `design/milestone-2/architecture-decision.md` — comparación completa de
  ambas alternativas.
- `design/milestone-2/bounded-contexts.md` — desarrollo completo de la
  alternativa elegida.
