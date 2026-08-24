# Semana 7: Arquitectura de Microservicios III (AMM III)

## Resumen del contenido

Este documento corresponde a las diapositivas de la Semana 7 del curso Arquitectura
de Software 3 (Jala University). El objetivo declarado de la semana es "dominar los
conceptos fundamentales para diseñar y construir microservicios efectivos: desde
patrones arquitectónicos y límites de Domain-Driven Design hasta prácticas de
desarrollo nativo en la nube". El material se organiza en cuatro grandes bloques:
(1) un repaso de los principios de diseño de microservicios vistos en la Semana 6
(AMM II); (2) un catálogo de patrones de arquitectura de microservicios agrupados en
patrones de interacción, gestión de datos y resistencia; (3) la relación entre
Arquitectura de Microservicios y Diseño Dirigido por Dominio (DDD), incluyendo
límites de servicio, mapeo de contextos y agregados; y (4) una introducción breve a
la metodología "12-Factor App" y, como material complementario, un desarrollo
extenso de estrategias de despliegue (azul-verde, canario, gradual).

## Conceptos clave

### Principios de diseño de microservicios (repaso de AMM II)

**Definición:** Conjunto de principios rectores para modelar, separar, escalar,
acoplar y desplegar microservicios.

**Características (listadas en el repaso):**
- Modelado alrededor del dominio de negocio (Domain-Driven Design).
- Descentralizar todo.
- Cultura de automatización.
- Aislar las fallas.
- Capacidad de despliegue independiente.
- Contratos centrados en el consumidor.
- Observabilidad, no solo monitoreo.
- Endpoints inteligentes y pipes simples.
- Límites y descomposición: usar DDD (contextos delimitados), descomponer por
  capacidad de negocio (no por tecnología), alinear con la propiedad del equipo.
- Separación de responsabilidades: cortes verticales (cada servicio posee el stack
  completo), externalizar responsabilidades transversales (auth, logging),
  aislamiento funcional y operacional.
- Escalabilidad y elasticidad: escalado granular e independiente, sin estado para
  escalado horizontal, autoescalado basado en eventos.
- Bajo acoplamiento: interfaces sobre implementaciones, mensajería asíncrona
  preferida sobre llamadas síncronas, APIs versionadas con compatibilidad hacia
  atrás, sin bases de datos compartidas entre servicios.
- Independencia de servicios: base de datos por servicio, pipelines de CI/CD
  independientes, heterogeneidad tecnológica permitida, aislamiento de fallas.
- Gestión de datos: cada servicio posee sus datos, consistencia eventual con
  patrón Saga, persistencia políglota, aceptar compromisos en consistencia y
  complejidad, observabilidad y visualización del flujo de datos.
- Diseño de API: REST (común) o gRPC (rendimiento), consistencia, comunicación
  liviana, asíncrono para desacoplamiento (colas de mensajes/eventos).

**Compromiso clave señalado:** agilidad organizacional vs. complejidad operacional.

### Circuit Breaker (Cortacircuitos)

**Definición:** Patrón que previene fallos en cascada en sistemas distribuidos
monitoreando las interacciones de servicios y deteniendo las solicitudes a
servicios que están fallando.

**Explicación:** Trata la disponibilidad de servicios remotos como una
preocupación arquitectónica de primera clase. En lugar de propagar fallos a
través del sistema, el patrón hace que el sistema "falle rápido".

**Características:**
- Tres estados: Cerrado (normal: el servicio está sano, las solicitudes pasan
  normalmente, el contador de errores se reinicia tras un éxito), Abierto
  (falla rápido: las llamadas se cortan/short-circuited, se corre un temporizador
  de recuperación), Semi-abierto (periodo de prueba: permite un número limitado
  de llamadas de prueba, transiciona a Cerrado si tienen éxito, vuelve a Abierto
  si fallan).
- La transición de Cerrado a Abierto ocurre cuando la tasa de error supera un
  umbral (errorRate > threshold).
- Los estados del circuito se convierten en indicadores cruciales de la salud
  del sistema (integración con monitoreo).

**Relaciones:**
- Se combina a menudo con el Patrón Retry para lograr una resistencia integral
  entre servicios.

### Patrón Retry (Reintento)

**Definición:** Mecanismos de reintento inteligentes que manejan fallos
transitorios en sistemas distribuidos.

**Explicación:** Los fallos transitorios son inevitables en sistemas
distribuidos; los reintentos mejoran la resistencia del sistema.

**Características / aspectos críticos de implementación:**
- Backoff exponencial: previene tormentas de reintentos (el tiempo de espera
  crece exponencialmente entre intentos, ejemplo mostrado: t = 100*2^(i-1) ms).
- Jitter: aleatorización del tiempo de espera para evitar efectos rebaño
  (thundering herd).
- Idempotencia: esencial para que los reintentos sean seguros (una operación
  repetida no debe producir efectos secundarios adicionales).
- Estrategias de retraso ilustradas: retraso fijo (Fixed Delay), retraso
  incremental (Incremental Delay: t = i*100ms) y backoff exponencial.

**Relaciones:**
- Patrón estratégico: a menudo se combina con Circuit Breaker.

### API Gateway (Puerta de enlace API)

**Definición:** Sirve como punto de entrada único para todas las solicitudes del
cliente, abstrayendo la complejidad del ecosistema de microservicios.

**Explicación:** Va más allá del simple enrutamiento; implementa
preocupaciones transversales como autenticación, limitación de velocidad
(rate limiting) y traducción de protocolos.

