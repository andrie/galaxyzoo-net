# devtools::install_github("andrie/mxNeuralNetExtra")
library(MicrosoftRML)
# library(mxNeuralNetExtra)

tf <- "reconstructed_net.nn"
prevModel <- readRDS("scored_model_2016-09-13.rds")
# str(prevModel)

z <- reconstructNetDefinition(prevModel, filename = tf)
zz <- readNetDefinition(tf)
zz[1]
scan(text = zz, what = "character", sep = "\n")[3]
# nchar(z)

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
                       numIterations = 5,
                       normalize = "No",
                       initWtsDiameter = 0.1
  )
})


# Loading net from: 
#   (3,20)-(3,21): error: Expected: '<Ident>', Found: ']'
# (5,20)-(5,21): error: Expected: '<Ident>', Found: ']'
# Error: *** Exception: 'Parsing errors'
