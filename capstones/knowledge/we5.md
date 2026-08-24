# Semana 5 — Arquitectura de Microservicios I (MSA I)

## Resumen del contenido

El documento corresponde a la Semana 5 del curso Arquitectura de Software 3
(Jala University). Su objetivo declarado es "comprender los principios y
prácticas de la arquitectura de microservicios". La sesión abre con una
recapitulación de conceptos de la Semana 4 (Rendimiento de Sistemas II)
vinculados a procesos de larga duración y contrapresión, y luego introduce en
profundidad la Arquitectura de Microservicios (MSA): su definición, cómo se
compara con la arquitectura monolítica, sus características fundamentales
(responsabilidad única, despliegue independiente, acoplamiento débil,
desarrollo/despliegue autónomo, gestión de datos descentralizada, comunicación
entre servicios, aislamiento de fallos, entrega/despliegue continuo,
escalabilidad y optimización de recursos, persistencia y desarrollo políglota),
sus ventajas, sus desafíos y recomendaciones para su adopción. Cierra con
conclusiones que enmarcan la adopción de microservicios como una decisión
estratégica de trade-offs.

La agenda de la semana declarada en el material es:
1. Recapitulación sobre Rendimiento de Sistemas II.
2. Introducción a la Arquitectura de Microservicios (MSA).
3. Características de la Arquitectura de Microservicios.

Este material se ubica en la Semana 5 del desglose de 8 semanas del curso
(Semana 1: Arquitectura Empresarial; Semana 2: Integración de Sistemas;
Semana 3: Rendimiento de Sistemas I; Semana 4: Rendimiento de Sistemas II;
Semana 5: MSA I; Semana 6: MSA II; Semana 7: MSA III; Semana 8: Presentaciones
del Proyecto Final).

## Conceptos clave

### Rendimiento de Sistemas (recapitulación de la semana anterior)

**Definición:** El rendimiento de sistemas se refiere a la eficiencia con la
que los sistemas de software utilizan recursos (CPU, memoria, disco, red)
para cumplir con los requisitos de usuario y negocio como throughput,
latencia, escalabilidad y confiabilidad.

**Explicación:** Rendimiento de Sistemas II (semana previa) se enfocó en
diseñar sistemas que puedan manejar altas cargas y procesamiento de datos a
gran escala. Esta sección funciona como puente hacia MSA, ya que varios
conceptos de rendimiento (procesos de larga duración, contrapresión,
patrones de resiliencia) motivan por qué se necesitan arquitecturas
distribuidas y desacopladas como los microservicios.

### Proceso de Larga Duración

**Definición:** Tarea cuyo tiempo de ejecución es lo suficientemente
significativo que no puede o no debería manejarse dentro del alcance de una
sola petición de usuario de corta duración (ej., un ciclo petición/respuesta
HTTP).

**Explicación:**
- **Problema:** bloquear un hilo de petición por minutos u horas es
  insostenible. Agota los recursos del servidor (hilos, memoria), lleva a
  timeouts y proporciona una experiencia de usuario terrible.
- **Objetivo:** desacoplar la iniciación de un proceso de su ejecución y
  finalización. Esto es fundamental para lograr asincronía y escalabilidad.
- **Ejemplos:** generar un reporte complejo, procesar un archivo de video
  grande, enviar una campaña de correo masivo, trabajos ETL (Extraer,
  Transformar, Cargar).
- **Implicación de rendimiento:** los procesos de larga duración son una
  fuente primaria de picos de carga impredecibles.

### Contrapresión (Backpressure)

**Definición:** Mecanismo de retroalimentación donde un componente del
sistema (el receptor) que está luchando por mantener el ritmo de la tasa de
datos entrantes puede señalar al componente ascendente (el emisor) para que
se desacelere.

**Explicación:** Sin contrapresión, los productores rápidos inevitablemente
abrumarán a los consumidores lentos, lo que llevaría a:
- **Crecimiento ilimitado de cola:** los mensajes se acumulan en memoria
  hasta que el sistema se queda sin ella y se bloquea.
- **Fallas en cascada:** el servicio lento falla, causando que la cola falle,
  lo que luego causa que el productor falle.
- **Pérdida de datos:** cuando los búferes están llenos, los nuevos datos a
  menudo se descartan.

**Características:**
- Es un patrón de resistencia crítico. No se trata de hacer el sistema más
  rápido; se trata de hacerlo estable y predecible bajo carga, que es una
  cualidad arquitectónica más importante que la velocidad pura.

**Enfoques para manejar la contrapresión:**
- **Colas (el patrón más común):** un productor envía un mensaje a una cola
  y puede continuar inmediatamente con su trabajo. Un consumidor extrae
  mensajes de la cola a su propio ritmo. La cola actúa como un buffer,
  absorbiendo picos de carga. La contrapresión se aplica cuando la cola
  alcanza sus límites (ej., tamaño máximo).
- **Procesadores de flujos:** sistemas como Apache Kafka, Apache Pulsar o
  Kinesis que tratan los datos como un flujo continuo e ilimitado. Son
  esencialmente registros distribuidos y duraderos. Los consumidores extraen
  datos a su propio ritmo, y el sistema puede manejar la contrapresión
  permitiendo que los consumidores se retrasen respecto a los productores.
