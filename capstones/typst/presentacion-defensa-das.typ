// ============================================================
// DAS – Presentación de Defensa Final
// Sistema Digital de Asistencia para UPCA
// Oscar Steven Muñoz Fajardo
// Arquitectura de Software 3 – JALA University
// ============================================================

#import "common/lib/contentBox.typ": contentBox
#import "common/lib/slideLayouts.typ": theme, mainTitle, layoutA, layoutATwoCols, layoutATwoColsWithTitle, layoutBTwoCols, layoutC, layoutCTwoColsWithTitle, layoutDTwoCols

// ─────────────────────────────────────────────
// SLIDE 1 — PORTADA
// ─────────────────────────────────────────────
#layoutBTwoCols(
  contentLeft: [
    #v(1.5fr)
    = DAS — Propuesta arquitectónica

    #text(size: 20pt, weight: "semibold")[
      Oscar Steven Muñoz Fajardo
    ]

    #text(size: 16pt, fill: luma(100))[
      Arquitectura de Software 3 · JALA University · 2026
    ]
    #v(0.4fr)
  ],
  contentRight: [
    #v(60pt)

    #contentBox(
      fill: theme.primary,
      [
        #text(fill: white, size: 18pt, weight: "bold")[Universidad Panamericana de Ciencias Aplicadas, UPCA]
      ]
    )
  ]
)

// ─────────────────────────────────────────────
// SLIDE 2 — AGENDA
// ─────────────────────────────────────────────
#layoutC(
  title: "Agenda",
  content: [
    #v(8pt)
    #grid(
      columns: (1fr, 1fr),
      gutter: 0.4in,
      [
        #text(size: 18pt)[
          *1.* El problema \
          #v(3pt)
          *2.* ¿Qué necesita DAS? \
          #v(3pt)
          *3.* Drivers arquitectónicos \
          #v(3pt)
          *4.* La decisión: Monolito Modular \
          #v(3pt)
          *5.* Bounded contexts \
          #v(3pt)
          *6.* Fase 1 → Fase 2 \
          #v(3pt)
          *7.* Flujos principales \
          #v(3pt)
          *8.* NIS y procesos de larga duración \
          #v(3pt)
          *9.* Síncrono vs. asíncrono \
          #v(3pt)
          *10.* Resiliencia y fallos
        ]
      ],
      [
        #text(size: 18pt)[
          *11.* Escenario: NIS falla \
          #v(3pt)
          *12.* Dispositivos offline \
          #v(3pt)
          *13.* Datos y consistencia \
          #v(3pt)
          *14.* Observabilidad \
          #v(3pt)
          *15.* Riesgos y mitigaciones \
          #v(3pt)
          *16.* Trade-offs \
          #v(3pt)
          *17.* Evolución \
          #v(3pt)
          *18.* Roadmap \
          #v(3pt)
          *19.* Reflexión crítica — IA \
          #v(3pt)
          *20.* Cierre
        ]
      ]
    )
  ]
)

// ─────────────────────────────────────────────
// SLIDE 3 — EL PROBLEMA
// ─────────────────────────────────────────────
#layoutC(
  title: "El problema",
  content: [
    #v(10pt)
    #text(size: 19pt)[
      La Universidad Panamericana de Ciencias Aplicadas (UPCA) opera en:
    ]
    #v(10pt)
    #grid(
      columns: (1fr, 1fr, 1fr),
      gutter: 0.3in,
      [
        #contentBox(
          fill: theme.primaryDark,
          text(fill: white, size: 20pt)[
            *10* ciudades \
            *20* campus
          ]
        )
      ],
      [
        #contentBox(
          fill: theme.primary,
          text(fill: white, size: 20pt)[
            *5.000* estudiantes \
            *400* profesores
          ]
        )
      ],
      [
        #contentBox(
          fill: theme.primaryLightest,
          text(fill: white, size: 20pt)[
            *+15.000* usuarios \
            en 2 años
          ]
        )
      ]
    )
    #v(14pt)
    #contentBox(
      fill: luma(240),
      text(size: 18pt)[
        El sistema de asistencia actual no puede verificar identidad de forma confiable, no opera sin conexión y no tiene un registro auditable a largo plazo.
        DAS debe modernizar ese ciclo completo: *autorregistro → verificación → credencial → asistencia → reportes*.
      ]
    )
  ]
)

// ─────────────────────────────────────────────
// SLIDE 4 — ¿QUÉ NECESITA DAS?
// ─────────────────────────────────────────────
#layoutC(
  title: "¿Qué necesita DAS?",
  content: [
    #v(8pt)
    #grid(
      columns: (1fr, 1fr),
      gutter: 0.35in,
      [
        #text(size: 17pt, weight: "semibold", fill: theme.primaryDark)[Capacidades funcionales]
        #v(6pt)
        #text(size: 17pt)[
          - Autorregistro con documento y fotografía \
          - Verificación de identidad vía NIS \
          - Emisión de credencial DAS \
          - Captura de asistencia (entrada/salida) \
          - Soporte offline en dispositivos de campus \
          - Portal de consulta, reportes y estadísticas \
          - Notificaciones al usuario
        ]
      ],
      [
        #text(size: 17pt, weight: "semibold", fill: theme.primaryDark)[Restricciones críticas]
        #v(6pt)
        #text(size: 17pt)[
          - NIS puede tardar *hasta 2 horas* \
          - Dispositivos pueden *perder conectividad* \
          - Reportes no deben bloquear la captura \
          - Retención mínima de *5 años* de asistencia \
          - Seguridad y confidencialidad de datos sensibles \
          - Equipo operativo de *3 a 5 desarrolladores*
        ]
      ]
    )
  ]
)

