SELECT DISTINCT FID FROM dbo.tb_Factor

SELECT '[' + CAST(FID AS VARCHAR(10)) + '],' FROM dbo.tb_Factor ORDER BY FID FOR XML PATH('')

SELECT '[' + CAST(FID AS VARCHAR(10)) + '] [FLOAT] NULL,' FROM dbo.tb_Factor ORDER BY FID
