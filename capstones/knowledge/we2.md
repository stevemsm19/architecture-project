# Semana 2: Integración de Sistemas

## Resumen del contenido

Este material corresponde a la Semana 2 del curso Arquitectura de Software 3
(Jala University). El objetivo declarado de la sesión es "comprender cómo los
sistemas pueden comunicarse", explorando los conceptos de interoperabilidad,
sistemas legados (heredados), migración de datos y los métodos comunes de
integración entre sistemas.

La sesión comienza con una breve recapitulación de Arquitectura Empresarial
(tema de la Semana 1), luego desarrolla en profundidad: (1) la
interoperabilidad de sistemas y sus dimensiones, (2) los sistemas heredados
(legacy) — qué son, por qué persisten, sus riesgos y enfoques de
modernización, (3) la integración de sistemas propiamente dicha, con cuatro
tecnologías clave (EDI, APIs, Webhooks, Mensajería) comparadas en detalle, y
(4) la migración de datos, como proceso distinto de la integración, con sus
tipos, fases y riesgos.

## Conceptos clave

### Arquitectura Empresarial (recapitulación)

**Definición:** Marco estratégico que alinea los objetivos comerciales de una
organización con su infraestructura de TI. Proporciona una visión holística
de procesos, sistemas, datos y tecnologías para guiar la toma de decisiones y
la transformación.

**Explicación:** Es el puente entre la estrategia comercial (lo que se quiere
lograr) y la ejecución de TI (cómo se logrará). Se trata de gestionar la
complejidad e impulsar el cambio estratégico, no solo de "plomería de TI".

**Características:**
- Se enfoca en la planificación a largo plazo y la integración.
- Ayuda a reducir la complejidad y mejorar la agilidad.
- Se compone de varios dominios: Arquitectura de Negocio, Arquitectura de
  Información, Arquitectura de Aplicaciones, Arquitectura Tecnológica.
- Incluye prácticas transversales: Análisis de Brechas (identifica
  desconexiones entre el estado actual y el estado futuro deseado a través de
  cada dominio arquitectónico), Gobierno y Cumplimiento (imponen políticas,
  seguridad y alineación regulatoria a través de todas las decisiones
  arquitectónicas), y Soluciones Modulares (ofrecen flexibilidad y agilidad
  al ensamblar sistemas a partir de componentes intercambiables).

**Relaciones:**
- Es el marco de fondo bajo el cual se entiende la necesidad de
  interoperabilidad e integración de sistemas, tema central de esta semana.

#### Dominios de la Arquitectura Empresarial

- **Arquitectura de Negocio:** define la estructura, capacidades y procesos
  de la organización, asegurando que cada iniciativa respalde los objetivos
  centrales y entregue valor medible. Establece el escenario para la
  transformación al clarificar qué hace el negocio y cómo debe evolucionar.
- **Arquitectura de Información:** organiza los activos de datos y flujos de
  contenido para respaldar la toma de decisiones, cumplimiento y eficiencia
  operacional, asegurando que la información correcta llegue a las personas
  correctas en el momento correcto.
- **Arquitectura de Aplicaciones:** traduce las necesidades del negocio en
  soluciones de software, especificando cómo las aplicaciones interactúan,
  escalan e integran a través de la empresa. Asegura modularidad,
  mantenibilidad y capacidad de respuesta al cambio.
- **Arquitectura Tecnológica:** proporciona la infraestructura — redes,
  plataformas y hardware — que permite la entrega segura y confiable de
  servicios. Estos cuatro dominios forman un plano cohesivo que guía la
  innovación, respalda la interoperabilidad y asegura el gobierno a través de
  sistemas y equipos.

### Interoperabilidad de Sistemas

**Definición:** Capacidad de diferentes sistemas de software para
intercambiar y usar información sin problemas, sin la necesidad de
modificaciones significativas o integraciones personalizadas.

**Explicación:** Involucra lograr comunicación entre sistemas diversos y
compartición efectiva de datos, habilitando mayor eficiencia, colaboración e
innovación. El documento ilustra el concepto con un ejemplo del sector salud:
múltiples actores (hospitales, pacientes, farmacéuticas, planes de salud,
proveedores, laboratorios) necesitan interoperar para "crear productos de
datos" (data products), y un principio arquitectónico de interoperabilidad
establece que, al tener sistemas con interfaces abiertas que usan formatos de
datos estandarizados para intercambiar datos, se asegura que los datos
puedan fluir libremente, de forma segura y sin restricciones entre sistemas,
permitiendo a organizaciones y profesionales tener acceso rápido y fácil a
datos de alta calidad.

**Características:**
- No requiere modificaciones significativas ni integraciones personalizadas
  para que los sistemas se comuniquen.
- Habilita mayor eficiencia, colaboración e innovación.

