od <- setwd("app")
source("global.R")
setwd(od)
library(magick)
library(mapview)

dir.create("_tmp")

cases <- TRUE

## maps
for (i in 1:length(St)) {
  j <- St[i]

  m1 <- make_map(date=j, zone="Edmonton", cases=cases)
  mapshot(m1, file=paste0("_tmp/map-edm-", i, ".png"))
  m2 <- make_map(date=j, zone="Calgary", cases=cases)
  mapshot(m2, file=paste0("_tmp/map-cal-", i, ".png"))

}

## plots
col <- colorRampPalette(
  RColorBrewer::brewer.pal(9, "YlOrRd"))(length(St))
for (i in 1:length(St)) {
  j <- St[i]

  p1 <- make_plot(date=j, filter=TRUE, zone="Edmonton", col=col[i], cases=cases) +
    labs(title=paste("Edmonton", j))
  ggsave(paste0("_tmp/plot-edm-", i, ".png"), p1, width=6, height=5)
  p2 <- make_plot(date=j, filter=TRUE, zone="Calgary", col=col[i], cases=cases) +
    labs(title=paste("Calgary", j))
  ggsave(paste0("_tmp/plot-cal-", i, ".png"), p2, width=6, height=5)

}

for (i in 1:length(St)) {
  j <- St[i]
  f <- paste0("_tmp/",
      c("map-edm-", "map-cal-", "plot-edm-", "plot-cal-", "out-"), i, ".png")
  im <- image_read(f[1:4])
  im <- image_resize(im, geometry_size_pixels(height=600))
  im <- image_border(im, "white", "20x20")
  im1 <- image_append(im[1:2], stack=TRUE)
  im2 <- image_append(im[3:4], stack=TRUE)
  im3 <- image_append(c(im1, im2))

  image_write(im3, f[5])

}

im <- image_read(paste0("_tmp/out-", c(1:length(St), rep(length(St), 5)), ".png"))
an <- image_animate(image_morph(im, 2), fps=5)
image_write(an, "_tmp/ab-covid.gif")

an2 <- image_resize(an, geometry_size_pixels(width=1000))
image_write(an2, "_tmp/ab-covid-sm.gif")
