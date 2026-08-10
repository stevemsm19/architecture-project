# Investigación técnica: Microservicios y principios arquitectónicos

## 1) Single Responsibility Principle (SRP)

### Definición
El SRP dice, en su formulación clásica, que un módulo o clase debe tener **una sola responsabilidad**; Robert C. Martin lo expresó también como “una única razón para cambiar”. En la práctica, esto no significa “hacer una sola cosa” en sentido literal, sino **tener una sola fuente principal de cambio** asociada a un actor o preocupación coherente. [learn.microsoft](https://learn.microsoft.com/es-es/dotnet/architecture/microservices/microservice-ddd-cqrs-patterns/microservice-application-layer-web-api-design)

### Fundamento y origen
SRP forma parte de SOLID y nació en el contexto del diseño de clases y módulos, no como un principio específico de microservicios. Su intención original es reducir el impacto del cambio: si una clase responde a varias presiones de cambio distintas, se vuelve más frágil, menos cohesionada y más difícil de mantener. [learn.microsoft](https://learn.microsoft.com/es-es/dotnet/architecture/microservices/microservice-ddd-cqrs-patterns/microservice-application-layer-web-api-design)

### Qué significa “una única razón para cambiar”
La expresión es más precisa que “una única función”. Una clase puede tener varios métodos, pero si todos sirven a la misma preocupación estable, el cambio esperado proviene de un mismo eje. Por ejemplo, un módulo que calcula impuestos y además formatea facturas tiene dos razones de cambio distintas: reglas fiscales y formato de salida.

### Responsabilidad técnica vs. responsabilidad de negocio
Aquí está una distinción clave:  
- **Responsabilidad técnica**: persistencia, logging, serialización, envío de emails, caché, etc.  
- **Responsabilidad de negocio**: gestionar pedidos, facturación, pagos, inventario, suscripciones.  

SRP funciona mejor cuando la responsabilidad se interpreta en términos de **actor o motivo de cambio**. Un mismo servicio de negocio puede contener varias preocupaciones técnicas, pero si estas se mezclan con responsabilidades de negocio no relacionadas, aparece un acoplamiento conceptual peligroso. [learn.microsoft](https://learn.microsoft.com/es-es/dotnet/architecture/microservices/microservice-ddd-cqrs-patterns/microservice-application-layer-web-api-design)

### Aplicación original a clases y módulos
En su origen, SRP guía la descomposición de código dentro de una aplicación. Ayuda a mejorar cohesión, testabilidad y mantenibilidad porque concentra cada unidad en un conjunto más homogéneo de cambios.

### Traslado a componentes y servicios
En microservicios, SRP no se aplica de forma literal a “una clase”, sino como **razonamiento de partición**: un servicio debería alinearse con una capacidad de negocio relativamente coherente y con un patrón estable de cambio. Esta es una **adaptación conceptual**, no una traslación mecánica. Un microservicio puede tener varias clases, procesos y endpoints; lo importante es que su frontera no mezcle motivos de cambio incompatibles. [learn.microsoft](https://learn.microsoft.com/es-es/azure/architecture/guide/architecture-styles/microservices)

### Relación entre SRP, cohesión y separación de responsabilidades
SRP se relaciona fuertemente con **alta cohesión**: las cosas que cambian juntas deben permanecer juntas. Cuando un módulo o servicio tiene una sola responsabilidad dominante, sus elementos internos tienden a ser más cohesionados, y la frontera externa se vuelve más clara. Esto no implica que “más pequeño siempre sea mejor”; cohesión alta importa más que tamaño mínimo.

### Cómo ayuda SRP a determinar límites entre servicios
SRP puede ser una pista para separar servicios cuando detectas responsabilidades que cambian por razones distintas, tienen distintos stakeholders o ciclos de evolución independientes. Por ejemplo, “gestión de pedidos” y “notificaciones” suelen tener ritmos de cambio distintos, y forzarlos en un mismo servicio aumenta el acoplamiento.

### Qué ocurre si un servicio concentra demasiadas responsabilidades
Aparece un “servicio dios”: cambios aparentemente locales impactan múltiples capacidades, los despliegues se vuelven más riesgosos y los equipos pierden autonomía. Además, la propia API tiende a crecer de forma desordenada porque intenta servir a muchas necesidades a la vez.

### Qué ocurre si SRP se lleva al extremo
Si se fragmenta demasiado, surgen servicios microscópicos con coordinación excesiva, demasiadas llamadas remotas y complejidad operacional innecesaria. En ese caso, se reemplaza complejidad interna por complejidad distribuida, y el sistema puede empeorar en latencia, observabilidad y tolerancia a fallos.

### ¿SRP se aplica directamente a microservicios?
No de forma directa y literal. En microservicios, SRP funciona como **principio orientador para delimitar capacidades y razones de cambio**, pero la unidad de diseño ya no es la clase sino el servicio como frontera de despliegue, contrato y ownership. Es una analogía útil, pero no una equivalencia estricta.

### Ejemplo técnico
Un servicio de “Checkout” que además calcula descuentos, envía emails, registra auditoría y orquesta integración con logística mezcla motivaciones distintas. Si las reglas de descuentos cambian por marketing, los correos por producto, y la auditoría por compliance, el cambio afecta a toda la unidad. Una mejor separación puede ser: checkout, pricing, notifications y audit, siempre que haya justificación arquitectónica real.

### Trade-offs y limitaciones
SRP mejora mantenibilidad, pero puede fragmentar demasiado si se interpreta dogmáticamente. La decisión correcta depende de la estabilidad de las responsabilidades, el costo de coordinación y el grado de independencia requerido.

### Errores comunes
- “SRP significa una sola función por clase.”  
- “Cada microservicio debe hacer una sola cosa muy pequeña.”  
- “SRP equivale a separar por técnica.”  
- “Cuanto más pequeño, mejor.”  

### Relación con los demás conceptos
SRP ayuda a **definir límites**, y esos límites influyen en **ownership de datos**, **cohesión**, **contratos** y **aislamiento de fallas**. La relación es indirecta pero muy importante: buenas fronteras funcionales facilitan buenas fronteras técnicas. [learn.microsoft](https://learn.microsoft.com/es-es/dotnet/architecture/microservices/microservice-ddd-cqrs-patterns/microservice-application-layer-web-api-design)

### Fuentes
- Robert C. Martin / SOLID, citado y resumido en fuentes técnicas de referencia. [en.wikipedia](https://en.wikipedia.org/wiki/Single-responsibility_principle)
- Microsoft/Azure sobre microservicios, cohesión y acoplamiento flexible. [learn.microsoft](https://learn.microsoft.com/es-es/azure/architecture/guide/architecture-styles/microservices)
- Discusión sobre SRP en contexto de microservicios y diseño de capas. [learn.microsoft](https://learn.microsoft.com/es-es/dotnet/architecture/microservices/microservice-ddd-cqrs-patterns/microservice-application-layer-web-api-design)

***

## 2) Acoplamiento débil vs. fuerte

### Definición
**Coupling** es el grado de dependencia entre componentes. Si cambiar uno obliga a cambiar otro, o si una falla se propaga fácilmente, hay acoplamiento alto. Si cada componente puede evolucionar con menos impacto en los demás, el acoplamiento es más bajo. [learn.microsoft](https://learn.microsoft.com/es-es/azure/architecture/guide/architecture-styles/microservices)

### Tight coupling y loose coupling
- **Tight coupling**: dependencias rígidas, detalles compartidos, contratos frágiles, despliegues coordinados.  
- **Loose coupling**: interacción acotada por contratos claros, menor dependencia de detalles internos y mayor autonomía de cambio. [learn.microsoft](https://learn.microsoft.com/es-es/azure/architecture/guide/architecture-styles/microservices)

### Tipos relevantes de acoplamiento
- **Dependencias entre componentes**: una función o servicio necesita conocer internals de otro.  
- **Acoplamiento temporal**: ambos deben estar disponibles al mismo tiempo para que la interacción funcione.  
- **Acoplamiento de implementación**: el consumidor depende de detalles internos del proveedor, no solo de su contrato.  
- **Acoplamiento mediante datos**: estructuras compartidas, modelos globales o formatos rígidos fuerzan cambios coordinados.  
- **Acoplamiento mediante contratos**: el cliente depende del esquema, errores y semántica del proveedor; esto no es malo en sí, pero debe ser explícito y estable.  
- **Bases de datos compartidas**: varios servicios leen y escriben las mismas tablas; esto crea fuerte acoplamiento de esquema, despliegue y gobernanza. [aichat.physics.ucla](https://aichat.physics.ucla.edu/filedownload.ashx/virtual-library/48a55V/Building%20Microservices%20Sam%20Newman.pdf)

### Por qué es crítico en sistemas distribuidos
En sistemas distribuidos, el acoplamiento ya no solo afecta el código: afecta latencia, disponibilidad, tolerancia a fallas y operación. Una dependencia remota puede fallar por red, timeouts, saturación o inconsistencia, y esa falla puede propagarse rápidamente.

### Propagación de fallas y cascadas
Una dependencia puede propagar una falla cuando un servicio aguas arriba espera una respuesta inmediata del servicio aguas abajo. Si este último se degrada, el primero acumula timeouts, reintentos y colas, elevando la carga hasta generar **cascading failure**: una falla que arrastra a otras partes del sistema.

### Blast radius
El **blast radius** es el alcance del daño cuando algo falla. Cuanto más acoplado está un sistema, mayor suele ser el radio de impacto, porque una incidencia local puede bloquear más flujos, más usuarios o más servicios.

### Impacto en cambio, despliegue y escala
- **Modificar**: un contrato frágil obliga a coordinar cambios entre equipos.  
- **Desplegar**: servicios acoplados tienden a desplegarse juntos o con fuerte sincronización.  
- **Escalar**: si el cuello de botella está en una dependencia compartida, escalar un servicio no resuelve el problema sistémico.

### ¿Microservicios garantizan bajo acoplamiento?
No. Puedes tener muchos microservicios y seguir con acoplamiento fuerte si comparten base de datos, modelos de datos, ciclos de despliegue o lógica centralizada. La fragmentación física no garantiza autonomía real. [learn.microsoft](https://learn.microsoft.com/es-es/azure/architecture/guide/architecture-styles/microservices)

### Ejemplos de microservicios fuertemente acoplados
- Varios servicios escriben en las mismas tablas.  
- Un servicio expone internals que otros consumen “directamente” mediante consultas o integración informal.  
- Los despliegues deben hacerse en orden estricto porque todos dependen de un contrato inestable.  
- Existe dependencia síncrona en cadena para operaciones críticas, de modo que una caída pequeña afecta todo el flujo.

### Trade-offs
Reducir acoplamiento mejora autonomía, pero puede introducir más contratos, más procesos asíncronos y más complejidad operativa. No siempre conviene minimizar acoplamiento al máximo: hay acoplamientos aceptables y baratos, especialmente dentro de un contexto pequeño y estable.

### Fuentes
- Sam Newman sobre coupling, cohesión y microservices-style. [youtube](https://www.youtube.com/watch?v=6USNEwkag7I)
- Azure Architecture Center sobre autonomía, cohesión y fault isolation. [learn.microsoft](https://learn.microsoft.com/es-es/azure/architecture/guide/architecture-styles/microservices)
- Referencias sobre bases de datos compartidas y autonomía. [aichat.physics.ucla](https://aichat.physics.ucla.edu/filedownload.ashx/virtual-library/48a55V/Building%20Microservices%20Sam%20Newman.pdf)

***

## 3) APIs como contratos estables

### Definición
Decir que “las APIs entre microservicios deben actuar como contratos estables” significa que la interacción entre servicios debe tratarse como un acuerdo explícito, versionable y evolutivo. La API no es solo un mecanismo técnico; define qué espera el consumidor y qué promete el proveedor. [martinfowler](https://martinfowler.com/articles/consumerDrivenContracts.html)

### Qué es el contrato
El contrato incluye:  
- operaciones disponibles;  
- request y response;  
- tipos, campos y restricciones;  
- códigos de error;  
- semántica del comportamiento;  
- reglas de compatibilidad;  
- políticas de versión y evolución.

### Sintaxis vs. semántica
- **Sintaxis**: forma del mensaje, nombres de campos, tipos, estructura.  
- **Semántica**: qué significa el mensaje y qué garantiza el sistema.  

Un cambio puede ser sintácticamente compatible y semánticamente romper consumidores, o viceversa.

### No limitar API a REST
El concepto aplica a REST, gRPC, mensajería, eventos y otros mecanismos. En todos los casos hay un acuerdo sobre estructura, significado y comportamiento. REST solo es una de las formas posibles de exponer ese contrato. [martinfowler](https://martinfowler.com/articles/enterpriseREST.html)

### API First, OpenAPI, CDC y Contract Testing
- **API First**: diseñar el contrato antes de implementar, para alinear consumidores y proveedor.  
- **OpenAPI**: describe formalmente APIs HTTP, útil para documentación, validación y generación.  
- **Consumer-Driven Contracts**: los consumidores expresan lo que necesitan; el proveedor verifica que lo cumple. [martinfowler](https://martinfowler.com/articles/consumerDrivenContracts.html)
- **Contract Testing**: prueba la compatibilidad del contrato sin depender de una integración completa.  
- **Schema Evolution**: evolución controlada de esquemas con reglas de compatibilidad hacia atrás y hacia delante.

### Cómo cambios pequeños rompen consumidores
Un “pequeño” cambio como renombrar un campo, convertir un valor opcional en obligatorio, alterar un código de error o cambiar el significado de un estado puede romper clientes que dependían de ese comportamiento. Lo pequeño desde el punto de vista del proveedor puede ser grande desde el punto de vista del consumidor. [martinfowler](https://martinfowler.com/articles/consumerDrivenContracts.html)

### Ejemplo compatible
Agregar un campo opcional nuevo a una respuesta, manteniendo los anteriores y el comportamiento existente. Si el consumidor ignora el campo, no se rompe la integración.

### Ejemplo incompatible
Eliminar un campo usado por consumidores, cambiar el tipo de un atributo o modificar la semántica de un estado sin versionado ni transición. Eso puede causar fallos inmediatos o errores lógicos silenciosos.

### Relación con bajo acoplamiento e independencia de despliegue
Contratos estables reducen el acoplamiento porque permiten evolución coordinada de forma explícita y no por conocimiento oculto. También facilitan el **despliegue independiente**, ya que el proveedor puede cambiar internamente mientras preserve el contrato observable. [martinfowler](https://martinfowler.com/articles/enterpriseREST.html)

### Trade-offs
La estabilidad del contrato no significa inmovilidad absoluta. Requiere disciplina de versionado, deprecación y pruebas, lo cual añade trabajo, pero evita integración frágil y despliegues coordinados.

### Fuentes
- Martin Fowler sobre REST, evolución y testing basado en consumidores. [martinfowler](https://martinfowler.com/articles/enterpriseREST.html)
- Consumer-Driven Contracts como patrón de evolución. [martinfowler](https://martinfowler.com/articles/consumerDrivenContracts.html)
- OpenAPI y prácticas de contrato en ecosistemas de microservicios. [dervis](https://www.dervis.no/presentations/cdc/pact-meetup-oslo.pdf)

***

## Síntesis parcial

SRP, acoplamiento y contratos estables forman una cadena conceptual útil:  
- **SRP** ayuda a identificar responsabilidades coherentes.  
- Eso favorece **límites de servicio** más claros.  
- Esos límites, si están bien definidos, reducen **acoplamiento**.  
- El acoplamiento se expresa y controla mediante **contratos**.  
- Contratos estables habilitan **evolución y despliegue independiente**. [learn.microsoft](https://learn.microsoft.com/es-es/dotnet/architecture/microservices/microservice-ddd-cqrs-patterns/microservice-application-layer-web-api-design)

Pero esta cadena no es automática ni garantiza éxito. Un servicio puede tener SRP razonable y aun así estar acoplado por datos, por sincronía temporal o por contratos frágiles. Del mismo modo, una API bien definida no compensa una mala partición de responsabilidades.

# Parte 2: comunicación y datos

Esta parte analiza **comunicación síncrona vs. asíncrona**, **gestión descentralizada de datos** y la relación entre **SRP, límites de servicio y ownership de datos**. La idea central es que en microservicios la autonomía no depende solo de “tener servicios separados”, sino de cómo se coordinan, cómo comparten información y quién es dueño de cada dato. [docs.aws.amazon](https://docs.aws.amazon.com/es_es/prescriptive-guidance/latest/modernization-integrating-microservices/communication-patterns.html)

## 4) Comunicación síncrona vs. asíncrona

### Definición
La comunicación **síncrona** es aquella en la que un servicio llama a otro y espera la respuesta para continuar. La **asíncrona** desacopla esa espera: el emisor publica un mensaje o evento y sigue ejecutando, mientras el receptor procesa cuando puede. [docs.aws.amazon](https://docs.aws.amazon.com/es_es/prescriptive-guidance/latest/modernization-integrating-microservices/communication-patterns.html)

### Fundamento y origen
No es un tema exclusivo de microservicios; es un principio general de sistemas distribuidos. En microservicios cobra especial importancia porque cada llamada remota añade latencia, dependencia temporal y una nueva vía de propagación de fallos. [docs.aws.amazon](https://docs.aws.amazon.com/es_es/prescriptive-guidance/latest/modernization-integrating-microservices/communication-patterns.html)

### Síncrona: qué resuelve y qué introduce
Tecnologías como HTTP/REST o gRPC encajan bien cuando se necesita una respuesta inmediata y el flujo depende de ese resultado. El problema es que el emisor queda bloqueado por la disponibilidad y el rendimiento del receptor; por tanto, hay acoplamiento temporal, necesidad de timeouts y sensibilidad a retries mal diseñados. [docs.aws.amazon](https://docs.aws.amazon.com/es_es/prescriptive-guidance/latest/modernization-integrating-microservices/communication-patterns.html)

### Asíncrona: qué resuelve y qué introduce
Colas, brokers, pub/sub y eventos permiten absorber picos, desacoplar disponibilidad y procesar trabajo diferido. A cambio, aparecen consistencia eventual, duplicación de mensajes, desorden potencial, idempotencia obligatoria y mayor complejidad operativa. [docs.aws.amazon](https://docs.aws.amazon.com/es_es/prescriptive-guidance/latest/modernization-integrating-microservices/communication-patterns.html)

### Conceptos importantes en asíncrono
- **Eventual consistency**: el sistema converge con el tiempo, no instantáneamente.  
- **Idempotencia**: procesar el mismo mensaje varias veces no debe corromper el estado.  
- **Duplicación**: los mensajes pueden entregarse más de una vez.  
- **Orden**: puede no preservarse globalmente.  
- **Delivery guarantees**: “at most once”, “at least once”, “exactly once” son garantías con costos y límites diferentes.  
- **Dead Letter Queue**: destino para mensajes que fallan repetidamente.  

### Comparación arquitectónica
| Aspecto | Síncrona | Asíncrona |
|---|---|---|
| Acoplamiento temporal | Alto | Bajo |
| Latencia percibida | Menor si el receptor responde rápido | Mayor o diferida |
| Disponibilidad | Depende del receptor | Mejor tolerancia a indisponibilidad temporal |
| Resiliencia | Vulnerable a fallos en cadena | Mejor aislamiento, pero no gratis |
| Manejo de errores | Más directo, más visible | Más distribuido, más complejo |
| Consistencia | Más inmediata | Eventual |
| Escalabilidad | Limitada por la cadena de llamadas | Mejor absorción de carga |
| Complejidad operacional | Menor al inicio | Mayor en observabilidad y mensajería |

### Cuándo usar cada una
- **Síncrona**: cuando necesitas una decisión inmediata, una validación rápida o una consulta de lectura simple.  
- **Asíncrona**: cuando el trabajo puede diferirse, cuando buscas desacoplar evolución o cuando quieres absorber picos y evitar dependencias temporales.

### Error común
No es cierto que lo asíncrono sea siempre mejor. Si el usuario necesita una respuesta inmediata, el costo de gestionar consistencia eventual, reintentos y reconciliación puede superar sus beneficios. [docs.aws.amazon](https://docs.aws.amazon.com/es_es/prescriptive-guidance/latest/modernization-integrating-microservices/communication-patterns.html)

### Ejemplo técnico
En un checkout, validar un pago crítico puede requerir llamada síncrona; en cambio, enviar un email de confirmación o actualizar analítica encaja mejor como evento asíncrono.

### Relación con otros conceptos
La comunicación síncrona tiende a aumentar acoplamiento temporal y, si se encadena, el blast radius. La asíncrona reduce ese acoplamiento, pero desplaza la complejidad hacia consistencia, observabilidad y entrega confiable. [docs.aws.amazon](https://docs.aws.amazon.com/es_es/prescriptive-guidance/latest/modernization-integrating-microservices/communication-patterns.html)

### Fuentes
- AWS Prescriptive Guidance sobre patrones de comunicación. [docs.aws.amazon](https://docs.aws.amazon.com/es_es/prescriptive-guidance/latest/modernization-integrating-microservices/communication-patterns.html)
- Microsoft y Azure sobre resiliencia, latencia y aislamiento. [learn.microsoft](https://learn.microsoft.com/en-us/azure/architecture/microservices/?WT.mc_id=events_jdconf)
- Material técnico sobre eventual consistency, colas y eventos. [cursa](https://cursa.app/es/pagina/comunicacion-entre-microservicios-y-resiliencia)

***

## 5) Gestión descentralizada de datos

### Definición
La gestión descentralizada de datos significa que cada servicio controla sus datos de forma autónoma, en vez de compartir una base de datos como capa común de integración. En microservicios, la idea no es solo técnica: protege la independencia de evolución del servicio. [docs.aws.amazon](https://docs.aws.amazon.com/prescriptive-guidance/latest/modernization-data-persistence/database-per-service.html)

### Fundamento y origen
La base conceptual está en la autonomía de servicio y en la noción de ownership: quien posee la capacidad de negocio debe controlar también sus invariantes y su persistencia. Por eso, Microsoft, AWS y microservices.io insisten en que otros servicios no deben acceder directamente al almacén privado de un servicio. [docs.aws.amazon](https://docs.aws.amazon.com/prescriptive-guidance/latest/modernization-data-persistence/database-per-service.html)

### Data ownership
**Ownership de datos** significa que un servicio es la fuente de verdad para un conjunto concreto de datos y reglas asociadas. No es solo “quién puede leer”, sino especialmente **quién puede escribir y garantizar invariantes**. [microservices](https://microservices.io/patterns/data/database-per-service.html)

### Database per Service
“Database per Service” no significa necesariamente una instancia física distinta por servicio. Puede significar:  
- servidor/instancia propia;  
- base de datos lógica propia;  
- schema propio;  
- tablas privadas dentro de una instancia compartida, siempre que haya ownership estricto.  

La idea arquitectónica que importa es la **privacidad y control del dato**, no necesariamente una separación física absoluta. [docs.aws.amazon](https://docs.aws.amazon.com/prescriptive-guidance/latest/modernization-data-persistence/database-per-service.html)

### Diferencia entre instancia, database, schema y tablas
- **Instancia**: proceso/servidor de base de datos.  
- **Database**: contenedor lógico dentro de una instancia.  
- **Schema**: partición lógica dentro de una database.  
- **Tablas**: estructuras concretas donde se almacenan filas.  
- **Ownership lógico**: quién define, escribe y gobierna ese conjunto de datos.  

Puedes tener separación lógica sin separación física, pero cuanto más se comparte el plano físico, más cuidado se necesita para no erosionar la frontera de ownership.

### Por qué compartir tablas es problemático
Si varios servicios escriben directamente las mismas tablas, quedan acoplados por esquema, transacciones, migraciones y reglas de integridad. Cualquier cambio en un servicio puede romper a los demás, y el acceso directo vuelve difusa la responsabilidad sobre los invariantes. [learn.microsoft](https://learn.microsoft.com/en-us/azure/architecture/microservices/design/data-considerations)

### Problemas al descentralizar datos
- **Consistencia eventual**: los datos no siempre están sincronizados al instante.  
- **Duplicación**: se replican datos para lecturas o integración.  
- **Consultas entre servicios**: aparecen composiciones de API o read models.  
- **Transacciones distribuidas**: difíciles y costosas; suelen reemplazarse por sagas.  
- **Integridad referencial**: ya no puedes confiar en claves foráneas entre dominios distintos.  
- **Reporting**: suele requerir pipelines de datos o modelos de lectura dedicados. [docs.aws.amazon](https://docs.aws.amazon.com/prescriptive-guidance/latest/modernization-data-persistence/database-per-service.html)

### Patrones relacionados
- **Saga**: coordina pasos distribuidos con acciones compensatorias.  
- **Transactional Outbox**: evita perder eventos al sincronizar persistencia y publicación.  
- **CQRS**: separa modelo de escritura y lectura, útil para proyecciones e integración de consultas. [tutorialesprogramacionya](https://www.tutorialesprogramacionya.com/disenosoftware/microservicios/tema5.html)

### Ejemplo técnico
Un servicio de pedidos puede ser dueño del estado `Order`. Si otro servicio necesita mostrar el estado en una pantalla, no debería leer la tabla interna de pedidos; debería usar API, evento o proyección propia. Eso preserva ownership y evita que el consumidor dependa del esquema interno.

### Trade-offs
La descentralización mejora autonomía, pero complica consistencia, reporting y consultas cruzadas. El beneficio arquitectónico es la independencia; el costo es la necesidad de patrones adicionales para coordinar datos. [docs.aws.amazon](https://docs.aws.amazon.com/prescriptive-guidance/latest/modernization-data-persistence/database-per-service.html)

### ¿“Cada microservicio debe tener su propia base de datos”?
La afirmación es útil como regla práctica, pero es una **simplificación**. Lo esencial no es la separación física sino el principio de **ownership exclusivo y acceso indirecto**; puedes compartir infraestructura física durante transiciones o por eficiencia, pero no deberías compartir libremente las tablas ni la lógica de escritura. [docs.aws.amazon](https://docs.aws.amazon.com/prescriptive-guidance/latest/modernization-data-persistence/database-per-service.html)

### Fuentes
- AWS Prescriptive Guidance sobre database-per-service y shared-database-per-service. [docs.aws.amazon](https://docs.aws.amazon.com/prescriptive-guidance/latest/modernization-data-persistence/database-per-service.html)
- Microsoft Learn sobre data sovereignty y datos aislados por servicio. [learn.microsoft](https://learn.microsoft.com/en-us/azure/architecture/microservices/design/data-considerations)
- microservices.io sobre database per service. [microservices](https://microservices.io/patterns/data/database-per-service.html)

***

## 6) SRP y ownership de datos

### Relación conceptual
SRP ayuda a definir **responsabilidad de negocio**; esa responsabilidad suele traducirse en **ownership de datos**. Si un servicio es responsable de una capacidad, normalmente debe controlar también los datos que sostienen sus invariantes. [microservices](https://microservices.io/patterns/data/database-per-service.html)

### Cómo las responsabilidades definen datos
Las responsabilidades de negocio no son solo operaciones; también implican decisiones sobre qué estados existen, quién los modifica y qué reglas deben preservarse. Eso ayuda a establecer qué datos debería controlar un servicio y cuáles deberían quedar fuera de su frontera.

### Por qué el ownership preserva límites
Si un servicio es el único que escribe su data, su frontera funcional queda protegida. Otros servicios no pueden “saltarse” esa frontera accediendo a tablas internas, lo que evita acoplamiento por implementación y por persistencia. [learn.microsoft](https://learn.microsoft.com/en-us/azure/architecture/microservices/design/data-considerations)

### Bases de datos compartidas y debilitamiento de límites
Una base compartida puede convertirse en una capa de integración informal: otros equipos pasan a depender del esquema, de nombres de tablas y de la lógica de escritura ajena. En ese punto, el límite del servicio deja de ser real aunque siga existiendo el código separado. [learn.microsoft](https://learn.microsoft.com/en-us/azure/architecture/microservices/design/data-considerations)

### Encapsulamiento, cohesión y ownership
Hay una relación estrecha entre estos tres conceptos:  
- **Cohesión**: la unidad hace cosas que pertenecen juntas.  
- **Encapsulamiento**: el detalle interno se oculta.  
- **Ownership**: un único servicio gobierna el dato y sus invariantes.  

Juntos ayudan a que la frontera del servicio sea comprensible y resistente al cambio.

### Separación lógica vs. física
La separación **lógica** define quién manda sobre el dato. La separación **física** define dónde vive ese dato. La primera es el principio arquitectónico; la segunda es una estrategia de implementación.

### Crítica a “cada microservicio debe tener su propia base de datos”
La parte correcta es que cada servicio debe ser **dueño exclusivo** de sus datos y acceso de escritura. La parte simplificadora es asumir que eso exige una instancia física exclusiva en todos los casos. El principio real que se protege es la **independencia evolutiva y la no interferencia entre servicios**. [docs.aws.amazon](https://docs.aws.amazon.com/prescriptive-guidance/latest/modernization-data-persistence/database-per-service.html)

### Fuentes
- Microsoft Learn sobre data sovereignty e isolated data/state. [learn.microsoft](https://learn.microsoft.com/en-us/dotnet/architecture/microservices/architect-microservice-container-applications/data-sovereignty-per-microservice)
- AWS y microservices.io sobre privacidad del almacenamiento. [docs.aws.amazon](https://docs.aws.amazon.com/prescriptive-guidance/latest/modernization-data-persistence/database-per-service.html)
- Relación con SRP y bounded contexts en literatura técnica de arquitectura. [youtube](https://www.youtube.com/watch?v=6MDeumsEa-4)

***

## Síntesis parcial

Aquí la cadena conceptual es más clara que antes:  
**responsabilidad de negocio → límites del servicio → ownership de datos → menor acoplamiento**.  
Pero sigue sin ser automática: si el ownership existe solo “en papel” y otros servicios acceden directamente a las tablas, el límite se rompe y la arquitectura vuelve a acoplarse.

La conclusión práctica es que la independencia de microservicios depende tanto de su partición funcional como de su control sobre datos y comunicación. SRP ayuda a descubrir fronteras razonables; el ownership de datos las hace reales; la comunicación elegida determina cuánto acoplamiento temporal aceptas.

# Parte 3: fallas, resiliencia y FDIR

Esta parte trata el **aislamiento de fallas**, los mecanismos de resiliencia y el concepto de **FDIR** como marco general de detección, aislamiento y recuperación. Aquí la idea central es que en sistemas distribuidos no se “eliminan” los fallos; se diseña para **limitar su propagación**, **reducir el blast radius** y **recuperar el servicio con el menor impacto posible**. [learn.microsoft](https://learn.microsoft.com/en-us/azure/architecture/microservices/?WT.mc_id=events_jdconf)

## 7) Fault Isolation

### Definición
Fault isolation es la capacidad de contener una falla para que no se expanda por el sistema. En microservicios esto significa evitar que un problema local —latencia, saturación, error lógico o caída de una dependencia— arrastre a otros servicios. [learn.microsoft](https://learn.microsoft.com/en-us/azure/architecture/microservices/?WT.mc_id=events_jdconf)

### Qué es una falla
Una falla no es solo “caerse”. Puede ser:  
- error funcional;  
- degradación de rendimiento;  
- saturación;  
- timeouts;  
- respuestas parciales;  
- pérdida temporal de conectividad;  
- comportamiento incorrecto bajo carga. [learn.microsoft](https://learn.microsoft.com/en-us/dotnet/architecture/microservices/implement-resilient-applications/monitor-app-health)

### Cómo se propagan las fallas
Se propagan por dependencias síncronas, colas saturadas, recursos compartidos, retries agresivos, pools comunes, o contratos que obligan a coordinar estados. El problema no siempre es el fallo original, sino la **reacción del resto del sistema** ante ese fallo.

### Cascading failures
Una cascading failure ocurre cuando una falla en un componente genera sobrecarga, timeouts o bloqueos en otros, que a su vez fallan y amplifican el incidente. Es uno de los riesgos más serios en arquitecturas distribuidas. [learn.microsoft](https://learn.microsoft.com/en-us/azure/architecture/microservices/?WT.mc_id=events_jdconf)

### Blast radius
El blast radius es el alcance del impacto de una falla. Reducirlo significa limitar cuántos usuarios, flujos o servicios quedan afectados cuando algo se degrada.

### Partial failure
En sistemas distribuidos es normal que solo una parte falle. El sistema no debe asumir éxito global o fracaso global; debe tolerar estados intermedios y degradación parcial.

### Graceful degradation
Es la capacidad de seguir ofreciendo funcionalidad reducida cuando una parte falla. No evita la falla, pero protege el valor esencial del sistema.

### Mecanismos de aislamiento

| Mecanismo | Qué problema soluciona | Cómo funciona | Riesgo si se usa mal |
|---|---|---|---|
| Timeouts | Evitar esperas indefinidas | Corta la espera tras un umbral | Umbral demasiado bajo causa falsos fallos |
| Retries | Fallos transitorios | Reintenta la operación | Puede amplificar carga y causar tormentas |
| Circuit Breaker | Evitar llamadas a dependencias degradadas | Abre el circuito tras fallos repetidos | Puede ocultar problemas si el umbral es incorrecto |
| Bulkhead | Evitar que un fallo consuma todos los recursos | Aísla pools de threads, colas o conexiones | Si se dimensiona mal, genera inanición artificial |
| Rate Limiting | Proteger de exceso de demanda | Limita el ritmo de solicitudes | Puede rechazar tráfico válido en picos |
| Health Checks | Detectar estado operativo | Expone endpoints de liveness/readiness | Si confunden “vive” con “está sano”, inducen falsos positivos |

### Combinación peligrosa: retries + servicio degradado
Si un servicio ya está lento y los clientes reintentan de manera agresiva, la carga aumenta justo cuando menos capacidad hay. Eso puede convertir un incidente local en una falla en cascada.

### Trade-offs
Estos mecanismos mejoran la resiliencia, pero añaden complejidad de tuning, observabilidad y operación. Mal usados, pueden ocultar síntomas, retrasar detección o empeorar la congestión.

### Fuentes
- Azure Architecture Center sobre fault isolation y microservices resilientes. [learn.microsoft](https://learn.microsoft.com/en-us/azure/architecture/microservices/?WT.mc_id=events_jdconf)
- Microsoft Learn sobre circuit breaker y bulkhead. [learn.microsoft](https://learn.microsoft.com/en-us/dotnet/architecture/microservices/implement-resilient-applications/implement-circuit-breaker-pattern)
- Literatura sobre patrones de resiliencia y prevención de fallas en cascada. [tutorialesprogramacionya](https://www.tutorialesprogramacionya.com/ciberseguridad/arqsegurasymicroservicios/tema22.html)

***

## 8) FDIR

### Definición
**FDIR** significa **Fault Detection, Isolation and Recovery**. Es un marco clásico de ingeniería de control para detectar fallas, localizarlas y ejecutar acciones de recuperación. No nació en microservicios; es un concepto general de sistemas tolerantes a fallos, muy usado en aeroespacial, satélites, energía y otros sistemas críticos. [en.wikipedia](https://en.wikipedia.org/wiki/Fault_detection_and_isolation)

### Origen y alcance
FDIR surge en control engineering y sistemas embebidos, donde una falla puede comprometer seguridad, estabilidad o misión. En arquitecturas distribuidas modernas se traslada como una forma de pensar la operación: detectar, aislar y recuperar con rapidez y precisión. [en.wikipedia](https://en.wikipedia.org/wiki/Fault_detection_and_isolation)

### ¿Es propio de microservicios?
No. Microservicios lo heredan y lo reinterpretan. El principio es general; lo que cambia es el tipo de falla y las herramientas disponibles: observabilidad, health checks, circuit breakers, failover, red de servicios, colas y despliegue automatizado.

### Fault Detection
Detectar implica reconocer que algo no está bien. En microservicios eso se apoya en:  
- métricas;  
- logs;  
- distributed tracing;  
- health checks;  
- alertas;  
- observabilidad unificada. [learn.microsoft](https://learn.microsoft.com/en-us/dotnet/architecture/microservices/implement-resilient-applications/monitor-app-health)

La observabilidad no es solo “ver datos”; es poder entender el estado interno a partir de telemetría útil y correlacionada.

### Fault Isolation
Aislar implica localizar el componente o dependencia problemática y evitar que arrastre al resto. En microservicios esto se apoya en tracing, circuit breakers, bulkheads, separación de recursos y límites claros de dependencia. [learn.microsoft](https://learn.microsoft.com/en-us/dotnet/architecture/microservices/implement-resilient-applications/monitor-app-health)

### Fault Recovery
Recuperar implica restaurar el servicio o el estado con impacto mínimo. Puede incluir retries controlados, restart, failover, redundancia, rollback, autoscaling, acciones compensatorias o replay de mensajes/eventos. [tutorialesprogramacionya](https://www.tutorialesprogramacionya.com/ciberseguridad/arqsegurasymicroservicios/tema22.html)

### Ejemplo conceptual completo
1. **Detection**: las métricas muestran aumento de latencia y error rate en un servicio de pagos; el tracing revela que la dependencia de un proveedor externo excede timeouts.  
2. **Isolation**: el circuit breaker abre, los clientes dejan de golpear la dependencia, y el bulkhead evita que el pool de threads se agote.  
3. **Recovery**: se activa fallback o respuesta degradada, se reintentan operaciones idempotentes cuando el proveedor se estabiliza, y se valida el estado antes de cerrar el incidente.

### Relación con observabilidad
FDIR depende de una observabilidad suficientemente rica para distinguir síntomas de causas. Sin telemetría bien correlacionada, se puede detectar que “algo falla” pero no aislar dónde ni recuperar con confianza. [learn.microsoft](https://learn.microsoft.com/en-us/Azure/azure-monitor/app/distributed-trace-data)

### Trade-offs
Más detección y más automatización no significan menos complejidad: exigen buen diseño de señales, umbrales, correlación y acciones seguras. La recuperación automática también puede ser peligrosa si reacciona al síntoma equivocado.

### Fuentes
- Wikipedia y literatura técnica sobre FDIR como subcampo de control engineering. [en.wikipedia](https://en.wikipedia.org/wiki/Fault_detection_and_isolation)
- Microsoft sobre health monitoring, distributed tracing y observability. [learn.microsoft](https://learn.microsoft.com/en-us/dotnet/architecture/microservices/implement-resilient-applications/monitor-app-health)
- Material técnico sobre recovery, failover y replay. [tutorialesprogramacionya](https://www.tutorialesprogramacionya.com/ciberseguridad/arqsegurasymicroservicios/tema22.html)

***

## Relaciones entre conceptos

### SRP → cohesión → límites de servicios
La relación es válida, pero no mecánica. SRP ayuda a identificar unidades de cambio coherentes, y eso suele favorecer cohesión alta; sin embargo, la frontera de un microservicio también depende de latencia aceptable, ownership de datos, modelo operativo y necesidad de autonomía. [learn.microsoft](https://learn.microsoft.com/es-es/dotnet/architecture/microservices/microservice-ddd-cqrs-patterns/microservice-application-layer-web-api-design)

### Límites de servicios → ownership de datos
Sí, la relación es fuerte. Si un servicio define su frontera funcional, normalmente debe controlar los datos que sostienen sus invariantes; de lo contrario, el límite se vuelve cosmético. [docs.aws.amazon](https://docs.aws.amazon.com/prescriptive-guidance/latest/modernization-data-persistence/database-per-service.html)

### Ownership de datos → menor acoplamiento
En general sí, porque evita accesos directos al almacenamiento interno y protege el contrato del servicio. Pero si el servicio sigue compartiendo flujos síncronos rígidos o modelos globales, el acoplamiento puede permanecer alto.

### Acoplamiento → propagación de fallas
Correcto. Más acoplamiento suele aumentar la probabilidad de fallos en cascada y el blast radius, especialmente cuando el acoplamiento es temporal y síncrono. [learn.microsoft](https://learn.microsoft.com/en-us/azure/architecture/microservices/?WT.mc_id=events_jdconf)

### Comunicación síncrona → acoplamiento temporal
Sí, de forma directa. El emisor depende de la disponibilidad y del tiempo de respuesta del receptor.

### Comunicación asíncrona → desacoplamiento temporal
Sí, pero con costo. Desacopla el tiempo de ejecución, no elimina el acoplamiento semántico ni el problema de consistencia.

### Contratos estables → evolución independiente
Sí, si los contratos están bien diseñados y versionados. Permiten que proveedor y consumidor evolucionen sin desplegarse al mismo tiempo. [martinfowler](https://martinfowler.com/articles/consumerDrivenContracts.html)

### Fault Isolation → reducción del blast radius
Sí, es precisamente uno de sus objetivos principales. Aislar una falla evita que el impacto se expanda. [learn.microsoft](https://learn.microsoft.com/en-us/azure/architecture/microservices/?WT.mc_id=events_jdconf)

### Observabilidad → Detection → Isolation → Recovery
Sí, con una matización: observabilidad no “causa” FDIR por sí sola, pero le da las señales necesarias para hacerlo viable. Sin ella, la recuperación tiende a ser ciega o reactiva. [learn.microsoft](https://learn.microsoft.com/en-us/Azure/azure-monitor/app/distributed-trace-data)

***

## Síntesis final

En conjunto, estos principios buscan **independencia práctica**, no independencia absoluta.  
- **SRP** y **cohesión** ayudan a definir fronteras con sentido de negocio.  
- **Ownership de datos** protege esas fronteras de la erosión por acceso directo.  
- **Contratos estables** permiten que los servicios evolucionen sin coordinar cada cambio.  
- **Comunicación síncrona/asíncrona** define cuánto acoplamiento temporal aceptas.  
- **Fault isolation** y **FDIR** reducen el daño cuando algo falla y mejoran la recuperación.  
- **Observabilidad** hace posible detectar, aislar y recuperar con precisión. [learn.microsoft](https://learn.microsoft.com/en-us/dotnet/architecture/microservices/implement-resilient-applications/monitor-app-health)

La idea importante es que **microservicios no equivalen automáticamente a bajo acoplamiento, resiliencia o autonomía**. Esos objetivos aparecen solo cuando la partición de responsabilidades, el ownership de datos, los contratos, la comunicación y las estrategias de resiliencia están alineados como un sistema coherente.
## Frameworks para contratos

| Caso de uso | Framework / herramienta | Qué aporta |
|---|---|---|
| APIs HTTP REST | OpenAPI / Swagger | Especificación formal del contrato, documentación y generación de clientes/servidores  [scitepress](https://www.scitepress.org/Papers/2020/93812/93812.pdf) |
| Diseño visual contract-first | Stoplight Studio | Editor visual para diseñar y revisar contratos OpenAPI  [apidog](https://apidog.com/es/blog/contract-first-development-toolstack/) |
| Contratos consumer-driven | Pact | Define expectativas del consumidor y valida compatibilidad  [testsprite](https://www.testsprite.com/use-cases/es/the-best-api-contract-testing-tools) |
| Contratos para Spring | Spring Cloud Contract | Automatiza contratos y stubs para servicios Java/Spring  [testsprite](https://www.testsprite.com/use-cases/es/the-best-api-contract-testing-tools) |
| Validación de contrato | Dredd | Ejecuta pruebas contra una especificación OpenAPI  [tools.openapis](https://tools.openapis.org/categories/all.html) |
| APIs asíncronas/eventos | AsyncAPI | Modela contratos de eventos y pub/sub |
| gRPC | protobuf / Buf | Contrato fuertemente tipado para RPC |


## 1.2 Análisis crítico del monolito BookSphere

Aplicando el marco anterior al monolito BookSphere descrito en el proyecto (una única aplicación con Gestión de Usuarios, Catálogo, Carrito, Pedidos, Pagos, Recomendaciones y Reseñas, todo sobre un único PostgreSQL compartido — ver Hito 2), se identifican los siguientes desafíos:

### Desafío 1 — Riesgo de fallas globales por ausencia de Fault Isolation

BookSphere, al ser un único proceso desplegado como una unidad, no tiene ningún mecanismo de aislamiento de fallas entre sus funcionalidades (sección 7): un error no controlado, una fuga de memoria, o simplemente carga excesiva en el **Motor de Recomendaciones** (probablemente la funcionalidad computacionalmente más pesada del sistema) puede degradar o tumbar el proceso completo, afectando también a **Catálogo**, **Carrito** y **Pedidos** — funcionalidades que, de negocio, no tienen ninguna razón para depender de que las recomendaciones funcionen. Esto es exactamente lo opuesto al principio de graceful degradation: en el monolito actual, todo el "blast radius" de cualquier falla es, por defecto, el sistema completo, porque no existe ningún límite de proceso entre responsabilidades. La misma lógica aplica al **Procesamiento de Pagos**: si la integración con la pasarela externa empieza a fallar o a responder lento, y ese código corre dentro del mismo proceso y con los mismos hilos/conexiones que atienden el resto de la aplicación, el problema puede agotar recursos compartidos y afectar la capacidad de simplemente *navegar el catálogo* — una funcionalidad que no debería depender en absoluto de la disponibilidad de la pasarela de pago.

### Desafío 2 — Bloqueo tecnológico y dificultad para desplegar por acoplamiento fuerte (código y base de datos compartidos)

Todas las funcionalidades comparten el mismo código base y el mismo PostgreSQL (sección 2, 5 y 6): esto crea acoplamiento de implementación y de datos entre responsabilidades que, de negocio, son independientes. La consecuencia directa es una **dificultad creciente para desplegar**: un cambio pequeño en, por ejemplo, la lógica de **Reseñas** requiere probar y desplegar la aplicación completa, incluyendo Pagos y Pedidos — el mismo problema documentado en la literatura de despliegues de monolitos, donde el acoplamiento fuerte entre componentes hace que los despliegues se vuelvan más lentos y riesgosos a medida que la aplicación crece, aumentando la probabilidad de que una funcionalidad recién desplegada tumbe la aplicación entera. Adicionalmente, existe **bloqueo tecnológico** (technology lock-in): dado que todo corre en un único proceso con una única stack tecnológica, no es posible, por ejemplo, adoptar una tecnología distinta mejor adaptada para el Motor de Recomendaciones (que podría beneficiarse de un modelo de datos y un patrón de escalado muy distintos a los de Pedidos) sin migrar o reescribir la aplicación entera — no existe la libertad de elegir la herramienta correcta por responsabilidad, que sí ofrece (cuando está justificado, ver Hito 2.2) una arquitectura de microservicios.

### Desafíos adicionales identificados (para contexto, más allá del mínimo de 2)

- **Cuello de botella de escalabilidad:** dado que toda la aplicación escala como una sola unidad, un pico de tráfico en **Catálogo** durante una campaña (mencionado explícitamente en el escenario de evolución) obliga a escalar también Pagos, Recomendaciones y Reseñas aunque no lo necesiten — desperdiciando recursos y encareciendo la operación, en lugar de escalar solo lo que realmente está bajo presión.
- **Degradación de UX bajo carga:** como consecuencia de los dos desafíos anteriores, un problema de rendimiento en cualquier parte del sistema (p. ej., una consulta lenta en el módulo de Reseñas) puede degradar la experiencia de navegar el catálogo o completar un checkout — funcionalidades críticas de negocio, afectadas por una funcionalidad que no lo es.
- **Fricción creciente para más desarrolladores:** el escenario menciona explícitamente que crecen los desarrolladores trabajando sobre la aplicación — sin límites de servicio ni ownership claro (SRP a nivel de módulo, sección 1 y 6), más personas modificando la misma base de código y el mismo esquema de base de datos aumenta la probabilidad de conflictos y de cambios que rompen funcionalidad no relacionada, sin que exista ningún contrato (sección 3) que contenga ese impacto.

Estos desafíos son exactamente los que la descomposición ya realizada en el Hito 2 (identificación de microservicios) y el Hito 2.2 (ownership de datos y persistencia) buscan resolver — este análisis del 1.2 confirma, con el marco conceptual del 1.1, por qué esas decisiones posteriores eran arquitectónicamente necesarias y no solo un ejercicio académico.