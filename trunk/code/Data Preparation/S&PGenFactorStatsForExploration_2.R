########### Calculate summary statistics based on universe/sector ############

options(stringsAsFactors=F)
library(lattice)
library(Hmisc)
library(RODBC)

dbhandle <- odbcConnect("S&P")

### Determine percentage threshold for selecting stock and factor/standard deviation for outlier limit
#PercNAThreshold.Stock=0.7
#PercNAThreshold.Factor=0.3
#Outlier.limit=3

PARM.dtfr='20031231'
PARM.dtto='20141215'

CrossDates=sqlQuery(dbhandle, paste("SELECT YYYYMMDD FROM DBO.TB_CALENDAR WHERE CALENDARDATE >='",PARM.dtfr,"' AND CALENDARDATE<='",PARM.dtto,"' and DayOfWeek>1 and DayOfWeek<7",sep=""))[,,drop=T];
CrossDates=as.character(CrossDates)
#crossdt="20040129"

x=sapply(CrossDates, function (crossdt) {
  
### Import Data
#SPData=read.csv("C:/SPDataDerived20040109.csv")

SPData = sqlQuery(dbhandle, paste("SELECT * 
FROM dbo.tb_FactorData where Date='", crossdt, "'", sep=""))
  
row.names(SPData)=SPData$SecId
Sectors=SPData[,"Sector",drop=T]
### Convert columns format to numeric
SPData[,5:ncol(SPData)]=sapply(SPData[,5:ncol(SPData)],as.numeric)

### Compute Stats for various universes 

Universe=Cs(All,LM,L,M,S)
Stats.by.universe=lapply(Universe,function(univ,SPData)
{

  if (univ %in% "All")  
  {  
    a=SPData[SPData$SML%in%Cs(L,M),5:ncol(SPData)]
  }
  
  if (univ %in% "LM")  
  {  
    a=SPData[,5:ncol(SPData)]
  }  
  
  if (univ %in% Cs(L,M,S))  
  {  
    a=SPData[SPData$SML%in%univ,5:ncol(SPData)]
  }

  a$PercNA=apply(a,1,function(row) sum(row%in%NA)/length(row) )
  #a=a[-which(a$PercNA>PercNAThreshold.Stock),] ### remove stocks with more than 50% NAs
  a=a[,-which(names(a)%in%"PercNA")]
  
  Stats=data.frame("Universe"=univ,Factor=names(a),"Mean"=apply(a,2,mean,na.rm=T),"Median"=apply(a,2,median,na.rm=T),
  "Mad"=apply(a,2,mad,na.rm=T),"Std"=apply(a,2,sd,na.rm=T),"Max"=apply(a,2,max,na.rm=T),"Min"=apply(a,2,min,na.rm=T),
  "PercNAs"=apply(a,2,function(i) return((sum(i%in%NA)/length(i))) ))
  Stats$LowerLimit=Stats$Mean-(2*Stats$Mad)
  Stats$HigherLimit=Stats$Mean+(2*Stats$Mad)
  Stats=Stats[order(Stats$PercNAs,decreasing=TRUE),]
  return(Stats)

},SPData=SPData)

Stats.by.universe=do.call('rbind',Stats.by.universe)

#Stats.by.universeT=Stats.by.universe
Stats.by.universe[,3:ncol(Stats.by.universe)]=sapply(Stats.by.universe[,3:ncol(Stats.by.universe)], function(col) 
{
  if (any(col%in%c("Inf","-Inf","NaN")))
  {
    col[col%in%c("Inf","-Inf","NaN")]=NA
  }
  return(col)
})

#Stats.by.universeOrdered=Stats.by.universe[order(Stats.by.universe$PercNAs,decreasing=TRUE),]

### Compute Stats for various sectors
#Sector=unique(Sectors)[6]
Stats.by.sector=lapply(unique(Sectors),function(Sector,SPData)
{
    
  a=SPData[SPData$Sector%in%Sector,5:ncol(SPData)]
  
  a$PercNA=apply(a,1,function(row) sum(row%in%NA)/length(row) )
  #a=a[-which(a$PercNA>PercNAThreshold.Stock),] ### remove stocks with more than 50% NAs
  a=a[,-which(names(a)%in%"PercNA")]
  
  Stats=data.frame("Sector"=rep(Sector,length(names(a))),Factor=names(a),"Mean"=apply(a,2,mean,na.rm=T),"Median"=apply(a,2,median,na.rm=T),
                   "Mad"=apply(a,2,mad,na.rm=T),"Std"=apply(a,2,sd,na.rm=T),"Max"=apply(a,2,max,na.rm=T),"Min"=apply(a,2,min,na.rm=T),
                   "PercNAs"=apply(a,2,function(i) return((sum(i%in%NA)/length(i))) ))
  
  Stats$LowerLimit=Stats$Mean-(2*Stats$Mad)
  Stats$HigherLimit=Stats$Mean+(2*Stats$Mad)
  Stats=Stats[order(Stats$PercNAs,decreasing=TRUE),]
  #print(Sector)
  return(Stats)
  
},SPData=SPData)

Stats.by.sector=do.call('rbind',Stats.by.sector)

Stats.by.sector[,3:ncol(Stats.by.sector)]=sapply(Stats.by.sector[,3:ncol(Stats.by.sector)], function(col) 
{
  if (any(col%in%c("Inf","-Inf","NaN")))
  {
    col[col%in%c("Inf","-Inf","NaN")]=NA
  }
  return(col)
})

#Stats.by.sectorOrdered=Stats.by.sector[order(Stats.by.sector$PercNAs,decreasing=TRUE),]

### Add date columns

CalendarDate=sqlQuery(dbhandle, paste("SELECT CalendarDate FROM DBO.TB_CALENDAR WHERE CALENDARDATE='", crossdt, "'",sep=""))[,,drop=T];

Stats.by.universe$Date=rep(CalendarDate,nrow(Stats.by.universe))
Stats.by.sector$Date=rep(CalendarDate,nrow(Stats.by.sector))

### Delete and export data 

deleter=sqlQuery(dbhandle, paste("DELETE
                                 FROM dbo.tb_FactorStatsByUniverse where Date='", crossdt, "'", sep=""))
sqlSave(dbhandle, dat=Stats.by.universe, tablename="tb_FactorStatsByUniverse", rownames=F, varTypes=c(Date="datetime"), append=T)

deleter=sqlQuery(dbhandle, paste("DELETE
                                 FROM dbo.tb_FactorStatsBySector where Date='", crossdt, "'", sep=""))
sqlSave(dbhandle, dat=Stats.by.sector, tablename="tb_FactorStatsBySector", rownames=F, varTypes=c(Date="datetime"), append=T)

###

cat(paste("\n",substring(date(),5,19)," : Factor Scoring for Crossection of Universe as of ",crossdt,sep=""))

})

