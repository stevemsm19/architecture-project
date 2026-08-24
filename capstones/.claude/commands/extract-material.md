---
description: Extrae la base de conocimiento del curso a partir de material/we1.pdf..we7.pdf
---

# /extract-material

Construye o reconstruye `knowledge/` desde cero a partir de `material/`.

## Pasos

1. Verificá con Glob qué archivos `material/we*.pdf` existen realmente (podrían
   no ser exactamente we1..we7). Para cada uno encontrado (`material/weN.pdf`),
   lanzá el subagente **material-curator-final** indicándole explícitamente:
   - Archivo fuente: `material/weN.pdf`.
   - Archivo de salida: `knowledge/weN.md`.
   - Contexto adicional: que el archivo de salida debe reflejar fielmente los
     temas, conceptos y patrones abordados en ese documento puntual — esto es
     simplemente el propósito del archivo (vos, el comando, ya sabés que cada
     `knowledge/weN.md` es el registro de qué se trató en su `material/weN.pdf`
     correspondiente), no información sobre ningún proyecto.

   El agente es genérico y no sabe nada de este proyecto ni de semanas de
   curso — sos vos, el comando, quien conoce el mapeo `material/` ↔
   `knowledge/` y quien se lo pasás explícitamente en cada invocación. No le
   des al agente contexto sobre el capstone, DAS/UPCA, ni sobre para qué se va
   a usar `knowledge/weN.md` después: su única tarea es curar fielmente ese
   documento.

   Lanzá **todas estas invocaciones en paralelo**, una por documento, ya que
   son independientes entre sí y cada una escribe solo su propio
   `knowledge/weN.md`.

2. Esperá a que las 7 (o las que existan) terminen.

3. Lanzá el subagente **synthesizer** una sola vez, después de que todos los
   `knowledge/weN.md` estén escritos, para que produzca `knowledge/index.md`.

4. Al terminar, reportá un resumen corto: cuántas semanas se procesaron, si
   alguna falló o quedó incompleta, y confirmá que `knowledge/index.md`existen.

## Notas

- Si `material/we6.pdf` u otro archivo es demasiado grande para que
  material-curator-final lo lea de una sola vez, el propio agente debe leerlo
  por rangos de páginas — no es motivo para saltarlo.
- No inventes contenido de una semana faltante. Si un PDF no existe, avisá y
  seguí con el resto.
- Este comando puede volver a correrse cuando cambie el contenido de
  `material/` — vuelve a sobreescribir los `knowledge/weN.md` afectados y
  siempre re-corre `synthesizer` al final.
