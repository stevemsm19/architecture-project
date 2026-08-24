# Índice de Conocimiento del Curso

> Síntesis generada a partir de `knowledge/we1.md` a `knowledge/we7.md` (las 7
> semanas de material disponibles al momento de esta síntesis). Este índice cubre por tanto el 100% del
> contenido conceptual curado disponible.

## Cobertura por semana

| Semana | Tema | Conceptos clave | Patrones/tácticas |
|---|---|---|---|
| 1 | Arquitectura Empresarial (AE) | Arquitectura Empresarial y sus dominios (Estrategia, Negocio, Información, Aplicaciones, Tecnología — el curso solo profundiza Información/Aplicaciones/Tecnología); Arquitectura de Información; Arquitectura de Aplicaciones; Arquitectura Tecnológica; Análisis de Brechas (Gap Analysis); Interoperabilidad de Sistemas (dimensiones: intercambio de datos, organizacional, semántica, técnica); Gobierno vs. Cumplimiento; Soluciones/Arquitectura Modular | Herramientas de modelado AE (Archi, Modelio, Bizzdesign, Sparx EA); proceso de Gap Analysis (5 pasos: documentar estado actual, definir estado objetivo, identificar brechas, priorizar, hoja de ruta); fundamentos de arquitectura modular (Independent Units, Self-Contained Functionality, Well-Defined Interfaces); módulos de diseño (Service/Data/API/Security Module) |
| 2 | Integración de Sistemas | Arquitectura Empresarial (recapitulación); Interoperabilidad de Sistemas; Sistemas Heredados (legacy) y deuda tecnológica; Integración de Sistemas; Migración de Datos | EDI, APIs (REST/GraphQL/gRPC), Webhooks, Mensajería (message queue vs. event broker) comparados en acoplamiento/temporización/flujo; espectro de complejidad de integración (Point-to-Point → Hub-and-Spoke → ESB → iPaaS → Microservices); enfoques de modernización de legacy (incremental, paralelo, migración completa); proceso de Migración de Datos (7 pasos); embudo de buenas prácticas de integración |
| 3 | Rendimiento del Sistema I | Rendimiento del sistema como conjunto de métricas (latencia, throughput, utilización, saturación); Dimensiones Arquitectónicas del Rendimiento (latencia, throughput, escalabilidad, eficiencia de recursos, concurrencia, resistencia); rendimiento como requisito no funcional (SLA/SLO); trade-offs de rendimiento (CAP, dev-time vs. performance, escalabilidad vs. complejidad, etc.); brokers de mensajes y colas; EDA; procesadores de flujos (stream processing) | Message Queue vs. Event Broker; patrones de intercambio de mensajes (Request-Reply, Fire-and-Forget, Publish-Subscribe, Message Queue); patrones de enrutamiento (Content-Based Router, Message Filter, Scatter-Gather, Message Translator, Splitter); patrones arquitectónicos basados en eventos (Event Sourcing, CQRS, Saga, Message-Driven Architecture, EDA); patrones de confiabilidad (Dead Letter Queue, Circuit Breaker, Idempotent Consumer, Transactional Outbox, Retry); Arquitectura Lambda vs. Kappa; Procesadores de Flujo vs. Bases de Datos de Flujo |
| 4 | Rendimiento del Sistema II | Contrapresión (Backpressure) como fenómeno arquitectónico; Procesos de Larga Duración (PLD) y sus características (duración, fallo, asincronía, observabilidad, consumo de recursos, gestión de estado, idempotencia); rendimiento del sistema (repaso) | Patrones para PLD: motores de flujo de trabajo/orquestación (Temporal, Step Functions), patrón Saga por coreografía, máquinas de estado, procesamiento por lotes; mecanismos de contrapresión por enfoque: colas/brokers (límite de cola, ack/nack, prefetch), procesadores de flujo (pull con buffer / rate limiting dinámico basado en créditos), EDA (rate limiting, load shedding, circuit breakers, DLQ, bulkheads, código no bloqueante), CQRS (aislamiento lectura/escritura + proyectores escalables), procesadores de trabajos (cola como buffer, autoescalado de workers); técnicas generales de backpressure (buffering, load shedding, rate limiting, circuit breakers, reactive streams, comunicación asíncrona, escalado horizontal, monitoreo) |
| 5 | Arquitectura de Microservicios I (MSA I) | Arquitectura de Microservicios (MSA) vs. monolito; características fundamentales: responsabilidad única, despliegue independiente, acoplamiento débil, desarrollo/despliegue autónomo, gestión de datos descentralizada, comunicación entre servicios, aislamiento de fallos, CI/CD continuo, escalabilidad de grano fino, persistencia/desarrollo políglota; recapitulación de PLD y contrapresión (puente desde Semana 4) | API Gateway, Service Discovery, Load Balancer, containerización (Docker)/orquestación (Kubernetes), sistemas de mensajería, herramientas de observabilidad (Jaeger/Zipkin); patrones de comunicación (síncrono, asíncrono uno-a-uno, pub/sub); recomendaciones de adopción de MSA (empezar pequeño, invertir en infraestructura, empoderar equipos autónomos) |
| 6 | Arquitectura de Microservicios II (MSA II) | Los 8 Principios Esenciales de Diseño de Microservicios (modelar por dominio/DDD, descentralizar, automatización, aislar fallos, desplegabilidad independiente, contratos orientados al consumidor, observabilidad, endpoints inteligentes/tuberías simples); Ley de Conway y DDD (bounded context, lenguaje ubicuo, subdominios); Separación de Responsabilidades (SoC) y su manifestación en Layered/Hexagonal/Microservicios/SOA; Escalabilidad vs. Elasticidad; Acoplamiento Débil; Independencia de Servicios; Datos en MSA; Diseño de APIs inter-servicio | Criterios de límites de servicio (capacidad de negocio, velocidad de cambio, propiedad de datos, estructura de equipo); patrones buenos (descomposición por capacidad/subdominio, Strangler Pattern) vs. anti-patrones (por capa técnica, monolito distribuido, base de datos compartida, servicios anémicos); mecanismos de acoplamiento débil (interfaces sobre implementaciones, mensajería/eventos, API gateway/BFF, bounded contexts + ACL, Principio de Inversión de Dependencias); gestión de datos (base de datos por servicio, Saga, composición de API, CQRS, event sourcing, data lake/warehouse); diseño de APIs (síncrono vs. asíncrono, reintentos con backoff exponencial, circuit breakers, timeouts/bulkheads) |
| 7 | Arquitectura de Microservicios III (AMM III) | Repaso integrado de principios de MSA I/II; DDD aplicado a límites de servicio (bounded contexts, heurísticas, anti-patrones), Context Mapping (9 patrones de relación entre contextos), Agregados (aggregate root, value objects); metodología 12-Factor App; estrategias de despliegue | Circuit Breaker (máquina de estados Cerrado/Abierto/Semi-abierto); Retry (fixed/incremental/exponential backoff + jitter); API Gateway; Backend-for-Frontend (BFF); Base de Datos por Servicio; patrón SAGA (coreografía vs. orquestación, transacciones compensatorias); diseño de agregados efectivos (5 pasos); despliegues Azul-Verde, Canario y Gradual (con procedimientos, trade-offs y anti-patrones de despliegue) |

