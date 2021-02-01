suppressPackageStartupMessages({
  library(shiny)
  library(shinymaterial)
  library(ggplot2)
  library(forecast)
  library(mefa4)
  library(sp)
  library(leaflet)
  library(htmltools)
  #library(plotly)
})

try(load(url("http://hub.analythium.io/covid-19/data/covid-19.RData")))
load("areas.RData")

#names(Areas$Population) <- gsub(" ", "", tolower(names(Areas$Population)))
#names(Areas$Regions) <- gsub(" ", "", tolower(names(Areas$Regions)))
#levels(ABsp@data$ID) <- gsub(" ", "", tolower(levels(ABsp@data$ID)))

setdiff(rownames(AA), names(Areas$Population))
setdiff(names(Areas$Population), rownames(AA))
Areas$Areas <- AA[names(Areas$Population),]
Areas$Dates <- as.Date(colnames(AA))
#save(ABsp, Areas, file="areas.RData")

## Areas
AA <- Areas$Areas
for (i in 2:ncol(AA))
    AA[is.na(AA[,i]),i] <- AA[is.na(AA[,i]),i-1]
A <- AA / (Areas$Population / 1000)
rownames(Ar) <- Ar$new_lower
Ar <- Ar[rownames(AA),]

get_zone <- function(zone=NULL) {
    ss <- if (is.null(zone))
      rep(TRUE, length(Areas$Regions)) else Areas$Regions == zone
    list(cases=AA[ss,], incidences=A[ss,], poly=ABsp[ss,])
}
#plot(get_zone("Edmonton")$poly)
#matplot(t(get_zone("Edmonton")$cases), type="l", lty=1, col=1)