- **Arquitectura Dirigida por Eventos (EDA):** estilo arquitectónico más
  amplio donde los componentes se comunican a través de eventos (un registro
  de algo que sucedió). A menudo utiliza colas o flujos como mecanismo
  subyacente. La contrapresión se gestiona a nivel del bus de eventos.
- **CQRS (Segregación de Responsabilidad de Comandos y Consultas):** separa
  el modelo para leer datos (consultas) del modelo para actualizar datos
  (comandos). El modelo de escritura (lado comando) publica eventos que se
  utilizan para actualizar uno o más modelos optimizados para lectura (lado
  consulta). Esta separación permite diferentes estrategias de escalado y
  contrapresión para lecturas y escrituras.
- **Procesadores de trabajos:** sistemas que gestionan un conjunto de
  procesos trabajadores para manejar trabajos asíncronos. Pueden limitar el
  número de trabajos concurrentes, implementar estrategias de reintento con
  retroceso exponencial, y mover trabajos fallidos a una cola de mensajes no
  entregados para análisis posterior.

### Arquitectura de Microservicios (MSA)

**Definición:** Estilo arquitectónico moderno para construir aplicaciones de
software como un conjunto de servicios pequeños, independientes y
débilmente acoplados. Cada servicio, o "microservicio", está diseñado para
implementar una capacidad de negocio específica, funciona en su propio
proceso, y se comunica con otros servicios a través de mecanismos ligeros
bien definidos, a menudo APIs basadas en HTTP.

**Explicación:** Este enfoque representa un cambio significativo respecto de
la forma tradicional monolítica de construir aplicaciones, enfatizando la
agilidad, escalabilidad y resistencia.

**Características:** un microservicio es una unidad autocontenida. En el
ejemplo de una gran aplicación de comercio electrónico, en lugar de
construirla como un bloque gigante de código, se divide en servicios más
pequeños y enfocados, por ejemplo:
- **Servicio de Cuenta:** maneja el registro de usuarios, autenticación y
  perfiles.
- **Servicio de Inventario:** gestiona información de productos, inventario
  y categorías.
- **Servicio de Envío:** procesa solicitudes de envío y rastrea envíos.
- **Servicio de Carrito de Compras:** gestiona el carrito de compras del
  usuario.

**Relaciones:**
- Se contrasta directamente con la Arquitectura Monolítica (ver sección de
  Comparaciones).
- Sus características fundamentales (Responsabilidad Única, Despliegue
  Independiente, Acoplamiento Débil, Desarrollo y Despliegue Autónomo,
  Gestión de Datos Descentralizada, Comunicación entre Servicios,
  Aislamiento de Fallos, Entrega y Despliegue Continuo, Escalabilidad y
  Optimización de Recursos, Persistencia y Desarrollo Políglota) están
  interconectadas entre sí y colectivamente habilitan los beneficios
  centrales de agilidad, escalabilidad y resistencia.

### Responsabilidad Única (a nivel de microservicio)

**Definición:** Cada microservicio está diseñado para manejar una capacidad
de negocio específica o función de dominio. Debe tener una única razón para
cambiar, adhiriéndose al Principio de Responsabilidad Única (SRP) del diseño
orientado a objetos, pero aplicado a nivel de servicio.

**Explicación:** en la práctica, en lugar de un solo `OrderService` que
maneja todo, se tendrían servicios como `InventoryService` (gestiona niveles
de inventario), `PaymentService` (procesa pagos) y `ShippingService` (maneja
logística de envíos). Los límites del servicio se definen alrededor de
dominios de negocio, no de capas técnicas.

**Características / Beneficios:**
- **Mantenibilidad mejorada:** bases de código más pequeñas y enfocadas son
  más fáciles de entender, depurar y modificar.
- **Cohesión mejorada:** todo el código relacionado para una tarea
  específica está contenido dentro de un servicio.
- **Propiedad clara:** es más fácil asignar a un equipo específico la
  responsabilidad de una función de negocio específica.

### Desplegable Independientemente

**Definición:** Posiblemente la característica más crítica de MSA. Cada
microservicio puede ser construido, probado y desplegado a producción
independientemente de otros servicios. No hay necesidad de redesplegar toda
la aplicación por un cambio en una parte del sistema.

**Explicación:** en la práctica, un equipo puede actualizar el
`UserProfileService` para agregar un nuevo campo y desplegarlo sin
coordinar con los equipos que gestionan el `ProductCatalogService` o el
`OrderService`. Esto se habilita usando pipelines de Entrega Continua que
tienen alcance a servicios individuales.

**Características / Beneficios:**
- **Tiempo al mercado más rápido:** los equipos pueden lanzar funcionalidades
  y correcciones de errores para su servicio sin esperar un ciclo de
  lanzamiento monolítico.
- **Riesgo reducido:** un despliegue fallido afecta solo un servicio, no
  toda la aplicación.
- **Agilidad:** habilita lanzamientos rápidos y frecuentes.

### Acoplamiento Débil

**Definición:** Los servicios están diseñados para tener dependencias
mínimas entre sí. Un cambio en un servicio no debería requerir un cambio en
otro. Interactúan a través de APIs y contratos bien definidos y estables,
sin conocer los detalles de implementación interna de otros servicios.

