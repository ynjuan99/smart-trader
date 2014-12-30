library(RODBC)
library(Hmisc)
options(stringsAsFactors=F)
channel <- odbcConnect("localDB")
PARM.dtto='20141031'
#paste(MthEnd, collapse = "','")
MthEnd=as.character(sqlQuery(channel, 
paste("SELECT [CalendarDate]
FROM [S&P].[dbo].[tb_Calendar]
where IsBizMonthEnd=1 and CalendarDate>='20040401' and  CalendarDate<='20141031' ",sep=""))[,,drop=T])

StockPred <- sqlQuery(channel, paste("SELECT a.*, b.PriceRetFF20D
                                 FROM [S&P].[dbo].[tb_StockPrediction] a left join [S&P].[dbo].[tb_FactorData] b
                                 on a.Date=b.Date and a.SecId=b.SecId where a.date in ('", 
                                 paste(MthEnd, collapse = "','"), "')", sep="")) #PriceRetFF20D,

StockPred=StockPred[order(StockPred$Date),]
StockPred[,c(5:12,14)]=sapply(StockPred[,c(5:12,14)], as.numeric)
#StockPred=StockPred[169708:179827]
str(StockPred)
StockPredDay=split(StockPred,as.character(StockPred$Date))
StockPredDaySect=lapply(StockPredDay, function(df.Day) split(df.Day,df.Day$Sector) )

## By Day/Sector
StatsByDaySect=lapply(StockPredDaySect, function(df.day)
{
  lapply(df.day, function(test)
  {
    
    Total=No.ksvm=No.rf=Accuracy.ksvm=Precision.ksvm=Sensitivity.ksvm=
    Specificity.ksvm=Accuracy.rf=Precision.rf=Sensitivity.rf=Specificity.rf=MeanRetPred.ksvm=MeanRetPred.rf=NA
    
    Total=nrow(test)
    No.ksvm=sum(test$ksvm==1)
    No.rf=sum(test$rf==1)
    
    Accuracy.ksvm=sum(test$binoutput==test$ksvm)/nrow(test)
    if (sum(test$ksvm==1)>0) Precision.ksvm=sum(test$binoutput[test$ksvm==1]==1)/sum(test$ksvm==1)
    Sensitivity.ksvm=sum(test$ksvm[test$binoutput==1]==1)/sum(test$binoutput==1)
    Specificity.ksvm=sum(test$ksvm[test$binoutput==0]==0)/sum(test$binoutput==0)
    
    Accuracy.rf=sum(test$binoutput==test$rf)/nrow(test)
    if (sum(test$rf==1)>0) Precision.rf=sum(test$binoutput[test$rf==1]==1)/sum(test$rf==1)
    Sensitivity.rf=sum(test$rf[test$binoutput==1]==1)/sum(test$binoutput==1)
    Specificity.rf=sum(test$rf[test$binoutput==0]==0)/sum(test$binoutput==0)
    
    MeanRetAll=mean(test$PriceRetFF20D, na.rm=T)
    if (sum(test$ksvm==1)>0) MeanRetPred.ksvm=mean(test$PriceRetFF20D[test$ksvm==1], na.rm=T)
    if (sum(test$rf==1)>0) MeanRetPred.rf=mean(test$PriceRetFF20D[test$rf==1], na.rm=T)
    
    Stats=data.frame("Date"=unique(test$Date),"Sector"=unique(test$Sector),"TotalStocks"=Total,"NoPred.SVM"=No.ksvm,"NoPred.rf"=No.rf,
                     "Accuracy.ksvm"=Accuracy.ksvm,"Precision.ksvm"=Precision.ksvm,"Sensitivity.ksvm"=Sensitivity.ksvm,
                     "Specificity.ksvm"=Specificity.ksvm,"Accuracy.rf"=Accuracy.rf,"Precision.rf"=Precision.rf,"Sensitivity.rf"=Sensitivity.rf,
                     "Specificity.rf"=Specificity.rf,MeanRetAll,MeanRetPred.ksvm,MeanRetPred.rf)
    return(Stats)
  })
})

StatsByDaySect=lapply(StatsByDaySect, function(df.Sector) do.call('rbind',df.Sector))
StatsByDaySect=do.call('rbind',StatsByDaySect)

## By Day/All Sectors
StatsByDayAll=lapply(StockPredDay, function(test)
{
  
  Total=No.ksvm=No.rf=Accuracy.ksvm=Precision.ksvm=Sensitivity.ksvm=
    Specificity.ksvm=Accuracy.rf=Precision.rf=Sensitivity.rf=Specificity.rf=NA
  
  Total=nrow(test)
  No.ksvm=sum(test$ksvm==1)
  No.rf=sum(test$rf==1)
  
  Accuracy.ksvm=sum(test$binoutput==test$ksvm)/nrow(test)
  if (sum(test$ksvm==1)>0) Precision.ksvm=sum(test$binoutput[test$ksvm==1]==1)/sum(test$ksvm==1)
  Sensitivity.ksvm=sum(test$ksvm[test$binoutput==1]==1)/sum(test$binoutput==1)
  Specificity.ksvm=sum(test$ksvm[test$binoutput==0]==0)/sum(test$binoutput==0)
  
  Accuracy.rf=sum(test$binoutput==test$rf)/nrow(test)
  if (sum(test$rf==1)>0) Precision.rf=sum(test$binoutput[test$rf==1]==1)/sum(test$rf==1)
  Sensitivity.rf=sum(test$rf[test$binoutput==1]==1)/sum(test$binoutput==1)
  Specificity.rf=sum(test$rf[test$binoutput==0]==0)/sum(test$binoutput==0)
  
  MeanRetAll=mean(test$PriceRetFF20D, na.rm=T)
  if (sum(test$ksvm==1)>0) MeanRetPred.ksvm=mean(test$PriceRetFF20D[test$ksvm==1], na.rm=T)
  if (sum(test$rf==1)>0) MeanRetPred.rf=mean(test$PriceRetFF20D[test$rf==1], na.rm=T)
  
  Stats=data.frame("Date"=unique(test$Date),"Sector"="AllSectors","TotalStocks"=Total,"NoPred.SVM"=No.ksvm,"NoPred.rf"=No.rf,
                   "Accuracy.ksvm"=Accuracy.ksvm,"Precision.ksvm"=Precision.ksvm,"Sensitivity.ksvm"=Sensitivity.ksvm,
                   "Specificity.ksvm"=Specificity.ksvm,"Accuracy.rf"=Accuracy.rf,"Precision.rf"=Precision.rf,"Sensitivity.rf"=Sensitivity.rf,
                   "Specificity.rf"=Specificity.rf,MeanRetAll,MeanRetPred.ksvm,MeanRetPred.rf)
  return(Stats)
})

StatsByDayAll=do.call('rbind',StatsByDayAll)
StatsAll=rbind(StatsByDayAll,StatsByDaySect)
StatsAll=StatsAll[order(StatsAll$Date),]

#StatsAll2=StatsAll[as.character(StatsAll$Date)%in%MthEnd[106:117],]

StatsAllAvg=aggregate(StatsAll[,3:16], list(Sector=StatsAll$Sector), FUN=mean, na.rm=T)

StatsAll$Year=substring(StatsAll$Date,1,4)
StatsAll$Mth=substring(StatsAll$Date,6,7)

Stats.SVM=StatsAll[,Cs(Date,Year,Mth,Sector,Accuracy.ksvm,Sensitivity.ksvm,Specificity.ksvm,Precision.ksvm)]
Stats.rf=StatsAll[,Cs(Date,Year,Mth,Sector,Accuracy.rf,Sensitivity.rf,Specificity.rf,Precision.rf)]
Stats.SVM=data.frame("ModelName"="SVM",Stats.SVM)
Stats.rf=data.frame("ModelName"="RandomForest",Stats.rf)
names(Stats.SVM)=names(Stats.rf)=Cs(ModelName,Date,ForYear,ForMth,Sector,
                                    Accuracy,Sensitivity,Specificity,Precision)

KVSM.pred=sqlQuery(channel, paste("SELECT [Date],[SecId],[Sector]
                            FROM [S&P].[dbo].[tb_StockPrediction] where ksvm=1 and date in ('", 
                            paste(MthEnd, collapse = "','"), "')", sep=""))

rf.pred=sqlQuery(channel, paste("SELECT [Date],[SecId],[Sector]
                          FROM [S&P].[dbo].[tb_StockPrediction] where rf=1 and date in ('", 
                          paste(MthEnd, collapse = "','"), "')", sep=""))

Stats.SVM=merge(Stats.SVM,KVSM.pred,by=c("Date","Sector"),all=T)
Stats.SVM=Stats.SVM[-which(Stats.SVM$Sector=="AllSectors"),]
Stats.rf=merge(Stats.rf,rf.pred,by=c("Date","Sector"),all=T)
Stats.rf=Stats.rf[-which(Stats.rf$Sector=="AllSectors"),]
Stats.Final=rbind(Stats.SVM,Stats.rf)
Stats.Final=Stats.Final[,2:ncol(Stats.Final)]
write.csv(Stats.Final, "D:/S&Pcode/ModelStats.csv")

