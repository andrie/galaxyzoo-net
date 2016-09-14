# devtools::install_github("andrie/mxNeuralNetExtra")
library(MicrosoftRML)
# library(mxNeuralNetExtra)

prevModel <- readRDS("scored_model_2016-09-13.rds")

tf <- "reconstructed_net.nn"
z <- reconstructNetDefinition(prevModel, filename = tf)

frm <- prevModel$Formula

galaxy_data <- rxReadXdf("images_test.xdf")


rxSetComputeContext(RxLocalParallel())
rxOptions(numCoresToUse = parallel::detectCores())
system.time({
  model <- mxNeuralNet(frm, galaxy_data,
                       netDefinition = readNetDefinition(tf), 
                       type = "multiClass", 
                       optimizer = maOptimizerSgd(
                         learningRate = 0.05, 
                         lRateRedRatio = 0.9, 
                         lRateRedFreq = 5,
                         momentum = 0.9
                       ),
                       # acceleration = "sse",
                       acceleration = "gpu",
                       miniBatchSize = 64,
                       numIterations = 100,
                       normalize = "No",
                       initWtsDiameter = 0.1
  )
})

