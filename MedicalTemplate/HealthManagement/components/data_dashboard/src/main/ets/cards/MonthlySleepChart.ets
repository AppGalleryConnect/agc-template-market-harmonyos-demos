import { BarChart } from '@ohos/mpchart';
import { MonthlySleepChartVM } from '../viewmodel/charts/MonthlySleepChartVM';

/**
 * @usage: 月度睡眠堆叠柱状图组件，用于展示月度睡眠阶段数据的可视化分析。主要数据结构包括BarChartModel（柱状图模型）、
 * sleepData（睡眠数据二维数组，每个元素包含[深睡,浅睡,快速眼动,清醒]四个值）、labels（日期标签数组）、groupSizes（分组大小数组）。
 * 包含if逻辑用于分组处理和数据验证。
 * @layout: 单一BarChart组件，高度固定220。图表采用底部X轴显示日期，左侧Y轴显示时长范围0-12小时，
 * 堆叠柱状图显示四种睡眠阶段，颜色分别为深蓝、浅蓝、黄色、橙色。
 * @constraints: sleepData数组每个元素必须包含4个数值，Y轴范围固定为0-12不可修改，
 * 睡眠阶段颜色固定不可修改（深睡深蓝、浅睡浅蓝、快速眼动黄色、清醒橙色），堆叠标签固定为['深睡','浅睡','快速眼动','清醒']不可修改。
 * @isGen: true
 * @fileType: component
 * @zhName: 月度睡眠堆叠柱状图组件
 * @subPage:
 * @component: BarChart
 */
@ComponentV2
export struct MonthlySleepChart {
  @Local private vm: MonthlySleepChartVM = new MonthlySleepChartVM();
  @Param sleepData: Array<[number, number, number, number]> = [];
  @Param labels: Array<string> = [];
  @Param groupSizes: Array<number> = [];
  @Param onValueSelected: (date: string, totalHours: number, totalMinutes: number) => void = () => {
  };

  async aboutToAppear() {
    this.vm.initializeChart();
    this.vm.setOnValueSelectedListener(this.onValueSelected);
    if (this.sleepData.length > 0) {
      this.vm.updateSleepData(this.sleepData);
    }
    if (this.labels.length > 0) {
      this.vm.updateLabels(this.labels);
    }
    if (this.groupSizes.length > 0) {
      this.vm.updateGroupSizes(this.groupSizes);
    }
  }

  @Monitor('sleepData')
  onSleepDataChange() {
    if (this.sleepData.length > 0) {
      this.vm.updateSleepData(this.sleepData);
    }
  }

  @Monitor('labels')
  onLabelsChange() {
    if (this.labels.length > 0) {
      this.vm.updateLabels(this.labels);
    }
  }

  @Monitor('groupSizes')
  onGroupSizesChange() {
    if (this.groupSizes.length > 0) {
      this.vm.updateGroupSizes(this.groupSizes);
    }
  }

  build() {
    BarChart({ model: this.vm.chartModel })
      .width('100%')
      .height(220)
  }
}

