# Semana 1: Arquitectura Empresarial

## Resumen del contenido

El documento corresponde a la clase magistral de la Semana 1 del curso "Arquitectura
de Software 3" (SAR-300, 7° semestre, Jala University). Presenta primero un resumen
administrativo del curso (código, créditos, duración, prerrequisitos, desglose
semanal) y un repaso de los temas cubiertos en Arquitectura de Software 2. Luego
desarrolla el tema central de la semana: la **Arquitectura Empresarial (AE)**, sus
dominios (estrategia, negocio, información, aplicaciones, tecnología —aclarando que
el curso solo profundiza en información, aplicaciones y tecnología—), herramientas de
modelado, el **Análisis de Brechas (Gap Analysis)**, la **Interoperabilidad de
Sistemas**, el **Gobierno y Cumplimiento** en AE, y las **Soluciones Modulares**.
Cierra con la presentación del Proyecto Final del curso.

## Conceptos clave

### Arquitectura Empresarial (AE)

**Definición:** "La Arquitectura Empresarial (AE) es una disciplina que proporciona
una visión holística de la estructura, procesos, sistemas de información e
infraestructura tecnológica de una organización, alineándolos con la estrategia y
objetivos del negocio."

**Explicación:** Su objetivo principal es asegurar que la organización pueda
adaptarse a los cambios en el entorno empresarial, optimizar recursos y mejorar la
toma de decisiones.

**Características:**
- Tiene una amplia gama de casos de uso; se aplica en sectores como gobierno,
  servicios financieros, educación, sanidad y hoteles, entre otros ("Etc.").
- Se organiza en capas o dominios jerárquicos con alineación estratégica vertical
  (cada capa soporta y es soportada por las capas adyacentes).

**Relaciones:**
- Se compone de los Dominios de Arquitectura Empresarial (ver más abajo).
- Es la base sobre la que se aplica el Análisis de Brechas.
- Se vincula con Gobierno y Cumplimiento como mecanismo de control.

### Dominios de Arquitectura Empresarial

**Definición:** Los dominios de AE incluyen: Capa de Estrategia, Arquitectura de
Negocio, Arquitectura de Información, Arquitectura de Aplicaciones y Arquitectura
Tecnológica.

**Explicación:** El documento aclara explícitamente que el curso explorará en detalle
cada una de estas capas **excepto la primera (Capa de Estrategia) y la segunda
(Arquitectura de Negocio)**, que no forman parte del contenido del curso.

**Características (según el diagrama "Enterprise Architecture Domains" del material):**
- **Strategy Layer**: Business Strategy, IT Strategy, Digital Strategy, Innovation
  Roadmap, Enterprise Goals, Success Metrics, Governance, Compliance, Standards,
  Policies.
- **Business Architecture**: Business Processes & Workflows, Organizational
  Structure & Roles, Business Capabilities & Services, Value Streams & Outcomes,
  Business Rules & Policies, Stakeholders & External Partners.
- **Information Architecture**: Data Models & Schemas, Information Flow &
  Lifecycle, Data Governance & Quality, Master Data Management & Reference,
  Analytics & Business Intelligence, Information Security & Privacy.
- **Application Architecture**: Application Portfolio & Landscape, Integration
  Patterns & APIs, Application Services & Components, Software Architecture
  Patterns, User Experience & Interfaces, Application Lifecycle Management.
- **Technology Architecture**: Infrastructure Platforms & Hardware, Cloud Services &
  Deployment, Network & Communication Architecture, Security Architecture &
  Controls, DevOps & Automation Tools, Monitoring & Operations Management.

**Relaciones:**
- Principios clave señalados en el diagrama: cada capa soporta y es soportada por
  las capas adyacentes; la alineación vertical asegura que los objetivos estratégicos
  fluyan por todas las capas; las dependencias entre capas requieren gobierno y
  gestión del cambio cuidadosos.

### Arquitectura de Información (o Datos)

**Definición:** "Disciplina dentro de la Arquitectura Empresarial que se enfoca en
estructurar, organizar y gobernar los datos e información de una organización para
hacerlos accesibles, comprensibles y útiles."

