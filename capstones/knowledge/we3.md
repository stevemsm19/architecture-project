# Semana 3: Rendimiento del Sistema I

## Resumen del contenido

El documento corresponde a la Semana 3 del curso Arquitectura de Software 3
(Jala University). Su objetivo declarado es "comprender los fundamentos del
rendimiento del sistema explorando cómo las arquitecturas modernas gestionan el
flujo de datos y la escalabilidad". La agenda cubre: un repaso de Integración
de Sistemas (contenido de la semana anterior), una visión general del
rendimiento del sistema como preocupación arquitectónica, una introducción a
brokers de mensajes y colas, una introducción a la arquitectura dirigida por
eventos (EDA) y una introducción a los procesadores de flujos (stream
processors). El hilo conductor del material es que el rendimiento y la
escalabilidad de un sistema dependen en gran medida de decisiones
arquitectónicas relacionadas con el desacoplamiento de componentes mediante
mensajería asíncrona, eventos y procesamiento continuo de datos.

## Conceptos clave

### Integración de Sistemas (repaso)

**Definición:** Proceso de conectar diferentes sub-sistemas, aplicaciones o
servicios en un solo sistema cohesivo y más grande que funciona como un todo
unificado.

**Explicación:** El objetivo principal es asegurar que componentes de TI
dispares, potencialmente de diferentes proveedores o construidos con
diferentes tecnologías, puedan operar juntos sin problemas para compartir
datos y procesos, mejorando la eficiencia empresarial, la consistencia de
datos y la visibilidad operacional general. El documento usa la analogía de
construir una red de carreteras (integraciones) entre ciudades aisladas
(sistemas) para que las personas y los bienes (datos) puedan fluir libremente,
haciendo que todo el país (organización) sea más productivo y conectado.

**Relaciones:**
- Es la base conceptual sobre la que se apoya el resto del material de la
  semana (mensajería, EDA, streaming son mecanismos de integración).

### Interoperabilidad

**Definición:** Capacidad fundamental de diferentes sistemas, aplicaciones o
componentes para comunicarse, intercambiar datos y usar la información que ha
sido intercambiada.

**Explicación:** Es el objetivo o resultado deseado que la integración de
sistemas pretende alcanzar.

### Sistemas Heredados (Legacy Systems)

**Definición:** Sistemas informáticos antiguos, a menudo obsoletos, con
lenguajes de programación o software de aplicación que aún están en uso.

**Características:**
- Típicamente críticos para las operaciones diarias.
- Difíciles de integrar con sistemas modernos debido a su antigüedad,
  naturaleza propietaria o falta de documentación y soporte.

### Métodos y tecnologías de Integración de Sistemas

- **API (Interfaz de Programación de Aplicaciones):** Conjunto de reglas y
  protocolos definidos que permiten a las aplicaciones comunicarse entre sí.
  Las APIs modernas son típicamente RESTful, usando peticiones HTTP (GET,
  POST, PUT, DELETE) para intercambiar datos en formato JSON o XML.
- **EDI (Intercambio Electrónico de Datos):** Formato estandarizado y
  estructurado para intercambiar documentos comerciales (ej. órdenes de
  compra, facturas, avisos de envío) entre organizaciones de forma
  electrónica. Reemplaza documentos en papel.
- **Webhooks:** Mecanismo dirigido por eventos donde un sistema envía datos en
  tiempo real a otro sistema cuando ocurre un evento específico. El sistema
  receptor proporciona una URL endpoint que el sistema emisor llama con los
  datos relevantes.
- **Sistemas de mensajería:** Método de comunicación asíncrona donde los
  sistemas intercambian mensajes vía una cola de mensajes intermediaria o un
  bus. El sistema emisor coloca un mensaje en una cola, y el sistema receptor
  lo recoge cuando está listo.

### Migración de Datos

**Definición:** Proceso de seleccionar, preparar, extraer, transformar y
transferir datos de un sistema de almacenamiento o formato a otro.

**Explicación:** Es un subconjunto crítico de los proyectos de integración,
especialmente al implementar nuevos sistemas (ej., moverse de un CRM antiguo a
uno nuevo).

**Proceso de Migración de Datos (alto nivel):**
1. Planificación y Análisis
2. Perfilado y Limpieza de Datos
3. Diseño y Mapeo
4. Pruebas
5. Ejecución (Migración)
6. Validación y Auditoría
7. Desmantelamiento (Opcional)

**Tipos de Migración de Datos:**
- Migración de Almacenamiento
- Migración de Base de Datos
- Migración de Aplicación
- Migración de Procesos de Negocio

### Rendimiento del Sistema (System Performance)

**Definición:** Medida de qué tan efectivamente un sistema informático
(hardware y software) logra su trabajo previsto. No es un número único sino un
conjunto de métricas.

**Explicación:** El documento organiza el rendimiento como respuestas a
preguntas críticas:

