using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using AForge.Fuzzy;

namespace Model
{
    public class FuzzyTrader
    {
        private readonly InferenceSystem _engine;
        public FuzzyTrader(Rule[] rules)
        {
            var rulebase = new Database();
            foreach (var item in GetInterestRateSet()) rulebase.AddVariable(item);
            foreach (var item in GetInflationRateSet()) rulebase.AddVariable(item);
            foreach (var item in GetStockIndexMomentumMonthlySet()) rulebase.AddVariable(item);
            foreach (var item in GetExchangeRateTrendSet()) rulebase.AddVariable(item);
            rulebase.AddVariable(GetUSD2SGDExchangeMomentumMonthlySet());
            rulebase.AddVariable(GetUSD2UKPExchangeMomentumMonthlySet());
            rulebase.AddVariable(GetTradeStrategySet());
            
            _engine = new InferenceSystem(rulebase, new CentroidDefuzzifier(1000));
            for (int i = 0; i < rules.Length; i++)
            {
                _engine.NewRule(String.Format("Rule-{0:D3}", i), rules[i].ToString());
            } 
            
        }       
        
        public List<Transaction> Propose(Indices indices)
        {
            var transactions = new List<Transaction>();
            var facts = Fact.LoadFact(indices);
            foreach (var fact in facts)
            {
                var country = fact.Country;
                foreach (var item in Enum.GetValues(typeof(Criterion)))
                {
                    var criterion = (Criterion)item;
                    _engine.SetInput(criterion.ToString().Replace("XX", country.ToString()), fact[criterion]);
                }

                float amount;
                try
                {
                    amount = _engine.Evaluate("TradeStrategy");
                }
                catch (Exception ex)
                {
                    if (!ex.Message.Contains("All memberships are zero."))
                    {
                        Trace.TraceError(ex.Message);
                    }
                    amount = 0;
                }
                
                float absAmount = Math.Abs(amount);
                if (absAmount >= 5)
                {                    
                    var currency = DataContext.CurrencyMap[country];
                    if (amount > 0) //buy USD
                    {
                        var transaction = new Transaction(currency, Currency.USD, absAmount);
                        transactions.Add(transaction);
                    }
                    else //sell USD
                    {
                        var transaction = new Transaction(Currency.USD, currency, absAmount);
                        transactions.Add(transaction);
                    }
                }
            }

            return transactions;
        }

        #region Variable

        private readonly string[] _countries = Enum.GetNames(typeof(Country));
        //--PRIME_weekly_z
        private LinguisticVariable[] GetInterestRateSet()
        {
            var set = new[]
            {
                new FuzzySet("Low", new TrapezoidalFunction(-0.9650211f, -0.4349310f, TrapezoidalFunction.EdgeType.Right)),
                new FuzzySet("Medium", new TrapezoidalFunction(-0.9650211f, -0.4349310f, 0.3181210f, 0.6023946f)),
                new FuzzySet("High", new TrapezoidalFunction(0.3181210f, 0.6023946f, TrapezoidalFunction.EdgeType.Left))
            };

            var variables = new LinguisticVariable[3];
            for (int i = 0; i < variables.Length; i++)
            {
                var country = _countries[i];
                variables[i] = new LinguisticVariable(country + "InterestRate", -1.6292685f, 2.5772774f);
                foreach (var item in set) variables[i].AddLabel(item);
            }

            return variables;
        }

        //--_StockIndex_monthly_momentum
        private LinguisticVariable[] GetStockIndexMomentumMonthlySet()
        {
            var set = new[]
            {
                new FuzzySet("Negative", new TrapezoidalFunction(-0.6582872f, -0.1314542f, TrapezoidalFunction.EdgeType.Right)),
                new FuzzySet("Neutral", new TrapezoidalFunction(-0.6582872f, -0.1314542f, 0.2154543f, 0.7080084f)),
                new FuzzySet("Positive", new TrapezoidalFunction(0.2154543f, 0.7080084f, TrapezoidalFunction.EdgeType.Left))
            };

            var variables = new LinguisticVariable[3];
            for (int i = 0; i < variables.Length; i++)
            {
                var country = _countries[i];
                variables[i] = new LinguisticVariable(country + "StockIndexMomentumMonthly", -7.2269432f, 4.5099269f);
                foreach (var item in set) variables[i].AddLabel(item);
            }

            return variables;
        }

