# Registro de Trazabilidad

> Este archivo es sembrado exclusivamente por el Milestone 1
> (`design/milestone-1/discovery.md`). Los agentes de milestones posteriores
> **solo agregan columnas/valores a estas filas** (DEC, TO, RISK
> relacionados) — no crean filas nuevas de tipo `DRV`, `REQ`, `ASM` o `AMB`.
> Nota de normalización: donde el enunciado o material de referencia use
> "SNI", debe leerse como sinónimo de **NIS** (Servicio de Identificación
> Nacional), término canónico usado en `context/capstone.pdf`.
>
> Nota de reconciliación: tras completarse las respuestas a las preguntas de
> stakeholders simulados en `discovery.md`, se agregaron las filas ASM-06 a
> ASM-15 (supuestos derivados de esas respuestas) y se anotó, dentro de la
> descripción de las filas AMB-01, AMB-02, AMB-05, AMB-07 y AMB-09, el cambio
> de estado correspondiente (resuelta / parcialmente resuelta / matizada) y
> el ASM que la reemplaza cuando aplica. Ninguna fila AMB fue borrada.
>
> Nota de Milestone 2 (Iteración 1): se agregaron los `DEC-0001` a
> `DEC-0005` (ver sección "Decisiones (Milestone 2)" al final de este
> documento) y se completó la columna "DEC relacionadas" de las filas
> `DRV`/`REQ`/`ASM`/`AMB` que motivan cada decisión. No se creó, modificó ni
> borró ninguna fila `DRV`/`REQ`/`ASM`/`AMB` existente, conforme a la regla
> de este archivo. Las restricciones no negociables (`RST-01` a `RST-05`,
> definidas en `discovery.md`, "Restricciones no negociables") nunca fueron
> sembradas como filas de este archivo — solo `DRV`/`REQ`/`ASM`/`AMB` lo
> son. Los ADRs de Milestone 2 sí las citan directamente contra
> `discovery.md` donde corresponde (ej. RST-02, RST-04 en `adr-0002`; RST-03
> en `adr-0004`), pero deliberadamente no se listan como columna de este
> archivo para no crear una falsa impresión de que existen como filas
> trazables aquí.
>
> Nota de Milestone 2 (Iteración 2, post-revisión `architecture-reviewer`):
> se agregaron `DEC-0006` a `DEC-0012`, registrados en
> `design/adr/adr-0006-*.md` a `design/adr/adr-0012-*.md`, para resolver
> hallazgos de `design/milestone-2/review-log.md` (Iteración 1). Se
> completó la columna "DEC relacionadas" de las filas `DRV`/`REQ`/`ASM`/
> `AMB` que motivan cada nueva decisión, **agregando** valores a las celdas
> existentes, sin borrar ni reemplazar los `DEC` ya listados. No se creó,
> modificó ni borró ninguna fila `DRV`/`REQ`/`ASM`/`AMB` existente. El
> hallazgo de RST-01 (complejidad operacional de MSA+EDA para equipo de una
> persona) fue dirigido explícitamente por `architecture-reviewer` a
> `architecture-risk` (Milestone 3) y **no** se resuelve en esta iteración
> — queda anotado en `design/milestone-2/architecture-decision.md`
> ("Nota de Iteración 2") como pendiente.
>
> Nota de iteración extra (fuera del ciclo estándar de 2 iteraciones,
> autorizada explícitamente para cerrar un solo hallazgo de severidad Alta
> que quedó abierto tras la Iteración 2): `review-log.md` (Iteración 2)
> señaló que el mecanismo declarado en **DEC-0008**/`ADR-0008` para el
> refresco de caché de credenciales del Dispositivo DAS reutilizaba, por
> nombre, la API de validación **individual** por `dasId`
> (`GET /identity/{dasId}/credential/validate`), que no soporta
> `since=<timestamp>` ni lote — una contradicción funcional que, implementada
> tal cual, saturaría el Circuit Breaker del camino síncrono crítico de
> escaneo (`ADR-0006`). Se corrigió **exclusivamente la sección "Decisión"
> de `ADR-0008`** (no se creó un `ADR-0013` nuevo ni se modificó ningún otro
> `DEC`): el delta que consume el Dispositivo DAS ahora se sirve desde una
> proyección local de Captura de Asistencia
> (`CredencialesVigentesPorCampus`) construida por consumo asíncrono de
> `CredentialIssued`/`CredentialRevoked` (ya publicados por Identidad y
> Credenciales), con una nueva API de snapshot en lote de baja frecuencia
> (`GET /identity/credentials/snapshot`) reservada para arranque en
> frío/reconciliación diaria — nunca para el ciclo de 15 minutos por
> dispositivo. **`DEC-0008` conserva el mismo número, el mismo título y los
> mismos `DRV-03`, `DRV-05`, `REQ-06` que la motivan** (la corrección no
> cambia el "quién puede llamar a quién", ya resuelto en Iteración 2, solo
> el "cómo" del mecanismo interno) — no se agregan ni quitan valores en la
> columna "DEC relacionadas" de ninguna fila `DRV`/`REQ`/`ASM`/`AMB` por
> este cambio, ya que `DRV-03`, `DRV-05` y `REQ-06` ya listaban `DEC-0008`
> desde la Iteración 2. Ver `design/milestone-2/bounded-contexts.md` y
> `design/milestone-2/data-model-conceptual.md` (secciones "Nota de
> iteración extra") para el detalle completo.
>
> Nota de Milestone 3 (`architecture-tradeoff`): se agregaron los `TO-01` a
> `TO-20` (ver sección "Trade-offs (Milestone 3)" al final de este
> documento), formalizando en `design/milestone-3/tradeoff-matrix.md` la
> comparación de trade-offs sobre los cuatro ejes exactos que pide
> `plan/milestones.pdf` (Monolito vs. Microservicios, REST vs.
> Event-driven, base de datos relacional vs. híbrida, síncrono vs.
> asíncrono para attendance). Cada `TO-NN` corresponde a una fila (criterio
> × eje) de esa matriz y enlaza al `DEC-NNNN` de Milestone 2 del que se
> deriva — **no se generó ninguna alternativa nueva**: toda "opción
> descartada" de la matriz es una alternativa ya rechazada explícitamente en
> `design/milestone-2/architecture-decision.md` o en la sección
> "Alternativas consideradas" de los ADRs `0001` a `0012`. Se completó la
> columna "TO relacionados" únicamente de las filas `DRV`/`REQ` cuyo driver o
> requisito es evaluado directamente por al menos un criterio de la matriz,
> agregando valores sin borrar ni reemplazar los ya existentes. No se creó,
> modificó ni borró ninguna fila `DRV`/`REQ`/`ASM`/`AMB` existente, ni
> ninguna fila `DEC`. `tradeoff-matrix.md` señala explícitamente, como
> hallazgo propio (no resuelto allí), que el eje "REST vs. Event-driven" no
> tiene en Milestone 2 un ADR único de estilo de comunicación global —
> queda como vacío de especificidad para que `architecture-reviewer` decida
> si amerita una iteración adicional de Milestone 2.
>
> Nota de Milestone 3 (`architecture-risk`): se agregaron `RISK-01` a
> `RISK-15`, registrados en `design/milestone-3/risk-register.md` (con su
> plan de mitigación en `design/milestone-3/mitigation-plan.md`), y se
> completó la columna "RISK relacionados" de las filas `DRV`/`REQ`/`ASM`/
> `AMB` cuyo `DEC` asociado queda expuesto por al menos un riesgo, agregando
> valores sin borrar ni reemplazar los ya existentes. No se creó, modificó
> ni borró ninguna fila `DRV`/`REQ`/`ASM`/`AMB` existente, ni ninguna fila
> `DEC`/`TO`. `RISK-01` es la evaluación formal del hallazgo RST-01 que
> `architecture-reviewer` diferió explícitamente desde Milestone 2 (ver nota
> de Iteración 2 arriba) y queda marcado en `risk-register.md` como
> **"requiere revisión de diseño"** — no se resuelve aquí ni en el plan de
> mitigación; queda a criterio de `architecture-reviewer` si reabre
> Milestone 2 para evaluar un punto intermedio de complejidad frente a
> RST-01. `RISK-08` (usuario modifica su información tras iniciar la
> verificación) queda documentado como hallazgo de diseño abierto para
> `architecture-strategist` — decisión de negocio, no de estilo — sin
> marcarse como "requiere revisión de diseño" porque no afecta la elección
> de estilo ni los bounded contexts. Ver sección "Riesgos (Milestone 3)" al
> final de este documento.
>
> Nota de gate de Milestone 3 (Iteración 1, `architecture-reviewer`): el
> hallazgo `RISK-01` (RST-01) fue evaluado como bloqueante y **sí ameritó
> reapertura parcial y acotada de Milestone 2** (`design/milestone-3/review-log.md`,
> Iteración 1). `architecture-strategist` resolvió esto con **`DEC-0013`**
> (`design/adr/adr-0013-monolito-modular-fase1-extraccion-selectiva.md`),
> que reemplaza el alcance de "día 1" de `DEC-0001` (Monolito Modular por
> Bounded Context en Fase 1, con extracción selectiva vía Strangler Pattern
> en Fase 2) — ver `design/milestone-2/architecture-decision.md`, sección
> "Revisión — Milestone 3". Se agregó `DEC-0013` a la columna "DEC
> relacionadas" de `DRV-01` a `DRV-05`, `REQ-06` y `REQ-07` (los mismos IDs
> que motivan `DEC-0001`), sin quitar ningún `DEC` ya listado. El Hallazgo 2
> del mismo gate (vacío del eje "REST vs. Event-driven" en la matriz de
> trade-offs) se aceptó como está, sin cambios. El Hallazgo 3 (cobertura
> incompleta de riesgos de protección de datos personales) se resolvió con
> `RISK-16` y `RISK-17` nuevos, agregados por `architecture-risk` — ver
> nota siguiente.
>
> Nota de Milestone 3 (`architecture-risk`, corrección del Hallazgo 3 de
> `review-log.md` Iteración 1): se agregaron `RISK-16` y `RISK-17` (ver
> sección "Riesgos (Milestone 3)"), y se completó la columna "RISK
> relacionados" de `DRV-03`, `DRV-04`, `DRV-05`, `REQ-12`, `ASM-04`,
> `ASM-13` y `AMB-04`, agregando valores sin borrar los ya existentes.
>
> Nota de Milestone 2 (cierre de propagación de `DEC-0013`,
> `architecture-strategist`): conforme a la sección "Nota de impacto sobre
> decisiones existentes" de `ADR-0013`, se agregó la sección "## Nota de
> revisión — Milestone 3 (DEC-0013)" al final de
> `design/milestone-2/bounded-contexts.md`,
> `design/milestone-2/data-model-conceptual.md` y de los ADRs `0002`
> (mecanismo de la Saga: motor de flujo de trabajo dedicado → cola de
> trabajos interna), `0003` (proyección CQRS: broker de eventos → réplica
> de lectura/vista materializada dentro del mismo motor), `0004` (tiering
> de retención: tres almacenes especializados → un único motor de base de
> datos), `0006` (Circuit Breaker Captura↔Identidad: **en pausa**, no hay
> frontera de red en Fase 1), `0007` (integración NIS: solo cambia "quién"
> ejecuta el polling, un worker interno), `0008` (refresco de caché del
> Dispositivo DAS: **en pausa**, lectura directa sobre esquema compartido) y
> `0009` (revocación de credencial: se simplifica al no existir cachés
> distribuidas físicas que sincronizar). Ninguna decisión de fondo se
> reabrió: el criterio DDD de bounded contexts, el ownership lógico de cada
> entidad, y el contenido de la sección "Decisión" de cada ADR permanecen
> exactamente como fueron aceptados — cada nota deja constancia únicamente
> del cambio de mecanismo de implementación en Fase 1 y de la vigencia sin
> cambios del principio conceptual. Con esta pasada, estos siete
> artefactos quedan consistentes con `DEC-0013`.
>
> Nota de Milestone 3 (`architecture-tradeoff`, actualización post-`DEC-0013`):
> conforme al pendiente dejado por la nota anterior, se ajustó
> `design/milestone-3/tradeoff-matrix.md` contra `DEC-0013`/`ADR-0013`. El
> **Eje 1** se reformuló por completo (ya no compara Monolito vs. MSA+EDA
> completo como dos extremos estáticos, sino Monolito Modular Fase 1
> —elegida, `DEC-0013`— vs. Microservicios completos desde el día 1
> —descartada, `ADR-0001` Alt. 2 original / `ADR-0013` Alt. A—), resolviendo
> con esto el hallazgo propio que la matriz había dejado abierto en su
> primera pasada (falta de un punto intermedio de complejidad). El **Eje 2**
> se precisó con una nota de aplicabilidad por fase (la comparación
> Event-driven vs. REST síncrono documentada allí es la topología de
> destino, Fase 2; no aplica operativamente en Fase 1) — el vacío de fondo
> (ausencia de un ADR único de estilo de comunicación) sigue sin resolverse,
> conforme a lo ya decidido por `architecture-reviewer` en el gate de
> Iteración 1. El **Eje 4** se confirmó explícitamente: `DEC-0005` no
> cambia (nivel de dispositivo, frontera de red real independiente de la
> topología del backend); `DEC-0006` sí queda en pausa en Fase 1 y se anotó
> como matiz de la fila de Seguridad, sin cambiar la conclusión del eje. El
> **Eje 3** se confirmó explícitamente sin cambios de fondo (la nota de
> revisión de `ADR-0004` es solo sobre el "cómo" físico del tiering en Fase
> 1). Se agregó `DEC-0013` a la columna "DEC relacionada" de `TO-01` a
> `TO-10`, `TO-11` a `TO-15`, `TO-17` y `TO-20` (ver sección "Trade-offs
> (Milestone 3)" abajo), agregando valores sin borrar los `DEC` ya
> listados; `TO-16`, `TO-18` y `TO-19` no se modificaron porque dependen
> únicamente de `DEC-0005`, sin impacto estructural confirmado por
> `ADR-0013`. No se creó, modificó ni borró ninguna fila `DRV`/`REQ`/`ASM`/
> `AMB`/`DEC` existente. Se señalan dos hallazgos menores, no bloqueantes,
> para `architecture-reviewer`: (1) una inconsistencia de redacción entre
> el Eje 1 y el Eje 3 de la matriz sobre el carácter físico vs. lógico de
> "Base de Datos por Servicio" en Fase 1; (2) `DEC-0006` queda en pausa en
> Fase 1 sin frontera de red que proteger, documentado ahora también en la
> matriz (no solo en `ADR-0013`). Ninguno de los dos cambia ninguna
> conclusión de eje ni amerita, por sí solo, una nueva reapertura de
> Milestone 2. **Pendiente, fuera de este alcance**: `design/diagrams/`
> (los diagramas C4 existentes asumen los 5 servicios desplegados
> independientemente desde el día 1) sigue correspondiendo a
> `architecture-modeler`.
>
> **Sigue pendiente, fuera del alcance de `architecture-strategist`**:
> `design/milestone-3/tradeoff-matrix.md` (Ejes 1, 2 y parcialmente 4, que
> comparan la Alternativa 2 completa sin la Fase 1 de extracción selectiva)
> — **ya resuelto por la nota de `architecture-tradeoff` de arriba** — y
> `design/diagrams/` (los diagramas C4 existentes asumen los 5 servicios
> desplegados independientemente desde el día 1) — corresponde a
> `architecture-modeler`, sigue pendiente.
>
> Nota de Milestone 2 (corrección puntual, `architecture-strategist`, tras
> `design/milestone-3/review-log.md`, "Cierre de cascada DEC-0013", segundo
> hallazgo bloqueante, severidad Alta): la eliminación de API Gateway y BFF
> Web/Móvil de los diagramas de Fase 1 había sido una instrucción de dibujo
> del orquestador, nunca ratificada por una decisión de arquitectura propia
> — contradiciendo a `design/milestone-2/bounded-contexts.md` (sección
> "Componentes transversales", sin matiz de fase) y dejando sin resolver
> dónde vive la autenticación de App Móvil/Portal Web en Fase 1 (impacto no
> evaluado sobre `DRV-03`). Se agregó **`DEC-0014`**
> (`design/adr/adr-0014-middleware-autenticacion-monolito-fase1.md`): ratifica
> la ausencia de API Gateway/BFF como componentes desplegados en Fase 1 y
> define un Middleware de Autenticación (Módulo de Seguridad transversal)
> dentro del propio monolito, con Identidad y Credenciales como emisor de
> sesión. Se agregó `DEC-0014` a la columna "DEC relacionadas" de `DRV-03` y
> `REQ-09`, agregando el valor sin quitar los `DEC` ya listados. Se
> agregaron a `design/milestone-2/bounded-contexts.md` la nota de vigencia
> por fase en "Componentes transversales" y la sección "Nota de revisión —
> Milestone 3 (DEC-0014)" al final del documento. **Pendiente, fuera de este
> alcance**: `c4-container.mmd`/`c4-component.mmd` no representan todavía el
> Middleware de Autenticación como componente explícito — corresponde a
> `architecture-modeler`.
>
> Nota de Milestone 1 (corrección puntual, 24-08-2026, sin reapertura de
> Milestone 2/3): se corrigió `RST-01` en `discovery.md`, "Restricciones no
> negociables". La redacción original ("El proyecto es individual",
> `plan/milestones.pdf`, "Otros — Tamaño del equipo") fue usada en cascada
> por `DEC-0013`/`ADR-0013` y por `RISK-01` como si el sistema DAS fuera a
> ser diseñado, desplegado y operado por una sola persona de forma
> permanente. El usuario aclaró explícitamente que la condición de
> "individual" en `plan/milestones.pdf` se refiere únicamente a la
> **entrega académica** del capstone, no a la operación real del sistema
> DAS. `RST-01` queda reformulado: (a) se documenta, separado y fuera de la
> lista de restricciones de diseño, que la entrega individual del capstone
> es una condición de evaluación académica sin implicancia arquitectónica; y
> (b) se fija como restricción operativa real que el sistema DAS debe ser
> operable por un **equipo pequeño de desarrollo (3 a 5 personas)**, sin
> equipos de plataforma/DevOps/SRE dedicados por servicio — con el rango
> numérico explícitamente marcado como el orden de magnitud indicado por el
> usuario, no como un dato exacto de `capstone.pdf`. Como ya establece la
> nota original de Iteración 1 de este archivo, `RST-01` nunca fue una fila
> de esta tabla (las restricciones se citan directamente en `discovery.md` y
> en los ADRs), por lo que esta corrección no modifica ninguna fila
> `DRV`/`REQ`/`ASM`/`AMB`/`DEC`/`TO`/`RISK` existente. **Esta nota deja
> explícitamente como pendiente, fuera del alcance de Milestone 1**, que
> `architecture-strategist` evalúe si la justificación de `DEC-0013`/
> `ADR-0013` (y, transitivamente, el tratamiento de `RISK-01` en
> `risk-register.md`) sigue sosteniéndose sin cambios bajo la restricción
> corregida (equipo de 3 a 5 desarrolladores, en vez de una sola persona) o
> si amerita un ajuste de matiz en su justificación — sin que esto implique,
> por sí solo, que la decisión de fondo (Monolito Modular en Fase 1) deba
> cambiar.
>
> Nota de Milestone 2 (cierre de la reevaluación de RST-01,
> `architecture-strategist`, 24-08-2026): en respuesta al pendiente dejado
> por la nota anterior, se reevaluó con criterio propio — sin asumir el
> mismo resultado por inercia — si `DEC-0013`/`ADR-0013` (Monolito Modular
> Fase 1 + extracción selectiva Fase 2) seguía siendo la decisión más
> defendible bajo la restricción real corregida (equipo de desarrollo
> pequeño, 3 a 5 personas, sin equipos de plataforma/DevOps/SRE dedicados por
> servicio), o si un equipo de ese tamaño podría razonablemente operar la
> arquitectura distribuida completa (5 microservicios + broker + motor de
> Saga + persistencia políglota) desde el día 1. **Conclusión: la decisión se
> mantiene sin cambios de fondo.** La condición que hace desproporcionado
> operar 5 microservicios+broker+motor de Saga+persistencia políglota desde
> el día 1 no es el número exacto de desarrolladores (1 vs. 3-5), sino la
> ausencia de equipos de plataforma/DevOps/SRE dedicados — precondición
> organizacional de adopción de MSA señalada por `knowledge/we5.md`
> ("empezar pequeño", "invertir en infraestructura") que un equipo de 3 a 5
> desarrolladores generalistas tampoco cumple, aunque sí podría, a
> diferencia de una sola persona, paralelizar el *diseño* del código de 5
> servicios. Lo que cambia es exclusivamente la severidad del argumento (de
> "imposible para un individuo" a "carga operativa desproporcionada para un
> equipo chico sin esa infraestructura organizacional, frente a un volumen
> real —~50-55 eventos/seg pico— que no exige distribución física desde el
> día 1"), no la dirección de la decisión. Se actualizaron
> `design/adr/adr-0013-monolito-modular-fase1-extraccion-selectiva.md`
> (nueva sección "Nota de reevaluación") y
> `design/milestone-2/architecture-decision.md` (secciones "Alternativa 1",
> "Alternativa 2" y "Revisión — Milestone 3", con una nueva subsección de
> corrección), reemplazando toda referencia textual a "una sola
> persona"/"un solo desarrollador" por la restricción real corregida.
> `DEC-0013` **no cambia de número, título ni de los `DRV`/`REQ` que la
> motivan** — sigue siendo exactamente la misma decisión, solo se corrige su
> justificación textual; no se modifica ninguna fila `DRV`/`REQ`/`ASM`/`AMB`
> existente por esta corrección. **Pendiente, fuera de este alcance, para
> `architecture-risk`**: `design/milestone-3/risk-register.md` (`RISK-01`,
> título y cuerpo) y la fila `RISK-01` de la sección "Riesgos (Milestone 3)"
> de este mismo archivo (más abajo) todavía citan "un equipo de una
> persona"/"una sola persona" — requieren el mismo ajuste textual, sin
> cambio de tratamiento (sigue "Resuelto").

| ID | Tipo | Descripción | Originado en | DEC relacionadas | TO relacionados | RISK relacionados |
|---|---|---|---|---|---|---|
| DRV-01 | Driver | Escalabilidad y rendimiento: soportar ~10.000 usuarios nuevos en 2 años (de ~5.000 a ~15.000) manteniendo rendimiento eficiente | capstone.pdf, "Requerimientos no funcionales" | DEC-0001, DEC-0013 | TO-01, TO-06, TO-11, TO-16 | RISK-01, RISK-11, RISK-12, RISK-15 |
| DRV-02 | Driver | Integración asíncrona con NIS: verificación externa vía API, no en tiempo real, hasta 2 horas de latencia | capstone.pdf, "Autorregistro a través de un portal en línea" y "(cont.)" | DEC-0001, DEC-0002, DEC-0007, DEC-0012, DEC-0013 | TO-06, TO-07, TO-09 | RISK-02, RISK-06, RISK-07 |
| DRV-03 | Driver | Seguridad y confidencialidad: "los datos del DAS deben ser confidenciales y seguros" | capstone.pdf, "Portal web administrativo" | DEC-0001, DEC-0006, DEC-0008, DEC-0009, DEC-0011, DEC-0013, DEC-0014 | TO-05, TO-10, TO-15, TO-20 | RISK-13, RISK-14, RISK-15, RISK-16 |
| DRV-04 | Driver | Retención de 5 años: los registros de asistencia deben conservarse un mínimo de 5 años por requisito legal | capstone.pdf, "Requerimientos no funcionales" | DEC-0001, DEC-0003, DEC-0004, DEC-0011, DEC-0013 | TO-11, TO-12, TO-13, TO-14, TO-15 | RISK-16, RISK-17 |
| DRV-05 | Driver | Asistencia casi en tiempo real (near real-time attendance): el registro de entrada/salida debe ser lo más cercano posible al tiempo real | capstone.pdf, "Requerimientos no funcionales" | DEC-0001, DEC-0003, DEC-0004, DEC-0005, DEC-0006, DEC-0008, DEC-0010, DEC-0013 | TO-04, TO-09, TO-16, TO-17, TO-18, TO-19, TO-20 | RISK-10, RISK-11, RISK-15, RISK-17 |
| REQ-01 | Requisito | DAS ID único por usuario (estudiante o profesor), verificable digitalmente desde app móvil, con datos personales y seguimiento de asistencia | capstone.pdf, "Identificación del usuario mediante DAS ID" | DEC-0001 | | |
| REQ-02 | Requisito | Autorregistro vía app móvil con documento de identidad oficial, fotografía y datos personales | capstone.pdf, "Autorregistro a través de un portal en línea" | DEC-0001, DEC-0002, DEC-0012 | | RISK-06, RISK-08 |
| REQ-03 | Requisito | Verificación a distancia con el NIS, basada en API, para garantizar exactitud de datos | capstone.pdf, "Autorregistro a través de un portal en línea" | DEC-0002, DEC-0007 | | RISK-02 |
| REQ-04 | Requisito | Verificación NIS no en tiempo real (hasta 2h) + aprobación adicional del personal administrativo | capstone.pdf, "Autorregistro a través de un portal en línea (cont.)" | DEC-0002, DEC-0007 | | RISK-04, RISK-05 |
| REQ-05 | Requisito | Emisión de Insignia DAS (física o en móvil) tras registro y verificación NIS exitosos | capstone.pdf, "Creación de la Insignia DAS" | DEC-0001 | | |
| REQ-06 | Requisito | Captura de asistencia (entrada/salida) por dispositivo DAS en cada campus, almacenada por usuario, día y ubicación | capstone.pdf, "Proceso de registro de entrada y salida" | DEC-0001, DEC-0003, DEC-0005, DEC-0006, DEC-0008, DEC-0010, DEC-0013 | TO-16, TO-17, TO-18, TO-19, TO-20 | RISK-09, RISK-10, RISK-11 |
| REQ-07 | Requisito | Portal administrativo web con reportes, estadísticas de asistencia y gestión de cursos/eventos | capstone.pdf, "Portal web administrativo" | DEC-0001, DEC-0003, DEC-0013 | TO-11, TO-12, TO-13, TO-14, TO-15 | RISK-12 |
| REQ-08 | Requisito | Consulta del propio estado de asistencia por parte del usuario vía app móvil DAS | capstone.pdf, "Portal web administrativo" | DEC-0003 | | |
| REQ-09 | Requisito | Confidencialidad y seguridad de los datos del DAS | capstone.pdf, "Portal web administrativo" | DEC-0001, DEC-0009, DEC-0014 | | RISK-14 |
| REQ-10 | Requisito | Soportar crecimiento de ~10.000 usuarios nuevos en 2 años manteniendo rendimiento eficiente | capstone.pdf, "Requerimientos no funcionales" | DEC-0001 | | RISK-12 |
| REQ-11 | Requisito | Registro de entrada/salida lo más cercano posible al tiempo real | capstone.pdf, "Requerimientos no funcionales" | DEC-0003 | | |
| REQ-12 | Requisito | Retención mínima de 5 años de los registros de asistencia por requisito legal | capstone.pdf, "Requerimientos no funcionales" | DEC-0004 | | RISK-17 |
| ASM-01 | Supuesto | El NIS es un sistema externo a UPCA, fuera del control operativo del equipo de diseño (SLA/disponibilidad/API no negociables) | discovery.md | DEC-0002, DEC-0007, DEC-0012 | | RISK-02, RISK-06, RISK-07 |
| ASM-02 | Supuesto | Las 10 ciudades y 20 campus de UPCA están dentro de un mismo país / jurisdicción, cubiertos por un único NIS | discovery.md | | | |
| ASM-03 | Supuesto | El crecimiento de ~10.000 usuarios se distribuye sobre los 20 campus existentes, sin apertura de nuevas sedes en el período | discovery.md | | | RISK-12 |
| ASM-04 | Supuesto | La retención de 5 años aplica, como mínimo, a los eventos de asistencia (usuario, fecha, ubicación, entrada/salida) | discovery.md | DEC-0004 | | RISK-17 |
| ASM-05 | Supuesto | La verificación digital del DAS ID desde la app (consulta) es una capacidad distinta del escaneo físico de la Insignia/tarjeta en captura de asistencia | discovery.md | | | RISK-13 |
| ASM-06 | Supuesto | Los stakeholders simulados priorizan exactitud/confiabilidad del registro por sobre la velocidad exacta de reflejo (demora de segundos aceptable si el dato final es correcto); resuelve parcialmente AMB-01 | discovery.md (respuesta Estudiante) | DEC-0003 | | |
| ASM-07 | Supuesto | Ante pérdida de conectividad de un dispositivo DAS, la asistencia real no debe perderse; debe existir registro posterior/manual (reemplaza a AMB-02) | discovery.md (respuestas Estudiante y Profesor) | DEC-0005, DEC-0010 | | RISK-09, RISK-10, RISK-11 |
| ASM-08 | Supuesto | Durante la espera de verificación NIS y aprobación administrativa, el usuario espera visibilidad explícita del estado de su solicitud (pendiente/verificado-pendiente aprobación/aprobado/rechazado) | discovery.md (respuesta Estudiante/Profesor) | DEC-0002 | | RISK-05 |
| ASM-09 | Supuesto | La Insignia DAS debe funcionar en todos los campus/ciudades de UPCA sin trámites adicionales, incluso para profesores multi-campus | discovery.md (respuesta Estudiante/Profesor) | DEC-0001 | | |
| ASM-10 | Supuesto | El personal administrativo necesita ver información personal, documentos, calidad de documentos, evidencia de matrícula/condiciones y situación administrativa para aprobar/rechazar un registro ya verificado por el NIS | discovery.md (respuesta Personal Administrativo) | DEC-0002 | | |
| ASM-11 | Supuesto | Ante rechazo de un registro (NIS o administrativo), el usuario debe ser notificado, idealmente con el motivo del rechazo; resuelve parcialmente AMB-05 | discovery.md (respuesta Personal Administrativo) | DEC-0002 | | RISK-03, RISK-04 |
| ASM-12 | Supuesto | Los reportes del portal administrativo deben actualizarse "suficientemente rápido" para reflejar la situación operativa actual; una actualización diaria es insuficiente; resuelve parcialmente AMB-01 | discovery.md (respuesta Personal Administrativo) | DEC-0003 | | |
| ASM-13 | Supuesto | Es aceptable que las consultas de registros históricos (años anteriores) sean más lentas que las del día en curso, siempre que la información permanezca disponible | discovery.md (respuesta Personal Administrativo) | DEC-0003, DEC-0004 | | RISK-17 |
| ASM-14 | Supuesto | El personal administrativo necesita visibilidad sobre todos los campus y ciudades de UPCA, no solo el propio (reemplaza a AMB-09) | discovery.md (respuesta Personal Administrativo) | DEC-0003 | | |
| ASM-15 | Supuesto | Si el NIS no responde en 2h, se espera: alerta al personal administrativo, notificación de demora al usuario, solicitud permanece pendiente, y mecanismo de reintento | discovery.md (respuesta Personal Administrativo) | DEC-0002, DEC-0007 | | RISK-02, RISK-05 |
| AMB-01 | Ambigüedad abierta | No hay umbral numérico definido para "near real-time" en el registro de entrada/salida. **Parcialmente resuelta**: señal cualitativa obtenida vía respuestas de stakeholders simulados (aplica también al portal, prioridad en exactitud sobre velocidad) — ver ASM-06, ASM-12 — pero el número exacto sigue sin definirse. **Milestone 2 fija un valor de diseño (≤15s p95 de proyección) en DEC-0003**, declarado explícitamente como decisión, no como dato del enunciado. Iteración 2: `DEC-0010` precisa que el SLA se mide desde `timestampRecibidoServidor`, no desde el reloj del dispositivo; `architecture-decision.md` (anexo) documenta una estimación de carga pico que respalda la factibilidad de esa cifra | discovery.md | DEC-0003, DEC-0010 | | RISK-12 |
| AMB-02 | Ambigüedad abierta | No se especifica el comportamiento de los dispositivos DAS ante pérdida de conectividad. **RESUELTA** a nivel de expectativa funcional → reemplazada por ASM-07; el mecanismo técnico concreto se define en **DEC-0005**, precisado en **DEC-0010** (clave de idempotencia) | discovery.md | DEC-0005, DEC-0010 | | RISK-09, RISK-10, RISK-11 |
| AMB-03 | Ambigüedad abierta | Relación no aclarada entre "Insignia DAS" y "tarjeta DAS" (mismo artefacto vs. artefactos distintos). Sigue abierta; `design/milestone-2/data-model-conceptual.md` documenta el supuesto de modelado adoptado para poder avanzar (mismo artefacto, atributo `formato`) | discovery.md | DEC-0001 | | |
| AMB-04 | Ambigüedad abierta | Alcance exacto de los datos sujetos a la retención de 5 años (solo eventos de asistencia vs. también documentos/fotos de registro). Sin cambios: ninguna respuesta de stakeholders simulados aborda el alcance (ver ASM-13 para un matiz distinto, sobre velocidad de consulta histórica, no sobre alcance). **DEC-0004 aplica la retención por capas únicamente a eventos de asistencia**, dejando explícitamente abierto el caso de documentos/fotos. Iteración 2: **DEC-0011 fija un valor de diseño por defecto (180 días / 1 año en sospecha de fraude)**, marcado explícitamente como placeholder operativo sujeto a validación con el instructor — la ambigüedad legal de fondo sigue formalmente abierta. Milestone 3: **RISK-16** registra formalmente el riesgo de que ese placeholder no sea validado legalmente antes de producción; **RISK-17** registra el riesgo de falla operativa silenciosa del mecanismo de transición por capas de **DEC-0004** | discovery.md | DEC-0004, DEC-0011 | | RISK-16, RISK-17 |
| AMB-05 | Ambigüedad abierta | Orden/dependencia no definidos entre verificación NIS y aprobación administrativa, y qué ocurre ante rechazo de cualquiera de las dos. **Parcialmente resuelta**: el manejo de rechazo y de timeout del NIS ahora tiene expectativa funcional vía stakeholders simulados — ver ASM-11, ASM-15 — pero el orden/dependencia estricta entre NIS y aprobación administrativa sigue sin confirmarse. **DEC-0002 asume explícitamente un orden secuencial NIS → aprobación administrativa** como supuesto de diseño. Iteración 2: **DEC-0007** especifica además el modelo de entrega (polling), la idempotencia de resultados entrantes y el tope de reintentos de ese mismo flujo | discovery.md | DEC-0002, DEC-0007 | | RISK-03, RISK-05 |
| AMB-06 | Ambigüedad abierta | No se especifica si las 10 ciudades están en un mismo país, ni si el crecimiento previsto implica nuevas ciudades/campus | discovery.md | | | RISK-11 |
| AMB-07 | Ambigüedad abierta | No se define qué constituye un "evento" de asistencia (registro por clase/evento vs. registro único diario por campus). **Matizada, no resuelta**: respuesta del Profesor simulado sugiere interés en granularidad por clase, sin confirmar el modelo de datos subyacente. `design/milestone-2/data-model-conceptual.md` documenta el supuesto de modelado adoptado (registro independiente por escaneo) | discovery.md | | | |
| AMB-08 | Ambigüedad abierta | No se especifica el mecanismo técnico de lectura de la Insignia/tarjeta DAS por el dispositivo de captura | discovery.md | | | |
| AMB-09 | Ambigüedad abierta | No se define si el personal administrativo ve solo su campus o toda la red UPCA (aislamiento de datos). **RESUELTA** → reemplazada por ASM-14; el personal administrativo requiere visibilidad global, con posible matiz de roles/permisos no profundizado. Implementada en **DEC-0003** (vista `EstadisticasGlobalUPCA`) | discovery.md | DEC-0003 | | |

## Decisiones (Milestone 2)

> Cada `DEC-NNNN` corresponde exactamente al ADR del mismo número en
> `design/adr/`. Ver también `design/milestone-2/architecture-decision.md`,
> `design/milestone-2/bounded-contexts.md` y
> `design/milestone-2/data-model-conceptual.md`. La columna "DRV/REQ/ASM/AMB
> que motivan la decisión" solo lista IDs que existen como filas en la
> tabla de arriba; las restricciones `RST-NN` que también motivan estas
> decisiones se citan directamente en el ADR correspondiente contra
> `discovery.md`, no aquí.

| DEC | Título | ADR | DRV/REQ/ASM/AMB que motivan la decisión |
|---|---|---|---|
| DEC-0001 | Adoptar Microservicios por Bounded Context con Arquitectura Dirigida por Eventos (MSA + EDA), sobre Monolito Modular | `design/adr/adr-0001-estilo-arquitectonico-msa-eda.md` | DRV-01, DRV-02, DRV-03, DRV-04, DRV-05, REQ-01, REQ-02, REQ-05, REQ-06, REQ-07, REQ-09, REQ-10, ASM-09, AMB-03 |
| DEC-0002 | Modelar el registro/verificación NIS como Saga orquestada (Proceso de Larga Duración) | `design/adr/adr-0002-saga-orquestada-nis.md` | DRV-02, REQ-02, REQ-03, REQ-04, ASM-01, ASM-08, ASM-10, ASM-11, ASM-15, AMB-05 |
| DEC-0003 | Separar escritura de asistencia y lectura de reportes con CQRS; fijar SLA de proyección ≤15s p95 | `design/adr/adr-0003-cqrs-reportes.md` | DRV-04, DRV-05, REQ-06, REQ-07, REQ-08, REQ-11, ASM-06, ASM-12, ASM-13, ASM-14, AMB-01, AMB-09 |
| DEC-0004 | Retención de eventos de asistencia por capas (caliente/tibio/frío) | `design/adr/adr-0004-retencion-por-capas.md` | DRV-04, DRV-05, REQ-12, ASM-04, ASM-13, AMB-04 |
| DEC-0005 | Captura de asistencia tolerante a desconexión mediante buffer local + consumidor idempotente | `design/adr/adr-0005-captura-offline-tolerante.md` | DRV-05, REQ-06, ASM-07, AMB-02 |
| DEC-0006 | Circuit Breaker (fail-open acotado) en la dependencia síncrona Captura de Asistencia → Identidad y Credenciales (backend-a-backend) | `design/adr/adr-0006-circuit-breaker-captura-identidad.md` | DRV-03, DRV-05, REQ-06 |
| DEC-0007 | Contrato de integración con el NIS: polling con backoff, idempotencia de resultados entrantes y tope de reintentos con escalamiento manual | `design/adr/adr-0007-integracion-nis-polling-idempotencia-reintentos.md` | DRV-02, REQ-03, REQ-04, ASM-01, ASM-15, AMB-05 |
| DEC-0008 | Refresco de caché de credencial del Dispositivo DAS vía Captura de Asistencia (no directo a Identidad). **Mecanismo interno corregido en iteración extra**: el delta se sirve desde una proyección local de Captura (`CredencialesVigentesPorCampus`) construida por consumo asíncrono de `CredentialIssued`/`CredentialRevoked`, con un snapshot en lote de baja frecuencia en Identidad reservado a arranque en frío/reconciliación — ya no se reutiliza la API de validación individual (`GET /identity/{dasId}/credential/validate`) para construir el delta | `design/adr/adr-0008-refresco-cache-dispositivo-via-captura.md` | DRV-03, DRV-05, REQ-06 |
| DEC-0009 | Revocación de credencial: evento `CredentialRevoked`, API de revocación y propagación de caché con TTL | `design/adr/adr-0009-revocacion-credencial.md` | DRV-03, REQ-09 |
| DEC-0010 | Especificación de la clave de idempotencia de eventos de asistencia (agrega dirección) y origen del timestamp de medición del SLA | `design/adr/adr-0010-idempotencia-clave-asistencia.md` | DRV-05, REQ-06, ASM-07, AMB-01, AMB-02 |
| DEC-0011 | Retención por defecto (placeholder de diseño) para documentos y fotos de `SolicitudDeRegistro` | `design/adr/adr-0011-retencion-default-documentos-registro.md` | DRV-03, DRV-04, AMB-04 |
| DEC-0012 | Idempotencia en el envío inicial de autorregistro (`POST /registrations`) | `design/adr/adr-0012-idempotencia-post-registrations.md` | REQ-02, DRV-02, ASM-01 |
| DEC-0013 | Reemplazar el alcance de "día 1" de DEC-0001: Monolito Modular por Bounded Context en Fase 1 (mismos 5 bounded contexts como módulos internos), con extracción selectiva vía Strangler Pattern en Fase 2, activada por triggers verificables — resuelve RISK-01/RST-01 (Milestone 3, gate de reapertura parcial) | `design/adr/adr-0013-monolito-modular-fase1-extraccion-selectiva.md` | DRV-01, DRV-02, DRV-03, DRV-04, DRV-05, REQ-06, REQ-07 (y RST-01, citada directamente contra `discovery.md`, no como fila de este archivo) |
| DEC-0014 | Middleware de Autenticación transversal dentro del monolito (sin API Gateway/BFF en Fase 1): ratifica con fundamento propio la ausencia de Gateway/BFF de Fase 1 y define dónde vive la autenticación de App Móvil/Portal Web — Identidad y Credenciales como emisor de sesión (`POST /identity/sessions`), middleware AOP-style como punto único de validación/autorización dentro del único desplegable. Resuelve el segundo hallazgo bloqueante de `design/milestone-3/review-log.md`, "Cierre de cascada DEC-0013" | `design/adr/adr-0014-middleware-autenticacion-monolito-fase1.md` | DRV-03, REQ-09 (y RST-01, citada directamente contra `discovery.md`, no como fila de este archivo) |

## Trade-offs (Milestone 3)

> Cada `TO-NN` corresponde a una fila (eje × criterio) de la matriz formal en
> `design/milestone-3/tradeoff-matrix.md`. La columna "Alternativa
> descartada" cita la fuente exacta de Milestone 2 de la que proviene —
> nunca una alternativa nueva generada en Milestone 3. Tras la actualización
> post-`DEC-0013` (ver nota arriba), la columna "DEC relacionada" de
> `TO-01` a `TO-10`, `TO-11` a `TO-15`, `TO-17` y `TO-20` agrega `DEC-0013`
> sin quitar los `DEC` ya listados; `TO-16`, `TO-18` y `TO-19` no cambian
> porque dependen únicamente de `DEC-0005`, sin impacto estructural.

| TO | Eje | Criterio | DEC relacionada | Alternativa descartada (fuente M2) |
|---|---|---|---|---|
| TO-01 | Monolito Modular Fase 1 vs. Microservicios día 1 | Escalabilidad | DEC-0001, DEC-0013 | Microservicios completos día 1, `adr-0001` Alt. 2 original / `adr-0013` Alt. A |
| TO-02 | Monolito Modular Fase 1 vs. Microservicios día 1 | Complejidad operativa | DEC-0001, DEC-0013 | idem |
| TO-03 | Monolito Modular Fase 1 vs. Microservicios día 1 | Costo (~estimado) | DEC-0001, DEC-0013 | idem |
| TO-04 | Monolito Modular Fase 1 vs. Microservicios día 1 | Rendimiento | DEC-0001, DEC-0013 | idem |
| TO-05 | Monolito Modular Fase 1 vs. Microservicios día 1 | Seguridad | DEC-0001, DEC-0013 | idem |
| TO-06 | REST vs. Event-driven (vigente desde Fase 2) | Escalabilidad | DEC-0001, DEC-0008, DEC-0013 | `adr-0008`, Alternativa C (REST síncrono en lote) |
| TO-07 | REST vs. Event-driven (vigente desde Fase 2) | Complejidad operativa | DEC-0008, DEC-0013 | `adr-0008`, Alternativa C |
| TO-08 | REST vs. Event-driven (vigente desde Fase 2) | Costo (~estimado) | DEC-0001, DEC-0013 | `adr-0008`, Alternativa C |
| TO-09 | REST vs. Event-driven (vigente desde Fase 2) | Rendimiento | DEC-0006, DEC-0008, DEC-0013 | `adr-0008`, Alternativa B (versión original rechazada en iteración extra) |
| TO-10 | REST vs. Event-driven (vigente desde Fase 2) | Seguridad | DEC-0006, DEC-0007, DEC-0013 | `adr-0006`; `adr-0007` (polling retenido sobre webhook para el NIS) |
| TO-11 | Relacional vs. Híbrida | Escalabilidad | DEC-0004, DEC-0013 | `adr-0004`, Alternativa A (almacén homogéneo único) |
| TO-12 | Relacional vs. Híbrida | Complejidad operativa | DEC-0004, DEC-0013 | idem |
| TO-13 | Relacional vs. Híbrida | Costo (~estimado) | DEC-0004, DEC-0013 | idem |
| TO-14 | Relacional vs. Híbrida | Rendimiento | DEC-0003, DEC-0004, DEC-0013 | idem |
| TO-15 | Relacional vs. Híbrida | Seguridad | DEC-0001, DEC-0004, DEC-0013 | idem |
| TO-16 | Síncrono vs. Asíncrono (attendance) | Escalabilidad | DEC-0005 | `adr-0005`, Alternativa A (captura estrictamente online) |
| TO-17 | Síncrono vs. Asíncrono (attendance) | Complejidad operativa | DEC-0005, DEC-0006, DEC-0013 | idem |
| TO-18 | Síncrono vs. Asíncrono (attendance) | Costo (~estimado) | DEC-0005 | idem |
| TO-19 | Síncrono vs. Asíncrono (attendance) | Rendimiento | DEC-0005 | idem |
| TO-20 | Síncrono vs. Asíncrono (attendance) | Seguridad | DEC-0005, DEC-0006, DEC-0013 | idem |

## Riesgos (Milestone 3)

> Cada `RISK-NN` está desarrollado en detalle en
> `design/milestone-3/risk-register.md` (escenario, probabilidad, impacto,
> mitigación anclada en `knowledge/`, con semana y concepto), y agrupado por
> tipo de mitigación en `design/milestone-3/mitigation-plan.md`. Esta tabla
> solo resume el `DEC` que cada riesgo afecta y su tratamiento — no duplica
> el contenido completo del registro.

| RISK | Título | DEC afectada | Tratamiento |
|---|---|---|---|
| RISK-01 | Complejidad operativa plena de MSA+EDA para un equipo pequeño sin infraestructura de plataforma/DevOps/SRE dedicada (RST-01, 3-5 desarrolladores) | DEC-0001 (y transitivamente DEC-0002 a DEC-0012) | **Resuelto** — `architecture-reviewer` confirmó que ameritaba reapertura de diseño; `architecture-strategist` respondió con **DEC-0013** (Monolito Modular Fase 1 + extracción selectiva Fase 2 vía Strangler Pattern), y propagó la consecuencia con notas de revisión en `bounded-contexts.md`, `data-model-conceptual.md` y los ADRs `0002`, `0003`, `0004`, `0006`, `0007`, `0008`, `0009`. `design/milestone-3/tradeoff-matrix.md` ya refleja `DEC-0013` en su Eje 1. Pendiente, fuera de este alcance: `design/diagrams/` (`architecture-modeler`). **Corrección (24-08-2026)**: `RST-01` fue corregida de "una sola persona" a "equipo pequeño (3-5 desarrolladores), sin plataforma/DevOps/SRE dedicada" — `architecture-strategist` reevaluó y confirmó que `DEC-0013` se mantiene sin cambios de fondo bajo la restricción real (ver `design/adr/adr-0013-*.md`, sección "Nota de reevaluación"); el tratamiento ("Resuelto") no cambia |
| RISK-02 | El NIS tarda más de las 2h esperadas o no está disponible más allá del tope de reintentos | DEC-0002, DEC-0007 | Mitigado parcialmente por diseño existente (ADR-0007); mitigación adicional propuesta (alerta escalonada + observabilidad) |
| RISK-03 | La verificación del NIS es rechazada, sin vía de reintento declarada | DEC-0002, DEC-0012 | Mitigación aditiva (documentar reintento vía `Idempotency-Key` nueva) |
| RISK-04 | El correo de confirmación no llega | DEC-0002 | Sin ADR previo — mitigación aditiva propuesta (retry + DLQ) |
| RISK-05 | El personal administrativo no aprueba el registro | DEC-0002 | Mitigación aditiva propuesta (alerta escalonada, mismo patrón que ASM-15) |
| RISK-06 | Usuario reintenta el registro mientras hay una verificación en curso | DEC-0007, DEC-0012 | Mitigado en gran medida (ADR-0012); ajuste aditivo propuesto sobre `escalado_manual` |
| RISK-07 | Respuesta duplicada del NIS | DEC-0007 | Ya mitigado (ADR-0007) — documentado por completitud |
| RISK-08 | Usuario modifica su información después de iniciar la verificación | DEC-0002 | Hallazgo de diseño abierto para `architecture-strategist` (decisión de negocio, no de estilo) |
| RISK-09 | Buffer local del Dispositivo DAS sin tamaño máximo ni política de purga | DEC-0005 | Abierto desde ADR-0005 (severidad Media) — mitigación aditiva propuesta (backpressure + load shedding) |
| RISK-10 | Tormenta de reconciliación al recuperar conectividad masiva | DEC-0005, DEC-0006 | Mitigación aditiva propuesta (retry con jitter + Bulkhead) |
| RISK-11 | Pérdida de conectividad de un campus completo hacia los servicios centrales | DEC-0005, DEC-0001 | Mecanismo funcional ya cubierto; mitigación de escala (RISK-09 + RISK-10 + observabilidad) |
| RISK-12 | Escalamiento a ~15.000 usuarios no soportado en la práctica | DEC-0003, DEC-0001 | Mitigado parcialmente por diseño (CQRS autoescalable); mitigación adicional (prototipo de carga + observabilidad) |
| RISK-13 | ASM-05 sin decisión/API dedicada | (sin DEC dedicada) | Severidad Baja — ajuste de documentación |
| RISK-14 | Ventana de exposición de credencial revocada coincide con incidente de backend | DEC-0006, DEC-0009 | Ya mitigado parcialmente (TTL + invalidación activa); mitigación adicional (alerta correlacionada) |
| RISK-15 | Broker de eventos como dependencia compartida por múltiples mecanismos de resiliencia | DEC-0001 | Riesgo transversal — infraestructura + observabilidad, no cambia el estilo |
| RISK-16 | Placeholder de retención de documentos/fotos de registro (DEC-0011) sin validación legal antes de producción | DEC-0011 (transitivamente AMB-04) | No se resuelve con un patrón de resiliencia — checkpoint de validación de cumplimiento normativo, con riesgo residual documentado si no se confirma antes de producción real |
| RISK-17 | Falla operativa silenciosa del mecanismo de transición por capas de retención (DEC-0004) | DEC-0004 | Mitigado con patrones de resiliencia ya presentes en el vocabulario del registro: PLD explícito/comprobable, Idempotent Consumer, DLQ y observabilidad sobre el propio job de migración |
