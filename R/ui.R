ui <- material_page(
  include_nav_bar=FALSE,
  background_color="white",
  font_color="black",
  material_row(
      material_column(
        width=4,
        material_dropdown(
          input_id = "zone",
          label = "Zones",
          choices = c("Total", "Calgary", "Edmonton", "Central",
                      "North", "South"),
          selected = "Total",
          color="#64b5f6"
        )
      ),
      material_column(
        width=8,
        material_column(
          width=4,
          material_checkbox("interv1",
                              "No gathering of more than 250 people"),
          material_checkbox("interv2",
                              "Schools are closed")
        ),
        material_column(
          width=4,
          material_checkbox("interv3",
                              "AHS changed testing"),
          material_checkbox("interv4",
                              "High River beef processing plant closed")
        )
      )
  ),
  material_tabs(
    tabs = c(
      "New cases" = "new_cases",
      "Forecast" = "forecast",
      "Demography" = "demography",
      "Space-time" = "spacetime"
    ),
    color="blue"
  ),
  material_tab_content(
    tab_id = "new_cases",
    plotOutput("plot_new"),
    tags$p("The number of daily new cases is shown. Intervention dates (solid line) are displayed with a 2-week shift (broken line).")
  ),
  material_tab_content(
    tab_id = "forecast",
    plotOutput("plot_pred"),
    tags$p("The number of daily new cases is forecast 2 weeks into the future using exponential smoothing state space model. Shaded areas represent 95% and 80% prediction intervals. Intervention dates (solid line) are displayed with a 2-week shift (broken line).")
  ),
  material_tab_content(
    tab_id = "demography",
    plotOutput("plot_demogr"),
    tags$p("Average age (lower end of age classes averaged) by date. Intervention dates (solid line) are displayed with a 2-week shift (broken line).")
  ),
  material_tab_content(
    tab_id = "spacetime",
    material_row(
      material_column(
        width=6,
        leafletOutput("map", width="100%", height="600px")),
      material_column(
        width=6,
        sliderInput("date", "Date", as.Date(colnames(AA)[1]),
            as.Date(colnames(AA)[ncol(AA)]), as.Date(colnames(AA)[ncol(AA)]), 1),
        material_checkbox("incidence", "Show cases per 1000 person"),
        plotOutput("plot_time"))),
    tags$p("Spatio temporal distribtion of cumulative cases by health region in Alberta. Intervention dates (solid line) are displayed with a 2-week shift (broken line).")
  )
)
