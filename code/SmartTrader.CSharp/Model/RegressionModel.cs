using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using AForge.Neuro;
using AForge.Neuro.Learning;
using Encog.Neural.Pattern;
using Repository;

namespace Model
{
    public class RegressionModel : Model
    {                
        protected readonly double _sigmoidAlphaValue;
        protected readonly double _learningRate;
        protected readonly double _momentum;        
        protected ActivationNetwork _network;
        
        protected int _inputDimension;
        protected int _outputDimension;
        
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

        public event Action<double[]> TransformOutput;

        protected override void TrainInternal(IList<DataTuple> samples)
        {            
            _inputDimension = samples[0].Inputs.Length;
            _outputDimension = samples[0].Outputs.Length;
            
            //2 hidden layers
            _network = new ActivationNetwork(new BipolarSigmoidFunction(_sigmoidAlphaValue), _inputDimension, _inputDimension / 2, 7, _outputDimension);
            var learning = GetLearningMethod();

            var inputs = samples.Select(o => o.Inputs).ToArray();
            var outputs = samples.Select(o => o.Outputs).ToArray();
            if (TransformOutput != null)
            {
                foreach (var item in outputs)
                {
                    TransformOutput(item);
                }
            }

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
        }

        protected virtual ISupervisedLearning GetLearningMethod()
        {
            return new BackPropagationLearning(_network)
            {
                LearningRate = _learningRate,
                Momentum = _momentum
            };
        }
        
        protected override double TestInternal(IList<DataTuple> samples)
        {
            double total = 0;
            int accure = 0;
            foreach (var sample in samples)
            {
                double[] output = Estimate(sample);
                bool acceptable = true;
                for (int i = 0; i < _outputDimension; i++)
                {
                    double delta = output[i] - sample.Outputs[i];
                    total += delta * delta;

                    if (Math.Abs(delta / sample.Outputs[i]) > 0.4) acceptable = false;
                }
                if (acceptable) accure++;
            }

            Accuracy = (double)accure / samples.Count;
            return total / (samples.Count * _outputDimension);
        }

        public override double[] Estimate(DataTuple sample)
        {
            if (_network == null) throw new InvalidOperationException("Neural Network not trained yet.");
            
            return _network.Compute(sample.Inputs);
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
                    builder.AppendFormat("\tHidden-Layer-Neuron[{0:D2},{1:D2}] weights - \t{2}", i + 1, j + 1,
                        string.Join(",", neuro.Weights.Select(o => o.ToString("'+'00.000;'-'00.000"))));
                    builder.AppendLine();
                }                
            }

            builder.AppendLine("=======================================================================================================");
            var outputLayer = _network.Layers[_network.Layers.Length - 1];
            for (int i = 0; i < outputLayer.Neurons.Length; i++)
            {
                var neuro = outputLayer.Neurons[i];
                builder.AppendFormat("\tOutput-Layer-Neuron[{0:D2}]    weights - \t{1}", i + 1,
                    string.Join(",", neuro.Weights.Select(o => o.ToString("'+'00.00000;'-'00.00000"))));
                builder.AppendLine();
            }

            return builder.ToString();
        }
    }
}
