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
            var data = FactorDataRepository.GetFactorData(2010, "Information Technology", "PriceRet20D");           
            int partitionPortion = (int)(data.Count * 0.75);
            var trainingData = data.Take(partitionPortion).ToList();
            var testData = data.Skip(partitionPortion).ToList();
            var model = new NeuralNetworkModel();
            model.Train(trainingData);
            Trace.WriteLine(model.Validate(testData));
            Trace.WriteLine(model);
            
            #region Result
            /*
             
             */
            #endregion
        }
    }
}
