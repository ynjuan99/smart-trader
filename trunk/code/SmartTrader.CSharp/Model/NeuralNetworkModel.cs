﻿using System;
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
        private readonly int _maxTry;
        public NeuralNetworkModel() : this(2, 0.1, 0.001, 10, 0.8)
        {
        }

        public NeuralNetworkModel(
            double sigmoidAlphaValue,
            double learningRate,
            double momentum,
            int maxIterations,
            double autoStopRatio)
        {
            _sigmoidAlphaValue = sigmoidAlphaValue;
            _learningRate = learningRate;
            _momentum = momentum;
            _maxIterations = maxIterations;
            _maxTry = (int)(_maxIterations * Math.Max(0.5, Math.Min(1.0, autoStopRatio)));
        }

        public double LeastTrainingMse { get; private set; }
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

            int noChangeCount = 0;
            double previousMse = 0, leastMse = double.MaxValue;
            while (!_stopTraining)
            {
                double currentMse = learning.RunEpoch(inputs, outputs) / (samples.Count * _outputDimension);
                if (currentMse < leastMse) leastMse = currentMse;

                if (iteration > 0)
                {
                    if (Math.Abs(1 - currentMse / previousMse) <= 0.0001) noChangeCount++;
                    else noChangeCount = 0;

                    if (noChangeCount > _maxTry) break;
                }
                
                iteration++;
                if (iteration > _maxIterations) break;
                previousMse = currentMse;
            }

            _stopTraining = false;
            LeastTrainingMse = leastMse;
        }

        public double Validate(IList<DataTuple> samples)
        {
            return samples.Sum(o => AggregateError(o)) / (samples.Count * _outputDimension);
        }

        public double[] Estimate(DataTuple sample)
        {
            if (_network == null) throw new InvalidOperationException("Neural Network not trained yet.");
            
            return _network.Compute(sample.Inputs);
        }

        private double AggregateError(DataTuple sample)
        {
            var output = Estimate(sample);
            double error = 0;
            for (int i = 0; i < _outputDimension; i++)
            {
                error += Math.Pow(output[i] - sample.Outputs[i], 2);
            }

            return error;
        }

        public void StopTrain()
        {
            _stopTraining = true;
        }
        
       
        public override string ToString()
        {
            var builder = new StringBuilder(300);
            builder.AppendLine("Optimal Neural Network Parameters:");            
            builder.AppendFormat("\tInput nodes - {0}, Output nodes - {1}, Hidden Layers - {2}, Least Training MSE: {3}", 
                _network.InputsCount, _network.Output.Length, _network.Layers.Length - 1, LeastTrainingMse);
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