// ─────────────────────────────────────────────
// SLIDE 5 — DRIVERS ARQUITECTÓNICOS
// ─────────────────────────────────────────────
#layoutC(
  title: "Drivers arquitectónicos",
  content: [
    #v(8pt)
    #text(size: 17pt)[
      Los drivers son condiciones que *cambian la estructura* del sistema, no solo una lista de características.
    ]
    #v(10pt)
    #table(
      columns: (auto, 1fr, 1fr),
      fill: (col, row) => if row == 0 { theme.primaryDark } else if calc.odd(row) { luma(245) } else { white },
      inset: 8pt,
      stroke: none,
      text(fill: white, size: 15pt)[*Driver*],
      text(fill: white, size: 15pt)[*Exigencia del problema*],
      text(fill: white, size: 15pt)[*Consecuencia arquitectónica*],
      text(size: 15pt)[NIS asíncrono],
      text(size: 15pt)[Verificación tarda hasta 2 h],
      text(size: 15pt)[Proceso persistido con estados y recuperación],
      text(size: 15pt)[Asistencia near real-time],
      text(size: 15pt)[Entrada/salida debe ser inmediata],
      text(size: 15pt)[Captura: ruta liviana, no espera NIS],
      text(size: 15pt)[Escalabilidad],
      text(size: 15pt)[~10.000 usuarios nuevos en 2 años],
      text(size: 15pt)[Separar lectura/escritura, extracción selectiva],
      text(size: 15pt)[Confiabilidad offline],
      text(size: 15pt)[Dispositivos pierden conectividad],
      text(size: 15pt)[Buffer local, idempotencia, reconexión controlada],
      text(size: 15pt)[Retención legal],
      text(size: 15pt)[5 años mínimo de asistencia],
      text(size: 15pt)[Políticas por capas: caliente / tibia / fría],
    )
  ]
)

// ─────────────────────────────────────────────
// SLIDE 6 — LA DECISIÓN: MONOLITO MODULAR
// ─────────────────────────────────────────────
#layoutC(
  title: "La decisión arquitectónica",
  content: [
    #v(6pt)
    #grid(
      columns: (1fr, 1fr),
      gutter: 0.4in,
      [
        #contentBox(
          fill: theme.primaryDark,
          [
            #text(fill: white, size: 22pt, weight: "bold")[Fase 1 — Monolito Modular]
            #v(8pt)
            #text(fill: luma(220), size: 16pt)[
              - Un único despliegue \
              - Límites de dominio claros internamente \
              - Operación manejable para 3-5 devs \
              - Evolución gradual basada en evidencia
            ]
          ]
        )
        #v(10pt)
        #text(size: 16pt, fill: theme.primaryDark, weight: "semibold")[
          ¿Por qué no microservicios desde el inicio?
        ]
        #v(4pt)
        #text(size: 15pt)[
          Broker, red interna, observabilidad distribuida y varias piezas operables *antes de que la carga lo justifique*. El costo operativo no tiene un beneficio comprobado para el escenario actual.
        ]
      ],
      [
        #contentBox(
          fill: luma(245),
          [
            #text(size: 18pt, weight: "semibold", fill: theme.primaryDark)[Comparación]
            #v(8pt)
            #table(
              columns: (auto, 1fr),
              fill: none,
              stroke: none,
              inset: (x: 0pt, y: 6pt),
              text(size: 15pt, weight: "bold")[Monolito modular],
              [],
              text(size: 14pt, fill: rgb("#1a7a1a"))[✓ Un despliegue],
              text(size: 14pt, fill: rgb("#1a7a1a"))[✓ Límites claros],
              text(size: 14pt, fill: rgb("#1a7a1a"))[✓ Operación simple],
              text(size: 14pt, fill: rgb("#cc4400"))[✗ Escala como unidad],
              [],
              [],
              text(size: 15pt, weight: "bold")[Microservicios],
              [],
              text(size: 14pt, fill: rgb("#1a7a1a"))[✓ Escala independiente],
              text(size: 14pt, fill: rgb("#cc4400"))[✗ Complejidad operativa],
              text(size: 14pt, fill: rgb("#cc4400"))[✗ Justificada por carga, no por diseño],
            )
          ]
        )
      ]
    )
  ]
)

// ─────────────────────────────────────────────
// SLIDE 7 — BOUNDED CONTEXTS
// ─────────────────────────────────────────────
#layoutC(
  title: "¿Cómo está organizado DAS?",
  content: [
    #v(4pt)
    #text(size: 16pt)[
      Cinco bounded contexts con responsabilidades, reglas y ownership de datos propios. En Fase 1 conviven en un mismo proceso con esquemas lógicos separados.
    ]
    #v(10pt)
    #grid(
      columns: (1fr, 1fr, 1fr, 1fr, 1fr),
      gutter: 0.15in,
      [
        #contentBox(
          fill: theme.primaryDark,
          inset: 10pt,
          [
            #text(fill: white, size: 14pt, weight: "bold")[Registro y Verificación]
            #v(4pt)
            #text(fill: luma(210), size: 12pt)[
              Autorregistro, NIS, estados, aprobación admin
            ]
          ]
        )
      ],
      [
        #contentBox(
          fill: theme.primary,
          inset: 10pt,
          [
            #text(fill: white, size: 14pt, weight: "bold")[Identidad y Credenciales]
            #v(4pt)
            #text(fill: luma(210), size: 12pt)[
              DAS ID, insignia, sesión, revocación
            ]
          ]
        )
      ],
      [
        #contentBox(
          fill: theme.primaryLight,
          inset: 10pt,
          [
            #text(fill: white, size: 14pt, weight: "bold")[Captura de Asistencia]
            #v(4pt)
            #text(fill: luma(210), size: 12pt)[
              Escaneos, offline, idempotencia
            ]
          ]
        )
      ],
      [
        #contentBox(
          fill: theme.primaryLightest,
          inset: 10pt,
          [
            #text(fill: white, size: 14pt, weight: "bold")[Reportes y Analítica]
            #v(4pt)
            #text(fill: luma(210), size: 12pt)[
              Consultas, estadísticas, proyecciones
            ]
          ]
        )
      ],
      [
        #contentBox(
          fill: luma(120),
          inset: 10pt,
          [
            #text(fill: white, size: 14pt, weight: "bold")[Notificaciones]
            #v(4pt)
            #text(fill: luma(210), size: 12pt)[
              Email, push, estado de entrega
            ]
          ]
        )
      ]
    )
  ]
)