| Pregunta | Métrica asociada |
|---|---|
| ¿Qué tan rápido es? | Latencia, Tiempo de Respuesta |
| ¿Cuánto trabajo puede hacer? | Rendimiento (throughput), Ancho de Banda |
| ¿Qué tan eficientemente usa los recursos? | Utilización |
| ¿Está esperando por algo? | Saturación, Encolamiento |

**Por qué importa el rendimiento del sistema:**
- **Retención de Clientes:** Un simple retraso de 1 segundo en respuesta
  puede llevar a una caída del 7% en conversiones, impactando directamente la
  rentabilidad.
- **Experiencia del Usuario:** Los sistemas lentos causan hasta un 40% de
  abandono de usuarios, indicando un fallo crítico en cumplir expectativas y
  brindar satisfacción.
- **Crecimiento Empresarial:** El rendimiento sustenta directamente la
  satisfacción del usuario, generación de ingresos y lealtad de marca,
  convirtiéndose en piedra angular del éxito empresarial sostenible.

**Relaciones:**
- Se fundamenta en decisiones de arquitectura de software (ver siguiente
  concepto).

### Arquitectura de Software como base del rendimiento

**Explicación:** La arquitectura define la estructura del sistema, cómo
interactúan los componentes y el flujo de datos. Influye profundamente en
aspectos críticos como velocidad, escalabilidad, utilización de recursos y
mantenibilidad. Según Aberdeen Group (citado en el material), un fuerte
enfoque en arquitectura empresarial puede aumentar la productividad de
desarrollo en 30%.

**Nota destacada del material:** "Una buena arquitectura no se trata solo de
funcionalidad; se trata de construir un sistema que funcione eficientemente
bajo todas las condiciones."

### Dimensiones Arquitectónicas del Rendimiento

| Dimensión | Descripción | Consideraciones clave |
|---|---|---|
| Latencia | Tiempo tomado para responder a una solicitud | Saltos de red, serialización, acceso a BD |
| Rendimiento (throughput) | Número de operaciones completadas por unidad de tiempo | Paralelismo, agrupamiento, encolamiento |
| Escalabilidad | Capacidad de mantener rendimiento cuando aumenta la carga | Escalado horizontal vs. vertical, ausencia de estado |
| Eficiencia de Recursos | Uso óptimo de CPU, memoria, E/S y ancho de banda | Recolección de basura, caché, pooling |
| Concurrencia | Manejo de múltiples tareas simultáneamente | Modelos de hilos, patrones async, bloqueos |
| Resistencia | Mantener rendimiento bajo condiciones de falla | Interruptores de circuito, reintentos, rutas de respaldo |

### Rendimiento como Requisito No Funcional

**Definición/Explicación:** El material insiste en tratar el rendimiento como
una preocupación arquitectónica de primera clase, no como una solución
posterior al despliegue. Esto significa:
- Definir SLAs y SLOs temprano.
- Incluir el rendimiento en los registros de decisiones arquitectónicas
  (ADRs).
- Validar con pruebas de rendimiento (carga, estrés, remojo/soak).

### Desafíos y Compromisos (trade-offs) en la arquitectura de rendimiento

**Explicación:** El mayor desafío en la arquitectura de software no es
construir un sistema que funcione bien, sino construir uno que continúe
funcionando bien mientras evoluciona. El material propone "conocer tus
prioridades": ¿es tu sistema una plataforma de trading en tiempo real
(prioriza Latencia y Consistencia) o un feed de redes sociales (prioriza
Disponibilidad y Rendimiento)?

- **Acto de Equilibrio:** Encontrar un equilibrio delicado entre objetivos de
  rendimiento, mantenibilidad del sistema y medidas de seguridad robustas.
- **Costo y Riesgo:** Los cambios arquitectónicos pueden ser costosos e
  introducir riesgo significativo si no se planifican y ejecutan
  meticulosamente.
- **Evolución Continua:** Requiere un enfoque arquitectónico que fomente la
  agilidad y resistencia para adaptarse a demandas y tecnologías en
  evolución.

