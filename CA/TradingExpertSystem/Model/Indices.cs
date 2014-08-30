using System;

namespace Model
{
    public class Indices
    {
        private readonly DateTime _date;
        private readonly double[] _inputs;
        private readonly double[] _outputs;

        public Indices(DateTime date, double[] inputs, double[] outputs)
        {
            _date = date;
            _inputs = inputs;
            _outputs = outputs;
        }

        public DateTime Date
        {
            get { return _date; }
        }

        public double[] Inputs
        {
            get { return _inputs; }
        }

        public double[] Outputs
        {
            get { return _outputs; }
        }

        public Indices Next { get; set; }

        public double GetExchangeRateToUSD(Currency currency)
        {
            switch (currency)
            {
                case Currency.SGD:
                    return _outputs[0];
                case Currency.UKP:
                    return _outputs[1];
                case Currency.USD:
                    return 1d;
                default:
                    throw new ArgumentOutOfRangeException("currency");
            }
        }

        public double GetDiscountedInterestRate(Currency currency)
        {
            switch (currency)
            {
                case Currency.SGD:
                    return _inputs[7] - _inputs[10];
                case Currency.UKP:
                    return _inputs[8] - _inputs[11];
                case Currency.USD:
                    return _inputs[9] - _inputs[12];
                default:
                    throw new ArgumentOutOfRangeException("currency");
            }
        }
    }
}