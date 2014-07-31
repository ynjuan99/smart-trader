using System;
using System.Collections.Generic;
using System.Diagnostics.Eventing.Reader;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using AForge.Genetic;
using AForge.Math.Random;

namespace OptimizerModel
{
    internal sealed class AdAssignmentChromosome : ChromosomeBase
    {
        private readonly DoubleArrayChromosome _timingChromosome;
        private readonly PermutationChromosome _adsChromosome;       
        private readonly Func<double, double> _timingDenormalizer;
        private readonly IEstimator _estimator;
        
        public AdAssignmentChromosome(
            IRandomNumberGenerator timingChromosomeGenerator, 
            IRandomNumberGenerator mutationMultiplierGenerator, 
            IRandomNumberGenerator mutationAdditionGenerator, 
            int timingChromosomeLength,
            int adChromosomeLength,
            Func<double, double> timingDenormalizer,
            IEstimator estimator)
        {
            _timingChromosome = new DoubleArrayChromosome(
                timingChromosomeGenerator,
                mutationMultiplierGenerator,
                mutationAdditionGenerator,
                timingChromosomeLength);
            _adsChromosome = new PermutationChromosome(adChromosomeLength);
            _timingDenormalizer = timingDenormalizer;
            _estimator = estimator;

            Repair(this);
        }

        public AdAssignmentChromosome(AdAssignmentChromosome source)
        {
            _timingChromosome = new DoubleArrayChromosome(source._timingChromosome);
            _adsChromosome = new PermutationChromosome(source._adsChromosome.Length);
            _timingDenormalizer = source._timingDenormalizer;
            _estimator = source._estimator;            
        }

        public override IChromosome CreateNew()
        {
            return new AdAssignmentChromosome(this);
        }

        public override IChromosome Clone()
        {
            return new AdAssignmentChromosome(this);
        }

        public override void Generate()
        {
            _timingChromosome.Generate();
            _adsChromosome.Generate();
            Repair(this);
        }

        public override void Crossover(IChromosome pair)
        {
            _timingChromosome.Crossover(((AdAssignmentChromosome)pair)._timingChromosome);
            _adsChromosome.Crossover(((AdAssignmentChromosome)pair)._adsChromosome);
            Repair(this);
            Repair((AdAssignmentChromosome)pair);
        }
        
        public override void Mutate()
        {
            _timingChromosome.Mutate();
            _adsChromosome.Mutate();  
            Repair(this);      
        }

        private void Repair(AdAssignmentChromosome chromosome)
        {
            for (int i = 0; i < chromosome._timingChromosome.Value.Length; i++)
            {
                chromosome._timingChromosome.Value[i] = ((chromosome._timingChromosome.Value[i] % 0.999) + 0.999) % 0.999;
            }

            for (int i = 0; i < chromosome._timingChromosome.Value.Length / 2; i++)
            {
                double startValue = chromosome._timingChromosome.Value[i * 2];
                double endValue = chromosome._timingChromosome.Value[i * 2 + 1];
                if (startValue > endValue)
                {
                    chromosome._timingChromosome.Value[i * 2] = endValue;
                    chromosome._timingChromosome.Value[i * 2 + 1] = startValue;
                }
            }
        }
        
        public AdAssignment ToAdAssignment()
        {
            int count = _timingChromosome.Length / 2;
            var placements = new AdPlacement[count];
            for (int i = 0; i < count; i++)
            {
                var placement = new AdPlacement
                {
                    Website = DataContext.Websites[i],
                    StartTime = _timingDenormalizer(_timingChromosome.Value[i * 2]),
                    EndTime = _timingDenormalizer(_timingChromosome.Value[i * 2 + 1]),
                    Ad = DataContext.Ads[_adsChromosome.Value[i]]
                };
                placements[i] = placement;
            }

            var result = new AdAssignment(placements);
            result.UserClicks = _estimator.EstimateUserClick(result);
            return result;
        }        
    }
}
