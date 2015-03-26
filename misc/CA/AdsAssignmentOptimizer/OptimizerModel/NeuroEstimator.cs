using System;
using System.Collections.Generic;
using System.Diagnostics.Eventing.Reader;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using AForge.Neuro;
using AForge.Neuro.Learning;

namespace OptimizerModel
{
    internal sealed class NeuroEstimator : IEstimator
    {                
        private readonly double _sigmoidAlphaValue;
        private readonly double _learningRate;
        private readonly double _momentum;
        private readonly int _maxIterations;
        private ActivationNetwork _network;
        private bool _stopTraining;
        
        private double _outputFloor;
        private double _outputCeiling;

        private readonly int FieldCount = DataContext.Websites.Count * DataContext.PlacementFields;

        public NeuroEstimator() : this(2, 0.1, 0.001, 1000)
        {
        }

        public NeuroEstimator(
            double sigmoidAlphaValue,
            double learningRate,
            double momentum,
            int maxIterations)
        {
            _sigmoidAlphaValue = sigmoidAlphaValue;
            _learningRate = learningRate;
            _momentum = momentum;
            _maxIterations = maxIterations;
        }
        
        public void Train(AdAssignment[] samples)
        {
            _outputFloor = samples.Min(o => o.UserClicks);
            _outputCeiling = samples.Max(o => o.UserClicks);

            _network = new ActivationNetwork(new BipolarSigmoidFunction(_sigmoidAlphaValue), FieldCount, FieldCount * 2, 1);
            var learning = new BackPropagationLearning(_network)
                {
                    LearningRate = _learningRate,
                    Momentum = _momentum
                };

            double[][] inputs, outputs;
            Preprocess(samples, out inputs, out outputs);

            int iteration = 0;
            while (!_stopTraining)
            {
                learning.RunEpoch(inputs, outputs);
                if (++iteration > _maxIterations) break;
            }
        }

        public double EstimateUserClick(AdAssignment assignment)
        {
            if (_network == null) throw new InvalidOperationException("Estimator not trained yet.");

            var data = new double[FieldCount];
            for (int i = 0; i < assignment.PlacementCount; i++)
            {
                var placement = assignment[i];
                data[i * DataContext.PlacementFields] = NormalizeInputTime(placement.StartTime);
                data[i * DataContext.PlacementFields + 1] = NormalizeInputTime(placement.EndTime);
                data[i * DataContext.PlacementFields + 2] = NormalizeInputAdId(placement.Ad.Id);
            }

            return DenormalizeOutput(_network.Compute(data)[0]);
        }

        public void StopTrain()
        {
            _stopTraining = true;
        }
        
        private void Preprocess(AdAssignment[] samples, out double[][] normalizedInputs, out double[][] normalizedOutputs)
        {
            int rowCount = samples.Length;
            normalizedInputs = new double[rowCount][];
            normalizedOutputs = new double[rowCount][];

            for (int i = 0; i < rowCount; i++)
            {
                normalizedInputs[i] = new double[FieldCount];
                var assignment = samples[i];
                for (int j = 0; j < assignment.PlacementCount; j++)
                {
                    var placement = assignment[j];
                    normalizedInputs[i][j * DataContext.PlacementFields] = NormalizeInputTime(placement.StartTime);
                    normalizedInputs[i][j * DataContext.PlacementFields + 1] = NormalizeInputTime(placement.EndTime);
                    normalizedInputs[i][j * DataContext.PlacementFields + 2] = NormalizeInputAdId(placement.Ad.Id);
                }
                normalizedOutputs[i] = new double[1];
                normalizedOutputs[i][0] = NormalizeOutput(assignment.UserClicks);
            }
        }

        private double NormalizeInputTime(double value)
        {
            return DataContext.Normalize(value, 0d, 24d);
        }

        private double NormalizeInputAdId(double value)
        {
            return DataContext.Normalize(value, 1, DataContext.Ads.Count);
        }

        private double NormalizeOutput(double value)
        {
            return DataContext.Normalize(value, _outputFloor, _outputCeiling);
        }
        private double DenormalizeOutput(double value)
        {
            return DataContext.Denormalize(value, _outputFloor, _outputCeiling);
        }

        public override string ToString()
        {
            var builder = new StringBuilder(300);
            builder.AppendLine("Optimal Neural Network Parameters:");            
            builder.AppendFormat("\tInput nodes - {0}, Output nodes - {1}, Hidden Layers - {2}", 
                _network.InputsCount, _network.Output.Length, _network.Layers.Length - 1);
            builder.AppendLine();
            for (int i = 0; i < _network.Layers.Length - 1; i++)
            {
                var layer = _network.Layers[i];
                for (int j = 0; j < layer.Neurons.Length; j++)
                {
                    var neuro = layer.Neurons[j];
                    builder.AppendFormat("\tLayer-Neuro[{0:D2},{1:D2}] weights - {2}", i + 1, j + 1,
                        string.Join(",", neuro.Weights.Select(o => o.ToString("F3"))));
                    builder.AppendLine();
                }                
            }

            for (int i = 0; i < _network.Layers.Length - 1; i++)
            {
                var layer = _network.Layers[i];
                for (int j = 0; j < layer.Neurons.Length; j++)
                {
                    var neuro = layer.Neurons[j];
                    builder.AppendFormat("\tOutput-Layer-Neuro[{0:D2},{1:D2}] weights - {2}", i + 1, j + 1,
                        string.Join(",", neuro.Weights.Select(o => o.ToString("F3"))));
                    builder.AppendLine();
                }
            }

            return builder.ToString();
        }
    }
}
