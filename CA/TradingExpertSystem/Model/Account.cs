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
            foreach (Currency currency in _accounts.Keys.ToArray())
            {
                UpdateInterest(currency, indices.GetCurrentInterestRate(currency));
            }

            foreach (Transaction transaction in transactions)
            {
                Trade(indices, transaction);
            }

            _currentBalance = _accounts.Sum(o => o.Value * indices.GetCurrentExchangeRate(o.Key));          

            return _currentBalance;
        }

        private void UpdateInterest(Currency currency, double interestRate)
        {
            _accounts[currency] *= (1 + interestRate / 100);
        }

        private void Trade(Indices indices, Transaction transaction)
        {
            double quantity = transaction.Percentage * _accounts[transaction.From] / 100;            
            _accounts[transaction.From] -= quantity * (1 + DataContext.CostPerTransaction);
            _accounts[transaction.To] += quantity * indices.GetCurrentExchangeRate(transaction.From) / indices.GetCurrentExchangeRate(transaction.To);
        }

        public override string ToString()
        {
            return string.Format("Current portfolio: SGD - {0:F2}, UKP - {1:F2}, USD - {2:F2}, total Balance in USD: {3:F2}", 
                _accounts[Currency.SGD], _accounts[Currency.UKP], _accounts[Currency.USD], _currentBalance);
        }
    }
}