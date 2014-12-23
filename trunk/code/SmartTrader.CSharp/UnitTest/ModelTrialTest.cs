using System;
using System.Collections.Generic;
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
        //const string sector = "Financials";
        string sector = "Consumer Discretionary";
        //string target = "PriceRetFF20D_Absolute";
        string target = "PriceRetFF20D";
        const int year = 2013;
       
        [TestMethod]
        public void TestNNRegression()
        {
            target = "PriceRetFF20D_Absolute";
            var trainingData = FactorDataRepository.GetFactorData(100, sector, new DateTime(year, 1, 1), new DateTime(year, 11, 30), target);
            var testData = FactorDataRepository.GetFactorData(100, sector, new DateTime(year, 12, 1), new DateTime(year, 12, 31), target);
            var model = new RegressionModel();
            model.Train(trainingData);
            Trace.WriteLine("Validation MSE: " + model.Test(testData));
            Trace.WriteLine("Statistics: " + model.Statistics);
            Trace.WriteLine(model);
        }

        [TestMethod]
        public void TestNNClassification()
        {
            
            var trainingData = FactorDataRepository.GetFactorData(100, sector, new DateTime(year, 11, 1), new DateTime(year, 11, 30), target);
            var testData = FactorDataRepository.GetFactorData(100, sector, new DateTime(year, 12, 1), new DateTime(year, 12, 31), target);
            var model = new ClassificationModelWithClassOutput();
            model.ClassificationBenchmark = FactorDataRepository.GetClassificationBenchmark(trainingData);            
            model.Train(trainingData);
            Trace.WriteLine(string.Format("Validation Accuracy: {0:P}", model.Test(testData)));
            Trace.WriteLine("Statistics: " + model.Statistics);
            Trace.WriteLine(model);
        }

        [TestMethod]
        public void TestWindowedNNClassification()
        {
            var trainingData1 = FactorDataRepository.GetFactorData(100, sector, new DateTime(year, 1, 1), new DateTime(year, 11, 30), target);
            var trainingData2 = FactorDataRepository.GetFactorData(100, sector, new DateTime(year, 9, 1), new DateTime(year, 11, 30), target);
            var trainingData3 = FactorDataRepository.GetFactorData(100, sector, new DateTime(year, 11, 1), new DateTime(year, 11, 30), target);
            var testData = FactorDataRepository.GetFactorData(100, sector, new DateTime(year, 12, 1), new DateTime(year, 12, 31), target);

            var model = new CompositeClassificationModel(
                new Tuple<ClassificationModel, double>(CreateClassificationModel(trainingData1), 0.2),
                new Tuple<ClassificationModel, double>(CreateClassificationModel(trainingData2), 0.3),
                new Tuple<ClassificationModel, double>(CreateClassificationModel(trainingData3), 0.5)
                );   
         
            Trace.WriteLine(string.Format("Validation Accuracy: {0:P}", model.Test(testData)));
            Trace.WriteLine("Statistics: " + model.Statistics);
        }

        private ClassificationModelWithClassOutput CreateClassificationModel(IList<DataTuple> trainingData)
        {
            var model = new ClassificationModelWithClassOutput();
            model.ClassificationBenchmark = FactorDataRepository.GetClassificationBenchmark(trainingData);
            model.Train(trainingData);

            return model;
        }

        [TestMethod]
        public void TestPnnClassification()
        {
            try
            {                
                var trainingData = FactorDataRepository.GetFactorData(10, sector, new DateTime(year, 1, 1), new DateTime(year, 11, 30), target);
                var testData = FactorDataRepository.GetFactorData(20, sector, new DateTime(year, 12, 1), new DateTime(year, 12, 31), target);
                var model = new PnnModel();
                model.Train(trainingData);
                Trace.WriteLine("Validation Accuracy: " + model.Test(testData));
                Trace.WriteLine("Statistics: " + model.Statistics);
                Trace.WriteLine(model);                
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }
    }
}
