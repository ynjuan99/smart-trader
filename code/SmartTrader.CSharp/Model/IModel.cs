using System.Collections.Generic;
using Repository;

namespace Model
{
    public interface IModel
    {
        void Train(IList<DataTuple> samples);
        double Test(IList<DataTuple> samples);
        double[] Estimate(DataTuple sample);
        void StopTrain();
    }
}