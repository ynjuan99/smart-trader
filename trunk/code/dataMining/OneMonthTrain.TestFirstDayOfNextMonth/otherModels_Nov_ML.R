library(rpart)
source("D://et//commonUtility.R")
addLibrary()

source("R/trainAndTest.R")

model.dataset = dataset

col.input = colnames(model.dataset)[1:(ncol(model.dataset)-1)]

columnsToRemove  <- c("BookYieldFY3", "DivRevFY1_3M", "DivRevFY1_6M", "EarningsFY2UpDnGrade_3M", "EarningsFY3UpDnGrade_3M", "EarningsFY1UpDnGrade_6M", "EarningsFY2UpDnGrade_6M", "EarningsFY3UpDnGrade_6M", "EBITDAFY1UpDnGrade_3M", "EBITDAFY2UpDnGrade_3M", "EBITDAFY3UpDnGrade_3M", "EBITDAFY1UpDnGrade_6M", "EBITDAFY2UpDnGrade_6M", "EBITDAFY3UpDnGrade_6M", "DivRatio", "OpCFOverCDiv1Y","EBITDAFY3Std")
col.input = col.input[ !col.input %in% columnsToRemove]

model.dataset$DayOfWeek = as.factor(weekdays(model.dataset$Date))
col.input = c(col.input[-(1:2)], "DayOfWeek")

dataset.train = model.dataset[model.dataset$Date<as.Date('2008-12-01'),]
dataset.test = model.dataset[model.dataset$Date==as.Date('2008-12-01'),]

dataset.train$bin.diff20 = cut(dataset.train$diff20, 
                               quantile(dataset.train$diff20, c(0, 0.8, 1)), 
                               labels=c(0,1), include.lowest=TRUE)
dataset.test$bin.diff20 = cut(dataset.test$diff20, 
                               quantile(dataset.test$diff20, c(0, 0.8, 1)), 
                               labels=c(0,1), include.lowest=TRUE)
dataset.train$diff20 = NULL
dataset.test$diff20 = NULL
col.target = "bin.diff20"

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

#precision = true positive/ all predicted true
write.csv(errorMatrix, "errorMatrix.csv")

dataset.test = model.dataset[model.dataset$Date==as.Date('2008-12-01'),]
results$Date = dataset.test$Date
results$SecId = dataset.test$SecId
results$diff20 = dataset.test$diff20

mean(results[results$nnet == 1, "diff20"])
mean(results[results$actual == 1, "diff20"])
mean(results[, "diff20"])

