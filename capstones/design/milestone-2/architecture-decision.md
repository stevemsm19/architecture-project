# Milestone 2 — Alternativas de Estilo Arquitectónico y Decisión

> Este documento presenta las alternativas de estilo evaluadas para el DAS de
> UPCA y remite a `design/adr/adr-0001-*.md` para el registro formal de la
> decisión, a `design/milestone-2/bounded-contexts.md` y
> `design/milestone-2/data-model-conceptual.md` para el desarrollo completo de
> la alternativa recomendada. No incluye diagramas (responsabilidad de
> `architecture-modeler`) ni la matriz formal de trade-offs (Milestone 3,
> `architecture-tradeoff`).
>
> Cada patrón citado se ancla en `knowledge/index.md` (y, donde aporta
> profundidad puntual, en `knowledge/we4.md` o `knowledge/we7.md`). Cada
> driver/requisito citado proviene de `design/traceability.md`.

## Nota de Iteración 2 (post-revisión `architecture-reviewer`)

`design/milestone-2/review-log.md` (Iteración 1) reportó varios hallazgos
sobre decisiones subespecificadas dentro de la Alternativa 2 (recomendada).
Se resolvieron con ADRs nuevos (`ADR-0006` a `ADR-0012`), sin cambiar la
elección de estilo ni las alternativas comparadas más abajo:

- Circuit Breaker no especificado para Captura → Identidad (backend) →
  `design/adr/adr-0006-circuit-breaker-captura-identidad.md`.
- Modelo de entrega del NIS no declarado, idempotencia de resultados
  entrantes y tope de reintentos → `design/adr/adr-0007-integracion-nis-polling-idempotencia-reintentos.md`.
- Ambigüedad de refresco de caché del Dispositivo DAS →
  `design/adr/adr-0008-refresco-cache-dispositivo-via-captura.md`.
- Revocación de credencial no modelada →
  `design/adr/adr-0009-revocacion-credencial.md`.
- Clave de idempotencia de asistencia sin campo dirección, origen del
  timestamp del SLA →
  `design/adr/adr-0010-idempotencia-clave-asistencia.md`.
- AMB-04 sin política de retención por defecto →
  `design/adr/adr-0011-retencion-default-documentos-registro.md`.
- `POST /registrations` sin idempotencia →
  `design/adr/adr-0012-idempotencia-post-registrations.md`.

**Hallazgo deferido, no resuelto en esta iteración**: el hallazgo
"Complejidad plena de MSA+EDA para equipo de una persona" (RST-01,
`review-log.md`) fue dirigido explícitamente por `architecture-reviewer` a
`architecture-risk` (Milestone 3), no a este milestone. Se deja constancia
aquí de que sigue abierto y pendiente de evaluación en Milestone 3 — no se
exploró en esta iteración ningún punto intermedio de complejidad (ej. menos
servicios en una primera fase) porque no corresponde a este agente
resolverlo. Ver también `design/milestone-2/review-log.md`, sección
"[RST-01 — sobreingeniería operativa...]". **Nota (24-08-2026)**: el título
citado arriba reproduce textualmente el hallazgo tal como quedó redactado en
`review-log.md` en ese momento, bajo la lectura entonces vigente de RST-01
("una sola persona"); esa lectura fue corregida después (ver sección
"Revisión — Milestone 3" más abajo, y su nota de cierre al final). Se
conserva la cita literal aquí como registro histórico de lo que motivó la
reapertura, no como descripción vigente de la restricción real.

## Alternativa 1: Monolito Modular con procesamiento asíncrono interno

**Nivel de inversión**: Menor

**Descripción**: Una única aplicación desplegable, organizada internamente en
módulos con límites explícitos que corresponden uno a uno con los mismos
bounded contexts del dominio (Identidad, Registro/Verificación, Captura de
Asistencia, Reportes, Notificaciones), comunicándose entre sí mediante
interfaces bien definidas dentro del mismo proceso. La integración
asíncrona con el NIS y el procesamiento de eventos de asistencia se resuelven
con una cola de trabajos interna (job queue) y workers, sin desplegar
servicios independientes ni un broker de eventos distribuido entre procesos.

