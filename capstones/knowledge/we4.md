# Semana 4: Rendimiento del Sistema II

## Resumen del contenido

El documento corresponde a la Semana 4 del curso Arquitectura de Software 3
(Jala University), cuyo objetivo declarado es "analizar y diseñar sistemas
distribuidos que puedan manejar elegantemente las limitaciones de recursos y
operaciones a largo plazo". Es la continuación directa de la Semana 3
("Rendimiento del Sistema I"), de la cual se incluye una recapitulación. El
contenido central se organiza en tres bloques:

1. **Procesos de Larga Duración (PLD)**: operaciones asíncronas que exceden el
   ciclo típico de solicitud/respuesta, y los patrones arquitectónicos para
   modelarlas y hacerlas confiables.
2. **Contrapresión (Backpressure) y rendimiento**: el fenómeno por el cual
   componentes downstream sobrecargados fuerzan a los componentes upstream a
   ralentizarse, y por qué es crítico gestionarlo para la estabilidad del
   sistema.
3. **Enfoques para manejar la contrapresión**: un recorrido por los mecanismos
   concretos (colas/brokers, procesadores de flujos, EDA, CQRS, procesadores de
   trabajos) y cómo cada uno implementa contrapresión.

El documento cierra con una conclusión que propone combinar todos estos
enfoques en un sistema distribuido moderno y resume la filosofía de diseño:
diseñar para la contrapresión desde el inicio y detectarla tempranamente.

## Conceptos clave

### Rendimiento del sistema (recapitulación de Semana 3)

**Definición:** Qué tan eficientemente los sistemas de software utilizan los
recursos (CPU, memoria, disco, red) para cumplir con los requisitos del
usuario y del negocio, expresados en atributos como rendimiento, latencia,
escalabilidad y confiabilidad.

**Características:**
- Conceptos clave asociados: rendimiento, latencia, escalabilidad,
  disponibilidad, confiabilidad, cuellos de botella (CPU, E/S, BD, red).
- Áreas de optimización: nivel de hardware (configuración de CPU, memoria,
  almacenamiento), nivel de aplicación (código, caché, concurrencia), nivel
  arquitectónico (balanceo de carga, replicación, comunicación asíncrona).
- Herramientas y métricas: perfiladores, herramientas de monitoreo, métricas.

**Relaciones:** Sirve de base conceptual para todo el resto del documento;
brokers de mensajes, EDA y procesadores de flujos (recapitulados aquí) se
retoman en detalle como mecanismos de contrapresión más adelante.

### Broker de mensajes y colas (recapitulación)

**Definición:** Sistema intermediario que implementa patrones de mensajería
asíncrona; su abstracción principal es una cola o un tema.

**Características:**
- **Beneficios:** reducción del acoplamiento entre servicios, tolerancia a
  fallos y mecanismos de reintento, suavizado de carga, habilita procesamiento
  asíncrono y distribuido.
- **Brokers comunes:** RabbitMQ, Kafka, ActiveMQ, SQS, NATS.
- **Tipos de cola:**
  - Punto a punto (cola): un consumidor por mensaje.
  - Publicar/suscribir (tema): múltiples suscriptores reciben copias de un
    mensaje.

### Arquitectura Dirigida por Eventos (EDA) (recapitulación y ampliación)

**Definición:** Patrón arquitectónico donde los eventos (cambios de estado)
desencadenan reacciones por otros componentes de forma asíncrona.

**Explicación:** Los componentes (servicios) se comunican asincrónicamente
emitiendo y consumiendo eventos. Un evento notifica que "algo sucedió", y los
servicios interesados reaccionan sin dependencias directas entre sí, lo que
crea límites naturales de contrapresión.

**Características:**
- Componentes clave: productores de eventos, canal de eventos (broker),
  consumidores de eventos.
- Beneficios: bajo acoplamiento y alta escalabilidad, ajuste natural para
  microservicios, habilita procesamiento de datos en tiempo real.
- Desafíos: orden de eventos e idempotencia, evolución del esquema de
  eventos, complejidad en depuración y rastreo.
- A menudo usa colas y procesadores de flujos como columna vertebral de
  implementación.

**Tácticas de contrapresión en EDA:**
- Limitación de tasa: limitar tasas de eventos entrantes para evitar
  abrumar a los suscriptores.
- Descarte de carga: rechazar elegantemente eventos de baja prioridad
  cuando el sistema alcanza su capacidad.
- Interruptores de circuito (circuit breakers): detener el envío de
  eventos a servicios fallidos, reduciendo fallos en cascada.
- Colas de cartas muertas (dead letter queues): capturar eventos no
  procesables para análisis posterior y reintento.

**Mecanismo de contrapresión detallado:**
- En el enrutador/broker de eventos: la cola de mensajes o procesador de
  flujos (RabbitMQ, Kafka) que actúa como bus de eventos maneja la
  contrapresión con los métodos generales descritos (buffering, límites de
  cola, etc.).
- En el procesador de eventos (servicio): el servicio debe diseñarse para
  manejar contrapresión de sus propias dependencias (ej. una base de datos),
  usando: interruptores de circuito (para detener solicitudes a un servicio
  fallido o lento aguas abajo), mamparas (bulkheads, para aislar fallos y
  grupos de recursos, previniendo que una operación lenta consuma todos los
  hilos), y código no-bloqueante/reactivo (frameworks como Project Reactor /
  Spring WebFlux o RxJava, para evitar bloquear hilos mientras se espera E/S).

