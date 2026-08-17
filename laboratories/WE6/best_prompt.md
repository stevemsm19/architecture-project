**Fecha/hora:** 11 de agosto de 2026  
**Herramienta y versión:** ChatGPT GPT-5.5  
**Prompt para el hito 1:** 


```
Actúa como un **Arquitecto de Software Senior especializado en arquitectura de microservicios, Domain-Driven Design (DDD), diseño de sistemas distribuidos y plataformas de comercio electrónico**.

Quiero que actúes como **mentor de arquitectura, compañero de razonamiento y crítico técnico**.

Tu objetivo no es simplemente darme una respuesta terminada. Quiero que me ayudes a **entender cómo se llega a una buena decisión arquitectónica**, cuestionar mis decisiones cuando sea necesario y explicarme los conceptos que estoy aplicando.

La prioridad es que pueda comprender y defender posteriormente cada decisión tomada.

---

# Contexto

Se está diseñando una arquitectura de microservicios para una plataforma de comercio electrónico llamada **QuickCart**.

El dominio contempla las siguientes capacidades:

- Registro y autenticación de usuarios.
    
- Navegación y búsqueda en un catálogo de productos.
    
- Gestión del carrito de compras.
    
- Realización y seguimiento de pedidos.
    
- Actualizaciones de stock del inventario.
    
- Envío de correos electrónicos de confirmación de pedidos.
    

El objetivo actual es realizar la **descomposición inicial del dominio y establecer límites adecuados entre los servicios**.

No se debe implementar código.

---

# Enfoque que debes utilizar

Quiero que bases el razonamiento principalmente en los principios de **diseño de microservicios y DDD**.

Utiliza como criterios principales:

1. **Capacidades de negocio.**
    
2. **Separación de responsabilidades (SoC).**
    
3. **Bounded Contexts.**
    
4. **Alta cohesión dentro del servicio.**
    
5. **Bajo acoplamiento entre servicios.**
    
6. **Independencia de servicios.**
    
7. **Propiedad de los datos.**
    
8. **Diferencias en ritmo de cambio.**
    
9. **Diferencias en necesidades de escalabilidad.**
    
10. **Diferencias en seguridad o ciclo de vida.**
    
11. **Alineación con el dominio de negocio.**
    
12. **Ley de Conway**, cuando sea relevante.
    

No quiero que el criterio principal sea:

> "Cada entidad o tabla debe convertirse en un microservicio."

Explícame por qué este enfoque puede producir una mala arquitectura.

Ten presente también la siguiente idea:

> Un servicio debe ser tan pequeño como sea necesario, pero no más pequeño.

Por lo tanto, **no asumas que tener más microservicios significa tener una mejor arquitectura**.

---

# Fase 1 — Enséñame los conceptos

Antes de diseñar QuickCart, explícame los conceptos necesarios para comprender el problema.

Explícalos primero de forma sencilla y después relaciónalos con ejemplos de QuickCart.

Como mínimo, quiero entender:

### 1. Microservicio

¿Qué caracteriza realmente a un microservicio?

No te limites a decir que es "un servicio pequeño". Explícame conceptos como:

- responsabilidad de negocio,
    
- autonomía,
    
- despliegue independiente,
    
- datos propios,
    
- bajo acoplamiento.
    

### 2. Separación de Responsabilidades (SoC)

Explícame:

- qué significa,
    
- por qué es importante,
    
- cómo se aplica a microservicios,
    
- y cómo podría aplicarse en QuickCart.
    

### 3. Capacidad de negocio

Explícame qué es una capacidad de negocio y por qué es un criterio más estable para definir servicios que simplemente dividir entidades o tablas.

Utiliza ejemplos como:

- Gestión de pedidos.
    
- Gestión de inventario.
    
- Gestión de usuarios.
    

### 4. Bounded Context

Explícame:

- qué es,
    
- qué problema resuelve,
    
- qué significa que un modelo sea consistente dentro de un contexto,
    
- y por qué un Bounded Context puede ser candidato para convertirse en un servicio.
    

### 5. Límite de servicio

Explícame qué significa realmente decir:

> "Este servicio es responsable de X, pero NO de Y."

Quiero entender cómo se decide dónde colocar ese límite.

### 6. Cohesión

Explícame qué significa que un servicio tenga **alta cohesión**.

Utiliza un ejemplo bueno y uno malo de QuickCart.

### 7. Acoplamiento

Explícame:

- qué es el acoplamiento,
    
- qué significa bajo acoplamiento,
    
- cómo puede aparecer un acoplamiento fuerte entre microservicios,
    
- y por qué esto puede terminar creando un Distributed Monolith.
    

### 8. Independencia de servicios

Explícame qué significa realmente que un servicio sea independiente.

No quiero que se interprete como "no depende absolutamente de ningún otro servicio".

Explícame qué tipo de independencia se busca realmente.

### 9. Propiedad de datos

Explícame por qué un límite de servicio también termina siendo un límite de propiedad de datos.

No profundices todavía en la implementación de bases de datos; quiero entender el principio arquitectónico.

### 10. Ley de Conway

Explícame brevemente cómo la estructura de los equipos puede influir en la estructura de los servicios y por qué esto puede ser relevante al definir límites.

---

# Fase 2 — Aprende a encontrar límites

Ahora quiero que me enseñes **cómo encontrar límites de servicio**, antes de decirme cuáles son los de QuickCart.

Utiliza las siguientes preguntas como heurísticas:

### Capacidad de negocio

> ¿Qué función de negocio realiza este conjunto de responsabilidades?

### Cambio

> ¿Estas responsabilidades cambian por las mismas razones?

Explícame el principio:

> Si dos partes cambian constantemente juntas, probablemente deberían permanecer juntas.

Y también el inverso:

> Si dos partes cambian por razones diferentes, puede existir un buen motivo para separarlas.

### Datos

> ¿Qué datos necesita controlar esta responsabilidad?

### Consistencia

> ¿Qué reglas necesitan mantenerse consistentes dentro del mismo límite?

### Escalabilidad

> ¿Estas responsabilidades necesitan escalar de la misma manera?

### Seguridad

> ¿Tienen los mismos requisitos de seguridad?

### Ciclo de vida

> ¿Tienen el mismo ciclo de vida?

### Autonomía

> ¿Podría este grupo de responsabilidades evolucionar, desplegarse y escalar de manera independiente?

Explícame cómo estas preguntas ayudan a encontrar límites.

---

# Fase 3 — Analiza QuickCart antes de crear servicios

Ahora analiza el dominio de QuickCart.

Identifica las principales capacidades de negocio.

Como punto de partida puedes considerar:

- Usuarios / autenticación.
    
- Catálogo.
    
- Carrito.
    
- Pedidos.
    
- Inventario.
    
- Notificaciones.
    

Pero **no conviertas automáticamente cada elemento en un microservicio**.

Para cada capacidad analiza:

- Qué problema de negocio resuelve.
    
- Qué responsabilidades contiene.
    
- Qué reglas de negocio podría tener.
    
- Qué datos necesita.
    
- Qué datos debería poseer.
    
- Qué otras capacidades podrían confundirse con ella.
    
- Qué razones existen para separarla.
    
- Qué razones existen para mantenerla junto a otra.
    
- Qué tan cohesionada sería.
    
- Qué tan acoplada quedaría con otros servicios.
    

Muéstrame primero este razonamiento.

---

# Fase 4 — Preguntas antes de decidir

Si encuentras una ambigüedad que **pueda cambiar realmente la definición de los servicios**, hazme una pregunta antes de continuar.

No hagas preguntas innecesarias.

Por ejemplo, pregunta si necesitas saber algo que pueda modificar:

- los límites,
    
- la cantidad de servicios,
    
- la propiedad de los datos,
    
- la responsabilidad de un servicio,
    
- o una decisión arquitectónica importante.
    

Si la ambigüedad no cambia significativamente la arquitectura, utiliza una suposición razonable y declárala.

Cuando hagas una pregunta, explícame:

> "Esta pregunta es importante porque la respuesta podría cambiar X límite o responsabilidad."

---

# Fase 5 — Propuesta de 5 a 7 servicios

Después del análisis, propón entre **5 y 7 microservicios candidatos**.

Para cada uno utiliza:

|Servicio|Responsabilidad principal|Qué NO hace|Justificación|
|---|---|---|---|

La responsabilidad principal debe estar expresada en **una sola oración clara**.

La sección "Qué NO hace" es especialmente importante.

No quiero límites vagos como:

> "Se encarga de los productos."

Quiero algo más explícito, por ejemplo:

> "Gestiona la información y disponibilidad del catálogo, pero no administra las cantidades físicas disponibles para venta."

Después de la tabla, explica el razonamiento detrás de los límites.

---

# Fase 6 — Analiza las decisiones difíciles

Quiero que analices especialmente estas decisiones.

## Carrito vs Pedidos

Analiza:

- Qué tienen en común.
    
- Por qué podrían confundirse.
    
- Qué responsabilidad tiene cada uno.
    
- Qué reglas de negocio pertenecen a cada uno.
    
- Qué datos controla cada uno.
    
- Si tienen diferentes ciclos de vida.
    
- Si cambian por las mismas razones.
    
- Si necesitan escalar de la misma manera.
    

Después determina si deben ser:

- un solo servicio,
    
- o dos servicios independientes.
    

No aceptes una respuesta simplemente porque "son conceptos diferentes".

Quiero que utilices los criterios de **cohesión, acoplamiento, cambio, autonomía y capacidad de negocio**.

---

# Fase 7 — Analiza Inventario vs Catálogo

Haz el mismo ejercicio para:

**Catálogo vs Inventario.**

Analiza:

- Qué responsabilidad tiene Catálogo.
    
- Qué responsabilidad tiene Inventario.
    
- Qué datos controla cada uno.
    
- Qué reglas pertenecen a cada contexto.
    
- Si cambian por las mismas razones.
    
- Si tienen diferentes necesidades de escalabilidad.
    
- Qué ocurriría si ambos estuvieran dentro del mismo servicio.
    
- Qué ocurriría si se separaran incorrectamente.
    

Finalmente recomienda una opción.

---

# Fase 8 — ¿Envío de Correos debe ser un servicio?

Analiza específicamente si **Envío de Correos** debe ser un servicio independiente.

No respondas únicamente:

> "Sí, porque tiene una responsabilidad diferente."

Quiero que analices:

- cohesión,
    
- responsabilidad,
    
- independencia,
    
- escalabilidad,
    
- ciclo de vida,
    
- dependencia de proveedores externos,
    
- fallos,
    
- reutilización,
    
- acoplamiento.
    

Compara al menos estas alternativas:

### Alternativa A

El envío de correos pertenece al servicio de Pedidos.

### Alternativa B

Existe un servicio independiente de Notificaciones / Email.

Explica ventajas y desventajas de ambas.

Finalmente recomienda una opción.

---

# Fase 9 — Anti-patrones

Analiza qué ocurriría si los límites se definieran incorrectamente.

Considera especialmente:

### God Service

¿Cómo podría aparecer en QuickCart?

Por ejemplo:

> Un único servicio que administra usuarios, productos, carrito, pedidos e inventario.

Explica por qué sería problemático.

### Distributed Monolith

Explica cómo podría aparecer si los servicios están separados físicamente pero siguen estando fuertemente acoplados.

### Chatty Services

Explica cómo una división excesivamente granular podría provocar demasiadas llamadas entre servicios.

### Shared Database

Explica por qué permitir que múltiples servicios modifiquen directamente la misma base de datos debilita la independencia de los servicios.

No necesitas desarrollar todos con la misma profundidad.

Identifica cuál consideras **el mayor riesgo para la propuesta de QuickCart** y justifícalo.

---

# Fase 10 — Mostrar un límite de servicio

Selecciona uno de los servicios propuestos y representa claramente su límite.

Utiliza **Mermaid**.

El diagrama debe mostrar:

- El límite del servicio.
    
- Responsabilidades que pertenecen al servicio.
    
- Datos o conceptos que controla.
    
- Elementos que pertenecen a otros contextos.
    
- Una interacción externa, si ayuda a comprender el límite.
    

El objetivo del diagrama **no es representar toda la arquitectura**.

Su objetivo es hacer evidente:

> "Esto pertenece al servicio y esto queda fuera."

Después del diagrama explica el límite.

---

# Fase 11 — Revisión arquitectónica

Ahora actúa como un **Arquitecto Senior realizando una revisión crítica de la propuesta**.

No aceptes automáticamente la primera solución.

Busca:

- Servicios demasiado grandes.
    
- Servicios demasiado pequeños.
    
- Responsabilidades mezcladas.
    
- Límites basados únicamente en tablas.
    
- Baja cohesión.
    
- Alto acoplamiento.
    
- Dependencias innecesarias.
    
- Servicios que deberían estar juntos.
    
- Servicios que deberían estar separados.
    
- Riesgo de Distributed Monolith.
    
- Riesgo de Chatty Services.
    
- Riesgo de Shared Database.
    
- Sobrefragmentación.
    
- Falta de autonomía.
    

Para cada problema encontrado utiliza:

**Problema → Por qué ocurre → Consecuencia → Mejora propuesta.**

---

# Fase 12 — Refinamiento

Después de la revisión, modifica la propuesta si consideras que es necesario.

Explícame:

- qué cambiaste,
    
- por qué lo cambiaste,
    
- qué principio arquitectónico motivó el cambio.
    

No cambies algo simplemente para hacer la arquitectura "más de microservicios".

El objetivo es encontrar **límites de negocio adecuados**, no maximizar el número de servicios.

---

# Resultado final

Solo después de completar el razonamiento y la revisión, construye la propuesta final.

La estructura final debe ser:

## 1. Descomposición del dominio

### 1.1 Capacidades de negocio

### 1.2 Criterios utilizados para definir los límites

### 1.3 Microservicios propuestos

Tabla:

|Servicio|Responsabilidad principal|Qué NO hace|Justificación|
|---|---|---|---|

### 1.4 Justificación de los principales límites

Explicación de las decisiones.

### 1.5 Decisiones arquitectónicas discutibles

- Carrito vs Pedidos.
    
- Catálogo vs Inventario.
    
- Envío de Correos.
    

### 1.6 Anti-patrón potencial

Explicación del principal riesgo identificado.

### 1.7 Límite de servicio

Diagrama Mermaid + explicación.

### 1.8 Conclusión

Explica brevemente por qué la propuesta consigue:

- separación clara de responsabilidades,
    
- alta cohesión,
    
- bajo acoplamiento,
    
- autonomía,
    
- límites alineados con el dominio,
    
- y capacidad de evolución independiente.
    

---

# Reglas importantes

1. **No implementes código.**
    
2. No conviertas automáticamente cada entidad en un microservicio.
    
3. No utilices las tablas de base de datos como criterio principal para separar servicios.
    
4. No asumas que más servicios significa mejor arquitectura.
    
5. Prioriza las capacidades de negocio.
    
6. Utiliza DDD y Bounded Contexts como herramientas para razonar sobre los límites.
    
7. Considera cohesión y acoplamiento en cada decisión.
    
8. Considera el ritmo de cambio como criterio de separación.
    
9. Considera la propiedad de los datos como consecuencia del límite.
    
10. Considera la escalabilidad y el ciclo de vida cuando ayuden a justificar una separación.
    
11. Si existen dos soluciones razonables, presenta el trade-off antes de elegir.
    
12. Declara las suposiciones.
    
13. Si detectas que mi razonamiento es incorrecto, corrígelo.
    
14. No presentes una decisión como "la única correcta" cuando existan varias alternativas válidas.
    
15. No avances hacia diseño detallado de APIs, bases de datos, Saga, CQRS u otros patrones que pertenezcan a etapas posteriores, salvo que sea estrictamente necesario para justificar un límite.
    
16. Mantén el análisis centrado en **descomposición de dominio, separación de responsabilidades y límites de servicio**.
    

---

# Objetivo de aprendizaje

Al finalizar, quiero poder explicar con mis propias palabras:

- ¿Qué es una capacidad de negocio?
    
- ¿Cómo se identifica un posible límite de servicio?
    
- ¿Qué es un Bounded Context?
    
- ¿Por qué un Bounded Context puede convertirse en un servicio?
    
- ¿Qué significa alta cohesión?
    
- ¿Qué significa bajo acoplamiento?
    
- ¿Cómo se determina qué pertenece y qué NO pertenece a un servicio?
    
- ¿Por qué Carrito y Pedidos están separados?
    
- ¿Por qué Catálogo e Inventario están separados?
    
- ¿Por qué Envío de Correos es o no un servicio independiente?
    
- ¿Cómo influye el ritmo de cambio en la definición de límites?
    
- ¿Cómo puede una mala descomposición crear un Distributed Monolith?
    
- ¿Cómo puede una descomposición demasiado granular crear Chatty Services?
    
- ¿Por qué los límites de datos deben seguir los límites de los servicios?
    
- ¿Por qué no se debe diseñar la arquitectura simplemente dividiendo una base de datos?
    

No empieces entregándome la solución final. Comienza enseñándome los conceptos de esta semana y después guíame progresivamente en el análisis de QuickCart. Si existe una ambigüedad que pueda cambiar una decisión arquitectónica importante, pregúntame antes de continuar.
```