**Explicación:** Objetivo principal: asegurar que la información correcta esté
disponible para las personas correctas, en el momento adecuado y en el formato
apropiado.

**Características (Componentes clave):**
- Modelos de Datos
- Gobierno de Datos
- Integración de Datos
- Almacenamiento de Datos
- Gestión de Metadatos

**Relaciones:**
- Es uno de los dominios de la AE que el curso sí desarrolla en detalle.
- Se conecta con Interoperabilidad de Sistemas (a través del intercambio de datos
  y la interoperabilidad semántica).

### Arquitectura de Aplicaciones

**Definición:** "Define la estructura, comportamiento e interacción de las
aplicaciones que soportan los procesos de negocio, incluyendo sus relaciones con
usuarios y con otras aplicaciones."

**Explicación:** Objetivo principal: asegurar que las aplicaciones estén alineadas
con las necesidades del negocio, sean escalables, mantenibles, interoperables y
seguras.

**Características (Componentes clave):**
- Portafolio de Aplicaciones
- Integración de Aplicaciones
- Seguridad de Aplicaciones
- Desarrollo de Aplicaciones
- Despliegue de Aplicaciones

**Relaciones:**
- Es uno de los dominios de la AE que el curso desarrolla en detalle.
- Se relaciona con Arquitectura Tecnológica (las aplicaciones se apoyan en la
  infraestructura tecnológica).

### Arquitectura Tecnológica

**Definición:** "Define la estructura y estándares de la infraestructura tecnológica
(hardware, redes, plataformas, sistemas operativos, servicios cloud, etc.) que
soporta las aplicaciones y el procesamiento de datos en la organización."

**Explicación:** Objetivo principal: asegurar que la infraestructura tecnológica sea
robusta, escalable, segura y esté alineada con las necesidades del negocio y las
capas superiores de arquitectura.

**Características (Componentes clave):**
- Infraestructura de Hardware
- Infraestructura de Software
- Infraestructura de Red
- Infraestructura de Seguridad
- Infraestructura Cloud

**Relaciones:**
- Es el dominio "base" que soporta a las capas de Aplicación, Datos y Negocio en la
  pirámide de dominios de AE.

### Análisis de Brechas (Gap Analysis)

**Definición:** La AE ayuda a identificar brechas entre el estado actual y el estado
futuro deseado de la organización, permitiendo una planificación estratégica
efectiva.

**Explicación:** El objetivo principal es proporcionar a los tomadores de decisiones
una hoja de ruta clara para una planificación y priorización más efectiva de las
iniciativas de transformación.

**Características (Importancia del Análisis de Brechas):**
- **Alineación Estratégica**: asegura que la estrategia de TI y de negocio estén
  sincronizadas al hacer explícito lo que necesita cambiar.
- **Toma de Decisiones Informada**: proporciona una base basada en hechos para
  priorizar proyectos e inversiones.
- **Mitigación de Riesgos**: identifica puntos débiles que podrían amenazar
  objetivos futuros o el cumplimiento.
- **Optimización de Recursos**: ayuda a optimizar recursos al enfocarse en las
  brechas más críticas para máximo impacto.
- **Gestión del Cambio**: apoya la comunicación y aceptación de iniciativas de
  transformación al clarificar la justificación y objetivos.

**Relaciones:**
- Se apoya en la documentación de la arquitectura actual (producida con
  herramientas de modelado de AE) y en la definición del estado objetivo derivado
  de la estrategia de negocio.

### Interoperabilidad de Sistemas

**Definición:** "La capacidad de diferentes sistemas de software para intercambiar y
usar información de manera fluida, sin la necesidad de modificaciones significativas
o integraciones personalizadas."

**Explicación:** Implica lograr comunicación entre sistemas diversos y compartir
datos de manera efectiva, permitiendo mayor eficiencia, colaboración e innovación.

**Características (Dimensiones de la Interoperabilidad de Sistemas):**
- **Intercambio de Datos**: capacidad de transferir datos entre sistemas de manera
  precisa y confiable.
