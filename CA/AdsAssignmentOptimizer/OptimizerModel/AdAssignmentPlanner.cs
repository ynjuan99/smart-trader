using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace OptimizerModel
{
    public class AdAssignmentPlanner
    {
        public static string PlanViaNN(string path)
        {
            DataContext.CreateContext(path);
            var estimator = new NeuroEstimator();
            estimator.Train(DataContext.Instance.AdAssignments);
            var presenter = new GeneticPresenter(DataContext.Websites.Count * DataContext.TimingFields, DataContext.Ads.Count, 10000, estimator);
            presenter.Evolve();
            var best = presenter.BestAssignment;

            return DisplayOuput(best, estimator);
        }

        public static string PlanViaGA(string path)
        {
            DataContext.CreateContext(path);
            var estimator = new GeneticEstimator();
            estimator.Train(DataContext.Instance.AdAssignments);
            var presenter = new GeneticPresenter(DataContext.Websites.Count * DataContext.TimingFields, DataContext.Ads.Count, 10000, estimator);
            presenter.Evolve();
            var best = presenter.BestAssignment;

            return DisplayOuput(best, estimator);
        }

        private static string DisplayOuput(AdAssignment best, IEstimator estimator)
        {
            return string.Format(@"
================================================================================================
{0}
------------------------------------------------------------------------------------------------
{1}
================================================================================================
", best, estimator);
        }
    }
}
