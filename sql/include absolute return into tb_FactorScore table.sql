ALTER TABLE tb_FactorScore ADD PriceRetFF20D_Absolute FLOAT NULL 
GO

UPDATE tb_FactorScore SET PriceRetFF20D_Absolute = b.PriceRetFF20D
FROM tb_FactorScore a JOIN tb_FactorData b ON a.Date = b.Date AND a.SecId = b.SecId AND a.Sector = b.Sector
GO


