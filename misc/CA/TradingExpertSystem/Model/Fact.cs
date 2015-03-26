using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;

namespace Model
{
    public class Fact
    {                
        private readonly Dictionary<Criterion, float> _dictionary = new Dictionary<Criterion, float>();

        public Fact(Country country)
        {
            Country = country;
        }

        public Country Country { get; private set; }

        public float this[Criterion criterion]
        {
            get { return _dictionary[criterion]; }
            set { _dictionary[criterion] = value; }
        }

        public override string ToString()
        {
            var buffer = new StringBuilder("Fact:");
            buffer.AppendLine();
            foreach (var item in _dictionary)
            {
                buffer.AppendFormat("\t{0}:{1:F3}", item.Key.ToString().Replace("XX", Country.ToString()).PadRight(20, ' '), item.Value);
                buffer.AppendLine();
            }

            return buffer.ToString();
        }

        public static Fact[] LoadFact(Indices indices)
        {
            var facts = new Fact[2];
            facts[0] = LoadFact(Country.SG, indices);
            facts[1] = LoadFact(Country.UK, indices);
            return facts;
        }

        private static Fact LoadFact(Country country, Indices indices)
        {
            var fact = new Fact(country);
            fact[Criterion.XXInterestRate] = Convert.ToSingle(indices.Row[country + "PRIME_weekly_z"]);
            fact[Criterion.USInterestRate] = Convert.ToSingle(indices.Row[country + "PRIME_weekly_z"]);

            fact[Criterion.XXInflationRate] = Convert.ToSingle(indices.Row[country + "INF_weekly_z"]);
            fact[Criterion.USInflationRate] = Convert.ToSingle(indices.Row[country + "INF_weekly_z"]);

            fact[Criterion.XXStockIndexMomentumMonthly] = Convert.ToSingle(indices.Row[country + "_StockIndex_monthly_momentum"]);
            fact[Criterion.USStockIndexMomentumMonthly] = Convert.ToSingle(indices.Row[country + "_StockIndex_monthly_momentum"]);

            fact[Criterion.USD2XXDMomentumMonthly] = Convert.ToSingle(indices.Row[country + "_D_monthly_momentum"]);
            var currency = DataContext.CurrencyMap[country];
            fact[Criterion.USD2XXDExchangeRateTrend] = Math.Sign(indices.GetFuturePredictedExchangeRate(currency) - indices.GetCurrentExchangeRate(currency));
                        
            return fact;
        }
    }
}