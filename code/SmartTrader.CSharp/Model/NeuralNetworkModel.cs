using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using AForge.Neuro;
using AForge.Neuro.Learning;
using Repository;

namespace Model
{
    public class NeuralNetworkModel
    {                
        private readonly double _sigmoidAlphaValue;
        private readonly double _learningRate;
        private readonly double _momentum;
        private readonly int _maxIterations;
        private ActivationNetwork _network;
        private bool _stopTraining;
        private int _inputDimension;
        private int _outputDimension;
        public NeuralNetworkModel() : this(2, 0.1, 0.001, 10)
        {
        }

        public NeuralNetworkModel(
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

        public void Train(IList<DataTuple> samples)
        {
            _inputDimension = samples[0].Inputs.Length;
            _outputDimension = samples[0].Outputs.Length;

            _network = new ActivationNetwork(new BipolarSigmoidFunction(_sigmoidAlphaValue), _inputDimension, _inputDimension * 2, 1);
            var learning = new BackPropagationLearning(_network)
                {
                    LearningRate = _learningRate,
                    Momentum = _momentum
                };

            var inputs = samples.Select(o => o.Inputs).ToArray();
            var outputs = samples.Select(o => o.Outputs).ToArray();
            int iteration = 0;
            while (!_stopTraining)
            {
                learning.RunEpoch(inputs, outputs);
                if (++iteration > _maxIterations) break;
            }

            _stopTraining = false;
        }

        public double[] Validate(IList<DataTuple> samples)
        {
            var delta = samples.AsParallel().Select(o => GetErrorVector(o)).ToArray();
            var results = new double[_outputDimension];
            for (int i = 0; i < _outputDimension; i++)
            {
                results[i] = Math.Sqrt(delta.Average(o => o[i]));
            }

            return results;
        }

        public double[] Estimate(DataTuple sample)
        {
            if (_network == null) throw new InvalidOperationException("Neural Network not trained yet.");
            
            return _network.Compute(sample.Inputs);
        }

        private double[] GetErrorVector(DataTuple sample)
        {
            var output = Estimate(sample);
            var errors = new double[_outputDimension];
            for (int i = 0; i < _outputDimension; i++)
            {
                errors[i] = Math.Pow(output[i] - errors[i], 2);
            }

            return errors;
        }

        public void StopTrain()
        {
            _stopTraining = true;
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