**Explicación:** en la práctica, los servicios se comunican de forma
asíncrona mediante mensajes (ej., usando un intermediario de mensajes como
RabbitMQ o Kafka) o síncronamente vía APIs RESTful o gRPC. No comparten
nada; no hay conexiones directas a bases de datos o estado en memoria entre
servicios. La API pública de un servicio es un contrato que debe permanecer
estable.

**Características / Beneficios:**
- **Resistencia:** el fallo o mal rendimiento de un servicio no se propaga
  a otros si se maneja adecuadamente.
- **Capacidad de evolución:** un servicio puede ser completamente reescrito
  con una nueva pila tecnológica sin afectar a sus consumidores, siempre que
  se respete el contrato de la API.
- **Desarrollo independiente:** los equipos pueden trabajar de forma
  autónoma.

### Desarrollo y Despliegue Autónomos

**Definición:** Extiende las ideas de despliegue independiente y
acoplamiento débil al nivel organizacional. Equipos multifuncionales (ej.,
desarrolladores, testers y DevOps) pueden poseer todo el ciclo de vida de
uno o más servicios; desde el diseño y desarrollo hasta el despliegue y
operaciones ("Lo construyes, lo ejecutas" / "You Build It, You Run It").

**Explicación:** en la práctica, un "Equipo de Envíos" es totalmente
responsable del `ServicioEnvíos`, incluyendo sus decisiones tecnológicas,
desarrollo, pruebas y monitoreo 24/7. Esta autonomía reduce la necesidad de
coordinación entre equipos y gastos burocráticos.

**Características / Beneficios:**
- **Mayor velocidad del equipo y propiedad:** los equipos tienen el poder de
  tomar decisiones y moverse rápidamente.
- **Alineación con objetivos de negocio:** los equipos se organizan
  alrededor de capacidades de negocio, llevando a mejor alineación.
- **Reducción de cuellos de botella:** los equipos no se bloquean por un
  equipo central de infraestructura o base de datos.

### Gestión de Datos Descentralizada

**Definición:** Cada microservicio posee sus datos de dominio privados y los
expone solo a través de su API. Ninguna base de datos única y compartida es
utilizada por todos los servicios. El patrón base-de-datos-por-servicio es
una implementación común.

**Explicación:** en la práctica, el `ServicioPedidos` tiene su propia base de
datos "Pedidos" y el `ServicioClientes` tiene su propia base de datos
"Clientes". Si el `ServicioPedidos` necesita datos de clientes, no lee
directamente la base de datos del `ServicioClientes`; en su lugar, llama a
la API del `ServicioClientes` o mantiene una copia de solo lectura de los
datos que necesita (usando patrones como CQRS o Saga).

**Características / Beneficios:**
- **Encapsulación de datos:** los servicios son libres de elegir el modelo
  de datos y tecnología de base de datos que mejor se adapte a sus
  necesidades (relacionado con Persistencia Políglota).
- **Reducción de contención:** no más cuellos de botella de base de datos de
  un esquema monolítico único.
- **Propiedad clara de datos:** es explícito qué servicio es la fuente de
  verdad para qué datos.

### Comunicación Entre Servicios

**Definición:** Dado que los servicios están distribuidos, necesitan un
mecanismo para comunicarse entre sí. La comunicación puede ser síncrona o
asíncrona y debe ser eficiente y confiable.

**Explicación:**
- **Comunicación síncrona:** típicamente usada para escenarios
  petición/respuesta.
  - **REST sobre HTTP:** el enfoque más común, usando JSON/XML.
  - **gRPC:** un framework RPC de alto rendimiento, a menudo usando Protocol
    Buffers.
- **Comunicación asíncrona:** usada para desacoplamiento y flujos de trabajo
  dirigidos por eventos.
  - **Intermediarios de mensajes (ej., RabbitMQ, Apache Kafka):** los
    servicios publican eventos, y otros servicios se suscriben a ellos sin
    conocer la fuente.
- El material visual (diagrama de patrones de comunicación) distingue tres
  patrones: Síncrono (Service A ↔ Service B ↔ Service C vía HTTP sync,
  pasando por un API Gateway), Asíncrono uno a uno (los servicios se
  comunican mediante colas intermedias, con operaciones Listen/Receive), y
  Publish/Subscribe (un servicio publica una notificación a un Topic y
  múltiples servicios/instancias se suscriben y reciben).

**Beneficios:**
- **Flexibilidad:** permite diferentes patrones de interacción
  (petición/respuesta, dirigido por eventos).
- **Desacoplamiento:** la mensajería asíncrona, en particular, promueve el
  acoplamiento débil y la resistencia.

### Aislamiento de Fallos

**Definición:** La arquitectura está diseñada para esperar y manejar fallos
de manera elegante. Un fallo en un servicio debe ser contenido y no derribar
todo el sistema.

**Explicación:** en la práctica se utilizan:
- **Patrón circuit breaker:** previene que un servicio intente
  repetidamente ejecutar una operación que probablemente fallará (ej., si un
  servicio downstream está caído).
