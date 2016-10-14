# devtools::install_github("andrie/RMLtools")
library(MicrosoftRML)
library("RMLtools")

if(!exists("galaxy_data")) galaxy_data <- rxReadXdf("images_train.xdf")

frm <- local({
  Vs <- sum(grepl("V\\d", names(galaxy_data)))
  as.formula(paste("Class ~ ", paste0("V", seq_len(Vs), collapse = "+")))
})
# frm

# netDefinition <- "
# const { T = true; F = false; }
# input pixels [3, 50, 50];
# 
# hidden conv1 [48, 24, 24] rlinear from pixels convolve {
#   InputShape  = [3, 50, 50];
#   KernelShape = [3,  5,  5];
#   Stride      = [1,  2,  2];
#   LowerPad    = [0, 1, 1];
#   Sharing     = [T, T, T];
#   MapCount    = 48;
# }
# 
# hidden rnorm1 [48, 11, 11] from conv1 response norm {
#   InputShape  = [48, 24, 24];
#   KernelShape = [1,   4,  4];
#   Stride      = [1,   2,  2];
#   LowerPad    = [0, 0, 0];
#   Alpha       = 0.0001;
#   Beta        = 0.75;
# }
# 
# hidden pool1 [48, 9, 9] from rnorm1 max pool {
#   InputShape  = [48, 11, 11];
#   KernelShape = [1, 3, 3];
#   Stride      = [1, 1, 1];
# }
# 
# hidden hid1 [256] rlinear from pool1 all;
# hidden hid2 [256] rlinear from hid1 all;
# output Class [6] from hid2 all;
# "


netDefinition <- "
const { T = true; F = false; }
input pixels [3, 50, 50];

hidden conv1 [64, 24, 24] rlinear from pixels convolve {
  InputShape  = [3, 50, 50];
  KernelShape = [3,  5,  5];
  Stride      = [1,  2,  2];
  LowerPad    = [0, 1, 1];
  Sharing     = [T, T, T];
  MapCount    = 64;
}

hidden rnorm1 [64, 11, 11] from conv1 response norm {
  InputShape  = [64, 24, 24];
  KernelShape = [1,   4,  4];
  Stride      = [1,   2,  2];
  LowerPad    = [0, 0, 0];
  Alpha       = 0.0001;
  Beta        = 0.75;
}

hidden pool1 [64, 9, 9] from rnorm1 max pool {
  InputShape  = [64, 11, 11];
  KernelShape = [1, 3, 3];
  Stride      = [1, 1, 1];
}

hidden hid1 [256] rlinear from pool1 all;
hidden hid2 [256] rlinear from hid1 all;
output Class [6] from hid2 all;
"

rxSetComputeContext(RxLocalParallel())
rxOptions(numCoresToUse = parallel::detectCores())
system.time({
  model <- mxNeuralNet(frm, data = galaxy_data,
                       netDefinition = netDefinition, 
                       type = "multiClass",
                       # optimizer = maOptimizerSgd(
                       #   learningRate = 0.05,
                       #   lRateRedRatio = 0.95,
                       #   lRateRedFreq = 5,
                       #   momentum = 0.25
                       #   ),
                       optimizer = maOptimizerAda(decay = 0.99, conditioningConst = 1E-07),
                       # acceleration = "sse",
                       acceleration = "gpu",
                       miniBatchSize = 32,
                       numIterations = 50,
                       normalize = "no",
                   initWtsDiameter = 0.1
  )
})


mxSaveModel(model, sprintf("models/scored_model_%s_fresh.rds", strftime(Sys.time(), format = "%F-%Hh%M")))

summary_train <- mxPredict(model, galaxy_data, extraVarsToWrite = "Class")
xtabs(~ Class + PredictedLabel, summary_train)

if(!exists("galaxy_test")) galaxy_test <- rxReadXdf("images_test.xdf")
summary_test <- mxPredict(model, galaxy_test, extraVarsToWrite = "Class")
xtabs(~ Class + PredictedLabel, summary_test)
