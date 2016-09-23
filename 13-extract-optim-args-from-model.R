# devtools::install_github("andrie/RMLtools")
library(MicrosoftRML)
library("RMLtools")

list.files(path = "models", pattern = "scored_model.*.rds", full.names = TRUE)
prevModelName <- list.files(path = "models", pattern = "scored_model.*.rds", full.names = TRUE)[13]

optimizer_characteristics <- function(rds){
  prevModel <- readRDS(rds)
  # browser()
  if(!is.null(as.list(prevModel$call)$optimizer)){
    optimizer <- as.list(prevModel$call)$optimizer
    call <- as.list(optimizer)
    
    extract_element <- function(x, name){
      if(is.null(x[[name]])) NA else x[[name]]
    }
    
    data.frame(
      optimizer         = as.character(as.list(optimizer)[[1]]),
      decay             = extract_element(call, "decay"),
      conditioningConst = extract_element(call, "conditioningConst"),
      learningRate      = extract_element(call, "learningRate"),
      lRateRedRatio     = extract_element(call, "lRateRedRatio"),
      lRateRedFreq      = extract_element(call, "lRateRedFreq"),
      momentum          = extract_element(call, "momentum")
    )
  } else {
    data.frame(
      optimizer         = "maOptimizerSgd",
      decay             = NA,
      conditioningConst = NA,
      learningRate      = 0.001,
      lRateRedRatio     = 1.0,
      lRateRedFreq      = 100,
      momentum          = 0
      
    )
  }
}


optimizer_characteristics(prevModelName)

all_models <- list.files(path = "models", pattern = "scored_model.*.rds", full.names = TRUE)
do.call(rbind, lapply(all_models, optimizer_characteristics))
