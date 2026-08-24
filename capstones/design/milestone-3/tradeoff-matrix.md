# Milestone 3 — Matriz Formal de Trade-offs

> Este documento formaliza, con los ejes exactos que pide `plan/milestones.pdf`
> para Milestone 3, la comparación que `design/milestone-2/architecture-decision.md`
> justificó de forma liviana dentro del ADR. **No se generan alternativas
> nuevas**: cada "opción descartada" de este documento es una alternativa que
> `architecture-strategist` ya consideró y rechazó explícitamente en Milestone 2
> — ver `design/milestone-2/architecture-decision.md` y `design/adr/adr-0001-*.md`
> a `design/adr/adr-0013-*.md` (incluida la corrección de iteración extra de
> `ADR-0008` y la reapertura parcial resuelta por `ADR-0013`). Cada valoración
> cita el concepto de `knowledge/index.md` que la sostiene. Ninguna cifra de
> costo es un dato duro: toda estimación de costo está marcada explícitamente
> `~estimado`.
>
> Este documento **no evalúa riesgos operacionales** (NIS caído, dispositivo
> offline, pérdida de conectividad) — eso es responsabilidad de
> `architecture-risk` (Milestone 3, documento separado). Tampoco recomienda
> cambiar la arquitectura elegida en Milestone 2: solo hace visible su costo.
> Si algún costo resulta preocupante, se señala como hallazgo para que
> `architecture-reviewer` decida si reabre Milestone 2.

## Nota de actualización (post-DEC-0013)

`design/adr/adr-0013-monolito-modular-fase1-extraccion-selectiva.md` (Aceptado)
reemplaza el alcance de "día 1" de `DEC-0001`: **Monolito Modular por Bounded
Context en Fase 1** (mismos 5 bounded contexts como módulos internos, con
límites aislados a nivel de esquema/namespace lógico), con **extracción
selectiva vía Strangler Pattern en Fase 2**, activada por triggers
verificables (no por fecha ni por promesa). Esta decisión resuelve **RISK-01
(RST-01)** — el hallazgo que esta misma matriz había señalado como propio y
no resuelto en su primera pasada: la ausencia de un punto intermedio de
complejidad entre Monolito y Microservicios completos.

Esta pasada ajusta los tres ejes que `ADR-0013` señaló como desactualizados
(ver su sección "Nota de impacto sobre decisiones existentes"):

- **Eje 1** se reformula por completo: ya no compara Monolito vs. MSA+EDA
  completo como dos extremos estáticos, sino **Monolito Modular Fase 1
  (elegida, `DEC-0013`) vs. Microservicios completos desde el día 1
  (descartada, `ADR-0001` Alternativa 2 original / `ADR-0013` Alternativa A)**.
- **Eje 2** se precisa con una nota de aplicabilidad por fase: la comparación
  Event-driven vs. REST síncrono documentada aquí es una decisión sobre la
  **topología de destino** (Fase 2), no sobre la Fase 1 (donde no existe
  frontera de red entre bounded contexts).
- **Eje 4** se confirma explícitamente, en vez de asumirse: `DEC-0005`
  (nivel de dispositivo) no cambia; `DEC-0006` (backend-a-backend, citado
  dentro de este mismo eje) sí queda en pausa en Fase 1.
- **Eje 3** se confirma explícitamente sin cambios: `DEC-0004` solo recibió
  una nota de revisión sobre el "cómo" físico del tiering en Fase 1, no sobre
  la decisión de fondo.

## Nota de alcance sobre el eje "REST vs. Event-driven"

A diferencia de los otros tres ejes (donde Milestone 2 dejó una comparación
binaria explícita a nivel de estilo completo, con "Alternativa" numerada y
sección "Por qué no se eligió"), **no existe en Milestone 2 un ADR único que
compare "REST" contra "Event-driven" como estilo de comunicación global**.
Esa decisión quedó parcialmente disuelta dentro de `ADR-0001` (elección de
MSA+EDA sobre monolito) y se resuelve de forma más granular, interacción por
interacción, en `ADR-0006`, `ADR-0007` y `ADR-0008`. Se deja constancia
explícita de este vacío de especificidad de Milestone 2: la matriz de este
eje se construye con la evidencia real más cercana disponible (la comparación
explícita REST-síncrono-en-lote vs. proyección-por-eventos de `ADR-0008`, y el
uso deliberado de REST síncrono retenido en `ADR-0006` y `ADR-0007`), en vez
de con una alternativa de paja fabricada para este milestone. `architecture-reviewer`
evaluó este hallazgo en el gate de reapertura de Milestone 3 (Iteración 1,
Hallazgo 2) y **decidió mantenerlo como está, sin cambios** — no amerita un
ADR de estilo de comunicación dedicado en esta pasada. Lo que sí se precisa
en esta pasada, con el contexto nuevo que aporta `DEC-0013`, es **cuándo**
se activa esta decisión — ver "Nota de aplicabilidad por fase" dentro del
Eje 2.

