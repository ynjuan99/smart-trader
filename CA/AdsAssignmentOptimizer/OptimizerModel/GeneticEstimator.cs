using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Diagnostics.Eventing.Reader;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using AForge;
using AForge.Genetic;
using AForge.Math.Random;
using AForge.Neuro;
using AForge.Neuro.Learning;

namespace OptimizerModel
{
    internal sealed class GeneticEstimator : IEstimator
    {
        private readonly int _maxIterations;

        private bool _stopTraining;

        private readonly Population _population;

        private double[] _best;

        private const int Length = 23;

        public GeneticEstimator() : this(10000, 100,
            0.75,
            0.25,
            0.2,
            new EliteSelection())
        {
        }

        public GeneticEstimator(int maxIterations,
            int populationSize,
            double crossOverRate,
            double mutationRate,
            double randomSelectionRate,
            ISelectionMethod selectionMethod)
        {
            _maxIterations = maxIterations;

            var chromosomeGenerator = new UniformGenerator(new Range(-1, 1));
            var mutationMultiplierGenerator = new ExponentialGenerator(1);
            var mutationAdditionGenerator = new UniformGenerator(new Range(-0.5f, 0.5f));

            var accestor = new DoubleArrayChromosome(
                chromosomeGenerator,
                mutationMultiplierGenerator,
                mutationAdditionGenerator, Length);

            _population = new Population(populationSize, accestor, new AdAssignmentFitnessFunc(DataContext.Instance.AdAssignments), selectionMethod)
                {
                    CrossoverRate = crossOverRate,
                    MutationRate = mutationRate,
                    RandomSelectionPortion = randomSelectionRate
                };
        }

        public void Train(AdAssignment[] samples)
        {
            int iteration = 0;
            _population.RunEpoch();
            var best = _population.BestChromosome.Clone();
            while (!_stopTraining)
            {
                _population.RunEpoch();
                var chromosome = _population.BestChromosome;
                if (chromosome.Fitness > best.Fitness) best = chromosome.Clone();

                if (++iteration > _maxIterations) break;
            }

            _best = ((DoubleArrayChromosome)best).Value;
        }

        public double EstimateUserClick(AdAssignment assignment)
        {
            if (_best == null) throw new InvalidOperationException("Estimator not trained yet.");
            return GetClicks(assignment, _best);
        }

        public void StopTrain()
        {
            _stopTraining = true;
        }

        private static double GetClicks(AdAssignment assignment, double[] parameters)
        {
            double cp1 = DenormalizeTime(parameters[0]);
            double cp2 = DenormalizeTime(parameters[1]);
            double sum = 0d;
            for (int i = 0; i < assignment.PlacementCount; i++)
            {
                var durations = GetDurations(assignment[i], cp1, cp2);
                double total = durations[0] * DenormalizeRate(parameters[2 + i * 3])
                    + durations[1] * DenormalizeRate(parameters[2 + i * 3 + 1])
                    + durations[2] * DenormalizeRate(parameters[2 + i * 3 + 2]);
                double factor = parameters[2 + 3 * assignment.PlacementCount + assignment[i].Ad.Id - 1];
                sum += total * DenormalizeFactor(factor);
            }
            return sum;
        }

        private static double[] GetDurations(AdPlacement placement, double cutPoint1, double cutPoint2)
        {
            var result = new double[3];
            double startTime = placement.StartTime;
            double endTime = placement.EndTime;
            if (startTime < endTime)
            {
                result[0] = Math.Min(endTime, cutPoint1) - Math.Min(startTime, cutPoint1);
                result[2] = Math.Max(endTime, cutPoint2) - Math.Max(startTime, cutPoint2);
                result[1] = endTime - startTime - result[0] - result[2];
            }

            return result;
        }

        private static double DenormalizeRate(double value)
        {
            return DataContext.Denormalize(value, 200d, 2000d, 0.999d);
        }

        private static double DenormalizeFactor(double value)
        {
            return DataContext.Denormalize(value, 10d, 100d, 0.999d);
        }

        private static double DenormalizeTime(double value)
        {
            return DataContext.Denormalize(value, 0d, 24d, 0.999d);
        }

        private class AdAssignmentFitnessFunc : IFitnessFunction
        {
            private readonly IEnumerable<AdAssignment> _samples;

            public AdAssignmentFitnessFunc(IEnumerable<AdAssignment> samples)
            {
                _samples = samples;
            }

            public double Evaluate(IChromosome chromosome)
            {
                var value = ((DoubleArrayChromosome)chromosome).Value;
                var discrepancy = _samples.AsParallel().Average(o => Math.Abs(GetClicks(o, value) - o.UserClicks));

                return -discrepancy;
            }
        }

        public override string ToString()
        {
            var builder = new StringBuilder(300);
            builder.AppendLine("Optimal Formula Parameters:");
            builder.AppendFormat("\tCut-Point 1 - {0:F2}, Cut-Point 2 - {1:F2}", DenormalizeTime(_best[0]), DenormalizeTime(_best[1]));
            builder.AppendLine();

            for (int i = 0; i < DataContext.Websites.Count; i++)
            {
                var website = DataContext.Websites[i];
                builder.AppendFormat("\t{0} Click Rates - [{1:F3},{2:F3},{3:F3}] ", website.Name,
                    DenormalizeRate(_best[2 + i * 3]),
                    DenormalizeRate(_best[2 + i * 3 + 1]),
                    DenormalizeRate(_best[2 + i * 3 + 2]));
                builder.AppendLine();
            }
            var factors = new double[_best.Length - (2 + DataContext.Websites.Count * 3)];
            Array.Copy(_best, 2 + DataContext.Websites.Count * 3, factors, 0, factors.Length);
            builder.AppendFormat("\tScale Factors - [{0}]", string.Join(",", factors.Select(o => DenormalizeFactor(o).ToString("F3"))));

            return builder.ToString();
        }
    }
}
