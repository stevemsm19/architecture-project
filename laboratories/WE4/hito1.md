Hito 1: Exploración y Aprendizaje

Nos aseguraremos de comprender el problema, el contexto arquitectónico y las estrategias posibles antes de diseñar una solución.

1.1 Analizaremos el escenario para identificar:

- Qué partes del sistema actúan como productores y cuáles como consumidores,
- Por qué el análisis de hashtags es un proceso de larga duración,
- En qué situaciones concretas aparece o debería aparecer la contrapresión (picos de tráfico, eventos globales).
- Pedir a la IA explicaciones alternativas del problema, ejemplos similares en sistemas reales, o reformulaciones del escenario en lenguaje más simple. Buscamos buenos prompt, completos, estratégicos.

1.2 Investigación de conceptos clave

Con la IA, material teórico y las notas de clase, generar unas buenas definiciones para:

- Procesos de Larga Duración
- Productores y Consumidores
- Contrapresión (Backpressure)
- Colas, buffers y desacoplamiento
- Procesamiento síncrono vs asíncrono

No queremos definiciones extremadamente técnicas. Tampoco definiciones para la tía Rosa que no usa ni celular. Un punto que podamos leer e interiorizar los conceptos, usando analogías, comparaciones (“explícamelo como si fuera un sistema de colas en un supermercado”), y, una sugerencia: contraejemplos.

1.3  Exploración de estrategias arquitectónicas

Busquemos las distintas estratégias que podemos usar para manejar la contrapresión, por ejemplo:

- uso de colas de mensajes
- escalado de consumidores
- limitación de la tasa de entrada
- degradación controlada del servicio
- alguna otra

No queremos elegir una solución, solo explorar y conocer las alternativas, entendiendo sus implicancias. Sugiero que iteren con la IA para conocer cómo respondería cada una de las soluciones a nuestro problema y compararlas con criterios útiles.

---

# Hito 1 — Exploración y Aprendizaje

## GlobalNewsFeed: Análisis de Hashtags en Tendencia

## Introducción

GlobalNewsFeed necesita analizar continuamente las publicaciones generadas por sus usuarios para identificar los hashtags que están ganando popularidad y mostrar tendencias actualizadas. En condiciones normales, este flujo puede mantenerse estable; sin embargo, durante eventos globales, noticias de último momento o picos inesperados de tráfico, la cantidad de publicaciones puede aumentar rápidamente y superar la capacidad del sistema encargado de analizarlas.

Antes de definir una arquitectura para resolver este problema, es necesario comprender cómo se comporta el flujo de información, por qué el análisis de hashtags debe considerarse un proceso de larga duración y qué ocurre cuando productores y consumidores trabajan a velocidades diferentes.

Por esta razón, este primer hito se concentra en **explorar el problema y las posibles estrategias de contrapresión**, sin seleccionar todavía una solución definitiva. El objetivo es comprender las alternativas disponibles, sus ventajas, limitaciones y comportamiento frente al escenario de GlobalNewsFeed, de manera que posteriormente puedan tomarse decisiones arquitectónicas justificadas.

---

## 1.1 Análisis del escenario

### 1.1.1 Identificación de productores y consumidores

El escenario de **GlobalNewsFeed** describe un flujo continuo de datos donde diferentes componentes participan en la generación, procesamiento y consulta de información. Identificar quién produce y quién consume permite entender dónde puede aparecer un desbalance entre la velocidad con la que llegan las publicaciones y la capacidad disponible para analizarlas.

| Componente                                | Rol                      | Función principal                                                                                                             |
| ----------------------------------------- | ------------------------ | ----------------------------------------------------------------------------------------------------------------------------- |
| **Usuarios**                              | Productores indirectos   | Generan publicaciones que contienen los hashtags que posteriormente serán analizados                                          |
| **Servicio de Ingesta**                   | Productor                | Recibe las publicaciones y las incorpora al flujo de procesamiento sin realizar el análisis completo                          |
| **Proceso de Análisis de Hashtags (PLD)** | Consumidor principal     | Consume continuamente las publicaciones, extrae hashtags, actualiza estadísticas y determina cuáles están ganando popularidad |
| **Servicio de Tendencias**                | Consumidor de resultados | Utiliza los resultados generados por el análisis para mostrar las tendencias a los usuarios                                   |