**Fecha/hora:** 13 de agosto de 2026  
**Herramienta y versión:** ChatGPT GPT-5.5  
**Prompt para el hito 3:** 

```
En el trabajo anterior definimos microservicios candidatos y sus límites, y posteriormente analizamos cómo pueden comunicarse entre ellos mediante comunicación síncrona y asíncrona.

Entre los servicios considerados están:

- Usuarios / Identidad
- Catálogo
- Carrito
- Pedidos
- Inventario
- Notificaciones / Email

También hemos discutido conceptos como:
- Bounded Context
- separación de responsabilidades
- ownership de datos
- comunicación síncrona y asíncrona
- REST
- mensajería
- eventos
- consistencia eventual
- backpressure
- acoplamiento
- escalabilidad horizontal y vertical
- RabbitMQ
- Kafka
- Amazon SQS

No asumas que todas estas tecnologías necesariamente serán utilizadas. Evalúa cada decisión según las necesidades del caso.

# HITO 3 — Gestión de datos y escalabilidad

Quiero desarrollar el siguiente objetivo:

Comprender cómo los datos definen la arquitectura y condicionan la escalabilidad de los microservicios.

Para AL MENOS 3 microservicios de QuickCart debemos definir:

1. Quién es dueño de los datos.
2. Qué datos administra ese servicio.
3. Qué tipo de persistencia sería adecuada:
   - SQL
   - NoSQL
   - Event Store
   - u otra alternativa justificada.
4. Justificar por qué ese tipo de persistencia es adecuado para ese servicio.
5. Cómo escala ese servicio:
   - horizontalmente
   - verticalmente
   - o mediante ambas estrategias.
6. Justificar la estrategia de escalabilidad.
7. Investigar un vendor o tecnología real de base de datos o infraestructura, por ejemplo:
   - PostgreSQL
   - MongoDB
   - DynamoDB
   - Redis
   - u otra tecnología pertinente.
8. Justificar la elección utilizando criterios como:
   - precio
   - capacidad
   - escalabilidad
   - soporte
   - madurez
   - complejidad operativa
   - conocimiento del equipo
   - integración con la arquitectura
   - ventajas y desventajas
9. Identificar qué podría ocurrir si ese vendor o tecnología no escala adecuadamente.
10. Identificar un posible efecto dominó provocado por ese problema.
11. Identificar al menos un anti-patrón relacionado con la gestión de datos o escalabilidad y explicar qué problema provocaría.

## Antes de empezar

Primero explícame qué significa cada uno de estos conceptos EN EL CONTEXTO DE QUICKCART:

- Data ownership / dueño de los datos.
- Database per Service.
- SQL vs NoSQL vs Event Store.
- Escalabilidad horizontal.
- Escalabilidad vertical.
- Escalabilidad de una aplicación vs escalabilidad de su base de datos.
- Cuello de botella.
- Efecto dominó / cascading failure.
- Anti-patrones relacionados con datos en microservicios.
- Shared Database.
- Distributed Monolith, si resulta relevante.

Después de explicar cada concepto, dame un ejemplo sencillo relacionado con QuickCart.

NO avances todavía al diseño final hasta comprobar que entendí los conceptos.

## Proceso que quiero seguir

Después de explicarme los conceptos, quiero que me guíes paso a paso.

### Fase 1 — Identificación de datos

Ayúdame a analizar qué datos maneja cada microservicio.

Por ejemplo, quiero razonar sobre preguntas como:

- ¿Quién es dueño del precio de un producto?
- ¿Quién es dueño del stock?
- ¿Quién es dueño del estado de un pedido?
- ¿Quién es dueño de la información del usuario?
- ¿El carrito debe almacenar una copia del precio?
- ¿Pedidos puede modificar directamente los datos de Inventario?
- ¿Los servicios deben compartir una misma base de datos?

No respondas automáticamente estas preguntas. Primero ayúdame a razonarlas y pregúntame cuando sea necesario.

### Fase 2 — Ownership y límites de datos

Para cada servicio candidato, ayúdame a determinar:

- qué datos posee;
- qué datos puede modificar;
- qué datos solamente puede consultar mediante una API o eventos;
- qué datos NO debería almacenar;
- qué información podría duplicar legítimamente como una proyección o snapshot.

Explícame especialmente la diferencia entre:

"compartir datos"

y

"compartir la propiedad de los datos".

Quiero entender por qué cada microservicio debería tener control sobre sus propios datos.

### Fase 3 — Elección de persistencia

Para al menos 3 servicios, ayúdame a decidir entre SQL, NoSQL, Event Store u otra alternativa.

NO quiero que digas simplemente:

"Pedidos usa PostgreSQL porque SQL es bueno".

Quiero que relaciones la decisión con características concretas del dominio, por ejemplo:

- relaciones;
- transacciones;
- consistencia;
- patrón de lectura;
- patrón de escritura;
- volumen;
- estructura de los datos;
- necesidad de consultas;
- necesidad de escalabilidad;
- complejidad operativa.

Si existen varias alternativas razonables, compáralas y explícame el trade-off.

### Fase 4 — Escalabilidad

Para cada uno de los servicios seleccionados, analiza:

- ¿Qué tipo de carga recibe?
- ¿Tiene muchas lecturas?
- ¿Tiene muchas escrituras?
- ¿Tiene picos de tráfico?
- ¿Necesita responder rápidamente?
- ¿Puede procesar solicitudes independientemente?
- ¿Puede escalar horizontalmente?
- ¿Tiene sentido escalar verticalmente?
- ¿Qué componente podría convertirse en cuello de botella?

Quiero que distingas entre:

Servicio escalable

y

Base de datos escalable.

Explícame qué ocurre si aumento de:

1 instancia → 5 instancias → 20 instancias

pero todas siguen dependiendo de una única base de datos saturada.

Relaciona esto con backpressure y cascading failures cuando corresponda.

### Fase 5 — Selección del vendor

Después de entender las necesidades, ayúdame a elegir UN vendor o tecnología real para la persistencia o infraestructura.

Podemos considerar, entre otros:

- PostgreSQL
- MongoDB
- DynamoDB
- Redis
- otro que tenga sentido.

NO elijas uno simplemente porque sea popular.

Primero define los requisitos que debe cumplir la tecnología y luego compara alternativas.

Utiliza criterios como:

- costo;
- capacidad;
- escalabilidad;
- disponibilidad;
- soporte;
- madurez;
- complejidad operativa;
- facilidad de integración;
- conocimiento del equipo;
- vendor lock-in.

Si utilizas información actual sobre precios, límites, características o servicios comerciales, indícame que se trata de información investigada externamente y proporciona fuentes confiables.

### Fase 6 — Fallo y efecto dominó

Una vez elegido el vendor, quiero analizar:

"¿Qué ocurre si esta tecnología no puede escalar adecuadamente?"

Construye conmigo un escenario.

Por ejemplo:

Muchos usuarios
→ más solicitudes
→ más instancias del microservicio
→ más conexiones a la base de datos
→ base de datos saturada
→ mayor latencia
→ timeouts
→ reintentos
→ más carga
→ cascading failure.

Pero NO asumas que este será necesariamente el escenario correcto. Determina conmigo cuál sería el riesgo más realista para la tecnología seleccionada.

### Fase 7 — Anti-patrón

Ayúdame a identificar un anti-patrón relacionado con los datos.

Considera ejemplos como:

- Shared Database.
- Distributed Monolith.
- Database coupling.
- God Service.
- u otro que realmente sea relevante.

Explícame:

1. Cómo se produciría.
2. Por qué parece atractivo inicialmente.
3. Qué problema genera.
4. Cómo afecta la escalabilidad.
5. Cómo lo evitaríamos en QuickCart.

# Entregable final

Cuando hayamos razonado y tomado las decisiones, ayúdame a construir el entregable solicitado.

## 1. Tabla

Debe ser simple y contener:

| Servicio | Datos | Escalado | Riesgo |
|---|---|---|---|

La información debe resumir nuestras decisiones anteriores.

## 2. Párrafo sobre anti-patrón

Escribir un párrafo claro explicando:

- qué anti-patrón evitamos;
- cómo podría aparecer en QuickCart;
- qué problema generaría;
- cómo nuestra arquitectura lo evita.

## 3. Explicaciones adicionales

Incluye únicamente las explicaciones que sean relevantes para defender las decisiones arquitectónicas.

No quiero una respuesta excesivamente teórica.

# Regla principal

Quiero que actúes como un arquitecto que me está enseñando a tomar decisiones, NO como un generador automático de respuestas.

Si digo:

"Creo que todos deberían usar PostgreSQL"

no aceptes la afirmación inmediatamente.

Pregúntame:

"¿Por qué?"

y ayúdame a analizar si realmente existe una razón para que todos los servicios utilicen la misma tecnología.

Si digo:

"Escalamos horizontalmente"

pregúntame:

"¿Y qué pasa con la base de datos?"

Si digo:

"Cada servicio tiene su propia base de datos"

pregúntame:

"¿Quién es dueño de esos datos y cómo obtiene información de otros servicios?"

Quiero que me lleves progresivamente desde los conceptos hasta las decisiones y finalmente hasta el entregable.
```