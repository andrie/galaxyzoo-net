
# Single file import ------------------------------------------------------

create_image_csv <- function(images,
                             output = "flattened_images_trial.csv",
                             size = c(50, 50),
                             rotate_angle = 0
                             
){
  source("0-common-functions.R", local = TRUE)
  
  library(readr)
  library(foreach)
  zz <- data.frame(
    image = "0",
    rbind(rep(NA, size[1] * size[2] * 3)),
    stringsAsFactors = FALSE
  )
  names(zz) <- c("Image", paste0("V", seq_len(size[1] * size[2] * 3)))
  write_csv(zz[-1, ], path = output)
  
  zzz <- foreach(
      i = images, 
      .combine = c, 
      .packages = c("magrittr", "imager"), 
      .inorder = TRUE
    ) %do% {
      z <- read_galaxy_image_name(i) %>% 
        crop_galaxy(0.26) %>% 
        rotate_galaxy(rotate_angle) %>% 
        resize_galaxy(size) %>%  
        flatten_galaxy()
      zz <- data.frame(
        basename(i),
        rbind(as.vector(z)),
        stringsAsFactors = FALSE
      )
      write_csv(zz,
                path = output,
                append = TRUE)
      i
    }
  zzz
}


# Parallel import ---------------------------------------------------------

create_image_csv_par <- function(
  nrows = NA, 
  input = "data/images_training_rev1",
  output = "flattened_images_trial.csv",
  size = c(50, 50),
  rotate_angle = 0,
  cores = 1
  
){
  library(foreach)
  library(doParallel)
  registerDoParallel(cores)
  
  filenames <- list.files(pattern = ".jpg", path = input, full.names = TRUE)
  if(!is.na(nrows)){
    filenames <- filenames[1:nrows]
  }
  ll <- length(filenames)
  
  split_image_names <- function(images, 
                                output, 
                                cores){
    foo <- function(input, cores) {
      x <- seq_along(input)
      (x-1) %/% (length(x)/cores) + 1
    }
    bah <- function(output, cores){
      output <- gsub("\\.csv$", "", output)
      paste0(output, "_", seq_len(cores), ".csv")
    }
    x1 <- split(images, foo(images, cores = cores))
    x2 <- bah(output, cores)
    lapply(seq_len(cores), function(i){
      list(images = x1[[i]], 
           filename = x2[[i]])
    })
  }
  
  split_list <- split_image_names(filenames, output = output, cores = cores)
  
  foreach(sl = split_list,
          .export = "create_image_csv") %dopar% {
    create_image_csv(images = sl$images,
                     output = sl$filename,
                     size = size,
                     rotate_angle = rotate_angle
                     )
  }
  sapply(split_list, "[[", "filename")
}


# Run job -----------------------------------------------------------------

# create_image_csv_par(nrows = NA, 
#                      input = "data/images_training_rev1",
#                      output = "flattened_images_rotated.csv",
#                      size = c(50, 50),
#                      cores = 8)

# create_image_csv_par(nrows = NA, 
#                      input = "data/images_training_rev1",
#                      output = "flattened_images.csv",
#                      size = c(50, 50),
#                      rotate_angle = 0,
#                      cores = 8)


create_image_csv_par(nrows = NA, 
                     input = "data/images_training_rev1",
                     output = "images_csv/flattened_images_rotated.csv",
                     size = c(50, 50),
                     rotate_angle = 90,
                     cores = parallel::detectCores())

#  ------------------------------------------------------------------------

# library(readr)
# gxy <- read_csv("flattened_images_rotated_1.csv")
# layout(t(1:2))
# read_csv("flattened_images_1.csv")[i, -1]         %>% unlist(use.names = FALSE) %>% as.cimg(dims = c(50, 50, 1, 3)) %>% plot_pretty()
# read_csv("flattened_images_rotated_1.csv")[i, -1] %>% unlist(use.names = FALSE) %>% as.cimg(dims = c(50, 50, 1, 3)) %>% plot_pretty()
# layout(1)
