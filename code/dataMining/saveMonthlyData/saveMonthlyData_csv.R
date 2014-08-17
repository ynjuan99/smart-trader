source("R/getScoredDataMSSQL_specifyDates.R")
sectors = 
  c("Health Care", "Information Technology", 
    "Consumer Discretionary", "Financials",                
    "Telecommunication Services", "Utilities",                 
    "Industrials", "Energy", "Materials", "Consumer Staples") 
#"All"
for (sector in sectors) {
  for (i in 1:12) {
    #for the year 2009
    if (i<10)
      startDate = paste0("2009-0", i, "-01")
    else
      startDate = paste0("2009-", i, "-01")
    testEndDate = paste(timeLastDayInMonth(startDate))
    momEndDate = as.Date(testEndDate) + 35
    label = paste0("scoredData_", sector, "_", startDate, "_", testEndDate)
    
    dataset = getData(sector, startDate, testEndDate, momEndDate)
    write.csv(dataset, paste0("R//data//", label,".csv"))
  }
}