**Pros:** sistemas altamente desacoplados, escalables y resistentes.

**Contras:** mayor complejidad en rastreo, depuración y aseguramiento de
consistencia eventual.

**Ejemplo mencionado:** Camunda Zeebe demuestra "contrapresión adaptativa"
rechazando solicitudes excesivas para mantener la latencia consistentemente
baja.

### Procesador de flujos (Stream processor) (recapitulación y ampliación)

**Definición:** Sistema diseñado para manejar flujos continuos e ilimitados de
datos. A diferencia de un broker de mensajes que a menudo maneja mensajes
individuales, los procesadores de flujos trabajan con datos en movimiento,
realizando operaciones en tiempo real.

**Explicación (cómo funcionan):** Los datos se organizan en temas (Kafka) o
flujos. Los consumidores se suscriben a estos temas y procesan registros en
tiempo real. El procesamiento a menudo involucra operaciones con estado
(por ejemplo, agregados por ventanas).

**Características:**
- Casos de uso: analítica en tiempo real, pipelines ETL en datos en vivo,
  correlación y enriquecimiento de eventos.
- Conceptos centrales: ventanas, procesamiento con estado, semántica de
  "exactamente una vez".
- Procesadores de flujos comunes: Apache Flink, Apache Kafka Streams, Apache
  Samza, AWS Kinesis Data Analytics.

**Mecanismos de contrapresión:**
- **Modelo de extracción con buffer (enfoque de Kafka):** los consumidores
  extraen datos del broker; la posición del consumidor (offset) en el log es
  su propia responsabilidad. Si un consumidor se retrasa, simplemente lee
  desde un offset anterior. La contrapresión se aplica al grupo de
  consumidores, no al productor: el productor puede seguir escribiendo a
  alta velocidad. El problema es que un consumidor lento puede quedar con
  gran retraso acumulado; la solución es escalar el grupo de consumidores o
  aumentar las particiones del tema, permitiendo que más consumidores
  trabajen en paralelo.
- **Limitación de tasa dinámica (enfoque de Flink):** mecanismo de
  contrapresión basado en créditos más sofisticado. Cada administrador de
  tareas monitorea sus buffers de entrada; cuando comienzan a llenarse,
  señala contrapresión hacia arriba a las tareas productoras para que
  reduzcan la velocidad. Esto crea una señal de contrapresión que se
  propaga hasta la fuente, regulando la tasa de ingesta de toda la tubería
  de datos.

**Pros:** manejan alto rendimiento y datos en tiempo real; replicación y
durabilidad integradas (Kafka); gestión de estado sofisticada.

**Contras:** complejidad operacional; entender el particionado y el retraso
del consumidor es crítico.

**Modelo basado en extracción / control de flujo reactivo (concepto general):**
- Los consumidores solicitan datos cuando están listos, previniendo el
  desbordamiento del buffer.
- Los flujos reactivos manejan la pausa y reanudación automáticamente
  (contrapresión integrada).
- Ejemplo de tiempo real: la API de Web Streams controla el flujo de
  WebSocket pausando y reanudando las lecturas.

## Procesos de larga duración (PLD)

### Concepto y comprensión

**Definición:** Operaciones o tareas asíncronas que toman una cantidad
significativa de tiempo para completarse, a menudo excediendo el ciclo típico
de solicitud-respuesta de una aplicación web o API. A diferencia de las
transacciones de corta duración (segundos o milisegundos), estos procesos
pueden ejecutarse durante minutos, horas, días, o incluso más tiempo.

**Explicación:** El pensamiento más fundamental que requieren los PLD es un
cambio de paradigma. La arquitectura web tradicional está construida
alrededor de ciclos síncronos de solicitud/respuesta de corta duración (un
usuario hace clic, el servidor procesa, devuelve un resultado). Los PLD
obligan a pensar en términos de "jornadas con estado" (stateful journeys) que
pueden durar segundos, horas o días. Un PLD no es solo una llamada API
"lenta"; es una unidad cohesiva de trabajo que progresa a través de múltiples
estados, puede involucrar múltiples servicios, y debe sobrevivir reinicios
del sistema.

**Características (según diagrama "Long-Running Process Characteristics"):**
- **Duration (Duración):** el tiempo de ejecución extendido es la
  característica definitoria.
- **Potential for Failure (Potencial de fallo):** mayor probabilidad de
  fallos debido a diversos problemas.
- **Asynchronous Nature (Naturaleza asíncrona):** se ejecutan
  asincrónicamente para evitar bloquear el hilo principal.
- **Observability (Observabilidad):** el monitoreo y el logging son
  esenciales para rastrear el progreso.
- **Resource Consumption (Consumo de recursos):** uso significativo de
  CPU, memoria y ancho de banda de red.
- **State Management (Gestión de estado):** crucial para reanudar la
  ejecución tras interrupciones.
- **Idempotency (Idempotencia):** múltiples ejecuciones deben tener el
  mismo efecto que una sola.

### Por qué importa el rendimiento del sistema (contexto de negocio)

- **Retención de clientes:** un retraso de 1 segundo en la respuesta puede
  llevar a una caída del 7% en las conversiones, impactando directamente los
  ingresos.
- **Experiencia del usuario:** los sistemas lentos causan hasta 40% de
  abandono de usuarios, indicando una falla crítica en cumplir expectativas.
