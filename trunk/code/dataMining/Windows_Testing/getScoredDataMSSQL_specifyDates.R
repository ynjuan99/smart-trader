library(stringr)
library(dplyr)

# Control Panel > Administrative Tools > Data Sources
# Add User Data Source with SQL Server Native Client 10.0
# (i used localDB as name of this connection)
# channel <- odbcConnect("ODBC_NAME", uid="username", pwd="password");

# sector = "Health Care"
# startDate = '2008-12-01'
# testDate = '2009-01-04'
# momEndDate = '2009-01-30'
# dayDiff = 20

weekdays = c("Monday", "Tuesday", "Wednesday", "Thursday", "Friday")

getData <- function(sector, trainingDates) {

  library(RODBC);
  channel <- odbcConnect("localDB") 
  securities <- sqlQuery(channel, "
                         SELECT *
                         FROM [S&P].[dbo].[tb_SecurityMaster]
                         ")
#   table(securities$SML)
#   table(securities$SML, securities$GICS_SEC) 
  if (sector == "All") {
    secIds = securities[ (securities$SML == 'L' | securities$SML == 'M') , 
                         'SecId']
  } else {
    secIds = securities[ (securities$SML == 'L' | securities$SML == 'M')
  #                       & str_trim(securities$GICS_SEC) == 'Financials', 
                        & str_trim(securities$GICS_SEC) == sector, 
                        'SecId']
  }
  #Using Financials Large and Mid <- 169
  ######################
  
  # #using 2008 data cos 2010 data not much
  data <- sqlQuery(channel, paste0("
             SELECT 
Date, 
SecId, 
Sector,
EarningsFY2UpDnGrade_1M,
EarningsFY1UpDnGrade_1M,
EarningsRevFY1_1M,
NMRevFY1_1M,
PriceMA10,
PriceMA20,
PMOM10,
RSI14D,
EarningsFY2UpDnGrade_3M,
FERating,
PriceSlope10D,
PriceMA50,
SalesRevFY1_1M,
PMOM20,
NMRevFY1_3M,
EarningsFY2UpDnGrade_6M,
PriceSlope20D,
Price52WHigh,
EarningsRevFY1_3M,
PMOM50,
PriceTStat200D,
RSI50D,
MoneyFlow14D,
PriceTStat100D,
PEGFY1,
Volatility12M,
SharesChg12M,
PriceMA100,
Volatility6M,
SalesYieldFY1,
EarningsYieldFY2,
PriceRetFF20D_Absolute
             FROM [S&P].[dbo].[tb_FactorScore] 
             WHERE [DATE] in ('", paste(trainingDates, collapse = "','"),
             "') AND SECTOR = '", sector, 
             "' AND SecId in (", paste(secIds,collapse=","), 
             ") ORDER by [Date], SecId")) #PriceRetFF20D,

  close(channel)
    
  ### Convert columns format to numeric
  data$Sector = NULL
  data[,3:ncol(data)]=apply(data[,3:ncol(data)],2,as.numeric)
  
  col.input = colnames(data)
  data$DayOfWeek = as.factor(weekdays(data$Date))
  levels(data$DayOfWeek) = weekdays #for those training data of only 1 day
  
  data = data[,c("DayOfWeek", col.input)] #put in front so later easier
#   summary(data)
  data$output = data$PriceRetFF20D_Absolute #rename
  data$PriceRetFF20D_Absolute = NULL
  return(data)
}
