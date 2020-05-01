library(shiny)
library(shinymaterial)
library(ggplot2)
library(forecast)
library(mefa4)

load(url("http://hub.analythium.io/covid-19/data/covid-19.RData"))

## demography

a <- "node10"
for (i in names(out)) {
    if (!is.null(out[[i]]$style) && out[[i]]$style == "bootstrap")
        a <- i
}
x <- as.data.frame(t(out[[a]]$x$data))
colnames(x) <- c("id", "date", "zone", "gender", "ageclass", "status", "type")
x$id <- as.integer(as.character(x$id))
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
"2020-03-12"="gatherings of more than 250 peoplei n Alberta be cancelled",
"2020-03-17"="Province limits mass gathering. Schools and Universities are closed",
"2020-03-24"="Alberta Health Services changed their approach to testing, to focus on groups at highest risk of local exposure",
"2020-04-20"="Cargill closed its High River beef processing plant")


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

