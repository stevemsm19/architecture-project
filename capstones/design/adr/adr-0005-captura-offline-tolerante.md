# ADR-0005: Captura de asistencia tolerante a desconexión mediante buffer local + consumidor idempotente

## Estado
Aceptado

## Contexto
El enunciado no especifica qué debe ocurrir si un dispositivo DAS pierde
conectividad (ambigüedad original **AMB-02**). Las respuestas de los
stakeholders simulados resuelven la expectativa funcional: la asistencia
real de un usuario no debe perderse, debe existir una vía de registro
posterior, incluyendo registro manual por parte del profesor cuando el
dispositivo no funciona (**ASM-07**, que reemplaza a AMB-02 a nivel de
expectativa funcional). El mecanismo técnico concreto queda explícitamente
abierto para Milestone 2 en adelante. Adicionalmente, la validación de
credencial en cada escaneo (Identidad y Credenciales, `bounded-contexts.md`)
no debería depender de una llamada síncrona que bloquee la captura si el
dispositivo está desconectado de la red interna aunque tenga conectividad
local. `knowledge/we3.md`/`we4.md` (Semanas 3-4) desarrollan Idempotencia,
Dead Letter Queue y contrapresión vía colas como los mecanismos del curso
para este tipo de escenario; `knowledge/we7.md` desarrolla Retry con
backoff exponencial y jitter.

## Decisión
Cada dispositivo DAS mantiene un buffer/cola local de eventos de asistencia
capturados mientras no hay conectividad, junto con una caché local de
credenciales válidas (refrescada periódicamente desde Identidad y
Credenciales, patrón Conformista/Servicio Host Abierto — ver
`bounded-contexts.md`) para poder validar un escaneo sin depender de una
llamada síncrona en el momento. Al recuperar conectividad, el dispositivo
sincroniza el buffer mediante `POST /attendance-events/batch`, marcando
cada evento con `modoCaptura = offline_retroactivo` y una clave de
idempotencia (dispositivo + timestamp de escaneo) para que reintentos o
duplicados de red no generen registros duplicados (Idempotent Consumer). El
registro manual del profesor (ASM-07) se modela como un canal de entrada
adicional al mismo endpoint, con el mismo contrato de idempotencia.

## Alternativas consideradas

### Alternativa A: Captura estrictamente online (sin buffer local, sin caché de credencial)
- **Pros**: modelo más simple, sin lógica de sincronización posterior ni
  de resolución de duplicados.
- **Contras**: contradice directamente la expectativa funcional confirmada
  por los stakeholders simulados en ASM-07 ("esperaría que mi asistencia no
  se pierda... el sistema debería poder registrar posteriormente que
  asistí"); un evento no capturado durante una caída de conectividad se
  perdería sin posibilidad de recuperación.
- **Por qué no se eligió**: viola un supuesto funcional explícito derivado
  directamente de las respuestas de los stakeholders simulados
  (Estudiante y Profesor), que Milestone 1 documenta como resolución de
  AMB-02.

## Consecuencias

**Positivas**
- Satisface ASM-07 sin ambigüedad: ningún evento de asistencia real se
  pierde por una caída de conectividad del dispositivo.
- La caché local de credenciales evita que la validación de identidad se
  convierta en un punto de fallo síncrono para la captura, reforzando
  DRV-05 (near real-time) incluso ante degradación parcial de red.
- La clave de idempotencia protege contra duplicados tanto en reintentos de
  red como en la sincronización diferida del buffer offline.

**Negativas / deuda que se acepta**
- La caché local de credenciales puede quedar desactualizada (ej. una
  credencial revocada) durante el período sin conectividad — se acepta como
  trade-off entre disponibilidad de captura y exactitud inmediata de
  revocación; requiere una política de expiración/refresco de caché a
  definir en detalle en una iteración posterior.
- Requiere lógica adicional en el dispositivo DAS (fuera del backend
  puro) para el buffer y la clave de idempotencia.

**Riesgos que quedan abiertos**
- El mecanismo técnico exacto del buffer (tamaño máximo, política de
  purga si el dispositivo permanece offline más allá de cierto tiempo) no
  está definido por el enunciado ni por los stakeholders simulados — queda
  como decisión de detalle para una iteración posterior, no cubierta por
  este ADR.

## Referencias
- `knowledge/we3.md`, `knowledge/we4.md` — Idempotencia, Dead Letter Queue,
  contrapresión vía colas.
- `knowledge/we7.md` — Retry con backoff exponencial y jitter, Idempotent
  Consumer.
- `design/traceability.md` — ASM-07 (reemplaza AMB-02), DRV-05, REQ-06.
- `design/milestone-2/bounded-contexts.md` — contexto Captura de
  Asistencia.
- `design/milestone-2/data-model-conceptual.md` — entidad
  `EventoDeAsistencia`, campo `modoCaptura`.
