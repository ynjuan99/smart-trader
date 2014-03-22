hist <- read.csv("../hist.csv", sep=",")
colnames(hist)

histclose <- hist[hist$X=="CLOSE",]
plot(log(histclose[1,10:60]))
x <- hist[2,10:60]
plot(hist$X)

for(i in 10:60)
  histclose[,i] = as.numeric(histclose[,i])
histclose2 = t(histclose)
save(histclose, file="histclose.Rdata")
histclose2 = t(histclose)
View(histclose2)
histclose2prices = histclose2[10:60,]
View(histclose2prices)
colnames(histclose2prices) = histclose2[1,]
View(histclose2prices)
View(histclose2prices[1])
colnames(histclose2prices[1])

library(stringr)
rownames(histclose2prices) = str_replace(rownames(histclose2prices),"X","")
df.hist = data.frame(histclose2prices)
save(df.hist, file="df.hist.Rdata")
qplot(data=df.hist, x=DDD)

plot(df.hist$DDD)

library(zoo)
dates=rownames(df.hist)
ts=zoo(df.hist, as.Date(dates,"%m.%d.%Y"))
head(ts,30)
plot(ts[,1:5])
# qplot(data=df.hist,y=DDD)
plot(ts[,1],ylim=c(0,10000), col="#CC0000FF", lty=1, xlab="Dates", add=FALSE)
par(new=TRUE)
plot(ts[,2],ylim=c(0,10000), col="#00CC00FF", lty=2, add=TRUE)
par(new=TRUE)
plot(ts[,3],ylim=c(0,10000), col="#0000CCFF", lty=3, add=TRUE)
par(new=TRUE)
plot(ts[,4],ylim=c(0,10000), col="#0052CCFF", lty=4, add=TRUE)
par(new=TRUE)
plot(ts[,5],ylim=c(0,10000), col="#A300CCFF", lty=5, add=TRUE)
legend("bottomleft", colnames(df.hist[,1:5]), col=rainbow(5, 1, .8), lty=1:5, title="Models", inset=c(0.05, 0.05))
title(main="Prices")
grid()
