using System;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.IO;
using System.Linq;

namespace OptimizerModel
{
    public class DataContext
    {
        #region Exposure

        public const int TimingFields = 2;
        public const int PlacementFields = 3;
        public const int FirstRowIndex = 2;
        public static int FieldCount
        {
            get { return Websites.Count * PlacementFields; }
        }

        public static ReadOnlyCollection<Website> Websites = new ReadOnlyCollection<Website>(new List<Website>
            {
                new Website(1, 15d),
                new Website(2, 10d),
                new Website(3, 8d),
                new Website(4, 8d),
                new Website(5, 12d)
            });
        public static ReadOnlyCollection<Ad> Ads = new ReadOnlyCollection<Ad>(new List<Ad>
            {
                new Ad(1),
                new Ad(2),
                new Ad(3),
                new Ad(4),
                new Ad(5),
                new Ad(6)
            });

        public static bool IsValidAssignment(AdAssignment candidate)
        {
            if (candidate.TotalCost > 300) return false;
            return true;
        }
      
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
            int fieldCount = Websites.Count * PlacementFields;
            var lines = File.ReadAllLines(path);
            int rowCount = lines.Length - FirstRowIndex;
            AdAssignments = new AdAssignment[rowCount];
            for (int i = 0; i < rowCount; i++)
            {
                var line = lines[i + FirstRowIndex].Split(',');
                var placemetns = new AdPlacement[Websites.Count];
                for (int j = 0; j < Websites.Count; j++)
                {
                    var placement = new AdPlacement
                    {
                        Website = Websites[j],
                        StartTime = Convert.ToDouble(line[j * PlacementFields]),
                        EndTime = Convert.ToDouble(line[j * PlacementFields + 1]),
                        Ad = Ads[Convert.ToInt32(line[j * PlacementFields + 2]) - 1]
                    };
                    placemetns[j] = placement;
                }

                double userClicks = Convert.ToDouble(line[fieldCount]);
                var assignment = new AdAssignment(placemetns) { UserClicks = userClicks };
                AdAssignments[i] = assignment;
            }            
        }
        
        public AdAssignment[] AdAssignments { get; private set; }
        
        #endregion

        #region Helper

        public static double Normalize(double value, double min, double max, double spectrum = 0.85)
        {
            double factor = Math.Abs(spectrum) * 2 / (max - min);
            return (value - min) * factor - Math.Abs(spectrum);
        }

        public static double Denormalize(double value, double min, double max, double spectrum = 0.85)
        {
            double factor = Math.Abs(spectrum) * 2 / (max - min);
            return (value + Math.Abs(spectrum)) / factor + min;
        }    
        #endregion                
    }
}