- **Mamparos (bulkheads):** aíslan recursos (como pools de hilos) para
  diferentes servicios, de modo que un fallo en uno no consuma todos los
  recursos.
- **Degradación elegante:** la aplicación puede proporcionar funcionalidad
  reducida en lugar de fallar completamente (ej., las recomendaciones de
  productos pueden no estar disponibles, pero el usuario aún puede navegar
  productos).

**Beneficios:**
- **Mejor resistencia y disponibilidad:** el sistema en su conjunto
  permanece operativo incluso cuando componentes individuales fallan.
- **Mejor experiencia de usuario:** previene apagones completos del sistema.

### Entrega y Despliegue Continuo (CI/CD en MSA)

**Definición:** Los microservicios son un facilitador clave para CI/CD. La
naturaleza pequeña e independiente de los servicios hace factible automatizar
todo el pipeline desde el commit de código hasta el despliegue en
producción.

**Explicación:** en la práctica, cada servicio tiene su propio pipeline de
CI/CD. Los procesos automatizados manejan la construcción, pruebas
(unitarias, de integración, de contrato), containerización (ej., Docker), y
despliegue del servicio. Infraestructura como Código (IaC) se usa para
gestionar la infraestructura subyacente de manera consistente.

**Beneficios:**
- **Lanzamientos rápidos y confiables:** la automatización reduce el error
  humano y permite despliegues frecuentes y de bajo riesgo.
- **Retroalimentación rápida:** los desarrolladores obtienen feedback
  inmediato sobre sus cambios.

### Persistencia y Desarrollo Políglota

**Definición:** Los equipos tienen libertad para elegir la mejor pila
tecnológica (lenguajes de programación, frameworks, bases de datos) para su
servicio específico, en lugar de estar forzados a usar una tecnología única
mandatada por la organización.

**Explicación:** en la práctica, un `AnalyticsService` intensivo en datos
podría usar Python con Pandas y una base de datos columnar; un
`PaymentService` de alto rendimiento podría usar Go con una base de datos
relacional para transacciones ACID; un `ProductCatalogService` que necesite
lecturas rápidas podría usar Node.js con una base de datos NoSQL de
documentos.

**Beneficios:**
- **Herramienta correcta para el trabajo:** optimiza el rendimiento y la
  productividad del desarrollador.
- **Evita el vendor lock-in tecnológico:** el sistema no depende del
  ecosistema de una sola tecnología.
- **Fomenta la innovación:** los equipos pueden experimentar y adoptar
  nuevas tecnologías más fácilmente.

### Escalabilidad y Optimización de Recursos

**Definición:** Los microservicios permiten escalabilidad de grano fino. En
lugar de escalar toda la aplicación monolítica, solo los servicios
específicos que están bajo alta carga son escalados. Esto permite un uso
óptimo y costo-efectivo de los recursos de infraestructura.

**Explicación:** en la práctica, durante una venta flash, el
`ProductCatalogService` y `OrderService` podrían experimentar alto tráfico,
mientras que el `ReportingService` permanece en carga base. Con
microservicios, se puede escalar horizontalmente solo el
`ProductCatalogService` y `OrderService` agregando más instancias, sin
desperdiciar recursos en el `ReportingService`. En un monolito, habría que
escalar toda la aplicación, incluyendo todos sus componentes, lo cual es
ineficiente y costoso.

**Beneficios:**
- **Eficiencia de costos:** los costos de infraestructura están
  directamente alineados con los patrones de uso real.
- **Rendimiento mejorado:** los recursos se enfocan donde más se necesitan,
  previniendo cuellos de botella y asegurando servicios responsivos.
- **Elasticidad:** el sistema puede adaptarse más dinámicamente a cargas
  cambiantes escalando componentes individuales hacia adentro y hacia
  afuera.

## Enfoques, métodos o herramientas

### API Gateway

Punto de entrada central para el tráfico externo. Maneja el enrutamiento
(routing) de peticiones hacia los microservicios correspondientes, la
seguridad y el rate limiting (limitación de tasa). Aparece en el diagrama de
ejemplo de e-commerce como intermediario entre el mobile app / browser y los
servicios de Account, Inventory y Shipping.

### Service Discovery

Permite que los servicios localicen y se comuniquen dinámicamente entre sí,
junto con balanceo de carga (load balancing).

### Load Balancer

Distribuye la distribución de tráfico entre instancias de un mismo servicio.

### Containerización (Docker) y Orquestación (Kubernetes)

Empaquetar servicios con sus dependencias (Docker) y gestionarlos con
orquestadores (Kubernetes). Mencionados como componentes clave de soporte
para microservicios y como herramientas críticas (no opcionales) para
gestionar despliegue, monitoreo y pruebas en un contexto DevOps maduro.

### Sistemas de mensajería / Intermediarios de mensajes

Facilitan la comunicación asíncrona y desacoplada entre servicios (ej.,
RabbitMQ, Apache Kafka).

### Herramientas de Observabilidad (Observability Tools)

Logging centralizado, métricas y trazado distribuido (distributed tracing)
son esenciales para monitorear la salud y depurar el sistema. Se mencionan
específicamente herramientas de trazado distribuido como Jaeger o Zipkin.

