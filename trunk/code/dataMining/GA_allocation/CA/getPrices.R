results1 = read.csv("results/results.test_Financials_2009-12-01.csv")
results1$sector= "Financials"
results2 = read.csv("results/results.test_Consumer Discretionary_2009-12-01.csv")
results2$sector= "Consumer Discretionary"

sectors = c("Financials", "Consumer Discretionary")
testDate = "2009-12-01"

library(RODBC);
channel <- odbcConnect("localDB") 
data = data.frame()
for (sector in sectors) {
  securities <- sqlQuery(channel, "
                           SELECT *
                           FROM [S&P].[dbo].[tb_SecurityMaster]
                           ")
  secIds = securities[ (securities$SML == 'L' | securities$SML == 'M')
                       #                       & str_trim(securities$GICS_SEC) == 'Financials', 
                       & str_trim(securities$GICS_SEC) == sector, 
                       'SecId']
  
  #get price close # FID=5
  priceClose <- sqlQuery(channel, paste0(" 
                   SELECT *
                   FROM [S&P].[dbo].[tb_FactorDataOld]
                   where [DATE] in ('", paste(testDate, collapse = "','"),
                                       "') AND Fid = 5 AND SecId in (", paste(secIds,collapse=","),
                                       ") ORDER by [Date], SecId
                   "))
  priceCloseIn20days <- sqlQuery(channel, paste0(" 
                   SELECT *
                   FROM [S&P].[dbo].[tb_FactorDataOld]
                   where [DATE] in ('", paste(getMomDate(testDate), collapse = "','"),
                                         "') AND Fid = 5 AND SecId in (", paste(secIds,collapse=","),
                                         ") ORDER by [Date], SecId
                   "))
  priceClose <- merge(priceClose, priceCloseIn20days, by="SecId")
  priceClose = priceClose[,c(1,4,7)]
  colnames(priceClose) = c("SecId", "PriceToday", "PriceForward20Days")
  results = read.csv(paste0("results/results.test_", sector, "_", testDate,".csv"))
  results$sector= sector
  
  results.Price <- merge(results, priceClose, by="SecId")
  data = rbind(data, results.Price)
}
close(channel)

save(data, file="GA_allocation/data.Rdata")
write.csv(data, "GA_allocation/data.csv")
