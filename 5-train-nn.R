library(MicrosoftRML)
library(readr)

flat_images  <- "flattened_images_trial_1.csv"
galaxy_class <- "data/galaxy_class.csv"


n_max <- Inf

if(!exists("galaxy_data")){
  galaxy_data <- local({
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
  
  View(galaxy_data)
}
# dim(galaxy_data)

frm <- local({
  
  Vs <- sum(grepl("V\\d", names(galaxy_data)))
  as.formula(paste("Class ~ ", paste0("V", seq_len(Vs),collapse = "+")))
})
# frm











netDefinition <- "
const { T = true; F = false; }
input pixels [3, 50, 50];

hidden conv1 [48, 24, 24] rlinear from pixels convolve {
  InputShape  = [3, 50, 50];
  KernelShape = [3,  5,  5];
  Stride      = [1,  2,  2];
  LowerPad    = [0, 1, 1];
  Sharing     = [T, T, T];
  MapCount    = 48;
}

hidden rnorm1 [48, 11, 11] from conv1 response norm {
  InputShape  = [48, 24, 24];
  KernelShape = [1,   4,  4];
  Stride      = [1,   2,  2];
  LowerPad    = [0, 0, 0];
  Alpha       = 0.0001;
  Beta        = 0.75;
}

hidden pool1 [48, 9, 9] from rnorm1 max pool {
  InputShape  = [48, 11, 11];
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

# 0:00:52 for 200 iterations on  500 observations
# 1:32:24 for 500 iterations on 7698 observations - two conv, hid3 100 nodes, hid 4 30 nodes
# 6:24:16 for 500 iterations on 7698 observations - 2 conv, 1 max pool, 256 nodes, 256 nodes

# model
# summary(model)

saveRDS(model, file = "scored_model_2016-09-12.rds")

x <- mxPredict(model, galaxy_data)
table(x$PredictedLabel)
rxSummary(~Class, galaxy_data)

table(galaxy_data$Class, x$PredictedLabel)