---

## Eje 1: Monolito Modular Fase 1 vs. Microservicios completos desde el día 1

**Opción elegida (M2, revisada M3 — `DEC-0013`)**: Monolito Modular por
Bounded Context (Fase 1), con extracción selectiva vía Strangler Pattern
activada por triggers verificables (Fase 2) — `DEC-0013`/`ADR-0013`, que
reemplaza el alcance de "día 1" de `DEC-0001`. Los cinco bounded contexts
(Identidad y Credenciales, Registro y Verificación, Captura de Asistencia,
Reportes y Analítica, Notificaciones) siguen vigentes como límites lógicos —
el criterio DDD de separación no cambia. Lo que cambia es el mapeo físico de
despliegue: de 5 servicios independientes a 5 módulos dentro de 1
desplegable, aislados a nivel de esquema/namespace lógico (no físico).

**Alternativa descartada (M2, reconfirmada como descartada en M3)**:
Microservicios completos desde el día 1 (5 servicios independientes + broker
de eventos + motor de Saga dedicado + persistencia políglota física en 5+
almacenes + los 7 mecanismos de resiliencia de `ADR-0006` a `ADR-0009`) — la
Alternativa 2 original de `design/milestone-2/architecture-decision.md`/
`ADR-0001`, reevaluada y descartada explícitamente **como plan de día 1** por
`ADR-0013` (su Alternativa A: "Mantener MSA+EDA completo desde el día 1, con
automatización agresiva como mitigación de RST-01").

> Nota: el Monolito Modular *sin* extracción selectiva (Alternativa 1
> original de `architecture-decision.md`, sin triggers ni Strangler Pattern
> de Fase 2) no es una tercera alternativa: `ADR-0013` la retoma casi
> textualmente como su Fase 1, agregándole exactamente lo que le faltaba
> (triggers de extracción verificables para una Fase 2). No se generó
> ninguna alternativa nueva para completar esta tabla.

| Criterio | Monolito Modular Fase 1 (elegida, `DEC-0013`) | Microservicios completos día 1 (descartada, `ADR-0001` Alt. 2 / `ADR-0013` Alt. A) | Cita en knowledge/ |
|---|---|---|---|
| Escalabilidad | Escala verticalmente como una sola instancia en Fase 1; el Anexo de `architecture-decision.md` (pico estimado ~50-55 eventos/seg agregados en toda la red) confirma que el volumen proyectado a 15.000 usuarios (`DRV-01`) cabe cómodamente en esa capacidad sin fragmentación física — la escalabilidad de grano fino se pospone, no se pierde: Fase 2 la habilita selectivamente vía Strangler Pattern cuando un trigger verificable (campus activos > 10, o contención de I/O medida en dos ventanas pico consecutivas) lo confirme con evidencia real, no con estimación anticipada | Escala de grano fino desde el día 1 (cada bounded context escala de forma independiente), pero paga esa capacidad por adelantado, antes de que el volumen real (según el propio Anexo) la exija — sobre-aprovisionamiento de complejidad frente a un requisito que la Fase 1 ya satisface con una sola instancia | Semana 5 (MSA I) — Escalabilidad como "propiedad arquitectónica", distinción escalamiento vertical/horizontal; Semana 6 (MSA II), "Evolución del pensamiento... fase pragmática (actual)": "considerar un monolito modular como alternativa viable si el tamaño del equipo/dominio no justifica la sobrecarga" |
| Complejidad operativa | Menor: un solo pipeline de CI/CD, un solo desplegable, sin Service Discovery ni orquestación de contenedores multi-servicio, sin broker de eventos ni motor de Saga dedicado — los mecanismos de `ADR-0002` (Saga), `ADR-0006` (Circuit Breaker Captura↔Identidad) y `ADR-0008` (proyección vía broker) se implementan como principios internos (cola de trabajos, llamada en proceso) o quedan **en pausa** hasta que un trigger de Fase 2 se cumpla | Mayor: exactamente el escenario que `design/milestone-3/risk-register.md` (RISK-01) califica como el único riesgo con Probabilidad Alta + Impacto Alta simultáneos para un equipo de una persona — 5 servicios, un broker, un motor de Saga, persistencia políglota en 5+ almacenes y 7 mecanismos de resiliencia operando en conjunto desde el primer commit | Semana 5 (MSA I), "Notas y advertencias": "MSA... generalmente no se recomienda para equipos pequeños o aplicaciones simples que están comenzando, donde una arquitectura monolítica sería más simple y eficiente" — afirmación normativa del propio material; Semana 5, "recomendaciones de adopción": "Empezar Pequeño y Planificar" e "Invertir en Infraestructura" como precondiciones de MSA; Semana 6 (MSA II) — anti-patrón **Monolito Distribuido** (servicios fuertemente acoplados que deben desplegarse juntos), el riesgo real que `risk-register.md` identifica en operar 5 servicios sin la disciplina/infraestructura que MSA exige |
| Costo (~estimado) | ~estimado menor: no requiere API Gateway multi-servicio, Service Discovery, orquestación de contenedores ni broker de eventos como infraestructura de Fase 1 — el costo de migración del Strangler Pattern (mantener temporalmente dos caminos: llamada en proceso y llamada al nuevo servicio) se paga **solo si y cuando** un trigger de Fase 2 se activa, no por adelantado; sin cifra dura disponible | ~estimado mayor: requiere la infraestructura de soporte completa de MSA (API Gateway, Service Discovery, Load Balancer, containerización/orquestación, observabilidad distribuida) desde el primer día, independientemente de si el volumen real ya la justifica; sin cifra dura disponible | Semana 5 (MSA I) — infraestructura de soporte de MSA como componentes adicionales que el monolito no requiere; Semana 6 (MSA II) — Patrón de estrangulamiento (Strangler Pattern): "descomponer gradualmente un monolito extrayendo funcionalidad rebanada por rebanada... dirigiendo el tráfico con el tiempo" (costo de migración incremental y condicionado, no de una vez por adelantado) |
| Rendimiento | Cumple el SLA de ≤15s p95 (`ADR-0003`) con una estrategia más simple en Fase 1 (réplica de lectura/vista materializada dentro del mismo motor, en vez de proyección distribuida); el aislamiento a nivel de esquema/namespace lógico reduce, pero no elimina completamente, el riesgo de contención de I/O entre la escritura de asistencia y la lectura de reportes dentro de un mismo motor compartido — riesgo que `ADR-0013` convierte explícitamente en su **trigger 2 de extracción de Fase 2** (degradación medible de latencia de Reportes, observada en dos ventanas pico consecutivas) | La ruta de escritura no compite con la ruta de lectura gracias a Base de Datos por Servicio física + CQRS completamente distribuido — pero paga esa separación total de recursos antes de que la contención real se haya medido u ocurrido siquiera una vez | Semana 4 — CQRS como mecanismo de contrapresión (el principio aplica en ambos casos, con distinto grado de aislamiento físico de los recursos); Semana 5 (MSA I) — Escalabilidad y Optimización de Recursos: "en un monolito, habría que escalar toda la aplicación... lo cual es ineficiente" (riesgo reconocido por el material y mitigado en Fase 1 por el Anexo de carga pico y por el trigger 2 de `ADR-0013`) |
| Seguridad | El aislamiento de datos sensibles se confina a nivel de esquema/namespace lógico dentro de un almacén compartido, no a nivel de Base de Datos por Servicio física — `ADR-0013` reconoce explícitamente que esto debilita parcialmente `DRV-03` y lo acepta como deuda porque `RST-01` (restricción no negociable) pesa más que `DRV-03` en este trade-off; menos superficie de red interna que asegurar (un solo desplegable) compensa parcialmente | Base de Datos por Servicio física confina el radio de exposición de datos sensibles al propio contexto de forma más estricta, a costa de más superficie de red interna (canales entre 5 servicios) que asegurar | Semanas 6-7 — Base de Datos por Servicio (confinamiento de exposición por contexto); Semana 6 (MSA II) — acoplamiento débil "a nivel de módulo/paquete, reforzado por límites en tiempo de compilación" en el monolito modular, descrito explícitamente como "campo de entrenamiento para la disciplina" que sostiene una eventual migración futura |

**Conclusión del eje**: se eligió Monolito Modular Fase 1 (`DEC-0013`) porque
resuelve **RISK-01/RST-01** (restricción no negociable: equipo de una sola
persona) sin comprometer `DRV-01` en el volumen proyectado a 2 años — el
Anexo de carga pico ya demuestra que ese volumen cabe cómodamente en una
sola instancia bien diseñada — sacrificando deliberadamente el aislamiento
físico completo de datos sensibles (`DRV-03`) y la escalabilidad de grano
fino inmediata frente a los Microservicios completos día 1. `ADR-0013`
acepta este trade-off explícitamente como "deuda que se acepta", pagando el
costo de migración del Strangler Pattern solo si y cuando la evidencia real
(no la estimación) lo justifique en Fase 2. **El hallazgo RST-01, que esta
misma matriz había señalado en su primera pasada como no resuelto por falta
de un punto intermedio de complejidad entre los dos extremos comparados,
queda resuelto por esta reapertura** — ya no vuelve a listarse como hallazgo
abierto en la sección final de este documento.

---

## Eje 2: REST (síncrono) vs. Event-driven (broker de eventos)

**Opción elegida (M2)**: Event-driven (broker de eventos) como columna
vertebral de comunicación entre bounded contexts (`DEC-0001`), con REST
síncrono retenido de forma deliberada y acotada en dos puntos: validación de
credencial en tiempo real (`DEC-0006`/`ADR-0006`) e integración con el NIS
por restricciones de un tercero no controlado (`DEC-0007`/`ADR-0007`).
**Alternativa descartada (M2)**: REST síncrono generalizado para el refresco
de estado entre contextos — documentada explícitamente como "Alternativa C"
en `ADR-0008` (`GET /identity/credentials/changes?since=<ts>`, llamada
síncrona repetida en alta frecuencia, sin proyección local por eventos).

### Nota de aplicabilidad por fase (post-DEC-0013)

`DEC-0013` (Milestone 3) precisa el alcance temporal de este eje, resolviendo
con más contexto la ambigüedad que esta misma matriz había señalado en su
primera pasada (ver "Nota de alcance" arriba): la comparación Event-driven
(backbone) vs. REST síncrono en lote (`ADR-0008`, Alternativa C) es una
decisión sobre la **topología de destino** del sistema, no sobre su Fase 1.
En Fase 1 (día 1, Monolito Modular), **este eje no es una decisión operativa
activa**: no existe frontera de red entre bounded contexts (todos son
módulos del mismo proceso), por lo que no hay ni un broker de eventos
desplegado ni llamadas REST síncronas inter-servicio que comparar en la
práctica. `ADR-0013` deja explícitamente **en pausa** los dos mecanismos que
este eje compara en detalle — `ADR-0006` (Circuit Breaker Captura↔Identidad,
backend-a-backend) y `ADR-0008` (proyección de caché del Dispositivo DAS vía
broker de eventos) — hasta que se cumpla el trigger de extracción de Captura
de Asistencia (Fase 2). En ese momento, el mecanismo ya especificado en
ambos ADRs vuelve a ser exactamente necesario tal cual está, y este eje pasa
a tener vigencia operativa real.

Este eje sigue documentando una decisión de diseño legítima — no descartada,
solo diferida en el tiempo —: la tabla de abajo compara el backbone de
destino contra la alternativa descartada, tal como se especificó en
Milestone 2. La novedad de esta pasada es dejar explícito **cuándo** se
activa esa decisión, lo que resuelve con más precisión el vacío de
especificidad que esta matriz había señalado originalmente. El vacío de
fondo — no existe un ADR único de estilo de comunicación global — **sigue
sin resolverse**: `architecture-reviewer` confirmó explícitamente, en el
gate de reapertura de Milestone 3 (Iteración 1, Hallazgo 2), que se acepta
como está, sin cambios; esta pasada no lo reabre, solo agrega la
precisión de fase que faltaba.

| Criterio | Event-driven (elegida, backbone de destino — vigente desde Fase 2) | REST síncrono (descartada, `ADR-0008` Alt. C) | Cita en knowledge/ |
|---|---|---|---|
| Escalabilidad | Desacopla productores/consumidores; permite que Captura y Reportes/refresco de caché escalen sin depender de la disponibilidad síncrona del contexto emisor | Acopla capacidad y disponibilidad del llamador y el llamado; `ADR-0008` señala que "perpetúa el acoplamiento de disponibilidad entre ambos contextos para esta ruta" | Semana 3 (Rendimiento I) — EDA: componentes productor/canal-broker/consumidor y su rol de desacoplamiento |
| Complejidad operativa | Mayor: gestión de esquema de eventos, ordering, consistencia eventual | Menor: `ADR-0008` reconoce como pro de la alternativa descartada que es "más simple de razonar que mantener una proyección local duplicada" | Semana 3 — EDA, desafíos explícitos: "ordering, complejidad, consistencia eventual, monitoreo, gestión de esquema, idempotencia" |
| Costo (~estimado) | ~estimado mayor: requiere operar un broker de eventos como infraestructura adicional, sin cifra dura disponible | ~estimado menor: reutiliza infraestructura HTTP síncrona ya existente, sin componente de mensajería dedicado adicional | Semana 3 — Broker de mensajes: "software intermediario que gestiona colas, temas, intercambios y reglas de enrutamiento" como pieza de infraestructura propia |
| Rendimiento | Elimina estructuralmente la saturación del Circuit Breaker del camino síncrono crítico de escaneo (`ADR-0008`: "elimina estructuralmente la saturación... que ADR-0006 fue diseñado para mitigar") | Alto riesgo de saturar el mismo Circuit Breaker que protege el camino crítico: para miles de `dasId` por campus cada 15 min, generaría "el propio incidente de backend degradado que ADR-0006 busca mitigar" | Semana 7 — Circuit Breaker (máquina de estados Cerrado/Abierto/Semi-abierto) como protección del camino síncrono; Semana 4 — CQRS/proyección de lado de lectura como alternativa asíncrona a esa carga |
| Seguridad | Base de Datos por Servicio + proyección local acotan la ventana de exposición ante revocación al mismo TTL ya declarado (`ADR-0009`); REST síncrono se retiene deliberadamente en `ADR-0006` para la validación de credencial en el momento del escaneo, donde la exactitud inmediata pesa más que el desacoplamiento | La alternativa descartada de REST síncrono en lote no agrega riesgo de seguridad distinto al del REST retenido, pero sí multiplica la frecuencia de llamadas hacia un contexto con datos sensibles (Identidad) | Semanas 6-7 — Base de Datos por Servicio, acoplamiento débil vía "bounded contexts + ACL"; Semana 7 — Circuit Breaker + fail-open acotado (`ADR-0006`) como táctica de resiliencia para el caso donde se prioriza `DRV-03` sobre `DRV-05` |

**Conclusión del eje**: se eligió Event-driven como backbone porque optimiza
el desacoplamiento de disponibilidad entre contextos y evita saturar el
camino síncrono crítico de escaneo (`DRV-01`, `DRV-05`), sacrificando
simplicidad de razonamiento y añadiendo desafíos de consistencia
eventual/gestión de esquema. REST síncrono no se elimina: se retiene de
forma acotada donde la exactitud inmediata lo exige (validación de
credencial, `ADR-0006`) o donde un tercero no controlado lo impone
(integración NIS vía polling, `ADR-0007`) — es un balance contextual, no una
sustitución total, y ese matiz **no** está resuelto por un único ADR de
estilo de comunicación en Milestone 2 (ver "Nota de alcance" arriba).
**Nota post-`DEC-0013`**: esta decisión de backbone describe la topología de
destino del sistema (Fase 2); en Fase 1 (día 1, Monolito Modular) no aplica
operativamente — no hay broker desplegado ni REST inter-servicio por red que
comparar — ver "Nota de aplicabilidad por fase" arriba.

---

## Eje 3: Base de datos relacional (homogénea) vs. híbrida (políglota por capas)

**Opción elegida (M2)**: Base de Datos por Servicio + Persistencia Políglota
con retención por capas caliente/tibio/frío sobre `EventoDeAsistencia`
(`DEC-0001`, `DEC-0004`/`ADR-0004`). **Alternativa descartada (M2)**: "Un
único almacén homogéneo para todo el horizonte de 5 años" — Alternativa A de
`ADR-0004`.

| Criterio | Híbrida por capas (elegida) | Homogénea/relacional única (descartada) | Cita en knowledge/ |
|---|---|---|---|
| Escalabilidad | Capa caliente optimizada para escritura de alto volumen y consulta de baja latencia, sin comprometerse por el volumen histórico acumulado a 5 años | Un único almacén debe balancear escritura near-real-time y conservación de bajo costo simultáneamente; ADR-0004: "obliga a un compromiso que probablemente no satisfaga bien a ninguno de los dos extremos" | Semanas 5-6-7 — Persistencia Políglota: "libertad de cada servicio para elegir la tecnología de base de datos... más adecuada a sus necesidades" |
| Complejidad operativa | Mayor: requiere proceso automatizado de transición entre capas y que la ruta "histórica" de Reportes sepa consultar contra el almacén frío con distinta latencia esperada (ADR-0004, negativas) | Menor: modelo de datos y operación más simples, sin lógica de transición entre capas (ADR-0004, pros de la alternativa A) | Semanas 6-7 — Base de Datos por Servicio como patrón de gestión de datos descentralizada, con la complejidad operativa adicional que introduce frente a un almacén único |
| Costo (~estimado) | ~estimado menor en el largo plazo: el almacén frío se optimiza específicamente para costo (ASM-13 confirma que consulta histórica más lenta es aceptable), a costa de una lógica de tiering con costo operativo propio — sin cifra dura disponible | ~estimado mayor si se dimensiona un único almacén para sostener rendimiento near-real-time durante los 5 años completos de retención, sin aprovechar la diferencia de patrón de acceso que ASM-13 habilita | Semanas 6-7 — Persistencia Políglota como mecanismo que habilita optimizar costo por patrón de acceso (sin que el material del curso dé cifras concretas de costo) |
| Rendimiento | Cumple el SLA de ≤15s p95 fijado en `ADR-0003` sin comprometerlo por el volumen histórico (ADR-0004, positivas) | Arriesga la latencia de escritura/consulta reciente, que es la crítica para DRV-05, al optimizar un único almacén para dos perfiles de carga opuestos | Semana 4 — CQRS y proyección de lado de lectura como mecanismo que separa el perfil de rendimiento de la ruta reciente de la ruta histórica |
| Seguridad | Base de Datos por Servicio aísla datos sensibles por contexto; la política de capas se aplica solo a `EventoDeAsistencia` (ASM-04), dejando explícitamente abierto el alcance de documentos/fotos de registro (AMB-04, con `DEC-0011` como placeholder) | Un único almacén homogéneo no confina por sí mismo el radio de exposición de datos sensibles entre contextos si se comparte el mismo tipo de almacén que el resto del sistema (tensión señalada en Alternativa 1 de `architecture-decision.md`: "sin persistencia políglota... es más difícil aplicar una estrategia de almacenamiento por niveles... sin acoplar esa decisión al resto del sistema") | Semanas 6-7 — Base de Datos por Servicio (confinamiento de exposición por contexto) |

**Conclusión del eje**: se eligió la estrategia híbrida por capas porque
optimiza el cumplimiento simultáneo de DRV-04 (retención de 5 años) y DRV-05
(near real-time) sin comprometer el SLA de `ADR-0003`, sacrificando
simplicidad operativa (lógica de tiering automatizada) frente a un único
almacén homogéneo. El alcance de la retención sobre documentos/fotos de
registro (AMB-04) sigue formalmente abierto y no se resuelve en este eje.

### Nota de vigencia (post-DEC-0013)

`ADR-0013` **no reabre esta decisión**: agrega únicamente una nota de
revisión a `ADR-0004` indicando que, en Fase 1, la retención por capas
caliente/tibio/frío se implementa **dentro de un único motor de base de
datos** (particionamiento, tablas de archivo, exportación a almacenamiento
frío del mismo motor), en vez de tres tecnologías de almacenamiento
físicamente distintas. La estrategia de fondo — retención por niveles según
patrón de acceso, para no comprometer el SLA de `ADR-0003` con el volumen
histórico de 5 años (`DRV-04`) — permanece exactamente igual; lo único que
cambia es el **cómo** físico de Fase 1, no el criterio de comparación de
este eje (por capas vs. almacén homogéneo único). **Las cinco celdas de la
tabla de arriba se confirman sin cambios.**

Queda una matización menor, no bloqueante: la celda de Seguridad de este eje
sigue describiendo "Base de Datos por Servicio" como si el aislamiento fuera
físico entre contextos. En Fase 1 (`DEC-0013`), igual que ya reconoce el Eje
1 de esta misma matriz, ese aislamiento es lógico (esquema/namespace dentro
de un almacén compartido), no físico. No cambia la conclusión de este eje
(que compara temporalidad/tiering, no aislamiento físico entre contextos),
pero es una inconsistencia menor de redacción entre ejes — señalada en
"Hallazgos para agentes posteriores" para que `architecture-reviewer` decida
si amerita homogeneizar el lenguaje en una futura pasada.

---

## Eje 4: Síncrono vs. Asíncrono para captura de asistencia

**Opción elegida (M2)**: captura tolerante a desconexión mediante buffer
local + consumidor idempotente, sincronización asíncrona por lotes al
recuperar conectividad (`DEC-0005`/`ADR-0005`), complementada con validación
síncrona protegida por Circuit Breaker de fail-open acotado
(`DEC-0006`/`ADR-0006`) para el camino en vivo. **Alternativa descartada
(M2)**: "Captura estrictamente online (sin buffer local, sin caché de
credencial)" — Alternativa A de `ADR-0005`.

