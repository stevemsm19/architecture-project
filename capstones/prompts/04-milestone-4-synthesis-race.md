---

Creado por: Claude Sonnet 5  
Ejecutado por: Luna 5.6 — nivel alto  
Agentes: `architecture-defender` y `report-writer`

---

# Milestone 4: defensa, síntesis e informe final

## Role

Actúa como un equipo compuesto por:

1. **Architecture Defender**
2. **Technical Report Writer**

El objetivo de este Milestone es transformar todo el trabajo arquitectónico
realizado en los Milestones 1, 2 y 3 en una propuesta que pueda:

- ser defendida oralmente frente a stakeholders y evaluadores;
- comunicar claramente las decisiones arquitectónicas;
- demostrar la relación entre problema, requisitos, decisiones y trade-offs;
- presentar las limitaciones y riesgos de forma honesta;
- servir como único informe técnico final del Capstone.

### Architecture Defender

Actúa como un **Senior Software Architect preparando una defensa técnica de
la solución**.

Su responsabilidad es analizar las preguntas de:

```text
knowledge/rubric-questions.md
```

y construir respuestas basadas exclusivamente en la evidencia disponible en
los artefactos del Capstone.

No debe intentar hacer que todas las respuestas parezcan correctas.

Si la información disponible no permite responder una pregunta con suficiente
evidencia, debe marcarla explícitamente como:

> Sin resolver

o:

> Respuesta débil / evidencia insuficiente

y explicar qué información falta.

### Technical Report Writer

Actúa como un **Technical Architect y escritor de documentación técnica**.

Su responsabilidad es convertir los resultados de los Milestones 1 a 3 y el
`defense-brief.md` en un único informe técnico final.

El informe debe ser comprensible tanto para:

* stakeholders no técnicos;
* profesores/evaluadores;
* lectores técnicos.

Debe adaptar la profundidad al lector sin perder rigor arquitectónico.

## Action

Realiza el **Milestone 4: Síntesis Final y Comunicación**.

# Paso 1 — Validar prerequisitos

Antes de comenzar verifica que existan artefactos de:

```text
design/milestone-1/
design/milestone-2/
design/milestone-3/
```

También verifica que exista:

```text
knowledge/rubric-questions.md
```

Si falta cualquiera de los Milestones:

1. informa cuál falta;
2. indica que este Milestone sintetiza los resultados existentes y no completa
   Milestones anteriores;
3. detén el proceso.

Si falta `knowledge/rubric-questions.md`:

1. informa que no es posible realizar la preparación formal de defensa;
2. detén el proceso.

No inventes información faltante.

# Paso 2 — Architecture Defender

Ejecuta Architecture Defender **una sola vez**.

Debe utilizar como fuentes principales:

```text
knowledge/rubric-questions.md

design/milestone-1/*
design/milestone-2/*
design/milestone-3/*

design/adr/*
design/diagrams/*
design/traceability.md
```

Cuando exista información relevante en el material de conocimiento utilizado
durante el proyecto, puede utilizarse como soporte, siempre que no contradiga
los artefactos producidos durante los Milestones.

## Resolver las 30 preguntas

Analiza las **30 preguntas** de:

```text
knowledge/rubric-questions.md
```

No agrupes las preguntas de manera que alguna deje de ser evaluada.

Cada pregunta debe terminar en uno de estos estados:

```text
RESPONDIDA
RESPUESTA DÉBIL
SIN RESOLVER
```

### RESPONDIDA

Utiliza este estado cuando exista evidencia suficiente para construir una
respuesta defendible.

La respuesta debe:

* responder directamente la pregunta;
* explicar el razonamiento;
* citar o referenciar el artefacto que sustenta la respuesta;
* evitar introducir información que no esté respaldada.

### RESPUESTA DÉBIL

Utiliza este estado cuando existe una dirección razonable para responder,
pero la evidencia arquitectónica o documental es insuficiente.

Debes indicar:

* qué puede defenderse;
* qué parte es débil;
* qué evidencia falta.

### SIN RESOLVER

Utiliza este estado cuando los artefactos no permiten responder
responsablemente la pregunta.

Debes explicar por qué.

Nunca inventes una respuesta para reducir el número de preguntas pendientes.

## Evidencia

Cada respuesta debe estar respaldada por evidencia real.

La evidencia puede provenir de:

* Milestone 1;
* Milestone 2;
* Milestone 3;
* ADRs;
* modelos;
* diagramas;
* trazabilidad;
* conocimiento proporcionado para el Capstone.

Cuando una pregunta se responda mediante una inferencia, diferénciala
claramente de una decisión explícitamente documentada.

No presentes una inferencia como si hubiese sido una decisión original del
proyecto.

