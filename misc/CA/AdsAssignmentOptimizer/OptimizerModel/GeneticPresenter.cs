using System;
using System.Collections.Generic;
using System.Diagnostics.Eventing.Reader;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using AForge;
using AForge.Genetic;
using AForge.Math.Random;

namespace OptimizerModel
{
    internal sealed class GeneticPresenter
    {
        private readonly int _maxIterations;
        private readonly Population _population;
        private bool _stopEvolve;
        private AdAssignmentChromosome _best;        

        public GeneticPresenter(int timingLength, int adLength, int maxIterations, IEstimator estimator) 
            : this(timingLength, adLength, maxIterations, 
            100, 
            0.75, 
            0.25, 
            0.2, 
            new EliteSelection(),
            estimator)
        {            
        }

        public GeneticPresenter(int timingLength, int adLength, int maxIterations,
            int populationSize,
            double crossOverRate,
            double mutationRate,
            double randomSelectionRate,
            ISelectionMethod selectionMethod,
            IEstimator estimator)
        {
            _maxIterations = maxIterations;
            var chromosomeGenerator = new UniformGenerator(new Range(-1, 1));
            var mutationMultiplierGenerator = new ExponentialGenerator(1);
            var mutationAdditionGenerator = new UniformGenerator(new Range(-0.5f, 0.5f));

            var accestor = new AdAssignmentChromosome(
                chromosomeGenerator,
                mutationMultiplierGenerator,
                mutationAdditionGenerator,
                timingLength,
                adLength,
                Denormalize,
                estimator
                );

            _population = new Population(populationSize, accestor, new AdAssignmentFitnessFunc(), selectionMethod)
                {
                    CrossoverRate = crossOverRate,
                    MutationRate = mutationRate,
                    RandomSelectionPortion = randomSelectionRate
                };            
        }
        
        public void Evolve()
        {
            _population.RunEpoch();
            var best = (AdAssignmentChromosome)_population.BestChromosome.Clone();
            int iteration = 0;
            while (!_stopEvolve)
            {
                _population.RunEpoch();
                var chromosome = (AdAssignmentChromosome)_population.BestChromosome;
                if (chromosome.Fitness > best.Fitness) best = chromosome.Clone() as AdAssignmentChromosome;

                if (++iteration > _maxIterations) break;
            }

            _best = best;
        }

        public void StopEvolve()
        {
            _stopEvolve = true;
        }
     
        public AdAssignment BestAssignment
        {
            get
            {
                var result = _best.ToAdAssignment();
                return result;
            }
        }

        private double Denormalize(double value)
        {
            return DataContext.Denormalize(value, 0d, 24d, 0.999);
        }

        private class AdAssignmentFitnessFunc : IFitnessFunction
        {
            public double Evaluate(IChromosome chromosome)
            {
                var assignment = ((AdAssignmentChromosome)chromosome).ToAdAssignment();
                //hard constraint
                if (!DataContext.IsValidAssignment(assignment)) return 0d;
                return assignment.UserClicks;
            }
        }        
    }
}
