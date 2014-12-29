﻿using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data.SqlClient;
using System.Linq;

namespace Repository
{
    public class FactorDataRepository
    {
        internal static string ConnectionString
        {
            get { return ConfigurationManager.AppSettings["ConnectionString"]; }
        }

        internal static int ClassificationBenchmark
        {
            get { return Convert.ToInt32(ConfigurationManager.AppSettings["ClassificationBenchmark"]); }
        }

        public static IList<DataTuple> GetFactorData(int sampling, string sector, int year)
        {
            string filter = string.Format("YEAR(Date) = {0} AND Sector = '{1}'", year, sector);
            return GetData(sampling, filter);
        }

        public static IList<DataTuple> GetFactorData(int sampling, string sector, DateTime start, DateTime end)
        {
            string filter = string.Format("Sector = '{0}' AND Date >= '{1:yyyy-MM-dd HH:mm:ss.fff}' AND Date < '{2:yyyy-MM-dd HH:mm:ss.fff}'",
                sector, start, end.AddDays(1));
            return GetData(sampling, filter);
        }

        private static IList<DataTuple> GetData(int samplePercentage, string filter)
        {
            #region Script
            string sampling = (samplePercentage > 0 && samplePercentage < 100)
                ? string.Format(" TABLESAMPLE ({0} PERCENT) ", samplePercentage)
                : string.Empty;
            string filterClause = string.IsNullOrWhiteSpace(filter) ? "0 = 0" : filter;

            string sql = string.Format(@"
SELECT 
Date, 
SecId, 
Sector,
EarningsFY2UpDnGrade_1M,
EarningsFY1UpDnGrade_1M,
EarningsRevFY1_1M,
NMRevFY1_1M,
PriceMA10,
PriceMA20,
PMOM10,
RSI14D,
EarningsFY2UpDnGrade_3M,
FERating,
PriceSlope10D,
PriceMA50,
SalesRevFY1_1M,
PMOM20,
NMRevFY1_3M,
EarningsFY2UpDnGrade_6M,
PriceSlope20D,
Price52WHigh,
EarningsRevFY1_3M,
PMOM50,
PriceTStat200D,
RSI50D,
MoneyFlow14D,
PriceTStat100D,
PEGFY1,
Volatility12M,
SharesChg12M,
PriceMA100,
Volatility6M,
SalesYieldFY1,
EarningsYieldFY2,
PriceRetFF20D,
PriceRetFF20D_Absolute
FROM    dbo.tb_FactorScore {0} 
WHERE PriceRetFF20D IS NOT NULL AND PriceRetFF20D_Absolute IS NOT NULL AND {1}
", sampling, filterClause);
            #endregion

            var result = new List<DataTuple>(15000);
            using (var conn = new SqlConnection(ConnectionString))
            {
                conn.Open();
                using (var cmd = new SqlCommand(sql, conn))
                {
                    using (var reader = cmd.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            DateTime date = (DateTime)reader[0];
                            int securityId = Convert.ToInt32(reader[1]);
                            string sector = Convert.ToString(reader[2]);

                            int width = reader.FieldCount - 3 - 2;
                            var inputs = new double[width];
                            for (int i = 3; i < width; i++)
                            {
                                inputs[i] = reader.IsDBNull(i) ? 0 : Convert.ToDouble(reader[i]);
                            }                            
                            double actualTarget = Convert.ToDouble(reader["PriceRetFF20D"]);
                            var outputs = new[] { actualTarget };
                            
                            var tuple = new DataTuple(date, securityId, sector, inputs, outputs);
                            result.Add(tuple);
                        }
                    }
                }
            }

            return result;
        }

        public static double GetClassificationBenchmark(IList<DataTuple> data, Func<DataTuple, double> selector, Func<DataTuple, double> sorter)
        {
            double pos = (double)data.Count * ClassificationBenchmark / 100;
            int index = (int)Math.Floor(pos);
            var source = data.OrderByDescending(sorter).Select(selector).ToArray();
            return (source[index] + source[index + 1]) / 2;
        }

