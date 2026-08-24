# Semana 6 — Arquitectura de Microservicios II (MSA II)

## Resumen del contenido

Este documento corresponde a las diapositivas de la Semana 6 del curso Arquitectura
de Software 3, cuyo objetivo declarado es "aplicar principios fundamentales y
mejores prácticas para diseñar microservicios escalables, resilientes y
mantenibles". Es la continuación directa de la Semana 5 (MSA I) y antecede a la
Semana 7 (MSA III). El material profundiza en el **diseño interno** de una
arquitectura de microservicios, cubriendo en este orden: repaso de MSA I,
principios esenciales de diseño de microservicios, límites de servicio y
descomposición de dominio (con Ley de Conway y DDD), separación de
responsabilidades (SoC), escalabilidad y elasticidad, acoplamiento débil,
independencia de servicios, gestión de datos en microservicios, y diseño de APIs
para comunicación entre servicios. El eje transversal del documento es que las
decisiones de diseño de microservicios deben derivarse del dominio de negocio
(Diseño Dirigido por el Dominio) y no de estructuras técnicas, y que cada
principio implica compensaciones (trade-offs) explícitas que el arquitecto debe
gestionar conscientemente.

## Conceptos clave

### Microservicios (repaso de MSA I)

**Definición:** Servicios pequeños y autónomos, cada uno realizando una función de
negocio, comunicándose vía APIs, desplegados independientemente.

**Explicación:** Se contrastan con el monolito: monolito = una gran aplicación, un
despliegue, una base de datos; microservicios = muchas aplicaciones pequeñas,
despliegues independientes, muchas bases de datos.

**Características esenciales (repaso):**
- Responsabilidad única: una capacidad de negocio por servicio.
- Desplegable independientemente: no se necesita coordinación para el despliegue.
- Acoplamiento débil: los cambios no se propagan entre servicios.
- Autonomía del equipo: propio desarrollo, despliegue y operaciones.
- Datos descentralizados: cada servicio tiene su propia base de datos.
- Comunicación inteligente: síncrona (HTTP/REST) o asíncrona (mensajería).
- Aislamiento de fallos: un servicio caído ≠ todo el sistema caído.
- Políglota: usar la mejor pila tecnológica por servicio (BDs y lenguajes).

**Patrones críticos (repaso):** API Gateway (punto de entrada único),
Descubrimiento de servicios (encontrar servicios dinámicamente), Circuit breaker
(dejar de llamar a servicios rotos), Patrón Saga (gestionar transacciones
distribuidas).

**Cuándo usar MSA (repaso):**
- Elegir MSA cuando: dominio complejo, equipos grandes, necesidad de escalado
  independiente.
- Evitar MSA cuando: aplicación simple, equipo pequeño, experiencia limitada en
  DevOps.

**Conclusión del repaso:** MSA intercambia simplicidad de desarrollo por
complejidad operacional para permitir escala y velocidad.

### Los tres pilares de la arquitectura de microservicios

**Definición:** Marco conceptual (contenido en inglés en el material) que agrupa
los principios de diseño en tres ejes.

**Características:**
- *Organizational Alignment & Autonomy*: habilitar que equipos independientes
  posean, desplieguen y escalen sus propios servicios.
- *Resilience & Independent Scalability*: aislar fallas y escalar de forma
  granular.
- *Evolutionary Design*: habilitar cambio rápido, seguro e independiente.

### Los 8 Principios Esenciales de Diseño de Microservicios

**Definición:** Lista central del material que organiza el diseño de
microservicios en ocho principios, cada uno desarrollado en detalle:
1. Modelado en torno al dominio de negocio (Diseño Dirigido por el Dominio).
2. Descentralizar todas las cosas.
3. Cultura de automatización.
4. Aislar fallos.
5. Desplegabilidad independiente.
6. Contratos orientados al consumidor.
7. Observabilidad, no solo monitoreo.
8. Endpoints inteligentes y tuberías simples.

#### 1. Modelado en torno al dominio de negocio (DDD)

**Explicación:** Los servicios deben alinearse con Contextos Delimitados
(*Bounded Contexts*), no con capas técnicas (ej., `UserService`, `OrderService`,
`PaymentService`). El material lo marca explícitamente como "el principio más
importante".

**Perspectiva del arquitecto (nota del material):** Usar DDD para descubrir
límites de servicio. Un límite mal definido lleva a servicios comunicativos
("chatty") y bases de datos compartidas, anulando todos los beneficios de MSA.

#### 2. Descentralizar todo

**Explicación:** Preferir estándares descentralizados y ligeros (REST, gRPC,
formatos de eventos) sobre mandatos rígidos a nivel empresarial, permitiendo a
los equipos elegir su stack tecnológico cuando sea apropiado.
- Gestión de datos: cada servicio posee sus datos de dominio y los expone vía
  APIs. El patrón **Base de Datos por Servicio** es crítico; evita la trampa del
  "monolito distribuido" con una única base de datos compartida.
- Toma de decisiones: empuja las decisiones operacionales (escalado, elecciones
  tecnológicas) a los equipos que poseen los servicios.

#### 3. Cultura de automatización

**Explicación:** Si no se puede automatizar el despliegue y las pruebas, no se
puede gestionar microservicios a escala; los procesos manuales llevan a errores,
versiones lentas y entornos inconsistentes.

**Enfoque del arquitecto:** Invertir en y exigir un pipeline CI/CD robusto,
Infraestructura como Código (Terraform, CloudFormation) y estrategias de pruebas
automatizadas (pruebas de contrato, pruebas de integración).

#### 4. Aislar fallos

**Explicación:** Un fallo en un servicio no debe propagarse y derribar el
sistema. Diseñar para fallos desde el primer día.

**Patrones de diseño asociados:**
- *Circuit Breakers*: evitan llamar repetidamente a un servicio que falla.
- *Bulkheads*: aíslan recursos (ej., pools de hilos, conexiones) para que el
  fallo en un área no agote todos los recursos.
- *Degradación Elegante*: diseñar clientes (especialmente UIs) para funcionar
  con datos parciales o funcionalidad degradada.

**Deber del arquitecto:** Diseñar para resistencia desde el primer día; no es una
ocurrencia tardía.

#### 5. Desplegabilidad independiente

**Explicación:** ¿Puedes desplegar un servicio sin coordinarte con otros equipos
o redesplegar otros servicios? Si no, los límites están mal definidos.

**Implica:** Compatibilidad hacia atrás estricta en APIs y esquemas de eventos.
Usar estrategias de versionado y apuntar a despliegues sin tiempo de inactividad
(blue-green, canary).

#### 6. Contratos orientados al consumidor

**Explicación:** Las APIs y eventos son contratos públicos. Diseñar
explícitamente para las necesidades del consumidor, no como un subproducto
accidental del modelo interno del servicio.

**Herramientas:** Pruebas de contrato (ej., Pact) y registros de esquemas (para
eventos), para asegurar que los contratos no se rompan inadvertidamente.

#### 7. Observabilidad, no solo monitoreo

**Explicación:** Con sistemas distribuidos, la depuración es imposible solo con
registro (logging) tradicional.

**Los tres pilares de la observabilidad:**
- *Trazado distribuido*: correlaciona peticiones a través de límites de servicio
  (ej., OpenTelemetry, Jaeger).
- *Registro estructurado centralizado*: logs agregados y buscables con IDs
  correlacionados.
- *Métricas*: métricas de negocio y operacionales por servicio (latencia, tasas
  de error, saturación).

**Mandato del arquitecto:** La observabilidad es un requisito de infraestructura
no negociable.

#### 8. Endpoints inteligentes y tuberías simples ("Smart Endpoints, Dumb Pipes")

**Explicación:** Mantener simple la comunicación entre servicios. La lógica de
negocio debe residir en los servicios, no en el middleware de comunicación.

**Práctica:** Usar mensajería simple y resistente (RabbitMQ) o flujos de eventos
(Kafka) como la "tubería tonta". Evitar motores de orquestación pesados e
inteligentes a nivel de infraestructura que se conviertan en puntos centrales de
lógica y falla.

### Ley de Conway y Diseño Dirigido por el Dominio (DDD)

**Definición:** Principio rector: la estructura del software reflejará la
estructura de la organización (Ley de Conway). Por tanto, los límites de
servicio deben alinearse con el dominio de negocio, no con construcciones
técnicas.

