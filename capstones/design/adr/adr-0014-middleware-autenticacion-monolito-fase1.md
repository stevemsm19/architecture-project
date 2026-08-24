# ADR-0014: Middleware de Autenticación Transversal dentro del Monolito — Ratifica "Sin API Gateway/BFF en Fase 1" y Cierra el Hueco de Seguridad Dejado por ADR-0013

## Estado
Aceptado

## Contexto

`design/milestone-3/review-log.md` ("Cierre de cascada DEC-0013", segundo
hallazgo bloqueante, severidad Alta) detectó que, al redibujar los diagramas
C4 contra `DEC-0013`/`ADR-0013` (Monolito Modular Fase 1), se eliminó el API
Gateway y los BFF Web/Móvil de `c4-container.mmd` y `c4-component.mmd` — pero
esa eliminación **nunca fue una decisión arquitectónica propia**: fue una
instrucción directa del orquestador al invocar a `architecture-modeler`, sin
pasar por la cadena `architecture-strategist` → ADR que gobierna toda otra
decisión de este proyecto. `design/diagrams/NOTES.md` (sección "Iteración
DEC-0013 — Fase 1") ya señala esto explícitamente como "un hueco real del
ADR en ese punto puntual", con honestidad, pero sin resolverlo.

Esto generó dos problemas concretos, no solo uno de prolijidad documental:

1. **Contradicción entre artefactos vigentes**: `design/milestone-2/bounded-contexts.md`
   (sección "Componentes transversales") seguía describiendo, sin ningún
   matiz de fase, un API Gateway activo que "centraliza autenticación, SSL,
   rate limiting" y dos BFF — mientras los diagramas ya no los mostraban.
   Un lector que entrara por uno u otro documento encontraba dos arquitecturas
   distintas para el mismo sistema en la misma fase.
2. **Gap de seguridad real, no evaluado**: `bounded-contexts.md` atribuía al
   API Gateway la responsabilidad de **centralizar autenticación**, además de
   enrutamiento y rate limiting. Al eliminarlo sin ADR, ningún artefacto de
   la cascada de `DEC-0013` decía dónde vive la autenticación de los dos
   clientes (App Móvil, Portal Administrativo Web) en Fase 1. `ADR-0013`
   acepta explícitamente "debilitar parcialmente **DRV-03**" solo en su
   dimensión de aislamiento de datos por esquema/namespace lógico — nunca
   evalúa ni acepta como deuda un impacto en la superficie de autenticación,
   porque esa dimensión nunca llegó a decidirse a nivel de ADR.

Esta decisión resuelve ambos problemas: ratifica (con fundamento propio, no
solo por instrucción de dibujo) la ausencia de API Gateway/BFF como
componentes desplegados en Fase 1, y define explícitamente dónde vive la
autenticación en su lugar.

**Restricción que sigue gobernando esta decisión**: `RST-01` — "El proyecto
es individual" (`design/milestone-1/discovery.md`, "Restricciones no
negociables"; `plan/milestones.pdf`, "Otros — Tamaño del equipo") — la misma
restricción que motivó `DEC-0013`. Cualquier alternativa que reintroduzca una
segunda pieza operable de infraestructura (un segundo proceso, un segundo
pipeline de CI/CD, un segundo punto de despliegue) en Fase 1 debe justificarse
contra esa restricción explícitamente, no darse por sentada porque "es solo
infraestructura de borde".

**Drivers/Requisitos que motivan directamente esta decisión**: `DRV-03`
(seguridad y confidencialidad — "los datos del DAS deben ser confidenciales y
seguros") y `REQ-09` (confidencialidad y seguridad de los datos del DAS),
ambos de `design/traceability.md`.

## Decisión

**Parte 1 — Se ratifica: no existe API Gateway ni BFF Web/Móvil como
componentes desplegados en Fase 1.** Esto confirma, con fundamento de
arquitectura propio (no solo por instrucción de dibujo), la lectura que
`c4-container.mmd` y `c4-component.mmd` ya representan desde la iteración
`DEC-0013`.

**Parte 2 — La autenticación, autorización y demás preocupaciones
transversales de seguridad se resuelven con un Middleware de Autenticación
(Módulo de Seguridad transversal) dentro del propio monolito:**

- **Qué es**: un componente técnico transversal — no un bounded context, no
  posee datos de dominio propios — que intercepta **toda** solicitud
  entrante de App Móvil y Portal Administrativo Web, antes de que llegue a
  cualquiera de los 5 módulos internos (Identidad y Credenciales, Registro y
  Verificación, Captura de Asistencia, Reportes y Analítica,
  Notificaciones), y valida la sesión/token del usuario contra el agregado
  `Credencial` de **Identidad y Credenciales**. Rechaza (401/403) antes de
  enrutar si la sesión no es válida o si el rol del usuario no tiene permiso
  sobre el recurso solicitado (ej. solo Personal Administrativo puede llamar
  `POST /registrations/{id}/admin-decision` o `POST
  /identity/{dasId}/revoke`).
- **Dónde vive el emisor de sesión**: `Identidad y Credenciales` — ya dueño
  del agregado `DASID`/`Credencial` — extiende su responsabilidad para emitir
  la sesión/token en el login de App Móvil/Portal Web (`POST
  /identity/sessions`, nueva API). Esta responsabilidad es distinta de la
  validación de credencial física que ya tenía para el escaneo de Captura de
  Asistencia (`GET /identity/{dasId}/credential/validate`, ADR-0005/ADR-0006),
  pero del mismo dueño de datos — no crea un sexto módulo ni un nuevo
  bounded context.
- **SSL/TLS y rate limiting**: en Fase 1 se resuelven a nivel de
  infraestructura de despliegue (terminación TLS y balanceo de carga frente
  al único desplegable), no como responsabilidad de un componente de
  aplicación nuevo que el equipo deba diseñar y versionar — es
  infraestructura operativa estándar que cualquier desplegable HTTPS
  necesita, independientemente del estilo arquitectónico.
- **Fase 2**: cuando se cumpla un trigger de extracción de `ADR-0013` y
  reaparezca una topología distribuida real, el API Gateway y los BFF
  Web/Móvil vuelven a aplicar tal cual los describe
  `design/milestone-2/bounded-contexts.md` (sección "Componentes
  transversales"), y la lógica de validación de sesión/rol del Middleware de
  Autenticación se **relocaliza** dentro del Gateway — mismo contrato lógico
  (qué se valida y contra qué agregado), distinto lugar físico de ejecución
  — consistente con el Strangler Pattern que ya gobierna el resto de la
  migración de Fase 1 a Fase 2 en `ADR-0013`.

## Alternativas consideradas

### Alternativa A: Mantener un API Gateway/BFF liviano en Fase 1, como infraestructura de borde
- **Pros**: un único punto de entrada para los 2 clientes; centraliza
  autenticación/SSL/rate limiting exactamente como el diseño original de
  `bounded-contexts.md`; no requiere relocalizar nada en Fase 2 (el Gateway
  ya está ahí desde el día 1).
- **Contras**: `we7.md` describe explícitamente el API Gateway como un
  componente que "introduce un potencial punto único de falla que debe
  mitigarse mediante agrupación (clustering) y redundancia" — es decir, no
  es gratis operarlo incluso en su versión "liviana": exige un segundo
  proceso desplegado, un segundo pipeline de CI/CD (o al menos una segunda
  superficie de configuración/versionado) y un segundo punto de monitoreo
  independiente del monolito. Es exactamente el tipo de pieza operable
  adicional que `ADR-0013` decidió eliminar para respetar `RST-01`
  (reducir de N piezas operables a 1). Además, el propósito específico del
  patrón BFF (`we7.md`: "cada experiencia de usuario se beneficia de su
  propia lógica personalizada de agregación... previene APIs 'todo en uno'
  que obtienen demasiados datos para clientes simples") presupone componer
  datos de **servicios de red independientes** — en Fase 1 esa composición
  ya ocurre en proceso, dentro del mismo desplegable, así que el problema
  que el BFF resuelve no existe todavía.
- **Por qué no se eligió**: reintroduce, con otro nombre ("infraestructura de
  borde" en vez de "servicio de negocio"), exactamente la segunda pieza
  operable independiente que `ADR-0013` eliminó por `RST-01`. Llamarlo
  "liviano" no cambia que sigue siendo un proceso separado que un
  desarrollador único debe desplegar, versionar, exponer con TLS propio y
  vigilar por separado del monolito.

### Alternativa B (elegida): Middleware de Autenticación transversal dentro del monolito
- Ver "Decisión" arriba.
- **Por qué se eligió**: aplica textualmente el mecanismo que `knowledge/we6.md`
  recomienda para preocupaciones transversales (seguridad incluida) en
  aplicaciones **monolíticas/en capas** — "Programación Orientada a Aspectos
  (AOP)" — en contraste explícito, en la misma fuente, con el "patrón
  sidecar / servicios centralizados (ej., un servicio Auth dedicado...)
  **para sistemas distribuidos**", que es exactamente lo que un API
  Gateway/BFF sería en Fase 1. `knowledge/we1.md` respalda además el
  concepto de un componente transversal dedicado a seguridad ("Security
  Module: transversal, estandarizado", uno de los cuatro tipos de módulo de
  "Modular Design in Enterprise Architecture", junto a Service/Data/API
  Module) — no es una idea nueva fuera del curso, es la aplicación de un
  concepto ya nombrado en `knowledge/` a la topología de un único
  desplegable. No agrega ningún proceso, pipeline ni punto de despliegue
  nuevo: vive dentro del mismo binario que los 5 módulos.

### Alternativa C: Cada uno de los 5 módulos valida el token de sesión por su cuenta, sin middleware centralizado
- **Pros**: cero componentes nuevos que diseñar; cada módulo es responsable
  únicamente de sí mismo.
- **Contras**: duplica la lógica de validación de sesión/rol cinco veces,
  con alto riesgo de que un módulo quede desactualizado o mal implementado
  respecto a los demás (exactamente el riesgo que `we6.md` describe como
  motivo para tratar las preocupaciones transversales con un patrón
  dedicado en vez de repetirlas por capa/módulo). Es además la lectura
  contraria a la que ya asumía `bounded-contexts.md` original
  ("autenticación centralizada"), así que revertirla sin necesidad
  introduce un cambio de fondo no pedido por ningún driver.
- **Por qué no se eligió**: viola el principio de responsabilidad única de
  la preocupación transversal "seguridad" (`we1.md`, `we6.md`) y aumenta,
  no reduce, el riesgo sobre `DRV-03` — el problema que se busca resolver
  aquí, no agravar.

## Consecuencias

**Positivas**
- Cierra el hallazgo de severidad Alta de `review-log.md` ("Cierre de
  cascada DEC-0013", Hallazgo 2): ya no hay contradicción entre
  `bounded-contexts.md` y los diagramas vigentes, y queda explícitamente
  definido dónde vive la autenticación en Fase 1.
- No reintroduce ninguna pieza operable adicional — el Middleware de
  Autenticación vive dentro del único desplegable de `DEC-0013`, respetando
  íntegramente `RST-01`.
- Deja un camino de migración explícito y de bajo costo hacia Fase 2: el
  contrato lógico del middleware (qué valida, contra qué agregado) no
  cambia al relocalizarse dentro de un Gateway real — es una relocalización,
  no un rediseño.
- Extiende una responsabilidad ya existente de Identidad y Credenciales
  (dueño de `DASID`/`Credencial`) en vez de crear un bounded context nuevo,
  preservando el criterio de separación DDD ya aceptado en Milestone 2.

**Negativas / deuda que se acepta**
- **Concentración de la superficie de autenticación en un único proceso**:
  al no existir una frontera de red entre el middleware y los 5 módulos, un
  compromiso del proceso completo del monolito compromete también la
  validación de sesión — no hay aislamiento de fallos/seguridad entre el
  middleware y el resto del sistema como sí lo habría con un Gateway
  desplegado aparte. Se acepta este trade-off porque es proporcional al
  tamaño real del sistema en Fase 1 (un solo desplegable, operado por una
  sola persona, `RST-01`) — exactamente el mismo tipo de trade-off que
  `ADR-0013` ya aceptó para el resto de la superficie del sistema.
- La responsabilidad de Identidad y Credenciales crece (ahora también emite
  sesiones de aplicación, no solo valida credenciales físicas) — una
  extensión menor de su alcance, no un cambio de su criterio de separación.

**Riesgos que quedan abiertos**
- Esta decisión no evalúa formalmente el riesgo operativo de tener un único
  punto de validación de autenticación sin redundancia de proceso en Fase 1
  (ej. si el proceso del monolito se reinicia, ¿qué pasa con las sesiones en
  memoria vs. persistidas?). Queda señalado aquí explícitamente para que
  `architecture-risk` lo evalúe en una futura pasada de Milestone 3 — no se
  resuelve en este ADR.

## Referencias
- `knowledge/we1.md` — "Modular Design in Enterprise Architecture": Security
  Module (transversal, estandarizado) como uno de los cuatro tipos de módulo.
- `knowledge/we6.md` — "Preocupaciones transversales" dentro de Separación
  de Responsabilidades (SoC): AOP para aplicaciones monolíticas/en capas vs.
  patrón sidecar/servicios centralizados para sistemas distribuidos; también
  "implementar balanceo de carga efectivo" como principio general de
  escalabilidad (fundamento de TLS/rate limiting como infraestructura, no
  como componente de aplicación).
- `knowledge/we7.md` — API Gateway (SPOF que exige clustering/redundancia) y
  Backend-for-Frontend (propósito: componer datos de servicios de red
  independientes).
- `design/traceability.md` — `DRV-03`, `REQ-09`; `RST-01` (citada
  directamente contra `design/milestone-1/discovery.md`, no como fila de
  ese archivo).
- `design/adr/adr-0013-monolito-modular-fase1-extraccion-selectiva.md` —
  decisión que esta ADR complementa y cuyo hueco cierra.
- `design/milestone-2/bounded-contexts.md` — sección "Componentes
  transversales" (con nota de vigencia por fase agregada por este ADR) y
  nueva sección "Nota de revisión — Milestone 3 (DEC-0014)".
- `design/milestone-3/review-log.md` — "Cierre de cascada DEC-0013",
  segundo hallazgo bloqueante, severidad Alta.
- `design/diagrams/NOTES.md` — "Iteración DEC-0013 — Fase 1", sección sobre
  la ambigüedad de API Gateway/BFF detectada al diagramar.
