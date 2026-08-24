# Capstone — Arquitectura de Software 3 (SAR-300)

## Qué es este repo

Proyecto final individual del curso **Arquitectura de Software 3** (Jala University,
SAR-300). El objetivo del curso no es implementar código: es **demostrar pensamiento
arquitectónico bajo incertidumbre real** — identificar drivers, tomar decisiones,
justificarlas contra trade-offs, y defenderlas. La implementación es opcional.

### El sistema a diseñar: DAS (Digital Attendance System) para UPCA

La Universidad Panamericana de Ciencias Aplicadas (UPCA) — 10 ciudades, 20 campus,
~5.000 estudiantes, ~400 profesores, ~3 clases/día — necesita un sistema de asistencia
digital con estas piezas funcionales:

- **DAS ID**: identificador único por usuario (estudiante o profesor).
- **Autorregistro**: app móvil, sube documento + foto + datos personales →
  verificación asíncrona con el **NIS** (Servicio de Identificación Nacional, API
  externa) que **puede tardar hasta 2 horas** → aprobación adicional del personal
  administrativo.
- **Insignia DAS**: credencial (física o en móvil) emitida tras la verificación.
- **Captura de asistencia**: dispositivos DAS en cada campus escanean la insignia
  para registrar entrada/salida por usuario, día y ubicación.
- **Portal administrativo web**: reportes y estadísticas de asistencia para el
  personal de la universidad.
- **App móvil**: los usuarios consultan su propio estado de asistencia.

### Requisitos no funcionales clave (de `context/capstone.pdf`)

Estos son los drivers que **deben** condicionar cualquier decisión de arquitectura:

1. **Escalabilidad y rendimiento** — de ~5.000 a ~15.000 usuarios en los próximos
   2 años (10.000 nuevos), manteniendo rendimiento eficiente. 20 campus en 10 ciudades.
2. **Asistencia casi en tiempo real ("near real-time")** — el registro de
   entrada/salida debe ser lo más cercano posible al tiempo real. El enunciado
   deliberadamente no dice cuántos segundos: es una decisión de diseño a definir y
   justificar, no un dato dado.
3. **Retención de 5 años** — los registros de asistencia deben conservarse un
   mínimo de 5 años por requisito legal. No se asume que deban vivir todo ese
   tiempo en el mismo tipo de almacenamiento "caliente".
4. **Confidencialidad y seguridad** — los datos del DAS (identidad, foto,
   asistencia) deben ser confidenciales y seguros; hay datos personales sensibles
   en múltiples partes del sistema.
5. **Integración asíncrona con el NIS** — latencia de hasta 2h, es una API externa
   fuera de nuestro control: implica estados intermedios, reintentos, idempotencia.

Estos cinco puntos + la lista de `Architectural Drivers` sugerida en
`plan/milestones.pdf` (Escalabilidad, Integración asíncrona con NIS, Seguridad y
confidencialidad, Retención 5 años, Near real-time attendance) son el punto de
partida esperado — no el resultado; el Milestone 1 del curso pide justificar
*por qué estos y no otros*.

## Mapa de carpetas

