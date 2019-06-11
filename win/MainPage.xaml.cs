using System;
using System.ComponentModel;
using Windows.UI.Xaml.Controls;
using Windows.UI.Xaml.Input;

// 空白ページの項目テンプレートについては、https://go.microsoft.com/fwlink/?LinkId=402352&clcid=0x411 を参照してください

namespace CircularProgressBar
{
    /// <summary>
    /// それ自体で使用できる空白ページまたはフレーム内に移動できる空白ページ。
    /// </summary>
    public sealed partial class MainPage : Page, INotifyPropertyChanged
    {
        public event PropertyChangedEventHandler PropertyChanged;
        private void notify(string propName)
        {
            PropertyChanged?.Invoke(this, new PropertyChangedEventArgs(propName));
        }

        public MainPage()
        {
            DataContext = this;
            InitializeComponent();
        }


        private int mProgress = 0;
        public int Progress
        {
            get => mProgress;
            set
            {
                if(mProgress!=value)
                {
                    mProgress = Math.Max(0,Math.Min(100,value));
                    notify("Progress");
                }
            }
        }

        private void OnNext(object sender, TappedRoutedEventArgs e)
        {
            var p = Progress;
            if(p<100)
            {
                p += 10;
                if(p>100)
                {
                    p = 100;
                }
            }
            else
            {
                p = 0;
            }
            Progress = p;
            //Progress1.Progress = p;
        }
    }
}
