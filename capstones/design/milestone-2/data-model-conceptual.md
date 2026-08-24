# Milestone 2 — Modelo de Datos Conceptual (Alternativa recomendada: MSA + EDA)

> Entidades y su dueño (bounded context), no el modelo físico/de tablas. Cada
> entidad usa Base de Datos por Servicio (`knowledge/index.md`, Semanas
> 5-6-7): el dueño es el único que escribe directamente sobre su propio
> almacén; el resto del sistema accede vía API o eventos, nunca por acceso
> directo a datos ajenos (anti-patrón "base de datos compartida",
> `we6.md`/`we7.md`).
>
> **Nota de Iteración 2 (post-revisión `architecture-reviewer`)**: se
> agregaron/precisaron campos para resolver hallazgos de
> `design/milestone-2/review-log.md` (Iteración 1). Los cambios están
> marcados inline con referencia al ADR correspondiente (`ADR-0006` a
> `ADR-0012`). La propiedad de datos (ownership) no cambió.
>
> **Nota de iteración extra (post-revisión `architecture-reviewer`,
> Iteración 2, hallazgo de severidad Alta sobre ADR-0008)**: se agrega la
> proyección local `CredencialesVigentesPorCampus` (Captura de Asistencia)
> a la sección de ese contexto y a la tabla de ownership — es una
> estructura de estado nueva, distinta de la caché "recientemente
> validadas" ya existente, introducida por el mecanismo corregido de
> ADR-0008. No se modifica ninguna otra entidad de este documento.

## Contexto: Identidad y Credenciales

**Agregado `DASID`** (entidad raíz)
- `dasId` (identificador único, REQ-01)
- `nombre`, `fechaNacimiento`, `correo`, `telefono`, `sexo`, `función`
  (estudiante | profesor) — datos personales de REQ-01
- `estado` (activo | revocado) — **desde ADR-0009, la transición a
  `revocado` es disparada exclusivamente por `POST
  /identity/{dasId}/revoke` y publica el evento `CredentialRevoked`; no
  existe ninguna otra vía de escritura de este campo.**
- `motivoRevocacion`, `revocadoEn` *(nuevos, ADR-0009, nullable, solo
  presentes si `estado = revocado`)*.
- Dueño: Identidad y Credenciales. Origen: creado a partir del evento
  `RegistrationApproved` publicado por Registro y Verificación — Identidad
  **no** captura estos datos de forma primaria, los recibe ya aprobados.

**Entidad `Credencial` (Insignia DAS)** (dentro del agregado `DASID`)
- `credencialId`, `dasId` (referencia), `formato` (física | móvil),
  `fotoRef`, `emitidaEn`
- Dueño: Identidad y Credenciales.
- Nota de trazabilidad (**AMB-03**, no resuelta): este modelo asume que
  "Insignia DAS" y "tarjeta DAS" son el mismo artefacto conceptual
  (`Credencial`), con `formato` como atributo distintivo, no como entidad
  separada. Si `AMB-03` se resolviera en sentido contrario (artefactos
  realmente distintos), este agregado debería dividirse — se declara aquí
  como supuesto de modelado, no como hecho confirmado por el enunciado.

## Contexto: Registro y Verificación

**Agregado `SolicitudDeRegistro`** (entidad raíz)
- `registroId`
- **`idempotencyKey`** *(nuevo, ADR-0012, generado por el cliente en
  `POST /registrations`)* — usado para deduplicar reenvíos del mismo
  intento de autorregistro antes de crear una nueva Saga.
