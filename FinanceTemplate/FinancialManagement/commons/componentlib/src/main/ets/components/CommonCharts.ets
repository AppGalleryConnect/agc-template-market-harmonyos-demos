import {
  JArrayList, // 工具类：数据集合
  XAxis, // 图表X轴部件
  XAxisPosition, // 图表X轴标签位置枚举类
  YAxis, // 图表Y轴部件
  Description, // 图表描述标签
  Legend, // 图表Legend(图例)部件
  OnChartValueSelectedListener, //
  Highlight, // 图表高亮数据
  EntryOhos, // 图表数据结构基础类
  YAxisLabelPosition, // 图表Y轴标签位置枚举类
  LineDataSet, //线形图数据集合
  ILineDataSet, // 线形图数据集合的操作类
  LineData, //线形图数据包
  Mode, //线形图形状
  LineChart, // 线形图图表类
  LineChartModel, // 线形图配置构建类
  LimitLine, // 图表LimitLine
  LimitLabelPosition, // 图表的LimitLine标签位置枚举类
  MarkerView,
  IAxisValueFormatter,
  AxisBase, //图例形状
} from '@ohos/mpchart';

@ComponentV2
export struct CommonCharts {
  @Local model: LineChartModel = new LineChartModel()
  @Local limitLine1: LimitLine = new LimitLine(120, 'Upper Limit')
  @Local limitLine2: LimitLine = new LimitLine(50, 'Upper Limit')
  @Local leftAxis: YAxis | null = null
  @Local rightAxis: YAxis | null = null
  @Local xAxis: XAxis | null = null
  @Local normalMarker: MarkerView = new MarkerView()
  @Local dataSet: LineDataSet = new LineDataSet(new JArrayList<EntryOhos>(), 'DataSet')
  @Local name: string = ''
  @Local rate: number = 0
  @Param label: string = '七日年化'
  @Param xData: string[] = []
  @Param seriesData: number[] = []

  @Monitor('xData')
  onDataChange() {
    let lineData: LineData = this.getLineData();
    this.model.setData(lineData)
    this.model.notifyDataSetChanged();
    this.model.invalidate();
  }

  // 构造数据选择监听器
  private valueSelectedListener: OnChartValueSelectedListener = {
    onValueSelected: (e: EntryOhos, h: Highlight) => {
      this.name = this.xData[e.getX()]
      this.rate = e.getY()
    },
    onNothingSelected: () => {
      // ...todoSomething
    }
  }

  // 图表数据初始化
  aboutToAppear() {
    this.name = this.xData[this.xData.length - 1]
    this.rate = this.seriesData[this.seriesData.length - 1]
    // Step1:必须：初始化图表配置构建类
    this.model = new LineChartModel();

    // Step2:配置图表指定样式，各部件间没有先后之分

    // 为图表添加数据选择的监听器
    this.model.setOnChartValueSelectedListener(this.valueSelectedListener);
    // 获取图表描述部件，设置图表描述部件不可用，即图表不进行绘制描述部件
    let description: Description | null = this.model.getDescription()
    if (description) {
      description.setEnabled(false);
    }

    // 获取图表图例部件，设置图表图例形状为线形
    let legend: Legend | null = this.model.getLegend();
    if (legend) {
      legend.setEnabled(false);
    }
    this.model.setDragEnabled(false)
    this.model.setScaleEnabled(false)

    // 设置图表数据最大的绘制数，如果超过该数值，则不进行绘制图表的数值标签
    this.model.setMaxVisibleValueCount(60);

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
      this.leftAxis.setLabelCount(6, false);
      //设置标签位置
      this.leftAxis.setPosition(YAxisLabelPosition.OUTSIDE_CHART)
      //设置距离顶部距离
      this.leftAxis.setSpaceTop(15);
      //设置最大值
      this.leftAxis.setAxisMinimum(0);
      //设置最小值
      this.leftAxis.setAxisMaximum(5);
      this.leftAxis.setGridDashedLine({ dash: [2, 2, 0], offset: 0 })
      this.leftAxis.setTextColor('rgba(0,0,0,0.40)')
      this.leftAxis.setTextSize(10)
    }

