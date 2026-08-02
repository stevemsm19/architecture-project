
# ROL

Actúa como un Arquitecto de Software Senior y Especialista en Sistemas Distribuidos, con experiencia en arquitecturas Event-Driven, procesamiento de streams de alta velocidad, Apache Kafka, Apache Flink, Redis, CQRS y estrategias de Backpressure.

Tu responsabilidad no es aceptar automáticamente mis decisiones. Debes colaborar conmigo para construir y cuestionar la arquitectura, señalar debilidades, identificar riesgos y proponer mejoras cuando sean necesarias.

# CONTEXTO

Estoy desarrollando el Hito 2: "Síntesis y Creación de Entregables" para el siguiente escenario:

“GlobalNewsFeed”, una plataforma de redes sociales, necesita crear una nueva funcionalidad de “Análisis de Hashtags en Tendencia”, que implica procesar un flujo de alta velocidad de publicaciones para identificar y clasificar hashtags en tendencia en tiempo real.

El componente central es un Proceso de Larga Duración (PLD) que consume continuamente un flujo de publicaciones. El servicio de ingesta puede producir datos más rápido de lo que el servicio de análisis puede procesarlos, especialmente durante eventos globales importantes.

El principal problema arquitectónico es, por lo tanto, gestionar la CONTRAPRESIÓN (Backpressure) y evitar que los picos de tráfico provoquen acumulación descontrolada de eventos, agotamiento de recursos, aumento excesivo de latencia o fallos en cascada.

# CONCEPTOS DEL HITO 1

La propuesta debe partir principalmente de los conceptos estudiados previamente:

- Procesos de Larga Duración (PLD).
- Backpressure.
- Buffering.
- Message Brokers y colas.
- Procesadores de flujos.
- Arquitectura Dirigida por Eventos (EDA).
- Escalado horizontal.
- Load Shedding.
- Rate Limiting.
- Circuit Breaker.
- Monitoreo y alertas.
- CQRS.
- Procesamiento asíncrono.
- Idempotencia y tolerancia a fallos.

No es obligatorio utilizar todos estos conceptos. Selecciona únicamente aquellos que realmente aporten valor al escenario.

# IDEAS ARQUITECTÓNICAS QUE ESTAMOS EVALUANDO

Hasta ahora he considerado una arquitectura basada principalmente en:

Servicio de Ingesta
        ↓
Apache Kafka
        ↓
Motor de procesamiento de streams / PLD
        ↓
Resultados de tendencias
        ↓
Redis / almacenamiento
        ↓
API de Tendencias
        ↓
Usuarios

Estoy considerando seriamente Apache Flink como motor del PLD porque el problema no consiste únicamente en consumir mensajes. El sistema necesita realizar procesamiento continuo y stateful sobre grandes flujos de publicaciones, por ejemplo:

- extraer hashtags;
- mantener conteos;
- calcular tendencias;
- detectar hashtags que aumentan rápidamente de popularidad;
- trabajar con ventanas temporales (por ejemplo 5, 15 o 60 minutos);
- manejar eventos que puedan llegar fuera de orden;
- utilizar Watermarks cuando corresponda;
- actualizar resultados de tendencias en Redis u otro almacenamiento optimizado para consultas rápidas.

Kafka podría actuar como buffer durable entre la ingesta y el procesamiento, mientras que Flink podría realizar el procesamiento distribuido y controlar el flujo de datos.

IMPORTANTE: estas son hipótesis de diseño, no decisiones incuestionables. Analiza críticamente si Kafka + Flink realmente es adecuado y señala cualquier componente innecesario o alternativa más sencilla cuando corresponda.

# OBJETIVO

Ayúdame a desarrollar el:

HITO 2: SÍNTESIS Y CREACIÓN DE ENTREGABLES

Quiero construir la solución progresivamente y entender las decisiones arquitectónicas antes de redactar el entregable definitivo.

No generes simplemente una arquitectura final sin cuestionarla.

---

# 2.1 SELECCIÓN DE UNA ESTRATEGIA

Primero, identifica cuál debería ser la ESTRATEGIA PRINCIPAL para manejar la contrapresión.

Diferencia claramente entre:

1. Estrategia principal.
2. Tecnologías utilizadas para implementarla.
3. Estrategias complementarias.

Por ejemplo, no quiero que simplemente digas "usar Kafka", porque Kafka es una tecnología. Quiero identificar el enfoque arquitectónico que estamos aplicando.

Analiza especialmente la combinación de:

- buffering durable;
- procesamiento de streams;
- escalado horizontal;
- control de flujo/backpressure;
- monitoreo;
- Load Shedding como mecanismo de último recurso.

Explica:

- por qué la estrategia elegida es adecuada para GlobalNewsFeed;
- cómo responde cuando la ingesta produce más rápido de lo que se puede procesar;
- qué problemas resuelve;
- qué problemas NO resuelve;
- qué trade-offs introduce.

Evita presentar el escalado horizontal como una solución infinita. Considera qué sucede cuando el tráfico supera incluso la capacidad máxima de escalado.

---

# 2.2 DISEÑO DE LA ARQUITECTURA

Una vez establecida la estrategia, ayúdame a diseñar la arquitectura.