#layoutC(
  title: "Diagrama de contexto (C4)",
  content: [
    #v(4pt)
    #align(center)[
      #image("images/diagrams/c4-context.png", height: 4.0in)
    ]
    #v(2pt)
    #align(center)[
      #text(size: 10pt, fill: luma(100))[
        #link(
          "https://www.plantuml.com/plantuml/png/fPB1JXj138RlUGgNKv08U-cf9rO1jKWKLarerLDaTWnOcfrPZJqfF1IdFW8lrd6oP5FQgfLwMy_E__ss_paHnQIvyvF96mwjpuxWNhMNTrMLyDln7Ujzlib2gOr1AUXn6xkgznXCD1Drdc-g-TjPOqVN7o-g3aKfbQFLt1GFUjnly1VrrwlhvMfvrQnEhxvSJWyd4sNr1CEr28uyBBYeEuJJUW4pk6xczMJIK98OfYIQ7HSNEeA3irrnKAe50MQDAT5TqIU4HoZjIlQA81bGZ1fQneF37QvFyPOafY9lXi_VeOx-G2eMVIP7y78nxV_iC6JqUsxeEWu5lotHGsq76w7oEfhpUnBbyk-566L_Z4HzJ4e2NIbvrcBNPp63nQDjREfG2gEipL2xBNB9hvWvWdfihbIss56yEdlGQM03N9vl09yfyIst21w17GLbXyw4FWfaoPWuYjMtCHKVbEUdqAOOy1NKiVHHs4QqxiOAXaxds6jE2CKYeKCRMT2pVNMq3TXwE0_2Tu7HP6RnYVnFxw7S_yip6CCnsm_BPRC3ZI_Xlp13n8Nnps7-mjY8jqaiekUM5M4zPD7oy_S0ZiP0J5utvq0FIgbuLQ-2CE9-0aDlPs7z_8H0wuBPfZXEzOAipANhOpbLCjO91PSx_mC0",
          text(
            size: 10pt,
            fill: theme.primaryDark,
            [
              Ver diagrama completo
            ]
          )
        )
      ]
    ]
  ]
)

// ─────────────────────────────────────────────
// SLIDE 8 — DIAGRAMA C4 CONTAINER
// ─────────────────────────────────────────────
#layoutC(
  title: "Diagrama de contenedores (C4)",
  content: [
    #v(4pt)
    #align(center)[
      #image("images/diagrams/c4-container.png", height: 4.0in)
    ]
    #v(2pt)
    #align(center)[
      #link(
        "https://www.plantuml.com/plantuml/png/pLZDRYEv4RxxAIg-n4PiQoRP8C020LOZALajR4cnD3l9oIYHPPcpRB93ikLrWhtc0PAdsCESVCjLRv8d2OjgTOljQFPW1LXZ07Vpf_nzN_rKzNpb0xfG5Vhav1VA25r9WeSGIlzbh-VmyMgbmaErh3mvOKqW4ww4BNgbHiENBdsGMYrxWoykPxpq_kQwLw0FvEBItI3UG6N8NPNf3rpt_p9zlxXRJ6Ttm-c7oTdvRkN3UF7rtVNeZwF9C2wU11Kq0TycGz8wyY19mrn5mmN2i3-7I_W3UeAt9sV3qU3opPktl_aIRgonMWKR7sIbqK5f7RopbP4ajzQ-3z7wB-7th_Y9r_k3nVHsD7-jePCPEM_D6VbGIOKHtWMSZfgNq_FTWTBPU_BMnUrP_TXkeYoKuPtqYXhwl12LSXZKsfuUW_1yF5-CRgBgepylHhUJwUkfpv_ObNUZxyDPn1hXJyRpq_XhJcwjXB8W2SQIJ53tIg1GcsS3a_YR6Lx1j-Jsrj5lFXdXuXPmxA8F2Bz-k8AHXcBp72F1mYsjM14BJvsxz9545S-NLcjbLY2iWIMAx-pzFHIqTGGyMlSTEGyglZXZFPprXxSnvjxyxlpgz3mZ8vKlhLUiV6GpRDyuQ9dW0CjGEOH8pQ74daUj94PS1KQoP0YgYA2wloS7sWhK82eqqaAfo4bYW2IYmNX9DZX-opYEvsV6UYmFf_H3ztGcaTtCAfp3tqzE8FuqvU6ii4kbEVpxPGatc-UrqerWMX4xeKYhlDAlWdMkzkW5AEFLoYYyO6ryfKCA0_819ViRFLSD8nH2wMofC4cL__dIke2QauWVkYa47sYvZ-Hn-zgFvfPr64c27Q38qX4RfFYKK6m--Q04UYWYE7Kfi2Wh7v4vMblH6X2EPCAfoR_4s0fPr5KkGdWN8vMCh0jYj_orGdV4Lb9gUaJ7WjyqBumXIiivLwFQ9kIgSYdOWaFZr-Gy9Y-CEHa4bS4ww4zdmCdgRAhJXV85F_bIqmgNccB6RiFSasV3lM0ZRdOEkrBzhHQ1oxMp6ZZfV7AYSLL01nez-CXDg539g0vCB91FcL9NTx6jxc1KjEA9G6AmoOQqx4kxTNwRks-_E6z4xiQYl5FCXbapqTrpn3lOyn6BS5FNbxeoyDBqCHfX6TWhus6yf176TOpoMYF6BW8opyTLAbIW99KrvBTQ9IfOwfrhFeEzpOpJGsNl0FGiiK19AaeRYFiIgoV8fxAypWfehDjjeHHMf-GB3fVuqUug9bF5lMp1_VJ2pr0HssBPbiqKeqr27w0nDYloTHLOawdZ82-u5oqzeU9Ri9eSyZF4qgyZWkIUkDs6PaI3_ZDecxIFmjUFqKZVeDvy2aeSWdkDCkcgIUme3lvqkwUgs_oO7DzRAwPLOBogKCUqaNW5WxheUN0a5ANK8NY8HpVFJedF8ZOszbTkldRNPwqv6DWZizvyIaW5Hma7LQnZ3orEPTPsPmF8D35ZuQDTjjsJyJ2K7peLRhWyaqkEGbsWsFoOQk8mPV7CgGATiWcO3TRnrX8zWTmb-kRVHebquBsfNm3P41aiM1KRKHSbkg2aZQAXn6Oug89YCS5NTP40yd-jUD3Kc-UL4l7yc0VZ9u8sj-hG12nBClBI6lrq0MjLnvrh_Lyt8ab91IR_myze1BqbdSsVJID-lnM55VrwiPZ5hirdsr7q9q_MSsdJMfkUcfrylHA3w_5eiXZDuJ__-2VSZ8V3wz67_kteAChiE6OTSzuseavHReX13xwPJoUr4hK4XwtazT1tpHn5fbQPhL2RVmtVNq-F4q3xnBhTSvuwFWS2kNkbuMclswMgqjI9IBDhB6zdUN_AUyfFcyeBzA0T5VSdnAScStE3Ht71S3oVJUVZnVZRwJ5apxyrydOvgljUpkvNu5NwK6echhhNCTbOJHRGs-_wHo4z6Hyfnh9Gs7upPZCDSsq2Br9z-J6GHfpPUFzxiRVxy3i6roQfO3mvqcSoCyyysqslUfJC9yYM-rgjqd8tcbzg-jBqm14sCspx1m1rdNZkiDKMRvvsVH6gDBcqhHBpSOu46kMBTl8uYBKxlDHUle2W2h9LIBrNeAxxFrl_nYwxTZFM1mplVQZz7yh2k_vy1CFuhxyuMiHadD9KDQf7ccOzZPv4q6ELd5fokdU5xjpTBH--sde-lrcljXVtngRsSXifsUsi9i-jjhjHkRxP-Yo_PhfJRGxwACxR_l_bgxrsZKztG_je_iSiTjvkviDNjfLDM-UjmPSZJ6RmnMHINxrLguTmkA-VxntADlAMdHzhrxDkbHywK3hoG-twNiBcfFCORYbtOpJVoG8mawBRVcf4rtJVGRtNbAE1hyZ8gj3_1G00",
        text(
          size: 10pt,
          fill: theme.primaryDark,
          [
            Ver diagrama completo
          ]
        )
      )
    ]
  ]
)

