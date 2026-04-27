import { WaterfallChart } from '@ohos/mpchart';
import { ThreeMonthsHeartRateChartVM } from '../viewmodel/charts/ThreeMonthsHeartRateChartVM';

/**
 * @usage: 三个月心率瀑布图组件，用于展示三个月心率范围数据的可视化分析。主要数据结构包括WaterfallChartModel（瀑布图模型）、
 * ranges（心率范围二维数组，每个元素包含[最低值,最高值]）、monthLabels（月份标签数组）、
 * tooltipLabels（提示标签数组）、rangeText（范围文本）、currentIndex（当前选中索引）。
 * 包含if逻辑用于数据验证和MarkerView位置计算。
 * @layout: 单一WaterfallChart组件占满整个容器。图表采用底部X轴显示月份标签，左侧Y轴显示心率范围0-150次/分，
 * 瀑布图显示每日心率范围区间，颜色为半透明红色。
 * @constraints: ranges数组每个元素必须包含2个数值，monthLabels数组长度必须为3，Y轴范围固定为0-150不可修改，
 * X轴范围固定为-0.5-3.5不可修改，瀑布图颜色固定为半透明红色(0x80FF6D6D)不可修改。
 * @isGen: true
 * @fileType: component
 * @zhName: 三个月心率瀑布图组件
 * @subPage:
 * @component: WaterfallChart
 */
@ComponentV2
export default struct ThreeMonthsHeartRateChart {
  @Local private vm: ThreeMonthsHeartRateChartVM = new ThreeMonthsHeartRateChartVM();
  @Param ranges: Array<[number, number]> = [];
  @Param monthLabels: Array<string> = [];
  @Param rangeText: string = '';
  @Param currentIndex: number = 4;
  @Param tooltipLabels: Array<string> = [];

  async aboutToAppear() {
    this.vm.initializeChart();
    this.vm.updateRanges(this.ranges);
    this.vm.updateMonthLabels(this.monthLabels);
    this.vm.updateRangeText(this.rangeText);
    this.vm.updateCurrentIndex(this.currentIndex);
    this.vm.updateTooltipLabels(this.tooltipLabels);
  }

  @Monitor('monthLabels')
  onMonthLabelsChange() {
    this.vm.updateMonthLabels(this.monthLabels);
  }

  @Monitor('ranges')
  onRangesChange() {
    this.vm.updateRanges(this.ranges);
  }


  @Monitor('currentIndex')
  onCurrentIndexChange() {
    this.vm.updateCurrentIndex(this.currentIndex);
  }

  @Monitor('tooltipLabels')
  onTooltipLabelsChange() {
    this.vm.updateTooltipLabels(this.tooltipLabels);
  }


  build() {
    WaterfallChart({ model: this.vm.chartModel })
      .height('100%')
      .width('100%')
  }
}

