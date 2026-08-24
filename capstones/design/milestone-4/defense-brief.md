# Defense Brief — DAS/UPCA

> Preguntas de defensa oral/escrita, más allá del checklist de
> `knowledge/rubric-questions.md`. Cada respuesta se sostiene en lenguaje
> directo, sin abreviaciones de ID ni citas a archivos — está pensada para
> leerse una vez y quedarse con la idea central, no para auditar referencias.
> El estado (Sólida / Débil-pendiente) es la única etiqueta que se conserva.
>
> Nota de estado general: el sistema arranca como un monolito modular
> organizado por los mismos cinco límites de dominio del diseño original
> (identidad y credenciales, registro y verificación, captura de asistencia,
> reportes, notificaciones), con la autenticación resuelta por un componente
> transversal dentro del propio proceso — no por una puerta de enlace
> separada. La versión distribuida con servicios independientes y un
> intermediario de eventos sigue siendo el destino lógico del sistema, pero
> se despliega recién cuando la evidencia real de carga lo justifique.

## ¿Cuáles fueron los principales architectural drivers?

**Respuesta**: Cuatro condicionaron la mayoría de las decisiones
estructurales: que la verificación de identidad con un servicio externo
puede tardar hasta dos horas y no está bajo control de la universidad; que
los datos del sistema (identidad, foto, asistencia) deben ser
confidenciales y seguros; que los registros de asistencia deben conservarse
un mínimo de cinco años por ley; y que el registro de entrada/salida debe
sentirse casi en tiempo real. El crecimiento de usuarios en dos años
también pesa, pero se resuelve en conjunto con la necesidad de separar la
escritura de asistencia de la lectura de reportes, no como un eje
independiente.
**Estado**: Sólida

## ¿Por qué esta arquitectura y no un monolito modular?

**Respuesta**: En realidad la pregunta se responde casi al revés: la
arquitectura elegida para el día uno **es** un monolito modular, organizado
por los mismos cinco límites de dominio que tendría la versión distribuida.
Se eligió así porque el proyecto lo desarrolla una sola persona, y operar
desde el primer día cinco servicios independientes, un intermediario de
eventos, un motor de proceso de larga duración, una puerta de enlace y dos
capas de agregación de clientes fue evaluado como el riesgo más severo de
todo el análisis — el único con probabilidad e impacto altos a la vez. El
diseño distribuido no se descarta: queda como el destino lógico del sistema
y se activa por partes, solo cuando hay evidencia real (no una estimación)
de que un módulo concreto lo necesita.
**Estado**: Sólida

## ¿Por qué no microservicios (si no se eligieron)?

**Respuesta**: No se eligieron para el día uno porque automatizar el
despliegue de cinco servicios no reduce la complejidad cognitiva que una
sola persona debe diseñar, entender y depurar simultáneamente — sería
resolver la fricción operativa sin resolver la causa real (el número de
piezas independientes). En cambio, sí se definieron condiciones concretas y
verificables para extraer un módulo a servicio independiente más adelante:
por ejemplo, si la cantidad de campus activos supera la mitad del objetivo
final de la red, o si se mide una degradación real de la latencia de
lectura de reportes en dos ventanas de carga pico consecutivas. El único
módulo con ese camino de extracción ya bien definido es el de captura de
asistencia, por tener el perfil de carga más distinto de todo el sistema.
**Estado**: Sólida

## ¿Qué pasa si el NIS falla?

**Respuesta**: Mientras dura la falla, cada solicitud de registro queda en
un estado visible de espera; si un ciclo de consulta se agota sin
respuesta, se alerta al personal administrativo, se notifica la demora al
usuario y se reintenta con espera creciente entre intentos. Tras un número
máximo de ciclos, la solicitud pasa a un estado de escalamiento manual que
exige revisión humana en vez de seguir esperando indefinidamente. Lo que
**no** está resuelto con el mismo nivel de detalle es qué pasa una vez que
una solicitud ya está en ese estado de escalamiento manual: no hay un plazo
ni una alerta de seguimiento si nadie la atiende, queda enteramente a
criterio operativo humano.
**Estado**: Sólida (con un matiz débil señalado explícitamente en el propio
registro de riesgos, sobre el seguimiento de la cola de revisión manual)

