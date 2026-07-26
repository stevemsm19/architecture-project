# Hito 3. Capa de Procesamiento en Tiempo Real de Eventos

## 1. Especificación Estructurada de Requerimientos

### 1.1. Detección de Fraude en Compras

| ID | Requerimiento | Criterio de Verificación | Observaciones |
|---|---|---|---|
| REQ-FRD-001 | El Módulo de Detección de Fraude deberá evaluar cada transacción de checkout contra las reglas de velocidad de compra en un tiempo menor o igual a 150 ms desde la recepción del evento de pago. | Prueba: medición de latencia p99 del componente bajo carga sintética de 5,000 TPS. | La latencia se mide de forma aislada al componente, sin incluir el tiempo de la pasarela de pago externa. |
| REQ-FRD-002 | El Módulo de Detección de Fraude deberá marcar como sospechosa toda cuenta de usuario que registre más de 5 intentos de compra fallidos en una ventana móvil de 60 segundos. | Prueba: inyección de 6 intentos fallidos consecutivos en 60 segundos y verificación del marcado de la cuenta. | Umbral configurable; el valor de 5 intentos se toma como línea base sujeta a calibración con datos históricos. |
| REQ-FRD-003 | El Módulo de Detección de Fraude deberá calcular la distancia geográfica entre la ubicación de la IP de origen y la última ubicación de compra confirmada del usuario para cada transacción. | Análisis: revisión del algoritmo de geolocalización y verificación de precisión contra dataset de referencia con margen de error menor a 50 km. | Depende de un servicio externo de geolocalización por IP; su disponibilidad es una dependencia crítica del requerimiento. |
| REQ-FRD-004 | El sistema deberá bloquear de forma automática toda transacción cuyo puntaje de riesgo agregado supere el umbral de 0.85 en una escala normalizada de 0 a 1. | Demostración: ejecución de un caso de prueba con transacción sintética de puntaje 0.90 y verificación del bloqueo antes de la confirmación del pago. | El cálculo del puntaje agregado (modelo de scoring) se especifica en un documento técnico separado, fuera del alcance de este hito. |
| REQ-FRD-005 | El Módulo de Detección de Fraude deberá procesar el 100 % de las transacciones antes de la confirmación del pago, sin excepción por tipo de producto o monto. | Inspección: revisión del flujo de checkout para confirmar que ninguna ruta de código omite la invocación al módulo de fraude. | Aplica exclusivamente a transacciones de compra; no cubre reembolsos ni cancelaciones. |

### 1.2. Sincronización Continua de Inventario

| ID | Requerimiento | Criterio de Verificación | Observaciones |
|---|---|---|---|
| REQ-INV-001 | El sistema deberá actualizar el stock disponible de un producto en un tiempo menor o igual a 200 ms desde la confirmación de una reserva de compra. | Prueba: medición de latencia p95 entre el evento de reserva y la actualización visible en el datastore de consulta. | Este requerimiento condiciona el diseño del pipeline descrito en la sección 2.2. |
| REQ-INV-002 | El sistema deberá garantizar que la cantidad reservada de un producto nunca exceda la cantidad de stock físico disponible registrada en el sistema de origen. | Prueba: ejecución de 1,000 solicitudes de reserva concurrentes sobre un stock de 100 unidades y verificación de que el número de reservas exitosas sea exactamente 100. | Este es el requerimiento crítico de prevención de overselling; determina la semántica de entrega exactly-once definida en la sección 3.1. |
| REQ-INV-003 | El Módulo de Inventario deberá liberar automáticamente toda reserva de stock no confirmada en un plazo máximo de 600 segundos desde su creación. | Prueba: creación de una reserva sin confirmación de pago y verificación de su liberación tras 600 segundos ± 5 segundos. | El plazo de expiración es configurable por tipo de evento de venta relámpago. |
| REQ-INV-004 | El sistema deberá emitir un evento de dominio `StockActualizado` por cada cambio en la cantidad disponible de un producto, incluyendo el identificador de producto, la cantidad resultante y una marca de tiempo. | Inspección: revisión del esquema del evento contra el contrato definido (schema registry). | El evento constituye la fuente de verdad para los modelos de lectura (CQRS) definidos en el Hito 1. |
| REQ-INV-005 | El sistema deberá procesar eventos de actualización de inventario del mismo producto en el orden estricto en que fueron generados. | Prueba: envío de una secuencia de 50 eventos ordenados para el mismo SKU y verificación de que el estado final coincide con el procesamiento secuencial esperado. | Requiere partición de tópico por identificador de producto (key-based partitioning), detallado en la sección 2.2. |

