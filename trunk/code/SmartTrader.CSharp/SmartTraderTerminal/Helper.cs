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

        private static readonly Dictionary<string, string> _Models = new Dictionary<string, string>
        {
            { "AdaBoost", "Ada Boost" },
            { "NN", "Neural Network" },            
            { "RF", "Random Forest" },
            { "SVN", "Support Vector Machine" }
        };

        private static readonly int[] _Years = Enumerable.Range(2004, 11).ToArray();

        private static readonly int[] _Months = Enumerable.Range(1, 12).ToArray();

        public static string[] Sectors
        {
            get { return _Sectors; }
        }

        public static Dictionary<string, string> Models
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