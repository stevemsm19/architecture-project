# Milestone 1 — Descubrimiento Arquitectónico

> Nota de normalización de terminología: `plan/milestones.pdf` nombra el driver
> de integración con el acrónimo **"SNI"**. `context/capstone.pdf` (fuente
> oficial de requisitos) y el resto del material usan consistentemente
> **"NIS" (Servicio de Identificación Nacional)**. Se trata de la misma
> entidad — no de dos sistemas distintos. En todo este documento y en los
> artefactos derivados se usa **"NIS"** como término canónico, por ser el que
> usa el enunciado oficial.

## Introducción del problema

La Universidad Panamericana de Ciencias Aplicadas (UPCA) es una institución
educativa con presencia en 10 ciudades, que gestiona 20 campus y atiende a
aproximadamente 5.000 estudiantes, 400 profesores, con unas 3 clases al día
por campus. Para modernizar sus operaciones y mantenerse al día con la
tecnología, la UPCA decidió implantar un Sistema Digital de Asistencia (DAS)
tanto para estudiantes como para profesores (`capstone.pdf`, "Descripción
General").

El DAS cubre, según el enunciado, un ciclo funcional completo: (1)
identificación de cada usuario mediante un **DAS ID** único verificable desde
una app móvil; (2) **autorregistro** en el que el usuario presenta documento
de identidad, fotografía y datos personales, con una **verificación a
distancia con el Servicio de Identificación Nacional (NIS)** que "no se
realiza en tiempo real y puede tardar hasta 2 horas en completarse", más una
aprobación adicional del personal administrativo de la universidad; (3)
emisión de una **Insignia DAS** (física o en dispositivo móvil) tras la
verificación; (4) **captura de asistencia** en cada campus mediante
dispositivos DAS que escanean la insignia/tarjeta para registrar entrada y
salida por usuario, día y ubicación; y (5) un **portal administrativo web**
con reportes y estadísticas, más una **app móvil** para que cada usuario
consulte su propio estado de asistencia (`capstone.pdf`, secciones
"Identificación del usuario mediante DAS ID" a "Portal web administrativo").

El propio enunciado declara un conjunto explícito de requisitos no
funcionales — crecimiento de ~10.000 usuarios nuevos en dos años manteniendo
"un rendimiento eficiente", registro de entrada/salida "lo más cercano
posible al tiempo real", retención mínima de cinco años de los registros de
asistencia "en cumplimiento de los requisitos legales", y la exigencia de que
"los datos del DAS deben ser confidenciales y seguros" — aclarando además que
"pudiendo existir otros más" (`capstone.pdf`, "Requerimientos no
funcionales"). Esta última frase es, en sí misma, una instrucción del
enunciado a no tratar la lista como cerrada, y es el motivo por el cual este
milestone no se limita a copiar los cinco drivers sugeridos en
`plan/milestones.pdf` sin antes justificarlos individualmente.

Este documento no propone ni insinúa una solución arquitectónica. Su único
objetivo es fijar, con trazabilidad a la fuente, qué es un requisito, qué es
un supuesto necesario para poder avanzar, qué es una restricción no
negociable y qué queda abierto como ambigüedad — de modo que el Milestone 2
en adelante tenga un conjunto de condiciones claras y priorizadas contra las
cuales diseñar.

> **Nota de reconciliación**: las secciones "Brechas y ambigüedades
> identificadas" y "Supuestos explícitos" de este documento fueron revisadas
> después de que el usuario completara las respuestas a las preguntas de
> stakeholders simulados (sección siguiente). Donde una respuesta resolvió,
> total o parcialmente, una ambigüedad originalmente abierta, se dejó
> constancia explícita del cambio de estado y, cuando corresponde, del nuevo
> supuesto (`ASM-NN`) que la reemplaza — sin borrar la entrada original, para
> conservar el rastro de por qué era una ambigüedad y cómo dejó de serlo (o
> por qué solo dejó de serlo en parte).

## Brechas y ambigüedades identificadas

- **[AMB-01] Umbral numérico de "near real-time" (parcialmente resuelta)** —
  El enunciado dice que "el proceso de registro de entrada y salida debe ser
  lo más cercano posible al tiempo real" (`capstone.pdf`, "Requerimientos no
  funcionales"), pero no define un umbral (segundos, minutos) ni distinguía
  originalmente si ese umbral aplica solo a la captura en el dispositivo o
  también a su reflejo en el portal administrativo y en la app móvil.

  Las respuestas de los stakeholders simulados dan una señal cualitativa
  fuerte, pero no un número exacto: el Estudiante tolera una demora de
  "algunos segundos o incluso un poco más" en la app siempre que el dato
  final quede registrado correctamente (ver **[ASM-06]**); el Profesor quiere
  ver el estado de una clase "rápidamente"; y el Personal Administrativo
  confirma que el umbral **sí aplica también al portal** —descarta
  explícitamente una actualización de una vez al día como insuficiente—
  aunque tampoco exige el mismo segundo que la captura (ver **[ASM-12]**).

  Lo que sigue sin resolverse: el número exacto de segundos/minutos que
  definirá el SLA de "near real-time" en Milestone 2, y si ese número debe
  ser el mismo para la captura en dispositivo, la app del usuario y el
  portal administrativo, o si puede variar por canal.

- **[AMB-02] Comportamiento de los dispositivos DAS ante pérdida de
  conectividad — RESUELTA a nivel de expectativa funcional, movida a
  [ASM-07]** — El enunciado no menciona en ningún momento qué debe ocurrir si
  el "dispositivo digital DAS (captura de asistencia)" situado en cada campus
  pierde conexión a la red o queda inoperativo. `plan/milestones.pdf` sí
  nombra este escenario como riesgo a analizar en el Milestone 3
  ("Dispositivos SAD offline / Pérdida de conectividad"), lo que confirmaba
  que era una preocupación real del curso, pero `capstone.pdf` no lo abordaba
  en absoluto.

  Las respuestas del Estudiante y del Profesor simulados a la pregunta
  correspondiente dan una expectativa funcional clara: la asistencia real no
  debe perderse, y debe existir una vía de registro posterior o manual. Ver
  **[ASM-07]** para el supuesto adoptado a partir de esa respuesta. Queda
  fuera del alcance de este milestone el mecanismo técnico concreto (cola
  offline, sincronización, ventana de tiempo permitida para el registro
  retroactivo), que sigue siendo una decisión de diseño abierta para
  Milestone 2 en adelante — no una ambigüedad del enunciado.

- **[AMB-03] Relación entre "Insignia DAS" y "tarjeta DAS"** — La sección
  "Creación de la Insignia DAS" describe una "identificación imprimible" que
  "puede imprimirse o guardarse en un dispositivo móvil". La sección
  siguiente, "Proceso de registro de entrada y salida", se refiere al mismo
  artefacto como "tarjeta DAS" ("Con su tarjeta DAS, los estudiantes y
  profesores pueden registrar su entrada y salida..."). El enunciado no
  aclara si "Insignia" y "tarjeta" nombran el mismo artefacto (físico o
  digital, indistintamente) o si "tarjeta" implica exclusivamente un soporte
  físico distinto del uso en dispositivo móvil descrito antes. Ninguna de las
  respuestas de los stakeholders simulados toca este punto; queda sin cambios.

- **[AMB-04] Alcance exacto de los datos sujetos a retención de 5 años** — El
  enunciado dice "los registros de asistencia deben conservarse durante un
  mínimo de cinco años en cumplimiento de los requisitos legales"
  (`capstone.pdf`, "Requerimientos no funcionales"), pero no aclara si esa
  obligación cubre también los datos de identidad, documento y fotografía
  capturados durante el autorregistro, o únicamente los eventos de
  entrada/salida. Ver también **[ASM-04]**, el supuesto adoptado para poder
  avanzar mientras esto no se resuelve. Ninguna respuesta de los stakeholders
  simulados aborda el *alcance* de qué datos están sujetos a retención (sí
  hay información nueva sobre la *velocidad* de consulta de datos
  históricos, que no resuelve esta ambigüedad — ver **[ASM-13]**); queda sin
  cambios.

- **[AMB-05] Orden y dependencia entre verificación NIS y aprobación
  administrativa (parcialmente resuelta — acotada a la pregunta de orden
  estricto)** — El enunciado menciona ambos pasos ("la confirmación se envía
  por correo electrónico al emisor (Universidad). El personal administrativo
  de la universidad también debe aprobar el registro", `capstone.pdf`,
  "Autorregistro a través de un portal en línea (cont.)") pero no especifica
  si la aprobación administrativa ocurre necesariamente después de una
  verificación NIS exitosa, en paralelo a ella, o de forma independiente de
  su resultado.

  Las respuestas de los stakeholders simulados resuelven la parte de **qué
  pasa ante un rechazo o una demora**, pero no la del **orden/dependencia
  estricta** entre ambos pasos: el Personal Administrativo describe su tarea
  como revisar "un registro que ya fue verificado por el NIS" (lo cual
  sugiere, sin confirmarlo como regla explícita, un orden secuencial
  NIS→administrativo), y detalla qué debe pasar ante un rechazo (ver
  **[ASM-11]**) y ante una demora del NIS más allá de las 2 horas esperadas
  (ver **[ASM-15]**). Ninguna respuesta confirma explícitamente si la
  aprobación administrativa podría ocurrir en paralelo a la verificación NIS
  o de forma independiente de su resultado — esa pregunta puntual queda
  abierta.

- **[AMB-06] Naturaleza geográfica de las "10 ciudades" y del crecimiento
  previsto** — No se especifica si las 10 ciudades y 20 campus están dentro
  de un mismo país (relevante para saber si "el" NIS es un único servicio con
  un único contrato/SLA o si podría haber múltiples instancias
  jurisdiccionales), ni si el crecimiento de "unos 10.000 nuevos usuarios en
  los próximos dos años" (`capstone.pdf`, "Requerimientos no funcionales")
  implica nuevas ciudades/campus o solo más usuarios sobre los 20 campus
  existentes. Ninguna de las preguntas formuladas a los stakeholders
  simulados cubría este punto; queda sin cambios.

- **[AMB-07] Qué constituye un "evento" de asistencia (matizada, no
  resuelta)** — El enunciado menciona seguimiento de "la asistencia a clases
  o eventos específicos" (sección DAS ID) y registro de entrada/salida de
  "instalaciones (por ejemplo, cursos) y eventos en diferentes campus"
  (sección de captura), sin definir si un usuario que asiste a varias clases
  en un mismo día genera varios registros de entrada/salida independientes
  (uno por clase/evento) o un único registro de presencia diaria por campus.

  Existe una señal cualitativa parcial y no buscada deliberadamente: en su
  respuesta a la pregunta sobre velocidad de reflejo del registro, el
  Profesor simulado expresó interés en "saber cuántos estudiantes están
  presentes en una clase" y tener "una visión del estado actual de la
  asistencia", lo que sugiere que la granularidad relevante para al menos un
  stakeholder es por clase, no solo un estado diario agregado por campus.
  Esto no resuelve la ambigüedad — no confirma si el sistema debe generar un
  registro distinto por clase/evento o si esa vista por clase puede derivarse
  de otra estructura de datos — pero se documenta como insumo para
  Milestone 2.

- **[AMB-08] Mecanismo técnico de lectura de la Insignia/tarjeta DAS** — El
  enunciado dice que el dispositivo DAS "escanea la tarjeta DAS para
  registrar la asistencia" pero no especifica el mecanismo (código de barras,
  QR, NFC, u otro). Se documenta como brecha de información porque condiciona
  supuestos de hardware/latencia de captura, aunque su resolución
  probablemente pertenezca a un nivel de decisión posterior al de este
  milestone. Ninguna respuesta de los stakeholders simulados lo aborda; queda
  sin cambios.

- **[AMB-09] Aislamiento de datos por campus/ciudad — RESUELTA, movida a
  [ASM-14]** — El enunciado dice que el portal administrativo "permite al
  personal de la universidad supervisar y gestionar los índices de
  asistencia" y ofrece "acceso a todos los datos del campus" (`capstone.pdf`,
  "Portal web administrativo"), pero no aclaraba si "todos los datos del
  campus" significaba que cada administrativo ve solo su propio campus, o si
  cualquier miembro del personal administrativo tiene visibilidad sobre los
  20 campus y 10 ciudades de la red UPCA.

  La respuesta del Personal Administrativo simulado resuelve esta
  ambigüedad: necesita poder consultar información de todos los campus, dado
  que la universidad opera de forma distribuida y "para ciertas actividades
  administrativas" requiere una visión global. Ver **[ASM-14]**. Queda como
  matiz no profundizado si esa visibilidad global aplica por igual a todo el
  personal administrativo o si existe una distinción de roles/permisos dentro
  de ese personal — ni el enunciado ni la respuesta lo aclaran de forma
  explícita.

## Preguntas a stakeholders simulados

- **A Estudiante/Profesor**: Cuando marcás tu entrada o salida con la
  Insignia/tarjeta DAS, ¿qué tan rápido esperás ver reflejado ese registro en
  la app móvil (segundos, minutos, al final del día)? ¿Te generaría un
  problema real que tardara más?

  - **Respuesta:**
  
    **Estudiante**

    > Para mí, lo más importante es que el registro sea **correcto y confiable**. No tendría un problema grave si tarda algunos segundos o incluso un poco más en aparecer, siempre que finalmente quede registrado correctamente.
    > 
    > Sí sería un problema si asistí a una clase y posteriormente aparezco como ausente, porque tendría que demostrar que realmente estuve presente.

    **Profesor**

    > Para mí sí sería útil que la información estuviera disponible rápidamente. Me interesa especialmente poder saber **cuántos estudiantes están presentes en una clase** y tener una visión del estado actual de la asistencia.

- **A Estudiante/Profesor**: Si el dispositivo DAS de tu campus estuviera sin
  conexión o fuera de servicio el día que tenés clase, ¿qué esperás que pase
  con tu registro de asistencia de ese día?

  - **Respuesta:**
  
    **Estudiante**

    > Esperaría que mi asistencia **no se pierda**. Si estuve presente, el sistema debería poder registrar posteriormente que asistí, aunque el dispositivo haya tenido problemas de conexión.

    **Profesor**

    > Si el dispositivo no funciona, necesitaría alguna alternativa para registrar la asistencia. Podría tomarla manualmente desde la aplicación.

- **A Estudiante/Profesor**: Durante el proceso de autorregistro, mientras
  esperás la verificación del NIS (hasta 2 horas) y la aprobación
  administrativa, ¿qué visibilidad esperás tener sobre el estado de tu
  solicitud (pendiente/aprobado/rechazado)?

  - **Respuesta:**

    Sí, necesito saber claramente en qué estado está mi solicitud.

    Esperaría como mínimo estados como:

    ```text
    Pendiente de verificación
            ↓
    Verificado / pendiente de aprobación
            ↓
    Aprobado
    ```

    o:

    ```text
    Rechazado
    ```

- **A Estudiante/Profesor**: Si sos profesor y dictás clases en más de un
  campus o ciudad, ¿esperás que tu misma Insignia DAS funcione en todos ellos
  sin trámites adicionales?

  - **Respuesta:**
  
    Sí, esperaría que mi Insignia DAS funcione en todos los campus y ciudades de la UPCA sin necesidad de trámites adicionales. Esto es importante para poder moverme entre diferentes ubicaciones sin complicaciones.

- **A Personal Administrativo**: Cuando revisás un registro que ya fue
  verificado por el NIS, ¿qué información necesitás ver en el portal para
  decidir si lo apruebas o lo rechazás? ¿Qué debería pasar con un usuario
  cuyo registro es rechazado, por vos o por el NIS?

  - **Respuesta:**
    
    **Personal administrativo**

    > Necesito poder comprobar que la persona realmente pertenece a la universidad y que cumple las condiciones necesarias para registrarse.

    Necesitaría consultar, por ejemplo:

    - información personal;
    - documentos presentados;
    - calidad de los documentos;
    - evidencia de que está matriculado o cumple las condiciones correspondientes;
    - información relacionada con su situación administrativa.
    
    **Si el registro es rechazado**

    > El usuario debería recibir una notificación indicando que su registro fue rechazado. Si es posible, sería útil conocer **el motivo del rechazo**, porque de lo contrario el usuario no sabría qué debe corregir.

- **A Personal Administrativo**: Los reportes y estadísticas de asistencia
  que consultás en el portal, ¿necesitan reflejar los datos "casi en tiempo
  real", o es aceptable que se actualicen con cierto retraso (por ejemplo,
  cada 15 minutos o una vez al día)?

  - **Respuesta:**
  
    **Personal administrativo**

    > Necesito que la información esté lo suficientemente actualizada como para conocer la situación actual de la universidad.

    > Si un estudiante acaba de registrar su entrada, no necesariamente necesito verlo exactamente en el mismo segundo, pero sí necesito que el sistema se actualice rápidamente.

    > Una actualización una vez al día no sería suficiente para este propósito.  "Casi en tiempo real" para mí significa que los datos deben ser suficientemente recientes para tomar decisiones operativas.


