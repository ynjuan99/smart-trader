library(RODBC);

getFirstBizDateEachMonth <- function(startDateIncluded, endDateExcluded) {
  channel <- odbcConnect("localDB") 
  cal.dates <- sqlQuery(channel, paste0("
                         SELECT *
                         FROM [S&P].[dbo].[tb_Calendar]
                         WHERE [CalendarDate] >= '", startDateIncluded, 
                         "' AND [CalendarDate] < '", endDateExcluded,
                         "'"))
  as.character(cal.dates[cal.dates$IsBizMonthBeg == 1,"CalendarDate"])
}

# xx = getFirstBizDateEachMonth('2008-01-01', '2010-01-01')

getAllDistinctDatesFactorData <- function() {
  channel <- odbcConnect("localDB") 
  cal.dates <- sqlQuery(channel, "Select Distinct Date
                        FROM [S&P].[dbo].[tb_FactorData]
                        order by Date")
  return(cal.dates)
}
allDistinctDates = getAllDistinctDatesFactorData()

getDates_41bizdays <- function(testdate) {
  rowNo <- which(allDistinctDates == testdate)-41
  as.character(allDistinctDates[rowNo:(rowNo+40),]) #so not inclusive of testdate itself
}

# getTrainingDates_41bizdaysb4('2008-01-02')

getMomDate <- function(testdate) {
  as.character(allDistinctDates[which(allDistinctDates == testdate)+20,])
}
get21DaysB4 <- function(testdate) {
  as.character(allDistinctDates[which(allDistinctDates == testdate)-21,])
}

getMomDates <- function(trainingDates) {
  apply(data.frame(trainingDates), 1, getMomDate)
}
# getStartDate_41bizbaysb4 <- function(testdate) {
#   as.character(allDistinctDates[which(allDistinctDates == testdate)-41,])
# }
# # getStartDate_41bizbaysb4('2008-01-02') #"2007-11-06 MYT"
# 
# GetMomEndDate_40DaysFromStart <- function(startDate) {
#   as.character(allDistinctDates[which(allDistinctDates == startDate)+40,])
# }
# # GetMomEndDate_40DaysFromStart("2007-11-06 MYT") #"2008-01-01 MYT"