**Relaciones:**
- Es un requisito previo/condición para que la integración de sistemas
  funcione correctamente.
- Se apoya en estándares, APIs, gobernanza de datos, gestión de metadatos y
  seguridad (ver "Aspectos Clave de la Interoperabilidad de Sistemas").

#### Dimensiones de la Interoperabilidad de Sistemas

- **Intercambio de Datos (Data Exchange):** la capacidad de transferir datos
  entre sistemas de manera precisa y confiable.
- **Interoperabilidad Organizacional:** alinea procesos, políticas y
  responsabilidades entre organizaciones o departamentos para garantizar
  interacciones coherentes y efectivas.
- **Interoperabilidad Semántica:** asegura que los datos intercambiados sean
  entendidos consistentemente por todos los sistemas y partes interesadas a
  través de estándares acordados y definiciones de datos.
- **Interoperabilidad Técnica:** garantiza que los sistemas puedan conectarse
  y transmitir datos (ej. APIs, protocolos, formatos de datos).

(El diagrama fuente representa estas cuatro dimensiones como ramas que
emergen de un prisma central etiquetado "Systems Interoperability".)

#### Aspectos clave de la Interoperabilidad de Sistemas

- **Estándares:** adoptar estándares industriales para formatos de datos,
  protocolos de comunicación y seguridad puede simplificar los esfuerzos de
  integración.
- **APIs:** las APIs bien diseñadas pueden facilitar la integración de
  diferentes sistemas.
- **Gobernanza de Datos:** establecer políticas y procedimientos claros para
  garantizar calidad, consistencia y seguridad de los datos.
- **Gestión de Metadatos:** crucial para comprender el significado y
  contexto de los datos intercambiados entre sistemas.
- **Seguridad:** los sistemas interoperables deben ser seguros para proteger
  datos sensibles del acceso no autorizado y amenazas cibernéticas.

(Estos cinco aspectos se representan visualmente como segmentos de un candado
circular, remarcando que la seguridad "envuelve" o protege a los demás
aspectos.)

### Sistemas Heredados (Legacy)

**Definición:** Software o tecnología construidos sobre plataformas obsoletas
que siguen siendo críticos para las operaciones actuales. Representan una
acumulación de deuda tecnológica.

**Explicación:** Son sistemas "obsoletos pero operativos" — a menudo carecen
de pruebas modernas, documentación completa, y son notoriamente difíciles de
mantener, actualizar o integrar con soluciones contemporáneas.

**Características / Ejemplos ubicuos:**
- **Mainframes basados en COBOL:** muchos bancos aún ejecutan sistemas
  centrales de transacciones en COBOL de los años 1960-70.
- **Sistemas de Información Hospitalaria (SIH):** sistemas antiguos que
  gestionan registros de pacientes o facturación.

**Relaciones:**
- Son uno de los grandes desafíos que motivan la necesidad de integración de
  sistemas (a menudo hay que conectar sistemas legados con sistemas modernos).
- Se relacionan con la migración de datos como una de las razones para migrar
  (reemplazar o actualizar sistemas heredados).

#### Por qué persisten los sistemas heredados

- **Criticidad Empresarial:** muchos sistemas heredados son indispensables,
  apoyando directamente las operaciones centrales del negocio y la
  generación de ingresos; reemplazarlos podría detener funciones críticas.
- **Alto Costo y Riesgo:** la inversión financiera y los riesgos inherentes
  asociados con el reemplazo completo o la modernización extensa pueden ser
  prohibitivos.
- **Dependencia del Proveedor:** la dependencia de proveedores específicos o
  tecnologías propietarias a menudo significa falta de alternativas viables
  y rentables, creando un escenario de "cautiverio" (vendor lock-in).
- **Familiaridad y Confiabilidad:** a pesar de su edad, estos sistemas a
  menudo ofrecen una sensación percibida de confiabilidad y familiaridad
  para usuarios de largo plazo, haciendo desafiante la gestión del cambio.

#### Riesgos ocultos / riesgos de mantener sistemas heredados

Un diagrama tipo "espina de pescado" (fishbone / Ishikawa) agrupa los riesgos
de mantener sistemas heredados en cuatro categorías causales:
- **Rendimiento** (naranja): degradación del rendimiento, procesamiento
  lento.
- **Seguridad** (gris): vulnerabilidades de seguridad, brechas de datos,
  infecciones de malware.
- **Costos** (rojo): consumo de energía, cuotas de mantenimiento, costos
  exorbitantes.
- **Conocimiento** (azul): falta de documentación, rotación de empleados,
  pérdida de conocimiento crítico.

El documento amplía cuatro de estos riesgos como "los riesgos ocultos de los
sistemas heredados":
- **Drenaje de Rendimiento:** las fallas inesperadas y el mal rendimiento se
  traducen directamente en un crecimiento empresarial más lento, impactando
  productividad y satisfacción del cliente.
