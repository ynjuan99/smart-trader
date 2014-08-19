library(rpart)
source("commonUtility.R")
addLibrary()

source("trainAndTest.R")

# model.dataset = dataset
runTrainAndTest <- function(model.dataset, testDate) {
col.input = colnames(model.dataset)[1:(ncol(model.dataset)-1)]
col.input = col.input[-c(2:3)]

dataset.train = model.dataset[model.dataset$Date<as.Date(testDate),]
dataset.test = model.dataset[model.dataset$Date==as.Date(testDate),]

dataset.train$bin.diff20 = cut(dataset.train$diff20, 
                               quantile(dataset.train$diff20, c(0, 0.8, 1)), 
                               labels=c(0,1), include.lowest=TRUE)
dataset.test$bin.diff20 = cut(dataset.test$diff20, 
                               quantile(dataset.test$diff20, c(0, 0.8, 1)), 
                               labels=c(0,1), include.lowest=TRUE)
actualResults = dataset.test[, c("Date", "SecId", "diff20", "bin.diff20")]

dataset.train$diff20 = NULL
dataset.test$diff20 = NULL
col.target = "bin.diff20"

dataset.train = dataset.train[ , c(col.input, col.target)]
dataset.test = dataset.test[ , c(col.input, col.target)]

results = trainAndTest(dataset.train, dataset.test, col.target, col.input)

actualResults = cbind(actualResults, results)
return(actualResults)
}

getErrorMatrix <- function(results) {
  errorMatrix <- as.data.frame(table(results$actual, results$actual))
  colnames(errorMatrix) = c("Actual", "Predicted", "actual")
  #   temp <- as.data.frame(table(results$actual, results$rpart))
  #   errorMatrix$rpart = temp$Freq
  temp <- as.data.frame(table(results$actual, results$ksvm))
  errorMatrix$ksvm = temp$Freq
  temp <- as.data.frame(table(results$actual, results$nnet))
  errorMatrix$nnet = temp$Freq
  temp <- as.data.frame(table(results$actual, results$rf))
  errorMatrix$rf = temp$Freq
  temp <- as.data.frame(table(results$actual, results$ada))
  errorMatrix$ada = temp$Freq
  temp <- as.data.frame(table(results$actual, results$voted))
  errorMatrix$voted = temp$Freq
  temp <- as.data.frame(table(results$actual, results$voted.prob))
  errorMatrix$voted.prob = temp$Freq
  # save(results, file="results1.Rdata")
  # save(errorMatrix, file = "errorMatrix.Rdata")
  
  #precision = true positive/ all predicted true
  # write.csv(errorMatrix, "errorMatrix.csv")
  return(errorMatrix)
}