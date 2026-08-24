# Review Log — Milestone 3 (Skeptic Review)

## Iteración 1 — 2026-08-23

Auditoría de estructura primero (`tradeoff-matrix.md`, `risk-register.md`,
`mitigation-plan.md`, `cronograma.md`, `traceability.md`), consistencia
contra `design/milestone-2/architecture-decision.md`, `design/adr/adr-0001-*`
a `adr-0012-*` y `design/milestone-2/review-log.md` leída después, y por
último `plan/milestones.pdf` para verificar que las 4 categorías de
mitigación y las 4 categorías de riesgo exigidas ("Integración con SNI",
"Dispositivos SAD offline/pérdida de conectividad", "Protección de datos
personales", "Escalamiento 10k usuarios") estén realmente cubiertas, no solo
nombradas. No es `SIN HALLAZGOS NUEVOS`: es la primera corrida de este gate
y hay una decisión explícita que este agente debía tomar (RISK-01) más
hallazgos nuevos de cobertura.

---

### [Decisión de gate] RISK-01 (RST-01) — SÍ amerita reapertura parcial de Milestone 2

- **ID relacionado**: RST-01 (`discovery.md`) / DEC-0001 (y transitivamente
  DEC-0002 a DEC-0012) / RISK-01
- **Qué falta o es ambiguo**: `risk-register.md` marca RISK-01 explícitamente
  "REQUIERE REVISIÓN DE DISEÑO" y deja la decisión a este agente. Mi
  veredicto, con evidencia concreta, es que **sí amerita reabrir Milestone 2
  en modo parcial**, acotado exclusivamente a `ADR-0001` /
  `architecture-decision.md` (no a bounded contexts, no al modelo de datos,
  no a los ADR-0002 a ADR-0012), por las siguientes razones verificables:
  1. Es el **único** riesgo de todo `risk-register.md` con Probabilidad
     **Alta** e Impacto **Alta** simultáneos — el punto más severo del
     registro completo (15 riesgos), no uno más entre otros.
  2. La misma restricción quedó sin resolver a través de **tres
     checkpoints consecutivos** sin que ninguno la cerrara: (a)
     `design/milestone-2/review-log.md` Iteración 1 la marca severidad Alta
     y la devuelve a `architecture-risk`, no la resuelve; (b)
     `architecture-decision.md` ("Nota de Iteración 2") admite
     textualmente que el trade-off "se agrava levemente" en la segunda
     iteración de M2, sin resolverlo; (c) `risk-register.md` (M3) la
     confirma sin resolver y la vuelve a marcar como pendiente de decisión.
     Tres pasadas de revisión y ninguna produjo una decisión — es un patrón
     de riesgo pospuesto, no de riesgo evaluado y aceptado conscientemente.
  3. El propio `risk-register.md` señala que `architecture-strategist`
     "solo comparó dos extremos (monolito modular completo vs. MSA+EDA
     completo)... no exploró ningún punto intermedio de complejidad" — este
     no es un déficit de mitigación operacional (algo que un patrón de
     resiliencia pueda resolver, como sí ocurre con RISK-02 a RISK-15), es
     un déficit en el **conjunto de alternativas evaluadas** en la decisión
     de estilo fundacional, exactamente el tipo de gap que corresponde
     resolver en Milestone 2, no mitigar en Milestone 3.
  4. `knowledge/we5.md` (citado por el propio `risk-register.md`) recomienda
     "empezar pequeño" como precondición de adopción de MSA, y `knowledge/we6.md`
     advierte contra el anti-patrón de "monolito distribuido" — ambos
     conceptos ya están en la base de conocimiento curada del curso, por lo
     que evaluar un punto intermedio no requiere ningún supuesto fuera del
     curso, solo aplicar herramientas ya citadas en `ADR-0001`.
  5. La pregunta de rúbrica 6 (`knowledge/rubric-questions.md`, sección C)
     exige poder responder "¿Por qué se eligió este estilo arquitectónico y
     no un monolito modular?" contra la restricción **no negociable** más
     limitante del proyecto (equipo de una persona). `ADR-0001` responde esa
     pregunta solo a nivel de los dos extremos, nunca contra la variante de
     complejidad intermedia que RST-01 específicamente demanda — la defensa
     actual del estilo elegido queda estructuralmente incompleta frente a
     esa restricción.
- **Escenario de falla**: si este hallazgo se acepta sin más como "riesgo
  conocido" y se avanza directo a Milestone 4, el estudiante llega a la
  defensa final sin haber evaluado nunca formalmente si un monolito modular
  por bounded context (evolucionando luego vía Strangler Pattern hacia MSA
  donde el perfil de carga lo justifique, p. ej. Captura de Asistencia) era
  una alternativa más defendible contra RST-01 — quedando expuesto
  exactamente en la pregunta de rúbrica 6 sin una respuesta completa.
- **Severidad**: Alta
- **A quién se devuelve**: `architecture-strategist`, en una reapertura
  **parcial** de Milestone 2 (no una vuelta completa del ciclo de 2
  iteraciones ya cerrado) — acotada a agregar, dentro de `ADR-0001` y
  `architecture-decision.md`, una evaluación formal de al menos una
  alternativa de complejidad intermedia contra RST-01 específicamente (no
  contra "escalabilidad" o "seguridad" en general, que ya están bien
  cubiertas), con una decisión explícita — aunque la decisión final siga
  siendo MSA+EDA completo, debe quedar defendida contra esta restricción
  puntual, no solo contra el binario monolito-completo/MSA-completo.

---

### [Trade-off / vacío de especificidad] Eje 2 (REST vs. Event-driven) sin ADR único — aceptable como limitación documentada, no bloqueante

- **ID relacionado**: DEC-0001, DEC-0006, DEC-0007, DEC-0008 / TO-06 a TO-10
- **Qué falta o es ambiguo**: confirmado — Milestone 2 nunca produjo un ADR
  único que compare "REST" vs. "Event-driven" como estilo de comunicación
  global; la evidencia usada por `tradeoff-matrix.md` para este eje está
  dispersa en `ADR-0006`, `ADR-0007` y `ADR-0008`, interacción por
  interacción.
