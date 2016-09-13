# import to xdf
library(readr)

input_files <- list.files(pattern = "flattened_images_trial.*.csv")
input_files

xdf_flat <- RxXdfData("flattened_images.xdf")

galaxy_class <- "data/galaxy_class.csv"
class <- read_csv(galaxy_class, n_max = Inf)


for(ff in input_files){
  dat <- read_csv(input_files[1], n_max = Inf, 
                col_types = cols(
                  .default = col_double(),
                  Image = col_character()
                )
  )
  
  idx <- match(dat$Image, paste0(class$GalaxyID, ".jpg"))
  dat$Class <- class$Class[idx]
  
  first <- ff == input_files[1]
  
  rxDataStep(dat, xdf_flat, rowsPerRead = 500, 
             overwrite = first,
             append = if(first) "none" else "rows"
             )
  
}
rxGetInfo(xdf_flat)

