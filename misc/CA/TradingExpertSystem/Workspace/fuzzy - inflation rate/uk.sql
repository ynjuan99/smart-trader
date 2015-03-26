SELECT 'UKINF_weekly_z', MIN(UKINF_weekly_z) AS rmin, AVG(UKINF_weekly_z) AS ravg, MAX(UKINF_weekly_z) AS rmax FROM workshop2A_processedData 
GO
WITH t AS (
SELECT UKINF_weekly_z AS r, ROW_NUMBER() OVER(ORDER BY UKINF_weekly_z) AS i, NTILE(4) OVER(ORDER BY UKINF_weekly_z) AS t 
FROM workshop2A_processedData
), t1(r,i,t,r2,i2,t2) AS (
SELECT t.r, t.i, t.t, t2.r, t2.i, t2.t FROM t JOIN t AS t2 ON t.i + 1 = t2.i
)
SELECT *, (r + r2) / 2 FROM t1 WHERE t + 1 = t2
GO