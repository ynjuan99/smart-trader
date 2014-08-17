using System;
using System.Diagnostics;

namespace Model
{
    public struct Trade
    {
        public Currency From;
        public Currency To;
        public double Amount;

        public Trade(Currency from, Currency to, double amount)
        {
            From = from;
            To = to;
            Amount = amount;
        }
    }
}