**Fecha/hora:** 18 de agosto de 2026  
**Herramienta y versión:** Sonnet 5  
**Prompt para el hito 3:** 


```
# Rol
Eres el mismo arquitecto de software senior de ShopStream que completó los Hitos 1 y 2.
Ahora debes consolidar, verificar la coherencia de, y defender formalmente todas las
decisiones arquitectónicas tomadas hasta ahora, preparando el entregable final del
laboratorio.

# Acción
Completa el Hito 3 del rediseño de ShopStream:
1. Revisa las decisiones de los Hitos 1 y 2 en busca de inconsistencias (nombres de
   servicios, tipos de comunicación, patrones de resiliencia) y corrígelas o señálalas.
2. Refina y produce el diagrama arquitectónico final consolidado.
3. Completa una tabla de decisiones arquitectónicas (formato tipo ADR) que resuma todas
   las decisiones tomadas en los Hitos 1 y 2.
4. Selecciona 2 de los 12 principios de la metodología 12-Factor App y explica cómo
   afectan específicamente al Servicio de Pedidos de ShopStream.
5. Organiza y documenta los prompts de IA utilizados en el laboratorio (Hitos 1, 2 y 3),
   explicando qué aportó cada uno, y agrega una breve reflexión sobre las capacidades/
   limitaciones observadas del modelo/agente usado.
6. Ensambla el documento final consolidado del laboratorio.

# Contexto

## Recordatorio del escenario ShopStream
Eres arquitecto en "ShopStream". El sistema tiene los contextos: Catálogo (información
de productos, inventario y búsqueda), Pedidos (creación de pedidos, precios y ciclo de
vida: Pendiente, Confirmado, Enviado), Clientes (perfiles de usuario, autenticación y
direcciones), y CMS (gestión de contenido enriquecido asociado al catálogo, con equipo
propio distinto al de Catálogo).

## Continuidad con los Hitos 1 y 2
Ya completaste el Hito 1 (descomposición de servicios + decisión BFF/Gateway + diagrama
v1) y el Hito 2 (flujo de "Realizar Pedido" + SAGA + Retry/Circuit Breaker + agregado
Pedido + Context Map Catálogo-CMS) en la misma sesión de trabajo. Usa esos resultados
como fuente primaria de este hito; no inventes decisiones nuevas que no hayan sido
tomadas en los hitos anteriores. Si no cuentas con el resultado exacto de algún hito
anterior en tu contexto actual, indícalo explícitamente al inicio de tu respuesta antes
de continuar con supuestos razonables.

## Conocimiento de referencia: metodología 12-Factor App
12-Factor App es un conjunto de doce principios/buenas prácticas para construir
aplicaciones SaaS modernas, escalables y mantenibles, creado originalmente por
ingenieros de Heroku. Los 12 factores son:
1. **Base de código:** una única base de código rastreada en control de versiones, con
   múltiples despliegues.
2. **Dependencias:** declarar y aislar explícitamente todas las dependencias (no
   depender de paquetes implícitos del sistema).
3. **Configuración:** almacenar la configuración (credenciales, endpoints) en variables
   de entorno, no en el código.
4. **Servicios de respaldo:** tratar bases de datos, colas, cachés, etc. como recursos
   conectados vía configuración, intercambiables sin cambiar código.
5. **Build, release, run:** separar estrictamente la etapa de construcción, la de
   combinación con configuración (release) y la de ejecución.
6. **Procesos:** ejecutar la aplicación como uno o más procesos sin estado (stateless);
   cualquier estado persistente va en un servicio de respaldo con estado.
7. **Vinculación de puertos (Port binding):** el servicio se expone a sí mismo vía
   enlace a un puerto, sin depender de un servidor externo inyectado en tiempo de
   ejecución.
8. **Concurrencia:** escalar horizontalmente vía el modelo de procesos (múltiples
   instancias del proceso), no solo escalando verticalmente un único proceso.
9. **Desechabilidad (Disposability):** maximizar la robustez con arranque rápido y
   apagado elegante (graceful shutdown), permitiendo escalado elástico y despliegues
   resilientes.
10. **Paridad entre desarrollo y producción:** mantener los entornos de desarrollo,
    staging y producción lo más similares posible.
11. **Logs:** tratar los logs como flujos de eventos (event streams), no gestionar
    archivos de log dentro de la propia aplicación.
12. **Procesos de administración (Admin processes):** ejecutar tareas puntuales de
    administración/gestión (migraciones, scripts) como procesos independientes en el
    mismo entorno que los procesos regulares de la app.

Lo importante para este hito no es repetir la definición genérica de cada factor, sino
explicar su **efecto concreto** sobre el Servicio de Pedidos de ShopStream tal como
quedó diseñado en los Hitos 1 y 2 (ej. cómo afecta su capacidad de escalar
horizontalmente, cómo afecta su manejo de configuración/entornos, cómo afecta su
resiliencia ante reinicios, etc.).

## Resultado mínimo exigido para este hito
El Hito 3 se considera completo cuando existan estos 5 entregables:
1. Arquitectura final (diagrama refinado).
2. Tabla de decisiones arquitectónicas.
3. Impacto de 2 principios 12-Factor en el Servicio de Pedidos.
4. Evidencia/reflexión sobre el uso de IA en el laboratorio.
5. Entregable consolidado.

# Expectativa
Entrega un único documento estructurado en exactamente estas 5 secciones, sin narrativa
adicional fuera de lo pedido:

## Sección 1 — Revisión de consistencia y diagrama final
- Tabla: `Elemento verificado | Estado (OK/Inconsistencia) | Resolución aplicada` —
  cubriendo como mínimo: nombres de servicios, capa de entrada (BFF/Gateway), tipo de
  SAGA, ubicación de Retry/Circuit Breaker.
- Diagrama Mermaid final consolidado, integrando: todos los servicios, la capa BFF/
  Gateway, las comunicaciones principales con su patrón de resiliencia anotado (si
  aplica), y el límite del agregado Pedido.
- El diagrama final no debe contradecir ninguna decisión previa que no haya sido
  señalada explícitamente como corregida en la tabla.

## Sección 2 — Tabla de decisiones arquitectónicas
- Tabla: `Decisión | Opciones consideradas | Elección | Justificación | Trade-off
  aceptado` — una fila por cada decisión arquitectónica relevante tomada en los Hitos 1
  y 2 (fronteras de servicio/subdivisión de Pedidos, BFF vs. Gateway, tipo de SAGA,
  ubicación de Retry/Circuit Breaker, patrón de Context Map Catálogo-CMS).
- No incluyas decisiones nuevas que no hayan sido tomadas previamente.

## Sección 3 — Impacto de 12-Factor App en el Servicio de Pedidos
- Tabla: `Factor 12-Factor | Definición breve | Aplicación concreta al Servicio de
  Pedidos de ShopStream` — exactamente 2 filas, con los 2 factores elegidos.
- Cada aplicación debe ser específica del Servicio de Pedidos ya diseñado (no una
  definición genérica sin contexto).

## Sección 4 — Reflexión sobre el uso de IA
- Tabla: `Hito | Qué se le pidió al agente | Qué produjo | Aporte concreto al hito` —
  una fila por cada uno de los 3 hitos ejecutados.
- Reflexión de máximo 5 líneas sobre capacidades/limitaciones observadas del modelo/
  agente durante el laboratorio (ej. dónde necesitó más guía explícita, dónde fue más
  autónomo, calidad de las justificaciones producidas). No repitas literalmente lo ya
  dicho en la tabla.

## Sección 5 — Entregable consolidado
- Un índice/tabla de contenidos de todo el laboratorio, enlazando (con enlaces
  relativos) los documentos generados para cada hito.
- Un resumen ejecutivo de máximo 5 líneas de la arquitectura final de ShopStream.

No agregues secciones adicionales fuera de las 5 anteriores.
```