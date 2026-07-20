# Hito 1. Comprensión del ecosistema y riesgos del legacy (Análisis inicial)

Antes de plantear una solución de integración, primero se analizó el estado actual del ecosistema de GlobalLogistics Inc. La empresa cuenta con dos sistemas muy diferentes entre sí: por un lado, un sistema monolítico que lleva aproximadamente 15 años en funcionamiento y soporta la operación principal del negocio; por otro, un microservicio moderno desarrollado para ofrecer seguimiento de envíos en tiempo real y capacidades analíticas.

En esta etapa no se busca definir cómo se van a integrar ambos sistemas. El objetivo es entender qué responsabilidades tiene cada uno, qué datos controla, cómo fluye la información entre ellos y cuáles son los principales riesgos que representa el sistema legado antes de iniciar cualquier proceso de interoperabilidad o migración.

## 1. Delimitación de Dominios y Responsabilidades (Mapeo de Capacidades)

### LogiMonolith (Java + SQL Server)

Se identifica a **LogiMonolith** como el sistema principal de la empresa. Es el responsable de administrar los procesos más importantes del negocio, como la gestión de clientes, inventario, facturación y órdenes. En otras palabras, es el sistema donde se ejecutan las operaciones que mantienen funcionando a la compañía día a día.

Después de 15 años de evolución, es normal que gran parte de la lógica de negocio esté muy ligada tanto al código Java como a la base de datos SQL Server. Esto hace que cualquier modificación pueda afectar otros procesos del sistema, incluso aquellos que aparentemente no tienen relación directa.

Además, toda la información crítica se encuentra almacenada en una única base de datos local. Este fenómeno se conoce como **gravedad de los datos (Data Gravity)**: mientras más información y procesos dependen de una misma base de datos, más difícil resulta mover funcionalidades o integrar nuevos sistemas sin afectar la operación existente. Por esta razón, considero que LogiMonolith sigue siendo el sistema con mayor responsabilidad sobre los datos transaccionales de la empresa.

### ShipTrack (Node.js + PostgreSQL + MongoDB)

Por otra parte, **ShipTrack** tiene un propósito completamente diferente. Su función principal es gestionar el seguimiento de los envíos en tiempo real y generar información útil para el análisis de las operaciones logísticas.

Al estar desarrollado como un microservicio cloud native y ejecutarse sobre Kubernetes, fue diseñado para procesar un alto volumen de solicitudes y adaptarse fácilmente al crecimiento de la empresa. El uso de PostgreSQL y MongoDB también muestra que busca combinar almacenamiento relacional para información estructurada y almacenamiento documental para datos más flexibles, como eventos o cambios de estado.

A diferencia de LogiMonolith, ShipTrack no pretende reemplazar las funciones principales del negocio. Su objetivo es complementar la operación ofreciendo información actualizada sobre los envíos y permitiendo realizar análisis sin afectar el rendimiento del sistema transaccional.

## 2. Matriz de Datos y Flujos de Información Críticos

La siguiente tabla resume qué sistema es responsable de cada tipo de información, dónde se almacena y cómo debe fluir entre ambos sistemas para cumplir con los requisitos del negocio.

| Entidad de datos       | Sistema responsable | Almacenamiento       | Flujo de datos                                                                                    |
| ---------------------- | ------------------- | -------------------- | ------------------------------------------------------------------------------------------------- |
| Clientes               | LogiMonolith        | SQL Server           | Unidireccional hacia ShipTrack para consultas relacionadas con los envíos.                        |
| Facturación            | LogiMonolith        | SQL Server           | Permanece únicamente en LogiMonolith; ShipTrack solo necesita información de referencia.          |
| Inventario             | LogiMonolith        | SQL Server           | Unidireccional hacia ShipTrack para relacionar los productos con los envíos.                      |
| Órdenes                | LogiMonolith        | SQL Server           | Bidireccional. LogiMonolith crea la orden y ShipTrack informa los cambios en el estado del envío. |
| Solicitudes de envío   | ShipTrack           | PostgreSQL / MongoDB | Se originan desde LogiMonolith y son procesadas por ShipTrack.                                    |
| Estados de envío       | ShipTrack           | PostgreSQL / MongoDB | Se envían de regreso a LogiMonolith para mantener actualizada la información de las órdenes.      |
| Historial de envíos    | ShipTrack           | PostgreSQL / MongoDB | Migración inicial desde SQL Server y posteriormente administrado por ShipTrack.                   |
| Eventos de seguimiento | ShipTrack           | MongoDB              | Flujo principalmente unidireccional para registrar eventos y consultas analíticas.                |

A partir de esta matriz se concluye que ambos sistemas deben compartir información, pero no deben ser responsables de los mismos datos. LogiMonolith continúa siendo el sistema principal para la información del negocio, mientras que ShipTrack se convierte en el responsable de toda la información relacionada con el seguimiento de los envíos. Mantener esta separación de responsabilidades ayuda a reducir inconsistencias y facilita la integración entre ambas plataformas.

## 3. Diagnóstico de Riesgos Críticos y Limitaciones del Legacy

### Acoplamiento entre la aplicación y la base de datos

El primer riesgo que identifico es el fuerte acoplamiento entre LogiMonolith y su base de datos SQL Server. Después de muchos años de evolución, es muy probable que gran parte de la lógica del negocio dependa directamente de tablas, procedimientos almacenados y estructuras específicas de la base de datos. Esto significa que cualquier cambio en el esquema puede afectar múltiples funcionalidades del sistema. Además, si otros sistemas comienzan a depender directamente de esa base de datos para obtener información, el nivel de dependencia aumentará todavía más y será mucho más difícil mantener o evolucionar la aplicación sin generar problemas.

### Obsolescencia tecnológica y dificultad para evolucionar

Otro riesgo importante es la antigüedad del sistema. Un monolito desarrollado hace 15 años normalmente acumula deuda técnica, componentes desactualizados y una estructura que no fue diseñada para integrarse fácilmente con aplicaciones modernas. Esto hace que implementar nuevas funcionalidades o exponer nuevas interfaces requiera más esfuerzo y aumente el riesgo de introducir errores. Mientras ShipTrack puede evolucionar rápidamente gracias a su arquitectura moderna, LogiMonolith probablemente necesitará cambios más cuidadosos y ciclos de pruebas más extensos.

### Impacto en el rendimiento durante la integración y la migración

También considero que existe un riesgo importante relacionado con el rendimiento. La base de datos SQL Server soporta procesos críticos como la facturación, el inventario y la gestión de órdenes. Si durante la integración o la migración se realizan consultas muy pesadas o se extraen grandes cantidades de información histórica, estas operaciones pueden competir con las transacciones diarias del negocio. Como consecuencia, podrían aumentar los tiempos de respuesta, aparecer bloqueos en la base de datos e incluso afectar la disponibilidad del sistema durante las horas de mayor uso.

### Riesgo de modificar procesos críticos del negocio

Finalmente, modificar un monolito de estas características siempre implica un riesgo considerable. Debido a la cantidad de funcionalidades que concentra, un cambio aparentemente pequeño puede terminar afectando otros procesos que no fueron considerados inicialmente. Si además la aplicación cuenta con pocas pruebas automatizadas o documentación limitada, la probabilidad de generar regresiones es todavía mayor. Desde mi punto de vista, esta deuda técnica representa uno de los principales desafíos para cualquier iniciativa de modernización, ya que obliga a avanzar con mucho cuidado para no comprometer la estabilidad de la operación actual.
