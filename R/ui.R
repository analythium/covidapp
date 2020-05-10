ui <- material_page(
  include_nav_bar=FALSE,
  background_color="white",
  font_color="black",
  material_tabs(
    tabs = c(
      "Trend and prediction" = "new_cases",
      "Age and gender" = "demography",
      "Interventions" = "interventions",
      "Space and time" = "spacetime"
    ),
    color="blue"
  ),

  material_tab_content(
    tab_id = "new_cases",
    material_row(
      material_column(
        width=6,
        material_dropdown(
          input_id = "zone",
          label = "Zones",
          choices = c("Total", "Calgary", "Edmonton", "Central", "North", "South"),
          selected = "Total",
          color="#64b5f6"
        )
      ),
      material_column(
        width=6,
        material_checkbox("incidence", "Show cases per 1000 person"),
      )
    ),
    material_row(
      material_column(
        width=12,
      plotOutput("plot_new"),
      tags$p("The number of daily new cases is shown."),
      plotOutput("plot_pred"),
      tags$p("The number of daily new cases is forecast 2 weeks into the future using exponential smoothing state space model. Shaded areas represent 95% and 80% prediction intervals.")
      )
    )
  ),

  material_tab_content(
    tab_id = "demography",
    material_row(
      material_column(
        width=12,
        plotOutput("plot_demogr1")
      )
    ),
    material_row(
      material_column(
        width=12,
        plotOutput("plot_demogr2")
      )
    ),
    material_row(
      material_column(
        width=12,
        tags$p("Average age (lower end of age classes averaged) by date.")
      )
    )
  ),

  material_tab_content(
    tab_id = "interventions",
    material_row(
      material_column(
        width=12,
        tags$h5(paste0("Edmonton (population: ",
                     round(PopByZone["Edmonton"]/1000, 2),
                     "M, total cases: ", sum(ABw$Edmonton), ")")),
        material_checkbox("interv1", "Alberta lockdown (March 17)"),
        plotOutput("plot_new1"),
        tags$h5(paste0("Calgary (population: ",
                       round(PopByZone["Calgary"]/1000, 2),
                       "M, total cases: ", sum(ABw$Calgary), ")"))
      )
    ),
    material_row(
      material_column(
        width=6,
        material_checkbox("interv2", "Alberta lockdown (March 17)")
      ),
      material_column(
        width=6,
        material_checkbox("interv3", "Meat processing plant closed (April 22)")
      )
    ),
    material_row(
      material_column(
        width=12,
        plotOutput("plot_new2"),
        tags$p("The number of daily new cases is shown. Intervention dates (solid line) are displayed with a 2-week shift (broken line)."),
      )
    )
  ),

  material_tab_content(
    tab_id = "spacetime",
    material_row(
      material_column(
        width=6,
        material_dropdown(
          input_id = "zone2",
          label = "Zones",
          choices = c("Total", "Calgary", "Edmonton", "Central", "North", "South"),
          selected = "Total",
          color="#64b5f6"
        )
      ),
      material_column(
        width=6,
        material_checkbox("incidence2", "Show cases per 1000 person"),
      )
    ),
    material_row(
      material_column(
        width=6,
        leafletOutput("map", width="100%", height="600px")),
      material_column(
        width=6,
        sliderInput("date", "Date", as.Date(colnames(AA)[1]),
            as.Date(colnames(AA)[ncol(AA)]), as.Date(colnames(AA)[ncol(AA)]), 1),
        plotOutput("plot_time"))),
    tags$p("Spatio temporal distribtion of cumulative cases by health region in Alberta. Intervention dates (solid line) are displayed with a 2-week shift (broken line).")
  )
)