- **Brechas de Seguridad:** protocolos obsoletos y parches de seguridad
  infrecuentes crean vulnerabilidades críticas, convirtiendo los sistemas en
  objetivos principales para ciberataques y violaciones de datos.
- **Costos Exorbitantes:** los altos gastos de mantenimiento, junto con la
  escasez de personal calificado familiarizado con tecnologías más antiguas
  ("unicornios de talento"), inflan los presupuestos operativos.
- **Pérdida de Conocimiento:** la documentación deficiente y la dependencia
  del conocimiento tribal aumentan el "factor autobús" — el riesgo de perder
  la comprensión crítica del sistema si el personal clave se marcha.

#### Evaluación de sistemas heredados (primer paso hacia la modernización)

Un diagrama de cuatro capas apiladas (representado como rombos escalonados)
describe el proceso de evaluación previo a modernizar:
1. **Comprehensive System Audit** (Auditoría integral del sistema):
   catalogar activos y comportamiento.
2. **Dependency Mapping** (Mapeo de dependencias): identificar componentes
   acoplados.
3. **Technology Stack Evaluation** (Evaluación del stack tecnológico):
   evaluar herramientas y versiones.
4. **Prioritization Frameworks** (Marcos de priorización): clasificar los
   objetivos de modernización.

#### Enfoques de modernización

- **Actualizaciones Incrementales:** se enfocan en agregar pruebas
  automatizadas, refactorizar código y automatizar tareas rutinarias. Este
  enfoque minimiza la interrupción y genera confianza.
- **Implementación Paralela:** ejecutar sistemas nuevos y heredados lado a
  lado. Reduce el riesgo al permitir una transición gradual y asegurar la
  continuidad del negocio.
- **Migración Completa:** trasladarse a plataformas nativas de la nube o
  modernas. Implica a menudo reconstruir o reemplazar aplicaciones heredadas
  por completo, ofreciendo la máxima transformación.

### Integración de Sistemas

**Definición:** Proceso de vincular diferentes sistemas informáticos y
aplicaciones de software física o funcionalmente para actuar como un
conjunto coordinado.

**Explicación:** Permite el flujo de datos, automatización de procesos y
experiencias de usuario unificadas a través de plataformas dispares. El
objetivo es crear un ecosistema tecnológico cohesivo y eficiente donde el
conjunto sea mayor que la suma de sus partes — pasando de silos de datos
aislados a una operación empresarial unificada.

**Características:**
- La elección del método de integración es una decisión arquitectónica
  crítica que equilibra factores como:
  - **Acoplamiento:** qué tan estrechamente conectados están los sistemas.
  - **Necesidades en tiempo real:** si los datos necesitan ser inmediatos o
    es aceptable el procesamiento por lotes.
  - **Confiabilidad:** qué tan importante es la entrega garantizada.
  - **Complejidad y Costo:** cuáles son los gastos generales de desarrollo y
    mantenimiento.

**Relaciones:**
- Depende de la interoperabilidad como condición habilitante.
- Se implementa mediante distintas tecnologías (EDI, APIs, Webhooks,
  Mensajería) cuya elección depende de los factores de acoplamiento, tiempo
  real, confiabilidad y costo.

#### Complejidad de la integración (espectro simple → sofisticado)

Un diagrama de flecha horizontal ordena los patrones/arquitecturas de
integración de menor a mayor sofisticación:
1. **Point-to-Point:** conexiones directas; crean "arquitectura espagueti"
   cuando se multiplican.
2. **Hub-and-Spoke:** un hub central simplifica pero crea un cuello de
   botella.
3. **Enterprise Service Bus (ESB):** comunicación estandarizada para
   escenarios complejos.
4. **iPaaS (Integration Platform as a Service):** entorno en la nube con
   conectores preconstruidos.
5. **Microservices Architecture:** servicios independientes que se comunican
   vía APIs (nivel más sofisticado).

### Migración de Datos

**Definición:** Proceso de seleccionar, preparar, extraer, transformar y
transferir datos de un sistema de almacenamiento de computadora o entorno a
otro.

**Explicación:** Es una actividad estratégica clave, frecuentemente
emprendida para: reemplazar o actualizar sistemas heredados; migrar a un
nuevo sistema o aplicación (p.ej. un nuevo CRM o ERP); consolidar sistemas
después de una fusión o adquisición; mover datos a la nube (p.ej. desde un
centro de datos local a AWS o Azure); crear un almacén de datos o lago de
datos; mejorar el rendimiento y la escalabilidad.

**Características:**
- Es un movimiento único y permanente de datos desde un origen A a un
  destino B; el sistema antiguo eventualmente se descomisiona (se retira).

