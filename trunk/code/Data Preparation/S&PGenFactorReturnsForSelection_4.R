########### Calculate summary statistics based on universe/sector ############

options(stringsAsFactors=F)
library(lattice)
library(Hmisc)
library(RODBC)
library(plyr)
library(dplyr)
library(ggplot2)
library(PerformanceAnalytics)

dbhandle <- odbcConnect("S&P")

PARM.dtfr='20031231'
PARM.dtto='20141215'

FactorsToOmit=Cs(PriceRetF1D,PriceRetF5D,PriceRetF10D,PriceRetF20D,PriceRetF40D,PriceRetFF10D,PriceRetFF20D)
CrossDates=sqlQuery(dbhandle, paste("SELECT YYYYMMDD FROM DBO.TB_CALENDAR WHERE CALENDARDATE >='",PARM.dtfr,"' AND CALENDARDATE<='",PARM.dtto,"' and DayOfWeek>1 and DayOfWeek<7",sep=""))[,,drop=T];
CrossDates=as.character(CrossDates)
#crossdt="20040119"

x=sapply(CrossDates, function (crossdt) {

# Get Date for next day's return  
RetnDt = sqlQuery(dbhandle, paste("SELECT TOP 1 [YYYYMMDD]
FROM [S&P].[dbo].[tb_Calendar]
where DayOfWeek<>1 and DayOfWeek<>7 and YYYYMMDD>'", crossdt, "' order by CalendarDate", sep=""))  

# Get Scores
SPScore = sqlQuery(dbhandle, paste("SELECT *
FROM [S&P].[dbo].[tb_FactorScore] where sector='all'
and DATE='", crossdt, "'", sep=""))

SPScore=SPScore[,-which(names(SPScore)%in%FactorsToOmit)]

Factors=names(SPScore)[-c(1:3)]

# Get Returns
SPRetn = sqlQuery(dbhandle, paste("SELECT SecId, TotRet1D
FROM [S&P].[dbo].[tb_ReturnPriceData] where DATE='", RetnDt, "'", sep=""))

row.names(SPScore)=SPScore$SecId

Inversion=sqlQuery(dbhandle, paste("SELECT Factor, Isinverted
FROM [S&P].[dbo].[tb_Factor] where fid>=2000", sep=""))

#Fact=Factors[105]
Factors=names(SPScore)[4:ncol(SPScore)]
a=data.frame(t(sapply(Factors, function(Fact,SPScore,SPRetn,Inversion)
{
  #print(Fact)
  SPScore2=SPScore[,Fact,drop=F]
  Inv=Inversion$Isinverted[Inversion$Factor%in%Fact]
  if (Inv==1) SPScore2[,Fact]=SPScore2[,Fact] * (-1)
  SPScore2=SPScore2[order(SPScore2[,Fact]),,drop=F]
  
  Q1retn=Q2retn=Q3retn=Q4retn=Q5retn=lretn=sretn=lsretn=0
  if (!(all(SPScore2[,1]%in%NA)))
  {
    
  lsecid=row.names(SPScore2)[SPScore2[,Fact]>=0]
  ssecid=row.names(SPScore2)[SPScore2[,Fact]<0]
  lretn=mean(SPRetn$TotRet1D[SPRetn$SecId%in%lsecid],na.rm=T)
  sretn=mean(SPRetn$TotRet1D[SPRetn$SecId%in%ssecid],na.rm=T)
  lsretn=0.5*(lretn-sretn)
  
  SPScore2$group <- as.numeric(cut_number(SPScore2[,Fact], 5))
  secidQ1=row.names(SPScore2)[SPScore2$group==5]
  secidQ2=row.names(SPScore2)[SPScore2$group==4]
  secidQ3=row.names(SPScore2)[SPScore2$group==3]
  secidQ4=row.names(SPScore2)[SPScore2$group==2]
  secidQ5=row.names(SPScore2)[SPScore2$group==1]
  Q1retn=mean(SPRetn$TotRet1D[SPRetn$SecId%in%secidQ1],na.rm=T)
  Q2retn=mean(SPRetn$TotRet1D[SPRetn$SecId%in%secidQ2],na.rm=T)
  Q3retn=mean(SPRetn$TotRet1D[SPRetn$SecId%in%secidQ3],na.rm=T)
  Q4retn=mean(SPRetn$TotRet1D[SPRetn$SecId%in%secidQ4],na.rm=T)
  Q5retn=mean(SPRetn$TotRet1D[SPRetn$SecId%in%secidQ5],na.rm=T)
  
  }
  
  retns=c(Q1retn,Q2retn,Q3retn,Q4retn,Q5retn,lretn,sretn,lsretn)
 
},SPScore=SPScore,SPRetn=SPRetn,Inversion=Inversion)))

names(a)=Cs(Q1retn,Q2retn,Q3retn,Q4retn,Q5retn,lretn,sretn,lsretn)

### Add date columns

CalendarDate=sqlQuery(dbhandle, paste("SELECT CalendarDate FROM DBO.TB_CALENDAR WHERE CALENDARDATE='", RetnDt, "'",sep=""))[,,drop=T];

a$Date=rep(CalendarDate,nrow(a))
a=data.frame("Factors"=row.names(a),a)

### Delete and export data 

deleter=sqlQuery(dbhandle, paste("DELETE
                                 FROM dbo.tb_FactorReturn where Date='", RetnDt, "'", sep=""))
sqlSave(dbhandle, dat=a, tablename="tb_FactorReturn", rownames=F, varTypes=c(Date="datetime"), append=T)

###

cat(paste("\n",substring(date(),5,19)," : Factor Scoring for Crossection of Universe as of ",crossdt,sep=""))

})

####

Factors = sqlQuery(dbhandle, paste("SELECT Factor
FROM [S&P].[dbo].[tb_Factor] where fid>=2000 order by factor", sep=""))[,,drop=T]

Yrs=2004:2014

FactorReturn=sqlQuery(dbhandle, paste("SELECT * FROM [S&P].[dbo].[tb_FactorReturn] order by date,factors"))

#fact=Factors[14]
StatsByFactorYr=lapply(Factors, function(fact) 
{
    print(fact)
    FactorReturn1=FactorReturn[FactorReturn$Factors%in%fact,]
    FactorReturn1=FactorReturn1[order(FactorReturn1$Date),]
    
    FactorReturn1$Factors=NULL
    #head(FactorReturn2)
    #yr=2004
    StatsByYr=lapply(Yrs, function(yr,FactorReturn1) 
    {
      #print(yr)
      FactorReturn2=FactorReturn1[substring(FactorReturn1$Date,1,4)%in%yr,]
      FactorReturn2=FactorReturn2[order(FactorReturn2$Date),]
      FactorReturn2[,2:ncol(FactorReturn2)]=FactorReturn2[,2:ncol(FactorReturn2)]/100

      ret=xts(FactorReturn2[,-1], order.by=FactorReturn2[,1])
      #names(ret)
      
      Sharpe=SharpeRatio.annualized(ret)
      AnnRet=Return.annualized(ret)
      cumRet=Return.cumulative(ret)
      AnnVol=StdDev.annualized(ret)
      Sortino=SortinoRatio(ret)
      MaxDrawdown=maxDrawdown(ret)
      AvgDrawdown=AverageDrawdown(ret)
      
      d=rbind(cumRet,AnnRet,AnnVol,Sharpe,Sortino,MaxDrawdown,AvgDrawdown)
      
      d=data.frame("Year"=yr,"Stats"=Cs(cumRet,AnnRet,AnnVol,Sharpe,Sortino,MaxDrawdown,AvgDrawdown),d)
      
    },FactorReturn1=FactorReturn1)
  
    StatsByYr=do.call('rbind',StatsByYr)
    StatsByYr=data.frame("Factor"=fact,StatsByYr)
    
})

StatsByFactorYr=do.call('rbind',StatsByFactorYr)

### Use years from 2004 - 2010
StatsByFactorYr2=StatsByFactorYr[StatsByFactorYr$Year%in%2004:2010,]
StatsByFactorYr2=split(StatsByFactorYr2,StatsByFactorYr2$Factor)

#df=StatsByFactorYr2[[1]]
StatsByFactorAllYr=lapply(StatsByFactorYr2, function(df)
{
  sharpe=df[df$Stats%in%"Sharpe",]
  sharpe=t(sapply(sharpe[,4:ncol(sharpe)],mean))
  sharpe=data.frame("Factor"=unique(df$Factor), "Stat"="Sharpe",sharpe)
  
  cumRet=df[df$Stats%in%"cumRet",]
  cumRet=t(sapply(cumRet[,4:ncol(cumRet)],mean))
  cumRet=data.frame("Factor"=unique(df$Factor), "Stat"="cumRet",cumRet)
  
  AnnVol=df[df$Stats%in%"AnnVol",]
  AnnVol=t(sapply(AnnVol[,4:ncol(AnnVol)],mean))
  AnnVol=data.frame("Factor"=unique(df$Factor), "Stat"="AnnVol",AnnVol)
  
  AvgDrawdown=df[df$Stats%in%"AvgDrawdown",]
  AvgDrawdown=t(sapply(AvgDrawdown[,4:ncol(AvgDrawdown)],mean))
  AvgDrawdown=data.frame("Factor"=unique(df$Factor), "Stat"="AvgDrawdown",AvgDrawdown)
  
  MaxDrawdown=df[df$Stats%in%"MaxDrawdown",]
  MaxDrawdown=t(sapply(MaxDrawdown[,4:ncol(MaxDrawdown)],mean))
  MaxDrawdown=data.frame("Factor"=unique(df$Factor), "Stat"="MaxDrawdown",MaxDrawdown)
  
  all=rbind(sharpe,cumRet,AnnVol,MaxDrawdown,AvgDrawdown)
  return(all)
}) 

### Factors with best average sharpe across 2004 - 2010
StatsByFactorAllYr=do.call('rbind',StatsByFactorAllYr)
#StatsByFactorAllYr=StatsByFactorAllYr[StatsByFactorAllYr$Stat%in%"Sharpe",]
#StatsByFactorAllYr=StatsByFactorAllYr[order(StatsByFactorAllYr$lsretn, decreasing=T),]

deleter=sqlQuery(dbhandle, paste("DELETE
                                 FROM dbo.tb_FactorReturnSummaryByYear", sep=""))
sqlSave(dbhandle, dat=StatsByFactorYr, tablename="tb_FactorReturnSummaryByYear", rownames=F, append=T)

deleter=sqlQuery(dbhandle, paste("DELETE
                                 FROM dbo.tb_FactorReturnSummaryAll", sep=""))
sqlSave(dbhandle, dat=StatsByFactorAllYr, tablename="tb_FactorReturnSummaryAll", rownames=F, append=T)

# StatsByFactorYr2 %>%
#   group by(Factor,Stats) %>%
#   
#   summarise_each(funs(mean))
# 
# #select(Q1retn,Q2retn) %>%


