source("commonUtility.R")
addLibrary()
library(caret)
source("trainAndTest.R")

# testStartDate = '2009-01-01'
runTrainAndTest <- function(dataset, testStartDate) {
col.input = colnames(dataset)[1:(ncol(dataset)-1)]
col.input = col.input[-c(2:3)]

dataset.train = dataset[dataset$Date<as.Date(testStartDate),]
dataset.test = dataset[dataset$Date>=as.Date(testStartDate),]

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
dataset.test = dataset.test[ , col.input]

results = trainAndTest(dataset.train, dataset.test, col.target, col.input)

#pca 
prinComs = prcomp(dataset.train[ , col.input[-1]]) #, scale. = TRUE)
cumulativeProp = summary(prinComs)$importance[3,]
#get num of Principal Components to reach 90%
numPcs = length(cumulativeProp[cumulativeProp<0.9]) + 1 
print(paste0("Using ", numPcs, " Principal Components."))
preProc <- preProcess(dataset.train[ , col.input[-1]], #must all be numeric
                      method = "pca", pcaComp=numPcs)
trainPCA <- predict(preProc, dataset.train[ , col.input[-1]])
col.inputPCA = colnames(trainPCA)
trainPCA <- cbind(dataset.train[,col.input[1]], trainPCA, dataset.train[,col.target])
col.inputPCA = c("DayOfWeek", col.inputPCA)
colnames(trainPCA) = c(col.inputPCA, col.target)
testPCA <- predict(preProc, dataset.test[ , col.input[-1]])
testPCA <- cbind(dataset.test[,col.input[1]], testPCA)
colnames(testPCA) = c(col.inputPCA)

resultsPCA = trainAndTest(trainPCA, testPCA, col.target, col.inputPCA)
colnames(resultsPCA) = paste0("PCA_", colnames(resultsPCA))

actualResults = cbind(actualResults, results, resultsPCA)
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

  #pca
  temp <- as.data.frame(table(results$actual, results$PCA_ksvm))
  errorMatrix$PCA_ksvm = temp$Freq
  temp <- as.data.frame(table(results$actual, results$PCA_nnet))
  errorMatrix$PCA_nnet = temp$Freq
  temp <- as.data.frame(table(results$actual, results$PCA_rf))
  errorMatrix$PCA_rf = temp$Freq
  temp <- as.data.frame(table(results$actual, results$PCA_ada))
  errorMatrix$PCA_ada = temp$Freq
  temp <- as.data.frame(table(results$actual, results$PCA_voted))
  errorMatrix$PCA_voted = temp$Freq
  temp <- as.data.frame(table(results$actual, results$PCA_voted.prob))
  errorMatrix$PCA_voted.prob = temp$Freq
  # save(results, file="results1.Rdata")
  # save(errorMatrix, file = "errorMatrix.Rdata")
  
  #precision = true positive/ all predicted true
  # write.csv(errorMatrix, "errorMatrix.csv")
  return(errorMatrix)
}