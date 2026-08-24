---

Creado por: Claude Sonnet 5  
Ejecutado por: Luna 5.6 — nivel alto  
Agentes: `architecture-tradeoff`, `architecture-risk`, `architecture-reviewer`,`architecture-strategist` y `architecture-modeler`solo si un hallazgo reabre una decisión estructural

---

# Milestone 3 — Trade-offs, Calidad y Riesgos

## Role

Actúa como un equipo de **Senior Software Architects especializados en
evaluación de arquitecturas, trade-offs, atributos de calidad, gestión de
riesgos arquitectónicos y planificación de implementación**.

Este Milestone tiene como objetivo evaluar críticamente la arquitectura
producida en Milestone 2.

No debes diseñar una arquitectura completamente nueva.

Debes determinar:

- qué trade-offs introduce la solución elegida;
- qué beneficios y costos tiene cada decisión importante;
- qué atributos de calidad son más relevantes;
- qué riesgos arquitectónicos, técnicos y operativos existen;
- qué riesgos tienen mayor severidad;
- cómo podrían mitigarse;
- qué riesgos son aceptables;
- qué riesgos podrían obligar a reconsiderar una decisión tomada en
  Milestone 2;
- qué impacto tienen estas decisiones sobre el cronograma de implementación.

Trabajarás con tres responsabilidades:

1. **Architecture Tradeoff**
   - Analiza los trade-offs de la arquitectura existente.
   - Evalúa las decisiones tomadas en Milestone 2.
   - Compara beneficios y costos.
   - No genera nuevas alternativas arquitectónicas.

2. **Architecture Risk**
   - Identifica y evalúa riesgos.
   - Determina probabilidad, impacto y severidad.
   - Propone mitigaciones.
   - Identifica riesgos residuales.
   - No rediseña la arquitectura por cuenta propia.

3. **Architecture Reviewer**
   - Actúa como gate independiente.
   - Audita los trade-offs, riesgos y mitigaciones.
   - Verifica consistencia con Milestone 2.
   - Determina si algún hallazgo puede resolverse dentro de Milestone 3 o si
     requiere reabrir una decisión arquitectónica anterior.

Los agentes de Tradeoff y Risk son independientes y pueden trabajar en paralelo.


## Action

Realiza el **Milestone 3: Trade-offs, Calidad y Riesgos** utilizando como base
los resultados de Milestone 2.


### Paso 1 — Validar prerequisitos

Antes de comenzar verifica que exista:

```text
design/milestone-2/architecture-decision.md
```

Además, verifica que el archivo documente al menos **una alternativa real que
haya sido descartada**.

Si `architecture-decision.md` no existe:

1. informa que Milestone 2 no está disponible;
2. indica que debe ejecutarse primero el Milestone 2;
3. detén el proceso.

Si existe el archivo pero NO contiene una alternativa real descartada:

1. informa que Milestone 2 no proporciona la información necesaria;
2. no inventes una alternativa descartada;
3. indica que debe revisarse Milestone 2;
4. detén el proceso.

# Iteración 1

## Paso 2 — Architecture Tradeoff

Analiza los artefactos de Milestone 2, especialmente:

```text
design/milestone-2/architecture-decision.md
design/milestone-2/bounded-contexts.md
design/milestone-2/data-model-conceptual.md
design/adr/*
design/diagrams/*
design/traceability.md
```

Identifica los principales trade-offs de la arquitectura seleccionada.

### Principio fundamental

Un trade-off representa una decisión donde obtener un beneficio implica
aceptar algún costo, limitación o consecuencia.

No describas únicamente beneficios.

Para cada trade-off analiza, cuando corresponda:

* decisión;
* beneficio obtenido;
* costo introducido;
* atributo de calidad favorecido;
* atributo de calidad afectado;
* impacto técnico;
* impacto operativo;
* impacto sobre mantenibilidad;
* impacto sobre escalabilidad;
* impacto sobre resiliencia;
* impacto sobre complejidad;
* impacto sobre costos;
* consecuencias a largo plazo.

No es necesario evaluar todos los atributos anteriores para cada decisión.
Utiliza únicamente los que sean relevantes.

### Alternativas

Utiliza únicamente las alternativas que realmente hayan sido documentadas en
Milestone 2.

NO generes nuevas alternativas.

Si una decisión no tiene una alternativa real documentada y el análisis
requiere compararla, registra un hallazgo:

> Falta una alternativa arquitectónica documentada en Milestone 2.

No inventes una alternativa artificial para completar la matriz.

### Trade-off Matrix

Genera:

```text
design/milestone-3/tradeoff-matrix.md
```

La matriz debe permitir responder:

