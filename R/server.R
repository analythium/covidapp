server <- function(input, output) {

    output$plot_demogr <- renderPlot({
        req(x)
        xx <- if (input$zone == "Total")
            x else x[x$zone==input$zone,]
        vct <- Xtab(~ date + gender, xx)
        vct[vct==0] <- 1
        vsm <- Xtab(ages ~ date + gender, xx)
        v <- vsm / vct
        vv <- mefa4::Melt(as(v, "dgCMatrix"))
        colnames(vv) <- c("Date", "Gender", "Age")
        vv$Date <- as.Date(vv$Date)

        p <- ggplot(vv,
                aes(x=Date, y=Age, color=Gender)) +
            geom_line() +
            geom_smooth(method = 'gam') +
            scale_y_continuous(limit=c(0,NA))
        if (input$interv1)
            p <- p +
                geom_vline(xintercept=as.Date(names(interv)[1])) +
                geom_vline(xintercept=as.Date(names(interv)[1])+14, lty=2)
        if (input$interv2)
            p <- p +
                geom_vline(xintercept=as.Date(names(interv)[2])) +
                geom_vline(xintercept=as.Date(names(interv)[2])+14, lty=2)
        if (input$interv3)
            p <- p +
                geom_vline(xintercept=as.Date(names(interv)[3])) +
                geom_vline(xintercept=as.Date(names(interv)[3])+14, lty=2)
        if (input$interv4)
            p <- p +
                geom_vline(xintercept=as.Date(names(interv)[4])) +
                geom_vline(xintercept=as.Date(names(interv)[4])+14, lty=2)
        p
    })

    output$plot_new <- renderPlot({
        req(AB)
        p <- ggplot(AB[AB$Zone==input$zone,],
                aes(x=Date, y=New)) +
            geom_line() +
            geom_smooth(method = 'gam') +
            scale_y_continuous(limit=c(0,NA))
        if (input$interv1)
            p <- p +
                geom_vline(xintercept=as.Date(names(interv)[1])) +
                geom_vline(xintercept=as.Date(names(interv)[1])+14, lty=2)
        if (input$interv2)
            p <- p +
                geom_vline(xintercept=as.Date(names(interv)[2])) +
                geom_vline(xintercept=as.Date(names(interv)[2])+14, lty=2)
        if (input$interv3)
            p <- p +
                geom_vline(xintercept=as.Date(names(interv)[3])) +
                geom_vline(xintercept=as.Date(names(interv)[3])+14, lty=2)
        if (input$interv4)
            p <- p +
                geom_vline(xintercept=as.Date(names(interv)[4])) +
                geom_vline(xintercept=as.Date(names(interv)[4])+14, lty=2)
        p
    })

    output$plot_pred <- renderPlot({
        req(ABw)
        tfun <- function(i)
            as.integer(as.Date(names(interv)[i]) - as.Date("2020-03-06"))
        i <- input$zone
        z <- ets(ABw[[i]])
        plot(forecast(z, 14), main=colnames(ABw)[i],
             xlab="Days since March 6", ylab="Daily new cases")
        if (input$interv1) {
            abline(v=tfun(1))
            abline(v=tfun(1)+14, lty=2)
        }
        if (input$interv2) {
            abline(v=tfun(2))
            abline(v=tfun(2)+14, lty=2)
        }
        if (input$interv3) {
            abline(v=tfun(3))
            abline(v=tfun(3)+14, lty=2)
        }
        if (input$interv4) {
            abline(v=tfun(4))
            abline(v=tfun(4)+14, lty=2)
        }
    })

    output$map <- renderLeaflet({
        req(AA, A)
        zone <- if (input$zone == "Total")
            NULL else input$zone
        make_map(as.character(input$date), zone, !input$incidence)
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
        zone <- if (input$zone == "Total")
            NULL else input$zone
        dat <- if (input$incidence)
            get_zone(zone)$incidences else get_zone(zone)$cases
        #matplot(t(dat), type="l", lty=1, col=1)
        vv <- data.frame(
            Cases=as.numeric(dat),
            Date=as.Date(rep(colnames(dat), each=nrow(dat))),
            Area=rep(rownames(dat), ncol(dat)))
        p <- ggplot(vv, aes(x=Date, y=Cases, group=Area)) +
            geom_line(colour="grey", show.legend = FALSE) +
            geom_vline(xintercept=input$date) +
            ylab(if (input$incidence) "Cases / 1000 people" else "Number of cases")
        if (!is.null(i.active))
            p <- p + geom_line(
                aes(x=Date, y=Cases), data=vv[vv$Area == i.active, ],
                colour="blue", show.legend = FALSE, lwd=2) +
            labs(title=i.active)
        p
    })


}
