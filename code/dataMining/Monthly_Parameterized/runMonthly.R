source("Monthly_Parameterized/getScoredDataMSSQL_specifyDates.R")
source("Monthly_Parameterized/otherModels_specify.R")

runMonthly <- function(startDate, testDate, momEndDate) {
  sectors = 
    c("All", "Health Care", "Information Technology", 
             "Consumer Discretionary", "Financials",                
              "Telecommunication Services", "Utilities",                 
              "Industrials", "Energy", "Materials", "Consumer Staples") 
  # 
  for (sector in sectors) {
    label = paste0("test_", sector, "_", testDate)
    modelLabel = paste0("_", sector, "_", startDate)
    
    dataset = getMonthlyData(sector, startDate, testDate, momEndDate)
    results = runTrainAndTest(dataset, testDate, modelLabel)
    write.csv(results, paste0("../../results/results.", label, ".csv"))
    results$actual = results$bin.diff20
    errorMatrix = getErrorMatrix(results)
    
    getColumns = c("ksvm", "nnet", "rf", "ada", "voted", "voted.prob")
    getColumns = c("actual", getColumns, paste0("PCA_", getColumns))
    for (colprint in getColumns) {
      val = mean(results[results[, colprint] == 1, "diff20"])
      print(paste(colprint, "mean:", val))
      errorMatrix[5, colprint] = val 
    }
    write.csv(errorMatrix, paste0("../../results/errorMatrix.", label, ".csv"))
  }
}

#part of 2008 ########################################################

startDate = '2008-11-01'
testDate = '2008-12-01'
momEndDate = '2009-01-10'
runMonthly(startDate, testDate, momEndDate)

startDate = '2008-12-01'
testDate = '2009-01-04'
momEndDate = '2009-02-10'
runMonthly(startDate, testDate, momEndDate)

#2009 ########################################################
startDate = '2009-01-01'
testDate = '2009-02-01'
momEndDate = '2009-03-10'
runMonthly(startDate, testDate, momEndDate)

startDate = '2009-02-01'
testDate = '2009-03-01'
momEndDate = '2009-04-10'
runMonthly(startDate, testDate, momEndDate)

startDate = '2009-03-01'
testDate = '2009-04-01'
momEndDate = '2009-05-10'
runMonthly(startDate, testDate, momEndDate)

startDate = '2009-04-01'
testDate = '2009-05-03'
momEndDate = '2009-06-10'
runMonthly(startDate, testDate, momEndDate)

startDate = '2009-05-01'
testDate = '2009-06-01'
momEndDate = '2009-07-10'
runMonthly(startDate, testDate, momEndDate)

startDate = '2009-06-01'
testDate = '2009-07-01'
momEndDate = '2009-08-10'
runMonthly(startDate, testDate, momEndDate)

startDate = '2009-07-01'
testDate = '2009-08-02'
momEndDate = '2009-09-10'
runMonthly(startDate, testDate, momEndDate)

startDate = '2009-08-01'
testDate = '2009-09-01'
momEndDate = '2009-10-10'
runMonthly(startDate, testDate, momEndDate)

startDate = '2009-09-01'
testDate = '2009-10-01'
momEndDate = '2009-11-10'
runMonthly(startDate, testDate, momEndDate)

startDate = '2009-10-01'
testDate = '2009-11-01'
momEndDate = '2009-12-10'
runMonthly(startDate, testDate, momEndDate)

startDate = '2009-11-01'
testDate = '2009-12-01'
momEndDate = '2010-01-10' #<- got data?? #think rows shift may be more than 20? cos no data
runMonthly(startDate, testDate, momEndDate)

# #2010 ########################################################
# startDate = '2009-12-01'
# testDate = '2010-01-04'
# momEndDate = '2010-02-10'
# runMonthly(startDate, testDate, momEndDate)
# 
# startDate = '2010-01-01'
# testDate = '2010-02-01'
# momEndDate = '2010-03-10'
# runMonthly(startDate, testDate, momEndDate)
# 
# startDate = '2010-02-01'
# testDate = '2010-03-01'
# momEndDate = '2010-04-10'
# runMonthly(startDate, testDate, momEndDate)
# 
# startDate = '2010-03-01'
# testDate = '2010-04-01'
# momEndDate = '2010-05-10'
# runMonthly(startDate, testDate, momEndDate)
# 
# startDate = '2010-04-01'
# testDate = '2010-05-02'
# momEndDate = '2010-06-10'
# runMonthly(startDate, testDate, momEndDate)
# 
# startDate = '2010-05-01'
# testDate = '2010-06-01'
# momEndDate = '2010-07-10'
# runMonthly(startDate, testDate, momEndDate)
# 
# startDate = '2010-06-01'
# testDate = '2010-07-01'
# momEndDate = '2010-08-10'
# runMonthly(startDate, testDate, momEndDate)
# 
# startDate = '2010-07-01'
# testDate = '2010-08-01'
# momEndDate = '2010-09-10'
# runMonthly(startDate, testDate, momEndDate)
# 
# startDate = '2010-08-01'
# testDate = '2010-09-01'
# momEndDate = '2010-10-10'
# runMonthly(startDate, testDate, momEndDate)
# 
# startDate = '2010-09-01'
# testDate = '2010-10-03'
# momEndDate = '2010-11-10'
# runMonthly(startDate, testDate, momEndDate)
# 
# startDate = '2010-10-01'
# testDate = '2010-11-01'
# momEndDate = '2010-12-10'
# runMonthly(startDate, testDate, momEndDate)
# 
# startDate = '2010-11-01'
# testDate = '2010-12-01'
# momEndDate = '2011-01-10'
# runMonthly(startDate, testDate, momEndDate)
