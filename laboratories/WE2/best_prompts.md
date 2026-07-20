**Fecha/hora:** 16 de julio de 2026  
**Herramienta y versión:** Gemini, 3.5 Flash  
**Prompt para los hitos:** 

```markdown
Contexto:

GlobalLogistics Inc. es una empresa en crecimiento que enfrenta dificultades con su ecosistema de software. Sus operaciones principales son manejadas por “LogiMonolith,” un sistema legado de 15 años escrito en Java, que gestiona datos de clientes, facturación e inventario. Utiliza una conexión directa a una única base de datos SQL Server local.

Para mantenerse competitivos, han desarrollado un nuevo microservicio nativo en la nube, “ShipTrack,” que proporciona estado de envío en tiempo real y análisis avanzado. “ShipTrack” está construido con Node.js, usa bases de datos PostgreSQL y MongoDB, y está desplegado en un clúster de Kubernetes.

Solicitud:

 El negocio ha mandatado que estos dos sistemas deben trabajar juntos de manera fluida. El “LogiMonolith” debe ser capaz de enviar solicitudes de envío a “ShipTrack,” y “ShipTrack” debe ser capaz de actualizar estados de órdenes dentro de “LogiMonolith.” Además, se requiere una migración única de datos históricos de envío del SQL Server legado a PostgreSQL y MongoDB para que los análisis sean efectivos.
Actúa como un Arquitecto de Software Principal (Staff/Principal Software Architect) con más de 15 años de experiencia en modernización de sistemas legacy, patrones de integración y migración de datos. 

Tu cliente es GlobalLogistics Inc. Te han contratado para resolver la interoperabilidad entre su sistema legacy y su nuevo ecosistema cloud native, además de planificar la migración de datos históricos.

Trabajaremos por hitos de manera secuencial. En esta primera iteración, nos enfocaremos única y exclusivamente en el **Hito 1: Comprensión del ecosistema y riesgos del legacy (Análisis inicial)**. No debes proponer arquitecturas de destino, tecnologías de integración (como colas de mensajería o ESBs), ni diseños de API todavía. El objetivo es el diagnóstico y la delimitación del problema.

### Directrices de Redacción y Formato:
* **Tono y Lenguaje:** Altamente técnico, formal y corporativo. Utiliza terminología precisa de la industria (ej. acoplamiento temporal, gravedad de los datos, deuda técnica, degradación de rendimiento, consistencia eventual, esquemas monolíticos, throughput, etc.).
* **Estilo de Redacción:** Evita las listas de viñetas simples o genéricas de una sola línea. Prefiero una redacción estructurada, con párrafos bien desarrollados, cohesivos y analíticos que expliquen el "por qué" y el "impacto" de cada punto.
* **Estructura del Entregable:** Divide tu respuesta en las siguientes tres secciones claramente definidas mediante encabezados:

---

# Hito 1:

## 1. Delimitación de Dominios y Responsabilidades (Mapeo de Capacidades)
Analiza y describe las responsabilidades operativas y funcionales de cada sistema. Detalla qué subdominios de negocio y qué datos específicos controla cada uno bajo el escenario actual:
* **LogiMonolith (Java, SQL Server local):** Define su rol como núcleo transaccional clásico y el riesgo de la "gravedad de los datos" que retiene.
* **ShipTrack (Node.js, PostgreSQL, MongoDB en Kubernetes):** Define su rol como sistema de alto throughput analítico y operativo de última generación.

## 2. Matriz de Datos y Flujos de Información Críticos
Presenta un esquema o tabla técnica que resuma de manera clara:
* La entidad de datos.
* El sistema que actúa como "Sistema de Registro" (System of Record / Single Source of Truth).
* El tipo de almacenamiento asociado.
* La dirección del flujo de datos requerida para la interoperabilidad (ej. Unidireccional, Bidireccional, Sincrónico vs Asincrónico latente).

## 3. Diagnóstico de Riesgos Críticos y Limitaciones del Legacy
Identifica y analiza a fondo entre 3 y 4 riesgos o limitaciones técnicas concretas del "LogiMonolith" que amenazan la viabilidad de la integración y la migración. Desarrolla cada riesgo en un párrafo robusto, abordando aspectos como:
* **Acoplamiento de Base de Datos:** Los peligros de la dependencia directa a nivel de esquema en SQL Server.
* **Obsolescencia Tecnológica y Rigidez:** La dificultad de exponer endpoints o interfaces modernas en una plataforma de hace 15 años.
* **Degradación del Rendimiento Transaccional:** El impacto de las consultas analíticas de ShipTrack y la migración masiva sobre las operaciones diarias de facturación e inventario en la base de datos local.
* **Bloqueo de Despliegue y Deuda Técnica:** El riesgo de modificar el monolito sin romper procesos críticos existentes.

Comienza directamente con el análisis del Hito 1, adoptando el rol senior desde la primera línea.
```

