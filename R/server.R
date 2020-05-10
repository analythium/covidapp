server <- function(input, output) {

    output$plot_demogr1 <- renderPlot({
        req(x)
        plot_demogr("Edmonton")
    })
    output$plot_demogr2 <- renderPlot({
        req(x)
        plot_demogr("Calgary")
    })

    output$plot_new <- renderPlot({
        req(AB)
        plot_new(input$zone, input$incidence)
    })
    output$plot_new1 <- renderPlot({
        req(AB)
        plot_new("Edmonton", i1=input$interv1)
    })
    output$plot_new2 <- renderPlot({
        req(AB)
        plot_new("Calgary", i1=input$interv2, i2=input$interv3)
    })

    output$plot_pred <- renderPlot({
        req(ABw)
        tfun <- function(i)
            as.integer(as.Date(names(interv)[i]) - as.Date("2020-03-06"))
        i <- input$zone
        y <- ABw[[i]]
        if (input$incidence)
            y <- y / PopByZone[input$zone]
        z <- ets(y)
        f <- forecast(z, 14)
        plot(f, main=colnames(ABw)[i],
             xlab="Days since March 6", ylab="Daily new cases",
             ylim=c(0, max(f$upper, y)))
#        abline(v=tfun(2))
#        abline(v=tfun(2)+14, lty=2)
#        if (input$zone == "Calgary") {
#            abline(v=tfun(4), col=2)
#            abline(v=tfun(4)+14, lty=2, col=2)
#        }
    })

    output$map <- renderLeaflet({
        req(AA, A)
        zone <- if (input$zone2 == "Total")
            NULL else input$zone2
        make_map(as.character(input$date), zone, !input$incidence2)
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
            SpatialPoints(data.frame(X=id$lng, Y=id$lat), CRS(proj4string(ABsp))), ABsp)$ID)
        print(i.active)
    })

    output$plot_time <- renderPlot({
        req(AA, A)
        zone <- if (input$zone2 == "Total")
            NULL else input$zone2
        dat <- if (input$incidence2)
            get_zone(zone)$incidences else get_zone(zone)$cases
        #matplot(t(dat), type="l", lty=1, col=1)
        vv <- data.frame(
            Cases=as.numeric(dat),
            Date=as.Date(rep(colnames(dat), each=nrow(dat))),
            Area=rep(rownames(dat), ncol(dat)))
        p <- ggplot(vv, aes(x=Date, y=Cases, group=Area)) +
            geom_line(colour="grey", show.legend = FALSE) +
            geom_vline(xintercept=input$date) +
            ylab(if (input$incidence2) "Cases / 1000 people" else "Number of cases")
        if (!is.null(i.active))
            p <- p + geom_line(
                aes(x=Date, y=Cases), data=vv[vv$Area == i.active, ],
                colour="blue", show.legend = FALSE, lwd=2) +
            labs(title=i.active)
        p
    })


}
