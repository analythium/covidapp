server <- function(input, output) {

    output$map <- renderLeaflet({
        req(AA, A)
        zone <- if (input$zone == "All")
            NULL else input$zone
        make_map(
            date=as.character(input$date),
            zone=zone,
            cases=!input$incidence,
            latestmax=TRUE,
            new=input$new,
            what=input$what)
    })

    i.active <- NULL
    makeReactiveBinding('i.active')
    ## use input$map_marker_mouseover for hover
    observeEvent(input$map_shape_click,{
        id <- input$map_shape_click
        #pt <- data.frame(X=id$lng, Y=id$lat)
        #coordinates(pt) <- ~ X+Y
        #proj4string(pt) <- proj4string(ABsp)
        i.active <<- as.character(over(
            SpatialPoints(data.frame(X=id$lng, Y=id$lat),
                          CRS(proj4string(ABsp))), ABsp)$ID)
        print(i.active)
    })
    observeEvent(input$zone, {
        i.active <<- NULL
    })

    output$plot <- renderPlotly({
        req(An)
        zone <- if (input$zone == "All")
            NULL else input$zone
        p <- make_plot(
            date=as.character(input$date),
            zone=zone,
            cases=!input$incidence,
            new=input$new,
            what=input$what,
            active=i.active)
        ggplotly(p)
    })

    output$excl <- renderText({
        N <- AAA["na", as.character(input$date), input$what]
        if (is.na(N) || N < 1)
            return(NULL)
        paste(N, if (N > 1) "cases" else "case",
              "without valid postal code are not shown.")
    })

}
