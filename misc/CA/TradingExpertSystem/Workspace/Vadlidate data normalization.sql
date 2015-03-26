SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_NAME = 'workshop2A_processedData' AND COLUMN_NAME LIKE '%_z' 
ORDER BY ORDINAL_POSITION
-- 25+2

--SELECT MIN(DJI_z), MAX(DJI_z), ROUND(AVG(DJI_z), 2), ROUND(STDEVP(DJI_z), 2) FROM workshop2A_processedData

SELECT 'SELECT ''' + COLUMN_NAME + ''', MIN(' + COLUMN_NAME + '), MAX(' + COLUMN_NAME + '), ROUND(AVG(' + COLUMN_NAME + '), 2), ROUND(STDEVP(' + COLUMN_NAME + '), 2) FROM workshop2A_processedData UNION ALL' 
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_NAME = 'workshop2A_processedData' AND COLUMN_NAME LIKE '%_z' 
ORDER BY ORDINAL_POSITION

SELECT 'SG_D_weekly_momentum_z', MIN(SG_D_weekly_momentum_z), MAX(SG_D_weekly_momentum_z), ROUND(AVG(SG_D_weekly_momentum_z), 2), ROUND(STDEVP(SG_D_weekly_momentum_z), 2) FROM workshop2A_processedData UNION ALL
SELECT 'SG_D_monthly_momentum_z', MIN(SG_D_monthly_momentum_z), MAX(SG_D_monthly_momentum_z), ROUND(AVG(SG_D_monthly_momentum_z), 2), ROUND(STDEVP(SG_D_monthly_momentum_z), 2) FROM workshop2A_processedData UNION ALL
SELECT 'P_D_weekly_momentum_z', MIN(P_D_weekly_momentum_z), MAX(P_D_weekly_momentum_z), ROUND(AVG(P_D_weekly_momentum_z), 2), ROUND(STDEVP(P_D_weekly_momentum_z), 2) FROM workshop2A_processedData UNION ALL
SELECT 'P_D_monthly_momentum_z', MIN(P_D_monthly_momentum_z), MAX(P_D_monthly_momentum_z), ROUND(AVG(P_D_monthly_momentum_z), 2), ROUND(STDEVP(P_D_monthly_momentum_z), 2) FROM workshop2A_processedData UNION ALL
SELECT 'DJI_weekly_momentum_z', MIN(DJI_weekly_momentum_z), MAX(DJI_weekly_momentum_z), ROUND(AVG(DJI_weekly_momentum_z), 2), ROUND(STDEVP(DJI_weekly_momentum_z), 2) FROM workshop2A_processedData UNION ALL
SELECT 'DJI_monthly_momentum_z', MIN(DJI_monthly_momentum_z), MAX(DJI_monthly_momentum_z), ROUND(AVG(DJI_monthly_momentum_z), 2), ROUND(STDEVP(DJI_monthly_momentum_z), 2) FROM workshop2A_processedData UNION ALL
SELECT 'S_P_weekly_momentum_z', MIN(S_P_weekly_momentum_z), MAX(S_P_weekly_momentum_z), ROUND(AVG(S_P_weekly_momentum_z), 2), ROUND(STDEVP(S_P_weekly_momentum_z), 2) FROM workshop2A_processedData UNION ALL
SELECT 'S_P_monthly_momentum_z', MIN(S_P_monthly_momentum_z), MAX(S_P_monthly_momentum_z), ROUND(AVG(S_P_monthly_momentum_z), 2), ROUND(STDEVP(S_P_monthly_momentum_z), 2) FROM workshop2A_processedData UNION ALL
SELECT 'FTSE_weekly_momentum_z', MIN(FTSE_weekly_momentum_z), MAX(FTSE_weekly_momentum_z), ROUND(AVG(FTSE_weekly_momentum_z), 2), ROUND(STDEVP(FTSE_weekly_momentum_z), 2) FROM workshop2A_processedData UNION ALL
SELECT 'FTSE_monthly_momentum_z', MIN(FTSE_monthly_momentum_z), MAX(FTSE_monthly_momentum_z), ROUND(AVG(FTSE_monthly_momentum_z), 2), ROUND(STDEVP(FTSE_monthly_momentum_z), 2) FROM workshop2A_processedData UNION ALL
SELECT 'STI_weekly_momentum_z', MIN(STI_weekly_momentum_z), MAX(STI_weekly_momentum_z), ROUND(AVG(STI_weekly_momentum_z), 2), ROUND(STDEVP(STI_weekly_momentum_z), 2) FROM workshop2A_processedData UNION ALL
SELECT 'STI_monthly_momentum_z', MIN(STI_monthly_momentum_z), MAX(STI_monthly_momentum_z), ROUND(AVG(STI_monthly_momentum_z), 2), ROUND(STDEVP(STI_monthly_momentum_z), 2) FROM workshop2A_processedData UNION ALL
SELECT 'DJI_z', MIN(DJI_z), MAX(DJI_z), ROUND(AVG(DJI_z), 2), ROUND(STDEVP(DJI_z), 2) FROM workshop2A_processedData UNION ALL
SELECT 'DJV_z', MIN(DJV_z), MAX(DJV_z), ROUND(AVG(DJV_z), 2), ROUND(STDEVP(DJV_z), 2) FROM workshop2A_processedData UNION ALL
SELECT 'S_P_z', MIN(S_P_z), MAX(S_P_z), ROUND(AVG(S_P_z), 2), ROUND(STDEVP(S_P_z), 2) FROM workshop2A_processedData UNION ALL
SELECT 'FTSE_z', MIN(FTSE_z), MAX(FTSE_z), ROUND(AVG(FTSE_z), 2), ROUND(STDEVP(FTSE_z), 2) FROM workshop2A_processedData UNION ALL
SELECT 'FTV_z', MIN(FTV_z), MAX(FTV_z), ROUND(AVG(FTV_z), 2), ROUND(STDEVP(FTV_z), 2) FROM workshop2A_processedData UNION ALL
SELECT 'STI_z', MIN(STI_z), MAX(STI_z), ROUND(AVG(STI_z), 2), ROUND(STDEVP(STI_z), 2) FROM workshop2A_processedData UNION ALL
SELECT 'STIV_z', MIN(STIV_z), MAX(STIV_z), ROUND(AVG(STIV_z), 2), ROUND(STDEVP(STIV_z), 2) FROM workshop2A_processedData UNION ALL
SELECT 'USPRIME_weekly_z', MIN(USPRIME_weekly_z), MAX(USPRIME_weekly_z), ROUND(AVG(USPRIME_weekly_z), 2), ROUND(STDEVP(USPRIME_weekly_z), 2) FROM workshop2A_processedData UNION ALL
SELECT 'UKPRIME_weekly_z', MIN(UKPRIME_weekly_z), MAX(UKPRIME_weekly_z), ROUND(AVG(UKPRIME_weekly_z), 2), ROUND(STDEVP(UKPRIME_weekly_z), 2) FROM workshop2A_processedData UNION ALL
SELECT 'SGPRIME_weekly_z', MIN(SGPRIME_weekly_z), MAX(SGPRIME_weekly_z), ROUND(AVG(SGPRIME_weekly_z), 2), ROUND(STDEVP(SGPRIME_weekly_z), 2) FROM workshop2A_processedData UNION ALL
SELECT 'USINF_weekly_z', MIN(USINF_weekly_z), MAX(USINF_weekly_z), ROUND(AVG(USINF_weekly_z), 2), ROUND(STDEVP(USINF_weekly_z), 2) FROM workshop2A_processedData UNION ALL
SELECT 'UKINF_weekly_z', MIN(UKINF_weekly_z), MAX(UKINF_weekly_z), ROUND(AVG(UKINF_weekly_z), 2), ROUND(STDEVP(UKINF_weekly_z), 2) FROM workshop2A_processedData UNION ALL
SELECT 'SGINF_weekly_z', MIN(SGINF_weekly_z), MAX(SGINF_weekly_z), ROUND(AVG(SGINF_weekly_z), 2), ROUND(STDEVP(SGINF_weekly_z), 2) FROM workshop2A_processedData UNION ALL
SELECT 'SG_D_forward_week_z', MIN(SG_D_forward_week_z), MAX(SG_D_forward_week_z), ROUND(AVG(SG_D_forward_week_z), 2), ROUND(STDEVP(SG_D_forward_week_z), 2) FROM workshop2A_processedData UNION ALL
SELECT 'P_D_forward_week_z', MIN(P_D_forward_week_z), MAX(P_D_forward_week_z), ROUND(AVG(P_D_forward_week_z), 2), ROUND(STDEVP(P_D_forward_week_z), 2) FROM workshop2A_processedData 


-- validate denormalization
;WITH t AS (
SELECT AVG(P_D_forward_week) AS P_D_mean, STDEV(P_D_forward_week) AS P_D_stdev FROM workshop2A_processedData
)
SELECT ROUND(ABS(P_D_forward_week_z * t.P_D_stdev + t.P_D_mean - P_D_forward_week), 3) FROM workshop2A_processedData, t

;WITH t AS (
SELECT AVG(SG_D_forward_week) AS SG_D_mean, STDEV(SG_D_forward_week) AS SG_D_stdev FROM workshop2A_processedData
)
SELECT ROUND(ABS(SG_D_forward_week_z * t.SG_D_stdev + t.SG_D_mean - SG_D_forward_week), 3) FROM workshop2A_processedData, t


;WITH tp AS (SELECT AVG(P_D_forward_week) AS P_D_mean, STDEV(P_D_forward_week) AS P_D_stdev FROM workshop2A_processedData),
tsg AS (SELECT AVG(SG_D_forward_week) AS SG_D_mean, STDEV(SG_D_forward_week) AS SG_D_stdev FROM workshop2A_processedData)
select *, tp.P_D_mean, tp.P_D_stdev, tsg.SG_D_mean, tsg.SG_D_stdev 
FROM workshop2A_processedData, tp, tsg 
WHERE F1 > 4 and F1 < 606