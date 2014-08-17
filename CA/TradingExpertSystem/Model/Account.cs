using System;
using System.Collections.Generic;
using System.Diagnostics;
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
        
        public double Transact(Indices indices, params Trade[] trades)
        {
            foreach (var currency in _accounts.Keys)
            {
                UpdateInterest(currency, indices.GetInterestRate(currency));
            }
            
            foreach (var trade in trades)
            {
                Trade(indices, trade);
            }
            
            _currentBalance = _accounts.Sum(o => o.Value * indices.GetExchangeRateToUSD(o.Key));
            _alreadySetBalance = true;

            return _currentBalance;
        }

        private void UpdateInterest(Currency currency, double rate)
        {
            _accounts[currency] *= (1 + rate / 5200);
        }

        private void Trade(Indices indices, Trade trade)
        {
            double actual = Math.Min(Math.Max(0, trade.Amount), _accounts[trade.From]);
            _accounts[trade.From] -= actual;
            _accounts[trade.To] += actual * indices.GetExchangeRateToUSD(trade.From) / indices.GetExchangeRateToUSD(trade.To);
        }       
    }
}