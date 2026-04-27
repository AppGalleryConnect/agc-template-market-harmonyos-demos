import { BarChart } from '@ohos/mpchart';
import { WeeklySleepChartVM } from '../viewmodel/charts/WeeklySleepChartVM';

/**
 * @usage: 周度睡眠堆叠柱状图组件，用于展示一周睡眠阶段数据的可视化分析。主要数据结构包括BarChartModel（柱状图模型）、
 * sleepData（睡眠数据二维数组，每个元素包含[深睡,浅睡,快速眼动,清醒]四个值）。包含if逻辑用于数据验证和模型初始化。
 * @layout: 单一BarChart组件，高度固定220。图表采用底部X轴显示周几，左侧Y轴显示时长范围0-12小时，
 * 堆叠柱状图显示四种睡眠阶段，颜色分别为深蓝、浅蓝、黄色、橙色。
 * @constraints: sleepData数组长度必须为7，每个元素必须包含4个数值，Y轴范围固定为0-12不可修改，X轴标签固定为周日到周六不可修改，
 * 睡眠阶段颜色固定不可修改（深睡深蓝、浅睡浅蓝、快速眼动黄色、清醒橙色），堆叠标签固定为['深睡','浅睡','快速眼动','清醒']不可修改。
 * @isGen: true
 * @fileType: component
 * @zhName: 周度睡眠堆叠柱状图组件
 * @subPage:
 * @component: BarChart
 */
@ComponentV2
export struct WeeklySleepChart {
  @Local private vm: WeeklySleepChartVM = new WeeklySleepChartVM();
  @Param sleepData: Array<[number, number, number, number]> = [];
  @Param dateLabels: string[] = [];
  @Param onValueSelected: (date: string, totalHours: number, totalMinutes: number) => void = () => {
  };

  async aboutToAppear() {
    this.vm.initializeChart();
    this.vm.setOnValueSelectedListener(this.onValueSelected);
    if (this.sleepData.length > 0) {
      this.vm.updateSleepData(this.sleepData);
    }
    if (this.dateLabels.length > 0) {
      this.vm.updateDateLabels(this.dateLabels);
    }
  }

  @Monitor('sleepData')
  onSleepDataChange() {
    if (this.sleepData.length > 0) {
      this.vm.updateSleepData(this.sleepData);
    }
  }

  @Monitor('dateLabels')
  onDateLabelsChange() {
    if (this.dateLabels.length > 0) {
      this.vm.updateDateLabels(this.dateLabels);
    }
  }

  build() {
    BarChart({ model: this.vm.chartModel })
      .width('100%')
      .height(220)
  }
}