- **Interoperabilidad Organizacional**: alinea procesos, políticas y
  responsabilidades entre organizaciones o departamentos para asegurar
  interacciones coherentes y efectivas.
- **Interoperabilidad Semántica**: asegura que los datos intercambiados sean
  consistentemente comprendidos por todos los sistemas y partes interesadas a
  través de estándares acordados y definiciones de datos.
- **Interoperabilidad Técnica**: asegura que los sistemas puedan conectarse y
  transmitir datos (ej. APIs, protocolos, formatos de datos).

**Características (Aspectos Clave de la Interoperabilidad de Sistemas):**
- **Estándares**: adoptar estándares de la industria para formatos de datos,
  protocolos de comunicación y seguridad puede simplificar los esfuerzos de
  integración.
- **APIs**: APIs bien diseñadas pueden facilitar la integración de diferentes
  sistemas.
- **Gobierno de Datos**: establecer políticas y procedimientos claros de gobierno
  de datos para asegurar calidad, consistencia y seguridad.
- **Gestión de Metadatos**: crucial para entender el significado y contexto de los
  datos intercambiados entre sistemas.
- **Seguridad**: los sistemas interoperables deben ser seguros para proteger datos
  sensibles de accesos no autorizados y amenazas cibernéticas.

**Relaciones:**
- Es un tema transversal que se apoya en la Arquitectura de Información (estándares
  de datos) y en la Arquitectura de Aplicaciones (APIs).

### Gobierno y Cumplimiento (Governance & Compliance)

**Definición (tabla comparativa del material):**

| Gobierno | Cumplimiento |
|---|---|
| Conjunto de estructuras, procesos, principios y roles que aseguran que la arquitectura empresarial esté definida, implementada y mantenida de manera consistente, alineada con la estrategia de negocio y cumpliendo estándares organizacionales. | Capacidad de la organización para cumplir con leyes, regulaciones, políticas internas, estándares de seguridad y estándares técnicos aplicables a su operación. |

**Explicación:** El diagrama "Balancing Strategic Alignment and Regulatory Adherence
in EA" presenta Gobierno y Cumplimiento como una balanza: el Gobierno se orienta a
la supervisión y dirección estratégica (decision-making authority, strategic
alignment focus), mientras que el Cumplimiento se orienta a la adherencia
regulatoria (policy implementation, regulatory adherence focus). Ambos convergen en
la "Controlled Architecture Management".

**Características (según tabla ampliada del material):**
- Gobierno: guiar y controlar las prácticas de AE; marco que incluye toma de
  decisiones, gestión de riesgos y responsabilidad; alineación estratégica, valor,
  riesgo y supervisión de procesos; políticas, roles, juntas de aprobación,
  monitoreo, mejora continua; busca AE efectiva y alineada que entregue valor al
  negocio; asegura que la AE se construya y mantenga de manera controlada,
  orientada al valor y alineada.
- Cumplimiento: asegurar adherencia a leyes y políticas; enfoque específico en
  estándares, reglas y regulaciones; adherencia a mandatos y políticas
  internas/externas; auditorías, revisiones, herramientas de monitoreo de
  cumplimiento automatizadas; busca evitar sanciones legales, brechas de seguridad
  y riesgos operacionales; garantiza que todas las actividades y productos de AE se
  conformen a las reglas y regulaciones requeridas por gobierno y autoridades
  externas.

**Relaciones:**
- Ambos conceptos son complementarios y se equilibran dentro de la gestión
  controlada de la arquitectura ("Controlled Architecture Management").

### Soluciones Modulares (Modular Architecture)

**Definición:** "Las soluciones modulares dentro de la arquitectura empresarial se
refieren al diseño e implementación de sistemas de TI como colecciones de
componentes o módulos independientes para proporcionar la agilidad, escalabilidad y
resistencia que las empresas necesitan en entornos de negocio cambiantes."

