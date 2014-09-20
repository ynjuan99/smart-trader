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
            const string connStr = @"Initial Catalog=Dummy;Data Source=localhost;Integrated Security=SSPI;";
            DataContext.CreateContext(connStr);
            var model = new NeuroEstimator();
            model.Train(DataContext.Instance.TrainingIndices);
           
            Trace.WriteLine("Validation MSE: " + model.Test(DataContext.Instance.TestingIndices));
            Trace.WriteLine(model);
        }
    }
}
