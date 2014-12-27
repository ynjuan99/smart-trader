using System;
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
        //Recall
        public double? Sensitivity { get; protected set; }
        public double? Specificity { get; protected set; }
        public double? Precision { get; protected set; }

        public string Statistics
        {
            get
            {
                return string.Format("Training#: {0}, Testing#: {1}, Accuracy: {2}, Sensitivity: {3}, Specificity: {4}, Precision: {5}",
                    TrainingSize, TestingSize, Accuracy, Sensitivity, Specificity, Precision);
            }
        }

        public double LeastTrainingMse { get; protected set; }
        public double LeastTestingMse { get; protected set; }


        public event Action<DataTuple> TransformOutput;
        public virtual void Train(IList<DataTuple> samples)
        {
            TrainingSize = samples.Count;
            if (TransformOutput != null)
            {
                foreach (var item in samples)
                {
                    TransformOutput(item);
                }
            }

            TrainInternal(samples);
        }

        protected internal abstract void TrainInternal(IList<DataTuple> samples);

        public virtual double Test(IList<DataTuple> samples)
        {
            TestingSize = samples.Count;
            if (TransformOutput != null)
            {
                foreach (var item in samples)
                {
                    TransformOutput(item);
                }
            }

            return TestInternal(samples);
        }

        protected internal abstract double TestInternal(IList<DataTuple> samples);

        protected internal abstract double[] Estimate(DataTuple sample);

        public void StopTrain()
        {
            _stopTraining = true;
        }
    }
}