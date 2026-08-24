# ADR-0010: Especificación de la clave de idempotencia de eventos de asistencia y origen del timestamp

## Estado
Aceptado

> Extiende `design/adr/adr-0005-captura-offline-tolerante.md` (que sigue
> **Aceptado**, sin cambios en su decisión central de buffer local +
> consumidor idempotente). Este ADR solo precisa la composición exacta de
> la clave de idempotencia y el origen del timestamp que ADR-0005 había
> dejado subespecificados.

## Contexto
`architecture-reviewer` (Iteración 1) encontró que
`data-model-conceptual.md` define `claveIdempotencia (dispositivoId +
timestampEscaneo, o equivalente)` **sin incluir `direccion`** (entrada |
salida). Si dos eventos legítimos y distintos (una entrada y una salida)
llegan con el mismo `dispositivoId` y el mismo `timestampEscaneo`
(resolución de reloj no especificada), la clave los trataría como
duplicados y uno se perdería silenciosamente. Tampoco se especificaba si
`timestampEscaneo` es generado por el reloj local del dispositivo o
asignado por el servidor — relevante tanto para idempotencia como para la
credibilidad del SLA de ≤15s p95 (ADR-0003), medido "desde el evento
`AttendanceRecorded`" sin que su timestamp de origen estuviera definido con
precisión (**DRV-05**, **REQ-06**, **ASM-07**).

## Decisión
- **Clave de idempotencia**: `dispositivoId + direccion + timestampEscaneo`
  (se agrega `direccion`, campo que ya existía en el modelo pero no estaba
  incluido en la clave).
- **`timestampEscaneo`**: se origina en el reloj del dispositivo — campo de
  auditoría que refleja el momento real del escaneo, incluso si se
  sincroniza horas después en modo offline (ASM-07). Se asume como
  precondición operativa que el dispositivo mantiene su reloj sincronizado
  (ej. vía NTP o equivalente); el mecanismo concreto de sincronización de
  reloj **no está cubierto por el material del curso** y se marca
  explícitamente como **"Supuesto fuera del curso — requiere validación
  con el instructor"**.
- **`timestampRecibidoServidor`** (nuevo campo): asignado por Captura de
  Asistencia al recibir el evento (online o en la sincronización de un
  lote offline). Es el timestamp que efectivamente se usa para medir el
  SLA de ≤15s p95 de ADR-0003 — "desde el evento `AttendanceRecorded`" se
  entiende ahora, explícitamente, como desde `timestampRecibidoServidor`,
  no desde `timestampEscaneo`.

Con `direccion` en la clave, una entrada y una salida del mismo dispositivo
en el mismo segundo ya no colisionan (son claves distintas). Una colisión
real de dos entradas (o dos salidas) del mismo dispositivo en el mismo
segundo exacto se sigue tratando como duplicado intencional (Idempotent
Consumer) — caso extremadamente improbable (dos escaneos físicos del mismo
dispositivo en <1s) y se acepta como riesgo residual menor, no cubierto por
este ADR.

## Alternativas consideradas

### Alternativa A: UUID generado por el dispositivo por escaneo, en vez de clave compuesta
- **Contras**: mayor complejidad de generación/almacenamiento en el
  dispositivo, sin beneficio claro sobre la clave compuesta.
- **Por qué no se eligió**: `dispositivoId + direccion + timestampEscaneo`
  ya es suficientemente único en la práctica y no requiere lógica adicional
  en el dispositivo.

## Consecuencias

**Positivas**
- Cierra la pérdida silenciosa de eventos de entrada/salida simultáneos.
- Da una definición verificable de qué timestamp respalda el SLA de
  ADR-0003, resolviendo la ambigüedad de medición señalada por el reviewer.

**Negativas / deuda que se acepta**
- Dos campos de timestamp en el modelo (`timestampEscaneo`,
  `timestampRecibidoServidor`) — más almacenamiento, a cambio de claridad
  en el contrato de qué se mide.

**Riesgos que quedan abiertos**
- La sincronización de reloj real del dispositivo (NTP) queda fuera del
  alcance curado del curso — supuesto explícito a validar con el
  instructor, no una garantía de este diseño.

## Referencias
- `knowledge/we3.md`, `knowledge/we7.md` — Idempotent Consumer.
- `design/traceability.md` — DRV-05, REQ-06, ASM-07.
- `design/adr/adr-0005-captura-offline-tolerante.md` — decisión base de
  buffer local + idempotencia, no modificada por este ADR.
- `design/adr/adr-0003-cqrs-reportes.md` — SLA ≤15s p95, ahora medido desde
  `timestampRecibidoServidor`.
- `design/milestone-2/data-model-conceptual.md` — entidad
  `EventoDeAsistencia`.