// ─────────────────────────────────────────────
// SLIDE 9 — FASE 1 VS FASE 2
// ─────────────────────────────────────────────
#layoutC(
  title: "Evolución: Fase 1 → Fase 2",
  content: [
    #v(6pt)
    #grid(
      columns: (1fr, 0.12fr, 1fr),
      gutter: 0.1in,
      [
        #contentBox(
          fill: theme.primaryDark,
          [
            #text(fill: white, size: 20pt, weight: "bold")[Fase 1 · HOY]
            #v(8pt)
            #text(fill: luma(220), size: 16pt)[
              - Monolito modular \
              - Un proceso, un despliegue \
              - Motor de datos compartido \
              - Ownership *lógico* por módulo \
              - Escalado de toda la aplicación
            ]
          ]
        )
      ],
      [
        #align(center + horizon)[
          #text(size: 28pt, fill: theme.primaryLight)[→]
        ]
      ],
      [
        #contentBox(
          fill: theme.primary,
          [
            #text(fill: white, size: 20pt, weight: "bold")[Fase 2 · SI HAY EVIDENCIA]
            #v(8pt)
            #text(fill: luma(220), size: 16pt)[
              - Monolito + servicio(s) extraídos \
              - Primer candidato: *Captura de Asistencia* \
              - APIs o eventos entre fronteras reales \
              - Database per Service del módulo extraído \
              - Broker solo si pub/sub lo requiere
            ]
          ]
        )
      ]
    )
    #v(14pt)
    #contentBox(
      fill: luma(240),
      [
        #text(size: 16pt, weight: "semibold", fill: theme.primaryDark)[
          No es una migración Big Bang. No todos los módulos se convierten en servicios. La extracción depende de métricas reales.
        ]
      ]
    )
  ]
)

// ─────────────────────────────────────────────
// SLIDE 10 — NIS Y PROCESOS DE LARGA DURACIÓN
// ─────────────────────────────────────────────
#layoutC(
  title: "NIS y procesos de larga duración",
  content: [
    #v(6pt)
    #grid(
      columns: (1fr, 1fr),
      gutter: 0.4in,
      [
        #text(size: 17pt, weight: "semibold", fill: theme.primaryDark)[El flujo de registro]
        #v(8pt)
        #contentBox(
          fill: luma(245),
          [
            #text(size: 14pt)[
              Usuario envía datos \
              ↓ \
              DAS responde *202 Accepted* + registroId \
              ↓ \
              Solicitud queda en `pendiente_nis` \
              ↓ \
              Job persistido de verificación \
              ↓ \
              ACL ↔ NIS externo (hasta 2 h) \
              ↓ \
              verificado / rechazado / escalado_manual \
              ↓ \
              aprobación administrativa \
              ↓ \
              DAS ID y credencial emitida
            ]
          ]
        )
      ],
      [
        #text(size: 17pt, weight: "semibold", fill: theme.primaryDark)[¿Por qué es importante?]
        #v(8pt)
        #text(size: 16pt)[
          DAS *no mantiene una petición HTTP abierta* durante la verificación. El usuario puede:
        ]
        #v(8pt)
        #contentBox(
          fill: theme.primaryDark,
          [
            #text(fill: white, size: 15pt)[
              - Consultar el estado en cualquier momento \
              - Recibir notificación al completarse \
              - El backend puede reiniciarse sin perder el proceso \
              - Si NIS no responde → escalamiento manual, no bloqueo
            ]
          ]
        )
        #v(8pt)
        #text(size: 15pt)[
          La solicitud tiene estados explícitos: \
          `pendiente_nis` → `pendiente_admin` → `aprobado` / `rechazado` / `escalado_manual`
        ]
        #v(8pt)
        
      ]
    )
  ]
)



// ─────────────────────────────────────────────
// SLIDE 11 — DIAGRAMA SECUENCIA REGISTRO NIS
// ─────────────────────────────────────────────
#layoutC(
  title: "Diagrama de secuencia: Registro DAS",
  content: [
    #v(4pt)
    #align(center)[
      #image("images/diagrams/sequence-registro-nis.png", height: 4.0in)
    ]
    #v(2pt)
    #align(center)[
      #link(
        "https://mermaid.ai/d/1e7139b3-82be-4864-8cb3-0c02f16e730e",
        text(
          size: 10pt,
          fill: theme.primaryDark,
          [
            Ver diagrama completo
          ]
        )
      )
    ]
  ]
)