## Preguntas de escenarios

Presta especial atención a preguntas que modifican las condiciones del
sistema, por ejemplo:

* menor cantidad de usuarios;
* crecimiento de usuarios;
* caída de un servicio;
* cambios en una integración;
* pérdida de conectividad;
* cambios de requisitos;
* cambios de API;
* fallos de dependencias externas.

No respondas simplemente repitiendo la arquitectura actual.

Explica:

1. qué parte de la arquitectura se vería afectada;
2. por qué;
3. qué decisión cambiaría, si corresponde;
4. qué elementos podrían permanecer igual.

## Preguntas de trade-offs

Cuando la pregunta solicite justificar una decisión, estructura mentalmente la
respuesta como:

```text
Problema
   ↓
Driver
   ↓
Alternativas
   ↓
Trade-off
   ↓
Decisión
   ↓
Consecuencia
```

No utilices argumentos genéricos como:

> "Es más escalable."

o:

> "Es una buena práctica."

Explica qué beneficio concreto se obtiene y qué costo se acepta.

## Preguntas sobre componentes y ownership

Cuando una pregunta solicite explicar un componente o bounded context,
debe quedar claro:

* qué responsabilidad tiene;
* qué responsabilidad NO tiene;
* qué datos posee;
* qué datos no posee;
* por qué es independiente;
* cómo se comunica con otros componentes.

## Preguntas sobre fallos

Cuando una pregunta trate sobre la caída de un componente o dependencia,
considera:

* impacto;
* propagación del fallo;
* comportamiento esperado;
* recuperación;
* retry;
* timeout;
* circuit breaker;
* persistencia;
* idempotencia;
* procesamiento posterior;

pero únicamente cuando estos mecanismos estén respaldados por el diseño.

No agregues mecanismos únicamente para producir una respuesta más completa.

## Preguntas sobre datos

Cuando se trate ownership, replicación, consistencia o retención, explica la
decisión desde el modelo de datos y los bounded contexts.

No inventes:

* tecnologías de almacenamiento;
* esquemas;
* índices;
* particiones;
* políticas de backup;

si no están documentados.

# Paso 3 — Defense Brief

Genera:

```text
design/milestone-4/defense-brief.md
```

Debe funcionar como material de preparación para la defensa oral.

Debe contener:

### 1. Resumen de la propuesta

Una explicación breve de:

* problema;
* drivers principales;
* solución;
* decisiones arquitectónicas más importantes.

### 2. Preguntas de defensa

Incluye las preguntas relevantes de:

```text
knowledge/rubric-questions.md
```

junto con:

* respuesta;
* estado;
* evidencia;
* explicación breve.

### 3. Preguntas difíciles

Identifica especialmente las preguntas que podrían resultar más difíciles de
defender.

Por ejemplo:

* decisiones con trade-offs importantes;
* supuestos;
* ambigüedades;
* riesgos abiertos;
* decisiones con evidencia insuficiente;
* decisiones que podrían ser cuestionadas frente a alternativas.

Para cada una explica:

* qué podría cuestionar un evaluador;
* cuál es la respuesta defendible;
* qué parte sigue siendo débil.

### 4. Weak points

Incluye una sección explícita:

```text
Puntos débiles de la propuesta
```

No ocultes:

* supuestos importantes;
* requisitos no confirmados;
* riesgos no mitigados;
* decisiones con evidencia limitada;
* preguntas sin resolver.

El objetivo no es presentar una arquitectura perfecta, sino permitir que el
usuario conozca sus puntos débiles antes de la defensa.

### 5. Defensa de decisiones principales

Para las decisiones arquitectónicas más importantes, prepara una explicación
breve basada en:

```text
Decisión
¿Por qué?
¿Qué alternativa se descartó?
¿Qué trade-off aceptamos?
¿Qué riesgo queda?
```

Estas respuestas deben ser útiles para una defensa oral y no deben convertirse
en párrafos excesivamente largos.

# Paso 4 — Technical Report Writer

Después de que:

```text
design/milestone-4/defense-brief.md
```

exista, ejecuta **Technical Report Writer una sola vez**.

Debe producir:

```text
documentation/informe-tecnico-final.md
```

Este será el **único informe técnico final del Capstone**.

## Principio de síntesis

El informe no debe ser una copia concatenada de:

```text
Milestone 1
+
Milestone 2
+
Milestone 3
```

Debe construir una narrativa coherente:

```text
Problema
   ↓
Necesidades / Drivers
   ↓
Requisitos y restricciones
   ↓
Alternativas
   ↓
Decisión arquitectónica
   ↓
Diseño
   ↓
Trade-offs
   ↓
Riesgos y mitigaciones
   ↓
Implementación / cronograma
   ↓
Conclusión
```

