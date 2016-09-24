library(jpeg)
# library(raster)
library(magrittr)
# library(fields)
library(imager)

galaxy_images <- function(id, image_dir = "data/images_training_rev1"){
  if(is.numeric(id)){
    imgs <- list.files(pattern = ".jpg", path = image_dir, full.names = TRUE)
    imgs[id]
  } else {
    imgs <- list.files(pattern = id, path = image_dir, full.names = TRUE)
    switch(as.character(length(imgs)), 
           "0" = stop("no images found"),
           "1" = imgs,
           {
             warning("multiple matches - returning first")
             imgs[1]
           }
    )
  }
}

read_galaxy <- function(id){
    load.image(galaxy_images(id))
}

read_galaxy_image_name <- function(file){
  load.image(file)
}


plot_pretty <- function(x, interpolate = FALSE, ...){
  zeroes <- rep(0, 4)
  oldpar <- par(mar = zeroes, mai = zeroes)
  on.exit(par(oldpar))
  plot(0:1, 0:1, type = "n", xaxt = "n", yaxt = "n", bty = "n")
  plot(x, interpolate = interpolate)

}

crop_galaxy <- function(x, fraction = 0.1){
  
  dx <- round(fraction * dim(x)[1])
  dy <- round(fraction * dim(x)[2])
  imager::crop.borders(x, nx = dx, ny = dy)
}

resize_galaxy <- function(x, dim = c(50, 50)){
  imager::resize(x, 
                 size_x = dim[1], 
                 size_y = dim[2], 
                 size_z = dim(x)[3], 
                 size_c = dim(x)[4],
                 interpolation_type = 4
  )
}

flatten_galaxy <- function(x){
  matrix(as.vector(x), nrow = 1)
}

rotate_galaxy <- function(x, angle, autocrop = TRUE){
  z <- imager::imrotate(x, angle = angle)
  nx <- (dim(z)[1] - dim(x)[1])/2
  ny <- (dim(z)[2] - dim(x)[2])/2
  crop.borders(z, nx = nx, ny = ny)
}