// ─────────────────────────────────────────────
// SLIDE 12 — SÍNCRONO VS ASÍNCRONO
// ─────────────────────────────────────────────
#layoutC(
  title: "Síncrono vs. asíncrono",
  content: [
    #v(6pt)
    #grid(
      columns: (1fr, 1fr),
      gutter: 0.4in,
      [
        #contentBox(
          fill: theme.primaryDark,
          [
            #text(fill: white, size: 20pt, weight: "bold")[Síncrono]
            #v(8pt)
            #text(fill: luma(220), size: 16pt)[
              El cliente necesita respuesta inmediata
            ]
            #v(10pt)
            #text(fill: luma(200), size: 15pt)[
              - App / portal → DAS \
              - Dispositivo → Captura (escaneo online) \
              - Validación y confirmación de persistencia
            ]
          ]
        )
      ],
      [
        #contentBox(
          fill: theme.primary,
          [
            #text(fill: white, size: 20pt, weight: "bold")[Asíncrono]
            #v(8pt)
            #text(fill: luma(220), size: 16pt)[
              El resultado tarda o no debe bloquear
            ]
            #v(10pt)
            #text(fill: luma(200), size: 15pt)[
              - Registro → NIS (hasta 2 horas) \
              - Captura → Reportes (proyección) \
              - Dispositivo offline → Captura (batch) \
              - Email / push → Notificaciones
            ]
          ]
        )
      ]
    )
    #v(12pt)
    #contentBox(
      fill: luma(240),
      [
        #text(size: 16pt)[
          La regla: *síncrono donde la respuesta importa en el momento; asíncrono donde el resultado puede esperar sin bloquear la operación crítica.*
        ]
      ]
    )
  ]
)

// ─────────────────────────────────────────────
// SLIDE 13 — FLUJO DE CAPTURA: CHECK-IN
// ─────────────────────────────────────────────

#layoutC(
  title: "Flujo de captura de asistencia",
  content: [
    #v(4pt)
    #align(center)[
      #image("images/diagrams/sequence-checkin.png", height: 4.0in)
    ]
    #v(2pt)
    #align(center)[
      #link(
        "https://mermaid.ai/d/885d6a98-8a90-43ef-82c8-73b6e1e5f15f",
        text(
          size: 10pt,
          fill: theme.primaryDark,
          [
            Ver diagrama completo
          ]
        )
      )
    ]
  ]
)

// ─────────────────────────────────────────────
// SLIDE 14 — RESILIENCIA Y MANEJO DE FALLOS
// ─────────────────────────────────────────────
#layoutC(
  title: "Resiliencia: ¿qué pasa cuando algo falla?",
  content: [
    #v(6pt)
    #table(
      columns: (1.1fr, 1.2fr, 1.2fr),
      fill: (col, row) => if row == 0 { theme.primaryDark } else if calc.odd(row) { luma(245) } else { white },
      inset: 8pt,
      stroke: none,
      text(fill: white, size: 15pt)[*Fallo*],
      text(fill: white, size: 15pt)[*Comportamiento*],
      text(fill: white, size: 15pt)[*Protección*],
      text(size: 14pt)[NIS lento o no disponible],
      text(size: 14pt)[Registro queda pendiente],
      text(size: 14pt)[Job persistido · Retry · Escalamiento manual],
      text(size: 14pt)[DAS o worker se reinicia],
      text(size: 14pt)[Proceso en curso se interrumpe],
      text(size: 14pt)[Estado persistido; otro ciclo lo retoma],
      text(size: 14pt)[Dispositivo offline],
      text(size: 14pt)[Escaneos no llegan al backend],
      text(size: 14pt)[Buffer local · Caché · Lote · Idempotencia],
      text(size: 14pt)[Reconexión masiva],
      text(size: 14pt)[Lotes compiten con escaneos en vivo],
      text(size: 14pt)[Bulkhead · Throttling · Jitter · Prioridad captura],
      text(size: 14pt)[Proyección lenta],
      text(size: 14pt)[Reportes con retraso],
      text(size: 14pt)[Tarea durable · Lag medido · Reproyección],
      text(size: 14pt)[Email / push falla],
      text(size: 14pt)[Usuario no recibe notificación],
      text(size: 14pt)[Retry · DLQ (tabla persistida de fallos)],
    )
    #v(8pt)
    #text(size: 14pt, fill: luma(80))[
      Reintentos solo para fallos *transitorios*. Datos inválidos o rechazos definitivos *no* se reintentan. Toda operación repetible usa idempotencia y backoff exponencial con jitter.
    ]
  ]
)

// ─────────────────────────────────────────────
// SLIDE 15 — ESCENARIO: ¿QUÉ PASA SI NIS FALLA?
// ─────────────────────────────────────────────
#layoutCTwoColsWithTitle(
  title: "Escenario: NIS no responde",
  contentLeft: [
    #v(6pt)
    #contentBox(
      fill: luma(245),
      [
        #text(size: 14pt)[
          DAS intenta contactar NIS \
          ↓ \
          *Timeout* (sin respuesta) \
          ↓ \
          *Retry + Backoff exponencial + jitter* \
          ↓ \
          Reintentos agotados \
          ↓ \
          *Circuit Breaker* (falla rápido) \
          ↓ \
          Solicitud → `escalado_manual` \
          ↓ \
          Admin notificado · Proceso protegido \
          ↓ \
          Cuando NIS vuelve → retoma desde estado guardado
        ]
      ]
    )
  ],
  contentRight: [
    #v(6pt)
    #contentBox(
      fill: theme.primaryDark,
      [
        #text(fill: white, size: 18pt, weight: "bold")[Garantías clave]
        #v(10pt)
        #text(fill: luma(220), size: 15pt)[
          - El proceso *no desaparece*; queda en estado auditado \
          - La asistencia sigue funcionando normalmente \
          - El admin puede intervenir manualmente \
          - Cuando NIS recupera, el job se retoma \
          - El Circuit Breaker protege al sistema de fallos en cascada
        ]
      ]
    )
    #v(10pt)
    #contentBox(
      fill: luma(240),
      [
        #text(size: 13pt, weight: "semibold", fill: theme.primaryDark)[Ambigüedad reconocida]
        #v(4pt)
        #text(size: 12pt)[
          El contrato exacto de entrega de resultado de NIS (webhook, polling, correo) *no está definido* por el enunciado. La arquitectura soporta resultado diferido sin asumir un mecanismo específico.
        ]
      ]
    )
  ]
)