**Relaciones:**
- Se distingue claramente de la Integración de Datos (ver Comparaciones).
- Está motivada frecuentemente por la existencia de sistemas heredados.

## Enfoques, métodos o herramientas

### EDI (Intercambio Electrónico de Datos)

**Qué es:** Un formato digital estandarizado para intercambiar documentos
comerciales (órdenes de compra, facturas, avisos de envío) entre
organizaciones. Los estándares comunes son ANSI X12 (Norteamérica) y EDIFACT
(Global). El documento lo describe como "el hermano mayor de las APIs", con
más de 50 años de historia, y como una piedra angular para estandarizar el
intercambio masivo de documentos en sectores con altos requisitos de
cumplimiento como finanzas y salud.

**Analogía del material:** Enviar una carta comercial formal por correo
certificado. El sobre, el formato de la dirección y la estructura de la
carta están estrictamente definidos por un protocolo; el receptor sabe
exactamente cómo interpretarla.

**Características clave:**
- Basado en Documentos: intercambia documentos comerciales completos.
- Asíncrono y Orientado a Lotes: los documentos se envían a menudo en lotes
  (ej. todas las facturas al final del día).
- Cumplimiento: cumple estándares regulatorios estrictos para el intercambio
  de datos.
- Alta Confiabilidad: a menudo usa protocolos como AS2 que proporcionan
  entrega segura y garantizada con recibos.

**Mejor para:**
- Transacciones B2B de alto volumen y repetitivas (ej. un minorista como
  Walmart enviando pedidos a sus proveedores).
- Industrias con sistemas heredados establecidos y mandatos (ej. automotriz,
  salud, logística).

**Fortaleza:** Maneja grandes volúmenes de manera confiable.
**Debilidad:** Capacidad de respuesta en tiempo real limitada.

**Ejemplo del documento:** La cadena de suministro global de Walmart aún
depende en gran medida de EDI para el procesamiento estandarizado de órdenes
de alto volumen, demostrando su relevancia perdurable.

### APIs (Interfaces de Programación de Aplicaciones)

**Qué es:** Un conjunto de reglas y protocolos definidos que permiten a una
aplicación solicitar servicios o datos de otra. El material las describe
como "la columna vertebral de la integración moderna", especialmente las
APIs REST, que facilitan la comunicación síncrona bajo demanda usando
protocolos como REST o GraphQL. Ejemplos de tecnologías mencionadas: REST,
GraphQL, gRPC.

**Analogía del material:** Un mesero en un restaurante. El cliente (la
aplicación) le dice al mesero (la API) lo que quiere del menú (la
documentación de la API). El mesero va a la cocina (el servidor) y trae la
comida (los datos).

**Características clave:**
- Modelo Solicitud-Respuesta: el cliente llama a la API y espera una
  respuesta inmediata.
- Síncrono: el llamador se bloquea hasta obtener una respuesta (éxito o
  error).
- Tiempo Real: diseñado para intercambio inmediato de datos.
- Débilmente Acoplado: cliente y servidor son independientes; mientras el
  contrato de la API no cambie, pueden evolucionar por separado.

**Mejor para:**
- Construir interfaces de usuario que necesitan datos en vivo (ej. una app
  móvil obteniendo el perfil de un usuario).
- Permitir a desarrolladores externos construir sobre la plataforma propia
  (ej. bots de Twitter, integraciones de Google Maps).
- Arquitecturas de microservicios, donde pequeños servicios se comunican vía
  APIs.

**Fortaleza:** Estandarización.
**Debilidad:** Acoplamiento síncrono.

**Ejemplo del documento:** El sistema de inventario de Amazon aprovecha las
APIs para actualizar instantáneamente los niveles de stock en diversas
plataformas, asegurando disponibilidad de productos precisa y actualizada.

### Webhooks

**Qué es:** Un método para que una aplicación proporcione a otras
aplicaciones información en tiempo real. En lugar de consultar una API
repetidamente preguntando "¿hay datos nuevos?", un webhook es una URL de
callback que una app llama automáticamente cuando ocurre un evento
específico. También se los llama "APIs inversas" o "APIs impulsadas por
eventos".

**Analogía del material:** Suscribirse a notificaciones. Se da un número de
teléfono (la URL del webhook) a una app y se dice "envíame un mensaje cuando
mi paquete se envíe." No se sigue llamando a la oficina postal; el sistema
notifica cuando sucede el evento.

**Características clave:**
- Basado en Eventos: los datos se envían inmediatamente cuando un evento lo
  desencadena.
- Asíncrono: el remitente activa el webhook y no espera una respuesta.
- Eficiente: elimina la necesidad de sondeo constante (polling), ahorrando
  recursos.
- Responsabilidad del Consumidor: el endpoint receptor debe ser robusto y
  manejar las cargas útiles entrantes de forma rápida y correcta.