| Criterio | Asíncrono con buffer local (elegida) | Síncrono estricto (descartada) | Cita en knowledge/ |
|---|---|---|---|
| Escalabilidad | Desacopla la captura de la disponibilidad de red/backend en el momento del escaneo; el buffer amortigua picos o caídas | Cada escaneo depende de una llamada en tiempo real sin capacidad de amortiguar picos ni caídas de conectividad | Semana 3 — Cola de mensajes como "buffer temporal que almacena mensajes... hasta que los consumidores están listos"; Semana 4 — mecanismos de contrapresión por buffering |
| Complejidad operativa | Mayor: requiere lógica adicional en el dispositivo (buffer, clave de idempotencia — ADR-0005, negativas) y un componente de caché + cola de reconciliación adicional en Captura (ADR-0006, negativas) | Menor: modelo más simple, sin lógica de sincronización posterior ni resolución de duplicados (ADR-0005, pros de la alternativa A) | Semanas 3-4-7 — Idempotencia / Idempotent Consumer como mecanismo que sostiene la corrección del modelo asíncrono, con el costo de complejidad que introduce |
| Costo (~estimado) | ~estimado mayor en desarrollo: buffer local, clave de idempotencia, cola de reconciliación y dos estructuras de caché distintas en Captura (ADR-0006/ADR-0008) — sin cifra dura disponible | ~estimado menor en desarrollo, pero con un costo no cuantificado de asistencia real perdida ante caída de conectividad, que el modelo síncrono estricto no mitiga | Semana 4 — Procesos de Larga Duración y mecanismos de contrapresión como la base conceptual del costo de ingeniería adicional que el modelo asíncrono acepta |
| Rendimiento | Sostiene DRV-05 (near real-time) incluso ante degradación parcial de red: "la caché local de credenciales evita que la validación de identidad se convierta en un punto de fallo síncrono para la captura, reforzando DRV-05" (ADR-0005, positivas) | Arriesga perder el evento completo ante una caída de conectividad, sin posibilidad de recuperación (ADR-0005, contras de la alternativa A) | Semana 4 — Contrapresión y Procesos de Larga Duración; Semana 7 — Retry con backoff exponencial y jitter |
| Seguridad | Acepta una ventana de exposición ante credencial revocada durante la desconexión, mitigada con TTL (ADR-0005, negativas) y con fail-open acotado solo a identidades ya conocidas (ADR-0006, prioriza DRV-03 sobre DRV-05 para el caso desconocido/revocado) | Validación de credencial siempre confirmada en el momento, sin ventana de exposición — mayor exactitud inmediata, pero a costa de bloquear la captura ante indisponibilidad de red o backend | Semana 7 — Circuit Breaker (máquina de estados) y fail-open acotado como táctica explícita de balance entre disponibilidad y exactitud; Semanas 3-4 — Idempotencia y Dead Letter Queue para la reconciliación posterior de eventos validados en modo degradado |

