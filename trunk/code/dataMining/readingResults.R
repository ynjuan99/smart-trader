results.dir = "../../results/"
resultfiles = list.files(results.dir)  

sectors =     c("All", "Health Care", "Information Technology", 
                "Consumer Discretionary", "Financials",                
                "Telecommunication Services", "Utilities",                 
                "Industrials", "Energy", "Materials", "Consumer Staples") 

transposedErrorMatrix = data.frame()
for (sector in sectors) {
  grepfiles = resultfiles[grep(paste0("errorMatrix.test_", sector), 
                               resultfiles)]
  for (grepfile in grepfiles) {
    file.date = unlist(strsplit(unlist(strsplit(grepfile, "_"))[3],
                                ".", fixed=TRUE))[1]
    file.date = as.Date(file.date)
    temp = read.csv(paste0(results.dir,grepfile))
    temp = data.frame(t(temp[4:16])) #ncol(temp)?
                #00, 10, 01, 11
    colnames(temp) = c("True Negative", "False Negative", 
                  "False Positive", "True Positive", 
                  "Mean Of Bought Returns")
    temp$Models = row.names(temp)
    temp$Date = file.date
    temp$Sector = sector
    transposedErrorMatrix = rbind(transposedErrorMatrix, temp)
  }
}

write.csv(transposedErrorMatrix, 
          paste0(results.dir,"compiled_ErrorMatrix.csv"), 
          row.names= FALSE)
