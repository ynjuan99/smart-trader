using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using AForge.Genetic;
using AForge.Neuro;
using AForge.Neuro.Learning;
using Repository;

namespace Model
{
    public class RegressionModel : IFitnessFunction
    {
        protected readonly double _sigmoidAlphaValue;
        protected readonly double _learningRate;
        protected readonly double _momentum;
        protected readonly int _maxIterations;
        protected ActivationNetwork _network;
        protected bool _stopTraining;
        protected int _inputDimension;
        protected int _outputDimension;
        protected readonly int _maxTry;

        public RegressionModel() : this(2, 0.1, 0.001, 10, 0.8)
        {
        }

        public RegressionModel(
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
        public int WeightNumber { get; private set; }
        public IList<DataTuple> TrainingData { get; set; }
        public IList<DataTuple> TestData { get; set; }

        public void Train()
        {
            var samples = TrainingData;
            _inputDimension = samples[0].Inputs.Length;
            _outputDimension = samples[0].Outputs.Length;

            //2 hidden layers
            _network = new ActivationNetwork(new BipolarSigmoidFunction(_sigmoidAlphaValue), _inputDimension, _inputDimension / 3, 7, _outputDimension);
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
                double currentMse = 2 * learning.RunEpoch(inputs, outputs) / (samples.Count * _outputDimension);
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
            WeightNumber = _network.Layers.SelectMany(o => o.Neurons).Sum(o => o.Weights.Length);
        }

        public double Test()
        {
            return Test(TestData, _network);
        }

        private double Test(IList<DataTuple> samples, Network network)
        {
            double total = 0;
            foreach (var sample in samples)
            {
                double[] output = network.Compute(sample.Inputs);
                for (int i = 0; i < _outputDimension; i++)
                {
                    double delta = output[i] - sample.Outputs[i];
                    total += delta * delta;
                }
            }

            return total / (samples.Count * _outputDimension);
        }

        public void StopTrain()
        {
            _stopTraining = true;
        }

        public double Evaluate(IChromosome chromosome)
        {
            double[] adjustment = ((DoubleArrayChromosome)chromosome).Value;
            Network networkClone;
            using (var snapshot = new MemoryStream())
            {
                _network.Save(snapshot);
                snapshot.Position = 0;
                networkClone = Network.Load(snapshot);
            }

            int p = 0;
            for (int i = 0; i < networkClone.Layers.Length; i++)
            {
                var layer = networkClone.Layers[i];
                for (int j = 0; j < layer.Neurons.Length; j++)
                {
                    var neuro = layer.Neurons[j];
                    for (int k = 0; k < neuro.Weights.Length; k++)
                    {
                        neuro.Weights[k] *= 1 + Cap(adjustment[p++]) / 100d;
                    }
                }
            }

            return -Test(TestData, networkClone);
        }

        private double Cap(double value)
        {
            const double cap = 10d;
            return Math.Min(cap, Math.Max(-cap, value));
        }

        public override string ToString()
        {
            var builder = new StringBuilder(30000);
            builder.AppendLine("Optimal Neural Network Parameters:");
            builder.AppendFormat("\tInput nodes - {0}, Output nodes - {1}, Hidden Layers - {2}[{4}], Least Training MSE: {3}",
                _network.InputsCount, _network.Output.Length, _network.Layers.Length - 1, LeastTrainingMse,
                string.Join("-", _network.Layers.Take(_network.Layers.Length - 1).Select(o => o.Neurons.Length)));
            builder.AppendLine();
            for (int i = 0; i < _network.Layers.Length - 1; i++)
            {
                var layer = _network.Layers[i];
                for (int j = 0; j < layer.Neurons.Length; j++)
                {
                    var neuro = layer.Neurons[j];
                    builder.AppendFormat("\tHidden-Layer-Neuro[{0:D2},{1:D2}] weights - \t{2}", i + 1, j + 1,
                        string.Join(",", neuro.Weights.Select(o => o.ToString("'+'00.000;'-'00.000"))));
                    builder.AppendLine();
                }
            }

            builder.AppendLine("=======================================================================================================");
            var outputLayer = _network.Layers[_network.Layers.Length - 1];
            for (int i = 0; i < outputLayer.Neurons.Length; i++)
            {
                var neuro = outputLayer.Neurons[i];
                builder.AppendFormat("\tOutput-Layer-Neuro[{0:D2}]    weights - \t{1}", i + 1,
                    string.Join(",", neuro.Weights.Select(o => o.ToString("'+'00.00000;'-'00.00000"))));
                builder.AppendLine();
            }

            return builder.ToString();
        }
    }
}