> ¿Qué estamos ganando con cada decisión y qué estamos aceptando a cambio?

Prioriza los trade-offs arquitectónicamente significativos.

No llenes la matriz con decisiones triviales.

## Paso 3 — Architecture Risk

En paralelo con Architecture Tradeoff, analiza los mismos artefactos de
Milestone 2.

Identifica riesgos relevantes de la arquitectura.

Los riesgos pueden incluir, cuando estén respaldados por la arquitectura:

* riesgos técnicos;
* riesgos de escalabilidad;
* riesgos de disponibilidad;
* riesgos de resiliencia;
* riesgos de consistencia;
* riesgos de integración;
* riesgos operativos;
* riesgos de seguridad;
* riesgos de datos;
* riesgos de rendimiento;
* riesgos de mantenibilidad;
* riesgos asociados a dependencias externas;
* riesgos de implementación;
* riesgos de complejidad.

No inventes riesgos hipotéticos sin relación con la arquitectura.

### Evaluación del riesgo

Para cada riesgo identifica, cuando sea posible:

* ID;
* descripción;
* causa;
* consecuencia;
* probabilidad;
* impacto;
* severidad;
* elementos arquitectónicos afectados;
* driver/requisito relacionado;
* estrategia de mitigación;
* riesgo residual;
* responsable o área responsable, si puede determinarse.

Utiliza una escala consistente para probabilidad, impacto y severidad.

### Risk Register

Genera:

```text
design/milestone-3/risk-register.md
```

Prioriza los riesgos más relevantes.

No es necesario generar una lista excesivamente extensa de riesgos menores.

## Paso 4 — Mitigation Plan

A partir de los riesgos identificados, genera:

```text
design/milestone-3/mitigation-plan.md
```

Cada mitigación debe explicar:

* qué riesgo aborda;
* qué acción se propone;
* por qué esa acción reduce el riesgo;
* cuándo debería realizarse;
* qué dependencia tiene;
* qué riesgo residual permanece.

Distingue claramente entre:

### Mitigación

Acción que reduce la probabilidad o impacto de un riesgo.

### Contingencia

Acción que se ejecutaría si el riesgo ocurre.

No confundas ambas.

### Importante

Una mitigación no debe convertirse automáticamente en una nueva decisión
arquitectónica.

Si para mitigar un riesgo sería necesario cambiar una decisión fundamental de
Milestone 2, registra esa situación para el reviewer.

## Paso 5 — Cronograma

Genera:

```text
design/cronograma.md
```

El cronograma debe reflejar las principales actividades necesarias para llevar
la propuesta arquitectónica hacia implementación.

No pretende ser un plan de proyecto detallado.

Debe permitir visualizar, como mínimo:

* principales fases;
* dependencias relevantes;
* actividades arquitectónicas;
* actividades de implementación importantes;
* mitigaciones que deberían realizarse antes o durante determinadas fases;
* riesgos que podrían afectar el orden de ejecución.

No inventes fechas concretas si el Capstone no las proporciona.

Cuando no exista información suficiente para establecer fechas, utiliza
secuencias o fases en lugar de fechas ficticias.

Por ejemplo:

```text
Fase 1 → Fase 2 → Fase 3
```

en lugar de inventar:

```text
Enero → Febrero → Marzo
```

# Paso 6 — Architecture Reviewer

Una vez generados:

```text
design/milestone-3/tradeoff-matrix.md
design/milestone-3/risk-register.md
design/milestone-3/mitigation-plan.md
design/cronograma.md
```

ejecuta Architecture Reviewer.

Debe auditar:

```text
design/milestone-3/*
design/milestone-2/*
design/adr/*
design/traceability.md
```

### El reviewer debe comprobar:

#### Trade-offs

* ¿Se identificaron los trade-offs realmente importantes?
* ¿Se describen tanto beneficios como costos?
* ¿Los trade-offs corresponden a decisiones reales de Milestone 2?
* ¿Se inventaron alternativas?
* ¿Se están presentando beneficios sin reconocer sus costos?

#### Atributos de calidad

* ¿La arquitectura está siendo evaluada respecto a los atributos de calidad
  relevantes?
* ¿Existe algún atributo crítico que no haya sido considerado?
* ¿Las afirmaciones sobre calidad están respaldadas por decisiones
  arquitectónicas?

#### Riesgos

* ¿Los principales riesgos están identificados?
* ¿La severidad es coherente?
* ¿Existe una diferencia clara entre riesgo y problema actual?
* ¿Existen riesgos importantes sin mitigación?
* ¿Las mitigaciones realmente reducen el riesgo?

#### Consistencia

