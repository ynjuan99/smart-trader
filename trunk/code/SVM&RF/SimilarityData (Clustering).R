options(stringsAsFactors=F)
source("Windows_Testing2/getScoredDataMSSQL_specifyDates.R")
source("Windows_Testing2/getDatesFromDB.R")
library(data.table)
library(stringr)
library(RODBC)
library(clue)
library(rpart)
library(kernlab)
library(nnet)
library(randomForest)
library(ada)
library(ROCR)
library(pROC)
library(plyr)
library(rattle)
library(rpart.plot)

channel <- odbcConnect("localDB")
STATIC_SEED=42
modelsDir = "models/"

trainSaveModelsC <- function(train.dataset, col.target, col.input, modelLabel) {
  
  # Build a Support Vector Machine model.
  set.seed(STATIC_SEED)
  model.ksvm <- ksvm(as.formula(paste0("as.factor(", col.target,") ~ .")),
                     data=train.dataset,
                     kernel="rbfdot",
                     prob.model=TRUE)
  save(model.ksvm, file=paste0(modelsDir, modelLabel, "model.ksvm", ".Rdata"))
  
  #neutral net
  #using Sum of Squares Residuals to get best number for Hidden Layer Nodes
#   sumSquaresResiduals = 99999999999
#   nohiddenNodes = 0
#   for(hiddenNodes in 20:30) { #round(length(col.input)*0.12)) {
#     set.seed(STATIC_SEED)
#     tempModel <- nnet(as.formula(paste0("as.factor(", paste0(col.target,") ~ ."))),
#                       data=train.dataset,
#                       size=hiddenNodes, skip=TRUE, MaxNWts=10000, trace=FALSE, maxit=100)
#     cat(sprintf("Sum of Squares Residuals: %.4f for %d hidden layer nodes.\n",
#                 sum(residuals(tempModel) ^ 2), hiddenNodes))
#     tempsumSquaresResiduals = sum(residuals(tempModel) ^ 2)
#     if (tempsumSquaresResiduals < sumSquaresResiduals) {
#       sumSquaresResiduals = tempsumSquaresResiduals
#       nohiddenNodes = hiddenNodes
#     }
#     # if (tempsumSquaresResiduals == 0)
#     # break #not working
#   }
#   # nohiddenNodes = 100
#   cat(sprintf("Using NN Model with %d hidden layer nodes.\n", nohiddenNodes))
#   set.seed(STATIC_SEED)
#   model.nnet <- nnet(as.formula(paste0("as.factor(", col.target,") ~ .")),
#                      data=train.dataset,
#                      size=nohiddenNodes, skip=TRUE, MaxNWts=10000, trace=FALSE, maxit=100)
#   save(model.nnet, file=paste0(modelsDir, modelLabel, "model.nnet", ".Rdata"))
#   
  # Random Forest
  set.seed(STATIC_SEED)
  model.rf <- randomForest(as.formula(paste0("as.factor(", col.target,") ~ .")),
                           data=train.dataset,
                           ntree=500,
                           mtry=14,
                           importance=TRUE,
                           na.action=na.roughfix,
                           replace=FALSE)
  save(model.rf, file=paste0(modelsDir, modelLabel, "model.rf", ".Rdata"))
  
  # windows()
  # #Plot the relative importance of the variables.
  # varImpPlot(model.rf, main="Variable Importance of Random Forest")
  
  #Ada boost
  set.seed(STATIC_SEED)
  model.ada <- ada(as.formula(paste0(col.target," ~ .")),
                   data=train.dataset,
                   control=rpart.control(maxdepth=30,
                                         cp=0.010000,
                                         minsplit=20,
                                         xval=10),iter=100)
  save(model.ada, file=paste0(modelsDir, modelLabel, "model.ada", ".Rdata"))
  # windows()
  # varplot(model.ada) #doesnt work, main="Variable Importance of Boost")
  # windows()
  # plot(model.ada) # Plot the error rate as we increase the number of trees.
  #allModels = list(model.ksvm=model.ksvm, model.nnet=model.nnet,
  #                 model.rf=model.rf, model.ada=model.ada)
  allModels = list(model.ksvm=model.ksvm,
                 model.rf=model.rf, model.ada=model.ada)
  save(allModels, file=paste0(modelsDir, modelLabel, "model.all", ".Rdata"))
  
  return(allModels)
}

