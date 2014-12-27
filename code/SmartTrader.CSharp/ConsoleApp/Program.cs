using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using UnitTest;

namespace ConsoleApp
{
    class Program
    {
        static void Main(string[] args)
        {
            var tester = new ModelTrialTest();
            tester.TestWindowedClassificationWithClassifiedOutput();
        }
    }
}
