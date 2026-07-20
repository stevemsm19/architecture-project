# Hito 5. Arquitectura integrada y narrativa final

## 5.1 Arquitectura integrada

La arquitectura integrada consolida los mecanismos definidos en los hitos anteriores para conectar LogiMonolith y ShipTrack sin introducir una dependencia síncrona entre ambos. LogiMonolith conserva la responsabilidad sobre la operación transaccional y sus datos en SQL Server, mientras que ShipTrack gestiona el ciclo de vida y el seguimiento de los envíos. La comunicación entre ambos dominios se realiza mediante eventos, con Kafka como broker y una Capa Anti-Corrupción (ACL) independiente que protege los modelos de cada sistema.

![!\[alt text\](image-3](../../documentation/images/laboratories/diagram_h5_we2.png)

El flujo de salida se inicia con la creación de una orden en LogiMonolith. En la misma operación transaccional se registra el evento correspondiente en Transactional Outbox, de modo que la orden y el evento mantengan consistencia. Debezium CDC detecta dicho registro y lo publica en Kafka. A continuación, la ACL consume el evento, verifica la idempotencia y la correlación mediante su State Store, y traduce el modelo del legacy al contrato requerido por ShipTrack.

ShipTrack procesa la solicitud recibida, persiste la información operativa en PostgreSQL y registra los eventos e historial de tracking en MongoDB. Cuando se produce un cambio relevante de estado, ShipTrack publica el evento en Kafka. La ACL recibe el evento de retorno, valida nuevamente su procesamiento, traduce los estados e identificadores al modelo del legacy y escribe la actualización en Inbox. Finalmente, LogiMonolith consume Inbox y actualiza el estado final de la orden en SQL Server. El cliente consulta el estado del envío a través de ShipTrack, sin requerir acceso directo al sistema legado.

## 5.2 Narrativa end-to-end

El siguiente recorrido describe el ciclo completo de una solicitud de envío, desde su creación en el sistema legado hasta la actualización de su estado final. Cada componente participa con una responsabilidad específica, lo que permite mantener el desacoplamiento entre LogiMonolith y ShipTrack.

1. **Creación de la orden.** Un operador logístico registra una nueva orden y su solicitud de envío en LogiMonolith. El monolito aplica sus reglas de negocio y persiste la información transaccional en SQL Server, que continúa siendo la fuente de referencia para órdenes y procesos críticos del negocio.

2. **Escritura en Transactional Outbox.** Dentro de la misma transacción en la que se guarda la orden, LogiMonolith registra un evento de solicitud de envío en la tabla Transactional Outbox. De esta manera, la persistencia de la orden y la generación del evento ocurren de forma atómica, evitando el Dual Write Problem.

3. **Captura mediante Debezium CDC.** Debezium CDC detecta la inserción realizada en Outbox. Este componente permite capturar el cambio sin que LogiMonolith deba conectarse directamente a Kafka ni incorporar lógica de publicación de eventos en su núcleo transaccional.

4. **Publicación en Kafka.** Debezium publica el evento capturado en Kafka. El broker desacopla temporalmente al productor y a los consumidores, por lo que la solicitud puede mantenerse disponible para su procesamiento sin depender de la disponibilidad inmediata de ShipTrack.

5. **Consumo y validación en la ACL.** La ACL consume el evento desde Kafka. Antes de continuar, consulta y actualiza el ACL State Store para controlar la idempotencia, correlacionar identificadores y evitar que un mensaje duplicado genere más de un envío.

6. **Traducción y creación del envío en ShipTrack.** La ACL transforma el modelo relacional y los identificadores del legacy al contrato JSON esperado por ShipTrack. Una vez aplicada esta traducción, entrega la solicitud al microservicio, que crea el envío conforme a sus propias reglas de negocio sin conocer los detalles internos de LogiMonolith.

7. **Almacenamiento operativo en PostgreSQL.** ShipTrack persiste los datos estructurados del envío en PostgreSQL. Esta base relacional soporta la información operativa necesaria para consultar y gestionar el envío durante su ciclo de vida.

8. **Generación y almacenamiento de eventos de tracking.** A medida que el envío avanza, ShipTrack genera eventos de tracking, como recolección, tránsito o entrega. Estos eventos y su historial se almacenan en MongoDB, cuya estructura documental permite conservar información flexible y trazable.

9. **Publicación del cambio de estado.** Cuando ShipTrack identifica un cambio relevante de estado, publica un evento de dominio en Kafka. Con ello, el microservicio informa el cambio sin realizar una llamada síncrona al sistema legado.

10. **Entrega del evento de retorno a la ACL.** Kafka entrega el evento de estado a la ACL. El uso del mismo broker conserva el desacoplamiento temporal en el flujo de retorno y permite procesar la actualización cuando los componentes estén disponibles.

11. **Traducción inversa y control de idempotencia.** La ACL valida el evento en su State Store y traduce el estado, los identificadores y el formato de ShipTrack al modelo que LogiMonolith reconoce. Así se evita que conceptos propios del dominio moderno se filtren hacia el sistema legado.

12. **Escritura en Inbox.** La ACL escribe la actualización traducida en la tabla Inbox de LogiMonolith. Inbox funciona como un punto de recepción confiable para las actualizaciones pendientes y evita que el legacy dependa de una llamada directa desde ShipTrack o desde la ACL.

13. **Consumo de Inbox por LogiMonolith.** LogiMonolith procesa la actualización almacenada en Inbox según su propio ritmo. Este mecanismo permite que el sistema legado conserve control sobre el momento en que aplica cambios en sus procesos transaccionales.

14. **Actualización del estado final.** Después de procesar el mensaje, LogiMonolith actualiza el estado de la orden en SQL Server. Como resultado, el sistema legado refleja el avance informado por ShipTrack, mientras que ambos sistemas mantienen sus responsabilidades y modelos de datos independientes.

El recorrido evidencia que la consistencia entre los dominios es eventual. No obstante, Transactional Outbox, CDC, Kafka, ACL e Inbox permiten tratar los fallos, los reintentos y los mensajes duplicados sin comprometer la consistencia de las transacciones críticas del monolito. La migración histórica gradual mediante ETL y CDC complementa este flujo operativo al incorporar los datos previos a PostgreSQL y MongoDB sin afectar la continuidad del sistema transaccional.

## 5.3 Reflexión personal

Después de desarrollar este caso, considero que el conocimiento adquirido será útil para enfrentar integraciones similares en la industria. Este ejercicio permitió comprender que integrar un sistema legacy con una arquitectura moderna implica mucho más que conectar dos aplicaciones; también requiere definir responsabilidades, mantener el desacoplamiento y elegir patrones que reduzcan los riesgos durante la integración.

Ahora tengo una mejor comprensión de conceptos como Event-Driven Architecture, Transactional Outbox, CDC, Inbox Pattern y la Capa Anti-Corrupción, así como de las ventajas y los compromisos que implica utilizar cada uno. Además, el análisis de la migración gradual de datos permitió entender por qué, en muchos escenarios, es preferible priorizar la continuidad operativa sobre una migración rápida.

Considero que este aprendizaje facilitaría participar o incluso apoyar la toma de decisiones en un proyecto de integración similar. Sin embargo, todavía sería necesario adquirir experiencia práctica para liderar un equipo con total confianza, especialmente en aspectos relacionados con la operación de sistemas reales y la coordinación entre equipos. Aun así, este ejercicio proporcionó una base sólida para comprender este tipo de arquitecturas y los desafíos que presentan.
