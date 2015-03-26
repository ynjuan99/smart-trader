SELECT 'SG_StockIndex', MIN(SG_StockIndex) AS rmin, AVG(SG_StockIndex) AS ravg, MAX(SG_StockIndex) AS rmax FROM workshop2A_processedData 
GO
WITH t AS (
SELECT SG_StockIndex AS r, ROW_NUMBER() OVER(ORDER BY SG_StockIndex) AS i, NTILE(7) OVER(ORDER BY SG_StockIndex) AS t 
FROM workshop2A_processedData
), t1(r,i,t,r2,i2,t2) AS (
SELECT t.r, t.i, t.t, t2.r, t2.i, t2.t FROM t JOIN t AS t2 ON t.i + 1 = t2.i
)
SELECT *, (r + r2) / 2 AS Boundary FROM t1 WHERE t + 1 = t2
GO