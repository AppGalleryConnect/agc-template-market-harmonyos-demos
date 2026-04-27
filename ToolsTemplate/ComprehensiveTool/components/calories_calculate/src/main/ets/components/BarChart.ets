import {
  AxisBase,
  BarChart,
  BarChartModel,
  BarData,
  BarDataSet,
  BarEntry,
  Description,
  EntryOhos,
  Highlight,
  IAxisValueFormatter,
  IBarDataSet,
  JArrayList,
  Legend,
  LimitLabelPosition,
  LimitLine,
  MarkerView,
  OnChartValueSelectedListener,
  XAxis,
  XAxisPosition,
  YAxis,
  YAxisLabelPosition,
} from '@ohos/mpchart';
import { xMap } from '../model/Index';

@ComponentV2
export struct CommonCharts {
  @Local model: BarChartModel = new BarChartModel();
  @Local limitLine1: LimitLine = new LimitLine(120, 'Upper Limit');
  @Local limitLine2: LimitLine = new LimitLine(50, 'Upper Limit');
  @Local leftAxis: YAxis | null = null;
  @Local rightAxis: YAxis | null = null;
  @Local xAxis: XAxis | null = null;
  @Local normalMarker: MarkerView = new MarkerView();
  @Local dataSet: BarDataSet = new BarDataSet(new JArrayList<BarEntry>(), 'DataSet');
  @Local name: string = '';
  @Local rate: number = 0;
  @Param xData: string[] = [];
  @Param seriesData: number[] = [];

  @Monitor('seriesData')
  onDataChange() {
    let barData: BarData = this.getBarData();
    this.model.setData(barData);
    this.model.notifyDataSetChanged();
    this.model.invalidate();
  }

  @Computed
  get totalCalories() {
    let totalCalories = 0;
    this.seriesData.forEach((item) => {
      totalCalories = totalCalories + item;
    });
    return totalCalories;
  }

  // 构造数据选择监听器
  private valueSelectedListener: OnChartValueSelectedListener = {
    onValueSelected: (e: EntryOhos, h: Highlight) => {
      this.name = this.xData[e.getX()];
      this.rate = e.getY();
    },
    onNothingSelected: () => {
      // ...todoSomething
    },
  };