- **A Personal Administrativo**: ¿Necesitás poder consultar registros de
  asistencia de años anteriores (dentro de la ventana legal de 5 años) con la
  misma rapidez que los del día en curso, o es aceptable que las consultas
  históricas sean más lentas?

  - **Respuesta:**
  
    **Personal administrativo**

    > No necesariamente.

    > Para las operaciones diarias necesito que los datos actuales sean rápidos. Para consultar información de hace varios años puedo aceptar que la consulta tarde más.

    > Lo importante es que la información histórica siga disponible cuando sea necesaria.

- **A Personal Administrativo**: ¿El personal de un campus o ciudad debería
  ver únicamente los datos de asistencia de su propio campus, o necesita
  visibilidad sobre todos los campus y ciudades de UPCA?

  - **Respuesta:**
  
    **Personal administrativo**

    > Necesito poder consultar información de todos los campus.
    > La universidad tiene operaciones distribuidas en diferentes ciudades, por lo que para ciertas actividades administrativas necesito tener una visión global.


- **A Personal Administrativo**: ¿Qué debe suceder operativamente si el NIS
  no responde dentro de las 2 horas esperadas, o si rechaza la verificación
  de un usuario?

  - **Respuesta:**
  
    **Personal administrativo**
    > Si el NIS no responde después del tiempo esperado, necesito saber que existe un problema. No debería simplemente quedar como una solicitud pendiente indefinidamente.

    Esperaría:

    1. una alerta para el personal administrativo;
    2. una notificación al usuario indicando que existe una demora;
    3. que la solicitud permanezca identificada como pendiente;
    4. que exista algún mecanismo para volver a intentar la verificación.

