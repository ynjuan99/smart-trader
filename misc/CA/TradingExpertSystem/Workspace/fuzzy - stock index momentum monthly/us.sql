SELECT 'US_StockIndex_monthly_momentum', MIN(US_StockIndex_monthly_momentum) AS rmin, AVG(US_StockIndex_monthly_momentum) AS ravg, MAX(US_StockIndex_monthly_momentum) AS rmax FROM workshop2A_processedData 
GO
WITH t AS (
SELECT US_StockIndex_monthly_momentum AS r, ROW_NUMBER() OVER(ORDER BY US_StockIndex_monthly_momentum) AS i, NTILE(5) OVER(ORDER BY US_StockIndex_monthly_momentum) AS t 
FROM workshop2A_processedData
), t1(r,i,t,r2,i2,t2) AS (
SELECT t.r, t.i, t.t, t2.r, t2.i, t2.t FROM t JOIN t AS t2 ON t.i + 1 = t2.i
)
SELECT *, (r + r2) / 2 FROM t1 WHERE t + 1 = t2
GO