---
description: Milestone 2 — Diseño Arquitectónico Base. Orquesta strategist ↔ modeler ↔ reviewer hasta que el gate no arroje hallazgos nuevos.
---

# /milestone-2-design

Produce `design/milestone-2/`, `design/adr/` y `design/diagrams/` a partir de
`design/milestone-1/`.

## Pasos

1. Verificá que `design/milestone-1/discovery.md` exista. Si no, avisá y
   detenete — correr primero `/milestone-1-discovery`.

2. **Iteración 1**:
   a. Lanzá **architecture-strategist** para que proponga al menos dos
   alternativas y recomiende una, con ADR, bounded contexts y modelo de
   datos conceptual.
   b. Lanzá **architecture-modeler** para que dibuje la alternativa
   recomendada.
   c. Lanzá **architecture-reviewer** (gate de Milestone 2) para que audite
   `design/milestone-2/*`, los ADRs, los diagramas y `design/traceability.md`.

3. Si `architecture-reviewer` reporta hallazgos nuevos:
   - Si el hallazgo es de estructura/decisión → volvé a lanzar
     **architecture-strategist** con el `review-log.md` como input, luego
     **architecture-modeler** solo si la estructura cambió, luego
     **architecture-reviewer** de nuevo.
   - Repetí hasta `SIN HALLAZGOS NUEVOS` o hasta completar **3 iteraciones**.
   - Si se llega a la iteración 2 con hallazgos abiertos, cerrá el gate
     igual y reportalos como "riesgo conocido, no resuelto" — no iteres
     indefinidamente.

4. Al cerrar, confirmá que existan:
   - `design/milestone-2/architecture-decision.md`
   - `design/adr/adr-NNNN-*.md` (al menos uno)
   - `design/milestone-2/bounded-contexts.md`
   - `design/milestone-2/data-model-conceptual.md`
   - `design/diagrams/*.mmd` + `NOTES.md`
   - `design/milestone-2/review-log.md`

5. Reportá un resumen corto: qué estilo se recomendó, qué alternativa(s) se
   descartaron, cuántas iteraciones del gate hicieron falta, y si quedó algún
   hallazgo abierto sin resolver.

## Notas

- No fuerces que `architecture-modeler` redibuje si `architecture-strategist`
  solo cambió texto de justificación, no estructura.
- Recordale al usuario la evidencia de prompting IA de este milestone (prompt
  para generar esqueleto de diagramas, prompt para comparar estilos,
  evaluación crítica) — la completa el usuario, no un agente.
