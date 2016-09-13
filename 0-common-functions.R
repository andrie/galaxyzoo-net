library(jpeg)
library(raster)
library(magrittr)
library(fields)

zoo_images <- function(id, image_dir = "data/images_training_rev1"){
  if(is.numeric(id)){
    imgs <- list.files(pattern = ".jpg", image_dir, full.names = TRUE)
    imgs[id]
  } else {
    imgs <- list.files(pattern = id, image_dir, full.names = TRUE)
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

read_zoo <- function(id){
  z <- readJPEG(zoo_images(id))
  class(z) <- c("galaxyzoo", "array")
  z
}

read_zoo_image_name <- function(file){
  z <- readJPEG(file)
  class(z) <- c("galaxyzoo", "array")
  z
}


plot.galaxyzoo <- function(x, interpolate = FALSE, ...){
  zeroes <- rep(0, 4)
  oldpar <- par(mar = zeroes, mai = zeroes)
  on.exit(par(oldpar))
  plot(0:1, 0:1, type = "n", xaxt = "n", yaxt = "n", bty = "n")
  rasterImage(x, xleft = 0, ybottom = 0, xright = 1, ytop = 1, interpolate = interpolate)
  
}

trim_zoo <- function(x, r = 0.1){
  d1 <- dim(x)[1]
  d2 <- dim(x)[2]
  t1 <- seq(from = (r * d1) + 1, to = ((1-r) * d1), by = 1)
  t2 <- seq(from = (r * d2) + 1, to = ((1-r) * d2), by = 1)
  z <- x[t1, t2, ]
  class(z) <- c("galaxyzoo", "array")
  z
}

ResizeMat <- function(mat, ndim=dim(mat)){
  stopifnot(require(fields))
  
  rescale <- function(x, newrange=range(x)){
    xrange <- range(x)
    mfac <- (newrange[2] - newrange[1]) / (xrange[2] - xrange[1])
    newrange[1] + (x - xrange[1]) * mfac
  }
  
  # input object
  odim <- dim(mat)
  obj <- list(x= 1:odim[1], y=1:odim[2], z= mat)
  
  # output object
  z <- matrix(NA, nrow=ndim[1], ncol=ndim[2])
  ndim <- dim(z)
  
  # rescaling
  ncord <- as.matrix(expand.grid(seq_len(ndim[1]), seq_len(ndim[2])))
  loc <- ncord
  loc[, 1] = rescale(ncord[, 1], c(1, odim[1]))
  loc[, 2] = rescale(ncord[, 2], c(1, odim[2]))
  
  # interpolation
  z[ncord] <- fields::interp.surface(obj, loc)
  
  z
}

resample_zoo <- function(x, dim = c(50, 50)){
  z <- apply(x, 3, function(xx){ ResizeMat(xx, dim)})
  dim(z) <- c(dim[1], dim[2], 3)
  class(z) <- c("galaxyzoo", "array")
  z
}

flatten_zoo <- function(x){
  matrix(as.vector(x), nrow = 1)
}



