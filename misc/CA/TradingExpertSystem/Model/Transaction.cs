namespace Model
{
    public struct Transaction
    {
        public double Percentage;
        public Currency From;
        public Currency To;

        public Transaction(Currency from, Currency to, double percentage)
        {
            From = from;
            To = to;
            Percentage = percentage;
        }
    }
}