#import "common/lib/contentBox.typ": contentBox
#import "common/lib/slideLayouts.typ": theme, mainTitle, layoutA, layoutATwoCols, layoutATwoColsWithTitle, layoutBTwoCols, layoutC, layoutCTwoColsWithTitle, layoutDTwoCols

#mainTitle(
  title: "Project Title",
  subtitle: "Author Name <email@example.com>",
  content: [

    #v(160pt)

    #contentBox(
      fill: luma(150, 30%),
      text(
        fill: white,
        size: 20pt,
        [
          A short description of the project, presentation, or document purpose.
        ],
      ),
    )
  ],
)

#layoutC(
  title: "Agenda",
  content: [
    #v(20pt)
    #text(
      size: 28pt,
      [
        1. Introduction and Context
        2. Problem Statement
        3. Objectives and Scope
        4. Proposed Approach
        5. System Design
        6. Implementation Details
        7. Technologies
        8. Demonstration
        9. Challenges and Lessons Learned
        10. Conclusions and Future Work
      ]
    )
  ]
)

#layoutC(
  title: "Introduction and Context",
  content: [

    #v(50pt)
    == Did you know?

    #contentBox(
      fill: theme.primaryLightest,
      text(
        fill: white,
        size: 28pt,
        [
          Add an interesting fact, statistic, or key observation related to your topic.
        ],
      ),
    )

    #text(size: 15pt, fill: black, "Source or reference link")
  ]
)

#layoutC(
  title: "Problem Statement",
  content: [
    #align(center + horizon,
    [
      #text(
        size: 30pt,
        weight: "bold",
        fill: theme.primary,
        [
          Describe the main question, challenge, or problem this project addresses.
        ],
      )
    ])
  ]
)

#layoutA(
  content: [
    #align(horizon,
    [
      #text(
        size: 28pt,
        [
          Explain the context behind the problem.

          #v(30pt)

          Describe why this problem matters and who is affected.
        ]
      )
    ])
  ]
)

#layoutA(
  content: [
    #align(center + horizon,
    [
      
    ])
  ]
)

#layoutC(
  title: "Objectives and Scope",
  content: [
    #align(horizon, [
      #text(
        size: 26pt,
        [
          - Define the main objective
          - Describe the project scope
          - Identify expected outcomes
          - Explain the main features or components
          - Mention important limitations
        ]
      )
    ])
  ]
)

#layoutC(
  title: "Proposed Approach",
  content: [
    #align(center + horizon,
    [
      
    ])
  ]
)

#layoutA(
  content: [
    #align(horizon,
    [
      #text(size: 28pt)[
        Describe the proposed solution, product, or methodology.

        #v(50pt)

        Explain how it solves the identified problem and provides value.
      ]
    ])
  ]
)

#layoutA(
  content: [
    #align(horizon,
    [
      #grid(
        columns: (1fr, 1fr),
        [
          #align(center)[

          ]
        ],
        [
          #align(center)[
            
          ]
        ],
      )
    ])
  ]
)

#layoutC(
  title: "System Design",
  content: [
    #align(center + horizon,
    [
      
    ])
  ]
)

#layoutC(
  title: "Technologies",
  content: [
    #align(horizon,
    [
      #grid(
        columns: (1fr,1fr,1fr),
        [
          #align(center)[]
          #align(center)[]
        ],
        [
          #align(center)[]
          #align(center)[]
        ],
        [
          #align(center)[]
          #align(center)[]
        ],
      )
    ])
  ]
)

#layoutC(
  title: "Implementation Details",
  content: [
    #align(center + horizon,
    [
      
    ])
  ]
)

#layoutC(
  title: "Additional Component or Module",
  content: [
    #align(center + horizon,
    [
      
    ])
  ]
)

#layoutA(
  content: [
    #align(center + horizon, [
      #text(
        size: 50pt,
        weight: "bold",
        fill: theme.primary,
        [
          Demo
        ],
      )

      #v(10pt)

      #link(
        "https://example.com",
        text(
          size: 15pt,
          fill: black,
          [
            https://example.com
          ]
        )
      )
    ])
  ]
)

#layoutC(
  title: "Challenges and Lessons Learned",
  content: [
    #align(horizon, [
      #text(
        size: 26pt,
        [
          - Challenge one
          - Challenge two
          - Technical or organizational difficulties
          - Important lessons learned
          - Improvements identified
        ]
      )
    ])
  ]
)

#layoutC(
  title: "Conclusions and Future Work",
  content: [
    #align(horizon, [
      #contentBox(
        fill: theme.primaryLightest,
        text(
          size: 25pt,
          fill: white,
          [
            Summarize the main achievements and the value created.

            #v(15pt)

            Describe possible improvements, extensions, or future opportunities.
          ]
        )
      )
    ])
  ]
)

#layoutA(
  content: [
    #align(center + horizon, [
      #text(
        size: 40pt,
        weight: "bold",
        fill: theme.primary,
        [
          "Thank you for your attention."
        ],
      )

      #text([Author Name])
    ])
  ]
)