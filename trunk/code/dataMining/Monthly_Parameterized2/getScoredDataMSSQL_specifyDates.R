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

getData <- function(sector, trainingDates, momentumDates) {
  if (length(trainingDates) != length(momentumDates))
    return(NULL)
  
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
             WHERE [DATE] in ('", paste(trainingDates, collapse = "','"),
             "') AND SECTOR = '", sector, 
             "' AND SecId in (", paste(secIds,collapse=","), 
             ") ORDER by [Date], SecId")) #nov and dec 2008

  #use price momentum instead #2098: PMOM20 (past 20 days)
  priceMom <- sqlQuery(channel, paste0(" 
                 SELECT *
                 FROM [S&P].[dbo].[tb_FactorDataOld]
                 where [DATE] in ('", paste(momentumDates, collapse = "','"),
                 "') AND Fid = 2098 AND SecId in (", paste(secIds,collapse=","),
                 ") ORDER by [Date], SecId
                 "))
  
  close(channel)
    
  ### Convert columns format to numeric
  data$Sector = NULL
  data[,3:ncol(data)]=apply(data[,3:ncol(data)],2,as.numeric)
  
  col.input = colnames(data)
  data$DayOfWeek = as.factor(weekdays(data$Date))
  levels(data$DayOfWeek) = weekdays #for those training data of only 1 day
  
  data = data[,c("DayOfWeek", col.input)] #put in front so later easier
  col.input = colnames(data)
#   summary(data)
  
#   #columns that have more than 20% not filled.
#   columnsToRemove = colnames(data)[apply(data, 2, function(x) sum(is.na(x))) > 0.2 * nrow(data)]
#   for (i in 4:ncol(data)) {
#     if (length(unique(data[,i])) < 4)
#       columnsToRemove = c(columnsToRemove, colnames(data)[i])
#   }
# "For run on sector 'Financials' and test date of '2009-12-01'"
# [1] "DivRevFY1_6M"            "DivRatio"                "OpCFOverCDiv1Y"         
# [4] "DivRevFY1_6M"            "EarningsFY1UpDnGrade_3M" "EarningsFY2UpDnGrade_3M"
# [7] "EarningsFY3UpDnGrade_3M" "EarningsFY1UpDnGrade_6M" "EarningsFY2UpDnGrade_6M"
# [10] "EarningsFY3UpDnGrade_6M" "EBITDAFY1UpDnGrade_3M"   "EBITDAFY2UpDnGrade_3M"  
# [13] "EBITDAFY3UpDnGrade_3M"   "EBITDAFY1UpDnGrade_6M"   "EBITDAFY2UpDnGrade_6M"  
# [16] "EBITDAFY3UpDnGrade_6M"   "DivRatio"                "OpCFOverCDiv1Y"    
#when dynamic, test may have diff columns than input <- all needed for test.

  columnsToRemove  <- c("BookYieldFY3", "DivRevFY1_3M", "DivRevFY1_6M", 
                        "EarningsFY2UpDnGrade_3M", "EarningsFY3UpDnGrade_3M", 
                        "EarningsFY1UpDnGrade_6M", "EarningsFY2UpDnGrade_6M", 
                        "EarningsFY3UpDnGrade_6M", "EBITDAFY1UpDnGrade_3M", 
                        "EBITDAFY2UpDnGrade_3M", "EBITDAFY3UpDnGrade_3M", 
                        "EBITDAFY1UpDnGrade_6M", "EBITDAFY2UpDnGrade_6M", 
                        "EBITDAFY3UpDnGrade_6M", "DivRatio", 
                        "OpCFOverCDiv1Y","EBITDAFY3Std")
  col.input = col.input[ !col.input %in% columnsToRemove]  
  data2 = data[ , col.input]
#   #remove securities with less than no. of training days 
#   removeSecIds <- 
#     data %>%
#       group_by(SecId) %>%
#       summarize(count=n()) %>%
#       filter(count < length(trainingDates)) %>%
#       select(SecId)
#   if (nrow(removeSecIds)>0) {
#     removeSecIds = unlist(c(removeSecIds))
#     data2 <- data2[!(data2$SecId %in% removeSecIds),]
#   }
#   data2 = data[order(data$SecId, data$Date),]

  library(plyr)
  priceMom$Fid = NULL
  
  priceMom$diff20 = as.numeric(as.character(priceMom$Data))
#   priceMom <- ddply(priceMom, .(SecId), transform,
#                     diff20 = c(Price[-(1:dayDiff)],rep(NA,dayDiff))) #take 20th value as 1st
#   priceMom = priceMom[,c('Date', 'SecId', 'diff20')]
#   data2 = join(data, priceMom)
  priceMom = priceMom[,c('Date', 'SecId', 'diff20')]
  for (i in 1:length(momentumDates)) {
    priceMom[priceMom$Date == momentumDates[i], "BackwardDate"] = trainingDates[i]
  }
  priceMom$Date = priceMom$BackwardDate 
  priceMom$BackwardDate = NULL 

  priceMom = priceMom[order(priceMom$SecId, priceMom$Date),]
  priceMom = priceMom[priceMom$SecId %in% data2$SecId,] #old data has some na securities

#   diff20 = data.frame(priceMom$Price)
#   data2 = cbind(data, diff20)
  data2 = join(data2, priceMom)
  data2$Date = as.character(data2$Date)
#   data2 = data2[data2$Date %in% trainingDates,] 
  data2$Date = as.Date(data2$Date)

  #data2[is.na(data2)] <- 0
#   head(data2[,1:20])
  return(data2)
}
# save(dataset, file="scored_financials_L_2008.Rdata")
# write.csv(dataset, "scored_financials_L_2008.csv")
