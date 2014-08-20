source("commonUtility.R")
addLibrary()
library(stringr)

# Control Panel > Administrative Tools > Data Sources
# Add User Data Source with SQL Server Native Client 10.0
# (i used localDB as name of this connection)
# channel <- odbcConnect("ODBC_NAME", uid="username", pwd="password");


# startDate = '2008-12-01'
# testDate = '2009-01-04'
# momEndDate = '2009-01-30'
dayDiff = 20

getMonthlyData <- function(sector, startDate, testDate, momEndDate) {
  library(RODBC);
  channel <- odbcConnect("localDB") 
  securities <- sqlQuery(channel, "
                         SELECT *
                         FROM [S&P].[dbo].[tb_SecurityMaster]
                         ")
  table(securities$SML)
  table(securities$SML, securities$GICS_SEC) 
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
             SELECT *
             FROM [S&P].[dbo].[tb_FactorScore] 
             WHERE [DATE] >= '", startDate, "' AND [DATE] < '", momEndDate,
             "' AND SECTOR = '", sector, 
             "' AND SecId in (", paste(secIds,collapse=","), 
             ") ORDER by [Date], SecId")) #nov and dec 2008

  #use price momentum instead
  priceMom <- sqlQuery(channel, paste0(" 
                 SELECT *
                 FROM [S&P].[dbo].[tb_FactorDataOld]
                 where [DATE] >= '", startDate, "' AND [DATE] < '", momEndDate,
                 "' AND Fid = 2098 AND SecId in (", paste(secIds,collapse=","),
                 ") ORDER by [Date], SecId
                 "))
  
  close(channel)
    
  ### Convert columns format to numeric
  data$Sector = NULL
  data[,3:ncol(data)]=apply(data[,3:ncol(data)],2,as.numeric)
  
  col.input = colnames(data)
  data$DayOfWeek = as.factor(weekdays(data$Date))
  
  data = data[,c("DayOfWeek", col.input)] #put in front so later easier
  col.input = colnames(data)
#   summary(data)
  
  #columns that have more than 20% not filled.
  columnsToRemove = colnames(data)[apply(data, 2, function(x) sum(is.na(x))) > 0.2 * nrow(data)]
  for (i in 4:ncol(data)) {
    if (length(unique(data[,i])) < 4)
      columnsToRemove = c(columnsToRemove, colnames(data)[i])
  }
  
#   columnsToRemove  <- c("BookYieldFY3", "DivRevFY1_3M", "DivRevFY1_6M", 
#                         "EarningsFY2UpDnGrade_3M", "EarningsFY3UpDnGrade_3M", 
#                         "EarningsFY1UpDnGrade_6M", "EarningsFY2UpDnGrade_6M", 
#                         "EarningsFY3UpDnGrade_6M", "EBITDAFY1UpDnGrade_3M", 
#                         "EBITDAFY2UpDnGrade_3M", "EBITDAFY3UpDnGrade_3M", 
#                         "EBITDAFY1UpDnGrade_6M", "EBITDAFY2UpDnGrade_6M", 
#                         "EBITDAFY3UpDnGrade_6M", "DivRatio", 
#                         "OpCFOverCDiv1Y","EBITDAFY3Std")
  col.input = col.input[ !col.input %in% columnsToRemove]  
  data = data[ , col.input]
  
  library(plyr)
  priceMom$Fid = NULL
  
  priceMom$Price = as.numeric(as.character(priceMom$Data))
  priceMom <- ddply(priceMom, .(SecId), transform,
                    diff20 = c(Price[-(1:dayDiff)],rep(NA,dayDiff))) #take 20th value as 1st
  priceMom = priceMom[,c('Date', 'SecId', 'diff20')]
  
  data2 = join(data, priceMom)
  data2$Date = as.Date(data2$Date)
  data2 = data2[data2$Date<=as.Date(testDate),]
  

  #data2[is.na(data2)] <- 0
#   head(data2[,1:20])
  return(data2)
}
# save(dataset, file="scored_financials_L_2008.Rdata")
# write.csv(dataset, "scored_financials_L_2008.csv")