- **Crecimiento del negocio:** el rendimiento sustenta directamente la
  satisfacción del usuario, la generación de ingresos y la lealtad de marca,
  convirtiéndose en piedra angular del éxito empresarial sostenible.

### Desafíos de los procesos de larga duración

- **Confiabilidad:** asegurar que los procesos se completen exitosamente a
  pesar de posibles fallas.
- **Escalabilidad:** manejar un gran número de procesos concurrentes de
  larga duración.
- **Tolerancia a fallos:** recuperarse de fallas sin perder datos ni
  interrumpir el sistema general.
- **Monitoreo y observabilidad:** rastrear el progreso y salud de los
  procesos e identificar posibles problemas.
- **Gestión de recursos:** asignar y gestionar recursos de manera eficiente
  para evitar cuellos de botella.
- **Complejidad:** gestionar la complejidad de flujos de trabajo de larga
  duración y sus dependencias.
- **Idempotencia:** diseñar procesos que puedan reintentarse de forma segura
  sin efectos secundarios no deseados.
- **Coordinación:** coordinar múltiples procesos de larga duración que
  dependen unos de otros.

## Enfoques, métodos o herramientas

### Patrones arquitectónicos para PLDs

El documento enumera cuatro patrones arquitectónicos principales para
implementar procesos de larga duración:
- Motores de flujo de trabajo (orquestación).
- Patrón Saga (coreografía).
- Máquinas de estado.
- Procesamiento por lotes.

### Motores de flujo de trabajo (orquestación)

**Concepto:** Un "orquestador" central (el motor de flujo de trabajo) define
y controla los pasos del proceso. Llama a varios servicios y decide qué hacer
a continuación basándose en los resultados.

**Ejemplos:** Temporal, AWS Step Functions, Azure Durable Functions, Camunda.

**Impacto arquitectural:** Promueve una clara separación de
responsabilidades. La lógica de negocio del flujo se separa de la lógica de
negocio de las tareas individuales. Esto hace que los procesos complejos sean
explícitos, comprobables y, crucialmente, recuperables.

### Patrón Saga (coreografía)

**Concepto:** En un sistema distribuido, el proceso se extiende a través de
múltiples servicios. Cada servicio reacciona a eventos y emite sus propios
eventos, coreografiando el proceso general. Para manejar fallos, cada
servicio participante tiene una acción compensatoria (una reversión de
transacción).

**Ejemplos:** Patrón común en arquitecturas dirigidas por eventos usando
brokers de mensajes (Kafka, RabbitMQ).

**Impacto arquitectural:** Desacopla los servicios pero hace que el flujo
general del proceso sea más difícil de visualizar y depurar. Se intercambia
el control central por descentralización y acoplamiento débil.

### Máquinas de estado

**Concepto:** El proceso se modela como una máquina de estados finita. El
PLD es una entidad que se mueve de un estado bien definido a otro en
respuesta a eventos.

**Impacto arquitectural:** Proporciona un modelo robusto para procesos de
negocio complejos con guardias y transiciones claras. Es frecuentemente la
base conceptual dentro de los motores de flujo de trabajo y las sagas.

### Procesamiento por lotes

**Concepto:** Las solicitudes de procesamiento asíncrono se aceptan en todo
momento y se almacenan hasta que las condiciones sean óptimas para su
procesamiento. Basándose en el número de solicitudes almacenadas,
condiciones ambientales y reglas personalizadas, se instancian componentes
para manejar las solicitudes. Las solicitudes solo se procesan bajo
condiciones no óptimas si no pueden retrasarse más.

**Impacto arquitectural:** El sistema se optimiza para el rendimiento
(throughput) en lugar de la latencia, reduciendo la sobrecarga por registro.
Esto introduce picos en el uso de recursos (CPU, memoria, E/S) durante las
ventanas de lotes, potencialmente requiriendo programación de carga o
throttling de recursos.

### Colas de mensajes y brokers (como mecanismo de contrapresión)

**Cómo funcionan:** Los productores envían mensajes a una cola. Los
consumidores extraen mensajes de la cola a su propio ritmo. La cola desacopla
las tasas de procesamiento del productor y consumidor.

**Mecanismo de contrapresión:**
- **Contrapresión implícita vía límites de cola:** la mayoría de colas
  tienen un tamaño máximo (ej. RabbitMQ puede establecer una longitud
  máxima). Cuando la cola está llena, el broker puede dejar de aceptar
  nuevos mensajes, efectivamente empujando de vuelta a los productores.
- **Reconocimiento explícito (ack/nack):** los consumidores solo remueven
  un mensaje de la cola después de procesarlo exitosamente y enviar un
  reconocimiento (ack). Si un consumidor falla o es muy lento, el mensaje
  permanece en la cola o se re-entrega a otro consumidor, previniendo
  pérdida de datos.
- **Límite de prefetch:** configuración crucial que limita el número de
  mensajes no reconocidos que un consumidor puede tener a la vez. Un bajo
  conteo de prefetch (ej. 1) crea un modelo "basado en pull", donde el
  consumidor explícitamente pide el siguiente mensaje solo cuando está
  listo, aplicando contrapresión directa.

**Ventajas:** excelente para desacoplar, proporciona persistencia, permite
escalado fácil de consumidores.

**Desventajas:** agrega complejidad (necesidad de gestionar un broker), puede
convertirse en un punto único de falla (aunque existen brokers
clusterizados), puede agregar latencia.

