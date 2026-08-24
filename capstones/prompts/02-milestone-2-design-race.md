--- 

Creado por: Claude Sonnet 5  
Ejecutado por: Luna 5.6 — nivel alto  
Agentes: `architecture-strategist`, `architecture-modeler`,
`architecture-reviewer`

---

# Milestone 2 — Diseño Arquitectónico Base

## Role

Actúa como un equipo coordinado de **Senior Software Architects especializados
en diseño de sistemas distribuidos, Domain-Driven Design, Architecture
Decision Records (ADR), modelado C4 y evaluación de trade-offs arquitectónicos**.

Este Milestone tiene como objetivo transformar los resultados del Milestone 1
en una **propuesta arquitectónica base**, evaluando alternativas antes de
seleccionar una solución.

Debes trabajar como si existieran tres responsabilidades independientes:

1. **Architecture Strategist**
   - Analiza los drivers y requisitos obtenidos en Milestone 1.
   - Propone alternativas arquitectónicas.
   - Evalúa sus trade-offs.
   - Recomienda una alternativa.
   - Define los bounded contexts.
   - Propone un modelo de datos conceptual.
   - Documenta las decisiones mediante ADR.

2. **Architecture Modeler**
   - Traduce la alternativa recomendada a modelos y diagramas.
   - Debe representar visualmente la arquitectura propuesta.
   - Los diagramas deben ser coherentes con las decisiones documentadas.
   - No debe inventar componentes que no estén justificados por la estrategia
     arquitectónica.

3. **Architecture Reviewer**
   - Actúa como un gate independiente.
   - Audita la propuesta completa.
   - Busca inconsistencias, decisiones no justificadas, violaciones de
     requisitos, problemas de trazabilidad, ambigüedades no tratadas y
     contradicciones entre texto, ADRs, modelo de datos y diagramas.
   - No debe modificar directamente la arquitectura para corregir sus
     hallazgos.
   - Debe documentar los hallazgos para que Strategist pueda corregirlos.

Debes mantener una separación clara entre estas responsabilidades.

El objetivo no es producir la mayor cantidad posible de componentes, patrones o
tecnologías, sino producir una arquitectura **justificada por el problema**.


## Action

Realiza el **Milestone 2: Diseño Arquitectónico Base** utilizando como entrada
los resultados del Milestone 1.

### Paso 1 — Validar prerequisitos

Antes de comenzar, verifica que exista:

```text
design/milestone-1/discovery.md. 
```

También debes verificar, cuando sea posible, que estén disponibles los demás
artefactos del Milestone 1, especialmente:

```text
design/milestone-1/priorizacion.md
design/traceability.md
```

Si `design/milestone-1/discovery.md` no existe:

1. informa que el Milestone 1 no está disponible;
2. indica que debe ejecutarse primero el Milestone 1;
3. detén el proceso.

No inventes información faltante del Milestone 1.

# Iteración 1

## Paso 2 — Architecture Strategist

Analiza:

```text
design/milestone-1/discovery.md
design/milestone-1/priorizacion.md
design/traceability.md
```

y genera una propuesta arquitectónica basada exclusivamente en los drivers,
requisitos, restricciones, supuestos y ambigüedades identificados.

### Alternativas

Debes proponer como mínimo **dos alternativas arquitectónicas razonables**.

Las alternativas deben representar opciones que realmente podrían utilizarse
para resolver el problema.

No generes alternativas artificialmente diferentes solo para cumplir con el
número mínimo.

Para cada alternativa analiza como mínimo:

* cómo responde a los principales architectural drivers;
* ventajas;
* desventajas;
* complejidad;
* impacto operativo;
* escalabilidad;
* mantenibilidad;
* resiliencia;
* consistencia de datos;
* impacto sobre los requisitos;
* principales riesgos;
* trade-offs.

Cuando una alternativa sea descartada, explica por qué.

### Recomendación

Después de comparar las alternativas, recomienda una.

La recomendación debe estar sustentada por:

```text
Architectural Driver
        ↓
Necesidad / Requisito
        ↓
Alternativa
        ↓
Trade-off
        ↓
Decisión
```

No selecciones una alternativa únicamente porque sea una tecnología o estilo
"popular".

La solución debe responder al problema identificado en Milestone 1.

## Paso 3 — Architecture Decision Records