### Lightweight Protocols (protocolos ligeros)

Mecanismos de comunicación como REST, gRPC o colas de mensajes que conectan
servicios débilmente acoplados (Loosely Coupled Services), según el diagrama
de Visión General.

### Message Bus / Event Bus

Infraestructura de comunicación asíncrona que conecta servicios como
Notification Service, Analytics Service y otros, presente en el diagrama de
Visión General de MSA.

### Infraestructura de soporte (Supporting Infrastructure)

Según el diagrama de Visión General, incluye: Monitoring and Logging, CI/CD
Pipeline (despliegue automatizado), Config Management, Container
Orchestration y API Documentation.

### Patrones mencionados sin desarrollo extenso

- **Patrón Saga:** mencionado como reemplazo de las transacciones ACID
  tradicionales para mantener consistencia eventual entre servicios con
  bases de datos propias (mencionado en Desafíos y en Gestión de Datos
  Descentralizada, pero no desarrollado en profundidad en este documento).
- **CQRS:** mencionado tanto en la recapitulación de Rendimiento de
  Sistemas II como en Gestión de Datos Descentralizada, sin desarrollo
  extenso adicional en este documento (se define brevemente en la sección
  de recapitulación).
- **Patrón circuit breaker y mamparos (bulkheads):** mencionados como
  prácticas de Aislamiento de Fallos, sin mecánica interna detallada.

## Procedimientos o procesos

### Adoptando Microservicios (recomendaciones de adopción)

1. **Empezar Pequeño y Planificar:** identificar contextos acotados
   (bounded contexts) claros y servicios no críticos para comenzar la
   migración. Enfocarse en aislar capacidades de negocio.
2. **Invertir en Infraestructura:** comprometerse con automatización sólida
   para despliegue, monitoreo y pruebas. Herramientas como Kubernetes son
   críticas, no opcionales.
3. **Empoderar Equipos Autónomos:** estructurar equipos alrededor de
   servicios, dándoles propiedad completa sobre desarrollo, pruebas y
   operación.

### Pipeline de Entrega Continua (Continuous Delivery Pipeline)

Descrito visualmente como un flujo: Repository / Continuous
Integration / Artefact-Code → Deployment & Test Automation → Continuous
Verification (funcionalidad, seguridad, rendimiento) con Automated Quality
Gates → Rollback Automation → Production → Business Users. Cada etapa
incluye automatización y puertas de calidad automatizadas antes de avanzar.

## Ejemplos y casos

### Aplicación de comercio electrónico (ejemplo guía)

Usado repetidamente en el documento para ilustrar la descomposición de un
monolito en microservicios: Servicio de Cuenta, Servicio de Inventario,
Servicio de Envío, Servicio de Carrito de Compras. También aparece en el
diagrama de arquitectura de referencia (fuente: microservices.io) con Mobile
app y Browser accediendo vía API Gateway o Storefront WebApp a Account
Service, Inventory Service y Shipping Service, cada uno con su propia base
de datos (Account DB, Inventory DB, Shipping DB).

### Netflix y Atlassian

Casos de impacto real: migraron exitosamente a microservicios para apoyar
su entrega rápida de características y asegurar alta disponibilidad del
sistema para millones de usuarios mundialmente.

### Plataformas de comercio electrónico (caso genérico)

Escalan los servicios de inventario y pago independientemente para manejar
picos de tráfico extremos durante eventos de ventas.

### Instituciones financieras

Usan servicios aislados para seguridad mejorada, como colocar la detección
de fraude en un dominio separado y estrictamente controlado.

### Ejemplo de Responsabilidad Única

En lugar de un solo `OrderService` que maneja todo, se dividiría en
`InventoryService`, `PaymentService` y `ShippingService`.

### Ejemplo de Desarrollo/Despliegue Autónomo (Team Alpha, Beta, Gamma)

Diagrama con tres equipos multifuncionales (Developers, Testers, DevOps)
cada uno con propiedad de ciclo de vida completo de un servicio: Team Alpha
→ Payment API; Team Beta → User Management; Team Gamma → Notification
Service. Cada equipo tiene responsabilidades de: end-to-end service
ownership, production support & on-call, performance & scaling, security &
compliance, continuous improvement; y prácticas autónomas: pipelines CI/CD
independientes, dashboards de monitoreo dedicados, documentación específica
del servicio, suites de pruebas automatizadas.

### Ejemplo de Gestión de Datos Descentralizada

`ServicioPedidos` con base de datos "Pedidos" y `ServicioClientes` con base
de datos "Clientes"; si el primero necesita datos del segundo, llama a su
API en lugar de leer su base de datos directamente. Diagrama adicional
(fuente externa) muestra tres microservicios (Admin, Orders & Booking,
Search) cada uno con su propia base de datos (MySQL, MySQL, ElasticSearch),
componentes de Data Capture y Event Handlers, conectados a un "distributed,
replicated event log" (Kafka).

### Ejemplo de Aislamiento de Fallos

Diagrama "Fault Isolation": el sistema puede seguir funcionando aunque el
servicio de Payments esté caído (marcado con una X), ya que Users,
Notifications, Disputes, Bookings y Reviews no dependen directamente de él
para operar.

### Ejemplo de Persistencia Políglota

