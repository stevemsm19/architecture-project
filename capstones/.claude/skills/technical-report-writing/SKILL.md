---
name: technical-report-writing
description: Reglas de estilo y redacción para el informe técnico final del capstone DAS/UPCA — tono natural de estudiante avanzado, estructura problema→causa→impacto→alternativa→decisión→justificación, sin relleno académico. Cargar antes de escribir o editar el informe técnico final.
---

El estilo debe ser técnico, pero natural y fácil de entender. No quiero que el documento parezca un paper académico ni una recopilación de definiciones. Debe sentirse como un informe elaborado por un estudiante avanzado de Ingeniería de Software que entiende los conceptos y explica sus decisiones de manera clara.

Ten en cuenta las siguientes reglas:

1. Explica primero el problema y después la solución. Cuando presentes una decisión arquitectónica, sigue preferiblemente esta estructura:
    problema → causa → impacto → alternativa → decisión → justificación.

2. Utiliza lenguaje técnico cuando sea necesario, pero explica los conceptos de forma sencilla. No utilices palabras excesivamente académicas solo para hacer que el texto parezca más formal.

3. Evita frases genéricas que no aporten información, como:
    "durante el análisis se discutió...",
    "como se mencionó anteriormente...",
    "cabe destacar que...",
    "en virtud de lo anterior...",
    o cualquier otra frase que solo sirva para rellenar.

4. No repitas la misma idea varias veces. Si un concepto ya fue explicado, continúa con el análisis en lugar de volver a definirlo.

5. Profundiza en las decisiones técnicas. No te limites a decir qué tecnología, patrón o arquitectura se propone. Explica por qué se selecciona, qué problema resuelve, qué ventajas tiene, qué desventajas introduce y qué trade-offs existen.

6. Relaciona siempre que sea posible los conceptos con el sistema analizado. Evita explicaciones completamente genéricas. Por ejemplo, en lugar de explicar únicamente qué es Database per Service, explica cómo se aplicaría al servicio de órdenes, inventario o pagos del sistema.

7. Utiliza tablas cuando permitan comparar alternativas, resumir responsabilidades, métricas, componentes, ventajas/desventajas o decisiones arquitectónicas. No agregues tablas artificialmente: deben aportar información que sea más clara en formato tabular.

8. Después de una tabla importante, explica las conclusiones relevantes en texto. La tabla debe resumir y el texto debe justificar.

9. Utiliza primera persona del singular únicamente cuando corresponda expresar una decisión, propuesta o reflexión del autor. Por ejemplo:
    "Propongo utilizar..."
    "Considero que..."
    "En este caso, seleccionaría..."

    Para describir conceptos técnicos o comportamientos del sistema, utiliza una redacción impersonal o directa:
    "El servicio de inventario es responsable de..."
    "Esta decisión permite..."

10. Utiliza ejemplos concretos del sistema para explicar conceptos abstractos.

11. Cada sección debe tener un propósito claro y responder una pregunta concreta. Evita párrafos que simplemente describan información sin llegar a una conclusión.

12. Cuando una sección implique una decisión arquitectónica, termina dejando clara la conclusión y la razón principal de la decisión.

13. Mantén una redacción directa. Prefiero frases relativamente cortas y bien conectadas antes que párrafos excesivamente largos.

14. No agregues conceptos, tecnologías, patrones o decisiones que no estén sustentados por el contenido original. Si el documento necesita más profundidad, desarrolla mejor las ideas existentes en lugar de inventar información.

15. No menciones el proceso de redacción, las discusiones previas, versiones anteriores ni que "se decidió durante el análisis", a menos que eso sea técnicamente relevante para el documento.

16. El resultado final debe sentirse como un informe técnico coherente, no como una respuesta de ChatGPT. Evita introducciones genéricas y conclusiones repetitivas.

Como regla general, busca este tipo de redacción:

"El problema principal es X. Esto ocurre porque Y, lo que genera Z. Para reducir este problema se propone A. Esta alternativa permite B, aunque introduce C. Considerando que el sistema necesita D, considero que A es la opción más adecuada."

Prioriza siempre:
claridad > profundidad > naturalidad > formalidad excesiva.
