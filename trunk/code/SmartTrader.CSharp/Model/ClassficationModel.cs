using System;
using System.Collections.Generic;
using System.Configuration;
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
        public ClassificationModel()
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

        protected internal override double TestInternal(IList<DataTuple> samples)
        {
            int passed = 0;
            foreach (var sample in samples)
            {
                double[] prediction = Estimate(sample);
                if (PassTest(sample, prediction)) passed++;
            }

            int actualPositive = samples.Count(o => o.ClassificationOutputs.Item1.All(p => p == Trend.Positive));
            int bothPositive = samples.Count(o => o.ClassificationOutputs.Item1.All(p => p == Trend.Positive) && o.ClassificationOutputs.Item2.All(p => p == Trend.Positive));
            int actualNegative = samples.Count(o => o.ClassificationOutputs.Item1.All(p => p == Trend.Negative));
            int bothNegative = samples.Count(o => o.ClassificationOutputs.Item1.All(p => p == Trend.Negative) && o.ClassificationOutputs.Item2.All(p => p == Trend.Negative));            
            int predictedPositive = samples.Count(o => o.ClassificationOutputs.Item2.All(p => p == Trend.Positive));
            
            Accuracy = (double)passed / samples.Count;
            Sensitivity = (double)bothPositive / actualPositive;
            Specificity = (double)bothNegative / actualNegative;
            Precision = (double)bothPositive / predictedPositive;
            
            return Accuracy.Value;
        }

        protected internal virtual bool PassTest(DataTuple sample, double[] prediction)
        {
            var class0 = new Trend[prediction.Length];
            var class1 = new Trend[prediction.Length];
            sample.ClassificationOutputs = new Tuple<Trend[], Trend[]>(class0, class1);
            
            bool pass = true;
            for (int i = 0; i < sample.Outputs.Length; i++)
            {
                var f0 = sample.Outputs[i] - ClassificationBenchmark[i] > 0 ? Trend.Positive : Trend.Negative;
                var f1 = prediction[i] - ClassificationBenchmark[i] > 0 ? Trend.Positive : Trend.Negative;
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
            TransformOutput += Classify;
        }

        public ClassificationModelWithClassOutput(
            double sigmoidAlphaValue,
            double learningRate,
            double momentum,
            int maxIterations,
            double autoStopRatio) : base(sigmoidAlphaValue, learningRate, momentum, maxIterations, autoStopRatio)
        {
            TransformOutput += Classify;
        }

        private void Classify(DataTuple sample)
        {
            for (int i = 0; i < sample.Outputs.Length; i++)
            {
                sample.Outputs[i] = sample.Outputs[i] - ClassificationBenchmark[i] > 0 ? 1 : 0;
            }
        }

        protected internal override bool PassTest(DataTuple sample, double[] prediction)
        {
            var class0 = new Trend[prediction.Length];
            var class1 = new Trend[prediction.Length];
            sample.ClassificationOutputs = new Tuple<Trend[], Trend[]>(class0, class1);

            bool pass = true;
            for (int i = 0; i < prediction.Length; i++)
            {
                var f0 = sample.Outputs[i] > PositiveTrendThreshold ? Trend.Positive : Trend.Negative;
                var f1 = prediction[i] > PositiveTrendThreshold ? Trend.Positive : Trend.Negative;
                class0[i] = f0;
                class1[i] = f1;
                if (f0 != f1) pass = false;
            }

            return pass;
        }

        private static double PositiveTrendThreshold
        {
            get { return Convert.ToDouble(ConfigurationManager.AppSettings["PositiveTrendThreshold"]); }             
        }
    }    
}