## Supuestos explícitos

- **[ASM-01]** El NIS (Servicio de Identificación Nacional) es un sistema
  externo a UPCA, fuera del control operativo del equipo que diseña el DAS
  (no se puede modificar su SLA, su disponibilidad ni el contrato de su API).
  — **Criterio usado**: el nombre "Servicio de Identificación Nacional", su
  descripción como integración "a distancia... basado en API"
  (`capstone.pdf`, "Autorregistro a través de un portal en línea") y el hecho
  de que su latencia de hasta 2 horas se presenta como un dato impuesto y no
  negociable son consistentes con un servicio gubernamental de terceros. Se
  asume esto porque, sin esta condición de contorno, no es posible razonar
  sobre integración asíncrona como driver.

- **[ASM-02]** Las 10 ciudades y 20 campus de UPCA se encuentran dentro de un
  mismo país / misma jurisdicción regulatoria, cubiertos por un único NIS. —
  **Criterio usado**: el "Servicio de Identificación Nacional" se nombra en
  singular, sin distinción por ciudad o país; si UPCA operara en múltiples
  países con distintos servicios de identificación nacional, el enunciado
  probablemente lo mencionaría explícitamente dado que es una entidad externa
  crítica para el flujo de registro.

- **[ASM-03]** El crecimiento de ~10.000 usuarios nuevos en los próximos dos
  años se distribuye sobre la infraestructura de campus ya existente (20
  campus, 10 ciudades), sin apertura de nuevas sedes en ese período. —
  **Criterio usado**: el enunciado cuantifica exclusivamente el crecimiento
  de usuarios ("La UPCA prevé añadir unos 10.000 nuevos usuarios en los
  próximos dos años", `capstone.pdf`, "Requerimientos no funcionales") y en
  ningún momento cuantifica ni menciona crecimiento de campus o ciudades; en
  ausencia de esa información se asume topología física constante, para
  poder acotar el problema de escalabilidad a "más usuarios por sitio" y no
  también a "más sitios".

- **[ASM-04]** El requisito de retención de 5 años aplica, como mínimo, a los
  eventos de asistencia (usuario, fecha, ubicación, entrada/salida), y no
  necesariamente a los documentos de identidad y fotografías capturados
  durante el autorregistro. — **Criterio usado**: la frase que establece la
  retención de 5 años aparece en el mismo punto de la lista de requisitos no
  funcionales que describe el "proceso de registro de entrada y salida"
  (`capstone.pdf`, "Requerimientos no funcionales"), lo que sugiere que su
  sujeto principal es el evento de asistencia. Este supuesto se adopta solo
  para poder avanzar con un alcance mínimo defendible; el alcance completo
  permanece abierto en **[AMB-04]**.

- **[ASM-05]** La "verificación digital" del DAS ID mencionada en la sección
  de identificación del usuario (consulta de la credencial desde la app
  móvil) es una capacidad distinta del mecanismo físico de captura de
  asistencia mediante el escaneo de la Insignia/tarjeta DAS en cada campus. —
  **Criterio usado**: el enunciado describe estas dos capacidades en
  secciones separadas ("Identificación del usuario mediante DAS ID" vs.
  "Proceso de registro de entrada y salida") con propósitos distintos
  (consulta personal de la propia credencial vs. captura oficial de
  asistencia por un dispositivo dedicado) sin unificarlas explícitamente en
  ningún momento del texto.

> Los supuestos **ASM-06** a **ASM-15** se agregaron durante la reconciliación
> posterior a las respuestas de los stakeholders simulados. A diferencia de
> ASM-01 a ASM-05 (que se apoyan en inferencias sobre `capstone.pdf`), estos
> se apoyan en respuestas de stakeholders **simulados** — por lo tanto siguen
> etiquetados como supuesto y no como requisito, ya que no provienen del
> enunciado oficial.

- **[ASM-06]** Los stakeholders simulados priorizan la exactitud y
  confiabilidad del registro de asistencia por sobre la velocidad exacta de
  reflejo: una demora de algunos segundos (o incluso algo más) en la app es
  aceptable, siempre que el dato final quede registrado correctamente; lo que
  genera un problema real es que un usuario presente aparezca como ausente.
  — **Criterio usado**: respuesta textual del Estudiante simulado a la
  pregunta sobre velocidad de reflejo del registro de entrada/salida (ver
  "Preguntas a stakeholders simulados"). Se adopta como supuesto, no como
  requisito, porque proviene de una simulación de stakeholder y no del
  enunciado oficial (`capstone.pdf`). Resuelve parcialmente **[AMB-01]** en
  su dimensión cualitativa de prioridades, sin fijar un número.

- **[ASM-07]** Ante la pérdida de conectividad o falla de un dispositivo DAS,
  la expectativa funcional es que el registro de asistencia real del usuario
  no se pierda: el sistema debe permitir que quede registrado posteriormente,
  incluyendo la posibilidad de un registro manual desde la app por parte del
  profesor cuando el dispositivo no funciona. — **Criterio usado**:
  respuestas del Estudiante ("esperaría que mi asistencia no se pierda... el
  sistema debería poder registrar posteriormente que asistí") y del Profesor
  ("necesitaría alguna alternativa para registrar la asistencia. Podría
  tomarla manualmente desde la aplicación") a la pregunta sobre
  comportamiento ante pérdida de conectividad. Reemplaza a **[AMB-02]**, que
  queda documentada como resuelta a nivel de expectativa funcional; el
  mecanismo técnico concreto (cola offline, sincronización, ventana de tiempo
  permitida) sigue siendo una decisión de diseño abierta para Milestone 2, no
  una ambigüedad del enunciado.

- **[ASM-08]** Durante la espera de verificación NIS (hasta 2 horas) y de
  aprobación administrativa, el usuario espera tener visibilidad explícita
  del estado de su solicitud, distinguiendo como mínimo los estados:
  pendiente de verificación → verificado/pendiente de aprobación → aprobado,
  o bien rechazado. — **Criterio usado**: respuesta del Estudiante/Profesor
  simulados a la pregunta sobre visibilidad del estado de la solicitud
  durante el autorregistro. Es información nueva que matiza **REQ-04** y
  **DRV-02**; no estaba cubierta por ninguna ambigüedad previamente
  identificada.

- **[ASM-09]** La Insignia DAS de un usuario —en particular la de un profesor
  que dicta clases en más de un campus o ciudad— debe funcionar en todos los
  campus y ciudades de la red UPCA sin trámites adicionales. — **Criterio
  usado**: respuesta del Estudiante/Profesor simulados a la pregunta sobre
  profesores que dictan clases en más de un campus. Matiza **REQ-01**,
  **REQ-05**, **REQ-06** y el driver **DRV-01** (Escalabilidad/distribución
  multi-campus); no reemplaza ninguna ambigüedad existente, es información
  adicional.

- **[ASM-10]** Para decidir si aprueba o rechaza un registro ya verificado
  por el NIS, el personal administrativo necesita ver, como mínimo:
  información personal del solicitante, los documentos presentados, la
  calidad/legibilidad de esos documentos, evidencia de matrícula o
  cumplimiento de las condiciones correspondientes, e información de su
  situación administrativa. — **Criterio usado**: respuesta del Personal
  Administrativo simulado a la pregunta sobre qué información necesita para
  revisar un registro ya verificado por el NIS. Matiza **REQ-04** y
  **DRV-02**.

- **[ASM-11]** Ante el rechazo de un registro —ya sea por el NIS o por el
  personal administrativo— la expectativa funcional es que el usuario reciba
  una notificación indicando el rechazo, incluyendo, de ser posible, el
  motivo, para que pueda corregirlo. — **Criterio usado**: respuesta del
  Personal Administrativo simulado a la misma pregunta ("Si el registro es
  rechazado..."). Resuelve parcialmente **[AMB-05]** en su dimensión de
  manejo de rechazo; no resuelve la dimensión de orden/dependencia estricta
  entre NIS y aprobación administrativa, que permanece abierta.

- **[ASM-12]** Los reportes y estadísticas del portal administrativo deben
  actualizarse con una cadencia "suficientemente rápida" para reflejar la
  situación operativa actual de la universidad; una actualización una vez al
  día se considera explícitamente insuficiente, aunque no se exige que el
  reflejo sea al mismo segundo del evento. — **Criterio usado**: respuesta
  del Personal Administrativo simulado a la pregunta sobre si los reportes
  necesitan ser "casi en tiempo real" o pueden actualizarse con retraso.
  Resuelve parcialmente **[AMB-01]** en la dimensión de si el umbral de
  "near real-time" aplica también al portal (sí aplica); el número exacto
  sigue sin definirse.

- **[ASM-13]** Es aceptable que las consultas de registros de asistencia
  históricos (de años anteriores, dentro de la ventana legal de 5 años) sean
  más lentas que las consultas de datos del día en curso; lo prioritario es
  que la información histórica permanezca disponible cuando se necesite, no
  que responda con la misma rapidez que las operaciones diarias. —
  **Criterio usado**: respuesta del Personal Administrativo simulado a la
  pregunta sobre si las consultas históricas deben tener la misma rapidez que
  las del día en curso. Es información nueva que matiza **REQ-08**,
  **REQ-12** y el driver **DRV-04** (Retención de 5 años); no reemplaza
  ninguna ambigüedad previamente identificada, ya que ninguna de las AMB-01 a
  AMB-09 formuladas originalmente cubría específicamente la velocidad de
  consulta histórica.

- **[ASM-14]** El personal administrativo necesita visibilidad sobre los
  datos de asistencia de todos los campus y ciudades de UPCA, no solo del
  propio, dado que la universidad opera de forma distribuida y ciertas
  actividades administrativas requieren una visión global. — **Criterio
  usado**: respuesta del Personal Administrativo simulado a la pregunta sobre
  aislamiento de datos por campus/ciudad. Reemplaza a **[AMB-09]**, que queda
  documentada como resuelta. Queda como matiz no profundizado si esta
  visibilidad global aplica por igual a todo el personal administrativo o si
  existe una distinción de roles/permisos dentro de ese personal — ni el
  enunciado ni la respuesta lo aclaran explícitamente ("para ciertas
  actividades administrativas").

- **[ASM-15]** Si el NIS no responde dentro de las 2 horas esperadas, la
  expectativa funcional del personal administrativo es: (1) recibir una
  alerta, (2) que el usuario sea notificado de la demora, (3) que la
  solicitud permanezca identificada como pendiente (no se pierde ni se
  cancela automáticamente), y (4) que exista algún mecanismo para reintentar
  la verificación. — **Criterio usado**: respuesta del Personal
  Administrativo simulado a la pregunta sobre qué debe suceder si el NIS no
  responde a tiempo o rechaza la verificación. Resuelve parcialmente
  **[AMB-05]** en su dimensión de manejo de demora/timeout del NIS.

## Restricciones no negociables

Estas condiciones están explícitamente dichas en las fuentes —o, en el caso
de RST-01, en una aclaración explícita del usuario/instructor del capstone
que corrige un malentendido de alcance sobre esa misma fuente— y no admiten
negociación ni reinterpretación por parte del diseño:

> **Nota de corrección (RST-01, 24-08-2026)** — La redacción original de este
> documento decía "El proyecto es individual (`plan/milestones.pdf`, 'Otros —
> Tamaño del equipo')" y fue usada en cascada, en Milestone 2 y Milestone 3,
> como si significara que el sistema DAS sería diseñado, desplegado y operado
> por una sola persona de forma permanente (ver
> `design/adr/adr-0013-monolito-modular-fase1-extraccion-selectiva.md` y
> `design/milestone-3/risk-register.md`, `RISK-01`). El usuario aclaró
> explícitamente el malentendido: "El proyecto menciona que es individual
> pero se refiere al trabajo a presentar [la entrega académica del
> capstone], no que en la realidad solo hay una persona que ejecuta [el
> sistema DAS]". Es decir: que el capstone se entregue de forma individual es
> una condición académica de la evaluación del curso, no una restricción real
> y permanente del sistema DAS que se está diseñando. RST-01 se reformula en
> consecuencia (texto vigente más abajo), separando explícitamente (a) la
> condición académica de entrega individual — que no es una restricción
> arquitectónica del sistema DAS, y se documenta aparte solo para dejar
> constancia de por qué no cuenta como tal — de (b) la restricción operativa
> real que sí condiciona el diseño: que el sistema DAS sea operable por un
> equipo pequeño de desarrollo (3 a 5 personas), no por una organización con
> equipos de plataforma/DevOps/SRE dedicados por servicio. Esta corrección
> **no reescribe** `ADR-0013` ni `RISK-01` — queda como insumo explícito para
> que `architecture-strategist`, en un paso siguiente, evalúe si su
> conclusión (Monolito Modular en Fase 1, justificada por complejidad
> operable para "una persona") sigue sosteniéndose bajo la restricción
> corregida (equipo de 3 a 5 desarrolladores, sin equipos de plataforma
> dedicados) o si amerita ajuste de matiz en su justificación.

- **[RST-01]** El sistema DAS debe poder ser construido, desplegado y operado
  por un **equipo de desarrollo pequeño** (del orden de 3 a 5
  desarrolladores), sin equipos de plataforma/DevOps/SRE dedicados por
  servicio ni estructura organizacional de gran escala — no por una sola
  persona de forma indefinida, ni por una organización con la capacidad
  operativa de una empresa con equipos especializados por dominio. —
  **Fuente**: aclaración explícita del usuario/instructor del capstone (no es
  una cita textual de `capstone.pdf`, que no menciona en ningún momento el
  tamaño del equipo real que construiría u operaría el DAS): "El proyecto
  menciona que es individual pero se refiere al trabajo a presentar [la
  entrega académica del capstone], no que en la realidad solo hay una persona
  que ejecuta [el sistema DAS]"; en un contexto realista, el sistema sería
  construido y operado por un equipo pequeño (3 a 5 desarrolladores), no por
  una sola persona de forma indefinida. Esta redacción **reemplaza** a la
  anterior de RST-01 ("El proyecto es individual"), que mezclaba
  indebidamente la condición académica con la restricción operativa real —
  ver nota de corrección arriba.

  **Nota sobre la condición académica de entrega individual** (se documenta
  aparte, precisamente para que quede explícito que *no* es una restricción
  de diseño): que el *capstone* —el trabajo a presentar en este curso— se
  entregue de forma individual es una condición de evaluación académica
  (`plan/milestones.pdf`, "Otros — Tamaño del equipo"). No tiene ninguna
  implicancia arquitectónica sobre el sistema DAS y no debe volver a citarse
  como fundamento de ninguna decisión de diseño (`ADR-NN`) ni de ningún
  riesgo (`RISK-NN`) sobre el DAS en sí.

  **Nota sobre precisión numérica**: el rango "3 a 5 desarrolladores" es el
  orden de magnitud que el usuario indicó para poder razonar con realismo
  sobre la complejidad operable del sistema, no un número exacto derivado de
  `capstone.pdf` (que no dice nada sobre el tamaño de equipo real). Se
  documenta explícitamente como tal para no inventar una precisión que
  ninguna fuente sostiene con exactitud; si Milestone 2 o 3 necesitaran un
  número puntual (no un rango) para alguna decisión concreta, eso debería
  tratarse como un supuesto de diseño adicional a validar, no como un dato ya
  fijado por esta restricción.

- **[RST-02]** La verificación con el NIS no se realiza en tiempo real y
  puede tardar hasta 2 horas en completarse (`capstone.pdf`, "Autorregistro a
  través de un portal en línea (cont.)").
- **[RST-03]** Los registros de asistencia deben conservarse un mínimo de
  cinco años, por requisito legal, no por preferencia de diseño
  (`capstone.pdf`, "Requerimientos no funcionales").
- **[RST-04]** El registro de un usuario requiere dos aprobaciones
  encadenadas de origen distinto: verificación del NIS y aprobación del
  personal administrativo de la universidad — ninguna de las dos es opcional
  (`capstone.pdf`, "Autorregistro a través de un portal en línea (cont.)").
- **[RST-05]** "Los datos del DAS deben ser confidenciales y seguros"
  (`capstone.pdf`, "Portal web administrativo") — declarado como obligación,
  no como aspiración.

## Requerimientos priorizados (alto nivel)

- **[REQ-01]** Cada usuario (estudiante o profesor) tiene un DAS ID único,
  verificable digitalmente desde la app móvil DAS, con acceso a datos
  personales (nombre, fecha de nacimiento, correo, teléfono, sexo, función) y
  seguimiento de asistencia a clases o eventos. — cita: `capstone.pdf`,
  "Identificación del usuario mediante DAS ID".
- **[REQ-02]** Los usuarios pueden autorregistrarse desde la app móvil DAS
  presentando documento de identidad oficial, fotografía y datos personales.
  — cita: `capstone.pdf`, "Autorregistro a través de un portal en línea".
- **[REQ-03]** El autorregistro incluye una verificación a distancia con el
  NIS, basada en API, para garantizar la exactitud de los datos. — cita:
  `capstone.pdf`, "Autorregistro a través de un portal en línea".
- **[REQ-04]** Esa verificación no es en tiempo real, puede tardar hasta 2
  horas, y su confirmación se envía por correo electrónico a la universidad;
  además, el personal administrativo debe aprobar el registro. — cita:
  `capstone.pdf`, "Autorregistro a través de un portal en línea (cont.)".
- **[REQ-05]** Tras el registro y la verificación del NIS, cada usuario
  recibe una Insignia DAS (identificación imprimible o guardable en
  dispositivo móvil) con foto e identificador único. — cita: `capstone.pdf`,
  "Creación de la Insignia DAS".
- **[REQ-06]** Los usuarios registran entrada y salida de instalaciones y
  eventos mediante un dispositivo DAS en cada campus que escanea su
  Insignia/tarjeta; los registros se almacenan por usuario, día y ubicación.
  — cita: `capstone.pdf`, "Proceso de registro de entrada y salida".
- **[REQ-07]** Existe un portal administrativo web con acceso a todos los
  datos del campus, informes y herramientas estadísticas de asistencia, y
  gestión de cursos/eventos. — cita: `capstone.pdf`, "Portal web
  administrativo".
- **[REQ-08]** Los estudiantes y profesores pueden consultar su propio estado
  de asistencia vía la app móvil DAS. — cita: `capstone.pdf`, "Portal web
  administrativo".
- **[REQ-09]** Los datos del DAS deben ser confidenciales y seguros. — cita:
  `capstone.pdf`, "Portal web administrativo".
- **[REQ-10]** El sistema debe soportar un crecimiento de ~10.000 usuarios
  nuevos en los próximos dos años (de ~5.000 a ~15.000), manteniendo un
  rendimiento eficiente. — cita: `capstone.pdf`, "Requerimientos no
  funcionales".
- **[REQ-11]** El proceso de registro de entrada y salida debe ser lo más
  cercano posible al tiempo real. — cita: `capstone.pdf`, "Requerimientos no
  funcionales".
- **[REQ-12]** Los registros de asistencia deben conservarse un mínimo de
  cinco años en cumplimiento de requisitos legales. — cita: `capstone.pdf`,
  "Requerimientos no funcionales".

## Architectural Drivers

Los cinco drivers sugeridos por `plan/milestones.pdf` tienen, cada uno,
respaldo textual directo y explícito en `capstone.pdf` — no fue necesario
descartar ninguno de los cinco ni encontramos, dentro del texto del
enunciado, un sexto driver con el mismo nivel de respaldo directo. Sí se
identificaron dos candidatos adicionales que se evaluaron y **no** se
promovieron a driver, documentados al final de esta sección, junto con la
justificación de por qué no califican todavía.

### [DRV-01] Escalabilidad y rendimiento

**Justificación**: "La UPCA prevé añadir unos 10.000 nuevos usuarios en los
próximos dos años. DAS está diseñado para hacer frente a este crecimiento
previsto, manteniendo al mismo tiempo un rendimiento eficiente."
(`capstone.pdf`, "Requerimientos no funcionales"). Esto es un crecimiento del
~200% en la base de usuarios (de ~5.000 estudiantes + 400 profesores a un
total ~15.000) en un horizonte de tiempo fijo, declarado explícitamente como
requisito no funcional — no es una inferencia nuestra. Condiciona
directamente cualquier decisión de arquitectura relacionada con capacidad,
particionamiento de datos y distribución geográfica entre 20 campus y 10
ciudades.

### [DRV-02] Integración asíncrona con NIS

**Justificación**: "El registro incluye un proceso de verificación a
distancia con el Servicio de Identificación Nacional (NIS) para garantizar la
exactitud de los datos (basado en API)" y "La verificación no se realiza en
tiempo real y puede tardar hasta 2 horas en completarse; la confirmación se
envía por correo electrónico al emisor (Universidad)" (`capstone.pdf`,
"Autorregistro a través de un portal en línea" y "(cont.)"). El enunciado
declara explícitamente que esta integración es asíncrona y con una latencia
alta e impuesta por un tercero — esto obliga a cualquier arquitectura a tratar
el registro de usuario como un proceso con estados intermedios, no como una
operación síncrona de solicitud/respuesta.

### [DRV-03] Seguridad y confidencialidad

**Justificación**: "Los datos del DAS deben ser confidenciales y seguros"
(`capstone.pdf`, "Portal web administrativo"), en un sistema que maneja
explícitamente datos personales sensibles (documento de identidad, foto,
fecha de nacimiento, sexo, teléfono, correo) recopilados en el autorregistro
y expuestos tanto en el portal administrativo como en la app móvil de cada
usuario (`capstone.pdf`, "Identificación del usuario mediante DAS ID" y
"Autorregistro a través de un portal en línea"). Es una obligación declarada
en el propio enunciado, no una buena práctica genérica añadida por este
análisis.

### [DRV-04] Retención de 5 años

**Justificación**: "los registros de asistencia deben conservarse durante un
mínimo de cinco años en cumplimiento de los requisitos legales"
(`capstone.pdf`, "Requerimientos no funcionales"). Es un requisito legal
explícito, con un horizonte temporal muy superior al de la operación diaria
del sistema (registro y consulta "cercanos al tiempo real"), lo que introduce
una tensión declarada por el propio enunciado entre dos exigencias de
naturaleza distinta sobre el mismo dato: acceso casi inmediato al momento de
la captura, y conservación obligatoria de largo plazo.

### [DRV-05] Asistencia casi en tiempo real (near real-time attendance)

**Justificación**: "Aunque el proceso de registro de entrada y salida debe
ser lo más cercano posible al tiempo real, los registros de asistencia deben
conservarse durante un mínimo de cinco años..." (`capstone.pdf`,
"Requerimientos no funcionales"). El propio enunciado usa la palabra "aunque"
para contraponer este requisito con el de retención (DRV-04), lo que confirma
que se trata de dos drivers en tensión reconocida por la fuente, no de un
único requisito genérico de "rendimiento". El umbral numérico no está dado
(ver **[AMB-01]**) — lo que está dado, y es innegociable, es la exigencia de
cercanía al tiempo real como propiedad del sistema.

### Candidatos evaluados y no promovidos a driver

- **Distribución geográfica multi-campus/multi-ciudad (20 campus, 10
  ciudades)**: tiene respaldo textual (`capstone.pdf`, "Descripción
  General"), pero el enunciado no le atribuye ninguna exigencia no funcional
  propia (no dice, por ejemplo, que deba haber resiliencia por región o
  independencia entre campus) — sus consecuencias arquitectónicas relevantes
  ya están cubiertas por la cuantificación de crecimiento en DRV-01
  (Escalabilidad) y por la pregunta abierta de aislamiento de datos en
  **[AMB-09]** (ahora resuelta a nivel de expectativa funcional, ver
  **[ASM-14]**: se requiere visibilidad global del personal administrativo,
  no aislamiento estricto por campus). Se decide no crear un driver separado
  por falta de un requisito no funcional propio distinto de escalabilidad
  declarado en `capstone.pdf`.
- **Disponibilidad/continuidad ante fallas de conectividad de los
  dispositivos DAS**: mencionado como riesgo en `plan/milestones.pdf`
  (Milestone 3, "Dispositivos SAD offline / Pérdida de conectividad"), pero
  **sin ningún respaldo textual en `capstone.pdf`** (ver **[AMB-02]**, ahora
  resuelta a nivel de expectativa funcional y movida a **[ASM-07]**). Ese
  respaldo sigue faltando en el enunciado oficial —la resolución vino de una
  respuesta de stakeholder simulado, no de `capstone.pdf`— por lo que, según
  la regla de este milestone de no promover drivers sin cita concreta del
  enunciado, se mantiene la decisión de no promoverlo a driver formal de
  Milestone 1; el supuesto funcional (**ASM-07**) queda disponible como
  condición a satisfacer igualmente por el diseño.
