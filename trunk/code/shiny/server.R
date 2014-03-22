library(zoo)
# This is the server logic for a Shiny web application.
# You can find out more about building applications with Shiny here:
# 
# http://www.rstudio.com/shiny/
#

library(shiny)

load("histclose.Rdata")
load("df.hist.Rdata")

shinyServer(function(input, output) {
   
  symbolNames <- reactive({
    histclose[1:input$obs, ]
  })
  
  output$distPlot <- renderPlot({   
    dates=rownames(df.hist)
    ts=zoo(df.hist, as.Date(dates,"%m.%d.%Y"))
    #head(ts,30)
    plot(ts[,1:input$obs])
  })
  
  output$tableOut <- renderDataTable({
    symbolNames()[,c("symbol","Name","Sector","Industry")]
  }, option=list(iDisplayLength=50,bSortClasses = TRUE,bAutoWidth=FALSE,
                 aoColumnDefs = list(list(sWidth=c("20px"), 
                                          aTargets=c(list(0),list(1),list(2), list(3)))))                                    )
  
  
})
