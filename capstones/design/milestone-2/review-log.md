# Review Log — Milestone 2 (Skeptic Review)

## Iteración 1 — 2026-08-23

Auditoría de estructura primero (bounded-contexts.md, data-model-conceptual.md,
traceability.md, los 5 ADRs, diagramas `.mmd` + NOTES.md), justificación
narrativa (architecture-decision.md) leída después. No es
`SIN HALLAZGOS NUEVOS`: esta es la primera corrida del gate y hay hallazgos
reales, incluyendo los que el propio equipo (architecture-modeler,
architecture-strategist) dejó explícitamente abiertos y que se pidió auditar
formalmente.

### [Fallo de punto único / cascada] Circuit Breaker citado pero nunca especificado para Captura → Identidad
- **ID relacionado**: DRV-03, DRV-05, REQ-06 / DEC-0001, DEC-0005
- **Qué falta o es ambiguo**: `architecture-decision.md` (fundamento de la
  Alternativa 2) menciona "Circuit Breaker + Retry con backoff exponencial y
  jitter... para la comunicación entre Captura de Asistencia y
  Registro/Identidad" como cita de `knowledge/we7.md`, pero ningún ADR
  (ni ADR-0005, que es el que trata la resiliencia de Captura de Asistencia)
  especifica el comportamiento real: ¿qué hace Captura cuando Identidad
  responde con error o timeout **por caída del servicio backend**, no por
  desconexión del dispositivo? ADR-0005 solo cubre el caso de dispositivo
  desconectado (con caché local en el borde); no cubre el caso de que el
  **servicio** Identidad y Credenciales completo esté caído o degradado
  mientras los 20 campus siguen online y enviando escaneos. Tampoco se
  especifica el Dead Letter Queue mencionado en el mismo párrafo de
  fundamento (`we3.md`/`we4.md`) para eventos que el proyector de Reportes
  no puede procesar repetidamente.
- **Escenario de falla**: Identidad y Credenciales sufre un incidente (no de
  red, sino del propio servicio/base de datos). Todos los dispositivos
  online en los 20 campus siguen intentando validar credenciales vía
  `Cap->>Iden` (síncrono, según `sequence-checkin.mmd` línea 14 y
  `c4-container.mmd` línea 64) y no tienen definido si deben: (a) rechazar el
  escaneo (fail-closed, degradando el servicio de asistencia para todo
  usuario legítimo), (b) aceptar el escaneo sin validación confirmada
  (fail-open, riesgo de seguridad, choca con DRV-03), o (c) tratarlo como si
  fuera una desconexión y encolarlo localmente (mezclando dos causas de
  fallo distintas bajo el mismo mecanismo).
- **Severidad**: Alta
- **A quién se devuelve**: architecture-strategist

### [Idempotencia y duplicados] Sin manejo definido de respuesta duplicada o fuera de orden del NIS
- **ID relacionado**: DRV-02, ASM-01, ASM-15 / DEC-0002, ADR-0002
- **Qué falta o es ambiguo**: ADR-0002 y el diagrama `sequence-registro-nis.mmd`
  definen idempotencia solo para las **solicitudes salientes** hacia el NIS
  ("clave de idempotencia por solicitud", para evitar tormentas de
  reintentos). No hay ninguna mención de qué ocurre si el **resultado
  entrante** del NIS llega duplicado o fuera de orden — un escenario
  realista dado que el propio ASM-01 declara que el NIS es un sistema
  externo no negociable cuyo comportamiento de entrega no se controla (podría
  reenviar el callback, o entregar "rechazado" después de ya haber entregado
  "aprobado" por un reintento propio del NIS).
- **Escenario de falla**: la Saga recibe `Verificación aprobada`, transiciona
  a `pendiente_admin`, y el personal administrativo ya aprobó (`aprobado`,
  `RegistrationApproved` ya publicado, `DASID`/`Credencial` ya creados). Minutos
  después llega un segundo callback del NIS (reenvío, duplicado de red) con el
  mismo resultado o, peor, con un resultado distinto ("rechazado"). El diseño
  actual no define si la Saga debe ignorar el evento por estar en un estado
  terminal, o si podría reprocesarlo y generar un `RegistrationRejected`
  contradictorio para un usuario que ya tiene una Insignia DAS emitida.
- **Severidad**: Alta
- **A quién se devuelve**: architecture-strategist

