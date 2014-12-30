source("Windows_Testing2/runWindow.R")

channel <- odbcConnect("localDB")
MthBeg=sqlQuery(channel, paste0("SELECT [CalendarDate]  
FROM [S&P].[dbo].[tb_Calendar]
where CalendarDate>='20040101' and CalendarDate<='20141101'
and IsCalMonthBeg=1
order by CalendarDate"))[,,drop=T]
MthBeg=as.character(MthBeg)
#i=1
## 1 year window
windowMth=3
a=sapply(1:(length(MthBeg)-windowMth-1), function(i) {

windowstartDate=MthBeg[i]
windowendDate=MthBeg[i+windowMth+1]
teststartDate=MthBeg[i+windowMth]
  
runWindow(windowstartDate = windowstartDate,
          windowendDate = windowendDate,
          teststartDate = teststartDate, windowMth=windowMth) #2nd date not inclusive

})

## 3 month window
# windowMth=3
# a=sapply(1:length(MthBeg)-windowMth-1), function(i) {
#   
#   StartDate=MthBeg[i]
#   EndDate=MthBeg[i+windowMth+1]
#   TestDate=MthBeg[i+windowMth]
#   
#   runWindow(windowstartDate = StartDate,
#             windowendDate = EndDate,
#             teststartDate = TestDate, windowMth=windowMth) #2nd date not inclusive
#   
# })

# runWindow(windowstartDate = '2013-09-01',
#           windowendDate = '2014-01-01',
#           teststartDate ='2013-12-01') #2nd date not inclusive
# 
# runWindow(windowstartDate = '2013-06-01',
#           windowendDate = '2014-01-01',
#           teststartDate ='2013-12-01') #2nd date not inclusive