  // 图表数据初始化
  aboutToAppear() {
    this.name = this.xData[this.xData.length - 1];
    this.rate = this.seriesData[this.seriesData.length - 1];
    // Step1:必须：初始化图表配置构建类
    this.model = new BarChartModel();

    // Step2:配置图表指定样式，各部件间没有先后之分

    // 为图表添加数据选择的监听器
    this.model.setOnChartValueSelectedListener(this.valueSelectedListener);
    // 获取图表描述部件，设置图表描述部件不可用，即图表不进行绘制描述部件
    let description: Description | null = this.model.getDescription();
    if (description) {
      description.setEnabled(false);
    }

    // 获取图表图例部件，设置图表图例部件不可用
    let legend: Legend | null = this.model.getLegend();
    if (legend) {
      legend.setEnabled(false);
    }

    // 设置图表数据最大的绘制数，如果超过该数值，则不进行绘制图表的数值标签
    this.model.setMaxVisibleValueCount(7);

    // 为左Y轴设置LimitLine,可设置限制线的宽度，线段样式，限制标签的位置，标签字体大小等
    this.limitLine1 = new LimitLine(120, 'Upper Limit');
    this.limitLine1.setLineWidth(4);
    //设置虚线样式
    this.limitLine1.enableDashedLine(10, 10, 0);
    //设置标签位置
    this.limitLine1.setLabelPosition(LimitLabelPosition.RIGHT_TOP);
    this.limitLine1.setTextSize(10);

    this.limitLine2 = new LimitLine(50, 'Lower Limit');
    this.limitLine2.setLineWidth(4);
    this.limitLine2.enableDashedLine(10, 10, 0);
    this.limitLine2.setLineColor(Color.Yellow);
    this.limitLine2.setLabelPosition(LimitLabelPosition.RIGHT_BOTTOM);
    this.limitLine2.setTextSize(10);

    // 设置图表左Y轴信息
    this.leftAxis = this.model.getAxisLeft();
    if (this.leftAxis) {
      //设置绘制标签个数
      this.leftAxis.setLabelCount(7, false);
      //设置标签位置
      this.leftAxis.setPosition(YAxisLabelPosition.OUTSIDE_CHART);
      //设置距离顶部距离
      this.leftAxis.setSpaceTop(15);
      //设置最小值
      this.leftAxis.setAxisMinimum(0);
      //设置最大值
      this.leftAxis.setAxisMaximum(2000);
      this.leftAxis.setGridDashedLine({ dash: [2, 2, 0], offset: 0 });
      this.leftAxis.setTextColor('#E6000000');
      this.leftAxis.setTextSize(12);
    }

    // 设置图表右Y轴信息
    this.rightAxis = this.model.getAxisRight();
    if (this.rightAxis) {
      this.rightAxis.setEnabled(false);
    }

    class YAxisValueFormatter implements IAxisValueFormatter {
      getFormattedValue(value: number, axis: AxisBase): string {
        //将原本存在的对应的value转换成需要的字符串
        return value.toString();
      }
    }

    this.leftAxis?.setValueFormatter(new YAxisValueFormatter());

    // 设置X轴信息
    this.xAxis = this.model.getXAxis();
    if (this.xAxis) {
      this.xAxis.setPosition(XAxisPosition.BOTTOM);
      this.xAxis.setDrawGridLines(false);
      this.xAxis.setGranularity(1);
      this.xAxis.setLabelCount(this.xData.length);
      this.xAxis.setTextColor('#E6000000');
      this.xAxis.setTextSize(12);
    }

    class XAxisValueFormatter implements IAxisValueFormatter {
      data: string[] = [];

      constructor(data: string[]) {
        this.data = data;
      }

      getFormattedValue(value: number, axis: AxisBase): string {
        //将原本存在的对应的value转换成需要的字符串
        let day = new Date().getDay() - 1;
        if (day === value) {
          return '今日';
        }
        return xMap[value];
      }
    }

    this.xAxis?.setValueFormatter(new XAxisValueFormatter(this.xData));
    // 生成图表数据
    let barData: BarData = this.getBarData();
    // 将数据与图表配置类绑定
    this.model.setData(barData);
    // 设置图表最大的X轴显示范围，如不设置，则默认显示全部数据
    this.model.setVisibleXRangeMaximum(20);
  }

  private getBarData(): BarData {
    let values: JArrayList<BarEntry> = new JArrayList<BarEntry>();
    for (let i = 0; i < this.seriesData.length; i++) {

      let val = this.seriesData[i];
      values.add(new BarEntry(i, val));
    }

    this.dataSet = new BarDataSet(values, 'DataSet');
    this.dataSet.setHighLightColor(Color.Black);
    this.dataSet.setDrawIcons(false);
    this.dataSet.setDrawValues(false);
    this.dataSet.setColorByColor(0xED6F21);


    let dataSetList: JArrayList<IBarDataSet> = new JArrayList<IBarDataSet>();
    dataSetList.add(this.dataSet);

    let barData: BarData = new BarData(dataSetList);
    barData.setBarWidth(0.5);
    return barData;
  }

  build() {
    Column({ space: 12 }) {
      Row() {
        Text('总摄入：').fontSize(16).fontColor($r('sys.color.font_primary')).fontWeight(FontWeight.Medium);
        Text(this.totalCalories.toString())
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor('#ED6F21')
          .margin({ left: 12 });
        Text('Kcal')
          .fontSize(12)
          .fontColor($r('sys.color.font_primary'))
          .fontWeight(FontWeight.Medium)
          .margin({ left: 4 });
      }
      .width('100%')
      .backgroundColor($r('sys.color.background_secondary'))
      .padding(12)
      .borderRadius(8)
      .alignItems(VerticalAlign.Bottom);

      Column() {
        Text('Kcal')
          .fontSize(14)
          .fontColor($r('sys.color.font_primary'))
          .fontWeight(FontWeight.Medium)
          .width('100%')
          .textAlign(TextAlign.Start);
        BarChart({ model: this.model })
          .width('100%')
          .height(190);
      }
      .width('100%');

      Text('数据统计以周为单位，每周日24:00点自动清零').fontSize(12).fontColor($r('sys.color.font_secondary'));
    }
    .width('100%');
  }
}