import { BarChart } from '@ohos/mpchart';
import { WeeklyBarChartVM } from '../viewmodel/charts/WeeklyBarChartVM';

/**
 * @usage: 周度步数柱状图组件，用于展示一周七天的步数数据可视化。主要数据结构包括BarChartModel（柱状图模型）、
 * weeklySteps（周步数数组，默认7个元素）。包含if逻辑用于边界检查和MarkerView位置计算，支持自定义StepsMarkerView显示步数详情。
 * @layout: 垂直布局（Column），内部包含BarChart组件占满整个容器。图表采用底部X轴显示周几，左侧Y轴显示步数范围0-10000，柱状图居中对齐。
 * @constraints: weeklySteps数组长度必须为7，Y轴最大值固定为10000不可修改，X轴标签固定为周日到周六不可修改，
 * 柱状图颜色固定为蓝色(0xFF2B69FF)不可修改。
 * @isGen: true
 * @fileType: component
 * @zhName: 周度步数柱状图组件
 * @subPage:
 * @component: BarChart
 */
@ComponentV2
export struct WeeklyBarChart {
  @Local private vm: WeeklyBarChartVM = new WeeklyBarChartVM();
  @Param weeklySteps: number[] = [1800, 6000, 2700, 900, 7500, 2500, 4600];
  @Param dateLabels: string[] = [];
  @Param onValueSelected: (date: string, steps: number) => void = () => {
  };

  async aboutToAppear() {
    await this.vm.initializeChart();
    this.vm.setOnValueSelectedListener(this.onValueSelected);
    if (this.weeklySteps.length > 0) {
      this.vm.updateWeeklySteps(this.weeklySteps);
    }
    if (this.dateLabels.length > 0) {
      this.vm.updateDateLabels(this.dateLabels);
    }
  }

  @Monitor('weeklySteps')
  onWeeklyStepsChange() {
    if (this.weeklySteps.length > 0) {
      this.vm.updateWeeklySteps(this.weeklySteps);
    }
  }

  @Monitor('dateLabels')
  onDateLabelsChange() {
    if (this.dateLabels.length > 0) {
      this.vm.updateDateLabels(this.dateLabels);
    }
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