**Ejemplo del mundo real:** Kafka usa monitoreo de profundidad de cola para
escalar automáticamente instancias de consumidores. Cuando se acumula
retraso en la cola, se activan consumidores adicionales para procesar
eventos más rápido, logrando throughput suave y controlado incluso durante
picos.

**Táctica clave:** monitorear continuamente la profundidad de cola. Cuando
la profundidad aumenta, activar autoescalado o descarte de carga antes del
colapso.

### CQRS (Command Query Responsibility Segregation)

**Definición:** La Segregación de Responsabilidades entre Comandos y
Consultas separa las operaciones de escritura (comandos) de las operaciones
de lectura (consultas), habilitando estrategias de escalamiento
independientes y manejo de contrapresión personalizado para cada carga de
trabajo.

**Cómo funciona:** Los comandos (intención de cambiar estado) se envían a un
lado de comandos, que actualiza la base de datos de escritura. Las consultas
(solicitudes de datos) son manejadas por un lado de lectura separado, que lee
desde un almacén de datos optimizado para lectura (modelo de lectura).

**Beneficio:** CQRS combinado con event sourcing soporta consistencia
eventual y control de flujo suave a través de cargas de trabajo
heterogéneas.

**Comandos (Escrituras):**
- Manejan operaciones de inserción, actualización y eliminación.
- Pueden ser más lentos, requieren consistencia.
- Pueden ser encolados y procesados asincrónicamente.

**Consultas (Lecturas):**
- Recuperan datos para lecturas rápidas y escalables.
- Pueden ser fuertemente cacheados o replicados.
- Escalamiento independiente de las rutas de escritura.

**Mecanismo de contrapresión:**
- **Separación de responsabilidades:** un aumento repentino en el tráfico
  de lecturas (consultas) no impacta la capacidad del sistema de procesar
  escrituras (comandos), y viceversa. Es una forma de aislamiento
  arquitectónico de contrapresión.
- **El problema de proyección asíncrona:** a menudo, el modelo de lectura se
  actualiza asincrónicamente desde el modelo de escritura (vía eventos). Si
  el actualizador del modelo de lectura (el proyector) no puede seguir el
  ritmo del flujo de eventos, experimenta contrapresión.
  - **Solución:** el almacén de eventos subyacente (un procesador de flujo o
    cola) permite que el proyector se quede atrás y procese eventos a su
    propio ritmo, dependiendo de la durabilidad del flujo de eventos. Se
    pueden escalar los proyectores horizontalmente para ponerse al día.

**Pros:** escalamiento independiente de lecturas y escrituras; permite
modelos de datos optimizados.

**Contras:** alta complejidad; consistencia eventual; requiere un sistema de
eventos robusto.

**Ejemplo — Desacoplando cargas de trabajo de lectura y escritura:**
- *Escenario:* un sistema con tráfico pesado de escrituras (ej. dispositivos
  IoT enviando telemetría) y consultas ocasionales pero complejas (ej.
  paneles de análisis).
- *Sin CQRS:* tanto las lecturas como las escrituras impactan la misma base
  de datos, generando contención, mayor latencia y eventualmente
  contrapresión en las escrituras entrantes cuando la BD se sobrecarga.
- *Con CQRS:* los comandos (escrituras) van a un modelo optimizado para
  escrituras (ej. log solo-anexo o almacén de eventos); las consultas
  impactan un modelo optimizado para lecturas (ej. proyecciones
  precomputadas, cachés o bases de datos replicadas). Esta separación
  permite que cada lado escale independientemente.
- *Resultado:* la contrapresión de consultas pesadas ya no ralentiza las
  escrituras, y la ingesta permanece estable.

### Procesadores de trabajos (Job Processors)

**Definición / cómo funcionan:** Manejan concurrencia controlada,
permitiendo limitar la ejecución simultánea de tareas e implementar
estrategias sofisticadas de reintentos. Un productor (ej. un servidor web)
encola un trabajo (una tarea a realizar) en una cola. Un pool de procesos
worker (los procesadores de trabajos) sondea continuamente la cola, extrae
trabajos y los ejecuta a una tasa predecible.

**Plataformas populares:** BullMQ, consumidores de RabbitMQ, Celery, Sidekiq.

**Características / capacidades:**
- Encolar trabajos: enviar trabajo asincrónicamente a una cola de trabajos.
- Limitar concurrencia: controlar cuántos trabajos se ejecutan en paralelo.
- Reintentar con backoff: los trabajos fallidos se reintentan con retraso
  exponencial.
- Cola de cartas muertas (DLQ): los trabajos permanentemente fallidos se
  mueven a DLQ para análisis.

**Mecanismo de contrapresión:**
- **Cola como buffer:** la cola absorbe picos en la creación de trabajos.
  Los workers procesan trabajos a una tasa fija y sostenible.
- **Autoescalado de workers:** monitorear la profundidad de la cola (número
  de trabajos pendientes) y escalar automáticamente el número de procesos
  worker hacia arriba o abajo. Una profundidad de cola creciente dispara la
  creación de más workers.
- **Limitación de velocidad por trabajador:** los trabajadores pueden
  configurarse para procesar solo un cierto número de trabajos por minuto,
  especialmente cuando llaman APIs externas con límites de velocidad
  estrictos.

