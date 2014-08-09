source("R/getScoredDataMSSQL_specifyDates.R")
source("R/otherModels_specify.R")

runMonthly <- function(label, startDate, testDate, momEndDate) {
  dataset = getMonthlyData(startDate, testDate, momEndDate)
  results = runTrainAndTest(dataset, testDate)
  write.csv(results, paste0("R/results/results.", label, ".csv"))
  errorMatrix = getErrorMatrix(results)

  getColumns = c("actual", "ksvm", "nnet", "rf", "ada", "voted", "voted.prob")
  for (colprint in getColumns) {
    val = mean(results[results[, colprint] == 1, "diff20"])
    print(paste(colprint, "mean:", val))
    errorMatrix[5, colprint] = val 
  }
  write.csv(errorMatrix, paste0("R/results/errorMatrix.", label, ".csv"))
}

startDate = '2008-11-01'
testDate = '2008-12-01'
momEndDate = '2009-01-10'
label = paste0("test_", testDate)
runMonthly(label, startDate, testDate, momEndDate)

startDate = '2008-12-01'
testDate = '2009-01-04'
momEndDate = '2009-02-10'
label = paste0("test_", testDate)
runMonthly(label, startDate, testDate, momEndDate)

#2009 ########################################################
startDate = '2009-01-01'
testDate = '2009-02-01'
momEndDate = '2009-03-10'
label = paste0("test_", testDate)
runMonthly(label, startDate, testDate, momEndDate)

startDate = '2009-02-01'
testDate = '2009-03-01'
momEndDate = '2009-04-10'
label = paste0("test_", testDate)
runMonthly(label, startDate, testDate, momEndDate)

startDate = '2009-03-01'
testDate = '2009-04-01'
momEndDate = '2009-05-10'
label = paste0("test_", testDate)
runMonthly(label, startDate, testDate, momEndDate)

startDate = '2009-04-01'
testDate = '2009-05-03'
momEndDate = '2009-06-10'
label = paste0("test_", testDate)
runMonthly(label, startDate, testDate, momEndDate)

startDate = '2009-05-01'
testDate = '2009-06-01'
momEndDate = '2009-07-10'
label = paste0("test_", testDate)
runMonthly(label, startDate, testDate, momEndDate)

startDate = '2009-06-01'
testDate = '2009-07-01'
momEndDate = '2009-08-10'
label = paste0("test_", testDate)
runMonthly(label, startDate, testDate, momEndDate)

startDate = '2009-07-01'
testDate = '2009-08-02'
momEndDate = '2009-09-10'
label = paste0("test_", testDate)
runMonthly(label, startDate, testDate, momEndDate)

startDate = '2009-08-01'
testDate = '2009-09-01'
momEndDate = '2009-10-10'
label = paste0("test_", testDate)
runMonthly(label, startDate, testDate, momEndDate)

startDate = '2009-09-01'
testDate = '2009-10-01'
momEndDate = '2009-11-10'
label = paste0("test_", testDate)
runMonthly(label, startDate, testDate, momEndDate)

startDate = '2009-10-01'
testDate = '2009-11-01'
momEndDate = '2009-12-10'
label = paste0("test_", testDate)
runMonthly(label, startDate, testDate, momEndDate)

startDate = '2009-11-01'
testDate = '2009-12-01'
momEndDate = '2010-01-10'
label = paste0("test_", testDate)
runMonthly(label, startDate, testDate, momEndDate)

