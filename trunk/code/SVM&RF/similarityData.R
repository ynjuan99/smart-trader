library(stringr)
library(clue)
source("getScoredDataMSSQL_specifyDates.R")
source("otherModels_specify.R")
source("getDatesFromDB.R")

# http://stackoverflow.com/questions/2547402/standard-library-function-in-r-for-finding-the-mode
Mode <- function(x) {
  x = round(x, 1) #1dp
  ux <- unique(x)
  ux[which.max(tabulate(match(x, ux)))]
}

sector= "Industrials" #"Consumer Discretionary" # "Financials"

startDate = '2013-01-01' #will check for month start
endDate = '2014-01-01'  #less than but excluded date
clusterDates = getAllDistinctDatesFactorScore(startDate, endDate)
cluster.dataset = getData(sector, clusterDates)
cluster.dataset$DayOfWeek = NULL
cluster.dataset$output = NULL
data.days <- split(cluster.dataset, cluster.dataset$Date)

testDate = '2014-01-30'
test.dataset = getData(sector, testDate)
test.dataset$DayOfWeek = NULL
test.dataset$output = NULL

fn.consolidate = c(mean, median, Mode)
for (fn in fn.consolidate) {
  print(fn) 
  test.dataset.consolidated = apply(test.dataset[,-c(1,2)], 2, fn)
  
  data.days.consolidated = lapply(data.days, 
                          function(byday) { apply(byday[,-c(1,2)], 2, fn)})
  mydata = data.frame(do.call(rbind, data.days.consolidated))
  # write.csv(mydata, paste0("averageDailyData/", sector, ".csv"))
  
  # mydata = read.csv(paste0("averageDailyData/", sector, ".csv"))
  mydata1 =na.omit(mydata)
  # mydata1 = mydata[complete.cases(mydata),]
  # str(mydata)
  # sum(is.na(mydata))
  # mydata[is.na(mydata),]
  
  wss <- (nrow(mydata1)-1)*sum(apply(mydata1,2,var))
  for (i in 2:15) {
    STATIC_SEED=42
    wss[i] <- sum(kmeans(mydata1, centers=i)$withinss)
  }
  plot(1:15, wss, type="b", xlab="Number of Clusters",
       ylab="Within groups sum of squares")
  
  #to get number of clusters
  wss.diff.perc = (wss - wss[length(wss)])/(wss[1]-wss[length(wss)])
  num.cluster = wss.diff.perc < 0.3 #30% of difference btw 2 clusters and 15 clusters
  num.cluster = which(num.cluster)[1] 
  print(paste0("using ", num.cluster, " clusters, withinss = ", wss[num.cluster]))
  
  # K-Means Cluster Analysis
  STATIC_SEED=42
  fit <- kmeans(mydata1, num.cluster) # 5 cluster solution
  classes <- cl_predict(fit)
  row.dates = row.names(mydata1)
  cluster.dates <- cbind(row.dates, classes)
  predicted.class = cl_predict(fit, t(data.frame(test.dataset.consolidated)))
  trainingDates = cluster.dates[cluster.dates[,2]==predicted.class, 1]
  print(trainingDates)
  print(paste0("there are ", length(trainingDates), " days of training data."))
  
  while (length(trainingDates) < 20) {
    num.cluster = num.cluster-1 #decrease num of cluster to have bigger cluster
    print(paste0("using ", num.cluster, " clusters, withinss = ", wss[num.cluster]))
    STATIC_SEED=42
    fit <- kmeans(mydata1, num.cluster) # 5 cluster solution
    classes <- cl_predict(fit)
    row.dates = row.names(mydata1)
    
    cluster.dates <- cbind(row.dates, classes)
    predicted.class = cl_predict(fit, t(data.frame(test.dataset.consolidated)))
    
    trainingDates = cluster.dates[cluster.dates[,2]==predicted.class, 1]
    print(trainingDates)
    print(paste0("there are ", length(trainingDates), " days of training data."))
  }
  
  if (length(trainingDates) > 20) {
    trainingDates = trainingDates[(length(trainingDates)-19):length(trainingDates)]
    print(paste0("using 20 days: ", paste0(trainingDates, collapse = ",")))
  } 

  testingDates = testDate
  train.dataset = getData(sector, trainingDates)
  test.dataset = getData(sector, testingDates)
  
  print(paste0("Starting run on sector '", sector, "' and test date of '", testDate, "'"))
  label = paste0("testCluster_", sector, "_", testDate)
  modelLabel = paste0("_clusterof_", sector, "_", testDate)
  
  results = runTrainValidateAndTest(train.dataset, test.dataset, modelLabel)
  results$actual = results$bin.output
  
  errorMatrix = getErrorMatrix(results)

}

# # # get cluster means 
# # aggregate(mydata,by=list(fit$cluster),FUN=mean)
# # # append cluster assignment
# # mydata <- data.frame(mydata, fit$cluster)
# 
# #http://stackoverflow.com/questions/20621250/simple-approach-to-assigning-clusters-for-new-data-after-k-means-clustering
# install.packages("flexclust")
# library(flexclust)
# 
set.seed(42)
cl1 <- kcca(mydata1, k=5, kccaFamily("ejaccard"))
#"kmeans", "kmedians", "angle", "jaccard", or "ejaccard"
cl1
newdata = t(data.frame(test.dataset.consolidated))
clusters(cl1,newdata)
pred_train <- predict(cl1)
pred_test <- predict(cl1, newdata=newdata)
trainingDates = names(pred_train[pred_train == pred_test])

testingDates = testDate
train.dataset = getData(sector, trainingDates)
test.dataset = getData(sector, testingDates)

print(paste0("Starting run on sector '", sector, "' and test date of '", testDate, "'"))
label = paste0("testCluster_", sector, "_", testDate)
modelLabel = paste0("_clusterof_", sector, "_", testDate)

results = runTrainValidateAndTest(train.dataset, test.dataset, modelLabel)
results$actual = results$bin.output

errorMatrix = getErrorMatrix(results)
