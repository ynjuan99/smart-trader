using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Repository;

namespace Model
{
    public class CompositeClassificationModel : Model
    {
        private Tuple<ClassificationModel, double>[] _models;
        public CompositeClassificationModel(params Tuple<ClassificationModel, double>[] models)
        {
            _models = models;
        }

        protected override void TrainInternal(IList<DataTuple> samples)
        {
            throw new NotImplementedException();
        }

        protected override double TestInternal(IList<DataTuple> samples)
        {
            int passed = 0;
            foreach (var sample in samples)
            {
                double vote = 0;
                double voteBase = 0;
                for (int i = 0; i < _models.Length; i++)
                {
                    var model = _models[i];

                    double[] output = model.Item1.Estimate(sample);
                    model.Item1.PassTest(sample, output);
                    
                    vote += model.Item2 * sample.ClassificationOutputs.Item2[0];
                    voteBase += model.Item2;
                }

                sample.ClassificationOutputs.Item2[0] = vote / (_models.Length * voteBase) > 0.5 ? 1 : 0;
            }

            Accuracy = samples.Count(o => o.ClassificationOutputs.Item1[0] == o.ClassificationOutputs.Item2[0]) / samples.Count;
            int actualPositive = samples.Count(o => o.ClassificationOutputs.Item1.All(p => p == 1));
            int bothPositive = samples.Count(o => o.ClassificationOutputs.Item1.All(p => p == 1) && o.ClassificationOutputs.Item2.All(p => p == 1));
            int predictedPositive = samples.Count(o => o.ClassificationOutputs.Item2.All(p => p == 1));
            Precision = (double)bothPositive / predictedPositive;
            Recall = (double)bothPositive / actualPositive;

            return Accuracy.Value;
        }        

        public override double[] Estimate(DataTuple sample)
        {
            throw new NotImplementedException();
        }
    }
}
