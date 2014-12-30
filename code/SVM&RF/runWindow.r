source("Windows_Testing2/getScoredDataMSSQL_specifyDates.R")
source("Windows_Testing2/otherModels_specify.R")
source("Windows_Testing2/getDatesFromDB.R")
channel <- odbcConnect("localDB")
# windowstartDate = '2013-11-01' #will check for month start
# windowendDate = '2014-01-01' #less than but excluded date
# teststartDate = '2013-12-01' #a day inside windowstartDate and windowendDate #will check for month start
runWindow <- function(windowstartDate, windowendDate, teststartDate, windowMth) {
  sectors = #c("Health Care")
    c("Health Care", "Information Technology",
      "Consumer Discretionary", "Financials",
      "Telecommunication Services", "Utilities",
      "Industrials", "Energy", "Materials", "Consumer Staples") #"All",
  windowstartDate = getFirstBizDateEachMonth(windowstartDate, windowendDate)
  if (length(windowstartDate) > 1)
    windowstartDate = windowstartDate[1]
  testStartDate = getFirstBizDateEachMonth(teststartDate, windowendDate)
  
  trainingDates = getAllDistinctDatesFactorScore(windowstartDate, testStartDate)
  testingDates = getAllDistinctDatesFactorScore(testStartDate, windowendDate)
  
  for (sector in sectors) {
    # sector = "Health Care"
    print(paste0("Starting run on sector '", sector, "' and test date of '", paste0(testingDates, collapse=","), "'"))
    cat(paste("\n","--------------------------------------------------------------------------------------",sep=""));
    cat(paste("\n",substring(date(),5,19)," ::::: Modeling by Sector", sector, " as of ",testingDates[1],sep=""));
    label = paste0("test_", sector, "_", testingDates[1], "to", testingDates[length(testingDates)])
    modelLabel = paste0("_", sector, "_", trainingDates[1], "to", trainingDates[length(trainingDates)])
    
    train.dataset = getData(sector, trainingDates)
    test.dataset = getData(sector, testingDates)
    testingDates=testingDates[order(testingDates)]
    results = runTrainValidateAndTest(train.dataset, test.dataset, modelLabel)
    
    # Add window and sector column and export to SQL
    results = data.frame(results,windowMth=windowMth,Sector=sector)
    deleter=sqlQuery(channel, paste("DELETE
                              FROM dbo.tb_StockPrediction where windowMth=", windowMth, " and sector='", sector,
                              "' and Date>='", testingDates[1], "' and Date<='" , testingDates[length(testingDates)], "'", sep=""))
    sqlSave(channel, dat=results, tablename="tb_StockPrediction", rownames=F, varTypes=c(Date="datetime"), append=T)
    #
    
    #cant write csv cos columns do not match. results is a list.
    # List of 2
    # $ validation:'data.frame': 835 obs. of 20 variables:
    # $ test :'data.frame': 836 obs. of 17 variables: <- test too diff so NA returned by predict (ksvm null)
    #
    
    # Temporarily blank out
    #write.csv(results, paste0("results/results.train", modelLabel, ".test",label, ".csv"))
    #results$actual = results$bin.output
    
    # results <-
    # lapply(results, function (result) {
    # result$actual = result$bin.diff20
    # })
    
    # Temporarily blank out
    #errorMatrix = getErrorMatrix(results)
    #write.csv(errorMatrix, paste0("results/errorMatrix.", modelLabel, ".test",label, ".csv"))
  }
}
