library(ada)
library(kernlab)
library(nnet)
library(randomForest)

library(quantmod)
library(stringr)
# By default, the file size limit is 5MB. It can be changed by
# setting this option. Here we'll raise limit to 9MB.
options(shiny.maxRequestSize = 9*1024^2)

modelDir = "../models"
testDataDir = "../../../data/dayData/"
sectors = 
  c("Financials", "All", "Health Care", "Information Technology", 
    "Consumer Discretionary",                
    "Telecommunication Services", "Utilities",                 
    "Industrials", "Energy", "Materials", "Consumer Staples") 
yearModel = c(rep("2008",2), rep("2009", 12))
monthModel = as.character(c(11:12, 1:12))
monthModel = str_pad(monthModel, 2, side="left", pad = 0)

shinyServer(function(input, output, session) {
  datasetInput <- reactive({
    # input$file1 will be NULL initially. After the user selects
    # and uploads a file, it will be a data frame with 'name',
    # 'size', 'type', and 'datapath' columns. The 'datapath'
    # column will contain the local filenames where the data can
    # be found.
    inFile <- input$file1
    if (is.null(inFile))
#       return(NULL)
      filePath = paste0(testDataDir, "scoredData_Financials_2008-12-01.csv")
    else
      filePath = inFile$datapath
    print(filePath)
    data.test = read.csv(filePath, header = TRUE,
                         stringsAsFactors = FALSE)
#     print(head(data.test))
    data.test$DayOfWeek = factor(weekdays(as.Date(data.test$Date)), 
                                 levels = c("Monday","Tuesday","Wednesday",
                                            "Thursday","Friday"
                                            #                                            ,"Saturday","Sunday"
                                 ))
    data.test
  })

  modelName <- reactive({
    if (is.null(input$sector) | is.null(input$monthYearModel)) {
      updateSelectInput(session, "sector", value=1)
      updateSelectInput(session, "monthYearModel", value=1)
    }
    paste0(sectors[as.integer(input$sector)], "_", 
             yearModel[as.integer(input$monthYearModel)], "-", 
             monthModel[as.integer(input$monthYearModel)], "-01")
  })
  
  model.ada <- reactive({
    load(paste0(modelDir, "/model.ada_", modelName(), ".Rdata"))    
    model.ada
  })
  model.ksvm <- reactive({
    load(paste0(modelDir, "/model.ksvm_", modelName(), ".Rdata"))
    model.ksvm
  })
  model.nnet <- reactive({
    load(paste0(modelDir, "/model.nnet_", modelName(), ".Rdata"))  
    model.nnet
  })
  model.rf <- reactive({
    load(paste0(modelDir, "/model.rf_", modelName(), ".Rdata"))  
    model.rf
  })

  output$plot <- renderPlot({
    data <- getSymbols(input$symb, src = "yahoo", 
                       from = input$dates[1],
                       to = input$dates[2],
                       auto.assign = FALSE)
    
    chartSeries(data, theme = chartTheme("white"), 
                type = "line", TA = NULL)
  })

  output$contents <- renderTable({
    if (is.null(datasetInput())) {
      return(NULL)
    }

    #Testing
    results = list()
    print("maybe the data does not work for this model. ")
    
    #   results$rpart = predict(model.rpart, test.dataset.withoutTarget, type="class")
    results$ksvm = predict(model.ksvm(), datasetInput()) #cannot put class
    print("still works.")
    results$nnet = predict(model.nnet(), datasetInput(), type="class")
    results$rf = predict(model.rf(), datasetInput(), type="class")
    results$ada = predict(model.ada(), datasetInput())
    #   results$rpart.prob = predict(model.rpart, test.dataset.withoutTarget)
    results$ksvm.prob = tryCatch(
      predict(model.ksvm(), datasetInput(), type="probabilities"),
      error = function(e) {
        print(paste("ksvm no probabilities"))
        return(NULL)
      })
    #   results$ksvm.prob = predict(model.ksvm, test.dataset.withoutTarget, type="probabilities")
    results$nnet.prob = predict(model.nnet(), datasetInput())
    results$rf.prob = predict(model.rf(), datasetInput(), type="vote")
    results$ada.prob = predict(model.ada(), datasetInput(), type="prob")
    results = data.frame(results)
    #majority votes
    results$votes= #as.integer(results$rpart)+ #becomes 1s and 2s
      as.integer(results$ksvm)+
      as.integer(results$nnet)+
      as.integer(results$rf)+
      as.integer(results$ada) -4 #to make 0s and 1s
    results$voted = results$votes - 2 #become -ve, +ve
    results$voted = results$voted/abs(results$voted)
    results$voted[is.na(results$voted)] = 0
    results$voted[results$voted==-1] = 0

    #probability votes
    if (length(results$ksvm.prob.1) == 0) {  
      results$all.prob =  ( #results$rpart.prob.1 *0.25 + 
        #     results$ksvm.prob.1 *0.25 + 
        results$nnet.prob *0.33 + 
          results$rf.prob.1 *0.34+
          results$ada.prob.2 *0.33) 
    } else { #use the other 3 only
      results$all.prob =  ( #results$rpart.prob.1 *0.25 + 
        results$ksvm.prob.1 *0.25 + 
          results$nnet.prob *0.25 + 
          results$rf.prob.1 *0.25+
          results$ada.prob.2 *0.25) 
    }
    results$voted.prob = results$all.prob - 0.5
    results$voted.prob = results$voted.prob/abs(results$voted.prob)
    results$voted.prob[results$voted.prob==-1] = 0
    
    results = cbind(results, datasetInput())
    resultsToShow = results[results$votes > 0, 
           c("BBTicker", "SecId", "CompanyName", "SML", "Date", "Sector",
             "ksvm", "nnet", "rf", "ada",
             "votes",	"voted",	"all.prob", "voted.prob"
           )]
#     print(resultsToShow$votes)
    orderDes = order(resultsToShow$votes, decreasing=TRUE)
    updateTextInput(session, 'symb', 
                value=str_trim(resultsToShow[orderDes[1], "BBTicker"]))
    print(resultsToShow[orderDes, "BBTicker"])
    resultsToShow[orderDes,]
  })
  
  output$rfVarImp <- renderPlot({
    varImpPlot(model.rf(), main="Variable Importance Plot")
  })

  output$adaVarImp <- renderPlot({
    varplot(model.ada()) # , main="Ada's Variable Importance") does not change name
  })
})