### 1.3. Motor de Recomendaciones Personalizadas

| ID | Requerimiento | Criterio de Verificación | Observaciones |
|---|---|---|---|
| REQ-REC-001 | El Módulo de Recomendaciones deberá incorporar cada evento de clickstream (vista de producto, agregado a carrito) al perfil de sesión activa del usuario en un tiempo menor o igual a 500 ms. | Prueba: medición de latencia p95 entre la generación del evento de clickstream y su reflejo en el perfil de sesión. | Aplica únicamente a sesiones activas; no cubre el reentrenamiento de modelos batch. |
| REQ-REC-002 | El Módulo de Recomendaciones deberá mantener el estado de sesión de un usuario disponible durante un mínimo de 30 minutos de inactividad antes de expirarlo. | Prueba: verificación de disponibilidad del estado de sesión a los 29 minutos y su expiración a los 31 minutos de inactividad. | El plazo de 30 minutos corresponde a una ventana de sesión (session window), definida en la sección 3.3. |
| REQ-REC-003 | El sistema deberá generar una lista de recomendaciones actualizada para el usuario en un tiempo menor o igual a 300 ms desde la solicitud, utilizando el estado de sesión más reciente disponible. | Prueba: medición de latencia p99 del endpoint de recomendaciones bajo carga de 2,000 solicitudes por segundo. | El requerimiento no exige que la recomendación incorpore el evento más reciente si este llegó fuera del margen de latencia definido en REQ-REC-001. |
| REQ-REC-004 | El Módulo de Recomendaciones deberá continuar sirviendo la última lista de recomendaciones calculada en caso de falla del procesador de clickstream en tiempo real. | Demostración: simulación de caída del stream processor y verificación de que el endpoint de recomendaciones continúa respondiendo con datos del último estado persistido. | Implica una estrategia de degradación controlada (graceful degradation), no bloqueo del flujo de navegación. |

### 1.4. Alertas Operativas y Monitoreo de Infraestructura

| ID | Requerimiento | Criterio de Verificación | Observaciones |
|---|---|---|---|
| REQ-MON-001 | El sistema deberá generar una alerta cuando la tasa de errores HTTP 5xx del servicio de checkout supere el 2 % del total de solicitudes en una ventana móvil de 1 minuto. | Prueba: inyección sintética de errores 5xx hasta superar el umbral y verificación de la generación de la alerta en un tiempo menor a 30 segundos. | El umbral del 2 % debe validarse contra el SLO definido en el Hito 1; sujeto a ajuste según el error budget acordado. |
| REQ-MON-002 | El sistema deberá generar una alerta cuando la latencia p99 de cualquier servicio crítico (checkout, inventario, pagos) supere los 1,000 ms durante 3 minutos consecutivos. | Prueba: simulación de degradación de latencia sostenida y verificación de la alerta correspondiente. | La lista de "servicios críticos" debe mantenerse en un catálogo versionado, no codificada de forma fija. |
| REQ-MON-003 | El sistema deberá detectar y notificar la activación de un circuit breaker en cualquier servicio dentro de un plazo máximo de 15 segundos desde su apertura. | Prueba: forzar la apertura de un circuit breaker mediante fallos simulados y medición del tiempo hasta la notificación. | Depende del requerimiento de instrumentación de resiliencia a definir en un hito posterior. |
| REQ-MON-004 | El sistema deberá calcular y exponer la tasa de errores de la pasarela de pago de forma segmentada por proveedor de pago, con una frecuencia de actualización menor o igual a 10 segundos. | Prueba: verificación de la frecuencia de actualización de la métrica en el panel de observabilidad bajo tráfico sintético. | Aplica cuando existe más de un proveedor de pago activo simultáneamente (multi-PSP). |

### 1.5. Preguntas de Aclaración

Los siguientes puntos requieren definición del equipo de negocio o de producto antes de poder formalizar el requerimiento correspondiente con una métrica cuantitativa verificable:

