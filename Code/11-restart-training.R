# devtools::install_github("andrie/RMLtools")
library(MicrosoftRML)
library("RMLtools")
source("data/00-common-functions.R")

prevModel <- read_last_model("data/modeling/models")

tf <- "reconstructed_net.nn"
z <- reconstructNetDefinition(prevModel, filename = tf)

frm <- prevModel$Formula

galaxy_train <- RxXdfData("data/xdf/images_train.xdf")
galaxy_test  <- RxXdfData("data/xdf/images_test.xdf")


system.time({
  model <- mxNeuralNet(frm, galaxy_train,
                       netDefinition = readNetDefinition(tf), 
                       type = "multiClass", 
                       optimizer = maOptimizerSgd(
                         learningRate = 0.05*(0.95)^(50/5),
                         lRateRedRatio = 0.95,
                         lRateRedFreq = 5,
                         momentum = 0.25
                       ),
                       acceleration = "gpu",
                       miniBatchSize = 100,
                       numIterations = 100,
                       normalize = "no",
                       initWtsDiameter = 0.1
  )
})

mxSaveModel(model, sprintf("data/modeling/models/scored_model_%s.rds", strftime(Sys.time(), format = "%F-%Hh%M")))

summary_train <- mxPredict(model, galaxy_train, extraVarsToWrite = "Class")
xtabs(~ Class + PredictedLabel, summary_train)

summary_test <- mxPredict(model, galaxy_test, extraVarsToWrite = "Class")
xtabs(~ Class + PredictedLabel, summary_test)


