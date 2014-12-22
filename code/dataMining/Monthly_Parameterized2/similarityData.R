library(stringr)
sector= "Consumer Discretionary" # "Financials"

testDate = '2009-12-31'
static_db_startDate = '2008-11-01'
library(RODBC);
channel <- odbcConnect("localDB") 
securities <- sqlQuery(channel, "
                         SELECT *
                         FROM [S&P].[dbo].[tb_SecurityMaster]
                         ")
secIds = securities[ (securities$SML == 'L' | securities$SML == 'M')
                     #                       & str_trim(securities$GICS_SEC) == 'Financials', 
                     & str_trim(securities$GICS_SEC) == sector, 
                     'SecId']

data <- sqlQuery(channel, paste0("
             SELECT *
             FROM [S&P].[dbo].[tb_FactorScore] 
             WHERE [Date] >= '", static_db_startDate,"' AND [Date] < '", testDate,
              "' AND SECTOR = '", sector, 
             "' AND SecId in (", paste(secIds,collapse=","), 
             ") ORDER by [Date], SecId")) #nov and dec 2008

col.input = colnames(data)
col.input = col.input[-c(2:3)]
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
str(data2)

data.days <- split(data2, data2$Date)
xx = lapply(data.days, function(byday) { apply(byday[,-1], 2, mean)})
mydata = data.frame(do.call(rbind, xx))
write.csv(mydata, paste0("averageDailyData/", sector, ".csv"))

mydata = read.csv(paste0("averageDailyData/", sector, ".csv"))
mydata1 =na.omit(mydata)
# mydata1 = mydata[complete.cases(mydata),]
# str(mydata)
# sum(is.na(mydata))
# mydata[is.na(mydata),]

testDate= "2009-12-01"
startDate = "2009-06-01"
endDate = "2010-01-01"
runFirstBizDates("2009-06-01", "2010-01-01")
runFirstBizDates <- function(startDate, endDate) {
  firstDates = getFirstBizDateEachMonth(startDate, endDate)
  
  for (testDate in firstDates) {
    mydata = read.csv(paste0("averageDailyData/", sector, ".csv"))
    mydata1 =na.omit(mydata)
    
mydata1$X = as.character(mydata1$X)
mydata1 <- mydata1[mydata1$X < get21DaysB4(testDate),]
row.dates = mydata1$X
mydata1$X = NULL

validationdata = read.csv("singleDayData/data_Financials_2009-11-02.csv")
validationdata = validationdata[ , col.input]
validationdata = data.frame(t(apply(validationdata[,-1], 2, mean)))
testdata = read.csv("singleDayData/data_Financials_2009-12-01.csv")
testdata = testdata[ , col.input]
testdata = data.frame(t(apply(testdata[,-1], 2, mean)))
testdata = rbind(validationdata, testdata)

# Determine number of clusters
wss <- (nrow(mydata1)-1)*sum(apply(mydata1,2,var))
for (i in 2:15) wss[i] <- sum(kmeans(mydata1, 
                                     centers=i)$withinss)
plot(1:15, wss, type="b", xlab="Number of Clusters",
     ylab="Within groups sum of squares")
# K-Means Cluster Analysis
fit <- kmeans(mydata1, 4) # 5 cluster solution
library(clue)
classes <- cl_predict(fit)
cluster.dates <- cbind(row.dates, classes)
cl_predict(fit, testdata)
trainingDates = cluster.dates[cluster.dates[,2]==4, 1]
print(trainingDates)
print(paste0("there are ", length(trainingDates), " days of training data."))
if (length(trainingDates) > 20) {
  trainingDates = trainingDates[(length(trainingDates)-19):length(trainingDates)]
  print(paste0("using 20 days: ", paste0(trainingDates, collapse = ",")))
}

momentumDates = getMomDates(trainingDates)
# validation.trainDate = momentumDates[1]
# validation.momDate = dates_41days[41]
testing.trainDate = testDate
testing.momDate = getMomDate(testDate)

print(paste0("Starting run on sector '", sector, "' and test date of '", testDate, "'"))
label = paste0("test_", sector, "_", testDate)
modelLabel = paste0("_", sector, "_", trainingDates[1])

train.dataset = getData(sector, trainingDates, momentumDates)
# validate.dataset = getData(sector, validation.trainDate, validation.momDate)
# write.csv(validate.dataset, file=paste0("singleDayData/data_", sector, "_", validation.trainDate, ".csv"))
test.dataset = getData(sector, testing.trainDate, testing.momDate)
# write.csv(test.dataset, file=paste0("singleDayData/data_", sector, "_", testing.trainDate, ".csv"))

results = runTrainValidateAndTest(train.dataset, NULL, test.dataset, modelLabel)
write.csv(results, paste0("results/results.", label, ".csv"))
results$actual = results$bin.diff20
#       results <-
#         lapply(results, function (result) {
#           result$actual = result$bin.diff20
#         })
errorMatrix = getErrorMatrix(results)

write.csv(errorMatrix, paste0("results/errorMatrix1.", label, ".csv"))
}
}



# # get cluster means 
# aggregate(mydata,by=list(fit$cluster),FUN=mean)
# # append cluster assignment
# mydata <- data.frame(mydata, fit$cluster)

#http://stackoverflow.com/questions/20621250/simple-approach-to-assigning-clusters-for-new-data-after-k-means-clustering
install.packages("flexclust")
library(flexclust)

set.seed(42)
cl1 <- kcca(mydata, k=5, kccaFamily("kmeans"))
cl1
clusters(cl1,newdata)
pred_train <- predict(cl1)
pred_test <- predict(cl1, newdata=newdata)

image(cl1)
points(mydata)

data("Nclus")
dat <- as.data.frame(Nclus)
ind <- sample(nrow(dat), 50)

dat[["train"]] <- TRUE
dat[["train"]][ind] <- FALSE

cl1 = kcca(dat[dat[["train"]]==TRUE, 1:2], k=4, kccaFamily("kmeans"))
cl1    
#
# call:
# kcca(x = dat[dat[["train"]] == TRUE, 1:2], k = 4)
#
# cluster sizes:
#
#  1   2   3   4 
#130 181  98  91 

pred_train <- predict(cl1)
pred_test <- predict(cl1, newdata=dat[dat[["train"]]==FALSE, 1:2])

image(cl1)
points(mydata)
points(dat[dat[["train"]]==TRUE, 1:2], col=pred_train, pch=19, cex=0.3)
points(dat[dat[["train"]]==FALSE, 1:2], col=pred_test, pch=22, bg="orange")


testDate= "2009-12-01"
