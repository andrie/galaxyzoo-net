# import to xdf
library(readr)



galaxy_class <- "data/xdf/galaxy_class.csv"
class <- read_csv(galaxy_class, n_max = Inf, col_types = cols(specobjid = "c"))
nrow(class)
head(class)
tail(class)


import_xdf <- function(input_files, output_xdf, n_max = Inf){
  for(ff in input_files){
    message(ff)
    dat <- read_csv(ff, n_max = n_max, 
                    col_types = cols(
                      .default = col_double(),
                      Image = col_character()
                    )
    )
    
    idx <- match(dat$Image, paste0(class$specobjid, ".jpg"))
    dat$Class <- class[["gz2class"]][idx]
    dat <- dat[!is.na(dat$Class), ]
    
    first <- ff == input_files[1]
    
    rxDataStep(dat, output_xdf, rowsPerRead = 500, 
               overwrite = first,
               append = if(first) "none" else "rows"
    )
    
  }
}

xdf_train <- RxXdfData("data/xdf/images_train.xdf")
# xdf_train_2 <- RxXdfData("data/xdf/images_train_2.xdf")
xdf_test  <- RxXdfData("data/xdf/images_test.xdf")
# xdf_test_2  <- RxXdfData("data/xdf/images_test_2.xdf")

input_train <- list.files(path = "data/xdf/images_csv", 
                          pattern = "flattened_images_(rotated_90_)*[1-2].csv", 
                          full.names = TRUE
)

# input_train <- list.files(path = "data/xdf/images_csv", 
#                           pattern = "flattened_images_[1].csv", 
#                           full.names = TRUE
# )


input_test <- list.files(path = "data/xdf/images_csv", 
                          pattern = "flattened_images_[8].csv", 
                          full.names = TRUE
)


input_train
input_test

import_xdf(input_train, xdf_train)
# rxReadXdf(xdf_train_2, varsToKeep = "Class")

import_xdf(input_test, xdf_test)

rxGetInfo(xdf_train)
rxGetInfo(xdf_test)

# rxGetInfo(xdf_train_2)
# library(magrittr)
# rxReadXdf(xdf_train_2, varsToKeep = "Class")$Class %>% table() %>% sum()
# rxSummary(~Class, xdf_train_2)
# rxCrossTabs(~Class, xdf_train_2)
# rxGetInfo(xdf_test)