**Conclusión del eje**: se eligió el modelo asíncrono tolerante a
desconexión porque optimiza DRV-05 (near real-time, incluso bajo
degradación de red) y satisface la expectativa funcional confirmada por
stakeholders simulados (ASM-07: ninguna asistencia real debe perderse),
sacrificando exactitud inmediata de revocación de credencial (ventana de
exposición acotada por TTL) y añadiendo complejidad de sincronización y
reconciliación que el modelo estrictamente síncrono no necesitaría.

### Nota de vigencia (post-DEC-0013)

Se confirma explícitamente, en vez de asumirlo, el impacto de `DEC-0013`
sobre este eje:

- **`DEC-0005` (buffer local + consumidor idempotente en el Dispositivo DAS)
  no cambia.** Es una decisión sobre la frontera **Dispositivo DAS ↔
  backend**, que sigue existiendo como una conexión de red real
  independientemente de si el backend es un monolito o 5 microservicios —
  `ADR-0013` ("Nota de impacto sobre decisiones existentes") lo confirma
  explícitamente: "sin impacto estructural... independientes de si el
  backend es monolito o microservicios. No requieren revisión". Las cinco
  celdas de la tabla de arriba, en la parte que depende de `DEC-0005`, se
  confirman sin cambios.
- **`DEC-0006` (Circuit Breaker Captura↔Identidad, backend-a-backend) sí
  cambia**, y esta misma tabla lo cita explícitamente en la fila de
  Seguridad ("fail-open acotado... ADR-0006, prioriza DRV-03 sobre DRV-05").
  En Fase 1, Captura de Asistencia e Identidad y Credenciales son módulos
  del mismo proceso: no hay frontera de red entre ellos que un Circuit
  Breaker de tipo distribuido deba proteger, por lo que `ADR-0013` deja este
  mecanismo explícitamente **en pausa**. La validación de credencial en el
  camino en vivo se resuelve en Fase 1 con una llamada interna directa (en
  proceso) al módulo de Identidad, sin la máquina de estados
  Cerrado/Abierto/Semi-abierto que `ADR-0006` especifica para una llamada de
  red. Esto **no cambia la conclusión del eje** — el modelo asíncrono con
  buffer local sigue siendo la elección correcta frente al síncrono
  estricto, por las mismas razones ya documentadas — pero matiza la fila de
  Seguridad: la ventana de exposición ante credencial revocada durante la
  desconexión del dispositivo (mitigada con TTL, `ADR-0005`) sigue vigente
  sin cambios; el mecanismo específico de fail-open acotado de `ADR-0006`
  para el caso "backend de Identidad caído/lento" vuelve a ser necesario tal
  cual solo a partir de Fase 2, cuando Captura de Asistencia se extraiga y
  la llamada vuelva a cruzar una frontera de red real.

