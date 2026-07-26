# Hito 1: Análisis de Rendimiento y Limitaciones del Sistema Actual

## 1. Análisis de Cuellos de Botella Monolíticos

### 1.1 Base de Datos Centralizada

Durante una venta relámpago, el monolito típico ejecuta lecturas y escrituras sobre una única instancia RDBMS (ej. PostgreSQL/MySQL) que actúa como fuente única de verdad para inventario, pedidos, pagos y notificaciones.

| Punto de Fallo | Mecanismo de Degradación | Clasificación CAP |
|---|---|---|
| Row-level locking en tabla `inventory` | 10,000+ transacciones concurrentes compiten por el mismo lock de fila (SKU en oferta), generando cola de espera exponencial | **CP**: el sistema prioriza consistencia (evitar overselling) sacrificando disponibilidad — las transacciones se bloquean en vez de fallar rápido |
| Connection pool exhaustion | Pool típico (100-200 conexiones) se satura; nuevas requests esperan en cola del lado de la aplicación hasta timeout | Consecuencia directa de mantener consistencia fuerte vía ACID en un solo nodo |
| Replicación síncrona (si existe) | Si hay réplicas de lectura síncronas, cada escritura espera ACK de réplicas → latencia amplificada | CP explícito: se sacrifica latencia/disponibilidad por consistencia replicada |
| Deadlocks en actualizaciones concurrentes de stock | `UPDATE inventory SET stock = stock - 1 WHERE sku = X` sin optimistic locking genera contención masiva | La estrategia CP de "leer-antes-de-escribir con bloqueo" colapsa a alta concurrencia |

**Justificación CAP**: la base de datos centralizada, al operar bajo semántica ACID estricta (CP), no está diseñada para absorber picos de escritura de esta magnitud. Cuando la partición de facto ocurre (saturación de la red interna o del pool de conexiones), el sistema no degrada disponibilidad de forma controlada — colapsa, porque no existe una estrategia explícita de trade-off hacia AP en los componentes que lo permitirían (ej. contador de inventario aproximado).

### 1.2 Procesamiento Sincrónico de Pedidos

| Punto de Fallo | Mecanismo de Degradación |
|---|---|
| Cadena de llamadas síncronas (validación → inventario → pago → notificación → confirmación) | Latencia acumulada de cada hop; si el proveedor de pagos externo tarda 2-3s, ese tiempo se propaga a TODO el request, bloqueando el thread/worker |
| Ausencia de colas intermedias | Cualquier fallo downstream (ej. servicio de email caído) revierte o cuelga la transacción completa |
| Thread-per-request (modelos no reactivos) | Con 10K usuarios concurrentes, cada request retiene un thread/worker durante todo el ciclo de vida del pedido; el thread pool se agota antes de que el hardware lo haga |

**Justificación CAP**: el procesamiento síncrono es una manifestación de CP llevado al extremo — cada paso exige confirmación consistente del paso anterior antes de continuar, sin tolerancia a que un subsistema esté temporalmente no disponible (P). No hay mecanismo de eventual consistency que permita, por ejemplo, aceptar el pedido y confirmar el pago de forma asíncrona.

### 1.3 Limitaciones del Escalado Vertical

| Limitación | Impacto en Venta Relámpago |
|---|---|
| Techo de hardware (CPU/RAM máximos por instancia) | Un pico de 10K usuarios puede requerir 10-20x la capacidad baseline; escalar verticalmente en tiempo real es operativamente inviable (requiere reinicio o migración) |
| Single point of failure | Toda la carga depende de una única instancia (o instancia primaria); su caída es caída total del sistema |
| Costo no lineal | Instancias de mayor tamaño tienen costo marginal creciente y rendimientos decrecientes (contención de memoria, NUMA effects) |
| Sin elasticidad reactiva | El escalado vertical no responde a picos de segundos/minutos típicos de flash sales (duración 5-30 min) |

### 1.4 Acoplamiento Fuerte Entre Módulos

| Problema | Consecuencia |
|---|---|
| Deploy monolítico único | Un bug en el módulo de notificaciones bloquea el deploy de un fix urgente en el módulo de pagos |
| Fallo en cascada | Si el módulo de notificaciones (ej. llamada a proveedor SMS/push) se degrada, consume threads/memoria compartida y afecta checkout |
| Escalado no granular | No es posible escalar solo el subsistema de notificaciones (que es el foco del rediseño) sin escalar todo el monolito |
| Contención de recursos compartidos | Todos los módulos compiten por el mismo pool de CPU/memoria/conexiones DB |

---

## 2. Métricas Clave de Rendimiento (SLIs/SLOs)