**Características:**
- Impacto arquitectónico: permite flexibilidad de backend-para-frontend
  mientras presenta una interfaz unificada.
- Ventaja estratégica: centraliza preocupaciones transversales (autenticación,
  SSL, traducción HTTP/protocolo, auditoría, enrutamiento, agregación).
- Intercambio (trade-off): introduce un potencial punto único de falla que
  debe mitigarse mediante agrupación (clustering) y redundancia.
- Beneficio evolutivo: permite la evolución independiente de servicios internos
  sin romper los contratos del cliente.

**Relaciones:**
- API Gateway + BFF: los gateways a menudo hospedan lógica BFF o enrutan a
  servicios BFF dedicados.

### Backend-para-Frontend (BFF)

**Definición:** Patrón que aborda las necesidades específicas de API del
cliente creando backends personalizados para diferentes interfaces de usuario
(por ejemplo, Web y Mobile).

**Explicación:** Previene APIs "todo en uno" que obtienen demasiados datos
para clientes simples o muy pocos datos para clientes complejos.

**Características:**
- Impacto arquitectónico: cada experiencia de usuario se beneficia de su
  propia lógica personalizada de agregación y transformación de datos.
- Intercambio: puede llevar a duplicación de código/lógica; requiere el uso
  disciplinado de bibliotecas comunes cuando sea apropiado.
- Alineación organizacional: permite que equipos dedicados posean segmentos
  verticales completos de funcionalidad.
- Ejemplo del diagrama: Web App → Web BFF API Gateway → microservicios (vía
  REST); Mobile App → Mobile BFF API Gateway → microservicios (vía REST, gRPC,
  AMQP).

### Base de Datos por Servicio

**Definición:** Patrón que exige que cada microservicio posea su base de datos
privada.

**Explicación:** Refuerza límites reales de servicio evitando el acoplamiento
directo de bases de datos entre servicios.

**Características:**
- Ventaja estratégica: permite persistencia políglota — cada servicio puede
  usar la tecnología de base de datos más adecuada para sus necesidades
  (ejemplo del diagrama: Aurora, DynamoDB, SQL Server usados por distintos
  servicios de un mismo sistema).
- Intercambio: introduce desafíos de gestión de datos distribuidos.
- Imperativo de diseño: obliga a la definición explícita de propiedad de datos
  y límites de servicio.

**Relaciones:**
- Base de Datos por Servicio + SAGA: la independencia de datos requiere SAGAs
  para coordinar transacciones entre servicios.

### Patrón SAGA

**Definición:** Las SAGAs gestionan transacciones distribuidas a través de
límites de servicio.

**Explicación:** Mantienen la consistencia de datos sin usar transacciones
distribuidas (2PC). Adoptan la consistencia eventual como concepto
arquitectónico de primera clase.

**Características:**
- Dos enfoques:
  - **Coreografía**: basada en eventos, descentralizada; cada servicio publica
    y escucha eventos y decide su siguiente acción. Ventaja: descentralizado.
    Desventaja: más difícil de depurar (no hay un punto central que muestre el
    flujo completo).
  - **Orquestación**: un coordinador centralizado (ej. "Create Order Saga")
    dirige la secuencia de pasos mediante comandos a través de un message
    broker. Ventaja: más fácil de monitorear. Desventaja: introduce
    acoplamiento hacia el orquestador.
- Intercambio: requiere operaciones idempotentes y transacciones
  compensatorias (para revertir pasos ya ejecutados si un paso posterior
  falla, ej. Cancel Order, Reverse Payment, Reverse Inventory Update, Cancel
  Delivery).

**Ejemplo (Saga por Coreografía):** Flujo mostrado con Order Service y
Customer Service comunicándose mediante canales de eventos ("Order events
channel", "Customer events channel"): 1) POST /orders, 2) evento "Order
Created" publicado, 3) Customer Service reserva crédito ("Credit Reserved"),
4) si se excede el límite se publica "Credit Limit Exceeded", 5) Order Service
reacciona al evento.

**Ejemplo (Saga por Orquestación):** Order Controller → Order Service →
"Create Order Saga" → agregado Order; la Saga envía un "Reserve Credit
Command" a través de un Message Broker (con un "Customer Service Command
Channel" y un "Create Order Saga Reply channel") hacia un Command Handler que
invoca al Customer Service, el cual reserva crédito en su agregado Customer y
responde con "Reserve Credit Response"; la Saga entonces aprueba (approve())
el agregado Order.

**Relaciones:**
- Circuit Breaker + Retry: combinados para crear comunicación robusta
  servicio-a-servicio (patrón complementario de resistencia, no de datos).
- Base de Datos por Servicio + SAGA.

### Contextos Delimitados (Bounded Contexts) y límites de servicio

**Definición:** DDD define límites precisos de dominio empresarial llamados
Contextos Delimitados, proporcionando un marco natural para organizar
servicios.

**Explicación:** Los límites de servicio se trazan alrededor de capacidades
empresariales cohesivas, no solo capas técnicas; cada microservicio debe tener
un propósito y responsabilidad claros.

**Características (principios clave):**
- Si dos servicios interactúan intensamente, considerar fusionarlos.
- La autonomía es fundamental: los servicios deben operar independientemente
  sin dependencias síncronas.
- Los límites deben reflejar el lenguaje empresarial y la estructura
  organizacional.
- Mapeo natural de servicios: cada Contexto Delimitado se mapea directamente a
  un microservicio, permitiendo verdadera autonomía y ciclos de despliegue
  independientes.
