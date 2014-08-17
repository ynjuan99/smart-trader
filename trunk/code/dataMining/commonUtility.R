addLibrary <- function() {
  .libPaths()
  .libPaths(c(.libPaths(), "C:/Revolution/R-Enterprise-7.0/R-3.0.2/library"))
}

updateVersionOfR <- function() {
  # installing/loading the package:
  if(!require(installr)) { 
    install.packages("installr"); require(installr)} #load / install+load installr
  updateR() # this will only work AFTER R 3.0.0 will be released to your CRAN mirror
  update.packages(checkBuilt=TRUE)
}

#returns 14May2014
getCurrentDate <- function() {
  return(format(Sys.time(), "%d%b%Y"))
}

#getDate('2008-11-30')
getDate <- function(date) {
  return(as.Date(date, "%Y-%m-%d"))
}

#use paste0
concatenate <- function(str1, str2) {
  return(paste(str1,str2, sep=""))
}

# Transform variables by rescaling to [0,1] 
#col.rescale = col.input
#for (i in 1:length(col.rescale)) {
#  dataset.train[[paste(col.rescale[i],"r",sep="")]] <-  rescaler(dataset.train[[col.rescale[i]]], "range")  
#  dataset.train[[col.rescale[i]]] <- NULL
#}

#col.rescale = colnames(numeric.data)
#for (i in 1:length(col.rescale)) {
#  numeric.data[[paste(col.rescale[i],"_num",sep="")]] <-  as.numeric(numeric.data[[col.rescale[i]]])
#  numeric.data[[col.rescale[i]]] <- NULL
#}

#  posts.twitter$time = strptime(posts.twitter$datetime, 
#                                format='%a %b %d %H:%M:%S %z %Y') #with %z time will be saved as current locale

#aggregate.monetary = aggregate(rfm.data$SaleAmount,list(rfm.data$CustomerID),sum)
#aggregate.frequency = aggregate(rfm.data$SaleAmount,list(rfm.data$CustomerID),length)
#aggregate.recency = aggregate(rfm.data$recency,list(rfm.data$CustomerID),min)
