# Control Panel > Administrative Tools > Data Sources
# Add User Data Source with SQL Server Native Client 10.0
# (i used localDB as name of this connection)
# channel <- odbcConnect("ODBC_NAME", uid="username", pwd="password");

library(RODBC);
channel <- odbcConnect("localDB") 
p <- sqlQuery(channel, "
SELECT * FROM [SmartTrader].[dbo].[tb_CountryCode]
");
close(channel);