Diagrama con 12 microservicios, cada uno usando una combinación distinta de
lenguaje y base de datos: Microservice 1 (PHP/HTML/jQuery → RDF DB),
Microservice 2 (Python → PostgreSQL), Microservice 3 (Ruby on Rails →
MySQL), Microservice 4 (PERL → Informix), Microservice 5 (ASP.NET → MSSQL),
Microservice 6 (Node.JS → JSON), Microservice 7 (PHP → Oracle DB),
Microservice 8 (JavaScript → Redis), Microservice 9 (C# → MS SQL),
Microservice 10 (ColdFusion → XML), Microservice 11 (AngularJS → MariaDB),
Microservice 12 (Java → Oracle DB).

### Ejemplo de Escalabilidad de grano fino

Durante una venta flash, `ProductCatalogService` y `OrderService`
experimentan alto tráfico mientras `ReportingService` permanece en carga
base; solo los dos primeros se escalan horizontalmente.

## Comparaciones

### Arquitectura Monolítica vs. Arquitectura de Microservicios

| Característica | Arquitectura Monolítica | Arquitectura de Microservicios |
|---|---|---|
| Estructura | Una sola base de código unificada para toda la aplicación. Todos los componentes (UI, lógica de negocio, acceso a datos) están interconectados. | Una colección de servicios pequeños e independientes, cada uno con su propia base de código y responsabilidad. |
| Desarrollo | Los equipos a menudo trabajan en la misma base de código, lo que puede llevar a conflictos de fusión y sobrecarga de coordinación. | Los equipos pueden organizarse alrededor de servicios, trabajando de forma autónoma y usando diferentes pilas tecnológicas si es necesario. |
| Despliegue | Toda la aplicación debe ser desplegada como una unidad, incluso para un cambio pequeño. | Cada servicio puede ser desplegado independientemente, habilitando entrega continua y ciclos de lanzamiento más rápidos. |
| Escalado | Todo el monolito debe ser escalado horizontalmente, incluso si solo una característica está experimentando alta carga. Esto es ineficiente. | Los servicios individuales pueden ser escalados independientemente basándose en su demanda específica, llevando a mejor utilización de recursos. |
| Pila Tecnológica | Típicamente usa una sola pila tecnológica estandarizada (ej., Java/Spring, .NET) para toda la aplicación. | Persistencia y Programación Políglota: cada servicio puede usar la tecnología (lenguaje de programación, base de datos) que mejor se adapte a sus necesidades. |
| Base de Datos | Usualmente una sola base de datos relacional grande compartida por todos los componentes de la aplicación. | Cada servicio posee su base de datos, que puede ser SQL o NoSQL, dependiendo de los requerimientos de datos del servicio. |
| Confiabilidad | Un error en cualquier módulo puede derribar toda la aplicación. | Una falla en un servicio no debería colapsar todo el sistema. La aplicación puede degradarse gradualmente. |

Diagrama complementario (fuente: cloudflight.io) contrasta visualmente:
Arquitectura Monolítica (User Interface conectada a Business Logic y Data
Access Layer, todo apuntando a una sola Data Base) vs. Arquitectura de
Microservicios (User Interface central conectada a múltiples
Micro-services, cada uno con su propia Data Base).

## Información visual relevante

### Diagrama de arquitectura de referencia (microservices.io)

Muestra Mobile app y Browser accediendo mediante REST API / Web
respectivamente. El Mobile app pasa por un API Gateway; el Browser accede a
través de una Storefront WebApp. Ambos puntos de entrada se conectan, vía
REST API, a Account Service, Inventory Service y Shipping Service, cada uno
con su propia base de datos (Account DB, Inventory DB, Shipping DB). Ilustra
el principio de base de datos por servicio y el rol del API Gateway y de la
capa de agregación (WebApp) como cliente de múltiples servicios.

### Microservice Characteristics (diagrama tipo mapa radial, en inglés)

Presenta cinco características centrales alrededor de un núcleo
"Microservices": Built for Failure (diseñados esperando que servicios
dependientes puedan fallar), Single Responsibility (cada microservicio se
enfoca en hacer una cosa bien, alineado con un dominio de negocio
específico), Lightweight Communication (comunicación sobre protocolos
estándar como HTTP/REST o colas de mensajes), Independence (los servicios
pueden desarrollarse, desplegarse, escalarse y actualizarse
independientemente unos de otros), Decentralized Data (cada servicio tiene
su propia base de datos privada, evitando acceso directo a datos desde
otros servicios).

### Advantages of Microservices Architecture (diagrama tipo árbol, en inglés)

Organiza los beneficios en un nodo central "Microservices Benefits" con seis
ramas: Agility and Faster Time-to-Market (despliegues rápidos y frecuentes
por equipos autónomos), Resilience and Fault Isolation (estabilidad del
sistema aislando fallas de servicio), Easier to Understand and Maintain
(simplifica la gestión de código con dominios de servicio enfocados),
Scalability (escalado independiente de servicios según demanda),
Technological Freedom (libertad de elegir herramientas óptimas por
servicio), Continuous Deployment (soporta prácticas DevOps modernas con
capacidad de despliegue independiente).

### Diagrama Monolithic vs. Microservice Architecture (cloudflight.io)

Ver sección de Comparaciones — representación visual del contraste
estructural entre ambos estilos, con foco en la relación entre interfaz de
usuario, lógica y bases de datos.

### Key Components Supporting Microservices (diagrama radial, en inglés)

Cinco componentes de soporte: Containerization (empaquetar servicios con sus
dependencias vía Docker y gestionarlos con orquestadores como Kubernetes),
API Gateway (punto de entrada central para tráfico externo, maneja
enrutamiento, seguridad y rate limiting), Service Discovery (permite a los
servicios localizarse y comunicarse dinámicamente, con balanceo de carga),
Observability Tools (logging centralizado, métricas y trazado distribuido
esenciales para monitorear salud y depurar), Messaging Systems (facilitan
comunicación asíncrona y desacoplada entre servicios, ej. Kafka o RabbitMQ;
en el diagrama aparece escrito como "KaGa" — posible error tipográfico de
"Kafka").

### Diagrama "Visión General" de MSA

Diagrama de arquitectura de referencia con capas: API Gateway (Entry Point /
Request Routing) en la parte superior, conectado a Service Discovery
(Registry & Lookup) y Load Balancer (Distribution); debajo, Lightweight
Protocols (REST, gRPC, Message Queues); luego una capa de "Loosely Coupled
Services" con seis servicios de ejemplo (User Service - Fine-grained, Order
Service - Independent, Payment Service - Autonomous, Inventory Service -
Scalable, Notification Service - Event-Driven, Analytics Service -
Deployable, Auth Service - Specialized), cada uno con su propia DB; debajo,
un Message Bus / Event Bus (Asynchronous Communication); y en la base,
"Supporting Infrastructure" con Monitoring and Logging, CI/CD Pipeline
(Automated Deploy), Config Management, Container Orchestration y API
Documentation.

