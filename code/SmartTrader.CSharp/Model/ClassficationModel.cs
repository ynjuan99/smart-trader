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
    public class ClassificationModel : RegressionModel
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

        public override double Test(IList<DataTuple> samples)
        {
            int passed = 0;
            foreach (var sample in samples)
            {
                double[] output = Estimate(sample);
                if (PassTest(sample, output)) passed++;
            }

            return (double)passed / samples.Count;
        }

        private bool PassTest(DataTuple sample, double[] output)
        {
            for (int i = 0; i < output.Length; i++)
            {
                if (output[i] * sample.Outputs[i] < 0) return false;
            }
            return true;
        }
    }
}