**Ventajas:** simplifica el manejo de tareas de larga duración o que
requieren muchos recursos; mejora la experiencia del usuario al hacer las
solicitudes asíncronas.

**Desventajas:** los resultados suelen ser asíncronos y deben ser
consultados o enviados de vuelta al usuario; requiere monitoreo de la salud
de la cola y el rendimiento de los trabajadores.

**Ejemplo — Servidor web delegando trabajo a una cola de trabajos:**
- *Escenario:* una API web recibe miles de cargas de imágenes.
- *Usar procesadores de trabajos:* en lugar de redimensionarlas en línea (lo
  que bloquea solicitudes y agota la CPU), cada carga es: (1) puesta en cola
  en un procesador de trabajos (ej. cola respaldada por Redis); (2)
  procesada asíncronamente por un número limitado de trabajadores (ej. 10
  trabajos concurrentes).
- *Resultado:* si la demanda se dispara, la cola crece —pero las
  solicitudes permanecen rápidas, y la velocidad de procesamiento del
  sistema se mantiene estable. La cola actúa como un amortiguador; los
  trabajadores procesan trabajos a un rendimiento sostenible.

## Procedimientos o procesos

### Técnicas para implementar el manejo de contrapresión (tabla general)

El documento presenta una tabla con técnicas que pueden emplearse (una o
más combinadas) para gestionar eficazmente la contrapresión en sistemas de
software:

1. **Buffering:** almacenar temporalmente las solicitudes o datos entrantes
   en una cola. Permite al consumidor procesar datos a su propio ritmo, sin
   ser abrumado por el productor. Limitación: las colas pueden llenarse,
   llevando a pérdida de datos o mayor latencia si no se gestionan
   cuidadosamente.
2. **Descarte de carga (Load Shedding):** descartar selectivamente
   solicitudes o datos cuando el sistema está sobrecargado, basándose en
   prioridad, tipo de solicitud u otros criterios. Es una medida drástica,
   pero puede ser necesaria para prevenir fallas del sistema.
3. **Limitación de tasa (Rate Limiting):** restringir el número de
   solicitudes que un productor puede enviar a un consumidor dentro de un
   período de tiempo dado. Previene que el consumidor sea abrumado por
   tráfico excesivo.
4. **Cortacircuitos (Circuit Breakers):** monitorean la salud de
   dependencias posteriores. Si una dependencia se vuelve no disponible o
   comienza a experimentar problemas de rendimiento, el cortacircuito se
   "abrirá", evitando que las solicitudes se envíen a la dependencia
   fallida. Previene fallas en cascada y permite que la dependencia se
   recupere.
5. **Flujos Reactivos (Reactive Streams):** estándar para procesamiento
   asíncrono de flujos con contrapresión incorporada. Define un conjunto de
   interfaces y protocolos que permiten a los consumidores señalar su
   capacidad de procesamiento a los productores, habilitando control de
   flujo eficiente.
6. **Comunicación Asíncrona:** usar patrones de comunicación asíncrona, como
   colas de mensajes o buses de eventos, puede desacoplar productores y
   consumidores, permitiéndoles operar independientemente y manejar la
   contrapresión más efectivamente.
7. **Escalado Horizontal:** escalar el sistema agregando más instancias de
   un componente puede aumentar su capacidad de procesamiento y reducir la
   probabilidad de contrapresión.
8. **Monitoreo y Alertas:** implementar sistemas robustos de monitoreo y
   alertas puede ayudar a detectar contrapresión tempranamente, permitiendo
   intervención proactiva. Métricas como longitudes de cola, utilización de
   CPU y latencia pueden usarse para identificar posibles cuellos de
   botella.

### Filosofía de diseño para manejar contrapresión (conclusión)

1. Diseñar para la contrapresión desde el inicio (no como parche
   posterior).
2. Usar comunicación asíncrona.
3. Emplear colas y buffers limitados.
4. Implementar tiempos de espera sensatos y cortacircuitos.
5. Asegurar que el sistema pueda escalar componentes independientemente.
6. Detectar temprano: monitorear continuamente las profundidades de cola,
   latencias y tasas de error.
7. Reaccionar antes de la cascada (la contrapresión es inevitable, la
   pregunta es si el sistema reacciona a tiempo).

## Ejemplos y casos

### Ejemplos de PLD (tipos de procesos de larga duración)

- **Codificación de video:** transformar formatos multimedia de forma
  asíncrona.
- **Agregación de datos:** compilar grandes conjuntos de datos sin bloqueo.
- **Generación de reportes:** análisis complejos computados en segundo
  plano.
- **Entrenamiento de modelos de aprendizaje automático:** entrenar modelos
  complejos en grandes conjuntos de datos.
- **Importaciones o migraciones de datos masivas:** procesamiento de
  grandes conjuntos de datos, como generar reportes o realizar
  transformaciones de datos.
- **Transacciones financieras:** procesar transacciones financieras
  complejas que requieren múltiples aprobaciones y verificaciones.

### Analogía de las tuberías de agua (contrapresión)

Imaginar un sistema de tuberías de agua: si se bombea agua hacia las
tuberías más rápido de lo que pueden drenar, la presión se acumula y puede
dañar las tuberías o causar fugas. De manera similar, en un sistema de
software, si un componente recibe más solicitudes de las que puede manejar,
puede llevar al agotamiento de recursos, aumento de latencia y, finalmente,
al fallo del sistema.

### Job Processors manejando contrapresión (comparación sin/con)