**Mejor para:**
- Obtener notificaciones instantáneas (ej. un nuevo envío de formulario, una
  confirmación de pago, un commit de código a un repositorio).
- Disparar flujos de trabajo en otros sistemas, incluyendo APIs (ej. una
  nueva venta en Shopify dispara un email en Mailchimp).

**Fortaleza:** Eficiencia en tiempo real.
**Debilidad:** Confiabilidad del consumidor (el consumidor/endpoint receptor
debe procesar correctamente y a tiempo, o se pueden perder eventos).

**Ejemplo del documento:** El seguimiento de exportaciones de Splice usa
webhooks para notificar instantáneamente a los clientes cuando cambia el
estado de un contenedor, proporcionando actualizaciones oportunas sin
demora.

**Nota visual:** Una imagen fuente (AWS) señala límites máximos de payload a
considerar en arquitecturas dirigidas por eventos: Amazon API Gateway 10mb,
AWS Lambda 6mb, Amazon DynamoDB 400kb, Amazon SQS 256kb (con extensión).

### Mensajería y Streaming de Eventos (Sistemas de Mensajería)

**Qué es:** Los sistemas utilizan un sistema de mensajería (p.ej. RabbitMQ,
Apache Kafka, Amazon SQS) como intermediario. Un servicio (productor)
publica un mensaje en una "cola" o "tema" sin saber quién lo recibirá. Otro
servicio (consumidor) se suscribe a esa cola y procesa el mensaje. Los
sistemas de mensajería desacoplan productores y consumidores, habilitando
comunicación escalable y asíncrona.

**Analogía del material:** Una oficina postal con apartados postales. El
productor deposita una carta en un apartado postal específico (cola). El
destinatario (consumidor) revisa su apartado cuando quiere recibir su
correo. La oficina postal (broker) mantiene el correo seguro hasta que es
recogido.

**Características clave:**
- Asíncrono: productores y consumidores están completamente desacoplados en
  el tiempo; no necesitan estar en línea simultáneamente.
- Duradero: los mensajes se persisten en la cola hasta que un consumidor
  confirma el procesamiento exitoso.
- Escalable: puede agregar múltiples consumidores para procesar mensajes de
  una cola en paralelo.
- Resistente (resiliente): si un servicio se cae, los mensajes simplemente
  esperan en la cola hasta que vuelve a estar en línea.

**Mejor para:**
- Descargar tareas que consumen mucho tiempo (ej. procesar videos subidos,
  generar reportes).
- Construir arquitecturas basadas en eventos y microservicios.
- Asegurar comunicación confiable en sistemas distribuidos complejos.

**Fortaleza:** Resistencia desacoplada.
**Debilidad:** Complejidad operacional.

**Ejemplo del documento:** Uber implementó Kafka como una columna vertebral
de mensajería distribuida para habilitar arquitectura basada en eventos a
través de sus microservicios.

**Complemento:** Los servicios en la nube como AWS EventBridge o Azure Event
Grid gestionan el enrutamiento y la limitación de eventos, simplificando
integraciones complejas. Las plataformas logísticas de múltiples sistemas
utilizan comúnmente la mensajería para integrar sin problemas tanto sistemas
heredados como modernos, orquestando operaciones complejas de manera
eficiente.

**Nota conceptual (Message Queues vs Event Brokers):** El material distingue
visualmente dos patrones dentro de la mensajería:
- **Message Queue:** los consumidores extraen (pull) mensajes, los procesan
  y los eliminan de la cola.
- **Event Broker:** los eventos se empujan (push) a los consumidores; el
  broker puede transmitir el mismo evento a múltiples consumidores y puede
  almacenar o descartar los eventos según su configuración.

## Procedimientos o procesos

### Proceso de Migración de Datos (Data Migration Process)

1. **Planning & Analysis** (Planificación y Análisis): definir objetivos,
   evaluar sistemas y asignar recursos.
2. **Data Extraction** (Extracción de Datos): extraer datos del sistema
   fuente de manera eficiente.
3. **Data Transformation** (Transformación de Datos): limpiar, estandarizar
   y enriquecer los datos extraídos.
4. **Data Loading** (Carga de Datos): cargar los datos transformados en el
   sistema destino.
5. **Testing & Validation** (Pruebas y Validación): asegurar la precisión de
   los datos y la funcionalidad del sistema.
6. **Deployment & Cutover** (Despliegue y Cutover): desplegar los datos
   migrados y cambiar (switch) al nuevo sistema.
7. **Post-Migration Support** (Soporte Post-Migración): proporcionar soporte
   continuo y monitorear el rendimiento del sistema.

### Buenas prácticas de planificación de la migración ("La Planificación lo
es Todo")

1. **Evaluar y Limpiar Datos:** identificar y corregir errores, eliminar
   duplicados y estandarizar formatos en los datos fuente.