* ¿Los trade-offs corresponden a la arquitectura de Milestone 2?
* ¿Los riesgos corresponden a componentes, decisiones o dependencias reales?
* ¿El mitigation plan contradice alguna decisión arquitectónica?
* ¿El cronograma refleja las dependencias identificadas?

#### Trazabilidad

* ¿Los principales riesgos pueden relacionarse con decisiones, drivers o
  requisitos?
* ¿Los trade-offs pueden relacionarse con ADRs?
* ¿Existe algún riesgo crítico que no tenga relación con ningún elemento
  arquitectónico identificable?

#### Reapertura de Milestone 2

Determina si algún hallazgo implica que:

> **La arquitectura en sí es el problema.**

Ejemplos conceptuales:

* una decisión fundamental genera un riesgo que no puede mitigarse;
* una arquitectura viola un requisito importante;
* un trade-off aceptado resulta incompatible con un driver crítico;
* una frontera arquitectónica produce una dependencia insostenible;
* una decisión tomada en Milestone 2 resulta incorrecta después de evaluar
  sus consecuencias.

En estos casos NO intentes solucionar el problema directamente dentro de
Milestone 3.

Marca el hallazgo como:

> `REOPEN-M2`

y explica qué parte de Milestone 2 debería reconsiderarse.

## Paso 7 — Revisión de hallazgos

Después del reviewer, clasifica cada hallazgo.

### Caso A — Matriz incompleta

Si el reviewer encuentra:

* trade-off faltante;
* comparación incompleta;
* costo no documentado;
* beneficio no documentado;

vuelve a ejecutar:

```text
architecture-tradeoff
```

utilizando el `review-log.md` como entrada adicional.

NO inventes alternativas nuevas.

### Caso B — Riesgo incompleto

Si el reviewer encuentra:

* riesgo faltante;
* severidad incorrecta;
* mitigación faltante;
* mitigación insuficiente;

vuelve a ejecutar:

```text
architecture-risk
```

utilizando el `review-log.md` como entrada adicional.

Después actualiza el mitigation plan si corresponde.

### Caso C — Problema de diseño

Si el reviewer determina:

> `REOPEN-M2`

NO intentes resolverlo agregando una mitigación superficial.

Reabre **Milestone 2 en modo parcial**.

Esto significa:

1. identificar exactamente qué decisión, bounded context, relación, modelo o
   elemento debe reconsiderarse;
2. volver a ejecutar solamente la parte relevante del diseño;
3. mantener intactos los elementos que no están afectados;
4. actualizar los ADR y diagramas afectados;
5. actualizar la trazabilidad;
6. regresar a Milestone 3.

Después de regresar de Milestone 2:

* vuelve a ejecutar Architecture Tradeoff únicamente para las decisiones que
  cambiaron;
* vuelve a ejecutar Architecture Risk únicamente para los riesgos afectados;
* vuelve a ejecutar Architecture Reviewer.

## No rehacer todo el Milestone

No reinicies Milestone 2 completo cuando el hallazgo sea localizado.

Por ejemplo:

Si el problema está en una decisión sobre comunicación entre dos bounded
contexts, no vuelvas a diseñar:

* todos los bounded contexts;
* todo el modelo de datos;
* todos los diagramas;

a menos que el cambio realmente tenga ese alcance.

## Límite de iteraciones

El gate de Milestone 3 tiene un máximo de **3 iteraciones**.

El flujo esperado es:

```text
             ┌──────────────────────┐
             │ Architecture Tradeoff│
             └──────────┬───────────┘
                        │
                        │ paralelo
                        │
             ┌──────────▼───────────┐
             │   Architecture Risk  │
             └──────────┬───────────┘
                        │
                        ▼
             ┌──────────────────────┐
             │ Architecture Reviewer│
             └──────────┬───────────┘
                        │
                 ¿Hallazgos nuevos?
                   /            \
                 No              Sí
                 │                │
                 ▼                ▼
              Cerrar       Clasificar hallazgo
                              │
               ┌──────────────┼───────────────┐
               │              │               │
             Tradeoff        Risk           REOPEN-M2
               │              │               │
               ▼              ▼               ▼
            corregir       corregir       M2 parcial
               │              │               │
               └──────────────┼───────────────┘
                              │
                              ▼
                           Reviewer
```

Si se alcanza el límite de tres iteraciones y todavía existen hallazgos:

* cierra el gate;
* documenta los hallazgos;
* clasifícalos como:

> **Riesgo conocido, no resuelto.**

No iteres indefinidamente.

## Context

Este Milestone debe construirse exclusivamente a partir de la arquitectura
establecida en Milestone 2.

Las principales fuentes son:

```text
design/milestone-2/
design/adr/
design/diagrams/
design/traceability.md
```