- Complejidad reducida: la separación de responsabilidades reduce
  interdependencias y crea límites claros, haciendo los sistemas más fáciles
  de entender, probar, depurar y evolucionar.

**Ejemplo (diagrama monolito → microservicios):** Una "Monolithic
architecture" con módulos internos (User access, Shopping cart, Product
management, Payments, Reporting) se descompone en Contextos Delimitados
(Bounded Contexts: User Management, Shopping Cart, Product Management,
Payment, Reporting), cada uno mapeado a uno o más microservicios (ej. User
Management → User registration, Authentication, Authorization; Product
Management → Product Catalog, Inventory; Payment → Payments, Refunds;
Reporting → Sales reporting, User Activity Reporting).

### Heurísticas para definir límites de servicio

**Explicación:** Cuatro heurísticas propuestas para decidir dónde trazar los
límites de un microservicio:
1. Identificar dominios núcleo, subdominios de soporte y subdominios genéricos.
2. Analizar la velocidad de cambio — dominios con diferentes tasas de cambio
   a menudo se benefician de la separación.
3. Evaluar la estructura del equipo — la Ley de Conway sugiere que la
   organización influye en la arquitectura.
4. Evaluar límites transaccionales — dónde la consistencia debe ser inmediata
   vs. eventual.

### Anti-patrones de límites de servicio

**Definición:** Prácticas a evitar al definir los límites de un microservicio.

**Características (anti-patrones listados):**
- Límites dirigidos por datos: servicios definidos por tablas de base de datos
  en lugar de capacidades empresariales.
- Servicios orientados a CRUD: servicios anémicos que carecen de comportamiento
  de dominio.
- Divisiones técnicas arbitrarias: microservicios divididos por capas
  tecnológicas en lugar de dominios.

### Mapeo de Contextos (Context Mapping)

**Definición:** Técnica de DDD para visualizar las relaciones entre Contextos
Delimitados.

**Explicación:** Distingue entre mapeos estratégicos (relaciones
organizacionales, de equipo y de capacidades de negocio) y mapeos tácticos
(patrones de implementación, opciones tecnológicas).

**Patrones de relación entre contextos (características):**
- **Asociación**: dos contextos evolucionan juntos con dependencia mutua.
- **Núcleo compartido (Shared Kernel)**: un subconjunto del modelo compartido
  deliberadamente entre contextos (requiere coordinación entre equipos).
- **Cliente-proveedor (Customer-Supplier)**: relación upstream-downstream con
  tasas de cambio potencialmente diferentes; el upstream define la API y el
  downstream la consume/se adapta a cambios.
- **Conformista (Conformist)**: el contexto downstream adopta el modelo
  upstream sin traducción (no tiene poder de negociación).
- **Capa Anti-Corrupción (ACL)**: patrón crítico para aislar dominios centrales
  de la influencia externa (por ejemplo, de un sistema legado con API
  compleja); traduce el modelo externo al modelo propio protegido.
- **Servicio host abierto (Open Host Service)**: un contexto expone un
  lenguaje publicado para integración; una API pública bien documentada sirve
  a muchos consumidores.
- **Lenguaje publicado (Published Language)**: formato de comunicación
  compartido y bien documentado (ej. un esquema de eventos estándar en JSON
  Schema) que un publicador emite y múltiples suscriptores consumen.
- **Partnership (Sociedad)**: dos contextos con dependencia mutua cuyos
  equipos alinean sus cronogramas de desarrollo.
- **Separate Ways (Caminos separados)**: sin relación entre contextos; se
  duplica funcionalidad si es necesario, en vez de integrar.
- **Big Ball of Mud**: anti-patrón — sistema legado sin límites claros ni
  dependencias ordenadas; se recomienda minimizar el contacto y aislar con una
  ACL si se necesita integración.

**Espectro de implementación de integración:**
- Síncrono (RPC/REST): simple pero crea acoplamiento en tiempo de ejecución.
- Asíncrono (Eventos): desacopla servicios temporalmente; permite resistencia.
- Captura de datos de cambio (Change Data Capture): observar cambios de base
  de datos como mecanismo de integración.

### Agregados (Aggregates)

**Definición:** Un agregado es un grupo de entidades y objetos de valor
relacionados que se tratan como una sola unidad, asegurando consistencia y
encapsulación. Son un concepto central en DDD y juegan un papel crucial en el
diseño de microservicios efectivos.

**Características:**
- Encapsulación: el agregado encapsula su estado interno y expone una
  interfaz bien definida para interactuar con él.
- Consistencia: el agregado asegura que su estado interno permanezca
  consistente en todo momento.
- Límite transaccional: el agregado representa un límite transaccional; los
  cambios al agregado son atómicos y consistentes.
- Punto único de acceso: los sistemas externos solo deben interactuar con el
  agregado a través de su entidad raíz (aggregate root).

**Beneficios (Aggregates Benefits):**
- Reduce acoplamiento: los agregados limitan el acceso externo, reduciendo el
  acoplamiento entre microservicios.
- Define límites: los agregados definen los límites del microservicio,
  asegurando un alcance bien definido.
- Simplifica transacciones: los agregados proveen una unidad natural de
  trabajo para transacciones, simplificando la gestión de datos.
- Promueve consistencia: los agregados encapsulan datos, forzando reglas de
  consistencia y manteniendo la integridad de los datos.

