library(tesseract)
library(magick)

ROOT <- "~/repos/covid-19/data" # need gh-pages branch
if (FALSE) {
png("map.png", width=200, height=100)
op <- par(mar=c(0,0,0,0))
plot(0, type="n", xlim=c(0,2), ylim=c(0,1),
    ann=FALSE, axes=FALSE, xaxs = "i", yaxs = "i")
polygon(c(0,0,1,1),c(0,1,1,0), col=1, border=NA)
#polygon(c(0,0,1,1)+1,c(0,1,1,0), col=2, border=NA)
par(op)
dev.off()
}

map <- image_read("map.png")
eng <- tesseract("hun", options = list(tessedit_char_whitelist = "0123456789"))
im <- list.files(ROOT, full.names=TRUE)

i <- "/Users/Peter/repos/covid-19/data/terkep1118.png"
#i <- "/Users/Peter/repos/covid-19/data/terkep1101.png"
ii <- image_read(i)
gr <- image_convert(ii, type = 'Grayscale')
bw <- image_convert(ii, type = 'Bilevel')



txtc <- tesseract::ocr(ii, engine = eng)
txtb <- tesseract::ocr(bw, engine = eng)
txtg <- tesseract::ocr(gr, engine = eng)
cat(txtc)
cat(txtb)
cat(txtg)