```
context/capstone.pdf          Enunciado y requisitos originales del sistema DAS/UPCA
documentation/questions.md    30 preguntas que el estudiante debe poder responder al final
documentation/recomendation-informe-final.md   Reglas de contenido/narrativa para el informe final
documentation/informe-tecnico-final.md   Informe final entregable (se genera con /milestone-4-synthesis)
material/we1.pdf … we7.pdf    Slides de las 7 semanas de clases magistrales del curso
plan/milestones.pdf           Los 4 Milestones oficiales del capstone
plan/estrategia-agentes-capstone.md   Diseño del pipeline de agentes de esta fase (Milestones 1-4)

knowledge/                    Base de conocimiento CURADA — ver regla de oro abajo
  weN.md                      Conceptos/patrones/definiciones de la semana N (generado
                               por el agente genérico material-curator-final, uno por
                               PDF de material/, invocado por /extract-material)
  index.md                    Síntesis transversal de todas las semanas (generado por
                               el agente synthesizer)
  rubric-questions.md         Las 30 preguntas de documentation/questions.md
                               reestructuradas como checklist verificable por categoría

design/                       Se genera durante el flujo de comandos de milestones
  traceability.md               Registro de trazabilidad DRV→REQ→DEC→TO→RISK (dueño:
                                 architecture-discovery, auditor: architecture-reviewer)
  milestone-1/discovery.md      Problema, brechas, supuestos, drivers (Milestone 1)
  milestone-1/priorizacion.md   Tabla de priorización de requisitos (Milestone 1)
  milestone-2/architecture-decision.md   Estilo elegido + alternativa(s) descartada(s)
  milestone-2/bounded-contexts.md, data-model-conceptual.md, review-log.md
  adr/adr-NNNN-*.md             Decisiones arquitectónicas (architecture-strategist)
  diagrams/*.mmd + NOTES.md     Diagramas C4 y de secuencia en Mermaid (architecture-modeler)
  milestone-3/tradeoff-matrix.md, risk-register.md, mitigation-plan.md, review-log.md
  cronograma.md                 Cronograma de hitos + gestión de riesgos (architecture-risk)
  milestone-4/defense-brief.md  Preguntas difíciles respondidas con evidencia (architecture-defender)

.claude/agents/                Subagentes especializados del flujo de trabajo
.claude/skills/                Convenciones reutilizables (diagramas, ADRs, planning, estilo de informe)
.claude/commands/               Comandos que orquestan los agentes en el orden correcto
```

## Regla de oro: todo diseño se justifica con `knowledge/`, nunca con conocimiento genérico

Este curso evalúa si el estudiante puede razonar **con las herramientas que el curso
dio**, no con "mejores prácticas" genéricas de internet. Por eso:

- Cualquier agente que proponga, dibuje o evalúe arquitectura
  (`architecture-strategist`, `architecture-modeler`, `architecture-tradeoff`,
  `architecture-risk`, `architecture-reviewer`) **debe fundamentar cada
  decisión, patrón o término citando un concepto presente en
  `knowledge/weN.md` o `knowledge/index.md`** (ej. "Semana 5 (MSA I): bounded
  contexts").
- Si una decisión requiere un concepto que el curso no cubrió, el agente debe
  **decirlo explícitamente** como supuesto fuera del curso a validar con el
  instructor — nunca insertarlo en silencio como si fuera parte del material.
- `context/capstone.pdf` y `documentation/questions.md` son fuentes válidas para
  entender el *problema*, pero no para justificar *soluciones* — las soluciones
  (patrones, estilos, tácticas) deben salir de `knowledge/`.
- `knowledge/` solo existe después de correr `/extract-material`. Si está vacío,
  ejecutá ese comando primero — no se debe diseñar arquitectura sin base de
  conocimiento curada.

## Flujo de trabajo

Ver `.claude/commands/`. Dos fases distintas:

1. **Extracción de conocimiento** (una sola vez, o cuando cambie `material/`):
   `/extract-material`.
2. **Diseño arquitectónico**, alineado 1:1 a los 4 Milestones oficiales de
   `plan/milestones.pdf` — ver `plan/estrategia-agentes-capstone.md` para el
   diseño completo del pipeline (agentes, artefactos, ciclos de revisión):
   `/milestone-1-discovery` → `/milestone-2-design` (loop interno
   strategist↔modeler↔reviewer) → `/milestone-3-tradeoffs` (loop interno
   tradeoff/risk↔reviewer, puede reabrir Milestone 2) → `/milestone-4-synthesis`.

`/milestone-4-synthesis` es el último paso: redacta
`documentation/informe-tecnico-final.md` a partir de los artefactos de los 4
Milestones (arquitectura elegida y alternativa descartada, ADRs, diagramas,
trade-offs, riesgos, defensa preparada) y del enunciado original. El informe
se lee como si el estudiante lo hubiera escrito de principio a fin — nunca
menciona el proceso interno de trabajo con agentes, skills, comandos o
milestones.

Dos piezas de cada milestone son responsabilidad del usuario, no de ningún
agente: las respuestas a las preguntas de stakeholders simulados (Milestone 1)
y la evidencia/reflexión crítica sobre el uso de IA (todos los milestones,
especialmente el 4).