1. **REQ-FRD-002 / REQ-FRD-004:** ¿Existe un modelo de scoring de fraude ya definido o debe diseñarse como parte de este proyecto? El umbral de 0.85 y la ventana de 5 intentos se proponen como línea base y requieren validación con el equipo de riesgo/antifraude.
2. **REQ-INV-003:** ¿El plazo de expiración de reservas no confirmadas (600 segundos) es uniforme para todos los productos o varía según el tipo de evento de venta relámpago (flash sale de 1 hora vs. oferta de fin de semana)?
3. **REQ-REC-002:** ¿La ventana de sesión de 30 minutos está alineada con la política de sesión ya utilizada en el frontend/autenticación, o debe definirse de forma independiente para el motor de recomendaciones?
4. **REQ-MON-001 / REQ-MON-002:** Los umbrales de alerta (2 % de error rate, 1,000 ms de p99) deben confirmarse contra los SLOs formales que se definan a partir de las métricas del Hito 1; se proponen como valores iniciales sujetos a ajuste.
5. **General:** ¿Existe un volumen histórico de tráfico (RPS/TPS pico de eventos anteriores) disponible para calibrar los umbrales de carga usados en los criterios de verificación, o deben tomarse como estimaciones iniciales a validar en pruebas de carga?

---

## 2. Diseño de Pipelines de Procesamiento en Tiempo Real

### 2.1. Detección de Fraude en Compras

| Etapa | Especificación |
|---|---|
| **Fuente de eventos** | Tópico `checkout.payment.initiated`, payload con `userId`, `transactionId`, `monto`, `ipOrigen`, `metodoPago`, `timestamp`. Ingesta vía productor síncrono desde el servicio de checkout en el momento de iniciar el cobro. |
| **Procesadores de flujo** | (1) Enriquecimiento: join con estado de geolocalización histórica del usuario (operación con estado, keyed por `userId`). (2) Filtrado: descarte de eventos duplicados por `transactionId` (deduplicación). (3) Agregación con estado: conteo de intentos fallidos en ventana deslizante de 60 segundos por `userId`. (4) Scoring: aplicación del modelo de riesgo sobre el evento enriquecido. |
| **Destinos (sinks)** | Cache de baja latencia (Redis) con el resultado del scoring indexado por `transactionId`, consumido de forma síncrona por el servicio de checkout antes de confirmar el pago. Adicionalmente, tópico `fraude.transaccion.marcada` para auditoría y alimentación del panel de riesgo. |

### 2.2. Sincronización Continua de Inventario

| Etapa | Especificación |
|---|---|
| **Fuente de eventos** | Tópico `inventario.reserva.solicitada`, particionado por `productId` para garantizar orden estricto por SKU (REQ-INV-005). Payload: `productId`, `cantidad`, `transactionId`, `timestamp`. |
| **Procesadores de flujo** | (1) Operación con estado: mantenimiento del contador de stock disponible por `productId` como estado local del procesador (state store). (2) Validación atómica: comparación de la cantidad solicitada contra el estado actual antes de decrementar (previene overselling, REQ-INV-002). (3) Emisión condicional: generación de evento de reserva confirmada o rechazada según resultado. (4) Temporizador de expiración: gestión de reservas no confirmadas mediante temporización con estado (timers), acorde a REQ-INV-003. |
| **Destinos (sinks)** | Base de datos NoSQL de baja latencia (ej. DynamoDB/Cassandra) como vista de lectura de stock para el catálogo. Tópico `inventario.stock.actualizado` (REQ-INV-004) consumido por el modelo de lectura CQRS y por el motor de recomendaciones para reflejar disponibilidad en tiempo real. |

### 2.3. Motor de Recomendaciones Personalizadas

| Etapa | Especificación |
|---|---|
| **Fuente de eventos** | Tópico `clickstream.evento`, payload con `sessionId`, `userId` (si autenticado), `productId`, `tipoEvento` (vista/carrito/búsqueda), `timestamp`. Ingesta de alto volumen desde el frontend vía SDK de tracking. |
| **Procesadores de flujo** | (1) Operación con estado: acumulación de eventos por `sessionId` dentro de una ventana de sesión (session window, REQ-REC-002). (2) Enriquecimiento: cruce con metadata de producto (categoría, precio) desde una tabla de referencia. (3) Cálculo incremental de afinidad por categoría/producto como estado agregado de la sesión. |
| **Destinos (sinks)** | Cache de baja latencia (Redis) con el vector de afinidad de sesión, consultado de forma síncrona por el endpoint de recomendaciones (REQ-REC-003). Motor de búsqueda (ej. Elasticsearch/OpenSearch) para recomendaciones basadas en similitud de producto como fuente secundaria ante degradación (REQ-REC-004). |

### 2.4. Alertas Operativas y Monitoreo de Infraestructura

