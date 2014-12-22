results.dir = "results/"
resultfiles = list.files(results.dir)  

sectors =     c("Health Care", "Information Technology", 
                "Consumer Discretionary", "Financials",                
                "Telecommunication Services", "Utilities",                 
                "Industrials", "Energy", "Materials", "Consumer Staples") #"All", 
#errorMatrix._Health Care_2013-11-01to2013-11-29.testtest_Health Care_2013-12-02to2013-12-31
transposedErrorMatrix = data.frame()
for (sector in sectors) {
  grepfiles = resultfiles[grep(paste0("errorMatrix._", sector), 
                               resultfiles)]
  for (grepfile in grepfiles) {
    window.date = unlist(strsplit(unlist(strsplit(grepfile, "_"))[3],
                                ".", fixed=TRUE))[1]
#     file.date = as.Date(file.date)
    temp = read.csv(paste0(results.dir,grepfile))
    temp = data.frame(t(temp[4:10])) #ncol(temp)?
                #00, 10, 01, 11
    colnames(temp) = c("True Negative", "False Negative", 
                  "False Positive", "True Positive", 
                  "Mean Of Bought Returns")
    temp$Models = row.names(temp)
    temp$Window = window.date
    temp$Sector = sector
    transposedErrorMatrix = rbind(transposedErrorMatrix, temp)
  }
}

write.csv(transposedErrorMatrix, 
          paste0(results.dir,"compiled_ErrorMatrix.csv"), 
          row.names= FALSE)

#got error when no rows i think
# source("Windows_Testing/otherModels_specify.R")
# singleDate_transposedErrorMatrix = data.frame()
# singleDate = '2013-12-27'  
# for (sector in sectors) {
#   grepfiles = resultfiles[grep(paste0("results.train_", sector), 
#                                resultfiles)]
# #   grepfile = grepfiles[1]
# for (grepfile in grepfiles) {
#     window.date = unlist(strsplit(unlist(strsplit(grepfile, "_"))[3],
#                                   ".", fixed=TRUE))[1]
#     #     file.date = as.Date(file.date)
#     temp = read.csv(paste0(results.dir,grepfile))
#     temp = temp[temp$Date == singleDate,]
#     temp$actual = temp$bin.output
#     errM = getErrorMatrix(temp)
#     errM = data.frame(errM)
#     errM = data.frame(t(errM[3:9]))  
#     #00, 10, 01, 11
#     colnames(errM) = c("True Negative", "False Negative", 
#                        "False Positive", "True Positive", 
#                        "Mean Of Bought Returns")
#     errM$Models = row.names(errM)
#     errM$Window = window.date
#     errM$Sector = sector
#     singleDate_transposedErrorMatrix = rbind(singleDate_transposedErrorMatrix, errM)
#   }
# }

