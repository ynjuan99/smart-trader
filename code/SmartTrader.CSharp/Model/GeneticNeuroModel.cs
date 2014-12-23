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
    public class GeneticNeuroModel : RegressionModel
    {
        public GeneticNeuroModel()
        {
            
        }

        public GeneticNeuroModel(
            double sigmoidAlphaValue,
            double learningRate,
            double momentum,
            int maxIterations,
            double autoStopRatio) : base(sigmoidAlphaValue, learningRate, momentum, maxIterations, autoStopRatio)
        {
        }

        protected override ISupervisedLearning GetLearningMethod()
        {
            return new EvolutionaryLearning(_network, 100);
        }
    }
}