    // 设置图表右Y轴信息
    this.rightAxis = this.model.getAxisRight();
    if (this.rightAxis) {
      this.rightAxis.setEnabled(false);
    }

    class YAxisValueFormatter implements IAxisValueFormatter {
      getFormattedValue(value: number, axis: AxisBase): string {
        //将原本存在的对应的value转换成需要的字符串
        return value + '.00%';
      }
    }

    this.leftAxis?.setValueFormatter(new YAxisValueFormatter())

    // 设置X轴信息
    this.xAxis = this.model.getXAxis();
    if (this.xAxis) {
      this.xAxis.setPosition(XAxisPosition.BOTTOM);
      this.xAxis.setDrawGridLines(false);
      this.xAxis.setGranularity(1);
      this.xAxis.setLabelCount(this.xData.length);
      this.xAxis.setTextColor('rgba(0,0,0,0.40)')
      this.xAxis.setTextSize(10)
    }

    class XAxisValueFormatter implements IAxisValueFormatter {
      data: string[] = []

      constructor(data: string[]) {
        this.data = data
      }

      getFormattedValue(value: number, axis: AxisBase): string {
        //将原本存在的对应的value转换成需要的字符串
        switch (value) {
          case axis.mEntries[0]:
            return this.data[0].slice(5);
          case axis.mEntries[axis.mEntries.length - 1]:
            return this.data[this.data.length - 1].slice(5);
        }
        return '';
      }
    }

    this.xAxis?.setValueFormatter(new XAxisValueFormatter(this.xData))
    // 生成图表数据
    let lineData: LineData = this.getLineData();
    // 将数据与图表配置类绑定
    this.model.setData(lineData);
    // 设置图表最大的X轴显示范围，如不设置，则默认显示全部数据
    this.model.setVisibleXRangeMaximum(20);
  }

  private getLineData(): LineData {
    let values: JArrayList<EntryOhos> = new JArrayList<EntryOhos>();
    for (let i = 0; i < this.seriesData.length; i++) {

      let val = this.seriesData[i]
      values.add(new EntryOhos(i, val));
    }

    this.dataSet = new LineDataSet(values, 'DataSet');
    this.dataSet.setHighLightColor(Color.Black);
    this.dataSet.setDrawIcons(false);
    this.dataSet.setDrawValues(false)

    this.dataSet.setMode(Mode.LINEAR); //直线模式
    this.dataSet.setDrawCircles(false); //折线点画圆圈
    this.dataSet.setColorByColor(0xE4480C); //设置折线颜色

    let dataSetList: JArrayList<ILineDataSet> = new JArrayList<ILineDataSet>();
    dataSetList.add(this.dataSet);

    let lineData: LineData = new LineData(dataSetList);
    return lineData
  }

  build() {
    Column() {
      if (this.label !== '收益统计') {
        Flex({ justifyContent: FlexAlign.SpaceBetween }) {
          Text(this.name)
            .fontSize(10)
            .fontWeight(FontWeight.Regular)
            .fontColor($r('sys.color.font_secondary'))
          Text() {
            Span(this.label + '：')
              .fontColor($r('sys.color.font_secondary'))
            Span(this.rate + '%')
              .fontColor('#E4480C')
          }
          .fontSize(10)
          .fontWeight(FontWeight.Regular)
        }
      } else {
        Row() {
          Text() {
            Span('累计收益：')
              .fontColor($r('sys.color.font_secondary'))
            Span('+1875.05')
              .fontColor('#E4480C')
          }
          .fontSize(10)
          .fontWeight(FontWeight.Regular)
        }
        .width('100%')
      }

      Column() {
        LineChart({ model: this.model })
          .width('100%')
          .height('calc(100% - 12vp)')
      }
      .width('100%')
    }
    .height('100%')
    .width('100%')
  }
}