| Etapa | Especificación |
|---|---|
| **Fuente de eventos** | Métricas y logs estructurados emitidos por todos los servicios vía OpenTelemetry: tópicos `metrics.http.status`, `metrics.latency`, `infra.circuitbreaker.estado`. |
| **Procesadores de flujo** | (1) Agregación en ventana deslizante (tumbling/sliding de 1 minuto) de tasa de error por servicio (REQ-MON-001). (2) Cálculo de percentiles de latencia mediante estructuras de aproximación (ej. t-digest) sobre ventana de 3 minutos (REQ-MON-002). (3) Detección de cambio de estado (state transition) para eventos de circuit breaker, sin ventana temporal — procesamiento evento por evento (REQ-MON-003). |
| **Destinos (sinks)** | Backend de series temporales (Prometheus remote-write o equivalente) para dashboards; sistema de alertas (Alertmanager/PagerDuty) para notificación activa; tópico `alertas.criticas` para integración con el panel operativo del equipo de guardia. |

---

## 3. Garantías de Consistencia, Estado y Ventanas Temporales

### 3.1. Semánticas de Entrega

La elección de semántica de entrega no es uniforme para toda la plataforma, sino que depende de la tolerancia a duplicados de cada dominio.

| Dominio | Semántica recomendada | Justificación |
|---|---|---|
| **Inventario y checkout** | Exactly-once (o at-least-once con idempotencia estricta) | Un decremento de stock duplicado provoca overselling directo (viola REQ-INV-002). Dado que exactly-once end-to-end real depende del soporte transaccional del broker y del sink, la alternativa operativamente más robusta es at-least-once combinado con deduplicación por `transactionId` (idempotency key) en el procesador con estado, logrando el mismo resultado observable sin depender exclusivamente de garantías transaccionales del broker. |
| **Detección de fraude** | At-least-once con deduplicación | El reprocesamiento de un evento de fraude no altera el estado del negocio si el marcado es idempotente (aplicar el mismo resultado dos veces no cambia el estado final); prioriza no perder eventos sobre evitar duplicados. |
| **Clickstream / recomendaciones** | At-least-once, sin deduplicación estricta | La pérdida o duplicación ocasional de un evento de clickstream tiene impacto negligible en la calidad de la recomendación; exigir exactly-once aquí añadiría latencia y complejidad sin beneficio proporcional. |
| **Alertas y métricas** | At-least-once o best-effort | Una métrica duplicada en una ventana de agregación introduce un sesgo mínimo tolerable; priorizar disponibilidad y baja latencia sobre precisión exacta. |

El principio general es que **exactly-once se reserva para el dominio donde un duplicado tiene costo de negocio directo (inventario)**, mientras que el resto de dominios adopta at-least-once, que ofrece mejor throughput y menor complejidad operativa, apoyándose en idempotencia a nivel de aplicación cuando es necesario.

### 3.2. Garantía de Orden y Eventos Fuera de Orden

El orden estricto solo es indispensable dentro de la misma entidad de negocio (mismo `productId` en inventario, mismo `userId` en fraude), no de forma global. Esto se logra mediante **particionado por clave** en el broker, garantizando que todos los eventos de una misma entidad se procesen en la misma partición y, por tanto, en orden de llegada.

Para el tratamiento de eventos tardíos (por ejemplo, un evento de clickstream que llega con retraso de red), se adopta **event time** como referencia temporal para los cálculos de ventana en lugar de **processing time**: el evento se agrupa según el momento en que ocurrió, no según el momento en que fue procesado, evitando que la variabilidad de la red distorsione los agregados. Se define un **watermark** con un margen de tolerancia (ej. 5 segundos para clickstream, más estricto para inventario) que determina cuándo una ventana se considera cerrada y lista para emitir resultado. Los eventos que llegan después del watermark (**late data**) se gestionan mediante una política explícita: para el dominio de recomendaciones se descartan o se incorporan a un agregado de corrección posterior sin bloquear el resultado ya emitido (dado el bajo costo de negocio de un dato tardío); para el dominio de inventario, dado que un evento tardío de reserva podría representar una operación crítica, se enruta a un flujo de reconciliación separado en lugar de descartarse silenciosamente.

### 3.3. Gestión de Estado y Ventanas

| Dominio | Tipo de ventana | Justificación |
|---|---|---|
| **Fraude (conteo de intentos fallidos)** | Sliding window de 60 segundos | Necesita evaluación continua y solapada; un intento nuevo debe reconsiderar los últimos 60 segundos completos, no esperar al cierre de un intervalo fijo. |
| **Inventario (contador de stock)** | Sin ventana — estado continuo (keyed state) | No es una agregación temporal sino un valor de estado persistente por `productId`, actualizado de forma incremental con cada evento. |
| **Recomendaciones (perfil de sesión)** | Session window con gap de 30 minutos | El límite de la ventana lo define la inactividad del usuario, no un intervalo de tiempo fijo, alineado con REQ-REC-002. |
| **Monitoreo (tasa de error, latencia)** | Tumbling window de 1 minuto (con posibles ventanas deslizantes de menor granularidad para alertas más sensibles) | Las métricas operativas requieren agregados discretos y no solapados para reportes consistentes, evitando el doble conteo de una misma anomalía en ventanas contiguas. |