## Conceptos transversales

- **Interoperabilidad de Sistemas** (we1, we2, we3): definida de forma casi
  idéntica en we1 y we2 ("capacidad de diferentes sistemas de software para
  intercambiar y usar información sin problemas, sin modificaciones
  significativas"); we2 la desarrolla en profundidad con sus cuatro
  dimensiones (intercambio de datos, organizacional, semántica, técnica) y
  cinco aspectos clave (estándares, APIs, gobernanza de datos, gestión de
  metadatos, seguridad); we3 la retoma brevemente como "objetivo o resultado
  deseado" de la integración de sistemas.

- **Mensajería / colas / brokers de eventos** (we2, we3, we4, we5, we6):
  introducida en we2 como una de las cuatro tecnologías de integración
  (junto a EDI, APIs, Webhooks); we3 la desarrolla en profundidad como
  mecanismo de desacoplamiento (Message Queue vs. Event Broker, conceptos de
  productor/consumidor/exchange/binding/topic); we4 la retoma
  específicamente como mecanismo de manejo de contrapresión (límite de cola,
  ack/nack, prefetch); we5 la recapitula como característica de comunicación
  entre microservicios; we6 la posiciona como el "estándar dorado" de
  comunicación entre servicios para lograr acoplamiento débil.

- **Arquitectura Dirigida por Eventos (EDA)** (we3, we4, we5): introducida en
  we3 junto con sus componentes (productores, canal/broker, consumidores) y
  desafíos (ordering, complejidad, consistencia eventual, monitoreo,
  gestión de esquema, idempotencia); we4 la retoma y detalla sus tácticas de
  contrapresión (rate limiting, load shedding, circuit breakers, DLQ,
  bulkheads, código no bloqueante); we5 la recapitula como uno de los
  enfoques que motivan la necesidad de MSA.

- **CQRS (Command Query Responsibility Segregation)** (we3, we4, we5, we6):
  mencionado por primera vez en el catálogo de patrones de we3 (sin
  desarrollo); we4 lo desarrolla como mecanismo específico de manejo de
  contrapresión (separación de escalado lectura/escritura, problema de
  proyección asíncrona); we5 lo recapitula brevemente en la sección de
  contrapresión; we6 lo retoma como patrón de gestión de datos en MSA
  (composición de API vs. CQRS para consultas complejas, combinado con
  event sourcing). Ningún documento individual contiene el desarrollo
  completo; el concepto se construye acumulativamente a través de we3→we6.

- **Patrón Saga** (we3, we4, we5, we6, we7): aparece nombrado en el catálogo
  de patrones de we3 (diagrama, sin desarrollo textual); we4 lo desarrolla
  como uno de los cuatro patrones para Procesos de Larga Duración,
  centrado en la coreografía; we5 lo menciona como mecanismo para
  reemplazar transacciones ACID en Gestión de Datos Descentralizada (sin
  profundizar); we6 lo retoma como solución al desafío de consistencia de
  datos entre servicios (transacciones locales + compensaciones); we7 es la
  única semana que desarrolla completamente ambos enfoques (coreografía y
  orquestación) con ejemplos de flujo y transacciones compensatorias. Ver
  también "Gaps y contradicciones" sobre la tensión entre coreografía y
  orquestación en el diagrama de we7.

- **Circuit Breaker / Bulkhead / patrones de resiliencia** (we3, we4, we5,
  we6, we7): aparecen en el catálogo de patrones de confiabilidad de we3
  (Dead Letter Queue, Circuit Breaker, Idempotent Consumer, Transactional
  Outbox, Retry); we4 los retoma como tácticas de aislamiento de fallos en
  EDA y en el "procesador de eventos"; we5 los presenta como mecanismos de
  Aislamiento de Fallos a nivel de MSA (junto con degradación elegante);
  we6 los lista dentro del principio "Aislar fallos" y como mecanismo de
  acoplamiento débil/independencia de servicios; we7 desarrolla en detalle
  la máquina de estados del Circuit Breaker (Cerrado/Abierto/Semi-abierto)
  y el patrón Retry (fixed/incremental/exponential backoff + jitter), y
  señala su combinación estratégica con Saga.

- **Diseño Dirigido por el Dominio (DDD) y límites de servicio** (we1, we6,
  we7): "DDD" aparece mencionado sin desarrollo en el repaso de
  Arquitectura de Software 2 dentro de we1; we6 lo introduce en profundidad
  como "el principio más importante" del diseño de microservicios (Ley de
  Conway, Bounded Context, Lenguaje Ubicuo, subdominios núcleo/genérico/
  soporte, Maniobra Conway Inversa); we7 lo extiende con heurísticas para
  definir límites de servicio, anti-patrones, Context Mapping (9 patrones
  de relación) y Agregados (aggregate root, value objects). Es un ejemplo
  de concepto anunciado en we1 sin desarrollo pero completamente
  desarrollado en we6-we7.

- **Escalabilidad (horizontal/vertical) y resiliencia/tolerancia a fallos**
  (we1, we3, we6): mencionadas en el repaso de Arquitectura de Software 2
  dentro de we1 (escalabilidad vertical/horizontal, resistencia, tolerancia
  a fallos) sin definición propia en ese documento; we3 las retoma como
  dimensión arquitectónica del rendimiento; we6 las desarrolla en
  profundidad, distinguiendo explícitamente Escalabilidad (propiedad
  arquitectónica/estructural) de Elasticidad (capacidad
  operacional/comportamiento en tiempo de ejecución), con la analogía de
  "comprar una mesa más grande" vs. "tomar sillas extra".

- **Acoplamiento débil / bajo acoplamiento** (we1, we2, we3, we5, we6):
  mencionado sin desarrollo en el repaso de we1 (junto con alta cohesión);
  we2 lo presenta como uno de los factores que determinan la elección de
  tecnología de integración; we3 lo usa para contrastar comunicación
  síncrona vs. asíncrona con colas; we5 lo define como característica
  fundamental de MSA; we6 lo desarrolla extensamente con la metáfora
  "módulos como isla" y mecanismos concretos (interfaces sobre
  implementaciones, paso de mensajes/EDA, API gateway/BFF, bounded
  contexts + ACL, Principio de Inversión de Dependencias).

- **Modularidad / Separación de Responsabilidades (SoC)** (we1, we6): we1
  presenta "Soluciones Modulares" a nivel de Arquitectura Empresarial
  (Independent Units, Self-Contained Functionality, Well-Defined
  Interfaces; módulos Service/Data/API/Security) y anticipa explícitamente
  que los enfoques de implementación mencionados (microservicios, DDD,
  SOA, desarrollo basado en componentes, API-first, EDA) se profundizarán
  en semanas 5-7; we6 desarrolla el concepto equivalente a nivel de
  arquitectura de software como Separación de Responsabilidades (SoC),
  mostrando cómo se manifiesta en Arquitectura en Capas, Limpia/Hexagonal,
  Microservicios y SOA.

- **Migración de Datos** (we2, we3): we2 la desarrolla en profundidad
  (definición, proceso de 7 pasos alto nivel similar aunque con
  nomenclatura ligeramente distinta, tipos, buenas prácticas, cifra de
  "más del 80% de las migraciones enfrentan retrasos o sobrecostos") y la
  distingue explícitamente de la Integración de Datos; we3 la recapitula
  con un proceso de 7 pasos (Planificación y Análisis, Perfilado y
  Limpieza, Diseño y Mapeo, Pruebas, Ejecución, Validación y Auditoría,
  Desmantelamiento) que es consistente en espíritu pero no idéntico
  palabra por palabra al de we2.

- **Contrapresión (Backpressure)** (we3 [implícito en colas], we4, we5):
  no se nombra explícitamente como término en we3, pero los mecanismos de
  colas/brokers y stream processors que we3 describe son la base técnica
  que we4 usa para explicar la contrapresión; we4 es la semana que
  desarrolla el concepto en profundidad (causas, técnicas generales,
  mecanismo específico por cada enfoque arquitectónico); we5 lo recapitula
  como puente de entrada a MSA, señalando que "no se trata de hacer el
  sistema más rápido, sino de hacerlo estable y predecible bajo carga".

- **Gobierno y Cumplimiento** (we1, we2): we1 desarrolla en profundidad la
  distinción Gobierno vs. Cumplimiento a nivel de Arquitectura Empresarial
  (tabla comparativa, diagrama de balanza "Controlled Architecture
  Management"); we2 los menciona brevemente en la recapitulación de AE sin
  añadir profundidad.

- **API Gateway** (we5, we6, we7): mencionado en we5 como parte de la
  infraestructura de soporte de MSA (enrutamiento, seguridad, rate
  limiting); we6 lo retoma como mecanismo de acoplamiento débil e
  independencia de servicios; we7 lo desarrolla completamente como patrón
  arquitectónico con sus componentes internos (auth, SSL, routing, HTTP/
  protocol translation, aggregation, audit) y su relación con el patrón
  Backend-for-Frontend (BFF).

- **Persistencia/Desarrollo Políglota** (we5, we6, we7): definida en we5
  como característica fundamental de MSA (libertad de stack tecnológico
  por servicio); we6 la retoma como parte de "Descentralizar todo" y de
  Datos en MSA; we7 la ilustra con un ejemplo concreto en AWS (Aurora,
  DynamoDB, SQL Server usados por distintos servicios Lambda).

## Glosario canónico

### Arquitectura Empresarial y organización (Semana 1)

- **Arquitectura Empresarial (AE)**: disciplina que proporciona una visión
  holística de la estructura, procesos, sistemas de información e
  infraestructura tecnológica de una organización, alineándolos con la
  estrategia y objetivos del negocio. *(Semana 1)*
- **Dominios de Arquitectura Empresarial**: Capa de Estrategia, Arquitectura
  de Negocio, Arquitectura de Información, Arquitectura de Aplicaciones y
  Arquitectura Tecnológica; el curso profundiza solo en los tres últimos.
  *(Semana 1)*
- **Arquitectura de Información**: disciplina dentro de la AE enfocada en
  estructurar, organizar y gobernar los datos e información de una
  organización para hacerlos accesibles, comprensibles y útiles.
  *(Semana 1)*
- **Arquitectura de Aplicaciones**: define la estructura, comportamiento e
  interacción de las aplicaciones que soportan los procesos de negocio.
  *(Semana 1)*
- **Arquitectura Tecnológica**: define la estructura y estándares de la
  infraestructura tecnológica que soporta aplicaciones y procesamiento de
  datos. *(Semana 1)*
- **Análisis de Brechas (Gap Analysis)**: proceso para identificar
  discrepancias entre el estado actual y el estado futuro deseado de la
  organización, con el fin de planificar la transformación. *(Semana 1)*
- **Gobierno (Governance, en AE)**: estructuras, procesos, principios y
  roles que aseguran que la AE esté definida, implementada y mantenida de
  manera consistente y alineada con la estrategia de negocio. *(Semana 1)*
- **Cumplimiento (Compliance)**: capacidad de la organización para cumplir
  leyes, regulaciones, políticas internas y estándares de
  seguridad/técnicos aplicables. *(Semana 1)*
- **Soluciones Modulares / Arquitectura Modular**: diseño e implementación
  de sistemas de TI como colecciones de componentes o módulos
  independientes, para lograr agilidad, escalabilidad y resistencia.
  *(Semana 1)*
- **TOGAF / ArchiMate**: mencionados como frameworks/notaciones soportados
  por herramientas de modelado de AE (Archi, Bizzdesign, Modelio, Sparx
  EA); no se definen en el material. *(Semana 1 — mencionado sin
  desarrollo)*

### Interoperabilidad e integración (Semanas 1-3)

- **Interoperabilidad de Sistemas**: capacidad de diferentes sistemas de
  software para intercambiar y usar información de manera fluida, sin
  necesidad de modificaciones significativas o integraciones
  personalizadas. *(Semanas 1 y 2, definición consistente)*
- **Interoperabilidad Semántica**: garantiza que los datos intercambiados
  sean comprendidos de manera consistente por todos los sistemas y partes
  interesadas. *(Semanas 1-2)*
- **Interoperabilidad Técnica**: garantiza que los sistemas puedan
  conectarse y transmitir datos (APIs, protocolos, formatos). *(Semanas
  1-2)*
- **Interoperabilidad Organizacional**: alinea procesos, políticas y
  responsabilidades entre organizaciones o departamentos. *(Semanas 1-2)*
- **Sistema Heredado (Legacy)**: software o tecnología construidos sobre
  plataformas obsoletas que siguen siendo críticos para las operaciones
  actuales, representando una acumulación de deuda tecnológica. *(Semana
  2, recapitulado en Semana 3)*
- **Deuda tecnológica**: acumulación de compromisos técnicos derivados del
  uso continuado de plataformas obsoletas. *(Semana 2)*
- **Vendor lock-in**: dependencia de proveedores específicos o tecnologías
  propietarias que limita las alternativas viables. *(Semana 2)*
- **Factor autobús (bus factor)**: riesgo de perder la comprensión crítica
  de un sistema si el personal clave que posee ese conocimiento se marcha.
  *(Semana 2)*
- **Integración de Sistemas**: proceso de vincular diferentes sistemas
  informáticos y aplicaciones de software física o funcionalmente para
  actuar como un conjunto coordinado. *(Semanas 2-3)*
- **EDI (Intercambio Electrónico de Datos)**: formato digital estandarizado
  para intercambiar documentos comerciales entre organizaciones (ANSI X12,
  EDIFACT); asíncrono y orientado a lotes, alta confiabilidad. *(Semana 2)*
- **Webhook**: URL de callback que una aplicación llama automáticamente
  cuando ocurre un evento específico, evitando sondeo constante; también
  llamado "API inversa". *(Semana 2)*
- **Migración de Datos**: proceso de seleccionar, preparar, extraer,
  transformar y transferir datos de un sistema de almacenamiento o entorno
  a otro, de forma única y permanente (a diferencia de la integración, que
  es continua). *(Semanas 2-3)*
- **ETL**: herramientas/scripts usados para ejecutar la migración de datos;
  mencionado sin desarrollar su significado (Extract, Transform, Load) ni
  sus fases. *(Semana 2 — mencionado sin desarrollo)*

### Rendimiento, mensajería y procesamiento de eventos (Semanas 3-4)

- **Rendimiento del Sistema (System Performance)**: medida de qué tan
  efectivamente un sistema logra su trabajo previsto, expresada como
  conjunto de métricas (latencia, throughput, utilización, saturación), no
  como un número único. *(Semanas 3-4, consistente)*
- **Latencia**: tiempo tomado para responder a una solicitud. *(Semana 3)*
- **Throughput (Rendimiento)**: número de operaciones completadas por
  unidad de tiempo. *(Semana 3)*
- **Cola de mensajes**: buffer temporal que almacena mensajes de
  productores hasta que los consumidores están listos para recuperarlos,
  típicamente FIFO. *(Semana 3)*
- **Broker de mensajes**: software intermediario que gestiona colas,
  temas, intercambios y reglas de enrutamiento, asegurando entrega
  confiable de mensajes; hace más que almacenar: enruta, transforma y
  gestiona mensajes. *(Semana 3)*
- **Message Queue (patrón)**: los consumidores extraen (pull), procesan y
  eliminan mensajes de la cola; cada mensaje va normalmente a un solo
  consumidor. *(Semana 3, contrastado con Event Broker)*
- **Event Broker (patrón)**: los eventos se empujan (push) a los
  consumidores; el mismo evento puede llegar a múltiples consumidores.
  *(Semana 3)*
- **EDA (Arquitectura Dirigida por Eventos)**: paradigma donde los
  componentes se comunican produciendo y reaccionando a eventos en lugar
  de llamadas directas. *(Semana 3, ampliado en Semana 4)*
- **Idempotencia**: propiedad de un consumidor/proceso que permite procesar
  el mismo mensaje o ejecutarse múltiples veces sin producir efectos
  adicionales o negativos. *(Semanas 3-4-7, consistente)*
- **Procesamiento de flujos (Stream Processing)**: paradigma de computación
  centrado en procesar datos continuamente a medida que llegan, en lugar
  de en lotes. *(Semana 3)*
- **Arquitectura Lambda**: combina una capa por lotes (batch, precisión
  histórica) y una capa de velocidad (tiempo real); mayor precisión pero
  mayor complejidad de mantenimiento (lógica duplicada). *(Semana 3)*
- **Arquitectura Kappa**: simplifica usando un único pipeline de flujo para
  tiempo real y reprocesamiento histórico; menor complejidad pero más
  exigente en infraestructura de streaming. *(Semana 3)*
- **Contrapresión (Backpressure)**: mecanismo de retroalimentación donde un
  componente downstream sobrecargado fuerza a los componentes upstream a
  ralentizarse o dejar de aceptar entrada; previene agotamiento de
  recursos y fallos en cascada. *(Semana 4, base técnica en Semana 3)*
- **Proceso de Larga Duración (PLD)**: operación o tarea asíncrona que
  excede el ciclo típico de solicitud/respuesta, progresando a través de
  múltiples estados y debiendo sobrevivir reinicios del sistema. *(Semana
  4)*
- **Patrón Saga (definición general)**: patrón para gestionar transacciones
  distribuidas mediante una secuencia de transacciones locales y acciones
  compensatorias en caso de fallo, evitando 2PC. Desarrollado
  completamente (coreografía vs. orquestación) en la Semana 7. *(Semanas
  3-4-5-6-7)*
- **CQRS (Command Query Responsibility Segregation / Segregación de
  Responsabilidad de Comandos y Consultas)**: separa las operaciones de
  escritura (comandos) de las de lectura (consultas), permitiendo
  estrategias de escalado y optimización independientes para cada una.
  *(Semanas 3-4-5-6)*
- **Event Sourcing**: patrón donde el estado de una entidad se determina
  reproduciendo una secuencia de eventos inmutables; mencionado como
  complemento de CQRS en varias semanas pero nunca desarrollado en
  profundidad como concepto independiente en ningún `weN.md`. *(Semanas
  3-4-6 — mencionado, nunca desarrollado en profundidad)*
- **Circuit Breaker**: patrón que monitorea la salud de dependencias
  posteriores y "se abre" para evitar enviar solicitudes a una dependencia
  fallida, previniendo fallos en cascada. Desarrollado con su máquina de
  estados completa (Cerrado/Abierto/Semi-abierto) en la Semana 7. *(Semanas
  3-4-5-6-7)*
- **Bulkhead (Mampara)**: técnica de aislamiento de recursos (ej. pools de
  hilos, conexiones) que previene que una operación lenta o un fallo en un
  área consuma todos los recursos disponibles. *(Semanas 4-5-6-7)*
- **Dead Letter Queue (DLQ)**: cola donde se capturan mensajes o trabajos
  que no pudieron procesarse exitosamente, para análisis posterior y
  reintento. *(Semanas 3-4)*
- **Backoff exponencial**: estrategia de reintento donde el tiempo de
  espera entre intentos fallidos crece exponencialmente, para prevenir
  tormentas de reintentos; en la Semana 7 se detalla con ejemplo (t =
  100·2^(i-1) ms) y se complementa con jitter (aleatorización) para evitar
  el efecto rebaño (thundering herd). *(Semanas 4 y 7)*

### Arquitectura de Microservicios (Semanas 5-7)

- **MSA (Microservices Architecture / Arquitectura de Microservicios)**:
  estilo arquitectónico que estructura una aplicación como un conjunto de
  servicios pequeños, independientes y débilmente acoplados, cada uno
  responsable de una capacidad de negocio específica, con comunicación vía
  mecanismos ligeros (a menudo APIs HTTP). *(Semana 5, base para 6 y 7)*
- **Base de Datos por Servicio (Database per Service)**: patrón de gestión
  de datos descentralizada donde cada microservicio posee su propia base
  de datos privada; previene el acoplamiento fuerte en la capa de datos.
  *(Semanas 5-6-7)*
- **Persistencia Políglota**: libertad de cada servicio para elegir la
  tecnología de base de datos (y lenguaje) más adecuada a sus necesidades.
  *(Semanas 5-6-7)*
- **API Gateway**: punto de entrada único para el tráfico externo hacia los
  microservicios; centraliza preocupaciones transversales (autenticación,
  SSL, enrutamiento, agregación, traducción de protocolos, rate limiting);
  introduce un potencial punto único de fallo mitigado con clustering.
  *(Semanas 5-6-7)*
- **Service Discovery**: mecanismo que permite a los servicios localizarse
  y comunicarse dinámicamente entre sí, junto con balanceo de carga.
  *(Semana 5)*
- **"You Build It, You Run It"**: principio organizacional donde un equipo
  multifuncional posee el ciclo de vida completo (diseño, desarrollo,
  despliegue, operación) de uno o más servicios. *(Semana 5)*
- **Bounded Context (Contexto Delimitado)**: patrón central de DDD; define
  un límite claro dentro del cual un modelo de dominio particular
  (entidades, reglas, lenguaje) es consistente y aplicable; cada Contexto
  Delimitado es candidato principal para un límite de servicio. *(Semanas
  6-7)*
- **Lenguaje Ubicuo (Ubiquitous Language)**: lenguaje compartido entre
  desarrolladores y expertos del dominio, codificado en la API y el modelo
  interno del servicio. *(Semana 6)*
- **Ley de Conway**: principio según el cual la estructura del software
  refleja la estructura de la organización que lo construye; usado como
  heurística para definir límites de servicio. *(Semanas 6-7)*
- **Maniobra Conway Inversa**: alinear intencionalmente la estructura de
  equipos con los límites de servicio deseados. *(Semana 6)*
- **Monolito Distribuido**: anti-patrón donde los servicios están
  fuertemente acoplados y deben desplegarse juntos, obteniendo la
  complejidad de los microservicios sin sus beneficios. *(Semana 6)*
- **Strangler Pattern (Patrón de Estrangulamiento)**: técnica de migración
  gradual de un monolito a servicios, extrayendo funcionalidad rebanada
  por rebanada. *(Semana 6)*
- **Escalabilidad**: capacidad fundamental de un sistema para manejar carga
  de trabajo incrementada añadiendo recursos de forma sistemática;
  propiedad arquitectónica/estructural (se "arquitecta"). *(Semanas 3 y 6,
  desarrollada en profundidad en 6)*
- **Elasticidad**: ajuste flexible y en tiempo real de recursos para
  manejar fluctuaciones de demanda impredecibles; capacidad operacional
  (se "implementa" sobre una base escalable). Nota: el material no
  capturó una definición formal de una sola frase, análoga a la de
  Escalabilidad; se define de forma indirecta mediante sus características.
  *(Semana 6)*
- **Acoplamiento Débil (Loose Coupling)**: grado en el cual los componentes
  de un sistema minimizan sus dependencias mutuas, comunicándose mediante
  protocolos/contratos estables en lugar de compartir implementación
  interna. *(Semanas 1-2-3-5, desarrollado en profundidad en 6)*
- **Independencia de Servicios**: grado al cual un servicio puede
  funcionar, desplegarse y evolucionar sin coordinación síncrona,
  disponibilidad o versiones específicas de otros servicios; espectro, no
  estado binario. *(Semana 6)*
- **Separación de Responsabilidades (SoC)**: principio de diseño que
  reduce interdependencias y crea límites claros entre responsabilidades
  de un sistema; se manifiesta de forma distinta en Arquitectura en Capas,
  Limpia/Hexagonal, Microservicios y SOA. *(Semana 6)*
- **Backend-for-Frontend (BFF)**: patrón que crea backends personalizados
  para diferentes tipos de cliente/interfaz (ej. Web y Mobile), evitando
  APIs "todo en uno". *(Semana 7)*
- **Agregado (Aggregate)**: grupo de entidades y objetos de valor
  relacionados tratados como una sola unidad para asegurar consistencia y
  encapsulación; representa un límite transaccional en DDD. *(Semana 7)*
- **Entidad Raíz (Aggregate Root)**: entidad principal de un agregado que
  controla la consistencia y es el único punto de acceso permitido para
  sistemas externos. *(Semana 7)*
- **Context Mapping (Mapeo de Contextos)**: técnica de DDD para visualizar
  relaciones entre Contextos Delimitados (patrones: Asociación, Núcleo
  Compartido, Cliente-Proveedor, Conformista, Capa Anti-Corrupción,
  Servicio Host Abierto, Lenguaje Publicado, Partnership, Separate Ways,
  Big Ball of Mud). *(Semana 7)*
- **Capa Anti-Corrupción (ACL)**: patrón que aísla dominios centrales de la
  influencia externa (ej. de un sistema legado), traduciendo el modelo
  externo al modelo propio protegido. *(Semanas 6-7)*
- **12-Factor App**: conjunto de doce principios para construir
  aplicaciones SaaS modernas, escalables, mantenibles y aptas para
  despliegue continuo, creado por ingenieros de Heroku. *(Semana 7)*
- **Despliegue Azul-Verde (Blue-Green)**: estrategia sin tiempo de
  inactividad con dos entornos idénticos en paralelo y un enrutador que
  cambia el tráfico entre ellos; rollback instantáneo, doble
  infraestructura. *(Semana 7)*
- **Despliegue Canario (Canary)**: exposición gradual de una nueva versión
  a un subconjunto pequeño de usuarios antes del lanzamiento completo;
  requiere monitoreo intensivo y triggers de rollback automático. *(Semana
  7)*
- **Despliegue Gradual (Rolling)**: actualización incremental de instancias
  en un pool, manteniendo siempre cierta capacidad disponible; eficiente
  en recursos pero requiere compatibilidad N-1. *(Semana 7)*

## Gaps y contradicciones

- **Alcance declarado del curso en AE**: `we1.md` indica explícitamente que,
  de los cinco dominios de Arquitectura Empresarial (Estrategia, Negocio,
  Información, Aplicaciones, Tecnología), el curso **no cubre en detalle**
  la Capa de Estrategia ni la Arquitectura de Negocio. Es una limitación de
  alcance declarada por la fuente, no una omisión de esta síntesis.

- **DDD mencionado antes de ser desarrollado**: "DDD" (Desarrollo/Diseño
  Guiado por el Dominio) aparece mencionado en `we1.md` (repaso de
  Arquitectura de Software 2) sin definición ni desarrollo. No se
  desarrolla en profundidad hasta `we6.md` y `we7.md`. Entre semanas 1 y 6
  el término queda sin contenido propio en el material curado.

- **CQRS y Event Sourcing fragmentados entre semanas**: CQRS se menciona en
  `we3.md` (catálogo de patrones, sin desarrollo), se desarrolla
  parcialmente en `we4.md` (como mecanismo de contrapresión) y en `we6.md`
  (como patrón de datos en MSA), pero ningún `weN.md` individual contiene
  una definición y desarrollo completos y unificados del patrón. Event
  Sourcing es mencionado en `we3.md`, `we4.md` y `we6.md`, siempre como
  complemento de CQRS o Saga, pero **nunca se define ni desarrolla como
  concepto independiente** en ninguna semana — queda como término
  mencionado sin desarrollo propio en todo el material.

- **Patrón Saga: tensión entre coreografía y orquestación**: `we4.md`
  define el patrón Saga explícitamente por coreografía (reacción
  descentralizada a eventos, sin orquestador). `we7.md`, en cambio,
  desarrolla el patrón Saga con dos enfoques igualmente válidos
  (coreografía y orquestación) y su propio diagrama de coreografía incluye
  un "Saga Orchestrator" central que coordina los pasos y dispara
  compensaciones — el propio `we4.md` señala esta tensión sin resolverla
  explícitamente entre el texto (coreografía = descentralizada) y el
  diagrama (con orquestador central). Al leer we4 y we7 en conjunto, el
  concepto de Saga es coherente (existen ambos enfoques como alternativas
  documentadas), pero dentro de we4 aislado hay una ambigüedad conceptual
  no resuelta por la fuente.

- **Elasticidad sin definición formal de una frase**: `we6.md` señala
  explícitamente que no se pudo capturar una diapositiva con una
  definición formal de una sola frase para "Elasticidad" (a diferencia de
  "Escalabilidad", que sí la tiene). El concepto queda definido solo de
  forma indirecta (características, analogía, distinción con
  escalabilidad).

- **Contrapresión sin definición encapsulada única**: `we4.md` indica
  explícitamente que no incluye una definición formal de "contrapresión"
  en una sección de terminología dedicada; el concepto se explica mediante
  el fenómeno, una analogía (tuberías de agua) y un diagrama de causas,
  sin una definición de una sola frase equivalente a la de otros términos
  del mismo documento.

- **Ambigüedad sobre "Flujos Reactivos" (Reactive Streams)**: `we4.md`
  presenta el término tanto en la tabla general de técnicas de manejo de
  contrapresión como en una sección específica de "Procesadores de Flujos:
  Control de Flujo Reactivo", sin aclarar si ambas apariciones refieren
  exactamente al mismo concepto o si una es un caso particular de la otra.

- **Términos mencionados sin desarrollo conceptual propio** (quedan como
  nombres de herramienta/estándar, no como conceptos explicados):
  - `we1.md`: TOGAF, ArchiMate.
  - `we2.md`: ETL (siglas no explicadas), AWS EventBridge, Azure Event
    Grid, AS2.
  - `we3.md`: Apache Beam (modelo de programación unificado), KSQL,
    Materialize, RisingWave.
  - `we6.md`: ADO.NET, Dapper, OpenTelemetry (mencionado como herramienta
    pero sin mecánica propia), Terraform, CloudFormation, Pact, Kafka
    Connect, Snowflake/BigQuery, Neo4j.
  - `we7.md`: Change Data Capture (mencionado en el espectro de
    integración sin desarrollo); "monolitos modulares" y
    "macro-servicios" (mencionados en la síntesis de DDD+MSA sin
    definición propia).

- **Duplicación/repetición textual dentro de una misma semana**: `we2.md`
  señala que las definiciones de "Interoperabilidad" e "Integración de
  Sistemas" aparecen con texto introductorio casi idéntico en dos
  diapositivas consecutivas del material original; podría ser repetición
  intencional o duplicación de contenido en la fuente, sin que el material
  lo aclare.

- **Errores/inconsistencias menores señalados por las propias curaciones
  semanales** (no afectan el contenido conceptual sustantivo, pero están
  documentados en la fuente y se listan aquí por completitud):
  - `we1.md`: texto truncado/ilegible en una diapositiva sobre planificación
    de migración ("Definir Planes"); listado de referencias externas
    excluido del contenido curado.
  - `we2.md`: texto truncado en la diapositiva "La Planificación lo es
    Todo" / "Definir Planes".
  - `we3.md`: error tipográfico "Pregfintate siempre" (probablemente
    "Pregúntate siempre"); cifras de negocio citadas (caída de conversión
    7%, abandono 40%, productividad +30% vía Aberdeen Group) sin fuente
    primaria verificable en la diapositiva.
  - `we5.md`: posible error tipográfico "KaGa" en vez de "Kafka" en un
    diagrama; cifras sobre Netflix (10K+ microservicios, 99.9% uptime, 30%
    ahorro de costos, 230M suscriptores) sin fuente primaria adicional más
    allá de la mención genérica del caso.
  - `we6.md`: diapositiva final con texto visualmente distorsionado
    ("Asynnchronation", "Synchroncoous", etc.) en un diagrama circular de
    cierre.
  - `we7.md`: posible error de cita de fuente en el diagrama de "Límites de
    Servicio" (URL de la fuente citada no corresponde temáticamente al
    contenido de esa diapositiva); bloque de "Estrategias de Despliegue"
    presentado como material complementario no anunciado explícitamente en
    la agenda inicial de la semana.

