using System;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.IO;
using System.Linq;

namespace Model
{
    public class DataContext
    {        
        #region Exposure

        public const int InputCount = 13;
        public const int OutputCount = 2;

        private static DataContext _instance;
        public static void CreateContext(string path)
        {
            _instance = new DataContext(path);
        }

        public static DataContext Instance
        {
            get
            {
                if (_instance == null) throw new InvalidOperationException("Must Create Context before use.");
                return _instance;
            }
        }
        #endregion

        #region Data

        private DataContext(string path)
        {
            var lines = File.ReadAllLines(path);
            int rowCount = lines.Length;
            var raw = new Indices[rowCount - 1];
            for (int i = 1; i < rowCount; i++)
            {
                var line = lines[i].Split(',');
                var date = DateTime.ParseExact(line[0], @"d-MMM-yy", null);
                var inputs = new double[InputCount];
                var outputs = new double[OutputCount];

                int k1 = 0, k2 = 0;
                for (int j = 1; j < line.Length; j++)
                {
                    var value = Convert.ToDouble(line[j]);

                    if (k1 < InputCount)
                    {
                        inputs[k1++] = value;
                    }
                    else
                    {
                        outputs[k2++] = value;
                    }
                }
                raw[i - 1] = new Indices(date, inputs, outputs);
            }

            var cutoff = new DateTime(1996, 4, 1);
            TrainingIndices = raw.Where(o => o.Date < cutoff).ToArray();
            TestingIndices = raw.Where(o => o.Date >= cutoff).ToArray();
        }
        
        #endregion

        public Indices[] TrainingIndices { get; private set; }
        public Indices[] TestingIndices { get; private set; }              
    }
}