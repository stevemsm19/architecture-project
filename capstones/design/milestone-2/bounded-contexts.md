# Milestone 2 — Bounded Contexts (Alternativa recomendada: MSA + EDA)

> Desarrolla en profundidad la Alternativa 2 de
> `design/milestone-2/architecture-decision.md`. Cada bounded context se
> justifica con al menos una de las cuatro heurísticas de límites de servicio
> de `knowledge/we7.md` (Semana 7): (1) dominio núcleo / subdominio de
> soporte / subdominio genérico, (2) velocidad de cambio, (3) estructura de
> equipo (Ley de Conway), (4) límites transaccionales (consistencia inmediata
> vs. eventual). No incluye diagramas — eso corresponde a
> `architecture-modeler`.
>
> **Nota de Iteración 2 (post-revisión `architecture-reviewer`)**: este
> documento se actualizó para resolver hallazgos de
> `design/milestone-2/review-log.md` (Iteración 1). Los cambios están
> marcados inline con referencia al ADR correspondiente (`ADR-0006` a
> `ADR-0012`). No se modificó el criterio de separación de contextos ni las
> relaciones de Context Mapping ya aceptadas — solo se completaron
> componentes, APIs y eventos que estaban subespecificados.
>
> **Nota de iteración extra (post-revisión `architecture-reviewer`,
> Iteración 2, hallazgo de severidad Alta)**: `review-log.md` (Iteración 2)
> confirmó que ADR-0008/este documento reutilizaban, para el refresco de
> caché del Dispositivo DAS, una API de Identidad descrita en todo el
> documento como consulta **individual** por `dasId` — sin soportar
> `since=<timestamp>` ni lote. Esta iteración extra corrige exclusivamente
> esa sección (relación Captura ↔ Identidad para el refresco de caché del
> Dispositivo DAS); no se toca ninguna otra parte del diseño. Ver
> `design/adr/adr-0008-refresco-cache-dispositivo-via-captura.md` para el
> detalle completo del mecanismo corregido.
>
> **Nota de iteración adicional (post-revisión `architecture-reviewer`,
> Milestone 3, "Cierre de cascada DEC-0013", Hallazgo 2, severidad Alta)**:
> al redibujar los diagramas contra `DEC-0013` (Monolito Modular Fase 1), se
> eliminó el API Gateway y los BFF Web/Móvil de `c4-container.mmd` y
> `c4-component.mmd` por instrucción directa del orquestador —
> `design/diagrams/NOTES.md` ("Iteración DEC-0013 — Fase 1") ya señalaba esto
> explícitamente como "un hueco real del ADR en ese punto puntual", nunca
> ratificado por un ADR propio. La sección "Componentes transversales" (más
> abajo) no se había actualizado en consecuencia, quedando en contradicción
> directa con los diagramas vigentes, y dejando sin resolver dónde vive la
> autenticación de los dos clientes (App Móvil, Portal Web) en Fase 1 — un
> gap de seguridad real sobre `DRV-03`, no solo de redacción.
> `design/adr/adr-0014-middleware-autenticacion-monolito-fase1.md`
> (`DEC-0014`) resuelve esto explícitamente. Ver la sección "Componentes
> transversales" (con nota de vigencia por fase agregada) y la nueva sección
> "Nota de revisión — Milestone 3 (DEC-0014)" al final de este documento.

## Criterio de separación explícito (resumen)

Los cinco contextos no se separan por capa técnica ni por tabla de base de
datos (anti-patrones explícitos de `we7.md`: "límites dirigidos por datos",
"divisiones técnicas arbitrarias"). Se separan porque cada uno tiene una
combinación distinta de estas cuatro variables:

| Contexto | Tipo de dominio (heurística 1) | Velocidad de cambio (heurística 2) | Límite transaccional (heurística 4) | Perfil de carga |
|---|---|---|---|---|
| Identidad y Credenciales | Núcleo | Baja — el modelo de identidad es estable una vez definido | Consistencia inmediata dentro del agregado DASID/Credencial | Lectura frecuente (validación de credencial individual), escritura poco frecuente, más un consumo de baja frecuencia de su propio snapshot en lote por parte de Captura (arranque/reconciliación, ADR-0008) |
| Registro y Verificación | Núcleo, con una dependencia externa de alta volatilidad | Alta — cambia con el contrato del NIS (tercero, ASM-01) y con la política de aprobación administrativa | Proceso de larga duración con estados intermedios (RST-04); consistencia eventual entre pasos | Bajo volumen, alta latencia (hasta 2h, RST-02) |
| Captura de Asistencia | Núcleo | Baja-media — la lógica de captura es estable, pero el volumen crece con DRV-01 | Escritura atómica por evento; no depende de otros contextos para aceptar un evento | Muy alto volumen de escritura, near real-time (DRV-05); ahora incluye también lectura periódica de sincronización de caché de dispositivos, servida desde una proyección local por eventos, no por llamada síncrona (ADR-0008) |
| Reportes y Analítica | Subdominio de soporte | Media — cambia con las necesidades de reporting del personal administrativo | Consistencia eventual (proyección CQRS) | Alto volumen de lectura agregada, tolerante a mayor latencia en consultas históricas (ASM-13) |
| Notificaciones | Subdominio genérico | Baja | Sin estado transaccional propio relevante — solo registro operativo de envíos | Bajo-medio, dirigido por eventos de otros contextos |