        //--INF_weekly_z
        private LinguisticVariable[] GetInflationRateSet()
        {
            var set = new[]
            {
                new FuzzySet("Low", new TrapezoidalFunction(-0.7347760f, -0.6108041f, TrapezoidalFunction.EdgeType.Right)),
                new FuzzySet("Medium", new TrapezoidalFunction(-0.7347760f, -0.6108041f, 0.5322620f, 0.8075016f)),
                new FuzzySet("High", new TrapezoidalFunction(0.5322620f, 0.8075016f, TrapezoidalFunction.EdgeType.Left))
            };

            var variables = new LinguisticVariable[3];
            for (int i = 0; i < variables.Length; i++)
            {
                var country = _countries[i];
                variables[i] = new LinguisticVariable(country + "InflationRate", -3.1810819f, 2.7253744f);
                foreach (var item in set) variables[i].AddLabel(item);
            }

            return variables;
        }

        //SG_D_monthly_momentum
        private LinguisticVariable GetUSD2SGDExchangeMomentumMonthlySet()
        {
            var set = new[]
            {
                new FuzzySet("Negative", new TrapezoidalFunction(-0.6070038f, 0f, TrapezoidalFunction.EdgeType.Right)),
                new FuzzySet("Neutral", new TrapezoidalFunction(-0.6070038f, 0f, 0.4299877f, 1.0307703f)),
                new FuzzySet("Positive", new TrapezoidalFunction(0.4299877f, 1.0307703f, TrapezoidalFunction.EdgeType.Left))                
            };
            var variable = new LinguisticVariable("USD2SGDMomentumMonthly", -6.4573556f, 6.5020862f);
            foreach (var item in set) variable.AddLabel(item);

            return variable;
        }

        //UK_D_monthly_momentum
        private LinguisticVariable GetUSD2UKPExchangeMomentumMonthlySet()
        {
            var set = new[]
            {
                new FuzzySet("Negative", new TrapezoidalFunction(-2.0871890f, -0.3369033f, TrapezoidalFunction.EdgeType.Right)),
                new FuzzySet("Neutral", new TrapezoidalFunction(-2.0871890f, -0.3369033f, 0.9130250f, 2.4779044f)),
                new FuzzySet("Positive", new TrapezoidalFunction(0.9130250f, 2.4779044f, TrapezoidalFunction.EdgeType.Left))
            };
            var variable = new LinguisticVariable("USD2UKDMomentumMonthly", -13.7809543f, 7.7503016f);
            foreach (var item in set) variable.AddLabel(item);

            return variable;
        }

        private LinguisticVariable[] GetExchangeRateTrendSet()
        {
            var set = new[]
            {
                new FuzzySet("Down", new SingletonFunction(-1f)),
                new FuzzySet("Up", new SingletonFunction(1f))
            };

            var variables = new LinguisticVariable[2];
            variables[0] = new LinguisticVariable("USD2SGDExchangeRateTrend", -1f, 1f);
            variables[1] = new LinguisticVariable("USD2UKDExchangeRateTrend", -1f, 1f);
            foreach (var item in set)
            {
                variables[0].AddLabel(item);
                variables[1].AddLabel(item);
            }
            
            return variables;
        }

        //with reference to USD, buy or sell USD
        private LinguisticVariable GetTradeStrategySet()
        {
            var set = new[]
            {
                new FuzzySet("SellMore", new TrapezoidalFunction(-50f, -25f, TrapezoidalFunction.EdgeType.Right)),
                new FuzzySet("SellLess", new TrapezoidalFunction(-50f, -25f, -10f, -5f)),
                new FuzzySet("OnHold", new TrapezoidalFunction(-10f, -5f, 5f, 10f)),
                new FuzzySet("BuyLess", new TrapezoidalFunction(5f, 10f, 25f, 50f)),
                new FuzzySet("BuyMore", new TrapezoidalFunction(25f, 50f, TrapezoidalFunction.EdgeType.Left)),                
            };
            var variable = new LinguisticVariable("TradeStrategy", -90f, 90f);
            foreach (var item in set) variable.AddLabel(item);

            return variable;
        }
        
        #endregion
       
    }
}