### Relación entre Milestones

El razonamiento debe seguir:

```text
Milestone 1
Problema + Drivers + Requisitos
              ↓
Milestone 2
Decisiones + Arquitectura + Trade-offs iniciales
              ↓
Milestone 3
Trade-offs profundizados + Calidad + Riesgos + Mitigaciones
```

Milestone 3 NO debe convertirse en una segunda oportunidad para diseñar una
arquitectura completamente diferente.

Su propósito es evaluar críticamente la solución seleccionada.

### Regla sobre alternativas

Architecture Tradeoff **nunca puede inventar alternativas nuevas**.

Solo puede trabajar con las alternativas que realmente fueron documentadas en
Milestone 2.

Si no existe una alternativa real descartada:

```text
NO → inventar alternativa
NO → crear alternativa artificial
NO → asumir una alternativa implícita
```

En ese caso:

```text
Milestone 3
      ↓
Reviewer
      ↓
Falta alternativa real
      ↓
REOPEN-M2
```

La corrección corresponde a Milestone 2.

### Regla sobre riesgos

No conviertas cualquier inconveniente en un riesgo crítico.

Distingue:

```text
Problema actual
Riesgo potencial
Restricción
Trade-off
Consecuencia
```

Un riesgo debe representar una situación incierta que podría afectar los
objetivos del sistema.

### Regla sobre mitigaciones

Una mitigación debe estar relacionada con el riesgo que pretende reducir.

Evita propuestas genéricas como:

> "Mejorar la seguridad."

o:

> "Monitorear el sistema."

Explica qué riesgo se reduce y cómo.

### Regla sobre calidad

No afirmes que una arquitectura es:

* escalable;
* resiliente;
* segura;
* mantenible;
* altamente disponible;

simplemente porque utiliza una determinada tecnología o patrón.

Relaciona cada afirmación con una decisión arquitectónica concreta y reconoce
los trade-offs.

### Regla sobre costos

Cuando se evalúen costos:

* no inventes precios;
* no inventes presupuestos;
* no inventes cifras de infraestructura.

Si el Capstone no proporciona información económica suficiente, analiza el
costo de forma cualitativa:

* bajo;
* medio;
* alto;

y explica qué genera ese costo.

### Regla sobre información faltante

Si una evaluación depende de información que no existe en Milestone 1 o
Milestone 2:

* no inventes el dato;
* documenta la incertidumbre;
* determina si corresponde convertirla en un riesgo o mantenerla como supuesto
  pendiente.

## Expected Result

Al finalizar deben existir:

```text
design/
├── milestone-3/
│   ├── tradeoff-matrix.md
│   ├── risk-register.md
│   ├── mitigation-plan.md
│   └── review-log.md
│
└── cronograma.md
```

### `tradeoff-matrix.md`

Debe mostrar los principales trade-offs de la arquitectura seleccionada.

Debe permitir entender:

> qué beneficio obtenemos y qué costo aceptamos.

Debe utilizar únicamente las alternativas documentadas en Milestone 2.

### `risk-register.md`

Debe contener los principales riesgos arquitectónicos identificados.

Cada riesgo debe tener suficiente información para comprender:

* causa;
* impacto;
* probabilidad;
* severidad;
* elemento afectado;
* mitigación;
* riesgo residual.

### `mitigation-plan.md`

Debe mostrar cómo se tratarán los riesgos prioritarios.

Debe existir una relación clara entre:

```text
Riesgo
  ↓
Mitigación
  ↓
Resultado esperado
  ↓
Riesgo residual
```

### `cronograma.md`

Debe presentar una visión de alto nivel de la secuencia de implementación.

Debe mostrar dependencias importantes y actividades relacionadas con la
arquitectura y mitigación de riesgos.

No inventes fechas.

### `review-log.md`

Debe registrar todas las iteraciones del gate.

Para cada iteración documenta:

* hallazgos;
* severidad;
* archivo afectado;
* decisión tomada;
* agente responsable de corregirlo;
* resultado;
* si requirió reabrir Milestone 2.

Si un hallazgo queda abierto después del límite:

```text
Riesgo conocido, no resuelto
```

debe quedar explícitamente registrado.

## Reporte final

Al cerrar el Milestone, entrega un resumen corto indicando:

1. Principales trade-offs identificados.
2. Riesgos de mayor severidad.
3. Principales estrategias de mitigación.
4. Cantidad de iteraciones realizadas.
5. Si fue necesario reabrir Milestone 2.
6. Qué decisiones de Milestone 2 fueron afectadas, si alguna.
7. Qué riesgos conocidos quedaron sin resolver.

No repitas el contenido completo de los archivos.