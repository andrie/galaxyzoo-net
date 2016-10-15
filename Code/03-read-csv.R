library(readr)

flat_images <- "flattened_images_trial_2.csv"
n_max <- 10 # number of lines to read

x <- read_csv(flat_images, n_max = n_max, 
              col_types = cols(
                .default = col_double(),
                Image = col_character()
              )
)
# x$Record <- as.character(x$Record)
str(x)
dim(x)
View(x)