- **Sin procesador de trabajos:** clientes (C1, C2, C3) envían solicitudes
  directamente a un servidor, que queda sobrecargado (errores 500), lo que
  a su vez sobrecarga la base de datos.
- **Con procesador de trabajos:** los clientes envían solicitudes a un
  servidor API que responde rápido (202 Accepted), encola el trabajo en una
  Job Queue con tasa controlada, y varios workers procesan los trabajos
  hacia una base de datos estable.
- **Beneficios listados:** rate limiting, retry logic, degradación
  elegante, mejor UX (202 vs 500), estabilidad del sistema.

### Combinando enfoques en una arquitectura integrada

El documento presenta un ejemplo de sistema distribuido moderno que combina
los distintos enfoques:
- Una aplicación web usa un procesador de trabajos con una cola (Redis)
  para manejar la generación de miniaturas de imágenes.
- La lógica de negocio principal se construye como una EDA, con servicios
  comunicándose vía procesadores de flujo (Kafka).
- Uno de esos servicios implementa CQRS para alimentar un panel complejo,
  con proyectores consumiendo eventos de Kafka para construir el modelo de
  lectura.

## Comparaciones

| Enfoque | Unidad que gestiona | Mecanismo de contrapresión principal | Pros | Contras |
|---|---|---|---|---|
| Colas de mensajes / brokers | Mensajes individuales | Límite de cola, ack/nack, límite de prefetch | Desacoplamiento, persistencia, escalado fácil de consumidores | Complejidad de gestión del broker, posible punto único de falla, latencia agregada |
| Procesadores de flujos | Flujos continuos de datos | Modelo de extracción con buffer (Kafka) / limitación de tasa dinámica basada en créditos (Flink) | Alto rendimiento, datos en tiempo real, gestión de estado sofisticada | Complejidad operacional, criticidad del particionado y retraso del consumidor |
| EDA | Eventos entre servicios | Limitación de tasa, descarte de carga, cortacircuitos, DLQ, mamparas, código no bloqueante | Sistemas desacoplados, escalables y resistentes | Complejidad en rastreo, depuración, consistencia eventual |
| CQRS | Comandos vs. consultas | Aislamiento arquitectónico (escalado independiente) + almacén de eventos que absorbe retraso del proyector | Escalamiento independiente de lecturas/escrituras, modelos de datos optimizados | Alta complejidad, consistencia eventual, requiere sistema de eventos robusto |
| Procesadores de trabajos | Trabajos/tareas discretas | Cola como buffer, autoescalado de workers, limitación de velocidad por trabajador | Simplifica tareas de larga duración, mejora UX | Resultados asíncronos requieren consulta posterior, requiere monitoreo |

| Patrón para PLD | Control | Impacto arquitectural |
|---|---|---|
| Motores de flujo de trabajo (orquestación) | Centralizado (orquestador) | Separación clara de responsabilidades; procesos explícitos, comprobables y recuperables |
| Patrón Saga (coreografía) | Descentralizado (cada servicio reacciona a eventos) | Desacopla servicios, pero dificulta visualizar y depurar el flujo general; se cambia control central por acoplamiento débil |
| Máquinas de estado | Modelo de estados finito | Modelo robusto con guardias y transiciones claras; base conceptual de motores de flujo y sagas |
| Procesamiento por lotes | Basado en condiciones/reglas de acumulación | Optimiza throughput sobre latencia; introduce picos de recursos, requiere throttling/programación de carga |

## Información visual relevante

### Diagrama: Long-Running Process Architecture

Muestra el flujo típico de una arquitectura de procesos de larga duración:
un Cliente (Web/Mobile App) envía una solicitud HTTP a un API Gateway (con
Auth y Validation), que encola (Enqueue) el trabajo en una Message Queue
(RabbitMQ/Kafka/SQS). Desde ahí se desencola (Dequeue) hacia un Worker Pool
(varios workers en estados Processing/Idle/Scalable), que actualiza (Update)
un State Store (Redis/Database, con Job State y Progress) y almacena
(Store) resultados en un Result Store (S3/Database). Un componente de
Monitoring (Metrics con Prometheus/Datadog, Logging con ELK Stack, Tracing
con Jaeger/Zipkin, Alerts con PagerDuty, y Dead Letter Queue para trabajos
fallidos) observa tanto la Message Queue como el State Store. Patrones
clave señalados: procesamiento asíncrono, escalado horizontal, persistencia
de estado, mecanismos de reintento.

### Diagrama: Causes of System Back-Pressure

Diagrama tipo "fishbone/flujo" que identifica cinco causas de la
contrapresión del sistema, todas convergiendo en "Back-Pressure": (1)
Resource Constraints — recursos limitados dificultan la velocidad y
eficiencia del procesamiento; (2) Slow Dependencies — dependencias lentas
crean cuellos de botella y retrasan el procesamiento; (3) Traffic Spikes —
picos repentinos de tráfico sobrepasan la capacidad del sistema; (4)
Inefficient Processing — algoritmos ineficientes ralentizan el
procesamiento de datos; (5) Network Congestion — la congestión de red
impide el flujo de datos y causa retrasos.

### Diagrama de flujo de trabajo (Motores de orquestación)

Diagrama tipo boceto que muestra un "Workflow Mgmt System" central que
recibe una solicitud de un actor "Vendor", y coordina secuencialmente
llamadas a varios sistemas: Id System, Vendor System, Verification System,
Key Mgmt System y Email System, terminando en un estado de "Success". El
orquestador central decide y controla el flujo entre estos sistemas.

