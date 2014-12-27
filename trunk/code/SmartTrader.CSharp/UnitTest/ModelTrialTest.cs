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
        private readonly string _sector;
        private readonly int _year;
        private readonly int _testMonth = 12;
        private readonly int _testStartDay = 31;
        private readonly int _testEndDay = 31;

        public ModelTrialTest() : this("Financials", 2013)           
        {            
        }

        public ModelTrialTest(string sector, int year)
        {
            _sector = sector;
            _year = year;
        }
        
        [TestMethod]
        public void TestRegression()
        {
            var trainingData = FactorDataRepository.GetFactorData(100, _sector, new DateTime(_year, 1, 1), new DateTime(_year, 11, 30));
            var testData = FactorDataRepository.GetFactorData(100, _sector, new DateTime(_year, _testMonth, _testStartDay), new DateTime(_year, _testMonth, _testEndDay));
            var model = new RegressionModel();
            model.Train(trainingData);
            Trace.WriteLine("Validation MSE: " + model.Test(testData));
            Trace.WriteLine("Statistics: " + model.Statistics);
            //Trace.WriteLine(model);
        }

        [TestMethod]
        public void TestClassificationWithUnclassifiedOutput()
        {
            var trainingData = FactorDataRepository.GetFactorData(100, _sector, new DateTime(_year, 1, 1), new DateTime(_year, 11, 30));
            var testData = FactorDataRepository.GetFactorData(100, _sector, new DateTime(_year, _testMonth, _testStartDay), new DateTime(_year, _testMonth, _testEndDay));
            var model = new ClassificationModel();
            model.ClassificationBenchmark = new[] { FactorDataRepository.GetClassificationBenchmark(trainingData, o => o.Outputs[0], o => o.Outputs[0]) };
            model.Train(trainingData);
            model.Test(testData);
            Trace.WriteLine("Statistics: " + model.Statistics);
            //Trace.WriteLine(model);
        }

        [TestMethod]
        public void TestClassificationWithClassifiedOutput()
        {            
            var trainingData = FactorDataRepository.GetFactorData(100, _sector, new DateTime(_year, 1, 1), new DateTime(_year, 11, 30));
            var testData = FactorDataRepository.GetFactorData(100, _sector, new DateTime(_year, _testMonth, _testStartDay), new DateTime(_year, _testMonth, _testEndDay));
            var model = new ClassificationModelWithClassOutput();
            model.ClassificationBenchmark = new [] {FactorDataRepository.GetClassificationBenchmark(trainingData, o => o.Outputs[0], o => o.Outputs[0])};            
            model.Train(trainingData);
            model.Test(testData);
            Trace.WriteLine("Statistics: " + model.Statistics);
            //Trace.WriteLine(model);
        }

        [TestMethod]
        public void TestWindowedClassificationWithClassifiedOutput()
        {
            var trainingData1 = FactorDataRepository.GetFactorData(100, _sector, new DateTime(_year, 1, 1), new DateTime(_year, 11, 30));
            var trainingData2 = FactorDataRepository.GetFactorData(100, _sector, new DateTime(_year, 6, 1), new DateTime(_year, 11, 30));
            var trainingData3 = FactorDataRepository.GetFactorData(100, _sector, new DateTime(_year, 9, 1), new DateTime(_year, 11, 30));
            var trainingData4 = FactorDataRepository.GetFactorData(100, _sector, new DateTime(_year, 11, 1), new DateTime(_year, 11, 30));
            var testData = FactorDataRepository.GetFactorData(100, _sector, new DateTime(_year, _testMonth, _testStartDay), new DateTime(_year, _testMonth, _testEndDay));

            var model = new CompositeClassificationModel(
                new Tuple<ClassificationModel, double>(CreateClassificationModel(trainingData1), 7),
                new Tuple<ClassificationModel, double>(CreateClassificationModel(trainingData2), 3),
                new Tuple<ClassificationModel, double>(CreateClassificationModel(trainingData3), 2),
                new Tuple<ClassificationModel, double>(CreateClassificationModel(trainingData4), 1)
                );   
         
            model.Test(testData);
            Trace.WriteLine("Statistics: " + model.Statistics);
        }

        private ClassificationModelWithClassOutput CreateClassificationModel(IList<DataTuple> trainingData)
        {
            var model = new ClassificationModelWithClassOutput();
            model.ClassificationBenchmark = new [] {FactorDataRepository.GetClassificationBenchmark(trainingData, o => o.Outputs[0], o => o.Outputs[0])};
            
            model.Train(trainingData);
            return model;
        }

        [TestMethod]
        public void TestPnnClassification()
        {
            try
            {                
                var trainingData = FactorDataRepository.GetFactorData(10, _sector, new DateTime(_year, 1, 1), new DateTime(_year, 11, 30));
                var testData = FactorDataRepository.GetFactorData(20, _sector, new DateTime(_year, _testMonth, _testStartDay), new DateTime(_year, _testMonth, _testEndDay));
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
