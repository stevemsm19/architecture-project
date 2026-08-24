# Plan de Mitigación — Milestone 3

> Agrupa las mitigaciones de `design/milestone-3/risk-register.md` por las
> cuatro categorías que nombra `plan/milestones.pdf` (Milestone 3, "Plan de
> mitigación"): Prototipo temprano de integración, Fallback authentication,
> Estrategia de reintento, Logging & observabilidad. Cada mitigación referencia
> el `RISK-NN` que atiende y el patrón concreto de `knowledge/` que la
> fundamenta. **RISK-01**, **RISK-08** y **RISK-16** no aparecen aquí como
> "implementables" — están marcados como hallazgos en el registro de riesgos
> y no se resuelven con ninguna de estas cuatro categorías (ver nota al
> final).
>
> Corrección post-revisión (`architecture-reviewer`, `review-log.md`,
> Iteración 1, Hallazgo 3): se agregan las mitigaciones de **RISK-17**
> (mecanismo de tiering de `DEC-0004`) en las categorías 3 y 4, y se agrega
> **RISK-16** a la nota final — ninguna mitigación existente fue modificada.
>
> Corrección post-revisión (`architecture-reviewer`, `review-log.md`,
> "Cierre de cascada DEC-0013", Hallazgo 1, severidad Alta): la nota final
> ("Nota: riesgos que no se resuelven con este plan") describía a **RISK-01**
> en presente, como pendiente de que `architecture-reviewer` decidiera si
> reabría Milestone 2 — decisión que ya se tomó y ya se resolvió con
> **`DEC-0013`**. Se corrige esa nota para reflejar el estado actual. Se
> agrega además una precisión de vigencia por fase a la mitigación de
> **RISK-15** (monitoreo del broker de eventos, categoría 4) y se deja
> constancia de que las mitigaciones de **RISK-10** (categorías 1 y 3) siguen
> aplicando en Fase 1 en su versión reducida (sin la cola de reconciliación
> del Circuit Breaker de `ADR-0006`, en pausa en Fase 1) — ver
> `design/milestone-3/risk-register.md` para el detalle completo de ambas
> notas de vigencia. Ninguna mitigación existente fue eliminada.

---

## 1. Prototipo temprano de integración

Valida contra el comportamiento **real** de dependencias externas o de carga,
antes de comprometerse a un contrato o un SLA en producción — reduce el
riesgo de que una cifra de diseño (`we7.md`, decisiones declaradas
explícitamente como tales en ADR-0003, ADR-0007, ADR-0008) resulte
inalcanzable recién en producción.

- **Spike técnico NIS** (atiende **RISK-02**, **RISK-06**, **RISK-07**):
  antes de implementar ADR-0007 tal cual, construir un cliente mínimo contra
  el NIS real (o su documentación de API si el acceso real no está
  disponible aún) para confirmar: (a) si expone realmente solo polling o
  también webhooks configurables — la premisa central de ADR-0007; (b) el
  formato real de `nisVerificationId` y si permite detectar duplicados como
  asume el diseño; (c) el comportamiento real ante timeout repetido (¿el NIS
  reintenta del lado suyo? ¿eso interactúa con el polling de UPCA?). Este
  spike es exactamente el hito "Spike técnico NIS" de `design/cronograma.md`
  y es condición previa razonable para dar por cerrados RISK-02, RISK-06 y
  RISK-07 con confianza operacional, no solo de diseño.

- **Prototipo de captura de asistencia bajo carga pico** (atiende
  **RISK-10**, **RISK-11**, **RISK-12**): simular la ventana de carga pico
  estimada en el Anexo de `architecture-decision.md` (~50-55 eventos/seg) más
  el escenario de reconexión masiva (RISK-10/RISK-11: cientos de dispositivos
  sincronizando buffers offline simultáneamente) contra un proyector CQRS de
  referencia, para confirmar que el SLA ≤15s p95 (ADR-0003) se sostiene no
  solo en el caso "escaneo en vivo distribuido" sino también en el caso
  "ráfaga post-outage". Corresponde al hito "Prototipo de captura" de
  `design/cronograma.md`. Fundamento: `knowledge/we4.md` (Semana 4), "el
  proyector debe escalar horizontalmente para ponerse al día" ante
  contrapresión — el prototipo confirma si esa capacidad de autoescalado
  alcanza en la práctica, no solo en la estimación. **Vigencia (post-DEC-0013)**:
  en Fase 1 (Monolito Modular), la parte de este prototipo que atiende
  RISK-10 se ejecuta contra la versión reducida del escenario (solo
  sincronización masiva de buffers, sin la cola de reconciliación del
  Circuit Breaker de `ADR-0006`, en pausa en Fase 1) — ver la nota de
  vigencia de RISK-10 en `risk-register.md`.

---

## 2. Fallback authentication

Mecanismos que permiten seguir operando la validación de identidad/credencial
bajo degradación, sin caer a un fallo total ni a un fail-open sin control —
ya presentes parcialmente en el diseño de Milestone 2, se listan aquí porque
Milestone 3 los evalúa como mitigación, no los inventa.

- **Circuit Breaker con fail-open acotado** (atiende **RISK-14**, mitiga
  parcialmente **RISK-02** en su dimensión de disponibilidad de captura):
  ya implementado en ADR-0006 — ante caída del backend de Identidad, Captura
  de Asistencia sirve validación desde su caché local de "recientemente
  validadas" (TTL 15 min) solo para `dasId` ya conocidos y no revocados,
  rechazando (fail-closed) los desconocidos. Patrón: Circuit Breaker
  (`knowledge/we7.md`, Semana 7, máquina de estados Cerrado/Abierto/
  Semi-abierto). Mitigación adicional propuesta en RISK-14: alerta
  correlacionada cuando el circuito está Abierto simultáneamente con una
  revocación reciente, para intervención manual dentro de la ventana de TTL.

- **Caché local de credenciales en el Dispositivo DAS** (atiende **RISK-09**,
  **RISK-11**, en su dimensión de "el dispositivo sigue validando aunque no
  tenga conectividad"): ya implementado en ADR-0005 (caché local refrescada
  cada 15 min vía ADR-0008) — el dispositivo puede seguir validando
  escaneos contra su última caché conocida incluso durante un corte de
  conectividad de campus completo (RISK-11). Patrón: Servicio Host
  Abierto/Conformista con caché en el borde (`knowledge/we6.md`/`we7.md`,
  Semanas 6-7).

- **Escalamiento manual como fallback del proceso de verificación NIS**
  (atiende **RISK-02**): ADR-0007 ya define `escalado_manual` como salida
  operativa cuando el mecanismo automático (polling + reintentos) se agota —
  es, en efecto, un "fallback" de proceso, no de autenticación en sentido
  estricto, pero cumple la misma función: evitar que la ausencia de una
  respuesta automática bloquee indefinidamente al usuario. Mitigación
  adicional (RISK-02): dar a esa cola manual el mismo tratamiento de alerta
  escalonada que ya tiene el timeout automático.

---

## 3. Estrategia de reintento

Todos los mecanismos de Retry + Idempotencia ya presentes en el diseño de
Milestone 2, evaluados aquí contra los escenarios operacionales de Milestone
3, más los ajustes aditivos que este milestone identifica como necesarios.

- **Retry con backoff exponencial + jitter** (`knowledge/we7.md`, Semana 7):
  ya aplicado a reintentos del NIS (ADR-0002/ADR-0007, atiende **RISK-02**) y
  propuesto como mitigación nueva para: sincronización de buffers offline en
  reconexión masiva (**RISK-10**, **RISK-11** — jitter específicamente para
  evitar el "efecto rebaño"/thundering herd que el propio `knowledge/index.md`
  nombra en la entrada de Backoff exponencial de Semana 7); envío de correo
  en el contexto Notificaciones (**RISK-04**, no cubierto por ningún ADR
  hasta ahora). **Vigencia (post-DEC-0013)**: para RISK-10, este retry con
  jitter sigue aplicando sin cambios en Fase 1 — actúa sobre
  `POST /attendance-events/batch` (`DEC-0005`), decisión no afectada por
  `DEC-0013`; ver nota de vigencia de RISK-10 en `risk-register.md`.

- **Idempotent Consumer** (`knowledge/we3.md`/`we7.md`, Semanas 3-4-7): ya
  aplicado a resultados entrantes del NIS (ADR-0007, resuelve **RISK-07**),
  a eventos de asistencia (ADR-0005/ADR-0010) y al envío inicial de
  autorregistro (ADR-0012, mitiga **RISK-06**). Ajuste aditivo propuesto en
  **RISK-06**: extender la excepción de deduplicación de ADR-0012 para
  tratar `escalado_manual` como "no terminal" a efectos de deduplicación,
  cerrando la ventana residual donde un usuario sin su `Idempotency-Key`
  original podría disparar una segunda verificación NIS duplicada.
  Propuesta nueva (**RISK-17**): aplicar el mismo patrón al job de
  transición por capas de `ADR-0004` — el reintento de un lote de migración
  tras una falla parcial no debe duplicar ni corromper eventos que ya
  transicionaron de capa.

- **Dead Letter Queue** (`knowledge/we3.md`, Semanas 3-4): ya aplicada a
  resultados contradictorios tardíos del NIS (ADR-0007) y a eventos
  aceptados en modo `cache_degradada` (ADR-0006). Extensión propuesta:
  notificaciones de correo que agotan reintentos (**RISK-04**); eventos de
  asistencia descartados por el buffer local al alcanzar su límite máximo
  (**RISK-09**, para que un descarte extremo quede auditado, no oculto); y
  lotes de transición entre capas de `ADR-0004` que fallan repetidamente
  (**RISK-17**), en vez de dejarlos silenciosamente en la capa de origen.

- **Backpressure / buffering con límite explícito + load shedding**
  (`knowledge/we4.md`, Semana 4): mitigación central de **RISK-09** (buffer
  local del Dispositivo DAS sin tamaño máximo ni política de purga, abierto
  desde ADR-0005 en Milestone 2, severidad Media). Se propone: tamaño máximo
  de buffer por dispositivo (cifra de diseño, dimensionada con el mismo
  criterio conservador del Anexo de carga de `architecture-decision.md`),
  purga con descarte del evento más antiguo solo al alcanzar el límite
  (nunca silencioso), y alerta al superar un umbral de advertencia (80%).

- **Bulkhead** (`knowledge/we4.md`/`we7.md`, Semanas 4-7): mitigación
  propuesta para **RISK-10** — aislar la capacidad de
  `POST /attendance-events/batch` (sincronización masiva post-outage) de la
  de `POST /attendance-events` (escaneo en vivo), para que una reconciliación
  masiva no degrade la ruta crítica near real-time. **Vigencia
  (post-DEC-0013)**: sigue siendo válida dentro del monolito de Fase 1 —
  aislar capacidad interna entre dos rutas no requiere una frontera de red;
  la reconciliación adicional del Circuit Breaker de `ADR-0006` que este
  mismo riesgo cita para Fase 2 permanece en pausa hasta entonces.

- **Proceso de Larga Duración explícito, comprobable y recuperable**
  (`knowledge/we4.md`, Semana 4): ya aplicado a la Saga NIS (ADR-0002,
  atiende **RISK-02**). Propuesta nueva (**RISK-17**): aplicar el mismo
  principio al job de transición por capas de `ADR-0004` — cada
  `EventoDeAsistencia` debe exponer un estado de migración verificable
  (ej. `capaActual` + `ultimaTransicionExitosa`), no una transición
  implícita inferible solo por antigüedad, para que una falla parcial sea
  detectable y recuperable en vez de silenciosa.

---

## 4. Logging & observabilidad

Visibilidad operativa que no cambia el comportamiento del sistema, pero
permite detectar y responder a las condiciones que las otras tres categorías
no pueden prevenir por completo — fundamentada en `knowledge/we6.md` (Semana
6), que lista observabilidad como uno de los 8 Principios Esenciales de
Diseño de Microservicios.

- **Métricas de tasa de éxito/latencia real del NIS** (atiende **RISK-02**):
  para validar si el intervalo de polling (5-30 min) y el tope de 3 ciclos de
  ADR-0007 son adecuados — cierra el riesgo abierto que el propio ADR-0007
  declara ("cifras de diseño... no validadas contra el comportamiento real
  del NIS").

- **Alerta de "campus sin heartbeat reciente"** (atiende **RISK-11**): dar
  visibilidad operativa directa al personal administrativo sobre un campus
  degradado, en vez de inferirlo indirectamente por ausencia de datos en el
  portal (Reportes y Analítica).

- **Alerta correlacionada Circuit Breaker Abierto + revocación reciente**
  (atiende **RISK-14**): visibilidad específica sobre la coincidencia de dos
  eventos de baja frecuencia que, combinados, generan la ventana de
  exposición de seguridad más severa del diseño actual.

- **Monitoreo de salud del broker de eventos y lag de consumidores** (atiende
  **RISK-15**): dado que el broker concentra la disponibilidad de múltiples
  mecanismos de resiliencia (CQRS de Reportes, proyección de credenciales del
  dispositivo, propagación de revocación, notificaciones), su degradación
  debe ser visible de inmediato, no descubierta indirectamente por el fallo
  en cascada de varios contextos a la vez. **Vigencia (post-DEC-0013)**:
  aplica desde Fase 2 — en Fase 1 (Monolito Modular) no hay broker
  desplegado (confirmado contra `design/diagrams/c4-container.mmd`), por lo
  que esta mitigación no tiene aún ningún componente que monitorear; se
  activa junto con el trigger de extracción de Captura de Asistencia. Ver
  nota de vigencia de RISK-15 en `risk-register.md`.

- **Métrica de throughput real vs. estimado en captura de asistencia**
  (atiende **RISK-12**): comparar el volumen y la concentración real de
  escaneos contra el supuesto de dispersión horaria del Anexo de
  `architecture-decision.md`, para detectar tempranamente si el patrón real
  de asistencia es más sincronizado de lo asumido.

- **Alerta de "capa caliente creciendo más allá de la ventana esperada sin
  transición confirmada"** (atiende **RISK-17**): visibilidad operativa
  específica sobre el mecanismo de tiering de `ADR-0004` — métrica de
  "eventos pendientes de transición más allá del plazo esperado", para que
  una falla parcial o total del job de migración se detecte antes de que
  comprometa el cumplimiento del mínimo legal de retención (REQ-12/DRV-04),
  en vez de descubrirse solo cuando Reportes consulta contra un almacén
  histórico incompleto.

---

## Nota: riesgos que no se resuelven con este plan

**RISK-01** (complejidad operativa plena de MSA+EDA para RST-01), **RISK-08**
(usuario modifica su información tras iniciar la verificación) y **RISK-16**
(placeholder de retención de `DEC-0011` sin validación legal) no figuran
arriba porque ninguna de las cuatro categorías de mitigación de Milestone 3
los resuelve:

- RISK-01 requería una decisión de **estilo/alcance arquitectónico** (ej.
  explorar un punto intermedio de complejidad, no evaluado en Milestone 2) —
  se documentó en `design/milestone-3/risk-register.md` marcado
  explícitamente **"requiere revisión de diseño"**, para que
  `architecture-reviewer` decidiera si reabría Milestone 2. **Ya fue
  resuelto**: `architecture-reviewer` confirmó la reapertura parcial
  (`design/milestone-3/review-log.md`, Iteración 1) y `architecture-strategist`
  respondió con **`DEC-0013`** (Monolito Modular Fase 1 + extracción
  selectiva Fase 2 vía Strangler Pattern), que reduce su Probabilidad de
  Alta a Media-Baja (`ADR-0013`, "Consecuencias positivas"). Sigue sin
  aparecer arriba porque ninguna de las cuatro categorías de mitigación de
  este plan lo resolvió — se resolvió con una decisión de diseño, no con un
  patrón de resiliencia — no porque continúe pendiente. Ver
  `design/milestone-3/risk-register.md`, entrada `[RISK-01]`, sección "Nota
  de resolución (post-DEC-0013)".
- RISK-08 requiere una **decisión de negocio** (¿se permite editar una
  solicitud en curso, o se exige cancelar y reenviar?) antes de poder
  aplicar cualquier patrón — se documenta como hallazgo de diseño abierto
  para `architecture-strategist`, no para `architecture-reviewer` (no
  cambia el estilo MSA+EDA ni los bounded contexts).
- RISK-16 requiere una **validación externa de cumplimiento normativo
  (legal/instructor)** sobre el placeholder de 180 días/1 año ya fijado en
  `ADR-0011` — no es un déficit de mecanismo de resiliencia (el mecanismo de
  purga automática ya está bien definido) ni un cambio de estilo
  arquitectónico, sino una confirmación externa de que ese valor numérico es
  correcto. Se documenta como hallazgo de gobernanza/cumplimiento pendiente
  de cierre antes de cualquier despliegue a producción real, anclado en
  `knowledge/we1.md` (Semana 1 — Gobierno vs. Cumplimiento), sin marcarse
  "requiere revisión de diseño".