- `datosPersonalesCandidato` (mismos campos que `DASID`, pero **no
  confiables hasta la aprobación** — ver REQ-02, "estado explícito de
  usuario no verificado")
- `documentoRef`, `fotoRef` (datos sensibles temporales — ver DRV-03).
  **Política de retención por defecto (ADR-0011, placeholder de diseño
  sujeto a validación con el instructor): 180 días tras alcanzar un estado
  terminal (`aprobado`/`rechazado`); 1 año adicional si la solicitud fue
  marcada por el personal administrativo como sospecha de fraude o
  irregularidad documental.** AMB-04 permanece formalmente abierta (el
  alcance legal exacto de la retención de 5 años no está confirmado para
  estos campos); ADR-0011 solo fija un valor operable transitorio, no una
  resolución definitiva de la ambigüedad.
- `estado` (pendiente_nis | nis_verificado | nis_rechazado | nis_timeout |
  pendiente_admin | aprobado | rechazado | **`escalado_manual`** *(nuevo,
  ADR-0007, terminal — tras agotar el tope de 3 ciclos de timeout del NIS)*)
  — refleja directamente los estados que **ASM-08** exige que el usuario
  pueda ver.
- `resultadoVerificacionNIS` (referencia externa/opaca, tratada vía ACL —
  ver `bounded-contexts.md`).
- **`nisVerificationId`** *(nuevo, ADR-0007)* — identificador de
  verificación devuelto por el NIS la primera vez que se recibe un
  resultado; usado para detectar duplicados/resultados contradictorios
  tardíos (Idempotent Consumer).
- **`intentosNIS`** *(nuevo, ADR-0007, contador)* — número de ciclos de
  timeout/reintento consumidos (máximo 3 antes de transicionar a
  `escalado_manual`).
- `motivoRechazo` (nullable) — exigido por **ASM-11**.
- `revisorAdministrativoId` (nullable, quién aprobó/rechazó).
- `timestamps` (creado, verificadoNIS, decididoAdmin).
- Dueño: Registro y Verificación. Es el único contexto que puede escribir
  sobre este agregado; una vez `aprobado`, publica `RegistrationApproved` y
  dispara la creación del `DASID` correspondiente en otro contexto — no hay
  escritura directa cruzada.

## Contexto: Captura de Asistencia

**Entidad `EventoDeAsistencia`** (log append-only, sin agregado mutable —
cada evento es inmutable una vez escrito)
- `eventoId`
- `dasId` (referencia externa, validada vía `Identidad y Credenciales` en el
  momento del escaneo, con caché local — ver ADR-0005 — y Circuit Breaker
  con fail-open acotado ante caída del backend — ver ADR-0006)
- `campusId`, `ciudadId`
- `dispositivoId`
- `timestampEscaneo` — **origen: reloj del dispositivo (ADR-0010); la
  sincronización de reloj (NTP o equivalente) es un supuesto operativo
  fuera del alcance curado del curso, marcado explícitamente como "Supuesto
  fuera del curso — requiere validación con el instructor" (ADR-0010).**
- **`timestampRecibidoServidor`** *(nuevo, ADR-0010)* — asignado por
  Captura de Asistencia al recibir el evento (online o en sincronización de
  lote offline); **es el timestamp que efectivamente mide el SLA de ≤15s
  p95 de ADR-0003**, no `timestampEscaneo`.
- `direccion` (entrada | salida)
- `modoCaptura` (online | offline_retroactivo) — preserva la distinción
  funcional pedida por **ASM-07**.
- **`validacionCredencial`** *(nuevo, ADR-0006, enum: `directa` |
  `cache_degradada`)* — marca de auditoría: `cache_degradada` indica que el
  evento se aceptó con el Circuit Breaker Abierto, usando la caché local de
  "recientemente validadas" en vez de una llamada síncrona confirmada;
  estos eventos se encolan para reconciliación posterior (ADR-0006).
- `claveIdempotencia` — **redefinida en ADR-0010: `dispositivoId +
  direccion + timestampEscaneo`** (se agrega `direccion`, que antes no
  formaba parte de la clave y podía causar pérdida silenciosa de un evento
  de entrada o salida simultáneos con el mismo timestamp).
- Dueño: Captura de Asistencia. Es la fuente de verdad de REQ-06.
- **Estrategia de retención por capas** (ver ADR-0004, resuelve **DRV-04**
  sin degradar **DRV-05**): mismos datos, tres niveles de almacenamiento
  según antigüedad — caliente (reciente, optimizado para escritura y
  consulta rápida), tibio, frío (hasta cumplir el mínimo legal de 5 años,
  RST-03) — no se modelan como entidades distintas, sino como una política
  operativa sobre la misma entidad conceptual.

**Proyección local `CredencialesVigentesPorCampus`** *(nuevo, ADR-0008
corregido — iteración extra)* — estructura de estado derivada, no fuente de
verdad
- `dasId`, `campusId`, `estado` (activo | revocado), `actualizadaEn`
- Construida de forma asíncrona consumiendo `CredentialIssued` y
  `CredentialRevoked` (publicados por Identidad y Credenciales), con
  reconciliación de baja frecuencia contra
  `GET /identity/credentials/snapshot` (arranque en frío o corrección de
  desvío) — nunca reconstruida iterando la API de validación individual.
- **Distinta de la caché "recientemente validadas" de ADR-0006** (ver fila
  siguiente en la tabla de ownership): esta proyección cubre todas las
  credenciales vigentes de un campus (fuente del delta que consulta el
  Dispositivo DAS, ADR-0008); la otra caché cubre solo las credenciales
  validadas recientemente en el camino síncrono de escaneo (fuente del
  fail-open acotado, ADR-0006). Ambas se actualizan a partir de los mismos
  eventos (`CredentialIssued`/`CredentialRevoked`), pero tienen alcance,
  propósito y ciclo de vida distintos — no deben confundirse ni fusionarse.
- Dueño: Captura de Asistencia. Copia derivada, no fuente de verdad — la
  fuente de verdad de `estado` sigue siendo `DASID.estado` en Identidad y
  Credenciales.

## Contexto: Reportes y Analítica

> Estas entidades son **proyecciones derivadas** (CQRS, lado de lectura),
> no fuente de verdad. Se reconstruyen a partir de los eventos publicados
> por Captura de Asistencia; su dueño solo controla el modelo de lectura,
> nunca los datos de origen.

**Vista `ResumenAsistenciaDiaria`** (por `dasId` + fecha + `campusId`)
- Derivada de `EventoDeAsistencia` (entrada/salida agregados por día)
- Consumida por REQ-08 (consulta del propio usuario) vía ruta "reciente"

**Vista `EstadisticasPorCampus`** / **`EstadisticasGlobalUPCA`**
- Agregados por campus y por red completa — la vista global existe
  específicamente porque **ASM-14** confirma que el personal administrativo
  necesita visibilidad sobre todos los campus, no solo el propio
- Consumida por REQ-07 (portal administrativo)

**Vista `HistoricoAsistencia`** (ventana de hasta 5 años, RST-03)
- Misma fuente de eventos, pero servida desde el almacén de menor costo /
  mayor latencia aceptada (**ASM-13**)
- Dueño: Reportes y Analítica (solo del modelo de lectura, no del dato
  origen)

## Contexto: Notificaciones

**Entidad `RegistroDeNotificacion`**
- `notificacionId`, `dasId` (destinatario), `tipo` (estado_solicitud |
  rechazo | alerta_timeout_nis | **escalamiento_manual** *(nuevo,
  ADR-0007)* | **revocacion_credencial** *(nuevo, ADR-0009)*), `canal`,
  `enviadaEn`, `estado`
- Dueño: Notificaciones. Datos operativos, sin relación de propiedad sobre
  identidad o asistencia — solo referencia al `dasId` como destinatario.

## Resumen de propiedad de datos (ownership)

| Entidad / Vista | Dueño (bounded context) | Tipo |
|---|---|---|
| `DASID`, `Credencial` | Identidad y Credenciales | Fuente de verdad |
| `SolicitudDeRegistro` | Registro y Verificación | Fuente de verdad (proceso de larga duración) |
| `EventoDeAsistencia` | Captura de Asistencia | Fuente de verdad (log append-only) |
| `ResumenAsistenciaDiaria`, `EstadisticasPorCampus`, `EstadisticasGlobalUPCA`, `HistoricoAsistencia` | Reportes y Analítica | Proyección derivada (CQRS) |
| `RegistroDeNotificacion` | Notificaciones | Dato operativo, sin relación de propiedad de dominio |
| Caché "recientemente validadas" (Captura), TTL 15 min *(ADR-0006/ADR-0009)* | Captura de Asistencia | Copia derivada, no fuente de verdad — invalidada activamente por `CredentialRevoked`; alimenta el fail-open acotado del camino síncrono de escaneo |
| **`CredencialesVigentesPorCampus` (Captura)** *(nuevo, ADR-0008 corregido — iteración extra)* | Captura de Asistencia | Copia derivada, no fuente de verdad — proyección por eventos (`CredentialIssued`/`CredentialRevoked`) + reconciliación de baja frecuencia; alimenta el delta que consulta el Dispositivo DAS. Distinta de la caché anterior (alcance, propósito y ciclo de vida propios, ver contexto Captura de Asistencia) |

## Nota sobre ambigüedades no resueltas que afectan este modelo

- **AMB-03** (Insignia vs. tarjeta DAS): ver nota en `Credencial` arriba —
  este modelo asume un único artefacto con un atributo `formato`.
- **AMB-04** (alcance de la retención de 5 años): este modelo aplica la
  retención por capas (ADR-0004) exclusivamente a `EventoDeAsistencia`
  (consistente con **ASM-04**); los `documentoRef`/`fotoRef` de
  `SolicitudDeRegistro` ahora tienen un **valor por defecto operable**
  (180 días / 1 año en caso de sospecha de fraude, ADR-0011), explícitamente
  marcado como placeholder de diseño — la ambigüedad legal de fondo (AMB-04)
  sigue formalmente abierta y sujeta a validación con el instructor/negocio
  real.
- **AMB-07** (qué constituye un "evento" de asistencia): este modelo asume
  que `EventoDeAsistencia` es un registro independiente por escaneo
  (entrada o salida), no un registro único diario agregado por campus — lo
  cual es compatible con el interés del Profesor simulado en ver "cuántos
  estudiantes están presentes en una clase" (señal citada en `discovery.md`
  bajo AMB-07), pero **no está confirmado por el enunciado** que esa deba
  ser la granularidad exacta (por clase/evento específico vs. por
  entrada/salida de campus). Se declara explícitamente como supuesto de
  modelado.