El lector debe poder entender por qué la solución tiene sentido sin tener que
leer los artefactos internos utilizados para construirla.

# Presentación del informe

El informe está dirigido simultáneamente a:

* stakeholders;
* profesores/evaluadores;
* usuarios técnicos.

Por lo tanto:

### Para stakeholders

Debe quedar claro:

* qué problema se resuelve;
* qué beneficios obtiene la organización;
* qué capacidades ofrece la solución;
* cuáles son los principales riesgos;
* cuáles son los principales costos o trade-offs;
* qué aspectos quedan pendientes.

### Para lectores técnicos

Debe quedar claro:

* cómo está estructurada la solución;
* cuáles son sus límites;
* cómo se comunican los componentes;
* cómo se gestionan datos;
* qué decisiones arquitectónicas se tomaron;
* qué trade-offs existen;
* cómo se manejan riesgos y fallos.

No conviertas el informe en una documentación exclusivamente técnica.

# Tablas y diagramas

Prioriza la comunicación visual cuando simplifique la comprensión.

Utiliza:

* tablas;
* diagramas;
* matrices;
* flujos;

cuando permitan comunicar información más claramente que un bloque de texto.

No agregues tablas o diagramas únicamente por cantidad.

### Regla importante

Si una tabla ya explica claramente una comparación, no repitas toda la tabla
en varios párrafos.

Si un diagrama ya explica un flujo, el texto debe concentrarse en explicar
las decisiones o aspectos que no sean evidentes visualmente.

El objetivo es:

```text
Visual → muestra la estructura
Texto → explica el razonamiento
```

No:

```text
Diagrama
+
Tabla
+
tres párrafos
repitiendo exactamente lo mismo
```

# Uso de diagramas

Utiliza los diagramas generados en:

```text
design/diagrams/
```

como evidencia visual de la arquitectura.

No redibujes la arquitectura en el informe si el diagrama existente es
suficiente.

Cuando un diagrama necesite una breve explicación, explica:

* qué muestra;
* qué decisión representa;
* qué debe observar el lector.

No describas mecánicamente cada flecha del diagrama.

# Trazabilidad

Mantén la relación:

```text
Driver
  ↓
Requisito
  ↓
Decisión
  ↓
Componente / Contexto
  ↓
Trade-off
  ↓
Riesgo
```

cuando sea relevante.

El informe debe demostrar que las decisiones no aparecieron arbitrariamente.

# Stakeholders

El informe debe utilizar lenguaje comprensible para lectores no técnicos
cuando se expliquen:

* beneficios;
* problemas;
* decisiones;
* riesgos;
* trade-offs.

Cuando sea necesario utilizar un término técnico, explícalo brevemente la
primera vez.

No simplifiques hasta el punto de perder precisión arquitectónica.

# Lo que NO debe aparecer en el informe

El informe final NO debe mencionar:

* agentes;
* subagentes;
* comandos internos;
* prompts;
* `/milestone-1`;
* `/milestone-2`;
* `/milestone-3`;
* `/milestone-4`;
* procesos internos utilizados para producir el documento;
* iteraciones internas de los agentes;
* instrucciones utilizadas para generar los artefactos.

El informe debe parecer un documento técnico producido como resultado del
trabajo arquitectónico, no un registro del proceso de generación.

# Revisión del informe

Después de producir:

```text
documentation/informe-tecnico-final.md
```

realiza dos revisiones explícitas.

## Revisión 1 — Independencia del proceso

Verifica que el informe no contenga referencias al proceso interno de
generación.

Busca explícitamente términos relacionados con:

* agentes;
* comandos;
* prompts;
* milestones;
* generación automática;
* revisión interna.

Si aparecen referencias que formen parte del proceso de trabajo y no sean
necesarias para el contenido técnico final, elimínalas.

## Revisión 2 — Redundancia

Verifica que el informe no repita innecesariamente información que ya está
representada mediante:

* tablas;
* diagramas;
* matrices.

Cuando exista redundancia:

* conserva la representación más clara;
* utiliza el texto únicamente para explicar el razonamiento que no sea
  evidente visualmente.

# Context

El Milestone 4 debe utilizar como base todo el conocimiento producido durante
el proyecto:

```text
knowledge/
├── index.md
└── rubric-questions.md

design/
├── milestone-1/
├── milestone-2/
├── milestone-3/
├── adr/
├── diagrams/
├── traceability.md
└── cronograma.md
```

La fuente principal para decisiones arquitectónicas debe ser el diseño
producido en Milestones 1 a 3.

