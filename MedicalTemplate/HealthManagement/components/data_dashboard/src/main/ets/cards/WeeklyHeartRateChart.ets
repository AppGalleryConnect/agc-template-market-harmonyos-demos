import { WaterfallChart } from '@ohos/mpchart';
import { WeeklyHeartRateChartVM } from '../viewmodel/charts/WeeklyHeartRateChartVM';

/**
 * @usage: 周度心率瀑布图组件，用于展示一周心率范围数据的可视化分析。主要数据结构包括WaterfallChartModel（瀑布图模型）、
 * ranges（心率范围二维数组，每个元素包含[最低值,最高值]）、currentIndex（当前选中索引）。
 * 包含if逻辑用于数据验证、边界检查和MarkerView位置计算。
 * @layout: 单一WaterfallChart组件占满整个容器。图表采用底部X轴显示周几，左侧Y轴显示心率范围0-150次/分，
 * 瀑布图显示每日心率范围区间，颜色为半透明红色。
 * @constraints: ranges数组长度必须为7，每个元素必须包含2个数值，Y轴范围固定为0-150不可修改，
 * X轴标签固定为周日到周六不可修改，瀑布图颜色固定为半透明红色(0x80FF6D6D)不可修改。
 * @isGen: true
 * @fileType: component
 * @zhName: 周度心率瀑布图组件
 * @subPage:
 * @component: WaterfallChart
 */
@ComponentV2
export default struct WeeklyHeartRateChart {
  @Local private vm: WeeklyHeartRateChartVM = new WeeklyHeartRateChartVM();
  @Param ranges: Array<[number, number]> = [];
  @Param currentIndex: number = 3;

  async aboutToAppear() {
    this.vm.initializeChart();
    if (this.ranges.length > 0) {
      this.vm.updateRanges(this.ranges);
    }
    this.vm.updateCurrentIndex(this.currentIndex);
  }

  @Monitor('currentIndex')
  onCurrentIndexChange() {
    this.vm.updateCurrentIndex(this.currentIndex);
  }

  @Monitor('ranges')
  onRangesChange() {
    if (this.ranges.length > 0) {
      this.vm.updateRanges(this.ranges);
    }
  }


  build() {
    WaterfallChart({ model: this.vm.chartModel })
      .height('100%')
      .width('100%')
  }
}

