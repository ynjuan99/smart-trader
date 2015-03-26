using System;
using System.Diagnostics;
using System.Linq;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using Model;
using Repository;

namespace UnitTest
{
    [TestClass]
    public class ModelTrialTest
    {
        [TestMethod]
        public void TestTrial1()
        {
            var data = FactorDataRepository.GetFactorData(33, "Information Technology", 2009, "PMOM20Advanced_Normalized");
            int partitionPortion = (int)(data.Count * 0.75);
            var trainingData = data.Take(partitionPortion).ToList();
            var testData = data.Skip(partitionPortion).ToList();
            var model = new RegressionModel();
            model.TrainingData = trainingData;
            model.TestData = testData;
            model.Train();
            Trace.WriteLine("Validation MSE: " + model.Test());
            Trace.WriteLine(model);
        }

        [TestMethod]
        public void TestTrial2()
        {
            var trainingData = FactorDataRepository.GetFactorData(33, "Information Technology", new DateTime(2009, 1, 1), new DateTime(2009, 11, 30), "PMOM20Advanced_Normalized");
            var testData = FactorDataRepository.GetFactorData(100, "Information Technology", new DateTime(2009, 12, 1), new DateTime(2009, 12, 31), "PMOM20Advanced_Normalized");
            var model = new RegressionModel();
            model.TrainingData = trainingData;
            model.TestData = testData;
            model.Train();
            Trace.WriteLine("Validation MSE: " + model.Test());
            Trace.WriteLine(model);
        }

        [TestMethod]
        public void TestTrial3()
        {
            var trainingData = FactorDataRepository.GetFactorData(33, "Information Technology", new DateTime(2009, 1, 1), new DateTime(2009, 11, 30), "PMOM20Advanced_Normalized");
            var testData = FactorDataRepository.GetFactorData(100, "Information Technology", new DateTime(2009, 12, 1), new DateTime(2009, 12, 31), "PMOM20Advanced_Normalized");
            var model = new RegressionModel();
            model.TrainingData = trainingData;
            model.TestData = testData;
            model.Train();
            Trace.WriteLine("Validation MSE: " + model.Test());
            //Trace.WriteLine(model);

            var tuner = new GeneticWeightTuner(model.WeightNumber, model);
            tuner.Evolve();
            Trace.WriteLine("Validation MSE After tuning: " + (-tuner.BestFitness));
        } 
    }
}
