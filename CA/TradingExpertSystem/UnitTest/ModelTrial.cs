using System;
using System.Diagnostics;
using System.Linq;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using Model;

namespace UnitTest
{
    [TestClass]
    public class ModelTrial
    {
        public ModelTrial()
        {
            const string connStr = @"Initial Catalog=Dummy;Data Source=localhost;Integrated Security=SSPI;";
            DataContext.CreateContext(connStr);
        }

        [TestMethod]
        public void TestNeuralEstimator()
        {
            try
            {
                var model = new NeuroPredictor();
                model.Train(DataContext.Instance.TrainingIndices);

                Trace.WriteLine("Validation MSE: " + model.Test(DataContext.Instance.TestingIndices));
                Trace.WriteLine(model);
            }
            catch (Exception)
            {
                throw;
            }
            
        }

        [TestMethod]
        public void TestFuzzyTrader()
        {
            try
            {
                //Test data
                var testIndices = DataContext.Instance.TestingIndices.OrderBy(o => o.Date).ToArray();

                //Build predictor
                var predictor = new NeuroPredictor();
                predictor.Train(DataContext.Instance.TrainingIndices);
                var mse = predictor.Test(DataContext.Instance.TestingIndices);
                //Trace.WriteLine("Validation MSE: " + mse);
                //Trace.WriteLine(model);

                //Open account
                var account = new Account(10000, 10000, 10000, 
                    testIndices[0].GetCurrentExchangeRate(Currency.SGD), 
                    testIndices[0].GetCurrentExchangeRate(Currency.UKP));

                //Build trader
                var trader = new FuzzyTrader(DataContext.Instance.Rules);

                //Start trading
                //Initial balance
                Trace.WriteLine(String.Format("{0:yyyy-MM-dd}: {1}", testIndices[0].Date, account));
                for (int i = 1; i < testIndices.Length; i++)
                {
                    var indices = testIndices[i];
                    var proposals = trader.Propose(indices);
                    if (proposals.Count > 0)
                    {
                        account.Transact(indices, proposals);                        
                    }

                    //New balance
                    Trace.WriteLine(String.Format("{0:yyyy-MM-dd}: {1}", indices.Date, account));
                }                
            }
            catch (Exception)
            {
                throw;
            }
           
        }
    }
}
