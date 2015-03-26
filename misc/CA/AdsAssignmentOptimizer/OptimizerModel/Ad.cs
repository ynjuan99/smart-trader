using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace OptimizerModel
{
    public struct Ad : IEquatable<Ad>
    {
        public Ad(int id) : this()
        {
            Id = id;
        }

        public int Id { get; private set; }

        public string Name
        {
            get { return "Ad " + Id; }
        }

        public override bool Equals(object obj)
        {
            return Equals((Ad)obj);
        }

        public bool Equals(Ad other)
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