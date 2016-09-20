# devtools::install_github("andrie/RMLtools")
library(MicrosoftRML)
library("RMLtools")

prevModelName <- tail(list.files(pattern = "scored_model.*.rds"), 1)
prevModel <- readRDS(prevModelName)

tf <- "reconstructed_net.nn"
z <- reconstructNetDefinition(prevModel, filename = tf)

frm <- prevModel$Formula

if(!exists("galaxydata")) galaxy_data <- rxReadXdf("images_train.xdf")


rxSetComputeContext(RxLocalParallel())
rxOptions(numCoresToUse = parallel::detectCores())
system.time({
  model <- mxNeuralNet(frm, galaxy_data,
                       netDefinition = readNetDefinition(tf), 
                       type = "multiClass", 
                       optimizer = maOptimizerAda(decay = 0.99),
                       # acceleration = "sse",
                       acceleration = "gpu",
                       miniBatchSize = 32,
                       numIterations = 50,
                       normalize = "auto",
                       initWtsDiameter = 0.1
  )
})

mxSaveModel(model, sprintf("scored_model_%s.rds", strftime(Sys.time(), format = "%F-%Hh%M")))

summary_train <- mxPredict(model, galaxy_data, extraVarsToWrite = "Class")
xtabs(~ Class + PredictedLabel, summary_train)

if(!exists("galaxy_test")) galaxy_test <- rxReadXdf("images_test.xdf")
summary_test <- mxPredict(model, galaxy_test, extraVarsToWrite = "Class")
xtabs(~ Class + PredictedLabel, summary_test)
