shinyUI(fluidPage(
  titlePanel("Uploading Files"),
  sidebarLayout(
    sidebarPanel(
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
      h3("Predicted to Buy: "),
      tableOutput('ada')#,
#       tags$hr(),
#       tableOutput('ksvm'),
#       tags$hr(),
#       tableOutput('rf')
    )
  )
))