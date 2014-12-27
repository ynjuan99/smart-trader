using System;
using System.Collections.Generic;
using System.Linq;
using System.Security.Cryptography;
using System.Text;
using System.Threading.Tasks;

namespace Repository
{
    public enum Trend
    {   
        Unsure,
        Positive,
        Negative        
    }

    public class DataTuple
    {
        public DateTime Date;
        public int SectorId;
        public string Sector;
        public double[] Inputs;
        public double[] Outputs;
        public Tuple<Trend[], Trend[]> ClassificationOutputs;

        public DataTuple(DateTime date, int sectorId, string sector, double[] inputs, double[] outputs)
        {
            Date = date;
            SectorId = sectorId;
            Sector = sector;
            Inputs = inputs;
            Outputs = outputs;
        }
    }

    public class SecurityInfo
    {
        public int SecurityId { get; set; }
        public string Company { get; set; }
        public string Sector { get; set; }
        public string SML { get; set; }
    }

    public class Measurement
    {
        public Measurement()
        {
            Top10SecurityList = new List<SecurityInfo>();    
        }

        public string Model { get; set; }
        public int ForYear { get; set; }
        public int ForMonth { get; set; }

        public string Sector { get; set; }

        public List<SecurityInfo> Top10SecurityList { get; private set; }

        public double? Accuracy { get; set; }        
        public double? Sensitivity { get; set; }
        public double? Specificity { get; set; }
        public double? Precision { get; set; }
    }
}
