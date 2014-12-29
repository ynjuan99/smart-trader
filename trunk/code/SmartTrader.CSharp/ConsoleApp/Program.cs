using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading;
using System.Threading.Tasks;
using Repository;
using UnitTest;

namespace ConsoleApp
{
    class Program
    {
        private static readonly string[] Sectors = new[]
            {
                "Consumer Discretionary", 
                "Consumer Staples", 
                "Energy", 
                "Financials", 
                "Health Care", 
                "Industrials", 
                "Information Technology", 
                "Materials", 
                "Telecommunication Services", 
                "Utilities"
            };

        private static void Main(string[] args)
        {
            RunMain();
        }

        private static void RunMain()
        {
            try
            {
                var start = new DateTime(2004, 12, 1);
                var end = new DateTime(2014, 10, 1);

                do
                {
                    var task = RunPerSectorAsync(start.Year, start.Month);  
                    task.Wait();             
                    start = start.AddMonths(1);
                } while (start <= end);
            }
            catch (AggregateException ex)
            {
                Console.WriteLine(ex);
                throw;
            }
            catch (Exception ex)
            {
                Console.WriteLine(ex);
                throw;
            }
        }

        private static async Task RunPerSectorAsync(int year, int month)
        {
            var tasks = new List<Task>(Sectors.Length);
            foreach (string sector in Sectors)
            {
                var tester = new ModelTrialTest(sector, year, month);
                tasks.Add(Task.Run(() =>
                {
                    var result = tester.TestWindowedClassificationWithClassifiedOutput();
                    FactorDataRepository.PersistResultTuple(result);
                    Console.WriteLine("Period: {1}-{2:D2}, Sector: {0}", result.Sector, result.ForYear, result.ForMonth);
                }));
            }
            await Task.WhenAll(tasks);
        }

        private static void RunPerSector(int year, int month)
        {
            foreach (string sector in Sectors)
            {
                var tester = new ModelTrialTest(sector, year, month);
                var result = tester.TestWindowedClassificationWithClassifiedOutput();
                FactorDataRepository.PersistResultTuple(result);
                Console.WriteLine("Period: {1}-{2:D2}, Sector: {0}", result.Sector, result.ForYear, result.ForMonth);
            }
        }
    }
}