- **Evaluación**: a diferencia de RISK-01, este vacío **no** amerita
  devolver la matriz completa ni reabrir Milestone 2 ahora, porque: (a) es
  metodológicamente sano — usa evidencia real ya decidida en M2, no fabrica
  una alternativa de paja, como el propio documento aclara explícitamente
  en su "Nota de alcance"; (b) las cinco filas de la tabla del Eje 2 son
  internamente consistentes entre sí y con `ADR-0006`/`ADR-0007`/`ADR-0008`
  (verificado citando líneas concretas de cada ADR, sin contradicciones); (c)
  es un vacío de **consolidación documental**, no de sustancia — las
  decisiones granulares (REST retenido en validación de credencial y en NIS,
  eventos como columna vertebral en el resto) ya existen y ya están
  justificadas individualmente.
- **Escenario de falla (si se ignora indefinidamente)**: sin un ADR
  consolidado, un lector nuevo del diseño (o el propio estudiante en la
  defensa de Milestone 4) no tiene un único lugar donde encontrar "por qué
  Event-driven y no REST" a nivel de estilo global — debe reconstruirlo
  cruzando tres ADRs distintos, lo cual es viable pero fricciona la defensa
  ante la pregunta de rúbrica 8 ("¿Qué beneficio concreto obtiene el sistema
  de la arquitectura elegida, y qué costo introduce?").
- **Severidad**: Media (no bloqueante para cerrar este gate)
- **A quién se devuelve**: `architecture-strategist`, como mejora aditiva de
  documentación (idealmente en la **misma** pasada de reapertura parcial que
  atienda RISK-01, ya que ambas tocan `ADR-0001`/`architecture-decision.md`,
  evitando dos reaperturas separadas) — no bloquea el cierre de este gate de
  Milestone 3.

---

### [Cobertura de riesgo obligatoria — "Protección de datos personales"] Sin ningún RISK-NN sobre retención de documentos/fotos (AMB-04) ni sobre el mecanismo de tiering (DEC-0004)

- **ID relacionado**: DRV-03, DRV-04, AMB-04 / DEC-0004, DEC-0011
- **Qué falta o es ambiguo**: `plan/milestones.pdf` (Milestone 3, "Análisis
  de riesgos técnicos") exige explícitamente una categoría de riesgo
  "Protección de datos personales". En `risk-register.md`, lo único que cae
  bajo esa categoría son **RISK-13** (severidad Baja, gap de documentación
  de API) y **RISK-14** (severidad Baja-Media, ventana de TTL de
  revocación). Ningún `RISK-NN` evalúa el riesgo, repetidamente señalado en
  el propio diseño, de que **AMB-04 (alcance de retención de documentos/
  fotos de `SolicitudDeRegistro`) sigue formalmente abierta** — `DEC-0011`
  solo fija un placeholder (180 días / 1 año si hay sospecha de fraude)
  "sujeto a validación con el instructor", y ese placeholder nunca fue
  evaluado como riesgo (¿qué pasa si el valor real exigido por ley es
  distinto? ¿qué pasa si nadie valida el placeholder antes de producción?).
  Tampoco existe ningún `RISK-NN` sobre el mecanismo operativo de la
  retención por capas de `DEC-0004` en sí (transición automatizada
  caliente→tibio→frío) — a pesar de que el propio `tradeoff-matrix.md` (Eje
  3, fila "Complejidad operativa") ya identifica ese mecanismo como "mayor:
  requiere proceso automatizado de transición entre capas" y como una
  "lógica de tiering con costo operativo propio" (fila "Costo") — exactamente
  el tipo de mecanismo nuevo que en otros ejes del diseño (buffer local de
  `ADR-0005` → RISK-09; broker de eventos → RISK-15) sí generó su propio
  `RISK-NN`, pero aquí no.
- **Escenario de falla**: el job de migración automatizada entre capas falla
  silenciosamente para un subconjunto de `EventoDeAsistencia` (ej. un
  batch nocturno que no corre, o corre parcialmente), y esos registros
  quedan en un estado intermedio no auditado ni alertado — nadie lo detecta
  porque no hay ningún riesgo (ni mitigación de observabilidad) definido
  para ese mecanismo específico, a diferencia de todos los demás mecanismos
  nuevos introducidos en Iteración 2 de M2, que sí tienen su contraparte de
  riesgo en M3.
- **Severidad**: Media
- **A quién se devuelve**: `architecture-risk`, para agregar como mínimo un
  `RISK-NN` nuevo bajo la categoría "Protección de datos personales" que
  cubra (a) el riesgo de que el placeholder de `DEC-0011` no sea validado
  legalmente antes de producción, y (b) el riesgo operativo del mecanismo de
  tiering de `DEC-0004` (falla silenciosa de migración, inconsistencia
  durante la ventana de transición) — no bloqueante para cerrar este gate
  específico, pero debe quedar cerrado antes de Milestone 4 dado que
  "Protección de datos personales" es una de las cuatro categorías
  explícitamente exigidas por `plan/milestones.pdf` y hoy queda
  parcialmente cubierta.

---

### Puntos verificados sin hallazgos

- **RISK-08 (usuario modifica datos tras iniciar verificación) —
  clasificación de severidad y tratamiento correctos, no bloqueante**:
  verificado que `risk-register.md` lo distingue explícitamente de RISK-01
  ("no se marca como 'requiere revisión de diseño' a nivel de
  `architecture-reviewer`, a diferencia de RISK-01") y lo devuelve a
  `architecture-strategist` como decisión de negocio (no de estilo). Coincido
  con esa clasificación: Probabilidad Media / Impacto Media es razonable —
  no compromete integridad de datos (`SolicitudDeRegistro` no tiene ninguna
  API de `PUT`/`PATCH` documentada, confirmado en `data-model-conceptual.md`
  vía la cita del propio riesgo) ni viola ningún NFR de seguridad/retención;
  es una brecha de UX/proceso, con dos caminos de solución ya esbozados
  (bloquear edición vs. permitir edición pre-Saga) que no requieren tocar
  bounded contexts ni el estilo MSA+EDA. Aceptable como hallazgo de diseño
  abierto para una iteración de detalle, no bloqueante para este gate.

- **Sin decisiones huérfanas en `traceability.md` (Milestone 2 → 3)**:
  verificado que cada `DEC-0001` a `DEC-0012` tiene su columna "DRV/REQ/ASM/
  AMB que motivan la decisión" poblada con filas que existen realmente en la
  tabla principal (`design/traceability.md`, sección "Decisiones (Milestone
  2)", líneas 171-184) — no hay ningún `DEC-NNNN` sin origen.

- **Sin drivers/requisitos abandonados al llegar a Milestone 3**: verificado
  que `DRV-01` a `DRV-05` y `REQ-01` a `REQ-12` tienen al menos una `DEC`
  en su columna "DEC relacionadas" (`design/traceability.md`, líneas
  118-134) — ninguno quedó sin decisión que lo atienda.

- **Todo `TO-NN` (01-20) y `RISK-NN` (01-15) tiene un `DEC` de origen
  explícito, salvo una excepción ya documentada como tal**: verificado en
  `design/traceability.md`, secciones "Trade-offs (Milestone 3)" (líneas
  193-214) y "Riesgos (Milestone 3)" (líneas 225-241). La única excepción es
  `RISK-13` ("sin DEC dedicada"), que no es una omisión nueva de Milestone 3
  sino la formalización explícita de un gap de trazabilidad ya señalado por
  `architecture-reviewer` en Milestone 2 (severidad Baja, sin cambios) —
  correctamente marcada como tal, no oculta.

- **Sin contradicciones sustantivas entre `tradeoff-matrix.md` y
  `risk-register.md`**: verificado punto por punto en los cuatro ejes —
  donde ambos documentos tocan el mismo mecanismo (ej. broker de eventos:
  tradeoff matrix lo presenta como beneficio de desacoplamiento en el Eje 2,
  risk-register lo presenta como SPOF transversal en RISK-15; TTL de
  revocación: tradeoff matrix lo acepta como trade-off de seguridad en el
  Eje 2, risk-register lo detalla como ventana de exposición en RISK-14) no
  hay contradicción — son lecturas complementarias del mismo trade-off desde
  ángulos distintos (costo/beneficio de diseño vs. escenario operacional de
  falla), consistente con la separación de alcance que ambos documentos
  declaran explícitamente en sus propias notas de cabecera.

- **Las cuatro categorías de mitigación exigidas por `plan/milestones.pdf`
  están todas presentes y con contenido real, no solo nombradas**:
  verificado contra el PDF (Milestone 3, "Plan de mitigación": Prototipo
  temprano de integración, Fallback authentication, Estrategia de reintento,
  Logging & observabilidad) — las cuatro secciones de `mitigation-plan.md`
  corresponden exactamente y cada una cita mecanismos concretos con su
  `RISK-NN` y su fundamento en `knowledge/`.

---

### Cierre de esta iteración

No corresponde `SIN HALLAZGOS NUEVOS` — es la Iteración 1 de este gate y hay
tres hallazgos: uno de severidad Alta (RISK-01, con decisión explícita de
reapertura parcial de Milestone 2) y dos de severidad Media (vacío de
especificidad del Eje 2, no bloqueante; cobertura incompleta de la categoría
obligatoria "Protección de datos personales" en el registro de riesgos).
Cap de iteraciones para este gate = 3; esta es la 1ª. Corresponde iterar
sobre los tres hallazgos (priorizando RISK-01 por ser el único bloqueante
real) antes de la próxima corrida de auditoría.

---

## Cierre de cascada DEC-0013 — 2026-08-23

Corrida de cierre de la reapertura parcial autorizada en la Iteración 1
(RISK-01/RST-01), explícitamente más allá del cap estándar de 3 iteraciones
de este gate — se documenta el estado final con lo que quedó resuelto y lo
que queda como riesgo conocido, no se itera una cuarta vez sobre este mismo
ciclo.

**Método**: auditoría de estructura primero (releídos completos, en este
orden: `traceability.md`, `architecture-decision.md` sección "Revisión —
Milestone 3", `ADR-0013`, `tradeoff-matrix.md`, `bounded-contexts.md` y
`data-model-conceptual.md` secciones "Nota de revisión — Milestone 3",
`ADR-0006` completo como muestra de los siete ADRs con nota de revisión,
`design/diagrams/NOTES.md` completo, `c4-container.mmd`, `c4-component.mmd`,
`c4-component-refresco-credenciales.mmd`) — y solo después `risk-register.md`
y `mitigation-plan.md` completos, para no validar por sesgo de aprobación la
narrativa de "cascada completa" que `traceability.md` afirma.

No corresponde `SIN HALLAZGOS NUEVOS`. Hay **dos hallazgos bloqueantes
reales** (no estilísticos) que la cascada dejó sin cerrar, y una
confirmación de que dos de los seis puntos pedidos están efectivamente bien
resueltos.

---

### [Bloqueante] `risk-register.md` y `mitigation-plan.md` nunca se actualizaron contra `DEC-0013` — contradicen directamente a `traceability.md`

- **ID relacionado**: RISK-01, RISK-10, RISK-14, RISK-15 / DEC-0013
- **Qué falta o es ambiguo**: `design/traceability.md` (nota de gate de
  Milestone 3, Iteración 1) afirma textualmente que RISK-01 quedó
  "**Resuelto**" por `DEC-0013`, y la fila `RISK-01` de la sección "Riesgos
  (Milestone 3)" repite "**Resuelto**". Pero `design/milestone-3/risk-register.md`
  — el documento primario, no el resumen — **no fue tocado en ningún
  carácter** por la cascada de `DEC-0013`: su entrada `[RISK-01]` sigue
  diciendo textualmente "**Marcado explícitamente: REQUIERE REVISIÓN DE
  DISEÑO** — se documenta aquí para que `architecture-reviewer` decida si
  reabre Milestone 2" (líneas 81-84 del documento), sin ninguna nota
  posterior que reconozca que esa decisión ya se tomó y ya se resolvió. Lo
  mismo ocurre en `design/milestone-3/mitigation-plan.md`, sección "Nota:
  riesgos que no se resuelven con este plan" (líneas 204-216): sigue
  describiendo a RISK-01 en presente, sin cerrar, exactamente con el mismo
  texto de antes de `DEC-0013` ("se documenta... **requiere revisión de
  diseño**, para que `architecture-reviewer` decida si reabre Milestone 2" —
  ya lo hizo, hace varias pasadas). Un lector que entre por
  `risk-register.md` (la fuente de verdad declarada de cada `RISK-NN`, según
  la propia nota de cabecera de `traceability.md`) encuentra el riesgo más
  severo de todo el registro (el único con Probabilidad Alta + Impacto Alta)
  como **abierto y sin resolver**; un lector que entre por `traceability.md`
  lo encuentra **cerrado**. Es una contradicción directa entre dos
  documentos que se supone deben estar sincronizados, no una discrepancia de
  redacción menor.

  El mismo problema, más silencioso, afecta a **RISK-15** (broker de eventos
  como SPOF transversal): su texto completo en `risk-register.md` (líneas
  495-527) y su mitigación en `mitigation-plan.md` (líneas 180-185)
  describen el broker como un mecanismo **actualmente desplegado y activo**
  que hay que monitorear ("monitoreo de salud del broker de eventos y lag de
  consumidores... su degradación debe ser visible de inmediato") — pero en
  Fase 1 (`DEC-0013`) **no existe ningún broker desplegado**, confirmado
  explícitamente por `c4-container.mmd` (no hay `Container(broker,...)`) y
  por la "Nota de aplicabilidad por fase" del propio Eje 2 de
  `tradeoff-matrix.md`. `RISK-10` (tormenta de reconciliación) tiene el
  mismo problema: su escenario depende explícitamente de "la cola de
  reconciliación del Circuit Breaker (ADR-0006)" revalidando eventos en modo
  `cache_degradada` — un mecanismo que `ADR-0006` (nota de revisión) deja
  **en pausa** en Fase 1 por no existir frontera de red. Ninguno de los tres
  (`RISK-01`, `RISK-10`, `RISK-15`) tiene el `DEC-0013` agregado a su columna
  "DEC afectada" en `traceability.md`, ni una nota de vigencia por fase como
  la que sí recibieron `TO-01` a `TO-20` en la matriz de trade-offs.

  Es importante notar que esto **no es una omisión silenciosa de
  `architecture-risk`**: el propio `ADR-0013` ya señala este pendiente
  explícitamente en dos lugares — su sección "Riesgos que quedan abiertos"
  ("Este riesgo operativo [trigger 2] debe evaluarse en una futura iteración
  de `architecture-risk`... contra este ADR nuevo" y "Esta decisión no
  resuelve por sí sola RISK-15... reaparecerá idéntico al activarse la
  extracción... en Fase 2") — y la nota de `architecture-tradeoff` en
  `traceability.md` también deja pendiente explícitamente "el resto de
  `design/diagrams/`... corresponde a `architecture-modeler`" pero **nunca
  menciona** que `risk-register.md`/`mitigation-plan.md` necesiten una
  pasada equivalente. El pendiente fue anotado por quien lo detectó, pero
  nadie lo cerró — es exactamente el patrón de "riesgo pospuesto, no
  evaluado" que motivó la reapertura original de RISK-01 en la Iteración 1
  de este mismo gate.

- **Escenario de falla**: en la defensa de Milestone 4, el estudiante (o
  quien audite el proyecto) abre `risk-register.md` — el documento que
  `plan/milestones.pdf` pide explícitamente como el "Análisis de riesgos
  técnicos" formal — y encuentra el riesgo más severo del proyecto marcado
  como abierto y bloqueante, mientras el resumen de trazabilidad dice lo
  contrario. Peor aún: si se pregunta específicamente "¿qué riesgos aplican
  hoy, en Fase 1?", el registro no distingue ninguno de los riesgos que
  dependen de mecanismos que **todavía no existen** (broker, Circuit
  Breaker Captura↔Identidad) de los que sí aplican desde el día 1 — no hay
  forma de responder esa pregunta sin releer manualmente cada ADR referenciado.
- **Severidad**: Alta
- **A quién se devuelve**: `architecture-risk`. Necesita: (1) actualizar la
  entrada `[RISK-01]` de `risk-register.md` para reflejar que fue resuelta
  por `DEC-0013`, retirando o reformulando el texto "requiere revisión de
  diseño" que hoy sigue vigente; (2) hacer lo mismo en `mitigation-plan.md`;
  (3) agregar una nota de vigencia por fase a `RISK-10` y `RISK-15` (y
  revisar `RISK-11`, `RISK-14`, que también citan mecanismos afectados por
  `DEC-0013`), aclarando cuáles de sus escenarios aplican en Fase 1 y cuáles
  reaparecen recién en Fase 2 — siguiendo el mismo patrón que
  `architecture-tradeoff` ya aplicó en `tradeoff-matrix.md` para sus ejes.

---

### [Bloqueante] La instrucción "sin API Gateway/BFF en Fase 1" creó una contradicción real entre `bounded-contexts.md` y los diagramas, y dejó sin resolver un impacto de seguridad no evaluado

- **ID relacionado**: DRV-03 / DEC-0013 (impacto no cubierto por el ADR)
- **Qué falta o es ambiguo**: la propia pregunta del orquestador ya anticipa
  el riesgo correcto — no es solo una cuestión de "quién debe ratificar
  esto", es que la instrucción, tal como se ejecutó, generó una
  inconsistencia verificable entre dos artefactos que ambos se declaran
  vigentes:
  - `design/milestone-2/bounded-contexts.md`, sección "Componentes
    transversales" (líneas 383-399, sin tocar por la nota de revisión de
    `DEC-0013` que sí está al final del mismo documento) sigue afirmando,
    sin ningún matiz de fase, que el sistema tiene **API Gateway** ("punto
    de entrada único, centraliza autenticación, SSL, rate limiting y
    enrutamiento") y **BFF Web/BFF Móvil** como componentes activos del
    diseño.
  - `c4-container.mmd` y `c4-component.mmd` (redibujados en la Iteración
    DEC-0013) **eliminan por completo** ambos componentes, con clientes
    llamando directamente a los módulos del monolito.
  - `design/diagrams/NOTES.md` (sección "Iteración DEC-0013 — Fase 1",
    subsección de `c4-container.mmd`) es honesto y señala esto explícitamente
    como "un hueco real del ADR en ese punto puntual" resuelto por
    "instrucción directa... no por inferencia propia" — pero esa honestidad
    no repara la inconsistencia entre los dos documentos: `bounded-contexts.md`
    sigue siendo, según la propia regla de este proyecto, el documento de
    Milestone 2 que los diagramas deben representar fielmente, y hoy no lo
    hacen en este punto.
  - Más allá del problema de trazabilidad entre documentos, hay un **gap de
    sustancia no evaluado**: `bounded-contexts.md` atribuye al API Gateway
    la responsabilidad de **centralizar autenticación**, además de
    enrutamiento y rate limiting. Al eliminarlo sin ADR, ningún artefacto de
    la cascada dice dónde vive la autenticación de los dos clientes (App
    Móvil, Portal Web) en Fase 1 — ¿cada uno de los 5 módulos valida el
    token de sesión por su cuenta? ¿hay un middleware compartido dentro del
    monolito no nombrado en ningún componente? El propio `ADR-0013` acepta
    explícitamente "debilitar parcialmente DRV-03" solo en su dimensión de
    aislamiento de datos por esquema — nunca evalúa ni acepta como deuda el
    impacto en la superficie de autenticación, porque nunca se decidió a
    nivel de ADR: se decidió por fuera de la cadena `architecture-strategist`
    → ADR, exactamente como advierte la pregunta original.
- **Escenario de falla**: si Fase 2 extrae Captura de Asistencia como
  servicio independiente (el trigger más probable, según el propio
  `ADR-0013`) sin que nunca se haya definido dónde vivía la autenticación en
  Fase 1, el nuevo servicio extraído no tiene ningún contrato claro de
  autenticación que heredar o renegociar — el problema que el API Gateway
  existía para resolver reaparece en el peor momento (una migración en
  curso), sin que nadie lo haya diseñado ni siquiera una vez.
- **Severidad**: Alta
- **A quién se devuelve**: `architecture-strategist`. No es una corrección
  de diagrama (`architecture-modeler` ya hizo su parte correctamente,
  incluida la transparencia de señalar el hueco) — es una decisión de
  arquitectura que falta tomar y registrar formalmente, ya sea como (a) una
  nota de revisión en `ADR-0013`/`bounded-contexts.md` que ratifique
  explícitamente "sin Gateway/BFF en Fase 1" y declare dónde vive la
  autenticación en su lugar (ej. middleware compartido dentro del
  monolito, o un Gateway ligero de solo autenticación/SSL sin las
  responsabilidades de enrutamiento multi-servicio que ya no aplican), o
  (b) revertir la eliminación y mantener un Gateway/BFF único (no
  "multi-servicio") en Fase 1 exactamente como el propio `NOTES.md` sugiere
  como alternativa aceptable. Cualquiera de las dos cierra el hallazgo;
  dejarlo como está hoy, no.

---

### Puntos verificados sin hallazgos

- **Consistencia diagrama↔decisión para `ADR-0002`, `ADR-0006`, `ADR-0007`,
  `ADR-0008`, `ADR-0009`**: verificado línea por línea `c4-container.mmd` y
  `c4-component.mmd` contra las notas de revisión de estos cinco ADRs y
  contra `bounded-contexts.md`. La máquina de estados de `ADR-0002`/`ADR-0007`
  aparece correctamente renombrada como "Máquina de Estados / Cola de
  Trabajos Interna" con la misma máquina de estados textual
  (`pendiente_nis → ... → escalado_manual`); el Circuit Breaker de
  `ADR-0006` aparece correctamente re-etiquetado como "en pausa" con la
  relación `mod_captura → mod_identidad` marcada "invocación en proceso, sin
  frontera de red"; el mecanismo de `ADR-0008` aparece correctamente como
  consulta directa en proceso, con `c4-component-refresco-credenciales.mmd`
  conservado y marcado de forma muy visible (bloque de comentarios `%%` de
  11 líneas al inicio del archivo más el propio título del diagrama) como
  "Diagrama de FASE 2 (en pausa)" — no genera ambigüedad de lectura
  adicional, contra lo que preguntaba el punto 6 del brief: el archivo por
  sí solo, sin necesitar `NOTES.md`, ya deja claro que no aplica hoy. La
  revocación de `ADR-0009` aparece simplificada a una sola fuente de verdad,
  consistente con la nota de revisión del ADR. No se encontró ninguna
  omisión ni agregado no trazable a un ADR o a `bounded-contexts.md` en
  estos cinco casos (aparte del hallazgo de Gateway/BFF, que no pertenece a
  ninguno de estos cinco ADRs).

- **`tradeoff-matrix.md` Eje 2 vs. diagramas de Fase 1**: verificado. La
  "Nota de aplicabilidad por fase" del Eje 2 afirma que en Fase 1 "no existe
  frontera de red entre bounded contexts... no hay ni un broker de eventos
  desplegado ni llamadas REST síncronas inter-servicio que comparar en la
  práctica" — confirmado exactamente así en `c4-container.mmd` (sin
  `Container(broker,...)`, todas las relaciones inter-módulo etiquetadas
  "invocación en proceso"). Coherente, sin hallazgo.

- **Inconsistencia de redacción Eje 1 / Eje 3 (Seguridad) de
  `tradeoff-matrix.md`**: confirmado que existe (Eje 3 sigue describiendo
  "Base de Datos por Servicio" en términos físicos donde el Eje 1 ya
  reconoce aislamiento lógico), pero coincido con la propia evaluación de
  `architecture-tradeoff`: no cambia la conclusión de ningún eje (el Eje 3
  compara tiering temporal, no aislamiento físico entre contextos) y es
  puramente de homogeneización de lenguaje. **No se eleva a hallazgo
  bloqueante** — queda como mejora aditiva de redacción para una futura
  pasada de `architecture-tradeoff`, sin volver a listarla como hallazgo
  nuevo de este gate.

- **`design/traceability.md`, decisiones huérfanas o drivers abandonados
  nuevos introducidos por la cascada de `DEC-0013`**: no se encontró
  ninguno. `DEC-0013` tiene su columna de `DRV`/`REQ`/`RST` de origen
  poblada correctamente (`DRV-01` a `DRV-05`, `REQ-06`, `REQ-07`, `RST-01`
  citada contra `discovery.md`). El problema real de trazabilidad detectado
  en esta corrida no es una fila huérfana o abandonada en el sentido
  estricto del mandato de este agente sobre `traceability.md` — es que las
  filas `RISK-01`, `RISK-10`, `RISK-15` de la tabla "Riesgos (Milestone 3)"
  quedaron con su "Tratamiento" desincronizado del documento primario que
  deberían resumir (`risk-register.md`), ver hallazgo bloqueante arriba.

---

### Cierre de esta corrida

**No corresponde `SIN HALLAZGOS NUEVOS`.** Hay dos hallazgos de severidad
Alta, ambos con evidencia concreta y verificable (no interpretación):

1. `risk-register.md` y `mitigation-plan.md` nunca se actualizaron contra
   `DEC-0013` — contradicen directamente la afirmación de "RISK-01:
   Resuelto" de `traceability.md`, y describen mecanismos (broker de
   eventos, Circuit Breaker Captura↔Identidad) como activos cuando en Fase
   1 no existen. Devuelto a `architecture-risk`.
2. La eliminación de API Gateway/BFF en los diagramas de Fase 1, decidida
   por instrucción directa fuera de la cadena `architecture-strategist` →
   ADR, generó una contradicción real con `bounded-contexts.md` (que sigue
   listando ambos componentes como vigentes) y dejó sin resolver dónde vive
   la autenticación centralizada en Fase 1 — un impacto sobre DRV-03 nunca
   evaluado. Devuelto a `architecture-strategist`.

Conforme a la instrucción explícita de esta corrida (cierre de la cascada,
más allá del cap estándar de 3 iteraciones del gate), **no se itera una
cuarta vez sobre este ciclo**: ambos hallazgos quedan documentados aquí como
**riesgo conocido, no resuelto**. No recomiendo tratarlos como cosméticos:
el primero compromete la integridad de la propia trazabilidad del proyecto
(dos documentos con estados contradictorios sobre el riesgo más severo
identificado en todo el registro); el segundo es un gap de seguridad real,
no solo de prolijidad de diagramación. Queda a criterio del usuario si esto
bloquea el avance a Milestone 4 o se acepta explícitamente como limitación
conocida — pero no debería avanzarse en silencio, sin que quede registrado
que ambos puntos siguen abiertos.

Los demás cuatro puntos del brief (consistencia diagrama↔ADR para
0002/0006/0007/0008/0009, `tradeoff-matrix.md` Eje 2 vs. diagramas,
homogeneización Eje 1/Eje 3, y visibilidad de
`c4-component-refresco-credenciales.mmd`) están verificados como correctos
o como no bloqueantes, con la cita concreta que lo sostiene en cada caso
— ver "Puntos verificados sin hallazgos" arriba.

---

## Cierre definitivo — Milestone 3 — 2026-08-24

Auditoría final y acotada, exclusivamente sobre lo tocado para cerrar los
dos hallazgos bloqueantes de "Cierre de cascada DEC-0013": `ADR-0014`, la
sección "Nota de revisión — Milestone 3 (DEC-0014)" de `bounded-contexts.md`,
el redibujo de `c4-container.mmd`/`c4-component.mmd` y la sección nueva de
`design/diagrams/NOTES.md`, las notas de vigencia por fase de RISK-01/
RISK-10/RISK-15 en `risk-register.md` y su reflejo en `mitigation-plan.md`,
y la fila `DEC-0014` de `traceability.md`. No se re-audita nada ya cerrado
en las dos corridas anteriores salvo para verificar que el cierre sea
consistente con lo nuevo.

**Método**: estructura primero — leídos completos `c4-container.mmd`,
`c4-component.mmd` y `design/diagrams/NOTES.md` (las tres secciones nuevas:
"Iteración DEC-0013 — Fase 1" para contexto y "Iteración DEC-0014"), luego
`risk-register.md` y `mitigation-plan.md` completos, luego
`traceability.md` completo, y solo al final `ADR-0014` de punta a punta,
para formar una lectura propia de si el middleware es una decisión
defendible antes de leer su propia justificación.

### Los dos hallazgos bloqueantes anteriores — CERRADOS, con evidencia

**Hallazgo 1 (`risk-register.md`/`mitigation-plan.md` desincronizados de
`DEC-0013`)**: cerrado. `[RISK-01]` tiene ahora la sección "Nota de
resolución (post-DEC-0013)" (líneas 119-160 de `risk-register.md`) que
retira explícitamente el texto "requiere revisión de diseño" en presente,
documenta la Probabilidad/Impacto actualizados (Alta/Alta → Media-Baja/Baja)
con justificación anclada en `ADR-0013` ("Consecuencias positivas"), y no
oculta el riesgo residual (dependencia del trigger 2 de observabilidad, costo
de migración de Fase 2 vía Strangler). `RISK-10` y `RISK-15` tienen ahora
"Nota de vigencia por fase (post-DEC-0013)" que distingue explícitamente qué
parte de cada escenario aplica hoy (Fase 1) y cuál queda diferida a Fase 2,
confirmado contra `c4-container.mmd` en ambos casos (cita textual de la
etiqueta de relación exacta). `mitigation-plan.md` refleja lo mismo en su
nota de cabecera y en las mitigaciones de categoría 1, 3 y 4 que tocan
RISK-10/RISK-15. Ya no hay contradicción con `traceability.md`.

**Hallazgo 2 (Gateway/BFF eliminado sin ADR, autenticación sin dueño)**:
cerrado. `ADR-0014` ratifica la ausencia de Gateway/BFF con fundamento
propio y define el Middleware de Autenticación. `bounded-contexts.md` ya no
contradice a los diagramas: la sección "Componentes transversales" tiene su
nota de vigencia por fase, y la nueva sección "Nota de revisión — Milestone
3 (DEC-0014)" desarrolla el mecanismo completo. Los diagramas ya representan
el middleware explícitamente (ver más abajo, consistencia verificada línea
por línea).

### Puntos verificados sin hallazgos

- **`ADR-0014` es una decisión defendible, no un post-hoc "porque el gateway
  ya no está"**: tiene tres alternativas reales, no un espantapájaros. La
  Alternativa A (Gateway/BFF liviano) se descarta con una razón concreta y
  verificable — `we7.md` describe el Gateway como SPOF que exige
  clustering/redundancia, es decir, sigue siendo una segunda pieza operable
  incluso "liviana", lo que viola `RST-01` tal como `DEC-0013` ya lo
  interpretó. La Alternativa C (validación duplicada por módulo) se
  descarta por duplicación de lógica transversal, anclada en `we6.md`
  (Separación de Responsabilidades). La alternativa elegida (B) cita
  `we6.md` (AOP para monolitos/en capas, en contraste explícito con
  sidecar/servicio Auth dedicado para sistemas distribuidos) y `we1.md`
  ("Security Module" transversal, uno de los cuatro tipos de módulo) — son
  citas puntuales y aplicadas a la topología concreta de Fase 1, no
  referencias genéricas. Es una justificación con el mismo nivel de rigor
  que el resto de los ADR-0001 a ADR-0013 ya auditados en corridas
  anteriores.

- **Consistencia diagrama↔diagrama↔ADR para el middleware**: verificado
  línea por línea. `c4-container.mmd` (línea 16) y `c4-component.mmd`
  (línea 9) usan el mismo nombre de componente ("Middleware de Autenticacion
  (Modulo de Seguridad transversal)"), la misma descripción funcional
  (intercepta App Móvil/Portal Web, valida contra el agregado Credencial,
  rechaza 401/403 antes de enrutar) y la misma relación hacia
  `mod_identidad` para la emisión/validación de sesión
  (`POST /identity/sessions`). Ambos diagramas confirman explícitamente que
  el Dispositivo DAS **no** pasa por el middleware (consistente con
  `ADR-0014`, que lo restringe a App Móvil y Portal Web). `NOTES.md`
  ("Iteración DEC-0014") documenta el criterio de por qué sí se tocó
  `c4-component.mmd` (para no dejar la restricción de rol de
  `api_admin` sin dueño visible) y por qué no se tocó
  `c4-component-refresco-credenciales.mmd` (mecanismo backend-a-backend sin
  cliente HTTP en su alcance) — ambos criterios son coherentes con el
  alcance que el propio `ADR-0014` declara ("intercepta solicitudes de App
  Móvil y Portal Web", no invocaciones internas entre módulos).

- **`traceability.md`, sin decisión huérfana nueva**: `DEC-0014` tiene su
  fila con `DRV-03`, `REQ-09` (y `RST-01` citada contra `discovery.md`, no
  como fila) en la columna de origen (línea 300); `DRV-03` y `REQ-09` tienen
  `DEC-0014` agregado a su columna "DEC relacionadas" (líneas 234 y 245) sin
  quitar los `DEC` ya listados. No hay ninguna fila `DEC-NNNN` sin origen ni
  ninguna fila `DRV`/`REQ` que quede sin al menos una `DEC` que la atienda.

### [Hallazgo nuevo, Media] `ADR-0014` autodetecta un riesgo operativo/de seguridad y lo deja explícitamente sin convertir en `RISK-NN` — a diferencia del tratamiento que sí recibió el riesgo equivalente de `ADR-0013`

- **ID relacionado**: DEC-0014, DRV-03 / (sin `RISK-NN` que lo cubra)
- **Qué falta o es ambiguo**: la propia sección "Riesgos que quedan
  abiertos" de `ADR-0014` dice textualmente: "Esta decisión no evalúa
  formalmente el riesgo operativo de tener un único punto de validación de
  autenticación sin redundancia de proceso en Fase 1 (ej. si el proceso del
  monolito se reinicia, ¿qué pasa con las sesiones en memoria vs.
  persistidas?). Queda señalado aquí explícitamente para que
  `architecture-risk` lo evalúe en una futura pasada de Milestone 3 — no se
  resuelve en este ADR." Revisé `risk-register.md` completo (RISK-01 a
  RISK-17): **ningún** `RISK-NN` cubre este escenario. No es el mismo
  riesgo que RISK-01 (complejidad operativa general de MSA+EDA para RST-01,
  ya resuelto por DEC-0013) ni que RISK-15 (broker de eventos como SPOF,
  diferido a Fase 2 y sin existir hoy) — es un SPOF de **seguridad**
  específico y nuevo, propio de DEC-0014, sobre el mecanismo de sesión: si
  el proceso del monolito se reinicia (deploy, crash, OOM) y las sesiones
  viven solo en memoria (el ADR no aclara si `POST /identity/sessions`
  persiste la sesión o no), todas las sesiones activas de App Móvil y
  Portal Web se invalidan simultáneamente sin ningún mecanismo de
  degradación declarado — a diferencia de, por ejemplo, RISK-14, donde sí
  existe un TTL y un modo `cache_degradada` explícitos para el caso
  análogo de validación de credencial física.

  Esto contrasta con el propio patrón que este proyecto ya siguió para el
  caso equivalente de `ADR-0013`: su sección "Riesgos que quedan abiertos"
  (trigger 2 dependiente de observabilidad, costo de migración de Fase 2)
  **sí** quedó capturado explícitamente dentro de la "Nota de resolución"
  de `RISK-01`, con Probabilidad/Impacto reevaluados. El riesgo abierto de
  `ADR-0014` no recibió ese mismo tratamiento — quedó señalado por quien lo
  detectó (`architecture-strategist`, dentro del propio ADR), pero nadie lo
  convirtió en una entrada verificable del registro de riesgos.

- **Escenario de falla**: un despliegue rutinario del monolito (o un
  crash/OOM no relacionado con seguridad) invalida silenciosamente todas
  las sesiones activas de App Móvil y Portal Web al mismo tiempo — cientos
  de usuarios deslogueados sin aviso, personal administrativo interrumpido
  a mitad de una revisión de solicitudes — y nadie diseñó explícitamente si
  eso es aceptable (UX degradada, requiere nuevo login) o si se esperaba
  persistencia de sesión entre reinicios. No es un escenario hipotético
  fuera de alcance: es exactamente el tipo de pregunta operacional que este
  registro de riesgos ya resuelve para otros mecanismos equivalentes
  (ver RISK-14, TTL de caché de credencial).
- **Severidad**: Media (el propio ADR ya lo señala explícitamente y de
  buena fe, no es una omisión oculta; el impacto es de disponibilidad/UX de
  sesión, no de pérdida ni corrupción de datos ni de bypass de
  autorización)
- **A quién se devuelve**: `architecture-risk`, para agregar un `RISK-NN`
  nuevo (ej. bajo la misma categoría que RISK-14/RISK-15, dependencias
  transversales de seguridad) que cubra explícitamente el escenario de
  reinicio de proceso vs. estado de sesión, con su probabilidad/impacto y
  una mitigación anclada en `knowledge/` (ej. sesión persistida en el mismo
  almacén compartido de `DEC-0013`, o degradación explícita aceptada como
  trade-off). No bloqueante para este cierre — el propio `ADR-0014` ya lo
  documenta con transparencia — pero debe quedar cerrado antes de
  Milestone 4, siguiendo el mismo estándar que el proyecto ya se exige a sí
  mismo para el resto de riesgos autodetectados en ADRs.

### [Hallazgo nuevo, Media] `RISK-11` y `RISK-14` — explícitamente señalados para revisión en el hallazgo anterior — nunca recibieron su nota de vigencia por fase

- **ID relacionado**: RISK-11, RISK-14 / DEC-0013
- **Qué falta o es ambiguo**: la remediación del Hallazgo 1 de "Cierre de
  cascada DEC-0013" pedía explícitamente "(3) agregar una nota de vigencia
  por fase a RISK-10 y RISK-15 (**y revisar RISK-11, RISK-14**, que también
  citan mecanismos afectados por DEC-0013)". La corrida que cerró ese
  hallazgo sí agregó las notas a RISK-10 y RISK-15, pero **no** tocó
  RISK-11 ni RISK-14 — ambos siguen describiendo, sin ningún matiz de fase,
  mecanismos que hoy no existen o están pausados en Fase 1:
  - `RISK-11` (línea 477 de `risk-register.md`): "un corte de WAN/ISP deja
    a todo un campus sin acceso a Captura de Asistencia (backend), **al
    broker de eventos** y a Identidad y Credenciales" — pero no hay ningún
    broker desplegado en Fase 1 (confirmado, igual que para RISK-15, contra
    `c4-container.mmd`, sin `Container(broker,...)`).
  - `RISK-14` (líneas 564-572): todo el escenario depende de "Circuit
    Breaker Abierto (incidente de backend)" en la relación
    Captura↔Identidad — mecanismo que la nota de revisión de `ADR-0006` deja
    explícitamente **en pausa** en Fase 1 (sin frontera de red que proteger,
    misma llamada en proceso), el mismo mecanismo que ya motivó la nota de
    vigencia agregada a RISK-10.
  Es el mismo patrón de inconsistencia que motivó el Hallazgo 1 original,
  parcialmente cerrado: se corrigieron dos de los cuatro riesgos
  explícitamente señalados, no los cuatro.
- **Escenario de falla**: igual que en el Hallazgo 1 original — alguien
  pregunta "¿qué riesgos aplican hoy, en Fase 1?" y `risk-register.md` no
  permite responder eso para RISK-11/RISK-14 sin releer manualmente
  `ADR-0006` y los diagramas, exactamente la fricción que las notas de
  vigencia de RISK-10/RISK-15 ya existen para evitar en el resto del
  documento.
- **Severidad**: Media (RISK-11 y RISK-14 ya tienen Probabilidad Baja y su
  mecanismo funcional de fondo —buffer local, TTL de caché— sigue vigente en
  Fase 1 sin cambios; lo que falta es la misma precisión de vigencia que ya
  se aplicó a sus pares, no una corrección de fondo)
- **A quién se devuelve**: `architecture-risk`, para completar exactamente
  lo que la propia remediación del hallazgo anterior ya pedía y quedó a
  mitad de camino: agregar nota de vigencia por fase a RISK-11 (aclarando
  que "al broker de eventos" no aplica hoy) y a RISK-14 (aclarando que el
  escenario de Circuit Breaker Abierto es de Fase 2). No bloqueante para
  este cierre.

### Cierre de esta corrida

**No corresponde `SIN HALLAZGOS NUEVOS`**, pero los dos hallazgos
bloqueantes de severidad Alta que motivaron esta pasada — el único par de
puntos que este cierre tenía mandato explícito de verificar — **están
genuinamente cerrados, con evidencia concreta citada arriba**: `ADR-0014`
es una decisión defendible (alternativas reales, anclaje en `knowledge/`,
no una racionalización posterior), los diagramas son consistentes entre sí
y con el ADR, y las notas de vigencia de RISK-01/RISK-10/RISK-15 resuelven
la contradicción con `traceability.md` sin solo cambiar texto — la lógica
de cada reclasificación se sostiene contra evidencia verificable (diagramas,
ADRs revisados). No hay decisión huérfana nueva en `traceability.md`.

Esta corrida encontró, sin embargo, **dos hallazgos nuevos de severidad
Media**, ninguno de los cuales estaba en el alcance original de los dos
hallazgos que se pedía cerrar, y ambos surgen directamente de los artefactos
nuevos de esta ronda (el propio `ADR-0014` autodetecta el primero; el
segundo es un resto sin cerrar del hallazgo anterior). Conforme a la
instrucción explícita de esta corrida — el margen de iteración normal para
este gate ya está agotado (esta es la tercera corrida sobre el mismo ciclo,
más allá del cap estándar de 3) — **no se itera una cuarta vez**. Ambos
quedan documentados aquí como **riesgo conocido, no resuelto**, no como
bloqueante: ninguno de los dos compromete integridad de datos, pérdida de
asistencia, bypass de autorización ni ninguna de las cinco garantías no
negociables del enunciado — son gaps de completitud del registro de
riesgos, del mismo tipo (y la misma severidad) que otros ya aceptados como
conocidos en este proyecto (ej. RISK-13, RISK-16).

**Veredicto explícito para el usuario**: los dos hallazgos que esta corrida
tenía mandato de verificar (defendibilidad de `ADR-0014` y consistencia de
diagramas/riesgos post-`DEC-0013`) están cerrados de verdad — se puede
avanzar a Milestone 4 con confianza en ese punto específico. Los dos
hallazgos nuevos de esta corrida (RISK-NN faltante para el SPOF de sesión
de `ADR-0014`; notas de vigencia faltantes en RISK-11/RISK-14) son
limitaciones conocidas y no bloqueantes — quedan a criterio del usuario si
se cierran antes de Milestone 4 (recomendado, son ediciones aditivas de bajo
costo sobre `risk-register.md`, no requieren tocar ningún ADR ni diagrama)
o se aceptan explícitamente como deuda documentada, igual que ya se hizo con
RISK-13 y RISK-16.
