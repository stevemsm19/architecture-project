# ADR-0011: Retención por defecto (placeholder de diseño) para documentos y fotos de `SolicitudDeRegistro`

## Estado
Aceptado

> Extiende `design/adr/adr-0004-retencion-por-capas.md` (que sigue
> **Aceptado**, sin cambios: la política de capas caliente/tibio/frío
> sigue aplicando únicamente a `EventoDeAsistencia`). Este ADR cubre
> específicamente la entidad que ADR-0004 dejaba explícitamente fuera de
> alcance.

## Contexto
**AMB-04** (alcance de la retención de 5 años) sigue formalmente abierta:
ni el enunciado ni los stakeholders simulados definen el alcance exacto
para `documentoRef`/`fotoRef` de `SolicitudDeRegistro`. `architecture-
reviewer` (Iteración 1) señaló que dejar esto como "ambigüedad abierta" sin
ningún valor por defecto no es un punto neutral: en la práctica significa
que documentos de identidad y fotos sensibles de miles de candidatos
(aprobados y rechazados) se retendrían **indefinidamente**, "el peor
resultado posible para DRV-03 (confidencialidad)" (cita textual del
hallazgo). `knowledge/we6.md`/`we7.md` no cubren normativa de retención
legal (fuera de alcance del curso), pero sí el principio de que los datos
personales sensibles deben minimizarse a su propósito (DRV-03,
confidencialidad).

## Decisión
A falta de una política legal confirmada por UPCA, se fija un **valor de
diseño por defecto**, marcado explícitamente como placeholder operativo
sujeto a validación por el instructor/negocio real:

- `documentoRef` y `fotoRef` de `SolicitudDeRegistro` se retienen un máximo
  de **180 días** después de que la solicitud alcanza un estado terminal
  (`aprobado` o `rechazado`), tras lo cual se purgan/anonimizan
  automáticamente.
- **Excepción**: solicitudes rechazadas y marcadas explícitamente por el
  personal administrativo como sospecha de fraude o irregularidad
  documental se retienen **1 año adicional** para posible auditoría (cifra
  también de diseño, no legal).
- Una vez `aprobado` y creado el `DASID`, la evidencia documental ya no es
  necesaria como fuente de verdad — los datos personales confiables viven
  en `DASID`, no en `SolicitudDeRegistro` (ya establecido en
  `data-model-conceptual.md`), por lo que la purga de la solicitud no
  afecta la operación del sistema.

**Se marca explícitamente como "Supuesto de diseño — requiere validación
con el instructor/negocio real"**: 180 días y 1 año no son cifras del
enunciado ni de `knowledge/`, son una decisión operativa de placeholder
para evitar el peor resultado (retención indefinida de facto) mientras
AMB-04 se resuelve formalmente.

## Alternativas consideradas

### Alternativa A: Retención indefinida por defecto (statu quo implícito)
- **Por qué no se eligió**: es exactamente el resultado que el hallazgo del
  reviewer identifica como "el peor resultado posible para DRV-03" — dejar
  la ambigüedad abierta sin valor por defecto equivale, en la práctica, a
  esta alternativa.

### Alternativa B: Purga inmediata al llegar a estado terminal (0 días)
- **Contras**: elimina toda posibilidad de auditoría o apelación de un
  rechazo reciente, lo cual podría ser operacionalmente necesario aunque no
  esté confirmado por el enunciado.
- **Por qué no se eligió**: es un extremo tan arbitrario como la retención
  indefinida, solo que en la dirección opuesta — no hay señal de los
  stakeholders simulados que respalde 0 días tampoco.

## Consecuencias

**Positivas**
- Cierra el hallazgo de "retención indefinida de facto" con un valor
  operable mientras se valida la política real.
- Reduce la ventana de exposición de datos sensibles (DRV-03) sin eliminar
  por completo la capacidad de auditoría de corto plazo.

**Negativas / deuda que se acepta**
- 180 días y 1 año son cifras sin respaldo legal confirmado — deben
  tratarse como supuesto operativo, no como cumplimiento normativo
  certificado.
- AMB-04 permanece formalmente abierta en `design/traceability.md`: este
  ADR no la resuelve, le da un valor operable transitorio.

**Riesgos que quedan abiertos**
- Si el instructor o una política legal real de UPCA exige un plazo
  distinto (mayor o menor), este ADR debe revisarse — se deja constancia
  explícita de que 180 días/1 año son un placeholder, no un hallazgo
  validado.

## Referencias
- `design/traceability.md` — DRV-03, DRV-04, AMB-04.
- `design/adr/adr-0004-retencion-por-capas.md` — política de retención de
  `EventoDeAsistencia`, no modificada por este ADR.
- `design/milestone-2/data-model-conceptual.md` — entidad
  `SolicitudDeRegistro`, campos `documentoRef`/`fotoRef`.
- `design/milestone-2/review-log.md` — Iteración 1, hallazgo "AMB-04
  abierta sin política por defecto".
