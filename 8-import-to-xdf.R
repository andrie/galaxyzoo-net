# import to xdf
library(readr)



galaxy_class <- "data/galaxy_class.csv"
class <- read_csv(galaxy_class, n_max = Inf)

import_xdf <- function(input_files, output_xdf){
  for(ff in input_files){
    message(ff)
    dat <- read_csv(ff, n_max = Inf, 
                    col_types = cols(
                      .default = col_double(),
                      Image = col_character()
                    )
    )
    
    idx <- match(dat$Image, paste0(class$GalaxyID, ".jpg"))
    dat$Class <- class$Class[idx]
    
    first <- ff == input_files[1]
    
    rxDataStep(dat, output_xdf, rowsPerRead = 500, 
               overwrite = first,
               append = if(first) "none" else "rows"
    )
    
  }
}

xdf_train <- RxXdfData("images_train.xdf")
xdf_test  <- RxXdfData("images_test.xdf")

input_train <- list.files(path = "images_csv", 
                          pattern = "flattened_images_.*[1-7].csv", 
                          full.names = TRUE
)

input_test <- list.files(path = "images_csv", 
                          pattern = "flattened_images_.*[8].csv", 
                          full.names = TRUE
)


input_train
input_test

import_xdf(input_train, xdf_train)
import_xdf(input_test, xdf_test)

rxGetInfo(xdf_train)
rxGetInfo(xdf_test)

