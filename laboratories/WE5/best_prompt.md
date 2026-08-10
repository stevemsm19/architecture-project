**Fecha/hora:** 4 de agosto de 2026  
**Herramienta y versión:** ChatGPT GPT-5.5  
**Prompt para los hitos:** 

Actúa como un **investigador senior en Arquitectura de Software y Sistemas Distribuidos**, con experiencia en Arquitectura de Microservicios, principios SOLID, resiliencia y diseño de sistemas distribuidos.

Necesito realizar una investigación técnica sobre una serie de conceptos fundamentales relacionados con la **Arquitectura de Microservicios**.

El objetivo no es obtener definiciones rápidas ni una explicación introductoria. Quiero construir una base conceptual suficientemente sólida para posteriormente utilizar estos conceptos en el análisis crítico de una arquitectura de software.

La investigación debe priorizar **comprensión, relaciones entre conceptos, implicaciones arquitectónicas y trade-offs**.

## Conceptos a investigar

### 1. Principio de Responsabilidad Única (SRP)

Investiga el **Single Responsibility Principle** y su origen dentro de los principios SOLID.

Explica:

* Qué establece realmente SRP.
* Qué significa la expresión "una única razón para cambiar".
* Diferencia entre responsabilidad técnica y responsabilidad de negocio.
* Cómo se aplica originalmente a clases y módulos.
* Cómo puede trasladarse el razonamiento de SRP hacia componentes y servicios.
* Relación entre SRP, cohesión y separación de responsabilidades.
* Cómo puede ayudar SRP a determinar límites entre servicios.
* Qué ocurre cuando un servicio concentra demasiadas responsabilidades.
* Qué ocurre cuando se lleva SRP al extremo y se crean servicios excesivamente pequeños.

Aclara especialmente si **SRP puede aplicarse directamente a microservicios o si se trata de una adaptación conceptual del principio original**.

---

### 2. Acoplamiento débil vs. acoplamiento fuerte

Investiga qué significa **coupling** en arquitectura de software.

Explica:

* Tight Coupling.
* Loose Coupling.
* Dependencias entre componentes.
* Acoplamiento temporal.
* Acoplamiento de implementación.
* Acoplamiento mediante datos.
* Acoplamiento mediante contratos.
* Acoplamiento causado por bases de datos compartidas.

Analiza por qué reducir el acoplamiento es especialmente importante en sistemas distribuidos.

Explica también:

* Cómo una dependencia puede propagar una falla.
* Qué es una falla en cascada.
* Qué significa blast radius.
* Cómo el acoplamiento afecta la capacidad de modificar, desplegar y escalar servicios independientemente.

Aclara una cuestión importante:

**¿Tener microservicios garantiza realmente bajo acoplamiento?**

Explica ejemplos donde una arquitectura aparentemente basada en microservicios puede seguir estando fuertemente acoplada.

---

### 3. APIs como contratos estables

Investiga qué significa afirmar que:

**"Las APIs entre microservicios deben actuar como contratos estables."**

No limites API únicamente a REST.

Explica:

* Qué significa un contrato entre servicios.
* Qué partes forman parte del contrato.
* Sintaxis vs. semántica del contrato.
* Requests y responses.
* Tipos y estructuras de datos.
* Códigos de error.
* Comportamiento esperado.
* Compatibilidad hacia atrás.
* Versionado.
* Evolución de contratos.

Investiga conceptos relacionados como:

* API First.
* OpenAPI.
* Consumer-Driven Contracts.
* Contract Testing.
* Schema Evolution.

Explica cómo cambios aparentemente pequeños pueden romper consumidores de un servicio.

Incluye ejemplos concretos de:

* un cambio compatible;
* un cambio incompatible.

Analiza además qué relación existe entre **contratos estables, bajo acoplamiento y despliegue independiente de servicios**.

---

### 4. Comunicación síncrona vs. asíncrona entre servicios

Investiga ambas formas de comunicación específicamente dentro de **sistemas distribuidos y microservicios**.

#### Comunicación síncrona

Investiga tecnologías o mecanismos como:

* HTTP/REST.
* gRPC.

Explica:

* Request/Response.
* Dependencia temporal.
* Latencia.
* Timeouts.
* Retries.
* Disponibilidad.
* Propagación de fallas.

#### Comunicación asíncrona

