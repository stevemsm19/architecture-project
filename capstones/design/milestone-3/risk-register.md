# Registro de Riesgos — Milestone 3

> Evalúa qué puede fallar en la arquitectura ya elegida en Milestone 2 (MSA +
> EDA por bounded context, `design/milestone-2/architecture-decision.md`,
> `design/adr/adr-0001-*.md` a `adr-0012-*.md`) — no compara alternativas ni
> rediseña. Cada riesgo cita el `DEC-NNNN` que afecta (`design/traceability.md`)
> y ancla su mitigación en un patrón concreto de `knowledge/`, con semana y
> concepto. Probabilidad e Impacto usan escala cualitativa (Alta/Media/Baja) —
> no se inventan cifras ni SLAs no presentes en el enunciado o en los ADRs.
>
> **RISK-08** y **RISK-16** no se resuelven con un mecanismo de resiliencia
> adicional: RISK-08 requiere una decisión de negocio (no de estilo) para
> `architecture-strategist`. RISK-16 requiere una **validación externa
> (legal/instructor)** de un placeholder ya declarado como tal en `ADR-0011`
> — no es un déficit de mecanismo de resiliencia ni un cambio de estilo
> arquitectónico, por lo que **no** se marca "requiere revisión de diseño";
> se documenta como hallazgo de gobernanza/cumplimiento pendiente de cierre
> externo, siguiendo la regla de oro de este proyecto de declarar
> explícitamente los supuestos fuera del alcance del curso. **RISK-01**
> tampoco se resuelve con un mecanismo de resiliencia adicional — a
> diferencia de RISK-08 y RISK-16, sí requería una decisión de diseño/estilo,
> se marcó explícitamente "requiere revisión de diseño" para
> `architecture-reviewer`, y **ya fue resuelto**: ver su entrada abajo,
> sección "Nota de resolución (post-DEC-0013)", y la corrección siguiente.
>
> Corrección post-revisión (`architecture-reviewer`,
> `design/milestone-3/review-log.md`, Iteración 1, Hallazgo 3, severidad
> Media, no bloqueante para el gate de M3 pero a cerrar antes de M4): se
> agregan **RISK-16** y **RISK-17** para cubrir explícitamente, bajo la
> categoría obligatoria "Protección de datos personales" de
> `plan/milestones.pdf`, (a) la validación legal pendiente del placeholder
> de retención de `DEC-0011`/`ADR-0011` (AMB-04), y (b) el riesgo operativo
> del mecanismo de tiering de `DEC-0004`/`ADR-0004`, ya señalado como
> complejidad no evaluada por `design/milestone-3/tradeoff-matrix.md` (Eje
> 3, filas "Complejidad operativa" y "Costo") pero nunca convertido en un
> `RISK-NN` propio, a diferencia de otros mecanismos nuevos de M2 Iteración
> 2 (buffer local → RISK-09; broker de eventos → RISK-15). Ninguna entrada
> anterior (RISK-01 a RISK-15) fue modificada en esa pasada.
>
> Corrección post-revisión (`architecture-reviewer`,
> `design/milestone-3/review-log.md`, "Cierre de cascada DEC-0013", Hallazgo
> 1, severidad Alta): este documento y `design/milestone-3/mitigation-plan.md`
> no habían sido tocados por la cascada de propagación de `DEC-0013`
> (Monolito Modular Fase 1 + extracción selectiva Fase 2,
> `design/adr/adr-0013-*.md`), a pesar de que `design/traceability.md` ya
> declaraba **RISK-01** "Resuelto" en dos lugares — una contradicción directa
> entre el documento primario (este registro) y su resumen. Se corrige aquí:
> **RISK-01** pasa de "requiere revisión de diseño" (pendiente) a **resuelto
> por `DEC-0013`**, con su Probabilidad reducida de Alta a Media-Baja en Fase
> 1 (tal como el propio `ADR-0013`, sección "Consecuencias positivas",
> declara). Se agregan además notas de vigencia por fase a **RISK-10** (la
> cola de reconciliación del Circuit Breaker de `ADR-0006` que este riesgo
> cita como parte de su escenario está **en pausa** en Fase 1, sin frontera
> de red Captura↔Identidad) y **RISK-15** (el broker de eventos que este
> riesgo evalúa como SPOF **no existe** en Fase 1, confirmado contra
> `design/diagrams/c4-container.mmd`). Ningún otro `RISK-NN` fue modificado
> en esta pasada.
>
> Corrección puntual (`architecture-risk`, 24-08-2026, en respuesta al
> pendiente dejado por `design/traceability.md`, "Nota de Milestone 1
> (corrección puntual, 24-08-2026...)" y "Nota de Milestone 2 (cierre de la
> reevaluación de RST-01...)"): el título y el cuerpo de **RISK-01** citaban
> la redacción original de **RST-01** ("una sola persona"/"proyecto
> individual", leída como si el sistema DAS fuera a ser diseñado, desplegado
> y operado por una sola persona de forma permanente). `RST-01` fue
> corregido en `design/milestone-1/discovery.md`, "Restricciones no
> negociables": la restricción operativa real es que el sistema DAS debe ser
> operable por un **equipo de desarrollo pequeño (del orden de 3 a 5
> desarrolladores)**, sin equipos de plataforma/DevOps/SRE dedicados por
> servicio — la condición de "individual" en `plan/milestones.pdf` se refiere
> únicamente a la entrega académica del capstone, sin implicancia
> arquitectónica. `architecture-strategist` ya reevaluó, con criterio propio,
> si `DEC-0013`/`ADR-0013` seguía siendo la decisión más defendible bajo la
> restricción corregida, y confirmó que se mantiene sin cambios de fondo: lo
> que hace desproporcionado operar 5 microservicios + broker + motor de Saga
> + persistencia políglota desde el día 1 no es el número exacto de
> desarrolladores (1 vs. 3-5), sino la ausencia de equipos de
> plataforma/DevOps/SRE dedicados — precondición organizacional de adopción
> de MSA señalada por `knowledge/we5.md` ("empezar pequeño", "invertir en
> infraestructura") que un equipo de 3 a 5 desarrolladores generalistas
> tampoco cumple, aunque sí podría, a diferencia de una sola persona,
> paralelizar el *diseño* del código de 5 servicios (`design/adr/adr-0013-*.md`,
> "Nota de reevaluación"; `design/milestone-2/architecture-decision.md`,
> "Nota de corrección"). Se corrige aquí, exclusivamente, el texto de la
> entrada `[RISK-01]` que citaba la cifra incorrecta — **Probabilidad,
> Impacto y tratamiento ("Resuelto" por `DEC-0013`) no cambian**, solo su
> fundamento textual.

---

## [RISK-01] Complejidad operativa plena de MSA+EDA para un equipo de desarrollo pequeño sin plataforma dedicada (RST-01)

**Escenario**: el diseño de Milestone 2 apuesta el 100% de la complejidad
operativa de MSA+EDA — 5 microservicios (Identidad y Credenciales, Registro y
Verificación, Captura de Asistencia, Reportes y Analítica, Notificaciones), un
broker de eventos, un motor de flujo de trabajo para la Saga orquestada
(ADR-0002), un API Gateway + 2 BFFs, y persistencia políglota (al menos 5
almacenes distintos, incluyendo 3 niveles de retención por capas en Captura de
Asistencia, ADR-0004) — para que las opere un **equipo de desarrollo pequeño
(del orden de 3 a 5 desarrolladores), sin equipos de plataforma/DevOps/SRE
dedicados por servicio** (RST-01, `discovery.md`, "Restricciones no
negociables", corregido 24-08-2026 — ver nota de corrección arriba). A esto se
suman, desde Iteración 2 de Milestone 2, siete mecanismos de resiliencia
adicionales (Circuit Breaker con caché propia y cola de reconciliación —
ADR-0006; polling con estado y máquina de reintentos — ADR-0007; proyección
local de credenciales del dispositivo — ADR-0008; propagación de revocación a
tres cachés — ADR-0009), cada uno un componente operable más. `architecture-
decision.md` (Nota de Iteración 2) y `review-log.md` documentan honestamente
que esto "agrava levemente" el trade-off, sin resolverlo. `architecture-
strategist` solo comparó dos extremos (monolito modular completo vs. MSA+EDA
completo, `architecture-decision.md`, Alternativas 1 y 2) — **no exploró
ningún punto intermedio de complejidad** (ej. menos servicios en una primera
fase, Notificaciones fusionado con Registro y Verificación por bajo costo de
desacople, Saga con estado persistido en el propio servicio en vez de un
motor de workflow dedicado).

**Probabilidad**: Alta (evaluación original, Milestone 2 / previa a
`DEC-0013`) — **Impacto**: Alta (evaluación original). Ver "Nota de
resolución (post-DEC-0013)" abajo para el estado actual.

**Componente/decisión afectada**: DEC-0001 (y transitivamente DEC-0002 a
DEC-0012), y **DEC-0013** (decisión que lo resuelve)

**Mitigación**: **No se resuelve agregando un patrón de resiliencia** — sería
tratar un síntoma sin atender la causa. `knowledge/we5.md` (Semana 5, MSA I)
recomienda explícitamente, como parte de la adopción de MSA, "empezar
pequeño" y "empoderar equipos autónomos" — precondiciones organizacionales
(disciplina operativa, infraestructura de plataforma) que un equipo de 3 a 5
desarrolladores sin roles de plataforma/DevOps/SRE dedicados no cumple por
definición, no porque el equipo no pueda diseñar el código de 5 servicios en
principio, sino porque nadie en el equipo tiene como responsabilidad dedicada
sostener la operación de esa plataforma distribuida mientras el resto
construye producto. `knowledge/we6.md` (Semana 6) advierte contra el
anti-patrón de "monolito distribuido" (acoplamiento fuerte disfrazado de
microservicios), que es precisamente el riesgo de intentar operar 5 servicios
sin la disciplina/infraestructura que MSA exige. La Alternativa 1 ya
descartada en `architecture-decision.md` (Monolito Modular, fundamentada en
`knowledge/we1.md`, Semana 1 — Independent Units, Self-Contained
Functionality, Well-Defined Interfaces) es exactamente el punto intermedio
que nunca se evaluó como fase 1 con evolución posterior hacia MSA (Strangler
Pattern, `we6.md`, Semana 6). **Se marcó explícitamente: REQUIERE REVISIÓN DE
DISEÑO** — se documentó aquí para que `architecture-reviewer` decidiera si
reabría Milestone 2 para evaluar un punto intermedio (ej. monolito modular por
bounded context como fase 1, con migración incremental por Strangler Pattern
hacia los servicios que primero lo justifiquen — Captura de Asistencia, por
su perfil de carga distinto ya documentado). `architecture-reviewer` confirmó
que sí ameritaba reapertura parcial (`design/milestone-3/review-log.md`,
Iteración 1) y `architecture-strategist` respondió con **`DEC-0013`** — ver
"Nota de resolución (post-DEC-0013)" abajo. **Este riesgo ya no está
pendiente.** Nota de contexto: como la implementación es opcional
(`capstone.pdf`, "Otros"), el riesgo inmediato no era un incidente de
producción real, sino la **defendibilidad** del diseño ante la pregunta
explícita que el propio curso exige poder responder: "sé qué problemas tendrá
mi arquitectura antes de implementarla" (`plan/milestones.pdf`, Milestone 3).

**Nota de resolución (post-DEC-0013):** `architecture-strategist` resolvió
este riesgo con **`DEC-0013`**
(`design/adr/adr-0013-monolito-modular-fase1-extraccion-selectiva.md`,
Aceptado), que reemplaza el alcance de "día 1" de `DEC-0001` por **Monolito
Modular por Bounded Context en Fase 1** (mismos 5 bounded contexts como
módulos internos de un único desplegable), con **extracción selectiva vía
Strangler Pattern en Fase 2**, activada por triggers verificables (número de
campus activos > 10, contención de I/O medida en dos ventanas pico
consecutivas, o madurez de pipeline/IaC probada) — no por fecha ni por
promesa. Esto es exactamente el punto intermedio de complejidad que este
riesgo señalaba como nunca evaluado en Milestone 2.

`ADR-0013` (sección "Consecuencias positivas") declara explícitamente que
esta decisión "reduce directamente la Probabilidad de RISK-01 (de Alta a,
razonablemente, Media-Baja en Fase 1): el equipo pequeño (3 a 5
desarrolladores, sin equipos de plataforma/DevOps/SRE dedicados) diseña,
despliega y opera **un** desplegable, no cinco, y no necesita infraestructura
de soporte de MSA (Service Discovery, orquestación de contenedores
multi-servicio, observabilidad distribuida) hasta que un trigger de Fase 2 lo
justifique". **Estado actualizado de este riesgo**: Probabilidad
**Media-Baja** (Fase 1) — Impacto **Baja** (Fase 1: ya no compromete la
defendibilidad del diseño frente a RST-01, que era el impacto real señalado
por este riesgo — ver "Nota de contexto" arriba). El riesgo **no desaparece
por completo**: `ADR-0013` ("Riesgos que quedan abiertos") reconoce que el
trigger 2 de extracción depende de que la observabilidad mínima recomendada
por `design/milestone-3/mitigation-plan.md` esté realmente implementada
desde el inicio de Fase 1 — si no se instrumenta, el trigger nunca dispara
aunque la contención real ya esté ocurriendo — y que la extracción de Fase 2,
cuando ocurra, reintroduce un costo de migración (Strangler Pattern) que no
existía en Fase 1. Ninguno de estos dos remanentes alcanza la severidad
Alta/Alta original: quedan documentados como riesgo residual **aceptado**,
no como "requiere revisión de diseño".

La cascada de propagación de `DEC-0013` ya actualizó, en Milestone 2,
`design/milestone-2/bounded-contexts.md`, `design/milestone-2/data-model-conceptual.md`
y los ADRs `0002`, `0003`, `0004`, `0006`, `0007`, `0008`, `0009` (secciones
"Nota de revisión — Milestone 3"), y en Milestone 3,
`design/milestone-3/tradeoff-matrix.md` (Eje 1, reformulado por completo).
Este registro y `design/milestone-3/mitigation-plan.md` quedan sincronizados
con esa cascada en esta misma pasada, cerrando la contradicción señalada por
`architecture-reviewer` contra `design/traceability.md` (que ya declaraba
este riesgo "Resuelto").

---

## [RISK-02] El NIS tarda más de las 2h esperadas o no está disponible más allá del tope de reintentos

**Escenario**: el NIS, como servicio externo no negociable (ASM-01), se
degrada por un período prolongado (días, no horas) — plausible para un
tercero gubernamental fuera de control operativo. ADR-0007 ya acota el ciclo
a 3 timeouts (hasta 6h acumuladas) y transiciona a `escalado_manual`,
publicando `NISVerificationEscalated`. Pero una vez en `escalado_manual`, el
diseño no define ningún SLA ni mecanismo de seguimiento automático para esa
cola de revisión manual — queda enteramente a criterio humano, sin alerta
escalonada si nadie la atiende. El propio ADR-0007 declara como riesgo
abierto que "el intervalo de polling (5-30 min) y el tope de 3 ciclos son
cifras de diseño... no validadas contra el comportamiento real del NIS".

**Probabilidad**: Media — **Impacto**: Alta (bloquea el flujo de registro
completo, incluyendo nuevas altas de usuarios, mientras dura)

**Componente/decisión afectada**: DEC-0002, DEC-0007

**Mitigación**: ya parcialmente mitigado por el diseño existente — Retry con
backoff exponencial y jitter (`knowledge/we7.md`, Semana 7) e Idempotent
Consumer sobre `nisVerificationId` (`we3.md`/`we7.md`, Semanas 3-4-7),
consistentes con el tratamiento de Procesos de Larga Duración como "explícitos,
comprobables y recuperables" (`we4.md`, Semana 4). Se evalúa que **el tope de
reintentos sí alcanza para acotar la espera del usuario, pero no para acotar
la espera de resolución una vez escalado**. Mitigación adicional propuesta
(aditiva, no cambia el estilo): aplicar el mismo patrón de alerta
escalonada que ya usa ASM-15 para el timeout del NIS también al estado
terminal `escalado_manual` (ej. recordatorio si la cola de revisión manual no
se atiende en un plazo operativo definido por UPCA); y logging &
observabilidad (`we6.md`, Semana 6, "You Build It, You Run It" +
observabilidad como principio de MSA) sobre la tasa real de timeouts del NIS,
para validar si 5-30 min / tope de 3 ciclos son adecuados, cerrando el riesgo
que el propio ADR-0007 deja abierto.

---

## [RISK-03] La verificación del NIS es rechazada

**Escenario**: el NIS rechaza la verificación (datos no coinciden, documento
inválido, etc.). ASM-11 exige notificación con motivo, ya cubierto
(`RegistrationRejected`, contexto Notificaciones). Lo que no está declarado
explícitamente es la **vía de reintento**: si el usuario corrige el error
(ej. subir un documento más legible), ¿reenvía un nuevo `POST /registrations`
completo? ADR-0012 solo bloquea reenvíos duplicados con la **misma**
`Idempotency-Key` o el mismo (documento+correo) mientras la solicitud
original esté en estado **no terminal** — una vez `rechazado` (terminal), un
reenvío nuevo no queda bloqueado por el mecanismo de deduplicación, pero esto
nunca se documenta como el camino intencional de "reintento tras rechazo".

**Probabilidad**: Media — **Impacto**: Media (afecta UX y carga
administrativa, no la integridad de datos)

**Componente/decisión afectada**: DEC-0002, DEC-0012

**Mitigación**: notificación con motivo ya resuelta (ASM-11, Lenguaje
Publicado, `knowledge/we7.md`, Semana 7 — Context Mapping). Mitigación
adicional: declarar explícitamente en `bounded-contexts.md` que
`POST /registrations` con una `Idempotency-Key` nueva del cliente, tras un
estado terminal `rechazado`, es la vía soportada de reintento (ya funciona
así por el diseño de ADR-0012, Idempotent Consumer, `we3.md`/`we7.md`, solo
falta documentarlo como decisión intencional, no como comportamiento
incidental). No requiere ningún componente nuevo.

---

## [RISK-04] El correo de confirmación no llega

**Escenario**: `capstone.pdf` ("Autorregistro... (cont.)") declara que "la
confirmación se envía por correo electrónico al emisor (Universidad)"; ASM-11
y ASM-15 exigen además notificaciones al propio usuario (rechazo, demora). El
contexto Notificaciones (`bounded-contexts.md`) se describe como "consumidor
de eventos genérico + adaptadores de canal (correo, push)", pero, a
diferencia de cada otro flujo del sistema (que sí tiene idempotencia,
reintento y/o DLQ explícitos: ADR-0005, ADR-0007, ADR-0012), **ningún ADR
define qué pasa si el envío de correo falla** (proveedor caído, buzón lleno,
filtro de spam, dirección inválida).

**Probabilidad**: Media (fallos de entrega de correo son comunes en
cualquier sistema real con un proveedor externo) — **Impacto**: Media (no hay
pérdida de datos — el estado sigue siendo consultable vía
`GET /registrations/{id}/status` — pero el usuario/la universidad puede no
enterarse de un evento importante a tiempo)

**Componente/decisión afectada**: DEC-0002 (contexto Notificaciones, sin ADR
propio hasta ahora)

**Mitigación**: Retry con backoff exponencial (`knowledge/we7.md`, Semana 7)
sobre el envío al proveedor de correo; Dead Letter Queue (`we3.md`, Semanas
3-4) para notificaciones que agotan reintentos, con reenvío manual o
conmutación a un canal alternativo (push a la app móvil, dado que
`GET /registrations/{id}/status` ya existe como mecanismo de *pull* de
respaldo, ASM-08); uso del campo `RegistroDeNotificacion.estado` (ya presente
en `data-model-conceptual.md`) como máquina de estados de entrega (enviado /
fallido / reintentando / en DLQ), no solo como registro pasivo. Se recomienda
un ADR nuevo de detalle en la siguiente iteración — aditivo, no requiere
tocar el estilo ni los bounded contexts.

---

## [RISK-05] El personal administrativo no aprueba el registro

**Escenario**: la Saga alcanza el estado `pendiente_admin` (RST-04, ADR-0002)
y permanece allí sin ningún mecanismo de seguimiento si el personal
administrativo no revisa la cola `GET /registrations/pending` a tiempo. A
diferencia del timeout del NIS (ASM-15, con alerta, notificación de demora y
reintento explícitamente exigidos por los stakeholders simulados), no existe
una expectativa funcional ni un mecanismo equivalente para la demora del lado
administrativo — es el mismo tipo de espera humana no acotada, sin el
tratamiento que sí recibió el lado del NIS.

**Probabilidad**: Media (depende de carga operativa humana, más probable en
picos de inscripción — ej. inicio de semestre) — **Impacto**: Media (el
usuario queda bloqueado sin Insignia DAS, pero el sistema no se corrompe ni
pierde datos)

**Componente/decisión afectada**: DEC-0002

**Mitigación**: aplicar el mismo patrón de Proceso de Larga Duración
"explícito, comprobable y recuperable" (`knowledge/we4.md`, Semana 4) que
ADR-0002 ya usa para el tramo NIS, extendido al tramo de aprobación
administrativa: alerta escalonada (recordatorio tras un plazo operativo,
escalamiento a supervisor tras un plazo mayor) vía el mismo canal de
Notificaciones (Lenguaje Publicado, `we7.md`), y ordenar
`GET /registrations/pending` por antigüedad de espera para dar visibilidad
operativa directa. Aditivo dentro de Registro y Verificación, no requiere ADR
que cambie el estilo.

---

## [RISK-06] El usuario intenta registrarse nuevamente mientras hay una verificación en curso

**Escenario**: cubierto en gran medida por ADR-0012 (`Idempotency-Key` del
cliente + deduplicación secundaria por documento+correo dentro de una ventana
de 24h, aplicable solo si la solicitud existente está en estado **no
terminal**). Riesgo residual: ADR-0007 declara `escalado_manual` como un
**nuevo estado terminal explícito**. Si un usuario pierde su
`Idempotency-Key` local (reinstaló la app, cambió de dispositivo) y su
solicitud original alcanza `escalado_manual`, la deduplicación secundaria de
ADR-0012 **no lo bloquearía** (por estar en estado "terminal"), permitiendo
una segunda `SolicitudDeRegistro` con su propia verificación NIS duplicada
contra un tercero no negociable (ASM-01) — mientras la primera sigue
pendiente de revisión manual.

**Probabilidad**: Baja-Media (requiere la coincidencia de dos eventos poco
frecuentes: pérdida de la clave local Y que la solicitud haya llegado a
`escalado_manual`) — **Impacto**: Media (verificación NIS duplicada
innecesaria contra un tercero cuyo costo/carga no se controla)

**Componente/decisión afectada**: DEC-0007, DEC-0012

**Mitigación**: extender la excepción de deduplicación secundaria de
ADR-0012 para tratar `escalado_manual` como "no terminal a efectos de
deduplicación" (representa una falla operativa del proceso, no una decisión
final) — ajuste aditivo sobre un ADR ya existente. Patrón: Idempotent
Consumer (`knowledge/we3.md`/`we7.md`, Semanas 3-4-7).

---

## [RISK-07] Se recibe una respuesta duplicada del NIS

**Escenario**: ya cubierto explícitamente por ADR-0007 — `nisVerificationId`
como clave de deduplicación (Idempotent Consumer); reenvíos con el mismo id
se descartan y auditan; resultados contradictorios tardíos tras un estado
terminal se enrutan a una cola de revisión manual (Dead Letter Queue) en vez
de reprocesarse automáticamente, evitando transiciones contradictorias
silenciosas (ej. revocar una credencial ya emitida sin intervención humana).

**Probabilidad**: Baja (mitigado) — **Impacto**: Baja (mitigado; el peor
caso remanente es una revisión manual adicional, no un dato corrupto)

**Componente/decisión afectada**: DEC-0007

**Mitigación**: ya implementada — Idempotent Consumer (`knowledge/we3.md`/
`we7.md`, Semanas 3-4-7) + Dead Letter Queue para el caso contradictorio
(`we3.md`, Semanas 3-4). Se documenta aquí por completitud de cobertura de
escenario (pedido explícito de Milestone 3), sin acción pendiente.

---

## [RISK-08] El usuario modifica su información después de iniciar la verificación

**Escenario**: `data-model-conceptual.md` no define ninguna API de
actualización (`PUT`/`PATCH`) sobre `SolicitudDeRegistro.datosPersonalesCandidato`
— solo `POST /registrations` (creación) y `GET /status` (consulta).
`bounded-contexts.md` y todos los ADRs de Registro y Verificación (ADR-0002,
ADR-0007, ADR-0012) asumen implícitamente que los datos de la solicitud son
inmutables una vez enviados. Si un usuario detecta un error (ej. errata en
fecha de nacimiento) mientras está `pendiente_nis`, no hay camino modelado:
¿puede editar? ¿debe cancelar y reenviar? Si el NIS ya empezó a verificar los
datos originales y el usuario los cambia por otra vía no modelada, el
resultado de la verificación podría no corresponder a los datos que el
usuario ve reflejados en su solicitud.

**Probabilidad**: Media (errores de tipeo en formularios móviles son
comunes) — **Impacto**: Media (puede producir una aprobación/rechazo basado
en datos que ya no coinciden con lo que el usuario cree haber enviado, o
confundir sobre qué versión fue verificada)

**Componente/decisión afectada**: DEC-0002 — sin ADR que lo cubra

**Mitigación**: **no resuelto por ningún mecanismo existente; requiere una
decisión de negocio, no solo un patrón de resiliencia**. Se documenta como
**hallazgo de diseño abierto** — no se resuelve por este agente. Dos caminos
posibles a decidir por `architecture-strategist` en la siguiente iteración de
detalle (ninguno cambia el estilo MSA+EDA ni los bounded contexts, por lo que
**no** se marca como "requiere revisión de diseño" a nivel de
`architecture-reviewer`, a diferencia de RISK-01): (a) bloquear ediciones
mientras `estado` no sea terminal, exigiendo cancelación explícita (nuevo
estado `cancelado`) y un nuevo envío vía el mismo `POST /registrations`
(reutilizando la idempotencia de ADR-0012); o (b) permitir edición solo antes
de que la Saga dispare la primera consulta al NIS. Patrón de referencia una
vez decidido: Idempotent Consumer (`knowledge/we3.md`/`we7.md`) sobre el
reenvío.

---

## [RISK-09] Buffer local del Dispositivo DAS sin tamaño máximo ni política de purga

**Escenario**: ADR-0005 declara explícitamente, desde Milestone 2, que "el
mecanismo técnico exacto del buffer (tamaño máximo, política de purga si el
dispositivo permanece offline más allá de cierto tiempo) no está definido...
queda como decisión de detalle para una iteración posterior". Ningún ADR de
Iteración 2 (`ADR-0006` a `ADR-0012`) lo retomó (`review-log.md`, Iteración
2). Un dispositivo en un campus remoto (20 campus, 10 ciudades, sin garantía
documentada de infraestructura de red uniforme — AMB-06) que pierde
conectividad por un período extendido (días) podría agotar su capacidad de
almacenamiento local y descartar eventos silenciosamente, contradiciendo
ASM-07 ("la asistencia real no debe perderse") — exactamente el requisito
que ADR-0005 fue creado para satisfacer.

**Probabilidad**: Baja-Media (depende de infraestructura real de los 20
campus, no garantizada uniforme por el enunciado) — **Impacto**: Alta (si
ocurre, contradice directamente una garantía funcional explícita, ASM-07)

**Componente/decisión afectada**: DEC-0005

**Mitigación**: definir (1) un tamaño máximo de buffer por dispositivo
(cifra de diseño, dimensionada con el mismo criterio conservador que el
Anexo de carga pico de `architecture-decision.md` — hasta 6 escaneos/usuario/
día); (2) política de purga con **load shedding** priorizado (descartar lo
más antiguo solo tras alcanzar el límite, nunca silenciosamente y siempre con
alerta) en vez de descarte no gestionado (`knowledge/we4.md`, Semana 4 —
técnicas de backpressure: "buffering, load shedding"); (3) evento de alerta
al superar un umbral de advertencia (ej. 80% de capacidad), consumido por
Notificaciones para avisar a soporte técnico del campus — mismo patrón de
Dead Letter Queue aplicado a auditoría de eventos descartados
(`knowledge/we3.md`, Semanas 3-4), para que un descarte extremo quede
registrado, no oculto.

---

## [RISK-10] Tormenta de reconciliación al recuperar conectividad masiva

**Escenario**: cuando muchos dispositivos de un mismo campus recuperan
conectividad simultáneamente tras un corte, cada uno sincroniza su buffer
offline vía `POST /attendance-events/batch` (ADR-0005) al mismo tiempo que
la cola de reconciliación del Circuit Breaker (ADR-0006) revalida en lote los
eventos aceptados en modo `cache_degradada` — una carga concentrada no
contemplada en la estimación de carga pico de `architecture-decision.md`
(Anexo de Iteración 2), que modela únicamente escaneos en vivo distribuidos
en ventanas de clase, no sincronización masiva post-outage.

**Probabilidad**: Baja-Media (depende de la frecuencia de outages extendidos
multi-dispositivo) — **Impacto**: Media (podría saturar Captura de
Asistencia justo cuando más se necesita, o disparar el Circuit Breaker de
ADR-0006 contra Identidad si la reconciliación exige revalidación masiva)

**Componente/decisión afectada**: DEC-0005, DEC-0006

**Mitigación**: throttling/rate limiting con **jitter** en la sincronización
de buffers offline — backoff exponencial + jitter para evitar el "efecto
rebaño"/thundering herd que el propio glosario de `knowledge/index.md`
(Semana 7, Backoff exponencial) nombra explícitamente; **Bulkhead**
(`knowledge/we4.md`/`we7.md`, Semanas 4-7) para aislar la capacidad de
`POST /attendance-events/batch` (sincronización masiva) de la de
`POST /attendance-events` (escaneo en vivo), de modo que una reconciliación
masiva no compita por los mismos recursos que la ruta crítica near real-time.

**Nota de vigencia por fase (post-DEC-0013):** el mecanismo que esta parte
del escenario describe — "la cola de reconciliación del Circuit Breaker
(`ADR-0006`) revalida en lote los eventos aceptados en modo
`cache_degradada`" — **no existe hoy**: `ADR-0013` deja explícitamente **en
pausa** el Circuit Breaker Captura↔Identidad en Fase 1, porque ambos módulos
viven en el mismo proceso (sin frontera de red que proteger); confirmado
contra `design/diagrams/c4-container.mmd` (relación `mod_captura →
mod_identidad` etiquetada "invocación en proceso, sin frontera de red") y
contra la nota de revisión de `ADR-0006`.

Reevaluación: el riesgo **no desaparece por completo en Fase 1**, pero sí se
reduce a una causa más simple. `DEC-0005`/`ADR-0005` (buffer local +
sincronización por lotes vía `POST /attendance-events/batch`) **no cambia**
con `DEC-0013` — confirmado explícitamente en la "Nota de impacto sobre
decisiones existentes" del propio `ADR-0013` ("sin impacto estructural...
independientes de si el backend es monolito o microservicios"). Es decir, en
Fase 1 puede seguir ocurriendo una concentración de carga cuando muchos
dispositivos de un mismo campus recuperan conectividad simultáneamente y
sincronizan su buffer offline al mismo tiempo — pero **sin** el agravante de
una reconciliación de Circuit Breaker compitiendo por el mismo backend, ya
que esa reconciliación no existe hasta Fase 2. La mitigación de throttling
con jitter (sobre la sincronización de buffers) sigue aplicando y siendo
suficiente en Fase 1; el componente de mitigación de Bulkhead sigue siendo
válido dentro del monolito (aislar la capacidad interna de la ruta batch de
la ruta de escaneo en vivo, sin requerir frontera de red). El escenario
**completo** (ambos mecanismos compitiendo simultáneamente) queda **diferido
a Fase 2**, cuando la extracción de Captura de Asistencia reactive el
Circuit Breaker de `ADR-0006` y su cola de reconciliación tal como están
especificados.

---

## [RISK-11] Un campus completo pierde conectividad hacia los servicios centrales

**Escenario**: distinto de un dispositivo individual caído (ADR-0005 cubre
ese caso) — un corte de WAN/ISP deja a **todo un campus** sin acceso a
Captura de Asistencia (backend), al broker de eventos y a Identidad y
Credenciales, simultáneamente para cientos de dispositivos. El mecanismo es
el mismo (buffer local por dispositivo) pero la escala del problema (un
campus completo, no un dispositivo aislado) no está evaluada explícitamente
en ningún ADR ni en la estimación de carga de `architecture-decision.md`.

**Probabilidad**: Baja (10 ciudades, 20 campus — un corte de ISP regional es
posible pero no frecuente) — **Impacto**: Alta (durante el corte, DRV-05 se
degrada completamente para toda una ubicación, no solo para un usuario; el
portal administrativo pierde visibilidad de ese campus)

**Componente/decisión afectada**: DEC-0005, DEC-0001 (topología distribuida
multi-campus)

**Mitigación**: el mecanismo funcional ya cubre este caso (buffer local +
Idempotent Consumer, ADR-0005, aplicado de forma consistente en todos los
dispositivos de un campus) — el riesgo real es de **escala**, no de
mecanismo faltante. Mitigación específica: (1) resolver primero RISK-09
(tamaño/purga del buffer), porque a escala de campus completo el riesgo de
pérdida silenciosa se multiplica por cientos de dispositivos; (2) aplicar la
mitigación de RISK-10 (throttling con jitter) al reconectar, más severa aquí
por involucrar un campus entero, no un dispositivo; (3) logging &
observabilidad (`knowledge/we6.md`, Semana 6 — observabilidad como principio
de MSA) — métrica de "campus sin heartbeat reciente" para que el personal
administrativo tenga visibilidad operativa directa de la degradación, en vez
de inferirla indirectamente por ausencia de datos en el portal.

---

## [RISK-12] Escalamiento a ~15.000 usuarios no soportado en la práctica

**Escenario**: `architecture-decision.md` (Anexo, Iteración 2) ya estima
carga pico (~50-55 eventos/seg) contra la capacidad típica de un proyector
CQRS de propósito general, declarado explícitamente como estimación de
diseño, no validación operacional. Riesgo residual reconocido por el propio
anexo: si el patrón real de asistencia resulta más sincronizado de lo
asumido (ej. todos los campus de una misma ciudad con el mismo horario
exacto de clases, sin la dispersión horaria asumida como "peor caso
conservador"), el pico real podría superar la estimación.

**Probabilidad**: Media (la propia estimación reconoce supuestos
optimistas sobre distribución horaria entre campus) — **Impacto**: Media
(afecta el SLA de proyección ≤15s p95 de ADR-0003, no la integridad del dato
— el proyector se atrasaría, no perdería eventos, según la propia
consecuencia aceptada de ADR-0003)

**Componente/decisión afectada**: DEC-0003, DEC-0001

**Mitigación**: ya parcialmente mitigado por diseño — CQRS con proyector
escalable horizontalmente ante contrapresión (`knowledge/we4.md`, Semana 4,
"el proyector debe escalar horizontalmente para ponerse al día"). Mitigación
adicional: **prototipo temprano de integración**/spike de carga — validar el
cálculo del Anexo con una prueba de carga simulada antes de comprometerse al
SLA en producción (corresponde directamente al hito "Prototipo de captura"
de `design/cronograma.md`); logging & observabilidad de throughput real vs.
estimado para detectar desvíos tempranamente frente al supuesto de dispersión
horaria.

---

## [RISK-13] ASM-05 (verificación digital vs. escaneo físico) sin decisión ni API dedicada

**Escenario**: ASM-05 distingue explícitamente la "verificación digital del
DAS ID desde la app" (consulta) del "escaneo físico de la Insignia" (captura
de asistencia), pero ningún `DEC` ni API queda explícitamente asignada a esa
primera capacidad — `GET /identity/{dasId}` (consulta de perfil genérica,
REQ-01/REQ-08) podría cubrirla, pero el diseño nunca lo confirma por nombre
(`review-log.md`, Iteración 1 y 2, severidad Baja, sin cambios).

**Probabilidad**: Baja (funcionalmente ya existe una API que probablemente
cubre el caso; el riesgo es de ambigüedad de documentación, no de vacío
funcional real) — **Impacto**: Baja (no bloquea ningún flujo crítico)

**Componente/decisión afectada**: sin `DEC` dedicada (gap de trazabilidad ya
señalado por `architecture-reviewer`)

**Mitigación**: aditivo — declarar explícitamente en `bounded-contexts.md`
(o en un ADR breve) que `GET /identity/{dasId}` satisface ASM-05, cerrando la
ambigüedad sin crear ningún componente nuevo. No requiere ningún patrón de
resiliencia, solo una decisión de documentación explícita (`knowledge/we7.md`,
Semana 7 — Lenguaje Ubicuo: nombrar explícitamente el concepto en el
contrato).

---

## [RISK-14] Ventana de exposición de una credencial revocada coincide con un incidente del backend de Identidad

**Escenario**: ADR-0006/ADR-0009 ya reconocen y aceptan como trade-off
explícito un TTL de 15 min de caché de "recientemente validadas". En el peor
caso — Circuit Breaker Abierto (incidente de backend) simultáneo a una
revocación reciente del mismo `dasId` — una credencial revocada podría
seguir siendo aceptada en modo `cache_degradada` hasta que expire ese TTL o
hasta que la propagación activa de `CredentialRevoked` la invalide (lo que
ocurra primero, pero la invalidación activa depende de que el Circuit
Breaker no esté en el estado que precisamente impide la validación
confirmada).

**Probabilidad**: Baja (requiere coincidencia de dos eventos de baja
frecuencia: incidente de backend + revocación reciente del mismo `dasId`) —
**Impacto**: Media (riesgo de seguridad acotado a 15 min y a una identidad
específica, no a todo el sistema)

**Componente/decisión afectada**: DEC-0006, DEC-0009

**Mitigación**: ya mitigado parcialmente — TTL explícito + invalidación
activa cuando es posible (Circuit Breaker, `knowledge/we7.md`, Semana 7;
mensajería asíncrona de propagación de estado, `we3.md`/`we4.md`, Semanas
3-4). Mitigación adicional: logging & observabilidad — alerta específica
cuando coincide un Circuit Breaker Abierto con una revocación reciente
(evento correlacionado), para que personal de seguridad pueda intervenir
manualmente durante la ventana de 15 min en casos de alto riesgo (ej. robo
de insignia reportado). No requiere modificar el TTL, solo agregar
visibilidad operativa sobre la coincidencia.

---

## [RISK-15] El broker de eventos concentra la disponibilidad de múltiples mecanismos de resiliencia

**Escenario**: tras Iteración 2 de Milestone 2, el broker de eventos ya no
es solo el canal de Captura de Asistencia → Reportes (CQRS, ADR-0003) — es
también la columna vertebral de la propagación de revocación (ADR-0009), de
la proyección de credenciales del Dispositivo DAS (ADR-0008) y de todas las
notificaciones del sistema. Si el broker se degrada, **múltiples mecanismos
de resiliencia fallan simultáneamente**, no solo un servicio puntual — un
tipo de fallo estructuralmente distinto al que cada ADR individual evalúa por
separado.

**Probabilidad**: Baja (brokers de eventos maduros suelen tener alta
disponibilidad, pero para RST-01 operar un broker en clúster con tolerancia
a fallos es carga operativa adicional — conecta directamente con RISK-01) —
**Impacto**: Alta (degrada simultáneamente Reportes, refresco de caché de
dispositivos, propagación de revocación y notificaciones)

**Componente/decisión afectada**: DEC-0001 (elección de EDA como columna
vertebral de comunicación entre contextos)

**Mitigación**: no requiere cambiar el estilo — el broker es, por diseño de
EDA (`knowledge/we3.md`, Semana 3), el mecanismo de desacoplamiento elegido
deliberadamente; se mitiga con infraestructura (clustering/réplicas del
broker, fuera del alcance de patrones de aplicación) + logging &
observabilidad (monitoreo de salud del broker y de lag de consumidores,
`we6.md`, Semana 6) + el hecho de que varios consumidores ya tienen
reconciliación de baja frecuencia como fallback (ADR-0008: snapshot diario;
ADR-0003 ya acepta que "un evento perdido... deja la proyección
desactualizada hasta la siguiente reconciliación" como riesgo residual ya
asumido). Se documenta aquí como riesgo **transversal** para dejar explícito
que varios ADRs comparten la misma raíz de fallo — no evaluado como tal en
ningún ADR individual de Milestone 2.

**Nota de vigencia (post-DEC-0013):** este riesgo **no existe hoy**. En
Fase 1 (`DEC-0013`, Monolito Modular por Bounded Context) no hay ningún
broker de eventos desplegado — confirmado contra
`design/diagrams/c4-container.mmd` (sin ningún `Container(broker,...)`,
todas las relaciones inter-módulo etiquetadas "invocación en proceso") y
contra la "Nota de aplicabilidad por fase" del Eje 2 de
`design/milestone-3/tradeoff-matrix.md`. La propagación de revocación
(`ADR-0009`), la proyección de credenciales del Dispositivo DAS (`ADR-0008`)
y la separación de lectura/escritura (`ADR-0003`) se implementan en Fase 1
sin ningún componente de mensajería distribuida compartida (lectura directa
en proceso, réplica de lectura/vista materializada dentro del mismo motor) —
no hay, por lo tanto, ninguna pieza de infraestructura única cuya
degradación arrastre a los cuatro mecanismos simultáneamente, que es
exactamente la condición que este riesgo describe.

El propio `ADR-0013` ("Riesgos que quedan abiertos") ya reconoce esto: "esta
decisión no resuelve por sí sola RISK-15... en Fase 1 ese riesgo simplemente
no existe aún (no hay broker), pero reaparecerá idéntico al activarse la
extracción de Captura de Asistencia en Fase 2". Este riesgo queda por lo
tanto **diferido a Fase 2** (activación del trigger de extracción de Captura
de Asistencia), momento en el que el broker de eventos vuelve a introducirse
exactamente como lo describe este escenario, y la mitigación de
clustering/réplicas + monitoreo de salud propuesta arriba vuelve a ser
necesaria. No se reclasifica Probabilidad/Impacto en esta pasada porque
ambos ya se evaluaban contra el escenario de Fase 2 (el único en el que este
mecanismo existe); no aplica una versión reducida en Fase 1 como sí ocurre
con `RISK-10`, porque aquí el mecanismo entero está ausente, no
parcialmente.

---

## [RISK-16] Placeholder de retención de documentos/fotos de registro (DEC-0011) sin validación legal antes de producción

**Escenario**: `ADR-0011` fija, a falta de una política legal confirmada por
UPCA, un valor de diseño por defecto para `documentoRef`/`fotoRef` de
`SolicitudDeRegistro` (180 días tras estado terminal, 1 año adicional en
sospecha de fraude), marcado explícitamente en el propio ADR como "Supuesto
de diseño — requiere validación con el instructor/negocio real". AMB-04
(alcance exacto de la retención de 5 años sobre estos datos) sigue
**formalmente abierta** en `design/traceability.md` — el ADR le da un valor
operable transitorio, pero no la resuelve. El riesgo no es que el mecanismo
técnico falle (no hay mecanismo de resiliencia que aplique aquí), sino que
**nadie confirme, antes de que el sistema entre en operación real, si 180
días/1 año coinciden con lo que exige la normativa real aplicable a UPCA** —
si la exigencia legal real fuera mayor, el placeholder purgaría evidencia
documental antes de lo permitido (riesgo de incumplimiento normativo y de
pérdida de capacidad de auditoría/apelación); si fuera menor, UPCA retendría
datos personales sensibles (documento de identidad, foto) más tiempo del
legalmente admitido, exactamente el "peor resultado posible para DRV-03"
que `ADR-0011` fue creado para evitar en su versión de retención indefinida.
`design/milestone-3/tradeoff-matrix.md` (Eje 3, fila "Seguridad") también
señala que "el alcance de la retención sobre documentos/fotos de registro
(AMB-04) sigue formalmente abierto" sin que ningún `RISK-NN` lo cubriera
hasta ahora (`review-log.md`, Iteración 1, Hallazgo 3).

**Probabilidad**: Media (el propio `ADR-0011` declara la cifra sin respaldo
legal confirmado; nada en el diseño obliga a que la validación ocurra antes
de producción — depende de que alguien la agende explícitamente) —
**Impacto**: Alta (expone a UPCA a incumplimiento normativo sobre datos
personales sensibles — documento de identidad y foto — o, en el extremo
contrario, a una purga prematura de evidencia con valor de auditoría; ambos
casos afectan directamente DRV-03 y DRV-04)

**Componente/decisión afectada**: DEC-0011 (`ADR-0011`), y transitivamente
AMB-04

**Mitigación**: **no se resuelve con un patrón de resiliencia ni con un
cambio de arquitectura** — el mecanismo (purga automática a los 180 días/1
año) ya está bien definido y es técnicamente correcto; lo que falta es una
**validación externa de cumplimiento (compliance)**, no una construcción de
software. `knowledge/we1.md` (Semana 1) es el único punto del curso que
desarrolla la distinción explícita entre **Gobierno** y **Cumplimiento**
("capacidad de la organización para cumplir leyes, regulaciones, políticas
internas y estándares de seguridad/técnicos aplicables") — se usa aquí como
anclaje conceptual del tipo de gap que este riesgo representa (uno de
cumplimiento normativo, no de mecanismo técnico), consistente con la regla
de oro de este proyecto de declarar explícitamente los supuestos fuera del
alcance del curso en vez de insertarlos en silencio. Acción propuesta
(proceso, no código): (1) agregar un checkpoint explícito de "validación
legal del placeholder de `ADR-0011`" como condición de salida antes de
cualquier despliegue a producción real (no antes de Milestone 4, que es
documental); (2) si para ese checkpoint no hay confirmación legal, mantener
el placeholder pero registrar explícitamente el riesgo residual aceptado,
en vez de asumir tácitamente que 180 días/1 año son correctos. **No se
marca "requiere revisión de diseño"** (a diferencia de RISK-01): ni el
mecanismo de purga ni el estilo MSA+EDA cambian con el resultado de esta
validación, solo el valor numérico del placeholder ya aislado en un único
ADR.

---

## [RISK-17] Falla operativa silenciosa del mecanismo de transición por capas de retención (DEC-0004)

**Escenario**: `ADR-0004` introduce, desde Milestone 2, un "proceso
automatizado de transición entre capas" (caliente → tibio → frío) sobre
`EventoDeAsistencia`, señalado por el propio ADR como "complejidad
operacional adicional" y confirmado por
`design/milestone-3/tradeoff-matrix.md` (Eje 3) como "mayor: requiere
proceso automatizado de transición entre capas" (fila "Complejidad
operativa") y como "lógica de tiering con costo operativo propio" (fila
"Costo") — pero, a diferencia de otros mecanismos nuevos introducidos en
Milestone 2 (buffer local del Dispositivo DAS → RISK-09; broker de eventos
como dependencia compartida → RISK-15), ningún `RISK-NN` evaluaba hasta
ahora qué pasa si ese proceso de transición **falla** (`review-log.md`,
Iteración 1, Hallazgo 3). El job de migración automatizada podría fallar
silenciosamente para un subconjunto de `EventoDeAsistencia` (ej. un batch
nocturno que no corre, o corre parcialmente) sin que nadie lo detecte, dado
que no hay ningún mecanismo de observabilidad definido específicamente para
este mecanismo. El escenario más severo no es solo un registro "atrasado" en
su capa: si la capa caliente está dimensionada para datos recientes (por
diseño, optimizada para escritura/consulta de baja latencia, no para
retener el histórico completo) y la migración a tibio/frío no ocurre a
tiempo, un evento podría quedar en una ventana de transición no auditada e
incluso en riesgo de no conservarse el mínimo legal de 5 años que motivó
ADR-0004 en primer lugar (REQ-12, DRV-04) — contradiciendo también ASM-07
("la asistencia real no debe perderse"), la misma garantía funcional que
RISK-09 protege del lado del dispositivo.

**Probabilidad**: Baja-Media (los mecanismos de transición automatizada por
lotes son un punto de falla conocido en cualquier pipeline de datos, pero no
hay evidencia de que esto ocurra con frecuencia alta específicamente en este
diseño) — **Impacto**: Alta (si ocurre sin detectarse, compromete
directamente el requisito legal de retención de 5 años, REQ-12/DRV-04, y la
garantía funcional de no pérdida de asistencia real, ASM-07 — no es un
problema de UX sino de cumplimiento e integridad de datos)

**Componente/decisión afectada**: DEC-0004 (`ADR-0004`)

**Mitigación**: a diferencia de RISK-16, este riesgo **sí se resuelve con
mecanismos de resiliencia ya presentes en el vocabulario de este registro**,
extendidos al proceso de transición entre capas: (1) tratar la transición
por capas como un **Proceso de Larga Duración explícito, comprobable y
recuperable** (`knowledge/we4.md`, Semana 4), igual que ADR-0002 ya hace
para la Saga NIS — cada `EventoDeAsistencia` debe tener un estado de
migración verificable (ej. `capaActual` + `ultimaTransicionExitosa`), no una
transición implícita solo inferible por su antigüedad; (2) **Idempotent
Consumer** sobre el propio job de migración (`knowledge/we3.md`/`we7.md`,
Semanas 3-4-7), para que un reintento tras falla parcial no duplique ni
corrompa datos ya migrados; (3) **Dead Letter Queue** (`knowledge/we3.md`,
Semanas 3-4) para lotes de transición que fallan repetidamente, en vez de
descartarlos o dejarlos silenciosamente en la capa de origen — mismo patrón
ya propuesto para RISK-09 (auditoría de eventos descartados) y RISK-04
(notificaciones fallidas); (4) **logging & observabilidad**
(`knowledge/we6.md`, Semana 6 — observabilidad como principio de MSA):
alerta si el volumen de la capa caliente crece más allá de la ventana
esperada de datos "recientes" sin que la migración correspondiente se haya
confirmado, y métrica explícita de "eventos pendientes de transición más
allá del plazo esperado". Ninguna de estas mitigaciones cambia el estilo
MSA+EDA ni el mecanismo de tiering ya aceptado en `ADR-0004` — son aditivas
sobre un ADR ya existente, en la misma línea que las mitigaciones ya
propuestas para RISK-09 y RISK-15.

---
