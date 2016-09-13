library(MicrosoftRML)
library(readr)

flat_images  <- "flattened_images_trial_2.csv"
galaxy_class <- "data/galaxy_class.csv"
class <- read_csv(galaxy_class, n_max = n_max)

n_max <- Inf

if(!exists("new_data")){
  new_data <- local({
    dat <- read_csv(flat_images, 
                    skip = 0,
                    n_max = n_max,
                    # col_names = c("Class", paste0("V", seq_len(ncol - 1))),
                    col_types = cols(
                      .default = col_double(),
                      Image = col_character()
                    ))
    
    nrow <- nrow(dat)
    
    class <- read_csv(galaxy_class, n_max = n_max)
    idx <- match(dat$Image, paste0(class$GalaxyID, ".jpg"))
    dat$Class <- class$Class[idx]
    dat
  })
  
  View(new_data)
}

model <- readRDS("scored_model_2016-09-12.rds")

pred <- mxPredict(model, new_data)
# rxSummary(~Class, galaxy_data)

# table(galaxy_data$Class)
table(new_data$Class)
table(pred$PredictedLabel)

table(new_data$Class, pred$PredictedLabel)
xtabs(~ new_data$Class + pred$PredictedLabel)

library(ggplot2)
library(magrittr)
as.data.frame(
  xtabs(~ new_data$Class + pred$PredictedLabel)
) %>% 
  ggplot(aes(x = new_data.Class, y = pred.PredictedLabel)) + 
  geom_point(aes(size = Freq, colour = Freq))