Documenta las decisiones arquitectónicas relevantes mediante ADR.

Cada ADR debe explicar, como mínimo:

* contexto;
* problema;
* decisión;
* alternativas consideradas;
* razones para elegir la decisión;
* trade-offs;
* consecuencias;
* drivers/requisitos relacionados.

Los ADR deben ser decisiones reales y significativas.

No generes ADRs triviales únicamente para aumentar el número de documentos.

Utiliza nombres consistentes, por ejemplo:

```text
design/adr/adr-0001-*.md
design/adr/adr-0002-*.md
```

Los ADR deben poder relacionarse posteriormente con los elementos de
`design/traceability.md`.

## Paso 4 — Bounded Contexts

Identifica los bounded contexts de la alternativa recomendada.

Para cada bounded context explica:

* propósito;
* responsabilidad;
* qué conceptos o información posee;
* qué información NO debería poseer;
* relaciones con otros bounded contexts;
* principales dependencias;
* razón por la que constituye un límite independiente.

No definas bounded contexts simplemente basándote en nombres de entidades.

El criterio debe considerar principalmente:

* responsabilidades de negocio;
* ownership de datos;
* límites de consistencia;
* lenguaje del dominio;
* cambios independientes;
* dependencias.

Evita crear bounded contexts innecesarios.

## Paso 5 — Modelo de datos conceptual

Genera un modelo de datos conceptual de la solución recomendada.

El modelo debe representar:

* principales conceptos del dominio;
* relaciones relevantes;
* ownership;
* límites de consistencia cuando sean relevantes;
* información compartida o referenciada entre contextos.

Este modelo es conceptual.

No diseñes todavía:

* tablas físicas;
* índices;
* particiones;
* tipos específicos de bases de datos;
* detalles de implementación.

El objetivo es mostrar cómo se organiza conceptualmente la información.

## Paso 6 — Architecture Modeler

Una vez que Strategist haya producido la alternativa recomendada, utiliza
Architecture Modeler para crear los diagramas correspondientes.

Los diagramas deben representar la arquitectura recomendada y deben ser
consistentes con:

```text
architecture-decision.md
ADR
bounded-contexts.md
data-model-conceptual.md
design/traceability.md
```

Utiliza preferentemente modelos C4 cuando sean adecuados.

Los diagramas deben ayudar a responder visualmente:

* ¿Quién interactúa con el sistema?
* ¿Cuáles son los principales límites del sistema?
* ¿Cuáles son los componentes/contextos relevantes?
* ¿Cómo se comunican?
* ¿Dónde están los principales límites de responsabilidad?
* ¿Cómo se relacionan los principales elementos del modelo?

No sobrecargues los diagramas.

Si existen muchas relaciones que generan flechas cruzadas o difícil lectura,
reorganiza el layout, divide el modelo cuando corresponda o utiliza diferentes
niveles de abstracción.

El diagrama debe priorizar legibilidad sobre cantidad de información.

Todos los diagramas deben incluir notas suficientes para que otro arquitecto
pueda entender:

* qué representa;
* qué decisiones refleja;
* qué elementos son importantes;
* qué aspectos deliberadamente no se representan.

## Paso 7 — Architecture Reviewer

Una vez generados los artefactos, ejecuta un review independiente.

El reviewer debe analizar:

```text
design/milestone-2/*
design/adr/*
design/diagrams/*
design/traceability.md
```

Debe buscar como mínimo:

### Coherencia

* ¿Los diagramas representan realmente la arquitectura descrita?
* ¿Los ADR coinciden con la arquitectura?
* ¿Los bounded contexts coinciden con las responsabilidades?
* ¿El modelo conceptual coincide con el ownership definido?

### Trazabilidad

* ¿Las decisiones importantes pueden relacionarse con drivers o requisitos?
* ¿Existe alguna decisión importante sin justificación?
* ¿Existe algún driver crítico que no tenga respuesta arquitectónica?

### Requisitos

* ¿La propuesta satisface los principales requisitos?
* ¿Algún requisito quedó ignorado?
* ¿Algún requisito fue reinterpretado sin justificación?

### Trade-offs

* ¿La alternativa recomendada tiene una justificación suficiente?
* ¿Se documentaron costos y consecuencias?
* ¿Se presentan las desventajas de la solución recomendada?

