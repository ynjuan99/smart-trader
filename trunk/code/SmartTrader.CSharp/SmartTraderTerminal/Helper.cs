using System;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using System.Windows.Data;

namespace SmartTraderTerminal
{
    public static class ConstantSource
    {
        private static readonly string[] _Sectors =
        {
            "Consumer Discretionary",
            "Consumer Staples",
            "Energy",
            "Financials",
            "Health Care",
            "Industrials",
            "Information Technology",
            "Materials",
            "Telecommunication Services",
            "Utilities"
        };

        private static readonly Dictionary<string, Tuple<string, int>> _Models = new Dictionary<string, Tuple<string, int>>
        {
            { "AdaBoost", new Tuple<string, int>("Ada Boost", 1) },
            { "NN", new Tuple<string, int>("Neural Network", 2) },            
            { "RF", new Tuple<string, int>("Random Forest", 3) },
            { "SVM", new Tuple<string, int>("Support Vector Machine", 4) },
            { "ClusteredAdaBoost", new Tuple<string, int>("Clustered Ada Boost", 5) },          
            { "ClusteredRF", new Tuple<string, int>("Clustered Random Forest", 6) },
            { "ClusteredSVM", new Tuple<string, int>("Clustered Support Vector Machine", 7) }
        };

        private static readonly int[] _Years = Enumerable.Range(2004, 11).Reverse().ToArray();

        private static readonly int[] _Months = Enumerable.Range(1, 12).ToArray();

        public static string[] Sectors
        {
            get { return _Sectors; }
        }

        public static Dictionary<string, Tuple<string, int>> Models
        {
            get { return _Models; }
        }

        public static int[] Years
        {
            get { return _Years; }
        }

        public static int[] Months
        {
            get { return _Months; }
        }
    }

    public class WidthConverter : IValueConverter
    {
        public object Convert(object value, Type targetType, object parameter, CultureInfo culture)
        {
            double percentage = System.Convert.ToDouble(parameter);
            double width = (double)value;
            return width * percentage;
        }

        public object ConvertBack(object value, Type targetType, object parameter, CultureInfo culture)
        {
            throw new NotImplementedException();
        }
    }
}