**Procedimiento (Designing Effective Aggregates):**
1. Identificar la entidad raíz: determinar la entidad principal que controla
   la consistencia.
2. Agrupar entidades relacionadas: combinar entidades y objetos de valor que
   necesitan ser consistentes.
3. Mantener los agregados pequeños: asegurar que sean manejables y con buen
   rendimiento (performant).
4. Minimizar dependencias: reducir el acoplamiento entre agregados para mejor
   escalabilidad.
5. Considerar la consistencia eventual: implementar estrategias para
   sincronizar datos cuando la consistencia inmediata no es posible.

### Ejemplo: Agregado de Pedido de Comercio Electrónico

**Descripción del ejemplo:** Un agregado de Pedido (Order) podría consistir en:
- **Entidad Raíz:** Pedido (orderId, customerId, orderDate, status, etc.),
  con métodos como addItem(), removeItem(), calculateTotal(),
  validateCreditLimit().
- **Entidades:** ArtículoPedido/OrderItem (itemId, productId, quantity,
  price), DirecciónEnvío/ShippingAddress (addressId, street, city,
  postalCode, country).
- **Objetos de Valor:** Dinero/Money (amount, currency), asociado tanto a
  OrderItem como al total del Order.

Los sistemas externos interactuarían con el agregado de Pedido únicamente a
través de la entidad raíz Pedido. Por ejemplo, para agregar un artículo al
pedido, se llamaría un método en la entidad Pedido, que crearía un
ArtículoPedido y lo agregaría. La entidad Pedido también sería responsable de
hacer cumplir reglas de consistencia, como asegurar que el monto total del
pedido no exceda el límite de crédito del cliente. En el diagrama, "External
Systems (UI, APIs, Other Services)" interactúan "ONLY through Aggregate Root"
dentro del "Order Aggregate Boundary".

### Aplicación de Doce Factores (12-Factor App)