## ¿Qué pasa si un dispositivo queda offline?

**Respuesta**: El dispositivo sigue validando escaneos contra su copia
local de credenciales y guarda cada evento en un buffer local, marcado
explícitamente como capturado fuera de línea. Al recuperar conectividad,
sincroniza ese buffer por lote, con una clave que combina dispositivo,
dirección del evento y marca de tiempo para evitar duplicados. Si el
dispositivo directamente no funciona, existe un canal de registro manual
desde la aplicación para que el profesor registre la asistencia. Lo que
queda débil es qué pasa si la desconexión dura mucho tiempo (días, no
minutos): el buffer no tiene definido un tamaño máximo ni una política de
descarte, y tampoco hay una regla de ordenamiento para eventos que lleguen
fuera de orden al sincronizarse.
**Estado**: Sólida para el mecanismo general; Débil-pendiente para
desconexiones prolongadas y para el orden de eventos al reconectar

## ¿Quién es owner de los datos?

**Respuesta**: Cada uno de los cinco módulos es dueño exclusivo de su
propio dato de origen: identidad y credenciales del identificador único del
usuario y de su credencial; registro y verificación de la solicitud
mientras está en trámite; captura de asistencia de cada evento de
entrada/salida. Reportes solo tiene vistas derivadas —nunca la fuente— y
notificaciones solo su propio registro operativo de envíos. Ningún módulo
escribe directamente sobre los datos de otro, ni siquiera en esta primera
fase donde todos comparten el mismo motor de base de datos: cada uno tiene
su propio esquema lógico, y el acceso cruzado siempre pasa por la interfaz
o los eventos que ese dueño expone.
**Estado**: Sólida

## ¿Qué ocurre si una interfaz cambia?

**Respuesta**: Depende de cuál. Si cambia el contrato del servicio externo
de identificación nacional, el impacto se confina casi por completo a la
capa que lo traduce al modelo interno del sistema — el resto de los módulos
consume estados y eventos ya traducidos, no el contrato externo
directamente, así que no deberían necesitar cambios. Si cambia una interfaz
interna entre dos módulos del monolito (por ejemplo, cómo captura de
asistencia consulta la vigencia de una credencial), hoy ese cambio se
resuelve dentro del mismo proceso sin coordinación de despliegue entre
equipos distintos — pero eso también significa que, si en el futuro ese
módulo se extrae como servicio independiente, esa misma interfaz interna
tendrá que renegociarse como un contrato de red real, con todo lo que eso
implica (versionado, compatibilidad hacia atrás, disponibilidad
independiente).
**Estado**: Sólida

## ¿Qué componente sería el cuello de botella?

**Respuesta**: En el volumen proyectado a dos años (hasta unos 15.000
usuarios), el cálculo de carga pico disponible no muestra ningún cuello de
botella real — el pico estimado de eventos de asistencia por segundo queda
cómodamente dentro de lo que puede sostener una sola instancia bien
diseñada. El punto más probable de contención, si el sistema creciera más
rápido de lo estimado, es el mismo motor de base de datos compartido entre
la escritura de eventos de asistencia y la lectura de reportes — es
exactamente la señal que el diseño usa como condición para decidir extraer
captura de asistencia a un servicio independiente: si se mide una
degradación real de esa lectura durante dos ventanas de carga pico
consecutivas. Para un volumen mucho mayor (cien mil usuarios en vez de
quince mil), no hay ningún cálculo que respalde una respuesta.
**Estado**: Sólida para el escenario de dos años; Débil-pendiente para
escenarios de crecimiento mucho mayores

## ¿Qué decisión sería más costosa de cambiar?