testModelsC <- function(allModels, test.dataset.withoutTarget) {
  #Testing
  results = list()
  
  # results$rpart = predict(model.rpart, test.dataset.withoutTarget, type="class")
  results$ksvm = tryCatch(
    predict(allModels$model.ksvm, test.dataset.withoutTarget), #cannot put class
    error = function(e) {
      print(paste("ksvm no class"))
      return(NULL)
    })
  #results$nnet = predict(allModels$model.nnet, test.dataset.withoutTarget, type="class")
  results$rf = predict(allModels$model.rf, test.dataset.withoutTarget, type="class")
  results$ada = predict(allModels$model.ada, test.dataset.withoutTarget)
  # results$rpart.prob = predict(model.rpart, test.dataset.withoutTarget)
  results$ksvm.prob = tryCatch(
    predict(allModels$model.ksvm, test.dataset.withoutTarget, type="probabilities"),
    error = function(e) {
      print(paste("ksvm no probabilities"))
      return(NULL)
    })
  # results$ksvm.prob = predict(model.ksvm, test.dataset.withoutTarget, type="probabilities")
  #results$nnet.prob = predict(allModels$model.nnet, test.dataset.withoutTarget)
  results$rf.prob = predict(allModels$model.rf, test.dataset.withoutTarget, type="vote")
  results$ada.prob = predict(allModels$model.ada, test.dataset.withoutTarget, type="prob")
  results = data.frame(results)
  #majority votes
  if (length(results$ksvm) == 0) {
    results$votes= #as.integer(results$rpart)+ #becomes 1s and 2s
      #as.integer(results$nnet)+
      as.integer(results$rf)+
      as.integer(results$ada) -3 #to make 0s and 1s
    results$voted = results$votes - 1.5 #become -ve, +ve
    results$voted = results$voted/abs(results$voted)
    results$voted[is.na(results$voted)] = 0
    results$voted[results$voted==-1] = 0
  } else { #use the other 3 only
    results$votes= #as.integer(results$rpart)+ #becomes 1s and 2s
      as.integer(results$ksvm)+
      #as.integer(results$nnet)+
      as.integer(results$rf)+
      as.integer(results$ada) -4 #to make 0s and 1s
    results$voted = results$votes - 2 #become -ve, +ve
    results$voted = results$voted/abs(results$voted)
    results$voted[is.na(results$voted)] = 0
    results$voted[results$voted==-1] = 0
  }
  
  #probability votes
  if (length(results$ksvm.prob.1) == 0) {
    results$all.prob = ( #results$rpart.prob.1 *0.25 +
      # results$ksvm.prob.1 *0.25 +
      #results$nnet.prob *0.33 +
        results$rf.prob.1 *0.5+
        results$ada.prob.2 *0.5)
  } else { #use the other 3 only
    results$all.prob = ( #results$rpart.prob.1 *0.25 +
      results$ksvm.prob.1 *0.34 +
        #results$nnet.prob *0.25 +
        results$rf.prob.1 *0.33+
        results$ada.prob.2 *0.33)
  }
  results$voted.prob = results$all.prob - 0.5
  results$voted.prob = results$voted.prob/abs(results$voted.prob)
  results$voted.prob[results$voted.prob==-1] = 0
  
  return(results)
}

sector="Industrials"
trainStartDate = '2004-01-01'
trainEndDate = '2009-12-31'
#trainEndDate = '2004-12-31'
#  Ideal cluster size
#Consumer Discretionary=2, Energy=4, Health Care=2, Telecom=2, Utilities=4, Industrials=5, Materials=3,
#Consumer Staples=4, Financials=2,Information Technology=2

sectors = #c("Financials")
  c("Health Care", "Information Technology",
    "Consumer Discretionary", "Financials",
    "Telecommunication Services", "Utilities",
    "Industrials", "Energy", "Materials", "Consumer Staples")
sectors = c("Industrials", "Energy", "Consumer Staples") #"Utilities",

#### Training

