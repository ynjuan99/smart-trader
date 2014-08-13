SELECT * FROM dbo.tb_Factor WHERE FID = 2098

ALTER TABLE dbo.tb_FactorScore ADD PMOM20Advanced FLOAT
GO

UPDATE dbo.tb_FactorScore 
SET PMOM20Advanced = b.Data
--SELECT TOP 100 a.Date, b.*
FROM dbo.tb_FactorScore a JOIN dbo.tb_FactorDataOld b 
ON a.SecId = b.SecId AND b.Date = DATEADD(DAY, 20, a.Date)
WHERE b.Fid = 2098
GO

ALTER TABLE dbo.tb_FactorScore ADD PMOM20Advanced_Normalized FLOAT
GO
/*
public static double Normalize(double value, double min, double max, double spectrum = 0.85)
        {
            double factor = Math.Abs(spectrum) * 2 / (max - min);
            return (value - min) * factor - Math.Abs(spectrum);
        }
*/
;WITH b AS (
SELECT Date, SecId, Sector, MAX(PMOM20Advanced) OVER() AS MaxPMOM20Advanced, MIN(PMOM20Advanced) OVER() AS MinPMOM20Advanced FROM dbo.tb_FactorScore
)
UPDATE dbo.tb_FactorScore 
SET PMOM20Advanced_Normalized = (a.PMOM20Advanced - b.MinPMOM20Advanced) * 0.999 * 2 / (b.MaxPMOM20Advanced - b.MinPMOM20Advanced) - 0.999
FROM dbo.tb_FactorScore a JOIN b
ON a.Date = b.Date AND a.SecId = b.SecId AND a.Sector = b.Sector

SELECT * FROM dbo.tb_FactorScore WHERE YEAR(date) = 2009
