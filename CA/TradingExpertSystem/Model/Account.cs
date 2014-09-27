using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace Model
{
    public class Account
    {
        private readonly Dictionary<Currency, double> _accounts;
        private double _currentBalance;

        public Account(double sgd, double ukp, double usd, double usd2sgd, double usd2ukp)
        {
            _accounts = new Dictionary<Currency, double>
            {
                { Currency.SGD, sgd },
                { Currency.UKP, ukp },
                { Currency.USD, usd }
            };
            _currentBalance = usd + sgd * usd2sgd + ukp * usd2ukp;
        }

        public double this[Currency currency]
        {
            get { return _accounts[currency]; }
        }

        public double CurrentBalanceInUSD
        {
            get
            {
                return _currentBalance;
            }
        }

        public double Transact(Indices indices, IEnumerable<Transaction> transactions)
        {
            var interest = UpdateInterest(indices);
            var exchange = Trade(indices, transactions);
            foreach (var key in _accounts.Keys.ToArray())
            {
                _accounts[key] += interest[key] + exchange[key];
            }

            _currentBalance = _accounts.Sum(o => o.Value * indices.GetCurrentExchangeRate(o.Key));          

            return _currentBalance;
        }

        private Dictionary<Currency, double> UpdateInterest(Indices indices)
        {
            var delta = new Dictionary<Currency, double>();
            foreach (Currency currency in _accounts.Keys)
            {
                var interestRate = indices.GetCurrentInterestRate(currency);
                delta.Add(currency, _accounts[currency] * interestRate / 100);
            }

            return delta;
        }

        private Dictionary<Currency, double> Trade(Indices indices, IEnumerable<Transaction> transactions)
        {
            var delta = new Dictionary<Currency, double>
            {
                { Currency.SGD, 0 },
                { Currency.UKP, 0 },
                { Currency.USD, 0 }
            };

            foreach (Transaction transaction in transactions)
            {
                double quantity = transaction.Percentage * _accounts[transaction.From] / 100;
                delta[transaction.From] -= quantity * (1 + DataContext.CostPerTransaction);
                delta[transaction.To] += quantity * indices.GetCurrentExchangeRate(transaction.From) / indices.GetCurrentExchangeRate(transaction.To);
            }

            return delta;
        }

        public override string ToString()
        {
            return string.Format("Current portfolio: SGD - {0:F2}, UKP - {1:F2}, USD - {2:F2}, total Balance in USD: {3:F2}", 
                _accounts[Currency.SGD], _accounts[Currency.UKP], _accounts[Currency.USD], _currentBalance);
        }
    }
}