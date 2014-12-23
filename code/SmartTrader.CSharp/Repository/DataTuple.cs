using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Repository
{
    public class DataTuple
    {
        public DateTime Date;
        public int SectorId;
        public string Sector;
        public double[] Inputs;
        public double[] Outputs;
        public Tuple<int[], int[]> ClassificationOutputs;

        public DataTuple(DateTime date, int sectorId, string sector, double[] inputs, double[] outputs)
        {
            Date = date;
            SectorId = sectorId;
            Sector = sector;
            Inputs = inputs;
            Outputs = outputs;
        }
    }
}
