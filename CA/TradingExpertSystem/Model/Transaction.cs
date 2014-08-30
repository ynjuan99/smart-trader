namespace Model
{
    public struct Transaction
    {
        public double Amount;
        public Currency From;
        public Currency To;

        public Transaction(Currency from, Currency to, double amount)
        {
            From = from;
            To = to;
            Amount = amount;
        }
    }
}