**Fecha/hora:** 19 de julio de 2026  
**Herramienta y versión:** Codex  
**Prompt para el resultado final:**

```markdown
Actúa como un Arquitecto de Software Senior y un redactor técnico experto. Tu tarea es ayudarme a completar, corregir y refinar un informe técnico sobre la integración de un sistema legado y un ecosistema moderno en la nube.

A continuación, te proporcionaré el CONTEXTO del proyecto, las INSTRUCCIONES de lo que se pedía en cada hito, mis RESPUESTAS a cada hito, y el BORRADOR ACTUAL del informe que he escrito hasta ahora.

### OBJETIVO

Quiero que leas mi borrador y mis respuestas, y generes un informe técnico final, coherente y unificado. Debes complementar la información faltante, corregir lo que sea necesario y mejorar la redacción. 

### REGLAS DE ESTILO Y FORMATO

1. Estructura estricta: El documento debe tener exactamente las siguientes secciones: Introducción, Hito 1, Hito 2, Hito 3, Hito 4, Hito 5, Conclusión.
2. Tono y Estilo: Mantén el estilo de escritura de mi borrador. Utiliza un lenguaje técnico pero accesible (no excesivamente denso).

---

### 1. CONTEXTO DEL PROYECTO

GlobalLogistics Inc. es una empresa en crecimiento que enfrenta dificultades con su ecosistema de software. Sus operaciones principales son manejadas por “LogiMonolith,” un sistema legado de 15 años escrito en Java, que gestiona datos de clientes, facturación e inventario. Utiliza una conexión directa a una única base de datos SQL Server local.

Para mantenerse competitivos, han desarrollado un nuevo microservicio nativo en la nube, “ShipTrack,” que proporciona estado de envío en tiempo real y análisis avanzado. “ShipTrack” está construido con Node.js, usa bases de datos PostgreSQL y MongoDB, y está desplegado en un clúster de Kubernetes.

El negocio ha mandatado que estos dos sistemas deben trabajar juntos de manera fluida. El “LogiMonolith” debe ser capaz de enviar solicitudes de envío a “ShipTrack,” y “ShipTrack” debe ser capaz de actualizar estados de órdenes dentro de “LogiMonolith.” Además, se requiere una migración única de datos históricos de envío del SQL Server legado a PostgreSQL y MongoDB para que los análisis sean efectivos.

Su equipo, como Arquitectos de Software, debe diseñar una solución para lograr esta interoperabilidad.

### 2. REQUISITOS DE LOS HITOS

- Hito 1: Comprensión del ecosistema y riesgos del legacy (Análisis inicial). Identificar responsabilidades de LogiMonolith y ShipTrack. Listar riesgos y limitaciones del legacy (DB acoplada, falta de APIs, etc.).

- Hito 2: Casos de interacción y elección de estilos de integración. Definir interacciones (LogiMonolith → ShipTrack; ShipTrack → LogiMonolith; interacción asincrónica). Elegir y justificar estilos (API, Webhook, Mensajería, etc.).

- Hito 3: Estrategia de interoperabilidad (Diseño defensivo). Proponer una capa Anti-Corrupción (ACL) o Adaptador. Justificar dónde vive y explicar qué traduce.

- Hito 4: Plan de migración de datos históricos. Definir proceso ETL a alto nivel y tipo de migración (Big Bang / Gradual / Cero downtime) con justificación según el escenario. 

- Hito 5: Arquitectura integrada + narrativa final. Explicación end-to-end de un caso de uso que involucre ambos sistemas. Incluir reflexiones personales sobre si el expertise adquirido ayudará en la industria y si sería más fácil dirigir un equipo para una integración de sistemas.

---

### 3. ADJUNTO MIS RESPUESTAS A LOS HITOS

### 4. ADJUNTO MI BORRADOR ACTUAL DEL INFORME TÉCNICO
```