# # load("models/model.ada_Consumer Discretionary_2008-11-01.Rdata")
# # data.test = read.csv("../../data/dayData/scoredData_Consumer Discretionary_2008-12-01.csv"
# #                        , header = TRUE,
# #                        stringsAsFactors = FALSE)
# # load("models/model.ada_Financials_2008-11-01.Rdata")
# data.test = read.csv("models/scoredData_Financials_2008-12-01.csv"
#                        , header = TRUE, #row.names=FALSE,
#                        stringsAsFactors = FALSE)
# 
# ### Convert columns format to numeric
# data.test[,7:ncol(data.test)]=apply(data.test[,7:ncol(data.test)],2,as.numeric)
# 
# col.input = colnames(data.test)
# 
# #columns that have more than 20% not filled.
# columnsToRemove = colnames(data.test[,7:ncol(data.test)])[
#   apply(data.test[,7:ncol(data.test)], 2, function(x) sum(is.na(x))) > 0.2 * nrow(data.test)]
# for (i in 7:ncol(data.test)) {
#   if (length(unique(data.test[,i])) < 4)
#     columnsToRemove = c(columnsToRemove, colnames(data.test)[i])
# }
# col.input = col.input[ !col.input %in% columnsToRemove]  
# data.test$DayOfWeek = factor(weekdays(as.Date(data.test$Date)), 
#                                 levels = c("Monday","Tuesday","Wednesday",
#                                            "Thursday","Friday"
# #                                            ,"Saturday","Sunday"
#                                            ))
# 
# col.input = c(col.input[1:6], "DayOfWeek", col.input[7:length(col.input)])
# data.test = data.test[,col.input] #put in front so later easier
# 
# # data.test[,7:ncol(data.test)]=apply(data.test[,7:ncol(data.test)],2,as.numeric)
# # data.test$DayOfWeek = as.factor(weekdays(as.Date(data.test$Date)))
# str(data.test[,7:ncol(data.test)])
# results = list()
# results$ada = predict(model.ada, data.test)
# results$ksvm = predict(model.ksvm, data.test[,7:ncol(data.test)])
# results$nnet = predict(model.nnet, data.test, type="class")
# results$rf = predict(model.rf, data.test[,7:ncol(data.test)], type="class")
# varImpPlot(model.rf, main="Variable Importance of Random Forest")
# 
# str(data.test)
# # tested = cbind(tested, data.test)
# # tested[tested$tested == 1, "CompanyName"]