### Diagrama: Saga Pattern — Distributed Transaction Flow

Muestra un flujo de transacción distribuida con un "Saga Orchestrator" que
coordina secuencialmente los servicios: Order Service (createOrder),
Payment Service (processPayment), Inventory Service (reserveStock),
Shipping Service (scheduleDelivery) — camino de éxito (Success Path,
Forward, en verde). Si ocurre un fallo (marcado con una X roja en
Shipping), se activa el camino de compensación (Failure Path, Compensation,
en rojo): cancelDelivery, releaseStock, refundPayment, cancelOrder — en
orden inverso, revirtiendo cada paso previamente completado.

### Diagrama de máquinas de estado (state machine) entre microservicios

Muestra dos microservicios (consumer y supplier), cada uno con su propia
entidad modelada como "state machine". Se comunican de dos formas: llamadas
directas de API (direct API calls) entre entidades, y eventos de ciclo de
vida (lifecycle events) publicados/consumidos a través de un Message Broker
con un tema (topic) vinculado (binding) a una cola (queue).

### Diagrama de procesamiento por lotes (Batch Processing Component)

Muestra usuarios (people icons) enviando "Request" hacia un "Request Store"
y un componente de "Batch Processing" que usa una configuración (config)
para decidir cuándo instanciar "Processing Components" que procesan las
solicitudes acumuladas.

### Diagramas de colas de mensajes (Message Queue / Broker)

Dos diagramas complementarios: uno genérico donde varios "Producers" envían
mensajes a una "Message Queue" que los entrega a un "Consumer"; otro más
detallado donde tres "Producer" (1, 2, 3) envían mensajes a un "Broker" que
gestiona dos colas (Queue 1, Queue 2), entregando mensajes a tres
"Consumer" (1, 2, 3), con un consumidor enviando un reconocimiento (ACK) de
vuelta al broker.

### Diagrama: Stream Processing Engine

Muestra "Input Data" (múltiples flujos de registros) entrando a un "Stream
Processing Engine" (representado como un cilindro con elementos internos de
procesamiento), que produce dos tipos de salida: un "Output Stream" y datos
hacia "Analytics".

### Diagrama de Arquitectura Dirigida por Eventos (EDA)

