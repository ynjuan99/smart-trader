using System;
using System.Data;
using System.Data.SqlClient;
using System.IO;
using System.Linq;

namespace Model
{
    public class DataContext
    {
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
WITH tp AS (SELECT AVG(P_D_forward_week) AS P_D_mean, STDEV(P_D_forward_week) AS P_D_stdev FROM workshop2A_processedData),
tsg AS (SELECT AVG(SG_D_forward_week) AS SG_D_mean, STDEV(SG_D_forward_week) AS SG_D_stdev FROM workshop2A_processedData)
select *, tp.P_D_mean, tp.P_D_stdev, tsg.SG_D_mean, tsg.SG_D_stdev 
FROM workshop2A_processedData, tp, tsg 
WHERE F1 > 4 and F1 < 606
";
            var table = new DataTable();
            using (var conn = new SqlConnection(connectionString))
            {
                conn.Open();
                using (var adatper = new SqlDataAdapter(query, conn))
                {
                    adatper.Fill(table);
                }
            }
            
            var cutoff = new DateTime(1996, 4, 1);
            TrainingIndices = table.Rows.Cast<DataRow>().Where(o => o.Field<DateTime>("date") < cutoff).Select(o => new Indices(o)).ToArray();
            TestingIndices = table.Rows.Cast<DataRow>().Where(o => o.Field<DateTime>("date") >= cutoff).Select(o => new Indices(o)).ToArray();
        }
        
        public Indices[] TrainingIndices { get; private set; }
        public Indices[] TestingIndices { get; private set; }
    }
}