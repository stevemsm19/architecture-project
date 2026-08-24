# ADR-0006: Circuit Breaker (fail-open acotado) en la dependencia síncrona Captura de Asistencia → Identidad y Credenciales

## Estado
Aceptado

## Contexto
`architecture-reviewer` (Iteración 1, `design/milestone-2/review-log.md`)
señaló que `architecture-decision.md` cita "Circuit Breaker + Retry con
backoff exponencial y jitter" para la comunicación entre Captura de
Asistencia y Registro/Identidad, pero ningún ADR especificaba el
comportamiento real. **ADR-0005 solo cubre la desconexión del dispositivo**
(con caché local en el borde) — no cubre el caso de que el **servicio**
Identidad y Credenciales completo esté caído o degradado (incidente de
backend/base de datos) mientras los 20 campus siguen online y enviando
escaneos (**DRV-03**, **DRV-05**, **REQ-06**). Sin definir esto, Captura no
sabe si debe (a) rechazar todo escaneo (fail-closed, degrada el servicio
para usuarios legítimos), (b) aceptar todo escaneo sin validación
confirmada (fail-open total, riesgo de seguridad, choca con DRV-03), o (c)
tratarlo como desconexión de dispositivo (mezcla dos causas de fallo
distintas). `knowledge/we7.md` (Semana 7) desarrolla la máquina de estados
completa del Circuit Breaker (Cerrado/Abierto/Semi-abierto);
`knowledge/we3.md` desarrolla Dead Letter Queue como mecanismo de
reconciliación posterior.

## Decisión
Captura de Asistencia (backend) envuelve su llamada síncrona
`GET /identity/{dasId}/credential/validate` con un **Circuit Breaker**
(`we7.md`):

- **Cerrado** (normal): cada escaneo online valida contra Identidad de
  forma síncrona, como hoy. Cada validación exitosa escribe (write-through)
  en una **caché local propia de Captura** — "credenciales recientemente
  validadas" (TTL 15 minutos, ver ADR-0009) — distinta de la caché interna
  de Identidad y de la caché del Dispositivo DAS (ADR-0005).
- Tras **N fallos/timeouts consecutivos** (cifra de diseño: 5 en una
  ventana móvil de 30s) el circuito pasa a **Abierto**: Captura deja de
  llamar a Identidad y sirve validación en **modo degradado (fail-open
  acotado)**:
  - Si el `dasId` **está** en la caché local de "recientemente validadas"
    y no fue marcado como revocado (ADR-0009) → se acepta el escaneo,
    escribiendo `EventoDeAsistencia.validacionCredencial = cache_degradada`
    (nuevo campo de auditoría, ver `data-model-conceptual.md`).
  - Si el `dasId` **no** está en esa caché (nunca validado recientemente, o
    revocado) → se **rechaza** el escaneo (fail-closed para ese caso
    puntual). Se prioriza explícitamente DRV-03 sobre DRV-05 solo para
    identidades que el sistema no puede confirmar recientemente.
  - Todo evento escrito con `cache_degradada` se encola en una cola de
    reconciliación (Dead Letter/re-validación, `we3.md`) para
    reconfirmarse contra Identidad en cuanto el circuito cierre.
- Tras un período de enfriamiento, el circuito pasa a **Semi-abierto**:
  permite un número limitado de solicitudes de prueba; si tienen éxito,
  vuelve a Cerrado; si fallan, vuelve a Abierto.

## Alternativas consideradas

### Alternativa A: Fail-open total (aceptar todo escaneo mientras el circuito está abierto)
- **Pros**: máxima disponibilidad de captura durante el incidente (DRV-05
  intacto).
- **Contras**: acepta escaneos de identidades no verificables, incluidas
  credenciales potencialmente revocadas o inexistentes — viola
  directamente DRV-03/REQ-09.
- **Por qué no se eligió**: el propio hallazgo del reviewer señala esto
  como "riesgo de seguridad".