// ─────────────────────────────────────────────
// SLIDE 16 — DISPOSITIVOS OFFLINE Y RECONEXIÓN
// ─────────────────────────────────────────────
#layoutC(
  title: "Dispositivos offline y reconexión",
  content: [
    #v(6pt)
    #grid(
      columns: (1fr, 1fr),
      gutter: 0.4in,
      [
        #contentBox(
          fill: luma(245),
          [
            #text(size: 16pt, weight: "semibold", fill: theme.primaryDark)[Flujo offline]
            #v(8pt)
            #text(size: 15pt)[
              Dispositivo pierde conectividad \
              ↓ \
              Valida contra caché local \
              ↓ \
              Eventos acumulados en buffer local \
              ↓ \
              Reconexión \
              ↓ \
              Sincronización por lotes (batch) \
              ↓ \
              Idempotencia evita duplicados \
              ↓ \
              Eventos auditados con doble timestamp
            ]
          ]
        )
      ],
      [
        #contentBox(
          fill: theme.primaryDark,
          [
            #text(fill: white, size: 18pt, weight: "bold")[¿Por qué importa?]
            #v(8pt)
            #text(fill: luma(220), size: 15pt)[
              - Campus pueden operar sin red \
              - La asistencia no se pierde \
              - Al reconectar, los lotes *no desplazan* los escaneos en vivo \
              - `timestampEscaneo` + `timestampRecibido` permiten auditoría del orden real
            ]
          ]
        )
        #v(10pt)
        #contentBox(
          fill: luma(240),
          [
            #text(size: 15pt, weight: "semibold", fill: theme.primaryDark)[Bulkhead de reconexión masiva]
            #v(4pt)
            #text(size: 14pt)[
              Límites de concurrencia, tamaño de lote y prioridad para la ruta crítica de captura en vivo.
            ]
          ]
        )
      ]
    )
  ]
)

// ─────────────────────────────────────────────
// SLIDE 17 — DATOS Y CONSISTENCIA
// ─────────────────────────────────────────────
#layoutC(
  title: "Datos y consistencia",
  content: [
    #v(6pt)
    #grid(
      columns: (1fr, 1fr),
      gutter: 0.4in,
      [
        #text(size: 17pt, weight: "semibold", fill: theme.primaryDark)[Ownership de datos]
        #v(8pt)
        #table(
          columns: (1fr, 1fr),
          fill: (col, row) => if row == 0 { theme.primaryDark } else if calc.odd(row) { luma(245) } else { white },
          inset: 7pt,
          stroke: none,
          text(fill: white, size: 14pt)[*Dato*],
          text(fill: white, size: 14pt)[*Dueño*],
          text(size: 13pt)[Solicitud de Registro],
          text(size: 13pt)[Registro y Verificación],
          text(size: 13pt)[DAS ID / Credencial],
          text(size: 13pt)[Identidad y Credenciales],
          text(size: 13pt)[Evento de Asistencia],
          text(size: 13pt)[Captura de Asistencia],
          text(size: 13pt)[Resúmenes / estadísticas],
          text(size: 13pt)[Reportes y Analítica],
          text(size: 13pt)[Registro de Notificación],
          text(size: 13pt)[Notificaciones],
        )
      ],
      [
        #text(size: 17pt, weight: "semibold", fill: theme.primaryDark)[Consistencia por caso]
        #v(8pt)
        #contentBox(
          fill: theme.primaryDark,
          [
            #text(fill: white, size: 15pt, weight: "bold")[Fuerte]
            #v(4pt)
            #text(fill: luma(210), size: 14pt)[
              Identidad, credencial, revocación y evento de asistencia: deben ser visibles de inmediato dentro del monolito.
            ]
          ]
        )
        #v(8pt)
        #contentBox(
          fill: theme.primary,
          [
            #text(fill: white, size: 15pt, weight: "bold")[Eventual]
            #v(4pt)
            #text(fill: luma(210), size: 14pt)[
              Reportes, estadísticas, cachés de dispositivos y resultado NIS: una demora acotada es preferible a detener la captura.
            ]
          ]
        )
        #v(8pt)
        #text(size: 14pt)[
          Ningún módulo escribe directamente datos de otro. Esa disciplina hace posible la migración futura.
        ]
      ]
    )
  ]
)

// ─────────────────────────────────────────────
// SLIDE 18 — OBSERVABILIDAD
// ─────────────────────────────────────────────
#layoutC(
  title: "Observabilidad",
  content: [
    #v(4pt)
    #contentBox(
      fill: luma(240),
      [
        #text(size: 16pt)[
          La observabilidad permite *operar DAS* y *decidir si debe evolucionar*. Las métricas son el criterio de extracción a Fase 2.
        ]
      ]
    )
    #v(8pt)
    #grid(
      columns: (1fr, 1fr, 1fr),
      gutter: 0.2in,
      [
        #contentBox(
          fill: theme.primaryDark,
          inset: 9pt,
          [
            #text(fill: white, size: 14pt, weight: "bold")[Operación]
            #v(4pt)
            #text(fill: luma(210), size: 13pt)[
              Latencia p95 \
              Error rate \
              Rechazos de auth
            ]
          ]
        )
      ],
      [
        #contentBox(
          fill: theme.primary,
          inset: 9pt,
          [
            #text(fill: white, size: 14pt, weight: "bold")[Registro / NIS]
            #v(4pt)
            #text(fill: luma(210), size: 13pt)[
              Solicitudes pendientes \
              Timeouts y reintentos \
              Estado Circuit Breaker
            ]
          ]
        )
      ],
      [
        #contentBox(
          fill: theme.primaryLight,
          inset: 9pt,
          [
            #text(fill: white, size: 14pt, weight: "bold")[Captura]
            #v(4pt)
            #text(fill: luma(210), size: 13pt)[
              Eventos recibidos \
              Duplicados detectados \
              Offline pendientes · Batch size
            ]
          ]
        )
      ],
    )
    #v(8pt)
    #grid(
      columns: (1fr, 1fr, 1fr),
      gutter: 0.2in,
      [
        #contentBox(
          fill: theme.primaryLightest,
          inset: 9pt,
          [
            #text(fill: white, size: 14pt, weight: "bold")[Reportes]
            #v(4pt)
            #text(fill: luma(210), size: 13pt)[
              Lag de proyección \
              Antigüedad de vistas
            ]
          ]
        )
      ],
      [
        #contentBox(
          fill: luma(100),
          inset: 9pt,
          [
            #text(fill: white, size: 14pt, weight: "bold")[Negocio]
            #v(4pt)
            #text(fill: luma(210), size: 13pt)[
              Registros completados \
              Campus sin actividad \
              Asistencia procesada
            ]
          ]
        )
      ],
      [
        #contentBox(
          fill: luma(60),
          inset: 9pt,
          [
            #text(fill: white, size: 14pt, weight: "bold")[Alertas críticas]
            #v(4pt)
            #text(fill: luma(210), size: 13pt)[
              NIS muy antiguo \
              Circuit Breaker abierto \
              Buffer cerca del límite
            ]
          ]
        )
      ],
    )
  ]
)

