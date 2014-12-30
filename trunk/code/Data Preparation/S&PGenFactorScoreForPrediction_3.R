options(stringsAsFactors=F)
library(lattice)
library(Hmisc)
library(RODBC)

## Normalize/scale factors 
#scalebyMAD <- function(val)
#{
#  Med=median(val,na.rm=T)
#  MAD=mad(val,na.rm=T)
#  scale=(val-Med)/MAD
#  return(scale)
#}  

dbhandle <- odbcConnect("S&P")

### Determine percentage threshold for selecting stock and factor/standard deviation for outlier limit
PercNAThreshold.Stock=0.3
PercNAThreshold.Factor=0.3
Outlier.limit=3

PARM.dtfr='20031231'
PARM.dtto='20141215'

CrossDates=sqlQuery(dbhandle, paste("SELECT YYYYMMDD FROM DBO.TB_CALENDAR WHERE CALENDARDATE >='",PARM.dtfr,"' AND CALENDARDATE<='",PARM.dtto,"' and DayOfWeek>1 and DayOfWeek<7",sep=""))[,,drop=T];
CrossDates=as.character(CrossDates)

KeyFactors=sqlQuery(dbhandle, paste("SELECT TOP 30 [Factor]
FROM [S&P].[dbo].[tb_FactorReturnSummaryAll]
where STAT='sharpe'
order by lsretn desc", sep=""))[,,drop=T]
#crossdt="20040102"

x=sapply(CrossDates, function (crossdt) {
  cat(paste("\n","--------------------------------------------------------------------------------------",sep=""));
  cat(paste("\n",substring(date(),5,19)," ::::: Factor Construction for Crossection of Universe as of ",crossdt,sep=""));  
### Import Data
#SPData=read.csv("C:/SPDataDerived20040109.csv")

SPData = sqlQuery(dbhandle, paste("SELECT * 
FROM dbo.tb_FactorData where Date='", crossdt, "'", sep=""))

row.names(SPData)=SPData$SecId
Sectors=SPData[,"Sector",drop=F]

### Convert columns format to numeric
SPData[,5:ncol(SPData)]=sapply(SPData[,5:ncol(SPData)],as.numeric)

a=SPData[SPData$SML %in% c("L","M"),5:ncol(SPData)]

a$PercNA=apply(a[,KeyFactors],1,function(row) sum(row%in%NA)/length(row) )
a=a[-which(a$PercNA>PercNAThreshold.Stock),] ### remove stocks with more than 50% NAs
a=a[,-which(names(a)%in%"PercNA")]

StatsLM=data.frame(Factor=names(a),"Mean"=apply(a,2,mean,na.rm=T),"Median"=apply(a,2,median,na.rm=T)
,"Max"=apply(a,2,max,na.rm=T),"Min"=apply(a,2,min,na.rm=T),"Mad"=apply(a,2,mad,na.rm=T),
"Std"=apply(a,2,sd,na.rm=T),"PercNAs"=apply(a,2,function(i) return((sum(i%in%NA)/length(i))) ))
StatsLM$Lower=StatsLM$Mean-(2*StatsLM$Mad)
StatsLM$Higher=StatsLM$Mean+(2*StatsLM$Mad)

StatsLMOrdered=StatsLM[order(StatsLM$PercNAs,decreasing=TRUE),]

#write.csv(StatsLM,"D:/StatsLM.csv")

### Factors to use/remove
#FactorsToUse=StatsLMOrdered$Factor[StatsLMOrdered$PercNAs<PercNAThreshold.Factor]
#FactorsToRemove=StatsLMOrdered$Factor[StatsLMOrdered$PercNAs>=PercNAThreshold.Factor]

### S&P Data Final Selection

#a=a[,FactorsToUse]

## Handle outliers: scale outliers to within 2 MAD, and give NAs median values

scaleOutliersbyMAD <- function(val,limit=2)
{
  Mad=mad(val,na.rm=T)
  
  if (Mad!=0)
  {
    Med=median(val,na.rm=T)
    val[val>(Med+limit*Mad)]=Med+limit*Mad
    val[val<(Med-limit*Mad)]=Med-limit*Mad
    val[val%in%NA]=Med
  }
  
  else
  {
    val[val%in%NA]=0
  }  
  
  return(val)
}  

SPFinal.scaleMAD=a
#SPFinal.scaleMAD[,1:ncol(SPFinal.scaleMAD)]=sapply(SPFinal.scaleMAD[,1:ncol(SPFinal.scaleMAD)],scaleOutliersbyMAD,limit=Outlier.limit)
#SPFinal.scaleMAD[,FactorsToUse]=sapply(SPFinal.scaleMAD[,FactorsToUse],scaleOutliersbyMAD,limit=Outlier.limit)
#SPFinal.scaleMAD[,FactorsToRemove]=sapply(SPFinal.scaleMAD[,FactorsToRemove],function(factor) return(factor=NA))
SPFinal.scaleMAD[,1:ncol(SPFinal.scaleMAD)]=sapply(SPFinal.scaleMAD[,1:ncol(SPFinal.scaleMAD)],scaleOutliersbyMAD,limit=Outlier.limit)

SPFinal.norm=SPFinal.scaleMAD

# UpDnGrade.Factors=Cs(EarningsFY1UpDnGrade_3M,EarningsFY2UpDnGrade_3M,EarningsFY3UpDnGrade_3M, 
#                      EarningsFY1UpDnGrade_6M,EarningsFY2UpDnGrade_6M,EarningsFY3UpDnGrade_6M,
#                      EBITDAFY1UpDnGrade_3M,EBITDAFY2UpDnGrade_3M,EBITDAFY3UpDnGrade_3M,
#                      EBITDAFY1UpDnGrade_6M,EBITDAFY2UpDnGrade_6M,EBITDAFY3UpDnGrade_6M)
# 
# Factors=names(SPFinal.norm)[!(names(SPFinal.norm)%in%UpDnGrade.Factors)]
# UpDnGrade.Factors2=names(SPFinal.norm)[names(SPFinal.norm)%in%UpDnGrade.Factors]
Factors=names(SPFinal.norm)
### Merge with Sectors
SPFinal.norm=merge(Sectors,SPFinal.norm,by="row.names")
names(SPFinal.norm)[1]="SecId"
#SPFinal.norm$PriceRetF1D
### Scale all factors other than up/downgrade factors
### Normalized/Scored by sector

SectorsAll=unique(Sectors$Sector)

SPData.Scored.by.Sector=lapply(SectorsAll, function(Sector,SPFinal.norm)
{
  
  SPDataScored.by.Sector=SPFinal.norm[SPFinal.norm$Sector %in% Sector,]
  SPDataScored.by.Sector[,Factors]=sapply(SPDataScored.by.Sector[,Factors],scale)
  return(SPDataScored.by.Sector)
  
},SPFinal.norm=SPFinal.norm)

SPData.Scored.by.Sector=do.call('rbind',SPData.Scored.by.Sector)
#SPData.Scored.by.Sector$PriceRetF1D
#### Score across all stocks after sector scoring

SPData.Scored.by.CtrySector=SPData.Scored.by.Sector
SPData.Scored.by.CtrySector$Sector=rep("All",nrow(SPData.Scored.by.CtrySector))

SPData.Scored.by.CtrySector[,Factors]=sapply(SPData.Scored.by.Sector[,Factors],scale)

SPData.ScoredCombined=rbind(SPData.Scored.by.Sector,SPData.Scored.by.CtrySector)
#SPData.ScoredCombined$PriceRetF1D
##### Curtail those factors with n-sd (set by Outlier limit) away from mean

SPData.ScoredCombined[,Factors]=sapply(SPData.ScoredCombined[,Factors],function(fact,Outlier.limit) 
{  
  fact[fact > Outlier.limit] = Outlier.limit
  fact[fact < (-Outlier.limit)]= -Outlier.limit
  return(fact)
},Outlier.limit=Outlier.limit)  

# SPData.ScoredCombined[,UpDnGrade.Factors2]=sapply(SPData.ScoredCombined[,UpDnGrade.Factors2],function(fact,Outlier.limit) 
# {
#   fact[fact %in% 1] = Outlier.limit
#   fact[fact %in% (-1)] = -Outlier.limit
#   return(fact)
# },Outlier.limit=Outlier.limit) 

CalendarDate=sqlQuery(dbhandle, paste("SELECT CalendarDate FROM DBO.TB_CALENDAR WHERE CALENDARDATE='", crossdt, "'",sep=""))[,,drop=T];
SPData.ScoredCombined$Date=rep(CalendarDate,nrow(SPData.ScoredCombined))
deleter=sqlQuery(dbhandle, paste("DELETE
FROM dbo.tb_FactorScore where Date='", crossdt, "'", sep=""))
sqlSave(dbhandle, dat=SPData.ScoredCombined, tablename="tb_FactorScore", rownames=F, varTypes=c(Date="datetime"), append=T)

cat(paste("\n",substring(date(),5,19)," : Factor Scoring for Crossection of Universe as of ",crossdt,sep=""))

})

