data = read.csv("../ws2A/FinancialData.csv", stringsAsFactors=FALSE)
colnames(data)
head(data)
data$date = strptime(data$X, format = "%d-%b-%y")

library(mice)
# Generate a summary of the missing values in the dataset.
md.pattern(data)

z_score <- function(vals) {
  #generate z-scores for variable A using the scale() function
  scale(vals, center = TRUE, scale = TRUE)
}

# pdf(file="Plots.pdf")
# par(mfrow=c(1,1))
# for (i in 2:16) {
#   plotData = data[,c(17, i)]
#   plot(plotData)
# }
# dev.off()

unique(weekdays(data$date))
#data is every Wednesday, therefore this is weekly data, need to put all to weekly

# #impute values??
# apply(data[,2:16], 2, 
#        function(x) {
#          sum(is.na(x))
#        }
#   )
# boxplot(data$FTV)
# boxplot(data$STIV)

col_monthly.inflation.rate = 14:16
col_yearly.banks.prime.rate = 11:13
col_exchange.rates = 9:10
col_indexes = c(2,4,5,7)

# #impute value from last 3 months (3*4 rows)
# x = -12:0
# y = data[(600+x),16]
# fit = lm(y ~ x)
# plot(fit)
# newdata = data.frame(x=1:6)
# predict(fit, newdata)
# library(forecast)
# plot(forecast(fit, 1:6, h=20))

#vals contain the NAs, will only lookback for how many rows <- if lookback too much, may average to all 
#this now applies if values to impute at last few rows. 
imputeByLinearRegression <- function(vals, lookback=12) {
  df = data.frame(x = 1:length(vals), y = vals)
  rows.to.impute = df$x[is.na(vals)]
  if (length(rows.to.impute) == 0) {
    return(vals)
  }
  row.train = (rows.to.impute[1] - lookback): (rows.to.impute[1] -1)
  df.train = df[row.train,]
  fit = lm(y ~ x, data = df.train)
  newdata = data.frame(x=rows.to.impute)
  vals[rows.to.impute] = predict(fit, newdata)
  return(vals)
}

#impute columns
for (i in c(col_monthly.inflation.rate,7)) {
  data[,i] = imputeByLinearRegression(data[,i])
}

#monthly inflation rate divide by 4 to get weekly
# library(dplyr)
# data %>%
#   select(ends_with="INF") %>%
for (i in col_monthly.inflation.rate) {
  data[,paste0(colnames(data)[i], ".weekly")] = data[,i] / 4
}
#banks prime rate is yearly, so divide by 52 to get weekly
for (i in col_yearly.banks.prime.rate) {
  data[,paste0(colnames(data)[i], ".weekly")] = data[,i] / 52
}

#exchange rates to forecast
#target: forward 1 week - current week
# data$SG.D.forward1 = c(data$SG.D[-1],NA)
# data$SG.D.diff1 = data$SG.D.forward1 - data$SG.D

getMomentum <- function(futureVal, currentVal) {
  (futureVal - currentVal)/currentVal *100
}

for (i in col_exchange.rates) {
  last.row = length(data[,i])
  data[,paste0(colnames(data)[i], ".forward.week")] = c(data[-1,i],NA)
  data[,paste0(colnames(data)[i], ".backward.week")] = c(NA, data[-last.row,i])
  data[,paste0(colnames(data)[i], ".backward.month")] = c(rep(NA,4), data[-((last.row-3):last.row),i])
  
  #target being forward 1 week momentum
  data[,paste0(colnames(data)[i], ".target")] = 
    getMomentum(data[,paste0(colnames(data)[i], ".forward.week")],data[,i]) 

  #backward predictors
  data[,paste0(colnames(data)[i], ".weekly.momentum")] = 
    getMomentum(data[,i], data[,paste0(colnames(data)[i], ".backward.week")])
  data[,paste0(colnames(data)[i], ".monthly.momentum")] = 
    getMomentum(data[,i], data[,paste0(colnames(data)[i], ".backward.month")])
}

#lookback values, like indexes help to predict exchange rate? 
# data$DJI.backward1 = c(NA, data$DJI[-length(data$DJI)])
# data$DJI.back1 = data$DJI - data$DJI.backward1 #later date - earlier
for (i in col_indexes) {
  last.row = length(data[,i])
  data[,paste0(colnames(data)[i], ".backward.week")] = c(NA, data[-last.row,i])
  data[,paste0(colnames(data)[i], ".backward.month")] = c(rep(NA,4), data[-((last.row-3):last.row),i])
  
  #backward predictors
  data[,paste0(colnames(data)[i], ".weekly.momentum")] = 
    getMomentum(data[,i], data[,paste0(colnames(data)[i], ".backward.week")])
  data[,paste0(colnames(data)[i], ".monthly.momentum")] = 
    getMomentum(data[,i], data[,paste0(colnames(data)[i], ".backward.month")])  
}

col_momentum = colnames(data)[grep(".momentum", colnames(data))]
data[,paste0(col_momentum, ".z")] = z_score(data[,col_momentum])

write.csv(data, "workshop2A_processedData.csv")


colnames(data)
i=21
boxplot(data[,i])