2. **Mapear Campos de Datos:** mapear rigurosamente los campos de datos
   entre los sistemas antiguo y nuevo para garantizar un flujo de datos
   preciso e integridad.
3. **Desarrollar y Probar Escenarios:** crear y probar varios escenarios de
   migración para identificar problemas potenciales antes de la ejecución en
   vivo.
4. **Definir Planes:** definir claramente cronogramas, responsabilidades
   (texto parcialmente ilegible en la fuente) y establecer planes de
   comunicación robustos.

### Ejecución y Validación de la migración

1. Ejecutar la migración usando herramientas ETL especializadas o scripts
   personalizados.
2. Monitorear continuamente la transferencia de datos para garantizar
   precisión y completitud.
3. Validar datos comparando meticulosamente los conjuntos de datos fuente y
   destino post-migración.
4. Realizar pruebas funcionales integrales para confirmar la preparación
   operacional del nuevo sistema.

### Mejores prácticas de integración de sistemas (System Integration Best
Practices Funnel)

Presentado como un embudo de seis pasos:
1. **Plan Carefully** (Planificar cuidadosamente): desarrollar un plan de
   integración detallado, incluyendo el escalado.
2. **Choose Technologies** (Elegir tecnologías): seleccionar las tecnologías
   de integración apropiadas.
3. **Use Standardized Data** (Usar datos estandarizados): simplificar el
   mapeo de datos con formatos estandarizados.
4. **Implement Security** (Implementar seguridad): proteger los datos
   sensibles con medidas robustas.
5. **Test Thoroughly** (Probar exhaustivamente): asegurar la funcionalidad
   del sistema mediante pruebas.
6. **Monitor Performance** (Monitorear rendimiento): identificar y resolver
   problemas de forma proactiva.

## Ejemplos y casos

### Interoperabilidad en el sector salud

Diagrama que ilustra la interoperabilidad como habilitadora de "productos de
datos" (data products), conectando seis actores: hospitales, pacientes,
compañías farmacéuticas, planes de salud, proveedores (providers) y
laboratorios, todos girando alrededor del concepto central de
interoperabilidad.

### Principio arquitectónico de interoperabilidad (Dragon1 / healthcare)

Diagrama que muestra dos sistemas (A y B) conectados mediante una interfaz
que usa "Data Standards" (estándares de datos), con control de acceso
(Access Control), alimentando un registro de salud / archivo de paciente en
la nube, conectado a hospital, profesional de salud y paciente. El principio
enunciado es: "By having systems with open interfaces using standardized
data formats to exchange data, it is ensured data can flow freely, securely,
and unrestricted between systems, enabling organizations and professionals
to have easy and quick access to high-quality data providing better
services to clients and users."

### Walmart y EDI

Ver sección EDI arriba: la cadena de suministro global de Walmart depende
del EDI para procesamiento estandarizado de órdenes de alto volumen.

### Amazon y APIs

Ver sección APIs arriba: el sistema de inventario de Amazon usa APIs para
actualizar instantáneamente niveles de stock en diversas plataformas.

### Splice y Webhooks

Ver sección Webhooks arriba: seguimiento de exportaciones mediante
notificación instantánea de cambios de estado de contenedores.

### Uber y Kafka

Ver sección Mensajería arriba: Uber implementó Kafka como columna vertebral
de mensajería distribuida para su arquitectura basada en eventos a través de
microservicios.

### Diagrama "Systems Integration Services From Equipment to Cloud"

Imagen que ilustra de forma general un ecosistema de integración industrial
(manufactura/logística/salud) donde equipos, personal, robots, fábricas,
sistemas ERP, chips/dispositivos, almacenes y transporte están conectados
mediante flujos de datos que confluyen hacia la nube y sistemas centrales
(ERP). Sirve como imagen de apertura del tema "Integración de Sistemas",
sin detalle textual adicional específico más allá de mostrar la diversidad
de dominios que requieren integración (equipos, personas, ERP, nube,
logística, salud).

## Comparaciones

### EDI vs API (REST) vs Webhooks vs Mensajería (Colas)

| Característica | API (REST) | EDI | Webhooks | Mensajería (Colas) |
|---|---|---|---|---|
| Patrón Principal | Solicitud/Respuesta | Intercambio de Documentos | Publicación Dirigida por Eventos | Publicación/Suscripción Dirigida por Eventos |
| Temporización | Síncrono | Asíncrono (Por lotes) | Asíncrono | Asíncrono |
| Acoplamiento | Débil | Fuerte (vía estándares) | Débil (pero directo) | Muy Débil (desacoplado) |
| Flujo de Datos | Cliente extrae datos | Socio envía documento | Servidor envía datos | Productor envía al intermediario; Consumidor extrae |
| Mejor Para | UI, consultas ad-hoc | Transacciones B2B, mandatos | Notificaciones en tiempo real | Trabajos en segundo plano, flujos confiables |

