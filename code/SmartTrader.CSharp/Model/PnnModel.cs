using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using AForge.Neuro;
using AForge.Neuro.Learning;
using Encog.ML.Data;
using Encog.ML.Data.Basic;
using Encog.Neural.Networks.Training.PNN;
using Encog.Neural.PNN;
using Repository;

namespace Model
{
    public class PnnModel : Model
    {
        private enum Category
        {
            Up,
            Down,
            Unknown
        }

        private BasicPNN _network;
        private int _inputDimension;
        private int _outputDimension;
        private readonly double _tolerance = 0.01;

        public PnnModel()
        {
        }

        public PnnModel(double tolerance)
        {
            _tolerance = tolerance;
        }

        protected override void TrainInternal(IList<DataTuple> samples)
        {
            _inputDimension = samples[0].Inputs.Length;
            _outputDimension = 3;

            _network = new BasicPNN(PNNKernelType.Gaussian, PNNOutputMode.Classification, _inputDimension, _outputDimension);           
            var trainingData = new BasicMLDataSet(samples.Select(o => o.Inputs).ToArray(), samples.Select(o => Classify(o.Outputs)).ToArray());
            var train = new TrainBasicPNN(_network, trainingData);
            train.Iteration();
        }

        protected override double TestInternal(IList<DataTuple> samples)
        {
            int passed = 0;
            foreach (var sample in samples)
            {
                double[] output = Estimate(sample);
                if (PassTest(sample, output)) passed++;
            }

            return (double)passed / samples.Count;            
        }

        public override double[] Estimate(DataTuple sample)
        {
            var outputs = _network.Compute(new BasicMLData(sample.Inputs));
            var result = new double[outputs.Count];
            outputs.CopyTo(result, 0, result.Length);
            return result;
        }
        
        private bool PassTest(DataTuple sample, double[] output)
        {            
            var output0 = ClassifyMap(sample.Outputs);
            for (int i = 0; i < _outputDimension; i++)
            {
                double delta = Math.Abs(output[i] - output0[i]);
                if (delta > _tolerance) return false;
            }
            return true;
        }

        private double[] ClassifyMap(double[] output)
        {
            var category = Categorize(output);
            switch (category)
            {
                case Category.Up:
                    return new[] { 1d, 0d, 0d };
                case Category.Down:
                    return new[] { 0d, 1d, 0d };
                default:
                    return new[] { 0d, 0d, 1d };
            }
        }

        private double[] Classify(double[] output)
        {
            var category = Categorize(output);
            switch (category)
            {
                case Category.Up:
                    return new[] { 2d };
                case Category.Down:
                    return new[] { 1d };
                default:
                    return new[] { 0d };
            }
        }

        private Category Categorize(double[] value)
        {
            Category result = GetCategory(value[0]);
            for (int i = 1; i < value.Length; i++)
            {
                if (result != GetCategory(value[i])) return Category.Unknown;
            }

            return result;
        }
        private Category GetCategory(double value)
        {
            if (value > 0) return Category.Up;
            if (value < 0) return Category.Down;
            return Category.Unknown;
        }

        public override string ToString()
        {
            var builder = new StringBuilder(300);
            builder.AppendLine("Optimal Probabilistic Neural Network Parameters:");
            builder.AppendFormat("\tInput nodes - {0}, Output nodes - {1}", _inputDimension, _outputDimension);
            builder.AppendLine();
            //builder.AppendFormat("\tSigma[{0}] values: - {1}", _network.Sigma.Length, string.Join(",", _network.Sigma.Select(o => o.ToString("F3"))));
            //builder.AppendLine();

            return builder.ToString();
        }
    }
}
