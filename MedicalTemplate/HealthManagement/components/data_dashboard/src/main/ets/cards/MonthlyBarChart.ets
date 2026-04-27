import { BarChart } from '@ohos/mpchart';
import { MonthlyBarChartVM } from '../viewmodel/charts/MonthlyBarChartVM';

/**
 * @usage: 月度步数柱状图组件，用于展示月度步数数据的可视化图表。主要数据结构包括BarChartModel（柱状图模型）、
 * monthlySteps（月度步数数组）、dateLabels（日期标签数组）。包含if逻辑用于边界检查和数据验证，支持自定义MarkerView显示详细信息。
 * @layout: 垂直布局（Column），内部包含BarChart组件占满整个容器。图表采用底部X轴显示日期，右侧Y轴显示步数范围0-1500，柱状图居中对齐。
 * @constraints: monthlySteps数组长度必须与dateLabels数组长度一致，Y轴最大值固定为1500不可修改，
 * 柱状图颜色固定为蓝色(0xFF2B69FF)不可修改，MarkerView样式和位置计算逻辑不可修改。
 * @isGen: true
 * @fileType: component
 * @zhName: 月度步数柱状图组件
 * @subPage:
 * @component: BarChart
 */
@ComponentV2
export default struct MonthlyBarChart {
  @Local private vm: MonthlyBarChartVM = new MonthlyBarChartVM();
  @Param monthlySteps: number[] = [];
  @Param dateLabels: string[] = [];
  @Param onValueSelected: (date: string, steps: number) => void = () => {
  };

  async aboutToAppear() {
    await this.vm.initializeChart();
    this.vm.setOnValueSelectedListener(this.onValueSelected);
    this.vm.updateMonthlySteps(this.monthlySteps);
    this.vm.updateDateLabels(this.dateLabels);
  }

  @Monitor('monthlySteps')
  onMonthlyStepsChange() {
    this.vm.updateMonthlySteps(this.monthlySteps);
  }

  @Monitor('dateLabels')
  onDateLabelsChange() {
    this.vm.updateDateLabels(this.dateLabels);
  }

  build() {
    Column() {
      BarChart({ model: this.vm.chartModel })
        .width('100%')
        .height('100%')
    }
    .width('100%')
    .height('100%')
  }
}

