library(ada)
# By default, the file size limit is 5MB. It can be changed by
# setting this option. Here we'll raise limit to 9MB.
options(shiny.maxRequestSize = 9*1024^2)

modelDir = "models"
shinyServer(function(input, output) {
  datasetInput <- reactive({
    # input$file1 will be NULL initially. After the user selects
    # and uploads a file, it will be a data frame with 'name',
    # 'size', 'type', and 'datapath' columns. The 'datapath'
    # column will contain the local filenames where the data can
    # be found.
    inFile <- input$file1
    if (is.null(inFile))
#       return(NULL)
      filePath = paste0(modelDir, "/scoredData_Financials_2008-12-01.csv")
    else
      filePath = inFile$datapath
    data.test = read.csv(filePath, header = TRUE,
                         stringsAsFactors = FALSE)
    data.test$DayOfWeek = as.factor(weekdays(as.Date(data.test$Date)))
    data.test
  })
  
  output$ada <- renderTable({
    if (is.null(datasetInput())) {
      return(NULL)
    }
    if(input$monthModel == 1) {
      load(paste0(modelDir, "/model.ada_Financials_2008-11-01.Rdata"))     
    }
    tested = predict(model.ada, datasetInput())
    tested = cbind(tested, data.test)
    tested[tested$tested == 1, 
           c("SecId", "CompanyName", "SML", "Date", "Sector")]
  })

#   output$ksvm <- renderTable({
#     if (is.null(datasetInput())) {
#       return(NULL)
#     }
#     if(input$monthModel == 1) {
#       load(paste0(modelDir, "/model.ksvm_Financials_2008-11-01.Rdata"))     
#     }
#     tested = predict(model.ksvm, datasetInput())
#     tested = cbind(tested, data.test)
#     tested[tested$tested == 1, 
#            c("SecId", "CompanyName", "SML", "Date", "Sector")]
#   })
# 
#   output$rf <- renderTable({
#     if (is.null(datasetInput())) {
#       return(NULL)
#     }
#     if(input$monthModel == 1) {
#       load(paste0(modelDir, "/model.rf_Financials_2008-11-01.Rdata"))     
#     }
#     tested = predict(model.rf, datasetInput())
#     tested = cbind(tested, data.test)
#     tested[tested$tested == 1, 
#            c("SecId", "CompanyName", "SML", "Date", "Sector")]
#   })

})

# load("models/model.ada_Consumer Discretionary_2008-11-01.Rdata")
# data.test = read.csv("../../data/dayData/scoredData_Consumer Discretionary_2008-12-01.csv"
#                        , header = TRUE,
#                        stringsAsFactors = FALSE)
# load("models/model.ada_Financials_2008-11-01.Rdata")
# data.test = read.csv("shiny/models/scoredData_Financials_2008-12-01.csv"
#                        , header = TRUE,
#                        stringsAsFactors = FALSE)
# data.test$DayOfWeek = as.factor(weekdays(as.Date(data.test$Date)))
# tested = predict(model.ada, data.test)
# tested = cbind(tested, data.test)
# tested[tested$tested == 1, "CompanyName"]