| Categoría | SLI | SLO Objetivo (Estado Estable) | SLO Objetivo (Pico Flash Sale) | Herramienta de Medición |
|---|---|---|---|---|
| **Latencia** | p95 latencia de notificación (evento → entrega) | ≤ 200 ms | ≤ 800 ms | APM (traces distribuidos) |
| **Latencia** | p99 latencia de notificación | ≤ 500 ms | ≤ 1,500 ms | APM |
| **Latencia** | p95 latencia de checkout end-to-end | ≤ 1 s | ≤ 3 s | APM |
| **Throughput** | Eventos de notificación procesados | 500 req/s | ≥ 10,000 req/s sostenidos | Métricas del broker (Kafka/Redis Streams) |
| **Throughput** | Pedidos procesados | 100 req/s | ≥ 2,000 req/s sostenidos | Métricas de aplicación |
| **Recursos** | CPU utilización promedio por nodo | ≤ 60% | ≤ 75% (umbral de auto-scaling) | Prometheus/Node Exporter |
| **Recursos** | Memoria utilizada | ≤ 70% | ≤ 80% | Prometheus |
| **Recursos** | I/O Wait | ≤ 5% | ≤ 15% (alerta crítica > 20%) | iostat / Prometheus |
| **Errores** | Tasa de HTTP 5xx | ≤ 0.1% | ≤ 1% (umbral de degradación aceptable) | Gateway/Load Balancer logs |
| **Errores** | Tasa de timeouts | ≤ 0.05% | ≤ 0.5% | APM |
| **Errores** | Error budget mensual | 99.9% disponibilidad (43.2 min/mes) | N/A (ventana de evento aislada) | SLO dashboard |
| **Backpressure** | Longitud de cola (broker) | < 1,000 mensajes | < 50,000 mensajes (alerta), circuit breaker en > 100,000 | Kafka consumer lag / Redis XLEN |
| **Backpressure** | Tiempo de retención en cola antes de procesamiento | < 100 ms | < 2 s (degradación aceptable), alerta > 5 s | Consumer lag time |
| **Backpressure** | Consumer lag (offset delta) | < 500 mensajes | < 10,000 mensajes | Kafka Exporter |
| **Backpressure** | Tasa de rechazo por saturación (load shedding) | 0% | ≤ 2% (aceptable bajo carga extrema) | Rate limiter metrics |

**Nota de diseño**: los SLOs de "Pico Flash Sale" reflejan una degradación controlada y explícita — priorizan disponibilidad (AP) sobre latencia estricta, aceptando notificaciones con delay antes que pérdida total de servicio.

---

## 3. Estrategia de Escalado y Particionado

### 3.1 Clasificación de Componentes para Escalado Horizontal

| Componente | Estrategia de Escalado | Estado | Justificación CAP |
|---|---|---|---|
| API Gateway / BFF | Horizontal (stateless, auto-scaling) | Sin estado | AP: prioriza disponibilidad; cualquier réplica atiende cualquier request |
| Servicio de Notificaciones | Horizontal (consumer groups) | Sin estado (delega estado a broker) | AP: entrega eventual, tolera nodos caídos sin bloquear el flujo |
| Servicio de Validación de Pedido | Horizontal | Sin estado | AP en la capa de aceptación; delega consistencia fuerte al paso de inventario |
| Motor de Inventario (stock) | Particionado (sharding) por SKU/región | Con estado | **CP obligatorio**: requiere consistencia fuerte para evitar overselling; el trade-off es disponibilidad reducida en el shard afectado durante partición de red |
| Base de Datos de Pedidos (Order DB) | Réplicas de lectura + escritura particionada por `order_id`/tenant | Con estado | CP en escritura (garantiza no duplicar pedidos), AP en lectura (réplicas pueden servir datos con leve staleness) |
| Cache de Catálogo/Precios | Réplicas horizontales (read-heavy) | Con estado, replicado | AP: tolera inconsistencia temporal de precios (staleness aceptable en ventana de segundos) |
| Broker de Eventos (Kafka/Redis Streams) | Particionado por partition key (ej. `user_id` o `order_id`) | Con estado, distribuido | AP a nivel de disponibilidad de partición, con configuración de `acks` ajustable para balancear CP/AP según criticidad del topic |

### 3.2 Réplicas vs. Sharding — Trade-offs Detallados

| Estrategia | Aplicado a | Ventaja | Trade-off CAP |
|---|---|---|---|
| **Replicación de lectura** | Catálogo, precios, perfil de usuario | Distribuye carga de lectura (80-90% del tráfico en flash sale es consulta de producto) | AP: las réplicas pueden servir datos ligeramente desactualizados (eventual consistency) durante picos de escritura en el nodo primario |
| **Sharding por SKU** | Inventario de productos en oferta | Aísla contención — un SKU "hot" no bloquea al resto del catálogo | CP dentro del shard (consistencia estricta del contador de stock), AP entre shards (fallo de un shard no tumba el sistema completo) |
| **Sharding por `order_id`/hash de usuario** | Order DB, notificaciones | Distribuye escrituras de pedidos entre múltiples particiones, evita cuello de botella único | CP por partición (garantiza atomicidad del pedido individual), AP a nivel de sistema (partición caída no bloquea otras) |
| **Particionado de tópicos por `user_id`** | Broker de notificaciones | Garantiza orden de eventos por usuario sin serializar todo el flujo global | AP explícito: se prioriza throughput y disponibilidad; el orden global entre usuarios distintos no se garantiza (no es requerido) |

### 3.3 Principio Rector del Hito 1