**Respuesta**: No hay, en el diseño actual, una comparación formal que
identifique una única decisión como la más costosa de revertir. Las
candidatas más plausibles son: la elección de mantener los cinco límites de
dominio como módulos de un mismo proceso en vez de servicios separados
(revertirla implica el costo de migración que el propio diseño ya anticipa
y acepta, pagado solo si y cuando hace falta), y la decisión de retención
por niveles del dato de asistencia (cambiar de estrategia de almacenamiento
después de tener años de historial acumulado sería más costoso que
diseñarla bien desde el principio). Ninguna de las dos está evaluada
cuantitativamente contra la otra.
**Estado**: Débil-pendiente

## ¿Por qué el hallazgo del equipo de una sola persona se resolvió recién en la tercera revisión, y no en la primera?

**Respuesta**: El propio proceso de revisión lo documenta con honestidad:
la restricción de que el proyecto lo desarrolla una sola persona quedó
señalada como riesgo desde la primera decisión de estilo, pero durante dos
pasadas de revisión se aceptó como "riesgo conocido, no resuelto" en vez de
convertirse en una decisión de diseño — porque cambiar el estilo
arquitectónico requiere evaluar formalmente una alternativa intermedia, no
solo mitigar con un patrón de resiliencia. Recién en la revisión siguiente
se reconoció explícitamente ese patrón ("riesgo pospuesto, no evaluado") y
se forzó la comparación que faltaba. Es una demora real del proceso, no
oculta, y queda documentada como tal.
**Estado**: Sólida

## ¿Qué pasa si nunca se extrae ningún módulo a servicio independiente?

**Respuesta**: El sistema sigue funcionando exactamente igual: los
criterios de extracción están definidos como condiciones a cumplir, no como
una fecha comprometida. Si el volumen de campus activos y la carga real
nunca llegan a los umbrales definidos, el monolito modular sigue siendo la
arquitectura vigente indefinidamente, y eso está aceptado explícitamente
como un resultado válido, no como una deuda pendiente. El riesgo real es el
opuesto: que la contención real ya esté ocurriendo pero nadie lo detecte
porque la instrumentación necesaria para medirla nunca se implementó — en
ese caso el criterio de extracción nunca se dispara aunque debería.
**Estado**: Sólida (el propio diseño reconoce este riesgo explícitamente)

## ¿Qué pasa si el proceso del monolito se reinicia o se cae?

**Respuesta**: Todos los módulos internos y el componente de autenticación
se ven afectados a la vez, porque no hay frontera de red entre ellos que
permita que uno falle de forma aislada — es el trade-off explícito de
concentrar todo en un único proceso. Lo que no está resuelto con precisión
es qué pasa específicamente con las sesiones de usuario activas ante ese
reinicio: si viven solo en memoria, un reinicio rutinario del despliegue
(no necesariamente un incidente) desconectaría a todos los usuarios
activos de golpe, sin que el diseño defina si eso es aceptable o si se
espera persistencia de sesión entre reinicios.
**Estado**: Débil-pendiente (señalado como riesgo abierto por el propio
diseño, sin resolver aún)

## ¿Por qué se eliminó la puerta de enlace (API Gateway) y las capas de agregación de clientes al pasar a monolito, y cómo se resolvió la autenticación?

**Respuesta**: Al redibujar el sistema como un único desplegable, esos dos
componentes se quitaron de los diagramas porque ya no hay múltiples
servicios de backend que enrutar o componer — pero esa eliminación se hizo
al principio solo como una instrucción de dibujo, no como una decisión de
arquitectura respaldada, y dejó sin resolver dónde vive la autenticación de
los dos clientes (aplicación móvil y portal administrativo). Eso se
corrigió después con una decisión formal: un componente transversal de
autenticación dentro del propio monolito, que intercepta toda solicitud de
ambos clientes y valida la sesión contra el mismo módulo dueño de las
credenciales, antes de dejarla pasar a cualquiera de los cinco módulos de
negocio. Cuando algún módulo se extraiga como servicio independiente, esa
misma lógica de validación se traslada a una puerta de enlace real, sin
cambiar qué se valida ni contra qué dato.
**Estado**: Sólida

