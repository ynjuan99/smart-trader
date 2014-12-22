modelsDir = "models/"

#       sector = "All"
# trainDate = "2009-06-09"
loadModels <- function(sector, trainDate) {
  modelLabel = paste0("_", sector, "_", trainDate)
  
  modelsUsed = c("model.ksvm", "model.nnet", "model.rf", "model.ada")
  for (model in modelsUsed) {
    load(paste0(modelsDir, model, modelLabel, ".Rdata"))
  }
  allModels = list(model.ksvm=model.ksvm, model.nnet=model.nnet, 
                   model.rf=model.rf, model.ada=model.ada)      
}
# allModels = loadModels(sector, trainDate)

library(dplyr)
xx <- 
  priceMom %>%
  group_by(SecId) %>%
  summarize(count=n())

yy <- 
  data %>%
  group_by(SecId) %>%
  summarize(count=n())


xx = list(model.ksvm=model.ksvm, model.ada=model.ada) 
str(xx,max.level = 1)
summary(xx$model.ada)
