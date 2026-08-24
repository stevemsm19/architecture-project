# ADR-0013: Adoptar Monolito Modular por Bounded Context como Fase 1, con Extracción Selectiva vía Strangler Pattern — Reemplaza el Alcance de "Día 1" de ADR-0001

## Estado
Aceptado

## Contexto

Esta decisión revisa, de forma **parcial** y **acotada**, la Alternativa 2
(MSA + microservicios independientes + EDA desde el día 1) fijada en
`ADR-0001`/`DEC-0001`, en respuesta a un gate explícito de
`architecture-reviewer` en Milestone 3
(`design/milestone-3/review-log.md`, Iteración 1, "[Decisión de gate] RISK-01
(RST-01) — SÍ amerita reapertura parcial de Milestone 2").

### Nota de reevaluación (corrección RST-01, 24-08-2026)

`design/milestone-1/discovery.md` corrigió **RST-01**: ya no dice "el
proyecto es individual" leído como "una sola persona opera el sistema DAS de
forma permanente", sino que fija como restricción real que el DAS debe ser
operable por un **equipo de desarrollo pequeño (del orden de 3 a 5
desarrolladores)**, sin equipos de plataforma/DevOps/SRE dedicados por
servicio ni estructura organizacional de gran escala. La entrega académica
individual del capstone queda documentada aparte, explícitamente sin
implicancia arquitectónica sobre el sistema DAS.

Esta corrección obliga a reevaluar con criterio propio, no a asumir por
inercia, si la conclusión de este ADR (Monolito Modular en Fase 1) sigue
siendo la más defendible, o si un equipo de 3 a 5 personas podría razonablemente
operar la arquitectura distribuida completa (5 microservicios + broker +
motor de Saga + persistencia políglota) desde el día 1. El análisis:

- **Lo que cambia**: un equipo de 3 a 5 personas puede paralelizar trabajo,
  revisar código entre pares, y repartir la carga cognitiva de *diseño* de un
  modo que una sola persona no puede. La afirmación literal "un solo
  desarrollador no puede diseñar/entender 5 servicios simultáneamente" ya no
  es la base correcta del argumento — un equipo de ese tamaño sí podría, en
  principio, dividirse el diseño de 5 bounded contexts.
- **Lo que no cambia**: la restricción corregida preserva explícitamente la
  ausencia de "equipos de plataforma/DevOps/SRE dedicados por servicio". Esa
  es la condición que `knowledge/we5.md` señala como precondición real de
  adopción de MSA — no es una cuestión de cuántas personas hay disponibles
  para *diseñar* código, sino de si existe la disciplina/infraestructura
  organizacional para *operar de forma sostenida* N servicios desplegables
  de forma independiente, un broker de eventos, un motor de Saga y
  persistencia políglota — cada uno con su propio ciclo de vida operativo
  (despliegue, monitoreo, incidentes, on-call) — simultáneamente a construir
  funcionalidad de producto nueva contra un horizonte de crecimiento de 2
  años. Un equipo de 3 a 5 desarrolladores generalistas — sin nadie cuyo rol
  dedicado sea sostener la plataforma — reparte esa carga operativa entre las
  mismas personas que además deben entregar producto, en vez de tener
  personal separado para ello. La lectura de `we5.md` ("empezar pequeño",
  "invertir en infraestructura" como precondiciones) no depende del número
  exacto de personas sino de si esas precondiciones organizacionales están
  dadas — y no lo están, corregida o no la cifra de 1 a 3-5.
- **Lo que cambia en severidad, no en dirección**: la carga proyectada real
  (~50-55 eventos/seg pico, ver Anexo de `architecture-decision.md`) sigue
  cabiendo cómodamente en una sola instancia bien diseñada — el argumento de
  que MSA+EDA completo desde el día 1 sería sobre-ingeniería frente al
  volumen real no depende del tamaño del equipo, y sigue vigente sin cambios.
  Lo que sí cambia es cómo se describe el costo de operar 5
  servicios+broker+Saga+persistencia políglota sin plataforma dedicada: ya no
  es "literalmente imposible para un individuo", sino "carga operativa
  desproporcionada para un equipo chico sin esa infraestructura
  organizacional, que además debe repartir su tiempo con la construcción de
  funcionalidad de producto para llegar a 15.000 usuarios en 2 años" — un
  argumento más matizado, pero igual de sólido como fundamento de
  right-sizing.

**Conclusión de esta reevaluación**: la decisión de fondo se **mantiene** —
Monolito Modular por Bounded Context en Fase 1, con extracción selectiva vía
Strangler Pattern en Fase 2 activada por triggers verificables. Lo que se
corrige en el resto de este documento es exclusivamente la redacción que
dependía de la cifra "una persona": se reemplaza por la restricción real
(equipo pequeño de 3 a 5 desarrolladores, sin plataforma/DevOps/SRE
dedicada), y se ajusta la severidad del argumento de "imposibilidad
individual" a "carga operativa desproporcionada para un equipo chico sin
infraestructura de plataforma dedicada, frente a un volumen real que no la
exige todavía". No se reabre el resto del ADR ni se reevalúan los triggers de
extracción de Fase 2 (número de campus activos, contención medida, madurez de
pipeline), que ya eran independientes del tamaño exacto del equipo.

**Por qué se reabre**: `design/milestone-3/risk-register.md` (`RISK-01`)
registra Probabilidad **Alta** e Impacto **Alta** simultáneos — el único
riesgo del registro completo (15 riesgos) con esa combinación — para la
complejidad operativa plena de MSA+EDA (5 microservicios, un broker de
eventos, un motor de flujo de trabajo para la Saga orquestada de `ADR-0002`,
API Gateway + 2 BFFs, persistencia políglota en al menos 5 almacenes
distintos, y siete mecanismos de resiliencia adicionales incorporados en
Iteración 2 — `ADR-0006` a `ADR-0009`) operada por, en la lectura original de
esta reapertura, un equipo de una sola persona. Esa lectura se apoyaba en la
redacción original de **[RST-01]** ("El proyecto es individual",
`plan/milestones.pdf`, "Otros — Tamaño del equipo"), posteriormente
corregida: RST-01 fija ahora la restricción real como un **equipo de
desarrollo pequeño (3 a 5 desarrolladores)**, sin equipos de
plataforma/DevOps/SRE dedicados por servicio
(`design/milestone-1/discovery.md`, "Restricciones no negociables", nota de
corrección 24-08-2026). Ver "Nota de reevaluación" arriba: la corrección no
cambia la conclusión de este ADR, pero sí la redacción de su fundamento en el
resto de este documento. El mismo hallazgo quedó sin resolver a través de
tres checkpoints consecutivos (`design/milestone-2/review-log.md` Iteración
1; `architecture-decision.md`, "Nota de Iteración 2"; `risk-register.md`) sin
que ninguno produjera una decisión — un patrón de riesgo pospuesto, no de
riesgo evaluado y aceptado conscientemente.

`design/milestone-3/tradeoff-matrix.md` (Eje 1) confirma independientemente
que la complejidad operativa y el costo de infraestructura son,
cuantitativamente, el costo central que MSA+EDA paga frente al Monolito
Modular — sin que Milestone 2 (Iteración 1) hubiera evaluado nunca un punto
intermedio de complejidad entre los dos extremos comparados
(`architecture-decision.md`, Alternativas 1 y 2 originales).

`knowledge/we5.md` (Semana 5, MSA I) recomienda explícitamente, como
precondición de adopción de MSA, "empezar pequeño" e "invertir en
infraestructura" antes de fragmentar en servicios independientes —
precondiciones organizacionales (disciplina operativa, infraestructura de
plataforma) que un equipo pequeño de 3 a 5 desarrolladores sin roles de
plataforma/DevOps/SRE dedicados no cumple en el día 1 de un proyecto — no
porque el equipo no pueda diseñar el código de 5 servicios (en principio sí
podría, dividiendo el trabajo), sino porque nadie en el equipo tiene como
responsabilidad dedicada sostener la operación de esa plataforma distribuida
mientras el resto construye producto. `knowledge/we6.md` (Semana 6, MSA II)
advierte explícitamente contra el anti-patrón de **Monolito Distribuido**
(acoplamiento fuerte disfrazado de microservicios) — que es precisamente el
riesgo de operar 5 servicios sin la disciplina/infraestructura que MSA
exige, tal como señala `risk-register.md`. El mismo `we6.md` documenta el
**Strangler Pattern** (migración gradual de un monolito a servicios,
extrayendo funcionalidad rebanada por rebanada) como la técnica del curso
para resolver exactamente esta clase de problema — evolucionar hacia
distribución cuando la evidencia lo justifique, no por adelantado.

## Decisión

Se **reemplaza el alcance de "día 1"** de `DEC-0001` por una estrategia de
dos fases, evaluada explícitamente contra la restricción **RST-01** (no
solo contra escalabilidad o seguridad en general, que `ADR-0001` ya cubre):

**Fase 1 (día 1, arquitectura por defecto)**: **Monolito Modular por
Bounded Context**. Un único desplegable, un único pipeline de CI/CD, un
único almacén de datos primario, organizado internamente en cinco módulos
con límites explícitos que corresponden **uno a uno** con los mismos cinco
bounded contexts ya definidos en `design/milestone-2/bounded-contexts.md`
(Identidad y Credenciales, Registro y Verificación, Captura de Asistencia,
Reportes y Analítica, Notificaciones) — **el criterio DDD de separación de
esos bounded contexts no cambia**, solo su mapeo físico de despliegue.
Dentro de esta fase:
- La integración con el NIS (`DRV-02`) se resuelve con una cola de trabajos
  interna (job queue) y workers en proceso — la máquina de estados explícita
  de `ADR-0002`/`ADR-0007` (Proceso de Larga Duración observable,
  recuperable, idempotente) se mantiene como principio, sin requerir un
  motor de flujo de trabajo dedicado como infraestructura separada.
- La separación lectura/escritura de `DEC-0003` (CQRS) se mantiene como
  principio de diseño interno (comandos vs. consultas separados en el
  código y, cuando el motor de base de datos lo permita, en una réplica de
  lectura o vista materializada), sin requerir un proyector alimentado por
  un broker de eventos distribuido.
- La retención por capas de `DEC-0004` se mantiene como política de ciclo de
  vida de datos (particionamiento/tablas de archivo/exportación a
  almacenamiento frío dentro del mismo motor), sin requerir necesariamente
  tres tecnologías de almacenamiento físicamente distintas desde el día 1.
- Los datos de cada módulo se aíslan a nivel de **esquema/namespace lógico**
  dentro del almacén compartido (no tablas compartidas entre módulos), para
  no comprometer la extracción futura — el mismo espíritu de Base de Datos
  por Servicio, realizado a nivel lógico en vez de físico.

**Fase 2 (extracción selectiva, activada por triggers verificables, no por
fecha ni por promesa)**: se extrae a servicio independiente **solo** el
módulo cuyo perfil de carga lo justifique con evidencia, siguiendo el
**Strangler Pattern** (`knowledge/we6.md`): interfaz ya bien definida →
servicio independiente apuntando temporalmente al mismo esquema → migración
a almacén propio → introducción del broker de eventos únicamente para ese
punto de integración → retiro de la llamada en proceso del monolito.

- **Candidato 1, con trigger definido — Captura de Asistencia**: es el único
  módulo cuyo perfil de carga fue identificado desde Milestone 1 como
  estructuralmente distinto al resto (`design/milestone-1/priorizacion.md`,
  riesgo de que REQ-07 "compita por recursos con la captura de asistencia en
  tiempo real"). Se extrae cuando se cumpla **al menos uno** de estos
  triggers verificables:
  1. El número de campus activos en producción supera **10** (mitad del
     objetivo de 20 campus/`DRV-01`) — punto en el que la carga concurrente
     empieza a acercarse al escenario "peor caso conservador" ya modelado en
     el Anexo de `architecture-decision.md` (~50-55 eventos/seg agregados en
     toda la red).
  2. La observabilidad — ya exigida como principio de MSA por `knowledge/we6.md`
     ("You Build It, You Run It" + observabilidad) y ya recomendada en
     `design/milestone-3/mitigation-plan.md` — mide, durante **dos ventanas
     pico consecutivas** (entrada/salida de clase), una degradación medible
     de la latencia de lectura de Reportes atribuible a contención de I/O con
     la escritura de asistencia. Es la señal empírica exacta que reemplaza a
     la estimación anticipada: extraer cuando el dato real lo confirme, no
     antes.
  3. El pipeline de CI/CD y una plantilla de infraestructura como código
     (IaC) reproducible ya están probados con el monolito en producción
     durante al menos un ciclo de release estable — condición operativa
     mínima (`knowledge/we5.md`, "invertir en infraestructura" como
     precondición de MSA) antes de que el equipo pequeño (sin plataforma
     dedicada) asuma un segundo desplegable independiente.
- **Candidato 2, condicional — Registro y Verificación**: **no** se extrae
  por adelantado. Se extrae únicamente si la volatilidad del NIS como
  tercero no controlado (**ASM-01**) demuestra, con evidencia (ej. más de un
  incidente de despliegue atribuible a cambios de este módulo en un período
  operativo definido), desestabilizar la cadencia de release del monolito
  compartido — señal de acoplamiento de despliegue dañino, no una suposición
  anticipada.
- **Identidad y Credenciales, Reportes y Analítica, Notificaciones**:
  permanecen módulos del monolito **indefinidamente**, salvo evidencia en
  contrario — ningún driver de Milestone 1 exige su aislamiento físico
  independiente, a diferencia de Captura de Asistencia.

Esta decisión sacrifica deliberadamente la "textura" completamente
distribuida de `DEC-0001` a cambio de hacer la arquitectura operable por un
equipo pequeño (3 a 5 desarrolladores, sin equipos de plataforma/DevOps/SRE
dedicados) desde el primer día, right-sizing el diseño al tamaño y
estructura real del equipo (**RST-01**) en vez de a un volumen de usuarios
(15.000 en 2 años) que, según el propio Anexo de `architecture-decision.md`,
ya cabe cómodamente en la capacidad de una sola instancia bien diseñada.

## Alternativas consideradas

### Alternativa A: Mantener MSA+EDA completo desde el día 1, con automatización agresiva como mitigación de RST-01
- **Pros**: no reabre ninguna de las especificaciones ya hechas en `ADR-0002`
  a `ADR-0012`; preserva el aislamiento de datos por contexto y la
  escalabilidad de grano fino completas desde el día 1.
- **Contras**: la automatización (CI/CD, IaC, un solo entorno de
  observabilidad) reduce el **esfuerzo operativo repetido** de desplegar y
  monitorear, pero **no reduce la complejidad cognitiva y operativa
  simultánea** que un equipo pequeño sin roles de plataforma dedicados debe
  construir, entender y operar a la vez — repartiendo esa carga entre las
  mismas 3 a 5 personas que también deben construir funcionalidad de
  producto nueva contra el horizonte de crecimiento a 15.000 usuarios—: 5
  servicios, un broker de eventos, un motor de Saga, persistencia políglota
  en 5+ almacenes, y los 7 mecanismos de resiliencia de Iteración 2
  (`ADR-0006` a `ADR-0009`) operando en conjunto desde el primer commit. Es
  exactamente el escenario que `risk-register.md` descarta como solución:
  "**No se resuelve agregando un patrón de resiliencia** — sería tratar un
  síntoma sin atender la causa". Automatizar el despliegue de algo
  intrínsecamente complejo no lo vuelve simple de operar cuando algo falla
  en producción (observabilidad distribuida, depuración de consistencia
  eventual entre 5 almacenes) — sigue exigiendo la disciplina de equipo que
  `knowledge/we5.md` identifica como precondición de MSA, no como algo que
  la automatización por sí sola sustituya.
- **Por qué no se eligió**: es una mitigación de síntoma (fricción
  operativa), no de causa (número de piezas operables independientes que un
  equipo pequeño sin plataforma dedicada debe diseñar, desplegar, entender y
  depurar, en paralelo a construir funcionalidad de producto). No habría
  sido "concreta y verificable" en el sentido exigido por este gate — la
  promesa de "automatizar todo" no tiene un trigger objetivo que demuestre
  que RST-01 quedó resuelto, a diferencia de los triggers de extracción de
  la Alternativa elegida.

### Alternativa B (elegida): Monolito Modular por Bounded Context (Fase 1) con extracción selectiva vía Strangler Pattern (Fase 2)
- Ver "Decisión" arriba.
- **Por qué se eligió**: ataca la causa raíz identificada por
  `risk-register.md` (número de piezas operables independientes desde el
  día 1, frente a un equipo sin roles de plataforma dedicados) en vez de
  mitigar su síntoma; aplica dos conceptos ya presentes en `knowledge/` y ya
  citados por el propio `ADR-0001` (bounded contexts como criterio de
  descomposición, `we6.md`/`we7.md`) sin requerir ningún supuesto fuera del
  curso; y define triggers de extracción verificables (número de campus
  activos, evidencia de contención medida, madurez de pipeline) en vez de
  una fecha o una promesa — cumpliendo el estándar que el propio brief de
  reapertura exige ("concreto y verificable, no una promesa vaga").

## Consecuencias

**Positivas**
- Reduce directamente la Probabilidad de `RISK-01` (de Alta a, razonablemente,
  Media-Baja en Fase 1): el equipo pequeño (3 a 5 desarrolladores, sin
  equipos de plataforma/DevOps/SRE dedicados) diseña, despliega y opera
  **un** desplegable, no cinco, y no necesita infraestructura de soporte de
  MSA (Service Discovery, orquestación de contenedores multi-servicio,
  observabilidad distribuida) hasta que un trigger de Fase 2 lo justifique.
- Preserva íntegramente el trabajo de modelado de dominio ya hecho: los
  bounded contexts de `design/milestone-2/bounded-contexts.md` y su criterio
  de separación DDD siguen siendo válidos como límites **lógicos** del
  sistema, incluso si su mapeo de despliegue físico cambia.
- El Anexo de carga pico de `architecture-decision.md` (~50-55 eventos/seg)
  ya demuestra que el volumen proyectado a 15.000 usuarios (**DRV-01**) no
  exige distribución física desde el día 1 — la Fase 1 no compromete DRV-01,
  solo pospone su realización física hasta que la evidencia real (no la
  estimación) lo requiera.
- Aplica explícitamente "empezar pequeño" (`knowledge/we5.md`) y evita el
  anti-patrón de Monolito Distribuido (`knowledge/we6.md`) que
  `risk-register.md` señala como el riesgo real de operar 5 servicios sin la
  disciplina/infraestructura que MSA exige.

**Negativas / deuda que se acepta**
- **DRV-03** (seguridad/confidencialidad) en su dimensión de aislamiento de
  datos se debilita parcialmente en Fase 1: el aislamiento por
  esquema/namespace lógico dentro de un almacén compartido confina menos el
  radio de exposición que la Base de Datos por Servicio física de `DEC-0001`
  — se acepta este trade-off porque RST-01 es una restricción no negociable
  y DRV-03 no lo es.
- **DRV-04** (retención 5 años) se implementa en Fase 1 con tiering dentro de
  un único motor de base de datos, en vez de tres tecnologías de
  almacenamiento especializadas — funcionalmente equivalente para el
  requisito legal (retención + disponibilidad de consulta, aunque más lenta
  para históricos, ya aceptado por **ASM-13**), pero sin la optimización de
  costo por patrón de acceso que la persistencia políglota completa
  habilitaría.
- La extracción de Fase 2, cuando ocurra, tiene un costo de migración
  real (Strangler Pattern no es gratuito: requiere mantener temporalmente
  ambos caminos — llamada en proceso y llamada al nuevo servicio — durante
  la transición) que `DEC-0001` no tenía que pagar por no empezar
  distribuido. Se acepta porque ese costo se paga **solo si y cuando** el
  trigger lo justifica, en vez de pagarse por adelantado siempre.

**Riesgos que quedan abiertos**
- El trigger 2 de extracción de Captura de Asistencia (degradación medible
  de latencia de Reportes) depende de que la observabilidad mínima
  recomendada por `design/milestone-3/mitigation-plan.md` esté realmente
  implementada desde el inicio de Fase 1 — si no se instrumenta, el trigger
  nunca dispara aunque la contención real ya esté ocurriendo. Este riesgo
  operativo debe evaluarse en una futura iteración de `architecture-risk`
  (Milestone 3) contra este ADR nuevo.
- Esta decisión **no** resuelve por sí sola `RISK-15` (broker de eventos
  como dependencia compartida) — en Fase 1 ese riesgo simplemente no existe
  aún (no hay broker), pero reaparecerá idéntico al activarse la extracción
  de Captura de Asistencia en Fase 2.

## Nota de impacto sobre decisiones existentes (NO editadas en esta pasada)

Esta decisión es **estructural**: cambia la topología de despliegue de la
Fase 1 del sistema (de N servicios independientes a 1 desplegable con N
módulos). Deja explícitamente anotado, para la siguiente pasada, qué
artefactos de Milestone 2/3 requieren revisión — **sin editarlos aquí**,
conforme al alcance acotado de esta reapertura:

- **`design/milestone-2/bounded-contexts.md`**: los bounded contexts y su
  criterio de separación DDD siguen vigentes como límites **lógicos**; lo
  que cambia es el mapeo físico de despliegue ("1 microservicio por BC" →
  "1 módulo por BC dentro de 1 desplegable, con extracción selectiva").
  Requiere una nota de revisión explícita en la próxima pasada, no una
  reescritura del criterio de separación.
- **`design/milestone-2/data-model-conceptual.md`**: el ownership lógico de
  cada entidad por bounded context no cambia; lo que cambia es la
  realización física de "Base de Datos por Servicio" (pasa a ser
  esquema/namespace lógico compartido en Fase 1, base de datos física propia
  solo tras extracción). Requiere nota de revisión, no reescritura del
  modelo de entidades.
- **`ADR-0002`** (Saga orquestada con motor de flujo de trabajo dedicado): en
  Fase 1 se reemplaza el motor de flujo de trabajo por una máquina de
  estados/cola de trabajos interna — el patrón conceptual (Proceso de Larga
  Duración explícito, comprobable, recuperable) se mantiene, cambia el
  mecanismo de implementación. Requiere nota de revisión o ADR de detalle.
- **`ADR-0006`** (Circuit Breaker Captura↔Identidad, backend-a-backend): no
  aplica en Fase 1 (llamada en proceso, sin frontera de red entre esos
  módulos). Queda **en pausa** hasta que se cumpla el trigger de extracción
  de Captura de Asistencia (Fase 2), momento en el que el mecanismo ya
  especificado vuelve a ser exactamente necesario tal cual está.
- **`ADR-0007`** (integración NIS — polling/idempotencia/reintentos): impacto
  bajo — el NIS es externo independientemente de la topología interna; solo
  cambia "quién" ejecuta el polling (un worker del job queue interno, no un
  servicio Registro y Verificación desplegado aparte). Requiere nota
  aclaratoria menor, no reescritura.
- **`ADR-0008`** (refresco de caché del Dispositivo DAS vía proyección +
  eventos): no aplica en Fase 1 (fuente única de verdad, lectura directa sin
  proyección distribuida). Queda **en pausa** hasta Fase 2, junto con la
  extracción de Captura de Asistencia.
- **`ADR-0009`** (revocación de credencial propagada a tres cachés): se
  simplifica drásticamente en Fase 1 (una sola fuente de verdad, sin cachés
  distribuidas que sincronizar); el evento `CredentialRevoked` y la API de
  revocación siguen siendo válidos conceptualmente. Requiere nota de
  revisión.
- **`ADR-0003`** (CQRS con proyector vía broker de eventos, SLA ≤15s p95): el
  SLA se mantiene como meta; en Fase 1 se logra con una estrategia más
  simple (réplica de lectura/vista materializada), no con proyección
  distribuida. Requiere nota de revisión, impacto bajo en la decisión en sí.
- **`ADR-0004`** (retención por capas caliente/tibio/frío, políglota): la
  estrategia de tiering conceptual se mantiene; en Fase 1 se implementa
  dentro de un único motor de base de datos. Requiere nota de revisión.
- **`ADR-0005`, `ADR-0010`, `ADR-0011`, `ADR-0012`**: sin impacto
  estructural — son decisiones a nivel de dispositivo, API o negocio,
  independientes de si el backend es monolito o microservicios. No
  requieren revisión.
- **`design/milestone-3/tradeoff-matrix.md`**: los Ejes 1, 2 y parcialmente
  4 quedan desactualizados frente a esta decisión (comparan MSA+EDA completo
  contra un monolito modular sin extracción selectiva) — requiere que
  `architecture-tradeoff` ajuste su matriz en la próxima pasada.
- **`design/diagrams/`**: cualquier diagrama C4 existente que asuma 5
  servicios desplegados independientemente queda desactualizado —
  `architecture-modeler` necesita redibujar contra esta decisión.

## Referencias
- `knowledge/we5.md`, `knowledge/we6.md`, `knowledge/index.md` — "empezar
  pequeño" como precondición de adopción de MSA; anti-patrón de Monolito
  Distribuido; Strangler Pattern.
- `design/traceability.md` — DRV-01 a DRV-05, REQ-06, REQ-07; RST-01
  (`design/milestone-1/discovery.md`, "Restricciones no negociables", citada
  directamente aquí por no ser una fila de `traceability.md`) — texto
  vigente tras la corrección del 24-08-2026 (equipo de 3 a 5
  desarrolladores, sin equipos de plataforma/DevOps/SRE dedicados); ver
  "Nota de reevaluación" arriba.
- `design/milestone-3/risk-register.md` — RISK-01.
- `design/milestone-3/tradeoff-matrix.md` — Eje 1.
- `design/milestone-3/review-log.md` — Iteración 1, gate de reapertura
  parcial.
- `design/milestone-2/architecture-decision.md` — sección "Revisión —
  Milestone 3" agregada por este ADR.
- `design/adr/adr-0001-estilo-arquitectonico-msa-eda.md` — decisión
  reemplazada en su alcance de día 1.