Esta tabla es, en sí misma, la aplicación directa de las heurísticas de
`we7.md` ("Analizar la velocidad de cambio — dominios con diferentes tasas de
cambio a menudo se benefician de la separación"; "Evaluar límites
transaccionales — dónde la consistencia debe ser inmediata vs. eventual").

---

## 1. Identidad y Credenciales

**Responsabilidad**: es dueño del DAS ID (REQ-01) y de la emisión de la
Insignia DAS (REQ-05) una vez que Registro y Verificación confirma una
aprobación. Expone la validación de credencial que necesita Captura de
Asistencia en cada escaneo. **Desde Iteración 2, también es dueño del ciclo
de vida de revocación de la credencial (ADR-0009).** **Desde ADR-0014
(Fase 1), también es el emisor de la sesión/token de aplicación con la que
App Móvil y Portal Administrativo Web se autentican** — responsabilidad
distinta de, pero anclada en el mismo agregado que, la validación de
credencial física de Captura de Asistencia.

**Por qué es un contexto separado de Registro y Verificación**: aunque REQ-05
dice que la insignia se emite "tras el registro y la verificación NIS", el
propio `priorizacion.md` (fila REQ-05) señala el riesgo de que "se emita una
insignia sin verificación completa, o que quede en un estado ambiguo" si no
hay una frontera clara entre "solicitud en proceso" (con datos aún no
confiables — ver REQ-02, "riesgo medio-alto: manejo de datos sensibles en un
estado intermedio no confirmado") y "usuario identificado" (dato confiable,
de uso transversal). Mezclar ambos conceptos en un mismo agregado violaría el
principio de Agregados pequeños y de límite transaccional claro (`we7.md`,
"Diseño de agregados efectivos").

**Componentes principales**:
- Servicio de Identidad (API): gestiona el agregado `DASID` (entidad raíz) y
  el agregado `Credencial`.
- Almacén de credenciales con caché de validación de lectura rápida (para no
  depender de una llamada síncrona en cada escaneo de Captura de Asistencia
  — ver ADR-0005).
- Consumidor de eventos: reacciona a `RegistrationApproved` (publicado por
  Registro y Verificación) para crear el DASID/Credencial.
- **Exportador de snapshot en lote** *(nuevo, ADR-0008 corregido)*: sirve
  `GET /identity/credentials/snapshot`, de uso exclusivo y poco frecuente
  de Captura de Asistencia (arranque en frío/reconciliación de su
  proyección local), separado del camino de validación individual.
- **Emisor de sesión de aplicación** *(nuevo, ADR-0014, Fase 1)*: gestiona el
  ciclo de vida de la sesión/token de corta duración usada por App Móvil y
  Portal Web (`POST /identity/sessions`), consultado en cada solicitud por
  el **Middleware de Autenticación** (componente transversal, ver
  "Componentes transversales" más abajo) — no es un endpoint público de uso
  directo por los módulos de negocio, solo por ese middleware.

**APIs principales**:
- `GET /identity/{dasId}` — consulta de perfil (REQ-01, REQ-08).
- `GET /identity/{dasId}/credential/validate` — Open Host Service consumido
  por Captura de Asistencia en el camino síncrono de escaneo en vivo (con
  caché local en el borde, ver ADR-0005, y Circuit Breaker, ver ADR-0006).
  **Corrección de iteración extra (post-revisión Iteración 2, ver
  ADR-0008)**: esta API es de consulta **individual** por `dasId` y **ya no
  se reutiliza** para construir el delta de sincronización de caché del
  Dispositivo DAS — ese delta se construye ahora por proyección de eventos
  (ver contexto Captura de Asistencia, más abajo).
- **`GET /identity/credentials/snapshot?campusId=<id>&cursor=<token>`**
  *(nuevo, ADR-0008 corregido)* — exportación paginada en lote de
  credenciales vigentes de un campus. Uso exclusivo de Captura de
  Asistencia, solo para arranque en frío de su proyección local o
  reconciliación periódica de baja frecuencia (cifra de diseño: una vez al
  día, no en el ciclo de 15 minutos por dispositivo) — ver ADR-0008.
  Explícitamente separada de `GET /identity/{dasId}/credential/validate`.
- **`POST /identity/{dasId}/revoke`** *(nuevo, ADR-0009)* — uso exclusivo del
  personal administrativo (vía Middleware de Autenticación + enrutamiento
  del monolito en Fase 1, ver nota de revisión DEC-0014; vía BFF Web en
  Fase 2); transiciona `DASID.estado = revocado` con consistencia inmediata
  y dispara `CredentialRevoked`.
- **`POST /identity/sessions`** *(nuevo, ADR-0014)* — login de App Móvil/
  Portal Web; emite una sesión/token de corta duración anclada al agregado
  `Credencial`. Uso exclusivo del Middleware de Autenticación para validar
  solicitudes subsecuentes de ambos clientes; explícitamente distinta de
  `GET /identity/{dasId}/credential/validate` (validación de credencial
  física en el escaneo de Captura de Asistencia, ADR-0005/ADR-0006).

**Eventos publicados**: `CredentialIssued` — consumido por Notificaciones y
por Captura de Asistencia, que **desde la corrección de ADR-0008 (iteración
extra)** lo usa junto con `CredentialRevoked` para alimentar su proyección
local `CredencialesVigentesPorCampus`, fuente exclusiva del delta que
consulta el Dispositivo DAS; **`CredentialRevoked` *(nuevo, ADR-0009)*** —
consumido por Captura de Asistencia con **dos** efectos distintos sobre
**dos** estructuras de estado distintas: invalida su caché local de
"recientemente validadas" (ADR-0006, protege el camino síncrono de escaneo)
y actualiza la proyección `CredencialesVigentesPorCampus` (ADR-0008, alimenta
el delta del Dispositivo DAS); también consumido por Notificaciones (avisa
al usuario afectado).

**Relación de Context Mapping**: **Cliente-Proveedor** con Registro y
Verificación (Identidad es downstream: consume `RegistrationApproved` y no
puede alterar el contrato de ese evento unilateralmente); **Servicio Host
Abierto** hacia Captura de Asistencia para la validación síncrona
individual (`GET /identity/{dasId}/credential/validate`, camino de escaneo
en vivo) y para el snapshot en lote de baja frecuencia
(`GET /identity/credentials/snapshot`, arranque/reconciliación, ADR-0008);
y, **desde la corrección de ADR-0008, también Lenguaje Publicado** hacia
Captura de Asistencia para `CredentialIssued`/`CredentialRevoked` (Captura
los consume de forma asíncrona para su proyección local, sin negociar su
contrato). Tres relaciones distintas, cada una con su propio propósito y
frecuencia, ninguna sustituyendo a otra — el único consumidor directo de
cualquiera de las tres sigue siendo Captura, nunca el Dispositivo DAS
(confirmado en ADR-0008). **Desde ADR-0014**, además, es **Servicio Host
Abierto** hacia el Middleware de Autenticación transversal (`POST
/identity/sessions`), que no pertenece a ningún bounded context.

---

## 2. Registro y Verificación

**Responsabilidad**: autorregistro (REQ-02), orquestación de la verificación
NIS (REQ-03, DRV-02) y de la aprobación administrativa (REQ-04, RST-04),
incluyendo visibilidad de estado (ASM-08), motivo de rechazo (ASM-11) y
manejo de timeout del NIS (ASM-15).

**Por qué es un contexto separado**: es el contexto de mayor volatilidad del
sistema porque depende de un tercero fuera de control (ASM-01) cuyo contrato,
disponibilidad y tiempos de respuesta el equipo de UPCA no gobierna — la
heurística 2 (velocidad de cambio) de `we7.md` señala explícitamente que
"dominios con diferentes tasas de cambio a menudo se benefician de la
separación". Aislarlo evita que la inestabilidad de la integración NIS se
propague a Identidad (estable) o a Captura de Asistencia (crítica en
latencia, DRV-05).

**Componentes principales**:
- Orquestador de Saga (`UserRegistrationSaga`, ver ADR-0002 y **ADR-0007**):
  motor de flujo de trabajo que mantiene el estado del proceso
  (`pendiente_nis` → `nis_verificado` | `nis_rechazado` | `nis_timeout` →
  `pendiente_admin` → `aprobado` | `rechazado`, y **`escalado_manual`
  (nuevo, ADR-0007) tras agotar el tope de reintentos**), replicando
  explícitamente los estados que ASM-08 exige que el usuario pueda ver.
- Capa Anti-Corrupción (ACL) hacia el NIS: traduce el contrato externo del
  NIS al modelo interno de la Saga. **Desde ADR-0007, implementa polling con
  backoff como mecanismo primario de consulta de estado (no espera
  pasivamente un callback entrante no confirmado), con idempotencia de
  resultados entrantes basada en `nisVerificationId` y tope de 3 ciclos de
  timeout antes de escalar.**
- API de revisión administrativa: expone la información que ASM-10 exige
  (datos personales, documentos, calidad de documentos, evidencia de
  matrícula, situación administrativa) para que el personal apruebe o
  rechace.

**APIs principales**:
- `POST /registrations` — autorregistro (REQ-02). **Desde ADR-0012, requiere
  header `Idempotency-Key` generado por el cliente; reenvíos con la misma
  clave devuelven el `registroId` existente en vez de crear una nueva
  solicitud/Saga.**
- `GET /registrations/{id}/status` — estado visible al usuario (ASM-08),
  ahora incluye el estado `escalado_manual` (ADR-0007).
- `GET /registrations/pending` — cola de revisión para el personal
  administrativo, con visibilidad global multi-campus (ASM-14).
- `POST /registrations/{id}/admin-decision` — aprobar/rechazar con motivo
  (ASM-10, ASM-11). **Restringida al rol Personal Administrativo, aplicado
  por el Middleware de Autenticación transversal desde ADR-0014.**

**Eventos publicados**: `RegistrationSubmitted`, `NISVerificationCompleted`,
`NISVerificationTimedOut` (dispara alerta al personal administrativo y
notificación de demora al usuario, ASM-15), **`NISVerificationEscalated`
*(nuevo, ADR-0007)*** (tras el 3er timeout, dispara intervención manual),
`RegistrationApproved`, `RegistrationRejected` (con motivo, ASM-11).

**Relación de Context Mapping**: **Capa Anti-Corrupción** hacia el NIS
(sistema externo, sin control sobre su contrato — ASM-01; **modelo de
entrega especificado en ADR-0007: polling con backoff, callback opcional
como acelerador**); **Cliente-Proveedor** (upstream) hacia Identidad y
Credenciales y hacia Notificaciones.

---

## 3. Captura de Asistencia

**Responsabilidad**: registrar entrada/salida por usuario, día y ubicación
(REQ-06) desde los dispositivos DAS de los 20 campus, con tolerancia a
pérdida de conectividad (ASM-07) y latencia mínima (DRV-05). **Desde
Iteración 2, también es responsable de aislar el resto del sistema frente a
una caída del backend de Identidad y Credenciales (ADR-0006), y de
intermediar el refresco de la caché de credenciales del Dispositivo DAS
(ADR-0008).**

**Por qué es un contexto separado**: tiene el perfil de carga más distinto
de todo el sistema — escritura de muy alto volumen y muy baja latencia
tolerada, exactamente el escenario que `priorizacion.md` marca como "riesgo
alto: es el punto de mayor volumen de escritura del sistema... el que más
directamente presiona sobre DRV-01 y DRV-05 a la vez" (fila REQ-06). Ningún
otro contexto comparte ese perfil; forzarlo a compartir base de datos o
runtime con Reportes (lectura agregada) o Registro (bajo volumen, alta
latencia) sería el anti-patrón de "límites dirigidos por datos" en sentido
inverso: ignorar un límite transaccional y de carga real y evidente.

**Componentes principales**:
- API de ingesta de eventos de asistencia, con validación de idempotencia
  (clave = dispositivo + **dirección** + timestamp de escaneo — ver
  ADR-0010) para soportar reintentos y reenvíos desde el buffer offline (ver
  ADR-0005).
- Buffer/cola local en el dispositivo DAS (fuera del backend, pero parte del
  contrato de este contexto) para el caso de pérdida de conectividad
  (ASM-07).
- Almacén de eventos de asistencia (log append-only), fuente de verdad,
  particionado con estrategia de niveles caliente/tibio/frío para cumplir
  DRV-04 sin degradar DRV-05 (ver ADR-0004).
- Publicador de eventos hacia el broker, consumido por Reportes y Analítica.
- **Circuit Breaker sobre la llamada síncrona individual a Identidad y
  Credenciales** *(nuevo, ADR-0006)*, con una caché local propia de
  "credenciales recientemente validadas" (TTL 15 minutos, ver ADR-0009)
  usada para fail-open acotado cuando el circuito está Abierto, y una cola
  de reconciliación para revalidar los eventos aceptados en modo
  degradado. Protege exclusivamente el camino síncrono de escaneo en
  vivo — **no** el refresco de caché del Dispositivo DAS (ver corrección
  de ADR-0008, siguiente bullet).
- **Proyección local `CredencialesVigentesPorCampus`** *(nuevo, ADR-0008
  corregido — iteración extra)*: estructura de estado independiente de la
  caché de "recientemente validadas". Se construye consumiendo de forma
  asíncrona los eventos `CredentialIssued` y `CredentialRevoked` del
  broker (Idempotent Consumer, `we3.md`), y es la fuente **exclusiva** del
  delta que sirve
  `GET /attendance-devices/{dispositivoId}/credential-cache?since=<ts>`.
  Se reconstruye en frío o se reconcilia (cifra de diseño: una vez al día)
  contra `GET /identity/credentials/snapshot` de Identidad y Credenciales
  — nunca reutilizando la llamada síncrona individual de validación.
- **Consumidor de `CredentialIssued`/`CredentialRevoked`** *(ADR-0009,
  mecanismo corregido en ADR-0008)*: `CredentialRevoked` invalida
  activamente la entrada correspondiente en la caché de "recientemente
  validadas" (ADR-0006) **y**, junto con `CredentialIssued`, actualiza la
  proyección `CredencialesVigentesPorCampus` (ADR-0008) — dos efectos sobre
  dos estructuras de estado distintas a partir de los mismos eventos.

**APIs principales**:
- `POST /attendance-events` — captura online (REQ-06); idempotente (clave
  dispositivo+dirección+timestamp, ADR-0010).
- `POST /attendance-events/batch` — sincronización de eventos capturados
  offline y registro manual del profesor cuando el dispositivo no funciona
  (ASM-07).
- **`GET /attendance-devices/{dispositivoId}/credential-cache?since=<ts>`**
  *(nuevo, ADR-0008)* — endpoint de solo lectura, basado en delta, que el
  Dispositivo DAS consulta periódicamente (cada 15 min, cifra de diseño)
  para refrescar su caché local de credenciales válidas.
  **Corrección de iteración extra (post-revisión Iteración 2)**: se sirve
  enteramente desde la proyección local `CredencialesVigentesPorCampus`
  (ver componentes principales, arriba) — no realiza ninguna llamada
  síncrona a Identidad en esta ruta, y por lo tanto **no** comparte el
  Circuit Breaker de ADR-0006 con el camino de escaneo en vivo. El
  Dispositivo DAS **no** llama directamente a Identidad y Credenciales —
  ver ADR-0008.

**Eventos publicados**: `AttendanceRecorded` (consumido por Reportes y
Analítica vía CQRS), `AttendanceRecordedRetroactively` (marca explícita de
que el evento se registró fuera de línea y se sincronizó después — preserva
la distinción funcional pedida por ASM-07 sin ocultarla).

**Relación de Context Mapping**: **Conformista** respecto a Identidad y
Credenciales para la validación síncrona individual del camino de escaneo
en vivo (consume `GET /identity/{dasId}/credential/validate` tal como la
expone Identidad, sin negociar el contrato, con caché local en dos niveles
— Dispositivo, ADR-0005, y backend de Captura, ADR-0006 — y con Circuit
Breaker ante caída del servicio backend, ADR-0006); **desde la corrección
de ADR-0008, también Lenguaje Publicado** respecto a Identidad y
Credenciales (consumidor asíncrono de `CredentialIssued`/
`CredentialRevoked` para su proyección local) y consumidor de baja
frecuencia de su snapshot en lote (arranque en frío/reconciliación,
ADR-0008) — tres relaciones distintas con Identidad, cada una con su
propio propósito y frecuencia, ninguna reutilizada incorrectamente para
otra; y **Lenguaje Publicado** hacia Reportes y Analítica (el esquema del
evento `AttendanceRecorded` es el contrato estable que Reportes consume).
**El Dispositivo DAS solo se relaciona con Captura de Asistencia** (ingesta
de eventos y sincronización de caché de credenciales, ADR-0008) — nunca
directamente con Identidad y Credenciales.

---

## 4. Reportes y Analítica

**Responsabilidad**: portal administrativo con reportes/estadísticas
(REQ-07), consulta del propio historial por el usuario (REQ-08), con dos
perfiles de consulta distintos y explícitamente reconocidos por los
stakeholders simulados: operativo/reciente (ASM-12, "suficientemente rápido",
nunca un batch diario) e histórico (ASM-13, "aceptable que sea más lento").

**Por qué es un contexto separado**: es el lado de lectura de un CQRS cuyo
lado de escritura es Captura de Asistencia. `priorizacion.md` señala
explícitamente (fila REQ-07) el "riesgo de que las consultas analíticas
compitan por recursos con la captura de asistencia en tiempo real si no se
diferencian los patrones de acceso" — separar el contexto es la resolución
arquitectónica directa de ese riesgo identificado en Milestone 1.

**Componentes principales**:
- Proyector de eventos: consume `AttendanceRecorded` y mantiene un modelo de
  lectura optimizado (vistas materializadas por usuario/día/campus y
  agregados por campus/ciudad), cumpliendo la visibilidad global exigida por
  ASM-14 (el personal administrativo consulta todos los campus, no solo el
  propio).
- Ruta de consulta "reciente" (ventana operativa, ej. últimos 90 días) sobre
  almacén optimizado para lectura rápida.
- Ruta de consulta "histórica" (dentro de la ventana legal de 5 años,
  RST-03) sobre almacén de menor costo y mayor latencia aceptada (ASM-13).

**APIs principales**:
- `GET /reports/campus/{campusId}` y `GET /reports/global` — reportes con
  visibilidad multi-campus (ASM-14, REQ-07).
- `GET /attendance/{dasId}/recent` — consulta rápida del propio usuario
  (REQ-08, umbral operativo).
- `GET /attendance/{dasId}/history?from=&to=` — consulta histórica, SLA más
  laxo (ASM-13).

**Eventos consumidos**: `AttendanceRecorded`,
`AttendanceRecordedRetroactively` (de Captura de Asistencia).

**SLA de "near real-time" definido explícitamente (resuelve AMB-01 en su
dimensión numérica)**: dado que el enunciado no fija un umbral (AMB-01) pero
los stakeholders simulados sí dan una señal cualitativa consistente (ASM-06:
"algunos segundos... o incluso un poco más" es aceptable en la app; ASM-12:
"suficientemente rápido" en el portal, nunca un batch diario), este
milestone fija como decisión de diseño: proyección del evento
`AttendanceRecorded` al modelo de lectura en ≤ 15 segundos p95, medido desde
`timestampRecibidoServidor` (ADR-0010, no desde el reloj del dispositivo),
tanto para el portal administrativo como para la app del usuario. Esta cifra
es una decisión del equipo de diseño, no un dato del enunciado — se declara
así explícitamente y se registra en ADR-0003. **Ver
`design/milestone-2/architecture-decision.md`, anexo de Iteración 2, para
una estimación de carga pico que respalda la factibilidad de este SLA.**

**Relación de Context Mapping**: **Lenguaje Publicado** (consumidor) desde
Captura de Asistencia; **Separate Ways** respecto a Registro y Verificación
para el flujo operativo diario (el estado de solicitudes pendientes no forma
parte de las estadísticas de asistencia — son datos de naturaleza distinta),
aunque el portal administrativo sí necesita ambos vía el BFF (composición en
el borde, no en el dominio).

---

## 5. Notificaciones

**Responsabilidad**: comunicar al usuario y al personal administrativo los
eventos que ASM-08, ASM-11 y ASM-15 exigen como visibilidad explícita
(cambios de estado de la solicitud, motivo de rechazo, alerta de timeout del
NIS, **y desde Iteración 2, revocación de credencial — ADR-0009, y
escalamiento manual de verificación — ADR-0007**).

**Por qué es un contexto separado**: es un subdominio genérico (heurística 1
de `we7.md`) — enviar una notificación no requiere conocimiento del dominio
de asistencia ni del de identidad, solo un contrato de evento de entrada.
Mantenerlo separado evita duplicar lógica de envío de notificaciones dentro
de Registro y Verificación, Identidad y Credenciales, y Captura de
Asistencia.

**Componentes principales**: consumidor de eventos genérico + adaptadores de
canal (correo, push a la app móvil).

**Eventos consumidos**: `NISVerificationTimedOut`,
**`NISVerificationEscalated` *(nuevo, ADR-0007)***, `RegistrationApproved`,
`RegistrationRejected` (de Registro y Verificación); **`CredentialRevoked`
*(nuevo, ADR-0009)*** (de Identidad y Credenciales).

**Relación de Context Mapping**: **Lenguaje Publicado** (consumidor puro,
sin negociar el contrato de los eventos que consume).

---

## Componentes transversales (no pertenecen a un único bounded context)

> **Nota de vigencia por fase (`DEC-0013`/`DEC-0014`)**: la lista de abajo
> describe la topología de **Fase 2** (post-extracción, con al menos un
> bounded context ya desplegado como servicio independiente) — el estado en
> el que estas tres piezas (API Gateway, BFF Web, BFF Móvil) tienen una
> justificación arquitectónica activa según `we7.md`. En **Fase 1** (monolito
> modular, `DEC-0013`, vigente hoy), **el API Gateway y los dos BFF no
> existen como componentes desplegados**: no hay múltiples servicios de
> backend que enrutar ni componer, así que el propósito original de ambos
> patrones no aplica todavía. En su lugar, Fase 1 usa un **Middleware de
> Autenticación (Módulo de Seguridad transversal)** dentro del propio
> monolito — ver "Nota de revisión — Milestone 3 (DEC-0014)" al final de
> este documento para el detalle completo y la justificación en
> `knowledge/`. Se conserva el texto original de esta sección sin editar
> (además de esta nota) porque vuelve a aplicar tal cual en Fase 2,
> siguiendo el mismo criterio ya establecido por la "Nota de revisión —
> Milestone 3 (DEC-0013)" para las relaciones de Context Mapping.

- **API Gateway**: punto de entrada único, centraliza autenticación, SSL,
  rate limiting y enrutamiento (`we7.md`, "API Gateway").
- **Backend-for-Frontend (BFF) Web** (Portal Administrativo) y **BFF Móvil**
  (App de estudiantes/profesores): agregan datos de varios contextos según
  la necesidad de cada cliente — ej. el BFF Web compone `Registro y
  Verificación` (cola de revisión) + `Reportes y Analítica` (estadísticas)
  para el mismo portal, sin que esos dos contextos se acoplen entre sí
  directamente (`we7.md`, "Backend-para-Frontend"). El BFF Web también
  intermedia la nueva API `POST /identity/{dasId}/revoke` (ADR-0009) para el
  personal administrativo.
- **Broker de eventos**: columna vertebral de comunicación asíncrona entre
  contextos (Semana 3, Event Broker: push, múltiples suscriptores por
  evento). **Desde la corrección de ADR-0008, también es el canal por el
  que Captura de Asistencia mantiene su proyección local de credenciales,
  no solo el canal de Reportes y Analítica.**

## Resumen de relaciones (Context Mapping)

| Relación | Patrón (`we7.md`, Context Mapping) |
|---|---|
| Registro y Verificación → NIS (externo) | Capa Anti-Corrupción (ACL); modelo de entrega = polling con backoff (ADR-0007) |
| Registro y Verificación → Identidad y Credenciales | Cliente-Proveedor |
| Identidad y Credenciales → Captura de Asistencia | Servicio Host Abierto / Conformista (validación síncrona individual, con Circuit Breaker, ADR-0006) **+** Lenguaje Publicado (proyección de eventos `CredentialIssued`/`CredentialRevoked`, ADR-0008 corregido) **+** snapshot en lote de baja frecuencia (arranque/reconciliación, ADR-0008) — tres vías separadas, cada una con su propia frecuencia y propósito |
| Captura de Asistencia → Reportes y Analítica | Lenguaje Publicado |
| Registro y Verificación → Notificaciones | Lenguaje Publicado |
| Captura de Asistencia → Notificaciones | Lenguaje Publicado (opcional, eventos de bajo volumen) |
| Identidad y Credenciales → Notificaciones | Lenguaje Publicado *(nuevo, ADR-0009: `CredentialRevoked`)* |
| Reportes y Analítica ↔ Registro y Verificación | Separate Ways (a nivel de dominio; se componen solo en el borde vía BFF) |
| **Dispositivo DAS → Captura de Asistencia** | *(nuevo, explícito, ADR-0008)* único canal del dispositivo hacia el backend — ingesta de eventos y sincronización de caché de credenciales. **Nunca Dispositivo DAS → Identidad y Credenciales directamente.** |
| **App Móvil / Portal Web → Middleware de Autenticación → Identidad y Credenciales** | *(nuevo, ADR-0014, Fase 1)* Servicio Host Abierto de Identidad hacia el Middleware de Autenticación transversal (`POST /identity/sessions`); el middleware no es un bounded context, ver "Componentes transversales" y "Nota de revisión — Milestone 3 (DEC-0014)" |

## Nota de revisión — Milestone 3 (DEC-0013)

`design/adr/adr-0013-monolito-modular-fase1-extraccion-selectiva.md`
(`DEC-0013`) reemplaza el alcance de "día 1" de `DEC-0001`, **no** el
criterio de separación DDD de este documento. Los cinco bounded contexts
descritos arriba (Identidad y Credenciales, Registro y Verificación, Captura
de Asistencia, Reportes y Analítica, Notificaciones), con las cuatro
heurísticas de `knowledge/we7.md` que los justifican, siguen vigentes sin
cambios como límites **lógicos** del dominio.

Lo que cambia es exclusivamente el mapeo físico de despliegue:

- **Antes (DEC-0001, Fase 1 original de este documento)**: 1 microservicio
  desplegado de forma independiente por bounded context (5 desplegables, 5
  pipelines, comunicados vía broker de eventos y llamadas de red entre
  servicios).
- **Ahora (DEC-0013, Fase 1 vigente)**: **1 módulo por bounded context,
  dentro de 1 único desplegable**, con 1 solo pipeline de CI/CD y datos
  aislados a nivel de esquema/namespace lógico (no base de datos física
  separada — ver nota equivalente en `data-model-conceptual.md`). Las
  relaciones de Context Mapping descritas arriba (Cliente-Proveedor,
  Servicio Host Abierto/Conformista, Capa Anti-Corrupción, Lenguaje
  Publicado, Separate Ways) se mantienen como contratos de interfaz entre
  módulos internos, en vez de llamadas de red entre servicios — el
  propósito de cada relación (quién puede depender de quién, y con qué
  grado de acoplamiento) no cambia, solo el medio de transporte.
- **Fase 2 (extracción selectiva, por los triggers verificables ya
  definidos en ADR-0013)**: cuando se cumpla al menos uno de los triggers de
  Captura de Asistencia (campus activos > 10, degradación de latencia
  medida en dos ventanas pico consecutivas, o madurez de pipeline probada) o
  el trigger condicional de Registro y Verificación (inestabilidad de
  release atribuible a la volatilidad del NIS), ese módulo se extrae a
  servicio independiente vía Strangler Pattern (`knowledge/we6.md`),
  momento en el que las relaciones de Context Mapping señaladas arriba
  vuelven a implementarse como comunicación de red real (broker de eventos,
  llamadas HTTP entre servicios) exactamente como estaban descritas en la
  versión original de este documento.

No se reescribe el criterio de separación DDD ni ninguna otra sección de
este documento — esta nota deja constancia del cambio de topología física
sin alterar el modelo de dominio ya aceptado.

## Nota de revisión — Milestone 3 (DEC-0014) — Autenticación y componentes transversales por fase

`design/adr/adr-0014-middleware-autenticacion-monolito-fase1.md` (`DEC-0014`)
resuelve el segundo hallazgo bloqueante de
`design/milestone-3/review-log.md` ("Cierre de cascada DEC-0013"): la
eliminación de API Gateway y BFF Web/Móvil de los diagramas de Fase 1
(`c4-container.mmd`, `c4-component.mmd`) fue correcta en el resultado, pero
nunca fue ratificada por una decisión de arquitectura propia — quedó como
instrucción de dibujo sin ADR, contradiciendo a la sección "Componentes
transversales" (arriba, antes de esta nota) y dejando sin resolver dónde
vive la autenticación de los dos clientes (App Móvil, Portal Web) en Fase 1.

**Decisión (ver `ADR-0014` para el detalle y las alternativas descartadas)**:
en Fase 1, **no** existe API Gateway ni BFF Web/Móvil como componentes
desplegados — se confirma, con fundamento propio, la lectura que ya
adoptaban los diagramas. En su lugar, la autenticación, autorización y las
demás preocupaciones transversales de seguridad se resuelven con un
**Middleware de Autenticación (Módulo de Seguridad transversal)** dentro del
propio monolito:

- **Qué es**: un componente técnico transversal — no un bounded context, no
  posee datos de dominio propios — que intercepta **toda** solicitud
  entrante de App Móvil y Portal Administrativo Web, antes de que llegue a
  cualquiera de los 5 módulos internos, y valida la sesión/token del
  usuario contra el agregado `Credencial` de **Identidad y Credenciales**
  (ver sección 1, arriba, "Emisor de sesión de aplicación" y `POST
  /identity/sessions`, ambos agregados por esta misma decisión). Rechaza
  (401/403) antes de enrutar si la sesión no es válida o si el rol no tiene
  permiso sobre el recurso solicitado (ej. `POST
  /registrations/{id}/admin-decision`, `POST /identity/{dasId}/revoke`,
  ambos restringidos al rol Personal Administrativo).
- **Por qué no es una violación de "un solo desplegable" (`DEC-0013`)**: no
  agrega un segundo proceso, un segundo pipeline de CI/CD ni una segunda
  pieza operable — vive dentro del mismo binario/desplegable que los 5
  módulos, como una capa que intercepta antes de enrutar. Aplica
  textualmente el mecanismo que `knowledge/we6.md` recomienda para
  preocupaciones transversales (seguridad incluida) en aplicaciones
  **monolíticas/en capas** ("Programación Orientada a Aspectos, AOP"), en
  contraste explícito, en la misma fuente, con el "patrón sidecar /
  servicios centralizados... para sistemas distribuidos" — que es
  exactamente lo que un API Gateway/BFF sería en Fase 1: infraestructura
  distribuida adicional que `ADR-0013` decidió posponer hasta que un
  trigger la justifique. `knowledge/we1.md` respalda además el concepto de
  un módulo transversal dedicado a seguridad ("Security Module: transversal,
  estandarizado").
- **SSL/TLS y rate limiting**: en Fase 1 se resuelven a nivel de
  infraestructura de despliegue (terminación TLS y balanceo de carga frente
  al único desplegable), no como responsabilidad de un componente de
  aplicación nuevo — es infraestructura operativa estándar que cualquier
  desplegable HTTPS necesita, independientemente del estilo arquitectónico.
- **Fase 2**: cuando se cumpla un trigger de extracción de `ADR-0013` y
  reaparezca una topología distribuida real, el API Gateway y los BFF
  Web/Móvil de la sección "Componentes transversales" (arriba) vuelven a
  aplicar tal cual están descritos, y la lógica de validación de
  sesión/rol del Middleware de Autenticación se **relocaliza** dentro del
  Gateway (mismo contrato lógico — qué se valida y contra qué agregado —,
  distinto lugar físico de ejecución), consistente con el Strangler Pattern
  que ya gobierna el resto de la migración de Fase 1 a Fase 2.

No se reabre ningún otro punto de este documento: los cinco bounded
contexts, sus heurísticas de separación DDD y las relaciones de Context
Mapping descritas arriba permanecen exactamente como estaban.

**Impacto sobre diagramas (para `architecture-modeler`)**: `c4-container.mmd`
y `c4-component.mmd` (Fase 1) ya representan correctamente la ausencia de
Gateway/BFF, pero **no** representan todavía el Middleware de Autenticación
como componente explícito ni la nueva relación `App Móvil / Portal Web →
Middleware de Autenticación → módulos` — hoy muestran a los clientes
llamando directamente a los módulos, sin ninguna capa de autenticación
visible. Requiere una pasada de redibujo acotada a este punto.
