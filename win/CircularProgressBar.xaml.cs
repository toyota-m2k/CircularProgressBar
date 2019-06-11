using System;
using System.ComponentModel;
using System.Runtime.CompilerServices;
using Windows.Foundation;
using Windows.UI;
using Windows.UI.Xaml;
using Windows.UI.Xaml.Controls;
using Windows.UI.Xaml.Data;
using Windows.UI.Xaml.Media;

// ユーザー コントロールの項目テンプレートについては、https://go.microsoft.com/fwlink/?LinkId=234236 を参照してください

namespace CircularProgressBar
{
    public sealed partial class CircularProgressBar : UserControl, INotifyPropertyChanged
    {
        #region INotifyPropertyChanged i/f

        public event PropertyChangedEventHandler PropertyChanged;
        private void notify(string propName)
        {
            PropertyChanged?.Invoke(this, new PropertyChangedEventArgs(propName));
        }
        private bool setProp<T>(ref T field, T value, params string[] propNames)
        {
            if (field==null || !field.Equals(value))
            {
                field = value;
                foreach (var p in propNames)
                {
                    notify(p);
                }
                return true;
            }
            return false;
        }
        #endregion

        #region Private Fields & Initialize

        private SolidColorBrush mRingBaseColor = null;
        private SolidColorBrush mProgressColor = null;
        private SolidColorBrush mInsideRingColor = null;
        private SolidColorBrush mTextColor = null;
        private double mRingThicknessRatio = 0.1;
        private double Radius => (100 - RingThickness) / 2;

        public CircularProgressBar()
        {
            DataContext = this;
            InitializeComponent();
        }

        #endregion

        #region 配色

        public SolidColorBrush RingBaseColor
        {
            get => mRingBaseColor ?? this.Resources["DefRingBaseColor"] as SolidColorBrush;
            set => setProp(ref mRingBaseColor, value, nameof(RingBaseColor));
        }
        public SolidColorBrush ProgressColor
        {
            get => mProgressColor ?? this.Resources["DefProgressColor"] as SolidColorBrush;
            set => setProp(ref mProgressColor, value, nameof(ProgressColor));
        }
        public SolidColorBrush TextColor
        {
            get => mTextColor ?? this.Resources["DefTextColor"] as SolidColorBrush;
            set => setProp(ref mTextColor, value, nameof(TextColor));
        }
        public SolidColorBrush InsideRingColor
        {
            get => mInsideRingColor ?? this.Resources["DefInsideRingColor"] as SolidColorBrush;
            set => setProp(ref mInsideRingColor, value, nameof(InsideRingColor));
        }
        #endregion

        #region RingThicknessと、それに依存するプロパティ

        public double RingThicknessRatio
        {
            get => mRingThicknessRatio;
            set => setProp(ref mRingThicknessRatio, value, nameof(RingThickness), nameof(StartPoint), nameof(ArcSize));
        }


        public double RingThickness => 50 * RingThicknessRatio;
        public Point StartPoint => new Point(50, RingThickness / 2);
        public Size ArcSize
        {
            get => new Size(Radius, Radius);
        }
        #endregion

        #region Progress と、それに依存するプロパティ

        /**
         * Progressプロパティは、
         * 利用側xamlからバインドできるようにDependencyPropertyとして実装
         */
        public static readonly DependencyProperty ProgressProperty = DependencyProperty.Register("Progress", typeof(int), typeof(CircularProgressBar),
            new PropertyMetadata(0, (sender, args) =>
            {
                var me = sender as CircularProgressBar;
                if (null != me)
                {
                    me.notify(nameof(me.IsLargeArc));
                    me.notify(nameof(me.EndPoint));
                    me.notify(nameof(me.ProgressText));
                }
            }));

        /**
         * progress in percent (0-100)
         */
        public int Progress
        {
            get => (int)GetValue(ProgressProperty);
            set { SetValue(ProgressProperty, value); }
        }

        /**
         * 円弧の終点
         */
        public Point EndPoint
        {
            get
            {
                double progress = Progress/100.0;
                if (progress >= 1.0)
                {
                    progress = 0.99999;
                }
                if (progress < 0)
                {
                    progress = 0;
                }
                double angle = 2 * Math.PI * progress;
                return new Point(Math.Sin(angle) * Radius + 50, Math.Cos(angle - Math.PI) * Radius + 50);
            }
        }

        /**
         * 大きい円弧/小さい円弧のどちらで結ぶか
         */
        public bool IsLargeArc => Progress > 50;

        /**
         * 進捗のテキスト表記
         */
        public string ProgressText => $"{Progress}%";
        
        #endregion
    }

    /**
     * bool --> Visibility
     */
    public class BoolVisibilityConverter : IValueConverter
    {
        public object Convert(object value, Type targetType, object parameter, string language)
        {
            if ((bool)value)
            {
                return Visibility.Visible;
            }
            else
            {
                return Visibility.Collapsed;
            }
        }

        public object ConvertBack(object value, Type targetType, object parameter, string language)
        {
            return DependencyProperty.UnsetValue;
        }
    }

}
