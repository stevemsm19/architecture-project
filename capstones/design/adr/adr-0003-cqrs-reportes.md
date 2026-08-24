# ADR-0003: Separar escritura de asistencia y lectura de reportes con CQRS

## Estado
Aceptado

## Contexto
El enunciado exige simultáneamente que el registro de entrada/salida sea "lo
más cercano posible al tiempo real" (**DRV-05**, **REQ-11**) y que el portal
administrativo ofrezca reportes y estadísticas (**REQ-07**), con acceso a
"todos los datos del campus" y, según **ASM-14**, visibilidad global
multi-campus. `priorizacion.md` señala explícitamente, para REQ-07, el
"riesgo de que las consultas analíticas compitan por recursos con la
captura de asistencia en tiempo real si no se diferencian los patrones de
acceso". Los stakeholders simulados matizan además el umbral de frescura
aceptable: la app individual tolera "algunos segundos... o incluso un poco
más" (**ASM-06**); el portal exige actualización "suficientemente rápida",
descartando explícitamente un batch diario, aunque sin exigir el mismo
segundo del evento (**ASM-12**); y las consultas históricas pueden ser más
lentas sin problema (**ASM-13**). `knowledge/we4.md` (Semana 4) desarrolla
CQRS explícitamente como mecanismo de manejo de contrapresión para este
tipo de escenario: "un aumento repentino en el tráfico de lecturas
(consultas) no impacta la capacidad del sistema de procesar escrituras
(comandos), y viceversa".

## Decisión
Se adopta CQRS: Captura de Asistencia es el lado de comandos/escritura
(fuente de verdad, `EventoDeAsistencia`); Reportes y Analítica es el lado
de consultas/lectura, alimentado de forma asíncrona por el evento
`AttendanceRecorded` vía un proyector, con dos rutas de lectura
diferenciadas por SLA: una ruta "reciente" (optimizada para velocidad) y una
ruta "histórica" (optimizada para costo, latencia mayor aceptada). Se fija
como SLA operativo de proyección: ≤ 15 segundos p95 desde el evento
`AttendanceRecorded` hasta su disponibilidad en el modelo de lectura, tanto
para el portal como para la app del usuario — cifra que resuelve
numéricamente la dimensión abierta de **AMB-01** para Milestone 2, declarada
explícitamente como decisión de diseño y no como dato del enunciado.

## Alternativas consideradas

### Alternativa A: Una única base de datos transaccional compartida entre captura y reportes
- **Pros**: modelo más simple, sin proyección asíncrona, sin consistencia
  eventual que gestionar.
- **Contras**: las consultas agregadas del portal (potencialmente sobre 20
  campus, con visibilidad global — ASM-14) competirían directamente por
  bloqueos y recursos de I/O con la escritura de alto volumen de eventos de
  asistencia — exactamente el riesgo que `priorizacion.md` identifica para
  REQ-07.
- **Por qué no se eligió**: no resuelve la tensión explícita del enunciado
  entre near real-time (DRV-05) y la necesidad de reportes agregados
  (REQ-07) sin degradación mutua; el propio material del curso (`we4.md`)
  presenta CQRS como la respuesta arquitectónica directa a este patrón de
  carga (escritura intensiva + consultas complejas ocasionales).

## Consecuencias

**Positivas**
- La ruta de escritura de Captura de Asistencia nunca se ve afectada por el
  volumen o la complejidad de las consultas de reportes.
- Permite atender el matiz de ASM-13 (consultas históricas más lentas
  aceptables) con un almacén de menor costo, sin comprometer la ruta
  reciente.
- El SLA de ≤15s p95 da un criterio verificable para `architecture-tradeoff`
  y `architecture-risk` en Milestone 3.

**Negativas / deuda que se acepta**
- Consistencia eventual entre el evento de escritura y su reflejo en el
  modelo de lectura — el propio `we4.md` señala esto como "el problema de
  proyección asíncrena": si el proyector se atrasa, experimenta
  contrapresión y debe escalar horizontalmente para ponerse al día.
- Mayor complejidad de infraestructura (proyector, dos almacenes de lectura
  con distinto perfil de costo/latencia).

**Riesgos que quedan abiertos**
- El SLA de 15s p95 es una decisión de este equipo de diseño, no un dato
  validado por el enunciado ni por los stakeholders reales (solo
  simulados) — `architecture-risk` (Milestone 3) debería evaluar qué pasa
  si ese número resulta insuficiente para algún caso de uso operativo no
  cubierto por las preguntas de Milestone 1.

## Referencias
- `knowledge/we4.md` — CQRS como mecanismo de contrapresión, problema de
  proyección asíncrona.
- `knowledge/index.md` — síntesis transversal de CQRS (Semanas 3-4-5-6).
- `design/traceability.md` — DRV-04, DRV-05, REQ-07, REQ-08, REQ-11,
  ASM-06, ASM-12, ASM-13, ASM-14, AMB-01.
- `design/milestone-2/bounded-contexts.md` — contexto Reportes y Analítica.

## Nota de revisión — Milestone 3 (DEC-0013)

`design/adr/adr-0013-monolito-modular-fase1-extraccion-selectiva.md`
(`DEC-0013`) mantiene el SLA de proyección (≤15s p95 desde
`AttendanceRecorded`/`timestampRecibidoServidor`, ver ADR-0010) como meta de
diseño vigente, y mantiene la separación conceptual comandos/consultas
(CQRS) como principio interno de este ADR — Captura de Asistencia sigue
siendo el lado de escritura, Reportes y Analítica el lado de lectura, con
dos rutas diferenciadas por SLA (reciente/histórica).

Lo que cambia en Fase 1 es la **estrategia de implementación** para lograr
esa separación: en vez de un proyector alimentado por un broker de eventos
distribuido entre dos servicios independientes, la separación
lectura/escritura se logra con una estrategia más simple dentro del mismo
motor de base de datos del monolito — una **réplica de lectura o vista
materializada** actualizada de forma asíncrona (ej. triggers internos,
replicación lógica del propio motor, o un job del mismo job queue interno
usado para la Saga de ADR-0002/ADR-0007), sin requerir la infraestructura
de un broker de eventos distribuido para este propósito específico. El
anexo de estimación de carga pico de `architecture-decision.md` (~50-55
eventos/seg en el peor caso) sigue siendo la referencia de factibilidad: ese
volumen es sostenible tanto por un proyector vía broker como por una
réplica de lectura dentro de un único motor de base de datos bien
dimensionado.

En Fase 2, si Captura de Asistencia se extrae (trigger de ADR-0013), la
proyección vuelve a implementarse vía broker de eventos exactamente como
estaba prevista en la versión original de este ADR.
