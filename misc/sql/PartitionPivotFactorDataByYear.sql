--Partition Data into Years.
  
SELECT * INTO [dbo].tb_PivotFactorData_2004
FROM [dbo].[tb_PivotFactorData]
WHERE [DATE] < '2005-01-01'

SELECT * INTO [dbo].tb_PivotFactorData_2005
FROM [dbo].[tb_PivotFactorData]
WHERE [DATE] > '2004-12-31' AND  [DATE] < '2006-01-01'

SELECT * INTO [dbo].tb_PivotFactorData_2006
FROM [dbo].[tb_PivotFactorData]
WHERE [DATE] > '2005-12-31' AND  [DATE] < '2007-01-01'

SELECT * INTO [dbo].tb_PivotFactorData_2007
FROM [dbo].[tb_PivotFactorData]
WHERE [DATE] > '2006-12-31' AND  [DATE] < '2008-01-01'

SELECT * INTO [dbo].tb_PivotFactorData_2008
FROM [dbo].[tb_PivotFactorData]
WHERE [DATE] > '2007-12-31' AND  [DATE] < '2009-01-01'

SELECT * INTO [dbo].tb_PivotFactorData_2009
FROM [dbo].[tb_PivotFactorData]
WHERE [DATE] > '2008-12-31' AND  [DATE] < '2010-01-01'

SELECT * --INTO [dbo].tb_PivotFactorData_2010
FROM [dbo].[tb_PivotFactorData]
WHERE [DATE] > '2009-12-31' 