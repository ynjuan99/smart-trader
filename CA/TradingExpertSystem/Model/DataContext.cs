using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.IO;
using System.Linq;

namespace Model
{
    public class DataContext
    {
        public static readonly Dictionary<Country, Currency> CurrencyMap = new Dictionary<Country, Currency>
        {
            { Country.SG, Currency.SGD },
            { Country.UK, Currency.UKP },
            { Country.US, Currency.USD }
        };

        public const double CostPerTransaction = 0.01f;

        private static DataContext _instance;

        public static DataContext Instance
        {
            get
            {
                if (_instance == null) throw new InvalidOperationException("Must Create Context before use.");
                return _instance;
            }
        }

        public static void CreateContext(string connStr)
        {
            _instance = new DataContext(connStr);
        }

        
        private DataContext(string connectionString)
        {
            const string query = @"
WITH tp AS (SELECT AVG(UK_D_forward_week) AS UK_D_mean, STDEV(UK_D_forward_week) AS UK_D_stdev FROM workshop2A_processedData),
tsg AS (SELECT AVG(SG_D_forward_week) AS SG_D_mean, STDEV(SG_D_forward_week) AS SG_D_stdev FROM workshop2A_processedData)
select *, tp.UK_D_mean, tp.UK_D_stdev, tsg.SG_D_mean, tsg.SG_D_stdev 
FROM workshop2A_processedData, tp, tsg 
WHERE F1 BETWEEN 5 AND 605

SELECT * FROM Rules
";
            var dataSet = new DataSet();
            using (var conn = new SqlConnection(connectionString))
            {
                conn.Open();
                using (var adatper = new SqlDataAdapter(query, conn))
                {
                    adatper.Fill(dataSet);
                }
            }
            
            var cutoff = new DateTime(1996, 4, 1);
            TrainingIndices = dataSet.Tables[0].Rows.Cast<DataRow>().Where(o => o.Field<DateTime>("date") < cutoff).Select(o => new Indices(o)).ToArray();
            TestingIndices = dataSet.Tables[0].Rows.Cast<DataRow>().Where(o => o.Field<DateTime>("date") >= cutoff).Select(o => new Indices(o)).ToArray();

            Rules = dataSet.Tables[1].Rows.Cast<DataRow>().SelectMany(o => Rule.LoadRule(o)).ToArray();
        }
        
        public Indices[] TrainingIndices { get; private set; }
        public Indices[] TestingIndices { get; private set; }

        public Rule[] Rules { get; private set; }
    }
}