- **Sincronización de reloj del Dispositivo DAS** *(nuevo, ADR-0010)*: el
  origen de `timestampEscaneo` (reloj local del dispositivo) asume una
  precondición operativa de sincronización (NTP o equivalente) que el
  material del curso no cubre — declarado explícitamente como **"Supuesto
  fuera del curso — requiere validación con el instructor"**, no como
  garantía de este diseño.
- **Consistencia de `CredencialesVigentesPorCampus`** *(nuevo, ADR-0008
  corregido)*: depende de la entrega confiable de eventos del broker; un
  evento perdido o muy retrasado deja la proyección desactualizada hasta la
  siguiente reconciliación diaria contra el snapshot de Identidad — mismo
  riesgo residual ya aceptado para el proyector de Reportes y Analítica
  (ADR-0003), ahora extendido explícitamente a este segundo proyector.

## Nota de revisión — Milestone 3 (DEC-0013)

`design/adr/adr-0013-monolito-modular-fase1-extraccion-selectiva.md`
(`DEC-0013`) no cambia el ownership lógico de ninguna entidad descrita en
este documento: cada entidad/vista sigue perteneciendo exactamente al mismo
bounded context (Identidad y Credenciales sigue siendo dueño de
`DASID`/`Credencial`, Registro y Verificación de `SolicitudDeRegistro`,
Captura de Asistencia de `EventoDeAsistencia` y sus proyecciones, Reportes y
Analítica de sus vistas derivadas, Notificaciones de `RegistroDeNotificacion`
— ver "Resumen de propiedad de datos" arriba, sin ninguna fila modificada).

