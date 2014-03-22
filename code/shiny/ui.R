
# This is the user-interface definition of a Shiny web application.
# You can find out more about building applications with Shiny here:
# 
# http://www.rstudio.com/shiny/
#

library(shiny)

shinyUI(pageWithSidebar(
  
  # Application title
  headerPanel("SmartTrader"),
  
  # Sidebar with a slider input for number of observations
  sidebarPanel(
    sliderInput("obs", 
                "No. of stocks in the output list:", 
                min = 1, 
                max = 20, 
                value = 5),
    checkboxInput('sales', 'Sales', TRUE),
    checkboxInput('High', 'High', TRUE),
    checkboxInput('cashFlow', 'cash Flow', TRUE),
    textInput("return", "Minimum expected return over a desired period, %", "10"),
    selectInput("dataset", "Holding Period:", 
                choices = c("1 day", "1 week", "1 month"))
  ),
  
  # Show a plot of the generated distribution
  mainPanel(
    plotOutput("distPlot"),
    dataTableOutput("tableOut")
  )
))
