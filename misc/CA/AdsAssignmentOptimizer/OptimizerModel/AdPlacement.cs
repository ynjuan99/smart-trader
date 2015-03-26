using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace OptimizerModel
{
    public class AdPlacement
    {     
        public Website Website { get; set; }
        public Ad Ad { get; set; }
        public double StartTime { get; set; }
        public double EndTime { get; set; }

        public double Cost
        {
            get { return Website.Rate * (EndTime - StartTime); }
        }

        public override string ToString()
        {
            return string.Format("{0}: Start time - {1}, End time - {2}, {3}",
                Website.Name, 
                StartTime.ToString("F1").PadLeft(4, ' '), 
                EndTime.ToString("F1").PadLeft(4, ' '), 
                Ad.Name);
        }
    }
}