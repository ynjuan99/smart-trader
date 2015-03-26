using System;
using System.Data;
using System.Linq;

namespace Model
{
    public class Indices
    {
        internal readonly DataRow Row;
        private readonly double _ukpMean, _ukpStdev, _sgdMean, _sgdStdev;

        public Indices(DataRow row)
        {
            Row = row;
            var columns = Row.Table.Columns.Cast<DataColumn>().Where(o => o.ColumnName.EndsWith("_z", StringComparison.OrdinalIgnoreCase)).ToArray();
            Inputs = new double[columns.Length - 2];
            FutureActualOutputs = new double[2];
            CurrentOutputs = new double[2];
            int i = 0;
            foreach (var column in columns)
            {
                var value = Convert.ToDouble(row[column.ColumnName]);
                if (column.ColumnName.Equals("SG_D_forward_week_z"))
                {
                    FutureActualOutputs[0] = value;
                }
                else if (column.ColumnName.Equals("UK_D_forward_week_z"))
                {
                    FutureActualOutputs[1] = value;
                }
                else
                {
                    Inputs[i++] = value;
                }
            }
            CurrentOutputs[0] = Convert.ToDouble(row["SG_D"]);
            CurrentOutputs[1] = Convert.ToDouble(row["UK_D"]);

            _sgdMean = Convert.ToDouble(row["SG_D_mean"]);
            _sgdStdev = Convert.ToDouble(row["SG_D_stdev"]);
            _ukpMean = Convert.ToDouble(row["UK_D_mean"]);
            _ukpStdev = Convert.ToDouble(row["UK_D_stdev"]);
            Date = row.Field<DateTime>("date");
        }

        public DateTime Date { get; set; }
        public double[] Inputs { get; private set; }
        public double[] CurrentOutputs { get; private set; }
        //Z-scored
        public double[] FutureActualOutputs { get; private set; }
        public double[] FuturePredictedOutputs { get; set; }

        //with reference to USD        
        public double GetCurrentExchangeRate(Currency currency)
        {
            switch (currency)
            {
                case Currency.SGD:
                    return CurrentOutputs[0];
                case Currency.UKP:
                    return CurrentOutputs[1];
                case Currency.USD:
                    return 1d;
                default:
                    throw new ArgumentOutOfRangeException("currency");
            }
        }

        public double GetFutureActualExchangeRate(Currency currency)
        {
            switch (currency)
            {
                case Currency.SGD:
                    return FutureActualOutputs[0] * _sgdStdev + _sgdMean;
                case Currency.UKP:
                    return FutureActualOutputs[1] * _ukpStdev + _ukpMean;
                case Currency.USD:
                    return 1d;
                default:
                    throw new ArgumentOutOfRangeException("currency");
            }
        }

        public double GetFuturePredictedExchangeRate(Currency currency)
        {
            if (FuturePredictedOutputs == null || FuturePredictedOutputs.Length == 0)
            {
                throw new InvalidOperationException("Have not predicted yet");
            }

            switch (currency)
            {
                case Currency.SGD:
                    return FuturePredictedOutputs[0] * _sgdStdev + _sgdMean;
                case Currency.UKP:
                    return FuturePredictedOutputs[1] * _ukpStdev + _ukpMean;
                case Currency.USD:
                    return 1d;
                default:
                    throw new ArgumentOutOfRangeException("currency");
            }
        }

        public double GetCurrentInterestRate(Currency currency)
        {
            switch (currency)
            {
                case Currency.SGD:
                    return Convert.ToDouble(Row["SGPRIME_weekly"]);
                case Currency.UKP:
                    return Convert.ToDouble(Row["UKPRIME_weekly"]);
                case Currency.USD:
                    return Convert.ToDouble(Row["USPRIME_weekly"]);
                default:
                    throw new ArgumentOutOfRangeException("currency");
            }
        }
    }
}