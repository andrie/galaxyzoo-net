library(MicrosoftRML)
library(readr)

source("code/00-common-functions.R")

galaxy_train <- RxXdfData("data/xdf/images_train.xdf")
galaxy_test  <- RxXdfData("data/xdf/images_test.xdf")

model <- read_last_model("data/modeling/models")

summary_train <- mxPredict(model, galaxy_train, extraVarsToWrite = "Class")
summary_test  <- mxPredict(model, galaxy_test, extraVarsToWrite = "Class")

conf_train <- xtabs(~ Class + PredictedLabel, summary_train)
conf_test  <- xtabs(~ Class + PredictedLabel, summary_test)

conf_train
conf_test


library(ggplot2)
library(magrittr)
dat <- as.data.frame(
  conf_test
)
dat <- within(dat, {
  PredictedLabel <- factor(PredictedLabel, levels = rev(levels(PredictedLabel)))
})

dat %>% 
  ggplot(aes(x = Class, y = PredictedLabel)) + 
  # geom_point(aes(size = Freq, colour = Freq))
  geom_tile(aes(fill = Freq)) +
  scale_fill_continuous(low = "white", high = "blue")