**Trade-offs específicos identificados (diagrama "Challenges and
Trade-offs"):**
- **Consistencia vs. Disponibilidad:** Asegurar la consistencia de datos
  puede reducir la disponibilidad del sistema, según el Teorema CAP.
- **Tiempo de Desarrollo vs. Rendimiento:** Un desarrollo más rápido puede
  comprometer el rendimiento, requiriendo trade-offs en elecciones
  tecnológicas.
- **Escalabilidad vs. Complejidad:** Diseñar para escalabilidad a menudo
  aumenta la complejidad del sistema, afectando la mantenibilidad.
- **Utilización de Recursos vs. Rendimiento:** Optimizar el uso de recursos
  mientras se mantiene el rendimiento implica algoritmos y estructuras de
  datos eficientes.
- **Latencia vs. Rendimiento (throughput):** Equilibrar baja latencia con alto
  rendimiento requiere asignación cuidadosa de recursos y estrategias de
  procesamiento.

## Enfoques, métodos o herramientas

### Técnicas de optimización de rendimiento del sistema (diagrama)

El documento presenta un diagrama circular con las siguientes técnicas:
- **Resource Allocation (Asignación de Recursos):** asegurar que los recursos
  se distribuyan apropiadamente entre procesos.
- **Code Optimization:** mejorar la eficiencia del código para reducir
  consumo de recursos.
- **Database Optimization:** mejorar el rendimiento de la base de datos
  mediante indexación y ajuste (tuning).
- **Network Optimization:** reducir latencia y mejorar el rendimiento en
  tráfico de red.
- **Operating System Tuning:** ajustar parámetros del SO para mejor
  rendimiento.
- **Virtualization Optimization:** mejorar el rendimiento de máquinas
  virtuales mediante asignación de recursos.
- **Load Balancing:** distribuir cargas de trabajo para prevenir sobrecarga.
- **Caching:** reducir latencia almacenando datos accedidos frecuentemente.
- **CDN Implementation:** distribuir contenido geográficamente para reducir
  latencia.
- **Regular Maintenance:** mantener el rendimiento del sistema mediante
  tareas rutinarias.

### Estrategias Arquitectónicas para el rendimiento

- **Optimización de Arquitectura por Capas:** minimizar llamadas entre capas;
  usar DTOs (Data Transfer Objects) para reducir el tamaño de la carga útil.
- **Patrones de Caché:** caché en memoria (ej. Redis) para rutas críticas;
  CDN para recursos estáticos.
- **Mensajería Asíncrona:** desacopla servicios para mejor escalabilidad;
  mejora la tolerancia a fallos y resistencia del sistema.
- **Diseño de Base de Datos:** indexación, particionamiento,
  desnormalización; pool de conexiones y optimización de consultas.
- **Distribución de Carga:** uso de balanceadores de carga y proxies
  inversos; geo-distribución para reducción de latencia.
- **Perfilado y Monitoreo:** herramientas APM (ej. New Relic, Datadog);
  métricas personalizadas y trazado (OpenTelemetry).

### Brokers de mensajes y colas de mensajes

**Definición (Cola de mensajes):** Buffer temporal que almacena mensajes
enviados por productores hasta que los consumidores estén listos para
recuperarlos.

**Características:**
- Típicamente opera sobre una base FIFO (Primero en Entrar, Primero en Salir),
  asegurando que los mensajes se procesen en orden (algunos brokers soportan
  colas de prioridad).
- Habilita comunicación asíncrona: el emisor y receptor no necesitan estar
  activos simultáneamente. Esto mejora la capacidad de respuesta y resistencia
  del sistema.

**Ejemplo del material:** Una cola RabbitMQ conteniendo miles de solicitudes
de pedidos entrantes, esperando pacientemente que un servicio de
procesamiento de pedidos disponible las recoja.

**Definición (Broker de Mensajes):** Software que implementa el sistema de
colas de mensajes; gestiona colas, temas, intercambios y reglas de
enrutamiento, asegurando entrega confiable de mensajes.

**Explicación:** Un broker de mensajes es un intermediario sofisticado que
hace más que solo almacenar mensajes; enruta, transforma y gestiona mensajes
entre productores y consumidores. Frecuentemente utiliza colas internamente
pero mejora la cola básica con características avanzadas como reglas de
enrutamiento flexibles, traducción de protocolos y enriquecimiento de
mensajes. Actúa como un sistema nervioso central para comunicación entre
aplicaciones, asegurando que los mensajes lleguen a sus destinos pretendidos
de manera confiable.

**Ejemplo del material:** Apache ActiveMQ o AWS SQS combinado con SNS para
mensajería de distribución múltiple, habilitando que un solo mensaje se
distribuya a muchos servicios suscriptores.

**Conceptos clave asociados a colas/brokers:**
- **Mensaje:** unidad fundamental de datos intercambiada entre aplicaciones;
  consiste en un encabezado (metadatos) y un cuerpo (datos reales).
- **Productor:** aplicación o servicio que crea y envía mensajes a la cola.
- **Consumidor:** aplicación o servicio que recibe y procesa mensajes de la
  cola.
- **Cola:** buffer que almacena mensajes hasta que son consumidos (FIFO,
  algunos brokers soportan prioridad).
- **Intercambio (Exchange):** (en algunos brokers como RabbitMQ) entidad que
  recibe mensajes de productores y los enruta a colas basándose en reglas
  predefinidas (vinculaciones).
- **Vinculación (Binding):** regla que define cómo los mensajes de un
  intercambio se enrutan a una cola específica.
- **Tema (Topic):** canal nombrado al cual los productores envían mensajes.
  Múltiples consumidores pueden suscribirse a un tema y recibir copias de
  todos los mensajes publicados en él; se usa frecuentemente para patrones
  publicar-suscribir (pub/sub).

### Concepto central: Desacoplamiento (mensajería)

**Explicación:** En su esencia, una cola de mensajes (MQ) o broker de
mensajes es un mecanismo de desacoplamiento. Se sitúa entre componentes
(servicios, aplicaciones) y les permite comunicarse de forma asíncrona
mediante el paso de mensajes, en lugar de llamarse directamente a través de
protocolos síncronos como HTTP/RPC.

- **Acoplamiento Síncrono (sin cola):** `Servicio A -> Llamada HTTP ->
  Servicio B`. Si B está lento o caído, A se bloquea o falla. A necesita
  conocer la ubicación de red de B. El escalado está vinculado.
- **Desacoplamiento Asíncrono (con cola):** `Servicio A -> [Mensaje] -> Cola
  -> Servicio B`. A puede publicar un mensaje y continuar su trabajo. B
  procesa el mensaje cuando está listo. Ningún servicio es consciente del
  estado o ubicación del otro.

**Nota del documento:** "Este simple cambio en el patrón de comunicación
tiene profundas consecuencias arquitectónicas."

### Por qué la mensajería importa en la arquitectura de software moderna

- **Sistemas Distribuidos y Microservicios:** requieren comunicación
  confiable y escalable para funcionar efectivamente entre servicios
  dispares.
- **Interacciones Asíncronas y Desacopladas:** la mensajería permite que los
  sistemas operen independientemente, mejorando significativamente la
  tolerancia a fallos y la escalabilidad general.
- **Middleware Fundamental:** los brokers de mensajes y las colas son
  componentes esenciales, sustentando el tejido de comunicación de estas
  arquitecturas complejas.

### Beneficios de los brokers de mensajes (diagrama)

- **Decoupling (Desacoplamiento):** productores y consumidores operan
  independientemente.
- **Asynchronous Communication:** mensajes se procesan sin esperar.
- **Scalability:** los sistemas pueden manejar demanda creciente.
- **Reliability:** los mensajes se entregan incluso con fallos.
- **Fault Tolerance:** los mensajes se procesan a pesar de fallos de
  consumidores.
- **Flexibility:** soporta varios patrones de mensajería.
- **Improved Performance:** la aplicación principal permanece responsiva.
- **Integration:** facilita la comunicación entre sistemas.

### Casos de uso comunes de mensajería

- **Procesamiento en Segundo Plano:** delegación de tareas de larga duración
  o intensivas en recursos a trabajadores en segundo plano (ej. procesar
  imágenes, enviar correos, generar reportes).
- **Arquitecturas Basadas en Eventos:** construir sistemas que reaccionen a
  eventos en tiempo real (ej. procesar acciones de usuario, monitorear
  rendimiento del sistema, detectar fraude).
- **Comunicación entre Microservicios:** permite comunicación débilmente
  acoplada entre microservicios, permitiendo desarrollo, despliegue y
  escalado independientes.
- **Streaming de Datos:** ingestar y procesar grandes volúmenes de datos de
  varias fuentes (ej. sensores, tráfico web, redes sociales).
- **Procesamiento de Órdenes:** gestionar órdenes en un sistema de comercio
  electrónico (recibir órdenes, procesar pagos, enviar productos).
- **Agregación de Logs:** recopilar logs de múltiples servidores y
  aplicaciones y centralizarlos para análisis.
- **Colas de Tareas:** distribuir tareas entre múltiples trabajadores para
  mejorar el rendimiento y la escalabilidad.

## Comparaciones

### Message Queue vs. Event Broker

| Aspecto | Message Queue | Event Broker |
|---|---|---|
| Modelo | Consumers pull messages, process and remove ("colocar en cola tu mensaje para ser procesado") | Events pushed to consumers ("difundir eventos a través de tu arquitectura") |
| Comportamiento | Los consumidores procesan y eliminan mensajes de la cola cuando terminan (un mensaje suele ir a un solo consumidor que lo consume) | El broker empuja el mismo evento a todos los consumidores; el broker puede almacenar eventos o descartarlos |

### Elegir una tecnología de mensajería (lista no exhaustiva)

| Característica | RabbitMQ (Broker Tradicional) | Apache Kafka (Log Distribuido) | AWS SQS (Servicio de Colas Simple) |
|---|---|---|---|
| Modelo Principal | Enrutamiento flexible (colas, exchanges) | Log persistente y ordenado (topics) | Cola Simple (SQS) |
| Retención de Mensajes | Hasta ser consumidos (confirmados) | Retención configurable (días/años) | Hasta 14 días |
| Protocolo | AMQP | TCP personalizado / HTTP | API HTTP (REST) |
| Rendimiento | Alto | Extremadamente Alto | Escalable, pero basado en API |
| Ordenamiento | Garantizado en una cola | Garantizado por partición | Estándar: No; FIFO: Sí |
| Mejor Para | Enrutamiento complejo, distribución de tareas | Streaming de eventos, alto rendimiento, reproducibilidad | Desacoplamiento simple y directo. Procesamiento masivo y simple en segundo plano |

### Arquitectura Lambda vs. Arquitectura Kappa

| Aspecto | Lambda | Kappa |
|---|---|---|
| Descripción | Combina una capa por lotes (batch, para precisión de datos históricos y reprocesamiento) y una capa de velocidad (para análisis en tiempo real) | Simplifica usando un único pipeline de flujo para el procesamiento en tiempo real y el reprocesamiento de datos históricos; todos los datos fluyen a través de una cola de mensajes |
| Ventajas | Alta precisión, robustez | Base de código más simple, menor latencia |
| Desventajas | Lógica duplicada, mayor complejidad (dos bases de código distintas) | Más exigente en infraestructura de flujo (requiere motores de flujo robustos) |

### Procesadores de Flujo vs. Bases de Datos de Flujo

| Aspecto | Procesadores de Flujo | Bases de Datos de Flujo |
|---|---|---|
| Enfoque | Cómputo y transformación de datos en movimiento; dependen de almacenamiento externo (colas para entrada, bases de datos para salida) y ofrecen APIs poderosas para procesamiento complejo de eventos | Integran capacidades de almacenamiento y consulta para análisis continuo tipo SQL sobre flujos de datos en vivo; mantienen vistas materializadas que se actualizan constantemente cuando llegan nuevos datos |
| Ejemplos | Apache Flink, Apache Spark Streaming | KSQL, Materialize, RisingWave |
| Mejor para | ETL complejo, análisis en tiempo real, aplicaciones dirigidas por eventos | Paneles en tiempo real, análisis operacional, consultas continuas |

## Procedimientos o procesos

### Proceso de Migración de Datos (alto nivel)

1. Planificación y Análisis
2. Perfilado y Limpieza de Datos
3. Diseño y Mapeo
4. Pruebas
5. Ejecución (Migración)
6. Validación y Auditoría
7. Desmantelamiento (Opcional)

### Rendimiento como requisito no funcional (pasos de tratamiento)

1. Definir SLAs y SLOs temprano.
2. Incluir el rendimiento en los registros de decisiones arquitectónicas
   (ADRs).
3. Validar con pruebas de rendimiento (carga, estrés, remojo/soak).

## Ejemplos y casos

### Cola RabbitMQ para pedidos entrantes

Una cola RabbitMQ conteniendo miles de solicitudes de pedidos entrantes,
esperando pacientemente que un servicio de procesamiento de pedidos disponible
las recoja. Ilustra el rol de la cola como buffer temporal.

### Broker con distribución múltiple

Apache ActiveMQ o AWS SQS combinado con SNS para mensajería de distribución
múltiple, habilitando que un solo mensaje se distribuya a muchos servicios
suscriptores. Ilustra la diferencia entre una cola simple y un broker
sofisticado.

### Casos de uso del mundo real de procesamiento de flujos

- **Detección de Fraude Financiero:** analizar cada transacción en
  milisegundos para identificar y bloquear actividades fraudulentas,
  protegiendo tanto a las instituciones financieras como a los clientes;
  requiere latencia ultra-baja y alta precisión.
- **Monitoreo de Sensores IoT:** gestionar el tamaño y la retención del
  estado para aplicaciones de streaming de larga duración; crucial para el
  rendimiento y la utilización de recursos, especialmente en agregaciones
  complejas.
- **Entrega de Contenido Personalizado:** adaptar recomendaciones de
  películas, feeds de noticias o sugerencias de comercio electrónico
  instantáneamente basándose en el comportamiento y preferencias del usuario;
  mejora la experiencia del usuario y el engagement.

## Información visual relevante

### Diagrama: Sistema de integración (icono decorativo)

Icono de un edificio institucional conectado jerárquicamente a tres nodos.
Ilustra de forma genérica el concepto de integración de sistemas como
conexión de componentes; no aporta información técnica adicional más allá de
la idea general.

### Diagrama: System Performance Optimization Techniques

Diagrama circular con un núcleo central rodeado de 10 técnicas de
optimización de rendimiento (Resource Allocation, Code Optimization, Database
Optimization, Network Optimization, Operating System Tuning, Virtualization
Optimization, Load Balancing, Caching, CDN Implementation, Regular
Maintenance), cada una con una breve descripción de su propósito. Ver
detalle en la sección "Enfoques, métodos o herramientas".

### Diagrama: Challenges and Trade-offs

Diagrama en forma de arco/rompecabezas con cinco trade-offs arquitectónicos
del rendimiento: Consistency vs. Availability (Teorema CAP), Development Time
vs. Performance, Scalability vs. Complexity, Resource Utilization vs.
Performance, Latency vs. Throughput. Detalle en la sección de "Desafíos y
Compromisos".

### Diagrama: flujo Producers -> Message Queue -> Consumer

Ilustra cómo múltiples productores envían mensajes a una cola de mensajes
(representada como una tubería/cinta transportadora) que los almacena de
forma ordenada hasta que un consumidor los retira. Refuerza el concepto FIFO
de la cola de mensajes. Fuente citada: hookdeck.com/blog/introduction-message-queue.

### Diagrama: arquitectura de un Broker de Mensajes

Muestra 3 productores (Producer 1, 2, 3) enviando mensajes a un broker que
contiene dos colas internas (Queue 1, Queue 2); el broker enruta los mensajes
a 3 consumidores (Consumer 1, 2, 3), incluyendo un mecanismo de confirmación
(ACK) desde Consumer 2. Ilustra el rol del broker como intermediario que
gestiona múltiples colas y el enrutamiento hacia consumidores específicos.
Fuente citada: blog.algomaster.io/p/message-queues.

### Diagrama: Message queues vs Event Brokers

Comparación visual: en "Message Queue", los consumidores extraen (pull) los
mensajes de una cola FIFO, los procesan y los eliminan de la cola (cada
mensaje va a un consumidor). En "Event Broker", el broker empuja (push) el
mismo evento a todos los consumidores suscritos, y puede almacenar o
descartar los eventos. Fuente citada:
eda-visuals.boyney.io/visuals/message-queue-vs-event-broker.

### Diagrama: patrones de intercambio de mensajes

Cuatro patrones ilustrados:
- **Request-Reply:** comunicación síncrona con respuesta inmediata (Client
  <-> Server).
- **Fire-and-Forget:** asíncrono, sin respuesta esperada ni garantizada
  (Sender -> Receiver).
- **Publish-Subscribe:** mensajería de uno a muchos vía temas/canales
  (Publisher -> Topic -> Sub1, Sub2).
- **Message Queue:** buffering FIFO con balanceo de carga (Producer -> Queue
  -> Consumer).

### Diagrama: patrones de enrutamiento y procesamiento de mensajes

- **Content-Based Router:** enruta mensajes según su contenido o propiedades
  (ej. tipo Order va a Route A, tipo Payment va a Route B).
- **Message Filter:** procesa selectivamente mensajes según criterios,
  descartando los que no cumplen (Rejected).
- **Scatter-Gather:** difunde una solicitud a múltiples servicios y agrega
  las respuestas.
- **Message Translator:** convierte formatos de mensaje entre distintos
  sistemas (ej. XML a JSON).
- **Splitter:** divide un mensaje por lotes (Batch Msg) en ítems individuales.

### Diagrama: patrones arquitectónicos basados en mensajería/eventos

- **Event Sourcing:** almacena todos los cambios como eventos inmutables
  (Event Store: E1 → E2 → E3 → E4 → ...); el estado actual puede
  reconstruirse a partir del historial de eventos.
- **CQRS (Command Query Responsibility Segregation):** separa las operaciones
  de lectura y escritura (Command Bus -> Write Model; Query Bus -> Read
  Model), optimizando cada una para su patrón de acceso.
- **Saga Pattern:** gestiona transacciones distribuidas mediante acciones
  compensatorias en caso de fallo; se ilustran el "Happy Path" (éxito de
  pasos secuenciales) y el "Failure Path (Rollback)" con acciones
  compensatorias (Comp 1, Comp 2).
- **Message-Driven Architecture:** acoplamiento débil a través de mensajería
  asíncrona (Service A -> Message Broker -> Service B, C, D).
- **Event-Driven Architecture:** sistema reactivo que responde a eventos de
  dominio (Event Producer -> Event Bus -> Handler 1, 2, 3).

### Diagrama: patrones de confiabilidad (reliability patterns)

- **Dead Letter Queue:** almacena mensajes que fallaron en su procesamiento
  para análisis posterior (Main Queue -> Consumer; en caso de fallo, el
  mensaje va a Dead Letter Queue).
- **Circuit Breaker:** previene fallos en cascada deteniendo las llamadas a
  servicios que están fallando (estado OPEN detiene las llamadas de Client a
  Service).
- **Idempotent Consumer:** asegura que mensajes duplicados produzcan el mismo
  resultado (verificación de ID de mensaje antes de procesar/almacenar).
- **Transactional Outbox:** asegura la publicación confiable de mensajes
  junto con transacciones de base de datos (el Service escribe en una tabla
  "Outbox" dentro de la misma transacción de negocio antes de publicar al
  Message Bus).
- **Retry Pattern:** reintentos con espera (delay) tras fallos, hasta lograr
  éxito (Client <-> Service, Attempt 1 -> Failure -> Retry (delay) ->
  Success).

### Diagrama: flujo interno de un sistema EDA (Sources -> Broker -> Sinks)

Ilustra: múltiples fuentes (Sources) generan datos de evento que pasan por un
"Event Data Publisher", llegan a un "Event Data Store" (almacenamiento
central de eventos), y de ahí a un "Event Data Subscriber" (y también un
componente "Subscriber and Publisher" que retroalimenta al Event Data Store).
Desde el subscriber, los datos llegan a distintos "Sinks": Database, File
System, Apps, entre otros. Fuente citada:
hazelcast.com/foundations/event-driven-architecture/event-driven-architecture/.

### Diagrama: Componentes clave de un sistema EDA (Producers -> Channels/Broker -> Consumers)

Muestra Producers (servidores) enviando eventos a través de "Channels" hacia
un "Broker" (representado con procesadores), que a su vez distribuye los
eventos a "Consumers" (representados como dispositivos: monitor, laptop,
móvil).

### Diagrama: Challenges in Event-Driven Architecture

Diagrama circular con seis desafíos: Ordering (garantizar el orden de eventos
es complejo en sistemas distribuidos), Complexity (diseñar e implementar
sistemas EDA puede ser intrincado), Eventual Consistency (la consistencia de
datos puede retrasarse debido a la comunicación asíncrona), Monitoring and
Debugging (la naturaleza distribuida dificulta el monitoreo y la depuración),
Event Schema Management (asegurar compatibilidad entre productores y
consumidores es crucial), Idempotency (los consumidores deben manejar eventos
duplicados sin efectos no deseados).

### Diagrama: "Inside event-driven architectures" (patrones internos de EDA)

Presenta seis patrones con boceto tipo dibujo a mano:
- **Process Manager (el "orchestrator"):** unidad central que orquesta la
  interacción entre otros servicios; procesa un flujo de trabajo como una
  sola unidad.
- **Event sourcing:** almacena eventos y los consume para reconstruir el
  estado actual, construyendo el estado a partir de los eventos.
- **Event streaming:** flujo de eventos usado normalmente para procesamiento
  en tiempo real (eventos nuevos y antiguos fluyen en una secuencia
  continua).
- **Point-to-point messaging (pull):** los mensajes se colocan en una cola
  por el emisor; el receptor los consume de la cola con confirmación (ack).
- **Change data capture:** escucha eventos de cambios en los datos de una
  base de datos y los consume directamente desde ella.
- **Pub/Sub (push):** el mismo mensaje/evento se entrega a múltiples
  consumidores/suscriptores; cada suscriptor obtiene una copia del evento
  para procesar. Fuente citada:
  eda-visuals.boyney.io/visuals/inside-event-driven-architectures.

### Diagrama: Stream Processing Engine (Input Data -> Engine -> Outputs)

Muestra datos de entrada (Input Data) fluyendo hacia un "Stream Processing
Engine" que los procesa, generando dos tipos de salida: "Output Stream" y
"Analytics". Fuente citada:
hazelcast.com/foundations/event-driven-architecture/stream-processing/.

### Diagrama: comparación visual Lambda vs. Kappa

- **Lambda:** el flujo de datos (Data stream) se bifurca en un "Batch mode" y
  un "Real-time mode", ambos convergiendo en un "Access mode" común.
- **Kappa:** el flujo de datos pasa primero por una "Data queue", luego por
  un único "Real-time mode", y finalmente hacia el "Access mode". Fuente
  citada: researchgate.net/figure/Comparison-of-Lambda-and-Kappa-architectures_fig1_341479006.

### Imágenes decorativas sin información técnica

Se identificaron imágenes puramente decorativas/ilustrativas (portada con
edificio moderno, dashboard financiero borroso con gráficos abstractos,
imagen de "pasillo de datos" con luces de neón) que acompañan encabezados de
sección pero no aportan contenido técnico verificable más allá de la
ambientación visual; se excluyen del contenido sustantivo por no comunicar
conocimiento específico.

## Terminología importante

- **Rendimiento del Sistema:** medida de qué tan efectivamente un sistema
  informático logra su trabajo previsto, expresada como conjunto de métricas
  (latencia, throughput, utilización, saturación).
- **Latencia:** tiempo tomado para responder a una solicitud.
- **Rendimiento/Throughput:** número de operaciones completadas por unidad de
  tiempo.
- **Escalabilidad:** capacidad de mantener el rendimiento cuando aumenta la
  carga.
- **Resistencia (Resilience):** capacidad de mantener rendimiento bajo
  condiciones de falla.
- **Mensaje:** unidad fundamental de datos intercambiada entre aplicaciones
  (encabezado + cuerpo).
- **Cola de mensajes:** buffer que almacena mensajes hasta que son
  consumidos, típicamente FIFO.
- **Broker de mensajes:** software intermediario que gestiona colas, temas,
  intercambios y reglas de enrutamiento, asegurando entrega confiable.
- **Productor / Consumidor:** aplicaciones que envían / reciben mensajes de
  una cola.
- **Intercambio (Exchange) / Vinculación (Binding):** conceptos de RabbitMQ
  para enrutar mensajes de productores a colas específicas mediante reglas.
- **Tema (Topic):** canal nombrado usado en patrones publicar-suscribir.
- **EDA (Arquitectura Dirigida por Eventos):** paradigma donde los
  componentes se comunican produciendo y reaccionando a eventos en lugar de
  llamadas directas.
- **Evento:** registro de algo que ya ha ocurrido (ej. `PedidoRealizado`,
  `UsuarioRegistrado`).
- **Modelo publicar/observar (publish/observe):** modelo de comunicación de
  EDA, en contraste con el modelo tradicional solicitud/respuesta.
- **Entrega "a lo más una vez" (at-most-once):** el mensaje puede perderse
  (ej. disparar y olvidar).
- **Entrega "al menos una vez" (at-least-once):** el mensaje no se pierde
  pero puede duplicarse; requiere consumidores idempotentes.
- **Entrega "exactamente una vez" (exactly-once):** muy difícil de lograr; a
  menudo simulada usando "al menos una vez" + idempotencia.
- **Idempotencia:** propiedad de un consumidor que permite procesar el mismo
  mensaje dos veces sin efectos negativos.
- **Procesamiento de flujos (Stream Processing):** paradigma de computación
  centrado en procesar datos continuamente a medida que llegan, en lugar de
  en lotes.
- **Tiempo de Evento vs. Tiempo de Procesamiento:** distinción entre cuándo
  ocurrió un evento y cuándo se procesa.
- **Ventanas de Tiempo (Time Windows):** agrupación de eventos sobre marcos
  temporales específicos (volcado/tumbling, salto/hopping, deslizante/sliding).
- **Computaciones con Estado (Stateful computations):** mantener y actualizar
  el estado a través de múltiples eventos para lógica compleja.
- **Checkpointing:** guardar regularmente el estado del motor de
  procesamiento en almacenamiento persistente para permitir recuperación tras
  fallas.
- **Arquitectura Lambda:** combina una capa por lotes y una capa de velocidad
  para análisis integral, con mayor complejidad de mantenimiento.
- **Arquitectura Kappa:** simplifica usando un único pipeline de flujo para
  tiempo real y reprocesamiento histórico.
- **SPOF (Single Point of Failure / Punto Único de Fallo):** riesgo de que un
  clúster de brokers mal configurado o mantenido se convierta en un único
  punto de fallo, pese a estar diseñado para alta disponibilidad.
- **DTO (Data Transfer Object):** objeto usado para reducir el tamaño de la
  carga útil en llamadas entre capas de la arquitectura.
- **APM (Application Performance Monitoring):** herramientas de perfilado y
  monitoreo (ej. New Relic, Datadog).
- **SLA / SLO:** acuerdos y objetivos de nivel de servicio que deben
  definirse tempranamente al tratar el rendimiento como requisito no
  funcional.

## Notas y advertencias

- El material presenta el rendimiento del sistema como un conjunto de
  métricas (no un número único), organizado explícitamente en cuatro
  preguntas (velocidad, capacidad de trabajo, eficiencia de recursos,
  espera/saturación); esta tabla es la base conceptual de todo el resto del
  documento.
- Las cifras citadas ("un retraso de 1 segundo puede llevar a una caída del
  7% en conversiones", "los sistemas lentos causan hasta un 40% de abandono
  de usuarios", "un fuerte enfoque en arquitectura empresarial puede aumentar
  la productividad de desarrollo en 30%", citando a Aberdeen Group) se
  presentan sin mayor desarrollo metodológico ni fuente primaria verificable
  en la diapositiva; se conservan tal como aparecen en el material, sin poder
  validar su origen exacto.
- El diagrama "Message queues vs Event Brokers" (con el atributo visual
  @boyney123) y el diagrama "Inside event-driven architectures" (mismo
  origen, eda-visuals.boyney.io) presentan un estilo de boceto a mano; su
  contenido fue interpretado con confianza razonable dado el texto
  acompañante, pero los detalles menores de las ilustraciones no son
  perfectamente nítidos en todos los casos.
- El título de una diapositiva contiene un error tipográfico evidente:
  "Pregfintate siempre" (probablemente "Pregúntate siempre"); se documenta
  aquí como hallado en el material, sin corregirlo en la fuente.
- El documento no profundiza en el "modelo de programación unificado" de
  Apache Beam más allá de mencionarlo como herramienta para elegir un
  procesador de flujo; no se explican sus conceptos internos (PCollection,
  PTransform, etc.), quedando como término mencionado sin desarrollo.
  Igualmente, KSQL, Materialize y RisingWave se mencionan solo como ejemplos
  de "Bases de Datos de Flujo" sin mayor detalle técnico.
- Los tres pilares de "Diseñando para Escalabilidad y Tolerancia a Fallos"
  (Escalado Horizontal, Semánticas Exactamente Una Vez, Checkpointing y
  Recuperación) se presentan como una lista de buenas prácticas del
  procesamiento de flujos, sin ejemplos de implementación concretos.
- El material concluye dos veces con secciones tituladas "Conclusión" (una
  para brokers de mensajes/colas, otra para EDA, y otra para procesadores de
  flujos), cada una reforzando que estas tecnologías no son "todo o nada"
  sino decisiones estratégicas que deben sopesar beneficios (desacoplamiento,
  escalabilidad, resistencia) contra costos (complejidad operacional,
  consistencia eventual).
- El material advierte explícitamente contra el uso indiscriminado de estas
  tecnologías: no usar EDA para aplicaciones CRUD simples, no adoptar
  procesadores de streams "porque estén de moda", y cuestionar si "los
  beneficios del desacoplamiento y procesamiento asíncrono superan la
  complejidad de introducir un nuevo sistema con estado" antes de adoptar un
  broker de mensajes.