### Migración de Datos vs. Integración de Datos

| Concepto A | Concepto B | Diferencia |
|---|---|---|
| Migración de Datos | Integración de Datos | La migración es un movimiento único y permanente de datos desde un origen A a un destino B; el sistema antiguo eventualmente se descomisiona. La integración es el proceso continuo de combinar datos de diferentes fuentes para proporcionar una vista unificada (p.ej. usando APIs para sincronización en tiempo real); los sistemas fuente permanecen activos. |

## Información visual relevante

### Espectro de complejidad de integración (Point-to-Point → Microservices)

Diagrama de flecha que ordena de "Simple" a "Sophisticated" los siguientes
patrones: Point-to-Point (conexiones directas que crean arquitectura
espagueti) → Hub-and-Spoke (hub central que simplifica pero crea cuello de
botella) → Enterprise Service Bus (comunicación estandarizada para
escenarios complejos) → iPaaS (entorno en la nube con conectores
preconstruidos) → Microservices Architecture (servicios independientes que
se comunican vía APIs).

### Diagrama de espina de pescado: Riesgos de mantener sistemas heredados

Ver detalle en sección "Riesgos ocultos" arriba. Agrupa causas en cuatro
categorías (rendimiento, seguridad, costos, conocimiento) que confluyen en
el efecto "Risks of Maintaining Legacy Systems".

### Diagrama de rombos escalonados: Evaluación de sistemas heredados

Cuatro pasos apilados en forma de diamante: Comprehensive System Audit →
Dependency Mapping → Technology Stack Evaluation → Prioritization
Frameworks.

### Diagrama tradicional de EDI (Buyer–Traditional EDI–Supplier)

Ilustra el flujo de un pedido de compra: el comprador genera una orden de
compra, se traduce a datos EDI, se mapea a datos de pedido, se carga en el
sistema del proveedor; en la dirección inversa, se genera una factura que
recorre el mismo camino de mapeo/traducción vía EDI, pasando por un
proveedor de servicios EDI punto a punto o en la nube.

### Diagrama de arquitectura API-céntrica

Muestra una API central conectando: aplicaciones móviles, aplicaciones web,
aplicaciones legadas, servidores de aplicación, servicios basados en la
nube, aplicaciones de socios (partner), recursos en la nube y datos —
ilustrando el rol de las APIs como conector universal entre tipos de
sistemas heterogéneos.

### Diagrama de límites de payload en arquitectura dirigida por eventos (AWS)

Muestra un "Webhook Provider" enviando datos hacia cuatro servicios AWS con
sus límites de payload: Amazon API Gateway (10mb), AWS Lambda (6mb), Amazon
DynamoDB (400kb), Amazon SQS (256kb con extensión). Ilustra una restricción
técnica práctica a considerar al diseñar integraciones basadas en eventos.

### Diagrama "Message Queues vs Event Brokers"

Compara dos patrones de mensajería: en Message Queue los consumidores
extraen (pull), procesan y eliminan mensajes de la cola (cada mensaje va a
un solo consumidor que lo procesa); en Event Broker los eventos se empujan
(push) a los consumidores y el broker puede enviar el mismo evento a
múltiples consumidores, pudiendo almacenar o descartar eventos.

### Diagrama Migración vs Integración (bases de datos)

Ilustra la migración como flechas bidireccionales entre dos bases de datos
(origen y destino), y la integración como un embudo que combina múltiples
fuentes de datos (iconos diversos) hacia un "Data Integration Process" que
produce una "Unified View" (vista unificada) en una laptop.

### Diagrama "Types of Data Migration"

Clasifica los tipos de migración de datos en seis categorías:
- **Storage Migration:** mover datos entre dispositivos de almacenamiento,
  a menudo para actualizaciones.
- **Database Migration:** mover datos entre sistemas de bases de datos,
  potencialmente cambiando el esquema.
- **Application Migration:** mover datos entre aplicaciones, posiblemente
  cambiando el formato de datos.
- **Cloud Migration:** mover datos desde sistemas on-premises a plataformas
  en la nube.
- **Data Center Migration:** mover datos entre diferentes ubicaciones de
  centro de datos.
- **Business Process Migration:** mover datos como parte de una
  transformación de procesos de negocio.

### Estadística destacada sobre riesgos de migración

El material destaca, como cifra clave: "Más del 80% de las migraciones de
datos enfrentan retrasos o sobrecostos", asociada a los siguientes desafíos:
problemas de calidad de datos, volumen de datos, compatibilidad del sistema,
tiempo de inactividad, riesgos de seguridad y falta de planificación.

## Terminología importante

