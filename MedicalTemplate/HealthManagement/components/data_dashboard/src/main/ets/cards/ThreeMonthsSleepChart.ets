import { BarChart } from '@ohos/mpchart';
import { ThreeMonthsSleepChartVM } from '../viewmodel/charts/ThreeMonthsSleepChartVM';

/**
 * @usage: 三个月睡眠堆叠柱状图组件，用于展示三个月睡眠阶段数据的可视化分析。主要数据结构包括BarChartModel（柱状图模型）、
 * sleepData（睡眠数据二维数组，每个元素包含[深睡,浅睡,快速眼动,清醒]四个值）、labels（月份标签数组）、groupSizes（分组大小数组）。
 * 包含if逻辑用于分组处理和数据验证。
 * @layout: 单一BarChart组件，高度固定220。图表采用底部X轴显示月份分组，左侧Y轴显示时长范围0-12小时，
 * 堆叠柱状图显示四种睡眠阶段，颜色分别为深蓝、浅蓝、黄色、橙色。
 * @constraints: sleepData数组每个元素必须包含4个数值，labels数组长度必须为3，Y轴范围固定为0-12不可修改，
 * X轴范围固定为0.3-5.5不可修改，睡眠阶段颜色固定不可修改（深睡深蓝、浅睡浅蓝、快速眼动黄色、清醒橙色），
 * 堆叠标签固定为['深睡','浅睡','快速眼动','清醒']不可修改。
 * @isGen: true
 * @fileType: component
 * @zhName: 三个月睡眠堆叠柱状图组件
 * @subPage:
 * @component: BarChart
 */
@ComponentV2
export struct ThreeMonthsSleepChart {
  @Local private vm: ThreeMonthsSleepChartVM = new ThreeMonthsSleepChartVM();
  @Param sleepData: Array<[number, number, number, number]> = [];
  @Param labels: Array<string> = [];
  @Param groupSizes: Array<number> = [];
  @Param onValueSelected: (date: string, totalHours: number, totalMinutes: number) => void = () => {
  };

  async aboutToAppear() {
    this.vm.initializeChart();
    this.vm.setOnValueSelectedListener(this.onValueSelected);
    this.vm.updateSleepData(this.sleepData);
    this.vm.updateLabels(this.labels);
    this.vm.updateGroupSizes(this.groupSizes);
  }

  build() {
    BarChart({ model: this.vm.chartModel })
      .width('100%')
      .height(220)
  }
}

