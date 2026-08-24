---
name: mermaid-c4
description: Conventions for drawing C4 diagrams (Context, Container, Component) and UML sequence diagrams in Mermaid syntax for the DAS/UPCA capstone. Load this before producing or editing any .mmd diagram in design/diagrams/.
---

# Convenciones de diagramación C4 + Mermaid para este capstone

Esta skill fija las convenciones que **todo** diagrama del proyecto debe
seguir, para que sean legibles por `architecture-reviewer`,
`architecture-defender`, `report-writer` y por quien los lea después.

## Formato general

- Un archivo `.mmd` por diagrama, ubicado en `design/diagrams/`.
- Un concepto por diagrama. No mezcles Context y Container en el mismo archivo.
- Nombrá los archivos según su nivel: `c4-context.mmd`, `c4-container.mmd`,
  `c4-component.mmd`, `sequence-<flujo>.mmd`.
- No inventes componentes que no estén en
  `design/milestone-2/architecture-decision.md` — si algo no está decidido,
  no lo dibujes; dejá una nota en `NOTES.md` en su lugar.

## Nivel 1 — Contexto (`c4-context.mmd`)

Usá el diagrama C4 nativo de Mermaid:

```mermaid
C4Context
    title Contexto del Sistema DAS - UPCA

    Person(estudiante, "Estudiante", "Registra y consulta su asistencia")
    Person(profesor, "Profesor", "Registra y consulta su asistencia")
    Person(admin, "Personal Administrativo", "Aprueba registros y consulta reportes")

    System(das, "DAS", "Sistema Digital de Asistencia")

    System_Ext(nis, "NIS", "Servicio de Identificación Nacional. Verificación asíncrona, hasta 2h de latencia")
    System_Ext(dispositivo, "Dispositivo DAS de captura", "Escanea la Insignia DAS en cada campus")

    Rel(estudiante, das, "Se autorregistra, consulta asistencia", "HTTPS")
    Rel(profesor, das, "Se autorregistra, consulta asistencia", "HTTPS")
    Rel(admin, das, "Aprueba registros, ve reportes", "HTTPS")
    Rel(das, nis, "Solicita verificación de identidad", "API asíncrona")
    Rel(dispositivo, das, "Envía eventos de check-in/check-out", "API")
```

Actores fijos del capstone (no los cambies sin que `context/capstone.pdf` lo
respalde): Estudiante, Profesor, Personal Administrativo, NIS, Dispositivo DAS
de captura. Marcá siempre la relación con el NIS como asíncrona/alta latencia
en la etiqueta — es un driver arquitectónico central, no un detalle.

## Nivel 2 — Contenedores (`c4-container.mmd`)

```mermaid
C4Container
    title Contenedores del Sistema DAS - Candidato: <nombre>

    Person(estudiante, "Estudiante/Profesor")

    System_Boundary(das, "DAS") {
        Container(mobile, "App Móvil DAS", "<tecnología o 'a definir'>", "Autorregistro, insignia, consulta")
        Container(admin_portal, "Portal Administrativo Web", "...", "Reportes y aprobación")
        Container(api, "<nombre del/los servicios propuestos por el candidato>", "...", "...")
        ContainerDb(db, "<almacenamiento propuesto>", "...", "...")
    }

    System_Ext(nis, "NIS")
    System_Ext(dispositivo, "Dispositivo DAS de captura")

    Rel(estudiante, mobile, "Usa")
    Rel(mobile, api, "...", "sync/async — especificar")
    Rel(dispositivo, api, "Envía eventos de asistencia", "...")
    Rel(api, nis, "Verificación de identidad", "async")
    Rel(api, db, "Lee/escribe")
```

Los containers que aparezcan acá deben ser exactamente los que
`design/milestone-2/architecture-decision.md` describe — ni más, ni menos.

## Nivel 3 — Componentes (`c4-component.mmd`)

Solo para el container más crítico/complejo de la arquitectura elegida
(normalmente el que maneja registro+verificación NIS, o el de captura de
asistencia). Mismo principio: `C4Component`, componentes internos con
`Component(...)`, relaciones con `Rel(...)`. Si la arquitectura elegida es
monolito modular, este nivel muestra los módulos internos del monolito.

## Diagramas de secuencia

Usá `sequenceDiagram` estándar de Mermaid. Reglas específicas para este dominio:

- Marcá explícitamente síncrono vs. asíncrono: una llamada async se representa
  con `->>` seguido de una respuesta inmediata de "aceptado/en proceso", y el
  resultado real llega después via otro mensaje o evento — nunca dibujes la
  espera de 2h del NIS como una flecha bloqueante síncrona.
- Usá `Note over` para marcar estados de espera prolongados (ej. "Usuario en
  estado PENDIENTE_VERIFICACION durante hasta 2h").
- Usá `alt`/`opt` para caminos de error: timeout del NIS, dispositivo offline,
  respuesta duplicada.
- Dos secuencias mínimas obligatorias:
  - `sequence-registro-nis.mmd`: autorregistro → verificación NIS (async) →
    aprobación administrativa → emisión de Insignia DAS.
  - `sequence-checkin.mmd`: escaneo en dispositivo → registro de
    entrada/salida → camino feliz y, si la arquitectura elegida lo define,
    manejo de pérdida de conectividad.

Ejemplo de esqueleto:

```mermaid
sequenceDiagram
    actor U as Usuario
    participant App as App Móvil DAS
    participant Svc as Servicio de Registro
    participant NIS as NIS (externo)
    participant Admin as Personal Administrativo

    U->>App: Envía documento, foto, datos
    App->>Svc: Solicita registro
    Svc->>NIS: Solicita verificación (async)
    NIS-->>Svc: Acuse de recibo (no es el resultado)
    Note over Svc,NIS: Espera de hasta 2h. Usuario en estado PENDIENTE_VERIFICACION
    NIS->>Svc: Resultado de verificación (evento/callback)
    Svc->>Admin: Notifica para aprobación
    Admin->>Svc: Aprueba
    Svc->>App: Emite Insignia DAS (email)
```

## Checklist antes de dar por terminado un diagrama

- [ ] ¿Todos los componentes dibujados existen en
      `design/milestone-2/architecture-decision.md`?
- [ ] ¿La relación con el NIS está marcada como asíncrona en todos los
      diagramas donde aparece?
- [ ] ¿El nombre del archivo sigue la convención (`c4-*.mmd`, `sequence-*.mmd`)?
- [ ] ¿Quedó alguna ambigüedad que tuviste que resolver para poder dibujar?
      Si sí, está anotada en `design/diagrams/NOTES.md`.