**Explicación:** El diagrama "Foundations of Modular Architecture" identifica tres
fundamentos: Independent Units (cada módulo opera autónomamente, mejorando
flexibilidad y escalabilidad), Self-Contained Functionality (los módulos encapsulan
funciones específicas, asegurando claridad y eficiencia), y Well-Defined Interfaces
(los módulos se comunican a través de interfaces claras, promoviendo integración sin
fricciones).

**Características (diagrama "Modular Design in Enterprise Architecture"):**
- La AE se organiza en cuatro capas: Business Layer (procesos y capacidades de
  negocio), Data Layer (arquitectura de datos, modelos de información),
  Application Layer (aplicaciones de software, integración de sistemas) y
  Technology Layer (infraestructura, plataformas).
- Los "Modular Design Principles" (módulos) que alimentan esas capas son: Service
  Module (independiente, reutilizable), Data Module (encapsulado, escalable), API
  Module (débilmente acoplado, basado en interfaces) y Security Module
  (transversal, estandarizado).
- Beneficios listados: Flexibility (fácil de modificar y reemplazar módulos),
  Reusability (compartido entre múltiples sistemas), Maintainability (cambios
  aislados reducen riesgo), Scalability (escalado independiente de partes), Risk
  Reduction (aislamiento y contención de fallas).
- Enfoques de implementación mencionados: Microservices Architecture,
  Domain-Driven Design, Service-Oriented Architecture, Component-Based
  Development, API-First Design, Event-Driven Architecture.

**Relaciones:**
- Conecta directamente con los dominios de Arquitectura de Aplicaciones, Datos y
  Tecnología descritos anteriormente.
- Los enfoques de implementación mencionados (microservicios, DDD, SOA, etc.) se
  anticipan como temas que se profundizarán en semanas posteriores del curso
  (Semanas 5-7: Arquitectura de Microservicios I, II y III).

## Enfoques, métodos o herramientas

### Herramientas de Modelado (Gratuitas / Código Abierto)

| Nombre | Características |
|---|---|
| **Archi** (ArchiMate Modelling) | Soporta el framework ArchiMate, importar/exportar formatos Open Exchange; adecuado para visualizar modelos y frameworks de AE (soporte TOGAF); ligero y fácil de usar, excelente para arquitectos individuales y equipos pequeños. |
| **Modelio** (The Open Source Modeling Environment) | Entorno de modelado de código abierto que soporta UML, BPMN, soporte ArchiMate y extensiones para modelado AE; bueno para personalizar meta-modelos e integrar con otras herramientas. |

### Herramientas de Modelado (Pagadas / Comerciales)

| Nombre | Características |
|---|---|
| **Bizzdesign Enterprise Studio** | Soporte ArchiMate/TOGAF, modelado multicapa, análisis de impacto, portal de colaboración web; basado en la nube con análisis y reportes en tiempo real; excelente para entornos de TI grandes y complejos; precios basados en suscripción, disponible en la nube y on-premise, precios premium. |
| **Sparx Systems Enterprise Architect** | Soporta UML, BPMN, ArchiMate, SysML y más; control de versiones avanzado, colaboración y reportes; adecuado para empresas pequeñas a grandes; precios desde $245 por usuario (licencia perpetua). |

El material incluye capturas de pantalla de las cuatro herramientas mostrando
ejemplos de vistas de arquitectura (procesos de negocio, servicios de aplicación,
componentes de aplicación, diagramas de motivación/principios, capas tecnológicas),
sin agregar información conceptual adicional a la ya descrita en las tablas.

## Procedimientos o procesos

### Proceso de Análisis de Brechas (Gap Analysis Process)

1. **Documentar el Estado Actual**: mapear la arquitectura existente, procesos de
   negocio, paisaje de aplicaciones, tecnologías, datos, etc. (Establecer una
   comprensión de línea base de la situación actual.)
2. **Definir el Estado Objetivo**: articular el estado deseado basado en la
   estrategia de negocio, requerimientos futuros y mejores prácticas. (Fijar
   objetivos claros para el estado futuro deseado.)
3. **Identificar las Brechas**: comparar ambos estados y resaltar desajustes,
   deficiencias o elementos faltantes.
