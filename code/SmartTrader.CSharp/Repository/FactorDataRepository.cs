using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Repository
{
    public class FactorDataRepository
    {
        private const string ConnectionString = "Initial Catalog=SmartTrader;Data Source=localhost;Integrated Security=SSPI;";
    
        public static IList<DataTuple> GetFactorData(int year, string sector, params string[] outputColumns)
        {
            #region Script
            const string query = @"
SELECT  Date
      , SecId
      , Sector
      , ISNULL(ISNULL(BookYieldFY1, AVG(BookYieldFY1) OVER ()), 0) AS BookYieldFY1
      , ISNULL(ISNULL(BookYieldFY2, AVG(BookYieldFY2) OVER ()), 0) AS BookYieldFY2
      , ISNULL(ISNULL(BookYieldFY3, AVG(BookYieldFY3) OVER ()), 0) AS BookYieldFY3
      , ISNULL(ISNULL(DividendYieldFY1, AVG(DividendYieldFY1) OVER ()), 0) AS DividendYieldFY1
      , ISNULL(ISNULL(DividendYieldFY2, AVG(DividendYieldFY2) OVER ()), 0) AS DividendYieldFY2
      , ISNULL(ISNULL(DividendYieldFY3, AVG(DividendYieldFY3) OVER ()), 0) AS DividendYieldFY3
      , ISNULL(ISNULL(EarningsYieldFY1, AVG(EarningsYieldFY1) OVER ()), 0) AS EarningsYieldFY1
      , ISNULL(ISNULL(EarningsYieldFY2, AVG(EarningsYieldFY2) OVER ()), 0) AS EarningsYieldFY2
      , ISNULL(ISNULL(EarningsYieldFY3, AVG(EarningsYieldFY3) OVER ()), 0) AS EarningsYieldFY3
      , ISNULL(ISNULL(EBITDAYieldFY1, AVG(EBITDAYieldFY1) OVER ()), 0) AS EBITDAYieldFY1
      , ISNULL(ISNULL(EBITDAYieldFY2, AVG(EBITDAYieldFY2) OVER ()), 0) AS EBITDAYieldFY2
      , ISNULL(ISNULL(EBITDAYieldFY3, AVG(EBITDAYieldFY3) OVER ()), 0) AS EBITDAYieldFY3
      , ISNULL(ISNULL(SalesYieldFY1, AVG(SalesYieldFY1) OVER ()), 0) AS SalesYieldFY1
      , ISNULL(ISNULL(SalesYieldFY2, AVG(SalesYieldFY2) OVER ()), 0) AS SalesYieldFY2
      , ISNULL(ISNULL(SalesYieldFY3, AVG(SalesYieldFY3) OVER ()), 0) AS SalesYieldFY3
      , ISNULL(ISNULL(EBIT_EV_NTM, AVG(EBIT_EV_NTM) OVER ()), 0) AS EBIT_EV_NTM
      , ISNULL(ISNULL(EBITDA_EV_NTM, AVG(EBITDA_EV_NTM) OVER ()), 0) AS EBITDA_EV_NTM
      , ISNULL(ISNULL(SALES_EV_NTM, AVG(SALES_EV_NTM) OVER ()), 0) AS SALES_EV_NTM
      , ISNULL(ISNULL(PEGFY1, AVG(PEGFY1) OVER ()), 0) AS PEGFY1
      , ISNULL(ISNULL(EarningsYield1Y, AVG(EarningsYield1Y) OVER ()), 0) AS EarningsYield1Y
      , ISNULL(ISNULL(FCFYield1Y, AVG(FCFYield1Y) OVER ()), 0) AS FCFYield1Y
      , ISNULL(ISNULL(SalesYield1Y, AVG(SalesYield1Y) OVER ()), 0) AS SalesYield1Y
      , ISNULL(ISNULL(EBIT_EV1Y, AVG(EBIT_EV1Y) OVER ()), 0) AS EBIT_EV1Y
      , ISNULL(ISNULL(EBITDA_EV1Y, AVG(EBITDA_EV1Y) OVER ()), 0) AS EBITDA_EV1Y
      , ISNULL(ISNULL(BookRevFY1_3M, AVG(BookRevFY1_3M) OVER ()), 0) AS BookRevFY1_3M
      , ISNULL(ISNULL(BookRevFY1_6M, AVG(BookRevFY1_6M) OVER ()), 0) AS BookRevFY1_6M
      , ISNULL(ISNULL(DivRevFY1_3M, AVG(DivRevFY1_3M) OVER ()), 0) AS DivRevFY1_3M
      , ISNULL(ISNULL(DivRevFY1_6M, AVG(DivRevFY1_6M) OVER ()), 0) AS DivRevFY1_6M
      , ISNULL(ISNULL(EarningsRevFY1_3M, AVG(EarningsRevFY1_3M) OVER ()), 0) AS EarningsRevFY1_3M
      , ISNULL(ISNULL(EarningsRevFY1_6M, AVG(EarningsRevFY1_6M) OVER ()), 0) AS EarningsRevFY1_6M
      , ISNULL(ISNULL(EBITDARevFY1_3M, AVG(EBITDARevFY1_3M) OVER ()), 0) AS EBITDARevFY1_3M
      , ISNULL(ISNULL(EBITDARevFY1_6M, AVG(EBITDARevFY1_6M) OVER ()), 0) AS EBITDARevFY1_6M
      , ISNULL(ISNULL(SalesRevFY1_3M, AVG(SalesRevFY1_3M) OVER ()), 0) AS SalesRevFY1_3M
      , ISNULL(ISNULL(SalesRevFY1_6M, AVG(SalesRevFY1_6M) OVER ()), 0) AS SalesRevFY1_6M
      , ISNULL(ISNULL(EarningsFY1Std, AVG(EarningsFY1Std) OVER ()), 0) AS EarningsFY1Std
      , ISNULL(ISNULL(EarningsFY2Std, AVG(EarningsFY2Std) OVER ()), 0) AS EarningsFY2Std
      , ISNULL(ISNULL(EarningsFY3Std, AVG(EarningsFY3Std) OVER ()), 0) AS EarningsFY3Std
      , ISNULL(ISNULL(EBITDAFY1Std, AVG(EBITDAFY1Std) OVER ()), 0) AS EBITDAFY1Std
      , ISNULL(ISNULL(EBITDAFY2Std, AVG(EBITDAFY2Std) OVER ()), 0) AS EBITDAFY2Std
      , ISNULL(ISNULL(EBITDAFY3Std, AVG(EBITDAFY3Std) OVER ()), 0) AS EBITDAFY3Std
      , ISNULL(ISNULL(EarningsFY1UpDnGrade_3M, AVG(EarningsFY1UpDnGrade_3M) OVER ()), 0) AS EarningsFY1UpDnGrade_3M
      , ISNULL(ISNULL(EarningsFY2UpDnGrade_3M, AVG(EarningsFY2UpDnGrade_3M) OVER ()), 0) AS EarningsFY2UpDnGrade_3M
      , ISNULL(ISNULL(EarningsFY3UpDnGrade_3M, AVG(EarningsFY3UpDnGrade_3M) OVER ()), 0) AS EarningsFY3UpDnGrade_3M
      , ISNULL(ISNULL(EarningsFY1UpDnGrade_6M, AVG(EarningsFY1UpDnGrade_6M) OVER ()), 0) AS EarningsFY1UpDnGrade_6M
      , ISNULL(ISNULL(EarningsFY2UpDnGrade_6M, AVG(EarningsFY2UpDnGrade_6M) OVER ()), 0) AS EarningsFY2UpDnGrade_6M
      , ISNULL(ISNULL(EarningsFY3UpDnGrade_6M, AVG(EarningsFY3UpDnGrade_6M) OVER ()), 0) AS EarningsFY3UpDnGrade_6M
      , ISNULL(ISNULL(EBITDAFY1UpDnGrade_3M, AVG(EBITDAFY1UpDnGrade_3M) OVER ()), 0) AS EBITDAFY1UpDnGrade_3M
      , ISNULL(ISNULL(EBITDAFY2UpDnGrade_3M, AVG(EBITDAFY2UpDnGrade_3M) OVER ()), 0) AS EBITDAFY2UpDnGrade_3M
      , ISNULL(ISNULL(EBITDAFY3UpDnGrade_3M, AVG(EBITDAFY3UpDnGrade_3M) OVER ()), 0) AS EBITDAFY3UpDnGrade_3M
      , ISNULL(ISNULL(EBITDAFY1UpDnGrade_6M, AVG(EBITDAFY1UpDnGrade_6M) OVER ()), 0) AS EBITDAFY1UpDnGrade_6M
      , ISNULL(ISNULL(EBITDAFY2UpDnGrade_6M, AVG(EBITDAFY2UpDnGrade_6M) OVER ()), 0) AS EBITDAFY2UpDnGrade_6M
      , ISNULL(ISNULL(EBITDAFY3UpDnGrade_6M, AVG(EBITDAFY3UpDnGrade_6M) OVER ()), 0) AS EBITDAFY3UpDnGrade_6M
      , ISNULL(ISNULL(EarningsFY1Cov, AVG(EarningsFY1Cov) OVER ()), 0) AS EarningsFY1Cov
      , ISNULL(ISNULL(EBITDAMarginNTM, AVG(EBITDAMarginNTM) OVER ()), 0) AS EBITDAMarginNTM
      , ISNULL(ISNULL(EBITMarginNTM, AVG(EBITMarginNTM) OVER ()), 0) AS EBITMarginNTM
      , ISNULL(ISNULL(NetMarginNTM, AVG(NetMarginNTM) OVER ()), 0) AS NetMarginNTM
      , ISNULL(ISNULL(NetDebtEbitdaNTM, AVG(NetDebtEbitdaNTM) OVER ()), 0) AS NetDebtEbitdaNTM
      , ISNULL(ISNULL(DivRatio, AVG(DivRatio) OVER ()), 0) AS DivRatio
      , ISNULL(ISNULL(ROIC1Y, AVG(ROIC1Y) OVER ()), 0) AS ROIC1Y
      , ISNULL(ISNULL(CROIC1Y, AVG(CROIC1Y) OVER ()), 0) AS CROIC1Y
      , ISNULL(ISNULL(DebtCapLQ, AVG(DebtCapLQ) OVER ()), 0) AS DebtCapLQ
      , ISNULL(ISNULL(DebtTALQ, AVG(DebtTALQ) OVER ()), 0) AS DebtTALQ
      , ISNULL(ISNULL(DebtEbitdaLQ, AVG(DebtEbitdaLQ) OVER ()), 0) AS DebtEbitdaLQ
      , ISNULL(ISNULL(OpCFOverFCF1Y, AVG(OpCFOverFCF1Y) OVER ()), 0) AS OpCFOverFCF1Y
      , ISNULL(ISNULL(OpCFOverEarnings1Y, AVG(OpCFOverEarnings1Y) OVER ()), 0) AS OpCFOverEarnings1Y
      , ISNULL(ISNULL(OpCFOverCDiv1Y, AVG(OpCFOverCDiv1Y) OVER ()), 0) AS OpCFOverCDiv1Y
      , ISNULL(ISNULL(NetCashDebt1Y, AVG(NetCashDebt1Y) OVER ()), 0) AS NetCashDebt1Y
      , ISNULL(ISNULL(SharesChg3M, AVG(SharesChg3M) OVER ()), 0) AS SharesChg3M
      , ISNULL(ISNULL(SharesChg6M, AVG(SharesChg6M) OVER ()), 0) AS SharesChg6M
      , ISNULL(ISNULL(SharesChg12M, AVG(SharesChg12M) OVER ()), 0) AS SharesChg12M
      , ISNULL(ISNULL(EPS_LTGMean, AVG(EPS_LTGMean) OVER ()), 0) AS EPS_LTGMean
      , ISNULL(ISNULL(EPSMeanLTMSlope6M, AVG(EPSMeanLTMSlope6M) OVER ()), 0) AS EPSMeanLTMSlope6M
      , ISNULL(ISNULL(EPSPastSlope6M, AVG(EPSPastSlope6M) OVER ()), 0) AS EPSPastSlope6M
      , ISNULL(ISNULL(EPSPastSlope12M, AVG(EPSPastSlope12M) OVER ()), 0) AS EPSPastSlope12M
      , ISNULL(ISNULL(EPSPastSlope36M, AVG(EPSPastSlope36M) OVER ()), 0) AS EPSPastSlope36M
      , ISNULL(ISNULL(EPSPastSlope60M, AVG(EPSPastSlope60M) OVER ()), 0) AS EPSPastSlope60M
      , ISNULL(ISNULL(EPSPastTStat36M, AVG(EPSPastTStat36M) OVER ()), 0) AS EPSPastTStat36M
      , ISNULL(ISNULL(EPSPastTStat60M, AVG(EPSPastTStat60M) OVER ()), 0) AS EPSPastTStat60M
      , ISNULL(ISNULL(SalesPSPastSlope6M, AVG(SalesPSPastSlope6M) OVER ()), 0) AS SalesPSPastSlope6M
      , ISNULL(ISNULL(SalesPSPastSlope12M, AVG(SalesPSPastSlope12M) OVER ()), 0) AS SalesPSPastSlope12M
      , ISNULL(ISNULL(SalesPSPastSlope36M, AVG(SalesPSPastSlope36M) OVER ()), 0) AS SalesPSPastSlope36M
      , ISNULL(ISNULL(SalesPSPastSlope60M, AVG(SalesPSPastSlope60M) OVER ()), 0) AS SalesPSPastSlope60M
      , ISNULL(ISNULL(SalesPSPastTStat36M, AVG(SalesPSPastTStat36M) OVER ()), 0) AS SalesPSPastTStat36M
      , ISNULL(ISNULL(SalesPSPastTStat60M, AVG(SalesPSPastTStat60M) OVER ()), 0) AS SalesPSPastTStat60M
      , ISNULL(ISNULL(NetMarginPastSlope12M, AVG(NetMarginPastSlope12M) OVER ()), 0) AS NetMarginPastSlope12M
      , ISNULL(ISNULL(NetMarginPastSlope36M, AVG(NetMarginPastSlope36M) OVER ()), 0) AS NetMarginPastSlope36M
      , ISNULL(ISNULL(PriceSlope20D, AVG(PriceSlope20D) OVER ()), 0) AS PriceSlope20D
      , ISNULL(ISNULL(PriceSlope50D, AVG(PriceSlope50D) OVER ()), 0) AS PriceSlope50D
      , ISNULL(ISNULL(PriceSlope100D, AVG(PriceSlope100D) OVER ()), 0) AS PriceSlope100D
      , ISNULL(ISNULL(PriceSlope200D, AVG(PriceSlope200D) OVER ()), 0) AS PriceSlope200D
      , ISNULL(ISNULL(PriceTStat20D, AVG(PriceTStat20D) OVER ()), 0) AS PriceTStat20D
      , ISNULL(ISNULL(PriceTStat50D, AVG(PriceTStat50D) OVER ()), 0) AS PriceTStat50D
      , ISNULL(ISNULL(PriceTStat100D, AVG(PriceTStat100D) OVER ()), 0) AS PriceTStat100D
      , ISNULL(ISNULL(PriceTStat200D, AVG(PriceTStat200D) OVER ()), 0) AS PriceTStat200D
      , ISNULL(ISNULL(MoneyFlow14D, AVG(MoneyFlow14D) OVER ()), 0) AS MoneyFlow14D
      , ISNULL(ISNULL(PriceRet10D, AVG(PriceRet10D) OVER ()), 0) AS PriceRet10D
      , ISNULL(ISNULL(PriceRet20D, AVG(PriceRet20D) OVER ()), 0) AS PriceRet20D
      , ISNULL(ISNULL(PriceRet50D, AVG(PriceRet50D) OVER ()), 0) AS PriceRet50D
      , ISNULL(ISNULL(PriceRet100D, AVG(PriceRet100D) OVER ()), 0) AS PriceRet100D
      , ISNULL(ISNULL(PriceMA20, AVG(PriceMA20) OVER ()), 0) AS PriceMA20
      , ISNULL(ISNULL(PriceMA50, AVG(PriceMA50) OVER ()), 0) AS PriceMA50
      , ISNULL(ISNULL(PriceMA100, AVG(PriceMA100) OVER ()), 0) AS PriceMA100
      , ISNULL(ISNULL(PriceMA200, AVG(PriceMA200) OVER ()), 0) AS PriceMA200
      , ISNULL(ISNULL(Price52WHigh, AVG(Price52WHigh) OVER ()), 0) AS Price52WHigh
      , ISNULL(ISNULL(Price52WLow, AVG(Price52WLow) OVER ()), 0) AS Price52WLow
      , ISNULL(ISNULL(PMOM20Advanced, AVG(PMOM20Advanced) OVER ()), 0) AS PMOM20Advanced
FROM    dbo.tb_FactorScore TABLESAMPLE (33 PERCENT)
WHERE   Sector = @sector
        AND YEAR(Date) = @year
";
            #endregion

            var result = new List<DataTuple>(13000);
            using (var conn = new SqlConnection(ConnectionString))
            {
                conn.Open();
                using (var cmd = new SqlCommand(query, conn))
                {
                    cmd.Parameters.AddWithValue("@year", year);
                    cmd.Parameters.AddWithValue("@sector", sector);
                    using (var reader = cmd.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            var date = (DateTime)reader[0];
                            var sectorId = (int)reader[1];
                            //3: descriptive columns, 11: output columns
                            int width = reader.FieldCount - 3 - 11 + outputColumns.Length;
                            var inputs = new double[width];
                            for (int i = 0; i < width; i++)
                            {
                                inputs[i] = Convert.ToDouble(reader[i + 3]);
                            }

                            var outputs = new double[outputColumns.Length];
                            for (int i = 0; i < outputColumns.Length; i++)
                            {
                                outputs[i] = Convert.ToDouble(reader[outputColumns[i]]);
                            }
                            var tuple = new DataTuple(date, sectorId, sector, inputs, outputs);
                            result.Add(tuple);
                        }
                    }
                }
            }

            return result;
        }

    }
}
