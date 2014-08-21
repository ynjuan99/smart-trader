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
      tags$hr(),
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
      selectInput("sector", label = "Select Sector", 
                  choices = list("Financials" = 1, "All" = 2, "Health Care" =3, 
                                 "Information Technology" = 4, 
                                 "Consumer Discretionary" = 5,                 
                                 "Telecommunication Services" = 6, 
                                 "Utilities" = 7, "Industrials" = 8, 
                                 "Energy" = 9, "Materials" = 10, 
                                 "Consumer Staples" = 11), selected = 1),
      tags$hr(),
      selectInput("monthYearModel", label = "Select Month of Models", 
                 choices = list("Nov2008" = 1, "Dec2008" = 2, 
                                "Jan2009" = 3, "Feb2009" = 4,
                                "Mar2009" = 5, "Apr2009" = 6,
                                "May2009" = 7, "Jun2009" = 8,
                                "Jul2009" = 9, "Aug2009" = 10,
                                "Sep2009" = 11, "Oct2009" = 12,
                                "Nov2009" = 13), 
                 selected = 1)
    ),
    mainPanel(
      plotOutput("plot"),
      br(),
      h3("Predicted to Buy: "),
      tableOutput('contents')
    )
  )
))