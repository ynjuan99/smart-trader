using System;
using System.Data;
using System.Linq;

namespace Model
{
    public class Indices
    {
        private readonly DataRow _row;
        private readonly double _ukpMean, _ukpStdev, _sgdMean, _sgdStdev;

        public Indices(DataRow row)
        {
            _row = row;
            var columns = _row.Table.Columns.Cast<DataColumn>().Where(o => o.ColumnName.EndsWith("_z", StringComparison.OrdinalIgnoreCase)).ToArray();
            Inputs = new double[columns.Length - 2];
            FutureOutputs = new double[2];
            CurrentOutputs = new double[2];
            int i = 0;
            foreach (var column in columns)
            {
                var value = Convert.ToDouble(row[column.ColumnName]);
                if (column.ColumnName.Equals("SG_D_forward_week_z"))
                {
                    FutureOutputs[0] = value;
                }
                else if (column.ColumnName.Equals("P_D_forward_week_z"))
                {
                    FutureOutputs[1] = value;
                }
                else
                {
                    Inputs[i++] = value;
                }
            }
            CurrentOutputs[0] = Convert.ToDouble(row["SG_D"]);
            CurrentOutputs[1] = Convert.ToDouble(row["P_D"]);

            _sgdMean = Convert.ToDouble(row["SG_D_mean"]);
            _sgdStdev = Convert.ToDouble(row["SG_D_stdev"]);
            _ukpMean = Convert.ToDouble(row["P_D_mean"]);
            _ukpStdev = Convert.ToDouble(row["P_D_stdev"]);
        }

        public double[] Inputs { get; private set; }
        public double[] CurrentOutputs { get; private set; }
        //Z-scored
        public double[] FutureOutputs { get; set; }

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

        public double GetFutureExchangeRate(Currency currency)
        {
            switch (currency)
            {
                case Currency.SGD:
                    return FutureOutputs[0] * _sgdStdev + _sgdMean;
                case Currency.UKP:
                    return FutureOutputs[1] * _ukpStdev + _ukpMean;
                case Currency.USD:
                    return 1d;
                default:
                    throw new ArgumentOutOfRangeException("currency");
            }
        }

        public double GetCurrentEffectiveInterestRate(Currency currency)
        {
            switch (currency)
            {
                case Currency.SGD:
                    return Convert.ToDouble(_row["SGPRIME_weekly"]) - Convert.ToDouble(_row["SGINF_weekly"]);
                case Currency.UKP:
                    return Convert.ToDouble(_row["UKPRIME_weekly"]) - Convert.ToDouble(_row["UKINF_weekly"]);
                case Currency.USD:
                    return Convert.ToDouble(_row["USPRIME_weekly"]) - Convert.ToDouble(_row["USINF_weekly"]);
                default:
                    throw new ArgumentOutOfRangeException("currency");
            }
        }
    }
}