Investiga:

* Message Queues.
* Message Brokers.
* Events.
* Publish/Subscribe.
* Event-Driven Architecture.

Explica conceptos importantes como:

* Eventual Consistency.
* Idempotencia.
* Duplicación de mensajes.
* Orden de mensajes.
* Delivery Guarantees.
* Retry.
* Dead Letter Queue.

No conviertas esta sección en una investigación sobre Kafka, RabbitMQ u otras herramientas. Las tecnologías pueden mencionarse como ejemplos, pero el objetivo es comprender **los principios arquitectónicos**.

Compara comunicación síncrona y asíncrona respecto a:

* acoplamiento temporal;
* latencia;
* disponibilidad;
* resiliencia;
* manejo de errores;
* consistencia;
* escalabilidad;
* complejidad operacional.

Explica cuándo resulta razonable utilizar cada enfoque y por qué.

Evita concluir que la comunicación asíncrona es inherentemente superior.

---

### 5. Gestión descentralizada de datos

Investiga qué significa **Decentralized Data Management** dentro de una arquitectura de microservicios.

Explica:

* Data Ownership.
* Database per Service.
* Encapsulamiento de datos.
* Bases de datos compartidas.
* Independencia entre servicios.

Aclara especialmente:

**¿"Database per Service" significa necesariamente tener un servidor o instancia física de base de datos diferente para cada microservicio?**

Diferencia entre:

* instancia de base de datos;
* database;
* schema;
* tablas;
* ownership lógico de los datos.

Explica por qué permitir que varios servicios modifiquen directamente las mismas tablas puede generar acoplamiento.

Analiza los problemas que aparecen al descentralizar los datos:

* consistencia eventual;
* duplicación de información;
* consultas entre servicios;
* transacciones distribuidas;
* integridad referencial;
* sincronización;
* reporting.

Introduce brevemente patrones relacionados cuando sean necesarios para comprender estos problemas:

* Saga Pattern.
* Transactional Outbox.
* CQRS.

No profundices innecesariamente en su implementación.

---

### 6. Relación entre SRP y gestión descentralizada de datos

Investiga específicamente la relación conceptual entre:

**Responsabilidad → límites del servicio → ownership de datos**

Quiero comprender:

* Cómo las responsabilidades de negocio ayudan a definir los datos que debería controlar un servicio.
* Por qué el ownership de datos ayuda a preservar los límites entre servicios.
* Cómo una base de datos compartida puede debilitar esos límites.
* Relación entre encapsulamiento, cohesión y ownership.
* Diferencia entre separación lógica y separación física de los datos.

Analiza críticamente si es correcto afirmar:

**"Cada microservicio debe tener su propia base de datos."**

Explica qué parte de esa afirmación es correcta, qué parte puede ser una simplificación y cuál es realmente el principio arquitectónico que se intenta proteger.

---

### 7. Aislamiento de fallas

Investiga qué significa **Fault Isolation** en sistemas distribuidos.

Explica:

* Qué se considera una falla.
* Cómo las fallas pueden propagarse entre servicios.
* Cascading Failures.
* Blast Radius.
* Partial Failure.
* Graceful Degradation.

Investiga mecanismos utilizados para limitar la propagación de fallas:

* Timeouts.
* Retries.
* Circuit Breaker.
* Bulkhead Pattern.
* Rate Limiting.
* Health Checks.

Para cada mecanismo explica:

1. qué problema intenta solucionar;
2. cómo funciona conceptualmente;
3. qué relación tiene con el aislamiento de fallas;
4. qué riesgos introduce si se utiliza incorrectamente.

Presta especial atención a combinaciones peligrosas, por ejemplo:

**Retries + servicio degradado → aumento de carga → falla en cascada.**

---

### 8. FDIR

Investiga en profundidad:

**FDIR — Fault Detection, Isolation and Recovery**

Quiero comprender primero su origen y alcance.

Explica:

* Qué es FDIR.
* De dónde surge el concepto.
* En qué tipos de sistemas se utiliza.
* Si FDIR es un concepto propio de microservicios o un principio general de sistemas tolerantes a fallos.
* Cómo puede trasladarse a arquitecturas distribuidas modernas.

Analiza sus tres etapas:

#### Fault Detection

¿Cómo se detecta que algo está funcionando incorrectamente?

