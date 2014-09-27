using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;

namespace Model
{
    public class Rule
    {                
        private readonly Dictionary<Criterion, string> _dictionary = new Dictionary<Criterion, string>();

        public Rule(Country country)
        {
            Country = country;
        }

        public Country Country { get; private set; }

        public string TradeStrategy { get; set; }

        public string this[Criterion criterion]
        {
            get { return _dictionary[criterion]; }
            set { _dictionary[criterion] = value; }
        }

        public bool IsValid
        {
            get { return _dictionary.Values.Any(o => !string.IsNullOrWhiteSpace(o)); }
        }

        public override string ToString()
        {
            var buffer = new StringBuilder("IF ");
            bool suffixAnd = false;
            foreach (var item in _dictionary)
            {
                if (!string.IsNullOrWhiteSpace(item.Value))
                {
                    if (suffixAnd) buffer.Append("AND ");
                    else suffixAnd = true;

                    buffer.AppendFormat("{0} IS {1} ", item.Key.ToString().Replace("XX", Country.ToString()), item.Value);                   
                }
            }

            buffer.AppendFormat("THEN TradeStrategy IS {0}", TradeStrategy);
            return buffer.ToString();
        }

        public static Rule[] LoadRule(DataRow row)
        {
            var rules = new Rule[2];
            rules[0] = LoadRule(Country.SG, row);
            rules[1] = LoadRule(Country.UK, row);
            return rules.Where(o => o.IsValid).ToArray();
        }

        private static Rule LoadRule(Country country, DataRow row)
        {
            var rule = new Rule(country);
            foreach (var item in Enum.GetValues(typeof(Criterion)))
            {
                var key = (Criterion)item;
                //rule[key] = row.Field<string>(key.ToString().Replace("XX", country.ToString()));
                rule[key] = row.Field<string>(key.ToString());
            }
            rule.TradeStrategy = row.Field<string>("TradeStrategy");

            return rule;
        }
    }
}