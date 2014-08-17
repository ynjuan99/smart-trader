using System;
using System.Diagnostics;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using Model;

namespace UnitTest
{
    [TestClass]
    public class ModelTrial
    {
        [TestMethod]
        public void TestNeuralEstimator()
        {
            var path = @"D:\SmartTrader\SVN\CA\TradingExpertSystem\Data\FinancialData_normalized.csv";
            DataContext.CreateContext(path);
            var model = new NeuroEstimator();
            model.Train(DataContext.Instance.TrainingIndices);
           
            Trace.WriteLine("Validation MSE: " + model.Test(DataContext.Instance.TestingIndices));
            Trace.WriteLine(model);
        }
    }
}
