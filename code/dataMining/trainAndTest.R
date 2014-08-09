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

trainAndTest <- function(model.dataset, test.dataset, col.target, col.input) {
  
  # Decision Tree 
#   model.rpart <- rpart(as.formula(concatenate(col.target," ~ .")),
#                        data=model.dataset,
#                        method="class",
#                        parms=list(split="information"),
#                        control=rpart.control(usesurrogate=0, 
#                                              maxsurrogate=0))
#   windows()
#   fancyRpartPlot(model.rpart, main="Decision Tree Splits")
  
  # Build a Support Vector Machine model.
  model.ksvm <- ksvm(as.formula(concatenate("as.factor(", concatenate(col.target,") ~ ."))),
                     data=model.dataset,
                     kernel="rbfdot",
                     prob.model=TRUE)
  
  #neutral net
  #using Sum of Squares Residuals to get best number for Hidden Layer Nodes
#   sumSquaresResiduals = 99999999999
#   nohiddenNodes = 0
#   for(hiddenNodes in 90:120) { #round(length(col.input)*0.12)) {
#     tempModel <- nnet(as.formula(concatenate("as.factor(", concatenate(col.target,") ~ ."))),
#          data=model.dataset,
#          size=hiddenNodes, skip=TRUE, MaxNWts=10000, trace=FALSE, maxit=100)
#     cat(sprintf("Sum of Squares Residuals: %.4f for %d hidden layer nodes.\n",
#                 sum(residuals(tempModel) ^ 2), hiddenNodes))    
#     tempsumSquaresResiduals = sum(residuals(tempModel) ^ 2)
#     if (tempsumSquaresResiduals < sumSquaresResiduals) {
#       sumSquaresResiduals = tempsumSquaresResiduals
#       nohiddenNodes = hiddenNodes
#     }
#   }
  nohiddenNodes = 100
  cat(sprintf("Using NN Model with %d hidden layer nodes.\n", nohiddenNodes))
  model.nnet <- nnet(as.formula(concatenate("as.factor(", concatenate(col.target,") ~ ."))),
                     data=model.dataset,
                     size=nohiddenNodes, skip=TRUE, MaxNWts=10000, trace=FALSE, maxit=100)
  
  # Random Forest 
  model.rf <- randomForest(as.formula(concatenate("as.factor(", concatenate(col.target,") ~ ."))),
                           data=model.dataset,
                           ntree=500,
                           mtry=14,
                           importance=TRUE,
                           na.action=na.roughfix,
                           replace=FALSE)
#   windows()
#   #Plot the relative importance of the variables.
#   varImpPlot(model.rf, main="Variable Importance of Random Forest")
  
  #Ada boost
  model.ada <- ada(as.formula(concatenate(col.target," ~ .")),
                   data=model.dataset,
                   control=rpart.control(maxdepth=30,
                                         cp=0.010000,
                                         minsplit=20,
                                         xval=10),
                   iter=100)
#   windows()
#   varplot(model.ada) #doesnt work, main="Variable Importance of Boost")
#   windows()  
#   plot(model.ada)  # Plot the error rate as we increase the number of trees.
       
  #Testing
  results = list()
  results$actual = test.dataset[,col.target]
  test.dataset[,col.target] = NULL

#   results$rpart = predict(model.rpart, test.dataset, type="class")
  results$ksvm = predict(model.ksvm, test.dataset) #cannot put class
  results$nnet = predict(model.nnet, test.dataset, type="class")
  results$rf = predict(model.rf, test.dataset, type="class")
  results$ada = predict(model.ada, test.dataset)
#   results$rpart.prob = predict(model.rpart, test.dataset)
  results$ksvm.prob = predict(model.ksvm, test.dataset, type="probabilities")
  results$nnet.prob = predict(model.nnet, test.dataset)
  results$rf.prob = predict(model.rf, test.dataset, type="vote")
  results$ada.prob = predict(model.ada, test.dataset, type="prob")
  results = data.frame(results)
  #majority votes
  results$votes= #as.integer(results$rpart)+ #becomes 1s and 2s
    as.integer(results$ksvm)+
    as.integer(results$nnet)+
    as.integer(results$rf)+
    as.integer(results$ada) -4 #to make 0s and 1s
  results$voted = results$votes - 2 #become -ve, +ve
  results$voted = results$voted/abs(results$voted)
  results$voted[results$voted==-1] = 0
  #probability votes
  results$all.prob =  ( #results$rpart.prob.1 *0.25 + 
                         results$ksvm.prob.1 *0.2 + 
                         results$nnet.prob *0.3 + 
                        results$rf.prob.1 *0.3+
                         results$ada.prob.2 *0.2) 
  results$voted.prob = results$all.prob - 0.5
  results$voted.prob = results$voted.prob/abs(results$voted.prob)
  results$voted.prob[results$voted.prob==-1] = 0
  
return(results)
#   errorMatrix <- as.data.frame(table(results$actual, results$rpart))
#   colnames(errorMatrix) = c("Actual", "Predicted", "rpart")
#   temp <- as.data.frame(table(results$actual, results$ksvm))
#   errorMatrix$ksvm = temp$Freq
#   temp <- as.data.frame(table(results$actual, results$nnet))
#   errorMatrix$nnet = temp$Freq
#   temp <- as.data.frame(table(results$actual, results$rf))
#   errorMatrix$rf = temp$Freq
#   temp <- as.data.frame(table(results$actual, results$ada))
#   errorMatrix$ada = temp$Freq
#   temp <- as.data.frame(table(results$actual, results$voted))
#   errorMatrix$voted = temp$Freq
#   temp <- as.data.frame(table(results$actual, results$voted.prob))
#   errorMatrix$voted.prob = temp$Freq
#   
#   for(i in 1:(length(errorMatrix)-2)) {
#     colno = 2+i
#     #percent correct
#     errorMatrix[5,colno] = (errorMatrix[1,colno] + errorMatrix[4,colno])/
#       (errorMatrix[1,colno] + errorMatrix[2,colno] + errorMatrix[3,colno] + errorMatrix[4,colno])
#   }
#   
#   # plot(table(results$actual, results$rpart),xlab="Predicted Tree", ylab="Actual")
#   # plot(table(results$actual, results$ksvm),xlab="Predicted SVN", ylab="Actual")
#   # plot(table(results$actual, results$nnet),xlab="Predicted Neutral Net", ylab="Actual")
#   # plot(table(results$actual, results$rf),xlab="Predicted Random Forest", ylab="Actual")
#   # plot(table(results$actual, results$ada),xlab="Predicted Boost", ylab="Actual")
#   
#   pred.rpart <- prediction(results$rpart.prob.1, results$actual)
#   pred.ksvm <- prediction(results$ksvm.prob.1, results$actual)
#   pred.nnet <- prediction(results$nnet.prob, results$actual)
#   pred.rf <- prediction(results$rf.prob.1, results$actual)
#   pred.ada <- prediction(results$ada.prob.2, results$actual)
# 
#   #ROC Curve
#   windows()
#   plot(performance(pred.rpart, "tpr", "fpr"), col="#CC0000FF", lty=1, add=FALSE)
#   plot(performance(pred.ksvm, "tpr", "fpr"), col="#00CC00FF", lty=2, add=TRUE)
#   plot(performance(pred.nnet, "tpr", "fpr"), col="#0000CCFF", lty=3, add=TRUE)
#   plot(performance(pred.rf, "tpr", "fpr"), col="#0052CCFF", lty=4, add=TRUE)
#   plot(performance(pred.ada, "tpr", "fpr"), col="#A300CCFF", lty=5, add=TRUE)
#   legend("bottomright", c("rpart","ksvm","nnet", "rf", "ada"), col=rainbow(5, 1, .8), lty=1:5, title="Models", inset=c(0.05, 0.05))
#   title(main="ROC Curve")
#   #       sub=paste("Rattle", format(Sys.time(), "%Y-%b-%d %H:%M:%S"), Sys.info()["user"]))
#   grid()
#   
#   #area under the curve
#   errorMatrix[6,3] = (performance(pred.rpart, "auc"))@y.values
#   errorMatrix[6,4] = (performance(pred.ksvm, "auc"))@y.values
#   errorMatrix[6,5] = (performance(pred.nnet, "auc"))@y.values
#   errorMatrix[6,6] = (performance(pred.rf, "auc"))@y.values
#   errorMatrix[6,7] = (performance(pred.ada, "auc"))@y.values
#   
#   #Lift Chart
#   # Convert rate of positive predictions to percentage.
#   per.rpart <- performance(pred.rpart, "lift", "rpp")
#   per.ksvm <- performance(pred.ksvm, "lift", "rpp")
#   per.nnet <- performance(pred.nnet, "lift", "rpp")
#   per.rf <- performance(pred.rf, "lift", "rpp")
#   per.ada <- performance(pred.ada, "lift", "rpp")
#   
#   per.rpart@x.values[[1]] <- per.rpart@x.values[[1]]*100
#   per.ksvm@x.values[[1]] <- per.ksvm@x.values[[1]]*100
#   per.nnet@x.values[[1]] <- per.nnet@x.values[[1]]*100
#   per.rf@x.values[[1]] <- per.rf@x.values[[1]]*100
#   per.ada@x.values[[1]] <- per.ada@x.values[[1]]*100
#   
#   # Plot the lift chart.
#   windows()
#   plot(per.rpart, col="#CC0000FF", lty=1, xlab="Caseload (%)", add=FALSE)
#   plot(per.ksvm, col="#00CC00FF", lty=2, xlab="Caseload (%)", add=TRUE)
#   plot(per.nnet, col="#0000CCFF", lty=3, xlab="Caseload (%)", add=TRUE)
#   plot(per.rf, col="#0052CCFF", lty=4, xlab="Caseload (%)", add=TRUE)
#   plot(per.ada, col="#A300CCFF", lty=5, xlab="Caseload (%)", add=TRUE)
#   legend("bottomleft", c("rpart","ksvm","nnet", "rf", "ada"), col=rainbow(5, 1, .8), lty=1:5, title="Models", inset=c(0.05, 0.05))
#   title(main="Lift Chart")
#   grid()
#   
#   return(errorMatrix)
}

#errorMatrix
#first 4 rows is the actual and predicted results from the various models
#5th row is the overall correct results from the first 4 rows
#6th row is the respective ROC's area under the curve.