4. **Analizar y Priorizar Brechas**: determinar qué brechas son más críticas,
   factibles de abordar y alineadas con prioridades organizacionales. (Evaluar y
   clasificar brechas según impacto y factibilidad.)
5. **Desarrollar una Hoja de Ruta**: crear planes accionables para abordar las
   brechas, a menudo con proyectos priorizados, cronogramas y asignaciones de
   recursos. (Crear un plan estratégico para abordar las brechas identificadas.)

## Ejemplos y casos

El material no desarrolla casos de estudio narrativos completos; se limita a listar
sectores de aplicación de la AE (gobierno, servicios financieros, educación, sanidad,
hoteles) y a mostrar capturas de pantalla de herramientas de modelado (Archi,
Modelio, Bizzdesign, Sparx Enterprise Architect) como ejemplos visuales de uso, sin
explicar el contenido específico de esos modelos más allá de lo ya indicado en las
descripciones de las capturas (ej. modelo "Archisurance" en Archi, ejemplo "Discount
Voyage" en Modelio).

## Comparaciones

| Concepto A | Concepto B | Diferencia |
|---|---|---|
| Gobierno (Governance) | Cumplimiento (Compliance) | El Gobierno es el marco de estructuras, procesos y roles que aseguran que la AE esté definida, implementada y mantenida de forma consistente y alineada con la estrategia de negocio (enfoque en dirección estratégica y toma de decisiones). El Cumplimiento es la capacidad de la organización de cumplir leyes, regulaciones, políticas internas y estándares técnicos/seguridad aplicables (enfoque en adherencia a reglas externas/internas mediante auditorías y monitoreo). |
| Herramientas de modelado gratuitas (Archi, Modelio) | Herramientas de modelado comerciales (Bizzdesign, Sparx EA) | Las gratuitas son ligeras, orientadas a arquitectos individuales o equipos pequeños; las comerciales ofrecen análisis de impacto, colaboración en la nube, reportes en tiempo real y soporte para entornos de TI grandes y complejos, con modelos de precio por suscripción o licencia perpetua. |

## Información visual relevante

### Pirámide de Dominios de Arquitectura Empresarial

Diagrama piramidal (fuente: linkurious.com) que muestra de arriba hacia abajo:
Business, Data, Application, Technology, representando una jerarquía de dominios
donde cada capa se apoya en la inferior. Corresponde a los "Dominios de Arquitectura
Empresarial" listados textualmente como Capa de Estrategia, Arquitectura de Negocio,
Arquitectura de Información, Arquitectura de Aplicaciones y Arquitectura Tecnológica.

### Enterprise Architecture Domains (diagrama detallado)

Diagrama de cinco bandas horizontales apiladas (Strategy Layer → Business
Architecture → Information Architecture → Application Architecture → Technology
Architecture) con flechas verticales entre capas indicando "Strategic Alignment".
Cada banda lista sus componentes específicos (detallados en la sección "Dominios de
Arquitectura Empresarial" arriba). Incluye principios clave: cada capa soporta y es
soportada por las capas adyacentes; la alineación vertical asegura que los objetivos
estratégicos fluyan por todas las capas; las dependencias entre capas requieren
gobierno y gestión del cambio cuidadosos.

### Diagrama de componentes de Arquitectura de Información

Diagrama hexagonal que conecta Integration, Data Assets y Accessibility & Security
con Storage y Management, ilustrando que los activos de datos son centrales a la
Arquitectura de Información, rodeados por integración, almacenamiento, gestión y
seguridad/accesibilidad.

### Diagrama de componentes de Arquitectura de Aplicaciones

Diagrama radial con un ícono central de aplicación del cual irradian cinco
componentes: Application Portfolio (catálogo de aplicaciones con propósitos y
características), Application Integration (conexión de aplicaciones para
intercambio de datos y procesos), Application Security (protección contra accesos
no autorizados y amenazas), Application Development (construcción y mantenimiento
con diversas herramientas y metodologías) y Application Deployment (despliegue a
entornos de producción usando cloud y virtualización).

### Diagrama de componentes de Arquitectura Tecnológica

Diagrama de círculos superpuestos (Technology Architecture Framework) con: Cloud
Infrastructure (servidores remotos que proveen recursos de cómputo bajo demanda),
Hardware Infrastructure (componentes físicos que soportan operaciones digitales),
Security Infrastructure (medidas para proteger datos y sistemas de amenazas),
Software Infrastructure (programas y sistemas que habilitan la funcionalidad del
hardware) y Network Infrastructure (sistemas que facilitan la comunicación entre
dispositivos).

### Diagrama Gap Analysis (Enterprise Architecture Gap)

Dos representaciones visuales complementarias: una de "tiro al blanco" que muestra
progresión desde Current State (paisaje de TI y procesos existentes) pasando por
Gaps (discrepancias que requieren planificación estratégica) hasta Desired Future
State (logro de objetivos estratégicos de negocio); y un diagrama de balanza/flujo
que muestra Current Architecture State (arquitectura ineficiente y desalineada) →
Gap Analysis → Desired Architecture State (arquitectura eficiente y alineada), con
dos acciones: encontrar diferencias entre estados e implementar cambios para cerrar
brechas.

### Diagrama de beneficios del Análisis de Brechas

Cinco tarjetas de color que resumen la importancia del análisis de brechas:
Strategic Alignment, Informed Decision-Making, Risk Mitigation, Resource
Optimization y Change Management (contenido igual al desarrollado textualmente en
la sección de conceptos).

### Diagrama Gap Analysis Process

Cinco íconos en línea horizontal que resumen visualmente el proceso de cinco pasos
ya descrito: Document Current State, Define Target State, Identify Gaps, Analyze and
Prioritize Gaps, Develop a Roadmap.

### Diagrama de Interoperabilidad para creación de productos de datos

Diagrama circular centrado en "Interoperability – for creating data products", con
seis actores conectados alrededor: Hospitals, Patients, Pharmaceutical companies,
Health plans, Providers, Labs. Ilustra un caso de uso sectorial (salud) de
interoperabilidad de sistemas, sin desarrollar detalles adicionales.

### Diagrama "Architecture Principle - Interoperability" (Healthcare, fuente Dragon1)

Diagrama que muestra dos sistemas (System A, System B) intercambiando datos a
través de una interfaz con estándares de datos ("Data Standards"), conectados a un
repositorio central ("Health Record / Patient File") con control de acceso, y
vinculados a actores como Healthcare provider/Hospital, Healthcare Professional,
Patient y Medical Data/Lab Tests. Declaración de principio citada del material: "By
having systems with open interfaces using standardized data formats to exchange
data, it is ensured data can flow freely, securely, and unrestricted between
systems, enabling organizations and professionals to have easy and quick access to
high-quality data providing better services to clients and users."

### Diagrama de Dimensiones de la Interoperabilidad de Sistemas

Diagrama de prisma con cuatro flechas de salida etiquetadas: Data Exchange,
Semantic Interoperability, Technical Interoperability, Organizational
Interoperability — correspondientes a las cuatro dimensiones descritas en el texto.

### Diagrama de Aspectos Clave de la Interoperabilidad de Sistemas

Diagrama tipo candado/rueda con cinco sectores: Security, Standards, APIs, Data
Governance, Metadata Management — correspondientes a los cinco aspectos descritos en
el texto.

### Diagramas de Gobierno y Cumplimiento

Dos diagramas: uno de forma de "ojo"/óvalo con Governance (supervisión y dirección
estratégica) y Compliance (adherencia a reglas y estándares) convergiendo en
"Controlled Architecture Management"; otro de balanza que contrapone Strategic
alignment focus / Decision-making authority (lado Governance) con Regulatory
adherence focus / Policy implementation (lado Compliance).

### Diagrama "Foundations of Modular Architecture"

Diagrama en forma de arco con tres secciones: Independent Units, Self-Contained
Functionality, Well-Defined Interfaces — correspondientes a los tres fundamentos
descritos en el texto de Soluciones Modulares.

### Diagrama "Modular Design in Enterprise Architecture"

Diagrama de tres niveles: (1) capas de AE (Business, Data, Application, Technology
Layer); (2) módulos de diseño modular (Service, Data, API, Security Module) que
alimentan esas capas mediante flechas ascendentes; (3) cinco beneficios numerados
(Flexibility, Reusability, Maintainability, Scalability, Risk Reduction) y una lista
de enfoques de implementación (Microservices Architecture, Domain-Driven Design,
Service-Oriented Architecture, Component-Based Development, API-First Design,
Event-Driven Architecture).

### Diagrama de dominios de Arquitectura de Información (Enterprise Architecture Applications)

Diagrama de círculos superpuestos centrado en "Enterprise Architecture" que muestra
casos de uso por sector: Hospitality (optimiza experiencias de huéspedes y
eficiencia operativa), Government Sector (alinea estrategias gubernamentales y
optimiza servicios públicos), Financial Services (mejora eficiencia operativa y
cumplimiento regulatorio), Education (soporta planificación estratégica y gestión de
recursos en instituciones educativas), Healthcare (mejora atención al paciente y
efectividad operativa).

### Tabla "Desglose Semanal" del curso

Tabla que ubica el contenido de este documento como Semana 1 (Arquitectura
Empresarial) dentro de una secuencia de 8 semanas: Semana 2 (Integración de
Sistemas), Semana 3 (Rendimiento de Sistemas I), Semana 4 (Rendimiento de Sistemas
II), Semana 5 (Arquitectura de Microservicios I / MSA I), Semana 6 (MSA II), Semana
7 (MSA III), Semana 8 (Presentaciones Finales del Proyecto).

### Tabla "Repaso de Arquitectura de Software 2"

Tabla que resume los temas previos como prerrequisito conceptual: Diseño de
arquitectura de software (proceso de diseño arquitectónico, estrategias, principios,
arquitectura emergente); Atributos de calidad del software (eficiencia, usabilidad,
seguridad, escalabilidad, testabilidad, modularidad, extensibilidad,
mantenibilidad); Modularidad y descomposición (bajo acoplamiento, alta cohesión);
Escalabilidad y rendimiento (escalabilidad vertical, escalabilidad horizontal,
resistencia, tolerancia a fallos); Objetivos de negocio y arquitectura (análisis de
negocio, Desarrollo Guiado por Dominio / DDD).

### Tabla "Prerrequisitos del Curso"

Tabla que vincula el curso con Arquitectura de Software 1 (ASO-415: impulsores de
arquitectura, niveles de arquitectura, estilos arquitectónicos, patrones
arquitectónicos, documentación y comunicación de arquitectura) y Arquitectura de
Software 2 (SAR-200: diseño de arquitectura de software, arquitectura de software y
calidad de software, modularidad y descomposición, escalabilidad y rendimiento), más
experiencia en implementación de arquitecturas cliente/servidor (diseño de APIs,
manejo de autenticación, comunicación entre procesos, despliegue de servicios
distribuidos).

## Terminología importante

- **Arquitectura Empresarial (AE)**: disciplina que da una visión holística de
  estructura, procesos, sistemas de información e infraestructura tecnológica de
  una organización, alineados con la estrategia de negocio.
- **Arquitectura de Información (AI)**: disciplina dentro de la AE enfocada en
  estructurar, organizar y gobernar los datos e información de una organización.
- **Arquitectura de Aplicaciones**: define estructura, comportamiento e interacción
  de las aplicaciones que soportan los procesos de negocio.
- **Arquitectura Tecnológica**: define estructura y estándares de la
  infraestructura tecnológica que soporta aplicaciones y procesamiento de datos.
- **Análisis de Brechas (Gap Analysis)**: proceso para identificar discrepancias
  entre el estado actual y el estado futuro deseado de la organización.
- **Interoperabilidad de Sistemas**: capacidad de diferentes sistemas de software
  para intercambiar y usar información de manera fluida sin modificaciones
  significativas.
- **Interoperabilidad Semántica**: garantiza que los datos intercambiados sean
  comprendidos de manera consistente por todos los sistemas y partes interesadas.
- **Interoperabilidad Técnica**: garantiza que los sistemas puedan conectarse y
  transmitir datos (APIs, protocolos, formatos).
- **Interoperabilidad Organizacional**: alinea procesos, políticas y
  responsabilidades entre organizaciones o departamentos.
- **Gobierno (Governance, en AE)**: estructuras, procesos, principios y roles que
  aseguran que la AE esté definida, implementada y mantenida de manera consistente.
- **Cumplimiento (Compliance)**: capacidad de la organización para cumplir leyes,
  regulaciones, políticas internas y estándares de seguridad/técnicos.
- **Soluciones Modulares / Arquitectura Modular**: diseño e implementación de
  sistemas de TI como colecciones de componentes o módulos independientes.
- **Bajo acoplamiento / alta cohesión**: mencionados en el repaso de Arquitectura
  de Software 2 como subtemas de Modularidad y descomposición (no se redefinen en
  este documento).
- **DDD (Desarrollo Guiado por Dominio)**: mencionado en el repaso de Arquitectura
  de Software 2 dentro de "Objetivos de negocio y arquitectura" (no se desarrolla
  en este documento).
- **TOGAF**: mencionado como framework soportado por herramientas de modelado
  (Archi, Bizzdesign) sin definición propia en el material.
- **ArchiMate**: mencionado como framework/notación de modelado soportado por
  varias herramientas (Archi, Modelio, Bizzdesign, Sparx EA) sin definición propia
  en el material.

## Notas y advertencias

- El documento indica explícitamente que, de los cinco dominios de Arquitectura
  Empresarial listados (Estrategia, Negocio, Información, Aplicaciones,
  Tecnología), el curso **no cubre en detalle** la Capa de Estrategia ni la
  Arquitectura de Negocio; solo se profundiza en Información, Aplicaciones y
  Tecnología. Esto es una limitación de alcance declarada por la propia fuente, no
  una omisión de esta curaduría.
- Términos como "DDD" (Desarrollo Guiado por Dominio), "bajo acoplamiento", "alta
  cohesión", "TOGAF" y "ArchiMate" aparecen mencionados (en el repaso de
  Arquitectura de Software 2 o como soporte de herramientas) pero no se desarrollan
  ni definen dentro de este documento; su contenido conceptual completo
  corresponde a material de cursos o semanas previas/posteriores no cubiertas aquí.
- La sección "Referencias" del material remite a una serie de enlaces externos
  (videos de YouTube y artículos web) sobre Arquitectura Empresarial, Gobierno de
  AE y Arquitectura Modular. Estos enlaces no contienen contenido propio
  desarrollado dentro del documento, por lo que se excluyeron de esta curaduría
  salvo como referencia de que existen (no se transcribió el listado completo de
  URLs por tratarse de una tabla de enlaces externos sin contenido propio, según el
  criterio de "señal y ruido").
- El documento cierra presentando el "Proyecto Final" del curso como un "Sistema de
  Asistencia Digital (SAD) para estudiantes y profesores", que desarrollará
  habilidades de: diseño y documentación de arquitectura empresarial, análisis de
  interoperabilidad de sistemas, diseño de rendimiento de sistemas y diseño de
  arquitectura de microservicios. Esta es información declarada explícitamente por
  el propio documento fuente sobre la estructura del curso, no una interpretación
  externa.
- Las capturas de pantalla de herramientas de modelado (Archi, Modelio, Bizzdesign,
  Sparx EA) muestran interfaces y ejemplos de modelos (p. ej. "Archisurance",
  "Discount Voyage pour ArchiMate", "Home & Away Policy Administration") pero el
  material no explica en detalle el significado de negocio de esos modelos de
  ejemplo; se documentan únicamente como evidencia del tipo de vistas que cada
  herramienta permite generar.
- Las diapositivas administrativas iniciales (portada, bienvenida del instructor,
  agenda, resumen del curso, prerrequisitos, desglose semanal) se registraron de
  forma resumida por ser relevantes para entender el encuadre del documento, pero
  no constituyen contenido conceptual de Arquitectura Empresarial en sí.