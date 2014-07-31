using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace OptimizerModel
{
    public class AdAssignment
    {
        private readonly AdPlacement[] placements;

        public AdAssignment(params AdPlacement[] placements)
        {
            this.placements = placements;
        }

        public int PlacementCount
        {
            get { return placements.Length; }
        }

        public AdPlacement this[int i]
        {
            get { return i >= 0 && i < placements.Length ? placements[i] : null; }            
        }

        public double UserClicks { get; set; }

        public double TotalCost
        {
            get { return placements.Sum(o => o.Cost); }
        }

        public override string ToString()
        {
            var builder = new StringBuilder(300);
            builder.AppendLine("Ad Assignment:");
            foreach (var item in placements)
            {
                builder.AppendLine("\t" + item);
            }
            builder.AppendFormat("Total cost - {0:F2}, User clicks - {1:F0}", TotalCost, UserClicks);
           
            return builder.ToString();
        }
    }
}
