---
description: Milestone 1 — Descubrimiento Arquitectónico. Convierte el enunciado del capstone en drivers, requisitos y supuestos priorizados y trazables.
---

# /milestone-1-discovery

Produce `design/milestone-1/` desde cero a partir de `context/capstone.pdf` y
`knowledge/index.md`.

## Pasos

1. Verificá que `knowledge/index.md` exista (correr `/extract-material`
   primero si no). Si no existe, avisá y detenete.

2. Lanzá el subagente **architecture-discovery** una sola vez. No hay nada que
   paralelizar en este milestone — es un único análisis coherente del
   problema completo.

3. Al terminar, revisá que existan:
   - `design/milestone-1/discovery.md`
   - `design/milestone-1/priorizacion.md`
   - `design/traceability.md` (sembrado con `DRV`/`REQ`/`ASM`/`AMB`)

4. Reportá un resumen corto: cuántos drivers, requisitos, supuestos y
   ambigüedades se identificaron, y **listá explícitamente las preguntas a
   stakeholders simulados que quedaron sin respuesta** — son para que el
   usuario las responda antes de avanzar a Milestone 2, no para que un agente
   las conteste.

## Notas

- Este milestone no propone ni insinúa arquitectura. Si el resultado de
  `architecture-discovery` menciona un estilo, patrón o tecnología, es un
  error de scope — pedile que lo saque.
- Recordale al usuario, al cerrar, que la "evidencia de prompting IA" que pide
  este milestone (prompt usado, evaluación crítica, refinamiento) es un
  registro que el usuario completa a mano — ningún agente la genera por él.
- Este comando puede volver a correrse si `context/capstone.pdf` cambia;
  vuelve a sobreescribir `design/milestone-1/*`. Si ya hay Milestones
  posteriores construidos sobre la versión anterior, avisá que van a quedar
  desactualizados.
