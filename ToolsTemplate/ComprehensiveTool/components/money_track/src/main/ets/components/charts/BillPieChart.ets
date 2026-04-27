import {
  IAxisValueFormatter,
  JArrayList,
  PieChart,
  PieChartModel,
  PieData,
  PieDataSet,
  PieEntry,
  ValuePosition,
} from '@ohos/mpchart';
import { BillPieChartItem } from '../../commons/Types';

@ComponentV2
export struct BillPieChart {
  @Local
  model: PieChartModel = new PieChartModel();
  @Param
  chartData: BillPieChartItem[] = [];
  @Param
  colorList: number[] = [];
  @Param
  valueColor: number = 0x000000;
  @Param
  valueSize: number = 10;
  @Param
  labelColor: number = 0x000000;
  @Param
  labelSize: number = 10;
  @Param
  valueLineColor: number = 0xd0d0d0;
  @Param
  chartHeight: Length = 200;

  @Computed
  get totalValue() {
    return this.chartData.reduce((pre, cur) => pre + cur.value, 0);
  }

  @Monitor('chartData')
  refreshChart() {
    this._setData();
  }

  aboutToAppear() {
    // 初始化动画时长
    this.model.animateX(1000);
    // 使用百分比值
    this.model.setUsePercentValues(true);
    // 显示图例
    this.model.getLegend()?.setEnabled(false);
    // 显示描述
    this.model.getDescription()?.setEnabled(false);
    // 设置额外偏移量
    this.model.setExtraOffsets(12, 12, 12, 12);
    // 透明圆环颜色
    this.model.setTransparentCircleColor(Color.White);
    // 标签文字颜色
    this.model.setEntryLabelColor(this.labelColor);
    // 标签文字尺寸
    this.model.setEntryLabelTextSize(this.labelSize);
    // 中心孔半径
    this.model.setHoleRadius(75);
    // 数据的最小角度
    this.model.setMinAngleForSlices(25);
    this._setData();
  }

  // 初始化饼状图数据
  private async _setData(): Promise<void> {
    let entries: JArrayList<PieEntry> = new JArrayList<PieEntry>();

    for (let i = 0; i < this.chartData.length; i++) {
      entries.add(new PieEntry(this.chartData[i].value, this.chartData[i].label));
    }

    let dataSet: PieDataSet = new PieDataSet(entries, 'Election Results');
    // 数据项之间的间隙
    dataSet.setSliceSpace(2);
    // 引出线为饼图颜色
    dataSet.setUsingSliceColorAsValueLineColor(false);
    // 引出线距离饼图偏移距离
    dataSet.setValueLinePart1OffsetPercentage(120);
    // 引出线第一段的长度
    dataSet.setValueLinePart1Length(0.6);
    // 引出线第二段的长度
    dataSet.setValueLinePart2Length(0.4);
    // 引出线颜色
    dataSet.setValueLineColor(this.valueLineColor);
    // 百分比文字大小
    dataSet.setValueTextSize(this.valueSize);
    // 百分比文字颜色
    dataSet.setValueTextColor(this.valueColor);

    // 显示数据格式化
    dataSet.setValueFormatter(new MyAxisValueFormatter());
    // 百分比文字显示在饼图外
    dataSet.setYValuePosition(ValuePosition.OUTSIDE_SLICE);
    // 标签文字显示在饼图外
    dataSet.setXValuePosition(ValuePosition.OUTSIDE_SLICE);

    let colors: JArrayList<number> = new JArrayList();
    for (let index = 0; index < this.colorList.length; index++) {
      colors.add(this.colorList[index]);
    }
    dataSet.setColorsByList(colors);
    let data: PieData = new PieData(dataSet);
    this.model.setData(data);
  }

  build() {
    Column() {
      if (this.chartData.length) {
        PieChart({ model: this.model })
          .width('100%')
          .height('100%');
      } else {
        Image($r('app.media.ic_data_empty')).width(80).height(80)
        Text('暂无内容')
          .fontColor('#99000000')
          .fontSize(14)
          .fontWeight(FontWeight.Regular)
      }

    }
    .width('100%')
    .height(this.chartHeight)
    .alignItems(HorizontalAlign.Center)
    .justifyContent(FlexAlign.Center)
  }
}


class MyAxisValueFormatter implements IAxisValueFormatter {
  public getFormattedValue(value: number): string {
    return value.toFixed(2) + '%';
  }
}

