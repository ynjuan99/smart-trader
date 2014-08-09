SELECT * FROM dbo.tb_Factor WHERE FID = 2098

ALTER TABLE dbo.tb_FactorScore ADD PMOM20Advanced FLOAT
GO

UPDATE dbo.tb_FactorScore 
SET PMOM20Advanced = b.Data
--SELECT TOP 100 a.Date, b.*
FROM dbo.tb_FactorScore a JOIN dbo.tb_FactorDataOld b 
ON a.SecId = b.SecId AND b.Date = DATEADD(DAY, 20, a.Date)
WHERE b.Fid = 2098