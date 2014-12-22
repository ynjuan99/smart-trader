source("Windows_Testing/getScoredDataMSSQL_specifyDates.R")
source("Windows_Testing/otherModels_specify.R")
source("Windows_Testing/getDatesFromDB.R")

# windowstartDate = '2013-11-01' #will check for month start
# windowendDate = '2014-01-01'  #less than but excluded date
# teststartDate = '2013-12-01' #a day inside windowstartDate and windowendDate #will check for month start
runWindow <- function(windowstartDate, windowendDate, teststartDate) {
  sectors = #c("Financials")
    c("Health Care", "Information Technology", 
      "Consumer Discretionary", "Financials",                
      "Telecommunication Services", "Utilities",                 
      "Industrials", "Energy", "Materials", "Consumer Staples")  #"All", 
  windowstartDate = getFirstBizDateEachMonth(windowstartDate, windowendDate)
  if (length(windowstartDate) > 1) 
    windowstartDate = windowstartDate[1]
  testStartDate = getFirstBizDateEachMonth(teststartDate, windowendDate)

  trainingDates = getAllDistinctDatesFactorScore(windowstartDate, testStartDate)
  testingDates = getAllDistinctDatesFactorScore(testStartDate, windowendDate)
    
  for (sector in sectors) {
      #       sector = "Financials"
    print(paste0("Starting run on sector '", sector, "' and test date of '", paste0(testingDates, collapse=","), "'"))
    label = paste0("test_", sector, "_", testingDates[1], "to", testingDates[length(testingDates)])
    modelLabel = paste0("_", sector, "_", trainingDates[1], "to", trainingDates[length(trainingDates)])
      
    train.dataset = getData(sector, trainingDates)
    test.dataset = getData(sector, testingDates)
    
    results = runTrainValidateAndTest(train.dataset, test.dataset, modelLabel)
      #cant write csv cos columns do not match. results is a list.
#       List of 2
#       $ validation:'data.frame':  835 obs. of  20 variables:
#       $ test      :'data.frame':	836 obs. of  17 variables: <- test too diff so NA returned by predict (ksvm null)
#         
    write.csv(results, paste0("results/results.train", modelLabel, ".test",label, ".csv"))
    results$actual = results$bin.output
#       results <-
#         lapply(results, function (result) {
#           result$actual = result$bin.diff20
#         })
    errorMatrix = getErrorMatrix(results)
    
    write.csv(errorMatrix, paste0("results/errorMatrix.", modelLabel, ".test",label, ".csv"))
  }
}
