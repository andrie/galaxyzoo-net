model <- readRDS("scored_model_2016-09-09.rds")
str(model)
cat(model$mamlCode)
model
print(model)
summary(model)

x <- MicrosoftRML:::mxModelSummary(model)
cat(x$keyValuePairs$Layers)
str(MicrosoftRML:::mxModelSummary(model))
