using System;
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

        public static DataContext Instance
        {
            get
            {
                if (_instance == null) throw new InvalidOperationException("Must Create Context before use.");
                return _instance;
            }
        }

        public static void CreateContext(string path)
        {
            _instance = new DataContext(path);
        }

        #endregion

        #region Data

        private DataContext(string path)
        {
            string[] lines = File.ReadAllLines(path);
            int rowCount = lines.Length;
            var raw = new Indices[rowCount - 1];
            Indices previous = null;
            for (int i = 1; i < rowCount; i++)
            {
                string[] line = lines[i].Split(',');
                DateTime date = DateTime.ParseExact(line[0], @"d-MMM-yy", null);
                var inputs = new double[InputCount];
                var outputs = new double[OutputCount];
                int k1 = 0, k2 = 0;
                for (int j = 1; j < line.Length; j++)
                {
                    double value = Convert.ToDouble(line[j]);

                    if (k1 < InputCount)
                    {
                        inputs[k1++] = value;
                    }
                    else
                    {
                        outputs[k2++] = value;
                    }
                }

                var current = new Indices(date, inputs, outputs);
                if (previous != null)
                {
                    previous.Next = current;
                }
                previous = current;
                raw[i - 1] = current;
            }

            var cutoff = new DateTime(1996, 4, 1);
            TrainingIndices = raw.Where(o => o.Date < cutoff && o.Next != null).ToArray();
            TestingIndices = raw.Where(o => o.Date >= cutoff && o.Next != null).ToArray();
        }

        #endregion

        public Indices[] TrainingIndices { get; private set; }
        public Indices[] TestingIndices { get; private set; }
    }
}