# Hito 2. Casos de interacción y elección de estilos de integración (Decisión arquitectónica)

Después de revisar nuevamente el escenario, considero que la estrategia más conveniente para GlobalLogistics Inc. es basar la interoperabilidad en **mensajería orientada a eventos**. Esta decisión me parece más sólida porque desacopla temporalmente a LogiMonolith y ShipTrack, reduce la dependencia entre ambos y permite que cada sistema procese la información a su propio ritmo sin comprometer la operación principal.

## 1. Matriz de Decisiones de Integración

| Caso de interacción (Origen ➔ Destino)                                                                 | Estilo de integración elegido                     | Justificación de arquitectura                                                                                                                                                                                                                    |
| ------------------------------------------------------------------------------------------------------ | ------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| **Creación de solicitud de envío (LogiMonolith ➔ ShipTrack)**                                          | **Message Broker / Command Message**              | LogiMonolith publica una solicitud como mensaje y ShipTrack la consume cuando esté disponible. Esto reduce el acoplamiento temporal y evita que el monolito dependa de la disponibilidad inmediata del servicio moderno.                         |
| **Actualización de estado de la orden (ShipTrack ➔ LogiMonolith)**                                     | **Message Broker / Domain Event**                 | ShipTrack emite un evento de cambio de estado y LogiMonolith lo procesa de forma asíncrona. Este enfoque es más resiliente que una llamada directa y evita que el microservicio quede bloqueado esperando respuesta del legacy.                  |
| **Sincronización de inventario tras un envío exitoso (ShipTrack ➔ LogiMonolith y otros consumidores)** | **Publish-Subscribe / Event-Driven Architecture** | El evento de envío completado puede ser consumido por varios sistemas sin duplicar lógica de integración. Esto mejora la escalabilidad funcional y permite que cada consumidor reaccione de forma independiente según su propia responsabilidad. |

## 2. Análisis de Compensaciones (Trade-offs)

Con este ajuste, yo evitaría una integración sincrónica basada en llamadas directas para los casos principales. Aunque una API REST podría parecer más simple al inicio, seguiría introduciendo dependencia inmediata entre los sistemas y haría que la disponibilidad de ShipTrack impactara directamente el flujo de LogiMonolith.

Al usar eventos, mantengo una separación más limpia entre responsabilidades: el monolito sigue siendo dueño de su operación transaccional y ShipTrack maneja la evolución de los envíos como un proceso desacoplado. A cambio, acepto mayor complejidad en la gestión de consistencia eventual, reintentos e idempotencia, pero considero que ese costo es razonable frente al beneficio de resiliencia y menor acoplamiento.