Muestra "Sources" (Event Data) que envían datos a un "Publisher", que
publica hacia un "Event Data Store" central. Desde este almacén, los datos
fluyen hacia "Subscriber" (y también hacia un componente "Subscriber and
Publisher" que retroalimenta al almacén), y finalmente hacia distintos
"Sinks": Database, File System, Apps y otros destinos genéricos.

### Diagrama de CQRS

Muestra una UI que se conecta por un lado a un "Command Service" (con
"Command Model") que escribe (Writes) hacia un almacenamiento (Storage), y
por otro lado a un "Query Service" (con "Query Model") que lee (Reads)
desde el mismo almacenamiento, devolviendo los datos a la UI. Ilustra la
separación física entre la ruta de escritura y la ruta de lectura.

### Diagrama: Job Processors Handling Back Pressure

Comparación explícita entre dos escenarios:
- **Without Job Processor (marcado con X roja):** tres clientes (C1, C2,
  C3) envían solicitudes directamente a un "Server" que queda "Overwhelmed"
  (con errores 500), lo cual sobrecarga ("Overloaded") a la base de datos
  (DB).
- **With Job Processor (marcado con check verde):** los clientes envían
  solicitudes a un "API Server" que responde rápido ("Fast 202"), encola el
  trabajo en una "Job Queue" (buffered, con tasa controlada — "Controlled
  rate"), que distribuye a varios "Worker" (1, 2, 3) hacia una base de
  datos "Stable". Se listan beneficios: Rate limiting, Retry logic,
  Graceful degradation, Better UX (202 vs 500), System stability.

### Diagrama: Combining Approaches — Integrated Architecture

Diagrama tipo hexágonos que agrupa los seis enfoques cubiertos y su rol
combinado en una arquitectura integrada: Queues (buffer y suavizado de
ráfagas de tráfico en microservicios), Event-Driven (desacopla servicios
usando eventos asíncronos), Job Processors (controla paralelismo y
reintentos para tareas en segundo plano), Stream Processors (maneja control
de flujo reactivo dentro de microservicios), CQRS (separa operaciones de
lectura y escritura para escalabilidad), Dynamic Monitoring (autoescala y
adapta microservicios en tiempo real).

## Terminología importante

- **Rendimiento del sistema (System Performance):** eficiencia con la que
  un sistema usa recursos (CPU, memoria, disco, red) para cumplir
  requisitos.
- **Contrapresión (Backpressure):** fenómeno por el cual componentes
  downstream sobrecargados fuerzan a los componentes upstream a
  ralentizarse o dejar de aceptar entrada; mecanismo natural de throttling
  que previene agotamiento de recursos y fallos en cascada.
- **Proceso de larga duración (PLD / Long-Running Process, LRP):** unidad
  cohesiva de trabajo asíncrona que progresa a través de múltiples estados,
  puede involucrar múltiples servicios y debe sobrevivir reinicios del
  sistema.
- **Idempotencia:** propiedad de un proceso o trabajo por la cual múltiples
  ejecuciones tienen el mismo efecto que una sola ejecución.
- **Buffering:** técnica de almacenar temporalmente solicitudes o datos
  entrantes en una cola para permitir que el consumidor procese a su
  propio ritmo.
- **Descarte de carga (Load Shedding):** descartar selectivamente
  solicitudes o datos cuando el sistema está sobrecargado.
- **Limitación de tasa (Rate Limiting):** restricción del número de
  solicitudes que un productor puede enviar a un consumidor en un período
  de tiempo dado.
- **Cortacircuito (Circuit Breaker):** mecanismo que monitorea la salud de
  dependencias posteriores y "se abre" para evitar enviar solicitudes a
  una dependencia fallida, previniendo fallos en cascada.
- **Flujos Reactivos (Reactive Streams):** estándar para procesamiento
  asíncrono de flujos con contrapresión incorporada, mediante interfaces y
  protocolos que permiten a consumidores señalar su capacidad de
  procesamiento a productores.
- **Escalado Horizontal:** agregar más instancias de un componente para
  aumentar su capacidad de procesamiento.
- **Prefetch (límite de prefetch):** configuración que limita el número de
  mensajes no reconocidos que un consumidor puede tener a la vez.
- **Ack/Nack:** reconocimiento explícito (o rechazo) que un consumidor
  envía tras procesar (o fallar en procesar) un mensaje de una cola.
- **CQRS (Command Query Responsibility Segregation):** patrón que separa
  las operaciones de escritura (comandos) de las de lectura (consultas)
  para permitir escalamiento y optimización independientes de cada lado.
- **Event Sourcing:** mencionado como complemento de CQRS que, combinado
  con este, soporta consistencia eventual y control de flujo suave (no se
  desarrolla en detalle en el documento).
- **Saga (patrón):** patrón para procesos distribuidos donde cada servicio
  participante reacciona a eventos, emite sus propios eventos y define una
  acción compensatoria en caso de fallo.
- **Máquina de estados (finita):** modelo donde una entidad se mueve de un
  estado bien definido a otro en respuesta a eventos.
- **Mamparas (Bulkheads):** técnica de aislamiento de fallos y grupos de
  recursos que previene que una operación lenta consuma todos los hilos
  disponibles.
- **Cola de cartas muertas (Dead Letter Queue, DLQ):** cola donde se
  capturan mensajes o trabajos que no pudieron procesarse exitosamente,
  para análisis posterior y reintento.
- **Consistencia eventual:** estado en el que los distintos modelos de
  datos (por ejemplo, en CQRS) convergen con el tiempo, sin garantizar
  sincronización inmediata.
- **Backoff exponencial:** estrategia de reintento en la que el retraso
  entre intentos fallidos aumenta exponencialmente.
- **Semántica de exactamente una vez (exactly-once):** garantía de
  procesamiento en procesadores de flujos donde cada registro se procesa
  una única vez, sin duplicados ni pérdidas.

## Notas y advertencias

- El documento es de naturaleza introductoria/conceptual (formato de
  diapositivas de clase) y combina texto explicativo con diagramas tomados
  de fuentes externas (se citan URLs de blogs y sitios como hookdeck.com,
  algomaster.io, hazelcast.com, cloudcomputingpatterns.org, kislayverma.com,
  rclayton.silvrback.com, henriquesd.medium.com). No se profundiza en el
  contenido técnico interno de esas fuentes más allá de lo que aparece en
  la diapositiva.
- **Event Sourcing** se menciona explícitamente como complemento de CQRS
  ("CQRS combinado con event sourcing soporta consistencia eventual...")
  pero no se define ni desarrolla como concepto independiente en este
  documento; queda como término mencionado sin explicación propia.
- El estándar "Flujos Reactivos" (Reactive Streams) se presenta tanto como
  una técnica general de manejo de contrapresión (en la tabla de técnicas)
  como con detalle adicional en la sección de "Procesadores de Flujos:
  Control de Flujo Reactivo"; el documento no aclara explícitamente si son
  exactamente el mismo concepto en ambos contextos o si uno es un caso
  particular del otro, aunque el contenido es coherente entre ambas
  secciones.
- Los ejemplos de "Motores de Flujo de Trabajo" (Temporal, AWS Step
  Functions, Azure Durable Functions, Camunda) y "Patrón Saga" se
  presentan sin ejemplo de código; son referencias a nivel de nombre de
  herramienta/plataforma, sin comparación directa entre sí más allá del
  contraste general orquestación vs. coreografía.
- El diagrama del patrón Saga presenta un "Saga Orchestrator" coordinando
  los pasos, lo cual podría generar cierta ambigüedad conceptual: el texto
  define el patrón Saga por coreografía (reacción descentralizada a
  eventos), pero el diagrama incluye un orquestador central que "coordina
  todos los pasos" y "dispara compensaciones al fallar". El documento no
  aclara esta aparente tensión entre coreografía pura y orquestación
  dentro del propio patrón Saga.
- No se incluye una definición formal separada de "contrapresión" en una
  sección dedicada de terminología dentro del documento; se explica
  mediante el fenómeno, la analogía de las tuberías y el diagrama de
  causas, pero sin una definición encapsulada única.
- Las páginas de portada, agenda, desglose semanal, imágenes puramente
  decorativas (fotografías de personas trabajando, tuberías) y la
  diapositiva final de agradecimiento fueron excluidas del contenido
  curado por no aportar conocimiento sustantivo.
