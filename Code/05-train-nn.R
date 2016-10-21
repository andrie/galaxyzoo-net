# devtools::install_github("andrie/RMLtools")
library(MicrosoftRML)
library("RMLtools")

galaxy_train <- RxXdfData("data/xdf/images_train.xdf")
galaxy_test  <- RxXdfData("data/xdf/images_test.xdf")

galaxy_data  <- rxReadXdf(galaxy_train, numRows = 10)


frm <- local({
  Vs <- sum(grepl("V\\d", names(galaxy_data)))
  as.formula(paste("Class ~ ", paste0("V", seq_len(Vs), collapse = "+")))
})
# frm

netDefinition <- "
const { T = true; F = false; }
input pixels [3, 50, 50];

hidden conv1 [64, 24, 24] rlinear from pixels convolve {
  InputShape  = [3, 50, 50];
  KernelShape = [3,  5,  5];
  Stride      = [1,  2,  2];
  LowerPad    = [0, 1, 1];
  Sharing     = [F, T, T];
  MapCount    = 64;
}

hidden rnorm1 [64, 12, 12] from conv1 response norm {
  InputShape  = [64, 24, 24];
  KernelShape = [1,   3,  3];
  Stride      = [1,   2,  2];
  LowerPad    = [0, 1, 1];
  Alpha       = 0.0001;
  Beta        = 0.75;
}

hidden pool1 [64, 6, 6] from rnorm1 max pool {
  InputShape  = [64, 12, 12];
  KernelShape = [1, 2, 2];
  Stride      = [1, 2, 2];
}

hidden hid1 [256] rlinear from pool1 all;
hidden hid2 [256] rlinear from hid1 all;
output Class [13] softmax from hid2 all;
"

system.time({
  model <- mxNeuralNet(frm, data = galaxy_train, 
                       netDefinition = netDefinition, 
                       type = "multiClass",
                       optimizer = maOptimizerSgd(
                         learningRate = 0.05,
                         lRateRedRatio = 0.95,
                         lRateRedFreq = 5,
                         momentum = 0.25
                         ),
                       acceleration = "gpu",
                       miniBatchSize = 100,
                       numIterations = 150,
                       normalize = "no",
                   initWtsDiameter = 0.1
  )
})


mxSaveModel(model, sprintf("data/modeling/models/scored_model_%s_fresh.rds", strftime(Sys.time(), format = "%F-%Hh%M")))

summary_train <- mxPredict(model, galaxy_train, extraVarsToWrite = "Class")
summary_test  <- mxPredict(model, galaxy_test, extraVarsToWrite = "Class")

conf_train <- xtabs(~ Class + PredictedLabel, summary_train)
conf_test  <- xtabs(~ Class + PredictedLabel, summary_test)

conf_train
conf_test