### Alternativa B: Fail-closed total (rechazar todo escaneo mientras el circuito está abierto)
- **Pros**: no hay riesgo de aceptar una identidad no verificada.
- **Contras**: degrada el servicio de asistencia para el 100% de los
  usuarios legítimos ante cualquier incidente del backend de Identidad,
  incluidos usuarios validados minutos antes — desproporcionado frente al
  riesgo real.
- **Por qué no se eligió**: el propio hallazgo del reviewer la marca como
  "degradando el servicio de asistencia para todo usuario legítimo";
  descarta información ya confirmada y disponible localmente (la caché de
  "recientemente validadas").

## Consecuencias

**Positivas**
- Resuelve explícitamente el escenario de falla que el reviewer describió
  (a/b/c) con una cuarta opción definida: fail-open **acotado** a
  identidades ya conocidas, con marca de auditoría y reconciliación
  posterior.
- Mantiene DRV-05 (near real-time) para el caso común (usuario ya validado
  recientemente) sin sacrificar DRV-03 para el caso desconocido/revocado.
- Se integra directamente con ADR-0009 (revocación): la caché de
  "recientemente validadas" se invalida activamente ante `CredentialRevoked`,
  no solo por expiración pasiva.

**Negativas / deuda que se acepta**
- Requiere un componente de caché adicional en Captura de Asistencia (no
  existía en el diseño original) y una cola de reconciliación.
- Nuevo campo `validacionCredencial` en `EventoDeAsistencia` — cambia el
  modelo de datos conceptual.
- El umbral de fallos (5/30s) y el período de enfriamiento son cifras de
  diseño no validadas contra comportamiento real de producción.

**Riesgos que quedan abiertos**
- El TTL de 15 minutos de la caché local (compartido con ADR-0009) acota
  pero no elimina la ventana de exposición ante una credencial revocada
  durante un incidente simultáneo del backend de Identidad —
  `architecture-risk` (Milestone 3) debería evaluar si ese TTL es
  aceptable para el apetito de riesgo real de UPCA.

## Referencias
- `knowledge/we7.md` — Circuit Breaker (máquina de estados).
- `knowledge/we3.md` — Dead Letter Queue.
- `design/traceability.md` — DRV-03, DRV-05, REQ-06.
- `design/adr/adr-0005-captura-offline-tolerante.md` — caso distinto
  (desconexión de dispositivo), complementario a este ADR.
- `design/adr/adr-0009-revocacion-credencial.md` — invalidación activa de
  la caché de "recientemente validadas".
- `design/milestone-2/bounded-contexts.md` — contexto Captura de
  Asistencia.
- `design/milestone-2/data-model-conceptual.md` — campo
  `validacionCredencial` de `EventoDeAsistencia`.
- `design/milestone-2/review-log.md` — Iteración 1, hallazgo "Circuit
  Breaker citado pero nunca especificado".

## Nota de revisión — Milestone 3 (DEC-0013)

`design/adr/adr-0013-monolito-modular-fase1-extraccion-selectiva.md`
(`DEC-0013`) deja este mecanismo **en pausa** durante la Fase 1: en el
Monolito Modular, la llamada de Captura de Asistencia a Identidad y
Credenciales (`GET /identity/{dasId}/credential/validate`) es una **llamada
en proceso** (invocación de función/método dentro del mismo desplegable),
no una llamada de red — no existe la frontera de red que este Circuit
Breaker está diseñado para proteger, y por lo tanto no hay fallos
transitorios de red, timeouts de socket ni degradación de un servicio
remoto que abran el circuito en el sentido descrito arriba.

Esto no invalida el mecanismo: queda especificado exactamente como está,
listo para activarse sin rediseño el día en que se cumpla el trigger de
extracción de Captura de Asistencia (ADR-0013, Fase 2) y esa llamada vuelva
a cruzar una frontera de red real entre dos servicios independientes. Hasta
entonces, los escenarios de falla que este ADR resuelve (backend de
Identidad caído o degradado) se reducen, en Fase 1, a un fallo del proceso
completo (caída de todo el monolito, no de un componente aislado) — un
escenario cubierto por la disponibilidad general del desplegable, no por
este patrón específico.
