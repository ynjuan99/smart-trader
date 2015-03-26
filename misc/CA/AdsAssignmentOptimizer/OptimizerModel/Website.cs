using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace OptimizerModel
{
    public struct Website : IEquatable<Website>
    {
        public Website(int id, double rate) : this()
        {
            Id = id;
            Rate = rate;
        }

        public int Id { get; private set; }
        public double Rate { get; private set; }
        public string Name
        {
            get { return "Website " + Id; }
        }
        
        public override bool Equals(object obj)
        {
            return Equals((Website)obj);
        }

        public bool Equals(Website other)
        {
            return Id == other.Id;
        }

        public override int GetHashCode()
        {
            return Id.GetHashCode();
        }

        public override string ToString()
        {
            return Name;
        }
    }
}