### Diagrama Single Responsibility Principle in Microservices

Client → API → cuatro servicios independientes: Order Service (Create and
manage orders), Inventory Service (Manage product stock), Payment Service
(Handle payment transactions), Notification Service (Send order
confirmation and shipping updates).

### Diagrama de relación Docker/Kubernetes/Cassandra

Muestra un Web User accediendo desde Client Device a Provider Cloud, donde
Kubernetes orquesta múltiples contenedores Docker que interactúan con un
Cassandra Cluster, cada uno respaldado por un Persistent Volume. Ilustra la
relación entre containerización, orquestación y almacenamiento persistente
en un contexto de microservicios.

### Diagrama de patrones de comunicación (dzone.com)

Tres patrones ilustrados: Synchronous (Client → API Gateway → Service A ↔
Service B ↔ Service C, todo vía HTTP sync), Asynchronous one-to-one (Service
A envía a una Queue que Service B escucha/recibe, y así sucesivamente en
cadena), Publish/Subscribe (Service A publica una notificación a un Topic,
y grupos de instancias de Service B y Service C reciben la notificación).

### Diagrama Fault Isolation (milanjovanovic.tech)

Ver sección de Ejemplos — ilustra cómo el sistema puede seguir funcionando
aun cuando el servicio de Payments está caído, porque otros servicios
(Users, Notifications, Disputes, Bookings, Reviews) no dependen
directamente de él.

### Diagrama Continuous Delivery Pipeline (inmobi.com)

Ilustra el flujo: Repository/Continuous Integration/Artefact-Code → stages →
Deployment & Test Automation → Continuous Verification (Functionality /
Security / Performance) con Automated Quality Gates → Rollback Automation →
Production → Business Users.

### Diagrama de Persistencia Políglota (researchgate.net)

Ver sección de Ejemplos — 12 microservicios con combinaciones distintas de
lenguaje y base de datos.

### Diagrama Scalability and Resource Optimization in Microservices (en inglés)

Nodo central "Microservices — Resource Optimization & Scalability" con tres
ramas: Cost Efficiency (Pay-per-use Model, Resource Right-Sizing,
Auto-Scaling Savings), Improved Performance (Independent Scaling, Load
Distribution, Reduced Latency), Elasticity (Dynamic Provisioning,
Auto-Healing, Geographic Distribution).

### Diagrama Tightly Coupled vs. Loosely Coupled (yusufdagtekin.com)

Comparación visual de dos redes de nodos: "Tightly Coupled — Many
Dependencies" (cuatro nodos con múltiples flechas bidireccionales entre
todos ellos) vs. "Loosely Coupled — Some Dependencies" (seis nodos con pocas
conexiones dirigidas entre sí). Ilustra el concepto de acoplamiento débil
aplicado a la comunicación entre servicios.

## Terminología importante

- **MSA (Microservices Architecture):** estilo arquitectónico que estructura
  una aplicación como un conjunto de servicios pequeños, independientes y
  débilmente acoplados, cada uno responsable de una capacidad de negocio
  específica.
- **Proceso de Larga Duración:** tarea cuya ejecución no puede resolverse
  dentro de una petición/respuesta de corta duración.
- **Contrapresión (Backpressure):** mecanismo de retroalimentación para que
  un receptor lento le indique a un emisor rápido que se desacelere.