**Drivers que optimiza**:
- **DRV-02** (Integración asíncrona con NIS): un job queue interno con
  workers ya resuelve el problema de "no bloquear" mientras se espera al NIS
  hasta 2 horas — no requiere la complejidad de un broker distribuido.
- **DRV-03** (Seguridad y confidencialidad): un único límite de despliegue y
  un único almacén de datos simplifican el perímetro de seguridad y el
  control de acceso — hay una sola superficie que asegurar, en vez de N
  servicios con sus propios canales de red internos.
- Operacionalmente compatible con **RST-01** (equipo de desarrollo pequeño,
  del orden de 3 a 5 personas, sin equipos de plataforma/DevOps/SRE
  dedicados por servicio): un solo pipeline de CI/CD, un solo entorno de
  despliegue, sin necesidad de infraestructura de orquestación de
  contenedores ni service discovery.

**Drivers que sacrifica**:
- **DRV-01** (Escalabilidad a ~15.000 usuarios / 20 campus): al compartir el
  mismo runtime y (típicamente) el mismo almacén de datos, la captura de
  asistencia (alto volumen de escritura, ver REQ-06 en `priorizacion.md`,
  "riesgo alto: mayor punto de volumen de escritura del sistema") y las
  consultas del portal de reportes (lectura agregada, REQ-07) compiten por
  los mismos recursos — el propio `priorizacion.md` señala este riesgo
  explícitamente para REQ-07 ("riesgo de que las consultas analíticas
  compitan por recursos con la captura de asistencia en tiempo real si no se
  diferencian los patrones de acceso"). Escalar solo el módulo de captura sin
  escalar todo el monolito no es posible.
- **DRV-04** (Retención de 5 años): sin persistencia políglota por contexto,
  es más difícil aplicar una estrategia de almacenamiento por niveles
  (caliente/frío) distinta para eventos de asistencia recientes vs.
  históricos (ver ASM-13) sin acoplar esa decisión al resto del sistema.
- **DRV-05** (Near real-time): el acoplamiento de despliegue entre Registro
  (sujeto a cambios frecuentes por la integración con el NIS, un tercero
  fuera de control — ASM-01) y Captura de Asistencia (que debe mantenerse
  estable y de baja latencia) implica que un cambio o un incidente en la
  lógica de Registro puede requerir redesplegar (y potencialmente degradar)
  todo el sistema, incluida la ruta crítica de captura casi en tiempo real.

**Fundamento en knowledge/**:
- Soluciones Modulares / Arquitectura Modular (Semana 1: Independent Units,
  Self-Contained Functionality, Well-Defined Interfaces) → los módulos
  internos del monolito se diseñan siguiendo estos tres principios, aun sin
  despliegue independiente.
- Separación de Responsabilidades / SoC (Semana 6) → "se manifiesta de forma
  distinta en Arquitectura en Capas, Limpia/Hexagonal, Microservicios y SOA";
  el monolito modular aplica SoC vía arquitectura hexagonal/en capas dentro
  de un mismo proceso.
- Procesadores de trabajos / Job Processors (Semana 4) → "cola como buffer +
  autoescalado de workers" es el mecanismo concreto usado para no bloquear la
  API ante la latencia del NIS (hasta 2h) sin necesitar un broker de eventos
  distribuido entre servicios.
- Mensajería / colas (Semana 3) → Message Queue (modelo pull, un consumidor
  por mensaje) es suficiente para las notificaciones internas del monolito,
  sin necesitar el modelo pub/sub multi-consumidor de un Event Broker
  distribuido.

## Alternativa 2 (recomendada): Microservicios por Bounded Context con Arquitectura Dirigida por Eventos (MSA + EDA)

**Nivel de inversión**: Mayor

**Descripción**: El sistema se descompone en servicios desplegables de forma
independiente, cada uno propietario de un bounded context del dominio
(Identidad y Credenciales, Registro y Verificación, Captura de Asistencia,
Reportes y Analítica, Notificaciones), comunicados mediante eventos
asíncronos a través de un broker, con un API Gateway + patrones
Backend-for-Frontend para los dos clientes (app móvil, portal web). El flujo
de registro/verificación con el NIS se modela como un proceso de larga
duración orquestado (Saga con motor de flujo de trabajo); la separación
lectura/escritura para reportes se resuelve con CQRS.

Ver desarrollo completo en `design/milestone-2/bounded-contexts.md` y
`design/milestone-2/data-model-conceptual.md`.

**Drivers que optimiza**:
- **DRV-01** (Escalabilidad): cada bounded context escala de forma
  independiente — Captura de Asistencia (escritura de alto volumen en 20
  campus) puede escalar horizontalmente sin arrastrar a Reportes (lectura
  agregada) ni a Registro (bajo volumen, alta latencia por el NIS).
- **DRV-02** (Integración asíncrona con NIS): el contexto Registro y
  Verificación aísla la dependencia externa detrás de una Capa
  Anti-Corrupción (ACL) y modela el flujo completo como Saga orquestada con
  estados explícitos, reintentos con backoff y timeout — exactamente el tipo
  de problema para el que el curso define los Procesos de Larga Duración.
  **Desde Iteración 2, el contrato de esa integración (modelo de entrega,
  idempotencia de resultados, tope de reintentos) está completamente
  especificado en ADR-0007.**
- **DRV-03** (Seguridad y confidencialidad): Base de Datos por Servicio
  aísla los datos sensibles de Registro/Identidad de los datos operativos de
  Captura de Asistencia y Reportes, reduciendo la superficie de exposición
  de cada tipo de dato sensible a su propio contexto. **Desde Iteración 2,
  también incluye Circuit Breaker con fail-open acotado (ADR-0006), un
  mecanismo explícito de revocación de credencial (ADR-0009) y un canal
  único y confinado para el Dispositivo DAS (ADR-0008).**
- **DRV-04** (Retención de 5 años): persistencia políglota permite aplicar
  una estrategia de almacenamiento por niveles (caliente/tibio/frío)
  exclusivamente en el contexto Captura de Asistencia, sin condicionar el
  resto del sistema.
- **DRV-05** (Near real-time): CQRS separa la ruta de escritura (captura) de
  la ruta de lectura (reportes/portal/app), permitiendo que la proyección de
  lectura se actualice de forma asíncrona y rápida (ASM-06, ASM-12) sin que
  las consultas agregadas compitan con la escritura de eventos de
  asistencia. **Ver anexo de Iteración 2 más abajo para la estimación de
  carga pico que respalda la factibilidad del SLA de ≤15s p95.**

**Drivers que sacrifica**:
- Introduce **complejidad operacional** significativamente mayor
  (orquestación de servicios, observabilidad distribuida, gestión de
  consistencia eventual) — un costo que el propio material del curso señala
  explícitamente como el trade-off central de MSA ("agilidad organizacional
  vs. complejidad operacional", Semana 7) y que choca en parte con **RST-01**
  (equipo de desarrollo pequeño, del orden de 3 a 5 personas, sin equipos de
  plataforma/DevOps/SRE dedicados por servicio): el mismo equipo pequeño que
  construye la funcionalidad de producto debe además operar múltiples
  servicios, un broker de eventos y una base de datos por servicio, sin
  personal dedicado a esa operación. **Este trade-off se agrava levemente en
  Iteración 2**: los nuevos mecanismos de resiliencia (circuit breaker con
  caché propia, cola de reconciliación, polling con estado, revocación
  propagada a tres cachés) suman componentes operables adicionales —
  exactamente la clase de detalle que `architecture-risk` (Milestone 3) debe
  evaluar contra RST-01, según lo señalado en la nota de arriba.
- **DRV-03** en su dimensión operativa: más servicios y canales de red
  internos implican más superficie a asegurar (aunque el aislamiento de
  datos por contexto mejora el confinamiento del daño ante una brecha,
  hay más puntos de entrada que proteger que en el monolito).

**Fundamento en knowledge/**:
- Bounded Context / DDD (Semanas 6-7) → criterio principal de descomposición
  en servicios; heurísticas de límites de servicio (dominio núcleo/soporte/
  genérico, velocidad de cambio, estructura de equipo, límites
  transaccionales) aplicadas explícitamente en `bounded-contexts.md`.
- Patrón Saga — orquestación (Semana 4, ampliado en Semana 7) → modela el
  flujo de Registro/Verificación NIS como Proceso de Larga Duración con
  motor de flujo de trabajo, en vez de una llamada síncrona.
- Capa Anti-Corrupción / ACL (Semanas 6-7, Context Mapping) → aísla el
  contexto Registro y Verificación del contrato externo e impredecible del
  NIS.
- CQRS (Semanas 3-4-6, desarrollado como mecanismo de contrapresión en
  Semana 4) → separa comandos (escritura de eventos de asistencia) de
  consultas (reportes/portal/app), resolviendo la tensión explícita entre
  DRV-05 y DRV-04/DRV-07 señalada en `priorizacion.md` para REQ-07.
  Referencia: "un aumento repentino en el tráfico de lecturas... no impacta
  la capacidad del sistema de procesar escrituras, y viceversa" (`we4.md`).
- Base de Datos por Servicio + Persistencia Políglota (Semanas 5-6-7) →
  habilita la estrategia de retención por niveles y el aislamiento de datos
  sensibles por contexto.
- API Gateway + Backend-for-Frontend (Semana 7) → dos consumidores con
  necesidades muy distintas (portal admin web vs. app móvil de usuario)
  justifican BFFs dedicados detrás de un gateway común.
- Circuit Breaker + Retry con backoff exponencial y jitter (Semana 7) →
  tácticas de resiliencia para la comunicación entre Captura de Asistencia y
  Registro/Identidad, y para las llamadas salientes al NIS. **Desde
  Iteración 2, especificadas en detalle en ADR-0006 (Captura↔Identidad) y
  ADR-0007 (NIS).**
- Idempotent Consumer / idempotencia (Semanas 3-4-7) → necesaria tanto para
  los reintentos de verificación NIS (DRV-02) como para el reenvío de
  eventos de asistencia capturados offline (ASM-07). **Desde Iteración 2,
  extendida a resultados entrantes del NIS (ADR-0007), a la clave de
  idempotencia de asistencia (ADR-0010) y al envío inicial de autorregistro
  (ADR-0012).**
- Webhook (Semana 2, "evita el sondeo constante") → usado en ADR-0007 para
  fundamentar que, a falta de confirmación de que el NIS soporte esa
  capacidad, el mecanismo base por defecto asumido es polling, no push.

## Decisión

Se recomienda la **Alternativa 2 (MSA + EDA por bounded context)**. El
razonamiento completo, con las alternativas descartadas y su "por qué no", se
registra formalmente en `design/adr/adr-0001-estilo-arquitectonico-msa-eda.md`
(skill `architecture-decision-records`). Decisiones de diseño consecuentes
(sincronía/asincronía del NIS, ownership de datos, retención por capas,
tolerancia a desconexión de dispositivos) se registran en ADRs separados
(`adr-0002` a `adr-0005`), listados también en `design/traceability.md` bajo
sus `DEC-NNNN` correspondientes. Los ADRs `0006` a `0012` (Iteración 2)
resuelven detalles de especificación subsecuentes sin alterar esta decisión
de estilo ni las alternativas comparadas arriba.

## Anexo — Estimación de carga pico que respalda el SLA de ≤15s p95 (Iteración 2)

`architecture-reviewer` (Iteración 1) señaló que ADR-0003 fija el SLA de
proyección (≤15s p95) sin un cálculo que respalde su factibilidad bajo el
escenario de carga más exigente. Se documenta aquí una estimación
aproximada, explícitamente declarada como cifra de diseño (no dato
operacional validado):

- **Usuarios objetivo (DRV-01)**: ~15.000.
- **Escaneos por usuario/día (cifra conservadora de diseño)**: hasta 6 (3
  clases/día, según `capstone.pdf`, × 2 escaneos por transición
  entrada/salida) — un límite superior deliberadamente pesimista frente al
  modelo de datos real (`EventoDeAsistencia` captura entrada/salida de
  campus, no por clase — ver AMB-07 en `data-model-conceptual.md`).
- **Volumen total estimado**: 15.000 × 6 = 90.000 escaneos/día en toda la
  red de 20 campus.
- **Concentración en ventanas pico**: se asume que ~70% del volumen diario
  se concentra en ~60 minutos/día (ventanas de 10 minutos alrededor de cada
  inicio/fin de clase, 6 transiciones/día) → 63.000 escaneos en 60 minutos
  ≈ 1.050 eventos/min ≈ **~17-18 eventos/seg promedio durante ventanas
  pico**, agregados en toda la red (peor caso conservador: asume
  sincronización total entre los 20 campus, sin diferencia horaria/de
  horario de clases entre ciudades).
- **Ráfaga instantánea**: con un factor de ráfaga de 3x sobre el promedio de
  ventana (sub-intervalos cortos donde una clase completa termina a la vez),
  el pico instantáneo estimado es de **~50-55 eventos/seg**.
- **Conclusión**: un proyector CQRS de propósito general (procesamiento de
  flujos, `we3.md`/`we4.md`) sostiene típicamente throughputs de cientos a
  miles de eventos/seg por instancia; el pico estimado (~50-55 eventos/seg)
  queda cómodamente dentro de ese margen para una sola instancia, y ADR-0003
  ya declara como consecuencia aceptada que "el proyector debe escalar
  horizontalmente para ponerse al día" ante contrapresión — este cálculo
  confirma que esa capacidad de autoescalado es un margen de seguridad
  adicional, no una condición estrictamente necesaria para el volumen
  proyectado a 15.000 usuarios.
- **Declarado explícitamente como estimación, no como validación
  operacional**: si el patrón real de asistencia resulta más sincronizado
  de lo asumido (ej. todos los campus de una misma ciudad con el mismo
  horario exacto de clases), el pico real podría superar esta estimación —
  `architecture-risk` (Milestone 3) debería revisar este cálculo si
  aparece evidencia operacional real que lo contradiga.

## Revisión — Milestone 3

`architecture-reviewer` (gate de Milestone 3, Iteración 1) constató que
**RISK-01** (`design/milestone-3/risk-register.md`) — la complejidad
operativa plena de la Alternativa 2 (5 microservicios independientes, un
broker de eventos, un motor de Saga, persistencia políglota en 5+ almacenes
y los mecanismos de resiliencia de Iteración 2) frente a **RST-01** (en su
redacción vigente a esa fecha, "el proyecto es individual") — es el único
riesgo del registro con Probabilidad Alta + Impacto Alta simultáneos, sin
resolverse en tres checkpoints consecutivos, y que ninguna alternativa
comparada en este documento evaluó nunca un punto intermedio de complejidad.
El gate autorizó una reapertura **parcial y acotada** de este milestone,
restringida exclusivamente a esta sección y a un ADR nuevo.

**`design/adr/adr-0013-monolito-modular-fase1-extraccion-selectiva.md`
reemplaza el alcance de "día 1" de esta decisión** (no la elección de
bounded contexts, que sigue vigente como límite lógico): en vez de desplegar
los 5 microservicios de la Alternativa 2 de forma independiente desde el
inicio, la arquitectura se implementa en dos fases:

- **Fase 1 (día 1)**: **Monolito Modular por Bounded Context** — un único
  desplegable, un único pipeline de CI/CD, un único almacén de datos
  primario, con los mismos 5 bounded contexts como módulos internos con
  límites explícitos (aislados a nivel de esquema/namespace lógico, no
  físico). Los principios de diseño ya decididos en `DEC-0002` a `DEC-0012`
  (Saga como PLD observable/recuperable/idempotente, CQRS, retención por
  capas, tolerancia a desconexión, etc.) se mantienen como principios
  internos, sin requerir su infraestructura distribuida completa desde el
  primer día.
- **Fase 2 (extracción selectiva, por triggers verificables)**: se extrae a
  servicio independiente, vía Strangler Pattern, únicamente el módulo cuyo
  perfil de carga lo justifique con evidencia — **Captura de Asistencia**
  es el único candidato con trigger ya definido (campus activos > 10,
  degradación de latencia medida en dos ventanas pico consecutivas, o
  madurez de pipeline probada); **Registro y Verificación** es candidato
  condicional (solo si la volatilidad del NIS desestabiliza la cadencia de
  release); el resto de los módulos permanece en el monolito
  indefinidamente salvo evidencia en contrario.

Esta revisión queda registrada como **`DEC-0013`** en
`design/traceability.md`. ADR-0013 deja explícitamente anotado (sección
"Nota de impacto sobre decisiones existentes") qué otros artefactos de
Milestone 2 y 3 quedan desactualizados por este cambio y requieren una
próxima pasada de los agentes correspondientes — **no editados aún**:
`bounded-contexts.md` y `data-model-conceptual.md` (nota de revisión sobre
mapeo físico, el criterio lógico no cambia), varios ADRs existentes
(`0002`, `0006`, `0007`, `0008`, `0009`, `0003`, `0004` — algunos quedan "en
pausa" hasta Fase 2), `design/milestone-3/tradeoff-matrix.md` (Ejes 1, 2 y
parcialmente 4, que comparan la Alternativa 2 completa sin la fase 1 de
extracción selectiva) y `design/diagrams/` (los diagramas C4 existentes
asumen los 5 servicios desplegados independientemente desde el día 1).

### Nota de corrección (24-08-2026) — RST-01 ya no es "una sola persona"

`design/milestone-1/discovery.md` corrigió `RST-01`: ya no es "el proyecto es
individual" leído como una sola persona operando el DAS de forma permanente,
sino la restricción real de que el sistema debe ser operable por un **equipo
de desarrollo pequeño (3 a 5 desarrolladores)**, sin equipos de
plataforma/DevOps/SRE dedicados por servicio. Esa lectura errónea venía
usándose en cascada por `DEC-0013`/`ADR-0013` y por `RISK-01` desde que se
citó por primera vez en este documento (párrafo anterior, y las secciones
"Alternativa 1" y "Alternativa 2" arriba, ya corregidas en esta misma
pasada).

`architecture-strategist` reevaluó, con criterio propio y sin asumir el
mismo resultado por inercia, si `DEC-0013`/`ADR-0013` (Monolito Modular Fase
1 + extracción selectiva Fase 2) seguía siendo la decisión más defendible
bajo la restricción corregida, y concluyó que **sí se mantiene, sin cambios
de fondo**. La razón: la condición que hace desproporcionado operar 5
microservicios+broker+motor de Saga+persistencia políglota desde el día 1 no
es el número exacto de desarrolladores (1 vs. 3-5), sino la ausencia de
equipos de plataforma/DevOps/SRE dedicados — precondición organizacional de
adopción de MSA señalada por `knowledge/we5.md` ("empezar pequeño", "invertir
en infraestructura") que un equipo de 3 a 5 desarrolladores generalistas
tampoco cumple, aun cuando sí podría, a diferencia de una sola persona,
paralelizar el *diseño* del código de 5 servicios. Lo que cambia es
exclusivamente la severidad del argumento: de "imposible para un individuo"
a "carga operativa desproporcionada para un equipo chico sin esa
infraestructura organizacional, frente a un volumen real (~50-55 eventos/seg
pico, ver Anexo arriba) que no exige distribución física desde el día 1". Ver
`design/adr/adr-0013-monolito-modular-fase1-extraccion-selectiva.md`, sección
"Nota de reevaluación", para el análisis completo.

**Pendiente, fuera de este alcance** (nota para `architecture-risk`):
`design/milestone-3/risk-register.md` (`RISK-01`, título y cuerpo) y la fila
resumen `RISK-01` en `design/traceability.md` (sección "Riesgos (Milestone
3)") todavía citan textualmente "un equipo de una persona"/"una sola
persona" — requieren el mismo ajuste textual (restricción real: equipo de 3
a 5 desarrolladores, sin equipos de plataforma/DevOps/SRE dedicados), sin que
esto implique un cambio de tratamiento del riesgo (sigue "Resuelto" por
`DEC-0013`).
