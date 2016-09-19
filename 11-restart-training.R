# devtools::install_github("andrie/mxNeuralNetExtra")
library(MicrosoftRML)
library(mxNeuralNetExtra)

prevModel <- readRDS("scored_model_2016-09-19.rds")

tf <- "reconstructed_net.nn"
z <- reconstructNetDefinition(prevModel, filename = tf)

frm <- prevModel$Formula

galaxy_data <- rxReadXdf("images_train.xdf")


rxSetComputeContext(RxLocalParallel())
rxOptions(numCoresToUse = parallel::detectCores())
system.time({
  model <- mxNeuralNet(frm, galaxy_data,
                       netDefinition = readNetDefinition(tf), 
                       type = "multiClass", 
                       optimizer = maOptimizerAda(decay = 0.99),
                       # acceleration = "sse",
                       acceleration = "gpu",
                       miniBatchSize = 16,
                       numIterations = 50,
                       normalize = "auto",
                       initWtsDiameter = 0.1
  )
})

mxSaveModel(model, "scored_model_2016-09-19a.rds")

x <- mxPredict(model, galaxy_data)
table(x$PredictedLabel)
rxSummary(~Class, galaxy_data)

xtabs(~galaxy_data$Class +x$PredictedLabel)