// ─────────────────────────────────────────────
// SLIDE 19 — RIESGOS Y MITIGACIONES
// ─────────────────────────────────────────────
#layoutC(
  title: "Riesgos y mitigaciones",
  content: [
    #v(6pt)
    #table(
      columns: (1.3fr, 1.2fr, 1fr),
      fill: (col, row) => if row == 0 { theme.primaryDark } else if calc.odd(row) { luma(245) } else { white },
      inset: 8pt,
      stroke: none,
      text(fill: white, size: 15pt)[*Riesgo*],
      text(fill: white, size: 15pt)[*Mitigación*],
      text(fill: white, size: 15pt)[*Riesgo residual*],
      text(size: 14pt)[Complejidad para equipo pequeño],
      text(size: 14pt)[Monolito modular hasta tener evidencia y madurez operativa],
      text(size: 14pt)[Extracción futura exige capacidad real],
      text(size: 14pt)[NIS incierto o indisponible],
      text(size: 14pt)[ACL · Jobs persistidos · Timeout · Retry · Escalamiento manual],
      text(size: 14pt)[Intervención humana depende del tercero],
      text(size: 14pt)[Buffer local lleno],
      text(size: 14pt)[Límites · Alertas · Estado degradado · Asistencia manual],
      text(size: 14pt)[Requiere procedimiento operativo de campus],
      text(size: 14pt)[Contención Captura / Reportes],
      text(size: 14pt)[CQRS interno · Lag medido · Posible extracción de Captura],
      text(size: 14pt)[Fase 1 sigue compartiendo proceso],
      text(size: 14pt)[Proceso / BD como punto único de falla],
      text(size: 14pt)[Alta disponibilidad · Backup/restauración · Monitoreo],
      text(size: 14pt)[Mayor radio de falla que servicios aislados],
    )
  ]
)

// ─────────────────────────────────────────────
// SLIDE 20 — TRADE-OFFS
// ─────────────────────────────────────────────
#layoutC(
  title: "Trade-offs arquitectónicos",
  content: [
    #v(6pt)
    #table(
      columns: (1.2fr, 1fr, 1fr),
      fill: (col, row) => if row == 0 { theme.primaryDark } else if calc.odd(row) { luma(245) } else { white },
      inset: 8pt,
      stroke: none,
      text(fill: white, size: 15pt)[*Decisión*],
      text(fill: white, size: 15pt)[*Ganancia*],
      text(fill: white, size: 15pt)[*Sacrificio aceptado*],
      text(size: 14pt)[Monolito modular vs. microservicios],
      text(size: 14pt)[Menor costo operativo; límites claros],
      text(size: 14pt)[Escala como unidad; aceptable hasta que la carga pruebe lo contrario],
      text(size: 14pt)[Síncrono para captura, asíncrono para NIS/reportes],
      text(size: 14pt)[Respuesta inmediata donde importa],
      text(size: 14pt)[Estados, jobs y monitoreo adicionales],
      text(size: 14pt)[Consistencia fuerte para identidad; eventual para vistas],
      text(size: 14pt)[Corrección en ops críticas; disponibilidad en captura],
      text(size: 14pt)[Reportes y cachés pueden tener retraso acotado],
      text(size: 14pt)[Buffer offline],
      text(size: 14pt)[Preservar asistencia durante cortes],
      text(size: 14pt)[Control de capacidad, orden y reconciliación],
      text(size: 14pt)[Extracción selectiva basada en evidencia],
      text(size: 14pt)[Pagar complejidad distribuida solo cuando aporta valor],
      text(size: 14pt)[Disciplina de contratos, métricas y migración gradual],
    )
  ]
)

// ─────────────────────────────────────────────
// SLIDE 21 — EVOLUCIÓN ARQUITECTÓNICA
// ─────────────────────────────────────────────
#layoutC(
  title: "¿Cómo evoluciona DAS?",
  content: [
    #v(6pt)
    #grid(
      columns: (1fr, 1fr),
      gutter: 0.4in,
      [
        #text(size: 17pt, weight: "semibold", fill: theme.primaryDark)[La secuencia de evolución]
        #v(5pt)
        #contentBox(
          fill: luma(245),
          [
            #text(size: 12pt)[
              Monolito Modular en operación \
              ↓ \
              Observabilidad activa \
              ↓ \
              Evidencia de presión real \
              ↓ \
              Identificación del módulo afectado \
              ↓ \
              Estabilización del contrato \
              ↓ \
              Extracción selectiva del módulo \
              ↓ \
              Migración de datos \
              ↓ \
              Comunicación distribuida donde se necesita \
              ↓ \
              Observar y decidir por módulo
            ]
          ]
        )
      ],
      [
        #text(size: 17pt, weight: "semibold", fill: theme.primaryDark)[Criterios para extraer Captura]
        #v(5pt)
        #contentBox(
          fill: theme.primaryDark,
          [
            #text(fill: white, size: 15pt, weight: "bold")[Al menos UNO de estos:]
            #v(8pt)
            #text(fill: luma(220), size: 14pt)[
              - Más de 10 campus activos con carga próxima al escenario de prueba \
              - Degradación atribuible a contención Captura/Reportes en 2 ventanas pico \
              - Necesidad repetida de desplegar Captura sin los demás módulos \
              - Pipeline e infraestructura reproducibles probados en producción
            ]
          ]
        )
        #v(10pt)
        #contentBox(
          fill: luma(240),
          [
            #text(size: 16pt, weight: "semibold", fill: theme.primaryDark)[
              No se construye complejidad futura antes de necesitarla.
            ]
          ]
        )
      ]
    )
  ]
)