## ¿Está validado legalmente el plazo de retención de documentos y fotos de registro?

**Respuesta**: No. El plazo de 180 días (o un año adicional si hay sospecha
de fraude) es un valor de diseño elegido para no dejar esos datos sensibles
sin ninguna fecha de purga, pero está declarado explícitamente como un
valor provisional que todavía necesita confirmarse contra la normativa
legal real aplicable a la universidad. Si el plazo legal real fuera mayor,
el sistema estaría purgando evidencia antes de tiempo; si fuera menor,
estaría reteniendo datos personales sensibles más tiempo del permitido. Es
un hallazgo de cumplimiento pendiente de cierre externo, no un defecto del
mecanismo técnico en sí.
**Estado**: Débil-pendiente (reconocido así explícitamente por el propio
diseño, no oculto)

## ¿Por qué no existe un único documento que compare comunicación síncrona contra comunicación dirigida por eventos como estilo global?

**Respuesta**: Esa comparación quedó resuelta de forma granular, punto de
interacción por punto de interacción (validación de credencial en el
escaneo, integración con el servicio externo de identificación, refresco de
caché de dispositivos), en vez de en una única decisión de estilo de
comunicación consolidada. Es un vacío real de documentación —un lector
nuevo tiene que reconstruir el criterio cruzando varias decisiones en vez de
encontrarlo en un solo lugar— pero no una inconsistencia: las decisiones
puntuales existen, están justificadas cada una por separado, y son
coherentes entre sí. Se evaluó explícitamente y se decidió no forzar un
documento consolidado solo por prolijidad.
**Estado**: Débil-pendiente (vacío de documentación reconocido y aceptado
como tal, no bloqueante)

---

## Huecos identificados para "qué haría diferente en versión 2"

- **Seguimiento de la cola de revisión manual del proceso de verificación**:
  no hay plazo ni alerta de seguimiento una vez que una solicitud entra en
  escalamiento manual; queda enteramente a criterio humano.
- **Tamaño máximo y política de descarte del buffer local de un
  dispositivo**: no está definido qué pasa si la desconexión dura días en
  vez de horas.
- **Orden de eventos al reconectar un dispositivo**: existe deduplicación,
  pero no una política explícita de ordenamiento ni de corrección temporal;
  además, la sincronización de reloj del dispositivo queda fuera del
  alcance validado.
- **Comportamiento a escala mucho mayor (cien mil usuarios)**: no hay
  ningún cálculo de carga para ese escenario, solo para el horizonte de dos
  años (~15.000 usuarios).
- **Comparación formal de qué decisión sería más costosa de revertir**: no
  existe ese análisis comparativo entre las decisiones estructurales más
  relevantes.
- **Persistencia de sesiones de usuario ante un reinicio del proceso**: el
  propio diseño reconoce el riesgo sin resolverlo — no está definido si las
  sesiones sobreviven a un reinicio rutinario del despliegue.
- **Validación legal del plazo de retención de documentos y fotos de
  registro**: sigue siendo un valor de diseño provisional, no una cifra
  confirmada contra la normativa real.
- **Documento único de estilo de comunicación (síncrono vs. dirigido por
  eventos)**: la decisión existe pero está repartida entre varias piezas en
  vez de consolidada en un solo lugar.
- **Ambigüedad de mayor impacto arquitectónico y stakeholder con más poder
  de cambio**: ninguna de las dos preguntas tiene una comparación formal
  que permita responderlas con una sola respuesta defendible.
- **Arquitectura a escala mínima (500 usuarios, un campus)**: nunca se
  evaluó si, a ese volumen, se simplificaría aún más la estructura de
  cinco módulos.
