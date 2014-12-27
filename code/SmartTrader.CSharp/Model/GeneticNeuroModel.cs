using System;
using System.Configuration;
using AForge.Neuro.Learning;

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
            return new EvolutionaryLearning(_network, DefaultPopulation);
        }

        private static int DefaultPopulation
        {
            get { return Convert.ToInt32(ConfigurationManager.AppSettings["GeneticNeuroModelDefaultPopulation"]); }
        }
    }
}