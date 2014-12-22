library(caret)
source("Windows_Testing/trainAndTest.R")

static_limit_bin_negative = 1

# testStartDate = '2009-01-01'
runTrainValidateAndTest <- function(train.dataset, test.dataset, label) { #validate.dataset=NULL, 

dataset.train = train.dataset
# dataset.validate = validate.dataset
dataset.test = test.dataset

col.input = colnames(dataset.train)[1:(ncol(dataset.train)-1)]
col.input = col.input[-c(2:3)]

dataset.train$bin.output = cut(dataset.train$output, 
                               quantile(dataset.train$output, 
                                        c(0, 0.8, 1)), 
                               labels=c(0,1), include.lowest=TRUE)
dataset.train[dataset.train$output < static_limit_bin_negative, "bin.output"] = 0

dataset.test$bin.output = cut(dataset.test$output, 
                               quantile(dataset.test$output, c(0, 0.8, 1)), 
                               labels=c(0,1), include.lowest=TRUE)
# dataset.test[dataset.test$output < static_limit_bin_negative, "bin.output"] = 0
actual.testResults = dataset.test[, c("Date", "SecId", "output", "bin.output")]

dataset.train$output = NULL
dataset.test$output = NULL
col.target = "bin.output"

dataset.train = dataset.train[ , c(col.input, col.target)]
# dataset.validate = dataset.validate[ , col.input]
# dataset.test = dataset.test[ , col.input]
dataset.test[ , col.target] = NULL

print("training models")
allModels = trainSaveModels(dataset.train, col.target, col.input, label)

# if (!is.null(validate.dataset)) {
#   dataset.validate$bin.output = cut(dataset.validate$output, 
#                                     quantile(dataset.validate$output, c(0, 0.8, 1)), 
#                                     labels=c(0,1), include.lowest=TRUE)
#   actual.validationResults = dataset.validate[, c("Date", "SecId", "output", "bin.output")]
#   dataset.validate$output = NULL
#   dataset.validate[ , col.target] = NULL
#   print("validating models")
#   validationResults = testModels(allModels, dataset.validate)
#   validationResults$type = "validation"
# }
print("testing models")
testResults = testModels(allModels, dataset.test)
testResults$type = "test"

# #pca 
# data.train.omitNAs = na.omit(dataset.train)
# prinComs = prcomp(data.train.omitNAs[ , col.input[-1]]) #, scale. = TRUE)
# cumulativeProp = summary(prinComs)$importance[3,]
# #get num of Principal Components to reach 90%
# numPcs = length(cumulativeProp[cumulativeProp<0.9]) + 1 
# print(paste0("Using ", numPcs, " Principal Components."))
# preProc <- preProcess(dataset.train[ , col.input[-1]], #must all be numeric
#                       method = "pca", pcaComp=numPcs)
# trainPCA <- predict(preProc, dataset.train[ , col.input[-1]])
# col.inputPCA = colnames(trainPCA)
# trainPCA <- cbind(dataset.train[,col.input[1]], trainPCA, dataset.train[,col.target])
# col.inputPCA = c("DayOfWeek", col.inputPCA)
# colnames(trainPCA) = c(col.inputPCA, col.target)
# testPCA <- predict(preProc, dataset.test[ , col.input[-1]])
# testPCA <- cbind(dataset.test[,col.input[1]], testPCA)
# colnames(testPCA) = c(col.inputPCA)
# 
# resultsPCA = trainAndTest(trainPCA, testPCA, col.target, 
#                           col.inputPCA, paste0("PCA_", label))
# colnames(resultsPCA) = paste0("PCA_", colnames(resultsPCA))

# results = list(validation = cbind(actual.validationResults, validationResults),
#                 test = cbind(actual.testResults, testResults)) #, resultsPCA)
# if (!is.null(validate.dataset)) {
#   results = rbind(cbind(actual.validationResults, validationResults),
#                cbind(actual.testResults, testResults)) #, resultsPCA)
# } else {
  results = cbind(actual.testResults, testResults)
# }
return(results)
}

getErrorMatrix <- function(results) {
#   results.list <- results
  results.list <- split(results, results$type)
  errorMatrix = data.frame()
  
  errorMatrix <- lapply(results.list, function (results) {
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
    
    getColumns = c("ksvm", "nnet", "rf", "ada", "voted", "voted.prob")
    getColumns = c("actual", getColumns) #, paste0("PCA_", getColumns))
    for (colprint in getColumns) {
      val = mean(results[results[, colprint] == 1, "output"])
      print(paste(colprint, "mean:", val))
      errorMatrix[5, colprint] = val 
    }
    
    return(errorMatrix)
  })
  
#   #pca
#   temp <- as.data.frame(table(results$actual, results$PCA_ksvm))
#   errorMatrix$PCA_ksvm = temp$Freq
#   temp <- as.data.frame(table(results$actual, results$PCA_nnet))
#   errorMatrix$PCA_nnet = temp$Freq
#   temp <- as.data.frame(table(results$actual, results$PCA_rf))
#   errorMatrix$PCA_rf = temp$Freq
#   temp <- as.data.frame(table(results$actual, results$PCA_ada))
#   errorMatrix$PCA_ada = temp$Freq
#   temp <- as.data.frame(table(results$actual, results$PCA_voted))
#   errorMatrix$PCA_voted = temp$Freq
#   temp <- as.data.frame(table(results$actual, results$PCA_voted.prob))
#   errorMatrix$PCA_voted.prob = temp$Freq
#   # save(results, file="results1.Rdata")
#   # save(errorMatrix, file = "errorMatrix.Rdata")
  
  #precision = true positive/ all predicted true
  # write.csv(errorMatrix, "errorMatrix.csv")
  return(errorMatrix)
}