### Complejidad

* ¿Se introdujeron componentes innecesarios?
* ¿Se utilizaron patrones o mecanismos que no están justificados?
* ¿La solución es excesivamente compleja para el problema?

### Boundaries

* ¿Los bounded contexts tienen responsabilidades claras?
* ¿Existe ownership claro de los datos?
* ¿Se están compartiendo datos que deberían pertenecer a otro contexto?

### Diagramas

* ¿Son legibles?
* ¿Hay flechas o relaciones ambiguas?
* ¿Los niveles de abstracción están mezclados?
* ¿Existe información contradictoria entre diagramas?

### Ambigüedades

* ¿Se tomó una decisión sobre algo que todavía estaba marcado como
  `AMB` sin justificarlo?
* ¿Alguna decisión depende de una pregunta de stakeholder que todavía no fue
  respondida?

Los hallazgos deben clasificarse por severidad y deben quedar registrados en:

```text
design/milestone-2/review-log.md
```

# Iteraciones posteriores

Si el reviewer encuentra nuevos hallazgos relevantes, inicia una nueva
iteración.

## Si el hallazgo afecta estructura o decisiones

Vuelve a ejecutar Architecture Strategist utilizando como entrada:

```text
design/milestone-2/review-log.md
```

además de todos los artefactos originales del Milestone 1.

Strategist debe:

1. analizar el hallazgo;
2. determinar si realmente requiere un cambio;
3. modificar la decisión o justificar por qué debe mantenerse;
4. actualizar los ADR afectados;
5. actualizar bounded contexts o modelo conceptual si corresponde;
6. mantener la trazabilidad.

Después:

* ejecuta Architecture Modeler **solo si cambió la estructura arquitectónica**;
* vuelve a ejecutar Architecture Reviewer.

## Si el hallazgo solamente afecta documentación

Si el hallazgo corresponde únicamente a:

* redacción;
* explicación;
* justificación;
* descripción;

no es necesario volver a generar los diagramas.

Actualiza únicamente los artefactos afectados y vuelve a ejecutar el reviewer.

## Regla para los diagramas

NO obligues a Architecture Modeler a redibujar los diagramas si Strategist
solamente modificó:

* texto;
* justificación;
* descripción;
* explicación de una decisión;

y la estructura arquitectónica no cambió.

Sí debe ejecutarse nuevamente cuando cambien:

* componentes;
* bounded contexts;
* relaciones;
* flujos;
* ownership;
* interfaces;
* límites arquitectónicos;
* decisiones que afecten la representación visual.

## Límite de iteraciones

Como máximo deben realizarse **3 iteraciones del gate**.

El proceso ideal es:

```text
Strategist
    ↓
Modeler
    ↓
Reviewer
    ↓
¿Hay nuevos hallazgos?
    │
    ├── No → Gate cerrado
    │
    └── Sí
         ↓
      Strategist
         ↓
      Modeler*
         ↓
      Reviewer
```

`Modeler*` solo se ejecuta si la estructura arquitectónica cambió.

Si se alcanza el límite de iteraciones y todavía existen hallazgos:

* cierra el gate;
* registra los hallazgos pendientes;
* clasifícalos como:

> Riesgo conocido, no resuelto.

No continúes iterando indefinidamente.

## Context

Este Milestone debe construirse a partir de:

```text
design/milestone-1/
├── discovery.md
└── priorizacion.md

design/traceability.md
```

El Milestone 1 constituye la base del diseño.

No debes ignorar sus drivers, requisitos, restricciones o ambigüedades para
crear una arquitectura "ideal" según conocimiento general.

### Principio fundamental

La arquitectura debe responder al problema descubierto.

No debe ocurrir:

```text
"Me gusta esta arquitectura"
        ↓
"Busquemos problemas que la justifiquen"
```

Debe ocurrir:

```text
Problema
   ↓
Architectural Drivers
   ↓
Requisitos / Restricciones
   ↓
Alternativas
   ↓
Trade-offs
   ↓
Decisión arquitectónica
```

### Uso del material de conocimiento

Si el Milestone 1 está respaldado por `knowledge/index.md`, las decisiones
arquitectónicas deben utilizar los conceptos y principios contenidos en ese
material cuando sean relevantes.

No introduzcas patrones o conceptos simplemente porque sean conocidos.

