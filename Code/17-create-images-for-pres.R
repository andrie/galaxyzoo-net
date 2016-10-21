img_file <- list.files(path = "data/raw/sdss_cutout", full.names = TRUE)[1]
img_file <- "data/raw/sdss_cutout/1066307241700780032.jpg"
img_file <- "data/raw/sdss_cutout/950414867288844288.jpg"
img_file <- "data/raw/sdss_cutout/1086577288767629312.jpg"  # spiral
img_file <- "data/raw/sdss_cutout/2365529238020319232.jpg"  # elliptical



source("code/00-common-functions.R")

#  ------------------------------------------------------------------------


# devtools::install_github("andrie/RMLtools")
# plot_pretty <- function(x){
#   # imager:::plot.cimg(x, interpolate = FALSE, xlab = NA, ylab = NA, axes = FALSE, frame.plot = FALSE, asp = 1)
#   plot(x, interpolate = FALSE, axes = FALSE, frame.plot = FALSE, asp = 1, xlab = "", ylab = "")
# }

library(imager)
# library(RMLtools)
library(magrittr)

# load.image(img_file) %>% plot()

img <- load.image(img_file) %>% crop_galaxy(0.25)

layout(matrix(1:2, ncol = 2))
img %>% plot_pretty()
img_small <- img %>% resize_galaxy(c(20, 20)) 
img_small %>% plot_pretty()

for(i in seq(1, 20, length.out = 21)){
  lines(x = c(i, i), y = c(1, 20), col = "grey")
  lines(x = c(1, 20), y = c(i, i), col = "grey")
}

str(img)
kernel <- img_small %>% imsub(x <= 5, y <= 5)
str(kernel)
kernel %>% plot_pretty()


img_small  %>% convolve(kernel) %>% plot_pretty()

layout(matrix(1:4, ncol = 4))
img <- load.image(img_file)
img %>% crop_galaxy(0.25) %>% plot_pretty()
img %>% rotate_galaxy(30) %>% crop_galaxy(0.25) %>%  plot_pretty()
img %>% crop_galaxy(0.1) %>% plot_pretty()
img %>% imsub(x < 300, y < 300) %>%  plot_pretty()




#  ------------------------------------------------------------------------


img %>% at(1:5, 1:5, 1, 1:3) %>% plot_pretty()

img %>% imsub(x %in% 3:5, y %in% 3:5) %>% plot_pretty()

parrots <- load.example("parrots")
imsub(parrots,x < 30) #Only the first 30 columns
imsub(parrots,y < 30) #Only the first 30 rows
imsub(parrots,x < 30,y < 30) #First 30 columns and rows
imsub(parrots, sqrt(x) > 8) #Can use arbitrary expressions
imsub(parrots,x > height/2,y > width/2)  #height and width are defined based on the image
imsub(parrots,cc==1) #Colour axis is "cc" not "c" here because "c" is an important R function