Desde la perspectiva del pipeline de procesamiento, el **Servicio de Ingesta** funciona como productor y el **Proceso de Análisis de Hashtags** como consumidor principal. Ambos pueden trabajar a velocidades diferentes: recibir una publicación es relativamente rápido, mientras que analizarla requiere extraer información y actualizar continuamente el estado utilizado para calcular las tendencias.

Mientras ambas velocidades sean similares, el flujo puede mantenerse estable. El problema aparece cuando la tasa de producción supera durante un periodo sostenido la capacidad de consumo. En ese momento comienza a acumularse trabajo pendiente y aparece la necesidad de aplicar mecanismos de contrapresión.

### 1.1.2 Naturaleza del proceso de análisis

El análisis de hashtags se considera un **Proceso de Larga Duración (Long-Running Process)** porque no corresponde a una operación puntual que comienza y termina con una única solicitud. Su trabajo consiste en analizar un flujo continuo de publicaciones que se mantiene activo mientras la plataforma está funcionando.

Cada nueva publicación puede modificar los conteos existentes y afectar cuáles hashtags se consideran tendencia. Por esta razón, el proceso necesita mantener información acumulada y actualizarla continuamente a medida que recibe nuevos eventos.

Además, el procesamiento no debería depender de que una solicitud permanezca abierta esperando a que termine el análisis. El usuario publica contenido, la plataforma recibe la publicación y el análisis puede continuar de manera independiente. Esta separación resulta especialmente importante cuando existen grandes cantidades de información por procesar.

Al mantenerse activo durante periodos prolongados, el proceso también debe considerar situaciones como interrupciones, recuperación después de fallos y acumulación temporal de trabajo. Estas características hacen que el análisis de hashtags sea diferente de una operación tradicional de corta duración.

### 1.1.3 Escenarios donde aparece la contrapresión

La contrapresión (**Backpressure**) se vuelve relevante cuando el sistema comienza a recibir trabajo a una velocidad superior a la que puede procesarlo. En GlobalNewsFeed, esto puede ocurrir principalmente cuando aumenta repentinamente la cantidad de publicaciones o cuando disminuye temporalmente la capacidad del proceso de análisis.

| Escenario                                  | ¿Qué ocurre?                                                                                                                                 | Riesgo para el sistema                                                                           |
| ------------------------------------------ | -------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------ |
| **Evento global**                          | Millones de usuarios pueden publicar simultáneamente alrededor de una final deportiva, elecciones, una noticia mundial o un desastre natural | La entrada supera temporalmente la capacidad de análisis y comienza a acumularse trabajo         |
| **Pico inesperado de tráfico**             | La tasa de publicaciones aumenta rápidamente por encima del comportamiento habitual                                                          | Aumenta la diferencia entre producción y consumo, junto con la latencia del procesamiento        |
| **Procesamiento más lento de lo esperado** | Los cálculos, consultas o utilización elevada de recursos reducen la velocidad del análisis                                                  | La acumulación puede crecer incluso aunque la tasa de entrada permanezca estable                 |
| **Problemas de infraestructura o red**     | Una degradación temporal reduce la capacidad disponible para procesar información                                                            | Las publicaciones pueden continuar llegando mientras los consumidores trabajan a menor velocidad |

Un ejemplo sencillo es imaginar una **caja de supermercado**. Los clientes representan las publicaciones y el cajero representa al consumidor. Mientras llegan clientes aproximadamente al mismo ritmo en que el cajero puede atenderlos, la fila permanece controlada. Si llegan cien personas al mismo tiempo y existe una sola caja, la fila comienza a crecer.

En un sistema distribuido ocurre algo similar. La diferencia es que permitir que esa acumulación crezca indefinidamente puede terminar agotando memoria, almacenamiento, conexiones u otros recursos. Por ello, la contrapresión no consiste únicamente en detectar que el sistema está lento, sino en decidir **cómo reaccionar cuando la capacidad de consumo deja de ser suficiente**.