La estrategia inicial establece una **frontera CAP explícita**: los componentes de "camino crítico transaccional" (inventario, confirmación de pago) permanecen **CP**, aislados mediante sharding para minimizar el radio de impacto de bloqueos. Los componentes de "camino de notificación y consulta" (el foco de este diseño) migran a **AP**, aceptando entrega eventual y posible reordenamiento/duplicación controlada a cambio de disponibilidad bajo carga masiva — esto sienta la base conceptual para el Hito 2 (arquitectura orientada a eventos).

---

# 4. Benchmark de Herramientas de Observabilidad

Una arquitectura orientada a eventos requiere una plataforma de observabilidad capaz de correlacionar métricas, registros y trazas distribuidas entre múltiples microservicios. La siguiente comparación resume las principales alternativas para este escenario.

| Herramienta / ecosistema | Tipo                                | Métricas | Logs                                       | Trazas / OpenTelemetry                                      | Alertas | Despliegue            | Ventaja principal                                                                                       | Limitación principal                                                                      | Costos / complejidad                                                    |
| ------------------------ | ----------------------------------- | -------- | ------------------------------------------ | ----------------------------------------------------------- | ------- | --------------------- | ------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------- | ----------------------------------------------------------------------- |
| Prometheus + Grafana     | Open-source / stack modular         | Sí       | Parcial, normalmente con backend adicional | Sí, vía OpenTelemetry e integraciones OTLP prometheus       | Sí      | Self-hosted o híbrido | Excelente para métricas de infraestructura y aplicaciones cloud-native, con alta flexibilidad gartner+1 | No unifica por sí solo logs y trazas; requiere componentes extra y operación propia jacar | Bajo costo de licencia, mayor complejidad operativa gartner+1           |
| Datadog                  | SaaS comercial                      | Sí       | Sí                                         | Sí                                                          | Sí      | SaaS                  | Cobertura unificada y adopción rápida para incidentes en alta carga datadoghq+1                         | Coste crece con ingestión, hosts, logs y APM; riesgo de lock-in datadoghq+1               | Alto costo relativo, baja fricción inicial datadoghq+1                  |
| OpenSearch               | Open-source / servicio administrado | Sí       | Sí                                         | Sí, con capacidades de análisis de trazas docs.aws.amazon+1 | Sí      | Self-hosted o managed | Muy útil para correlacionar logs, métricas y trazas en investigación de incidentes docs.aws.amazon+1    | Requiere tuning, retención e indexación cuidadosa; operación más pesada docs.aws.amazon+1 | Costo de licencia bajo o nulo; complejidad media-alta docs.aws.amazon+1 |
| Grafana Cloud            | SaaS / managed                      | Sí       | Sí, con Loki                               | Sí, con Tempo y OpenTelemetry grafana                       | Sí      | Managed               | Buen balance entre stack abierto y operación reducida; integración natural con OpenTelemetry grafana    | Puede crecer en costo según volumen y retención; menos control que self-hosted grafana    | Costo moderado a alto según escala grafana                              |
| New Relic                | SaaS comercial                      | Sí       | Sí                                         | Sí                                                          | Sí      | SaaS                  | Plataforma completa para observabilidad de aplicaciones, útil para equipos que buscan rapidez gartner+1 | Dependencia del proveedor y costos de uso a escala                                        | Complejidad baja-media, costo comercial gartner+1                       |
| Dynatrace                | SaaS comercial                      | Sí       | Sí                                         | Sí                                                          | Sí      | SaaS / híbrido        | Muy fuerte en automatización, APM y detección de anomalías gartner+1                                    | Precio y curva de adopción pueden ser altos para equipos pequeños                         | Complejidad baja operativa, costo alto gartner+1                        |
| Elastic Observability    | Open-source / comercial             | Sí       | Sí                                         | Sí                                                          | Sí      | Self-hosted o cloud   | Buena para stacks que ya usan Elastic y necesitan búsqueda potente g2                                   | Puede requerir tuning y gestión de índices a escala                                       | Costo variable; complejidad media-alta g2                               |
| Google Cloud Operations  | Managed / cloud-native              | Sí       | Sí                                         | Sí                                                          | Sí      | Managed               | Encaja muy bien si toda la plataforma vive en GCP g2                                                    | Menos conveniente si el entorno es multicloud o híbrido                                   | Complejidad baja dentro de GCP, costo por consumo g2                    |
| Coralogix                | SaaS comercial                      | Sí       | Sí                                         | Sí                                                          | Sí      | SaaS                  | Fuerte en análisis de logs y telemetría a escala g2                                                     | Menos control que un stack abierto; dependencia del proveedor g2                          | Costo comercial, operación simple g2                                    |

Para FlashSale Inc., **Prometheus + Grafana** constituye la alternativa más equilibrada debido a su amplia adopción en arquitecturas cloud-native, su integración nativa con Kubernetes y OpenTelemetry, y su bajo costo de adopción. **Datadog** resulta una excelente opción cuando se prioriza la rapidez de implementación y una plataforma completamente administrada, mientras que **Amazon OpenSearch Service** ofrece una solución flexible para organizaciones que desean centralizar la observabilidad manteniendo un mayor control sobre la infraestructura.
