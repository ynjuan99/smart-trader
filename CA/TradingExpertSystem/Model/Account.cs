using System;
using System.Collections.Generic;
using System.Linq;

namespace Model
{
    public class Account
    {
        private readonly Dictionary<Currency, double> _accounts = new Dictionary<Currency, double>
        {
            { Currency.SGD, 0d },
            { Currency.UKP, 0d },
            { Currency.USD, 0d }
        };

        private bool _alreadySetBalance;
        private double _currentBalance;

        public Account(double sgd, double ukp, double usd)
        {
            _accounts[Currency.SGD] = sgd;
            _accounts[Currency.UKP] = ukp;
            _accounts[Currency.USD] = usd;
        }

        public double this[Currency currency]
        {
            get { return _accounts[currency]; }
        }

        public double CurrentBalanceInUSD
        {
            get
            {
                if (!_alreadySetBalance) throw new InvalidOperationException("No transaction yet");
                return _currentBalance;
            }
        }

        public double Transact(Indices indices, params Transaction[] transactions)
        {
            foreach (Currency currency in _accounts.Keys)
            {
                UpdateInterest(currency, indices.GetCurrentEffectiveInterestRate(currency));
            }

            foreach (Transaction trade in transactions)
            {
                Trade(indices, trade);
            }

            _currentBalance = _accounts.Sum(o => o.Value * indices.GetCurrentExchangeRate(o.Key));
            _alreadySetBalance = true;

            return _currentBalance;
        }

        private void UpdateInterest(Currency currency, double interestRate)
        {
            _accounts[currency] *= (1 + interestRate / 5200);
        }

        private void Trade(Indices indices, Transaction transaction)
        {
            double actual = Math.Min(Math.Max(0, transaction.Amount), _accounts[transaction.From]);
            _accounts[transaction.From] -= actual;
            _accounts[transaction.To] += actual * indices.GetCurrentExchangeRate(transaction.From) / indices.GetCurrentExchangeRate(transaction.To);
        }
    }
}