Si una decisión requiere un concepto que no está respaldado por el material
disponible, identifica esa situación explícitamente en lugar de ocultarla.

### No inventar requisitos

No inventes:

* usuarios;
* cargas;
* volúmenes;
* SLA;
* tecnologías;
* proveedores;
* costos;
* protocolos;
* integraciones;
* requisitos de seguridad;
* requisitos regulatorios;
* restricciones operativas.

Si una decisión arquitectónica necesita uno de estos datos y no existe,
documenta la incertidumbre y determina si corresponde:

* utilizar un supuesto explícito;
* mantener una alternativa abierta;
* generar una pregunta para stakeholders.

### Stakeholder questions

Las preguntas pendientes del Milestone 1 deben tratarse como entradas
importantes.

No debes inventar sus respuestas.

Si una decisión arquitectónica depende de una pregunta todavía sin respuesta,
debes señalar la dependencia.

### Arquitectura y tecnologías

En este Milestone ya está permitido analizar tecnologías cuando sean
necesarias para comparar alternativas.

Sin embargo, la tecnología debe aparecer como consecuencia de una decisión
arquitectónica, no como punto de partida.

Ejemplo incorrecto:

> "Utilizaremos Kafka porque es escalable."

Ejemplo correcto:

> "La arquitectura requiere comunicación desacoplada entre determinados
> procesos. Se evaluaron diferentes mecanismos de comunicación y se seleccionó
> X debido a A, B y C, aceptando como trade-off D."

La decisión debe poder defenderse independientemente de la popularidad de la
tecnología.

## Expected Result

Al finalizar deben existir como mínimo:

```text
design/
├── milestone-2/
│   ├── architecture-decision.md
│   ├── bounded-contexts.md
│   ├── data-model-conceptual.md
│   └── review-log.md
│
├── adr/
│   ├── adr-0001-*.md
│   └── ...
│
└── diagrams/
    ├── *.mmd
    └── NOTES.md
```

### `architecture-decision.md`

Debe presentar:

* alternativas consideradas;
* comparación;
* alternativa recomendada;
* justificación;
* principales trade-offs;
* consecuencias;
* relación con los drivers y requisitos.

Debe ser posible entender por qué se eligió la solución sin tener que leer
todos los demás archivos.

### `bounded-contexts.md`

Debe documentar los bounded contexts de la arquitectura recomendada y sus
límites.

Debe quedar claro:

* quién es responsable de qué;
* qué datos posee cada contexto;
* cómo se relacionan los contextos;
* qué responsabilidades deliberadamente no pertenecen a cada uno.

### `data-model-conceptual.md`

Debe representar el modelo conceptual del dominio y el ownership de la
información.

Debe evitar detalles prematuros de implementación.

### `design/adr/`

Debe contener al menos un ADR significativo.

Los ADR deben documentar decisiones importantes y sus trade-offs.

### `design/diagrams/`

Debe contener los diagramas de arquitectura necesarios para comunicar la
solución.

Preferentemente utiliza C4 cuando corresponda.

Cada diagrama debe estar acompañado por:

```text
design/diagrams/NOTES.md
```

donde se explique brevemente:

* propósito del diagrama;
* nivel de abstracción;
* qué decisiones representa;
* qué elementos importantes deben observarse;
* cualquier simplificación realizada.

### `review-log.md`

Debe registrar:

* cada iteración;
* fecha/orden de la iteración;
* hallazgos encontrados;
* severidad;
* acción tomada;
* si se resolvió;
* si quedó como riesgo conocido.

Debe ser posible reconstruir cómo evolucionó la arquitectura durante el gate.

## Reporte final

Al cerrar el Milestone, entrega un resumen breve indicando:

1. **Estilo arquitectónico recomendado.**
2. **Alternativas consideradas y cuáles fueron descartadas.**
3. **Principales razones de la decisión.**
4. **Principales trade-offs aceptados.**
5. **Cantidad de ADRs generados.**
6. **Cantidad de bounded contexts identificados.**
7. **Cantidad de iteraciones realizadas.**
8. **Si el gate terminó en `SIN HALLAZGOS NUEVOS`.**
9. **Si quedaron riesgos conocidos o hallazgos sin resolver.**

No repitas todo el contenido de los archivos en el reporte final.