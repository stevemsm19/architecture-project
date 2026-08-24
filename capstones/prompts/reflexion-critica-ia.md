# Reflexión crítica sobre el uso de Inteligencia Artificial

Durante el desarrollo del Capstone utilicé Inteligencia Artificial como una herramienta de apoyo para analizar el problema, estructurar las decisiones arquitectónicas, cuestionar la propuesta y preparar la documentación final. Para esto definí diferentes agentes especializados y posteriormente utilicé cuatro prompts principales, correspondientes a las cuatro etapas del proceso arquitectónico.

El objetivo no fue delegar completamente el diseño en la IA, sino utilizarla para **organizar el razonamiento, identificar posibles omisiones y generar diferentes perspectivas sobre el mismo problema**. La separación de responsabilidades permitió que un agente propusiera decisiones mientras otro pudiera cuestionarlas, evitando depender únicamente de una única respuesta generada por IA.

## Uso de los prompts

| Prompt                               | Propósito                                                                                                       | Valor generado                                                                                                                                                                                                     | Principal limitación                                                                                                                                                           |
| ------------------------------------ | --------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| **Prompt 1 — Descubrimiento**        | Analizar el problema y separar drivers, requisitos, supuestos, restricciones y ambigüedades.                    | Ayudó a transformar un enunciado amplio en elementos concretos que podían utilizarse posteriormente para tomar decisiones. También permitió identificar preguntas que necesitaban validación.                      | Inicialmente existía el riesgo de que la IA interpretara ambigüedades como requisitos o intentara responder preguntas que correspondían a los stakeholders.                    |
| **Prompt 2 — Diseño arquitectónico** | Generar y cuestionar alternativas, decisiones arquitectónicas, bounded contexts, modelo conceptual y diagramas. | Fue fundamental para estructurar el diseño y, especialmente, para obligar a justificar las decisiones en función de los drivers. El reviewer agregó una perspectiva crítica que permitió detectar inconsistencias. | Algunas propuestas podían introducir patrones o componentes porque parecían buenas prácticas, aunque no fueran estrictamente necesarios para el problema.                      |
| **Prompt 3 — Trade-offs y riesgos**  | Evaluar la arquitectura seleccionada, sus costos, trade-offs, riesgos y mitigaciones.                           | Permitió pasar de "esta arquitectura parece adecuada" a explicar qué beneficios se obtienen y qué costos o riesgos se aceptan. También ayudó a preparar escenarios de falla.                                       | Fue necesario controlar que la IA no intentara solucionar todos los riesgos modificando la arquitectura o inventando alternativas que no habían sido consideradas.             |
| **Prompt 4 — Síntesis y defensa**    | Preparar las preguntas de defensa y convertir el trabajo anterior en un informe técnico comprensible.           | Ayudó a identificar debilidades antes de la defensa y a consolidar el trabajo en una narrativa coherente para stakeholders y usuarios técnicos.                                                                    | La IA podía producir respuestas demasiado convincentes incluso cuando la evidencia disponible no era suficiente, por lo que fue necesario revisar críticamente las respuestas. |

## ¿Qué prompt generó mayor valor?

Considero que el **Prompt 2 — Diseño arquitectónico** fue el que generó mayor valor.

La razón principal es que no se limitó a producir una solución, sino que estableció un proceso en el que una propuesta podía ser **planteada, representada y posteriormente cuestionada**. La separación entre `architecture-strategist`, `architecture-modeler` y `architecture-reviewer` fue especialmente útil porque cada uno tenía una responsabilidad diferente: el strategist tomaba las decisiones, el modeler las representaba y el reviewer intentaba encontrar problemas en ellas. El reviewer, además, estaba definido como una voz adversarial que debía buscar contradicciones, sobreingeniería, puntos únicos de falla y decisiones sin trazabilidad.

Esto cambió la forma en la que evalué la arquitectura. En lugar de preguntarme solamente:

> "¿Qué arquitectura podría funcionar?"

también pude preguntarme:

> "¿Por qué esta arquitectura y no otra?"

y posteriormente:

> "¿Qué podría estar mal con esta decisión?"

Considero que esta segunda perspectiva fue una de las mayores contribuciones de la IA al proceso.

## ¿Qué prompt generó más ruido?

El **Prompt 3 — Trade-offs, calidad y riesgos** fue el que requirió mayor control.

El análisis de riesgos puede llevar fácilmente a que una IA intente cubrir todos los escenarios posibles y termine agregando mecanismos, componentes o patrones que aumentan innecesariamente la complejidad. Por esta razón fue necesario establecer límites claros: el agente de riesgos debía identificar y mitigar riesgos, pero no rediseñar unilateralmente la arquitectura; de igual forma, el agente de trade-offs debía utilizar alternativas reales y no inventar nuevas.

Este comportamiento me permitió identificar una característica importante del uso de IA: **una respuesta más completa no necesariamente es una respuesta mejor**. En arquitectura, agregar más mecanismos puede hacer que una solución parezca más robusta, pero también puede introducir complejidad que no está justificada por los requisitos.