// ─────────────────────────────────────────────
// SLIDE 22 — ROADMAP
// ─────────────────────────────────────────────
#layoutC(
  title: "Roadmap",
  content: [
    #v(2pt)

    #table(
      columns: (1.4fr, 1.3fr, 1fr),
      fill: (col, row) =>
        if row == 0 {
          theme.primaryDark
        } else if calc.odd(row) {
          luma(245)
        } else {
          white
        },
      inset: 8pt,
      stroke: none,

      text(fill: white, size: 14pt)[*Hito*],
      text(fill: white, size: 14pt)[*Resultado verificable*],
      text(fill: white, size: 14pt)[*Riesgo que reduce*],

      // Validación de la propuesta
      text(size: 10pt)[Validación de la propuesta],
      text(size: 10pt)[Drivers, restricciones, supuestos y escenarios priorizados],
      text(size: 10pt)[Diseñar sobre información incorrecta],

      // Diseño de la solución
      text(size: 10pt)[Diseño de la solución],
      text(size: 10pt)[Arquitectura, bounded contexts, datos, integraciones y decisiones tecnológicas definidos],
      text(size: 10pt)[Contradicciones y decisiones sin justificar],

      // Spike NIS
      text(size: 10pt)[Spike NIS],
      text(size: 10pt)[Contrato, entrega de resultado, errores y límites confirmados],
      text(size: 10pt)[Integración externa incorrecta],

      // Implementación Fase 1
      text(size: 10pt)[Implementación Fase 1],
      text(size: 10pt)[Monolito Modular con límites, ownership y flujos implementados],
      text(size: 10pt)[Acoplamiento y responsabilidades ambiguas],

      // Validación de captura
      text(size: 10pt)[Validación de captura],
      text(size: 10pt)[Offline, idempotencia, orden y reconexión masiva probados],
      text(size: 10pt)[Duplicación o saturación de asistencia],

      // Pruebas
      text(size: 10pt)[Prueba de carga y seguridad],
      text(size: 10pt)[Meta near real-time, recuperación y controles medidos],
      text(size: 10pt)[Capacidad y privacidad no comprobadas],

      // Operación
      text(size: 10pt)[Operación Fase 1],
      text(size: 10pt)[Métricas, alertas y criterios de extracción activos],
      text(size: 10pt)[Migrar por intuición y no por evidencia],
    )

    #v(2pt)

    #contentBox(
      fill: luma(240),
      [
        #text(size: 11pt)[
          *Fase 2 no tiene fechas fijas.* Empieza únicamente cuando
          la operación y las métricas proporcionen evidencia suficiente
          para justificar la extracción selectiva de un bounded context.
        ]
      ]
    )
  ]
)

// ─────────────────────────────────────────────
// SLIDE 23 — REFLEXIÓN CRÍTICA: USO DE IA
// ─────────────────────────────────────────────
#layoutC(
  title: "Reflexión crítica sobre el uso de IA",
  content: [
    #v(4pt)
    #grid(
      columns: (1fr, 1fr),
      gutter: 0.35in,
      [
        #text(size: 16pt, weight: "semibold", fill: theme.primaryDark)[Cuatro prompts principales]
        #v(6pt)
        #table(
          columns: (1fr, 1fr),
          fill: (col, row) => if row == 0 { theme.primaryDark } else if calc.odd(row) { luma(245) } else { white },
          inset: 7pt,
          stroke: none,
          text(fill: white, size: 13pt)[*Prompt*],
          text(fill: white, size: 13pt)[*Propósito*],
          text(size: 12pt)[1 — Descubrimiento],
          text(size: 12pt)[Drivers, requisitos, ambigüedades],
          text(size: 12pt)[2 — Diseño †],
          text(size: 12pt)[Alternativas, decisiones, diagramas],
          text(size: 12pt)[3 — Trade-offs],
          text(size: 12pt)[Riesgos, costos, mitigaciones],
          text(size: 12pt)[4 — Síntesis],
          text(size: 12pt)[Defensa, narrativa, informe],
        )
        #v(6pt)
        #text(size: 13pt)[† Mayor valor: Prompt 2, por separar proposición, modelado y revisión adversarial.]
      ],
      [
        #text(size: 16pt, weight: "semibold", fill: theme.primaryDark)[Lo que requirió control manual]
        #v(6pt)
        #contentBox(
          fill: theme.primaryDark,
          [
            #text(fill: white, size: 14pt)[
              - Supuestos que se convertían en requisitos \
              - Patrones propuestos sin driver que los justifique \
              - Riesgos con soluciones que aumentaban complejidad \
              - Respuestas plausibles sin evidencia suficiente
            ]
          ]
        )
        #v(8pt)
        #contentBox(
          fill: luma(240),
          [
            #text(size: 14pt, weight: "semibold", fill: theme.primaryDark)[Aprendizaje principal]
            #v(4pt)
            #text(size: 13pt)[
              La IA generó mayor valor como *herramienta de razonamiento y revisión*, no como generador de contenido. Una respuesta más completa no es necesariamente una respuesta mejor.
            ]
          ]
        )
      ]
    )
  ]
)

// ─────────────────────────────────────────────
// SLIDE 24 — CIERRE
// ─────────────────────────────────────────────
#layoutC(
  title: "",
  content: [
    #v(1fr)

    #align(center)[
      #text(
        size: 42pt,
        weight: "bold",
        fill: theme.primaryDark
      )[
        Muchas gracias
      ]
    ]

    #v(1fr)
  ]
)
