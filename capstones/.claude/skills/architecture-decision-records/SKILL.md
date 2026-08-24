---
name: architecture-decision-records
description: Fixed ADR template (context, decision, alternatives considered, consequences) for recording DAS/UPCA capstone architectural decisions. Load this before writing or editing any file under design/adr/.
---

# Plantilla de ADR para este capstone

Cada decisión arquitectónica significativa del capstone (elección de estilo,
sincronía vs. asincronía para el NIS, ownership de datos por bounded context,
estrategia de retención por capas, etc.) se documenta como un ADR en
`design/adr/adr-NNNN-slug.md`, numerado secuencialmente empezando en `0001`.

## Cuándo escribir un ADR

- Cuando `architecture-strategist` elige un estilo arquitectónico entre las
  alternativas que propuso (Milestone 2) → un ADR por decisión de estilo.
- Cuando `architecture-strategist` o `architecture-reviewer` resuelven una
  ambigüedad del enunciado con un supuesto explícito que tiene impacto
  arquitectónico.
- Cuando se decide algo puntual pero consecuente (ej. "usamos idempotency keys
  para las respuestas del NIS", "definimos near real-time como ≤10 segundos").

No hace falta un ADR por cada detalle — solo por decisiones que, si se
revirtieran, obligarían a rediseñar algo.

## Plantilla

```markdown
# ADR-NNNN: <Título en imperativo corto, ej. "Usar procesamiento asíncrono para la verificación NIS">

## Estado
Propuesto | Aceptado | Reemplazado por ADR-XXXX | Rechazado

## Contexto
<Qué problema o fuerza obliga a esta decisión. Citá el `DRV-NN`/`REQ-NN` de
`design/traceability.md` (sembrado en Milestone 1) y el concepto de
`knowledge/` que informa la decisión — ej. "Semana 2 (Integración de
Sistemas): patrones de integración asíncrona".>

## Decisión
<Qué se decidió, en una o dos frases directas y verificables — no ambiguas.>

## Alternativas consideradas
### Alternativa A: <nombre>
- **Pros**: ...
- **Contras**: ...
- **Por qué no se eligió**: ...

### Alternativa B: <nombre>
- ...

## Consecuencias
**Positivas**
- ...

**Negativas / deuda que se acepta**
- ...

**Riesgos que quedan abiertos**
- <Si `architecture-reviewer` o `architecture-risk` ya identificaron riesgos
  relacionados, referencialos acá con su `RISK-NN` y severidad.>

## Referencias
- `knowledge/<weN o index>.md` — <qué concepto respalda esto>
- `design/traceability.md` — <DRV-NN / REQ-NN que origina esto>
- `design/milestone-2/architecture-decision.md` — <si aplica>
```

## Reglas duras

- Todo ADR debe tener al menos una alternativa real considerada y descartada
  — un ADR con una sola opción no es una decisión, es una afirmación.
- La sección "Decisión" debe ser lo suficientemente concreta como para que
  `architecture-reviewer` pueda auditarla contra un escenario de falla
  específico.
- Nunca edites un ADR ya "Aceptado" para cambiar la decisión — creá uno nuevo
  que lo reemplace y marcá el viejo como "Reemplazado por ADR-XXXX".