- **EDA (Arquitectura Dirigida por Eventos):** estilo donde los componentes
  se comunican mediante eventos, a menudo sobre colas o flujos.
- **CQRS (Segregación de Responsabilidad de Comandos y Consultas):**
  separación del modelo de lectura (consultas) del modelo de escritura
  (comandos).
- **Patrón Saga:** mencionado como mecanismo para reemplazar transacciones
  ACID tradicionales y lograr consistencia eventual entre microservicios
  (no desarrollado en profundidad en este documento).
- **Base-de-datos-por-servicio (Database per Service):** patrón de gestión
  de datos descentralizada donde cada microservicio posee su propia base de
  datos privada.
- **Persistencia Políglota / Desarrollo Políglota:** libertad de cada
  servicio para elegir su propia pila tecnológica (lenguaje, framework,
  base de datos).
- **API Gateway:** punto de entrada central que enruta el tráfico externo
  hacia los microservicios, gestionando seguridad y rate limiting.
- **Service Discovery:** mecanismo que permite a los servicios localizarse
  dinámicamente entre sí, con balanceo de carga.
- **Circuit Breaker:** patrón que previene que un servicio reintente
  repetidamente una operación que probablemente fallará.
- **Bulkheads (Mamparos):** aislamiento de recursos (ej. pools de hilos)
  entre servicios para contener fallos.
- **Degradación elegante (Graceful degradation):** capacidad de un sistema
  de ofrecer funcionalidad reducida en lugar de fallar por completo.
- **"You Build It, You Run It":** principio organizacional donde un equipo
  multifuncional posee el ciclo de vida completo (diseño, desarrollo,
  despliegue, operación) de uno o más servicios.
- **IaC (Infraestructura como Código):** gestión de infraestructura
  subyacente de manera consistente mediante código, usada en pipelines
  CI/CD de microservicios.
- **gRPC:** framework RPC de alto rendimiento usado para comunicación
  síncrona entre servicios, a menudo con Protocol Buffers.
- **Trazado distribuido (Distributed Tracing):** técnica de observabilidad
  para rastrear una petición a través de múltiples servicios (herramientas
  mencionadas: Jaeger, Zipkin).

## Notas y advertencias

- El diagrama "Key Components Supporting Microservices" contiene lo que
  parece un error tipográfico: escribe "KaGa" donde probablemente debería
  decir "Kafka" (aparece junto a RabbitMQ como ejemplo de sistema de
  mensajería). Se preserva tal como figura en la fuente.
- El patrón Saga se menciona dos veces (en Desafíos de MSA y en Gestión de
  Datos Descentralizada) pero el documento no desarrolla su mecánica interna
  (coreografía vs. orquestación, compensación de transacciones, etc.); queda
  como concepto mencionado sin desarrollo.
- CQRS se define brevemente en la recapitulación de Rendimiento de Sistemas
  II, pero no se profundiza más en la sección de MSA propiamente dicha más
  allá de una mención en Gestión de Datos Descentralizada.
- Los diagramas generados con la herramienta "Napkin" (marca de agua visible
  en varias láminas: Microservice Characteristics, Advantages of
  Microservices Architecture, Key Components Supporting Microservices,
  Scalability and Resource Optimization) están en inglés, a diferencia del
  resto del contenido textual del documento que está en español. Se
  tradujeron/contextualizaron sus contenidos en este resumen sin alterar su
  significado.
- El documento no profundiza en cómo se implementan técnicamente los
  patrones circuit breaker, bulkhead o Saga (por ejemplo, no menciona
  bibliotecas o frameworks específicos para su implementación, más allá de
  nombrar Docker, Kubernetes, Jaeger, Zipkin, RabbitMQ y Kafka como
  herramientas de soporte general).
- La sección "Desafíos de la Arquitectura de Microservicios" lista:
  Complejidad Aumentada (latencia de red, tolerancia a fallos, transacciones
  distribuidas, consistencia eventual), Gestión de Datos y Consistencia
  (transacciones ACID reemplazadas por consistencia eventual y patrón Saga),
  Congestión de Red y Latencia (comunicación por red más lenta que llamadas
  en proceso), DevOps y Sobrecarga Operacional (cultura DevOps madura
  necesaria, con Docker/Kubernetes/logging centralizado), Depuración y
  Monitoreo (trazado distribuido con Jaeger o Zipkin), Pruebas (pruebas de
  contrato y de integración necesarias). Estos desafíos se presentan como
  contrapeso explícito a los beneficios, reforzando el mensaje de las
  conclusiones de que MSA implica un trade-off estratégico.
- Las conclusiones del documento son explícitas en señalar que MSA "no es
  una solución mágica" y que "generalmente no se recomienda para equipos
  pequeños o aplicaciones simples que están comenzando, donde una
  arquitectura monolítica sería más simple y eficiente" — esta es una
  afirmación normativa del propio material, no una interpretación externa.
- El documento anuncia que esta es la primera de tres semanas dedicadas a
  microservicios (MSA I, II y III), por lo que temas como el patrón Saga,
  CQRS en profundidad, y otros patrones de descomposición/comunicación
  probablemente se desarrollen con más detalle en el material de semanas
  posteriores (we6, we7), fuera del alcance de este documento.
