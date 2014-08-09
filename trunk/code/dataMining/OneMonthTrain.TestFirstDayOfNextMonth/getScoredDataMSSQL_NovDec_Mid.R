source("D://et//commonUtility.R")
addLibrary()
library(stringr)

# Control Panel > Administrative Tools > Data Sources
# Add User Data Source with SQL Server Native Client 10.0
# (i used localDB as name of this connection)
# channel <- odbcConnect("ODBC_NAME", uid="username", pwd="password");

library(RODBC);
channel <- odbcConnect("localDB") 
securities <- sqlQuery(channel, "
                       SELECT *
                       FROM [S&P].[dbo].[tb_SecurityMaster]
                       ")
table(securities$SML)
table(securities$SML, securities$GICS_SEC) 
secIds = securities[ (securities$SML == 'L' | securities$SML == 'M')
                    & str_trim(securities$GICS_SEC) == 'Financials', 
                    'SecId']
#Using Financials Large and Mid <- 169
######################

# #using 2008 data cos 2010 data not much
data <- sqlQuery(channel, paste0("
                                 SELECT *
                                 FROM [S&P].[dbo].[tb_FactorScore] 
                                 WHERE [DATE] >= '2008-11-01' AND [DATE] < '2008-12-10'
                                 AND SECTOR = 'Financials' 
                                 AND SecId in (", paste(secIds,collapse=","), 
                                 ") ORDER by [Date], SecId")) #nov and dec 2008

#use price momentum instead
priceMom <- sqlQuery(channel, paste0(" 
                                     SELECT *
                                     FROM [S&P].[dbo].[tb_FactorDataOld]
                                     where [DATE] >= '2008-11-01' AND [DATE] < '2009-01-01' AND
                                     Fid = 2098 AND SecId in (", paste(secIds,collapse=","),
                                     ") ORDER by [Date], SecId
                                     "))

close(channel)

library(plyr)
priceMom$Fid = NULL
dayDiff = 20

priceMom$Price = as.numeric(as.character(priceMom$Data))
priceMom <- ddply(priceMom, .(SecId), transform,
                  diff20 = c(Price[-(1:dayDiff)],rep(NA,dayDiff))) #take 20th value as 1st
priceMom = priceMom[,c('Date', 'SecId', 'diff20')]

data2 = join(data, priceMom)
data2$Date = as.Date(data2$Date)
data2 = data2[data2$Date<=as.Date('2008-12-01'),]

summary(data2)
#columns that have less than 50% filled.
colnames(data2)[apply(data2, 2, function(x) sum(is.na(x))) > 0.2 * nrow(data2)]

### Convert columns format to numeric
data2$Sector = NULL
data2[,2:ncol(data2)]=apply(data2[,2:ncol(data2)],2,as.numeric)

#data2[is.na(data2)] <- 0
head(data2[,1:20])
dataset = data2

# save(dataset, file="scored_financials_L_2008.Rdata")
# write.csv(dataset, "scored_financials_L_2008.csv")
