library(dplyr)
library(echarts4r)

#u <- jsonlite::fromJSON(
#  "https://hub.analythium.io/covid-19/api/v1/data/canada/regions/")
u <- jsonlite::fromJSON(
  "https://hub.analythium.io/covid-19/api/v1/data/alberta/")
u <- as.data.frame(u$numtotal)
u$Unknown <- NULL
N <- c(Calgary =1622391,
       Central =478050,
       Edmonton =1363653,
       North=484964,
       South=303663)
N <- N[colnames(u)[-1]]
N <- N/1000

z <- NULL
for (i in 1:nrow(u)) {
  val <- as.numeric(u[i,-1])/N
  k <- data.frame(
    day=rep(u$Date[i], ncol(u)-1),
    cases=val,
    zone=names(N))
  k <- k[order(-k$cases),]
  k$order <- letters[1:length(N)]
  k$num <- order(-k$cases)
  z <- rbind(z, k)
}

dates <- u$Date
titles <- list()
for (i in 1:length(dates)){
  titles[[i]] <- list(text = paste0("Alberta COVID-19 cases /1000 individuals on ",dates[i]), textStyle = list(fontSize = 16))
}

z <- z %>%
  group_by(day)
COL <- hcl.colors(5, "Warm")

p <- z %>%
  e_charts(order, timeline=TRUE, reorder=TRUE) %>%
  e_bar(cases, bind=zone,
        #color=COL[2],
        label=list(show=TRUE, formatter = "{b}",
                   position = "insideBottomLeft")) %>%
  e_timeline_opts(
    show = FALSE,
    autoPlay = TRUE,
    playInterval=100,
    tooltip = list(formatter = '{c}')
  ) %>%
  e_timeline_serie(title = titles) %>%
  e_animation(duration.update=100) %>%
  e_flip_coords() %>%
  e_x_axis(axisLine=list(show=FALSE), axisTick=list(show=FALSE),
           axisLabel=list(show=TRUE), position = "top") %>%
  e_y_axis(axisLabel=list(show=FALSE), axisLine=list(show=FALSE),
           axisTick=list(show=FALSE), inverse=TRUE) %>%
  e_visual_map(num,
              calculable=FALSE,
              dimension=4,
              orient= 'horizontal',
              left='center',
              inRange=list(color = c('#E15457', '#D7DA8B')))
#              inRange=list(color = COL))


