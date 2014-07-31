using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace OptimizerModel
{
    public interface IEstimator
    {
        void Train(AdAssignment[] samples);

        double EstimateUserClick(AdAssignment assignment);

        void StopTrain();
    }
}