make_map <- function(date=NULL, zone=NULL, cases=FALSE, latestmax=TRUE) {
    Labels <- FALSE
    if (is.null(date))
      date <- colnames(AA)[ncol(AA)]
    z <- get_zone(zone)
    p <- z$poly
    p@data$cases <- z$cases[,date]
    p@data$incidences <- z$incidences[,date]
    p@data$nam <- Ar[as.character(p@data$ID), "new_short"]
    var <- if (cases)
        p@data$cases else p@data$incidences
    if (latestmax) {
      Max <- if (cases)
          max(z$cases[,ncol(z$cases)]) else max(z$incidences[,ncol(z$incidences)])
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
    labels <- lapply(paste0("<strong>", p@data$nam,
        "</strong><br/>", p@data$cases, " cases on ", date,
        "<br/>(", round(p@data$incidences, 3), "/1000 individual)"), htmltools::HTML)
    bb <- bbox(p)
    leaflet(p) %>%
      setView(mean(bb[1,]), mean(bb[2,]), Zoom) %>%
      addProviderTiles("Esri.OceanBasemap", group = "Esri.OceanBasemap") %>%
      addProviderTiles("CartoDB.DarkMatter", group = "DarkMatter (CartoDB)") %>%
      addProviderTiles("OpenStreetMap.Mapnik", group = "OpenStreetmap") %>%
      addProviderTiles("Esri.WorldImagery", group = "Esri.WorldImagery") %>%
      addLayersControl(baseGroups = c("OpenStreetmap","Esri.OceanBasemap",
        "DarkMatter (CartoDB)", "Esri.WorldImagery"),
        options = layersControlOptions(collapsed = TRUE, autoZIndex = FALSE)) %>%
      addPolygons(
        fillColor = ~pal(var),
        weight = 1,
        opacity = 1,
        color = "white",
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
        title = if (cases) "Cases" else "Cases/1000 person",
        position = "bottomleft", className = "info legend")
}


## demography

PopByZone <- sum_by(Areas$Population, Areas$Regions)[,"x"]
PopByZone <- c(PopByZone, Total=sum(PopByZone))
PopByZone <- PopByZone / 1000

a <- "node11"
for (i in names(out)) {
    if (!is.null(out[[i]]$x$style) && out[[i]]$x$style == "bootstrap")
        a <- i
}
x <- as.data.frame(t(out[[a]]$x$data), stringsAsFactors = TRUE)
#colnames(x) <- c("id", "date", "zone", "gender", "ageclass", "status", "type")
#x$id <- as.integer(as.character(x$id))
colnames(x) <- c("date", "zone", "gender", "ageclass", "status", "type")
x$date <- as.Date(x$date)
x$date <- factor(as.character(x$date),
    as.character(seq(min(x$date), max(x$date), 1)))

Ages <- levels(x$ageclass)
StartYr <- sapply(strsplit(Ages, "-"), "[[", 1)
names(StartYr) <- StartYr
StartYr[c("80+ years", "Under 1 year", "Unknown")] <- c("80", "0", NA)
StartYr <- as.integer(StartYr)
x$ages <- StartYr[as.integer(x$ageclass)]
x <- droplevels(x[!is.na(x$ages) & x$gender != "Unknown" & x$zone != "Unknown",])
levels(x$zone) <- gsub(" Zone", "", levels(x$zone))

## new cases

ab$Date <- as.Date(ab$Date)
Date <- seq(min(ab$Date), max(ab$Date), 1)
AB <- NULL
ABw <- data.frame(Date=Date[-length(Date)])
for (i in colnames(ab)[-1]) {
    tmp <- ab[[i]][match(Date, ab$Date)]
    for (j in which(is.na(tmp)))
        if (j > 1)
            tmp[j] <- tmp[j-1]
    ABi <- data.frame(
        Date=Date[-length(Date)],
        Zone=i,
        New=diff(tmp))
    AB <- rbind(AB, ABi)
    ABw[[i]] <- diff(tmp)
}
ABw[,1] <- NULL
ABi <- data.frame(
        Date=Date[-length(Date)],
        Zone="Total",
        New=rowSums(ABw))
AB <- rbind(AB, ABi)
AB <- droplevels(AB[AB$Zone != "Unknown",])
ABw$Total  <- rowSums(ABw)

interv <- list(
"2020-03-12"="gatherings of more than 250 people in Alberta be cancelled",
"2020-03-17"="Province limits mass gathering. Schools and Universities are closed",
"2020-03-24"="Alberta Health Services changed their approach to testing, to focus on groups at highest risk of local exposure",
"2020-04-20"="Cargill closed its High River beef processing plant",
"2020-05-14"="Stage 1 reopening",
"2020-06-12"="Stage 2 reopening")


## prediction

## calculate PI for lm/glm
predict_sim <-
function(object, newdata=NULL,
interval = c("none", "confidence", "prediction"),
type=c("asymp", "pboot", "npboot"),
level=0.95, B=99, ...) {
    interval <- match.arg(interval)
    type <- match.arg(type)
    if (is.null(newdata)) {
        x <- model.frame(object)
        X <- model.matrix(object)
    } else {
        x <- model.frame(delete.response(terms(object)), newdata)
        X <- model.matrix(attr(x, "terms"), x)
    }
    n <- nrow(x)
    fun <- switch(family(object)$family,
        "gaussian"=function(x) rnorm(length(x), x, summary(object)$sigma),
        "poisson"= function(x) rpois(length(x), x),
        "binomial"=function(x) rbinom(length(x), 1, x))
    if (interval=="none")
        return(predict(object, newdata))
    if (B < 2)
        stop("Are you kidding? B must be > 1")
    if (type == "asymp") {
        cm <- rbind(coef(object),
            MASS::mvrnorm(B, coef(object), vcov(object)))
        fm <- apply(cm, 1, function(z) X %*% z)
    }
    if (type == "boot") {
        cm <- matrix(0, B+1, length(coef(object)))
        cm[1,] <- coef(object)
        xx <- model.frame(object)
        for (i in 2:B) {
            j <- sample.int(n, n, replace=TRUE)
            cm[i,] <- coef(update(object, data=xx[j,]))
        }
        fm <- apply(cm, 1, function(z) X %*% z)
    }
    if (type == "npboot") {
        cm <- matrix(0, B+1, length(coef(object)))
        cm[1,] <- coef(object)
        xx <- model.frame(object)
        j <- attr(attr(xx, "terms"), "response")
        f <- fitted(object)
        for (i in 2:B) {
            xx[,j] <- fun(f)
            cm[i,] <- coef(update(object, data=xx))
        }
        fm <- apply(cm, 1, function(z) X %*% z)
    }
    fm <- family(object)$linkinv(fm)
    if (interval=="prediction") {
        y <- matrix(fun(fm), n, B+1)
    } else {
        y <- fm
    }
    rownames(y) <- rownames(x)
    p <- c(0.5, (1-level)/2, 1-(1-level)/2)
    stat_fun <- function(x)
        c(mean(x), sd(x), quantile(x, p))
    out <- cbind(fm[,1], t(apply(y, 1, stat_fun)))
    colnames(out) <- c("fit", "mean", "se", "median", "lwr", "upr")
    out[,c("fit", "lwr", "upr", "mean", "median", "se")]
}

plot_demogr <- function(zone) {
        xx <- x[x$zone==zone,]
        xx <- droplevels(xx[xx$gender %in% names(rev(sort(table(xx$gender))))[1:2],])
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
            scale_y_continuous(limit=c(0,NA)) +
#            geom_vline(xintercept=as.Date(names(interv)[2])) +
#            geom_vline(xintercept=as.Date(names(interv)[2])+14, lty=2) +
            labs(title=zone)
#        if (zone == "Calgary")
#            p <- p +
#                geom_vline(xintercept=as.Date(names(interv)[4]), colour="red") +
#                geom_vline(xintercept=as.Date(names(interv)[4])+14, colour="red", lty=2)
        p + theme_minimal()
}

plot_new <- function(zone, incidence=FALSE,
                     i1=FALSE, i2=FALSE, i3=FALSE, i4=FALSE,
                     smooth=TRUE) {
        d <- AB[AB$Zone==zone,]
        if (incidence)
            d$New <- d$New / PopByZone[zone]
        p <- ggplot(d,
                aes(x=Date, y=New)) +
            geom_line() +
            scale_y_continuous(limit=c(0,NA)) +
            labs(title=zone)
        if (smooth)
            p <- p + geom_smooth(method = 'gam')

        if (i1)
          p <- p + geom_vline(xintercept=as.Date(names(interv)[2])) +
            geom_vline(xintercept=as.Date(names(interv)[2])+14, lty=2)
        if (i2 && zone == "Calgary")
            p <- p +
              geom_vline(xintercept=as.Date(names(interv)[4]), colour="red") +
              geom_vline(xintercept=as.Date(names(interv)[4])+14, colour="red", lty=2)
        if (i3)
          p <- p + geom_vline(xintercept=as.Date(names(interv)[5]), colour="blue") +
            geom_vline(xintercept=as.Date(names(interv)[5])+14, colour="blue", lty=2)
        if (i4)
          p <- p + geom_vline(xintercept=as.Date(names(interv)[6]), colour="green") +
            geom_vline(xintercept=as.Date(names(interv)[6])+14, colour="green", lty=2)
        p + theme_minimal()
}