Relaciona con:

* métricas;
* logs;
* distributed tracing;
* health checks;
* alertas;
* observabilidad.

#### Fault Isolation

¿Cómo se determina dónde está ocurriendo una falla y cómo se evita su propagación?

Relaciona con:

* dependencias;
* tracing;
* circuit breakers;
* bulkheads;
* aislamiento de recursos.

#### Fault Recovery

¿Cómo puede recuperarse un sistema después de una falla?

Relaciona con:

* retries;
* restart;
* failover;
* redundancy;
* rollback;
* autoscaling;
* compensating actions;
* message replay.

Incluye al menos un ejemplo conceptual completo siguiendo:

**Detection → Isolation → Recovery**

---

## Relaciones entre conceptos

Después de investigar cada concepto individualmente, analiza cómo se relacionan entre sí.

En particular investiga relaciones como:

**SRP → cohesión → límites de servicios**

**Límites de servicios → ownership de datos**

**Ownership de datos → menor acoplamiento**

**Acoplamiento → propagación de fallas**

**Comunicación síncrona → acoplamiento temporal**

**Comunicación asíncrona → desacoplamiento temporal**

**Contratos estables → evolución independiente**

**Fault Isolation → reducción del blast radius**

**Observabilidad → Detection → Isolation → Recovery**

No asumas que estas relaciones son automáticamente correctas. **Valídalas, matízalas o corrígelas según la literatura consultada.**

---

## Nivel de profundidad

Quiero una investigación de nivel **universitario avanzado / profesional**, pero explicada de forma clara.

Evita definiciones circulares o excesivamente abstractas.

Para cada concepto intenta responder:

**¿Qué es? → ¿Por qué existe? → ¿Qué problema resuelve? → ¿Cómo funciona? → ¿Qué relación tiene con microservicios? → ¿Qué trade-offs introduce?**

Utiliza ejemplos técnicos sencillos cuando ayuden a comprender una idea.

No diseñes ninguna arquitectura concreta ni propongas una migración.

---

## Pensamiento crítico

No presentes las prácticas de microservicios como reglas absolutas.

Distingue entre:

* principio;
* patrón;
* buena práctica;
* decisión contextual.

Cuestiona afirmaciones simplificadas como:

* "Microservicios significa bajo acoplamiento."
* "Cada microservicio necesita una base de datos física independiente."
* "La comunicación asíncrona siempre es mejor."
* "REST desacopla automáticamente los servicios."
* "Retries aumentan siempre la resiliencia."
* "SRP significa que un servicio solo puede hacer una cosa."

Cuando una afirmación dependa del contexto, explica **de qué depende**.

---

## Fuentes

Utiliza fuentes técnicas confiables y reconocidas.

Prioriza:

1. documentación oficial;
2. libros reconocidos de arquitectura de software;
3. autores reconocidos;
4. documentación de proveedores cloud;
5. papers académicos cuando aporten valor.

Busca especialmente fuentes de:

* Martin Fowler.
* Sam Newman.
* Robert C. Martin.
* Microsoft Architecture Center.
* AWS Architecture Center.
* Google Cloud Architecture Framework.
* Red Hat.
* CNCF.

No dependas principalmente de blogs genéricos, Medium o artículos SEO.

Incluye las fuentes y enlaces utilizados en cada sección.

Cuando existan diferentes interpretaciones de un concepto, compáralas en lugar de presentar una como verdad absoluta.

---

## Formato esperado

Organiza la investigación por conceptos.

Para cada uno utiliza una estructura similar a:

**Definición**

**Fundamento y origen**

**Problema arquitectónico que intenta resolver**

**Relación con microservicios**

**Ejemplo técnico**

**Trade-offs y limitaciones**

**Errores comunes de interpretación**

**Relación con los demás conceptos investigados**

**Fuentes**

Al finalizar, incluye una **síntesis conceptual** que explique cómo todos estos principios contribuyen —o no— a objetivos como:

* independencia entre servicios;
* bajo acoplamiento;
* alta cohesión;
* resiliencia;
* aislamiento de fallas;
* escalabilidad independiente;
* evolución independiente.

El objetivo final no es memorizar conceptos, sino **comprenderlos suficientemente bien para utilizarlos posteriormente como criterios de análisis y toma de decisiones arquitectónicas**.
