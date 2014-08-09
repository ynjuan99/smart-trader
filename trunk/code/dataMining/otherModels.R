library(rpart)
source("D://et//commonUtility.R")
addLibrary()

source("R/trainAndTest.R")

load("scored_financials_L_2008.Rdata")
dataset$bin.diff20 = cut(dataset$diff20, 
                         quantile(dataset$diff20, c(0, 0.8, 1)), 
                         labels=c(0,1), include.lowest=TRUE)

model.dataset = dataset
model.dataset$diff20 = NULL
col.target = colnames(model.dataset)[109]
col.input = colnames(model.dataset)[1:(ncol(model.dataset)-1)]

columnsToRemove  <- c("BookYieldFY3", "DivRevFY1_3M", "DivRevFY1_6M", "EarningsFY2UpDnGrade_3M", "EarningsFY3UpDnGrade_3M", "EarningsFY1UpDnGrade_6M", "EarningsFY2UpDnGrade_6M", "EarningsFY3UpDnGrade_6M", "EBITDAFY1UpDnGrade_3M", "EBITDAFY2UpDnGrade_3M", "EBITDAFY3UpDnGrade_3M", "EBITDAFY1UpDnGrade_6M", "EBITDAFY2UpDnGrade_6M", "EBITDAFY3UpDnGrade_6M", "DivRatio", "OpCFOverCDiv1Y","EBITDAFY3Std")
col.input = col.input[ !col.input %in% columnsToRemove]

model.dataset$DayOfWeek = as.factor(weekdays(model.dataset$Date))
col.input = c(col.input[-(1:2)], "DayOfWeek")

dataset.train = model.dataset[model.dataset$Date<as.Date('2008-12-01'),]
dataset.test = model.dataset[model.dataset$Date>as.Date('2008-11-30'),]

dataset.train = dataset.train[ , c(col.input, col.target)]
dataset.test = dataset.test[ , c(col.input, col.target)]

results = trainAndTest(dataset.train, dataset.test, col.target, col.input)

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
save(results, file="results1.Rdata")
save(errorMatrix, file = "errorMatrix.Rdata")

# actual = dataset.test[, col.target]
# dataset.test[, col.target] = NULL
# 
# errorMatrix <- as.data.frame(table(actual, actual))
# colnames(errorMatrix) = c("Actual", "Predicted", "actual")

# 
# 
# 
# 
# 
# 
# # Random Forest 
# model.rf <- randomForest(as.formula(concatenate("as.factor(", concatenate(col.target,") ~ ."))),
#                          data=dataset.train,
#                          ntree=500,
#                          mtry=14,
#                          importance=TRUE,
#                          na.action=na.roughfix,
#                          replace=FALSE)
# 
# 
# temp <- as.data.frame(table(actual, predict(model.rf, dataset.test, type="class")))
# label = "RandomForest"
# errorMatrix[,label] = temp$Freq
# 
# # Build a Support Vector Machine model.
# model.ksvm <- ksvm(as.formula(concatenate("as.factor(", concatenate(col.target,") ~ ."))),
#                    data=dataset.train,
#                    kernel="rbfdot",
#                    prob.model=TRUE)
# 
# temp <- as.data.frame(table(actual, predict(model.ksvm, dataset.test)))
# label = "KSVM"
# errorMatrix[,label] = temp$Freq
# 
# #neutral net
# #using Sum of Squares Residuals to get best number for Hidden Layer Nodes
# sumSquaresResiduals = 99999999999
# nohiddenNodes = 0
# for(hiddenNodes in 101:120) { #round(length(col.input)*0.12)) {
#   set.seed(STATIC_SEED)
#   tempModel <- nnet(as.formula(concatenate("as.factor(", concatenate(col.target,") ~ ."))),
#                     data=dataset.train,
#                     size=hiddenNodes, skip=TRUE, MaxNWts=10000, trace=FALSE, maxit=100)
#   cat(sprintf("Sum of Squares Residuals: %.4f for %d hidden layer nodes.\n",
#               sum(residuals(tempModel) ^ 2), hiddenNodes))    
#   tempsumSquaresResiduals = sum(residuals(tempModel) ^ 2)
#   if (tempsumSquaresResiduals < sumSquaresResiduals) {
#     sumSquaresResiduals = tempsumSquaresResiduals
#     nohiddenNodes = hiddenNodes
#   }
#   cat(sprintf("Results - actual)^2) is %.4f \n",
#               (predict(tempModel, dataset.test) - actual) ^ 2))
# }
# #   nohiddenNodes = 18
# cat(sprintf("Using NN Model with %d hidden layer nodes.\n", nohiddenNodes))
# model.nnet <- nnet(as.formula(concatenate("as.factor(", concatenate(col.target,") ~ ."))),
#                    data=model.dataset,
#                    size=nohiddenNodes, skip=TRUE, MaxNWts=10000, trace=FALSE, maxit=100)