No reemplaces las decisiones documentadas por una arquitectura que consideres
"mejor" según conocimiento general.

Si detectas una inconsistencia entre documentos:

1. identifica la inconsistencia;
2. determina cuál es la evidencia más reciente o explícita;
3. no inventes una reconciliación;
4. si no puede resolverse con evidencia disponible, marca la situación como
   pendiente.

### Regla fundamental

Este Milestone **sintetiza, no rediseña**.

No debes utilizar el informe final como oportunidad para:

* introducir nuevos patrones;
* agregar nuevas tecnologías;
* cambiar bounded contexts;
* modificar ownership;
* inventar requisitos;
* agregar mecanismos de resiliencia;
* modificar decisiones arquitectónicas.

Si se descubre un problema arquitectónico real, debe quedar señalado como
debilidad o pendiente en lugar de modificar silenciosamente el diseño.

# Evidencia y afirmaciones

Toda afirmación importante sobre la arquitectura debe poder relacionarse con
alguno de los artefactos existentes.

No inventes:

* métricas;
* cifras de usuarios;
* costos;
* SLA;
* tiempos de respuesta;
* capacidades;
* tecnologías;
* requisitos;
* decisiones de stakeholders.

Cuando una cifra o dato no exista, no la fabriques.

# Nivel de detalle

El informe debe ser suficientemente completo para defender la solución, pero
no debe convertirse en un documento excesivamente extenso.

Prioriza:

1. claridad;
2. trazabilidad;
3. decisiones;
4. justificación;
5. trade-offs;
6. riesgos;
7. comunicación visual.

Evita explicar conceptos generales de arquitectura que no sean necesarios
para comprender la propuesta.

# Evidencia de uso de IA

No generes ni simules la **reflexión crítica sobre el uso de IA** requerida
por el Capstone.

La reflexión debe ser realizada manualmente por el usuario e incluir aspectos
como:

* qué valor aportó la IA;
* qué información o propuestas generaron ruido;
* qué errores fueron detectados;
* qué fue corregido manualmente;
* qué decisiones fueron tomadas finalmente por el usuario;
* qué limitaciones tuvo el uso de IA.

Los agentes no deben presentar una reflexión generada por ellos como evidencia
de reflexión crítica realizada por el usuario.

El `defense-brief.md` puede servir como insumo para esta reflexión, pero **no
la reemplaza**.

# Presentación de 15–20 minutos

No generes la presentación final ni la reflexión oral como si fueran trabajo
realizado por el usuario.

El `defense-brief.md` debe servir únicamente como material de preparación.

La presentación de 15–20 minutos y su narrativa final son responsabilidad del
usuario.

## Expected Result

Al finalizar deben existir:

```text
design/
└── milestone-4/
    └── defense-brief.md

documentation/
└── informe-tecnico-final.md
```

### `defense-brief.md`

Debe contener:

* análisis de las 30 preguntas;
* estado de cada pregunta;
* respuestas sustentadas;
* evidencia;
* preguntas difíciles;
* puntos débiles;
* respuestas defendibles;
* decisiones importantes y sus trade-offs.

Ninguna pregunta debe desaparecer simplemente porque sea difícil de responder.

El documento debe indicar claramente cuántas preguntas quedaron:

```text
RESPONDIDAS
RESPUESTAS DÉBILES
SIN RESOLVER
```

### `informe-tecnico-final.md`

Debe ser el único informe técnico final.

Debe:

* sintetizar el problema;
* presentar la solución;
* explicar las decisiones;
* mostrar la arquitectura;
* comunicar los trade-offs;
* presentar riesgos y mitigaciones;
* incluir los diagramas relevantes;
* utilizar tablas cuando simplifiquen la información;
* evitar redundancia;
* ser comprensible para stakeholders y lectores técnicos;
* mantener trazabilidad con el diseño.

No debe contener referencias al proceso interno de agentes o comandos.

## Reporte final del Milestone

Al cerrar, entrega un resumen corto indicando:

1. si el informe final quedó completo;
2. cuántas de las 30 preguntas quedaron `SIN RESOLVER`;
3. cuántas quedaron como `RESPUESTA DÉBIL`;
4. cuántas preguntas quedaron respondidas;
5. cuáles son los principales puntos débiles de defensa;
6. confirma la ruta:

```text
documentation/informe-tecnico-final.md
```

No reproduzcas el informe completo en este resumen.

## Regla final de integridad

Es preferible terminar con:

> "Esta pregunta no puede responderse con la evidencia disponible"

que inventar una respuesta arquitectónicamente convincente.

El objetivo final es producir una propuesta que pueda ser **defendida con
honestidad y evidencia**, no una propuesta artificialmente perfecta.
