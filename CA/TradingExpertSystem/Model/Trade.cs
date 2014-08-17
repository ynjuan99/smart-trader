namespace Model
{
    public struct Trade
    {
        public double Amount;
        public Currency From;
        public Currency To;

        public Trade(Currency from, Currency to, double amount)
        {
            From = from;
            To = to;
            Amount = amount;
        }
    }
}