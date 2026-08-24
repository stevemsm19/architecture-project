# ADR-0004: Retención de eventos de asistencia por capas (caliente/tibio/frío)

## Estado
Aceptado

## Contexto
Los registros de asistencia deben conservarse un mínimo de 5 años por
requisito legal (**RST-03**, **DRV-04**, **REQ-12**), un horizonte muy
superior al de la operación diaria del sistema. El propio enunciado
contrapone explícitamente este requisito al de near real-time (**DRV-05**)
con la palabra "aunque" (ver `discovery.md`, DRV-05). Los stakeholders
simulados confirman que esta tensión es real pero manejable: las consultas
de años anteriores pueden ser más lentas, siempre que la información
"permanezca disponible cuando sea necesaria" (**ASM-13**); no así las
consultas del día en curso, que sí deben ser rápidas. `knowledge/we6.md` y
`knowledge/we7.md` (Semanas 6-7) establecen Base de Datos por Servicio y
Persistencia Políglota como el mecanismo que habilita, dentro de un mismo
bounded context, distintas estrategias de almacenamiento según el patrón de
acceso de los datos.

## Decisión
El contexto Captura de Asistencia aplica una política de almacenamiento por
niveles sobre la misma entidad `EventoDeAsistencia` (sin duplicar el modelo
de dominio): **caliente** (datos recientes, optimizados para escritura de
alto volumen y consulta de baja latencia — soporta DRV-05 y la ruta
"reciente" de Reportes definida en ADR-0003), **tibio** (datos de meses
recientes, consulta ocasional), **frío** (datos hasta cumplir el mínimo
legal de 5 años, optimizado para costo, consulta admitida con mayor latencia
— soporta ASM-13 y RST-03). La transición entre capas es una política
operativa automatizada, no una decisión manual por evento.

## Alternativas consideradas

### Alternativa A: Un único almacén homogéneo para todo el horizonte de 5 años
- **Pros**: modelo de datos y operación más simples, sin lógica de
  transición entre capas.
- **Contras**: optimizar un único almacén simultáneamente para escritura de
  alto volumen near real-time (DRV-05) y para conservación de bajo costo a
  5 años (DRV-04) obliga a un compromiso que probablemente no satisfaga
  bien a ninguno de los dos extremos; además, el enunciado y ASM-13
  explícitamente permiten (y sugieren aprovechar) una diferencia de
  velocidad entre consulta reciente e histórica que este diseño
  desaprovecharía.
- **Por qué no se eligió**: no aprovecha la señal explícita de los
  stakeholders simulados (ASM-13) de que la velocidad de consulta histórica
  puede sacrificarse a favor de menor costo, y arriesga la latencia de
  escritura/consulta reciente que sí es crítica (DRV-05).

## Consecuencias

**Positivas**
- Cumple RST-03 (retención de 5 años) sin comprometer el SLA de ≤15s p95
  definido en ADR-0003 para la ruta reciente de reportes.
- El costo de almacenamiento a largo plazo se optimiza específicamente para
  el patrón de acceso que ASM-13 confirma que es aceptable (más lento, pero
  siempre disponible).

**Negativas / deuda que se acepta**
- Complejidad operacional adicional: proceso automatizado de transición
  entre capas, y necesidad de que la ruta "histórica" de Reportes (ADR-0003)
  sepa consultar contra el almacén frío con una expectativa de latencia
  distinta.

**Riesgos que quedan abiertos**
- **AMB-04** (alcance exacto de qué datos están sujetos a la retención de 5
  años) sigue abierta: esta política se aplica únicamente a
  `EventoDeAsistencia` (consistente con **ASM-04**), no a los documentos y
  fotos de `SolicitudDeRegistro` — si el instructor confirma que la
  retención de 5 años también aplica a esos datos, este ADR debe
  extenderse o debe crearse uno nuevo específico para esa entidad.

## Referencias
- `knowledge/index.md`, `knowledge/we6.md`, `knowledge/we7.md` — Base de
  Datos por Servicio, Persistencia Políglota.
- `design/traceability.md` — DRV-04, DRV-05, RST-03, REQ-12, ASM-04,
  ASM-13, AMB-04.
- `design/milestone-2/data-model-conceptual.md` — entidad
  `EventoDeAsistencia`.

## Nota de revisión — Milestone 3 (DEC-0013)

`design/adr/adr-0013-monolito-modular-fase1-extraccion-selectiva.md`
(`DEC-0013`) mantiene sin cambios la estrategia conceptual de retención por
capas (caliente/tibio/frío) sobre `EventoDeAsistencia` descrita en este
ADR, como respuesta a **DRV-04**/**RST-03** sin degradar **DRV-05** — la
lógica de transición automatizada entre capas por antigüedad del dato sigue
siendo la decisión vigente.

Lo que cambia en Fase 1 es la realización física de esas capas: en vez de
tres tecnologías de almacenamiento especializadas y físicamente distintas
(ej. persistencia políglota completa, como preveía la Fase 1 original de
`DEC-0001`), el tiering se implementa **dentro de un único motor de base de
datos** del monolito, usando los mecanismos que ese motor ofrezca para
diferenciar el patrón de acceso por antigüedad (ej. particionamiento por
fecha, tablas/particiones de archivo, políticas de compresión o de
almacenamiento en frío del propio motor). Esto es funcionalmente
equivalente para el requisito legal (retención de 5 años + disponibilidad
de consulta, aunque más lenta para históricos, ya aceptado por **ASM-13**),
pero sin la optimización de costo por patrón de acceso que la persistencia
políglota completa habilitaría — exactamente la deuda ya declarada
explícitamente en la sección "Negativas / deuda que se acepta" de
`ADR-0013`.

En Fase 2, si Captura de Asistencia se extrae (trigger de ADR-0013), las
capas caliente/tibio/frío pueden migrar a tecnologías de almacenamiento
físicamente distintas por capa, tal como preveía la versión original de
este ADR.
