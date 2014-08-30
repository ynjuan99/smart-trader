using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using AForge.Fuzzy;

namespace Model
{
    public class FuzzyTrader
    {
        private readonly InferenceSystem _engine;
        public FuzzyTrader()
        {
            var rulebase = new Database();
            rulebase.AddVariable(GetInflationRateSet());
            rulebase.AddVariable(GetInflationRateSet());
            rulebase.AddVariable(GetExchangeRateTrendSet());

            _engine = new InferenceSystem(rulebase, new CentroidDefuzzifier(1000));
            //todo
            _engine.NewRule("Rule#01", "IF THEN");
        }

        public void Propose()
        {
            //todo
            _engine.Evaluate("");
        }

        private LinguisticVariable GetInterestRateSet()
        {
            var set = new[]
            {
                new FuzzySet("Low", new TrapezoidalFunction(3, 6, TrapezoidalFunction.EdgeType.Right)),
                new FuzzySet("Medium", new TrapezoidalFunction(3, 6, 9, 12)),
                new FuzzySet("High", new TrapezoidalFunction(9, 12, TrapezoidalFunction.EdgeType.Left))
            };
            var variable = new LinguisticVariable("InterestRate", 0, 20);
            foreach (var item in set)
            {
                variable.AddLabel(item);
            }

            return variable;
        }

        private LinguisticVariable GetInflationRateSet()
        {
            var set = new[]
            {
                new FuzzySet("Low", new TrapezoidalFunction(-1, 1, TrapezoidalFunction.EdgeType.Right)),
                new FuzzySet("Low", new TrapezoidalFunction(-1, 1, 2, 4)),
                new FuzzySet("Medium", new TrapezoidalFunction(2, 4, 6, 8)),
                new FuzzySet("High", new TrapezoidalFunction(6, 8, TrapezoidalFunction.EdgeType.Left))
            };
            var variable = new LinguisticVariable("InflationRate", -2, 12);
            foreach (var item in set)
            {
                variable.AddLabel(item);
            }

            return variable;
        }

        private LinguisticVariable GetExchangeRateTrendSet()
        {
            var set = new[]
            {
                new FuzzySet("VeryNegative", new TrapezoidalFunction(-0.07f, -0.06f, TrapezoidalFunction.EdgeType.Right)),
                new FuzzySet("Negative", new TrapezoidalFunction(-0.07f, -0.06f, -0.04f, -0.03f)),
                new FuzzySet("LittleNegative", new TrapezoidalFunction(-0.04f, -0.03f, -0.01f, -0.005f)),
                new FuzzySet("Zero", new TrapezoidalFunction(-0.01f, -0.005f, 0.01f, 0.015f)),
                new FuzzySet("LittlePositive", new TrapezoidalFunction(0.01f, 0.015f, 0.025f, 0.03f)),
                new FuzzySet("Positive", new TrapezoidalFunction(0.025f, 0.03f, 0.04f, 0.045f)),
                new FuzzySet("VeryPositive", new TrapezoidalFunction(0.04f, 0.045f, TrapezoidalFunction.EdgeType.Left))
            };
            var variable = new LinguisticVariable("ExchangeRateTrend", -0.11f, 0.05f);
            foreach (var item in set)
            {
                variable.AddLabel(item);
            }

            return variable;
        }
    }
}
