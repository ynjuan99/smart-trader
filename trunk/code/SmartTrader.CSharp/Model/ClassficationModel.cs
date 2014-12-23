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
    public class ClassificationModel : 
        //GeneticNeuroModel 
        RegressionModel
    {        
        public ClassificationModel() : base()
        {
        }

        public ClassificationModel(
            double sigmoidAlphaValue,
            double learningRate,
            double momentum,
            int maxIterations,
            double autoStopRatio) : base(sigmoidAlphaValue, learningRate, momentum, maxIterations, autoStopRatio)
        {            
        }

        public double[] ClassificationBenchmark { get; set; }

        protected override double TestInternal(IList<DataTuple> samples)
        {
            int passed = 0;
            foreach (var sample in samples)
            {
                double[] output = Estimate(sample);
                if (PassTest(sample, output)) passed++;
            }

            Accuracy = (double)passed / samples.Count;
            int actualPositive = samples.Count(o => o.ClassificationOutputs.Item1.All(p => p == 1));
            int bothPositive = samples.Count(o => o.ClassificationOutputs.Item1.All(p => p == 1) && o.ClassificationOutputs.Item2.All(p => p == 1));
            int predictedPositive = samples.Count(o => o.ClassificationOutputs.Item2.All(p => p == 1));
            Precision = (double)bothPositive / predictedPositive;
            Recall = (double)bothPositive / actualPositive;

            return Accuracy.Value;
        }

        protected internal virtual bool PassTest(DataTuple sample, double[] output)
        {
            var class0 = new int[output.Length];
            var class1 = new int[output.Length];
            sample.ClassificationOutputs = new Tuple<int[], int[]>(class0, class1);
            
            bool pass = true;
            for (int i = 0; i < sample.Outputs.Length; i++)
            {
                var f0 = sample.Outputs[i] - ClassificationBenchmark[i] > 0 ? 1 : 0;
                var f1 = output[i] - ClassificationBenchmark[i] > 0 ? 1 : 0;
                class0[i] = f0;
                class1[i] = f1;
                if (f0 != f1) pass = false;
            }

            return pass;
        }        
    }

    public class ClassificationModelWithClassOutput : ClassificationModel
    {
        public ClassificationModelWithClassOutput()
        {
            TransformOutput += ToClassification;
        }

        public ClassificationModelWithClassOutput(
            double sigmoidAlphaValue,
            double learningRate,
            double momentum,
            int maxIterations,
            double autoStopRatio) : base(sigmoidAlphaValue, learningRate, momentum, maxIterations, autoStopRatio)
        {
            TransformOutput += ToClassification;
        }

        private void ToClassification(double[] output)
        {
            for (int i = 0; i < output.Length; i++)
            {
                output[i] = output[i] - ClassificationBenchmark[i] > 0 ? 1 : 0;
            }
        }

        protected internal override bool PassTest(DataTuple sample, double[] output)
        {
            ToClassification(sample.Outputs);
            

            var class0 = new int[output.Length];
            var class1 = new int[output.Length];
            sample.ClassificationOutputs = new Tuple<int[], int[]>(class0, class1);

            bool pass = true;
            for (int i = 0; i < output.Length; i++)
            {
                var f0 = sample.Outputs[i] > 0.99 ? 1 : 0;
                var f1 = output[i] > 0.99 ? 1 : 0;
                class0[i] = f0;
                class1[i] = f1;
                if (f0 != f1) pass = false;
            }

            return pass;
        }        
    }    
}