Identifica claramente los componentes principales y la responsabilidad de cada uno.

Como mínimo analiza si necesitamos:

- Usuarios / productores.
- Servicio de Ingesta.
- Kafka.
- Topics y particiones.
- Apache Flink.
- Workers/Task Managers de Flink.
- Estado del procesamiento.
- Redis.
- API de Tendencias.
- Almacenamiento persistente si fuera necesario.
- Monitoreo y observabilidad.
- CQRS, únicamente si aporta valor real.

Para cada componente explica POR QUÉ existe. Evita agregar componentes solamente porque son comunes en arquitecturas modernas.

Después describe el flujo end-to-end:

Publicación
→ Ingesta
→ Buffer
→ Procesamiento
→ Cálculo de tendencias
→ Persistencia
→ Consulta.

---

# BACKPRESSURE: PARTE MÁS IMPORTANTE

Identifica explícitamente TODOS los puntos donde puede aparecer contrapresión.

No quiero únicamente:

"Kafka maneja el backpressure".

Quiero analizar el flujo completo.

Por ejemplo:

Ingesta → Kafka
Kafka → Flink
Dentro del pipeline de Flink
Flink → Redis / almacenamiento

Para cada punto explica:

- qué componente produce;
- qué componente consume;
- qué ocurre cuando el consumidor se vuelve más lento;
- cómo se detecta;
- qué mecanismo evita el agotamiento de recursos;
- qué sucede si el problema continúa durante varios minutos;
- qué sucede si continúa durante horas.

Diferencia claramente entre:

DETECCIÓN del backpressure
y
MITIGACIÓN del backpressure.

Por ejemplo, Consumer Lag es una señal de que existe retraso, pero por sí mismo no resuelve el problema.

---

# FLINK Y PROCESAMIENTO DE STREAMS

Analiza específicamente si Apache Flink es adecuado para implementar el PLD.

Si lo propones, explica de manera intuitiva:

- cómo consume eventos desde Kafka;
- cómo distribuye el procesamiento;
- qué significa procesamiento stateful;
- cómo utilizar ventanas temporales para calcular tendencias;
- qué papel cumplen los Watermarks;
- cómo manejar eventos tardíos o fuera de orden;
- cómo escala horizontalmente;
- cómo maneja internamente el backpressure;
- cómo se recuperaría ante fallos.

No profundices innecesariamente en configuraciones específicas de bajo nivel salvo que sean necesarias para justificar una decisión arquitectónica.

---

# ESTRATEGIA DE DEGRADACIÓN

La arquitectura debe explicar qué ocurre cuando la demanda supera la capacidad disponible.

Analiza una estrategia progresiva similar a:

Carga normal
    ↓
Buffering
    ↓
Aumento del Consumer Lag
    ↓
Escalado horizontal
    ↓
Persistencia del problema
    ↓
Degradación controlada
    ↓
Load Shedding

No asumas que agregar servidores siempre resolverá el problema.

Evalúa posibles mecanismos de degradación, como:

- sampling de publicaciones;
- descarte de eventos demasiado antiguos;
- priorización;
- reducción temporal de precisión;
- reducción de frecuencia de actualización de tendencias.

Indica claramente qué información se sacrifica y qué se conserva.

La prioridad debería ser mantener disponible la plataforma y conservar tendencias suficientemente frescas y útiles.

---

# MONITOREO

Define las métricas necesarias para detectar que el sistema se está acercando a sus límites.

Como mínimo considera:

- Consumer Lag.
- Throughput de entrada.
- Throughput de procesamiento.
- Latencia end-to-end.
- Utilización de CPU/memoria.
- Saturación de Kafka.
- Backpressure dentro del procesamiento.
- Latencia de Redis o almacenamiento.
- Tasa de eventos descartados.

No quiero solamente una lista de métricas.

Relaciona:

Métrica → problema detectado → acción.

---

# DIAGRAMAS

Cuando la arquitectura esté suficientemente definida, genera:

1. Un diagrama C4 Nivel 2 (Contenedores) en Mermaid o PlantUML.
2. Un diagrama adicional que muestre específicamente los puntos de contrapresión.
3. Si aporta valor, un diagrama de secuencia mostrando qué ocurre durante un pico extremo de tráfico.

Los diagramas deben representar las decisiones que realmente hayamos tomado y no introducir componentes nuevos sin explicación.

---

# FORMA DE TRABAJO

No quiero que generes todo el Hito 2 inmediatamente.

Trabajaremos de manera iterativa.

En cada etapa:

1. Propón una decisión.
2. Explícala.
3. Justifícala.
4. Identifica sus debilidades.
5. Presenta alternativas si existen.
6. Hazme preguntas únicamente cuando exista una decisión arquitectónica relevante que necesite mi aprobación.

Prioriza siempre una arquitectura coherente sobre una arquitectura innecesariamente compleja.

El resultado final debe poder defenderse técnicamente explicando no solo "qué tecnologías usamos", sino principalmente:

POR QUÉ las usamos,
QUÉ problema resuelve cada una,
DÓNDE ocurre la contrapresión,
CÓMO reaccionamos ante ella,
y QUÉ hacemos cuando la capacidad máxima del sistema es superada.`