Por eso, parte del trabajo consistió en distinguir entre:

* una mejora realmente necesaria;
* una recomendación razonable pero no requerida;
* una sobreingeniería;
* y una propuesta que simplemente sonaba técnicamente bien.

## ¿Qué tuve que corregir manualmente?

La revisión manual fue necesaria principalmente en cuatro aspectos:

| Aspecto                        | Corrección realizada                                                                                                                             |
| ------------------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------ |
| **Supuestos**                  | Revisé que una interpretación de la IA no terminara convirtiéndose automáticamente en un requisito del sistema.                                  |
| **Decisiones arquitectónicas** | Verifiqué que los patrones y componentes propuestos estuvieran relacionados con un driver, requisito o problema real.                            |
| **Riesgos y alternativas**     | Eliminé o cuestioné propuestas que introducían mecanismos innecesarios o alternativas que no estaban realmente justificadas.                     |
| **Informe y defensa**          | Revisé que las respuestas fueran defendibles y que no presentaran como hechos decisiones o información que no estaba suficientemente sustentada. |

Un ejemplo importante fue el tratamiento de las preguntas de stakeholders. El agente de descubrimiento debía identificar las preguntas abiertas, pero **no responderlas por sí mismo**. Esto fue importante porque una IA puede llenar fácilmente un vacío de información con una respuesta que parece razonable. Sin embargo, en un problema real, una suposición razonable no necesariamente representa lo que el stakeholder necesita. 

Algo similar ocurrió durante la preparación de la defensa. El agente `architecture-defender` fue diseñado para dejar una pregunta como débil o sin resolver cuando no existiera evidencia suficiente, en lugar de inventar una respuesta. 

## ¿Qué aprendí del uso de IA?

Uno de los principales aprendizajes fue que **la calidad del resultado depende considerablemente de la calidad de las restricciones dadas a la IA**.

Un prompt genérico como:

> "Diseña una arquitectura para este sistema"

puede generar una respuesta técnicamente atractiva, pero no necesariamente una arquitectura adecuada para el problema.

En cambio, dividir el proceso permitió establecer límites:

```text
Problema
   ↓
Drivers y requisitos
   ↓
Alternativas
   ↓
Decisión
   ↓
Revisión crítica
   ↓
Trade-offs y riesgos
   ↓
Defensa
   ↓
Informe
```

Esto hizo que la IA funcionara más como un **equipo de apoyo al razonamiento arquitectónico** que como un generador automático de una solución.

También aprendí que es importante introducir mecanismos de crítica dentro del propio proceso. El hecho de contar con un agente cuyo objetivo era cuestionar la arquitectura resultó más valioso que utilizar únicamente agentes orientados a generar contenido.

## Valor generado por la IA

De manera general, considero que la IA aportó valor principalmente en cuatro áreas:

**1. Organización del razonamiento**

Permitió convertir una problemática extensa en elementos más manejables y relacionados entre sí.

**2. Exploración**

Ayudó a considerar diferentes alternativas y consecuencias antes de seleccionar una solución.

**3. Crítica**

La revisión adversarial permitió encontrar inconsistencias y decisiones que necesitaban mayor justificación.

**4. Comunicación**

Facilitó transformar el razonamiento arquitectónico en diagramas, tablas, respuestas de defensa y documentación comprensible para diferentes tipos de lectores.

La IA fue especialmente útil para mantener la continuidad entre estas etapas. Por ejemplo, los trade-offs podían utilizar las decisiones tomadas durante el diseño, mientras que la preparación de la defensa podía utilizar los riesgos y decisiones identificados anteriormente. El diseño de los agentes buscaba precisamente mantener esa separación y trazabilidad.

## Conclusión

El uso de Inteligencia Artificial fue útil para acelerar y estructurar el proceso de diseño arquitectónico, pero no sustituyó el criterio necesario para tomar las decisiones finales.

La principal ventaja no estuvo en que la IA pudiera "diseñar la arquitectura", sino en que permitió **obtener diferentes perspectivas sobre el mismo problema**: una perspectiva para descubrir requisitos, otra para proponer decisiones, otra para cuestionarlas, otra para analizar sus riesgos y finalmente otra para preparar su defensa.

Al mismo tiempo, el proceso mostró una limitación importante: la IA puede generar respuestas técnicamente plausibles que no necesariamente están justificadas por el problema. Por esta razón, tuve que revisar manualmente los supuestos, las alternativas, los riesgos y las justificaciones antes de aceptarlos.

En conclusión, considero que la IA generó mayor valor cuando fue utilizada como **herramienta de razonamiento y revisión**, y no simplemente como generador de contenido. El criterio humano siguió siendo necesario para decidir qué propuestas tenían sentido, cuáles introducían complejidad innecesaria y cuáles podían realmente defenderse con la información disponible.

**La IA aceleró el análisis, amplió las perspectivas y ayudó a encontrar problemas, pero la responsabilidad de las decisiones arquitectónicas finales permaneció en mí.**
