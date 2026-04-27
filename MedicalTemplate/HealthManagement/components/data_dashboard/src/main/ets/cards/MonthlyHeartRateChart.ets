import { WaterfallChart } from '@ohos/mpchart';
import { MonthlyHeartRateChartVM } from '../viewmodel/charts/MonthlyHeartRateChartVM';

/**
 * @usage: 月度心率瀑布图组件，用于展示月度心率范围数据的可视化分析。主要数据结构包括WaterfallChartModel（瀑布图模型）、
 * ranges（心率范围二维数组，每个元素包含[最低值,最高值]）、dateLabels（日期标签数组）、groupSizes（分组大小数组）、
 * currentIndex（当前选中索引）。包含if逻辑用于数据验证、分组处理和MarkerView位置计算。
 * @layout: 单一WaterfallChart组件占满整个容器。图表采用底部X轴显示日期分组，左侧Y轴显示心率范围0-150次/分，、
 * 瀑布图显示每日心率范围区间，颜色为半透明红色。
 * @constraints: ranges数组每个元素必须包含2个数值，dateLabels数组长度必须为5，Y轴范围固定为0-150不可修改，
 * 瀑布图颜色固定为半透明红色(0x80FF6D6D)不可修改，分组逻辑和位置计算不可修改。
 * @isGen: true
 * @fileType: component
 * @zhName: 月度心率瀑布图组件
 * @subPage:
 * @component: WaterfallChart
 */
@ComponentV2
export default struct MonthlyHeartRateChart {
  @Local private vm: MonthlyHeartRateChartVM = new MonthlyHeartRateChartVM();
  @Param ranges: Array<[number, number]> = [];
  @Param dateLabels: Array<string> = [];
  @Param groupSizes: Array<number> = [];
  @Param currentIndex: number = 4;

  async aboutToAppear() {
    this.vm.initializeChart();
    if (this.ranges.length > 0) {
      this.vm.updateRanges(this.ranges);
    }
    if (this.dateLabels.length > 0) {
      this.vm.updateDateLabels(this.dateLabels);
    }
    if (this.groupSizes.length > 0) {
      this.vm.updateGroupSizes(this.groupSizes);
    }
    this.vm.updateCurrentIndex(this.currentIndex);
  }

  @Monitor('ranges')
  onRangesChange() {
    if (this.ranges.length > 0) {
      this.vm.updateRanges(this.ranges);
    }
  }

  @Monitor('dateLabels')
  onDateLabelsChange() {
    if (this.dateLabels.length > 0) {
      this.vm.updateDateLabels(this.dateLabels);
    }
  }

  @Monitor('groupSizes')
  onGroupSizesChange() {
    if (this.groupSizes.length > 0) {
      this.vm.updateGroupSizes(this.groupSizes);
    }
  }

  @Monitor('currentIndex')
  onCurrentIndexChange() {
    this.vm.updateCurrentIndex(this.currentIndex);
  }

  build() {
    WaterfallChart({ model: this.vm.chartModel })
      .width('100%')
      .height('100%')
      .onSizeChange((_oldValue: SizeOptions, newValue: SizeOptions) => {
        if (newValue.width && typeof newValue.width === 'number' && newValue.width > 0) {
          this.vm.setChartWidth(newValue.width);
        }
      })
  }
}

