using AForge;
using AForge.Genetic;
using AForge.Math.Random;

namespace Model
{
    public class GeneticWeightTuner
    {
        private readonly int _maxIterations;
        private readonly Population _population;
        private bool _stopEvolve;
        private DoubleArrayChromosome _best;

        public GeneticWeightTuner(int chromosomeLength, IFitnessFunction fitnessFunc)
            : this(chromosomeLength, 100,
                100,
                0.75,
                0.25,
                0.2,
                new EliteSelection(),
                fitnessFunc
                )
        {
        }

        public GeneticWeightTuner(int chromosomeLength, int maxIterations,
            int populationSize,
            double crossOverRate,
            double mutationRate,
            double randomSelectionRate,
            ISelectionMethod selectionMethod,
            IFitnessFunction fitnessFunc)
        {
            _maxIterations = maxIterations;
            var chromosomeGenerator = new UniformGenerator(new Range(-1, 1));
            var mutationMultiplierGenerator = new ExponentialGenerator(1);
            var mutationAdditionGenerator = new UniformGenerator(new Range(-0.5f, 0.5f));

            var accestor = new DoubleArrayChromosome(
                chromosomeGenerator,
                mutationMultiplierGenerator,
                mutationAdditionGenerator,
                chromosomeLength);

            _population = new Population(populationSize, accestor, fitnessFunc, selectionMethod)
            {
                CrossoverRate = crossOverRate,
                MutationRate = mutationRate,
                RandomSelectionPortion = randomSelectionRate
            };
        }

        public void Evolve()
        {
            _population.RunEpoch();
            var best = (DoubleArrayChromosome)_population.BestChromosome.Clone();
            int iteration = 0;
            while (!_stopEvolve)
            {
                _population.RunEpoch();
                var chromosome = (DoubleArrayChromosome)_population.BestChromosome;
                if (chromosome.Fitness > best.Fitness) best = chromosome.Clone() as DoubleArrayChromosome;

                if (++iteration > _maxIterations) break;
            }

            _best = best;
        }

        public void StopEvolve()
        {
            _stopEvolve = true;
        }

        public double[] BestAdjustment
        {
            get { return _best.Value; }
        }

        public double BestFitness
        {
            get { return _best.Fitness; }
        }
    }
}