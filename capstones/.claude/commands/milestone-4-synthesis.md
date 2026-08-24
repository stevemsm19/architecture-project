---
description: Milestone 4 — Síntesis Final y Comunicación. defender → report-writer, produce el único informe final del capstone.
---

# /milestone-4-synthesis

Produce `design/milestone-4/defense-brief.md` y
`documentation/informe-tecnico-final.md` a partir de todo lo generado en
Milestones 1 a 3.

## Pasos

1. Verificá que existan `design/milestone-1/*`, `design/milestone-2/*` y
   `design/milestone-3/*`. Si falta alguno, avisá y detenete — este milestone
   sintetiza, no completa huecos de milestones anteriores.

2. Lanzá **architecture-defender** una sola vez, para que:
   a. Resuelva `knowledge/rubric-questions.md` in situ — cada una de las 30
      preguntas tildada con su respuesta citada debajo, o explícitamente
      dejada sin resolver con la razón.
   b. Produzca `design/milestone-4/defense-brief.md` con las preguntas
      difíciles de la defensa respondidas (o marcadas como
      débiles/pendientes) citando evidencia real.

3. Lanzá **report-writer** una sola vez, después de que el defense-brief
   exista, para que produzca `documentation/informe-tecnico-final.md`.

4. Verificá el resultado con dos lecturas explícitas (ya las hace
   `report-writer`, pero confirmalo): sin referencias al proceso interno de
   agentes/comandos/milestones, y sin texto que repita lo que una tabla o
   diagrama ya explica.

5. Reportá un resumen corto: si el informe quedó completo, cuántas de las 30
   preguntas de `knowledge/rubric-questions.md` quedaron sin resolver,
   cuántas preguntas de la defensa quedaron marcadas como débiles/pendientes,
   y confirmá la ruta final: `documentation/informe-tecnico-final.md`.

## Notas

- Este comando es el único punto donde se toca `documentation/`. Ningún
  comando anterior debe escribir ahí.
- Recordale al usuario que la "reflexión crítica sobre uso de IA" (qué generó
  valor, qué generó ruido, qué corrigió manualmente) y la presentación de
  15-20 minutos son responsabilidad del usuario — ningún agente las genera;
  el `defense-brief.md` es un insumo para prepararlas, no un reemplazo.