**Explicación:** El DDD es la herramienta principal para diseñar esos límites.

**Elementos de DDD mencionados:**
- *Contexto delimitado (Bounded Context)*: el patrón central. Define un límite
  claro dentro del cual un modelo de dominio particular (entidades, reglas,
  lenguaje) es consistente y aplicable. Cada Contexto Delimitado es un candidato
  principal para un límite de servicio.
- *Lenguaje ubicuo (Ubiquitous Language)*: lenguaje compartido entre
  desarrolladores y expertos del dominio, que debe codificarse en la API del
  servicio y el modelo interno.
- *Diseño estratégico*: patrones como Subdominios (Núcleo, Genérico, Soporte)
  ayudan a priorizar dónde invertir. Los Subdominios Núcleo más críticos merecen
  los servicios más aislados y bien diseñados.

**Maniobra Conway Inversa:** Alinear servicios con límites de equipo; un solo
equipo autónomo debe poseer uno o más servicios relacionados.

### Capas de un microservicio DDD (referencia técnica del material)

**Definición:** Ejemplo de estructura interna de un microservicio ("Ordering")
diseñado con DDD, tomado de documentación de Microsoft (fuente citada en el
material).

**Explicación:**
- *Application layer* (`Ordering.API`): ASP.NET Web API, acceso de red al
  microservicio, contratos/implementación de API, comandos y manejadores de
  comandos, consultas (enfoque CQS, ej. micro-ORMs como Dapper).
