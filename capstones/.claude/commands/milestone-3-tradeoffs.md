---
description: Milestone 3 — Trade-offs, Calidad y Riesgos. tradeoff + risk en paralelo, luego reviewer; puede reabrir Milestone 2 si el hallazgo es de diseño.
---

# /milestone-3-tradeoffs

Produce `design/milestone-3/` y `design/cronograma.md` a partir de
`design/milestone-2/`.

## Pasos

1. Verificá que `design/milestone-2/architecture-decision.md` exista (con al
   menos una alternativa descartada documentada). Si no, avisá y detenete —
   correr primero `/milestone-2-design`.

2. **Iteración 1**: lanzá **architecture-tradeoff** y **architecture-risk**
   en paralelo — son independientes entre sí, ambos leen
   `design/milestone-2/*` pero no se necesitan mutuamente.

3. Lanzá **architecture-reviewer** (gate de Milestone 3) para auditar
   `design/milestone-3/tradeoff-matrix.md`, `risk-register.md`,
   `mitigation-plan.md` y su consistencia con `design/milestone-2/*`.

4. Si `architecture-reviewer` reporta hallazgos nuevos:
   - Si el hallazgo es "falta mitigación" o "matriz incompleta" → vuelve a
     **architecture-risk** o **architecture-tradeoff** según corresponda.
   - Si el hallazgo es "la arquitectura en sí es la falla" → invocá
     `/milestone-2-design` en modo parcial (solo lo que
     `architecture-reviewer` señaló, no todo el milestone desde cero), y
     al volver, repetí el paso 2 solo para lo que cambió.
   - Repetí hasta `SIN HALLAZGOS NUEVOS` o hasta completar **3 iteraciones**
     del gate de Milestone 3. Al llegar al límite con hallazgos abiertos,
     cerrá igual y reportalos como "riesgo conocido, no resuelto".

5. Al cerrar, confirmá que existan:
   - `design/milestone-3/tradeoff-matrix.md`
   - `design/milestone-3/risk-register.md`
   - `design/milestone-3/mitigation-plan.md`
   - `design/cronograma.md`
   - `design/milestone-3/review-log.md`

6. Reportá un resumen corto: principales trade-offs, riesgos de mayor
   severidad y si algún hallazgo obligó a reabrir Milestone 2.

## Notas

- `architecture-tradeoff` nunca genera alternativas nuevas — si
  `design/milestone-2/architecture-decision.md` no dejó una alternativa
  real descartada, el hallazgo correspondiente vuelve a Milestone 2, no se
  inventa una alternativa de paja acá.
- Recordale al usuario la evidencia de prompting IA de este milestone.
