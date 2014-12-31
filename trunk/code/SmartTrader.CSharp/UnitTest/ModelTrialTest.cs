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
        private readonly int _month;
        private readonly DateTime _testDate;
        private readonly DateTime _defaultTrainingStartDay;
        private readonly DateTime _defaultTrainingEndDay;
        
        public ModelTrialTest() : this("Financials", 2013, 12)           
        {            
        }

        public ModelTrialTest(string sector, int year, int month)
        {
            _sector = sector;
            _year = year;
            _month = month;
            _testDate = FactorDataRepository.GetTargetDate(year, month);
            _defaultTrainingStartDay = GetLastNMonthFirstDay(_testDate, 11);
            _defaultTrainingEndDay = GetLastNMonthLastDay(_testDate, 1);
        }
        
        [TestMethod]
        public void TestRegression()
        {
            var _defaultTrainingEndDay = GetLastNMonthLastDay(_testDate, 1);
            var trainingData = FactorDataRepository.GetFactorData(100, _sector, _defaultTrainingStartDay, _defaultTrainingEndDay.AddMonths(-1));
            var testData = FactorDataRepository.GetFactorData(100, _sector, _testDate, _testDate);
            var model = new RegressionModel();
            model.Train(trainingData);
            Trace.WriteLine("Validation MSE: " + model.Test(testData));
            Trace.WriteLine("Statistics: " + model.Statistics);
            //Trace.WriteLine(model);
        }

        [TestMethod]
        public void TestClassificationWithUnclassifiedOutput()
        {
            var trainingData = FactorDataRepository.GetFactorData(100, _sector, _defaultTrainingStartDay, _defaultTrainingEndDay);
            var testData = FactorDataRepository.GetFactorData(100, _sector, _testDate, _testDate);
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
            var trainingData = FactorDataRepository.GetFactorData(100, _sector, 
                _defaultTrainingStartDay, _defaultTrainingEndDay);
            var testData = FactorDataRepository.GetFactorData(100, _sector, _testDate, _testDate);
            var model = new ClassificationModelWithClassOutput
            {
                ClassificationBenchmark = new[]
                {
                    FactorDataRepository.GetClassificationBenchmark(trainingData, o => o.Outputs[0], o => o.Outputs[0])
                }
            };

            model.Train(trainingData);
            model.Test(testData);
            Trace.WriteLine("Statistics: " + model.Statistics);
            //Trace.WriteLine(model);
        }

        [TestMethod]
        public void TestWindowedClassificationWithClassifiedOutput2()
        {
            TestWindowedClassificationWithClassifiedOutput();
        }
        
        public ResultTuple TestWindowedClassificationWithClassifiedOutput()
        {
            var endDay = _defaultTrainingEndDay;
            var trainingData1 = FactorDataRepository.GetFactorData(100, _sector, GetLastNMonthFirstDay(_testDate, 11), endDay);
            var trainingData2 = FactorDataRepository.GetFactorData(100, _sector, GetLastNMonthFirstDay(_testDate, 6), endDay);
            var trainingData3 = FactorDataRepository.GetFactorData(100, _sector, GetLastNMonthFirstDay(_testDate, 3), endDay);
            var trainingData4 = FactorDataRepository.GetFactorData(100, _sector, GetLastNMonthFirstDay(_testDate, 1), endDay);
            var testData = FactorDataRepository.GetFactorData(100, _sector, _testDate, _testDate);

            var model = new CompositeClassificationModel(
                new Tuple<ClassificationModel, double>(CreateClassificationModel(trainingData1), 0.7),
                new Tuple<ClassificationModel, double>(CreateClassificationModel(trainingData2), 0.3),
                new Tuple<ClassificationModel, double>(CreateClassificationModel(trainingData3), 0.2),
                new Tuple<ClassificationModel, double>(CreateClassificationModel(trainingData4), 0.1)
                );   
         
            model.Test(testData);
            Trace.WriteLine("Statistics: " + model.Statistics);

            return GetResultTuple(model, _year, _month, _sector);
        }

        [TestMethod]
        public void TestPnnClassification()
        {
            try
            {
                var trainingData = FactorDataRepository.GetFactorData(10, _sector, _defaultTrainingStartDay, _defaultTrainingEndDay);
                var testData = FactorDataRepository.GetFactorData(20, _sector, _testDate, _testDate);
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

        #region Helper
        private static ClassificationModelWithClassOutput CreateClassificationModel(IList<DataTuple> trainingData)
        {
            var model = new ClassificationModelWithClassOutput();
            model.ClassificationBenchmark = new[] { FactorDataRepository.GetClassificationBenchmark(trainingData, o => o.Outputs[0], o => o.Outputs[0]) };

            model.Train(trainingData);
            return model;
        }

        private static ResultTuple GetResultTuple(IClassificationModel model, int year, int month, string sector)
        {
            var result = new ResultTuple();
            result.Model = model.GetType().Name;
            result.ForYear = year;
            result.ForMonth = month;
            result.Sector = sector;
            result.Accuracy = model.Accuracy;
            result.Sensitivity = model.Sensitivity;
            result.Specificity = model.Specificity;
            result.Precision = model.Precision;
            result.TopSecurityList = FactorDataRepository.GetSecurityList(model.TopSecurityList.Select(o => o.SecurityId).ToArray());

            return result;
        }

        private DateTime GetLastNMonthFirstDay(DateTime targetDate, int n)
        {
            return new DateTime(targetDate.Year, targetDate.Month, 1).AddMonths(-n);
        }
        private DateTime GetLastNMonthLastDay(DateTime targetDate, int n)
        {
            return new DateTime(targetDate.Year, targetDate.Month, 1).AddMonths(-n + 1).AddDays(-1);
        }
        #endregion
    }
}
