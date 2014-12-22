data = read.csv("D:/SmartTrader/smart-trader/trunk/code/dataMining/GA_allocation/data.csv")
data = data[data$voted.prob >0,]
data = data[, c("SecId", "votes", "all.prob", "sector", "PriceToday")]
data = data[order(data$sector, data$all.prob),]
targetTotalInvestAmount = 5000

numStocks = nrow(data)
bitsPerStock = 5
nBits = bitsPerStock*numStocks

library(GA)
decode <- function(string) {
  string <- gray2binary(string)
  startingPositions = rep(1,numStocks) + c(0:(numStocks-1) *bitsPerStock)
  noToBuy = as.integer()
  for (i in 1:numStocks ) {
    noToBuy = c(noToBuy, 
                binary2decimal(string[startingPositions[i]:
                                        (startingPositions[i]+bitsPerStock-1)]))
  }
  return(noToBuy)
}
fitness <- function(string) {
  noToBuy <- decode(string)
  spent = noToBuy * data$PriceToday
  sumSpent = sum(spent)
  diffFromTarget = abs(targetTotalInvestAmount - sumSpent)
  
  prob.bin = cut(data$all.prob, 
                 c(0.5, 0.6, 0.8, 1), 
                 labels=c(1,2,3), include.lowest=TRUE)
  # limit the amount spent on bin1 stocks 
  diffSpentBin1 = spent[prob.bin == 1]-
                  (targetTotalInvestAmount/numStocks*data$all.prob[prob.bin == 1])
  diffSpentBin1[diffSpentBin1<0] = 0
  diffSpentBin1 = sum(diffSpentBin1)

  # limit the amount spent on bin2 stocks 
  diffSpentBin2 = spent[prob.bin == 2]-
    (targetTotalInvestAmount/numStocks*data$all.prob[prob.bin == 2]*2)
  diffSpentBin2[diffSpentBin2<0] = 0
  diffSpentBin2 = sum(diffSpentBin2)
  
#   #associate prob with total spent on stock
# prob.bin = cut(data$all.prob, 
#                c(0.5, 0.6, 0.8, 1), 
#                labels=c(1,2,3), include.lowest=TRUE)
#   spent.bin = cut(spent, 
#                   quantile(spent, c(0, 0.33, 0.66, 1)), 
#                   labels=c(1,2,3), include.lowest=TRUE)  
#   diffInBins = sum(abs(as.integer(prob.bin) - as.integer(spent.bin)))
#   diffOrderSpent = sum(abs(spent[order(spent)]-spent))

  sector1 = which(data$sector==sectors[1])
  sector2 = which(data$sector==sectors[2])
  diffInSectors = abs(sum(spent[sector1]) - sum(spent[sector2]))

#   return(-(diffFromTarget+ diffInBins*0.4 + diffInSectors*0.3))
  return(-(diffFromTarget + diffSpentBin1 + diffSpentBin2 + diffInSectors))
}
# gaControl("binary" = list(selection = "gabin_rwSelection")) #worse
# gaControl("binary")

#decimal2binary(63, 6) #6 bits is 0 to 63
GA <- ga(type="binary", fitness=fitness, nBits=nBits, popSize = 500,
         pmutation = 0.3, maxiter=200) #,elitism=1,
#          keepBest=TRUE)
# noToBuy = decode(GA@bestSol[[73]])
summary(GA)

noToBuy = decode(GA@solution)
prob = data$all.prob
spent = noToBuy * data$PriceToday
sum(spent)
cbind(sector=data$sector, round(prob,2), noToBuy, price = round(data$PriceToday,2), round(spent,2))
# prob.bin = cut(data$all.prob, 
#                c(0.5, 0.6, 0.8, 1), 
#                labels=c(1,2,3), include.lowest=TRUE)
# spent.bin = cut(spent, 
#                 quantile(spent, c(0, 0.33, 0.66, 1)), 
#                 labels=c(1,2,3), include.lowest=TRUE)  
# sum(abs(as.integer(prob.bin) - as.integer(spent.bin)))
# sum(abs(spent[order(spent)]-spent))
sector1 = which(data$sector==sectors[1])
sector2 = which(data$sector==sectors[2])
abs(sum(spent[sector1]) - sum(spent[sector2]))

plot(GA)
library(ggplot2)
qplot(prob, spent, color=data$sector)
abline(prob[sector1], spent[sector1])
# curve(f, -20, 20)
# abline(v = GA@solution, lty = 3)
