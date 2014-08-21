shinyUI(fluidPage(
  titlePanel("SmartTrader"),
  sidebarLayout(
    sidebarPanel(
      helpText("Select a stock to examine. 
        Information will be collected from yahoo finance."),
      
      textInput("symb", "Symbol", "SPY"),
      
      dateRangeInput("dates", 
                     "Date range",
                     start = "2008-11-01", 
                     end = "2009-03-01"
#                        as.character(Sys.Date())
                      ),
      
      actionButton("get", "Get Stock"),
      
      br(),
      br(),
      fileInput('file1', 'Choose file to upload',
                accept = c(
                  'text/csv',
                  'text/comma-separated-values',
                  'text/tab-separated-values',
                  'text/plain',
                  '.csv',
                  '.tsv'
                )
      ),
      tags$hr(),
      selectInput("monthModel", label = "select month of models", 
                 choices = list("Nov2008" = 1, "Dec2008" = 2, 
                                "Jan2009" = 3, "Feb2009" = 4,
                                "Mar2009" = 5), selected = 1)
    ),
    mainPanel(
      plotOutput("plot"),
      br(),
      h3("Predicted to Buy: "),
      tableOutput('contents')
    )
  )
))