        public static IList<SecurityInfo> GetSecurityList(params int[] securityIds)
        {
            var result = new List<SecurityInfo>();
            if (securityIds.Length == 0) return result;

            string sql = string.Format("SELECT SecId, CompanyName AS Company, GICS_SEC AS Sector, SML FROM tb_SecurityMaster WHERE SecId IN ({0})",
                string.Join(",", securityIds));

            using (var conn = new SqlConnection(ConnectionString))
            {
                conn.Open();
                var cmd = new SqlCommand(sql, conn);
                using (var reader = cmd.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        var stockInfo = new SecurityInfo
                        {
                            SecurityId = Convert.ToInt32(reader[0]),
                            Company = Convert.ToString(reader[1]),
                            Sector = Convert.ToString(reader[2]),
                            SML = Convert.ToString(reader[3])
                        };
                        result.Add(stockInfo);
                    }
                }
            }

            return result;
        }

        private static readonly Lazy<Dictionary<int, DateTime>> TargetDate = new Lazy<Dictionary<int, DateTime>>(
            () =>
            {
                string sql = "SELECT CalendarDate FROM tb_Calendar WHERE IsBizMonthEnd = 1 ORDER BY CalendarDate";
                var dictionary = new Dictionary<int, DateTime>(204);
                using (var conn = new SqlConnection(ConnectionString))
                {
                    conn.Open();
                    var cmd = new SqlCommand(sql, conn);
                    var reader = cmd.ExecuteReader();
                    while (reader.Read())
                    {
                        var date = Convert.ToDateTime(reader[0]);
                        dictionary.Add(date.Year * 100 + date.Month, date);
                    }
                }
                return dictionary;
            }
            );

        public static DateTime GetTargetDate(int year, int month)
        {
            return TargetDate.Value[year * 100 + month];
        }

        public static void PersistResultTuple(ResultTuple data)
        {
            string sql = string.Format(@"
INSERT tb_ModelResult(ModelName, Sector, ForYear, ForMonth, Accuracy, Sensitivity, Specificity, Precision, Top10SecurityIds)
VALUES('{0}', '{1}', {2}, {3}, {4}, {5}, {6}, {7}, '{8}')
", data.Model, data.Sector, data.ForYear, data.ForMonth, 
 data.Accuracy.HasValue ? data.Accuracy.ToString() : "NULL",
 data.Sensitivity.HasValue ? data.Sensitivity.ToString() : "NULL",
 data.Specificity.HasValue ? data.Specificity.ToString() : "NULL",
 data.Precision.HasValue ? data.Precision.ToString() : "NULL", 
 string.Join(",", data.TopSecurityList.Select(o => o.SecurityId).ToArray()));

            using (var conn = new SqlConnection(ConnectionString))
            {
                conn.Open();
                var cmd = new SqlCommand(sql, conn);
                cmd.ExecuteNonQuery();
            } 
        }
       
        public IList<ResultTuple> RetrieveResultTuple(string model, string sector, int year, int month)
        {
            string sql = string.Format(@"
SELECT ModelName, Sector, ForYear, ForMonth, Accuracy, Sensitivity, Specificity, Precision, Top10SecurityIds 
FROM tb_ModelResult 
WHERE ForYear = {0} AND ForMonth = {1}", year, month);
            if (!string.IsNullOrWhiteSpace(model)) sql += string.Format(" AND ModelName LIKE '%{0}%'", model.Trim());
            if (!string.IsNullOrWhiteSpace(sector)) sql += string.Format(" AND Sector LIKE '%{0}%'", sector.Trim());

            var result = new List<ResultTuple>();
            using (var conn = new SqlConnection(ConnectionString))
            {
                conn.Open();
                var cmd = new SqlCommand(sql, conn);
                using (var reader = cmd.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        var data = new ResultTuple
                        {
                            Model = Convert.ToString(reader[0]),
                            Sector = Convert.ToString(reader[1]),
                            ForYear = Convert.ToInt32(reader[2]),
                            ForMonth = Convert.ToInt32(reader[3]),
                            Accuracy = Convert.ToDouble(reader[4]),
                            Sensitivity = Convert.ToDouble(reader[5]),
                            Specificity = Convert.ToDouble(reader[6]),
                            Precision = Convert.ToDouble(reader[7])                            
                        };
                        var ids = Convert.ToString(reader[8]).Split(',').Select(o => Convert.ToInt32(o)).ToArray();                      
                        data.TopSecurityList = GetSecurityList(ids);

                        result.Add(data);
                    }
                }
            }

            return result;
        }
    }
}