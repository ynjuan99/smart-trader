using System;
using System.Collections.Generic;
using System.Configuration;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Data;
using System.Windows.Documents;
using System.Windows.Input;
using System.Windows.Media;
using System.Windows.Media.Imaging;
using System.Windows.Navigation;
using System.Windows.Shapes;
using Repository;

namespace SmartTraderTerminal
{
    /// <summary>
    /// Interaction logic for MainWindow.xaml
    /// </summary>
    public partial class MainWindow : Window
    {
        public MainWindow()
        {
            InitializeComponent();    
        }

        private async void btnStart_Click(object sender, RoutedEventArgs e)
        {            
            LoadingAdorner.IsAdornerVisible = true;
            BtnStart.IsEnabled = false;

            var models = InputModels.SelectedValue.Split(',');
            var year = Convert.ToInt32(InputYear.SelectedValue);
            var month = Convert.ToInt32(InputMonth.SelectedValue);
            var sectors = InputSectors.SelectedValue.Split(',');
            var results = await LoadResult(year, month, models, sectors);

            results.ForEach(o => o.ModelDescription = ConstantSource.Models[o.Model]);
            GridResult.ItemsSource = results;             
            BtnStart.IsEnabled = true;
            LoadingAdorner.IsAdornerVisible = false;
        }

        private async Task<List<ResultTuple>> LoadResult(int year, int month, string[] models, string[] sectors)
        {
            await Task.Delay(1000 * DisplayDelaySeconds);
            return FactorDataRepository.RetrieveResultTuple(year, month, models, sectors);
        }

        private int DisplayDelaySeconds
        {
            get { return Convert.ToInt32(ConfigurationManager.AppSettings["DisplayDelaySeconds"]); }        
        }
    }    
}