Lo que cambia es la realización física del principio "Base de Datos por
Servicio" (`knowledge/index.md`, Semanas 5-6-7) citado en el encabezado de
este documento:

- **Antes (DEC-0001)**: cada bounded context con su propio almacén de datos
  físicamente independiente (potencialmente persistencia políglota,
  tecnologías distintas por contexto).
- **Ahora (DEC-0013, Fase 1)**: un único almacén de datos primario compartido
  por todo el desplegable, con cada bounded context aislado a nivel de
  **esquema/namespace lógico** dentro de ese almacén — ningún módulo escribe
  directamente sobre las tablas de otro módulo; el acceso cruzado sigue
  realizándose exclusivamente vía las APIs/eventos ya descritos en
  `bounded-contexts.md`, ahora como llamadas en proceso en vez de llamadas
  de red. Esto preserva la regla de "el dueño es el único que escribe
  directamente sobre su propio almacén" citada en el encabezado de este
  documento; solo cambia que "almacén" pasa a significar "esquema lógico"
  en vez de "base de datos física" durante la Fase 1.
- **Fase 2**: cuando un módulo se extraiga por Strangler Pattern (triggers
  de ADR-0013), su esquema lógico migra a una base de datos física propia,
  recuperando el aislamiento físico completo de `DEC-0001` únicamente para
  ese módulo extraído.

Esta nota no reescribe ninguna entidad, campo, evento ni la tabla de
ownership de arriba — el modelo de entidades y su dueño lógico permanecen
exactamente como fueron aceptados.