La persistencia del estado intermedio (contadores, perfiles de sesión, contadores de stock) debe respaldarse mediante **checkpointing** periódico a almacenamiento durable, de forma que ante una falla del procesador de flujo el estado se reconstruya desde el último checkpoint más el reprocesamiento del log de eventos posterior, sin pérdida de consistencia ni reinicio completo del cálculo.

---

## 4. Benchmark de Tecnologías de Stream Processing

| Criterio | **Apache Flink** | **Kafka Streams** | **Spark Structured Streaming** |
|---|---|---|---|
| **Modelo de procesamiento** | Native streaming, evento por evento, con latencia de procesamiento del orden de milisegundos. | Native streaming, evento por evento; se ejecuta embebido dentro de la propia aplicación consumidora, sin clúster dedicado. | Micro-batching (con modo de baja latencia "Continuous Processing" experimental y limitado en garantías); introduce latencia mínima del orden de cientos de milisegundos por diseño de batch. |
| **Gestión de estado interno** | Estado gestionado nativamente con checkpointing distribuido (RocksDB como backend), pensado para operaciones con estado complejas y de gran volumen. | Estado local por instancia respaldado en un tópico de changelog de Kafka; suficiente para agregaciones moderadas, pero el estado crece acoplado al particionado del tópico de entrada. | Estado gestionado mediante checkpoints sobre almacenamiento distribuido (HDFS/S3); más orientado a agregaciones por micro-batch que a estado de baja latencia por evento. |
| **Escalabilidad horizontal** | Alta; diseñado para clústeres dedicados con reparticionamiento dinámico de estado. | Escala junto con el número de particiones del tópico de Kafka; el paralelismo máximo está limitado por el particionado de origen. | Alta, apalancada en el motor de ejecución distribuido de Spark, aunque orientada a paralelismo de lotes más que a procesamiento evento por evento de baja latencia. |
| **Tolerancia a fallos** | Checkpointing distribuido con semántica exactly-once end-to-end cuando el sink lo soporta (ej. transacciones de Kafka). | Tolerancia a fallos mediante reprocesamiento del changelog topic; soporta exactly-once dentro del ecosistema Kafka. | Tolerancia a fallos mediante checkpoints y write-ahead logs; exactly-once alcanzable con sinks idempotentes o transaccionales. |
| **Complejidad operativa** | Alta: requiere operar y dimensionar un clúster dedicado (JobManager/TaskManager), con curva de aprendizaje pronunciada. | Baja: no requiere infraestructura adicional al clúster de Kafka ya existente; se despliega como parte de la propia aplicación. | Media-alta: requiere clúster Spark (o servicio administrado) y presenta mayor complejidad de tuning para casos de baja latencia, para los que no fue diseñado originalmente. |

**Casos de uso ideales dentro de la arquitectura de FlashSale Inc.:**

**Apache Flink** es la opción más adecuada para el dominio de **inventario** (sección 2.2) y **detección de fraude** (sección 2.1), donde se requieren operaciones con estado complejas (contadores por producto, ventanas deslizantes de intentos fallidos), garantías estrictas de orden por clave y baja latencia consistente bajo picos de carga — exactamente el escenario donde su gestión de estado distribuido y sus garantías de checkpointing justifican la mayor complejidad operativa.

**Kafka Streams** encaja mejor en el dominio de **monitoreo y alertas** (sección 2.4) y como componente auxiliar en flujos de menor complejidad de estado, dado que FlashSale Inc. ya dependerá de Kafka como broker central para toda la plataforma EDA: evita introducir un clúster adicional cuando el volumen y la complejidad de las agregaciones no lo justifican, priorizando simplicidad operativa.

**Spark Structured Streaming** es la alternativa menos indicada para los flujos de baja latencia definidos en este hito (fraude, inventario, recomendaciones en sesión activa), dado que su modelo de micro-batching entra en conflicto directo con los requerimientos de latencia sub-segundo (REQ-FRD-001, REQ-INV-001, REQ-REC-001). Su uso queda mejor justificado fuera del alcance de este hito, en cargas de analítica batch o near-real-time menos sensibles a la latencia, como el reentrenamiento periódico de los modelos de recomendación o fraude sobre grandes volúmenes históricos.