### 1.1.4 Perspectiva general del problema

Desde una perspectiva de negocio, el desafío no consiste únicamente en contar hashtags. GlobalNewsFeed necesita mantener un flujo continuo de análisis incluso cuando el comportamiento de los usuarios cambia de manera repentina.

Durante un evento global, detener completamente la recepción de publicaciones porque el análisis está saturado tendría un impacto directo sobre la plataforma. Al mismo tiempo, permitir que el trabajo pendiente crezca sin ningún control podría trasladar el problema a otros componentes y eventualmente afectar la estabilidad del sistema completo.

Por lo tanto, el problema puede reformularse de una manera más sencilla:

**¿Cómo puede GlobalNewsFeed continuar recibiendo y analizando publicaciones cuando estas llegan temporalmente más rápido de lo que pueden ser procesadas, sin permitir que la acumulación de trabajo comprometa la estabilidad del sistema?**

Este tipo de situación es habitual en sistemas que procesan grandes flujos de eventos. Por ello, existen diferentes mecanismos arquitectónicos para desacoplar productores y consumidores, absorber variaciones temporales de tráfico, aumentar capacidad o reducir controladamente la carga cuando el sistema alcanza sus límites.

---

## 1.2 Investigación de conceptos clave

Antes de comparar estas estrategias, es necesario establecer algunos conceptos que permiten comprender el problema de contrapresión y las decisiones que pueden tomarse para manejarlo.

### Procesos de Larga Duración

Un **Proceso de Larga Duración** es una ejecución que permanece activa durante un periodo considerable o que no tiene un final inmediato porque procesa trabajo continuamente. Puede requerir mantener estado, recuperarse después de interrupciones y continuar trabajando sin mantener bloqueada una solicitud del usuario.

En GlobalNewsFeed, el análisis de hashtags cumple estas características porque las publicaciones continúan llegando y las tendencias deben recalcularse constantemente.

Una forma sencilla de entenderlo es compararlo con la vigilancia de una cámara de seguridad. No se enciende la cámara, se observa un único segundo y se considera terminado el trabajo. El proceso permanece activo mientras exista información que observar.

**Contraejemplo:** validar el formato de un correo electrónico durante un registro no sería un proceso de larga duración. Es una operación corta que puede completarse dentro de la misma solicitud.

### Productores y Consumidores

El patrón de **productores y consumidores** separa a los componentes que generan trabajo de aquellos que lo procesan. El productor puede continuar generando información mientras uno o varios consumidores se encargan de procesarla según su capacidad.

En GlobalNewsFeed, el Servicio de Ingesta produce el flujo que posteriormente debe ser procesado por el análisis de hashtags.

La comparación con un supermercado también resulta útil: los clientes que llegan generan trabajo y los cajeros lo consumen. El problema aparece cuando los clientes llegan más rápido de lo que pueden ser atendidos.

Esta separación permite que productor y consumidor evolucionen y escalen de manera independiente, pero también introduce una pregunta importante: **¿qué ocurre cuando sus velocidades son diferentes?**

### Contrapresión (Backpressure)

La **contrapresión** es el conjunto de mecanismos utilizados para controlar una situación en la que los productores generan trabajo más rápido de lo que los consumidores pueden procesarlo.

Su objetivo no necesariamente es hacer que el consumidor sea más rápido, sino impedir que el desbalance crezca indefinidamente hasta comprometer la estabilidad del sistema. Dependiendo de la estrategia, esto puede implicar acumular temporalmente trabajo, reducir la tasa de entrada, aumentar consumidores o incluso descartar información cuando el sistema alcanza una situación extrema.

Volviendo al supermercado, la contrapresión aparece cuando la fila comienza a superar la capacidad de las cajas. El establecimiento puede abrir nuevas cajas, controlar la entrada o establecer otras medidas para evitar que la acumulación continúe creciendo sin límite.

**Contraejemplo:** si llegan diez publicaciones por segundo y el sistema puede procesar constantemente cien, no existe una situación de contrapresión aunque haya un flujo continuo de información.

