ui <- fluidPage(
  tags$head(includeHTML("ga.html")),
  theme = shinytheme("cosmo"),
  HTML("<p>COVID-19 cases in Alberta by geographic areas and date reported to <a href='https://covid19stats.alberta.ca/' target=_blank>Alberta Health</a>. Weekly aggregates are presented because data are not updated on weekends.</p>"),
  fluidRow(
    column(4,
      checkboxInput("incidence", "Show cases per 1000 person", FALSE),
      checkboxInput("new", "Show new cases", FALSE)
    ),
    column(4,
      selectInput("zone",
                "Alberta health zones",
                c("All", "Calgary", "Edmonton", "Central", "North", "South"))
    ),
    column(4,
      selectInput("what",
                "Cases to show",
                c("Total"="cases", "Active"="active",
                  "Recovered"="recovered", "Deaths"="deaths"))
    )
  ),
  fluidRow(
    column(6,
      leafletOutput("map", width="100%", height="600px")
    ),
    column(6,
      sliderInput("date", "Date",
        min=as.Date(dimnames(AA)[[2]][1]),
        max=as.Date(dimnames(AA)[[2]][dim(AA)[2]]),
        value=as.Date(dimnames(AA)[[2]][dim(AA)[2]]),
        step=7,
        animate=animationOptions(interval=500)),
      plotlyOutput("plot", width="100%", height="400px"),
      textOutput("excl")
    )
  ),
  includeHTML("footer.html")
)

