# ADR-0012: Idempotencia en el envío inicial de autorregistro (`POST /registrations`)

## Estado
Aceptado

## Contexto
A diferencia de `POST /attendance-events` (que sí define
`claveIdempotencia` explícitamente, ver ADR-0005/ADR-0010),
`bounded-contexts.md` y `data-model-conceptual.md` no definían ningún
mecanismo de idempotencia para el envío inicial de autorregistro
(**REQ-02**). Un candidato en un campus con conectividad inestable podría
reenviar el formulario (timeout del cliente, doble tap en la app) y el
sistema crearía dos `SolicitudDeRegistro` independientes para la misma
persona, cada una disparando su propia Saga y potencialmente su propia
verificación NIS duplicada contra un tercero cuyo costo/SLA no se controla
(**ASM-01**, **DRV-02**). `knowledge/we3.md`/`we7.md` desarrollan
Idempotent Consumer como el mecanismo del curso para este tipo de
escenario.

## Decisión
`POST /registrations` requiere un header `Idempotency-Key` generado por el
cliente (app móvil) por intento de envío (ej. UUID persistido localmente
mientras dura el intento, reutilizado en reintentos de red/timeout del
cliente). Registro y Verificación deduplica:

- Si ya existe una `SolicitudDeRegistro` con la misma `Idempotency-Key` →
  devuelve el `registroId` existente (200) en vez de crear una nueva Saga.
- Como resguardo adicional (no como mecanismo primario, por la condición de
  carrera de un reintento inmediato antes de que el primer registro
  complete su escritura), se deduplica también por (`documentoRef` hash +
  `correo`) dentro de una ventana de 24h, solo si la solicitud existente
  está en un estado **no terminal**.

## Alternativas consideradas

### Alternativa A: Deduplicar solo por (documento + correo), sin `Idempotency-Key` explícita
- **Contras**: no cubre el caso de reintento inmediato antes de que el
  primer registro complete su escritura (condición de carrera).
- **Por qué no se eligió**: se mantiene como resguardo secundario, no como
  mecanismo primario — insuficiente por sí solo.

### Alternativa B: No deduplicar (dejar que el personal administrativo filtre duplicados manualmente)
- **Contras**: dispara verificaciones NIS duplicadas contra un tercero no
  negociable (ASM-01), con posible costo/carga innecesarios sobre un
  servicio cuyo comportamiento y costo no se controlan.
- **Por qué no se eligió**: traslada al personal administrativo un problema
  que el propio diseño puede evitar en el origen.

## Consecuencias

**Positivas**
- Evita Sagas duplicadas y verificaciones NIS redundantes para la misma
  persona.
- Consistente con el patrón de idempotencia ya usado en
  `POST /attendance-events` (ADR-0005/ADR-0010) — mismo criterio aplicado
  de forma uniforme en las dos APIs de escritura expuestas a clientes con
  conectividad no confiable.

**Negativas / deuda que se acepta**
- El cliente (app móvil) debe generar y persistir la clave durante el
  intento de envío — complejidad adicional menor en el cliente.

## Referencias
- `knowledge/we3.md`, `knowledge/we7.md` — Idempotent Consumer.
- `design/traceability.md` — REQ-02, DRV-02, ASM-01.
- `design/adr/adr-0005-captura-offline-tolerante.md`,
  `design/adr/adr-0010-idempotencia-clave-asistencia.md` — mismo patrón
  aplicado a Captura de Asistencia.
- `design/milestone-2/bounded-contexts.md` — contexto Registro y
  Verificación, API `POST /registrations`.
- `design/milestone-2/review-log.md` — Iteración 1, hallazgo
  "`POST /registrations` sin clave de idempotencia definida".
