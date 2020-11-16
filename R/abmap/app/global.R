suppressPackageStartupMessages({
  library(shiny)
  library(shinythemes)
  library(ggplot2)
  library(sp)
  library(leaflet)
  library(htmltools)
  library(plotly)
})

try(load(url("http://hub.analythium.io/covid-19/data/covid-19-abmap.RData")))
load("areas.RData")

setdiff(dimnames(AAA)[[1]], names(Areas$Population))
setdiff(names(Areas$Population), dimnames(AAA)[[1]])
Areas$Areas <- NULL
#Areas$Areas <- AA[names(Areas$Population),]
Areas$Dates <- as.Date(dimnames(AAA)[[2]])

## Areas
AA <- AAA[names(Areas$Population),,]
for (i in 2:dim(AA)[2])
  for (j in 1:4)
    AA[is.na(AA[,i,j]),i,j] <- AA[is.na(AA[,i,j]),i-1,j]

A <- AA
A[] <- 0
for (j in 1:4)
  A[,,j] <- AA[,,j] / (Areas$Population / 1000)
rownames(Ar) <- Ar$new_lower
Ar <- Ar[dimnames(AA)[[1]],]

## Picking Friday for weekly stats
Dt <- as.POSIXlt(as.Date(dimnames(AA)[[2]]))
W <- Dt$wday
St <- colnames(AA)[W == 5] # Friday is 0
Wk <- factor(St[cumsum(W == W[1])], St)

## calculating new cases
AA <- AA[,St,]
A <- A[,St,]
AAn <- AA
AAn[] <- 0
An <- A
An[] <- 0
for (j in 1:4) {
  AAn[,,j] <- cbind(0, t(apply(AA[,,j], 1, diff)))
  An[,,j] <- cbind(0, t(apply(A[,,j], 1, diff)))
}
AAn[AAn < 0] <- 0
An[An < 0] <- 0

get_zone <- function(zone=NULL, new=FALSE) {
    ss <- if (is.null(zone))
      rep(TRUE, length(Areas$Regions)) else Areas$Regions == zone
    out <- if (new) {
        list(cases=AAn[ss,,], incidences=An[ss,,], poly=ABsp[ss,])
    } else {
        list(cases=AA[ss,,], incidences=A[ss,,], poly=ABsp[ss,])
    }
}

make_map <- function(date=NULL, zone=NULL, cases=FALSE,
latestmax=TRUE, new=FALSE, what="cases") {
    Labels <- FALSE
    if (is.null(date))
      date <- dimnames(AA)[[2]][dim(AA)[2]]
    z <- get_zone(zone=zone, new=new)
    p <- z$poly
    p@data$cases <- z$cases[,date,what]
    p@data$incidences <- z$incidences[,date,what]
    p@data$nam <- Ar[as.character(p@data$ID), "new_short"]
    var <- if (cases)
      p@data$cases else p@data$incidences
    if (latestmax) {
      Max <- if (cases) {
        max(z$cases[,ncol(z$cases),what])
      } else {
        max(z$incidences[,ncol(z$incidences),what])
      }
    } else {
      Max <- max(var)
    }
    bins <- seq(0, sqrt(1.1*Max), length.out = 8)^2
    bins <- unique(bins)
    bins[1] <- 0.000001
    bins <- c(0, bins)
    pal <- colorBin("YlOrRd", domain = range(bins), bins = bins)
    Zoom <- if (is.null(zone))
      5 else switch(zone,
                   "Edmonton"=8,
                   "Calgary"=7,
                   "North"=5,
                   6)
    TITLE <- switch(what,
                    "cases"="Total",
                    "active"="Active",
                    "recovered"="Recovered",
                    "deaths"="Deaths")
    WHAT <- switch(what,
                    "cases"="cases",
                    "active"="active cases",
                    "recovered"="recovered cases",
                    "deaths"="deaths")
    labels <- lapply(paste0("<strong>", p@data$nam,
        "</strong><br/>", p@data$cases, if (new) " new " else " ",
        WHAT, " on ", date,
        "<br/>(", round(p@data$incidences, 2), "/1000 individual)"),
        htmltools::HTML)
    bb <- bbox(p)
    leaflet(p) %>%
      setView(mean(bb[1,]), mean(bb[2,]), Zoom) %>%
      addProviderTiles("OpenStreetMap.Mapnik", group = "OpenStreetmap") %>%
      addPolygons(
        fillColor = ~pal(var),
        weight = 1,
        opacity = 1,
        color = ~pal(var),
        dashArray = "",
        fillOpacity = 0.7,
        highlight = highlightOptions(
          weight = 5,
          color = "#666",
          dashArray = "",
          fillOpacity = 0.7,
          bringToFront = TRUE),
        popup = if (Labels) NULL else labels,
        popupOptions = if (Labels) NULL else popupOptions(),
        label = if (!Labels) NULL else labels,
        labelOptions = if (!Labels) NULL else labelOptions(
          style = list("font-weight" = "normal", padding = "3px 8px"),
          textsize = "12px",
          direction = "auto")) %>%
      addLegend(pal = pal, values = 0:max(bins), opacity = 0.7,
        title = if (cases) TITLE else paste0(TITLE, "/1000 person"),
        position = "bottomleft", className = "info legend")
}

make_plot <- function(date=NULL, zone=NULL, cases=FALSE,
new=FALSE, what="cases", active=NULL) {

  if (is.null(date))
    date <- dimnames(AA)[[2]][dim(AA)[2]]
  dat <- if (cases) {
    get_zone(zone=zone, new=new)$cases[,,what]
  } else {
    get_zone(zone=zone, new=new)$incidences[,,what]
  }
  WHAT <- switch(what,
                    "cases"="Total",
                    "active"="Active",
                    "recovered"="Recovered",
                    "deaths"="Deaths")
  YLAB <- paste0(WHAT, if (new) " new cases" else " cases",
      if (cases) "" else " / 1000 people")
  vv <- data.frame(
      Value=as.numeric(dat),
      Date=as.Date(rep(colnames(dat), each=nrow(dat))),
      Key=rep(rownames(dat), ncol(dat)),
      Area=rep(Ar[rownames(dat), "new_short"], ncol(dat)))
  p <- ggplot(vv, aes(x=Date, y=Value, group=Area)) +
      geom_line(colour="grey", show.legend = FALSE) +
      geom_vline(xintercept=as.numeric(as.Date(date))) +
      ylab(YLAB)
  if (!is.null(active))
      p <- p + geom_line(
          aes(x=Date, y=Value), data=vv[vv$Key == active, ],
          colour="red", show.legend = FALSE) +
      labs(title=Ar[active, "new_short"])
  p + theme_minimal()
}