---

## Trazabilidad (TO-NN → DEC-NNNN)

Cada fila de las cuatro tablas de arriba queda registrada en
`design/traceability.md` bajo un `TO-NN`, enlazado al `DEC-NNNN` (y su ADR)
que la origina en Milestone 2. Tras esta pasada, `TO-01` a `TO-10`, `TO-11`
a `TO-15`, `TO-17` y `TO-20` agregan `DEC-0013` a su columna "DEC
relacionada" (sin quitar los `DEC` ya listados), reflejando que `DEC-0013`
condiciona la vigencia o la fase de aplicación de esos criterios. `TO-16`,
`TO-18` y `TO-19` (Eje 4, criterios que dependen únicamente de `DEC-0005`)
**no** agregan `DEC-0013`, porque `ADR-0013` confirma explícitamente que
`DEC-0005` no tiene impacto estructural. Ver la sección "Trade-offs
(Milestone 3)" agregada al final de `design/traceability.md`.

## Hallazgos para agentes posteriores

- **RST-01 / RISK-01 (Eje 1) — RESUELTO en esta pasada.** El hallazgo
  original de esta matriz ("falta un punto intermedio de complejidad entre
  Monolito y Microservicios") queda resuelto por `DEC-0013`/`ADR-0013`
  (Monolito Modular Fase 1 + extracción selectiva Fase 2 vía Strangler
  Pattern). Ya no se lista como hallazgo abierto.
- **Eje 2 (REST vs. Event-driven) sin ADR de estilo dedicado — sigue sin
  resolverse, ahora con alcance temporal explícito.** Milestone 2 no dejó
  una comparación binaria única a nivel de estilo de comunicación global; la
  evidencia usada aquí es real (`ADR-0006`, `ADR-0007`, `ADR-0008`) pero está
  distribuida por interacción, no consolidada. `architecture-reviewer` ya
  confirmó en el gate de Milestone 3 (Iteración 1, Hallazgo 2) que se acepta
  como está. Esta pasada agrega, con el contexto de `DEC-0013`, la precisión
  de que la decisión aplica a la topología de destino (Fase 2), no al día 1.
- **AMB-04 (alcance de retención sobre documentos/fotos de registro)** sigue
  formalmente abierta y condiciona parcialmente el Eje 3 (seguridad); no se
  resuelve en este documento.
- **Inconsistencia menor de redacción entre Eje 1 y Eje 3 (Seguridad) —
  para que `architecture-reviewer` decida si amerita homogeneizar.** El Eje
  1 ya reconoce que, en Fase 1, "Base de Datos por Servicio" es un
  aislamiento lógico (esquema/namespace), no físico. La celda de Seguridad
  del Eje 3 todavía describe "Base de Datos por Servicio" en términos
  físicos, sin la misma matización. No cambia la conclusión de ningún eje
  (Eje 3 compara tiering temporal, no aislamiento físico entre contextos),
  pero es una inconsistencia de lenguaje entre secciones de este mismo
  documento que conviene homogeneizar en una futura pasada.
- **Eje 4 — `DEC-0006` en pausa en Fase 1.** Documentado explícitamente en
  la "Nota de vigencia" del Eje 4: el Circuit Breaker Captura↔Identidad
  (backend-a-backend) que este eje cita en su fila de Seguridad no tiene
  frontera de red que proteger mientras ambos módulos vivan en el mismo
  proceso. No es una inconsistencia nueva — es consistente con lo que
  `ADR-0013` ya declara — pero se deja constancia explícita para que quede
  trazable en esta matriz, no solo en el ADR.
- Ninguna cifra de costo presentada en esta matriz es un dato validado: toda
  celda de "Costo" está marcada `~estimado` y se basa en razonamiento
  cualitativo sobre componentes de infraestructura citados en `knowledge/`,
  no en benchmarks ni cotizaciones reales.