### Colas, buffers y desacoplamiento

Las **colas y buffers** permiten almacenar temporalmente información entre productores y consumidores. Su propósito es evitar que ambos componentes tengan que trabajar exactamente a la misma velocidad y al mismo tiempo.

Si durante algunos segundos llegan más publicaciones de las que pueden analizarse, un buffer puede conservar temporalmente ese exceso mientras el consumidor recupera capacidad. Esto produce **desacoplamiento**, ya que el productor no necesita esperar a que cada publicación termine de ser procesada antes de recibir la siguiente.

Sin embargo, una cola no elimina por sí sola el problema de contrapresión. Si durante una hora ingresan más eventos de los que pueden procesarse, la cola simplemente continuará creciendo. Por esta razón, funciona bien para absorber diferencias temporales, pero necesita combinarse con otras estrategias cuando la saturación es sostenida.

**Contraejemplo:** utilizar una cola con capacidad prácticamente ilimitada y asumir que esto resuelve cualquier pico de tráfico únicamente aplaza el problema si los consumidores nunca consiguen recuperar el ritmo.

### Procesamiento síncrono vs. asíncrono

En un procesamiento **síncrono**, quien inicia una operación espera a que esta termine para continuar o recibir una respuesta. Esto puede ser adecuado para tareas rápidas donde el resultado se necesita inmediatamente.

En un procesamiento **asíncrono**, el trabajo puede ser aceptado y procesado posteriormente sin mantener bloqueado al componente que lo originó. Esto permite separar la velocidad de recepción de la velocidad de procesamiento.

Para GlobalNewsFeed, obligar al Servicio de Ingesta a esperar a que termine todo el análisis de una publicación aumentaría el acoplamiento entre ambos procesos. Un enfoque asíncrono permite recibir las publicaciones y procesarlas de acuerdo con la capacidad disponible.

La diferencia puede compararse con pedir comida. Un modelo completamente síncrono sería permanecer en el mostrador hasta que el pedido esté preparado antes de permitir que se atienda a la siguiente persona. En un modelo asíncrono, se registra el pedido, se entrega un número y la preparación continúa mientras se reciben nuevos pedidos.

---

## 1.3 Exploración de estrategias arquitectónicas

Una vez comprendido el problema, es posible explorar diferentes estrategias para manejar la contrapresión. En esta etapa **no se busca seleccionar una solución definitiva**, sino analizar cómo respondería cada alternativa ante los escenarios identificados y cuáles serían sus principales implicaciones.

Las estrategias no son necesariamente excluyentes. Algunas actúan sobre la acumulación de trabajo, otras sobre la capacidad de procesamiento y otras directamente sobre la cantidad de tráfico que el sistema acepta. Por esta razón, pueden utilizarse individualmente o combinarse dependiendo de las necesidades del sistema.

### 1.3.1 Colas de mensajes y buffers

Una primera alternativa consiste en introducir una **cola o buffer** entre el Servicio de Ingesta y el proceso de análisis. En lugar de entregar cada publicación directamente al consumidor y esperar que pueda procesarla inmediatamente, el productor deposita el trabajo en un componente intermedio.

Ante un pico temporal, la cola absorbe la diferencia entre producción y consumo. El Servicio de Ingesta puede continuar recibiendo publicaciones mientras el proceso de análisis trabaja sobre los eventos pendientes a su propio ritmo.

En GlobalNewsFeed, esta estrategia sería útil durante aumentos breves de tráfico donde posteriormente la carga regresa a valores normales y el consumidor tiene oportunidad de ponerse al día.

Su principal limitación aparece cuando el aumento de tráfico deja de ser temporal. Si constantemente entran más publicaciones de las que pueden procesarse, la cola seguirá creciendo. En ese escenario, el buffer deja de ser suficiente y únicamente está trasladando la saturación hacia otro punto.

### 1.3.2 Escalado de consumidores

Otra alternativa consiste en **aumentar la cantidad de consumidores** encargados del análisis. Si un único proceso no puede seguir el ritmo de las publicaciones, el trabajo puede distribuirse entre varias instancias que procesen eventos en paralelo.

