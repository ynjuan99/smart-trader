load("scored_financials_L_2008.Rdata")

summary(dataset$diff20)
dataset$bin.diff20 = cut(dataset$diff20, 
                         breaks=c(-100, -10, -5, 0, 5, 10, 100, 500),
                         include.lowest=TRUE,
                           labels=c(-100, -10, -5, 0, 5, 10, 100))   
#                          labels=c(1:7))   
head(dataset[,c("diff20", "bin.diff20")])
summary(dataset[dataset$bin.diff20==5, "diff20"])

table(dataset$bin.diff20)

dataset$bin.diff20 = cut(dataset$diff20, 
                         breaks=c(-100, 10, 500),
                         include.lowest=TRUE,
                         labels=c(0,1))   


dataset$diff20 = NULL

dataset$bin.diff20 = cut(dataset$diff20, 
                         quantile(dataset$diff20, c(0, 0.8, 1)), 
                        labels=c(0,1), include.lowest=TRUE)
