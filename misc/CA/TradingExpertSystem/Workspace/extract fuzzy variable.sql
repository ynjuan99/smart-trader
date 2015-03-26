SELECT *,
STI_z AS SG_StockIndex, 
STI_weekly_momentum_z AS SG_StockIndex_weekly_momentum,
STI_monthly_momentum_z AS SG_StockIndex_monthly_momentum,
FTSE_z AS UK_StockIndex, 
FTSE_weekly_momentum_z AS UK_StockIndex_weekly_momentum,
FTSE_monthly_momentum_z AS UK_StockIndex_monthly_momentum,
(DJI_z + S_P_z) / 2 AS US_StockIndex,
(DJI_weekly_momentum_z + S_P_weekly_momentum_z) / 2 AS US_StockIndex_weekly_momentum,
(DJI_monthly_momentum_z + S_P_monthly_momentum_z) / 2 AS US_StockIndex_monthly_momentum
INTO workshop2A_processedData
FROM workshop2A_processedData0

