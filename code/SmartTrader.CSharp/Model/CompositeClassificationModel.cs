using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Repository;

namespace Model
{
    public class CompositeClassificationModel : Model, IClassificationModel
    {
        private readonly Tuple<ClassificationModel, double>[] _models;
        public CompositeClassificationModel(params Tuple<ClassificationModel, double>[] models)
        {
            _models = models;
        }

        protected internal override void TrainInternal(IList<DataTuple> samples)
        {            
        }

        protected internal override double TestInternal(IList<DataTuple> samples)
        {
            int passed = 0;
            foreach (var sample in samples)
            {
                double vote = 0;
                double voteBase = 0;
                foreach (var model in _models)
                {
                    double[] prediction = model.Item1.Estimate(sample);
                    model.Item1.PassTest(sample, prediction);
                    
                    vote += model.Item2 * (sample.ClassificationOutputs.Item2[0] == Trend.Positive ? 1 : -1);
                    voteBase += model.Item2;
                }

                sample.ClassificationOutputs.Item2[0] = vote > 0 ? Trend.Positive : Trend.Negative;
            }

            int actualPositive = samples.Count(o => o.ClassificationOutputs.Item1.All(p => p == Trend.Positive));
            int bothPositive = samples.Count(o => o.ClassificationOutputs.Item1.All(p => p == Trend.Positive) && o.ClassificationOutputs.Item2.All(p => p == Trend.Positive));
            int actualNegative = samples.Count(o => o.ClassificationOutputs.Item1.All(p => p == Trend.Negative));
            int bothNegative = samples.Count(o => o.ClassificationOutputs.Item1.All(p => p == Trend.Negative) && o.ClassificationOutputs.Item2.All(p => p == Trend.Negative));
            int predictedPositive = samples.Count(o => o.ClassificationOutputs.Item2.All(p => p == Trend.Positive));

            Accuracy = (double)samples.Count(o => o.ClassificationOutputs.Item1.All(p => p == Trend.Positive) && o.ClassificationOutputs.Item2.All(p => p == Trend.Positive)
                || o.ClassificationOutputs.Item1.All(p => p == Trend.Negative) && o.ClassificationOutputs.Item2.All(p => p == Trend.Negative)) / samples.Count;
            Sensitivity = (double)bothPositive / actualPositive;
            Specificity = (double)bothNegative / actualNegative;
            Precision = (double)bothPositive / predictedPositive;
            TopSecurityList = samples.Where(o => o.ClassificationOutputs.Item1.All(p => p == Trend.Positive) && o.ClassificationOutputs.Item2.All(p => p == Trend.Positive))
                .OrderByDescending(o => o.OriginalOutputs[0])
                .Take(TopNSecurity)
                .GroupBy(o => o.SecurityId)
                .Select(o => o.First())
                .ToList();
            
            return Accuracy.Value;
        }

        protected internal override double[] Estimate(DataTuple sample)
        {
            throw new NotImplementedException();
        }

        public IList<DataTuple> TopSecurityList
        {
            get; private set; 
        }

        public string ModelName
        {
            get { return "NN"; }
        }
    }
}
