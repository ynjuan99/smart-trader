using System.Collections.Generic;
using Repository;

namespace Model
{
    public abstract class Model
    {
        protected int _maxIterations;
        protected int _maxTry;
        protected bool _stopTraining;

        public int TrainingSize { get; protected set; }
        public int TestingSize { get; protected set; }

        public double? Accuracy { get; protected set; }
        public double? Precision { get; protected set; }
        public double? Recall { get; protected set; }

        public double LeastTrainingMse { get; protected set; }
        
        public string Statistics
        {
            get
            {
                return string.Format("Training #: {0}; Testing #: {1}; Training MSE: {2}; Accuracy: {3}; Precision: {4}; Recall: {5}",
                    TrainingSize, TestingSize, LeastTrainingMse, Accuracy, Precision, Recall);
            }
        }

        public virtual void Train(IList<DataTuple> samples)
        {
            TrainingSize = samples.Count;
            TrainInternal(samples);
        }

        protected abstract void TrainInternal(IList<DataTuple> samples);

        public virtual double Test(IList<DataTuple> samples)
        {
            TestingSize = samples.Count;
            return TestInternal(samples);
        }

        protected abstract double TestInternal(IList<DataTuple> samples);
        
        public abstract double[] Estimate(DataTuple sample);

        public void StopTrain()
        {
            _stopTraining = true;
        }
    }
}