### [Estado del usuario durante la espera / Reintentos] Sin tope máximo de reintentos ante timeout repetido del NIS
- **ID relacionado**: DRV-02, ASM-15, RST-02 / DEC-0002, ADR-0002
- **Qué falta o es ambiguo**: `sequence-registro-nis.mmd` (líneas 51-58) y
  ADR-0002 definen que, ante timeout de 2h, se alerta, se notifica demora y
  se reintenta con backoff exponencial + jitter. No se define un número
  máximo de ciclos de timeout/reintento ni un mecanismo de escalamiento
  definitivo (ej. "tras N timeouts, se cierra la solicitud y se exige
  intervención manual del personal administrativo"). El backoff exponencial +
  jitter es la táctica correcta para fallos transitorios de corta duración,
  pero aquí se aplica sobre un timeout ya de **2 horas** — sin tope, el
  usuario podría quedar en un ciclo `pendiente_nis → timeout → reintento →
  timeout` de duración no acotada, contradiciendo la premisa de que la espera
  máxima es de 2h (RST-02 la limita solo para *un* intento del NIS, no para
  el proceso completo de registro).
- **Escenario de falla**: el NIS está degradado por varios días (evento
  plausible para un sistema externo que "puede tardar hasta 2 horas" en el
  mejor caso). Un candidato queda reintentando indefinidamente sin que el
  sistema defina en qué punto eso deja de ser "espera normal" y se convierte
  en una falla a escalar o comunicar de forma distinta al usuario.
- **Severidad**: Alta
- **A quién se devuelve**: architecture-strategist

### [Idempotencia — clave insuficiente] `claveIdempotencia` no incluye dirección del evento; sin manejo de reloj de dispositivo
- **ID relacionado**: DRV-05, REQ-06, ASM-07 / DEC-0005, ADR-0005
- **Qué falta o es ambiguo**: `data-model-conceptual.md` define
  `claveIdempotencia (dispositivoId + timestampEscaneo, o equivalente)` sin
  incluir `direccion` (entrada | salida). Si dos eventos legítimos y
  distintos (una entrada y una salida) llegaran con el mismo
  `dispositivoId` + el mismo `timestampEscaneo` (resolución de reloj no
  especificada — ¿segundos? ¿milisegundos?), la clave de idempotencia los
  trataría como duplicados y uno de los dos se perdería silenciosamente.
  Tampoco se especifica si `timestampEscaneo` es generado por el reloj local
  del dispositivo (sin sincronización NTP mencionada en ningún ADR) o
  asignado por el servidor al recibir el evento — esto es relevante tanto
  para la garantía de idempotencia como para la credibilidad del SLA de
  "≤15s p95" (ADR-0003), que se mide "desde el evento `AttendanceRecorded`",
  cuyo timestamp de origen no está definido con precisión.
- **Escenario de falla**: un estudiante escanea salida inmediatamente después
  de una entrada corregida manualmente por el profesor (mismo dispositivo,
  mismo segundo) — la segunda escritura podría rechazarse como duplicado.
- **Severidad**: Media
- **A quién se devuelve**: architecture-strategist

### [Ambigüedad no resuelta, ya señalada por architecture-modeler] Refresco de caché del Dispositivo DAS: ¿directo a Identidad o vía Captura?
- **ID relacionado**: DRV-03, DRV-05, REQ-06 / DEC-0001, DEC-0005, ADR-0005
- **Qué falta o es ambiguo**: confirmado en `design/diagrams/NOTES.md`,
  punto 3 — ADR-0005 dice que la caché del Dispositivo DAS "se refresca
  periódicamente desde Identidad y Credenciales", pero `bounded-contexts.md`
  solo nombra a **Captura de Asistencia** como consumidor de
  `GET /identity/{dasId}/credential/validate`. Esto no es un detalle de
  dibujo: cambia la arquitectura de red y el perímetro de seguridad. Si el
  Dispositivo DAS llama directamente a Identidad, se extiende la superficie
  de exposición de esa API a ~20 campus de dispositivos físicos (contradice
  parcialmente el argumento de DRV-03 de "confinar" el dato sensible dentro
  de su contexto). Si el refresco pasa por Captura de Asistencia, entonces
  Captura debe exponer una nueva ruta de "sincronización de caché" no
  documentada en sus APIs principales (`POST /attendance-events`,
  `POST /attendance-events/batch`), y absorbe tráfico adicional no
  contemplado en su perfil de carga.
- **Escenario de falla**: sin definir esto, no se puede razonar sobre
  seguridad de red (quién tiene credenciales/certificados para llamar a
  Identidad), ni sobre el volumen real que debe soportar Captura de
  Asistencia, ni sobre a quién pertenece la responsabilidad operativa si el
  refresco falla silenciosamente en 20 campus a la vez.
- **Severidad**: Alta
- **A quién se devuelve**: architecture-strategist

### [Confidencialidad / DRV-03] Revocación de credencial no modelada — sin evento, sin API, sin propagación a cachés
- **ID relacionado**: DRV-03, REQ-09 / DEC-0001
- **Qué falta o es ambiguo**: `data-model-conceptual.md` define
  `DASID.estado (activo | revocado)` como atributo, pero no existe en todo
  el diseño (bounded-contexts.md, ADRs, diagramas) ningún flujo, API o
  evento (`CredentialRevoked` o equivalente) que dispare esa transición ni
  que la propague a las dos cachés identificadas (la del backend de
  Identidad y Credenciales, y la del propio Dispositivo DAS, ADR-0005). El
  único evento publicado por Identidad listado es `CredentialIssued`
  (`bounded-contexts.md`, línea 66-67) — no hay evento de revocación.
- **Escenario de falla**: un estudiante es expulsado o reporta su insignia
  como perdida/robada; el personal administrativo revoca su `DASID`, pero no
  hay mecanismo definido para que esa revocación invalide la caché del
  backend de Identidad ni la caché local del Dispositivo DAS — el usuario
  revocado podría seguir registrando asistencia válida hasta que expire un
  TTL no especificado en ningún documento.
- **Severidad**: Alta
- **A quién se devuelve**: architecture-strategist

### [Retención / DRV-03] AMB-04 abierta sin política por defecto — riesgo de retención indefinida de facto
- **ID relacionado**: DRV-03, DRV-04 / DEC-0004, ADR-0004, AMB-04
- **Qué falta o es ambiguo**: tanto `data-model-conceptual.md` como
  ADR-0004 declaran honestamente que AMB-04 (alcance de la retención de 5
  años) sigue abierta para `documentoRef`/`fotoRef` de `SolicitudDeRegistro`,
  y que "no tienen, en este milestone, una política de retención definida
  más allá de 'más corta que 5 años'". El problema no es dejarla declarada
  como abierta (eso es correcto y transparente) — el problema es que **no
  hay ningún valor por defecto ni placeholder operativo**: en la práctica,
  "sin política definida" para un sistema real significa que esos documentos
  de identidad y fotos sensibles no tienen fecha de purga alguna, lo cual es
  el peor resultado posible para DRV-03 (confidencialidad), no un punto
  neutral a resolver después.
- **Escenario de falla**: el sistema entra en operación con esta ambigüedad
  sin resolver; por defecto de implementación, los documentos de identidad
  escaneados de miles de candidatos (aprobados y rechazados) se retienen
  indefinidamente porque nadie definió lo contrario.
- **Severidad**: Media
- **A quién se devuelve**: architecture-strategist

### [Síncrono/asíncrono NIS] Modelo de entrega del resultado del NIS (push/callback vs. polling) asumido sin declararlo como supuesto
- **ID relacionado**: DRV-02, ASM-01 / DEC-0002, ADR-0002
- **Qué falta o es ambiguo**: `sequence-registro-nis.mmd` dibuja
  `NIS->>ACL: Resultado de verificación (evento/callback)`, es decir, asume
  que el NIS **empuja** (push/webhook) el resultado hacia la Capa
  Anti-Corrupción de UPCA. A diferencia de AMB-05 (orden NIS→admin), que
  ADR-0002 declara explícitamente como supuesto de diseño con su propia
  sección "Riesgos que quedan abiertos", este supuesto sobre el modelo de
  entrega **no está declarado en ningún lado** como tal — ni en ASM-01
  (que solo dice que el NIS es "fuera de control operativo", sin hablar de
  su modelo de integración), ni en el contexto de ADR-0002, ni en NOTES.md.
  Es una decisión técnica de alto impacto (si el NIS es un servicio
  gubernamental real, es más plausible que solo exponga un API de consulta
  de estado por polling, no que soporte webhooks configurables por un
  tercero como UPCA) tratada como un hecho dado en el diagrama.
- **Escenario de falla**: si el NIS real no soporta callbacks entrantes, la
  Capa Anti-Corrupción necesitaría un mecanismo de polling con su propia
  política de intervalos (¿cada cuánto se consulta durante las 2h? ¿eso
  genera carga adicional sobre un tercero no negociable, ASM-01?) — un
  rediseño de esa parte de la Saga, no cubierto por ningún ADR actual.
- **Severidad**: Alta
- **A quién se devuelve**: architecture-strategist

### [Idempotencia] `POST /registrations` sin clave de idempotencia definida
- **ID relacionado**: REQ-02, DRV-02 / DEC-0002
- **Qué falta o es ambiguo**: a diferencia de `POST /attendance-events` (que
  sí define `claveIdempotencia` explícitamente), `bounded-contexts.md` y
  `data-model-conceptual.md` no definen ningún mecanismo de idempotencia
  para el envío inicial de autorregistro (`POST /registrations`, REQ-02).
- **Escenario de falla**: un candidato en un campus con conectividad
  inestable reenvía el formulario de autorregistro (timeout del cliente,
  doble tap en la app) y el sistema crea dos `SolicitudDeRegistro`
  independientes para la misma persona, cada una disparando su propia Saga y
  potencialmente su propia verificación NIS duplicada contra un tercero cuyo
  costo/SLA no se controla (ASM-01).
- **Severidad**: Media
- **A quién se devuelve**: architecture-strategist

### [RST-01 — sobreingeniería operativa / riesgo declarado sin mitigante de diseño] Complejidad plena de MSA+EDA para equipo de una persona
- **ID relacionado**: RST-01 (restricción, `discovery.md`) / DEC-0001, ADR-0001
- **Qué falta o es ambiguo**: ADR-0001 declara honestamente, en "Riesgos que
  quedan abiertos", que "la complejidad de operar múltiples servicios con un
  equipo de una sola persona es un riesgo real que `architecture-risk`
  (Milestone 3) debe evaluar con detalle — este ADR no lo resuelve, solo lo
  acepta". Eso es transparente, pero significa que Milestone 2 apuesta el
  100% de la complejidad operativa completa (5 microservicios, un motor de
  Saga, un broker de eventos, dos BFFs, un API Gateway, persistencia
  políglota de 5 almacenes distintos con retención por capas en uno de
  ellos) sin explorar ningún punto intermedio (ej. "MSA con menos servicios
  en una primera fase", "Notificaciones fusionado con Registro por bajo
  costo de desacople", "Saga sin motor de workflow dedicado, con estado
  persistido en el propio servicio de Registro"). `architecture-decision.md`
  solo compara dos alternativas (monolito completo vs. MSA+EDA completo), sin
  ningún punto intermedio, para una restricción no negociable (RST-01) que
  es, por definición, la más limitante de todo el proyecto.
- **Escenario de falla**: el estudiante-arquitecto (equipo de una persona)
  llega a Milestone 3/4 sin capacidad real de operar 5 servicios + broker +
  saga engine, y el gap entre "lo decidido" y "lo operable por una persona"
  recién se descubre en el registro de riesgos, cuando ya está comprometido
  el diseño completo de Milestone 2.
- **Severidad**: Alta
- **A quién se devuelve**: architecture-risk

### [Trazabilidad — capacidad no validada] SLA de ≤15s p95 sin cálculo de carga pico que lo sostenga
- **ID relacionado**: DRV-01, DRV-05 / DEC-0003, ADR-0003
- **Qué falta o es ambiguo**: ADR-0003 fija ≤15s p95 como SLA de proyección
  y lo declara explícitamente como decisión de diseño (correcto, resuelve
  AMB-01 con transparencia). Pero ningún documento de Milestone 2 estima si
  ese número es sostenible bajo el escenario de carga más exigente descrito
  en el propio enunciado: ~15.000 usuarios, ~3 clases/día, 20 campus, lo cual
  implica picos de escaneo concentrados en ventanas cortas (inicio/fin de
  clase) más que un flujo uniforme. El propio ADR-0003 reconoce el "problema
  de proyección asíncrona" y dice que el proyector "debe escalar
  horizontalmente para ponerse al día" ante contrapresión, pero no hay ni un
  cálculo aproximado (throughput esperado en el pico vs. capacidad asumida
  del proyector) que respalde que 15s p95 es alcanzable, no solo deseable.
- **Severidad**: Media
- **A quién se devuelve**: architecture-risk

### [Trazabilidad — menor] ASM-02, ASM-03 y ASM-05 sin `DEC` asociada
- **ID relacionado**: ASM-02, ASM-03, ASM-05
- **Qué falta o es ambiguo**: no es un "driver abandonado" en sentido
  estricto (la regla de esta auditoría aplica a filas `DRV`/`REQ`, y estas
  son `ASM`), pero vale señalarlo: ASM-02 (jurisdicción única de NIS) y
  ASM-03 (crecimiento sin nuevos campus) son contextuales y no requieren
  necesariamente una decisión arquitectónica dedicada. ASM-05, en cambio,
  declara una distinción funcional explícita ("la verificación digital del
  DAS ID desde la app es una capacidad distinta del escaneo físico de la
  Insignia") que no tiene una `DEC` ni una API claramente dedicada en
  `bounded-contexts.md` — el `GET /identity/{dasId}` documentado es una
  consulta de perfil genérica, no queda explícito si también sirve como la
  "verificación digital" que ASM-05 diferencia del escaneo de captura.
- **Severidad**: Baja
- **A quién se devuelve**: architecture-strategist

---

### Puntos verificados sin hallazgos

- **AMB-05 (orden NIS → aprobación administrativa) está declarada como
  supuesto explícito, no oculta**: ADR-0002, sección "Riesgos que quedan
  abiertos" ("La orden/dependencia estricta entre verificación NIS y
  aprobación administrativa sigue sin confirmarse... Este ADR asume...");
  reforzado en `design/diagrams/NOTES.md` punto 4 y en
  `design/traceability.md` (fila AMB-05: "**DEC-0002 asume explícitamente un
  orden secuencial NIS → aprobación administrativa** como supuesto de
  diseño"). Es exactamente el tratamiento correcto de una ambigüedad
  parcialmente resuelta: se declara, no se disfraza de hecho confirmado.

- **Criterio de separación de bounded contexts explicitado, no arbitrario**:
  `bounded-contexts.md` (tabla "Criterio de separación explícito") aplica
  las cuatro heurísticas de `we7.md` (tipo de dominio, velocidad de cambio,
  límite transaccional, perfil de carga) a cada uno de los cinco contextos
  de forma nombrada y justificada individualmente en cada sección — no hay
  separación por capa técnica ni por tabla, y el documento cita
  explícitamente esos anti-patrones para descartarlos.

- **Sin decisiones huérfanas ni drivers/requisitos abandonados en
  `traceability.md`**: cada `DEC-0001` a `DEC-0005` tiene su columna
  "DRV/REQ/ASM/AMB que motivan la decisión" poblada con filas que sí existen
  en la tabla principal, y cada `DRV-01..05` / `REQ-01..12` tiene al menos
  una `DEC` en su columna "DEC relacionadas" — no hay ninguna fila `DRV` o
  `REQ` de Milestone 1 sin cobertura en Milestone 2.

- **Ownership de datos entre Identidad y Registro/Verificación,
  explícitamente resuelto, no ambiguo**: `data-model-conceptual.md`
  distingue con claridad `datosPersonalesCandidato` (dentro de
  `SolicitudDeRegistro`, "no confiables hasta la aprobación") de `DASID`
  (dato confiable, creado únicamente a partir del evento
  `RegistrationApproved`), con una sola dirección de escritura por entidad y
  sin acceso directo cruzado — el caso que el propio checklist de este
  agente marca como "grave si es ambiguo" está aquí resuelto con una
  frontera de propiedad clara.

- **AMB-01 (near real-time) resuelta con número concreto, declarado como
  decisión de diseño, no como frase vacía**: ADR-0003 fija ≤15s p95 y aclara
  explícitamente que "es una cifra... del equipo de diseño, no un dato del
  enunciado". (Nota: la sostenibilidad de ese número bajo carga pico queda
  como hallazgo separado arriba — lo verificado aquí es solo que la cifra
  existe y está declarada como decisión, no la validación de capacidad.)

### Riesgo conocido, no resuelto (para seguimiento si se repiten hallazgos en próximas iteraciones)

Dado que esta es la Iteración 1, todos los hallazgos de arriba son nuevos y
no corresponde aún invocar la regla de límite de 3 iteraciones. Se deja
constancia de que los hallazgos de mayor severidad (circuit breaker no
especificado, idempotencia de respuesta del NIS, tope de reintentos,
ambigüedad de refresco de caché del dispositivo, revocación de credencial no
modelada, y modelo de entrega del NIS no declarado como supuesto) son, en su
mayoría, decisiones de diseño faltantes más que errores de estructura — se
devuelven a `architecture-strategist` para resolución antes de re-auditar.

---

## Iteración 2 — 2026-08-23 (corrida final del gate — cap de iteraciones = 2)

No es `SIN HALLAZGOS NUEVOS`. Auditoría de estructura primero
(`bounded-contexts.md`, `data-model-conceptual.md`, `traceability.md`, los
ADR-0006 a ADR-0012, todos los `.mmd` incluyendo el nuevo
`sequence-revocacion-credencial.mmd`, y `design/diagrams/NOTES.md` sección
"Iteración 2"), `architecture-decision.md` leído después. De los 6 hallazgos
de severidad Alta y 4 de severidad Media de la Iteración 1, **9 de los 10
quedan efectivamente resueltos con mecanismo concreto** (no solo
mencionados), y el ítem restante (RST-01) queda correctamente diferido a
`architecture-risk`/Milestone 3, tal como se pidió. Sin embargo, aparecen 2
hallazgos nuevos — uno de ellos es exactamente la ambigüedad que
`architecture-modeler` dejó señalada en `NOTES.md` para esta iteración y que
**no fue resuelta** por ningún ADR nuevo.

### [Ambigüedad señalada por architecture-modeler, confirmada NO resuelta] Mecanismo real de "delta" de credenciales entre Identidad y Captura (ADR-0008) sigue sin contrato de API concreto
- **ID relacionado**: DRV-03, DRV-05, REQ-06 / DEC-0008, ADR-0008
- **Qué falta o es ambiguo**: `design/diagrams/NOTES.md`, sección
  "Ambigüedad nueva detectada al diagramar en Iteración 2", señala
  explícitamente y por nombre esta pregunta para que `architecture-reviewer`
  la resuelva: ¿Identidad expone una API bulk/delta separada para el
  refresco de caché del dispositivo, o Captura reconstruye ese delta sobre
  la API de validación individual existente? Auditando ADR-0008 y
  `bounded-contexts.md` (línea 74-76, línea 208-211), la respuesta sigue sin
  existir: ambos documentos afirman que "internamente Captura obtiene el
  delta de Identidad y Credenciales (llamada backend-a-backend protegida por
  el mismo Circuit Breaker de ADR-0006)" **reutilizando por nombre** la
  misma API `GET /identity/{dasId}/credential/validate` que está descrita en
  todo el documento como una consulta **por `dasId` individual** — no admite
  parámetro `since=<timestamp>` ni devuelve un lote. No se creó ningún
  endpoint bulk nuevo en Identidad, ni se aclaró que Captura itera sobre una
  lista de `dasId` conocidos, ni se definió sobre qué conjunto de datos
  (¿eventos `CredentialIssued`/`CredentialRevoked` cacheados internamente
  por Captura? ¿una tabla derivada?) se construye realmente ese "delta". Los
  tres diagramas que tocan este flujo (`c4-container.mmd` línea 66,
  `c4-component.mmd`, `sequence-checkin.mmd` líneas 58-64) dibujan
  deliberadamente una relación síncrona genérica `captura → identidad` sin
  resolver la mecánica — el propio `architecture-modeler` documenta esa
  decisión de dibujo como una omisión intencional en espera de esta
  auditoría, no como un hallazgo resuelto.
- **Escenario de falla**: si se implementa literalmente "reutilizando la API
  individual", Captura tendría que iterar sobre todos los `dasId` conocidos
  de su campus en cada ciclo de sincronización (cada ~15 min, ADR-0008,
  potencialmente miles de llamadas síncronas por campus) para reconstruir
  algo parecido a un delta — contradice directamente la propia
  caracterización de ADR-0008 de que es "un endpoint de solo lectura,
  basado en delta, de baja frecuencia relativa frente al volumen de
  escritura", y satura exactamente el mismo Circuit Breaker (ADR-0006) que
  protege el camino crítico de escaneo en vivo, generando el propio
  incidente de "backend degradado" que ADR-0006 fue diseñado para mitigar.
  Si en cambio se asume una API bulk no documentada, su contrato (semántica
  de `since`, fuente de datos, paginación para campus grandes) sigue sin
  definir — no hay manera de verificar la factibilidad de la cifra "cada 15
  minutos" de ADR-0008 sin saber qué operación real se está ejecutando.
- **Severidad**: Alta
- **A quién se devuelve**: architecture-strategist

### [Riesgo operativo ya reconocido por su propio ADR, sin resolver en Iteración 2] Buffer local del Dispositivo DAS sin tamaño máximo ni política de purga
- **ID relacionado**: DRV-05, REQ-06, ASM-07 / DEC-0005, ADR-0005
- **Qué falta o es ambiguo**: ADR-0005 declara explícitamente, en su propia
  sección "Riesgos que quedan abiertos" (no modificada por ningún ADR
  posterior), que "el mecanismo técnico exacto del buffer (tamaño máximo,
  política de purga si el dispositivo permanece offline más allá de cierto
  tiempo) no está definido por el enunciado ni por los stakeholders
  simulados — queda como decisión de detalle para una iteración posterior,
  no cubierta por este ADR". De los 7 ADRs nuevos de Iteración 2
  (`ADR-0006` a `ADR-0012`), ninguno cubre este punto — no está en la lista
  de "5 cambios estructurales" que `NOTES.md` (Iteración 2) documenta como
  clasificados por `architecture-strategist`, ni aparece mencionado en
  ningún otro ADR o en `data-model-conceptual.md`.
- **Escenario de falla**: un dispositivo en un campus remoto (la restricción
  original es 20 campus en 10 ciudades, sin garantía documentada de
  infraestructura de red uniforme) pierde conectividad por un período
  extendido (días, no minutos). Sin tamaño máximo de buffer ni política de
  purga definida, el dispositivo podría (a) agotar su capacidad de
  almacenamiento local y empezar a descartar eventos silenciosamente al
  llegar al límite físico no gestionado — contradiciendo directamente la
  garantía funcional explícita de **ASM-07** ("la asistencia real no debe
  perderse"), exactamente el requisito que ADR-0005 fue creado para
  satisfacer — o (b) acumular datos sin límite, un supuesto operativo sobre
  capacidad de hardware no validado ni declarado en ningún documento.
- **Severidad**: Media
- **A quién se devuelve**: architecture-strategist

---

### Puntos verificados sin hallazgos (Iteración 2)

- **Circuit Breaker Captura → Identidad, completamente especificado, no solo
  citado**: `design/adr/adr-0006-circuit-breaker-captura-identidad.md`
  define la máquina de estados completa (Cerrado/Abierto/Semi-abierto),
  umbral de apertura (5 fallos/30s), comportamiento fail-open **acotado**
  (solo para `dasId` ya presentes en caché local y no revocados) vs.
  fail-closed (para `dasId` desconocidos), campo de auditoría
  `validacionCredencial` y cola de reconciliación — resuelve
  explícitamente las tres opciones (a/b/c) que la Iteración 1 dejó
  indefinidas. Confirmado también en `sequence-checkin.mmd` (rama "Circuit
  Breaker Abierto", líneas 23-36) y `c4-container.mmd` (línea 66).

- **Idempotencia y orden de resultados del NIS, con máquina de estados
  explícita**: `design/adr/adr-0007-integracion-nis-polling-idempotencia-reintentos.md`
  define `nisVerificationId` como clave de deduplicación (Idempotent
  Consumer), tres casos explícitos (primer resultado / duplicado reenviado /
  resultado contradictorio tardío enrutado a revisión manual vía DLQ) — el
  escenario exacto del hallazgo de Iteración 1 ("aprobado ya publicado,
  llega un rechazo tardío") ahora tiene una ruta definida (revisión manual,
  con posibilidad de revocar vía ADR-0009), no un comportamiento
  indeterminado. Confirmado en `sequence-registro-nis.mmd` líneas 34-42.

- **Tope de reintentos NIS con escalamiento definido**: ADR-0007 fija
  máximo 3 ciclos de timeout (hasta 6h de espera acumulada total, tope
  explícito), nuevo estado terminal `escalado_manual` y evento
  `NISVerificationEscalated` — cierra el hallazgo de "ciclo indefinido"
  con una cota numérica y una salida operativa clara. Confirmado en
  `data-model-conceptual.md` (campo `intentosNIS`) y
  `sequence-registro-nis.mmd` líneas 57-62.

- **Modelo de entrega del NIS declarado explícitamente como decisión (no
  supuesto implícito)**: ADR-0007 fija polling con backoff como mecanismo
  primario, con callback opcional no confiable por sí solo, y documenta
  por qué (`we2.md`, Webhook "evita el sondeo constante" — implica que sin
  confirmación de esa capacidad del NIS, el mecanismo base es polling).
  `sequence-registro-nis.mmd` fue redibujado (confirmado en `NOTES.md`,
  sección "Iteración 2") reemplazando la flecha `NIS->>ACL` de push por un
  `loop` de polling activo — el hallazgo original señalaba precisamente
  que ese dibujo estaba tratando un supuesto como un hecho dado; ya no es
  el caso.

- **Clave de idempotencia de asistencia con `direccion`, y origen del
  timestamp del SLA definido**: `design/adr/adr-0010-idempotencia-clave-asistencia.md`
  redefine la clave como `dispositivoId + direccion + timestampEscaneo` y
  distingue explícitamente `timestampEscaneo` (reloj del dispositivo) de
  `timestampRecibidoServidor` (nuevo campo, el que efectivamente mide el
  SLA de ADR-0003) — cierra ambas dimensiones del hallazgo original.
  Correctamente declara la sincronización NTP del dispositivo como
  "Supuesto fuera del curso — requiere validación con el instructor" en
  vez de asumirla en silencio, consistente con la regla de oro del
  proyecto.

- **Revocación de credencial completamente modelada — evento, API y
  propagación con TTL explícito**: `design/adr/adr-0009-revocacion-credencial.md`
  agrega `POST /identity/{dasId}/revoke`, el evento `CredentialRevoked` y
  define los tres consumidores (Captura invalida caché local activamente,
  el canal de sincronización del Dispositivo DAS lo incluye en el próximo
  delta, Notificaciones avisa al usuario), con un TTL explícito de 15
  minutos como cota del peor caso — declarado como trade-off aceptado entre
  DRV-03 y DRV-05, no como garantía absoluta. El nuevo diagrama
  `sequence-revocacion-credencial.mmd` documenta correctamente la dimensión
  temporal (propagación inmediata vía evento hacia Captura/Notificaciones,
  no inmediata hacia el Dispositivo DAS) que un diagrama de contenedores no
  podía comunicar — decisión de diagramación bien justificada en `NOTES.md`.

- **AMB-04 con valor por defecto operable, sin dejar de declarar la
  ambigüedad legal de fondo como abierta**: `design/adr/adr-0011-retencion-default-documentos-registro.md`
  fija 180 días (1 año adicional si hay sospecha de fraude) como
  placeholder de diseño explícitamente marcado "sujeto a validación con el
  instructor/negocio real" — resuelve exactamente el problema señalado en
  Iteración 1 (retención indefinida de facto por ausencia de valor por
  defecto) sin fingir que la ambigüedad legal está cerrada. `AMB-04` sigue
  correctamente marcada como abierta en `traceability.md`.

- **`POST /registrations` con idempotencia explícita**: `design/adr/adr-0012-idempotencia-post-registrations.md`
  agrega `Idempotency-Key` generado por el cliente como mecanismo primario
  y deduplicación por (`documentoRef` hash + correo) como resguardo
  secundario ante condición de carrera — mismo patrón que
  `POST /attendance-events`, aplicado de forma consistente. Confirmado en
  `sequence-registro-nis.mmd` líneas 14-19.

- **RST-01 correctamente diferido a Milestone 3, no perdido**:
  `design/traceability.md` (nota de Iteración 2, líneas 40-44) registra
  explícitamente "El hallazgo de RST-01... fue dirigido explícitamente por
  `architecture-reviewer` a `architecture-risk` (Milestone 3) y **no** se
  resuelve en esta iteración — queda anotado en
  `design/milestone-2/architecture-decision.md` ('Nota de Iteración 2')
  como pendiente". `architecture-decision.md` (líneas 38-46) reproduce esa
  misma anotación con el mismo lenguaje de "hallazgo deferido, no
  resuelto", y agrega honestamente que la complejidad operativa **se agrava
  levemente** en Iteración 2 por los nuevos mecanismos de resiliencia
  (líneas 169-174) — trazabilidad completa y consistente en ambos
  documentos, tal como exige el punto 4 de esta auditoría.

- **SLA ≤15s p95 ahora con estimación de carga pico que respalda su
  factibilidad**: el "Anexo — Estimación de carga pico" de
  `architecture-decision.md` (líneas 231-271) calcula ~50-55 eventos/seg en
  el pico instantáneo estimado (con supuestos de concentración
  explícitamente declarados como pesimistas/conservadores) contra una
  capacidad típica de "cientos a miles de eventos/seg" para un proyector
  CQRS de propósito general — cierra el hallazgo de Iteración 1 sin
  pretender que sea una validación operacional real (lo declara
  explícitamente como estimación, con nota de revisión para
  `architecture-risk` si aparece evidencia real distinta).

- **Sin decisiones huérfanas en `traceability.md`**: cada `DEC-0006` a
  `DEC-0012` tiene su columna "DRV/REQ/ASM/AMB que motivan la decisión"
  poblada con filas que existen en la tabla principal (DEC-0006: DRV-03,
  DRV-05, REQ-06; DEC-0007: DRV-02, REQ-03, REQ-04, ASM-01, ASM-15, AMB-05;
  DEC-0008: DRV-03, DRV-05, REQ-06; DEC-0009: DRV-03, REQ-09; DEC-0010:
  DRV-05, REQ-06, ASM-07, AMB-01, AMB-02; DEC-0011: DRV-03, DRV-04, AMB-04;
  DEC-0012: REQ-02, DRV-02, ASM-01) — ninguna es huérfana. La nota de
  Iteración 2 en `traceability.md` (líneas 32-44) documenta correctamente
  que solo se agregaron valores a celdas existentes, sin crear ni borrar
  filas `DRV`/`REQ`/`ASM`/`AMB`, conforme a la regla del archivo.

### Ítems de severidad Baja de Iteración 1 — sin cambios, no bloquean el gate

- **ASM-02, ASM-03, ASM-05 sin `DEC` asociada**: sigue exactamente igual que
  en Iteración 1 (`traceability.md`, columnas "DEC relacionadas" de esas
  tres filas siguen vacías); ningún ADR nuevo de Iteración 2 lo toca. Se
  mantiene como hallazgo de severidad Baja, no resuelto, aceptado como
  riesgo conocido de cierre de gate (ver más abajo) porque nunca fue
  bloqueante.

### Cierre de gate — Milestone 2 (cap de iteraciones = 2 alcanzado)

Esta es la corrida final del gate según el límite fijado para esta
auditoría. El gate se cierra en esta iteración, documentando explícitamente
qué queda resuelto y qué queda como riesgo conocido para que el usuario
decida si bloquea el avance a Milestone 3 o se acepta como limitación
conocida:

**Resuelto con verificación concreta (9 de 10 hallazgos de Iteración 1,
Alta+Media)**: Circuit Breaker Captura→Identidad, idempotencia/orden de
resultados del NIS, tope de reintentos NIS, clave de idempotencia de
asistencia (+ origen de timestamp del SLA), refresco de caché del
dispositivo — **solo en su dimensión "quién llama a quién"** (ver más
abajo), revocación de credencial, AMB-04 (valor por defecto), modelo de
entrega del NIS, idempotencia de `POST /registrations`, y SLA ≤15s p95
(cálculo de carga pico).

**Correctamente diferido, no perdido (1 de 10)**: RST-01 (complejidad
operacional MSA+EDA para equipo de una persona) — dirigido a
`architecture-risk`/Milestone 3 con trazabilidad completa en
`traceability.md` y `architecture-decision.md`. No es un hallazgo cerrado
en falso: está anotado como abierto en el lugar correcto.

**Riesgo conocido, no resuelto — Severidad Alta (bloqueante recomendado
antes de implementación, no antes de avanzar el gate de diseño)**: el
mecanismo real de "delta" de credenciales entre Identidad y Captura
(ADR-0008) sigue sin contrato de API concreto — la ambigüedad que
`architecture-modeler` señaló explícitamente en `NOTES.md` para esta
iteración no fue resuelta por ningún ADR nuevo, y la redacción actual de
ADR-0008/`bounded-contexts.md` contiene una contradicción funcional (una
API de consulta por `dasId` individual no puede, tal como está descrita,
producir un "delta desde un timestamp"). Se recomienda que
`architecture-strategist` produzca un ADR adicional (ej. `ADR-0013`) antes
de que este mecanismo se dé por diseñado en Milestone 3, porque de otro
modo, el "quién puede llamar a quién" (correctamente resuelto: Dispositivo
DAS → Captura, nunca directo a Identidad) queda sin sustento en el "cómo",
lo cual reabre exactamente el riesgo de carga/seguridad que ADR-0008 dice
haber cerrado.

**Riesgo conocido, no resuelto — Severidad Media**: política de tamaño
máximo y purga del buffer local del Dispositivo DAS ante desconexión
prolongada (ADR-0005) — declarada como abierta por su propio ADR desde
Iteración 1 y nunca retomada en los 7 ADRs de Iteración 2. Riesgo de
pérdida silenciosa de eventos que contradice ASM-07 en el caso extremo
(desconexión de varios días), no en el caso común.

**Riesgo conocido, no resuelto — Severidad Baja**: ASM-05 (distinción entre
verificación digital del DAS ID y escaneo físico) sigue sin `DEC` ni API
dedicada explícita.

Estos tres puntos quedan documentados aquí para que el usuario decida:
avanzar a Milestone 3 aceptándolos como limitaciones conocidas del diseño
(razonable para los de severidad Media/Baja, dado que ninguno invalida la
elección de estilo ni los bounded contexts), o solicitar una iteración
adicional fuera del ciclo estándar de este gate específicamente para el
hallazgo de severidad Alta (contrato de API del delta de ADR-0008), dado
que afecta directamente dos drivers de alta prioridad (DRV-03, DRV-05) y
tiene una contradicción técnica identificable, no solo una cifra de diseño
pendiente de validar.