**Definición:** Un conjunto de doce principios o mejores prácticas para
construir aplicaciones modernas, escalables y mantenibles de software como
servicio (SaaS). Fue creado por ingenieros de Heroku basándose en sus
observaciones de miles de aplicaciones ejecutándose en su plataforma en la
nube (referencia: https://12factor.net/).

**Filosofía central:** La metodología está diseñada para aplicaciones que se
despliegan en plataformas en la nube, usan configuración declarativa, son
adecuadas para despliegue continuo, y pueden escalar sin cambios
significativos en las herramientas, arquitectura o prácticas de desarrollo.

**Por qué es importante:** Aunque originalmente concebido para aplicaciones
web, sus principios se han vuelto fundamentales para el desarrollo nativo en
la nube, microservicios y aplicaciones contenerizadas (como las que se
ejecutan con Docker y Kubernetes). En esencia, es un plano para construir
aplicaciones que prosperan en la nube.

**Los factores proporcionan un vocabulario compartido y una lista de
verificación para crear aplicaciones que son:** portátiles entre entornos de
ejecución (diferentes proveedores de nube), escalables horizontalmente
(añadiendo más instancias), resistentes y adecuadas para pipelines de
despliegue modernos y automatizados (CI/CD), y colaborativas para equipos de
desarrollo.

**Los 12 factores (resumidos):**
1. **Base de Código (Codebase):** Una base de código seguida en control de
   versiones, múltiples despliegues.
2. **Dependencias (Dependencies):** Declarar y aislar explícitamente las
   dependencias.
3. **Configuración (Config):** Almacenar la configuración en el entorno (no
   en el código).
4. **Servicios de Respaldo (Backing Services):** Tratar los servicios de
   respaldo (bases de datos, colas) como recursos adjuntos.
5. **Construir, Liberar, Ejecutar (Build, Release, Run):** Separar
   estrictamente las etapas de construcción y ejecución.
6. **Procesos (Processes):** Ejecutar la aplicación como uno o más procesos
   sin estado.
7. **Vinculación de Puertos (Port Binding):** Exportar servicios mediante
   vinculación de puertos (ser autosuficiente).
8. **Concurrencia (Concurrency):** Escalar mediante el modelo de procesos
   (ejecutar más procesos).
9. **Disponibilidad (Disposability):** Maximizar la robustez con arranque
   rápido y apagado elegante.
10. **Paridad Dev/Prod:** Mantener desarrollo, pruebas y producción lo más
    similares posible.
11. **Registros (Logs):** Tratar los registros como flujos de eventos.
12. **Procesos de Administración (Admin Processes):** Ejecutar tareas
    administrativas como procesos únicos.

## Enfoques, métodos o herramientas

### Despliegue Azul-Verde (Blue-Green Deployment)

**Descripción:** Una estrategia de despliegue sin tiempo de inactividad donde
dos entornos idénticos ("azul" y "verde") funcionan en paralelo. Un enrutador
dirige el tráfico de usuarios hacia uno u otro entorno (ruta azul o ruta
verde), mientras ambos comparten recursos como la base de datos.

**Caso de uso:** Sistemas financieros, aplicaciones de salud, donde el tiempo
de inactividad es inaceptable.

**Impacto arquitectónico:**
- Infraestructura inmutable: cada despliegue crea instancias completamente
  nuevas en lugar de actualizar las existentes.
- Abstracción de enrutamiento de tráfico: requiere una capa de enrutamiento
  inteligente (balanceador de carga, service mesh) para cambiar el tráfico
  entre entornos.
- Desafío de gestión de estado: crítico para servicios con estado; requiere
  manejo cuidadoso de sesiones o estado externalizado.

**Ventajas estratégicas:**
- Rollback instantáneo: cambiar el tráfico de vuelta a la versión anterior en
  segundos.
- Actualizaciones sin tiempo de inactividad: los usuarios no experimentan
  interrupción durante el despliegue.
- Pruebas seguras: puede validar el nuevo despliegue con tráfico sintético o
  interno antes de exponerlo a los usuarios.

**Compensaciones (trade-offs):**
- Sobrecarga de recursos: el doble de infraestructura durante la ventana de
  despliegue.
- Complejidad de migración de base de datos: requiere cambios de base de
  datos compatibles hacia atrás o versiones separadas de base de datos.
- Desafío de pruebas de integración: debe probar ambas versiones si otros
  servicios no se despliegan simultáneamente.

### Despliegue Canario (Canary Deployment)

**Descripción:** Exponer gradualmente la nueva versión a un pequeño
subconjunto de usuarios antes del lanzamiento completo.

**Caso de uso:** Aplicaciones de cara al consumidor, escenarios de pruebas
A/B.

**Criticidad del monitoreo:** Requiere activadores de rollback automático
basados en métricas clave (tasas de error, picos de latencia).

**Impacto arquitectónico:**
- Segmentación de tráfico: requiere enrutamiento sofisticado basado en
  atributos de usuario, porcentajes u otros criterios.
- Diseño centrado en observabilidad: demanda recopilación extensiva de
  métricas para comparar versiones.
- Integración de feature flags: a menudo combinado con toggles de
  características para control granular.

**Ventajas estratégicas:**
- Mitigación de riesgos: limita el impacto de lanzamientos problemáticos a un
  subconjunto de usuarios.
- Validación en el mundo real: prueba la nueva versión con tráfico de
  producción real y comportamiento del usuario.
- Monitoreo de rendimiento: compara métricas clave (latencia, tasas de error)
  entre versiones.

**Patrones de implementación:**
- Canario basado en usuario: enrutar usuarios específicos (empleados, beta
  testers).
- Canario basado en porcentaje: enrutar un porcentaje de todo el tráfico.
- Canario geográfico: enrutar usuarios de regiones específicas.
- Canario conductual: enrutar usuarios basado en patrones de uso.

**Compensaciones:**
- Uso intensivo de recursos: los lanzamientos canario requieren tiempo
  extra, herramientas y monitoreo para rastrear errores, retroalimentación
  del usuario y diferencias de rendimiento.
- Sobrecarga operacional: ejecutar múltiples versiones aumenta la complejidad
  para los equipos de ingeniería, especialmente en compatibilidad, control de
  versiones y rollbacks.
- Experiencia de usuario desigual: los usuarios canario pueden encontrar
  comportamiento notablemente diferente que aquellos en la versión estable,
  por lo que los mecanismos de opt-in pueden ayudar a reducir la fricción.

**Procedimiento (Proceso de Despliegue Canario):**
1. Duplicar infraestructura (Duplicate Infrastructure).
2. Seleccionar el grupo canario (Select the Canary Group).
3. Desplegar la actualización (Deploy the update).
4. Monitorear el rendimiento (Monitor Performance).
5. Analizar resultados (Analyze Results).
6. Lanzamiento completo (Full Rollout).

### Despliegue Gradual (Rolling Deployment)

**Descripción:** Actualizar incrementalmente las instancias en un pool de
servicios, asegurando que siempre permanezca disponible cierta capacidad.

**Caso de uso:** Servicios internos, entornos con restricciones de recursos.

**Características arquitectónicas:**
- Coexistencia de versiones: múltiples versiones funcionan simultáneamente
  durante el despliegue.
- Validación progresiva de salud: cada nueva instancia debe pasar
  verificaciones de salud (health checks) antes de continuar.
- Conocimiento del balanceador de carga: requiere que el balanceador de carga
  drene las conexiones de las instancias antiguas.

**Ventajas estratégicas:**
- Eficiente en recursos: no requiere infraestructura duplicada.
- Compatibilidad hacia atrás: fuerza la compatibilidad de versiones durante
  el período de transición.
- Despliegue predecible: ritmo controlado de despliegue.

**Compensaciones:**
- Compatibilidad de versiones: los servicios deben soportar compatibilidad
  N-1 durante el despliegue.
- Duración del despliegue: puede ser lento para grandes cantidades de
  instancias.
- Rollback complejo: requiere actualización gradual inversa si surgen
  problemas.

## Comparaciones

| Factor | Azul-Verde | Canario | Gradual |
|---|---|---|---|
| Velocidad de Rollback | Instantánea | Rápida | Lenta |
| Sobrecarga de Recursos | Alta (2x) | Baja | Baja |
| Mitigación de Riesgos | Media | Alta | Media |
| Complejidad | Media | Alta | Baja-Media |
| Mejor Para | Servicios críticos, SLAs estrictos | Servicios de cara al usuario, experimentación | Entornos con recursos limitados |

| Enfoque SAGA | Descripción | Ventaja | Desventaja |
|---|---|---|---|
| Coreografía | Basado en eventos, descentralizado | Descentralizado (sin coordinador único) | Más difícil de depurar |
| Orquestación | Coordinador centralizado | Más fácil de monitorear | Introduce acoplamiento hacia el orquestador |

| Relación de Contexto (Context Mapping) | Descripción según el documento |
|---|---|
| Asociación | Dos contextos evolucionan juntos con dependencia mutua |
| Núcleo compartido | Subconjunto del modelo compartido deliberadamente; requiere coordinación |
| Cliente-proveedor | Relación upstream-downstream con tasas de cambio potencialmente diferentes |
| Conformista | El downstream adopta el modelo upstream sin traducción |
| Capa Anti-Corrupción (ACL) | Aísla dominios centrales de influencia externa |
| Servicio host abierto | Lenguaje publicado para integración; una API sirve a muchos consumidores |
| Lenguaje publicado | Formato de comunicación compartido y bien documentado |
| Partnership | Dependencia mutua con alineación de cronogramas de equipos |
| Separate Ways | Sin relación; se duplica funcionalidad si es necesario |
| Big Ball of Mud (anti-patrón) | Sin límites claros ni dependencias ordenadas; minimizar contacto, aislar con ACL |

## Procedimientos o procesos

### Diseño de agregados efectivos (Designing Effective Aggregates)

1. Identificar la entidad raíz: determinar la entidad principal que controla
   la consistencia.
2. Agrupar entidades relacionadas: combinar entidades y objetos de valor que
   necesitan ser consistentes.
3. Mantener los agregados pequeños: asegurar que sean manejables y
   performantes.
4. Minimizar dependencias: reducir el acoplamiento entre agregados para mejor
   escalabilidad.
5. Considerar la consistencia eventual: implementar estrategias para
   sincronizar datos cuando la consistencia inmediata no es posible.

### Proceso de Despliegue Canario

1. Duplicate Infrastructure (duplicar infraestructura).
2. Select the Canary Group (seleccionar el grupo canario).
3. Deploy the update (desplegar la actualización).
4. Monitor Performance (monitorear el rendimiento).
5. Analyze Results (analizar resultados).
6. Full Rollout (lanzamiento completo).

### Estrategia de Despliegue Evolutiva

Enfoque progresivo que las organizaciones siguen a medida que maduran su
práctica de microservicios:
1. Comenzar con Despliegues Graduales: más simples de implementar, establecen
   automatización de despliegue.
2. Introducir Azul-Verde para Servicios Críticos: donde el tiempo de
   inactividad es inaceptable.
3. Adoptar Canario para Servicios de Cara al Usuario: cuando se tiene
   suficiente tráfico y monitoreo.
4. Combinar Estrategias: usar diferentes patrones para diferentes tipos de
   servicios.

### Enfoque de Refinamiento Progresivo (evolución de arquitectura con DDD y microservicios)

1. Comenzar con arquitectura monolítica pero con identificación de contextos
   delimitados.
2. Extraer módulos a lo largo de límites de contexto como servicios.
3. Permitir que los agregados informen la descomposición de servicios cuando
   las demandas de escalabilidad lo requieran.

### Evolución y adopción de patrones de microservicios

Al implementar los patrones de AMM (interacción, datos, resistencia,
despliegue):
- Comenzar con límites: definir límites de servicio alrededor de capacidades
  de negocio, no capas técnicas.
- Adoptar diseño evolutivo: comenzar con implementaciones simples; agregar
  patrones según surjan necesidades.
- Invertir en observabilidad: estos patrones requieren herramientas
  sofisticadas de monitoreo, trazado y depuración.
- Considerar los anti-patrones: reconocer cuándo se implementan microservicios
  por razones equivocadas.

## Ejemplos y casos

### Ejemplo: Saga basada en Coreografía

Ver descripción completa en la sección "Patrón SAGA" arriba: flujo entre
Order Service y Customer Service comunicándose vía canales de eventos, sin
coordinador central.

### Ejemplo: Saga basada en Orquestación

Ver descripción completa en la sección "Patrón SAGA" arriba: un "Create Order
Saga" central coordina la interacción entre Order Service y Customer Service
a través de un Message Broker.

### Ejemplo: Agregado de Pedido de Comercio Electrónico

Ver descripción completa en la sección "Ejemplo: Agregado de Pedido de
Comercio Electrónico" arriba.

### Ejemplo: Despliegue Azul-Verde

Diagrama: los usuarios llegan a un Router que dirige el tráfico ("Blue
route" o "Green route") hacia un "Blue Environment" (App Servers + Services)
o un "Green Environment" (App Servers + Services), ambos conectados a
recursos compartidos (Database, Services).

### Ejemplo: Despliegue Canario

Diagrama: el "User Traffic" pasa por un Load Balancer que dirige la mayoría
del tráfico (Core Users) a la "Stable Version" (múltiples servidores) y una
porción pequeña (Canary Group) a la "Canary Version" (menos servidores).

### Ejemplo: Despliegue Gradual (Rolling Deployment)

Diagrama: con dos nodos ejecutándose, primero se aplica el parche al primer
nodo (sacándolo temporalmente de servicio mientras el segundo sigue
atendiendo usuarios), luego se aplica el parche al segundo nodo, y finalmente
ambos nodos quedan corriendo con la nueva versión.

## Información visual relevante

### Diagrama: Puerta de enlace API

Muestra un flujo: Usuario → Mobile/Web Application → API Gateway (con
componentes internos de Authentication, SSL, Routing, HTTP Translation,
Protocol Translation, Aggregation, Audit/DB) → Mobile/Web Application (App)
del backend. Ilustra que el gateway centraliza preocupaciones transversales
antes de enrutar hacia los servicios internos.

### Diagrama: Backend For Frontend

Muestra Web App y Mobile App conectándose cada una a su propio "BFF API
Gateway" dedicado (Web BFF, Mobile BFF), los cuales a su vez se conectan a
distintos microservicios mediante distintos protocolos (REST, gRPC, AMQP),
ilustrando cómo cada tipo de cliente tiene su propia capa de agregación.

### Diagrama: Base de datos por servicio (AWS)

Muestra un API Gateway de AWS enrutando solicitudes (/sales, /customer,
/compliance) hacia funciones Lambda distintas ("Sales", "Customer",
"Compliance"), cada una con su propia política IAM y su propia base de datos
(Amazon Aurora, Amazon DynamoDB, Amazon RDS for SQL Server respectivamente),
ilustrando persistencia políglota por servicio.

### Diagrama: Flow of SAGA

Muestra una secuencia lineal de transacciones (Create Order → Process Payment
→ Update Inventory → Deliver Order) cada una con su transacción compensatoria
correspondiente (Cancel Order, Reverse Payment, Reverse Inventory Update,
Cancel Delivery) en caso de fallo, ilustrando el concepto de transacciones
compensatorias del patrón Saga.

### Diagrama: Circuit Breaker Pattern

Muestra la máquina de estados: Closed (servicio sano) → transición a Open
cuando errorRate > threshold (fallando rápido) → tras un cooldownPeriod pasa
a Half-Open (periodo de prueba con llamadas limitadas) → si tiene éxito
regresa a Closed, si falla vuelve a Open.

### Diagrama: How Retry Pattern Works

Secuencia cliente-servicio mostrando tres estrategias de espera entre
reintentos tras respuestas de error (500): Fixed Delay (t=100ms constante),
Incremental Delay (t=i*100ms, creciente linealmente) y Exponential Backoff
(t=100*2^(i-1)ms, creciente exponencialmente).

### Diagrama: Límites de Servicio (monolito → contextos delimitados → microservicios)

Ilustra la descomposición de una "Monolithic architecture" (con módulos User
access, Shopping cart, Product management, Payments, Reporting) hacia
Bounded Contexts (User Management, Shopping Cart, Product Management,
Payment, Reporting) y de ahí a microservicios concretos (User registration,
Authentication, Authorization, Cart Service, Product Catalog, Inventory,
Payments, Refunds, Sales reporting, User Activity Reporting).

### Diagrama: Context Mapping in Domain-Driven Design

Panel visual con nueve ejemplos de patrones de mapeo de contextos
(Customer-Supplier, Conformist, Anticorruption Layer, Shared Kernel,
Partnership, Open Host Service, Separate Ways, Published Language, Big Ball
of Mud), cada uno con un ejemplo concreto de servicios y una breve leyenda
explicativa (ver detalles en la sección "Mapeo de Contextos" arriba).

### Diagrama: Order Aggregate Boundary

Muestra "External Systems (UI, APIs, Other Services)" interactuando
únicamente a través de la "Aggregate Root" (Order), la cual "owns" dos
instancias de OrderItem (Entity) y una ShippingAddress (Entity), y "has
total" un Money (Value Object); cada OrderItem también "has" un Money (Value
Object) propio. Ilustra el principio de punto único de acceso al agregado.

### Diagrama: Aggregates Benefits

Panel de cuatro beneficios de los agregados: Reduce Coupling, Define
Boundaries, Simplify Transactions, Promote Consistency (ver descripciones en
la sección "Agregados" arriba).

### Diagrama: Designing Effective Aggregates (escalera de 5 pasos)

Ilustra en forma de escalera ascendente los cinco pasos para diseñar
agregados efectivos (Identify Root Entity, Group Related Entities, Keep
Aggregates Small, Minimize Dependencies, Consider Eventual Consistency),
correspondientes al procedimiento documentado arriba.

### Diagrama: Requisitos Previos de Infraestructura (para estrategias de despliegue)

Pentágono con cinco requisitos de infraestructura necesarios para soportar
las estrategias de despliegue modernas:
- **Pipeline Automation**: optimiza el ciclo de vida del desarrollo de
  software con CI/CD y despliegues automatizados.
- **Immutable Infrastructure**: asegura consistencia y confiabilidad mediante
  contenedorización o imágenes de VM.
- **Orchestration**: gestiona y automatiza aplicaciones contenedorizadas con
  plataformas como Kubernetes.
- **Traffic Management**: dirige y balancea el tráfico de red con service
  meshes o balanceadores de carga avanzados.
- **Observability**: provee visibilidad del rendimiento del sistema mediante
  trazado, métricas y logging.

### Diagrama: Deployment Anti-Patterns

Panel de cinco anti-patrones de despliegue:
- **Big Bang Deployment**: liberar todo a la vez sin lanzamiento gradual.
- **Manual Traffic Switching**: la intervención humana en el ciclo derrota el
  propósito de la automatización.
- **Insufficient Monitoring**: desplegar sin métricas para evaluar el éxito.
- **Ignoring Database Migrations**: enfocarse solo en el código de la
  aplicación (sin considerar la evolución del esquema de datos).
- **Over-Engineering**: usar patrones complejos para servicios simples y de
  bajo riesgo.

### Diagrama: Organizational and Process Implications (por estrategia de despliegue)

Panel de tres columnas con implicaciones organizacionales/de proceso por
estrategia:
- **Blue-Green Deployment**: fases separadas de testing y validación en
  producción; escaneo de seguridad del nuevo entorno antes del cambio de
  tráfico; verificación de cumplimiento en un entorno de staging similar a
  producción.
- **Canary Deployment**: cultura de toma de decisiones basada en datos;
  infraestructura avanzada de monitoreo y alertas; criterios claros para
  decisiones de rollback; colaboración entre equipos de desarrollo y de
  producto.
- **Rolling Deployment**: disciplina fuerte de compatibilidad hacia atrás;
  pruebas de integración exhaustivas; service mesh o balanceo de carga
  sofisticado.

## Terminología importante

- **DDD (Domain-Driven Design / Diseño Dirigido por Dominio):** Enfoque para
  modelar software alrededor del dominio de negocio; provee las herramientas
  estratégicas y tácticas para diseñar microservicios que reflejen la
  realidad del negocio en lugar de la conveniencia técnica.
- **Contexto Delimitado (Bounded Context):** Límite preciso de dominio
  empresarial definido por DDD; marco natural para organizar servicios.
- **Agregado (Aggregate):** Grupo de entidades y objetos de valor
  relacionados tratados como una sola unidad para asegurar consistencia y
  encapsulación.
- **Entidad Raíz (Aggregate Root):** Entidad principal de un agregado que
  controla la consistencia y es el único punto de acceso permitido para
  sistemas externos.
- **Objeto de Valor (Value Object):** Elemento de un agregado sin identidad
  propia (ej. Money), definido por sus atributos.
- **Ley de Conway:** Principio mencionado que sugiere que la estructura
  organizacional de un equipo influye en la arquitectura del software que
  produce (usado como heurística para definir límites de servicio).
- **Consistencia eventual:** Modelo de consistencia de datos donde las
  actualizaciones se propagan con el tiempo, en lugar de ser inmediatas;
  adoptado por el patrón Saga como concepto arquitectónico de primera clase.
- **Transacción compensatoria:** Operación que revierte los efectos de un
  paso previo de una Saga cuando un paso posterior falla.
- **Idempotencia:** Propiedad de una operación que produce el mismo resultado
  sin efectos secundarios adicionales al repetirse; esencial para reintentos
  seguros y operaciones de Saga.
- **Backoff exponencial:** Estrategia de reintento donde el tiempo de espera
  entre intentos crece exponencialmente, para prevenir tormentas de
  reintentos.
- **Jitter:** Aleatorización añadida al tiempo de espera de reintentos para
  evitar el efecto rebaño (thundering herd).
- **Persistencia políglota:** Uso de distintas tecnologías de base de datos,
  cada una elegida según las necesidades específicas de cada servicio.
- **Infraestructura inmutable:** Práctica de crear instancias completamente
  nuevas en cada despliegue en lugar de actualizar las existentes.
- **Feature flags (toggles de características):** Mecanismo para activar o
  desactivar funcionalidades de forma granular, combinado a menudo con
  despliegues canario.
- **Compatibilidad N-1:** Requisito de que los servicios soporten
  compatibilidad con la versión inmediatamente anterior durante un despliegue
  gradual.
- **12-Factor App:** Conjunto de doce principios para construir aplicaciones
  SaaS modernas, escalables y mantenibles, creado por ingenieros de Heroku.

## Notas y advertencias

- El material de la Semana 7 combina, sin una separación tajante, tres
  bloques temáticos que en la agenda original aparecen diferenciados
  (patrones de AMM, AMM+DDD, y 12-Factor App), pero el bloque final de
  "Material Complementario: Estrategias de Despliegue" (azul-verde, canario,
  gradual) aparece después de la introducción a 12-Factor App sin estar
  anunciado explícitamente en la agenda inicial de la diapositiva 2 — se
  presenta como contenido adicional ("To Do").
- El documento no desarrolla en detalle los patrones de Circuit Breaker,
  Retry, API Gateway, BFF, Base de Datos por Servicio y SAGA en la sección
  "Repaso de Arquitectura de Microservicios II" más allá de mencionarlos en
  el resumen de la diapositiva "Resumen de Patrones"; su desarrollo completo
  ocurre luego en la sección "Patrones de Arquitectura de Microservicios".
- El diagrama de "Base de Datos por Servicio" incluye una fuente que en
  realidad corresponde a documentación de AWS sobre modernización, mientras
  que la diapositiva de "Límites de Servicio" cita como fuente una URL sobre
  "retry-pattern-in-microservices", lo cual parece ser un error de cita en el
  material original (la URL no corresponde temáticamente al contenido de esa
  diapositiva sobre límites de servicio/bounded contexts). Se preserva tal
  como aparece en la fuente, sin corregirlo.
- Los "Deployment Anti-Patterns" y "Requisitos Previos de Infraestructura"
  aparecen en inglés en las diapositivas (a diferencia del resto del
  material, mayormente en español), lo cual sugiere que fueron tomados de una
  fuente o plantilla distinta sin traducir; se preservan tal como aparecen.
- El "Enfoque Híbrido" mencionado en la síntesis de DDD y microservicios
  introduce los términos "monolitos modulares" y "macro-servicios" sin
  definirlos ni desarrollarlos más allá de la mención breve: "Considerar
  monolitos modulares como un paso intermedio, o macro-servicios para
  dominios complejos que requieren consistencia fuerte, con microservicios
  para capacidades que evolucionan independientemente."
- El documento no profundiza en el "Captura de datos de cambio" (Change Data
  Capture) como mecanismo de integración más allá de nombrarlo en el
  "Espectro de implementación de integración" de la sección de Mapeo de
  Contextos.
- La distinción entre "Mapeos estratégicos" y "Mapeos tácticos" se enuncia
  pero no se desarrolla con ejemplos propios más allá de la definición breve
  dada.
