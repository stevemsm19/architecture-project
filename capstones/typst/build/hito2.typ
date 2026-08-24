#import "../common/lib/documentLayouts.typ": documentLayout, coverPage

#show: documentLayout

#let horizontalrule = [
  #line(start: (0%,0%), end: (100%,0%))
]

#coverPage(
  title: "Arquitectura de software 3 - CSAR-484.GA.T2.26.M1",
  professor: "Santiago Henn",
  student: "Oscar Steven Muñoz Fajardo",
  date: "Unknown Date",
  lab: "Unknown Lab"
)

#figure(
  align(center)[#table(
    columns: (33.33%, 33.33%, 33.33%),
    align: (auto,auto,auto,),
    table.header([Interacción], [Estilo de Integración
      Propuesto], [Justificación Técnica],),
    table.hline(),
    [#strong[\1. Solicitud de envío (Shipping Request)]], [Mensajería
    Asíncrona (Colas de Mensajes)], [Este estilo elimina el
    #strong[acoplamiento] temporal entre sistemas, aislando al monolito
    de caídas en el receptor y asegurando una alta #strong[tolerancia a
    fallos] mediante mecanismos de reintento encolados. Además, facilita
    la #strong[escalabilidad] horizontal de ShipTrack en Kubernetes para
    procesar picos de solicitudes sin saturar la base de datos
    relacional de LogiMonolith.],
    [#strong[\2. Actualización del estado del envío]], [Arquitectura
    Orientada a Eventos (EDA / Pub-Sub)], [Publicar eventos de cambio de
    estado reduce drásticamente el #strong[acoplamiento] de plataforma,
    permitiendo que LogiMonolith procese las actualizaciones a su propio
    ritmo sin bloquear hilos transaccionales críticos. Asimismo,
    estructurar estos flujos mediante un contrato de eventos documentado
    mitiga el #strong[factor bus] al simplificar la integración de
    futuros consumidores sin requerir personal especializado en el
    monolito.],
    [#strong[\3. Alerta de retraso crítico en ruta (Interacción
    asíncrona adicional)]], [Mensajería Asíncrona / Notificaciones
    Basadas en Eventos], [Desacoplar las alertas de retraso mediante
    eventos reactivos permite disparar notificaciones paralelas
    (clientes, soporte, facturación) sin degradar el flujo principal de
    transporte, garantizando la #strong[tolerancia a fallos] si un canal
    de salida falla. Este diseño favorece la #strong[escalabilidad]
    elástica de los microservicios de mensajería y reduce el
    #strong[factor bus] operativo al aislar la lógica de contingencia
    logística de las aplicaciones core.],
  )]
  , kind: table
  )

