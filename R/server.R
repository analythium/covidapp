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
            geom_smooth(method = 'gam')
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
            geom_smooth(method = 'gam')
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
        i <- input$zone
        z <- ets(ABw[[i]])
        plot(forecast(z, 14), main=colnames(ABw)[i],
             xlab="Days since March 6", ylab="Daily new cases")
    })


}