- **Interoperabilidad de sistemas:** capacidad de diferentes sistemas de
  software para intercambiar y usar información sin problemas, sin
  necesidad de modificaciones significativas o integraciones
  personalizadas.
- **Sistema heredado (legacy):** software o tecnología construidos sobre
  plataformas obsoletas que siguen siendo críticos para las operaciones
  actuales; representan deuda tecnológica acumulada.
- **Deuda tecnológica:** acumulación de compromisos técnicos que resulta del
  uso continuado de plataformas obsoletas.
- **Vendor lock-in / "cautiverio":** dependencia de proveedores específicos
  o tecnologías propietarias que limita las alternativas viables y
  rentables.
- **Factor autobús ("bus factor"):** riesgo de perder la comprensión crítica
  de un sistema si el personal clave que posee ese conocimiento se marcha.
- **Integración de sistemas:** proceso de vincular diferentes sistemas
  informáticos y aplicaciones de software física o funcionalmente para
  actuar como un conjunto coordinado.
- **Acoplamiento:** grado de conexión/dependencia entre sistemas; factor
  clave al elegir método de integración.
- **EDI (Intercambio Electrónico de Datos):** formato digital estandarizado
  para intercambiar documentos comerciales entre organizaciones (estándares
  ANSI X12, EDIFACT).
- **API (Interfaz de Programación de Aplicaciones):** conjunto de reglas y
  protocolos que permiten a una aplicación solicitar servicios o datos de
  otra.
- **Webhook:** URL de callback que una aplicación llama automáticamente
  cuando ocurre un evento específico, evitando la necesidad de sondeo
  (polling) constante; también llamado "API inversa" o "API impulsada por
  eventos".
- **Mensajería (message broker / colas):** intermediario (p.ej. RabbitMQ,
  Apache Kafka, Amazon SQS) que permite a un productor publicar mensajes en
  una cola/tema sin conocer al consumidor, desacoplando ambos extremos.
- **Message Queue:** patrón de mensajería donde los consumidores extraen
  (pull), procesan y eliminan mensajes de la cola.
- **Event Broker:** patrón de mensajería donde los eventos se empujan (push)
  a los consumidores, pudiendo llegar a múltiples consumidores.
- **iPaaS (Integration Platform as a Service):** entorno en la nube con
  conectores preconstruidos para integración.
- **ESB (Enterprise Service Bus):** comunicación estandarizada para
  escenarios de integración complejos.
- **Migración de datos:** proceso de seleccionar, preparar, extraer,
  transformar y transferir datos de un sistema de almacenamiento o entorno a
  otro, de forma única y permanente.
- **ETL:** herramientas/scripts especializados usados para ejecutar la
  migración de datos (Extract, Transform, Load — mencionado como
  herramienta, sin desarrollo detallado de sus siglas en el material).
- **AS2:** protocolo mencionado como usado por EDI para proporcionar entrega
  segura y garantizada con recibos.

## Notas y advertencias

- La sigla "ETL" se menciona ("herramientas ETL especializadas") sin
  desarrollar su significado (Extract, Transform, Load) ni explicar sus
  fases dentro del propio documento — se registra como término mencionado
  pero no explicado en la fuente.
- El texto de la diapositiva "La Planificación lo es Todo", en el cuadro
  "Definir Planes", contiene una porción de texto truncada/ilegible en el
  PDF fuente ("Definir claramente cronogramas, [...]resados y establecer
  planes de [...]omunicación robustos para tr[...]cia."), lo que sugiere un
  error de renderizado o superposición de texto en el material original;
  se preserva el contenido legible.
- Los términos "Interoperabilidad" e "Integración de Sistemas" se presentan
  con definiciones textualmente casi idénticas en dos diapositivas
  consecutivas ("Conceptos Fundamentales" y "Enfoques Comunes de
  Integración de Sistemas" repiten el mismo párrafo introductorio sobre
  integración de sistemas), lo cual podría ser una repetición intencional
  del material o una duplicación de contenido en la presentación original.
- El diagrama de apertura de "Integración de Sistemas" ("Systems
  Integration Services From Equipment to Cloud") es principalmente
  ilustrativo/genérico (iconografía industrial); no aporta conceptos
  adicionales a los desarrollados textualmente en las diapositivas
  siguientes, más allá de reforzar la idea de que la integración abarca
  equipos físicos, personas, ERP y la nube.
- No se desarrolla en el documento el significado o mecanismo interno de
  AWS EventBridge ni de Azure Event Grid más allá de mencionarlos como
  "servicios en la nube que gestionan el enrutamiento y la limitación de
  eventos, simplificando integraciones complejas".
- El documento no profundiza en el "análisis de brechas" ni en "gobierno y
  cumplimiento" (mencionados en la recapitulación de Arquitectura
  Empresarial) más allá de una definición breve de una línea cada uno.