Aplicado a GlobalNewsFeed, durante un evento global podrían incorporarse temporalmente nuevos consumidores para aumentar el throughput del análisis. Cuando el tráfico regrese a niveles normales, la cantidad de instancias podría reducirse nuevamente.

Esta estrategia aprovecha el escalado horizontal y resulta especialmente útil cuando el trabajo puede dividirse entre diferentes consumidores. Sin embargo, no representa una capacidad infinita. El paralelismo puede estar condicionado por la forma en que se distribuyen los datos, los recursos disponibles y otros componentes del sistema que también pueden convertirse en cuellos de botella.

Por lo tanto, **escalar consumidores aumenta la capacidad**, pero no garantiza por sí solo que cualquier volumen de tráfico pueda ser procesado.

### 1.3.3 Limitación de la tasa de entrada

El **Rate Limiting** controla cuántas solicitudes o eventos puede aceptar un componente durante un intervalo determinado. A diferencia de una cola, que intenta absorber el exceso de trabajo, esta estrategia actúa directamente sobre la entrada.

En GlobalNewsFeed podría utilizarse cuando la tasa de publicaciones alcance valores que pongan en riesgo la capacidad del sistema. Limitar la entrada permite proteger los componentes internos y evitar que una carga excesiva termine generando fallos en cascada.

La principal ventaja es que establece un límite claro de protección. Su costo es que algunas solicitudes pueden retrasarse o rechazarse, por lo que debe analizarse cuidadosamente qué tráfico se limita y cuál es el impacto para el usuario.

Si se utiliza demasiado pronto, puede afectar innecesariamente la experiencia incluso cuando otros componentes todavía tienen capacidad. Si se utiliza demasiado tarde, el sistema puede haber acumulado una cantidad importante de trabajo antes de que la protección entre en funcionamiento.

### 1.3.4 Control de flujo

El **control de flujo** permite que los componentes adapten la velocidad con la que intercambian información de acuerdo con la capacidad disponible aguas abajo.

En lugar de permitir que cada etapa envíe información sin considerar el estado de la siguiente, el flujo puede reducirse temporalmente cuando un consumidor comienza a saturarse. Esto ayuda a evitar que el cuello de botella simplemente se traslade de un componente a otro.

Para el análisis de hashtags, este mecanismo sería especialmente útil dentro del pipeline de procesamiento, donde diferentes etapas pueden trabajar a velocidades distintas. Si una etapa se vuelve más lenta, el sistema puede propagar esa presión hacia las etapas anteriores.

Sin embargo, controlar el flujo no crea capacidad adicional. Si el sistema recibe de forma sostenida más trabajo del que puede procesar, reducir la velocidad entre componentes ayuda a mantener estabilidad, pero sigue siendo necesario resolver qué hacer con el exceso de carga.

### 1.3.5 Degradación controlada del servicio

Otra estrategia consiste en aceptar que, durante situaciones extremas, puede no ser posible mantener exactamente el mismo nivel de servicio que durante condiciones normales.

La **degradación controlada** busca reducir temporalmente trabajo no esencial para proteger las funciones más importantes del sistema. Dependiendo del producto, esto podría implicar reducir precisión, procesar menos información, retrasar determinadas operaciones o descartar trabajo que haya perdido valor.

En GlobalNewsFeed esta alternativa plantea una pregunta principalmente de negocio: **si el sistema no puede procesar todas las publicaciones durante un evento extremo, ¿qué característica debe protegerse primero?**

A diferencia del escalado o las colas, esta estrategia reconoce explícitamente que existe un límite de capacidad y define cómo debe comportarse el sistema cuando ese límite es superado. Su principal costo es que alguna característica del servicio se sacrifica temporalmente, por lo que requiere criterios claros antes de implementarse.

### 1.3.6 Load Shedding

El **Load Shedding** es una forma de degradación controlada en la que el sistema descarta deliberadamente parte del trabajo cuando procesarlo completamente pondría en riesgo su estabilidad o haría que el resultado dejara de ser útil.

