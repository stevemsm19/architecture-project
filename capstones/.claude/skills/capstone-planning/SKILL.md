---
name: capstone-planning
description: Fixed schedule format with milestones and risk management, aligned to plan/milestones.pdf's 4 course milestones. Load this before writing or editing design/cronograma.md.
---

# Formato de cronograma y gestión de riesgos

`plan/milestones.pdf` sugiere organizar el capstone en 4 milestones. Esta skill
fija el formato único en el que ese plan se documenta en `design/cronograma.md`,
para que sea consistente sin importar qué agente lo actualice.

## Estructura de `design/cronograma.md`

```markdown
# Cronograma del Capstone DAS/UPCA

## Tabla de Milestones

| # | Milestone | Objetivo cognitivo | Entregables | Fecha objetivo | Estado |
|---|---|---|---|---|---|
| 1 | Descubrimiento Arquitectónico | Pasar de un enunciado ambiguo a drivers priorizados | Documento 3-5 páginas + tabla de priorización + evidencia de prompting IA | ... | Pendiente/En curso/Hecho |
| 2 | Diseño Arquitectónico Base | Transformar drivers en estructura concreta | Estilo justificado + C4 N1-N3 + bounded contexts + ADRs + evidencia IA | ... | ... |
| 3 | Trade-offs, Calidad y Riesgos | Demostrar madurez arquitectónica (justificar, no diseñar) | Trade-off analysis + riesgos técnicos + plan de mitigación + cronograma con hitos arquitectónicos | ... | ... |
| 4 | Síntesis Final y Comunicación | Apropiación intelectual y defensa del diseño | Documento final integrado + presentación 15-20 min + reflexión crítica sobre IA | ... | ... |

## Hitos arquitectónicos específicos (de Milestone 3)

| Hito | Descripción | Depende de | Fecha objetivo | Estado |
|---|---|---|---|---|
| Spike técnico NIS | Prototipo o prueba de concepto de la integración con el NIS | Decisión arquitectónica (design/milestone-2/architecture-decision.md) | ... | ... |
| Diseño validado | Arquitectura auditada sin hallazgos abiertos de severidad alta | Gate de architecture-reviewer sin hallazgos nuevos (M2 y M3) | ... | ... |
| Modelo de datos estable | Modelo de datos conceptual congelado, incluyendo estrategia de retención por capas | Milestone 2 | ... | ... |
| Prototipo de captura | Validación del flujo de check-in/check-out (real o simulado) | Diseño validado | ... | ... |

## Registro de Riesgos

Esta tabla resume `design/milestone-3/risk-register.md` — no lo dupliques
entero acá, solo referencialo:

| Riesgo | Probabilidad | Impacto | Estrategia de mitigación | Referencia |
|---|---|---|---|---|
| Integración con NIS más lenta/inestable de lo esperado | ... | ... | ... | RISK-NN |
| Dispositivos DAS offline pierden/duplican/desordenan eventos | ... | ... | ... | RISK-NN |
| Protección de datos personales insuficiente | ... | ... | ... | RISK-NN |
| Escalamiento a 10k-15k usuarios nuevos no soportado | ... | ... | ... | RISK-NN |
| <otros riesgos de design/milestone-3/risk-register.md> | ... | ... | ... | RISK-NN |
```

## Reglas duras

- Las 4 filas de la tabla de Milestones son fijas — no agregues ni quites
  milestones, solo actualizás fechas/estado/entregables a medida que el
  proyecto avanza.
- Los 4 hitos arquitectónicos específicos vienen literalmente de
  `plan/milestones.pdf` (Milestone 3) — no los renombres.
- Cada fila del Registro de Riesgos debe referenciar el `RISK-NN` de
  `design/milestone-3/risk-register.md` donde se documentó, no duplicar el
  texto completo del hallazgo.
- Las fechas objetivo son responsabilidad del estudiante/usuario — si no se
  proveen, dejá la celda como `<pendiente de definir por el estudiante>` en
  vez de inventar una fecha.
- Este archivo lo mantiene `architecture-risk` (Milestone 3), no cualquier
  agente.
