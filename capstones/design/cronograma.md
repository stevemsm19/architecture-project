# Cronograma del Capstone DAS/UPCA

## Tabla de Milestones

| # | Milestone | Objetivo cognitivo | Entregables | Fecha objetivo | Estado |
|---|---|---|---|---|---|
| 1 | Descubrimiento Arquitectónico | Pasar de un enunciado ambiguo a drivers priorizados | Documento 3-5 páginas + tabla de priorización + evidencia de prompting IA | <pendiente de definir por el estudiante> | Hecho |
| 2 | Diseño Arquitectónico Base | Transformar drivers en estructura concreta | Estilo justificado + C4 N1-N3 + bounded contexts + ADRs + evidencia IA | <pendiente de definir por el estudiante> | Hecho |
| 3 | Trade-offs, Calidad y Riesgos | Demostrar madurez arquitectónica (justificar, no diseñar) | Trade-off analysis + riesgos técnicos + plan de mitigación + cronograma con hitos arquitectónicos | <pendiente de definir por el estudiante> | En curso |
| 4 | Síntesis Final y Comunicación | Apropiación intelectual y defensa del diseño | Documento final integrado + presentación 15-20 min + reflexión crítica sobre IA | <pendiente de definir por el estudiante> | Pendiente |

## Hitos arquitectónicos específicos (de Milestone 3)

| Hito | Descripción | Depende de | Fecha objetivo | Estado |
|---|---|---|---|---|
| Spike técnico NIS | Prototipo o prueba de concepto de la integración con el NIS (cliente mínimo contra el NIS real o su documentación de API, para confirmar modelo de entrega, formato de `nisVerificationId` y comportamiento real ante timeout repetido). Condición previa para dar por cerrados con confianza operacional **RISK-02**, **RISK-06** y **RISK-07** | Decisión arquitectónica (`design/milestone-2/architecture-decision.md`, ADR-0002, ADR-0007) | <pendiente de definir por el estudiante> | Pendiente |
| Diseño validado | Arquitectura auditada sin hallazgos abiertos de severidad alta. Incluye la resolución explícita (por `architecture-reviewer`) de **RISK-01** (marcado "requiere revisión de diseño" — decide si reabre Milestone 2 para evaluar un punto intermedio de complejidad frente a RST-01) y del hallazgo de diseño abierto **RISK-08** (edición de solicitud en curso, a decidir por `architecture-strategist`); también cierra **RISK-13** (ASM-05 sin API dedicada, ajuste de documentación) | Gate de `architecture-reviewer` sin hallazgos nuevos (M2 y M3) | <pendiente de definir por el estudiante> | Pendiente |
| Modelo de datos estable | Modelo de datos conceptual congelado, incluyendo estrategia de retención por capas. Incorpora los campos/estructuras aditivas propuestas para **RISK-09** (tamaño máximo y política de purga del buffer local del Dispositivo DAS, abierto desde ADR-0005) y para **RISK-04** (máquina de estados de entrega en `RegistroDeNotificacion`) | Milestone 2 | <pendiente de definir por el estudiante> | Pendiente |
| Prototipo de captura | Validación del flujo de check-in/check-out (real o simulado) bajo la carga pico estimada en el Anexo de `architecture-decision.md`, incluyendo el escenario de reconexión masiva. Valida **RISK-10**, **RISK-11** y **RISK-12** con evidencia operacional, no solo con la estimación de diseño | Diseño validado | <pendiente de definir por el estudiante> | Pendiente |

## Registro de Riesgos

Esta tabla resume `design/milestone-3/risk-register.md` — no lo dupliques
entero acá, solo referencialo.

| Riesgo | Probabilidad | Impacto | Estrategia de mitigación | Referencia |
|---|---|---|---|---|
| Complejidad operativa plena de MSA+EDA para un equipo de una persona (RST-01) | Alta | Alta | No se resuelve con un patrón de resiliencia — requiere revisión de diseño por `architecture-reviewer` (¿reabrir Milestone 2 para un punto intermedio de complejidad?) | RISK-01 |
| Integración con NIS más lenta/inestable de lo esperado, más allá del tope de reintentos | Media | Alta | Retry con backoff exponencial + jitter e Idempotent Consumer (ya en ADR-0007); alerta escalonada sobre la cola `escalado_manual`; logging de tasa real de éxito del NIS | RISK-02 |
| Verificación del NIS rechazada, sin vía de reintento declarada | Media | Media | Documentar `POST /registrations` con nueva `Idempotency-Key` como vía soportada de reintento (ya funciona por diseño de ADR-0012) | RISK-03 |
| Correo de confirmación no entregado | Media | Media | Retry con backoff + Dead Letter Queue en el contexto Notificaciones; canal alternativo (push) como respaldo | RISK-04 |
| Personal administrativo no aprueba el registro (cola `pendiente_admin` sin SLA) | Media | Media | Mismo patrón de alerta escalonada que ya tiene el timeout del NIS, extendido al tramo de aprobación administrativa | RISK-05 |
| Usuario reintenta el registro mientras hay una verificación en curso | Baja-Media | Media | Idempotent Consumer (ADR-0012); extender la excepción de deduplicación a `escalado_manual` | RISK-06 |
| Respuesta duplicada del NIS | Baja (mitigado) | Baja (mitigado) | Idempotent Consumer + Dead Letter Queue (ya implementado en ADR-0007) | RISK-07 |
| Usuario modifica su información después de iniciar la verificación | Media | Media | No resuelto por ningún mecanismo existente — hallazgo de diseño abierto para `architecture-strategist` (decisión de negocio, no de estilo) | RISK-08 |
| Dispositivos DAS offline: buffer local sin tamaño máximo ni política de purga | Baja-Media | Alta | Backpressure con límite explícito + load shedding priorizado + alerta de umbral (`we4.md`) | RISK-09 |
| Tormenta de reconciliación al recuperar conectividad masiva | Baja-Media | Media | Retry con jitter + Bulkhead entre sincronización masiva y escaneo en vivo | RISK-10 |
| Pérdida de conectividad de un campus completo hacia los servicios centrales | Baja | Alta | Mecanismo funcional ya cubierto (ADR-0005); mitigación de escala: RISK-09 + RISK-10 + alerta de "campus sin heartbeat" | RISK-11 |
| Escalamiento a 10k-15k usuarios nuevos no soportado en la práctica | Media | Media | CQRS con proyector autoescalable (ya en ADR-0003); prototipo de carga + observabilidad de throughput real vs. estimado | RISK-12 |
| Protección de datos personales: ASM-05 sin decisión/API dedicada | Baja | Baja | Ajuste de documentación — declarar `GET /identity/{dasId}` como API que satisface ASM-05 | RISK-13 |
| Protección de datos personales: ventana de exposición de credencial revocada (TTL 15 min) coincide con incidente de backend | Baja | Media | Ya mitigado parcialmente (ADR-0006/ADR-0009); alerta correlacionada Circuit Breaker Abierto + revocación reciente | RISK-14 |
| Broker de eventos como dependencia compartida por múltiples mecanismos de resiliencia | Baja | Alta | No requiere cambiar el estilo — infraestructura (clustering) + logging & observabilidad de salud del broker | RISK-15 |
