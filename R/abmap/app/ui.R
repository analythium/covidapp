ui <- fluidPage(
  tags$head(includeHTML("ga.html")),
  theme = shinytheme("cosmo"),
  HTML("<p>COVID-19 cases in Alberta by geographic areas and date reported to <a href='https://covid19stats.alberta.ca/' target=_blank>Alberta Health</a>. Weekly aggregates are presented because data were not always updated on weekends. New cases are defined as the increase in the number of cases since the previous week. Incidence (cases / 1000 person) is given as the case numbers standardized by population size in an area. The total number of cases is the sum of active, recovered cases, and deaths.</p>"),
  fluidRow(
    column(4,
      checkboxInput("new", "Show new cases", FALSE),
      checkboxInput("incidence", "Show cases per 1000 person (incidence)", FALSE)
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
      leafletOutput("map", width="100%", height="500px")
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