- *Domain model layer* (`Ordering.Domain`): modelo de entidad de dominio, clases
  POCO (código C# limpio), entidades de dominio con datos + comportamiento,
  patrones DDD (entidad de dominio, agregado, raíz de agregado, objeto de valor,
  contratos/interfaces de repositorio).
- *Infrastructure layer* (`Ordering.Infrastructure`): infraestructura de
  persistencia de datos (implementación de repositorio), uso de ORMs o API de
  acceso a datos (Entity Framework Core, ADO.NET, cualquier API de base de datos
  NoSQL), otra implementación de infraestructura usada desde la capa de
  aplicación (logging, criptografía, motor de búsqueda, etc.).

## Enfoques, métodos o herramientas

### Criterios clave para definir límites de servicio

Al descomponer un dominio, evaluar los límites basándose en:
- **Capacidad de negocio:** ¿qué función de negocio realiza este grupo de
  operaciones? (ej., "Gestión de Pedidos", "Inventario", "Procesamiento de
  Pagos"). Es el enfoque más estable y recomendado.
- **Desacoplamiento y velocidad de cambio:**
  - "Los datos que cambian juntos pertenecen juntos": si un cambio en las reglas
    de negocio requiere consistentemente cambios en dos "servicios",
    probablemente sean un solo servicio.
  - Separar partes que cambian por razones diferentes (ej., un servicio
    "Promociones" de evolución rápida vs. un "Registro de Clientes" estable).
- **Propiedad de datos y consistencia:**
  - Un servicio debe poseer y ser el sistema de registro para sus datos; expone
    esos datos vía APIs, no otorga acceso directo a la base de datos.
  - Esforzarse por consistencia fuerte dentro de un servicio y aceptar
    consistencia eventual entre servicios (crítico para transacciones a través
    de límites, usando el patrón Saga).
- **Estructura del equipo:** alinear servicios con límites de equipo (Maniobra
  Conway Inversa); un solo equipo autónomo debe poseer uno o más servicios
  relacionados.

### Patrones de descomposición (buenos patrones) vs. anti-patrones

**Buenos patrones:**
- *Descomponer por capacidad de negocio/subdominio*: más sostenible.
- *Descomponer por "sustantivo" (con precaución)*: cuidado con los "Servicios de
  Entidad" de grano grueso (ej., un `UserService` monolítico que maneja todo
  sobre un usuario: perfil, autenticación, preferencias, pedidos), que a menudo
  lleva a un monolito distribuido. En su lugar, dividir basado en la capacidad
  relacionada con el sustantivo (ej., `CustomerIdentityService`,
  `CustomerProfileService`).
- *Patrón de estrangulamiento (Strangler Pattern)*: descomponer gradualmente un
  monolito extrayendo funcionalidad rebanada por rebanada en servicios,
  dirigiendo el tráfico con el tiempo.

**Anti-patrones a evitar:**
- *Descomponer por capa técnica*: tener un "Servicio de Base de Datos",
  "Servicio de Lógica" y "Servicio de UI" crea acoplamiento fuerte y redes
  charlantes. Los servicios deben ser rebanadas verticales, poseyendo su UI (si
  la hay), lógica y almacén de datos.
- *Límites anémicos*: servicios tan charlantes e interdependientes que las
  llamadas de red se asemejan a llamadas de función in-proceso, matando el
  rendimiento y la resistencia.
- *Librerías "comunes" compartidas*: especificaciones compartidas (clientes de
  API, esquemas de eventos) están bien, pero librerías compartidas pesadas para
  lógica de negocio crean acoplamiento explosivo. Duplicar en lugar de acoplar.
- *Monolito Distribuido*: servicios fuertemente acoplados que deben desplegarse
  juntos.
- *Base de Datos Compartida*: el anti-patrón de acoplamiento definitivo.
- *Ignorar lo "Micro"*: servicios creciendo hacia componentes monolíticos dentro
  de la arquitectura de microservicios; se trata de contexto delimitado, no de
  líneas de código.
- *Comunicación Parlanchina (Chatty)*: APIs de grano fino causando alta latencia
  y acoplamiento estrecho.

### El rol de los patrones de comunicación (en descomposición de dominio)

- **Síncrono (REST, gRPC):** usado para consultas y comandos donde se necesita
  una respuesta inmediata; lleva a acoplamiento en tiempo de ejecución.
- **Asíncrono (Eventos/Mensajes):** el "estándar dorado" para comunicación entre
  servicios, para lograr acoplamiento débil. Un servicio publica un evento (ej.,
  `OrderConfirmed`) cuando algo significativo ocurre en su dominio; otros
  servicios escuchan y reaccionan en su propio contexto sin llamar de vuelta a
  la fuente. Crea desacoplamiento temporal, esencial para la verdadera
  autonomía.

### Separación de Responsabilidades (SoC)

**Definición:** Principio de diseño que reduce las interdependencias y crea
límites claros entre las distintas responsabilidades de un sistema.

**Por qué importa:**
- *Complejidad Creciente*: los sistemas modernos entretejen capas de UI, lógica
  de negocio, acceso a datos, seguridad e infraestructura en intrincadas redes
  de dependencias.
- *Efectos Dominó*: sin separación adecuada, un simple cambio en un área se
  propaga impredeciblemente por todo el sistema, creando pesadillas de
  mantenimiento y errores ocultos.
- *La Solución*: SoC reduce interdependencias y crea límites claros, haciendo
  los sistemas más fáciles de entender, probar, depurar y evolucionar.

**Beneficios core (Core Benefits of Separation of Concerns, en inglés en el
material):** Modularidad (componentes desarrollados independientemente para
flujos de trabajo paralelos), Colaboración (equipos trabajando simultáneamente
sin conflictos), Bajo acoplamiento (dependencias externas mínimas para
interfaces limpias), Alta cohesión (responsabilidad enfocada dentro de cada
módulo), Reusabilidad (bloques autocontenidos reusados entre proyectos).

**Manifestaciones en patrones arquitectónicos:** SoC es la base de la mayoría de
los patrones arquitectónicos modernos; cada patrón proporciona una "lente"
diferente para separar las preocupaciones:
- *Arquitectura en Capas (n-Niveles)*: separa horizontalmente por
  responsabilidad técnica. Preocupaciones: Presentación (UI), Lógica de
  Negocio, Acceso a Datos, Base de Datos. Regla de separación: una capa solo
  puede depender de la capa inmediatamente inferior (la UI no sabe nada de SQL,
  solo la interfaz de lógica de negocio).
- *Arquitectura Limpia / Hexagonal (Puertos y Adaptadores)*: separa por
  dirección de dependencia, colocando la lógica de negocio central en el
  centro. Preocupación central: reglas de negocio y entidades empresariales
  (más estables). Preocupaciones externas: mecanismos de entrega (Web, APIs,
  CLI) y fuentes de datos (bases de datos, servicios externos), tratados como
  "plugins" del núcleo. Regla de separación: las dependencias apuntan hacia
  adentro; el núcleo tiene cero dependencias en frameworks, bases de datos o
  UIs.
- *Arquitectura de Microservicios*: separa verticalmente por dominio de negocio
  o capacidad. Cada servicio posee una función específica de negocio (ej.,
  "Gestión de Pedidos", "Autenticación de Usuario", "Inventario"). Regla de
  separación: los servicios son desplegables independientemente, con su propia
  lógica, datos y componentes de UI; la preocupación es la separación de
  límites de negocio.
- *Arquitectura Orientada a Servicios (SOA)*: separa en servicios discretos e
  interoperables, a menudo con enfoque en integración empresarial y protocolos
  de comunicación compartidos.

**Compensaciones y consideraciones prácticas de SoC:**
- *Abstracción vs. complejidad*: SoC reduce la complejidad del dominio pero
  introduce complejidad de abstracción (más interfaces, más módulos, más
  direccionamiento indirecto); el objetivo es una reducción neta de la
  complejidad general.
- *Riesgo de sobre-ingeniería*: separar preocupaciones muy temprano o muy
  granularmente ("microservicios en todas partes") puede crear un sistema más
  difícil de entender y mantener que un monolito bien estructurado. El
  contexto es clave.
- *Implicaciones de rendimiento*: el direccionamiento indirecto (múltiples
  capas, llamadas remotas en microservicios) puede agregar latencia; a veces
  "filtración" controlada o consolidación es necesaria para el rendimiento,
  pero debe ser una decisión consciente y documentada.
- *Preocupaciones transversales*: algunas preocupaciones (logging, seguridad,
  telemetría) inherentemente atraviesan todas las capas/servicios; se manejan
  mejor con patrones dedicados: Programación Orientada a Aspectos (AOP) para
  aplicaciones monolíticas/en capas; patrón sidecar / servicios centralizados
  (ej., un servicio Auth dedicado, o una malla de servicios para
  observabilidad) para sistemas distribuidos.

**Preguntas guía para el arquitecto (SoC):**
- ¿Cuáles son los ejes primarios de cambio? (¿UI, reglas de negocio, o
  almacenamiento de datos? Separar a lo largo del eje de cambio.)
- ¿Cuál es la unidad de despliegue? (¿Necesita escalar/actualizar la UI
  independientemente de la lógica de negocio?)
- ¿Puedo probar esta preocupación de forma aislada?
- ¿Es la interfaz clara y mínima? (El límite entre preocupaciones debe ser el
  contrato "más estrecho" posible.)

**Conclusión de SoC (del material):** SoC no es un fin en sí mismo; es un medio
para lograr Mantenibilidad (cambios localizados), Comprobabilidad (componentes
probables de forma aislada), Desarrollo paralelo (equipos trabajando con
fricción mínima) y Diseño evolutivo (el sistema se adapta a nuevas tecnologías o
requisitos sin reescritura completa). La buena arquitectura de software es el
arte de dibujar las "líneas" correctas entre preocupaciones.

### Escalabilidad y Elasticidad

**Definición (Escalabilidad):** Capacidad fundamental de un sistema para manejar
una carga de trabajo incrementada añadiendo sistemáticamente recursos (potencia
de cómputo, almacenamiento o capacidad de red).

**Definición (Elasticidad):** Adaptación de recursos en tiempo real; ajuste
flexible y temporal de recursos para manejar fluctuaciones de demanda
impredecibles de manera eficiente (nota: la definición formal explícita para
Elasticidad no quedó completamente capturada en el material extraído; ver Notas
y advertencias).

**Explicación:** Los sistemas modernos enfrentan desafíos sin precedentes al
manejar patrones de crecimiento impredecibles y demanda fluctuante de usuarios.
El cambio hacia la computación en la nube transformó estos conceptos de
características deseables a requisitos arquitectónicos críticos. Impactan
directamente tres resultados de negocio: costos operativos, rendimiento del
sistema y experiencia del usuario.

**Tipos de escalamiento:**
- *Escalamiento vertical*: escalar hacia arriba añadiendo más potencia a
  máquinas existentes (CPU, RAM o almacenamiento en un solo servidor).
- *Escalamiento horizontal*: escalar hacia afuera añadiendo más máquinas al pool
  de recursos, distribuyendo la carga a través de múltiples servidores en
  paralelo.

**Ejemplo del mundo real (escalabilidad):** añadir más servidores de
aplicaciones detrás de un balanceador de carga para acomodar una base de
usuarios creciente de millones sin degradación del rendimiento.

**Definiendo Elasticidad (aspectos capturados):**
- *Respuesta en Tiempo Real*: los recursos se ajustan en minutos o segundos
  basándose en umbrales de monitoreo y señales de demanda.
- *Inteligencia Automatizada*: las herramientas de orquestación nativas de la
  nube toman decisiones de escalamiento automáticamente usando reglas
  predefinidas y modelos de ML.
- *Ejemplo clásico*: Netflix activa automáticamente cientos de servidores de
  transmisión adicionales durante horas pico nocturnas y luego reduce recursos
  después de la medianoche para optimizar costos.

**Analogía de la cena (Escalabilidad vs. Elasticidad):**
- *Escalabilidad = Comprar una Mesa Más Grande*: inversión permanente en una
  mesa de comedor más grande para acomodar más invitados regularmente
  (crecimiento planificado de capacidad a largo plazo).
- *Elasticidad = Tomar Sillas Extra*: cuando llegan invitados sorpresa, se toman
  rápidamente sillas plegables del almacén, se usan durante la cena y luego se
  guardan (ajuste flexible bajo demanda).

**Distinción clave (nota destacada del material):** La escalabilidad aborda el
crecimiento planificado y el aumento de capacidad base, mientras que la
elasticidad proporciona ajuste flexible y temporal para manejar fluctuaciones de
demanda impredecibles de manera eficiente.

**Implicaciones arquitectónicas — Diseñando para Escalabilidad:**
- *Modularidad y acoplamiento débil*: enfatizar la arquitectura de
  microservicios e independencia de componentes para habilitar escalamiento
  horizontal a través de sistemas distribuidos.
- *Componentes sin estado*: diseñar servicios sin afinidad de sesión para
  permitir replicación transparente y distribución inteligente de carga a
  través de múltiples instancias.
- *Estrategia de escalabilidad de base de datos*: planificar el crecimiento de
  la capa de datos a través de particionamiento (sharding), réplicas de
  lectura, caché de escritura directa (write-through) y patrones de base de
  datos distribuida.
- *Principios centrales*: diseñar para falla y redundancia; implementar
  balanceo de carga efectivo; desacoplar capas de datos y cómputo; usar colas
  de mensajes para procesamiento asíncrono.

**Implicaciones arquitectónicas — Diseñando para Elasticidad:**
- *Monitoreo inteligente*: monitoreo automatizado integral de métricas de
  recursos (CPU, memoria, latencia de solicitudes) y métricas personalizadas de
  aplicación que activen decisiones de escalado.
- *Herramientas cloud-native*: aprovechar plataformas como Kubernetes, AWS Auto
  Scaling Groups o Azure Scale Sets para agregar/eliminar instancias
  dinámicamente basado en condiciones en tiempo real.
- *Escalado elegante*: nuevas instancias deben calentarse adecuadamente, y las
  instancias terminadas deben drenar conexiones sin perder solicitudes.
- *Umbrales de rendimiento*: definir métricas claras (ej., escalar hacia arriba
  al 70% de CPU, escalar hacia abajo al 30% de CPU sostenido por 5 minutos).
- *Períodos de enfriamiento (cooldown)*: prevenir oscilaciones estableciendo
  intervalos mínimos entre acciones de escalado.
- *Verificaciones de salud (health checks)*: solo enrutar tráfico a instancias
  que pasen pruebas de preparación (readiness) y vitalidad (liveness).

**Ejemplo del mundo real — Arquitectura Elástica de Netflix:** Netflix se erige
como el "estándar de oro" para combinar escalabilidad y elasticidad en sistemas
de producción, sirviendo a más de 230 millones de suscriptores con
confiabilidad excepcional.
- *Escalado automático*: los servidores de streaming escalan automáticamente
  según picos de demanda de usuarios.
- *Optimización de costos*: la elasticidad en la nube libera miles de recursos
  computacionales cuando la demanda baja, reduciendo dramáticamente los costos
  de infraestructura.
- *Excelencia arquitectónica*: combina arquitectura escalable de microservicios
  con auto-escalado elástico.
- *Métricas citadas*: 10K+ microservicios ejecutándose en infraestructura
  distribuida en la nube; 99.9% de tiempo activo logrado a través de patrones
  de resistencia elástica; 30% de ahorro de costos mediante gestión inteligente
  de recursos elásticos.

**Desafíos y compromisos:**
- "La escalabilidad es la base para la elasticidad": no se puede ser elástico
  si la arquitectura no es escalable. Si la base de datos monolítica es el
  cuello de botella, auto-escalar 100 servidores web frente a ella solo
  empeorará las cosas (problema del "Rebaño Estruendoso" / thundering herd).
- *Desafíos de escalabilidad*: requiere diseño arquitectónico inicial
  significativo, inversión en infraestructura y planificación cuidadosa de
  capacidad.
- *Dependencias de elasticidad*: el éxito depende de la madurez de
  automatización, capacidades sofisticadas de monitoreo y experiencia en
  herramientas cloud-native; las organizaciones necesitan excelencia en DevOps
  para obtener beneficios.
- *Balanceo de carga, consistencia de datos, observabilidad* (desafíos cont.):
  distribución inteligente de tráfico, monitoreo de salud, gestión de
  sesiones; transacciones distribuidas, consistencia eventual, resolución de
  conflictos; trazado distribuido, registro centralizado, métricas en tiempo
  real.
- *Insight crítico*: aunque la elasticidad puede reducir dramáticamente los
  costos operacionales al pagar solo por los recursos que se usan, demanda
  orquestación robusta, tolerancia integral a fallas y prácticas operacionales
  maduras para prevenir fallas en cascada durante eventos de escalado.

**Principios rectores para arquitectos (escalabilidad y elasticidad):**
- Diseñar para escalabilidad horizontal primero: asumir que se necesitará
  escalar hacia afuera; esto fuerza buenas prácticas (ausencia de estado,
  desacoplamiento, externalización del estado).
- Identificar y aislar el estado: decidir dónde y cómo se gestiona el estado
  tempranamente; usar almacenes de datos especializados y escalables.
- Escalar mediante duplicación: crear copias idénticas e independientes de un
  componente detrás de un balanceador de carga; guía hacia idempotencia y
  ausencia de estado.
- Implementar elasticidad como un bucle de control automatizado: definir
  métricas (qué medir), políticas (cuándo escalar) y mecanismos (cómo
  escalar); comenzar simple (CPU), luego avanzar a métricas personalizadas de
  aplicación (RPS, latencia).
- Probar escalado y modos de fallo rigurosamente: usar ingeniería del caos y
  pruebas de carga (2x, 5x, 10x la carga pico esperada) para encontrar cuellos
  de botella (ej., saturación del pool de conexiones de base de datos al
  escalar de 10 a 50 pods).

**Conclusión (escalabilidad vs. elasticidad):**
- Escalabilidad es una **propiedad arquitectónica**, una preocupación de diseño
  estructural: se "arquitecta para escalabilidad".
- Elasticidad es una **capacidad operacional**, un comportamiento en tiempo de
  ejecución: se "implementa elasticidad" sobre una base escalable.
- Una arquitectura moderna cloud-native apunta a ambas: un diseño escalable que
  puede crecer a tamaño inmenso, coronado con automatización elástica que lo
  hace rentable y responsivo a patrones de tráfico reales.

### Acoplamiento Débil (Loose Coupling)

**Definición:** Grado en el cual los componentes de un sistema dependen unos de
otros; el acoplamiento débil minimiza esas dependencias.

**Metáfora central del material — "Módulos como Islas":** cada componente
principal (servicio, módulo, capa) es una isla. El acoplamiento débil significa
que estas islas se comunican a través de protocolos bien definidos y estables
("transbordadores y señales de radio"), no conectadas por puentes frágiles ni
compartiendo el suelo interno del otro. Un cambio en el paisaje de una isla no
debería necesitar una reconstrucción de otra.

**Mecanismos arquitectónicos clave para acoplamiento débil:**
- *Interfaces sobre implementaciones*: la herramienta más fundamental; depender
  de un contrato (interfaz/especificación API), no de la clase concreta o
  lógica de servicio, permite intercambiar implementaciones sin afectar a los
  invocadores.
- *Paso de mensajes y arquitectura dirigida por eventos*: los componentes se
  comunican enviando mensajes (eventos, comandos) a un canal/broker, no por
  llamadas RPC directas; el emisor no sabe ni le importa quién consume el
  mensaje. Esto es desacoplamiento temporal (emisor/receptor pueden estar
  desconectados) y desacoplamiento de procesamiento. Ejemplo: un evento
  `PedidoRealizado`; los servicios de facturación, inventario y
  recomendaciones se suscriben independientemente; el servicio de pedidos no
  sabe que existen.
- *Gateways API y BFFs*: en microservicios, un gateway desacopla clientes de
  las ubicaciones específicas y APIs de servicios individuales; los clientes
  hablan con un punto de entrada estable.
- *Contextos acotados de DDD*: cada contexto acotado tiene su propio modelo y
  lenguaje; se integran a través de capas anti-corrupción y lenguaje publicado,
  previniendo que cambios internos se filtren (desacoplamiento semántico).
- *Principio de Inversión de Dependencias (PID)*: los módulos de alto nivel no
  deberían depender de módulos de bajo nivel; ambos deberían depender de
  abstracciones; invierte el flujo tradicional de dependencias, haciendo la
  lógica de negocio central agnóstica a detalles de base de datos o framework.

**El espectro del acoplamiento — "No Todo o Nada":** el acoplamiento existe en
un espectro; el objetivo es a menudo "acoplamiento correcto" (no cero
acoplamiento, imposible), sino acoplamiento en conceptos estables y relevantes
al negocio.
- *Acoplamiento fuerte*: llamadas directas a base de datos desde la capa UI,
  tablas de base de datos compartidas entre servicios, referencias de
  biblioteca hardcodeadas.
- *Acoplamiento débil*: APIs RESTful con versionado, publicación asíncrona de
  eventos, uso de service mesh para comunicación.
- *Dimensiones de desacoplamiento*: se puede desacoplar en tiempo, espacio,
  tecnología y formato de datos.

**Compromisos y costos del acoplamiento débil:**
- *Sobrecarga operacional*: más partes móviles (intermediarios de mensajes,
  descubrimiento de servicios).
- *Latencia*: la comunicación indirecta (vía intermediario) añade milisegundos.
- *Consistencia eventual*: en sistemas dirigidos por eventos, los datos no son
  inmediatamente consistentes en todas partes; es una decisión de diseño, no
  solo una desventaja.
- *Depuración y trazabilidad*: seguir una solicitud a través de una cadena de
  eventos asíncronos es más difícil que una pila de llamadas monolítica.

**Beneficios: habilitando cualidades arquitectónicas:**
- *Mantenibilidad y evolucionabilidad*: el cambio está aislado (ej., se puede
  reescribir un servicio en Go mientras el resto están en Java).
- *Escalabilidad*: los componentes pueden escalarse independientemente según la
  carga.
- *Resistencia*: las fallas están contenidas (ej., un servicio de inventario
  que falle no debería derribar el proceso de checkout; podría encolar órdenes
  o mostrar "temporalmente no disponible").
- *Autonomía del equipo (Ley de Conway)*: el acoplamiento débil permite la
  independencia del equipo; los equipos pueden poseer, desplegar y operar sus
  servicios con coordinación mínima.
- *Facilidad de prueba*: los componentes pueden probarse de forma aislada
  usando mocks y stubs de sus dependencias.

**Errores comunes y conceptos erróneos (acoplamiento débil):**
- *Sobre-ingeniería*: no construir una arquitectura de microservicios dirigida
  por eventos para el panel de administración de una startup de 3 personas;
  comenzar con un monolito modular que practique acoplamiento débil a nivel de
  código/API.
- *Consistencia eventual*: recordar que es una decisión de diseño.
- *Latencia y depuración/trazabilidad*: repetidos como compromisos ya
  mencionados.

**Implicaciones del estilo arquitectónico (acoplamiento débil):**
- *Microservicios*: el acoplamiento débil es el objetivo principal; sin él, se
  obtiene un monolito distribuido, "lo peor de ambos mundos".
- *Monolito modular*: el acoplamiento débil existe a nivel de módulo/paquete,
  reforzado por límites en tiempo de compilación; es un "campo de
  entrenamiento" para la disciplina.
- *SOA*: enfatiza el acoplamiento débil a través de buses de servicios
  empresariales (ESB), aunque los ESB tradicionales pueden convertirse en
  puntos centrales de acoplamiento.
- *Arquitectura por capas (N-Tier)*: tradicionalmente más acoplada; aplicar el
  Principio de Inversión de Dependencias y límites de interfaz entre capas
  (ej., entre Lógica de Negocio y Acceso a Datos) introduce acoplamiento débil
  vital.

**Conclusión (acoplamiento débil):** El acoplamiento débil es un reconocimiento
de la incertidumbre y el cambio; es la materialización arquitectónica de "diseña
para el cambio". No se trata de hacer las conexiones más complejas; se trata de
hacer el cambio seguro y local. Es la diferencia entre un castillo de naipes y
una cúpula geodésica: uno colapsa con un solo toque, la otra distribuye el
estrés y permanece en pie.

### Independencia de Servicios

**Definición:** El grado al cual un servicio puede funcionar, ser desplegado y
evolucionar sin requerir coordinación síncrona, disponibilidad o versiones
específicas de otros servicios. No se trata de *no* tener dependencias, sino de
gestionarlas de manera asíncrona y defensiva.

**Dimensiones de la Independencia de Sistemas (Dimensions of System
Independence, en inglés en el material):**
- *Data Independence*: asegura que la gestión y acceso a datos pueda ocurrir sin
  verse afectados por cambios en estructuras de datos subyacentes.
- *Developmental & Deployment Independence*: asegura que los sistemas puedan
  desarrollarse y desplegarse sin interdependencias.
- *Communication Independence*: facilita la interacción fluida entre
  componentes sin acoplamiento fuerte.
- *Runtime & Operational Independence*: permite que los sistemas operen
  autónomamente durante la ejecución.

**Independencia de Desarrollo y Despliegue:**
- *Propiedad*: un solo equipo pequeño posee el ciclo de vida completo (código,
  datos, despliegue, ops) del servicio.
- *CI/CD*: puede construir, probar y desplegar el servicio independientemente,
  sin desencadenar una cascada de despliegues en otros servicios.
- *Elección de tecnología*: libertad para usar el lenguaje, framework y almacén
  de datos más apropiado para el dominio del servicio (dentro de directrices
  organizacionales).

**Independencia de Tiempo de Ejecución y Operacional:**
- *Resistencia*: debe continuar proporcionando su funcionalidad principal
  incluso si los servicios dependientes están caídos o lentos (mediante
  patrones como Circuit Breakers, Bulkheads, Fallbacks).
- *Localidad de datos*: posee su almacén de datos privado y autoritativo; no
  comparte base de datos directamente con otros servicios.
- *Estado aislado*: no depende de estado de tiempo de ejecución compartido
  (ej., datos de sesión en caché centralizada) que crea un punto de
  acoplamiento en tiempo de ejecución.

**Independencia de Comunicación:**
- *Preferencia asíncrona primero*: preferir comunicación asíncrona basada en
  eventos (pub/sub, streaming de eventos) sobre solicitud/respuesta síncrona
  (REST, gRPC); los eventos desacoplan el tiempo de producción y consumo.
- *Capa Anti-Corrupción (ACL)*: usa un modelo interno, traduciendo hacia/desde
  contratos externos; protege al servicio de cambios en dependencias externas.
- *Estabilidad de contrato*: publica APIs bien definidas, versionadas y
  retrocompatibles (REST) o esquemas (eventos); los consumidores no deben
  fallar con cambios no disruptivos.

**Independencia de Datos:**
- *Alineación de Contexto Delimitado (DDD)*: el modelo de datos del servicio
  está perfectamente delimitado a su responsabilidad específica del dominio de
  negocio, con mínima superposición.
- *Datos Derivados y CQRS*: para datos necesarios de otros dominios, puede
  mantener una copia local derivada (modelo de lectura/caché desnormalizada)
  actualizada vía eventos, eliminando llamadas síncronas "datos bajo demanda".

**Patrones arquitectónicos que habilitan la independencia:**
- *Arquitectura Basada en Eventos (EDA)*: el pináculo del desacoplamiento en
  tiempo de ejecución; los servicios difunden cambios de estado como hechos
  (eventos); las partes interesadas reaccionan independientemente.
- *API gateway / BFF*: maneja preocupaciones transversales (autenticación,
  enrutamiento, agregación) en el borde, liberando a los servicios internos.
- *Patrón Saga*: gestiona transacciones de negocio distribuidas de larga
  duración sin bloqueos distribuidos/2PC, usando una serie de eventos
  compensatorios si es necesario.
- *Service mesh*: descarga la resistencia de comunicación (reintentos,
  timeouts, circuit breaking) y observabilidad a la capa de infraestructura.

**Principios rectores para la implementación (independencia de servicios):**
- Comenzar con contextos delimitados: definir límites de servicio basados en
  capacidades de negocio (DDD), no capas técnicas; la independencia es un medio
  para la agilidad de negocio, no un objetivo técnico en sí mismo.
- Priorizar rutas críticas: aplicar patrones de resistencia (circuit breakers,
  etc.) primero en los viajes de usuario más críticos; no toda dependencia
  necesita un conjunto completo de independencia.
- Adoptar comunicación asíncrona por defecto: preguntar "¿esta interacción
  necesita una respuesta inmediata, o puede ser un acuse de recibo seguido de
  un evento?"
- Versionar desde el día uno: asumir que las APIs y esquemas de eventos
  cambiarán; tener una estrategia de versionado desde el primer lanzamiento.
- Invertir en observabilidad: con la independencia viene la complejidad
  distribuida; se debe tener excelente logging (con IDs correlacionados),
  métricas y trazado distribuido.

**Conclusión (independencia de servicios):** La Independencia de Servicios es un
espectro, no un estado binario. El objetivo no es la independencia absoluta
(imposible en un sistema de sistemas), sino la independencia óptima, suficiente
para lograr velocidad de equipo, resistencia del sistema y escalabilidad
deseadas, gestionando conscientemente el "impuesto de complejidad".

**Prueba definitiva propuesta por el material:** ¿Puede el Equipo A desplegar su
servicio, durante horas laborales, sin coordinarse con el Equipo B, y con cero
tiempo de inactividad o funcionalidad degradada para sus usuarios? Si es así, se
ha logrado un alto grado de Independencia de Servicios. Esta filosofía aplica
tanto a microservicios bien implementados como a monolitos modulares bien
estructurados o sistemas SOA.

### Datos en Arquitectura de Microservicios

**Definición:** Conjunto de principios y patrones para gestionar datos cuando
cada microservicio posee su propio almacén de datos, en contraposición a una
base de datos monolítica compartida.

**Soberanía de Datos y Desacoplamiento:** el objetivo principal es que cada
servicio posea sus datos (piedra angular de la autonomía de microservicios).
- *Base de datos por servicio*: cada servicio tiene su almacén de datos privado
  (esquema, tabla o incluso una instancia de base de datos separada); ningún
  otro servicio puede acceder directamente a él (ej., vía JOINs). Previene el
  acoplamiento fuerte en la capa de datos.
- *Tecnología de almacenamiento apropiada (Persistencia Políglota)*: libertad
  para elegir el mejor almacén de datos según las necesidades del servicio: ej.,
  PostgreSQL para transacciones ACID, MongoDB para documentos JSON,
  Elasticsearch para búsquedas, Neo4j para relaciones.

**Desafíos clave y patrones:**
- *Consistencia de Datos — Patrón Saga*: las transacciones distribuidas
  clásicas (2PC) son impracticables e indeseables. Solución: Sagas, una
  secuencia de transacciones locales, cada una actualizando los datos privados
  de un servicio; si un paso falla, se disparan transacciones compensatorias
  ("deshacer") para revertir la operación de negocio general. Compromiso: se
  pasa de consistencia fuerte a consistencia eventual; el diseño del sistema y
  la UX deben acomodar esto.
- *Consulta de Datos — Composición de API y CQRS*: cómo recuperar datos que
  abarcan múltiples servicios (ej., "Historial de Pedidos con Detalles del
  Cliente") sin llamadas ineficientes punto a punto ni acceso directo ilegal a
  la BD.
  - *Composición de API*: un servicio de consultas ligero (o API Gateway) llama
    a múltiples servicios y agrega los resultados; bueno para consultas
    simples.
  - *CQRS (Segregación de Responsabilidades de Comando y Consulta)*: para
    consultas complejas, crea una vista de datos separada, optimizada para
    lectura ("modelo de lectura"); los servicios publican eventos de dominio
    (ej., `PedidoEnviado`, `DirecciónClienteActualizada`), y un proceso
    separado se suscribe a estos eventos para construir y mantener una vista
    desnormalizada. Es el patrón más escalable, pero también el más complejo.
- *Sincronización de Datos y Eventos — "La Columna Vertebral"*: cómo mantener
  sincronizados los datos de los servicios sin acceso directo a la BD ni
  acoplamiento fuerte. Los Eventos de Dominio se convierten en el sistema de
  registro para "por qué cambiaron los datos". Un registro de eventos (a
  menudo vía un Message Broker como Kafka o RabbitMQ) es el "sistema
  circulatorio" de la arquitectura. El Event Sourcing puede utilizarse, donde
  el estado de una entidad se determina reproduciendo una secuencia de
  eventos; proporciona un registro de auditoría por diseño y se integra
  naturalmente con el ecosistema de microservicios basado en eventos.
- *Reportes y Análisis — El Data Lake / Warehouse*: las herramientas de BI
  tradicionales no pueden consultar cien bases de datos diferentes. Solución:
  usar streaming de eventos para publicar todos los cambios de datos
  relevantes a un Data Lake o Warehouse central (ej., vía Kafka Connect a
  Snowflake/BigQuery); es la única forma sancionada de "datos centralizados",
  una copia analítica de solo lectura, desacoplada de los sistemas
  operacionales.

**Compromisos y consideraciones críticas (datos en MSA):**
- *Complejidad*: la complejidad operacional y de desarrollo es inmensa; se está
  construyendo un sistema distribuido; debugging, tracing y monitoreo no son
  opcionales.
- *Experiencia del desarrollador*: las consultas simples se convierten en
  problemas de sistemas distribuidos; los desarrolladores deben pensar en
  términos de eventos, consistencia eventual y límites de servicios.
- *Gobernanza de datos y seguridad*: hacer cumplir políticas de datos,
  cumplimiento de PII y control de acceso a través de docenas de almacenes de
  datos es un desafío significativo; requiere propiedad clara y a menudo
  herramientas centralizadas para gestión de secretos y auditoría.
- *Diseño de límites*: es la decisión arquitectónica más importante. Los
  límites de servicios mal definidos (y por tanto límites de datos) llevan al
  "infierno del monolito distribuido", donde los servicios son charlatanes y
  están fuertemente acoplados. Usar DDD para identificar Contextos
  Delimitados, que deben alinearse perfectamente con los límites de propiedad
  de servicios y datos.

**Evolución del pensamiento (industria, sobre datos en MSA):**
- *Fase temprana (ingenua)*: "simplemente dividamos la base de datos del
  monolito y veamos qué pasa" → lleva al desastre.
- *Fase centrada en patrones*: adopción masiva de Saga, CQRS, Event Sourcing;
  resolvió problemas pero a veces sobre-ingenierizó.
- *Fase pragmática (actual)*: fuerte énfasis en comenzar con un monolito si el
  dominio no está claro; definir contextos delimitados primero; usar
  comunicación síncrona (llamadas API) solo para necesidades verdaderamente
  síncronas, prefiriendo eventos asíncronos para coordinación entre estados;
  abrazar la consistencia eventual donde el negocio lo permita (no todo
  necesita una saga); considerar un monolito modular como alternativa viable
  si el tamaño del equipo/dominio no justifica la sobrecarga.

**Conclusión (datos en MSA):** En microservicios, los datos son locales, no
globales. La arquitectura está diseñada alrededor del flujo y propiedad de
datos, no alrededor de un esquema compartido y centralizado. El éxito depende
de: (1) límites de servicios correctos (DDD); (2) abrazar los eventos como
ciudadanos de primera clase para propagación de datos; (3) aceptar compromisos
en consistencia y complejidad; (4) invertir fuertemente en observabilidad,
visualización de flujo de datos y herramientas para desarrolladores. El cambio
es de diseñar "una base de datos con servicios adjuntos" a diseñar "un sistema
de servicios colaboradores, cada uno con sus propios datos privados".

### Diseñando APIs para Comunicación Inter-Servicios

**Definición:** Conjunto de principios, patrones y prácticas para diseñar las
APIs mediante las cuales los microservicios se comunican entre sí.

**Por qué importa:** las arquitecturas de microservicios dependen de canales de
comunicación eficientes y robustos para entregar funcionalidad de negocio
fluida a través de sistemas distribuidos. La calidad de las APIs
inter-servicios impacta directamente la confiabilidad, rendimiento y
mantenibilidad del sistema. Las APIs mal diseñadas crean deuda técnica que se
acumula con el tiempo, llevando a fallas en cascada, picos impredecibles de
latencia y desafíos de mantenimiento que pueden paralizar la velocidad de
desarrollo.

**Tres objetivos clave:** Resistencia (aislar fallas y degradar con elegancia),
Rendimiento (minimizar latencia y uso de recursos), Mantenibilidad (simplificar
evolución y depuración). Validación del mundo real citada: la transformación de
microservicios de Netflix demuestra que el diseño cuidadoso de comunicación es
un factor crítico de éxito, no una ocurrencia tardía.

**Comunicación Síncrona vs Asíncrona (comparación):**

| Aspecto | Síncrona | Asíncrona |
|---|---|---|
| Patrón | Solicitud-respuesta (REST, gRPC), interacciones en tiempo real con retroalimentación inmediata | Mensajería dirigida por eventos (Kafka, RabbitMQ) |
| Acoplamiento | Acoplamiento fuerte entre servicios | Acoplamiento débil, mejora la flexibilidad |
| Latencia | Mayor sensibilidad a la latencia | Modelos de datos eventualmente consistentes |
| Depuración | Depuración y rastreo más simples | Complejidad arquitectónica añadida |

**Nota del material:** el estilo de comunicación correcto depende del caso de
uso específico, requisitos de rendimiento y tolerancia para escenarios de
falla.

**El Desafío de Resistencia en las Llamadas Entre Servicios:** en sistemas
distribuidos, los servicios inevitablemente fallan debido a crashes,
agotamiento de recursos o particiones de red. Construir APIs resistentes
requiere patrones de diseño proactivos:
- *Reintentos con Retroceso Exponencial (Exponential Backoff)*: manejar fallas
  transitorias automáticamente, pero asegurar que las operaciones sean
  idempotentes para evitar efectos secundarios no deseados de solicitudes
  duplicadas.
- *Disyuntores (Circuit Breakers)*: detectar servicios no saludables y fallar
  rápidamente, previniendo fallas en cascada que pueden derribar regiones
  enteras del sistema.
- *Timeouts y Mamparos (Bulkheads)*: aislar fallas y prevenir que servicios
  lentos agoten recursos necesarios para componentes saludables.

Nota citada: la arquitectura de referencia de microservicios de Azure enfatiza
estos patrones de resistencia como requisitos fundamentales, no mejoras
opcionales.

**Principios de Diseño de API para Microservicios:**
- *Responsabilidad Única*: cada API debe dirigirse a una capacidad de negocio
  clara, permitiendo que los equipos posean y evolucionen servicios
  independientemente.
- *Consistencia*: establecer convenciones uniformes para nomenclatura,
  versionado, manejo de errores y formatos de respuesta en todas las APIs.
- *Sin Estado*: diseñar APIs sin dependencias de sesión del lado del servidor,
  habilitando escalamiento horizontal y despliegue simplificado.
- *Compatibilidad Hacia Atrás*: evolucionar APIs sin romper clientes
  existentes, mediante estrategias cuidadosas de versionado y obsolescencia.
- *Comunicación Ligera*: preferir formatos de serialización eficientes como
  JSON o Protocol Buffers, a menos que requisitos específicos demanden
  protocolos más pesados.

**Patrones de Soporte para Diseño de API:**
- *Patrón API Gateway*: proporciona un punto de entrada único que enruta
  inteligentemente solicitudes, agrega respuestas de múltiples servicios y
  transforma datos para diversas necesidades de clientes. Ejemplo citado: el
  API Gateway de Netflix personaliza respuestas específicamente para
  aplicaciones móviles, navegadores web e integraciones de terceros.
- *Service Mesh*: maneja preocupaciones transversales como descubrimiento de
  servicios, balanceo de carga, encriptación y observabilidad de manera
  transparente en la capa de infraestructura, permitiendo que los equipos de
  desarrollo se enfoquen en la lógica de negocio.

**Combinando Fortalezas de Comunicación:** las arquitecturas más robustas
combinan estratégicamente patrones síncronos y asíncronos, aprovechando cada
enfoque donde sobresale:
- *Síncrono para necesidades inmediatas*: usar APIs de solicitud-respuesta
  cuando los clientes requieren datos inmediatos o confirmación.
- *Asíncrono para desacoplamiento*: publicar eventos para consistencia eventual
  y flujos de trabajo que no requieren finalización instantánea.

**Ejemplo práctico (del material):** un Servicio-Estudiante hace una llamada
síncrona al Servicio-Libros para verificar disponibilidad en tiempo real.
Después del préstamo, publica un evento "Estudiante Prestó Libro" de forma
asíncrona, permitiendo que el Servicio-Notificación envíe correos sin bloquear
la transacción.

**Errores Arquitectónicos Comunes (diseño de APIs):**
- *APIs charlatanas / sobre-obtención (chatty / over-fetching)*: conduce a bajo
  rendimiento. Solución: diseñar para casos de uso específicos, considerar BFFs
  o GraphQL.
- *Acoplamiento temporal estrecho*: los servicios deben estar disponibles
  simultáneamente. Solución: introducir patrones asíncronos, colas.
- *Modelos/librerías de API compartidos*: crea acoplamiento en tiempo de
  despliegue; un cambio requiere despliegues coordinados. Recomendación:
  preferir SDKs de cliente generados por el consumidor desde una
  especificación, o aceptar duplicación.
- *Ignorar fallas parciales*: el "camino feliz" no es el único camino; diseñar
  lógica de reintento, timeouts y respaldos (fallbacks).
- *Filtración de datos*: exponer IDs internos, detalles de implementación, o
  campos que deberían estar ocultos.

**Recomendación Evolutiva (conclusión del tema y del documento):** comenzar con
REST/gRPC síncronos para interacciones claras y delimitadas donde la
simplicidad es clave. A medida que el sistema escala y los flujos de trabajo se
vuelven más complejos, introducir estratégicamente comunicación asíncrona
dirigida por eventos para desacoplamiento y resistencia. La API "correcta" no
es una sola tecnología sino una mezcla heterogénea elegida para el contexto.

**Mantra arquitectónico final (cita literal del material):** "Diseña APIs para
el consumidor, no para el proveedor. Diseña para el cambio, no para la
perfección. Diseña para el fallo, porque va a suceder." Esta mentalidad asegura
que el ecosistema de servicios permanezca adaptable y robusto mientras crece.

## Procedimientos o procesos

### Practical Heuristics & Process (heurísticas prácticas para descomposición de dominio)

Proceso de 4 pasos presentado en el material (en inglés, dentro de un diagrama):
1. **Start with Monolith**: comenzar con un monolito modular bien estructurado
   para entender el dominio.
2. **Identify Seams**: buscar diferencias en tasas de cambio, escalabilidad,
   seguridad y límites de ciclo de vida.
3. **Define APIs**: diseñar las APIs de servicio antes de la implementación
   para enfocarse en contratos y capacidades.
4. **Embrace Event Storming**: usar talleres colaborativos para descubrir
   contextos delimitados y límites de agregados.

## Comparaciones

### Comparación de patrones arquitectónicos de Separación de Responsabilidades

| Patrón | Eje de separación | Preocupación central | Regla de separación |
|---|---|---|---|
| Arquitectura en Capas (n-Niveles) | Horizontal, por responsabilidad técnica | Presentación, Lógica de Negocio, Acceso a Datos, Base de Datos | Una capa solo depende de la capa inmediatamente inferior |
| Arquitectura Limpia / Hexagonal | Dirección de dependencia | Reglas de negocio y entidades (núcleo estable) | Las dependencias apuntan hacia adentro; el núcleo no depende de frameworks, BD ni UI |
| Arquitectura de Microservicios | Vertical, por dominio de negocio/capacidad | Cada servicio posee una función de negocio específica | Servicios desplegables independientemente, con su propia lógica, datos y UI |
| SOA | Servicios discretos e interoperables | Integración empresarial | Protocolos de comunicación compartidos, a menudo vía ESB |

### Comunicación Síncrona vs Asíncrona

| Aspecto | Síncrona (REST, gRPC) | Asíncrona (Eventos/Mensajes) |
|---|---|---|
| Uso típico | Consultas y comandos con necesidad de respuesta inmediata | Estándar dorado para lograr acoplamiento débil entre servicios |
| Acoplamiento | Acoplamiento en tiempo de ejecución / fuerte | Acoplamiento débil, desacoplamiento temporal |
| Sensibilidad a latencia | Alta | Menor (consistencia eventual) |
| Depuración | Más simple | Más compleja (trazado distribuido necesario) |

### Escalabilidad vs Elasticidad

| Aspecto | Escalabilidad | Elasticidad |
|---|---|---|
| Naturaleza | Propiedad arquitectónica (diseño estructural) | Capacidad operacional (comportamiento en tiempo de ejecución) |
| Horizonte | Crecimiento planificado, capacidad base a largo plazo | Ajuste flexible y temporal ante demanda impredecible |
| Analogía | Comprar una mesa más grande | Tomar sillas extra cuando llegan invitados |
| Patrón gráfico citado | Crecimiento escalonado sostenido en el tiempo | Fluctuación de demanda con picos y valles |

### Buenos patrones vs Anti-patrones de descomposición de dominio

| Buen patrón | Anti-patrón equivalente/relacionado | Problema del anti-patrón |
|---|---|---|
| Descomponer por capacidad de negocio/subdominio | Descomponer por capa técnica | Acoplamiento fuerte y redes charlantes |
| Descomponer por sustantivo (con precaución) | Servicios de Entidad de grano grueso (ej. UserService monolítico) | Lleva a monolito distribuido |
| Patrón de estrangulamiento | — | — |
| Especificaciones compartidas (clientes API, esquemas de eventos) | Librerías "comunes" compartidas con lógica de negocio pesada | Acoplamiento explosivo |

## Información visual relevante

### Diagrama: Layers in a Domain-Driven Design Microservice

Diagrama (en inglés, fuente Microsoft Learn) que muestra la estructura de
carpetas de un microservicio "Ordering" con tres proyectos: `Ordering.API`
(Application layer), `Ordering.Domain` (Domain model layer) y
`Ordering.Infrastructure` (Infrastructure layer), con flechas que apuntan desde
cada capa listada hacia el proyecto correspondiente. Ilustra la separación
física en código de las responsabilidades DDD dentro de un solo microservicio.

### Diagrama: Separation of Concerns - Architectural Patterns Comparison

Comparación visual de tres estilos: Layered (n-Tier) con flujo de dependencia
vertical descendente (Presentation → Business Logic → Data Access → Database);
Clean/Hexagonal (Ports & Adapters) con círculos concéntricos (Domain en el
centro, rodeado por Application Layer, rodeado por adaptadores UI/API/DB/Ext.
Service, con dependencias apuntando hacia adentro); Microservices, mostrando
User Service, Order Service y Payment Service, cada uno con sus propias capas
internas (API, Business Logic, Data Access, DB) conectados entre sí y a un API
Gateway/Service Mesh, señalando "preocupaciones independientes y distribuidas".

### Diagrama: Scalability in Cloud Computing vs Elasticity

Dos gráficos de demanda en el tiempo: el de Escalabilidad muestra una curva
ascendente escalonada y sostenida (crecimiento incremental permanente); el de
Elasticidad muestra fluctuaciones irregulares hacia arriba y abajo (picos y
valles de demanda que se ajustan y liberan).

### Diagrama: Saga Design Pattern

Diagrama que muestra un flujo "NEW ORDER" pasando por un Message Broker hacia
Order Service, Payment Service y Shipping Service secuencialmente, cada uno con
su propia base de datos, ilustrando la secuencia de transacciones locales que
compone una Saga.

### Diagrama: Smart End Points, Dumb Pipes (matriz 2x2)

Matriz que cruza "Producers" (Smart/Dumb) con "Consumers" (Smart/Dumb),
generando cuatro cuadrantes: Genius Consumer (pipe dumb, consumer hace todo el
trabajo — lento para equipos consumidores), Genius Pipe (pipe necesita conocer
todos los endpoints — costoso de operar, requiere su propio equipo), Dumb Pipe
(cuadrante recomendado: los endpoints transforman a un contrato común, bajo
costo de operar la tubería), Genius Producer (el productor hace todo el
trabajo — lento para equipos productores).

### Diagrama: Data in Traditional approach vs Data in Microservices approach

Comparación visual entre un enfoque tradicional (base de datos monolítica
única, niveles de tecnologías específicas: Web Tier, Services Tier, Cache Tier,
Data Tier) y el enfoque de microservicios (grafo de microservicios
interconectados, estado típicamente delimitado al microservicio,
almacenamiento remoto para datos fríos; servicios stateless y stateful, cada
microservicio posee su propio modelo/datos).

## Terminología importante

- **Microservicio**: servicio pequeño y autónomo que realiza una función de
  negocio, se comunica vía APIs y se despliega independientemente.
- **Contexto Delimitado (Bounded Context)**: límite claro dentro del cual un
  modelo de dominio particular es consistente y aplicable; patrón central de
  DDD y candidato principal para un límite de servicio.
- **Lenguaje ubicuo**: lenguaje compartido entre desarrolladores y expertos de
  dominio, codificado en la API y el modelo interno del servicio.
- **Subdominio Núcleo/Genérico/Soporte**: clasificación estratégica de DDD para
  priorizar inversión en el diseño de servicios.
- **Ley de Conway**: principio según el cual la estructura del software refleja
  la estructura de la organización que lo construye.
- **Maniobra Conway Inversa**: alinear intencionalmente la estructura de
  equipos con los límites de servicio deseados.
- **Monolito distribuido**: anti-patrón donde servicios están fuertemente
  acoplados y deben desplegarse juntos, obteniendo la complejidad de los
  microservicios sin sus beneficios.
- **Base de Datos Compartida**: anti-patrón de acoplamiento definitivo entre
  servicios.
- **Comunicación Parlanchina (Chatty)**: anti-patrón de APIs de grano fino que
  causan alta latencia y acoplamiento estrecho.
- **Patrón de estrangulamiento (Strangler Pattern)**: técnica de migración
  gradual de un monolito a servicios, extrayendo funcionalidad rebanada por
  rebanada.
- **Circuit Breaker**: patrón de resistencia que detiene las llamadas a un
  servicio que está fallando.
- **Bulkhead**: patrón que aísla recursos (pools, conexiones) para contener
  fallas.
- **Degradación Elegante**: diseño de clientes para operar con datos parciales
  o funcionalidad reducida ante fallas.
- **Saga**: patrón para gestionar transacciones de negocio distribuidas de
  larga duración mediante una secuencia de transacciones locales y acciones
  compensatorias, en lugar de 2PC.
- **CQRS (Command Query Responsibility Segregation)**: patrón que separa las
  operaciones de escritura (comandos) de las de lectura (consultas),
  habilitando modelos de lectura optimizados y desnormalizados.
  (En español en el material: "Segregación de Responsabilidades de Comando y
  Consulta").
- **Event Sourcing**: patrón donde el estado de una entidad se determina
  reproduciendo una secuencia de eventos, proporcionando registro de auditoría
  por diseño.
  - **Capa Anti-Corrupción (ACL)**: capa de traducción que protege el modelo
    interno de un servicio de los cambios en contratos/dependencias externas.
- **Principio de Inversión de Dependencias (PID)**: los módulos de alto y bajo
  nivel deben depender de abstracciones, no uno del otro directamente.
- **Persistencia Políglota**: elección de la tecnología de almacenamiento más
  adecuada por servicio (SQL, NoSQL documental, grafos, motores de búsqueda,
  etc.).
- **Consistencia eventual**: modelo de consistencia donde los datos no están
  sincronizados de inmediato en todo el sistema, sino que convergen con el
  tiempo; es una decisión de diseño explícita en sistemas distribuidos.
- **Rebaño Estruendoso (Thundering Herd)**: problema donde escalar componentes
  sin resolver un cuello de botella subyacente (ej. base de datos monolítica)
  empeora la situación.
- **API Gateway**: punto de entrada único que enruta, agrega y transforma
  solicitudes hacia/desde múltiples servicios.
- **BFF (Backend for Frontend)**: variante de API Gateway especializada por
  tipo de cliente/consumidor.
- **Service Mesh**: capa de infraestructura que gestiona de forma transparente
  descubrimiento de servicios, balanceo de carga, encriptación y
  observabilidad entre servicios.
- **Observabilidad**: capacidad de entender el comportamiento interno de un
  sistema distribuido a través de trazado distribuido, logging centralizado y
  métricas, más allá del monitoreo tradicional.
- **Endpoints inteligentes, tuberías simples**: principio de mantener la
  lógica de negocio en los servicios y la infraestructura de mensajería lo más
  simple posible.
- **Escalamiento vertical/horizontal**: aumentar recursos de una máquina
  existente vs. añadir más máquinas en paralelo.
- **Elasticidad**: capacidad de ajustar recursos de forma automática y
  temporal en respuesta a fluctuaciones de demanda en tiempo real.
- **Independencia de Servicios**: grado al que un servicio puede funcionar,
  desplegarse y evolucionar sin coordinación síncrona con otros servicios.

## Notas y advertencias

- El material presenta la sección "Definiendo Elasticidad" con una diapositiva
  cuyo título indica "(cont.)" sin que se haya podido capturar de forma
  independiente una diapositiva inicial con una definición formal de una sola
  frase para "Elasticidad" (análoga a la que sí existe para "Escalabilidad").
  El concepto de elasticidad queda de todos modos suficientemente definido de
  forma indirecta a través de sus características (Respuesta en Tiempo Real,
  Inteligencia Automatizada), la analogía de la cena, y la "Distinción clave"
  explícita entre escalabilidad y elasticidad. Se registra como limitación
  menor de cobertura, no como ambigüedad del contenido en sí.
- El documento reutiliza el encabezado "Conclusiones" en al menos tres
  secciones distintas del material (Escalabilidad y Elasticidad; Acoplamiento
  Débil; Independencia de Servicios), cada una con contenido propio y
  específico a su sección; no se trata de contenido duplicado sino de un
  patrón de cierre repetido en cada bloque temático del documento.
- Varias diapositivas de diagramas e infografías del material están en inglés
  (ej. "Core Pillars of Microservices Architecture", "Dimensions of System
  Independence", "Smart End Points, Dumb Pipes", "Key Principles of
  Microservices", "Layers in a Domain-Driven Design Microservice"), aunque el
  texto explicativo circundante está en español; se preservaron los términos
  originales en inglés donde el material los usa así.
- El material cita explícitamente varias fuentes externas (Microsoft Learn,
  ByteByteGo, akfpartners, Medium, GeeksforGeeks, Qlik, Estuary, dev.pro,
  Wikipedia, acompiler.com) como origen de diagramas e infografías; estas
  fuentes no fueron verificadas de forma independiente, solo se documenta que
  el material las referencia.
- Algunas cifras concretas sobre Netflix (10K+ microservicios, 99.9% de tiempo
  activo, 30% de ahorro de costos, 230 millones de suscriptores) se presentan
  en el material como hechos de referencia sin fuente primaria adicional más
  allá de la mención genérica al caso de Netflix; se registran tal como
  aparecen en la diapositiva, sin validación adicional.
- El documento no profundiza en el "por qué" técnico detrás de algunos
  términos mencionados de pasada sin desarrollo propio, como "ADO.NET",
  "Dapper", "OpenTelemetry", "Jaeger", "Terraform", "CloudFormation", "Pact",
  "Kafka Connect", "Snowflake/BigQuery", "Neo4j": se mencionan como ejemplos de
  herramientas concretas dentro de una explicación más amplia, sin que el
  material explique su funcionamiento interno.
- La diapositiva final "Combinando Fortalezas de Comunicación" incluye un
  diagrama circular con texto parcialmente distorsionado/con errores
  tipográficos evidentes en el original (ej. "Asynnchronation",
  "Synchroncoous", "Synnromous Communication Asynchtoomoncation", "Collond");
  se documenta como limitación de legibilidad del elemento visual original,
  no como error de transcripción propio.