Por ejemplo, si durante un evento global se acumula una cantidad de publicaciones que requeriría demasiado tiempo para procesarse, podría llegar un momento en que analizar publicaciones antiguas tenga menos valor que continuar trabajando con información reciente.

Esta estrategia permite recuperar capacidad rápidamente, pero introduce un trade-off importante: se sacrifica **completitud** para proteger otra propiedad del sistema, como disponibilidad, latencia o frescura.

Por esta razón, no debería considerarse la primera respuesta ante cualquier aumento de carga. Es una alternativa para escenarios donde absorber, regular o escalar ya no resulta suficiente.

### 1.3.7 Comparación de estrategias

Las alternativas exploradas responden al mismo problema desde perspectivas diferentes. Compararlas permite identificar qué aporta cada una y, especialmente, qué problema no puede resolver por sí sola.

| Estrategia                   | ¿Cómo responde a la contrapresión?                             | Principal ventaja                                                 | Principal limitación                                             |
| ---------------------------- | -------------------------------------------------------------- | ----------------------------------------------------------------- | ---------------------------------------------------------------- |
| **Colas / buffers**          | Acumulan temporalmente el trabajo pendiente                    | Desacoplan productores y consumidores y absorben picos temporales | Si el desbalance es sostenido, la acumulación continúa creciendo |
| **Escalado de consumidores** | Aumenta la capacidad de procesamiento                          | Permite procesar más eventos en paralelo                          | Está limitado por el paralelismo y los recursos disponibles      |
| **Rate Limiting**            | Reduce o controla la tasa de entrada                           | Protege los componentes internos frente a sobrecarga              | Puede retrasar o rechazar tráfico                                |
| **Control de flujo**         | Adapta la velocidad entre etapas según la capacidad disponible | Evita que un componente sobrecargue directamente al siguiente     | No aumenta por sí mismo la capacidad total                       |
| **Degradación controlada**   | Reduce temporalmente determinadas características o trabajo    | Mantiene disponibles las funciones prioritarias                   | Requiere decidir qué nivel de servicio puede sacrificarse        |
| **Load Shedding**            | Descarta deliberadamente parte del trabajo                     | Permite recuperar capacidad durante saturación extrema            | Produce pérdida intencional de información                       |

La comparación muestra que **ninguna estrategia resuelve por sí sola todos los escenarios de contrapresión**. Una cola puede absorber un pico, pero no una sobrecarga indefinida; escalar consumidores aumenta la capacidad, pero tiene límites; el Rate Limiting protege la entrada, pero puede afectar al usuario; y el Load Shedding permite recuperarse de situaciones extremas a cambio de perder parte del trabajo.

Esto lleva a considerar que el manejo de contrapresión puede abordarse mediante **diferentes niveles de respuesta**, comenzando por mecanismos que intentan absorber o adaptarse a la carga y dejando las medidas de degradación para situaciones donde la capacidad disponible ya no resulte suficiente.

---

La exploración realizada permite entender que el problema de GlobalNewsFeed surge principalmente del **desbalance entre la velocidad con la que se generan publicaciones y la capacidad disponible para analizarlas**. Al tratarse de un proceso continuo, este desbalance puede acumularse y terminar afectando tanto la latencia como la estabilidad del sistema.

Los conceptos estudiados muestran que la contrapresión no debe entenderse como un único mecanismo, sino como un problema que puede abordarse desde diferentes puntos del flujo. Las colas permiten absorber variaciones temporales, el escalado aumenta la capacidad de los consumidores, el Rate Limiting protege la entrada, el control de flujo regula la comunicación entre etapas y la degradación controlada permite establecer un comportamiento seguro cuando las medidas anteriores dejan de ser suficientes.

A partir de esta exploración, el siguiente paso consiste en **sintetizar las alternativas y tomar decisiones concretas para GlobalNewsFeed**. En el **Hito 2 — Síntesis y Creación de Entregables**, estas estrategias serán llevadas al diseño arquitectónico, definiendo qué mecanismos se utilizarán, dónde se aplicará la contrapresión, qué métricas permitirán detectar la saturación y qué trade-offs se aceptarán para mantener el sistema estable durante eventos de alta demanda.