for (sector in sectors)
{
  securities <- sqlQuery(channel, "
                       SELECT *
                       FROM [S&P].[dbo].[tb_SecurityMaster]
                       ")
  secIds = securities[ (securities$SML == 'L' | securities$SML == 'M')
                       # & str_trim(securities$GICS_SEC) == 'Financials',
                       & str_trim(securities$GICS_SEC) == sector,
                       'SecId']
  data <- sqlQuery(channel, paste0("
                                 SELECT Date, EarningsFY2UpDnGrade_1M, EarningsFY1UpDnGrade_1M, EarningsRevFY1_1M, NMRevFY1_1M,
                                PriceMA10, PriceMA20, PMOM10, RSI14D, EarningsFY2UpDnGrade_3M, FERating, PriceSlope10D,
                                PriceMA50, SalesRevFY1_1M, PMOM20, NMRevFY1_3M, EarningsFY2UpDnGrade_6M,PriceSlope20D,
                                Price52WHigh,EarningsRevFY1_3M,PMOM50,PriceTStat200D,RSI50D,MoneyFlow14D,PriceTStat100D,
                                PEGFY1,Volatility12M,SharesChg12M,PriceMA100,Volatility6M,SalesYieldFY1,EarningsYieldFY2,PriceRetFF20D
                                 FROM [S&P].[dbo].[tb_FactorData]
                                 WHERE [Date] >= '", trainStartDate,"' AND [Date] < '", trainEndDate,
                                   "' AND SECTOR = '", sector,
                                   "' AND SecId in (", paste(secIds,collapse=","),
                                   ") ORDER by [Date], SecId")) #nov and dec 2008
  
  data2 = data
  data2[,2:ncol(data2)]=sapply(data2[,2:ncol(data2)], as.numeric)
  #str(data)
  data.days <- split(data2, data2$Date)
  data.days=data.days[1]
  xx = lapply(data.days, function(byday) { apply(byday[,-1], 2, mean, na.rm=T)})
  xx = lapply(data.days, function(byday) { return(byday) })
  xx=do.call('rbind',xx)
  head(xx)
  xx = lapply(data.days, function(byday) 
  { 
    byday[,2:ncol(byday)]=sapply(byday[,2:ncol(byday)], mean, na.rm=T) 
    return(byday) 
  
  })
  mydata = data.frame(do.call(rbind, xx))
  mydata1 =na.omit(mydata)
  row.dates = row.names(mydata1) 
  
  #Determine number of clusters
  wss <- (nrow(mydata1)-1)*sum(apply(mydata1,2,var))
  for (i in 2:15) wss[i] <- sum(kmeans(mydata1,centers=i)$withinss)
  plot(1:15, wss, type="b", xlab="Number of Clusters",ylab="Within groups sum of squares")

  # K-Means Cluster Analysis
    if (sector=="Energy" | sector=="Consumer Staples" | sector=="Utilities") no.Clusters=4
    if (sector=="Industrials") no.Clusters=5
    fit <- kmeans(mydata1, no.Clusters) # 
    save(fit, file=paste0(modelsDir, sector, "_clusterfit", ".Rdata"))
  
    o=order(fit$cluster)
    mydata1=data.frame(mydata1[o,],fit$cluster[o])
    
    classes <- cl_predict(fit)
    cluster.dates <- cbind(row.dates, classes)  
    #cluster=2
    #table(cluster.dates[,2]) find out distribution of clusters (using 4 clusters)
    for (cluster in 1:no.Clusters) 
    {
    
    trainingDates = cluster.dates[cluster.dates[,2]==cluster, 1]
    print(trainingDates)
    print(paste0("there are ", length(trainingDates), " days of training data."))
    
    print(paste0("Starting run on sector '", sector, "' and cluster '", cluster, "'"))
    #label = paste0("test_", sector, "_cluster ", cluster, "_", length(trainingDates), " Days")
    modelLabel = paste0("Cluster", cluster, "_", sector, "_")
    
    train.dataset = getData(sector, trainingDates)
     
    col.input = colnames(train.dataset)[1:(ncol(train.dataset)-1)]
    col.input = col.input[-c(1:3)] ## remove col1 weekday 
    
    train.dataset$bin.output = cut(train.dataset$output,
                                   quantile(train.dataset$output,
                                            c(0, 0.8, 1)),
                                   labels=c(0,1), include.lowest=TRUE)
    train.dataset[train.dataset$output < 1, "bin.output"] = 0
        
    train.dataset$output = NULL
    col.target = "bin.output"
    train.dataset = train.dataset[ , c(col.input, col.target)]  
      
    #results = runTrainValidateAndTest(train.dataset, NULL, test.dataset, modelLabel)
    results = trainSaveModelsC(train.dataset, col.target, col.input, modelLabel)
    
    #     dataset.test$bin.output = cut(dataset.test$output,
    #                                   quantile(dataset.test$output, c(0, 0.8, 1)),
    #                                   labels=c(0,1), include.lowest=TRUE)
    #     
    #     actual.testResults = dataset.test[, c("Date", "SecId", "output", "bin.output")]
    #dataset.test$output = NULL
  }
}

#### Testing: Use models on testing data - 201001 to 201411

channel <- odbcConnect("localDB")
MthBeg=sqlQuery(channel, paste0("SELECT [CalendarDate]  
                                FROM [S&P].[dbo].[tb_Calendar]
                                where CalendarDate>='20091231' and CalendarDate<='20141101'
                                and IsCalMonthBeg=1
                                order by CalendarDate"))[,,drop=T]
MthBeg=as.character(MthBeg)
#i=1
a=sapply(1:(length(MthBeg)-1), function(i) {
  
  windowstartDate=MthBeg[i]
  windowendDate=MthBeg[i+1]
  testingDates = getAllDistinctDatesFactorScore(windowstartDate, windowendDate)
  testingDates=tail(testingDates,1) # get month end
  for (sector in sectors) {
    securities <- sqlQuery(channel, "
                       SELECT *
                       FROM [S&P].[dbo].[tb_SecurityMaster]
                       ")
    secIds = securities[ (securities$SML == 'L' | securities$SML == 'M')
                         # & str_trim(securities$GICS_SEC) == 'Financials',
                         & str_trim(securities$GICS_SEC) == sector,
                         'SecId']
    # sector = "Health Care"
    print(paste0("Starting run on sector '", sector, "' and test date of '", paste0(testingDates, collapse=","), "'"))
    cat(paste("\n","--------------------------------------------------------------------------------------",sep=""));
    cat(paste("\n",substring(date(),5,19)," ::::: Modeling by Sector", sector, " as of ",windowstartDate,sep=""));

    testdata <- sqlQuery(channel, paste0("
                                 SELECT Date, EarningsFY2UpDnGrade_1M, EarningsFY1UpDnGrade_1M, EarningsRevFY1_1M, NMRevFY1_1M,
                                PriceMA10, PriceMA20, PMOM10, RSI14D, EarningsFY2UpDnGrade_3M, FERating, PriceSlope10D,
                                PriceMA50, SalesRevFY1_1M, PMOM20, NMRevFY1_3M, EarningsFY2UpDnGrade_6M,PriceSlope20D,
                                Price52WHigh,EarningsRevFY1_3M,PMOM50,PriceTStat200D,RSI50D,MoneyFlow14D,PriceTStat100D,
                                PEGFY1,Volatility12M,SharesChg12M,PriceMA100,Volatility6M,SalesYieldFY1,EarningsYieldFY2,PriceRetFF20D
                                FROM [S&P].[dbo].[tb_FactorData]
                                WHERE [Date] = '", testingDates,
                                "' AND SECTOR = '", sector,
                                "' AND SecId in (", paste(secIds,collapse=","),
                                ") ORDER by [Date], SecId")) #nov and dec 2008
    
    testdata = data.frame(t(apply(testdata[,-1], 2, mean,na.rm=T)))
    
    # Load cluster fit
    load(paste0(modelsDir, sector, "_clusterfit", ".Rdata"))
    
    ClusterNo=cl_predict(fit, testdata)
    
    test.dataset = getData(sector, testingDates)
    #dataset.test=test.dataset[,-c(1:3)] 
    dataset.test=test.dataset
    dataset.test$bin.output = cut(dataset.test$output,
                                  quantile(dataset.test$output, c(0, 0.8, 1)),
                                  labels=c(0,1), include.lowest=TRUE)

    actual.testResults = dataset.test[, c("Date", "SecId", "output", "bin.output")]
    
    dataset.test$output = NULL
    col.target = "bin.output"
    dataset.test[ , col.target] = NULL
    # Load Models
    load(paste0(modelsDir, "Cluster", ClusterNo, "_", sector, "_model.all", ".Rdata"))
    
    testResults = testModelsC(allModels, test.dataset) 
    testResults$type = "test"
    results = cbind(actual.testResults, "Sector"=sector, "Cluster"=as.numeric(ClusterNo), testResults)
    deleter=sqlQuery(channel, paste("DELETE
                              FROM dbo.tb_StockPredictionCluster where sector='", sector,
                                    "' and Date='" , testingDates, "'", sep=""))
    sqlSave(channel, dat=results, tablename="tb_StockPredictionCluster", rownames=F, varTypes=c(Date="datetime"), append=T)
    }
})  

###

