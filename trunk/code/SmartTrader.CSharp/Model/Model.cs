using System;
using System.Collections.Generic;
using System.Configuration;
using Repository;

namespace Model
{
    public interface IMeasurement
    {
        double? Accuracy { get; }        
        double? Sensitivity { get; }
        double? Specificity { get; }
        double? Precision { get; }
    }

    public abstract class Model
    {
        protected int _maxIterations;
        protected int _maxTry;
        protected bool _stopTraining;

        public int TrainingSize { get; protected set; }
        public int TestingSize { get; protected set; }


        private double? _Accuracy;
        private double? _Sensitivity;
        private double? _Specificity;
        private double? _Precision;

        public double? Accuracy
        {
            get { return _Accuracy; }
            protected set { _Accuracy = EnsureValue(value); }
        }
        public double? Sensitivity
        {
            get { return _Sensitivity; }
            protected set { _Sensitivity = EnsureValue(value); }
        }

        public double? Specificity
        {
            get { return _Specificity; }
            protected set { _Specificity = EnsureValue(value); }
        }
        public double? Precision
        {
            get { return _Precision; }
            protected set { _Precision = EnsureValue(value); }
        }

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

        protected static int TopNSecurity
        {
            get { return Convert.ToInt32(ConfigurationManager.AppSettings["TopNSecurity"]); }
        }

        protected double? EnsureValue(double? value)
        {
            if (value.HasValue && (double.IsNaN(value.Value) || double.IsInfinity(value.Value))) return null;
            return value;
        }

    }
}