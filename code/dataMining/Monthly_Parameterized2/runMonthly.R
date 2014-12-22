source("Monthly_Parameterized2/getScoredDataMSSQL_specifyDates.R")
source("Monthly_Parameterized2/otherModels_specify.R")
source("Monthly_Parameterized2/getDatesFromDB.R")

#data starts from '2008-11-01' to '2010-01-01'
runMonthlyFirstBizDates <- function(startDate, endDate) {
  sectors = c("Financials")
#     c("All", "Health Care", "Information Technology", 
#       "Consumer Discretionary", "Financials",                
#       "Telecommunication Services", "Utilities",                 
#       "Industrials", "Energy", "Materials", "Consumer Staples") 
  firstDates = getFirstBizDateEachMonth(startDate, endDate)
  
  for (testDate in firstDates) {
    #     testDate = '2009-03-02'
    dates_41days = getDates_41bizdays(testDate)
    trainingDates = dates_41days[1:20]
    momentumDates = dates_41days[21:40]
    validation.trainDate = dates_41days[21]
    validation.momDate = dates_41days[41]
    testing.trainDate = testDate
    testing.momDate = getMomDate(testDate)
    
    for (sector in sectors) {
      #       sector = "All"
      print(paste0("Starting run on sector '", sector, "' and test date of '", testDate, "'"))
      label = paste0("test_", sector, "_", testDate)
      modelLabel = paste0("_", sector, "_", trainingDates[1])
      
      train.dataset = getData(sector, trainingDates, momentumDates)
      validate.dataset = getData(sector, validation.trainDate, validation.momDate)
      write.csv(validate.dataset, file=paste0("singleDayData/data_", sector, "_", validation.trainDate, ".csv"))
      test.dataset = getData(sector, testing.trainDate, testing.momDate)
      write.csv(test.dataset, file=paste0("singleDayData/data_", sector, "_", testing.trainDate, ".csv"))
      
      results = runTrainValidateAndTest(train.dataset, validate.dataset, test.dataset, modelLabel)
      #cant write csv cos columns do not match. results is a list.
#       List of 2
#       $ validation:'data.frame':  835 obs. of  20 variables:
#       $ test      :'data.frame':	836 obs. of  17 variables: <- test too diff so NA returned by predict (ksvm null)
#         
      write.csv(results, paste0("results/results.", label, ".csv"))
      results$actual = results$bin.diff20
#       results <-
#         lapply(results, function (result) {
#           result$actual = result$bin.diff20
#         })
      errorMatrix = getErrorMatrix(results)
      
      write.csv(errorMatrix, paste0("results/errorMatrix.", label, ".csv"))
    }
  }
}
# runMonthlyFirstBizDates('2009-01-01', '2009-02-01' )

# runMonthlyFirstBizDates('2009-01-01', '2010-01-01' )
runMonthlyFirstBizDates('2009-04-01', '2009-08-10' )

#test date of '2009-03-02' cannot 