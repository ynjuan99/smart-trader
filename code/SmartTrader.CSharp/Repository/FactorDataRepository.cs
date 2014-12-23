using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Diagnostics;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Repository
{
    public class FactorDataRepository
    {
        private const string ConnectionString = "Initial Catalog=SmartTrader;Data Source=localhost;Integrated Security=SSPI;";
        private const int TopN = 20;
        public static IList<DataTuple> GetFactorData(int sampling, string sector, int year, params string[] outputColumns)
        {
            string filter = string.Format("YEAR(Date) = {0} AND Sector = '{1}'", year, sector);            
            return GetData(sampling, filter, outputColumns);
        }
        public static IList<DataTuple> GetFactorData(int sampling, string sector, DateTime start, DateTime end, params string[] outputColumns)
        {
            string filter = string.Format("Sector = '{0}' AND Date >= '{1:yyyy-MM-dd HH:mm:ss.fff}' AND Date < '{2:yyyy-MM-dd HH:mm:ss.fff}'",
                sector, start, end.AddDays(1));
            return GetData(sampling, filter, outputColumns);
        }

        private static IList<DataTuple> GetData(int samplePercentage, string filter, params string[] outputColumns)
        {
            #region Script
            const string sql = @"
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
FROM    dbo.tb_FactorScore 
";            
            #endregion

            var query = new StringBuilder(sql);
            if (samplePercentage > 0 && samplePercentage < 100)
            {
                query.AppendFormat(" TABLESAMPLE ({0} PERCENT) ", samplePercentage);
            }
            query.Append(" WHERE 1 = 1");

            foreach (string item in outputColumns)
            {
                query.AppendFormat(" AND {0} IS NOT NULL", item);
            }
            if (!string.IsNullOrWhiteSpace(filter))
            {
                query.AppendFormat(" AND {0} ", filter);
            }

            var result = new List<DataTuple>(15000);
            using (var conn = new SqlConnection(ConnectionString))
            {
                conn.Open();
                using (var cmd = new SqlCommand(query.ToString(), conn))
                {
                    using (var reader = cmd.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            DateTime date = (DateTime)reader[0];
                            int sectorId = Convert.ToInt32(reader[1]);
                            string sector = Convert.ToString(reader[2]);
                            //3: descriptive columns, 12: output columns
                            int width = reader.FieldCount - 3 - outputColumns.Length;
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

        public static double[] GetClassificationBenchmark(IList<DataTuple> data)
        {
            double pos = (double)data.Count * TopN / 100;
            int index = (int)Math.Floor(pos);
            int length = data[0].Outputs.Length;
            var result = new double[length];
            for (int i = 0; i < length; i++)
            {
                //method 1
                var source = data.Select(o => o.Outputs[i]).OrderByDescending(o => o);
                result[i] = (source.ElementAt(index) + source.ElementAt(index + 1)) / 2;

                //method 2
                //result[i] = data.Select(o => o.Outputs[i]).OrderByDescending(o => o).Take(index).Average();
            }

            return result;
        }
    }
}
    